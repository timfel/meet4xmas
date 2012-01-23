package org.meet4xmas.util;

import java.util.Formatter;

public class StringUtil {
  static String NULL_STRING = "<null>";

  public static String ValueOrNullToString(Object obj, boolean testForString) {
    if (obj == null) {
      return NULL_STRING;
    } else if(testForString && obj instanceof String) {
      return "'" + obj + "'";
    } else if(obj instanceof byte[]) {
      Formatter formatter = new Formatter();
      for (byte b : (byte[])obj)
          formatter.format("%02x", b);
      return formatter.toString();
    } else {
      return obj.toString();
    }
  }

  public static String ValueOrNullToString(Object obj) {
    return ValueOrNullToString(obj, false);
  }

  public static interface IArrayElementVisitor {
    public String visitElement(Object elem);
  }
  public static class DefaultArrayElementVisitor implements IArrayElementVisitor {
    public String visitElement(Object elem) {
      return ValueOrNullToString(elem);
    }
  }

  public static String ArrayOrNullToString(Object[] arr, IArrayElementVisitor visitor) {
    if (arr == null) {
      return NULL_STRING;
    } else {
      StringBuilder sb = new StringBuilder("[");
      for(int i = 0; i < arr.length; i++) {
        sb.append(visitor.visitElement(arr[i]));
        if(i < arr.length - 1) sb.append(", ");
      }
      sb.append("]");
      return sb.toString();
    }
  }

  public static String ArrayOrNullToString(Object[] arr) {
    return ArrayOrNullToString(arr, new DefaultArrayElementVisitor());
  }
}
