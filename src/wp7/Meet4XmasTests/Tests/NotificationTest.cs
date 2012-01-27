using System;
using Microsoft.Phone.Notification;
using System.Text;
using System.Windows.Threading;
using System.Windows;
using System.Net;
using Microsoft.Silverlight.Testing;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace Meet4XmasTests.Tests
{
    //[TestClass]
    public class NotificationTest : SilverlightTest
    {
        public static Dispatcher dispatcher = Deployment.Current.Dispatcher;
        private const string ChannelName = "MyApplicationChannel";
        public HttpNotificationChannel Channel { get; set; }
        public bool ChannelIsActive { get; set; }
        public string notificationStatus { get; set; }
        public string notificationChannelStatus { get; set; }
        public string deviceConnectionStatus { get; set; }
        public string result { get; set; }

        [TestMethod]
        [Asynchronous]
        public void testToastNotification()
        {
            ChannelIsActive = false;
            EnqueueCallback(() => EstablishNotificationChannel());
            var messageTemplate = "<?XML version=\"1.0\" encoding=\"utf-8\"?>" +
                                                        "<wp:Notification xmlns:wp=\"WPNotification\">" +
                                                            "<wp:Toast>" +
                                                                "<wp:Text1>{0}</wp:Text1>" +
                                                                "<wp:Text2>{1}</wp:Text2>" +
                                                            "</wp:Toast>" +
                                                        "</wp:Notification>";
            var message = string.Format(messageTemplate, "Hello", "World!");
            byte[] msg = Encoding.UTF8.GetBytes(message);
            SendNotification(msg, 2, "toast");
            EnqueueConditional(() => notificationStatus != null &&
                                     deviceConnectionStatus != null &&
                                     notificationChannelStatus != null);
            EnqueueConditional(() =>
            {
                return result != null;
            });
            EnqueueCallback(() =>
            {
                Assert.AreEqual(result, "Key:Text1 Value:Hello, Key:Text2 Value:World, ");
            });
            EnqueueTestComplete();
        }

        private void SendNotification(byte[] notificationMessage, int notificationType, string targetHeader = null)
        {
            HttpWebRequest request = null;
            EnqueueConditional(() => Channel.ChannelUri != null);
            EnqueueCallback(() =>
            {
                HttpNotificationChannel channel = Channel;
                var channelUri = channel.ChannelUri;
                var myReq = (HttpWebRequest)WebRequest.Create(channelUri);
                myReq.Method = "POST";
                myReq.Headers = new WebHeaderCollection();
                var messageId = Guid.NewGuid();
                myReq.Headers["X-MessageID"] = messageId.ToString();
                myReq.Headers["X-NotificationClass"] = notificationType.ToString();
                if (!string.IsNullOrEmpty(targetHeader))
                {
                    myReq.ContentType = "text/XML";
                    myReq.Headers["X-WindowsPhone-Target"] = targetHeader;
                }
                request = myReq;
            });
            IAsyncResult asyncResult = null;
            EnqueueConditional(() => request != null);
            EnqueueCallback(() =>
            {
                request.BeginGetRequestStream((result) =>
                {
                    var requst = result.AsyncState as HttpWebRequest;
                    using (var requestStream = requst.EndGetRequestStream(result))
                    {
                        requestStream.Write(notificationMessage, 0,
                                            notificationMessage.Length);
                    }
                    asyncResult = result;
                }, request);
            });
            EnqueueConditional(() => asyncResult != null);
            EnqueueCallback(() =>
            {
                var req = asyncResult.AsyncState as HttpWebRequest;
                req.BeginGetResponse((responseResult) =>
                    {
                        var responseRequest = asyncResult.AsyncState as HttpWebRequest;
                        using (var response = responseRequest.EndGetResponse(responseResult))
                        {
                            notificationStatus = response.Headers["X-NotificationStatus"];
                            notificationChannelStatus = response.Headers["X-SubscriptionStatus"];
                            deviceConnectionStatus = response.Headers["X-DeviceConnectionStatus"];
                        }
                    }, req);
            });
        }

        private void EstablishNotificationChannel()
        {
            Channel = HttpNotificationChannel.Find(ChannelName);
            if (Channel != null)
            {
                Channel.Close();
            }
            Channel = new HttpNotificationChannel(ChannelName);
            Channel.ChannelUriUpdated += HttpChannelChannelUriUpdated;
            Channel.Open();
            Channel.BindToShellToast();
            Channel.HttpNotificationReceived += HttpChannelHttpNotificationReceived;
            Channel.ErrorOccurred += HttpChannelErrorOccurred;
            Channel.ShellToastNotificationReceived += HttpChannelToastNotificationReceived;
            UpdateChannelIsActive();
        }

        public void HttpChannelHttpNotificationReceived(object sender, HttpNotificationEventArgs e)
        {
            result = e.ToString();
        }

        public void HttpChannelErrorOccurred(object sender, NotificationChannelErrorEventArgs e)
        {
            result = e.ToString();
        }

        public void HttpChannelToastNotificationReceived(object sender, NotificationEventArgs e)
        {
            var sb = new StringBuilder();
            foreach (var kvp in e.Collection)
            {
                sb.Append(string.Format("Key:{0} Value:{1}, ", kvp.Key, kvp.Value));
            }
            result = sb.ToString();
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
