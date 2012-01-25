package de.uni_potsdam.hpi.meet4android;

import android.content.Intent;
import org.meet4xmas.Service;
import org.meet4xmas.ServiceException;
import org.meet4xmas.wire.Response;

import android.app.Activity;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;
import android.widget.Toast;

public class SignUpActivity extends Activity {

    protected SignUpActivity self = this;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.signup);

        setupSignUpButton();
    }

    protected void setupSignUpButton() {
        final Button button = (Button) findViewById(R.id.signUpButton);
        button.setOnClickListener(new View.OnClickListener() {
            public void onClick(View v) {
                String email = ((TextView) findViewById(R.id.signUpEmail)).getText().toString();
                try {
                    new Service(self).signUp(email);
                    new Preferences(self).setUser(email);
                    startActivity(new Intent(self, MenuActivity.class));
                } catch (ServiceException e) {
                    Toast.makeText(self, e.getMessage(), Toast.LENGTH_LONG).show();
                }
            }
        });
    }
}
