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
import java.io.FileOutputStream;

public class DocumentationTool {
    static void extract(String src, String dest) throws Exception {
        File file = new File(src);
        if(file.exists() == false || file.isFile() == false || file.canRead() == false) {
            throw new Exception("Can not open: " + file.getCanonicalPath());
        }
        // load file
        FileInputStream in = new FileInputStream(file);
        byte buf[] = new byte[(int)file.length()];
        if(in.read(buf) != buf.length) throw new Exception("Can not read: " + file.getCanonicalPath());

        String all = new String(buf);

        // find <div class="contents"
        String start_str = "<div class=\"contents\"";
        int start = all.indexOf(start_str);
        if(start == -1) throw new Exception("Can not find: " + start_str);

        int start_saved = start;
        start += start_str.length();

        // find closing </div
        int deep = 1;
        while(deep != 0) {
            int next_start = all.indexOf("<div", start);
            int next_end = all.indexOf("</div", start);
            //System.out.println("deep: " + deep + ", next_start: " + next_start + ", next_end: " + next_end);
            
            if(next_start != -1 && next_end != -1 && next_start < next_end) {
                deep++;
                start = next_start + 4;
            }
            else if(next_start != -1 && next_end != -1 && next_start >= next_end) {
                deep--;
                start = next_end + 5;
            }
            else if(next_start == -1 && next_end != -1) {
                deep--;
                start = next_end + 5;
            }
            else throw new Exception("Error parsing file.");
        }
        String result = all.substring(start_saved, start) + ">";

        //System.out.println("s: " + start_saved + ", e: " + start);
        //System.out.println(result);

        result = result.replaceAll("<h1>", " ");
        result = result.replaceAll("</h1>", " ");
        result = result.replaceAll("<br/>", "<br>");

        int max=0;
        while(result.indexOf("href=\"", max) != -1) {
            int i = result.indexOf("href=\"", max);
            max = i+6;

            if(result.substring(i).startsWith("href=\"http:")) continue;

            result = result.substring(0, i) + "href=\"file://./doxygen/html/" + result.substring(i+6);
        }

        // save output
        FileOutputStream out = new FileOutputStream(dest);
        out.write(result.getBytes());
        out.close();
    }
}
