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
using hessiancsharp.client;
using System.Reflection;
using org.meet4xmas.wire;
using Meet4Xmas;
using System.Windows.Threading;

namespace Meet4Xmas
{
    public class ServiceCall
    {
        private static Dispatcher UIDispatcher = Deployment.Current.Dispatcher;
        private static string ServiceUrl = "http://tessi.fornax.uberspace.de/xmas/1/";
        private static CHessianProxyFactory m_proxyFactory = null;
        private static CHessianProxyFactory ProxyFactory
        {
            get
            {
                if (m_proxyFactory == null) m_proxyFactory = new CHessianProxyFactory();
                return m_proxyFactory;
            }
        }

        public static void Invoke(string method, Action<Response> cb, params object[] args)
        {
            CAsyncHessianMethodCaller methodCaller = new CAsyncHessianMethodCaller(ProxyFactory, new Uri(ServiceUrl));
            MethodInfo mInfo_1 = typeof(IServiceAPI).GetMethod(method);
            methodCaller.BeginHessianMethodCall(args, mInfo_1,
                    new AsyncCallback((r) => UIDispatcher.BeginInvoke(() => cb((Response)r.AsyncState))));
        }
    }
}
