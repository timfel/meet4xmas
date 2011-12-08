//package tessi.test;

import com.caucho.hessian.client.HessianProxyFactory;
import lib.java.Appointment;

public class Test {

  public interface BasicAPI {
    public Appointment getAppointment( int appointment_id );
  }

  public static void main(String[] args) throws Exception {
    //String url = "http://172.16.18.55:4567/";
    String url = "http://localhost:4567/";
    System.out.println(test);
    HessianProxyFactory factory = new HessianProxyFactory();
    BasicAPI appointment = (BasicAPI) factory.create(BasicAPI.class, url);
    System.out.println(appointment.getAppointment(0));
  }
}
