package lib.java;

public interface Appointment {
  public int id();
  public int locationType(); // 0 -> xmas market
  public Location location();
  public String[] invitees();
  public String[] participants();
}
