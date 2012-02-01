package de.uni_potsdam.hpi.meet4android;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.util.Log;
import android.widget.Toast;
import org.meet4xmas.Service;
import org.meet4xmas.ServiceException;

public class C2DMReceiver extends BroadcastReceiver {

    public void onReceive(Context context, Intent intent) {
        if (intent.getAction().equals("com.google.android.c2dm.intent.REGISTRATION")) {
            handleRegistration(context, intent);
        } else if (intent.getAction().equals("com.google.android.c2dm.intent.RECEIVE")) {
            handleMessage(context, intent);
        }
    }

    public void handleRegistration(Context context, Intent intent) {
        String registration = intent.getStringExtra("registration_id");

        if (intent.getStringExtra("error") != null) {
            int id = context.getResources().getIdentifier("error_" + intent.getStringExtra("error").toLowerCase(),
                    "string", "de.uni_potsdam.hpi.meet4android");
            Toast.makeText(context, id, Toast.LENGTH_LONG).show();
        } else if (intent.getStringExtra("unregistered") != null) {
            new Preferences(context).setRegistrationId(null);
            Toast.makeText(context, "Unregistered with C2DM", Toast.LENGTH_LONG).show();
        } else if (registration != null) {
            new Preferences(context).setRegistrationId(registration);
            synchronizeRegistrationId(context, registration);
            Toast.makeText(context, "Registered with C2DM", Toast.LENGTH_LONG).show();
        }
    }

    public void handleMessage(Context context, Intent intent) {
        String msg = intent.getExtras().getString("message");
        Toast.makeText(context, "Received notification: " + msg, Toast.LENGTH_LONG).show();
        Log.d("xmas", "Received notification: " + msg);
    }

    /**
     * Sends the received registration_id to the meet4xmas server in order to get push notifications from it.
     *
     * @param id The registration id as received from Google.
     */
    public void synchronizeRegistrationId(final Context context, String id) {
        new Thread(new Runnable() {
            public void run() {
                Service service = new Service(context);
                Preferences pref = new Preferences(context);
                try {
                    service.signUp(pref.getUser());
                } catch (ServiceException e) {
                    Log.e("xmas", e.getMessage());
                }
            }
        }).start();
    }
}
