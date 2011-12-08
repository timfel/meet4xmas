//package tessi.test;

import com.caucho.hessian.client.HessianProxyFactory;
import lib.java.*;

public class Test {
  public static void main(String[] args) throws Exception {
    //String url = "http://172.16.18.55:4567/";
    String url = "http://localhost:4567/1/";
    HessianProxyFactory factory = new HessianProxyFactory();
    Servlet appointment = (Servlet) factory.create(Servlet.class, url);

    // createAppointment
    ResponseBody response = appointment.createAppointment("tessi@tessenow.org", 0, null, new String[]{"student@hpi.uni-potsdam.de"}, 0, "my message to all my friends");
    if(response.success)
      System.out.println(response.payload);
    else
      System.out.println(response.error);

    // getAppointment
    response = appointment.getAppointment(40);
    if(response.success)
      System.out.println(response.payload);
    else
      System.out.println(response.error);
  }
}
