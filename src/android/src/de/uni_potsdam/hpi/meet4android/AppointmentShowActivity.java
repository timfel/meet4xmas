package de.uni_potsdam.hpi.meet4android;

import java.util.List;

import org.meet4xmas.Service;
import org.meet4xmas.ServiceException;
import org.meet4xmas.wire.Appointment;

import android.app.Activity;
import android.os.Bundle;
import android.util.Log;

public class AppointmentShowActivity extends Activity {

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.appointment_show);
    }
}
