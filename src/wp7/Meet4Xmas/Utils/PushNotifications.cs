using System;
using System.Net;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Documents;
using System.Windows.Ink;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Animation;
using System.Windows.Shapes;
using Microsoft.Phone.Notification;
using System.Text;
using System.Windows.Threading;
using Meet4Xmas;
using System.Linq;

namespace org.meet4xmas.wire
{
    public partial class Account : Participant
    {
        private static Dispatcher dispatcher = Deployment.Current.Dispatcher;
        private const string ChannelName = App.ApplicationName + "Channel";
        private HttpNotificationChannel Channel { get; set; }

        private void OpenNotificationChannel()
        {
            FindNotificationChannel();
            if (Channel == null)
            {
                Channel = new HttpNotificationChannel(ChannelName);
                Channel.Open();
                Channel.BindToShellToast();
                Channel.BindToShellTile();
            }
            Channel.ChannelUriUpdated += new EventHandler<NotificationChannelUriEventArgs>(HttpChannelChannelUriUpdated);
            Channel.HttpNotificationReceived += new EventHandler<HttpNotificationEventArgs>(HttpChannelHttpNotificationReceived);
            Channel.ErrorOccurred += new EventHandler<NotificationChannelErrorEventArgs>(HttpChannelErrorOccurred);
            Channel.ShellToastNotificationReceived += new EventHandler<NotificationEventArgs>(HttpChannelToastNotificationReceived);
            Channel.ConnectionStatusChanged += new EventHandler<NotificationChannelConnectionEventArgs>(HttpChannelConnectionStatusChanged);
        }

        private void FindNotificationChannel()
        {
            Channel = HttpNotificationChannel.Find(ChannelName);
        }

        private void CloseNotificationChannel()
        {
            FindNotificationChannel();
            if (Channel != null) {
                Channel.Close();
            }
        }

        private void ReopenNotificationChannel()
        {
            CloseNotificationChannel();
            OpenNotificationChannel();
        }

        private void HttpChannelHttpNotificationReceived(object sender, HttpNotificationEventArgs e)
        {
            // TODO: e.ToString();
        }

        private void HttpChannelErrorOccurred(object sender, NotificationChannelErrorEventArgs e)
        {
            // TODO: e.ToString();
            ReopenNotificationChannel(); // Often, MS advice is to reopen the channel
        }

        private void HttpChannelToastNotificationReceived(object sender, NotificationEventArgs e)
        {
            var sb = new StringBuilder();
            foreach (var kvp in e.Collection)
            {
                if (kvp.Key.CompareTo("wp:Param") == 0) {
                    foreach(string item in new Uri(kvp.Value).Query.Split('&')) {
                        string[] parts = item.Replace("?", "").Split('=');
                        if (parts[0].CompareTo("appointmentId") == 0) {
                            HandleAppointmentToast(parts[1]);
                            break;
                        }
                    }
                } else {
                    sb.Append(kvp.Value + "\n");
                } 
            }
            dispatcher.BeginInvoke(() => MessageBox.Show("Received an appointment update!\n" + sb.ToString()));
        }

        private void HttpChannelChannelUriUpdated(object sender, NotificationChannelUriEventArgs e)
        {
            UpdateChannelURI();
        }

        private void HttpChannelConnectionStatusChanged(object sender, NotificationChannelConnectionEventArgs e)
        {
            if (Channel.ConnectionStatus == ChannelConnectionStatus.Disconnected)
            {
                ReopenNotificationChannel();
            }
        }

        private bool ChannelIsActive()
        {
            return Channel != null &&
                Channel.ChannelUri != null &&
                !string.IsNullOrEmpty(Channel.ChannelUri.OriginalString);
        }

        private void UpdateChannelURI()
        {
            if (ChannelIsActive()) {
                dispatcher.BeginInvoke(() =>
                    ServiceCall.Invoke(ServiceCallCreate,
                        (Response result) =>
                        {
                            if (!result.success)
                            {
                                dispatcher.BeginInvoke(() => MessageBox.Show("Error establishing a channel for notifications"));
                            }
                        }, userId, new NotificationServiceInfo(Channel.ChannelUri)));
            }
        }

        public static void HandleAppointmentToast(string appointmentId)
        {
            var app = from a in Settings.Appointments where a.identifier.ToString() == appointmentId select a;
            if (app.Count() == 0) { // New appointment, cache it
                Appointment.Find(Convert.ToInt32(appointmentId),
                (a) =>
                {
                    Settings.Appointments.Add(a);
                    Settings.Save();
                    App.ViewModel.Appointments.Add(a);
                },
                (ei) =>
                {
                    dispatcher.BeginInvoke(() => MessageBox.Show("Failed to load appointment." + ei.message));
                });
            }
        }

    }
}
