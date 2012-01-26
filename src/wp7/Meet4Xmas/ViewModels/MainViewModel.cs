using System;
using System.ComponentModel;
using System.Collections.Generic;
using System.Diagnostics;
using System.Text;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Shapes;
using System.Collections.ObjectModel;
using System.IO.IsolatedStorage;
using org.meet4xmas.wire;


namespace Meet4Xmas
{
    public class MainViewModel : INotifyPropertyChanged
    {
        public MainViewModel()
        {
            this.Appointments = new ObservableCollection<Appointment>();
            this.ApplicationName = App.ApplicationName;
        }

        public ObservableCollection<Appointment> Appointments { get; private set; }
        public string ApplicationName { get; private set; }
        public string AccountName { get { return Settings.Account == null ? "" : Settings.Account.userId; } }

        public bool IsDataLoaded { get; private set; }

        /// <summary>
        /// Creates and adds a few ItemViewModel objects into the Items collection.
        /// </summary>
        public void LoadData()
        {
            LoadAppointments();
            this.IsDataLoaded = true;
        }

        /// <summary>
        /// Cleanup the appointments
        /// This will clear appointment cache if the account is null (user logged out)
        /// This will add all appointments from the cache to the visible list
        /// </summary>
        public void LoadAppointments()
        {
            Appointments.Clear();
            if (Settings.Account == null) {
                Settings.Appointments.Clear();
            } else {
                foreach (Appointment a in Settings.Appointments) {
                    Appointments.Add(a);
                }
            }
        }

        public event PropertyChangedEventHandler PropertyChanged;
        private void NotifyPropertyChanged(String propertyName)
        {
            PropertyChangedEventHandler handler = PropertyChanged;
            if (null != handler)
            {
                handler(this, new PropertyChangedEventArgs(propertyName));
            }
        }
    }
}