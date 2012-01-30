package org.meet4xmas;

import android.content.Context;
import android.location.*;
import android.os.Bundle;
import android.telephony.TelephonyManager;
import android.util.Log;
import com.caucho.hessian.client.HessianProxyFactory;
import de.uni_potsdam.hpi.meet4android.R;
import org.meet4xmas.wire.*;
import org.meet4xmas.wire.Location;

import java.io.UnsupportedEncodingException;
import java.net.MalformedURLException;
import java.util.Collection;
import java.util.LinkedList;
import java.util.List;

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

    /**
     * Registers the given email with the Meet4Xmas server.
     *
     * @param email The email to be registered.
     * @throws ServiceException When registration fails.
     */
    public void signUp(String email) throws ServiceException {
        NotificationServiceInfo notificationServiceInfo = new NotificationServiceInfo();
        notificationServiceInfo.serviceType = NotificationServiceInfo.NotificationServiceType.C2DM;
        notificationServiceInfo.deviceId = getBytes(getDeviceId());

        Response response = getAPI().registerAccount(email, notificationServiceInfo);
        if (!response.success) {
            raise("Sign-up failed", response.error);
        }
    }

    public void createAppointment(String user, String what, Collection<String> invitees,
                                  int travelType) throws ServiceException {

        Response response = getAPI().createAppointment(user, travelType, getLocation(),
                invitees.toArray(new String[invitees.size()]), Location.LocationType.ChristmasMarket, what);
        if (!response.success) {
            raise("Appointment Creation failed", response.error);
        }
    }

    /**
     * Negotiates a registration ID with the Google servers.
     *
     * @return A registration ID usable to send push notifications to this device.
     */
    public String getDeviceId() {
        return "@TODO"; // @TODO
    }

    public Location getLocation() throws ServiceException {

        LocationManager mngr = (LocationManager) context.getSystemService(Context.LOCATION_SERVICE);
        String locProvider = selectProvider(mngr);

        if (locProvider == null) {
            throw new ServiceException("No appropriate location provider found (in: " + mngr.getAllProviders() + ").");
        }
        android.location.Location dloc = mngr.getLastKnownLocation(locProvider);
        if (dloc == null) {
            final List<android.location.Location> locs = new LinkedList<android.location.Location>();
            mngr.requestSingleUpdate(locProvider, new LocationListener() {
                public void onLocationChanged(android.location.Location location) {
                    Log.d("xmas", "added location");
                    locs.add(location);
                }
                public void onStatusChanged(String s, int i, Bundle bundle) { Log.d("xmas", "status changed " + s + ", " + i); }
                public void onProviderEnabled(String s) { Log.d("xmas", "provider " + s + " enabled"); }
                public void onProviderDisabled(String s) { Log.d("xmas", "provider " + s + " disabled"); }
            }, null);
            Log.d("xmas", "meeeeh");
            try { Thread.sleep(1000); } catch (Exception e) { }
            if (locs.size() == 0) {
                throw new ServiceException("Location Provider disabled");
            } else {
                dloc = locs.get(0);
            }
        }

        Location loc = new Location();
        loc.title = "current location";
        loc.description = "where I am right now";
        loc.latitude = dloc.getLatitude();
        loc.longitude = dloc.getLongitude();

        return loc;
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
