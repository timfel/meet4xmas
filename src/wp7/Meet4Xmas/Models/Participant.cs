using System;

namespace org.meet4xmas.wire
{
    public partial class Participant
    {
        public bool Equals(Participant obj)
        {
            if (obj == null)
                return false;
            return this == obj;
        }

        public Participant() { }
        public Participant(string userId)
        {
            this.userId = userId;
            this.status = ParticipationStatus.Pending;
        }
    }
}
