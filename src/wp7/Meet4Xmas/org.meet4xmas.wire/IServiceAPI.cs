
namespace org.meet4xmas.wire
{
    public interface IServiceAPI
    {
        Response registerAccount(string userId, object ignored /*TODO*/);
        Response deleteAccount(string userId);
        Response createAppointment(string userId, int travelType, Location location, string[] invitees, int locationType, string userMessage);
        Response getAppointment(int appointmentId);
        Response getTravelPlan(int appointmentId, int travelType, Location location);
        Response joinAppointment(int appointmentId, string userId, int travelType, Location location);
        Response declineAppointment(int appointmentId, string userId);
        Response finalizeAppointment(int appointmentId);
    }
}
