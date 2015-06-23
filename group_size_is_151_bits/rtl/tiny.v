/*
 * Copyright 2012, Homer Hsing <homer.hsing@gmail.com>
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

module tiny(clk, reset, sel, addr, w, data, out, done);
    input clk, reset;
    input sel;
    input [5:0] addr;
    input w;
    input [197:0] data;
    output [197:0] out;
    output done;

    /* for FSM */
    wire [5:0] fsm_addr;
    /* for RAM */
    wire [5:0] ram_a_addr, ram_b_addr;
    wire [197:0] ram_b_data_in;
    wire ram_a_w, ram_b_w;
    wire [197:0] ram_a_data_out, ram_b_data_out;
    /* for const */
    wire [197:0] const0_out, const1_out;
    wire const0_effective, const1_effective;
    /* for muxer */
    wire [197:0] muxer0_out, muxer1_out;
    /* for ROM */
    wire [8:0] rom_addr;
    wire [25:0] rom_q;
    /* for PE */
    wire [10:0] pe_ctrl;
    
    assign out = ram_a_data_out;
    
    select 
        select0 (sel, addr, fsm_addr, w, ram_a_addr, ram_a_w);
    rom
        rom0 (clk, rom_addr, rom_q);
    FSM
        fsm0 (clk, reset, rom_addr, rom_q, fsm_addr, ram_b_addr, ram_b_w, pe_ctrl, done);
    const
        const0 (clk, ram_a_addr, const0_out, const0_effective),
        const1 (clk, ram_b_addr, const1_out, const1_effective);
    ram
        ram0 (clk, ram_a_w, ram_a_addr, data, ram_a_data_out, ram_b_w, ram_b_addr[5:0], ram_b_data_in, ram_b_data_out);
    muxer
        muxer0 (ram_a_data_out, const0_out, const0_effective, muxer0_out),
        muxer1 (ram_b_data_out, const1_out, const1_effective, muxer1_out);
    PE
        pe0 (clk, reset, pe_ctrl, muxer1_out, muxer0_out[193:0], muxer0_out[193:0], ram_b_data_in[193:0]);
    
    assign ram_b_data_in[197:194] = 0;
endmodule

module select(sel, addr_in, addr_fsm_in, w_in, addr_out, w_out);
    input sel;
    input [5:0] addr_in;
    input [5:0] addr_fsm_in;
    input w_in;
    output [5:0] addr_out;
    output w_out;
    
    assign addr_out = sel ? addr_in : addr_fsm_in;
    assign w_out = sel & w_in;
endmodule

module muxer(from_ram, from_const, const_effective, out);
    input [197:0] from_ram, from_const;
    input const_effective;
    output [197:0] out;
    
    assign out = const_effective ? from_const : from_ram;
endmodule
