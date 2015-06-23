/*
 * Copyright 2010, Aleksander Osman, alfik@poczta.fm. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification, are
 * permitted provided that the following conditions are met:
 *
 *  1. Redistributions of source code must retain the above copyright notice, this list of
 *     conditions and the following disclaimer.
 *
 *  2. Redistributions in binary form must reproduce the above copyright notice, this list
 *     of conditions and the following disclaimer in the documentation and/or other materials
 *     provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR IMPLIED
 * WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
 * FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR
 * CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
 * ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 * ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

package ao68000_tool;

import java.io.File;
import java.util.HashMap;
import java.util.Random;
import java.util.Vector;

/* 
 * 0000 0000 ss ddd DDD : ORI
 *
 * 0000 rrr1 00 ddd DDD : BTST
 * 0000 ddd1 ss 001 sss : MOVEP from memory
 *
 * 0000 rrr1 01 ddd DDD : BCHG
 * 0000 rrr1 10 ddd DDD : BCLR
 * 0000 rrr1 11 ddd DDD : BSET
 *
 * 0000 0010 ss ddd DDD : ANDI
 *
 * 0000 0100 ss ddd DDD : SUBI
 *
 * 0000 0110 ss ddd DDD : ADDI
 *
 * 0000 1000 00 ddd DDD : BTST imm
 * 0000 1000 01 ddd DDD : BCHG imm
 * 0000 1000 10 ddd DDD : BCLR imm
 * 0000 1000 11 ddd DDD : BSET imm
 *
 * 0000 1010 ss ddd DDD : EORI
 * 0000 1100 ss ddd DDD : CMPI
 *
 * 0000 1110 xx xxx xxx : illegal instruction
 *
 * 00ss DDDd dd sss SSS : MOVE
 * 00ss DDD0 01 sss SSS : MOVEA
 *
 * 0100 0000 ss ddd DDD : NEGX
 * 0100 0000 11 ddd DDD : MOVE FROM SR
 *
 * 0100 0001 00 xxx xxx : illegal instruction
 *
 * 0100 rrrs s0 ddd DDD : CHK
 * 0100 rrr1 11 ddd DDD : LEA
 *
 * 0100 0010 ss ddd DDD : CLR
 *
 * 0100 0100 ss ddd DDD : NEG
 * 0100 0100 11 sss SSS : MOVE TO CCR
 * 0100 0110 ss ddd DDD : NOT
 * 0100 0110 11 sss SSS : MOVE TO SR
 *
 * 0100 1000 00 ddd DDD : NBCD
 * 0100 1000 01 000 rrr : SWAP
 *
 * 0100 1000 01 001 xxx : illegal instruction
 * 0100 1000 01 ddd DDD : PEA
 *
 * 0100 1000 ss ddd DDD : EXT
 * 0100 1000 ss 001 rrr : MOVEM register to memory
 *
 * 0100 1010 ss ddd DDD : TST
 * 0100 1010 11 ddd DDD : TAS
 * 
 * 0100 1010 11 111 100 : ILLEGAL
 * 
 * 0100 1100 ss ddd DDD : MOVEM memory to register
 * 
 * 0100 1110 01 00i iii : TRAP
 * 
 * 0100 1110 01 010 rrr : LNK
 * 0100 1110 01 011 rrr : ULNK
 * 
 * 0100 1110 01 10d rrr : MOVE USP
 * 
 * 0100 1110 01 110 000 : RESET
 * 0100 1110 01 110 001 : NOP
 * 0100 1110 01 110 010 : STOP
 * 0100 1110 01 110 011 : RTE
 * 0100 1110 01 110 100 : illegal instruction
 * 0100 1110 01 110 101 : RTS
 * 0100 1110 01 110 110 : TRAPV
 * 0100 1110 01 110 111 : RTR
 *
 * 0100 1110 01 111 xxx : illegal instruction
 * 0100 1110 10 sss SSS : JSR
 * 0100 1110 11 sss SSS : JMP
 * 
 * 0101 cccc 11 001 rrr : DBcc
 * 0101 cccc 11 ddd DDD : Scc
 * 0101 qqq1 ss ddd DDD : SUBQ
 * 0101 qqq0 ss ddd DDD : ADDQ
 *
 * 0110 0001 dd ddd ddd : BSR
 * 0110 0000 dd ddd ddd : BRA
 * 0110 cccc dd ddd ddd : Bcc
 * 
 * 0111 rrr0 dd ddd ddd : MOVEQ
 *
 * 1011 rrro oo sss SSS : CMP
 * 1011 rrro oo sss SSS : CMPA
 * 1011 ddd1 ss 001 sss : CMPM
 * 1011 ssso oo ddd DDD : EOR
 *
 * 1101 rrro oo eee EEE : ADD
 * 1100 rrro oo eee EEE : AND
 * 1000 rrro oo eee EEE : OR
 * 1001 rrro oo eee EEE : SUB
 *
 * 1001 rrro oo sss SSS : SUBA
 * 1101 rrro oo sss SSS : ADDA
 *
 * 1101 ddd1 oo 00m sss : ADDX
 * 1001 ddd1 oo 00m sss : SUBX
 *
 * 1100 ddd1 00 00m sss : ABCD
 * 1000 ddd1 00 00m sss : SBCD
 *
 * 1100 ddd1 oo ooo aaa : EXG
 *
 * 1100 ddd0 11 sss SSS : MULU
 * 1100 ddd1 11 sss SSS : MULS
 * 1000 ddd0 11 sss SSS : DIVU
 * 1000 ddd1 11 sss SSS : DIVS
 * 
 * 1110 000d 11 sss SSS : ASL,ASR memory
 * 1110 cccd ss i00 rrr : ASL,ASR register/immediate
 * 1110 001d 11 sss SSS : LSL,LSR memory
 * 1110 cccd ss i01 rrr : LSL,LSR register/immediate
 * 1110 011d 11 sss SSS : ROL,ROR memory
 * 1110 cccd ss i11 rrr : ROL,ROR register/immediate
 * 1110 010d 11 sss SSS : ROXL,ROXR memory
 * 1110 cccd ss i10 rrr : ROXL,ROXR register/immediate
 */

