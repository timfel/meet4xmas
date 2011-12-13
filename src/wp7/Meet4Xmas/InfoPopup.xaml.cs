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
using System.Windows.Controls.Primitives;

namespace Meet4Xmas
{
    public partial class InfoPopup : UserControl
    {
        public InfoPopup()
        {
            InitializeComponent();
        }

        public Popup container { get; set; }

        private void OkButton_Click(object sender, RoutedEventArgs e)
        {
            container.IsOpen = false;
        }
    }
}
