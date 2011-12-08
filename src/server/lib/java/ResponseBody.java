package lib.java;

import java.io.Serializable;

public class ResponseBody implements Serializable {
	public static class ErrorInfo implements Serializable {
		public int code;
		public String message;
	}

	public boolean success;
	public ErrorInfo error;
	public Object payload;
}
