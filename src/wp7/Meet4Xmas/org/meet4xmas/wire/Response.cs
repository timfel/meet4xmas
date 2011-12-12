using System.Text;

namespace org.meet4xmas.wire
{
    public class Response
    {
        public bool success;
        public ErrorInfo error;
        public object payload;

        public override string ToString()
        {
            StringBuilder sb = new StringBuilder("<Response: ");
            sb.Append("@success: ").Append(success).Append(", ");
            sb.Append("@error: ").Append(error.ToString()).Append(",");
            sb.Append("@payload: ").Append(payload.ToString()).Append(">");
            return sb.ToString();
        }
    }
}
