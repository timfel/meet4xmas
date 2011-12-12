using System.Text;

namespace org.meet4xmas.wire
{
    public class Location
    {
        public static class LocationType
        {
            public static const int ChristmasMarket = 0;

            public static string ToString(int locationType)
            {
                switch (locationType)
                {
                    case LocationType.ChristmasMarket: return "ChristmasMarket";
                    default: return "Invalid";
                }
            }
        }

        public double longitude;
        public double latitude;
        public string title;
        public string description;

        public string ToString()
        {
            StringBuilder sb = new StringBuilder("<Location ");
            sb.Append("@longitude: ").Append(longitude).Append(", ");
            sb.Append("@latitude: ").Append(latitude).Append(", ");
            sb.Append("@title: ").Append(title).Append(", ");
            sb.Append("@description: ").Append(description);
            sb.Append(">");
            return sb.ToString();
        }
    }
}
