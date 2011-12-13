using System;

namespace org.meet4xmas.wire
{
    public partial class Location
    {
        public Location() { }

        public Location(double longitude, double latitude)
        {
            this.longitude = longitude;
            this.latitude = latitude;
        }
    }
}
