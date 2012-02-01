package de.uni_potsdam.hpi.meet4android;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.Toast;
import org.meet4xmas.Service;

public class MenuActivity extends Activity {

    protected MenuActivity self = this;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.menu);

        Preferences pref = new Preferences(this);

        setTitle(pref.getUser());
        setupAppointmentButton();
        setupSettingsButton();
        setupLogoutButton();

        if (!pref.isRegistrationId()) {
            new Thread(new Runnable() {
                public void run() {
                    new Service(self).registerWithC2DM();
                }
            }).start();
        }
    }

    protected void setupAppointmentButton() {
        final Button button = (Button) findViewById(R.id.menuCreateAppointment);
        button.setOnClickListener(new View.OnClickListener() {
            public void onClick(View v) {
                startActivity(new Intent(self, AppointmentActivity.class));
            }
        });
    }

    protected void setupSettingsButton() {
        final Button button = (Button) findViewById(R.id.menuSettings);
        button.setOnClickListener(new View.OnClickListener() {
            public void onClick(View v) {
                startActivity(new Intent(self, SettingsActivity.class));
            }
        });
    }

    protected void setupLogoutButton() {
        final Button button = (Button) findViewById(R.id.menuLogout);
        button.setOnClickListener(new View.OnClickListener() {
            public void onClick(View v) {
                new Thread(new Runnable() {
                    public void run() {
                        Preferences pref = new Preferences(self);
                        pref.setUser(null);
                    }
                }).start();
                startActivity(new Intent(self, SignUpActivity.class));
            }
        });
    }
}
