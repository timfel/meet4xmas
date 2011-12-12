using Microsoft.Silverlight.Testing;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using hessiancsharp.client;
using System.Reflection;
using org.meet4xmas.wire;
using System;
using System.Threading;

namespace Meet4XmasTests.Tests
{
    [TestClass]
    public class TestClass1 : SilverlightTest
    {
        //const string url = "http://tessi.fornax.uberspace.de/xmas/1/";
        const string url = "http://172.16.18.83:4567/1/";

        object global;
        CHessianProxyFactory factory;
        CAsyncHessianMethodCaller methodCaller;

        [TestInitialize]
        public void setUp()
        {
            global = null;
            factory = new CHessianProxyFactory();
            methodCaller = new CAsyncHessianMethodCaller(factory, new Uri(url));
        }

        [TestMethod]
        [Asynchronous]
        public void TestMethod1()
        {
            EnqueueCallback(() => BeginRequest("registerAccount", new object[] { "Tim" + DateTime.Now.ToString() }));
            EnqueueConditional(() => global != null);
            EnqueueCallback(() =>
            {
                Assert.IsInstanceOfType(global, typeof(Response));
            });
            EnqueueTestComplete();
        }

        private void BeginRequest(string method, object[] args)
        {
            MethodInfo mInfo_1 = typeof(IServiceAPI).GetMethod(method);
            methodCaller.BeginHessianMethodCall(args, mInfo_1, new AsyncCallback(EndRequest));
        }

        private void EndRequest(IAsyncResult ar)
        {
            global = ar.AsyncState;
        }
    }
}