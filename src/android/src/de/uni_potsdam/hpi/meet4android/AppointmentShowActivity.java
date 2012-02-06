package de.uni_potsdam.hpi.meet4android;

import android.widget.TextView;
import org.meet4xmas.wire.Appointment;

import android.app.Activity;
import android.os.Bundle;

public class AppointmentShowActivity extends Activity {

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.appointment_show);

        Appointment app = (Appointment) getIntent().getExtras().getBundle("data").get("appointment");

        ((TextView) findViewById(R.id.textView1)).setText(app.message);
    }
}
