package org.meet4xmas;

import android.content.Context;
import android.telephony.TelephonyManager;
import com.caucho.hessian.client.HessianProxyFactory;
import de.uni_potsdam.hpi.meet4android.R;
import org.meet4xmas.wire.IServiceAPI;
import org.meet4xmas.wire.NotificationServiceInfo;

import java.net.MalformedURLException;

public class Service {

    private Context context;
    private HessianProxyFactory hessianFactory;
    private String url;

    public Service(Context context, String url) {
        this.context = context;
        this.url = url;
        hessianFactory = new HessianProxyFactory();

        hessianFactory.setHessian2Request(false);
        hessianFactory.setHessian2Reply(false);
    }

    public Service(Context context) {
        this(context, context.getResources().getString(R.string.service_url));
    }

    public void signUp(String email) {
        NotificationServiceInfo notificationServiceInfo = new NotificationServiceInfo();
        notificationServiceInfo.serviceType = NotificationServiceInfo.NotificationServiceType.C2DM;
        notificationServiceInfo.deviceId = new byte[]{0,0,7};
    }

    public String getDeviceId() {
        TelephonyManager tm = (TelephonyManager) context.getSystemService(Context.TELEPHONY_SERVICE);
        return tm.getDeviceId();
    }

    public IServiceAPI getAPI() {
        try {
            return (IServiceAPI) hessianFactory.create(IServiceAPI.class, getURL());
        } catch (MalformedURLException e) {
            throw new RuntimeException("Invalid Service URL: " + e.getMessage());
        }
    }

    public String getURL() {
        return url;
    }
}
