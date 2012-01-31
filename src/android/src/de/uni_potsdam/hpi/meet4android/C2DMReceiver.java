package de.uni_potsdam.hpi.meet4android;

import android.app.AlertDialog;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.res.Resources;
import android.util.Log;
import android.view.View;
import android.widget.Toast;

public class C2DMReceiver extends BroadcastReceiver {

    public C2DMReceiver() {
        Log.d("xmas", "instantiated C2DMReceiver");
    }

    public void onReceive(Context context, Intent intent) {
        Log.d("xmas", "receiving something");
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
            Toast.makeText(context, "Unregistered", Toast.LENGTH_LONG).show();
        } else if (registration != null) {
            new Preferences(context).setRegistrationId(registration);
            synchronizeRegistrationId(registration);
            Toast.makeText(context, "Registered", Toast.LENGTH_LONG).show();
        }
    }

    public void handleMessage(Context context, Intent intent) {
        Log.d("xmas", "receiving message");
        String foobar = intent.getExtras().getString("foobar");
    }

    /**
     * Sends the received registration_id to the meet4xmas server in order to get push notifications from it.
     *
     * @param id The registration id as received from Google.
     */
    public void synchronizeRegistrationId(String id) {
        new Thread(new Runnable() {
            public void run() {
                // @TODO send it to the server
            }
        }).start();
    }
}
