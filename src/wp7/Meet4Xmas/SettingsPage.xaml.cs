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
        public SettingsPage()
        {
            InitializeComponent();
            InitializeTravelTypes();
        }

        private void InitializeTravelTypes()
        {
            listPicker.ItemsSource = new List<string>(TravelPlan.TravelType.TypesList);
            listPicker.SelectedIndex = Settings.PreferredTravelType;
            listPicker.SelectionChanged += new SelectionChangedEventHandler(listPicker_SelectionChanged);
        }

        private void listPicker_SelectionChanged(object sender, EventArgs e)
        {
            Settings.PreferredTravelType = listPicker.SelectedIndex;
        }

        private void gpsCheckBox_Checked(object sender, RoutedEventArgs e)
        {
            Settings.AllowUsingLocation = gpsCheckBox.IsChecked;
        }
    }
}