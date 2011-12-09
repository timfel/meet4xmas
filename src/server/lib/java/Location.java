package lib.java;

import lib.java.util.StringUtil;

public class Location implements java.io.Serializable {
  public static enum LocationType {
    ChristmasMarket(0);

    private int value;
    private LocationType(int value) { this.value = value; }
    public int getValue() { return value; }
  }

  public double longitude;
  public double latitude;
  public String title;
  public String description;

  public String toString() {
    StringBuilder sb = new StringBuilder("Location(");
    sb.append("@longitude: ").append(longitude).append(", ");
    sb.append("@latitude: ").append(latitude).append(", ");
    sb.append("@title: ").append(StringUtil.ValueOrNullToString(title)).append(", ");
    sb.append("@description: ").append(StringUtil.ValueOrNullToString(description));
    sb.append(")");
    return sb.toString();
  }
}
