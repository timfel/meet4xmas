using System;
using System.Windows;
using Microsoft.Phone.Controls;
using hessiancsharp.client;
using System.Reflection;
using org.meet4xmas.wire;
using System.Threading;
using System.Windows.Threading;
using System.ComponentModel;

namespace Meet4Xmas
{
    public partial class SignUpPage : PhoneApplicationPage
    {
        public SignUpPage()
        {
            InitializeComponent();
        }

        protected override void OnBackKeyPress(CancelEventArgs e)
        {
            e.Cancel = true;
        }

        private void SignUpButtonClick(object sender, RoutedEventArgs e)
        {
            SignUpProgressBar.Visibility = Visibility.Visible;
            Account.Create(SignUpTextInput.Text,
                (Account account) =>
                {
                    SignUpProgressBar.Visibility = Visibility.Collapsed;
                    SignUpErrorInfo.Text = "Success";
                    Settings.Account = account;

                    // Load the user's appointments
                    Settings.Appointments.Clear();
                    foreach (int id in account.AppointmentIds) {
                        Appointment.Find(id, (a) =>
                        {
                            Settings.Appointments.Add(a);
                            Settings.Save();
                            App.ViewModel.LoadAppointments();
                        }, (ei) => { });
                    }

                    Settings.Save();
                    new Timer((state) => Dispatcher.BeginInvoke(() =>
                            NavigationService.Navigate(new Uri("/MainPage.xaml", UriKind.Relative))),
                            null, 1000, Timeout.Infinite);
                },
                (ErrorInfo errorInfo) =>
                {
                    SignUpProgressBar.Visibility = Visibility.Collapsed;
                    SignUpErrorInfo.Text = errorInfo.message;
                });
        }

        private void button1_Click(object sender, RoutedEventArgs e)
        {
            MessageBox.Show("W-w-w-w-wub");
        }

        private void Image_ImageFailed(object sender, ExceptionRoutedEventArgs e)
        {

        }
    }
}