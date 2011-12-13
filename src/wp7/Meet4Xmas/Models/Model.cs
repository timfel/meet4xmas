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
using System.Windows.Threading;
using Meet4Xmas;

namespace org.meet4xmas.wire
{
    public abstract class Model
    {
        public Dispatcher UIDispatcher = Deployment.Current.Dispatcher;
    }
}
