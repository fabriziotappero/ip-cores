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

package ao486.test.layers;

import ao486.test.TestUnit;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.Random;

public class EffectiveAddressLayerFactory {
    
    public static enum modregrm_reg_t {
        SET,
        RANDOM
    }
    
    private static long update_target(long target, long val) {
        target -= val;
        target &= 0xFFFFFFFFL;
        return target;
    }
    
    public static byte[] prepare(long value_from_mod_rm,
                                int value_from_reg, modregrm_reg_t reg_type,
                                int length,
                                boolean a32,
                                LinkedList<Layer> layers,
                                final Random random,
                                TestUnit test,
                                boolean only_mem, boolean only_reg) throws Exception
    {
        int mod     = (only_reg)? 3 : random.nextInt(only_mem? 3 : 4);
        int rm      = random.nextInt(8);
        
        int scale   = random.nextInt(4);
        int index   = random.nextInt(8);
        int base    = random.nextInt(8);
        
System.out.printf("mod: %x\n", mod);
System.out.printf("rm:  %x\n", rm);
        
    boolean from_ss =
            (a32 && (mod == 1 || mod == 2) && rm == 5) ||
            (a32 && mod != 3 && rm == 4 && base == 4)  ||
            (a32 && (mod == 1 || mod == 2) && rm == 4 && base == 5) ||
            (!a32 && mod == 0 && (rm == 2 || rm == 3)) ||
            (!a32 && (mod == 1 || mod == 2) && (rm == 2 || rm == 3 || rm == 6));
        
        String segment = from_ss? "ss" : "ds";
        
        int     length_allowed  = length;
        boolean is_sib          = false;
        boolean is_memory       = true;
        
        int     disp_length = 0;
        long    disp = 0;
        
        long seg_base = 0;
        long target   = 0;
        long target_final = 0;
        
        final HashMap<String, Long> map = new HashMap<>();
        while(true) {
            
            if(mod == 3) {
                is_memory = false;
                
                if(length == 4) {
                    if(rm == 0) map.put("eax", value_from_mod_rm);
                    if(rm == 1) map.put("ecx", value_from_mod_rm);
                    if(rm == 2) map.put("edx", value_from_mod_rm);
                    if(rm == 3) map.put("ebx", value_from_mod_rm);
                    if(rm == 4) map.put("esp", value_from_mod_rm);
                    if(rm == 5) map.put("ebp", value_from_mod_rm);
                    if(rm == 6) map.put("esi", value_from_mod_rm);
                    if(rm == 7) map.put("edi", value_from_mod_rm);
                }
                else if(length == 2) {
                    if(rm == 0) map.put("ax", value_from_mod_rm & 0xFFFF);
                    if(rm == 1) map.put("cx", value_from_mod_rm & 0xFFFF);
                    if(rm == 2) map.put("dx", value_from_mod_rm & 0xFFFF);
                    if(rm == 3) map.put("bx", value_from_mod_rm & 0xFFFF);
                    if(rm == 4) map.put("sp", value_from_mod_rm & 0xFFFF);
                    if(rm == 5) map.put("bp", value_from_mod_rm & 0xFFFF);
                    if(rm == 6) map.put("si", value_from_mod_rm & 0xFFFF);
                    if(rm == 7) map.put("di", value_from_mod_rm & 0xFFFF);
                }
                else if(length == 1) {
                    if(rm == 0) map.put("al", value_from_mod_rm & 0xFF);
                    if(rm == 1) map.put("cl", value_from_mod_rm & 0xFF);
                    if(rm == 2) map.put("dl", value_from_mod_rm & 0xFF);
                    if(rm == 3) map.put("bl", value_from_mod_rm & 0xFF);
                    if(rm == 4) map.put("ah", value_from_mod_rm & 0xFF);
                    if(rm == 5) map.put("ch", value_from_mod_rm & 0xFF);
                    if(rm == 6) map.put("dh", value_from_mod_rm & 0xFF);
                    if(rm == 7) map.put("bh", value_from_mod_rm & 0xFF);
                }
                break;
            }
System.out.println("segment: " + segment);
            long seg_limit = Layer.norm(test.getInput(segment + "_limit"));
            seg_base  = Layer.norm(test.getInput(segment + "_base"));
            if(seg_limit < length) length_allowed = (int)(length - seg_limit);
            target =
                    (seg_limit == 0)?       0 :
                    (seg_limit < length)?   random.nextInt((int)seg_limit) :
                                            random.nextInt((int)(seg_limit - length +1));
            
            if(!a32) {
                target &= 0xFFFF;
            }
            target_final = target;
            
System.out.printf("target: %x, length: %d, final loc: %08x\n", target_final, length, seg_base + target);
            boolean target_ok = true;
            for(int i=0; i<length; i++) {
                if(test.is_memory_not_random((int)(seg_base + target + i))) target_ok = false;
            }
            if(target_ok == false) continue;
            
            if(!a32) {
                if(mod == 1) {
                    long disp8 = random.nextInt(256);
                    map.put("disp8", disp8);
                    if((disp8 >> 7) == 1) disp8 |= 0xFF00;
                    target = update_target(target, disp8);
                }
                if(mod == 2) {
                    long disp16 = random.nextInt(65536);
                    map.put("disp16", disp16);
                    target = update_target(target, disp16);
                }
                
                if((mod == 0 || mod == 1 || mod == 2) && rm == 0) {
                    long si = Layer.norm(random.nextInt(65536));
                    map.put("si", si);
                    target = update_target(target, si);
                    map.put("bx", target);
                }
                if((mod == 0 || mod == 1 || mod == 2) && rm == 1) {
                    long di = Layer.norm(random.nextInt(65536));
                    map.put("di", di);
                    target = update_target(target, di);
                    map.put("bx", target);
                }
                if((mod == 0 || mod == 1 || mod == 2) && rm == 2) {
                    long si = Layer.norm(random.nextInt(65536));
                    map.put("si", si);
                    target = update_target(target, si);
                    map.put("bp", target);
                }
                if((mod == 0 || mod == 1 || mod == 2) && rm == 3) {
                    long di = Layer.norm(random.nextInt(65536));
                    map.put("di", di);
                    target = update_target(target, di);
                    map.put("bp", target);
                }
                if((mod == 0 || mod == 1 || mod == 2) && rm == 4) {
                    map.put("si", target);
                }
                if((mod == 0 || mod == 1 || mod == 2) && rm == 5) {
                    map.put("di", target);
                }
                if(mod == 0 && rm == 6) {
                    map.put("disp16", target);
                }
                if((mod == 1 || mod == 2) && rm == 6) {
                    map.put("bp", target);
                }
                if((mod == 0 || mod == 1 || mod == 2) && rm == 7) {
                    map.put("bx", target);
                }
            }
            
            if(a32) {
                if(mod == 1 && rm != 4) {
                    long disp8 = random.nextInt(256);
                    map.put("disp8", disp8);
                    if((disp8 >> 7) == 1) disp8 |= 0xFFFFFF00;
                    target = update_target(target, disp8);
System.out.printf("disp8: %x\n", disp8);
                }
                if(mod == 2 && rm != 4) {
                    long disp32 = Layer.norm(random.nextInt());
                    map.put("disp32", disp32);
                    target = update_target(target, disp32);
                }
                
                if((mod == 0 || mod == 1 || mod == 2) && rm == 0) {
                    map.put("eax", target);
                }
                if((mod == 0 || mod == 1 || mod == 2) && rm == 1) {
                    map.put("ecx", target);
                }
                if((mod == 0 || mod == 1 || mod == 2) && rm == 2) {
                    map.put("edx", target);
                }
                if((mod == 0 || mod == 1 || mod == 2) && rm == 3) {
                    map.put("ebx", target);
                }
                if(mod == 0 && rm == 5) {
                    map.put("disp32", target);
                }
                if((mod == 1 || mod == 2) && rm == 5) {
                    map.put("ebp", target);
                }
                if((mod == 0 || mod == 1 || mod == 2) && rm == 6) {
                    map.put("esi", target);
                }
                if((mod == 0 || mod == 1 || mod == 2) && rm == 7) {
                    map.put("edi", target);
                }
                
                if(rm == 4) {
                    is_sib = true;
                    
                    HashMap<String, Integer> sib_map = new HashMap<>();
                    
                    sib_map.put("eax", 0);
                    sib_map.put("ecx", 0);
                    sib_map.put("edx", 0);
                    sib_map.put("ebx", 0);
                    sib_map.put("esp", 0);
                    sib_map.put("ebp", 0);
                    sib_map.put("esi", 0);
                    sib_map.put("edi", 0);
                    
                    if(base == 0) sib_map.put("eax", sib_map.get("eax") + 1);
                    if(base == 1) sib_map.put("ecx", sib_map.get("ecx") + 1);
                    if(base == 2) sib_map.put("edx", sib_map.get("edx") + 1);
                    if(base == 3) sib_map.put("ebx", sib_map.get("ebx") + 1);
                    if(base == 4) sib_map.put("esp", sib_map.get("esp") + 1);
                    if(base == 5 && (mod == 1 || mod == 2)) sib_map.put("ebp", sib_map.get("ebp") + 1);
                    if(base == 6) sib_map.put("esi", sib_map.get("esi") + 1);
                    if(base == 7) sib_map.put("edi", sib_map.get("edi") + 1);
                    
                    if(mod == 0 && base == 5)   sib_map.put("disp32", 1);
                    if(mod == 1)                sib_map.put("disp8",  1);
                    if(mod == 2)                sib_map.put("disp32", 1);
                    
                    int count = (scale == 0)? 1 :
                                (scale == 1)? 2 :
                                (scale == 2)? 4 :
                                              8;
                    if(index == 0) sib_map.put("eax", sib_map.get("eax") + count);
                    if(index == 1) sib_map.put("ecx", sib_map.get("ecx") + count);
                    if(index == 2) sib_map.put("edx", sib_map.get("edx") + count);
                    if(index == 3) sib_map.put("ebx", sib_map.get("ebx") + count);
                    if(index == 5) sib_map.put("ebp", sib_map.get("ebp") + count);
                    if(index == 6) sib_map.put("esi", sib_map.get("esi") + count);
                    if(index == 7) sib_map.put("edi", sib_map.get("edi") + count);
                    
                    //-----
                    
                    if(sib_map.containsKey("disp8")) {
                        long disp8 = random.nextInt(256);
                        map.put("disp8", disp8);
                        if((disp8 >> 7) == 1) disp8 |= 0xFFFFFF00;
                        target = update_target(target, disp8);
                        
                        sib_map.remove("disp8");
                    }
                    
                    String found = null;
                    for(String s : sib_map.keySet()) {
                        if(sib_map.get(s) == 1) {
                            found = s;
                            break;
                        }
                    }
                    
                    while(found != null) {
                        String key = sib_map.keySet().toArray(new String[0])[random.nextInt(sib_map.keySet().size())];
                        if(sib_map.get(key) != 1) continue;
                        found = key;
                        sib_map.remove(found);
                        break;
                    }
                    
                    if(found != null) {
                        for(String s : sib_map.keySet()) {
                            int coeff = sib_map.get(s);
                            
                            if(coeff > 0) {
                                long val32 = Layer.norm(random.nextInt());
                                while((val32 % coeff) != 0) val32--;
                                map.put(s, val32/coeff);
                                target = update_target(target, val32);
                            }
                        }
                        map.put(found, target);
                    }
                    else {
                        while(true) {
                            boolean removed = false;
                            for(String s : sib_map.keySet()) {
                                if(sib_map.get(s) == 0) {
                                    sib_map.remove(s);
                                    removed = true;
                                    break;
                                }
                            }
                            if(removed == false) break;
                        }
                        
                        if(sib_map.size() != 1) throw new Exception("Internal test error");
                        
                        int coeff = 0;
                        String key = null;
                        for(String s : sib_map.keySet()) {
                            coeff = sib_map.get(s);
                            key = s;
                            break;
                        }
                        
                        if((target % coeff) != 0) continue;
                        
                        map.put(key, target/coeff);
                    }
                }
            }
            break;
        }    
        if(map.containsKey("eax")) layers.addFirst(new Layer(random) { long eax() { return map.get("eax").longValue() & 0xFFFFFFFFL; } });
        if(map.containsKey("ecx")) layers.addFirst(new Layer(random) { long ecx() { return map.get("ecx").longValue() & 0xFFFFFFFFL; } });
        if(map.containsKey("edx")) layers.addFirst(new Layer(random) { long edx() { return map.get("edx").longValue() & 0xFFFFFFFFL; } });
        if(map.containsKey("ebx")) layers.addFirst(new Layer(random) { long ebx() { return map.get("ebx").longValue() & 0xFFFFFFFFL; } });
        if(map.containsKey("esp")) layers.addFirst(new Layer(random) { long esp() { return map.get("esp").longValue() & 0xFFFFFFFFL; } });
        if(map.containsKey("ebp")) layers.addFirst(new Layer(random) { long ebp() { return map.get("ebp").longValue() & 0xFFFFFFFFL; } });
        if(map.containsKey("esi")) layers.addFirst(new Layer(random) { long esi() { return map.get("esi").longValue() & 0xFFFFFFFFL; } });
        if(map.containsKey("edi")) layers.addFirst(new Layer(random) { long edi() { return map.get("edi").longValue() & 0xFFFFFFFFL; } });

        if(map.containsKey("ax")) layers.addFirst(new Layer(random) { long eax() { return (random.nextInt(65536) << 16) | ((int)Layer.norm(map.get("ax").intValue()) & 0xFFFF); } });
        if(map.containsKey("cx")) layers.addFirst(new Layer(random) { long ecx() { return (random.nextInt(65536) << 16) | ((int)Layer.norm(map.get("cx").intValue()) & 0xFFFF); } });
        if(map.containsKey("dx")) layers.addFirst(new Layer(random) { long edx() { return (random.nextInt(65536) << 16) | ((int)Layer.norm(map.get("dx").intValue()) & 0xFFFF); } });
        if(map.containsKey("bx")) layers.addFirst(new Layer(random) { long ebx() { return (random.nextInt(65536) << 16) | ((int)Layer.norm(map.get("bx").intValue()) & 0xFFFF); } });
        if(map.containsKey("sp")) layers.addFirst(new Layer(random) { long esp() { return (random.nextInt(65536) << 16) | ((int)Layer.norm(map.get("sp").intValue()) & 0xFFFF); } });
        if(map.containsKey("bp")) layers.addFirst(new Layer(random) { long ebp() { return (random.nextInt(65536) << 16) | ((int)Layer.norm(map.get("bp").intValue()) & 0xFFFF); } });
        if(map.containsKey("si")) layers.addFirst(new Layer(random) { long esi() { return (random.nextInt(65536) << 16) | ((int)Layer.norm(map.get("si").intValue()) & 0xFFFF); } });
        if(map.containsKey("di")) layers.addFirst(new Layer(random) { long edi() { return (random.nextInt(65536) << 16) | ((int)Layer.norm(map.get("di").intValue()) & 0xFFFF); } });

        if(map.containsKey("al")) layers.addFirst(new Layer(random) { long eax() { return (random.nextInt(16777216) << 8) | ((int)Layer.norm(map.get("al").intValue()) & 0xFF); } });
        if(map.containsKey("ah")) layers.addFirst(new Layer(random) { long eax() { return random.nextInt(256) | (((int)Layer.norm(map.get("ah").intValue()) & 0xFF) << 8) | (random.nextInt(65536) << 16); } });
        if(map.containsKey("bl")) layers.addFirst(new Layer(random) { long ebx() { return (random.nextInt(16777216) << 8) | ((int)Layer.norm(map.get("bl").intValue()) & 0xFF); } });
        if(map.containsKey("bh")) layers.addFirst(new Layer(random) { long ebx() { return random.nextInt(256) | (((int)Layer.norm(map.get("bh").intValue()) & 0xFF) << 8) | (random.nextInt(65536) << 16); } });
        if(map.containsKey("cl")) layers.addFirst(new Layer(random) { long ecx() { return (random.nextInt(16777216) << 8) | ((int)Layer.norm(map.get("cl").intValue()) & 0xFF); } });
        if(map.containsKey("ch")) layers.addFirst(new Layer(random) { long ecx() { return random.nextInt(256) | (((int)Layer.norm(map.get("ch").intValue()) & 0xFF) << 8) | (random.nextInt(65536) << 16); } });
        if(map.containsKey("dl")) layers.addFirst(new Layer(random) { long edx() { return (random.nextInt(16777216) << 8) | ((int)Layer.norm(map.get("dl").intValue()) & 0xFF); } });
        if(map.containsKey("dh")) layers.addFirst(new Layer(random) { long edx() { return random.nextInt(256) | (((int)Layer.norm(map.get("dh").intValue()) & 0xFF) << 8) | (random.nextInt(65536) << 16); } });
        
        if(is_memory) {
System.out.printf("value_from_mod_rm: %x\n", value_from_mod_rm);
            target_map.clear();
            for(int i=0; i<length_allowed; i++) {
                target_map.put(seg_base+target_final+i, (byte)((value_from_mod_rm >> (i*8)) & 0xFF));
            }
            layers.addFirst(new Layer(random) {
                public boolean is_memory_not_random(long address) { return target_map.containsKey(address); }
                
                public Byte get_memory(long address) {
                    return (target_map.containsKey(address) == false)? null : target_map.get(address);
                }
            });
        }
        
        
        // prepare modregrm bytes
        if(map.containsKey("disp8")) {
            if(disp_length != 0) throw new Exception("Internal test error");
            disp = map.get("disp8");
            disp_length = 1;
        }
        if(map.containsKey("disp16")) {
            if(disp_length != 0) throw new Exception("Internal test error");
            disp = map.get("disp16");
            disp_length = 2;
        }
        if(map.containsKey("disp32")) {
            if(disp_length != 0) throw new Exception("Internal test error");
            disp = map.get("disp32");
            disp_length = 4;
        }
        
        int reg = (reg_type == modregrm_reg_t.SET)? value_from_reg : random.nextInt(8);
        
        LinkedList<Byte> modregrm_bytes = new LinkedList<>();
        
        modregrm_bytes.add((byte)( ((mod & 0x3) << 6) | ((reg & 0x7) << 3) | ((rm & 0x7) << 0) ));

System.out.printf("modregrm: %x\n", modregrm_bytes.get(0)); 
System.out.printf("len: %d - %d\n", length_allowed, length);
System.out.printf("seg_base: %x\n", seg_base);

        if(is_sib)              modregrm_bytes.add((byte)( ((scale & 0x3) << 6) | ((index & 0x7) << 3) | ((base & 0x7) << 0) ));
        if(disp_length == 1)    modregrm_bytes.add((byte)(disp & 0xFF));
        if(disp_length == 2) {
            modregrm_bytes.add((byte)(disp & 0xFF));
            modregrm_bytes.add((byte)((disp >> 8) & 0xFF));
        }
        if(disp_length == 4) {
            modregrm_bytes.add((byte)(disp & 0xFF));
            modregrm_bytes.add((byte)((disp >> 8) & 0xFF));
            modregrm_bytes.add((byte)((disp >> 16) & 0xFF));
            modregrm_bytes.add((byte)((disp >> 24) & 0xFF));
        }
        
        byte bytes[] = new byte[modregrm_bytes.size()];
        for(int i=0; i<bytes.length; i++) bytes[i] = modregrm_bytes.get(i);
        
        return bytes;
    }
    static HashMap<Long, Byte> target_map = new HashMap<>();
}
