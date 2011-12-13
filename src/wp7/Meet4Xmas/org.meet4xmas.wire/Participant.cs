using System.Text;

namespace org.meet4xmas.wire
{
    public partial class Participant
    {
        public static class ParticipationStatus
        {
            public const int Pending = 0;
            public const int Joined = 1;
            public const int Declined = 2;

            public static string ToString(int status)
            {
                switch (status)
                {
                    case Pending: return "Pending";
                    case Joined: return "Joined";
                    case Declined: return "Declined";
                    default: return "Invalid";
                }
            }
        }

        public string userId;
        public int status; // use values in ParticipationStatus

        public string toString() {
            StringBuilder sb = new StringBuilder("<Participant ");
            sb.Append("@userId: ").Append(userId).Append(", ");
            sb.Append("@status: ").Append(ParticipationStatus.ToString(status));
            sb.Append(">");
            return sb.ToString();
        }
    }
}
