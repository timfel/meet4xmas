package de.uni_potsdam.hpi.meet4android;

import java.util.List;

import org.meet4xmas.Service;
import org.meet4xmas.ServiceException;
import org.meet4xmas.wire.Appointment;

import android.app.Activity;
import android.os.Bundle;
import android.util.Log;
import android.widget.ArrayAdapter;
import android.widget.ListView;

public class AppointmentListActivity extends Activity {
    private ArrayAdapter<Appointment> appointmentAdapter;
    
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.appointment_list);
        try {
            List<Appointment> appointments = new Service(this).getAppointments(new Preferences(this).getUser());
            appointmentAdapter = new ArrayAdapter<Appointment>(this, R.layout.appointment_item);
            ListView list = (ListView) findViewById(R.id.appointment_list);
            list.setAdapter(appointmentAdapter);
        } catch (ServiceException e) {
            Log.d("xmas", e.getMessage());
        }
    }
}
