package org.meet4xmas;

import android.content.Context;
import com.caucho.hessian.client.HessianProxyFactory;
import de.uni_potsdam.hpi.meet4android.R;
import org.meet4xmas.wire.IServiceAPI;

import java.net.MalformedURLException;

public class Service {

    private HessianProxyFactory hessianFactory;
    private String url;

    public Service(String url) {
        this.url = url;
        hessianFactory = new HessianProxyFactory();

        hessianFactory.setHessian2Request(false);
        hessianFactory.setHessian2Reply(false);
    }

    public Service(Context ctx) {
        this(ctx.getResources().getString(R.string.service_url));
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
