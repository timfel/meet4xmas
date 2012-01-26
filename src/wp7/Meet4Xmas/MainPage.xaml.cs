using System;
using System.Windows;
using Microsoft.Phone.Controls;
using org.meet4xmas.wire;
using System.Windows.Controls.Primitives;
using System.Windows.Controls;

namespace Meet4Xmas
{
    public partial class MainPage : PhoneApplicationPage
    {
        // Constructor
        public MainPage()
        {
            InitializeComponent();

            // Set the data context of the listbox control to the sample data
            DataContext = App.ViewModel;
            this.Loaded += new RoutedEventHandler(MainPage_Loaded);
            AppointmentsList.Tap += new EventHandler<System.Windows.Input.GestureEventArgs>(AppointmentsList_Tap);
        }

        // Load data for the ViewModel Items
        private void MainPage_Loaded(object sender, RoutedEventArgs e)
        {
            if (!App.ViewModel.IsDataLoaded)
            {
                App.ViewModel.LoadData();
            }
            if (Settings.Account == null)
            {
                NavigationService.Navigate(new Uri("/SignUpPage.xaml", UriKind.Relative));
            }
            else
            {
                Settings.Account.Loaded();
            }
        }

        private void CreateAppointmentButtonClick(object sender, RoutedEventArgs e)
        {
            NavigationService.Navigate(new Uri("/AppointmentCreate.xaml", UriKind.Relative));
        }

        private void LogOutButton_Click(object sender, RoutedEventArgs e)
        {
            Settings.Account = null;
            NavigationService.Navigate(new Uri("/SignUpPage.xaml", UriKind.Relative));
        }

        private void AppointmentsList_Tap(object sender, System.Windows.Input.GestureEventArgs e)
        {
            var appointment = (sender as ListBox).SelectedValue;
            NavigationService.Navigate(new Uri(String.Format("/AppointmentShow.xaml?appointmentId={0}",
                                                            (appointment as Appointment).identifier),
                                               UriKind.Relative));
        }
    }
}
