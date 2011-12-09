package org.meet4xmas.wire;

import org.meet4xmas.util.StringUtil;

public class TravelPlan implements java.io.Serializable {
  public static class TravelType {
    public final static int Car = 0;
    public final static int Walk = 1;
    public final static int PublicTransport = 2;

    public static String toString(int travelType) {
      switch(travelType) {
        case Car: return "Car";
        case Walk: return "Walk";
        case PublicTransport: return "PublicTransport";
        default: return "Invalid";
      }
    }
  }

  public int appointmentId;
  public Location[] path;
  public int travelType; // use values in TravelType

  public String toString() {
    StringBuilder sb = new StringBuilder("TravelPlan(");
    sb.append("@appointmentId: ").append(appointmentId).append(", ");
    sb.append("@path: ").append(StringUtil.ArrayOrNullToString(path)).append(", ");
    sb.append("@travelType: ").append(TravelType.toString(travelType));
    sb.append(")");
    return sb.toString();
  }
}
