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

import java.util.Random;

public class SegmentLayer extends Layer {
    public SegmentLayer(Random random) {
        this.random = random;
    }
    
    public long es_cache_valid()   { return 1; }
    public long cs_cache_valid()   { return 1; }
    public long ds_cache_valid()   { return 1; }
    public long ss_cache_valid()   { return 1; }
    public long fs_cache_valid()   { return 1; }
    public long gs_cache_valid()   { return 1; }
    public long ldtr_cache_valid() { return 1; }
    public long tr_cache_valid()   { return 1; }
    
    public long es()        { return 0; }
    public long cs()        { return 0; }
    public long ss()        { return 0; }
    public long ds()        { return 0; }
    public long fs()        { return 0; }
    public long gs()        { return 0; }
    public long ldtr()      { return 0; }
    public long tr()        { return 0; }
    
    public long es_base()   { return 0; }
    public long cs_base()   { return 0; }
    public long ss_base()   { return 0; }
    public long ds_base()   { return 0; }
    public long fs_base()   { return 0; }
    public long gs_base()   { return 0; }
    public long ldtr_base() { return 0; }
    public long tr_base()   { return 0; }
    
    public long es_limit()   { return 0x000FFFFF; }
    public long cs_limit()   { return 0x000FFFFF; }
    public long ss_limit()   { return 0x000FFFFF; }
    public long ds_limit()   { return 0x000FFFFF; }
    public long fs_limit()   { return 0x000FFFFF; }
    public long gs_limit()   { return 0x000FFFFF; }
    public long ldtr_limit() { return 0x000FFFFF; }
    public long tr_limit()   { return 0x000FFFFF; }
    
    public long es_valid()   { return 1; }
    public long cs_valid()   { return 1; }
    public long ss_valid()   { return 1; }
    public long ds_valid()   { return 1; }
    public long fs_valid()   { return 1; }
    public long gs_valid()   { return 1; }
    public long ldtr_valid() { return 1; }
    public long tr_valid()   { return 1; }
    
    public long es_selector()   { return 0; }
    public long cs_selector()   { return 0; }
    public long ss_selector()   { return 0; }
    public long ds_selector()   { return 0; }
    public long fs_selector()   { return 0; }
    public long gs_selector()   { return 0; }
    public long ldtr_selector() { return 0; }
    public long tr_selector()   { return 0; }
    
    public long es_rpl()   { return 0; }
    public long cs_rpl()   { return 0; }
    public long ss_rpl()   { return 0; }
    public long ds_rpl()   { return 0; }
    public long fs_rpl()   { return 0; }
    public long gs_rpl()   { return 0; }
    public long ldtr_rpl() { return 0; }
    public long tr_rpl()   { return 0; }
    
    public long es_g()   { return 0; }
    public long cs_g()   { return 0; }
    public long ss_g()   { return 0; }
    public long ds_g()   { return 0; }
    public long fs_g()   { return 0; }
    public long gs_g()   { return 0; }
    public long ldtr_g() { return 0; }
    public long tr_g()   { return 0; }
    
    public long es_d_b()   { return 0; }
    public long cs_d_b()   { return 0; }
    public long ss_d_b()   { return 0; }
    public long ds_d_b()   { return 0; }
    public long fs_d_b()   { return 0; }
    public long gs_d_b()   { return 0; }
    public long ldtr_d_b() { return 0; }
    public long tr_d_b()   { return 0; }
    
    public long es_avl()   { return 0; }
    public long cs_avl()   { return 0; }
    public long ss_avl()   { return 0; }
    public long ds_avl()   { return 0; }
    public long fs_avl()   { return 0; }
    public long gs_avl()   { return 0; }
    public long ldtr_avl() { return 0; }
    public long tr_avl()   { return 0; }
    
    public long es_p()   { return 1; }
    public long cs_p()   { return 1; }
    public long ss_p()   { return 1; }
    public long ds_p()   { return 1; }
    public long fs_p()   { return 1; }
    public long gs_p()   { return 1; }
    public long ldtr_p() { return 1; }
    public long tr_p()   { return 1; }
    
    public long es_dpl()   { return 0; }
    public long cs_dpl()   { return 0; }
    public long ss_dpl()   { return 0; }
    public long ds_dpl()   { return 0; }
    public long fs_dpl()   { return 0; }
    public long gs_dpl()   { return 0; }
    public long ldtr_dpl() { return 0; }
    public long tr_dpl()   { return 0; }
    
    public long es_s()     { return 1; }
    public long cs_s()     { return 1; }
    public long ss_s()     { return 1; }
    public long ds_s()     { return 1; }
    public long fs_s()     { return 1; }
    public long gs_s()     { return 1; }
    public long ldtr_s()   { return 1; }
    public long tr_s()     { return 1; }

    // data read write accessed
    public long es_type()   { return 3; }
    public long cs_type()   { return 3; }
    public long ss_type()   { return 3; }
    public long ds_type()   { return 3; }
    public long fs_type()   { return 3; }
    public long gs_type()   { return 3; }
    public long ldtr_type() { return 3; }
    public long tr_type()   { return 3; }
}
