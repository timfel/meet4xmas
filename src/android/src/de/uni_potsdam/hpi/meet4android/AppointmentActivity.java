package de.uni_potsdam.hpi.meet4android;

import android.app.Activity;
import android.os.Bundle;
import android.view.View;
import android.widget.*;

public class AppointmentActivity extends Activity {

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.appointment);

        setupListView();
    }

    protected void setupListView() {
        final ListView list = (ListView) findViewById(R.id.who_list);
        list.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                Toast.makeText(getApplicationContext(), ((TextView) view).getText(),
                        Toast.LENGTH_SHORT).show();
            }
        });
    }
}
