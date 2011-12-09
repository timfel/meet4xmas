package lib.java;

import lib.java.util.StringUtil;

public class TravelPlan implements java.io.Serializable {
  public static enum TravelType {
    Car(0),
    Walk(1),
    PublicTransport(2);

    private int value;
    private TravelType(int value) { this.value = value; }
    public int getValue() { return value; }
  }

  public int appointmentId;
  public Location[] path;
  public TravelType travelType;

  public String toString() {
    StringBuilder sb = new StringBuilder("TravelPlan(");
    sb.append("@appointmentId: ").append(appointmentId).append(", ");
    sb.append("@path: ").append(StringUtil.ArrayOrNullToString(path)).append(", ");
    sb.append("@travelType: ").append(travelType);
    sb.append(")");
    return sb.toString();
  }
}
