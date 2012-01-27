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
    public class AppointmentTest : SilverlightTest
    {
        [TestInitialize]
        public void setUp()
        {
            ServiceCall.ServiceUrl = "http://tessi.fornax.uberspace.de/xmas/2/";
            //ServiceCall.ServiceUrl = "http://172.16.16.116:4567/1/";
            //ServiceCall.ServiceUrl = "http://172.16.18.83:4567/1/";
            //ServiceCall.ServiceUrl = "http://172.16.59.124:4567/1/";
            //ServiceCall.ServiceUrl = "http://172.16.18.55:4567/1/";
        }

        public string getNewName()
        {
            return String.Format("Tim{0}@example.com", DateTime.Now.Ticks.ToString());
        }

        [TestMethod]
        [Asynchronous]
        public void TestAppointmentCreate()
        {
            string name = getNewName();
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
                Appointment.Create(tim, TravelPlan.TravelType.Walk, new Participant[] { },
                    Location.LocationType.ChristmasMarket, testMessage,
                    (Appointment a) => app = a,
                    (ErrorInfo e) => error = e);
            });
            EnqueueConditional(() => app != null || error != null);
            EnqueueCallback(() =>
            {
                assertNoError(error);
                Assert.IsInstanceOfType(app, typeof(Appointment));
                Assert.AreEqual(((Appointment)app).creator, tim.userId);
                Assert.IsNotNull(((Appointment)app).identifier);
                Assert.AreEqual(((Appointment)app).message, testMessage);
                Assert.AreEqual(((Appointment)app).locationType, Location.LocationType.ChristmasMarket);
                Assert.IsFalse(((Appointment)app).isFinal);
            });
            EnqueueTestComplete();
        }

        private static void assertNoError(ErrorInfo error)
        {
            String msg = error == null ? "" : error.message;
            Assert.IsNull(error, msg);
        }

        [TestMethod]
        [Asynchronous]
        public void TestAppointmentGetTravelPlan()
        {
            string name = getNewName();
            Account tim = null;
            ErrorInfo error = null;
            Appointment app = null;
            TravelPlan travelPlan = null;
            string testMessage = "Test Appointment";

            EnqueueCallback(() => Account.Create(name, (Account ac) => tim = ac, (ErrorInfo ei) => error = ei));
            EnqueueConditional(() => tim != null || error != null);
            EnqueueCallback(() =>
            {
                Assert.IsNotNull(tim, "Account creation failed");
                Appointment.Create(tim, TravelPlan.TravelType.Walk, new Participant[] { },
                    Location.LocationType.ChristmasMarket, testMessage,
                    (Appointment a) => app = a,
                    (ErrorInfo e) => error = e);
            });
            EnqueueConditional(() => app != null || error != null);
            EnqueueCallback(() =>
            {
                Assert.IsNotNull(app, "Appointment creation failed");
                app.GetTravelPlan(TravelPlan.TravelType.Car,
                    (TravelPlan t) => travelPlan = t,
                    (ErrorInfo e) => error = e);
            });
            EnqueueConditional(() => travelPlan != null || error != null);
            EnqueueCallback(() =>
            {
                assertNoError(error);
                Assert.IsNotNull(travelPlan);
            });
            EnqueueTestComplete();
        }

        [TestMethod]
        [Asynchronous]
        public void TestAppointmentFinalize()
        {
            string name = getNewName();
            Account tim = null;
            ErrorInfo error = null;
            Appointment app = null;
            TravelPlan travelPlan = null;
            string testMessage = "Test Appointment";

            EnqueueCallback(() => Account.Create(name, (Account ac) => tim = ac, (ErrorInfo ei) => error = ei));
            EnqueueConditional(() => tim != null || error != null);
            EnqueueCallback(() =>
            {
                Assert.IsNotNull(tim, "Account creation failed");
                Appointment.Create(tim, TravelPlan.TravelType.Walk, new Participant[] { },
                    Location.LocationType.ChristmasMarket, testMessage,
                    (Appointment a) => app = a,
                    (ErrorInfo e) => error = e);
            });
            EnqueueConditional(() => app != null || error != null);
            EnqueueCallback(() =>
            {
                Assert.IsNotNull(app, "Appointment creation failed");
                app.Finalize(() => { }, (ErrorInfo e) => error = e);
            });
            EnqueueConditional(() => app.isFinal == true || error != null);
            EnqueueCallback(() =>
            {
                assertNoError(error);
                Assert.IsTrue(app.isFinal);
            });
            EnqueueTestComplete();
        }
    }
}
