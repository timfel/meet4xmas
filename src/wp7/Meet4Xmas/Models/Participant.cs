using System;

namespace org.meet4xmas.wire
{
    public partial class Participant
    {
        public static bool operator ==(Participant a, Participant b)
        {
            return a.userId == b.userId;
        }

        public static bool operator !=(Participant a, Participant b)
        {
            return a.userId != b.userId;
        }
    }
}
