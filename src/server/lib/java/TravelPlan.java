package lib.java;

public class TravelPlan implements java.io.Serializable {
  public int appointmentId;
  public Location[] path;
  public int travelType; // 0 = car, 1 = by foot, 2 = public transportation

  public String toString() {
    StringBuilder sb = new StringBuilder("TravelPlan(");
    sb.append("@appointmentId: ").append(appointmentId).append(", ");
    sb.append("@path: [");
    for(int i = 0; i < path.length; i++) {
      sb.append(path[i]);
      if(i < path.length - 1) sb.append(", ");
    }
    sb.append("], ");
    sb.append("@travelType: ").append(travelType);
    sb.append(")");
    return sb.toString();
  }
}
