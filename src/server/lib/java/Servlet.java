package lib.java;

public interface Servlet {
  public ResponseBody registerAccount(String userId);
  public ResponseBody createAppointment(String userId, int travelType, Location location, String[] invitees, int locationType, String userMessage);
  public ResponseBody getAppointment(int appointmentId);
  public ResponseBody getTravelPlan(int appointmentId, int travelType, Location location);
  public ResponseBody joinAppointment(int appointmentId, String userId, int travelType, Location location);
  public ResponseBody declineAppointment(int appointmentId, String userId, String userMessage);
  public ResponseBody finalizeAppointment(int appointmentId);
}
