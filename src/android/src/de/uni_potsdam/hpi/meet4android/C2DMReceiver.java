package de.uni_potsdam.hpi.meet4android;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;

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
            // Registration failed, should try again later.
        } else if (intent.getStringExtra("unregistered") != null) {
            // unregistration done, new messages from the authorized sender will be rejected
        } else if (registration != null) {
            // Send the registration ID to the 3rd party site that is sending the messages.
            // This should be done in a separate thread.
            // When done, remember that all registration is done.
        }
    }

    public void handleMessage(Context context, Intent intent) {
        String foobar = intent.getExtras().getString("foobar");
    }
}
