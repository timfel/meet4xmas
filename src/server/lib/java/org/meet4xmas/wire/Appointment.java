package org.meet4xmas.wire;

import org.meet4xmas.util.StringUtil;

public class Appointment implements java.io.Serializable {
  public int identifier;
  public String creator; // userId
  public int locationType; // use values in Location.LocationType
  public Location location;
  public Participant[] participants;
  public String message;

  public String toString() {
    StringBuilder sb = new StringBuilder("Appointment(");
    sb.append("@identifier: ").append(identifier).append(", ");
    sb.append("@locationType: ").append(Location.LocationType.toString(locationType)).append(", ");
    sb.append("@location: ").append(StringUtil.ValueOrNullToString(location)).append(", ");
    sb.append("@participants: ").append(StringUtil.ArrayOrNullToString(participants, new StringUtil.StringArrayElementVisitor()));
    return sb.toString();
  }
}
