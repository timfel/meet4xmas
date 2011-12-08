package lib.java;

public class Appointment implements java.io.Serializable {
  public int identifier;
  public int locationType; // 0 -> xmas market
  public Location location;
  public String[] invitees;
  public String[] participants;

  public String toString() {
    StringBuilder sb = new StringBuilder("Appointment(");
    sb.append("@identifier: ").append(identifier).append(", ");
    sb.append("@locationType: ").append(locationType).append(", ");
    sb.append("@location: ").append(location).append(", ");
    sb.append("@invitees: [");
    for(int i = 0; i < invitees.length; i++) {
            sb.append(invitees[i]);
            if(i < invitees.length - 1) sb.append(", ");
    }
    sb.append("], ");
    sb.append("@participants: [");
    for(int i = 0; i < participants.length; i++) {
            sb.append(participants[i]);
            if(i < participants.length - 1) sb.append(", ");
    }
    sb.append("], ");
    return sb.toString();
  }
}
