/*
 * Copyright (c) 2014, Aleksander Osman
 * All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 * 
 * * Redistributions of source code must retain the above copyright notice, this
 *   list of conditions and the following disclaimer.
 * 
 * * Redistributions in binary form must reproduce the above copyright notice,
 *   this list of conditions and the following disclaimer in the documentation
 *   and/or other materials provided with the distribution.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

package ao486;

import java.io.File;
import java.io.FileInputStream;
import java.io.RandomAccessFile;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.nio.file.Files;
import java.util.Arrays;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.Properties;

public class SDGenerator {
    
    static byte[] crc32(byte bytes[]) {
        int crc[] = new int[32];

        for(int i=0; i<32; i++) crc[i] = 1;
        
        for(byte b : bytes) {
            int in[] = new int[8];
            for(int j=0; j<8; j++) in[j] = (b >> j) & 1;

            int new_crc[] = new int[32];

            new_crc[31] = in[2] ^ crc[23] ^ crc[29];
            new_crc[30] = in[0] ^ in[3] ^ crc[22] ^ crc[28] ^ crc[31];
            new_crc[29] = in[0] ^ in[1] ^ in[4] ^ crc[21] ^ crc[27] ^ crc[30] ^ crc[31];
            new_crc[28] = in[1] ^ in[2] ^ in[5] ^ crc[20] ^ crc[26] ^ crc[29] ^ crc[30];
            new_crc[27] = in[0] ^ in[2] ^ in[3] ^ in[6] ^ crc[19] ^ crc[25] ^ crc[28] ^ crc[29] ^ crc[31];
            new_crc[26] = in[1] ^ in[3] ^ in[4] ^ in[7] ^ crc[18] ^ crc[24] ^ crc[27] ^ crc[28] ^ crc[30];
            new_crc[25] = in[4] ^ in[5] ^ crc[17] ^ crc[26] ^ crc[27];
            new_crc[24] = in[0] ^ in[5] ^ in[6] ^ crc[16] ^ crc[25] ^ crc[26] ^ crc[31];
            new_crc[23] = in[1] ^ in[6] ^ in[7] ^ crc[15] ^ crc[24] ^ crc[25] ^ crc[30];
            new_crc[22] = in[7] ^ crc[14] ^ crc[24];
            new_crc[21] = in[2] ^ crc[13] ^ crc[29];
            new_crc[20] = in[3] ^ crc[12] ^ crc[28];
            new_crc[19] = in[0] ^ in[4] ^ crc[11] ^ crc[27] ^ crc[31];
            new_crc[18] = in[0] ^ in[1] ^ in[5] ^ crc[10] ^ crc[26] ^ crc[30] ^ crc[31];
            new_crc[17] = in[1] ^ in[2] ^ in[6] ^ crc[9] ^ crc[25] ^ crc[29] ^ crc[30];
            new_crc[16] = in[2] ^ in[3] ^ in[7] ^ crc[8] ^ crc[24] ^ crc[28] ^ crc[29];
            new_crc[15] = in[0] ^ in[2] ^ in[3] ^ in[4] ^ crc[7] ^ crc[27] ^ crc[28] ^ crc[29] ^ crc[31];
            new_crc[14] = in[0] ^ in[1] ^ in[3] ^ in[4] ^ in[5] ^ crc[6] ^ crc[26] ^ crc[27] ^ crc[28] ^ crc[30] ^ crc[31];
            new_crc[13] = in[0] ^ in[1] ^ in[2] ^ in[4] ^ in[5] ^ in[6] ^ crc[5] ^ crc[25] ^ crc[26] ^ crc[27] ^ crc[29] ^ crc[30] ^ crc[31];
            new_crc[12] = in[1] ^ in[2] ^ in[3] ^ in[5] ^ in[6] ^ in[7] ^ crc[4] ^ crc[24] ^ crc[25] ^ crc[26] ^ crc[28] ^ crc[29] ^ crc[30];
            new_crc[11] = in[3] ^ in[4] ^ in[6] ^ in[7] ^ crc[3] ^ crc[24] ^ crc[25] ^ crc[27] ^ crc[28];
            new_crc[10] = in[2] ^ in[4] ^ in[5] ^ in[7] ^ crc[2] ^ crc[24] ^ crc[26] ^ crc[27] ^ crc[29];
            new_crc[9] = in[2] ^ in[3] ^ in[5] ^ in[6] ^ crc[1] ^ crc[25] ^ crc[26] ^ crc[28] ^ crc[29];
            new_crc[8] = in[3] ^ in[4] ^ in[6] ^ in[7] ^ crc[0] ^ crc[24] ^ crc[25] ^ crc[27] ^ crc[28];
            new_crc[7] = in[0] ^ in[2] ^ in[4] ^ in[5] ^ in[7] ^ crc[24] ^ crc[26] ^ crc[27] ^ crc[29] ^ crc[31];
            new_crc[6] = in[0] ^ in[1] ^ in[2] ^ in[3] ^ in[5] ^ in[6] ^ crc[25] ^ crc[26] ^ crc[28] ^ crc[29] ^ crc[30] ^ crc[31];
            new_crc[5] = in[0] ^ in[1] ^ in[2] ^ in[3] ^ in[4] ^ in[6] ^ in[7] ^ crc[24] ^ crc[25] ^ crc[27] ^ crc[28] ^ crc[29] ^ crc[30] ^ crc[31];
            new_crc[4] = in[1] ^ in[3] ^ in[4] ^ in[5] ^ in[7] ^ crc[24] ^ crc[26] ^ crc[27] ^ crc[28] ^ crc[30];
            new_crc[3] = in[0] ^ in[4] ^ in[5] ^ in[6] ^ crc[25] ^ crc[26] ^ crc[27] ^ crc[31];
            new_crc[2] = in[0] ^ in[1] ^ in[5] ^ in[6] ^ in[7] ^ crc[24] ^ crc[25] ^ crc[26] ^ crc[30] ^ crc[31];
            new_crc[1] = in[0] ^ in[1] ^ in[6] ^ in[7] ^ crc[24] ^ crc[25] ^ crc[30] ^ crc[31];
            new_crc[0] = in[1] ^ in[7] ^ crc[24] ^ crc[30];
            
            System.arraycopy(new_crc, 0, crc, 0, 32);
        }
        
        long output = 0;
        for(int i=0; i<32; i++) {
            output |= crc[i] << (31-i);
        }
        output = ~output;
        
        byte out[] = new byte[4];
        for(int i=0; i<4; i++) out[i] = (byte)((output >> (i*8)) & 0xFF);
        return out;
    }
    
    final static byte TYPE_BIOS     = 1;
    final static byte TYPE_VGABIOS  = 2;
    final static byte TYPE_HDD      = 3;
    final static byte TYPE_FD_1_44M = 16;
    final static byte TYPE_CRC32    = 127;
    
    final static int HEADER_MAX_ENTRIES = 128;
    
    static void append_name(String name, ByteBuffer buf) throws Exception {
        byte name_bytes[] = name.getBytes();
        buf.put(name_bytes, 0, (name_bytes.length > 14)? 14 : name_bytes.length);
        for(int i=name_bytes.length; i<14; i++) buf.put((byte)0);
        buf.put((byte)0);
    }
    
    public static void main(String args[]) throws Exception {
        
        File sd_root = new File("../sd");
        
        //scan for bios
        String bios_files[] = new File(sd_root, "bios").list();
        Arrays.sort(bios_files);
        
        //scan for vgabios files
        String vgabios_files[] = new File(sd_root, "vgabios").list();
        Arrays.sort(vgabios_files);
        
        //1_44m floppies
        String fd_1_44m_files[] = new File(sd_root, "fd_1_44m").list();
        Arrays.sort(fd_1_44m_files);
        
        //hdd
        String hdd_files[] = new File(sd_root, "hdd").list();
        Arrays.sort(hdd_files);
        
        //header
        ByteBuffer buf = ByteBuffer.allocate(32 * (HEADER_MAX_ENTRIES - 1));
        buf.order(ByteOrder.LITTLE_ENDIAN);
        
        int first_free_sector = 32 * HEADER_MAX_ENTRIES;
        if((first_free_sector % 512) != 0) throw new Exception("Header not % 512 !");
        first_free_sector /= 512;
        
        HashMap<Integer, Object> files = new HashMap<>();
        LinkedList<Integer> used_sectors = new LinkedList<>();
        
        //process bios files
        for(String name : bios_files) {
            File file = new File(sd_root, "bios/" + name);
            byte file_bytes[] = Files.readAllBytes(file.toPath());
            
            buf.put(TYPE_BIOS);
            append_name(name, buf);
            buf.putInt(first_free_sector);
            buf.putInt((int)file.length());
            buf.putInt(0xF0000);
            buf.put(crc32(file_bytes));
            
            files.put(first_free_sector, file_bytes);
            first_free_sector += (file_bytes.length + 511)/512;
        }
        
        //process vgabios files
        for(String name : vgabios_files) {
            File file = new File(sd_root, "vgabios/" + name);
            byte file_bytes[] = Files.readAllBytes(file.toPath());
            
            buf.put(TYPE_VGABIOS);
            append_name(name, buf);
            buf.putInt(first_free_sector);
            buf.putInt((int)file.length());
            buf.putInt(0xC0000);
            buf.put(crc32(file_bytes));
            
            files.put(first_free_sector, file_bytes);
            first_free_sector += (file_bytes.length + 511)/512;
        }
        
        //process hdd files
        for(String name : hdd_files) {
            File file = new File(sd_root, "hdd/" + name);
            Properties props = new Properties();
            props.load(new FileInputStream(file));
            
            int start     = Integer.parseInt(props.getProperty("start"));
            if((start % 512) != 0) throw new Exception("Invalid start property in file: " + file.getCanonicalPath());
            
            int cylinders = Integer.parseInt(props.getProperty("cylinders"));
            int heads     = Integer.parseInt(props.getProperty("heads"));
            int spt       = Integer.parseInt(props.getProperty("spt"));
            
            int size      = Integer.parseInt(props.getProperty("size"));
            
            if(cylinders * heads * spt * 512 != size) throw new Exception("Invalid parameters in hdd file: " + file.getCanonicalPath());
            
            buf.put(TYPE_HDD);
            append_name(name.substring(0, name.indexOf(".")), buf);
            buf.putInt(start/512);
            buf.putInt(cylinders);
            buf.putInt(heads);
            buf.putInt(spt);
            
            used_sectors.add(start/512);
            used_sectors.add(start/512 + size/512 - 1);
        }
        
        //process fd_1_44m files
        for(String name : fd_1_44m_files) {
            File file = new File(sd_root, "fd_1_44m/" + name);
            byte file_bytes[] = Files.readAllBytes(file.toPath());
            
            buf.put(TYPE_FD_1_44M);
            append_name(name, buf);
            buf.putInt(first_free_sector);
            buf.putInt(0);
            buf.putInt(0);
            buf.putInt(0);
            
            files.put(first_free_sector, file_bytes);
            first_free_sector += (file_bytes.length + 511)/512;
        }
        
        //verify that sectors do not overlap
        for(int i=0; i<used_sectors.size(); i+=2) {
            int start = used_sectors.get(i+0);
            int end   = used_sectors.get(i+1);
            
            if(first_free_sector >= start) throw new Exception("first_free_sector overlaps used_sectors: " + i);
            
            for(int j=i+2; j<used_sectors.size(); j+=2) {
                int cmp_start = used_sectors.get(j+0);
                int cmp_end   = used_sectors.get(j+1);
                
                if(cmp_end >= start && cmp_end <= end)      throw new Exception("cmp_end overlaps: " + i + ", " + j);
                if(cmp_start >= start && cmp_start <= end)  throw new Exception("cmp_start overlaps: " + i + ", " + j);
                if(cmp_start < start && cmp_end > end)      throw new Exception("cmp overlaps: " + i + ", " + j);
            }
        }
        
        //prepare header for output file
        byte header_start[] = new byte[buf.position()];
        if((header_start.length % 32) != 0) throw new Exception("Invalid header_start - not %32");
        buf.flip();
        buf.get(header_start);
        
        //crc32 entry
        buf = ByteBuffer.allocate(32);
        buf.put(TYPE_CRC32);
        for(int i=0; i<15; i++) buf.put((byte)0);
        buf.put(crc32(header_start));
        
        byte header_end[] = new byte[buf.position()];
        buf.flip();
        buf.get(header_end);
        
        //output
        File sd_dat = new File("sd.dat");
        if(sd_dat.exists()) {
            if(sd_dat.delete() == false) throw new Exception("Can not delete file: " + sd_dat.getCanonicalPath());
        }
        
        RandomAccessFile raf = new RandomAccessFile(sd_dat, "rws");
        raf.seek(0);
        raf.write(header_start);
        raf.write(header_end);
        
        for(int pos : files.keySet()) {
            byte bytes[] = (byte [])files.get(pos);
            
            raf.seek(pos*512);
            raf.write(bytes);
        }
        raf.close();
    }
}
