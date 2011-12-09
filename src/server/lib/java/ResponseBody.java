package lib.java;

import lib.java.util.StringUtil;
import java.io.Serializable;

public class ResponseBody implements Serializable {
	public static class ErrorInfo implements Serializable {
		public int code;
		public String message;

    public String toString() {
      return "API ERROR(" + code  +"): '" + message + "'";
    }
	}

	public boolean success;
	public ErrorInfo error;
	public Object payload;

	public String toString() {
		StringBuilder sb = new StringBuilder("ResponseBody(");
    sb.append("@success: ").append(success).append(", ");
    sb.append("@error: ").append(StringUtil.ValueOrNullToString(error)).append(", ");
    sb.append("@payload: ").append(StringUtil.ValueOrNullToString(payload));
    sb.append(")");
    return sb.toString();
	}
}
