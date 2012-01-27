using System;
using System.Net;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Documents;
using System.Windows.Ink;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Animation;
using System.Windows.Shapes;
using System.IO.IsolatedStorage;
using System.Xml;
using System.Xml.Serialization;
using org.meet4xmas.wire;
using System.Collections.Generic;

namespace Meet4Xmas
{
    public class Settings
    {
        public static IsolatedStorageSettings Storage = IsolatedStorageSettings.ApplicationSettings;
        public static Account Account
        {
            get
            {
                if (!Storage.Contains("Account")) return null;
                if (Storage["Account"] == null) return null;
                XmlSerializer xs = new XmlSerializer(typeof(Account));
                return (Account)xs.Deserialize(new System.IO.StringReader((string)Storage["Account"]));
            }
            set
            {
                XmlSerializer xs = new XmlSerializer(typeof(Account));
                System.IO.StringWriter writer = new System.IO.StringWriter();
                xs.Serialize(writer, value);
                Storage["Account"] = writer.ToString();
                Storage.Save();
            }
        }

        public static List<Appointment> Appointments
        {
            get
            {
                if (!Storage.Contains("Appointments")) Storage["Appointments"] = new List<Appointment>();
                return (List<Appointment>)Storage["Appointments"];
            }
        }

        public static int PreferredTravelType
        {
            get
            {
                if (!Storage.Contains("PreferredTravelType"))
                    Storage["PreferredTravelType"] = TravelPlan.TravelType.PublicTransport;
                return (int)Storage["PreferredTravelType"];
            }
            set
            {
                Storage["PreferredTravelType"] = value;
                Storage.Save();
            }
        }

        public static void Save()
        {
            Storage.Save();
        }

        public static bool? AllowUsingLocation
        {
            get
            {
                if (!Storage.Contains("AllowUsingLocation"))
                    Storage["AllowUsingLocation"] = true;
                return (bool?)Storage["AllowUsingLocation"];
            }
            set
            {
                Storage["AllowUsingLocation"] = value;
                Storage.Save();
            }
        }

        public static bool? AllowPushNotifications
        {
            get
            {
                if (!Storage.Contains("AllowPushNotifications"))
                    Storage["AllowPushNotifications"] = false;
                return (bool?)Storage["AllowPushNotifications"];
            }
            set
            {
                Storage["AllowPushNotifications"] = value;
                Storage.Save();
            }
        }
    }
}
