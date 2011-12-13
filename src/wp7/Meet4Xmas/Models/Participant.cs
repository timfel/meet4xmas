using System;

namespace org.meet4xmas.wire
{
    public partial class Participant : Model
    {
        public static void Find(string userId, Action<Account> cb, Action<ErrorInfo> errorCb)
        {
        }

        private Action<Account> callback;
        private Action<ErrorInfo> errorCallback;
    }
}
