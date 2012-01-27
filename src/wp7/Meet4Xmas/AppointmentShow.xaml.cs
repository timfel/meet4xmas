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
using System.Linq;
using Microsoft.Phone.Controls.Maps;
using System.Device.Location;


namespace Meet4Xmas
{
    public partial class AppointmentShow : PhoneApplicationPage
    {
        public List<string> source = new List<string>(new string[] { "Car", "Public Transport", "Walk" });
        private Map map { get; set; }

        public AppointmentShow()
        {
            InitializeComponent();
            InitializeTravelTypes();
        }

        private void InitializeBingMap()
        {
            Appointment a = DataContext as Appointment;
            map = new Map();
            //map.CredentialsProvider = new ApplicationIdCredentialsProvider("Bing Maps Key");

            // Set the center coordinate and zoom level
            Location center = a.location;

            // Create pushpins to put at the waypoints
            if (a.TravelPlan == null) {
                a.GetTravelPlan(0,
                    (travelPlan) => InitializeMapWaypoints(),
                    (ei) => MessageBox.Show("Error refreshing travel plan" + ei.message));
            } else {
                InitializeMapWaypoints();
            }

            // Set the map style to Aerial
            map.Mode = new Microsoft.Phone.Controls.Maps.AerialMode();

            // Zoom the map view on tap
            map.Tap += new EventHandler<System.Windows.Input.GestureEventArgs>((sender, ev) =>
            {
                foreach (UIElement e in ContentPanel.Children) {
                    if (e != MapGrid)
                        e.Visibility = e.Visibility == Visibility.Collapsed ? Visibility.Visible : Visibility.Collapsed;
                }
            });
            MapGrid.Children.Add(map);
        }

        private void InitializeMapWaypoints()
        {
            Appointment a = DataContext as Appointment;
            map.Children.Clear();
            foreach (Location l in a.TravelPlan.path) {
                Pushpin pin1 = new Pushpin();
                pin1.Location = new GeoCoordinate(l.latitude, l.longitude);
                pin1.Content = l.title;
                map.Children.Add(pin1);
            }
            GeoCoordinate mapCenter = new GeoCoordinate(a.location.latitude, a.location.longitude);
            map.SetView(mapCenter, 15);
        }

        private void InitializeTravelTypes()
        {
            listPicker.ItemsSource = source;
            listPicker.SelectionChanged += new SelectionChangedEventHandler(listPicker_SelectionChanged);
        }

        protected override void OnNavigatedTo(System.Windows.Navigation.NavigationEventArgs e)
        {
            base.OnNavigatedTo(e);
            string appointmentId = "";
            if (NavigationContext.QueryString.TryGetValue("appointmentId", out appointmentId)) {
                var app = from a in Settings.Appointments where a.identifier.ToString() == appointmentId select a;
                this.DataContext = app.First();
                ContactList.Items.Clear();
                foreach (Participant p in app.First().participants) {
                    ContactList.Items.Add(p.userId);
                }
                InitializeBingMap();
            }
        }

        private void ApplicationBarLeaveButton_Click(object sender, EventArgs e)
        {
            (this.DataContext as Appointment).Decline(Settings.Account,
                () => NavigationService.GoBack(),
                (ErrorInfo ei) =>
                {
                    MessageBox.Show("An error occured trying to leave this appointment." + ei.message);
                }
            );
        }

        private void ApplicationBarJoinButton_Click(object sender, EventArgs e)
        {
            (this.DataContext as Appointment).Join(Settings.Account, listPicker.SelectedIndex + 1,
                () => MessageBox.Show("You joined this appointment"),
                (ErrorInfo ei) =>
                {
                    MessageBox.Show("An error occurred trying to join this appointment." + ei.message);
                }
            );
        }

        private void listPicker_SelectionChanged(object sender, EventArgs e)
        {
            Appointment a = DataContext as Appointment;
            if (a.TravelType != listPicker.SelectedIndex + 1) {
                a.GetTravelPlan(listPicker.SelectedIndex + 1,
                    (TravelPlan t) => InitializeMapWaypoints(),
                    (ErrorInfo ei) => MessageBox.Show("An error occurred trying to update your travel plan." + ei.message));
            }
        }

        private void ApplicationBarMapButton_Click(object sender, EventArgs e)
        {
            Location end = (DataContext as Appointment).location;
            var task = new BingMapsDirectionsTask();
            task.End = new LabeledMapLocation(end.title, new GeoCoordinate(end.latitude, end.longitude));
            task.Show();
        }
    }
}