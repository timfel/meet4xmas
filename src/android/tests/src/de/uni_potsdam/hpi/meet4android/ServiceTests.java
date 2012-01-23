package de.uni_potsdam.hpi.meet4android;

import android.util.Log;
import junit.framework.Assert;
import android.test.AndroidTestCase;
import org.meet4xmas.Service;
import org.meet4xmas.wire.IServiceAPI;
import org.meet4xmas.wire.Response;

public class ServiceTests extends AndroidTestCase {

    public void testSignUp() throws Throwable {
        Service service = new Service("http://tessi.fornax.uberspace.de/xmas/2/");
        IServiceAPI api = service.getAPI();
        Response response = api.registerAccount("hans@wur.st", null);

        Assert.assertTrue(response.success);
    }
}
