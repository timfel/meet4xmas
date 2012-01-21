using System;
using System.Text;

namespace org.meet4xmas.wire
{
    public partial class NotificationServiceInfo
    {
        public NotificationServiceInfo() : base() { }
        public NotificationServiceInfo(Uri channelUri)
        {
            serviceType = NotificationServiceType.MPNS;
            deviceId = Encoding.UTF8.GetBytes(channelUri.ToString());
        }
    }
}
