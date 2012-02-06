package de.uni_potsdam.hpi.meet4android;

import android.content.Intent;
import android.widget.TextView;
import org.meet4xmas.wire.Appointment;

import android.app.Activity;
import android.os.Bundle;

public class AppointmentShowActivity extends Activity {

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.appointment_show);

        Appointment app = getAppointment();

        ((TextView) findViewById(R.id.textView1)).setText(app.message);
    }

    public Appointment getAppointment() {
        return (Appointment) getIntent().getExtras().getBundle("data").get("appointment");
    }

    public static void setAppointment(Intent intent, Appointment appointment) {
        Bundle bundle = new Bundle();
        bundle.putSerializable("appointment", appointment);
        intent.putExtra("data", bundle);
    }
}
