module Meet4Xmas
module Persistence
  module LocationType
    ChristmasMarket = 0

    ALL = [ ChristmasMarket ]
  end

  module TravelType
    Car = 0
    Walk = 1
    PublicTransport = 2

    ALL = [ Car, Walk, PublicTransport ]
  end

  module ParticipationStatus
    Pending = 0
    Accepted = 1
    Declined = 2

    ALL = [ Pending, Accepted, Declined ]
  end

  module NotificationServiceType
    APNS = 0
    MPNS = 1
    C2DM = 2

    ALL = [ APNS, MPNS, C2DM ]
  end
end
end
