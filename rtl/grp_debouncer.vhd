-----------------------------------------------------------------------------------------------------------------------
-- Author:          Jonny Doin, jdoin@opencores.org, jonnydoin@gmail.com
-- 
-- Create Date:     09:56:30 07/06/2011  
-- Module Name:     grp_debouncer - RTL
-- Project Name:    basic functions
-- Target Devices:  Spartan-6
-- Tool versions:   ISE 13.1
-- Description: 
--
--      This block is a generic multiple input debouncing circuit.
--      It handles multiple inputs, like mechanical switch inputs, and outputs a debounced, stable registered version of the inputs.
--      A 'new_data' one-cycle strobe is also available, to sync downstream logic.
--
--      CONCEPTUAL CIRCUIT
--      ==================
--                                                                                     
--                                           W                                         
--                          /----------------/----------------\                        
--                          |                                 |                        
--                          |                                 |                        
--                          |        ______        ______     |         _____          
--                          |    W   |    |   W    |fdr |  W  |    W    |cmp \         
--                          \----/---| +1 |---/----|    |--/--+----/----|     \        
--                                   |    |        |    |               |      \       
--                                   ------        |    |               \       |      
--                                                 |    |                |   =  |-----\
--                                                 |> R |               /       |     |
--                                                 ---+--               |      /      |
--                                                    |       CNT_VAL---|     /       |
--                                                    |                 |____/        |
--                                                    |                               |
--                                                    \------------\                  |
--                                                                 |                  |
--                                      N    ____                  |                  |
--                              /-------/---))   \      ____       |                  |
--                              |           ))XOR |-----)   \      |                  |
--                              |    /------))___/      )OR  |-----/                  |
--                              |    |              /---)___/                         |
--                              |    |              |                                 |
--                              |    |              \----------\                      |
--                              |    |        N                |                      |
--                              |    \--------/-----------\    +----------------------+---------\
--                              |                         |    |                                |
--                              \---\                     |    |                                |
--                     ______       |        ______       |    |   ______                       |
--                     | fd |       |        | fd |       |    |   |fde |                       |
--   [data_i]----/-----|    |---/---+---/----|    |---/---+----)---|    |---/---+---/-----------)------------------------[data_o]
--               N     |    |   N       N    |    |   N   |    |   |    |   N   |   N           |
--                     |    |                |    |       |    \---|CE  |       |               |
--                     |    |                |    |       |        |    |       |               |
--   [clk_i]---->      |>   |                |>   |       |        |>   |       |               |   ____       ______
--                     ------                ------       |        ------       |   N    ____   \---|   \      | fd |
--                                                        |                     \---/---))   \      |AND |-----|    |----[strb_o]
--                                                        |                             ))XOR |-----|___/      |    |
--                                                        \-------------------------/---))___/                 |    |
--                                                                                   N                         |    |
--                                                                                                             |>   |
--                                                                                                             ------
--
--
--      PIPELINE LOGIC
--      ==============
--
--      This debouncer circuit detects edges in an input signal, and waits the signal to stabilize for the designated time 
--      before transferring the stable signal to the registered output. 
--      A one-clock-cyle strobe is pulsed at the output to signalize a new data available.
--      The core clock should be the system clock, to optimize use of global clock resources.
--
--      GROUP DEBOUNCING
--      ================
--
--      A change in state in any bit in the input word causes reload of the delay counter, and the output word is updated only 
--      when all bits are stable for the specified period. Therefore, the grouping of signals and delay selection should match
--      behaviour of the selected signals.
--
--      RESOURCES USED
--      ==============
--
--      The number of registers inferred is: 3*N + (LOG(CNT_VAL)/LOG(2)) + 1 registers.
--      The number of LUTs inferred is roughly: ((4*N+2)/6)+2.
--      The slice distribution will vary, and depends on the control set restrictions and LUT-FF pairs resulting from map+p&r.
--
--      This design was originally targeted to a Spartan-6 platform, synthesized with XST and normal constraints.
--      Verification in silicon was done on a Digilent Atlys board with a Spartan-6 FPGA @100MHz clock.
--      The VHDL dialect used is VHDL'93, accepted largely by all synthesis tools.
--
------------------------------ COPYRIGHT NOTICE -----------------------------------------------------------------------
--                                                                   
--                                                                   
--      Author(s):      Jonny Doin, jdoin@opencores.org, jonnydoin@gmail.com
--                                                                   
--      Copyright (C) 2011 Jonny Doin
--      -----------------------------
--                                                                   
--      This source file may be used and distributed without restriction provided that this copyright statement is not    
--      removed from the file and that any derivative work contains the original copyright notice and the associated 
--      disclaimer. 
--                                                                   
--      This source file is free software; you can redistribute it and/or modify it under the terms of the GNU Lesser 
--      General Public License as published by the Free Software Foundation; either version 2.1 of the License, or 
--      (at your option) any later version.
--                                                                   
--      This source is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied
--      warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more  
--      details.
--
--      You should have received a copy of the GNU Lesser General Public License along with this source; if not, download 
--      it from http://www.gnu.org/licenses/lgpl.txt
--                                                                   
------------------------------ REVISION HISTORY -----------------------------------------------------------------------
--
-- 2011/07/06   v0.01.0010  [JD]    started development. verification of synthesis circuit inference.
-- 2011/07/07   v1.00.0020  [JD]    verification in silicon. operation at 100MHz, tested on the Atlys board (Spartan-6 LX45).
-- 2011/08/10   v1.01.0025  [JD]    added one pipeline delay to new data strobe output.
-- 2011/09/19   v1.01.0030  [JD]    changed range for internal counter (cnt_reg, cnt_next) to avoid adder flipover (Altera/ModelSim).
--
-----------------------------------------------------------------------------------------------------------------------
--  TODO
--  ====
--
--  The circuit can easily be extended to have a signature of which inputs changed at the data out port.
--
-----------------------------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity grp_debouncer is
    Generic (   
        N : positive := 8;                                                      -- input bus width
        CNT_VAL : positive := 10000);                                           -- clock counts for debounce period
    Port (  
        clk_i : in std_logic := 'X';                                            -- system clock
        data_i : in std_logic_vector (N-1 downto 0) := (others => 'X');         -- noisy input data
        data_o : out std_logic_vector (N-1 downto 0);                           -- registered stable output data
        strb_o : out std_logic                                                  -- strobe for new data available
    );                      
