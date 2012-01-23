package de.uni_potsdam.hpi.meet4android;

import android.test.ActivityInstrumentationTestCase2;

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

    public SignUpActivityTest() {
        super("de.uni_potsdam.hpi.meet4android", SignUpActivity.class);
    }

}
