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
import java.io.FileInputStream;
import java.util.Vector;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.HashMap;

class ParseParams {
    /**
     * Parse microcode_params.v to get information about what to control with the microcode,
     * that is, about the microcode parameters.
     *
     * @param file_name         - path to microcode_params.v,
     * @return                  - the contents of Parser.java,
     * @throws Exception        - in case of file read error.
     */
    static String parse(String file_name) throws Exception {
        // load file
        File file = new File(file_name);
        byte bytes[] = new byte[(int)file.length()];
        FileInputStream in = new FileInputStream(file);
        if( in.read(bytes) != bytes.length ) throw new Exception("Can not read from file: " + file.getCanonicalPath());
        in.close();
        
        // find 'OPERATIONS START' and 'OPERATIONS END' substrings
        String all_string = new String(bytes);
        int start_index = all_string.indexOf("OPERATIONS START");
        if(start_index == -1) throw new Exception("Can not find 'OPERATIONS START' substring in " + file.getCanonicalPath());
        int end_index = all_string.indexOf("OPERATIONS END");
        if(end_index == -1) throw new Exception("Can not find 'OPERATIONS END' substring in " + file.getCanonicalPath());
        
        // prepare Parser.java header and constructors
        String java = "";
        java += "package ao68000_tool;" + "\n";
        java += "class Parser {" + "\n";
        java += "\t" + "boolean newline;" + "\n";
        java += "\t" + "Parser() { this(true); }" + "\n";
        java += "\t" + "Parser(boolean newline) { this.newline = newline; }" + "\n";

        // prepare data structures to keep information about the microcode parameters
        prefixes = new Vector<String>();
        prefix_locations = new HashMap<String, Integer>();
        name_values = new HashMap<String, Integer>();

        // split read file into lines
        String string = all_string.substring(start_index, end_index);
        String tokens[] = string.split("\\n");

        // prepare patterns, initialize counters
        Pattern pat = Pattern.compile("`define\\s*(\\S+)\\s*(\\d+)'d(\\d+).*");
        int last_parameter_size = 0;
        control_bit_offset = 0;

        // parse each line
        for(String s : tokens) {
            Matcher m0 = pat.matcher(s);
            
            // match parameter names and values
            if( m0.matches() ) {
                String name = m0.group(1);
                int size = Integer.parseInt(m0.group(2));
                int value = Integer.parseInt(m0.group(3));

                // check if parameter name ends with _IDLE
                if(name.endsWith("_IDLE")) {
                    last_parameter_size = size;

                    String prefix = name.substring(0, name.length()-5);

                    prefixes.add(prefix + "_");
                    prefix_locations.put(prefix + "_start", control_bit_offset);
                    prefix_locations.put(prefix + "_end", control_bit_offset+last_parameter_size-1);
                    control_bit_offset += last_parameter_size;
                }
                else {
                    java += "\t" + "Parser " + name + "() throws Exception {" + "\n";
                    java += "\t\t" + "GenerateMicrocode.entry(newline, \"" + name + "\");" + "\n";
                    java += "\t\t" + "return new Parser(false);" + "\n";
                    java += "\t" + "}" + "\n";

                    name_values.put(name, value);
                }
            }
        }

        // prepare Parser.java ending
        java += "\t" + "void label(String label) throws Exception { GenerateMicrocode.entry(newline, \"label_\" + label); }" + "\n";
        java += "\t" + "Parser offset(String label) throws Exception {" + "\n";
        java += "\t\t" + "GenerateMicrocode.entry(newline, \"offset_\" + label);" + "\n";
        java += "\t\t" + "return new Parser(false);" + "\n";
        java += "\t" + "}" + "\n";

        java += "}" + "\n";

        return java;
    }

    static Vector<String> prefixes;
    static HashMap<String, Integer> name_values;
    static HashMap<String, Integer> prefix_locations;
    static int control_bit_offset;
}
