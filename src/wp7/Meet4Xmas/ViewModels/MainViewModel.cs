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
            this.Appointments = new ObservableCollection<ItemViewModel>();
        }

        public ObservableCollection<ItemViewModel> Appointments { get; private set; }

        public bool IsDataLoaded { get; private set; }

        /// <summary>
        /// Creates and adds a few ItemViewModel objects into the Items collection.
        /// </summary>
        public void LoadData()
        {
            LoadAppointments();
            this.IsDataLoaded = true;
        }

        public void LoadAppointments()
        {
            Appointments.Clear();
            foreach (Appointment a in Settings.Appointments)
            {
                string friends = "";
                foreach (Participant p in a.participants)
                {
                    friends += (p.userId + " ");
                }
                Appointments.Add(new ItemViewModel() { LineOne = a.message, LineTwo = friends, LineThree = String.Format("{0}", a.location) });
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