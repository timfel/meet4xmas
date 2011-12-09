package org.meet4xmas.wire;

public class ErrorInfo implements java.io.Serializable {
	public int code;
	public String message;

  public String toString() {
    return "API ERROR(" + code  +"): '" + message + "'";
  }
}
