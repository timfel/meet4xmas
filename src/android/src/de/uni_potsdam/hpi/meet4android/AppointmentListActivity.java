package de.uni_potsdam.hpi.meet4android;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import android.widget.SimpleAdapter;
import org.meet4xmas.Service;
import org.meet4xmas.ServiceException;
import org.meet4xmas.wire.Appointment;

import android.app.Activity;
import android.os.Bundle;
import android.util.Log;
import android.widget.ListView;

public class AppointmentListActivity extends Activity {
    private SimpleAdapter appointmentAdapter;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.appointment_list);
        try {
            List<Appointment> appointments = new Service(this).getAppointments(new Preferences(this).getUser());
            List<Map> views = new ArrayList<Map>(appointments.size());
            for (Appointment app: appointments) {
                Map<String, String> view = new HashMap<String, String>();
                view.put("title", app.message);
                views.add(view);
            }
            appointmentAdapter = new SimpleAdapter(this, views, R.layout.appointment_item,
                    new String[] { "title" }, new int[] { R.id.app_item_title });
            ListView list = (ListView) findViewById(R.id.appointment_list);
            list.setAdapter(appointmentAdapter);
        } catch (ServiceException e) {
            Log.d("xmas", e.getMessage());
        }
    }
}
