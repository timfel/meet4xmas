using System;
using Meet4Xmas;
using System.Collections.Generic;
using System.Linq;

namespace org.meet4xmas.wire
{
    public partial class Appointment
    {
        const string ServiceCallCreate = "createAppointment";
        const string ServiceCallFind = "getAppointment";
        const string ServiceCallGetTravelPlan = "getTravelPlan";
        const string ServiceCallJoin = "joinAppointment";
        const string ServiceCallDecline = "declineAppointment";
        const string ServiceCallFinalize = "finalizeAppointment";

        public string MessageString { get { return message; } }
        public string ParticipantsString
        {
            get
            {
                IEnumerable<string> list = from p in participants select p.userId;
                return list.Aggregate((acc, next) => acc + " " + next);
            }
        }
        public TravelPlan TravelPlan;
        public int TravelType;

        /// <summary>
        /// Create a new Appointment
        /// </summary>
        /// <param name="user">The creating user</param>
        /// <param name="travelType">An integer defined on TravelPlan.TravelType</param>
        /// <param name="loc">GPS location</param>
        /// <param name="invitees">A list of participants</param>
        /// <param name="locType">The kind of location to look for, defined on Location.LocationType</param>
        /// <param name="msg">A message to include in the invitations</param>
        /// <param name="cb">The callback to pass the created Appointment to</param>
        /// <param name="errorCb">An error callback</param>
        public static void Create(Account user, int travelType, Participant[] invitees,
                int locType, string msg, Action<Appointment> cb, Action<ErrorInfo> errorCb)
        {
            List<string> inviteeNames = new List<string>();
            foreach (Participant invitee in invitees) {
                inviteeNames.Add(invitee.userId);
            }
            Appointment.Create(user, travelType, invitees, inviteeNames.ToArray(), locType, msg, cb, errorCb);
        }

        public static void Create(Account user, int travelType, Participant[] invitees, string[] inviteeNames,
                int locType, string msg, Action<Appointment> cb, Action<ErrorInfo> errorCb)
        {
            withGpsLocationDo((Location loc) =>
            {
                ServiceCall.Invoke(ServiceCallCreate,
                        (Response result) =>
                        {
                            if (!result.success) {
                                errorCb(result.error);
                            } else {
                                Appointment.Find(Convert.ToInt32(result.payload), cb, errorCb);
                            };
                        }, user.userId, travelType, loc, inviteeNames, locType, msg);
            }, errorCb);
        }

        public static void Find(int id, Action<Appointment> cb, Action<ErrorInfo> errorCb)
        {
            ServiceCall.Invoke(ServiceCallFind,
                (Response result) =>
                {
                    if (!result.success) {
                        errorCb(result.error);
                    } else {
                        cb((Appointment)result.payload);
                    }
                }, id);
        }

        public void GetTravelPlan(int travelType, Action<TravelPlan> cb, Action<ErrorInfo> errorCb)
        {
            withGpsLocationDo((Location loc) =>
            {
                ServiceCall.Invoke(ServiceCallGetTravelPlan,
                    (Response result) =>
                    {
                        if (!result.success)
                        {
                            errorCb(result.error);
                        }
                        else
                        {
                            Location[] path = ((TravelPlan)result.payload).path;
                            if (path.Length == 0) {
                                errorCb(new ErrorInfo(-1, "Invalid TravelPlan. No path data."));
                            } else {
                                this.location = path[path.Length - 1];
                                this.TravelPlan = result.payload as TravelPlan;
                                this.TravelType = travelType;
                                cb((TravelPlan)result.payload);
                            }
                        }
                    }, this.identifier, travelType, loc);
            }, errorCb);
        }

        public void Finalize(Action cb, Action<ErrorInfo> errorCb)
        {
            ServiceCall.Invoke(ServiceCallFinalize,
                (Response result) =>
                {
                    if (!result.success) {
                        errorCb(result.error);
                    } else {
                        this.isFinal = true;
                        cb();
                    }
                }, this.identifier);
        }

        public void Join(Account user, int travelType, Action cb, Action<ErrorInfo> errorCb)
        {
            withGpsLocationDo((Location loc) =>
            {
                ServiceCall.Invoke(ServiceCallJoin,
                    (Response result) =>
                    {
                        if (!result.success) {
                            errorCb(result.error);
                        } else {
                            foreach (Participant p in this.participants) {
                                if (p.Equals(user)) {
                                    p.status = Participant.ParticipationStatus.Joined;
                                    break;
                                }
                            }
                            cb();
                        }
                    }, this.identifier, user.userId, travelType, loc);
            }, errorCb);
        }

        public void Decline(Account user, Action cb, Action<ErrorInfo> errorCb)
        {
            ServiceCall.Invoke(ServiceCallDecline,
                (Response result) =>
                {
                    if (!result.success) {
                        errorCb(result.error);
                    } else {
                        foreach (Participant p in this.participants) {
                            if (p.Equals(user)) {
                                p.status = Participant.ParticipationStatus.Declined;
                                break;
                            }
                        }
                        cb();
                    }
                }, this.identifier, user.userId);
        }

        private static void withGpsLocationDo(Action<Location> cb, Action<ErrorInfo> errorCb)
        {
            Gps.NewFromGps((Location loc) =>
            {
                if (loc == null) {
                    errorCb(new ErrorInfo(-1, "Access to GPS denied."));
                } else {
                    cb(loc);
                }
            });
        }
    }
}
