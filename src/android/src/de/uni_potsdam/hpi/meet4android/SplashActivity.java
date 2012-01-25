package de.uni_potsdam.hpi.meet4android;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;

public class SplashActivity extends Activity {
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        Preferences pref = new Preferences(this);
        if (pref.isUser()) {
            startActivity(new Intent(this, MenuActivity.class));
        } else {
            startActivity(new Intent(this, SignUpActivity.class));
        }
    }
}
