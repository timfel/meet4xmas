package lib.java;

public interface Traveller {
  public String echo(String msg);
  public int registerAccount(String userId);
  public int createAppointment(String userId, int travelType, Location location, String[] invitees, int locationType, String userMessage);
  public Appointment getAppointment(int appointmentId);
  public TravelPlan getTravelPlan(int appointmentId, int travelType, Location location);
  public TravelPlan joinAppointment(int appointmentId, String userId, int travelType, Location location);
  public int declineAppointment(int appointmentId, String userId, String userMessage);
  public int finalizeAppointment(int appointmentId);
}
