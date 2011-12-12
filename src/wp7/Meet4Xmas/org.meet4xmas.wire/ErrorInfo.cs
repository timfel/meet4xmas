using System.Text;

namespace org.meet4xmas.wire
{
    public class ErrorInfo
    {
        public int code;
        public string message;

        public override string ToString()
        {
            StringBuilder sb = new StringBuilder("<ErrorInfo: ");
            sb.Append("@code: ").Append(code).Append(", @message: ").Append(message).Append(">");
            return sb.ToString();
        }
    }
}
