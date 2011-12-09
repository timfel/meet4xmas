package org.meet4xmas.wire;

import org.meet4xmas.util.StringUtil;

public class Participant implements java.io.Serializable {
  public static class ParticipationStatus {
    public final static int Pending = 0;
    public final static int Joined = 1;
    public final static int Declined = 2;

    public static String toString(int status) {
      switch(status) {
        case Pending: return "Pending";
        case Joined: return "Joined";
        case Declined: return "Declined";
        default: return "Invalid";
      }
    }
  }

  public String userId;
  public int status; // use values in ParticipationStatus

  public String toString() {
    StringBuilder sb = new StringBuilder("Participant(");
    sb.append("@userId: ").append(StringUtil.ValueOrNullToString(userId)).append(", ");
    sb.append("@status: ").append(ParticipationStatus.toString(status));
    return sb.toString();
  }
}
