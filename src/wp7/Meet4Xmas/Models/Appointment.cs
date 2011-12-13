using System;
using Meet4Xmas;
using System.Collections.Generic;

namespace org.meet4xmas.wire
{
    public partial class Appointment : Model
    {
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
            Appointment a = new Appointment(user, invitees, locType, travelType);
            a.Create(msg, cb, errorCb);
        }

        public Appointment() { }

        private Appointment(Account user, Participant[] invitees, int locType, int travelType) {
            this.creator = user.userId;
            this.locationType = locType;
            this.invitees = invitees;
            this.travelType = travelType;
            this.isFinal = false;
        }

        private void Create(string msg, Action<Appointment> callback, Action<ErrorInfo> errorCallback)
        {
            this.callback = callback;
            this.errorCallback = errorCallback;

            List<string> inviteeNames = new List<string>();
            foreach(Participant invitee in invitees)
            {
                inviteeNames.Add(invitee.userId);
            }
            
            Gps.NewFromGps((Location loc) =>
            {
                if (loc == null)
                {
                    errorCallback(new ErrorInfo(-1, "Access to GPS denied."));
                }
                else
                {
                    ServiceCall.Invoke("createAppointment", new AsyncCallback(FinishCreate),
                        creator, travelType, loc, inviteeNames.ToArray(), locationType, msg);
                }
            });
        }

        public void FinishCreate(IAsyncResult ar)
        {
            Response result = (Response)ar.AsyncState;
            UIDispatcher.BeginInvoke(() =>
            {
                if (!result.success)
                {
                    errorCallback.Invoke(result.error);
                }
                else
                {
                    this.identifier = (int)result.payload;
                    callback.Invoke(this);
                }
            });
        }

        private Action<Appointment> callback;
        private Action<ErrorInfo> errorCallback;
        private Participant[] invitees;
        private int travelType;
    }
}
