using System.Text;

namespace org.meet4xmas.wire
{
    public partial class Appointment
    {
        public int identifier;
        public string creator; // userId
        public int locationType; // use values in Location.LocationType
        public Location location;
        public Participant[] participants;
        public string message;
        public bool isFinal;

        public string ToString()
        {
            StringBuilder sb = new StringBuilder("<Appointment ");
            sb.Append("@identifier: ").Append(identifier).Append(", ");
            sb.Append("@locationType: ").Append(Location.LocationType.ToString(locationType)).Append(", ");
            sb.Append("@location: ").Append(location).Append(", ");
            sb.Append("@participants: ").Append(participants).Append(", ");
            sb.Append("@isFinal: ").Append(isFinal);
            sb.Append(">");
            return sb.ToString();
        }
    }
}
