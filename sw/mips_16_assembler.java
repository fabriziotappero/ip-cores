import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.util.Hashtable;

public class mips_16_assembler {

	private static File sourceFile, destFile;
	private static Hashtable<String, Integer>  labelList = new Hashtable<String, Integer>();
	private static Hashtable<String, Integer>  instructionList = new Hashtable<String, Integer>();
	private static int currentLine = 0;
	private static int codeLineCnt = 0;
	
	public static void main(String[] args) {
		if(args.length == 0)
		{
			System.out.println("no filename specified");
			System.exit(-1);
		}
		sourceFile = new File(args[0]);
		
		if(args.length == 1)
		{
			if(args[0].equalsIgnoreCase("-h") || args[0].equalsIgnoreCase("--help") )
			{
				System.out.println("Useage:");
				System.out.println("java mips_16_assembler [options]");
				System.out.println("options:");
				System.out.println("<source_code_path> <dest_path>:");
				System.out.println("\tAssemble source code to dest. For exaple .\\bin\\test1.asm .\\bin\\test1.prog");
				System.out.println("<source_code_path>:");
				System.out.println("\tAssemble source code to dest file a.prog");
				System.out.println("-h(or --help):");
				System.out.println("\tShow this help");
				System.exit(0);
			}
			else
			{
				if(sourceFile.getParent() != null)
					destFile = new File(sourceFile.getParent().concat(File.separator).concat("a.prog"));
				else
					destFile = new File("a.prog");
			}
		}
		else if(args.length == 2)
		{
			destFile = new File(args[1]);
		}
		
		
		if(!destFile.exists())
			try {
				destFile.createNewFile();
			} catch (IOException e) {
				System.out.println("Create machine language file error");
				e.printStackTrace();
			}
		System.out.println("assemble filename :"+ sourceFile.getName());
		System.out.println("machine language filename : "+destFile.getName());
		
		initialInstructionList();
		findLabels(sourceFile, destFile);
		assembleFile(sourceFile, destFile);
		//System.out.println(labelList);
	}

	private static void initialInstructionList() {
		instructionList.put("NOP", 0);
		instructionList.put("ADD", 1);
		instructionList.put("SUB", 2);
		instructionList.put("AND", 3);
		instructionList.put("OR", 4);
		instructionList.put("XOR", 5);
		instructionList.put("SL", 6);
		instructionList.put("SR", 7);
		instructionList.put("SRU", 8);
		instructionList.put("ADDI", 9);
		instructionList.put("LD", 10);
		instructionList.put("ST", 11);
		instructionList.put("BZ", 12);
	}
	
	private static void findLabels(File sourceFile, File destFile) {
		String line = new String();
		BufferedReader sourceBr;
		BufferedWriter destBw;
		
		String parsedLine[] = new String[5];
		
		currentLine = 0;
		codeLineCnt = 0;
		System.out.println("=====Pass one: Finding Labels=====");
		
		try {
			sourceBr = new BufferedReader(new FileReader(sourceFile));
			destBw = new BufferedWriter(new FileWriter(destFile));
			boolean endOfFile = false;
			while(!endOfFile)
			{
				line = sourceBr.readLine();
				if(line != null)
				{
					currentLine++;
					codeLineCnt++;
					line = line.toUpperCase();
					parsedLine = parseLine(currentLine, line);
					if(parsedLine[0] != null)
					{
						//translatedLine = translateLine(currentLine, parsedLine);
						//System.out.print("translatedLine: "+translatedLine);
						//destBw.write(translatedLine);
						//destBw.newLine();
						//System.out.println(" wrote");
					}
					else
					{
						codeLineCnt--;
						//System.out.println("Non-Code line, skiped");
					}
				}
				else
					endOfFile = true;
			}
			sourceBr.close();
			destBw.close();
			System.out.println("Labels found: ");
			System.out.println(labelList);
			
			
		} catch (FileNotFoundException e) {
			e.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		}
		
	}
	
	private static void assembleFile(File sourceFile, File destFile) {
		
		String line = new String();
		BufferedReader sourceBr;
		BufferedWriter destBw;
		
		String parsedLine[] = new String[5];
		String translatedLine;
		
		currentLine = 0;
		codeLineCnt = 0;
		System.out.println("=====Pass two: translate=====");
		
		try {
			sourceBr = new BufferedReader(new FileReader(sourceFile));
			destBw = new BufferedWriter(new FileWriter(destFile));
			boolean endOfFile = false;
			while(!endOfFile)
			{
				line = sourceBr.readLine();
				if(line != null)
				{
					currentLine++;
					codeLineCnt++;
					line = line.toUpperCase();
					parsedLine = parseLine(currentLine, line);
					if(parsedLine[0] != null)
					{
						translatedLine = translateLine(currentLine, parsedLine);
						System.out.print("translatedLine: "+translatedLine);
						destBw.write(translatedLine);
						destBw.newLine();
						System.out.println(" wrote");
					}
					else
					{
						codeLineCnt--;
						System.out.println("Non-Code line, skiped");
					}
				}
				else
					endOfFile = true;
			}
			sourceBr.close();
			destBw.close();
			System.out.println("assemble complete ");
			
			
			
		} catch (FileNotFoundException e) {
			e.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		}
		
		
		
	}

