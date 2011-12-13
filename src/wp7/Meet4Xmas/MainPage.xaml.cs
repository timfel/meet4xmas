using System;
using System.Windows;
using Microsoft.Phone.Controls;
using org.meet4xmas.wire;
using System.Windows.Controls.Primitives;

namespace Meet4Xmas
{
    public class Foo
    {
        int a;
        string b;
    }

    public interface IHessianTest
    {
        Foo getAppointment(int id);
    }

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
            Panorama.DefaultItem = AppointmentsList;
            Appointment.Create(Settings.Account, TravelPlan.TravelType.PublicTransport,
                new Participant[] {}, Location.LocationType.ChristmasMarket, "TODO MESSAGE",
                (Appointment apt) => { Settings.Appointments.Add(apt); App.ViewModel.LoadAppointments(); },
                (ErrorInfo errorInfo) => {
                    Popup p = new Popup();
                    InfoPopup ip = new InfoPopup();
                    ip.container = p;
                    ip.PopupText.Text = "An error occurred trying to create your appointment." + errorInfo.message;
                    p.Child = ip;
                    p.IsOpen = true;
                });
        }
    }
}
