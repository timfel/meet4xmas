using System;
using Meet4Xmas;

namespace org.meet4xmas.wire
{
    public class Account : Participant
    {
        /// <summary>
        /// Creates a new User account on the server.
        /// </summary>
        /// <param name="userId">The new user name</param>
        /// <param name="cb">A callback to pass the created account to</param>
        /// <param name="errorCb">An error callback that will receive ErrorInfo</param>
        public static void Create(string userId, Action<Account> cb, Action<ErrorInfo> errorCb)
        {
            Account a = new Account(userId);
            a.Create(cb, errorCb);
        }

        private Account(string userId) {
            this.userId = userId;
        }

        private void Create(Action<Account> callback, Action<ErrorInfo> errorCallback)
        {
            this.callback = callback;
            this.errorCallback = errorCallback;
            ServiceCall.Invoke("registerAccount", new AsyncCallback(FinishCreate), this.userId);
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
                    callback.Invoke(this);
                }
            });
        }

        private Action<Account> callback;
        private Action<ErrorInfo> errorCallback;
    }
}
