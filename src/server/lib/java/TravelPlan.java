package lib.java;

public interface TravelPlan {
  public int appointmentId();
  public Location[] path();
  public int travelType(); // 0 = car, 1 = by foot, 2 = public transportation
}
