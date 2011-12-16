using System;

namespace org.meet4xmas.wire
{
    public partial class ErrorInfo
    {
        public ErrorInfo() { }

        public ErrorInfo(int code, string msg)
        {
            this.code = code;
            this.message = msg;
        }
    }
}
