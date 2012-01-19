using Microsoft.Silverlight.Testing;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using hessiancsharp.client;
using System.Reflection;
using org.meet4xmas.wire;
using System;
using System.Threading;
using Meet4Xmas;

namespace Meet4XmasTests.Tests
{
    [TestClass]
    public class AccountTest : SilverlightTest
    {
        [TestInitialize]
        public void setUp()
        {
            // ServiceCall.ServiceUrl = "http://tessi.fornax.uberspace.de/xmas/1/";
            //ServiceCall.ServiceUrl = "http://172.16.16.116:4567/1/";
            //ServiceCall.ServiceUrl = "http://172.16.18.83:4567/1/";
            //ServiceCall.ServiceUrl = "http://172.16.59.124:4567/1/";
            ServiceCall.ServiceUrl = "http://172.16.18.55:4567/2/";
        }

        public string getNewName()
        {
            return String.Format("Tim{0}@example.com", DateTime.Now.Ticks.ToString());
        }

        private static void assertNoError(ErrorInfo error)
        {
            String msg = error == null ? "" : error.message;
            Assert.IsNull(error, msg);
        }

        [TestMethod]
        [Asynchronous]
        public void TestAccCreate()
        {
            object result = null;
            string name = getNewName();
            EnqueueCallback(() => Account.Create(name,
                                                (Account ac) => result = ac,
                                                (ErrorInfo ei) => result = ei));
            EnqueueConditional(() => result != null);
            EnqueueCallback(() =>
            {
                Assert.IsInstanceOfType(result, typeof(Account));
                Assert.AreEqual(((Account)result).userId, name);
            });
            EnqueueTestComplete();
        }

        [TestMethod]
        [Asynchronous]
        public void TestAccDelete()
        {
            string name = getNewName();
            Account tim = null;
            ErrorInfo error = null;
            EnqueueCallback(() => Account.Create(name,
                                                (Account ac) => tim = ac,
                                                (ErrorInfo ei) => error = ei));
            EnqueueConditional(() => tim != null || error != null);
            EnqueueCallback(() =>
            {
                Assert.IsNotNull(tim);
                assertNoError(error);
                tim.Delete(() => tim = null,
                           (ErrorInfo ei) => error = ei);
            });
            EnqueueConditional(() => tim == null || error != null);
            EnqueueCallback(() =>
            {
                assertNoError(error);
                Assert.IsNull(tim);
            });
            EnqueueTestComplete();
        }
    }
}
