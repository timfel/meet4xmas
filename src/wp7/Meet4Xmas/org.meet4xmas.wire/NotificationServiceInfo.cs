using System.Text;

namespace org.meet4xmas.wire
{
    public partial class NotificationServiceInfo
    {
        public static class NotificationServiceType
        {
            public const int APNS = 0;
            public const int MPNS = 1;
            public const int C2DM = 2;
        }

        public int serviceType;
        public byte[] deviceId; // UTF-8 encoded Channel URI

        public override string ToString()
        {
            StringBuilder sb = new StringBuilder("<NotificationServiceInfo ");
            sb.Append("@serviceType: ").Append(serviceType).Append(", ").
                Append("@deviceId: ").Append(deviceId).Append(">");
            return sb.ToString();
        }
    }
}