public class Tester {
    static int get_random(Random random, boolean must_be_even) {
        if(global_zero) return 0;
        while(true) {
            int rand = random.nextInt();
            if(must_be_even == false) return rand;
            else if(must_be_even == true && (rand % 2) == 0) return rand;
        }
    }
    static int get_random_bit(Random random) {
        if(global_zero) return 0;
        return (random.nextInt() % 2 == 0) ? 0 : 1;
    }
    static int get_random_ipm(Random random) {
        if(global_zero) return 0;
        int rand = random.nextInt();
        rand = rand % 8;
        return (rand < 0) ? -rand : rand;
    }
    static String get_8_char_hex_string(int val) throws Exception {
        String s = Integer.toHexString(val>>>2);
        while(s.length() < 8) s = "0" + s;
        return s.substring(s.length()-8);
    }
    static String get_4_char_hex_string(int val) throws Exception {
        String s = Integer.toHexString(val);
        while(s.length() < 4) s = "0" + s;
        return s.substring(s.length()-4);
    }
    
    static void start_test(File exe1, File exe2, int start, int end) throws Exception {
        random = new Random();
        for(int i=start; i<end; i++) {
            String ir = Integer.toBinaryString(i);
            while(ir.length() < 16) ir = "0" + ir;
            instruction = "ir=" + ir + ", " + i + "/" + end;
            System.out.println(instruction);
            
            for(int j=0; j<6; j++) {
                if(j==0) global_zero = true;
                else global_zero = false;
                
                System.out.println("j=" + j);
                start_test_hex(i,exe1,exe2);
            }
        }
    }
    static void start_test_hex(int i, File exe1, File exe2) throws Exception {

        Vector<String> common = new Vector<String>();
        
        try {
            common.add("+A0=" + Integer.toHexString(get_random(random, false)));
            common.add("+A1=" + Integer.toHexString(get_random(random, false)));
            common.add("+A2=" + Integer.toHexString(get_random(random, false)));
            common.add("+A3=" + Integer.toHexString(get_random(random, false)));
            common.add("+A4=" + Integer.toHexString(get_random(random, false)));
            common.add("+A5=" + Integer.toHexString(get_random(random, false)));
            common.add("+A6=" + Integer.toHexString(get_random(random, false)));
            common.add("+SSP=" + Integer.toHexString(get_random(random, false)));
            common.add("+USP=" + Integer.toHexString(get_random(random, false)));

            common.add("+D0=" + Integer.toHexString(get_random(random, false)));
            common.add("+D1=" + Integer.toHexString(get_random(random, false)));
            common.add("+D2=" + Integer.toHexString(get_random(random, false)));
            common.add("+D3=" + Integer.toHexString(get_random(random, false)));
            common.add("+D4=" + Integer.toHexString(get_random(random, false)));
            common.add("+D5=" + Integer.toHexString(get_random(random, false)));
            common.add("+D6=" + Integer.toHexString(get_random(random, false)));
            common.add("+D7=" + Integer.toHexString(get_random(random, false)));

            common.add("+C=" + get_random_bit(random));
            common.add("+V=" + get_random_bit(random));
            common.add("+Z=" + get_random_bit(random));
            common.add("+N=" + get_random_bit(random));
            common.add("+X=" + get_random_bit(random));
            common.add("+IPM=" + get_random_ipm(random));
            common.add("+S=" + get_random_bit(random));
            common.add("+T=" + "0"); //get_random_bit(random));

            int pc = get_random(random, true);
            common.add("+PC=" + Integer.toHexString(pc));

            if((pc % 4) == 0) {
                common.add("+MEM" + get_8_char_hex_string(pc) + "=" +
                        get_4_char_hex_string(i) +
                        get_4_char_hex_string(get_random(random, false)));
            }
            else {
                common.add("+MEM" + get_8_char_hex_string(pc) + "=" +
                        get_4_char_hex_string(get_random(random, false)) +
                        get_4_char_hex_string(i));
            }
            program_output = "Running exe1: " + exe1.getName() + "\n";
            common.add(0,  exe1.getCanonicalPath());
            HashMap<String, String> map_exe1 = start_test_process(common, exe1);
            if(map_exe1 == null) throw new Exception("Exe1 odd address read/write.");


            program_output += "\nRunning exe2: " + exe2.getName() + "\n";
            common.remove(0);
            common.add(0, exe2.getCanonicalPath());
            HashMap<String, String> map_exe2 = start_test_process(common, exe2);
            if(map_exe2 == null) throw new Exception("Exe2 odd address read/write.");

            boolean failed = false;
            boolean is_blocked = (map_exe1.containsKey("processor blocked") && map_exe2.containsKey("processor blocked")) ? true : false;
            for(String key : map_exe1.keySet()) {
                String value_emu = map_exe1.get(key);
                String value_verilog = map_exe2.get(key);
                map_exe2.remove(key);

                // if processor blocked, do not compare PC and SSP registers
                if(is_blocked && key.equals("PC")) continue;
                if(is_blocked && key.equals("SSP")) continue;
                
                if(value_emu.equals(value_verilog) == false) {
                    if(failed == false) System.out.println("");
                    System.out.println("Key mismatch: " + key + ": Exe1=" + value_emu + " / Exe2=" + value_verilog);
                    failed = true;
                }
            }
            for(String key : map_exe2.keySet()) {
                if(failed == false) System.out.println("");
                System.out.println("Key mismatch: " + key + ": EXE1=" + null + " / EXE2=" + map_exe2.get(key));
                failed = true;
            }

            if(failed) {
                System.out.println("");
                throw new Exception("Mismatch detected. Program output:\n" + program_output);
            }
        }
        catch(Exception e) {
            String result = "";
            for(String s : common) {
                result += s + "\n";
            }
            throw new Exception(e.getMessage() + "\nCommon dump:\n" + result + "\nInstruction:\n" + instruction);
        }
    }
    static HashMap<String, String> start_test_process(Vector<String> common, File file) throws Exception {

        Runtime runtime = Runtime.getRuntime();
        String result = "";
        String addresses = "\n";
        int count=0;
        while(true) {
            result = "";
            if(file.isDirectory() == false) file = new File(file.getParent());
            Process p = runtime.exec(common.toArray(new String[0]), null, file);

            int read = p.getInputStream().read();
            while(read != -1) {
                result += (char)read;
                read = p.getInputStream().read();
            }
            p.waitFor();
            p.getErrorStream().close();
            p.getInputStream().close();
            p.getOutputStream().close();
            
            if(p.exitValue() == 0) break;
            else {
                int index = result.indexOf("Missing argument: MEM");
                int index2 = result.indexOf("on odd address");
                if(index != -1) {
                    index += new String("Missing argument: MEM").length();
                    result = result.substring(index, index+8);
                    addresses += result + "\n";

                    String to_add = "+MEM" + result + "=" + Integer.toHexString(get_random(random, false));
                    if(to_add.length() > 4+8+1+8) throw new Exception("Illegal memory value length: " + to_add);
                    common.add(to_add);
                }
                else if(index2 != -1) {
                    throw new Exception("Odd address:" + result);
                }
                else throw new Exception("Error running process:\n" + result);
            }

            count++;
            if(count == 100) throw new Exception("Number of memory reads exceeded: " + common.firstElement() + " " + addresses);
        }

        program_output += result;
        
        result = result.substring(result.indexOf("START TEST") + new String("START TEST").length());
        String split[] = result.split("\n");

        HashMap<String, String> map = new HashMap<String, String>();
        for(int i=0; i<split.length; i++) {
            if(split[i].trim().length() == 0) continue;
            if(split[i].startsWith("memory read")) continue;

            String split2[] = split[i].split(":");
            if(split2.length == 1) throw new Exception("Line not split: " + split2[0]);

            map.put(split2[0].trim(), split2[1].trim());
        }
        return map;
    }
    static String program_output;
    static Random random;
    static boolean global_zero;
    static String instruction;
}
