/**
 * 
 */
package edu.byu.cc.plieber.util;

import java.util.ArrayList;

/**
 * @author plieber
 *
 */
public class StringUtil {
	public static String arrayToString(byte[] bytearray) {
		String ret = "";
		if (bytearray.length > 0 && bytearray != null) {
			ret += "<";
			for (int i=0; i<(bytearray.length-1); i++) {
				ret += bytearray[i] + ",";
			}
			ret += bytearray[bytearray.length-1] + ">";
		}
		return ret;
	}
	public static String listToString(ArrayList list) {
		String ret = "";
		if (list != null && list.size() > 0) {
			ret += "<";
			for (int i=0; i<(list.size()-1); i++) {
				ret += list.get(i) + ",";
			}
			ret += list.get(list.size()-1) + ">";
		}
		return ret;
	}
	public static ArrayList<Byte> stringToByteList(String str) {
		ArrayList<Byte> bytes = new ArrayList<Byte>(str.length());
		for (char ch : str.toCharArray()) {
			bytes.add((byte) (ch & 0xff));
		}
		return bytes;
	}
	public static String arrayToHexString(byte[] bytearray) {
		String ret = "";
		if (bytearray.length > 0 && bytearray != null) {
			for (int i=0; i<(bytearray.length); i++) {
				ret += String.format("%02x", bytearray[i]);
			}
		}
		return ret;
	}
}
