package de.uni_potsdam.hpi.meet4android;

import android.content.Intent;
import org.meet4xmas.Service;
import org.meet4xmas.wire.Response;

import android.app.Activity;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;
import android.widget.Toast;

public class SignUpActivity extends Activity {

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
                Response response = new Service(getApplicationContext()).getAPI().registerAccount(email, null);
                if (response.success) {
                    startActivity(new Intent(SignUpActivity.this, MenuActivity.class));
                } else {
                    Toast.makeText(SignUpActivity.this,
                            "Error " + response.error.code + ": " + response.error.message, Toast.LENGTH_LONG).show();
                }
            }
        });
    }
}
