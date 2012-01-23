package de.uni_potsdam.hpi.meet4android;

import java.net.MalformedURLException;

import org.meet4xmas.wire.IServiceAPI;
import org.meet4xmas.wire.Response;

import android.app.Activity;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;
import android.widget.Toast;

import com.caucho.hessian.client.HessianProxyFactory;

public class SignUpActivity extends Activity {
    /** Called when the activity is first created. */
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.main);

        setupSignUpButton();

        String url = "http://tessi.fornax.uberspace.de/xmas/2/";
        HessianProxyFactory factory = new HessianProxyFactory();
        // Use Hessian protocol v1
        factory.setHessian2Request(false);
        factory.setHessian2Reply(false);

        IServiceAPI proxy;
        Response response;
		try {
			proxy = (IServiceAPI) factory.create(IServiceAPI.class, url);

//			NotificationServiceInfo notificationServiceInfo = new NotificationServiceInfo();
//			notificationServiceInfo.serviceType = 2;
//			notificationServiceInfo.deviceId = new byte[]{0,0,7};

			response = proxy.registerAccount("robert.aschenbrenner@student.hpi.uni-potsdam.de", null);
	        if(response.success)
	          System.out.println(response.payload);
	        else
	          System.out.println(response.error);

	        // createAppointment
//			Location loc = new Location();
//			loc.latitude = 52.440107;
//			loc.longitude = 13.246536;
//	        response = proxy.createAppointment("robert.aschenbrenner@student.hpi.uni-potsdam.de", 0, loc, new String[]{"lysann.kessler@gmail.com"}, 0, "my message to all my friends");
//	        if(response.success)
//	          System.out.println(response.payload);
//	        else
//	          System.out.println(response.error);

	        // getAppointment
	        response = proxy.getAppointment(3);
	        if(response.success)
	          System.out.println(response.payload);
	        else
	          System.out.println(response.error);
		} catch (MalformedURLException e) {
			e.printStackTrace();
		}
    }

    protected void setupSignUpButton() {
        final Button button = (Button) findViewById(R.id.signUpButton);
        button.setOnClickListener(new View.OnClickListener() {
            public void onClick(View v) {
                String email = ((TextView) findViewById(R.id.signUpEmail)).getText().toString();
                Toast.makeText(SignUpActivity.this, "Given email: " + email, Toast.LENGTH_SHORT).show();
            }
        });
    }
}
