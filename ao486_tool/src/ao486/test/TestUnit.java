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

package ao486.test;

import ao486.test.layers.Layer;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.io.Serializable;
import java.lang.reflect.Method;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.Properties;
import java.util.Random;

public abstract class TestUnit {
    
    //--------------------------------------------------------------------------
    
    public long getInput(String name) throws Exception {
//System.out.println("getInput for " + name);
        return (Long)executeMethod(name, false);
    }
    long check_interrupt(long time) throws Exception {
        Long ret = (Long)executeMethod("check_interrupt", false, check_interrupt_index++);
        return (ret == null)? 0x100 : ret;
    }
    long getTestType() throws Exception {
        return (Long)executeMethod("get_test_type", false);
    }
    
    long read_io(Runner.CMD_start_io_read params) throws Exception {
        return read(params.byteena, params.address, local_io, null, "get_io");
    }
    long read(Runner.CMD_start_read params) throws Exception {
        return read(params.byteena, params.address, local_memory, local_memory_read_only, "get_memory");
    }
    long read_code(Runner.CMD_start_read_code params) throws Exception {
        return read(params.byteena, params.address, local_memory, local_memory_read_only, "get_memory");
    }
    void write_io(Runner.CMD_start_io_write params) throws Exception {
        // do nothing; params saved in Runner
    }
    void write(Runner.CMD_start_write params) throws Exception {
        long byteenable = params.byteena;
        long data       = params.data;
        
        for(int i=0; i<4; i++) {
            if((byteenable & 1) == 1) local_memory.put(params.address + i, (byte)(data & 0xFF));
        
            byteenable >>= 1;
            data >>= 8;
        }
    }

    //--------------------------------------------------------------------------
    
    LinkedList<Object>          run_log                 = new LinkedList<>();
    HashMap<Long, Byte>         local_memory            = new HashMap<>();
    HashMap<Long, Byte>         local_memory_read_only  = new HashMap<>();
    HashMap<Long, Byte>         local_io                = new HashMap<>();
    long                        check_interrupt_index   = 0;
    
    public Random               random;
    public int                  index;
    public LinkedList<Layer>    layers = new LinkedList<>();
    
    //--------------------------------------------------------------------------
    
    private Object executeMethod(String name, boolean null_is_skip, Object ...args) throws Exception {
        for(Layer layer : layers) {
            for(Method m : layer.getClass().getDeclaredMethods()) {
                if(m.getName().equals(name)) {
                    m.setAccessible(true);
                    Object ret = m.invoke(layer, args);
                    if(ret != null || null_is_skip == false) {
                        return ret;
                    }
                }
            }
        }
        return null;
    }
    
    private long read(long byteenable, long address, HashMap<Long, Byte> map, HashMap<Long, Byte> map_ro, String method_name) throws Exception {
        long data = 0;
        
        for(int i=0; i<4; i++) {
            data <<= 8;
            
            if((byteenable & 1) == 1) {
            
                if(map.containsKey(address + i)) {
                    data |= map.get(address + i) & 0xFFL;
//System.out.printf("in map: %08x = %x\n", (address+i), data & 0xFFL);
                }
                else {
                    Object obj = executeMethod(method_name, true, (address + i));
//System.out.printf("executed: %08x = %x, in class: %s, method_name: %s\n", (address+i), (obj != null)? (Byte)obj : 0, executed_in_class, method_name);
                    if(obj == null) data |= random.nextInt() & 0xFFL;
                    else            data |= ((Byte)obj) & 0xFFL;
                    
                    map.put(address + i, (byte)(data & 0xFFL));
                    if(map_ro != null) map_ro.put(address + i, (byte)(data & 0xFFL));
                }
            }
            byteenable >>= 1;
        }
        return ((data >> 24) & 0xFFL) | ((data >> 8) & 0xFF00L) | ((data << 8) & 0xFF0000L) | ((data << 24) & 0xFF000000L);
    }
    
    //--------------------------------------------------------------------------
    
    public boolean is_memory_not_random(long address) throws Exception {
        Boolean ret = (Boolean)executeMethod("is_memory_not_random", false, address);
        return (ret == null)? false : ret;
    }
    
    public String bytesToHex(byte bytes[]) {
        String s = "";
        for(byte b : bytes) s += String.format("%02x", b);
        return s;
    }
    
    static public byte[] hexToBytes(String hex) throws Exception {
        if((hex.length() %2) != 0) throw new Exception("Not full hex string: " + hex);
        
        byte bytes[] = new byte[hex.length()/2];
        for(int i=0; i<bytes.length; i++) bytes[i] = (byte)Integer.valueOf(hex.substring(i*2, i*2+2), 16).intValue();
        
        return bytes;
    }
    
    public boolean isAccepted(int val, boolean... conds) {
        for(boolean b : conds) {
            if((val & 1) == 1 && b == false) return false;
            if((val & 1) == 0 && b == true) return false;
            val >>= 1;
        }
        return true;
    }
    
    public int unsigned(byte b) {
        int result = b;
        if(result < 0) result += 256;
        return result;
    }
    
