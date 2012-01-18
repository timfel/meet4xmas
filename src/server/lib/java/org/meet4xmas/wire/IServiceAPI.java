package org.meet4xmas.wire;

public interface IServiceAPI {
	public Response registerAccount(String userId);
  public Response registerAccount(String userId, NotificationServiceInfo notificationServiceInfo); // new in version 2
  public Response deleteAccount(String userId);
  public Response createAppointment(String userId, int travelType, Location location, String[] invitees, int locationType, String userMessage);
  public Response getAppointment(int appointmentId);
  public Response getTravelPlan(int appointmentId, int travelType, Location location);
  public Response joinAppointment(int appointmentId, String userId, int travelType, Location location);
  public Response declineAppointment(int appointmentId, String userId);
  public Response finalizeAppointment(int appointmentId);
}
