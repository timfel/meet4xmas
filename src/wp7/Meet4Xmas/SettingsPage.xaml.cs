using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Animation;
using System.Windows.Shapes;
using Microsoft.Phone.Controls;
using org.meet4xmas.wire;
using System.Windows.Controls.Primitives;
using Microsoft.Phone.Tasks;
using Microsoft.Phone.Controls.Maps;
using System.Device.Location;


namespace Meet4Xmas
{
    public partial class SettingsPage : PhoneApplicationPage
    {
        private bool? allowPushNotifications;
        public SettingsPage()
        {
            InitializeComponent();
        }

        protected override void OnNavigatedTo(System.Windows.Navigation.NavigationEventArgs e)
        {
            base.OnNavigatedTo(e);
            InitializeTravelTypes();
            InitializeCheckboxes();
        }

        private void InitializeCheckboxes()
        {
            gpsCheckBox.IsChecked = Settings.AllowUsingLocation;
            notificationsCheckBox.IsChecked = Settings.AllowPushNotifications;
            this.allowPushNotifications = Settings.AllowPushNotifications;
        }

        private void InitializeTravelTypes()
        {
            listPicker.ItemsSource = new List<string>(TravelPlan.TravelType.TypesList);
            listPicker.SelectedIndex = Settings.PreferredTravelType;
        }

        private void saveButton_Click(object sender, RoutedEventArgs e)
        {
            Settings.AllowUsingLocation = gpsCheckBox.IsChecked;
            Settings.AllowPushNotifications = notificationsCheckBox.IsChecked;
            Settings.PreferredTravelType = listPicker.SelectedIndex;
            if (this.allowPushNotifications != notificationsCheckBox.IsChecked) {
                // Push notification settings changed, adjust
                if ((bool)this.allowPushNotifications) {
                    Settings.Account.CloseNotificationChannel();
                } else {
                    Settings.Account.OpenNotificationChannel();
                }
            }
            NavigationService.Navigate(new Uri("/MainPage.xaml", UriKind.Relative));
        }
    }
}