    public int modregrm_len(boolean a16, int modregrm, int sib) {
        int mod      = (modregrm >> 6) & 3;
        int rm       = modregrm & 7;
        int base     = sib & 7;

        // d_CRx_DRx_condition ignored
        
        if(a16 && mod == 0 && rm == 6) return 3;
        if(a16 && mod == 1) return 2;
        if(a16 && mod == 2) return 3;
        if(a16) return 1;
        
        if(mod == 0 && rm == 5) return 5;
        if(mod == 0 && rm == 4 && base == 5) return 6;
        if(mod == 0 && rm == 4) return 2;
        if(mod == 1 && rm == 4) return 3;
        if(mod == 1) return 2;
        if(mod == 2 && rm == 4) return 6;
        if(mod == 2) return 5;
        
        return 1;
    }
    
    public static class Descriptor implements Serializable {
        public Descriptor(int base, int limit, int type, boolean segment, boolean present, int dpl, boolean d_b, boolean g, boolean l, boolean avl) {
            this.base       = base;
            this.limit      = limit;
            this.type       = type;
            this.segment    = segment;
            this.present    = present;
            this.dpl        = dpl;
            this.d_b        = d_b;
            this.g          = g;
            this.l          = l;
            this.avl        = avl;
        }
        public int     base,limit,type,dpl;
        public boolean segment, present, d_b, g;
        public boolean l, avl;
        
        public byte get_byte(int index) {
            switch(index) {
                case 0:     return (byte)((limit >> 0) & 0xFF);
                case 1:     return (byte)((limit >> 8) & 0xFF);
                case 2:     return (byte)((base >> 0) & 0xFF);
                case 3:     return (byte)((base >> 8) & 0xFF);
                case 4:     return (byte)((base >> 16) & 0xFF);
                case 5:     return (byte)( (present? 1 << 7 : 0) | ((dpl & 3) << 5) | (segment? 1 << 4 : 0) | (type & 15) );
                case 6:     return (byte)( (g? 1 << 7 : 0) | (d_b? 1 << 6 : 0) | (l? 1 << 5 : 0) | (avl? 1 << 4 : 0) | ((limit >> 16) & 15) );
                default:    return (byte)((base >> 24) & 0xFF);
            }
        }
        public void set_dest_offset(long offset) {
            limit = (int)(offset & 0xFFFFF);
            avl   = ((offset >> 20)&1) == 1;
            l     = ((offset >> 21)&1) == 1;
            d_b   = ((offset >> 22)&1) == 1;
            g     = ((offset >> 23)&1) == 1;
            
            base  = (int)((offset & 0xFF000000) | (base & 0x00FFFFFF));
        }
    }
    
    //--------------------------------------------------------------------------
    
    public abstract int get_test_count() throws Exception;
    
    public abstract void init() throws Exception;
    
    //--------------------------------------------------------------------------
    
    //--------------------------------------------------------------------------

    public static void run_test(Class test_class) throws Exception {
        
        int index = 0;
        
        FileInputStream run_prop_files = new FileInputStream("run.properties");
        Properties run_prop = new Properties();
        run_prop.load(run_prop_files);
        run_prop_files.close();
        
        if(run_prop.getProperty("deserialize").toLowerCase().equals("yes")) {
            ObjectInputStream ois = new ObjectInputStream(new FileInputStream("test.obj"));
            index = ois.readInt();
            ois.close();
        }
        
        File output_directory = new File(".");
        File directory;
        LinkedList<String> command_line = new LinkedList<>();
        
        Runner runner = new Runner();
        
        boolean test_failed = false;
        
        TestUnit test_for_size = (TestUnit)test_class.newInstance();
      
        for(; index<test_for_size.get_test_count(); index++) {
            System.out.println(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Running test " +
                    (index+1) + "/" + test_for_size.get_test_count());
            
            ObjectOutputStream oos = new ObjectOutputStream(new FileOutputStream("test.obj"));
            oos.writeInt(index);
            oos.close();
            
            //run bochs486
            TestUnit test_bochs = (TestUnit)test_class.newInstance();
            test_bochs.index = index;
            
            test_bochs.init();
            
            directory = new File("./../bochs486/");
            command_line.clear();
            command_line.add("./bochs486");
            
            runner.execute(command_line, directory, test_bochs);
            
            //run verilog
            TestUnit test_verilog = (TestUnit)test_class.newInstance();
            test_verilog.index        = index;
            test_verilog.local_io     = test_bochs.local_io;
            test_verilog.local_memory = test_bochs.local_memory_read_only;
            
            test_verilog.init();
            
            directory = new File("./../sim/ao486");
            command_line.clear();
            command_line.add("/opt/iverilog/bin/vvp");
            command_line.add("tb_ao486.vvp");
            //command_line.add("-lxt");
            
            runner.execute(command_line, directory, test_verilog);
            
            test_failed = RunRaport.compare(test_bochs.run_log, test_verilog.run_log, output_directory);
            if(test_failed) break;
        }
        
        if(test_failed) System.out.println("TEST: FAILED.");
        else            System.out.println("TEST: OK.");
    }
}
