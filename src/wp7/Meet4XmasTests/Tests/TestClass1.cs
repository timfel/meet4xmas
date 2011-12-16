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
        const string url = "http://tessi.fornax.uberspace.de/xmas/1/";
        //const string url = "http://172.16.18.83:4567/1/";

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
            string name = "Tim" + DateTime.Now.ToString();
            EnqueueCallback(() => Account.Create(name,
                                                (Account ac) => global = ac,
                                                (ErrorInfo ei) => global = ei));
            EnqueueConditional(() => global != null);
            EnqueueCallback(() =>
            {
                Assert.IsInstanceOfType(global, typeof(Account));
                Assert.AreEqual(((Account)global).userId, name);
            });
            EnqueueTestComplete();
        }
    }
}