end grp_debouncer;

architecture rtl of grp_debouncer is
    -- datapath pipeline 
    signal reg_A, reg_B : std_logic_vector (N-1 downto 0) := (others => '0');   -- debounce edge detectors
    signal reg_out : std_logic_vector (N-1 downto 0) := (others => '0');        -- registered output
    signal dat_strb : std_logic := '0';                                         -- data transfer strobe
    signal strb_reg : std_logic := '0';                                         -- registered strobe
    signal strb_next : std_logic := '0';                                        -- lookahead strobe
    signal dat_diff : std_logic := '0';                                         -- edge detector
    -- debounce counter
    signal cnt_reg : integer range CNT_VAL + 1 downto 0 := 0;                   -- debounce period counter
    signal cnt_next : integer range CNT_VAL + 1 downto 0 := 0;                  -- combinatorial signal
begin

    --=============================================================================================
    -- DEBOUNCE COUNTER LOGIC
    --=============================================================================================
    -- This counter is implemented as a up-counter with reset and final count detection via compare,
    -- instead of a down-counter with preset and final count detection via nonzero detection.
    -- This is better for Spartan-6 and Virtex-6 CLB architecture, because it uses less control sets.
    --
    -- cnt_reg register transfer logic
    cnt_reg_proc: process (clk_i) is
    begin
        if clk_i'event and clk_i = '1' then
            cnt_reg <= cnt_next;
        end if;
    end process cnt_reg_proc;
    -- cnt_next combinatorial logic
    cnt_next_proc: cnt_next <=  0 when dat_diff = '1' or dat_strb = '1' else cnt_reg + 1;
    -- final count combinatorial logic
    final_cnt_proc: dat_strb <= '1' when cnt_reg = CNT_VAL else '0';

    --=============================================================================================
    -- DATAPATH SIGNAL PIPELINE
    --=============================================================================================
    -- input pipeline logic
    pipeline_proc: process (clk_i) is
    begin
        if clk_i'event and clk_i = '1' then
            -- edge detection pipeline
            reg_A <= data_i;
            reg_B <= reg_A;
            -- new data strobe pipeline delay
            strb_reg <= strb_next;
        end if;
        -- output data pipeline
        if clk_i'event and clk_i = '1' then
            if dat_strb = '1' then
                reg_out <= reg_B;
            end if;
        end if;
    end process pipeline_proc;
    -- edge detector
    edge_detector_proc: dat_diff <= '1' when reg_A /= reg_B else '0';
    -- lookahead new data strobe
    next_strobe_proc: strb_next <= '1' when ((reg_out /= reg_B) and dat_strb = '1') else '0';
    
    --=============================================================================================
    -- OUTPUT LOGIC
    --=============================================================================================
    -- connect output ports
    data_o_proc:    data_o <= reg_out;
    strb_o_proc:    strb_o <= strb_reg;
end rtl;

