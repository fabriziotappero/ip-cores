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

package aoOCS_tool;

import java.io.File;
import java.io.OutputStream;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.nio.ByteBuffer;
import java.nio.channels.FileChannel;
import java.util.LinkedList;
import javax.imageio.ImageIO;
import java.awt.image.BufferedImage;
import java.util.Vector;

public class Main {
    /**
     * Print program call arguments description and exit.
     */
    static void print_call_arguments() {
        System.out.println("Can not parse program arguments.");
        System.out.println("");
        System.out.println("aoOCS_tool accepts the following arguments:");
        System.out.println("<operation> [operation arguments]");
        System.out.println("");
        System.out.println("The following   <operations> are available:");
        System.out.println("\t sd_disk      <intro image> <directory with ROM> <directory with AFS> <output disk image>");
        System.out.println("\t control_osd  <output control_osd.mif>");
        System.out.println("\t spec_extract <input> <output>");
        System.out.println("\t vga_to_png   <input file> <output directory>");
        System.out.println("");
        System.out.println("For more information please read the aoOCS IP core documentation.");
        
        System.exit(1);
    }
    
    static class LoadedFile {
        String name;
        long position_in_sectors;
    }
    
    static void p(String s) throws Exception {
        if(p_out == null) {
            System.out.println(s);
        }
        else {
            s += "\n";
            p_out.write(s.getBytes());
        }
    }
    static int print_32bits(int offset, int a, int b, int c, int d) throws Exception {
        String ha = Integer.toHexString(a);
        String hb = Integer.toHexString(b);
        String hc = Integer.toHexString(c);
        String hd = Integer.toHexString(d);

        if(ha.length() < 2) ha = "0" + ha;
        if(hb.length() < 2) hb = "0" + hb;
        if(hc.length() < 2) hc = "0" + hc;
        if(hd.length() < 2) hd = "0" + hd;

        p("" + (offset/4) + ": " + ha + hb + hc + hd + ";");
        return offset+4;
    }
    static int print_string(String str, int val_a, int val_b, int offset) throws Exception {
        for(int j=0; j<24; j+=4) {
            int a = str.charAt(j +0);
            int b = str.charAt(j +1);
            int c = str.charAt(j +2);
            int d = str.charAt(j +3);

            offset = print_32bits(offset, a,b,c,d);
        }
        offset = print_32bits(offset, (val_a>>24)&0xFF, (val_a>>16)&0xFF, (val_a>>8)&0xFF, (val_a)&0xFF);
        offset = print_32bits(offset, (val_b>>24)&0xFF, (val_b>>16)&0xFF, (val_b>>8)&0xFF, (val_b>>0)&0xFF);
        return offset;
    }
    static void load_files(String directory, LinkedList<LoadedFile> list, FileChannel channel) throws Exception {
        File rom_dir = new File(directory);
        if(rom_dir.exists() == false || rom_dir.isDirectory() == false) throw new Exception("Can not find directory: " + rom_dir.getCanonicalPath());

        for(File f : rom_dir.listFiles()) {
            if(f.isFile()) {
                byte bytes[] = new byte[(int)f.length()];
                FileInputStream in = new FileInputStream(f);
                if(in.read(bytes) != bytes.length) throw new Exception("Can not read file: " + f.getCanonicalPath());
                in.close();

                LoadedFile loaded = new LoadedFile();
                loaded.name = "  " + f.getName() + "                        ";
                if(loaded.name.length() > 24) loaded.name = loaded.name.substring(0, 24);
                loaded.position_in_sectors = channel.position()/512;
                list.addLast(loaded);
                System.out.println("" + f.getName() + ": " + channel.position());
                channel.write(ByteBuffer.wrap(bytes));

                if((channel.position() % 512) != 0) channel.position(channel.position() + 512 - (channel.position() % 512));

            }
        }
    }
    static void write_header(LinkedList<LoadedFile> list, FileChannel channel, int first, int middle, int last) throws Exception {
        for(int i=0; i<list.size(); i++) {
            LoadedFile f = list.get(i);

            byte line[] = new byte[32];
            System.arraycopy(f.name.getBytes(), 0, line, 0, 24);
            int a = 0;
            if(i == 0)                          a |= first;
            if(i == list.size()-1)              a |= last;
            if(i != 0 && i != list.size()-1)    a |= middle;
            int b = (int)f.position_in_sectors;

            line[24] = (byte)(a >> 24);
            line[25] = (byte)(a >> 16);
            line[26] = (byte)(a >> 8);
            line[27] = (byte)(a);
            line[28] = (byte)(b >> 24);
            line[29] = (byte)(b >> 16);
            line[30] = (byte)(b >> 8);
            line[31] = (byte)(b);

            channel.write(ByteBuffer.wrap(line));
        }
    }
    public static void main(String[] args) throws Exception {
        // check program call arguments
        if(args.length == 0)                                                print_call_arguments();
        else if(args[0].equals("sd_disk") == true && args.length != 5)      print_call_arguments();
        else if(args[0].equals("control_osd") == true && args.length != 2)  print_call_arguments();
        else if(args[0].equals("spec_extract") == true && args.length != 3) print_call_arguments();
        else if(args[0].equals("vga_to_png") == true && args.length != 3)   print_call_arguments();
        
        int SELECTABLE      = 1;
        int TOP             = 2;
        int BOTTOM          = 4;
        int RESET           = 8;
        int JOYSTICK        = 16;
        int FLOPPY          = 32;
        int WRITE_ENABLED   = 64;
        
        if(args[0].equals("control_osd")) {
            File f = new File(args[1]);
            p_out = new FileOutputStream(f);
            
            p("DEPTH = 1024;");
            p("WIDTH = 32;");
            p("ADDRESS_RADIX = DEC;");
            p("DATA_RADIX = HEX;");
            p("CONTENT");
            p("BEGIN");
            int offset = 0;

            offset = print_string("aoOCS version 1.0       ", 0,0, offset);
            offset = print_string("Initializing SD card....", 0,0, offset);
            offset = print_string("SD fatal error.         ", 0,0, offset);
            offset = print_string("SD ready. Select ROM:   ", 0,0, offset);
            offset += 32; // blank line
            offset = print_string("Inserted floppy:        ", 0,                            0, offset);
            offset = print_string("None                    ", 0,                            0, offset);
            offset = print_string("Joystick(kbd arrows) OFF", TOP | JOYSTICK | SELECTABLE,  0, offset);
            offset = print_string("Joystick(kbd arrows) ON ", TOP | JOYSTICK | SELECTABLE,  0, offset);
            offset = print_string("Floppy write enabled OFF", WRITE_ENABLED | SELECTABLE,   0, offset);
            offset = print_string("Floppy write enabled ON ", WRITE_ENABLED | SELECTABLE,   0, offset);
            offset = print_string("Reset                   ", RESET | SELECTABLE,           0, offset);
            offset = print_string("Eject floppy            ", BOTTOM | FLOPPY | SELECTABLE, 0, offset);

            p("END;");
            p_out.close();
        }
        else if(args[0].equals("sd_disk")) {
            // read image file
            File intro_image_file = new File(args[1]);
            if(intro_image_file.exists() == false) throw new Exception("Can not read intro image file: " + intro_image_file.getCanonicalPath());

            BufferedImage img = ImageIO.read(intro_image_file);

            // prepare output file
            FileOutputStream out = new FileOutputStream(args[4]);
            FileChannel channel = out.getChannel();

            channel.position(0);
            for(int y=0; y<256; y++) {
                for(int x=0; x<640; ) {
                    long three_pixels = 0;

                    for(int z=0; z<3; z++) {
                        int r,g,b;

                        if(x >= img.getWidth() || y >= img.getHeight()) {
                            r = g = b = 0;
                        }
                        else {
                            r = (img.getRGB(x, y)>>16) & 0xFF;
                            g = (img.getRGB(x, y)>>8) & 0xFF;
                            b = (img.getRGB(x, y)) & 0xFF;
                        }

                        three_pixels <<= 3;
                        three_pixels |= (r>>5) & 0x7;
                        three_pixels <<= 3;
                        three_pixels |= (g>>5) & 0x7;
                        three_pixels <<= 3;
                        three_pixels |= (b>>5) & 0x7;

                        x++;
                    }
                    three_pixels <<= 5;
                    
                    byte word[] = new byte[4];
                    word[0] = (byte)((three_pixels >> 24) & 0xFF);
                    word[1] = (byte)((three_pixels >> 16) & 0xFF);
                    word[2] = (byte)((three_pixels >> 8) & 0xFF);
                    word[3] = (byte)((three_pixels) & 0xFF);

                    channel.write(ByteBuffer.wrap(word));
                }
                // padding
                byte padding[] = new byte[4*2];
                channel.write(ByteBuffer.wrap(padding));
            }
            System.out.println("Start channel pos: " + channel.position());

            channel.position(216*4*256 + 4096);
            
            LinkedList<LoadedFile> roms = new LinkedList<LoadedFile>();
            load_files(args[2], roms, channel);

            LinkedList<LoadedFile> floppies = new LinkedList<LoadedFile>();
            load_files(args[3], floppies, channel);

            channel.position(216*4*256 + 0);
            write_header(roms, channel, TOP | SELECTABLE, SELECTABLE, BOTTOM | SELECTABLE);

            channel.position(216*4*256 + 512);
            write_header(floppies, channel, FLOPPY | SELECTABLE, FLOPPY | SELECTABLE, BOTTOM | FLOPPY | SELECTABLE);

            channel.close();
            out.close();
        
            /* Sample zero and first SD sector.
            * The 0 sector is loaded at byte offset 512 in control_osd|display_ram_inst.
            * The 1-7 sectors are loaded starting at byte offset 1024 in control_osd|display_ram_inst.
            */
            /*
            offset = 512;
            offset = print_string("  Some ROM              ", TOP | SELECTABLE,             0, offset);
            offset = print_string("  R1                    ", SELECTABLE,                   0, offset);
            offset = print_string("  R2                    ", SELECTABLE,                   0, offset);
            offset = print_string("  R3                    ", SELECTABLE,                   0, offset);
            offset = print_string("  R4                    ", SELECTABLE,                   0, offset);
            offset = print_string("  R5                    ", SELECTABLE,                   0, offset);
            offset = print_string("  Some ROM2             ", BOTTOM | SELECTABLE,          0, offset);

            offset = 1024;
            offset = print_string("  Floppy1               ", FLOPPY | SELECTABLE,          1, offset);
            offset = print_string("  F2                    ", FLOPPY | SELECTABLE,          1, offset);
            offset = print_string("  F3                    ", FLOPPY | SELECTABLE,          1, offset);
            offset = print_string("  F4                    ", FLOPPY | SELECTABLE,          1, offset);
            offset = print_string("  F5                    ", FLOPPY | SELECTABLE,          1, offset);
            offset = print_string("  F6                    ", FLOPPY | SELECTABLE,          1, offset);
            offset = print_string("  F7                    ", FLOPPY | SELECTABLE,          1, offset);
            offset = print_string("  F8                    ", FLOPPY | SELECTABLE,          1, offset);
            offset = print_string("  F9                    ", FLOPPY | SELECTABLE,          1, offset);
            offset = print_string("  F10                   ", FLOPPY | SELECTABLE,          1, offset);
            offset = print_string("  F11                   ", FLOPPY | SELECTABLE,          1, offset);
            offset = print_string("  F12                   ", FLOPPY | SELECTABLE,          1, offset);
            offset = print_string("  F13                   ", FLOPPY | SELECTABLE,          1, offset);
            offset = print_string("  F14                   ", FLOPPY | SELECTABLE,          1, offset);
            offset = print_string("  F15                   ", FLOPPY | SELECTABLE,          1, offset);
            offset = print_string("  F16                   ", FLOPPY | SELECTABLE,          1, offset);
            offset = print_string("  F17                   ", FLOPPY | SELECTABLE,          1, offset);
            offset = print_string("  F18                   ", FLOPPY | SELECTABLE,          1, offset);
            offset = print_string("  F19                   ", FLOPPY | SELECTABLE,          1, offset);
            offset = print_string("  F20                   ", BOTTOM | FLOPPY | SELECTABLE, 1, offset);
            */
        }
        else if(args[0].equals("spec_extract")) {
            DocumentationTool.extract(args[1], args[2]);
        }
        else if(args[0].equals("vga_to_png")) {
            int screen[][] = new int[480][640];
            int line_inserted[] = new int[480];

            File in_file = new File(args[1]);
            if(in_file.exists() == false || in_file.isDirectory() == true) throw new Exception("Can not open input file: " + in_file.getCanonicalPath());

            FileInputStream in = new FileInputStream(in_file);
            int b;
            int frame_number = 0;
            while(true) {
                // read line number
                int line_number;
                
                b = in.read(); if(b == -1) break;
                line_number = b;
                b = in.read(); if(b == -1) break;
                line_number |= (b<<8);

                // read full line
                byte line[] = new byte[960];
                if(in.read(line) != line.length) break;

                // convert bytes to bits
                int bits[] = new int[960*8];
                for(int i=0; i<line.length; i++) {
                    for(int j=0; j<8; j++) {
                        bits[i*8+j] = (line[i] >> j) & 0x01;
                    }
                }

                // fill in screen array
                if(line_number < 0 || line_number >= 480) throw new Exception("Illegal line number: " + line_number);
                for(int i=0; i<640; i++) {
                    int red = 0, green = 0, blue = 0;
                    for(int j=0; j<4; j++) blue  |= ((bits[i*12 +j +0]) << j);
                    for(int j=0; j<4; j++) green |= ((bits[i*12 +j +4]) << j);
                    for(int j=0; j<4; j++) red   |= ((bits[i*12 +j +8]) << j);
                    screen[line_number][i] = (0xFF << 24) | (red << 20) | (green << 12) | (blue << 4);
                }

                // check is screen frame ready
                line_inserted[line_number] = 1;

                boolean ready = true;
                for(int v : line_inserted) if(v != 1) ready = false;

                // create PNG image file when frame ready
                if(ready) {
                    BufferedImage img = new BufferedImage(640,480, BufferedImage.TYPE_INT_ARGB);
                    for(int i=0; i<480; i++) {
                        for(int j=0; j<640; j++) {
                            img.setRGB(j, i, screen[i][j]);
                        }
                    }
                    File output_dir = new File(args[2]);
                    if(output_dir.exists() == false || output_dir.isDirectory() == false) throw new Exception("Output directory illegal: " + output_dir.getCanonicalPath());

                    File output_file = new File(output_dir.getCanonicalFile() + File.separator + "frame_" + frame_number);
                    boolean written = ImageIO.write(img, "PNG", output_file);
                    if(written == false) throw new Exception("Could not write image file: " + output_file.getCanonicalPath());

                    System.out.println("Written frame number: " + frame_number);
                    frame_number++;
                    for(int i=0; i<line_inserted.length; i++) line_inserted[i] = 0;
                }
            }
        }
    }
    static OutputStream p_out;
}
