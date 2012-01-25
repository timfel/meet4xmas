package org.meet4xmas.wire;

import org.meet4xmas.util.StringUtil;

public class NotificationServiceInfo implements java.io.Serializable {
	public static class NotificationServiceType {
    public final static int APNS = 0; // Apple Push Notification Service (http://developer.apple.com/library/mac/documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/ApplePushService/ApplePushService.html)
    public final static int MPNS = 1; // Push Notifications for Windows Phone (http://msdn.microsoft.com/en-us/library/ff402537(v=vs.92).aspx)
    public final static int C2DM = 2; // Google Android C2DM (http://code.google.com/android/c2dm/)

    public static String toString(int servicetype) {
      switch(servicetype) {
        case APNS: return "APNS";
        case MPNS: return "MPNS";
        case C2DM: return "C2DM";
        default: return "Invalid";
      }
    }
  }

  public int serviceType; // use values of NotificationServiceType
  public byte[] deviceId; // APNS: device token (raw); MPNS: notification channel URI (encoded as UTF-8); Google Android C2DM: registration ID (encoded as UTF-8)
  
  public String toString() {
    StringBuilder sb = new StringBuilder("NotificationServiceInfo(");
    sb.append("@serviceType: ").append(NotificationServiceType.toString(serviceType)).append(", ");
    sb.append("@deviceId: ").append(StringUtil.ValueOrNullToString(deviceId));
    sb.append(")");
    return sb.toString();
  }
}
