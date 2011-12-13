import com.caucho.hessian.client.HessianProxyFactory;
import org.meet4xmas.wire.*;

public class Test {
  public static void main(String[] args) throws Exception {
    //String url = "http://tessi.fornax.uberspace.de/xmas/1/";
    String url = "http://localhost:4567/1/";
    HessianProxyFactory factory = new HessianProxyFactory();
    IServiceAPI proxy = (IServiceAPI) factory.create(IServiceAPI.class, url);

    // createAppointment
    Response response = proxy.createAppointment("tessi@tessenow.org", 0, null, new String[]{"student@hpi.uni-potsdam.de"}, 0, "my message to all my friends");
    if(response.success)
      System.out.println(response.payload);
    else
      System.out.println(response.error);

    // getAppointment
    response = proxy.getAppointment(40);
    if(response.success)
      System.out.println(response.payload);
    else
      System.out.println(response.error);
  }
}
