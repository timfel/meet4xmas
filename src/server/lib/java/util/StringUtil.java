package lib.java.util;

public class StringUtil {
	static String NULL_STRING = "<null>";

	public static String ValueOrNullToString(Object obj) {
		if (obj == null) {
			return NULL_STRING;
		} else {
			return obj.toString();
		}
	}

	public static interface IArrayElementVisitor {
		public String visitElement(Object elem);
	}
	public static class DefaultArrayElementVisitor implements IArrayElementVisitor {
		public String visitElement(Object elem) {
			return ValueOrNullToString(elem);
		}
	}
	public static class StringArrayElementVisitor implements IArrayElementVisitor {
		public String visitElement(Object elem) {
			if(elem == null) {
        return StringUtil.NULL_STRING;
      } else {
        return "'" + elem + "'";
      }
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
