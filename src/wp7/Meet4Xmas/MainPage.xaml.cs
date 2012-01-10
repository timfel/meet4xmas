using System;
using System.Windows;
using Microsoft.Phone.Controls;
using org.meet4xmas.wire;
using System.Windows.Controls.Primitives;

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
    }
}
