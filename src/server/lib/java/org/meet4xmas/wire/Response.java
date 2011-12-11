package org.meet4xmas.wire;

import org.meet4xmas.util.StringUtil;

public class Response implements java.io.Serializable {
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
