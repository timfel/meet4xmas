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

namespace Meet4Xmas
{
    public partial class AppointmentCreate : PhoneApplicationPage
    {
        public AppointmentCreate()
        {
            InitializeComponent();
        }

        private void createButton_Click(object sender, RoutedEventArgs e)
        {
            var participants = from email in ContactList.Items select new Participant((string)email);
            Appointment.Create(Settings.Account, TravelPlan.TravelType.PublicTransport,
                participants.ToArray<Participant>(), Location.LocationType.ChristmasMarket, SubjectBox.Text,
                (Appointment apt) =>
                {
                    Settings.Appointments.Add(apt);
                    apt.GetTravelPlan(TravelPlan.TravelType.PublicTransport,
                        (TravelPlan tp) =>
                        {
                            TravelPlan t = tp;
                        },
                        (ErrorInfo ei) =>
                        {
                            MessageBox.Show("An error occured trying to find your travel plan." + ei.message);
                        });
                    Settings.Save();
                    App.ViewModel.LoadAppointments();
                },
                (ErrorInfo errorInfo) =>
                {
                    MessageBox.Show("An error occurred trying to create your appointment." + errorInfo.message);
                });
            NavigationService.GoBack();
        }

        private void ApplicationBarIconButton_Click(object sender, EventArgs e)
        {
            var task = new EmailAddressChooserTask();
            task.Completed += new EventHandler<EmailResult>((object searchSender, EmailResult csea) =>
            {
                if (csea.TaskResult == TaskResult.OK)
                {
                    ContactList.Items.Add(csea.Email);
                }
            });
            task.Show();
        }
    }
}