	private static String translateLine(int currentLine, String[] parsedLine) {
		String translatedLine = null;
		String op = parsedLine[0];

		if(instructionList.get(op) == null)
			reportSyntaxError(currentLine, "unkown Instruction:"+op);
		
		switch(instructionList.get(op))
		{
		case 0:	//("NOP", 0)
			translatedLine = "0000000000000000";
			break;
		case 1: //("ADD", 1)
		case 2: //("SUB", 2)
		case 3: //("AND", 3)
		case 4: //("OR", 4)
		case 5: //("XOR", 5)
		case 6: //("SL", 6)
		case 7: //("SR", 7)
		case 8: //("SRU", 8)
			if(checkRType(currentLine, parsedLine))
			{
				translatedLine = convTo4Digits(instructionList.get(op)) +
								convTo3Digits(Integer.parseInt(parsedLine[1].replace("R", ""))) +
								convTo3Digits(Integer.parseInt(parsedLine[2].replace("R", ""))) +
								convTo3Digits(Integer.parseInt(parsedLine[3].replace("R", ""))) +
								"000";
			}
			break;
		case 9: //("ADDI", 9)
		case 10: //("LD", 10)
		case 11: //("ST", 11)
			if(checkIType(currentLine, parsedLine))
			{
				translatedLine = convTo4Digits(instructionList.get(op)) +
								convTo3Digits(Integer.parseInt(parsedLine[1].replace("R", ""))) +
								convTo3Digits(Integer.parseInt(parsedLine[2].replace("R", ""))) +
								convTo6Digits(Integer.parseInt(parsedLine[3]));
			}
			break;
		case 12: //("BZ", 12)
			if(checkBranchType(currentLine, parsedLine))
			{
				translatedLine = convTo4Digits(instructionList.get(op)) +
				"000"+
				convTo3Digits(Integer.parseInt(parsedLine[1].replace("R", ""))) +
				convTo6Digits(labelList.get(parsedLine[2]) - codeLineCnt -1);
				//System.out.println("br: "+codeLineCnt);
			}
			break;
		default:
			reportSyntaxError(currentLine, "unknown Instruction:"+op);
			break;
		}
		return translatedLine;
	}

	

	
	private static boolean checkBranchType(int currentLine2, String[] parsedLine) {
		if(parsedLine[1].startsWith("R") &&
				labelList.get(parsedLine[2])!=null
		)
			return true;
		else
			reportSyntaxError(currentLine, "Branch-type instrcution should have 1 registers and line label");
		
		return false;
	}

	private static boolean checkIType(int currentLine2, String[] parsedLine) {
		if(parsedLine[1].startsWith("R") &&
				parsedLine[2].startsWith("R")&&
				Integer.parseInt(parsedLine[3])<32 &&
				Integer.parseInt(parsedLine[3])>=-32
		)
			return true;
		else
			reportSyntaxError(currentLine, "I-type instrcution should have 2 registers and a immediate number(range -32~31)");
		
		return false;
	}

	private static boolean checkRType(int currentLine, String[] parsedLine) {
		if(parsedLine[1].startsWith("R") &&
				parsedLine[2].startsWith("R")&&
				parsedLine[3].startsWith("R")
		)
			return true;
		else
			reportSyntaxError(currentLine, "R-type instrcution should have 3 registers");
		
		return false;
	}
	
	private static String convTo3Digits(int in) {
		String binary3digits;
		binary3digits = Integer.toBinaryString(in);
		if(binary3digits.length()>3)
			reportSyntaxError(currentLine,"conv To 3 digits wrong");
		while(binary3digits.length()<3)
			binary3digits = "0"+binary3digits;
		return binary3digits;
	}
	
	private static String convTo4Digits(int in) {
		String binary4digits;
		binary4digits = Integer.toBinaryString(in);
		if(binary4digits.length()>4)
			reportSyntaxError(currentLine,"conv To 4digits wrong");
		while(binary4digits.length()<4)
			binary4digits = "0"+binary4digits;
		return binary4digits;
	}
	
	private static String convTo6Digits(int in) {
		String binary6digits;
		binary6digits = Integer.toBinaryString(in);
		//System.out.println("binary6digits : "+binary6digits);
		if(in>=0)
		{
			if(binary6digits.length()>6)
				reportSyntaxError(currentLine,"conv To 6digits wrong");
			else
				while(binary6digits.length()<6)
					binary6digits = "0"+binary6digits;
		}
		else
		{
			binary6digits = binary6digits.substring(binary6digits.length()-6);
		}
		//System.out.println("binary6digits : "+binary6digits);
		return binary6digits;
	}

	private static String[] parseLine(int currentLine, String line) {
		String temp[];
		int i, p;
		String parsedLine[] = new String[5];
		//System.out.println("parsing: "+line);
		temp = line.split("[\\s,]");
		//System.out.println("string length"+temp.length);
		p = 0;
		boolean labelFound = false;
		for(i=0; i< temp.length; i++)
		{
			if(temp[i].contains(";"))
				break;
			else if(temp[i].length()>0)
			{
				if(temp[i].contains(":"))
				{
					String  temp1[] = null;
					
					if(!labelFound)
						labelFound = true;
					else
						reportSyntaxError(currentLine,"found multi-labels");
					
					temp1 = temp[i].split(":");
					if(temp1.length == 1)
					{
						labelList.put(temp1[0], codeLineCnt);
					}
					else 
					if(temp1.length == 2)
					{
						labelList.put(temp1[0], codeLineCnt);
						parsedLine[p++] = temp1[1];
					}
					else
					{	
						reportSyntaxError(currentLine,"error when parsing labels");
					}
				}
				else 
					parsedLine[p++] = temp[i];
			}
		}
		System.out.print("parsed Line "+currentLine+": ");
		for(i=0; i<p; i++)
			System.out.print(parsedLine[i]+" ");
		System.out.println("");
		
		return parsedLine;
	}

	private static void reportSyntaxError(int lineNum, String errReason) {
		System.out.println("error at line:"+lineNum+", "+ errReason);
		System.exit(-1);
	}

}
