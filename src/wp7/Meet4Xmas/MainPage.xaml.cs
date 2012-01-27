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
            if (!App.ViewModel.IsDataLoaded) {
                App.ViewModel.LoadData();
            }
            if (Settings.Account == null) {
                NavigationService.Navigate(new Uri("/SignUpPage.xaml", UriKind.Relative));
            }
        }

        protected override void OnNavigatedTo(System.Windows.Navigation.NavigationEventArgs e)
        {
            base.OnNavigatedTo(e);
            string appointmentId = "";
            if (NavigationContext.QueryString.TryGetValue("appointmentId", out appointmentId)) {
                Account.HandleAppointmentToast(appointmentId);
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
            if (appointment == null) return;
            NavigationService.Navigate(new Uri(String.Format("/AppointmentShow.xaml?appointmentId={0}",
                                                            (appointment as Appointment).identifier),
                                               UriKind.Relative));
        }

        private void MenuItem_Click(object sender, RoutedEventArgs e)
        {
            string header = (sender as MenuItem).Header.ToString();

            ListBoxItem selectedListBoxItem = AppointmentsList.ItemContainerGenerator.ContainerFromItem((sender as MenuItem).DataContext) as ListBoxItem;
            if (selectedListBoxItem == null) return;
            Appointment selectedAppointment = selectedListBoxItem.DataContext as Appointment;

            if (header.StartsWith("Remove")) {
                Settings.Appointments.Remove(selectedAppointment);
                Settings.Save();
                App.ViewModel.LoadAppointments();
            }
        }

        private void SettingsButton_Click(object sender, RoutedEventArgs e)
        {
            NavigationService.Navigate(new Uri("/SettingsPage.xaml", UriKind.Relative));
        }

        private void AboutButton_Click(object sender, RoutedEventArgs e)
        {
            MessageBox.Show(String.Format("{0} {1}\nDeveloped by Tim Felgentreff, Markus Kahl\nContact: timfelgentreff@hotmail.com",
                                           App.ApplicationName, App.Version));
        }
    }
}
