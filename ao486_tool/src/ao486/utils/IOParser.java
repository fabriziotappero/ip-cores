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

package ao486.utils;

import java.io.DataInputStream;
import java.io.EOFException;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.net.DatagramPacket;
import java.net.DatagramSocket;
import java.net.SocketTimeoutException;

public class IOParser {
    public static int read(DataInputStream dis, FileOutputStream fos) throws Exception {
        int val = dis.readInt();
        
        if(((val >> 24) & 0xFF) == 0xC0) {
            fos.write(String.format("IAC 0x%02x\n", val & 0xFF).getBytes());
            return 0;
        }
        if(((val >> 24) & 0xFF) == 0xC1) {
            fos.write(String.format("Exception 0x%02x\n", val & 0xFF).getBytes());
            return 0;
        }
        return val;
    }
    
    static void capture(String prefix) throws Exception {
        DatagramSocket socket = new DatagramSocket(52446);
        socket.setReceiveBufferSize(10000000);
        socket.setSoTimeout(5000);
        System.out.println("Recv buffer size: " + socket.getReceiveBufferSize());
        
        byte buf[] = new byte[1500];
        byte global[] = new byte[1073741824 + 1073741800];
        int index = 0;
        
        DatagramPacket packet = new DatagramPacket(buf, 1500);
        
        while(true) {
            try {
                socket.receive(packet);
            }
            catch(SocketTimeoutException e) {
                System.out.println("Checking end...");
                File end_file = new File("end");
                if(end_file.exists()) {
                    end_file.delete();
                    break;
                }
                continue;
            }
            System.arraycopy(buf, packet.getOffset(), global, index, packet.getLength());
            index += packet.getLength();
        }
        
        FileOutputStream fos = new FileOutputStream(prefix + ".dat");
        fos.write(global, 0, index);
        fos.close();
    }
    
    public static void main(String args[]) throws Exception {
        String prefix = "io_sndblaster_7";
        
        capture(prefix);
        
        
        FileInputStream fis = new FileInputStream(prefix + ".dat");
        DataInputStream dis = new DataInputStream(fis);
        
        FileOutputStream fos = new FileOutputStream(prefix + ".txt");
        
        Integer counter_prev = null;
        
        long input_length = new File(prefix + ".dat").length();
        input_length /= 1462;
       
        int val1 = 0, val2 = 0, val3 = 0;
        int state = 0;
        int total_counter = 0;
        
        int last_percent = 0;
        while(true) {
            
            int counter;
            try {
                total_counter++;
                counter = dis.readShort();
                if(counter < 0) counter += 65536;
            }
            catch(EOFException e) {
                System.out.println("Finished: total_counter: " + total_counter);
                break;
            }
            
            if(counter_prev == null) {
                counter_prev = counter;
            }
            else {
                int counter_compare = counter_prev + 1;
                if(counter_compare > 0xFFFF) counter_compare = 0;
                if(counter != counter_compare) {
                    System.out.println("Missing: counter: " + counter + " != counter_prev: " + counter_compare + " (" + total_counter + ")");
                    //return;
                }
                counter_prev = counter;
            }
            
            int next_percent = total_counter * 100 / (int)input_length;
            if(next_percent != last_percent) {
                last_percent = next_percent;
                System.out.println(next_percent + "%");
            }
            
            for(int i=0; i<365; i++) {
                if(state == 0) {
                    val1 = dis.readInt();
                    if(((val1 >> 30) & 3) != 0) state++;
                }
                else if(state == 1) {
                    val2 = dis.readInt();
                    state++;
                }
                else if(state == 2) {
                    val3 = dis.readInt();
                    state++;
                }
                
                if(state == 3) {
                    state = 0;
                    
                    int header1 = (val1 >> 30) & 3;
                    int header2 = (val1 >> 29) & 1;
                    int address = (val1 << 2) | ((val2 >> 30) & 3);
                    int data    = (val2 << 2) | ((val3 >> 30) & 3);
                    int byteena = (val3 >> 26) & 0xF;
                    boolean write = ((val3 >> 25) & 1) == 1;
                    boolean read  = ((val3 >> 24) & 1) == 1;
                    long instr_cnt= ((val1 & 0xFFL) << 32) | val2;
                    int vector    = (val3 >> 24) & 0xFF;
                    
                    if(header1 != 1 && header1 != 2 && header1 != 3) System.out.println("Inv header1: " + header1);
                    
                    if(byteena == 1) data &= 0x000000FF;
                    if(byteena == 2) data &= 0x0000FF00;
                    if(byteena == 4) data &= 0x00FF0000;
                    if(byteena == 8) data &= 0xFF000000;
                    if(byteena == 3) data &= 0x0000FFFF;
                    if(byteena == 6) data &= 0x00FFFF00;
                    if(byteena == 12)data &= 0xFFFF0000;
                    if(byteena == 7) data &= 0x00FFFFFF;
                    if(byteena == 14)data &= 0xFFFFFF00;
                    
                    if(header1 == 1) {
                        //mem
                        if(read == false && write == false) System.out.println("Inv mem read/write");
                        if(read == true  && write == true)  System.out.println("Inv mem read/write");
                        
                        fos.write(String.format("mem %s %08x %x %08x\n", write? "wr" : "rd", address, byteena, data).getBytes());
                    }
                    else if(header1 == 2) {
                        //io
                        if(read == false && write == false) System.out.println("Inv io read/write");
                        if(read == true  && write == true)  System.out.println("Inv io read/write");
                        
                        fos.write(String.format("io %s %04x %x %08x\n", write? "wr" : "rd", address, byteena, data).getBytes());
                    }
                    else if(header1 == 3 && header2 == 0) {
                        //interrupt
                        fos.write(String.format("IAC 0x%02x at %d\n", vector, instr_cnt).getBytes());
                    }
                    else if(header1 == 3 && header2 == 1) {
                        //interrupt
                        fos.write(String.format("Exception 0x%02x at %d\n", vector, instr_cnt).getBytes());
                    }
                    
                }
                
            }
        }
        fos.close();
    }
}
