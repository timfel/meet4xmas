package de.uni_potsdam.hpi.meet4android;

import android.test.ActivityInstrumentationTestCase2;
import junit.framework.Assert;
import org.meet4xmas.Service;
import org.meet4xmas.wire.IServiceAPI;
import org.meet4xmas.wire.NotificationServiceInfo;
import org.meet4xmas.wire.Response;

/**
 * This is a simple framework for a test of an Application.  See
 * {@link android.test.ApplicationTestCase ApplicationTestCase} for more information on
 * how to write and extend Application tests.
 * <p/>
 * To run this test, you can type:
 * adb shell am instrument -w \
 * -e class de.uni_potsdam.hpi.meet4android.SignUpActivityTest \
 * de.uni_potsdam.hpi.meet4android.tests/android.test.InstrumentationTestRunner
 */
public class SignUpActivityTest extends ActivityInstrumentationTestCase2<SignUpActivity> {

    private Service service;

    public SignUpActivityTest() {
        super("de.uni_potsdam.hpi.meet4android", SignUpActivity.class);
    }

    @Override
    public void setUp() throws Exception {
        super.setUp();

        this.service = new Service(getActivity(), "http://tessi.fornax.uberspace.de/xmas/2/");
    }

    public void testSignUp() {
        Service service = new Service(this);
        List<Appointment> appointments = service.getAppointments("hans@wur.st");
        Log.d("xmas", appointments.toString());
    }

    public Service getService() {
        return service;
    }
}
