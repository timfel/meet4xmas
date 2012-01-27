using System;
using Meet4Xmas;
using System.Collections.Generic;
using System.Linq;

namespace org.meet4xmas.wire
{
    public partial class Account : Participant
    {
        const string ServiceCallCreate = "registerAccount";
        const string ServiceCallDelete = "deleteAccount";

        public List<int> AppointmentIds { get; set; }

        public void Delete(Action callback, Action<ErrorInfo> errorCallback)
        {
            ServiceCall.Invoke(ServiceCallDelete,
                (Response ar) =>
                {
                    if (ar.success) {
                        callback();
                    } else {
                        errorCallback(ar.error);
                    }
                }, this.userId);
        }

        /// <summary>
        /// Creates a new User account on the server.
        /// </summary>
        /// <param name="userId">The new user name</param>
        /// <param name="cb">A callback to pass the created account to</param>
        /// <param name="errorCb">An error callback that will receive ErrorInfo</param>
        public static void Create(string userId, Action<Account> callback, Action<ErrorInfo> errorCallback)
        {
            ServiceCall.Invoke(ServiceCallCreate,
                (Response result) =>
                {
                    if (!result.success) {
                        errorCallback(result.error);
                    } else {
                        Account a = new Account();
                        if (result.payload != null) {
                            var ids = from id in (result.payload as List<Object>)
                                      where (id != null)
                                      select (Convert.ToInt32(id));
                            a.AppointmentIds = new List<int>(ids);
                        } else {
                            a.AppointmentIds = new List<int>();
                        }
                        a.userId = userId;
                        a.OpenNotificationChannel();
                        callback(a);
                    }
                }, userId, null);
        }

        // Should be called whenever this account is loaded from cold storage
        public void Loaded()
        {
            OpenNotificationChannel();
        }
    }
}
