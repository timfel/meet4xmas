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
using hessiancsharp.client;
using System.Reflection;

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
                if (!App.ViewModel.Settings.Contains("AccountName"))
                {
                    SignUpGrid.Visibility = Visibility.Visible;
                }
            }
        }

        private void SignUpButtonClick(object sender, RoutedEventArgs e)
        {
            SignUpProgressBar.Visibility = Visibility.Visible;
            CHessianProxyFactory factory = new CHessianProxyFactory();
            String url = "http://172.16.18.83:4567/";
            CAsyncHessianMethodCaller methodCaller = new CAsyncHessianMethodCaller(factory, new Uri(url));
            MethodInfo mInfo_1 = typeof(IHessianTest).GetMethod("getAppointment");
            methodCaller.BeginHessianMethodCall(new object[] { 42 }, mInfo_1, new AsyncCallback(EndSignUpButtonClick));
        }

        private void EndSignUpButtonClick(IAsyncResult ar)
        {
            SignUpProgressBar.Visibility = Visibility.Collapsed;
            object result = ar.AsyncState;
        }
    }
}