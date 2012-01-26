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


namespace Meet4Xmas
{
    public partial class AppointmentShow : PhoneApplicationPage
    {
        public List<string> source = new List<string>(new string[] { "Car", "Public Transport", "Walk" });

        public AppointmentShow()
        {
            InitializeComponent();
            listPicker.ItemsSource = source;
        }

        protected override void OnNavigatedTo(System.Windows.Navigation.NavigationEventArgs e)
        {
            base.OnNavigatedTo(e);
            string appointmentId = "";
            if (NavigationContext.QueryString.TryGetValue("appointmentId", out appointmentId)) {
                var app = from a in Settings.Appointments where a.identifier.ToString() == appointmentId select a;
                this.DataContext = app.First();
                foreach (Participant p in app.First().participants) {
                    ContactList.Items.Add(p.userId);
                }
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
                    MessageBox.Show("An error occured trying to join this appointment." + ei.message);
                }
            );
        }
    }
}