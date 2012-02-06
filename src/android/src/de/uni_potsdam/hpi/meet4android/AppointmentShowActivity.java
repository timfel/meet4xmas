package de.uni_potsdam.hpi.meet4android;

import org.meet4xmas.wire.Appointment;

import android.content.Intent;
import android.os.Bundle;
import android.widget.LinearLayout;

import com.google.android.maps.GeoPoint;
import com.google.android.maps.MapActivity;
import com.google.android.maps.MapController;
import com.google.android.maps.MapView;


public class AppointmentShowActivity extends MapActivity {
    private LinearLayout linearLayout;
    private MapView mapView;
    private MapController mapController;
    private GeoPoint meetingPoint;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        Appointment app = getAppointment();

        setContentView(R.layout.appointment_show);
        mapView = (MapView) findViewById(R.id.mapview);
        mapView.setBuiltInZoomControls(true);
        mapController = mapView.getController();
        mapController.setZoom(14); // Zoom 1 is world view
        meetingPoint = new GeoPoint((int)(app.location.latitude * 1E6), (int)(app.location.longitude * 1E6));
        mapController.animateTo(meetingPoint);

//        ((TextView) findViewById(R.id.textView1)).setText(app.message);
    }

    @Override
    protected boolean isRouteDisplayed() {
        return false;
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
