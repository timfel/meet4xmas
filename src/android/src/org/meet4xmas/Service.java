package org.meet4xmas;

import java.io.UnsupportedEncodingException;
import java.net.MalformedURLException;
import java.util.ArrayList;
import java.util.Collection;
import java.util.List;

import org.meet4xmas.wire.Appointment;
import org.meet4xmas.wire.ErrorInfo;
import org.meet4xmas.wire.IServiceAPI;
import org.meet4xmas.wire.Location;
import org.meet4xmas.wire.NotificationServiceInfo;
import org.meet4xmas.wire.Response;

import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.location.Criteria;
import android.location.LocationManager;

import com.caucho.hessian.client.HessianProxyFactory;

import de.uni_potsdam.hpi.meet4android.Preferences;
import de.uni_potsdam.hpi.meet4android.R;

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

    public void registerWithC2DM() {
        Intent registrationIntent = new Intent("com.google.android.c2dm.intent.REGISTER");
        registrationIntent.putExtra("app", PendingIntent.getBroadcast(context, 0, new Intent(), 0));
        registrationIntent.putExtra("sender", context.getText(R.string.meet4xmas_account));
        context.startService(registrationIntent);
    }

    public void unregisterWithC2DM() {
        Intent unregIntent = new Intent("com.google.android.c2dm.intent.UNREGISTER");
        unregIntent.putExtra("app", PendingIntent.getBroadcast(context, 0, new Intent(), 0));
        context.startService(unregIntent);
    }

    /**
     * Registers the given email with the Meet4Xmas server.
     *
     * @param email The email to be registered.
     * @throws ServiceException When registration fails.
     */
    public void signUp(String email) throws ServiceException {
        String deviceId = getDeviceId();
        NotificationServiceInfo notificationServiceInfo;
        if (deviceId != null) {
            notificationServiceInfo = new NotificationServiceInfo();
            notificationServiceInfo.serviceType = NotificationServiceInfo.NotificationServiceType.C2DM;
            notificationServiceInfo.deviceId = getBytes(getDeviceId());
        } else {
            notificationServiceInfo = null;
        }

        Response response = getAPI().registerAccount(email, notificationServiceInfo);
        if (!response.success) {
            raise("Sign-up failed", response.error);
        }
    }

    public Appointment getAppointment(int id) throws ServiceException {
        return (Appointment) getAPI().getAppointment(id).payload;
    }

    public List<Appointment> getAppointments(String email) throws ServiceException {
        Response response = getAPI().registerAccount(email, null);
        if (!response.success) {
            raise("Sign-up failed", response.error);
        }
        List<Long> appIds = (List<Long>) response.payload;
        List<Appointment> appointments = new ArrayList<Appointment>(appIds.size());
        for (long id: appIds) {
            appointments.add((Appointment)getAPI().getAppointment((int) id).payload);
        }
        return appointments;
    }

    public int createAppointment(String user, android.location.Location location, String what, Collection<String> invitees,
                                  int travelType) throws ServiceException {
        Location loc = new Location();
        loc.title = "current location";
        loc.description = "where I am right now";
        if (location != null) {
            loc.latitude = location.getLatitude();
            loc.longitude = location.getLongitude();
        } else {
            loc.latitude = 52.396868;
            loc.longitude = 13.13467;
        }
        Response response = getAPI().createAppointment(user, travelType, loc,
                invitees.toArray(new String[invitees.size()]), Location.LocationType.ChristmasMarket, what);
        if (!response.success) {
            raise("Appointment Creation failed", response.error);
        }
        return ((Long) response.payload).intValue();
    }

    /**
     * Negotiates a registration ID with the Google servers.
     *
     * @return A registration ID usable to send push notifications to this device.
     */
    public String getDeviceId() {
        return new Preferences(context).getRegistrationId();
    }

    protected String selectProvider(LocationManager manager) {
        Criteria crit = new Criteria();
        crit.setHorizontalAccuracy(Criteria.ACCURACY_FINE);

        return manager.getBestProvider(crit, true);
    }

    public IServiceAPI getAPI() {
        try {
            return (IServiceAPI) hessianFactory.create(IServiceAPI.class, getURL());
        } catch (MalformedURLException e) {
            throw new RuntimeException("Invalid Service URL: " + e.getMessage());
        }
    }

    protected void raise(String msg, ErrorInfo error) throws ServiceException {
        String errorMessage;
        if (error != null) {
            errorMessage = msg + String.format(" Cause: Error %d (%s)", error.code, error.message);
        } else {
            errorMessage = msg + " Cause: unknown";
        }
        throw new ServiceException(errorMessage);
    }

    protected byte[] getBytes(String str) {
        try {
            return str.getBytes("UTF-8");
        } catch (UnsupportedEncodingException e) {
            throw new RuntimeException("Don't think so.", e);
        }
    }

    public String getURL() {
        return url;
    }
}
