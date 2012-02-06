package de.uni_potsdam.hpi.meet4android;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import android.content.Intent;
import android.view.View;
import android.widget.AdapterView;
import android.widget.SimpleAdapter;
import org.meet4xmas.Service;
import org.meet4xmas.ServiceException;
import org.meet4xmas.wire.Appointment;

import android.app.Activity;
import android.os.Bundle;
import android.util.Log;
import android.widget.ListView;

public class AppointmentListActivity extends Activity {

    private AppointmentListActivity self = this;
    private SimpleAdapter appointmentAdapter;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.appointment_list);
        try {
            final List<Appointment> appointments = new Service(this).getAppointments(new Preferences(this).getUser());
            List<Map<String, String>> views = new ArrayList<Map<String, String>>(appointments.size());
            for (Appointment app: appointments) {
                Map<String, String> view = new HashMap<String, String>();
                view.put("title", app.message);
                views.add(view);
            }
            appointmentAdapter = new SimpleAdapter(this, views, R.layout.appointment_item,
                    new String[] { "title" }, new int[] { R.id.app_item_title });
            ListView list = (ListView) findViewById(R.id.appointment_list);
            list.setAdapter(appointmentAdapter);

            list.setOnItemClickListener(new AdapterView.OnItemClickListener() {
                public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                    Intent intent = new Intent(self, AppointmentShowActivity.class);
                    AppointmentShowActivity.setAppointment(intent, appointments.get(position));
                    startActivity(intent);
                }
            });
        } catch (ServiceException e) {
            Log.d("xmas", e.getMessage());
            new MessageBox("Error: " + e.getMessage(), this).show();
        }
    }
}
