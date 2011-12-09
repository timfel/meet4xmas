package lib.java;

import lib.java.util.StringUtil;

public class Appointment implements java.io.Serializable {
  public int identifier;
  public Location.LocationType locationType;
  public Location location;
  public String[] invitees;
  public String[] participants;

  public String toString() {
    StringBuilder sb = new StringBuilder("Appointment(");
    sb.append("@identifier: ").append(identifier).append(", ");
    sb.append("@locationType: ").append(locationType).append(", ");
    sb.append("@location: ").append(StringUtil.ValueOrNullToString(location)).append(", ");
    sb.append("@invitees: ").append(StringUtil.ArrayOrNullToString(invitees, new StringUtil.StringArrayElementVisitor())).append(", ");
    sb.append("@participants: ").append(StringUtil.ArrayOrNullToString(participants, new StringUtil.StringArrayElementVisitor()));
    return sb.toString();
  }
}
