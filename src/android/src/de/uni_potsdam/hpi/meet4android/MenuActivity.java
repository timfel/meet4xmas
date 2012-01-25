package de.uni_potsdam.hpi.meet4android;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;

public class MenuActivity extends Activity {

    protected MenuActivity self = this;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.menu);

        setupLogoutButton();
    }

    protected void setupLogoutButton() {
        final Button button = (Button) findViewById(R.id.menuLogout);
        button.setOnClickListener(new View.OnClickListener() {
            public void onClick(View v) {
                new Preferences(self).setUser(null);
                startActivity(new Intent(self, SignUpActivity.class));
            }
        });
    }
}
