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

namespace Meet4Xmas.Utils
{
    public class PushNotifications
    {
        public static Dispatcher dispatcher = Deployment.Current.Dispatcher;
        private const string ChannelName = App.ApplicationName + "Channel";
        public HttpNotificationChannel Channel { get; set; }
        public bool ChannelIsActive { get; set; }

        private void EstablishNotificationChannel()
        {
            Channel = HttpNotificationChannel.Find(ChannelName);
            if (Channel == null)
            {
                Channel = new HttpNotificationChannel(ChannelName);
                Channel.ChannelUriUpdated += HttpChannelChannelUriUpdated;
                Channel.Open();
                Channel.BindToShellToast();
                Channel.HttpNotificationReceived += HttpChannelHttpNotificationReceived;
                Channel.ErrorOccurred += HttpChannelErrorOccurred;
                Channel.ShellToastNotificationReceived += HttpChannelToastNotificationReceived;
            }
            UpdateChannelIsActive();
        }

        public void HttpChannelHttpNotificationReceived(object sender, HttpNotificationEventArgs e)
        {
            // TODO: e.ToString();
        }

        public void HttpChannelErrorOccurred(object sender, NotificationChannelErrorEventArgs e)
        {
            // TODO: e.ToString();
            Channel.Close();
            Channel = null;
            UpdateChannelIsActive();
            EstablishNotificationChannel();
        }

        public void HttpChannelToastNotificationReceived(object sender, NotificationEventArgs e)
        {
            var sb = new StringBuilder();
            foreach (var kvp in e.Collection)
            {
                sb.Append(kvp.Value + "\n");
            }
            dispatcher.BeginInvoke(() => MessageBox.Show(sb.ToString()));
        }

        void HttpChannelChannelUriUpdated(object sender, NotificationChannelUriEventArgs e)
        {
            UpdateChannelIsActive();
        }

        void UpdateChannelIsActive()
        {
            ChannelIsActive = Channel != null &&
                Channel.ChannelUri != null &&
                !string.IsNullOrEmpty(Channel.ChannelUri.OriginalString);
        }
    }
}
