/**
 * 
 */
package edu.byu.cc.plieber.fpgaenet.debug.llparse;

import java.io.FileInputStream;
import java.io.FileNotFoundException;

/**
 * @author plieber
 *
 */
public class Test_LL_Virtex5 {

	/**
	 * @param args
	 */
	public static void main(String[] args) {
		// TODO Auto-generated method stub
		LL_Virtex5 parser = null;
		try {
			parser = new LL_Virtex5(new FileInputStream(args[0]));
		} catch (FileNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		parser.initTables();
		try {
			parser.parseLL();
		} catch (ParseException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		System.err.println("DOne");
	}

}
