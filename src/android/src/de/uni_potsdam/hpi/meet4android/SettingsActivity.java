package de.uni_potsdam.hpi.meet4android;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;
import org.meet4xmas.Service;

public class SettingsActivity extends Activity {

    private SettingsActivity self = this;

    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.settings);

        setupApplyButton();
        setupCloseButton();
        setupRegistrationId();
    }

    protected void setupRegistrationId() {
        final TextView view = (TextView) findViewById(R.id.registrationIdView);
        view.setText(new Preferences(self).getRegistrationId());
    }

    protected void setupApplyButton() {
        final Button button = (Button) findViewById(R.id.applySettingsButton);
        button.setOnClickListener(new View.OnClickListener() {
            public void onClick(View v) {
                new Service(self).unregisterWithC2DM();
            }
        });
    }

    protected void setupCloseButton() {
        final Button button = (Button) findViewById(R.id.closeSettingsButton);
        button.setOnClickListener(new View.OnClickListener() {
            public void onClick(View v) {
                startActivity(new Intent(self, MenuActivity.class));
            }
        });
    }
}
