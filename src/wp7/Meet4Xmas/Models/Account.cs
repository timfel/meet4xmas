using System;
using Meet4Xmas;

namespace org.meet4xmas.wire
{
    public partial class Account : Participant
    {
        const string ServiceCallCreate = "registerAccount";
        const string ServiceCallDelete = "deleteAccount";

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
                        a.userId = userId;
                        a.OpenNotificationChannel();
                        callback(a);
                    }
                }, userId, null);
        }
    }
}
