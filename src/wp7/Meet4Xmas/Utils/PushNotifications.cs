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
                Channel.ChannelUriUpdated += HttpChannelChannelUriUpdated;
                Channel.Open();
                Channel.BindToShellToast();
                Channel.BindToShellTile();
                Channel.HttpNotificationReceived += HttpChannelHttpNotificationReceived;
                Channel.ErrorOccurred += HttpChannelErrorOccurred;
                Channel.ShellToastNotificationReceived += HttpChannelToastNotificationReceived;
            }
            UpdateChannelURI();
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
                sb.Append(kvp.Value + "\n");
            }
            dispatcher.BeginInvoke(() => MessageBox.Show(sb.ToString()));
        }

        private void HttpChannelChannelUriUpdated(object sender, NotificationChannelUriEventArgs e)
        {
            UpdateChannelURI();
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
                ServiceCall.Invoke(ServiceCallCreate,
                    (Response result) =>
                    {
                        if (!result.success)
                        {
                            dispatcher.BeginInvoke(() => MessageBox.Show("Error establishing a channel for notifications"));
                        }
                    }, userId, new NotificationServiceInfo(Channel.ChannelUri));
            }
        }
    }
}
