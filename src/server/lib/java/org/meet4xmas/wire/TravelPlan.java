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

  public Location[] path;

  public String toString() {
    StringBuilder sb = new StringBuilder("TravelPlan(");
    sb.append("@path: ").append(StringUtil.ArrayOrNullToString(path));
    sb.append(")");
    return sb.toString();
  }
}
