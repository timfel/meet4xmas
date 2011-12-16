# some constants concerning the Server API
module Meet4Xmas
module Server
  module API
    VERSION = 1

    ALL_MESSAGES = %w(registerAccount deleteAccount
        createAppointment getAppointment getTravelPlan
        joinAppointment declineAppointment finalizeAppointment)
  end
end
end
