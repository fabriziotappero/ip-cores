package pl.com.kgajewski.serialcomm.datagen;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;

import org.apache.commons.lang3.StringUtils;


public class PresentDataGenerator {
	public static void main(String[] args) {
		String drive = "e:\\";
		String data = "a112ffc72f68417b";
		String key  = "00000000000000000000";
		
		String data2 = "3333dcd3213210d2";
		String key2  = "ffffffffffffffffffff";
		
		try {
			System.out.println("key");
			File f1 = new File(drive + "key.txt");
			f1.createNewFile();
			formatDataFromHex(key, f1);
			
			System.out.println("data");
			File f2 = new File(drive + "data.txt");
			f1.createNewFile();
			formatDataFromHex(data, f2);
			
			System.out.println("key2");
			File f3 = new File(drive + "key2.txt");
			f3.createNewFile();
			formatDataFromHex(key2, f3);
			
			System.out.println("data2");
			File f4 = new File(drive + "data2.txt");
			f4.createNewFile();
			formatDataFromHex(data2, f4);
			
		} catch (IOException e1) {
			// TODO Auto-generated catch block
			e1.printStackTrace();
		} 
		
	}
	
	private static void formatDataFromHex(String str, File f) throws IOException {
		BufferedWriter bfw = new BufferedWriter(new FileWriter(f));
		for (int i = str.length(); i > 0; i -= 2) {
			String substr = str.substring(i - 2, i);

			parseByteStringHex(bfw, substr);
		}
		bfw.close();
	}
	
	private static void parseByteStringHex(BufferedWriter bfw, String str)
			throws IOException {
		Integer i = Integer.valueOf(str, 16);
		String s = Integer.toString(i, 2);
		String tmp = "";
		for (int j = 8 - s.length(); j > 0; j--) {
			tmp = tmp.concat("0");
		}
		parseByteString(bfw, tmp + s);
	}
	
	private static void parseByteString(BufferedWriter bfw, String str)
			throws IOException {
		int ones = 0;
		bfw.write(str);
		bfw.write("\n");
		str = StringUtils.reverse(str);

		for (int j = 0; j < str.length(); j++) {
			bfw.write(str.charAt(j));
			bfw.write("\n");
			if (str.charAt(j) == '1') {
				ones++;
			}
		}
		if (ones % 2 == 1) {
			bfw.write("0");
		} else {
			bfw.write("1");
		}
		bfw.write("\n");
	}

}
