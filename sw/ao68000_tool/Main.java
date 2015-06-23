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
import java.io.FileOutputStream;

public class Main {
    /**
     * Print program call arguments description and exit.
     */
    static void print_call_arguments() {
        System.out.println("Can not parse program arguments.");
        System.out.println("");
        System.out.println("ao68000_tool accepts the following syntax:");
        System.out.println("<operation> [operation arguments]");
        System.out.println("");
        System.out.println("The following   <operations> are available:");
        System.out.println("\t parser       <input ao68000.v> <output Parser.java>");
        System.out.println("\t microcode    <input/output ao68000.v> <output microcode.mif>");
        System.out.println("\t test         <input exe1> <input exe2> <start> <end>");
        System.out.println("\t spec_extract <input> <output>");
        System.out.println("");
        System.out.println("For more information please read the ao68000 IP core documentation.");
        
        System.exit(1);
    }

    /**
     * @param args          - program arguments described in method
     *                        print_call_arguments().
     */
    public static void main(String[] args) {
        try {
            // check program call arguments
            if(args.length == 0)                                                print_call_arguments();
            else if(args[0].equals("parser") == true && args.length != 3)       print_call_arguments();
            else if(args[0].equals("microcode") == true && args.length != 3)    print_call_arguments();
            else if(args[0].equals("test") == true && args.length != 5)         print_call_arguments();
            else if(args[0].equals("spec_extract") == true && args.length != 3) print_call_arguments();
            
            if(args[0].equals("parser")) {
                String java = ParseParams.parse(args[1]);
                
                FileOutputStream output = new FileOutputStream(args[2]);
                output.write(java.getBytes());
                output.close();
            }
            else if(args[0].equals("microcode")) {
                ParseParams.parse(args[1]);
                
                FileOutputStream microcode_os = new FileOutputStream(args[2]);

                GenerateMicrocode.generate(microcode_os, args[1]);

                microcode_os.close();
            }
            else if(args[0].equals("test")) {
                File exe1 = new File(args[1]);
                File exe2 = new File(args[2]);

                int start = Integer.parseInt(args[3]);
                int end = Integer.parseInt(args[4]);

                Tester.start_test(exe1, exe2, start, end);
            }
            else if(args[0].equals("spec_extract")) {
                DocumentationTool.extract(args[1], args[2]);
            }

            System.exit(0);
        }
        catch(Exception e) {
            e.printStackTrace();

            try {
                while(true) {
                    Thread.sleep(1000);
                }
            }
            catch(Exception e2) {
                e2.printStackTrace();
            }
        }
    }
}
