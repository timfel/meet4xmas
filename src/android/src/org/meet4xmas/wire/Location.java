package org.meet4xmas.wire;

import org.meet4xmas.util.StringUtil;

public class Location implements java.io.Serializable {
  public static class LocationType {
    public final static int ChristmasMarket = 0;

    public static String toString(int locationType) {
      switch(locationType) {
        case ChristmasMarket: return "ChristmasMarket";
        default: return "Invalid";
      }
    }
  }

  public double longitude;
  public double latitude;
  public String title;
  public String description;

  public String toString() {
    StringBuilder sb = new StringBuilder("Location(");
    sb.append("@longitude: ").append(longitude).append(", ");
    sb.append("@latitude: ").append(latitude).append(", ");
    sb.append("@title: ").append(StringUtil.ValueOrNullToString(title, true)).append(", ");
    sb.append("@description: ").append(StringUtil.ValueOrNullToString(description, true));
    sb.append(")");
    return sb.toString();
  }
}
