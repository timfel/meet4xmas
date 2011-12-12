using System.Text;

namespace org.meet4xmas.wire
{
    public class TravelPlan
    {
        public static class TravelType
        {
            public sealed static const int Car = 0;
            public sealed static const int Walk = 1;
            public sealed static const int PublicTransport = 2;

            public static string ToString(int travelType)
            {
                switch (travelType)
                {
                    case Car: return "Car";
                    case Walk: return "Walk";
                    case PublicTransport: return "PublicTransport";
                    default: return "Invalid";
                }
            }
        }

        public Location[] path;

        public override string ToString() {
            StringBuilder sb = new StringBuilder("<TravelPlan ");
            sb.Append("@path: ").Append(path);
            sb.Append(">");
            return sb.ToString();
        }
    }
}
