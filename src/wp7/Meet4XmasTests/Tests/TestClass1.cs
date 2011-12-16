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

        [TestMethod]
        [Asynchronous]
        public void TestAccCreate()
        {
            object result = null;
            string name = "Tim" + DateTime.Now.ToString();
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
            string name = "Tim";
            Account tim = null;
            ErrorInfo error = null;
            EnqueueCallback(() => Account.Create(name,
                                                (Account ac) => tim = ac,
                                                (ErrorInfo ei) => error = ei));
            EnqueueConditional(() => tim != null || error != null);
            EnqueueCallback(() =>
            {
                Assert.IsNotNull(tim);
                Assert.IsNull(error);
                tim.Delete(() => tim = null,
                           (ErrorInfo ei) => error = ei);
            });
            EnqueueConditional(() => tim == null || error != null);
            EnqueueCallback(() =>
            {
                Assert.IsNull(error);
                Assert.IsNull(tim);
            });
            EnqueueTestComplete();
        }

        [TestMethod]
        [Asynchronous]
        public void TestAppointmentCreate()
        {
            string name = "Tim";
            Account tim = null;
            ErrorInfo error = null;
            object app = null;
            string testMessage = "Test Appointment";

            EnqueueCallback(() => Account.Create(name,
                                                (Account ac) => tim = ac,
                                                (ErrorInfo ei) => error = ei));
            EnqueueConditional(() => tim != null || error != null);
            EnqueueCallback(() =>
            {
                Assert.IsNotNull(tim);
                Appointment.Create(tim, TravelPlan.TravelType.Walk, new Participant[] { tim },
                    Location.LocationType.ChristmasMarket, testMessage,
                    (Appointment a) => app = a,
                    (ErrorInfo e) => error = e);
            });
            EnqueueConditional(() => app != null || error != null);
            EnqueueCallback(() =>
            {
                Assert.IsNull(error);
                Assert.IsInstanceOfType(app, typeof(Appointment));
                Assert.AreEqual(((Appointment)app).creator, tim.userId);
                Assert.IsNotNull(((Appointment)app).identifier);
                Assert.AreEqual(((Appointment)app).message, testMessage);
                Assert.AreEqual(((Appointment)app).locationType, Location.LocationType.ChristmasMarket);
                Assert.IsFalse(((Appointment)app).isFinal);
            });
            EnqueueTestComplete();
        }
    }
}
