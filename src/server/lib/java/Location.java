package lib.java;

public class Location implements java.io.Serializable {
  public double longitude;
  public double latitude;
  public String title;
  public String description;

  public String toString() {
    StringBuilder sb = new StringBuilder("Location(");
    sb.append("@longitude: ").append(longitude).append(", ");
    sb.append("@latitude: ").append(latitude).append(", ");
    sb.append("@title: ").append(title).append(", ");
    sb.append("@description: ").append(description);
    sb.append(")");
    return sb.toString();
  }
}
