-------------------------------------------------------------------------------
-- 
-- RapidIO IP Library Core
-- 
-- This file is part of the RapidIO IP library project
-- http://www.opencores.org/cores/rio/
-- 
-- To Do:
-- -
-- 
-- Author(s): 
-- - A. Demirezen, azdem@opencores.org 
-- 
-------------------------------------------------------------------------------
-- 
-- Copyright (C) 2013 Authors and OPENCORES.ORG 
-- 
-- This source file may be used and distributed without 
-- restriction provided that this copyright statement is not 
-- removed from the file and that any derivative work contains 
-- the original copyright notice and the associated disclaimer. 
-- 
-- This source file is free software; you can redistribute it 
-- and/or modify it under the terms of the GNU Lesser General 
-- Public License as published by the Free Software Foundation; 
-- either version 2.1 of the License, or (at your option) any 
-- later version. 
-- 
-- This source is distributed in the hope that it will be 
-- useful, but WITHOUT ANY WARRANTY; without even the implied 
-- warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR 
-- PURPOSE. See the GNU Lesser General Public License for more 
-- details. 
-- 
-- You should have received a copy of the GNU Lesser General 
-- Public License along with this source; if not, download it 
-- from http://www.opencores.org/lgpl.shtml 
-- 
------------------------------------------------------------------------------
------------------------------------------------------------------------------
--
-- File name:    ccs_timer.vhd
-- Rev:          0.0
-- Description:  This entity watches the CCS (clock compensation sequence) 
--               insertion according to RIO Sepec. Part-6, subchapter 4.7.1
-- 
------------------------------------------------------------------------------
------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use work.rio_common.all;

entity ccs_timer is
  generic (
    TCQ         : time      := 100 ps
  );
  port ( 
    rst_n               : in  std_logic;
    UCLK                : in  std_logic;
    
    send_ccs            : out std_logic;    
    ccs_timer_rst       : in  std_logic
  );
end ccs_timer;

architecture RTL of ccs_timer is
--------------------------------------------------------------------------------------
signal   ccs_counter            : std_logic_vector(11 downto 0) := (others => '0');
constant CCS_INTERVAL           : std_logic_vector(11 downto 0) := x"7FF";  -- = 4096 chars

--------------------------------------------------------------------------------------
begin
 
-- CCS counter process
process(rst_n, UCLK)
    begin    
    if rst_n = '0'  then    
        ccs_counter     <= CCS_INTERVAL; 
        send_ccs        <= '0';
    elsif rising_edge(UCLK) then 
        if ccs_timer_rst = '0' then  
            if ccs_counter = CCS_INTERVAL then
                send_ccs    <= '1';
            else
                send_ccs    <= '0';
                ccs_counter <= ccs_counter + '1';
            end if;   
        else
            send_ccs    <= '0';
            ccs_counter <= (others => '0');  
        end if;   
    end if;
end process;
 
end RTL;
---------------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- 
-- RapidIO IP Library Core
-- 
-- This file is part of the RapidIO IP library project
-- http://www.opencores.org/cores/rio/
-- 
-- To Do:
-- -
-- 
-- Author(s): 
-- - A. Demirezen, azdem@opencores.org 
-- 
-------------------------------------------------------------------------------
-- 
-- Copyright (C) 2013 Authors and OPENCORES.ORG 
-- 
-- This source file may be used and distributed without 
-- restriction provided that this copyright statement is not 
-- removed from the file and that any derivative work contains 
-- the original copyright notice and the associated disclaimer. 
-- 
-- This source file is free software; you can redistribute it 
-- and/or modify it under the terms of the GNU Lesser General 
-- Public License as published by the Free Software Foundation; 
-- either version 2.1 of the License, or (at your option) any 
-- later version. 
-- 
-- This source is distributed in the hope that it will be 
-- useful, but WITHOUT ANY WARRANTY; without even the implied 
-- warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR 
-- PURPOSE. See the GNU Lesser General Public License for more 
-- details. 
-- 
-- You should have received a copy of the GNU Lesser General 
-- Public License along with this source; if not, download it 
-- from http://www.opencores.org/lgpl.shtml 
-- 
------------------------------------------------------------------------------
------------------------------------------------------------------------------
--
-- File name:    idle_generator.vhd
-- Rev:          0.0
-- Description:  This entity generates IDLE1 sequence for SRIO PHY 
--               RIO Sepec. Part-6, subchapter 4.7.2
-- 
------------------------------------------------------------------------------
------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use work.rio_common.all;

entity idle_generator is
  generic (
            lfsr_init   : std_logic_vector(7 downto 0) := x"01";
            TCQ         : time      := 100 ps
  );
  port ( 
    UCLK                : in  std_logic;
    rst_n               : in  std_logic;
    
    send_idle           : in  std_logic;
    
    send_K              : out std_logic;
    send_A              : out std_logic;
    send_R              : out std_logic
  );
end idle_generator;

architecture RTL of idle_generator is
-------------------------------------------------------------------------------------------------------------------------------------------
signal q_pseudo_random_number  : std_logic_vector(7 downto 0) := (others => '0');
signal pseudo_random_bit       : std_logic                    := '0';

signal down_counter_load_value : std_logic_vector(4 downto 0) := (others => '0');
signal down_counter            : std_logic_vector(4 downto 0) := (others => '0');
signal Acntr_eq_zero           : std_logic                    := '0';
signal send_idle_q             : std_logic                    := '0';
-- 

COMPONENT pseudo_random_number_generator    
GENERIC (
         lfsr_init   : std_logic_vector(7 downto 0)
        );
PORT(
	clk     : IN std_logic;
	rst_n   : IN std_logic;          
	q       : OUT std_logic_vector(7 downto 0)
	);
END COMPONENT;

-------------------------------------------------------------------------------------------------------------------------------------------
begin

inst_prng: pseudo_random_number_generator GENERIC MAP(
        lfsr_init => lfsr_init  --x"01"
	)
    PORT MAP(
        clk     => UCLK,
		rst_n   => rst_n,
		q       => q_pseudo_random_number
	);

pseudo_random_bit       <= q_pseudo_random_number(0);

down_counter_load_value <= '1' & q_pseudo_random_number(6) & q_pseudo_random_number(4) & q_pseudo_random_number(3) & q_pseudo_random_number(1);

-- down counter process
process(rst_n, UCLK)
    begin    
    if rst_n = '0'  then    
        down_counter      <= (others => '0');       
    elsif rising_edge(UCLK) then    
        if Acntr_eq_zero = '1' then
            down_counter <= down_counter_load_value;
        else
            down_counter <= down_counter - '1';
        end if;   
    end if;
end process;

Acntr_eq_zero <= '1' when down_counter = "00000" else '0';

-- send_idle delay process
process(rst_n, UCLK)
    begin    
    if rst_n = '0'  then    
        send_idle_q     <= '0';       
    elsif rising_edge(UCLK) then    
        send_idle_q     <= send_idle;
    end if;
end process;
 
send_K <= send_idle and (not(send_idle_q) or (send_idle_q and not(Acntr_eq_zero) and pseudo_random_bit)); 
send_A <= send_idle and send_idle_q and Acntr_eq_zero;
send_R <= send_idle and send_idle_q and not(Acntr_eq_zero) and not(pseudo_random_bit);

end RTL;
-------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- 
-- RapidIO IP Library Core
-- 
-- This file is part of the RapidIO IP library project
-- http://www.opencores.org/cores/rio/
-- 
-- To Do:
-- -
-- 
-- Author(s): 
-- - A. Demirezen, azdem@opencores.org 
-- 
-------------------------------------------------------------------------------
-- 
-- Copyright (C) 2013 Authors and OPENCORES.ORG 
-- 
-- This source file may be used and distributed without 
-- restriction provided that this copyright statement is not 
-- removed from the file and that any derivative work contains 
-- the original copyright notice and the associated disclaimer. 
-- 
-- This source file is free software; you can redistribute it 
-- and/or modify it under the terms of the GNU Lesser General 
-- Public License as published by the Free Software Foundation; 
-- either version 2.1 of the License, or (at your option) any 
-- later version. 
-- 
-- This source is distributed in the hope that it will be 
-- useful, but WITHOUT ANY WARRANTY; without even the implied 
-- warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR 
-- PURPOSE. See the GNU Lesser General Public License for more 
-- details. 
-- 
-- You should have received a copy of the GNU Lesser General 
-- Public License along with this source; if not, download it 
-- from http://www.opencores.org/lgpl.shtml 
-- 
------------------------------------------------------------------------------
------------------------------------------------------------------------------
--
-- File name:    idle_generator_dual.vhd
-- Rev:          0.0
-- Description:  This entity generates IDLE1 sequence for SRIO PHY 
--               RIO Sepec. Part-6, subchapter 4.7.2
-- 
------------------------------------------------------------------------------
------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use work.rio_common.all;

entity idle_generator_dual is
  generic (
            TCQ         : time      := 100 ps
  );
  port ( 
    UCLK                : in  std_logic;
    rst_n               : in  std_logic;
    
    send_idle           : in  std_logic_vector(1 downto 0);
    
    send_K              : out std_logic_vector(1 downto 0);
    send_A              : out std_logic_vector(1 downto 0);
    send_R              : out std_logic_vector(1 downto 0)
  );
end idle_generator_dual;

architecture RTL of idle_generator_dual is
-------------------------------------------------------------------------------------------------------------------------------------------

COMPONENT idle_generator
  generic (
            lfsr_init   : std_logic_vector(7 downto 0);
            TCQ         : time 
  );
PORT(
	UCLK        : IN  std_logic;
	rst_n       : IN  std_logic;
	send_idle   : IN  std_logic;          
	send_K      : OUT std_logic;
	send_A      : OUT std_logic;
	send_R      : OUT std_logic
	);
END COMPONENT;

-------------------------------------------------------------------------------------------------------------------------------------------
begin

	Inst_idle_generator_0: idle_generator GENERIC MAP(
        TCQ         => 100 ps,
        lfsr_init   => x"0F"
    )
        PORT MAP(
		UCLK        => UCLK,
		rst_n       => rst_n,
		send_idle   => send_idle(0),
		send_K      => send_K(0),
		send_A      => send_A(0),
		send_R      => send_R(0)
	);

	Inst_idle_generator_1: idle_generator GENERIC MAP(
        TCQ         => 100 ps,
        lfsr_init => x"F0"
    )
        PORT MAP(
		UCLK        => UCLK,
		rst_n       => rst_n,
		send_idle   => send_idle(1),
		send_K      => send_K(1),
		send_A      => send_A(1),
		send_R      => send_R(1)
	);

end RTL;
-------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- 
-- RapidIO IP Library Core
-- 
-- This file is part of the RapidIO IP library project
-- http://www.opencores.org/cores/rio/
-- 
-- To Do:
-- -
-- 
-- Author(s): 
-- - A. Demirezen, azdem@opencores.org 
-- 
-------------------------------------------------------------------------------
-- 
-- Copyright (C) 2013 Authors and OPENCORES.ORG 
-- 
-- This source file may be used and distributed without 
-- restriction provided that this copyright statement is not 
-- removed from the file and that any derivative work contains 
-- the original copyright notice and the associated disclaimer. 
-- 
-- This source file is free software; you can redistribute it 
-- and/or modify it under the terms of the GNU Lesser General 
-- Public License as published by the Free Software Foundation; 
-- either version 2.1 of the License, or (at your option) any 
-- later version. 
-- 
-- This source is distributed in the hope that it will be 
-- useful, but WITHOUT ANY WARRANTY; without even the implied 
-- warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR 
-- PURPOSE. See the GNU Lesser General Public License for more 
-- details. 
-- 
-- You should have received a copy of the GNU Lesser General 
-- Public License along with this source; if not, download it 
-- from http://www.opencores.org/lgpl.shtml 
-- 
------------------------------------------------------------------------------
------------------------------------------------------------------------------
--
-- File name:    pcs_rx_controller.vhd
-- Rev:          0.0
-- Description:  This entity controls the RX stream 
--               
-- 
------------------------------------------------------------------------------
------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use work.rio_common.all;

entity pcs_rx_controller is
  generic (
    TCQ                     : time  := 100 ps
  );
  port ( 
    rst_n                   : in  std_logic;
    rio_clk                 : in  std_logic;  -- ~150 MHz
    UCLK_x2                 : in  std_logic;  --  312,5 MHz
    UCLK                    : in  std_logic;  --  156,25 MHz 
    UCLK_x2_DV2             : in  std_logic;  --  312,5 MHz @ x4 mode / 78,125 @ x1 (fallback mode) 
    UCLK_or_DV4             : in  std_logic;  --  156,25 MHz @ x4 mode / 39,0625 @ x1 (fallback mode)
    -- UCLK_DV4                : in  std_logic;  --  39,0625
    --
    -- Interface to the RioSerial
    inboundRead_i           : in  std_logic;
    inboundEmpty_o          : out std_logic;
    inboundSymbol_o         : out std_logic_vector(33 downto 0);    
    --
    -- Interface to the GTX transceivers
    RXDATA_i                : in  std_logic_vector(63 downto 0);  -- N = 4
    RXCHARISK_i             : in  std_logic_vector(7 downto 0);
    RXCHARISvalid_i         : in  std_logic_vector(7 downto 0);
    --
    -- Interface to the port init
    port_initalized_i       : in  std_logic;
    mode_sel_i              : in  std_logic;
    mode_0_lane_sel_i       : in  std_logic
    
  );
end pcs_rx_controller;

architecture RTL of pcs_rx_controller is
    
-------------------------------------------------------------------------------
COMPONENT pcs_rx_boudary_32b_out_64b_in
    PORT (
    rst             : IN STD_LOGIC;
    wr_clk          : IN STD_LOGIC;
    rd_clk          : IN STD_LOGIC;
    din             : IN STD_LOGIC_VECTOR(67 DOWNTO 0);
    wr_en           : IN STD_LOGIC;
    rd_en           : IN STD_LOGIC;
    dout            : OUT STD_LOGIC_VECTOR(33 DOWNTO 0);
    full            : OUT STD_LOGIC;
    almost_full     : OUT STD_LOGIC;
    empty           : OUT STD_LOGIC;
    almost_empty    : OUT STD_LOGIC;
    valid           : OUT STD_LOGIC
  );
END COMPONENT;    
-------------------------------------------------------------------------------
signal rst                  : std_logic:= '0';

signal RXDATA_swap          : std_logic_vector(63 downto 0) := (others => '0'); 
signal RXCHARISK_swap       : std_logic_vector(7  downto 0) := (others => '0');
signal RXCHARISvalid_swap   : std_logic_vector(7  downto 0) := (others => '0');

signal RXDATA_u             : std_logic_vector(31 downto 0) := (others => '0'); 
signal RXCHARISK_u          : std_logic_vector(3  downto 0) := (others => '0');
signal RXDATA_l             : std_logic_vector(31 downto 0) := (others => '0'); 
signal RXCHARISK_l          : std_logic_vector(3  downto 0) := (others => '0');
signal RXCHARISvalid_u      : std_logic_vector(3  downto 0) := (others => '0');
signal RXCHARISvalid_l      : std_logic_vector(3  downto 0) := (others => '0');

signal inboundValid           : std_logic:= '0';
signal rx_fifo_wr_en          : std_logic:= '0';
signal rx_fifo_wr_en_q        : std_logic:= '0';
signal rx_fifo_full           : std_logic:= '0';
signal rx_fifo_almost_full    : std_logic:= '0';
signal rx_fifo_almost_empty   : std_logic:= '0';
    
signal rx_fifo_data_in        : std_logic_vector(67 downto 0) := (others => '0');
signal rx_fifo_data_in_q      : std_logic_vector(67 downto 0) := (others => '0');
signal rx_fifo_data_swapped   : std_logic_vector(67 downto 0) := (others => '0');
signal rx_fifo_full_p         : std_logic:= '0';

signal port_initalized      : std_logic:= '0'; 
signal mode_sel             : std_logic:= '0'; 
signal mode_0_lane_sel      : std_logic:= '0';    

signal port_state           : std_logic_vector(2 downto 0) := (others => '0');

signal upper_symbol_type    : std_logic_vector(1  downto 0) := (others => '0');
signal lower_symbol_type    : std_logic_vector(1  downto 0) := (others => '0');

signal upper_symbol_not_idle  : std_logic:= '0'; 
signal lower_symbol_not_idle  : std_logic:= '0'; 
signal upper_symbol_valid     : std_logic:= '0'; 
signal lower_symbol_valid     : std_logic:= '0'; 
signal upper_symbol_not_error : std_logic:= '0'; 
signal lower_symbol_not_error : std_logic:= '0'; 

-- signal RXDATA_sr              : std_logic_vector(63 downto 0) := (others => '0'); 
-- signal RXCHARISK_sr           : std_logic_vector(7  downto 0) := (others => '0');
-- signal RXCHARISvalid_sr       : std_logic_vector(7  downto 0) := (others => '0'); 

signal RXDATA_sr_done         : std_logic_vector(63 downto 0) := (others => '0'); 
signal RXCHARISK_sr_done      : std_logic_vector(7  downto 0) := (others => '0');
signal RXCHARISvalid_sr_done  : std_logic_vector(7  downto 0) := (others => '0');   

signal RXDATA_sr              : std_logic_vector(71 downto 0) := (others => '0'); 
signal RXCHARISK_sr           : std_logic_vector(8  downto 0) := (others => '0');
signal RXCHARISvalid_sr       : std_logic_vector(8  downto 0) := (others => '0');   

signal RXDATA_R_lane          : std_logic_vector(15 downto 0) := (others => '0'); 
signal RXCHARISK_R_lane       : std_logic_vector(1  downto 0) := (others => '0');
signal RXCHARISvalid_R_lane   : std_logic_vector(1  downto 0) := (others => '0');    

signal valid_byte_cntr        : std_logic_vector(2  downto 0) := (others => '0');
signal irregular_stream       : std_logic:= '0';
signal done_cntr              : std_logic_vector(1  downto 0) := (others => '0');
signal rx_done                : std_logic:= '0';

signal u_l_switch             : std_logic:= '0';

-- signal sr_symbol_not_idle     : std_logic:= '0'; 
-- signal sr_symbol_not_idle_q   : std_logic:= '0'; 
-- signal sr_symbol_not_error    : std_logic:= '0'; 
-- signal sr_symbol_not_error_q  : std_logic:= '0'; 
-- signal RXDATA_sr              : std_logic_vector(31 downto 0) := (others => '0'); 
-- signal RXCHARISK_sr           : std_logic_vector(3  downto 0) := (others => '0');
-- signal RXCHARISvalid_sr       : std_logic_vector(3  downto 0) := (others => '0');                              
-- signal sr_symbol_type         : std_logic_vector(1  downto 0) := (others => '0');

signal sr_u_symbol_not_idle     : std_logic:= '0'; 
signal sr_u_symbol_not_idle_q   : std_logic:= '0'; 
signal sr_u_symbol_not_error    : std_logic:= '0'; 
signal sr_u_symbol_not_error_q  : std_logic:= '0'; 
signal RXDATA_u_sr              : std_logic_vector(31 downto 0) := (others => '0'); 
signal RXCHARISK_u_sr           : std_logic_vector(3  downto 0) := (others => '0');
signal RXCHARISvalid_u_sr       : std_logic_vector(3  downto 0) := (others => '0');                              
signal sr_u_symbol_type         : std_logic_vector(1  downto 0) := (others => '0');

signal sr_l_symbol_not_idle     : std_logic:= '0'; 
signal sr_l_symbol_not_idle_q   : std_logic:= '0'; 
signal sr_l_symbol_not_error    : std_logic:= '0'; 
signal sr_l_symbol_not_error_q  : std_logic:= '0'; 
signal RXDATA_sr_l              : std_logic_vector(31 downto 0) := (others => '0'); 
signal RXCHARISK_sr_l           : std_logic_vector(3  downto 0) := (others => '0');
signal RXCHARISvalid_sr_l       : std_logic_vector(3  downto 0) := (others => '0');                              
signal sr_l_symbol_type         : std_logic_vector(1  downto 0) := (others => '0');
                              
                              
signal started_once           : std_logic:= '0'; 
signal word_switch            : std_logic:= '0';
signal shift_cntr             : std_logic_vector(1  downto 0) := (others => '0');


----------------------------------------------------------------------------------
begin  
rst                  <= not(rst_n);

rx_boundary_fifo : pcs_rx_boudary_32b_out_64b_in   -- FWFT FIFO
  PORT MAP (
    rst            => rst,    
    rd_clk         => rio_clk,
    rd_en          => inboundRead_i,
    dout           => inboundSymbol_o,
    valid          => inboundValid,
    empty          => inboundEmpty_o,
    almost_empty   => rx_fifo_almost_empty,
    
    wr_clk         => UCLK_or_DV4,
    wr_en          => rx_fifo_wr_en_q,      -- rx_fifo_wr_en,        -- rx_fifo_wr_en_q,         --
    din            => rx_fifo_data_in_q,    -- rx_fifo_data_in,      -- rx_fifo_data_in_q,       --
    full           => rx_fifo_full,         -- rx_fifo_full    
    almost_full    => rx_fifo_almost_full   -- rx_fifo_full    
  ); 

-- Pipelining RX write
process(UCLK_or_DV4)  
    begin  
    if rising_edge(UCLK_or_DV4) then            
        rx_fifo_wr_en_q   <= rx_fifo_wr_en; 
        rx_fifo_data_in_q <= rx_fifo_data_in;        
    end if;
end process;  
  
  
-- rx_fifo_data_swapped <= rx_fifo_data_in(33 downto 32) 
--                         & rx_fifo_data_in(7 downto 0) & rx_fifo_data_in(15 downto 8) & rx_fifo_data_in(23 downto 16) & rx_fifo_data_in(31 downto 24); 
  
port_initalized  <= port_initalized_i; 
mode_sel         <= mode_sel_i;         
mode_0_lane_sel  <= mode_0_lane_sel_i;  
  
port_state <= port_initalized & mode_sel & mode_0_lane_sel;
  
-- RX management / FIFO write process  
process(rst_n, UCLK)  -- _x2
    begin      
    if rst_n = '0'  then                
    
        rx_fifo_wr_en    <= '0';
        word_switch      <= '0';
        started_once     <= '0';
        rx_fifo_data_in  <= (others => '0');    
        -- RXDATA_sr        <= (others => '0');    
        -- RXCHARISK_sr     <= (others => '1');    
        -- RXCHARISvalid_sr <= (others => '0');
        shift_cntr       <= (others => '0');
        
    elsif rising_edge(UCLK) then   
        -- Alternative If-Else Statement 
        if port_initalized = '0' then   -- Port has not been initialized yet
            rx_fifo_wr_en   <= '0';
            rx_fifo_data_in <= (others => '0');            
        else                            -- Port has been initialized            
            -- if mode_sel = '1' then      -- x4 mode is active
                if upper_symbol_valid = '1' and lower_symbol_valid = '1' then
                    rx_fifo_data_in <= upper_symbol_type & RXDATA_u & lower_symbol_type & RXDATA_l;                        
                    rx_fifo_wr_en   <= not(rx_fifo_almost_full);
                elsif upper_symbol_valid = '1' then
                    rx_fifo_data_in <= upper_symbol_type & RXDATA_u & SYMBOL_IDLE & x"00000000";                        
                    rx_fifo_wr_en   <= not(rx_fifo_almost_full);       
                elsif lower_symbol_valid = '1' then
                    rx_fifo_data_in <= SYMBOL_IDLE & x"00000000" & lower_symbol_type & RXDATA_l;                        
                    rx_fifo_wr_en   <= not(rx_fifo_almost_full);
                else                  
                    rx_fifo_wr_en   <= '0';                    
                end if;  
            -- else -- x1 fallback mode is active    
            --     if upper_symbol_valid = '1' and lower_symbol_valid = '1' then
            --         rx_fifo_data_in <= upper_symbol_type & RXDATA_u & lower_symbol_type & RXDATA_l;                        
            --         rx_fifo_wr_en   <= not(rx_fifo_full);
            --     elsif upper_symbol_valid = '1' then
            --         rx_fifo_data_in <= upper_symbol_type & RXDATA_u & SYMBOL_IDLE & RXDATA_l;                        
            --         rx_fifo_wr_en   <= not(rx_fifo_full);       
            --     elsif lower_symbol_valid = '1' then
            --         rx_fifo_data_in <= SYMBOL_IDLE & RXDATA_u & lower_symbol_type & RXDATA_l;                        
            --         rx_fifo_wr_en   <= not(rx_fifo_full);
            --     else                  
            --         rx_fifo_wr_en   <= '0';                    
            --     end if;                  
            -- end if;        
        end if;
    end if;
end process;  
-------------------------------------------------------------------------------------------------------------------------------------------------------

-- -- Pipelining RX stream
-- process(UCLK)  
--     begin  
--     if rising_edge(UCLK) then   
--         RXDATA_swap         <= RXDATA_i(15 downto 0)   & RXDATA_i(31 downto 16)  & RXDATA_i(47 downto 32)  & RXDATA_i(63 downto 48);
--         RXCHARISK_swap      <= RXCHARISK_i(1 downto 0) & RXCHARISK_i(3 downto 2) & RXCHARISK_i(5 downto 4) & RXCHARISK_i(7 downto 6);
--         RXCHARISvalid_swap  <= RXCHARISvalid_i(1 downto 0) & RXCHARISvalid_i(3 downto 2) & RXCHARISvalid_i(5 downto 4) & RXCHARISvalid_i(7 downto 6);
--     end if;
-- end process;  

-- Pipelining RX stream
process(UCLK)  
    begin  
    if rising_edge(UCLK) then   
        
        RXDATA_swap         <= RXDATA_i(15 downto 0)   & RXDATA_i(31 downto 16)  & RXDATA_i(47 downto 32)  & RXDATA_i(63 downto 48);
        RXCHARISK_swap      <= RXCHARISK_i(1 downto 0) & RXCHARISK_i(3 downto 2) & RXCHARISK_i(5 downto 4) & RXCHARISK_i(7 downto 6);
        RXCHARISvalid_swap  <= RXCHARISvalid_i(1 downto 0) & RXCHARISvalid_i(3 downto 2) & RXCHARISvalid_i(5 downto 4) & RXCHARISvalid_i(7 downto 6);        
        
        -- if mode_sel = '1' then      -- x4 mode is active               
        
        -- else                        -- x1 fallback mode is active  
        --     
        --     RXDATA_swap         <= RXDATA_sr_done        ;
        --     RXCHARISK_swap      <= RXCHARISK_sr_done     ;
        --     RXCHARISvalid_swap  <= RXCHARISvalid_sr_done ;
        --     
        -- end if;  
    end if;
end process;  
---                      Lane 0 active                                                  Lane 2 active
RXDATA_R_lane         <= RXDATA_i(15 downto 0)          when mode_0_lane_sel = '0' else RXDATA_i(47 downto 32)       ;  
RXCHARISK_R_lane      <= RXCHARISK_i(1 downto 0)        when mode_0_lane_sel = '0' else RXCHARISK_i(5 downto 4)      ;
RXCHARISvalid_R_lane  <= RXCHARISvalid_i(1 downto 0)    when mode_0_lane_sel = '0' else RXCHARISvalid_i(5 downto 4)  ; 

-- RXDATA shifting process for x1 mode
process(UCLK)  -- _x2  rst_n, 
    begin      
    -- if rst_n = '0'  then                
    -- 
    --     RXDATA_sr              <= (others => '0');    
    --     RXCHARISK_sr           <= (others => '1');    
    --     RXCHARISvalid_sr       <= (others => '0');
    --     valid_byte_cntr        <= (others => '0');
    --     
    --     RXDATA_sr_done         <= (others => '0');
    --     RXCHARISK_sr_done      <= (others => '1');
    --     RXCHARISvalid_sr_done  <= (others => '0');
    --     
    --     done_cntr              <= (others => '0');
    --     rx_done                <= '0';
    --     
    -- els
    if rising_edge(UCLK) then           
    
        if port_initalized = '0' then   -- Port has not been initialized yet
        
            RXDATA_sr              <= (others => '0');    
            RXCHARISK_sr           <= (others => '1');    
            RXCHARISvalid_sr       <= (others => '0');
            valid_byte_cntr        <= (others => '0');
            
            RXDATA_sr_done         <= (others => '0');
            RXCHARISK_sr_done      <= (others => '1');
            RXCHARISvalid_sr_done  <= (others => '0');
            
            done_cntr              <= (others => '0');
            rx_done                <= '0';
            
        else               
            done_cntr <= done_cntr + rx_done;            
            if RXCHARISvalid_R_lane(0) = '1' and (RXCHARISK_R_lane(0) = '0' or (RXCHARISK_R_lane(0) = '1' and (RXDATA_R_lane(7 downto 0) = SC or RXDATA_R_lane(7 downto 0) = PD))) then
                if RXCHARISvalid_R_lane(1) = '1' and (RXCHARISK_R_lane(1) = '0' or (RXCHARISK_R_lane(1) = '1' and (RXDATA_R_lane(15 downto 8) = SC or RXDATA_R_lane(15 downto 8) = PD))) then
                --- [VVVV] It may appear anytime
                    valid_byte_cntr    <= valid_byte_cntr + "10";                    
                    RXDATA_sr          <= RXDATA_sr(55 downto 0)   & RXDATA_R_lane(15 downto 0);
                    RXCHARISK_sr       <= RXCHARISK_sr(6 downto 0) & RXCHARISK_R_lane(1 downto 0);       
                    RXCHARISvalid_sr   <= RXCHARISvalid_sr(6 downto 0) & RXCHARISvalid_R_lane(1 downto 0);  
                    if valid_byte_cntr = "110" then
                        irregular_stream        <= '0';
                        rx_done                 <= '1';
                        done_cntr               <= (others => '0');
                        RXDATA_sr_done          <= RXDATA_sr(47 downto 0)   & RXDATA_R_lane(15 downto 0);
                        RXCHARISK_sr_done       <= RXCHARISK_sr(5 downto 0) & RXCHARISK_R_lane(1 downto 0);       
                        RXCHARISvalid_sr_done   <= RXCHARISvalid_sr(5 downto 0) & RXCHARISvalid_R_lane(1 downto 0);                    
                    elsif valid_byte_cntr = "111" then
                        irregular_stream        <= '1';
                        rx_done                 <= '1';
                        done_cntr               <= (others => '0');
                        RXDATA_sr_done          <= RXDATA_sr(55 downto 0)   & RXDATA_R_lane(15 downto 8);
                        RXCHARISK_sr_done       <= RXCHARISK_sr(6 downto 0) & RXCHARISK_R_lane(1);       
                        RXCHARISvalid_sr_done   <= RXCHARISvalid_sr(6 downto 0) & RXCHARISvalid_R_lane(1);  
                    elsif done_cntr = "11" then   
                        rx_done                 <= '0';                 
                        RXCHARISK_sr_done       <= (others => '1');
                        RXCHARISvalid_sr_done   <= (others => '0');
                    end if;         
                else
                --- [__VV] : It can appear only in the beginning                
                    if valid_byte_cntr = "100" then
                        valid_byte_cntr    <= valid_byte_cntr + '1';    
                    else -- either it is an irregular start or something went wrong
                        valid_byte_cntr    <= "001";
                        irregular_stream   <= '1';
                    end if;
                    RXDATA_sr          <= RXDATA_sr(63 downto 0)   & RXDATA_R_lane(7 downto 0);
                    RXCHARISK_sr       <= RXCHARISK_sr(7 downto 0) & RXCHARISK_R_lane(0);       
                    RXCHARISvalid_sr   <= RXCHARISvalid_sr(7 downto 0) & RXCHARISvalid_R_lane(0);  
                    if done_cntr = "11" then         
                        rx_done                 <= '0';           
                        RXCHARISK_sr_done       <= (others => '1');
                        RXCHARISvalid_sr_done   <= (others => '0');
                    end if; 
                end if;
            else
                if RXCHARISvalid_R_lane(1) = '1' and (RXCHARISK_R_lane(1) = '0' or (RXCHARISK_R_lane(1) = '1' and (RXDATA_R_lane(15 downto 8) = SC or RXDATA_R_lane(15 downto 8) = PD))) then
                --- [VV__] : It can appear only in the end               
                    RXDATA_sr          <= RXDATA_sr(63 downto 0)   & RXDATA_R_lane(15 downto 8);
                    RXCHARISK_sr       <= RXCHARISK_sr(7 downto 0) & RXCHARISK_R_lane(1);       
                    RXCHARISvalid_sr   <= RXCHARISvalid_sr(7 downto 0) & RXCHARISvalid_R_lane(1);   
                    if valid_byte_cntr = "011" then
                        valid_byte_cntr    <= valid_byte_cntr + '1';        
                        irregular_stream   <= '0'; -- irregularity has been compensated for the first symbol
                        if done_cntr = "11" then         
                            rx_done                 <= '0';           
                            RXCHARISK_sr_done       <= (others => '1');
                            RXCHARISvalid_sr_done   <= (others => '0');
                        end if;                     
                    elsif valid_byte_cntr = "111" then -- 2 symbols (2x32b) are done
                        valid_byte_cntr         <= (others => '0');
                        irregular_stream        <= '0'; -- irregularity has been compensated for the second symbol
                        rx_done                 <= '1';
                        done_cntr               <= (others => '0');
                        RXDATA_sr_done          <= RXDATA_sr(55 downto 0)   & RXDATA_R_lane(15 downto 8);
                        RXCHARISK_sr_done       <= RXCHARISK_sr(6 downto 0) & RXCHARISK_R_lane(1);       
                        RXCHARISvalid_sr_done   <= RXCHARISvalid_sr(6 downto 0) & RXCHARISvalid_R_lane(1);  
                    else -- something went wrong
                        valid_byte_cntr    <= (others => '0');
                        irregular_stream   <= '0';           
                        if done_cntr = "11" then         
                            rx_done                 <= '0';           
                            RXCHARISK_sr_done       <= (others => '1');
                            RXCHARISvalid_sr_done   <= (others => '0');
                        end if; 
                    end if; 
                else
                --- [____]
                    if valid_byte_cntr /= "100" then  -- No IDLE allowed, unless between two symbols: Something went wrong probably
                        valid_byte_cntr    <= "000";
                        irregular_stream   <= '0';
                    end if;
                    if done_cntr = "11" then         
                        rx_done                 <= '0';           
                        RXCHARISK_sr_done       <= (others => '1');
                        RXCHARISvalid_sr_done   <= (others => '0');
                    end if;            
                end if;
            end if;    
        end if;    
    end if;    
end process;  

RXDATA_u           <= RXDATA_swap(63 downto 56) & RXDATA_swap(47 downto 40) & RXDATA_swap(31 downto 24) & RXDATA_swap(15 downto  8) when mode_sel = '1' else -- x4 mode 
                      RXDATA_sr_done(63 downto 32);                                                                                                          -- x1 mode 
RXCHARISK_u        <= RXCHARISK_swap(7) & RXCHARISK_swap(5) & RXCHARISK_swap(3) & RXCHARISK_swap(1) when mode_sel = '1' else                                 -- x4 mode 
                      RXCHARISK_sr_done(7 downto 4);                                                                                                         -- x1 mode                     
RXCHARISvalid_u    <= RXCHARISvalid_swap(7) & RXCHARISvalid_swap(5) & RXCHARISvalid_swap(3) & RXCHARISvalid_swap(1) when mode_sel = '1' else                 -- x4 mode 
                      RXCHARISvalid_sr_done(7 downto 4);                                                                                                     -- x1 mode 
RXDATA_l           <= RXDATA_swap(55 downto 48) & RXDATA_swap(39 downto 32) & RXDATA_swap(23 downto 16) & RXDATA_swap(7 downto  0) when mode_sel = '1' else  -- x4 mode 
                      RXDATA_sr_done(31 downto 0);                                                                                                           -- x1 mode 
RXCHARISK_l        <= RXCHARISK_swap(6) & RXCHARISK_swap(4) & RXCHARISK_swap(2) & RXCHARISK_swap(0) when mode_sel = '1' else                                 -- x4 mode 
                      RXCHARISK_sr_done(3 downto 0);                                                                                                         -- x1 mode
RXCHARISvalid_l    <= RXCHARISvalid_swap(6) & RXCHARISvalid_swap(4) & RXCHARISvalid_swap(2) & RXCHARISvalid_swap(0) when mode_sel = '1' else                 -- x4 mode 
                      RXCHARISvalid_sr_done(3 downto 0);                                                                                                     -- x1 mode 

-- RXDATA_u           <= RXDATA_swap(63 downto 56) & RXDATA_swap(47 downto 40) & RXDATA_swap(31 downto 24) & RXDATA_swap(15 downto  8);
-- RXCHARISK_u        <= RXCHARISK_swap(7) & RXCHARISK_swap(5) & RXCHARISK_swap(3) & RXCHARISK_swap(1);
-- RXDATA_l           <= RXDATA_swap(55 downto 48) & RXDATA_swap(39 downto 32) & RXDATA_swap(23 downto 16) & RXDATA_swap(7 downto  0);
-- RXCHARISK_l        <= RXCHARISK_swap(6) & RXCHARISK_swap(4) & RXCHARISK_swap(2) & RXCHARISK_swap(0);                   
-- RXCHARISvalid_u    <= RXCHARISvalid_swap(7) & RXCHARISvalid_swap(5) & RXCHARISvalid_swap(3) & RXCHARISvalid_swap(1);
-- RXCHARISvalid_l    <= RXCHARISvalid_swap(6) & RXCHARISvalid_swap(4) & RXCHARISvalid_swap(2) & RXCHARISvalid_swap(0);

upper_symbol_type  <= SYMBOL_IDLE       when RXCHARISK_u = "1111" and RXCHARISvalid_u = "1111" else  
                      SYMBOL_CONTROL    when RXCHARISK_u = "1000" and RXCHARISvalid_u = "1111" and (RXDATA_u(31 downto 24) = SC or RXDATA_u(31 downto 24) = PD) else    
                      SYMBOL_DATA       when RXCHARISK_u = "0000" and RXCHARISvalid_u = "1111" else    
                      SYMBOL_ERROR;

lower_symbol_type  <= SYMBOL_IDLE       when RXCHARISK_l = "1111" and RXCHARISvalid_l = "1111" else  
                      SYMBOL_CONTROL    when RXCHARISK_l = "1000" and RXCHARISvalid_l = "1111" and (RXDATA_l(31 downto 24) = SC or RXDATA_l(31 downto 24) = PD) else    
                      SYMBOL_DATA       when RXCHARISK_l = "0000" and RXCHARISvalid_l = "1111" else    
                      SYMBOL_ERROR;
                      
-- 
upper_symbol_not_idle   <= '0' when upper_symbol_type = SYMBOL_IDLE  else '1';                   
lower_symbol_not_idle   <= '0' when lower_symbol_type = SYMBOL_IDLE  else '1'; 
upper_symbol_not_error  <= '0' when upper_symbol_type = SYMBOL_ERROR else '1';                   
lower_symbol_not_error  <= '0' when lower_symbol_type = SYMBOL_ERROR else '1'; 

upper_symbol_valid      <= upper_symbol_not_idle and upper_symbol_not_error;
lower_symbol_valid      <= lower_symbol_not_idle and lower_symbol_not_error;


end RTL;
---------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 
-- RapidIO IP Library Core
-- 
-- This file is part of the RapidIO IP library project
-- http://www.opencores.org/cores/rio/
-- 
-- To Do:
-- -
-- 
-- Author(s): 
-- - A. Demirezen, azdem@opencores.org 
-- 
-------------------------------------------------------------------------------
-- 
-- Copyright (C) 2013 Authors and OPENCORES.ORG 
-- 
-- This source file may be used and distributed without 
-- restriction provided that this copyright statement is not 
-- removed from the file and that any derivative work contains 
-- the original copyright notice and the associated disclaimer. 
-- 
-- This source file is free software; you can redistribute it 
-- and/or modify it under the terms of the GNU Lesser General 
-- Public License as published by the Free Software Foundation; 
-- either version 2.1 of the License, or (at your option) any 
-- later version. 
-- 
-- This source is distributed in the hope that it will be 
-- useful, but WITHOUT ANY WARRANTY; without even the implied 
-- warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR 
-- PURPOSE. See the GNU Lesser General Public License for more 
-- details. 
-- 
-- You should have received a copy of the GNU Lesser General 
-- Public License along with this source; if not, download it 
-- from http://www.opencores.org/lgpl.shtml 
-- 
------------------------------------------------------------------------------
------------------------------------------------------------------------------
--
-- File name:    pcs_tx_controller.vhd
-- Rev:          0.0
-- Description:  This entity controls the TX stream 
--               
-- 
------------------------------------------------------------------------------
------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use work.rio_common.all;

entity pcs_tx_controller is
  generic (
    TCQ         : time      := 100 ps
  );
  port ( 
    rst_n                   : in  std_logic;
    rio_clk                 : in  std_logic;  -- ~150 MHz
    UCLK_x2                 : in  std_logic;  --  312,5 MHz
    UCLK                    : in  std_logic;  --  156,25 MHz 
    UCLK_x2_DV2             : in  std_logic;  --  312,5 MHz @ x4 mode / 78,125 @ x1 (fallback mode) 
    UCLK_or_DV4             : in  std_logic;  --  156,25 MHz @ x4 mode / 39,0625 @ x1 (fallback mode)
    --
    -- Interface to the RioSerial
    outboundWrite_i         : in  std_logic;
    outboundFull_o          : out std_logic;
    outboundSymbol_i        : in  std_logic_vector(33 downto 0);
    -- outboundSymbolEmpty_i   : in  std_logic;
    -- outboundSymbolRead_o    : out std_logic;
    -- outboundSymbol_i        : in  std_logic_vector(33 downto 0);
    --
    -- Interface to the GTX transceivers
    TXDATA_o                : out std_logic_vector(63 downto 0);  -- N = 4
    TXCHARISK_o             : out std_logic_vector(7 downto 0);
    --
    -- Interface to the other blocks
    send_ccs_i              : in  std_logic;    
    ccs_timer_rst_o         : out std_logic;    
    send_idle_o             : out std_logic_vector(1 downto 0);    
    send_K_i                : in  std_logic_vector(1 downto 0);    
    send_A_i                : in  std_logic_vector(1 downto 0);    
    send_R_i                : in  std_logic_vector(1 downto 0);
    --
    -- Interface to the port init
    TXINHIBIT_02            : in  std_logic;
    TXINHIBIT_others        : in  std_logic;
    port_initalized_i       : in  std_logic;
    mode_sel_i              : in  std_logic;
    mode_0_lane_sel_i       : in  std_logic
    
  );
end pcs_tx_controller;

architecture RTL of pcs_tx_controller is
    
-------------------------------------------------------------------------------
COMPONENT pcs_tx_boudary_32b_in_64b_out
    PORT (
    rst          : IN STD_LOGIC;
    wr_clk       : IN STD_LOGIC;
    rd_clk       : IN STD_LOGIC;
    din          : IN STD_LOGIC_VECTOR(33 DOWNTO 0);
    wr_en        : IN STD_LOGIC;
    rd_en        : IN STD_LOGIC;
    dout         : OUT STD_LOGIC_VECTOR(67 DOWNTO 0);
    full         : OUT STD_LOGIC;
    empty        : OUT STD_LOGIC;
    almost_empty : out STD_LOGIC; 
    almost_full  : out STD_LOGIC;
    valid        : OUT STD_LOGIC
  );
END COMPONENT;
-------------------------------------------------------------------------------
-- COMPONENT pcs_tx_boudary_32b_v2
--     PORT (
--     rst            : IN STD_LOGIC;
--     wr_clk         : IN STD_LOGIC;
--     rd_clk         : IN STD_LOGIC;
--     din            : IN STD_LOGIC_VECTOR(33 DOWNTO 0);
--     wr_en          : IN STD_LOGIC;
--     rd_en          : IN STD_LOGIC;
--     dout           : OUT STD_LOGIC_VECTOR(33 DOWNTO 0);
--     full           : OUT STD_LOGIC;
--     empty          : OUT STD_LOGIC;
--     almost_empty   : OUT STD_LOGIC;
--     valid          : OUT STD_LOGIC
--   );
-- END COMPONENT;
-------------------------------------------------------------------------------
signal rst                  : std_logic:= '0';
signal fragment_counter     : std_logic_vector(9 downto 0)  := (others => '0');
signal outboundSymbolType   : std_logic_vector(1 downto 0)  := (others => '0');
signal outboundSymbol       : std_logic_vector(33 downto 0) := (others => '0');
signal outboundSymbolRead   : std_logic:= '0';
signal non_idle             : std_logic:= '0';
signal decrement_frag_cntr  : std_logic:= '0';

signal tx_fifo_full         : std_logic:= '0';
signal symbol_empty         : std_logic:= '0';
signal symbol_almost_empty  : std_logic:= '0';
signal symbol_read          : std_logic:= '0';
signal symbol_valid         : std_logic:= '0';
-- signal symbol               : std_logic_vector(33 downto 0) := (others => '0');
signal symbol               : std_logic_vector(67 downto 0) := (others => '0');
signal symbol_u             : std_logic_vector(33 downto 0) := (others => '0');
signal symbol_l             : std_logic_vector(33 downto 0) := (others => '0');
-- signal symbol_type          : std_logic_vector(1  downto 0) := (others => '0');
signal symbol_type          : std_logic_vector(3  downto 0) := (others => '0');
signal symbol_type_u        : std_logic_vector(1  downto 0) := (others => '0');
signal symbol_type_l        : std_logic_vector(1  downto 0) := (others => '0');

signal TXDATA               : std_logic_vector(63 downto 0);  -- N = 4
signal TXCHARISK            : std_logic_vector(7 downto 0);
signal TXDATA_u             : std_logic_vector(31 downto 0); 
signal TXCHARISK_u          : std_logic_vector(3 downto 0);
signal TXDATA_l             : std_logic_vector(31 downto 0); 
signal TXCHARISK_l          : std_logic_vector(3 downto 0);

signal TXDATA_u_idle        : std_logic_vector(31 downto 0); 
signal TXDATA_l_idle        : std_logic_vector(31 downto 0); 
    
signal word_switch          : std_logic:= '0';
signal lane_switch          : std_logic_vector(1  downto 0) := (others => '0');
signal cycle_switch         : std_logic_vector(1  downto 0) := (others => '0');
signal read_switch          : std_logic_vector(1  downto 0) := (others => '0');
    
signal send_idle_q          : std_logic:= '0';
signal send_idle_reg        : std_logic_vector(1 downto 0)  := (others => '0');
signal send_idle            : std_logic_vector(1 downto 0)  := (others => '0');
signal idle_char_type_0     : std_logic_vector(2  downto 0) := (others => '0');
signal idle_char_type_1     : std_logic_vector(2  downto 0) := (others => '0');

signal send_ccs_cntr        : std_logic_vector(1  downto 0) := (others => '0');
signal send_K               : std_logic_vector(1 downto 0)  := (others => '0');
signal send_A               : std_logic_vector(1 downto 0)  := (others => '0');
signal send_R               : std_logic_vector(1 downto 0)  := (others => '0');
signal send_ccs             : std_logic:= '0';
signal send_ccs_q           : std_logic:= '0';
signal do_not_interrupt     : std_logic:= '0';

signal be_silent              : std_logic:= '0';
signal fifo_wr_selective      : std_logic:= '0';
signal fifo_wr_selective_q    : std_logic:= '0';
signal fifo_wr_always_even    : std_logic:= '0';
signal fifo_wr_odd_or_even    : std_logic:= '0';
signal fifo_wr_evenly         : std_logic:= '0';
signal outboundSymbolisData   : std_logic:= '0';
signal outboundSymbolisData_q : std_logic:= '0';

signal outboundSymbol_q       : std_logic_vector(33 downto 0) := (others => '0');
signal fifo_wr_evenly_q       : std_logic:= '0';
-- signal send_K_ccs           : std_logic:= '0';
-- signal send_R_ccs           : std_logic:= '0';
-- signal send_K_q             : std_logic:= '0';
-- signal send_A_q             : std_logic:= '0';
-- signal send_R_q             : std_logic:= '0';
----------------------------------------------------------------------------------
begin
-- 
rst                  <= not(rst_n);

outboundSymbolType  <= outboundSymbol_i(33 downto 32);
-- Filtering the ERROR symbol out
outboundSymbol      <= outboundSymbol_i when (outboundSymbolType = SYMBOL_DATA or outboundSymbolType = SYMBOL_CONTROL) else 
                       SYMBOL_IDLE & outboundSymbol_i(31 downto 0);    

fifo_wr_selective   <= outboundWrite_i when (outboundSymbolType = SYMBOL_DATA or outboundSymbolType = SYMBOL_CONTROL) else '0';

fifo_wr_always_even <= fifo_wr_selective or (fifo_wr_selective_q and fifo_wr_odd_or_even);

outboundSymbolisData <= '1' when outboundSymbolType = SYMBOL_DATA else '0';

fifo_wr_evenly  <= fifo_wr_selective or (fifo_wr_selective_q and fifo_wr_odd_or_even and not(outboundSymbolisData_q));

-- Writing to the FIFO
process(rio_clk)
    begin    
    if rising_edge(rio_clk) then 
        fifo_wr_selective_q     <= fifo_wr_selective;
        outboundSymbolisData_q  <= outboundSymbolisData;
        if fifo_wr_selective    = '1' then
            fifo_wr_odd_or_even <= not(fifo_wr_odd_or_even);
        elsif fifo_wr_selective_q = '1' then
            fifo_wr_odd_or_even <= fifo_wr_odd_or_even and outboundSymbolisData_q; -- '0';
        end if;        
        
        outboundSymbol_q <= outboundSymbol;
        fifo_wr_evenly_q <= fifo_wr_evenly;
    end if;
end process;

send_K <= send_K_i;  
send_A <= send_A_i;         
send_R <= send_R_i;  

-- idle_char_type  <= send_K & send_A & send_R;
idle_char_type_0  <= send_K(0) & send_A(0) & send_R(0);
idle_char_type_1  <= send_K(1) & send_A(1) & send_R(1);

be_silent   <= '1' when TXINHIBIT_02 = '1' and TXINHIBIT_others = '1' else '0';

-- symbol_type <= symbol(33 downto 32);  
symbol_type_u <= symbol_u(33 downto 32);  
symbol_type_l <= symbol_l(33 downto 32);  

symbol_u      <= symbol(67 downto 34);  
symbol_l      <= symbol(33 downto 0);  

send_idle(1)   <= '1'  when (send_ccs = '0')  and 
                         ((symbol_read = '1' and symbol_type_u = SYMBOL_IDLE) or 
                          (symbol_read = '0') or 
                          (port_initalized_i = '0')) 
                        else 
                  '0';                

send_idle(0)   <= '1'  when (send_ccs = '0')  and 
                         ((symbol_read = '1' and symbol_type_l = SYMBOL_IDLE) or 
                          (symbol_read = '0') or 
                          (port_initalized_i = '0')) 
                       else 
                  '0'; 
 
send_idle_o <= send_idle; -- _reg; 

-- symbol_read <= not(symbol_empty) and not(send_ccs) and not(send_ccs_q);

-- Pipelining
process(UCLK) -- _x2
    begin    
    if rising_edge(UCLK) then 
        send_ccs        <= not(do_not_interrupt) and send_ccs_i;  -- will be high only during real CCS transmission 
        -- send_idle_reg   <= send_idle;        
    end if;
end process;

-- Reading from the FIFO
process(UCLK_or_DV4) -- UCLK_x2_DV2
    begin    
    if rising_edge(UCLK_or_DV4) then 
      --   case symbol_read is
      --       when '0' => 
      --           symbol_read <= not(symbol_empty) and not(send_ccs) and not(send_ccs_q); -- after TCQ;                
      --       when '1' => 
      --           symbol_read <= not(symbol_almost_empty); -- after TCQ; -- and not(send_ccs) and not(send_ccs_q);                
      --       when others => 
      --           symbol_read <= '0'; -- after TCQ;
      --   end case;        
        
    end if;
end process;

tx_boundary_fifo : pcs_tx_boudary_32b_in_64b_out   -- FWFT FIFO
  PORT MAP (
    rst             => rst,
            
    wr_clk          => rio_clk,
    wr_en           => fifo_wr_evenly_q, --fifo_wr_always_even, --outboundWrite_i,
    din             => outboundSymbol_q,
    full            => open, -- outboundFull_o,
    almost_full     => outboundFull_o,
            
    rd_clk          => UCLK_or_DV4,
    rd_en           => symbol_read,
    dout            => symbol,
    empty           => symbol_empty,
    almost_empty    => symbol_almost_empty,
    valid           => symbol_valid
  ); 

-- FIFO read / TX output process
process(rst_n, UCLK) -- UCLK_x2
    begin    
    if rst_n = '0'  then         
    
        ccs_timer_rst_o  <= '0'; 
        do_not_interrupt <= '0';
        TXDATA_u         <= (others => '0');
        TXCHARISK_u      <= (others => '0');
        TXDATA_l         <= (others => '0');
        TXCHARISK_l      <= (others => '0');    
        cycle_switch     <= (others => '0');   
        read_switch      <= (others => '0');   
        symbol_read      <= '0';
        
    elsif rising_edge(UCLK) then 
    
      if be_silent = '0' then -- Transmitters are NOT inhibitied
        if send_ccs = '1' or send_ccs_q = '1' then -- Transmitting the clock compensation sequence (ccs) = |K|,|R|,|R|,|R|
            symbol_read      <= '0';
            if send_ccs_q = '0' then
                TXDATA_u        <= K_column;
                TXCHARISK_u     <= (others => '1');
                TXDATA_l        <= R_column;
                TXCHARISK_l     <= (others => '1');              
                ccs_timer_rst_o <= '1';
            else
                TXDATA_u        <= R_column;
                TXCHARISK_u     <= (others => '1');
                TXDATA_l        <= R_column;
                TXCHARISK_l     <= (others => '1');                          
            end if;
        else  -- Transmitting the IDLE sequence or the CONTROL/DATA symbols 
            
            read_switch  <= read_switch + '1'; 
            if read_switch = "00" then
                case symbol_read is
                    when '0' => 
                        symbol_read         <= not(symbol_empty); -- and not(send_ccs) and not(send_ccs_q); -- after TCQ; 
                        do_not_interrupt    <= not(symbol_empty);               
                    when '1' => 
                        symbol_read         <= not(symbol_almost_empty); -- after TCQ; -- and not(send_ccs) and not(send_ccs_q);        
                        do_not_interrupt    <= not(symbol_almost_empty);                       
                    when others => 
                        symbol_read         <= '0'; -- after TCQ;
                        do_not_interrupt    <= '0'; 
                end case;  
            end if;
            
            ccs_timer_rst_o <= '0';                                   
            if symbol_read = '1' then -- two symbols have been read, at least one of them is non-idle, they should be forwarded in 1 or 4 cycles
                case mode_sel_i is
                    when '1' => -- Lane stripping (x4 mode: rd_clk = UCLK)     
                        case symbol_type_u is                
                            when SYMBOL_DATA =>      
                                TXDATA_u      <= symbol_u(31 downto 24) & symbol_u(23 downto 16) & symbol_u(15 downto 8) & symbol_u(7 downto 0);
                                TXCHARISK_u   <= (others => '0');                                 
                            when SYMBOL_CONTROL => 
                                TXDATA_u      <= symbol_u(31 downto 24) & symbol_u(23 downto 16) & symbol_u(15 downto 8) & symbol_u(7 downto 0);
                                TXCHARISK_u   <= "1000";                                        
                            when SYMBOL_IDLE =>     
                                TXDATA_u      <= TXDATA_u_idle;
                                TXCHARISK_u   <= (others => '1');                                 
                            when others =>   
                                -- dummy
                                TXDATA_u      <= TXDATA_u_idle;
                                TXCHARISK_u   <= (others => '1');   
                        end case;  
                        case symbol_type_l is                
                            when SYMBOL_DATA =>      
                                TXDATA_l      <= symbol_l(31 downto 24) & symbol_l(23 downto 16) & symbol_l(15 downto 8) & symbol_l(7 downto 0);
                                TXCHARISK_l   <= (others => '0');                                 
                            when SYMBOL_CONTROL => 
                                TXDATA_l      <= symbol_l(31 downto 24) & symbol_l(23 downto 16) & symbol_l(15 downto 8) & symbol_l(7 downto 0);
                                TXCHARISK_l   <= "1000";                                        
                            when SYMBOL_IDLE =>     
                                TXDATA_l      <= TXDATA_l_idle;
                                TXCHARISK_l   <= (others => '1');                                 
                            when others =>   
                                -- dummy
                                TXDATA_l      <= TXDATA_l_idle;
                                TXCHARISK_l   <= (others => '1');   
                        end case;                               
                    when '0' => -- Slow motion read (x1 mode: rd_clk = UCLK_DV4)
                        cycle_switch    <= cycle_switch + '1'; 
                        -- Cycle | Symbol part to be sent  
                        ---------|----------------------
                        --   00  | symbol_u(31 downto 16)
                        --   01  | symbol_u(15 downto 0)
                        --   10  | symbol_l(31 downto 16)
                        --   11  | symbol_l(15 downto 0)
                        case cycle_switch(1) is
                            when '0' =>
                                case cycle_switch(0) is
                                    when '0' => --   00 
                                        if symbol_type_u /= SYMBOL_IDLE then 
                                            TXDATA_u        <= symbol_u(31 downto 24) & symbol_u(31 downto 24) & symbol_u(31 downto 24) & symbol_u(31 downto 24);
                                            if symbol_type_u = SYMBOL_DATA then 
                                                TXCHARISK_u     <= (others => '0');
                                            else -- if symbol_type_u = SYMBOL_CONTROL then 
                                                TXCHARISK_u     <= (others => '1');
                                            end if;
                                            TXDATA_l        <= symbol_u(23 downto 16) & symbol_u(23 downto 16) & symbol_u(23 downto 16) & symbol_u(23 downto 16);
                                            TXCHARISK_l     <= (others => '0');  
                                        else -- if symbol_type_u = SYMBOL_IDLE then                                         
                                            TXDATA_u      <= TXDATA_u_idle;
                                            TXCHARISK_u   <= (others => '1');  
                                            TXDATA_l      <= TXDATA_l_idle;
                                            TXCHARISK_l   <= (others => '1');                                            
                                        end if;                                        
                                    when '1' => --   01  
                                        if symbol_type_u /= SYMBOL_IDLE then 
                                            TXDATA_u        <= symbol_u(15 downto 8) & symbol_u(15 downto 8) & symbol_u(15 downto 8) & symbol_u(15 downto 8);
                                            TXCHARISK_u     <= (others => '0'); -- This is the second part: does not matter control or data
                                            TXDATA_l        <= symbol_u(7 downto 0) & symbol_u(7 downto 0) & symbol_u(7 downto 0) & symbol_u(7 downto 0);
                                            TXCHARISK_l     <= (others => '0');  
                                        else -- if symbol_type_u = SYMBOL_IDLE then                                         
                                            TXDATA_u      <= TXDATA_u_idle;
                                            TXCHARISK_u   <= (others => '1');  
                                            TXDATA_l      <= TXDATA_l_idle;
                                            TXCHARISK_l   <= (others => '1');                                            
                                        end if;                                        
                                    when others =>   
                                    -- dummy
                                end case;                                  
                            when '1' =>
                                case cycle_switch(0) is
                                    when '0' =>
                                        if symbol_type_l /= SYMBOL_IDLE then 
                                            TXDATA_u        <= symbol_l(31 downto 24) & symbol_l(31 downto 24) & symbol_l(31 downto 24) & symbol_l(31 downto 24);
                                            if symbol_type_l = SYMBOL_DATA then 
                                                TXCHARISK_u     <= (others => '0');
                                            else -- if symbol_type_l = SYMBOL_CONTROL then 
                                                TXCHARISK_u     <= (others => '1');
                                            end if;
                                            TXDATA_l        <= symbol_l(23 downto 16) & symbol_l(23 downto 16) & symbol_l(23 downto 16) & symbol_l(23 downto 16);
                                            TXCHARISK_l     <= (others => '0');  
                                        else -- if symbol_type_l = SYMBOL_IDLE then                                         
                                            TXDATA_u      <= TXDATA_u_idle;
                                            TXCHARISK_u   <= (others => '1');  
                                            TXDATA_l      <= TXDATA_l_idle;
                                            TXCHARISK_l   <= (others => '1');                                            
                                        end if;                                        
                                    when '1' =>
                                        if symbol_type_l /= SYMBOL_IDLE then 
                                            TXDATA_u        <= symbol_l(15 downto 8) & symbol_l(15 downto 8) & symbol_l(15 downto 8) & symbol_l(15 downto 8);
                                            TXCHARISK_u     <= (others => '0'); -- This is the second part: does not matter control or data
                                            TXDATA_l        <= symbol_l(7 downto 0) & symbol_l(7 downto 0) & symbol_l(7 downto 0) & symbol_l(7 downto 0);
                                            TXCHARISK_l     <= (others => '0');  
                                        else -- if symbol_type_l = SYMBOL_IDLE then                                         
                                            TXDATA_u      <= TXDATA_u_idle;
                                            TXCHARISK_u   <= (others => '1');  
                                            TXDATA_l      <= TXDATA_l_idle;
                                            TXCHARISK_l   <= (others => '1');                                            
                                        end if;                                        
                                    when others =>   
                                    -- dummy
                                end case;                                                                  
                            when others =>   
                                -- dummy
                        end case;  
                        
                    when others =>           
                        -- dummy
                end case;  
            -----------------------------------------------------------------------------
            else -- No Symbols are present at the FIFO output: Transmitting an idle sequence: |K| or |A| or |R|
                TXDATA_u         <= TXDATA_u_idle;
                TXCHARISK_u      <= (others => '1'); 
                TXDATA_l         <= TXDATA_l_idle;
                TXCHARISK_l      <= (others => '1');     
            end if;
        end if;  
      else -- Transmitters are inhibitied
        TXDATA_u         <= x"BCBCBCBC"    ;
        TXCHARISK_u      <= (others => '1');
        TXDATA_l         <= x"FDFDFDFD"    ;
        TXCHARISK_l      <= (others => '1');  
      end if;
    end if;
end process;

-- Combinational idle drive process
process(idle_char_type_0, idle_char_type_1)
    begin  
    case idle_char_type_1 is                 
        when "100" =>  -- |K| (~%50)
            TXDATA_u_idle      <= K_column;
            
        when "010" => -- |A| (1/16 .. 1/32)
            TXDATA_u_idle      <= A_column; 
            
        when "001" => -- |R| (~%50)
            TXDATA_u_idle      <= R_column;
            
        when others =>
            -- dummy
            TXDATA_u_idle      <= K_column;                         
    end case;                 
    case idle_char_type_0 is                 
        when "100" =>  -- |K| (~%50)
            TXDATA_l_idle      <= K_column;
            
        when "010" => -- |A| (1/16 .. 1/32)
            TXDATA_l_idle      <= A_column; 
            
        when "001" => -- |R| (~%50)
            TXDATA_l_idle      <= R_column;
            
        when others =>
            -- dummy
            TXDATA_l_idle      <= R_column;                           
    end case; 
end process; 

-- TXDATA buffering by UCLK
process(UCLK)
    begin    
    if rising_edge(UCLK) then     
        ------------------
        -- MUST BE SWAPPED
        TXDATA_o    <=   TXDATA_u( 7 downto  0) & TXDATA_l( 7 downto  0) & TXDATA_u(15 downto  8) & TXDATA_l(15 downto  8)
                       & TXDATA_u(23 downto 16) & TXDATA_l(23 downto 16) & TXDATA_u(31 downto 24) & TXDATA_l(31 downto 24);   
        TXCHARISK_o <= TXCHARISK_u(0) & TXCHARISK_l(0) & TXCHARISK_u(1) & TXCHARISK_l(1) & TXCHARISK_u(2) & TXCHARISK_l(2) & TXCHARISK_u(3) & TXCHARISK_l(3);
        ------------------
    end if;
end process; 

-- Delaying send_ccs  
process(UCLK)
    begin    
    if rising_edge(UCLK) then     
        if be_silent = '0' then 
            send_ccs_q <= send_ccs; ---  
        else 
            send_ccs_q <= '0';
        end if;
    end if;
end process; 

end RTL;
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 
-- RapidIO IP Library Core
-- 
-- This file is part of the RapidIO IP library project
-- http://www.opencores.org/cores/rio/
-- 
-- To Do:
-- -
-- 
-- Author(s): 
-- - A. Demirezen, azdem@opencores.org 
-- 
-------------------------------------------------------------------------------
-- 
-- Copyright (C) 2013 Authors and OPENCORES.ORG 
-- 
-- This source file may be used and distributed without 
-- restriction provided that this copyright statement is not 
-- removed from the file and that any derivative work contains 
-- the original copyright notice and the associated disclaimer. 
-- 
-- This source file is free software; you can redistribute it 
-- and/or modify it under the terms of the GNU Lesser General 
-- Public License as published by the Free Software Foundation; 
-- either version 2.1 of the License, or (at your option) any 
-- later version. 
-- 
-- This source is distributed in the hope that it will be 
-- useful, but WITHOUT ANY WARRANTY; without even the implied 
-- warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR 
-- PURPOSE. See the GNU Lesser General Public License for more 
-- details. 
-- 
-- You should have received a copy of the GNU Lesser General 
-- Public License along with this source; if not, download it 
-- from http://www.opencores.org/lgpl.shtml 
-- 
------------------------------------------------------------------------------
------------------------------------------------------------------------------
--
-- File name:    port_init_fsms.vhd
-- Rev:          0.0
-- Description:  This entity does the 1x/Nx port init according to the 
--               RIO Sepec. Part-6, subchapter 4.2
-- 
------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use work.rio_common.all;
--use work.rio_common_sim.all;

entity port_init_fsms is
  generic (
    TCQ         : time      := 100 ps
  );
  port ( 
    rst_n               : in  std_logic;
    UCLK_x2             : in  std_logic;
    UCLK                : in  std_logic;
    UCLK_DV4            : in  std_logic; 
    UCLK_DV_1024        : in  std_logic;   
    
    force_reinit        : in  std_logic:='0';   -- force retraining
    mode_sel            : out std_logic;        -- 0: x1 fallback mode / 1: xN Mode
    mode_0_lane_sel     : out std_logic;        -- If mode_sel = 0 then 0: Lane 0 is active(R), 1: Lane 2 is active else don't care
    port_initalized     : out std_logic;        -- 1: Port initialization is successfully complete
    lane_sync           : out std_logic_vector(N-1 downto 0); -- Lane is synchoronised
    RXCHARISvalid       : out std_logic_vector(N*2-1 downto 0);
    
    -- GTXRESET            : out std_logic;
    TXINHIBIT_02        : out std_logic;
    TXINHIBIT_others    : out std_logic;
    ENCHANSYNC          : out std_logic;
    -- TXDATA              : out std_logic_vector(N*16-1 downto 0);
    -- TXCHARISK           : out std_logic_vector(N*2-1 downto 0);
    PLLLKDET            : in  std_logic;
    RXDATA              : in  std_logic_vector(N*16-1 downto 0);
    RXCHARISK           : in  std_logic_vector(N*2-1 downto 0);
    RXCHARISCOMMA       : in  std_logic_vector(N*2-1 downto 0);
    RXBYTEISALIGNED     : in  std_logic_vector(N-1 downto 0);
    RXBYTEREALIGN       : in  std_logic_vector(N-1 downto 0);
    RXELECIDLE          : in  std_logic_vector(N-1 downto 0);
    RXDISPERR           : in  std_logic_vector(N*2-1 downto 0);
    RXNOTINTABLE        : in  std_logic_vector(N*2-1 downto 0);
    RXBUFERR            : in  std_logic;
    RXBUFRST            : out std_logic;
    CHBONDDONE          : in  std_logic_vector(N-1 downto 0)
  );
end port_init_fsms;

architecture rtl of port_init_fsms is
-------------------------------------------------------------------------------------------------------------------------------------------
-- Lane_Synchronization State Machine 
type lane_sync_states is (NO_SYNC, NO_SYNC_1, NO_SYNC_2, NO_SYNC_2a, NO_SYNC_2b, NO_SYNC_3, SYNC, SYNCa, SYNCb, SYNC_1, SYNC_2, SYNC_2a, SYNC_2b, SYNC_3, SYNC_4);
type lane_sync_states_array is array (N-1 downto 0) of lane_sync_states;

signal lane_sync_state_n : lane_sync_states_array           := (others => NO_SYNC);
signal lane_sync_n       : std_logic_vector(N-1 downto 0)   := (others => '0');
signal Kcounter_n        : Kcounter_array_type              := (others => (others => '0'));
signal Vcounter_n        : Vcounter_array_type              := (others => (others => '0'));
signal Icounter_n        : Icounter_array_type              := (others => (others => '0'));
signal code_group_valid  : std_logic_vector(N*2-1 downto 0) := (others => '0');
-------------------------------------------------------------------------------------------------------------------------------------------
-- Lane_Alignment State Machine
type lane_alignment_states is (NOT_ALIGNED, NOT_ALIGNED_1, NOT_ALIGNED_2, ALIGNED, ALIGNED_1, ALIGNED_2, ALIGNED_3);

signal lane_alignment_state : lane_alignment_states          := NOT_ALIGNED;
signal N_lanes_aligned      : std_logic                      := '0';
signal Acounter             : std_logic_vector(2 downto 0)   := (others => '0');
signal Mcounter             : Mcounter_type                  := (others => '0');
signal lane_alignment_reset : std_logic                      := '0';
signal N_lane_sync          : std_logic                      := '0';
constant N_lanes_all_high   : std_logic_vector(N-1 downto 0) := (others => '1');
constant N_lanes_all_low    : std_logic_vector(N-1 downto 0) := (others => '0');

signal A_column_valid       : std_logic := '0';
signal align_error          : std_logic := '0';
signal A_column_valid_upper : std_logic := '0';
signal align_error_upper    : std_logic := '0';
signal A_column_valid_lower : std_logic := '0';
signal align_error_lower    : std_logic := '0';

signal RXCHARIS_A_upper     : std_logic_vector(N-1 downto 0) := (others => '0');
signal RXCHARIS_A_lower     : std_logic_vector(N-1 downto 0) := (others => '0');
-------------------------------------------------------------------------------------------------------------------------------------------
-- begin --dummy   
-- 1x/Nx Mode Init State Machine
type mode_init_states is (SILENT, SEEK, DISCOVERY, x1_RECOVERY, Nx_MODE, x1_MODE_LANE0, x1_MODE_LANE2);

signal mode_init_state      : mode_init_states          := SILENT;
signal lanes02_drvr_oe      : std_logic := '0';
signal N_lanes_drvr_oe      : std_logic := '0';
signal Nx_mode_active       : std_logic := '0';
signal receive_lane2        : std_logic := '0';
signal force_reinit_reg     : std_logic := '0';
signal force_reinit_clear   : std_logic := '0';

signal silence_timer_en     : std_logic := '0';
signal silence_timer_done   : std_logic := '0';
signal silence_timer        : std_logic_vector(4 downto 0)   := (others => '0');

signal disc_tmr_en          : std_logic := '0';
signal disc_tmr_done        : std_logic := '0';
signal disc_tmr             : std_logic_vector(15 downto 0)   := (others => '0'); 

signal port_initalized_reg  : std_logic := '0';

signal idle_selected        : std_logic := '1'; -- Only IDLE1 is to be used
signal Nx_mode_enabled      : std_logic := '1'; -- Nx mode is to be always enabled
signal force_1x_mode        : std_logic := '0'; -- don't force 1x mode
signal force_laneR          : std_logic := '0'; -- don't care, when force_1x_mode = 0

signal lane_ready_n         : std_logic_vector(N-1 downto 0)   := (others => '0');
signal rcvr_trained_n       : std_logic_vector(N-1 downto 0)   := (others => '0');
signal N_lanes_ready        : std_logic := '0';

signal rxbufrst_cntr        : std_logic_vector(2 downto 0)   := (others => '0');
signal rxbuferr_reg         : std_logic := '0';
-------------------------------------------------------------------------------------------------------------------------------------------
begin

lane_sync <= lane_sync_n;
----------------------------------------------------------------
-- Figure 4-14. Lane_Synchronization State Machine for N Lanes
GEN_LANE_SYNC_FSM: for i in 0 to N-1 generate
    
code_group_valid(i*2)   <= not(RXNOTINTABLE(i*2)  ) and not(RXDISPERR(i*2)  );
code_group_valid(i*2+1) <= not(RXNOTINTABLE(i*2+1)) and not(RXDISPERR(i*2+1)); 

RXCHARISvalid(i*2)    <= code_group_valid(i*2)  ;
RXCHARISvalid(i*2+1)  <= code_group_valid(i*2+1);

process(rst_n, UCLK)  -- (UCLK_x2) -- 
    begin
    
    if rst_n = '0'  then
    
        lane_sync_state_n(i) <= NO_SYNC;
        lane_sync_n(i)       <= '0';      
        Kcounter_n(i)        <= (others => '0');       
        Vcounter_n(i)        <= (others => '0');    
        
    elsif rising_edge(UCLK) then
    
        case lane_sync_state_n(i) is
            when NO_SYNC => 
                -- change(signal_detect[n])
                if RXELECIDLE(i) = '1' then
                    lane_sync_n(i)       <= '0';      
                    Kcounter_n(i)        <= (others => '0');       
                    Vcounter_n(i)        <= (others => '0'); 
                -- signal_detect[n] & /COMMA/   [ KK-- ] : /K/ is being detected at the upper half
                elsif (code_group_valid(i*2+1) = '1' and RXCHARISCOMMA(i*2+1) = '1') then
                    -- signal_detect[n] & /COMMA/   [ --KK ] :  /K/ is being detected also at the lower half
                    if (code_group_valid(i*2) = '1' and RXCHARISCOMMA(i*2) = '1') then                         
                        lane_sync_state_n(i) <= NO_SYNC_2;               
                        Kcounter_n(i)        <= Kcounter_n(i) + "10";       
                        Vcounter_n(i)        <= Vcounter_n(i) + "10";
                    -- signal_detect[n]         [ --VV ] :  At the lower half: no comma, but valid 
                    elsif (code_group_valid(i*2) = '1') then
                        lane_sync_state_n(i) <= NO_SYNC_2;               
                        Kcounter_n(i)        <= Kcounter_n(i) + '1';       
                        Vcounter_n(i)        <= Vcounter_n(i) + "10";   
                    -- do nothing                     
                    else
                        lane_sync_n(i)       <= '0';      
                        Kcounter_n(i)        <= (others => '0');       
                        Vcounter_n(i)        <= (others => '0');    
                    end if;           
                ----------------------------------------------------------------------------------------------    
                -- signal_detect[n] & /COMMA/   [ --KK ] :  /K/ is being detected only at the lower half
                elsif (code_group_valid(i*2) = '1' and RXCHARISCOMMA(i*2) = '1') then                     
                    lane_sync_state_n(i) <= NO_SYNC_2;               
                    Kcounter_n(i)        <= Kcounter_n(i) + '1';       
                    Vcounter_n(i)        <= Vcounter_n(i) + '1';                       
                ----------------------------------------------------------------------------------------------    
                -- !signal_detect[n] | !/COMMA/ 
                else
                    lane_sync_n(i)       <= '0';      
                    Kcounter_n(i)        <= (others => '0');       
                    Vcounter_n(i)        <= (others => '0');                     
                end if;
                -- -- change(signal_detect[n])
                -- if RXELECIDLE(i) = '1' then
                --     lane_sync_n(i)       <= '0';      
                --     Kcounter_n(i)        <= (others => '0');       
                --     Vcounter_n(i)        <= (others => '0'); 
                -- -- signal_detect[n] & /COMMA/   [ KK-- ] : /K/ is being detected at the upper half
                -- elsif (code_group_valid(i*2+1) = '1' and RXCHARISCOMMA(i*2+1) = '1') then
                --     lane_sync_state_n(i) <= NO_SYNC_2a;               
                --     Kcounter_n(i)        <= Kcounter_n(i) + '1';       
                --     Vcounter_n(i)        <= Vcounter_n(i) + '1';                    
                -- -- signal_detect[n] & /COMMA/   [ --KK ] :  /K/ is being detected at the lower half
                -- elsif (code_group_valid(i*2) = '1' and RXCHARISCOMMA(i*2) = '1') then 
                --     lane_sync_state_n(i) <= NO_SYNC_2b;               
                --     Kcounter_n(i)        <= Kcounter_n(i) + '1';       
                --     Vcounter_n(i)        <= Vcounter_n(i) + '1';                       
                -- -- !signal_detect[n] | !/COMMA/ 
                -- else
                --     lane_sync_n(i)       <= '0';      
                --     Kcounter_n(i)        <= (others => '0');       
                --     Vcounter_n(i)        <= (others => '0');                     
                -- end if;
            
            -- when NO_SYNC_1 =>           
            
            when NO_SYNC_2 =>         
                -- [ IIXX or XXII ] -- One of both /INVALID/  
                if (code_group_valid(i*2) = '0' or code_group_valid(i*2+1) = '0') then
                    lane_sync_state_n(i) <= NO_SYNC;                           
                    lane_sync_n(i)       <= '0';      
                    Kcounter_n(i)        <= (others => '0');       
                    Vcounter_n(i)        <= (others => '0'); 
                -- [ KKKK ]         -- Both /COMMA/  
                elsif (RXCHARISCOMMA(i*2) = '1' and RXCHARISCOMMA(i*2+1) = '1') then    
                    -- (Kcounter[n] > 126) & (Vcounter[n] > Vmin-1) 
                    if Kcounter_n(i) >= Kmin and Vcounter_n(i) >= Vmin then 
                        lane_sync_state_n(i) <= SYNC;                              
                    -- (Kcounter[n] < 127) | (Vcounter[n] < Vmin) 
                    else                                                
                        Kcounter_n(i)        <= Kcounter_n(i) + "10";       
                        Vcounter_n(i)        <= Vcounter_n(i) + "10";                               
                    end if;                                               
                -- [ KKVV or VVKK ] -- One of both /COMMA/  
                elsif (RXCHARISCOMMA(i*2) = '1' or RXCHARISCOMMA(i*2+1) = '1') then  
                    -- (Kcounter[n] > 126) & (Vcounter[n] > Vmin-1) 
                    if Kcounter_n(i) >= Kmin and Vcounter_n(i) >= Vmin then 
                        lane_sync_state_n(i) <= SYNC;                              
                    -- (Kcounter[n] < 127) | (Vcounter[n] < Vmin) 
                    else                                                
                        Kcounter_n(i)        <= Kcounter_n(i) + '1' ;       
                        Vcounter_n(i)        <= Vcounter_n(i) + "10";                               
                    end if;                            
                    
                -- [ VVVV ]         -- None of both /COMMA/, but both /VALID/  
                else -- if RXCHARISCOMMA(i*2) = '0') and RXCHARISCOMMA(i*2+1) = '0') then    
                    -- (Kcounter[n] > 126) & (Vcounter[n] > Vmin-1) 
                    if Kcounter_n(i) >= Kmin and Vcounter_n(i) >= Vmin then 
                        lane_sync_state_n(i) <= SYNC;                              
                    -- (Kcounter[n] < 127) | (Vcounter[n] < Vmin) 
                    else                                                
                        Vcounter_n(i)        <= Vcounter_n(i) + "10";                               
                    end if;    
                end if;
                    
            -- when NO_SYNC_2a =>             
            --     -- !(/COMMA/|/INVALID/)
            --     if (code_group_valid(i*2) = '1' and not(RXCHARISCOMMA(i*2) = '1')) then --RXCHARISK(i*2) = '1' and RXDATA(i*16+7 downto i*16) = x"BC")) then
            --         lane_sync_state_n(i) <= NO_SYNC_2b;                
            --         Vcounter_n(i)        <= Vcounter_n(i) + '1';                      
            --     -- /COMMA/  
            --     elsif (code_group_valid(i*2) = '1' and RXCHARISCOMMA(i*2) = '1') then --RXCHARISK(i*2) = '1' and RXDATA(i*16+7 downto i*16) = x"BC") then
            --         -- (Kcounter[n] > 126) & (Vcounter[n] > Vmin-1) 
            --         if Kcounter_n(i) >= Kmin and Vcounter_n(i) >= Vmin then 
            --             lane_sync_state_n(i) <= SYNCb;                              
            --         -- (Kcounter[n] < 127) | (Vcounter[n] < Vmin) 
            --         else                                  
            --             lane_sync_state_n(i) <= NO_SYNC_2b;               
            --             Kcounter_n(i)        <= Kcounter_n(i) + '1';       
            --             Vcounter_n(i)        <= Vcounter_n(i) + '1';                               
            --         end if;                           
            --     -- /INVALID/  
            --     elsif (code_group_valid(i*2) = '0') then
            --         lane_sync_state_n(i) <= NO_SYNC;                           
            --         lane_sync_n(i)       <= '0';      
            --         Kcounter_n(i)        <= (others => '0');       
            --         Vcounter_n(i)        <= (others => '0');                     
            --     end if;                
            -- 
            -- when NO_SYNC_2b =>              
            --     -- !(/COMMA/|/INVALID/)
            --     if (code_group_valid(i*2+1) = '1' and not(RXCHARISCOMMA(i*2+1) = '1')) then --RXCHARISK(i*2+1) = '1' and RXDATA(i*16+15 downto i*16+8) = x"BC")) then
            --         lane_sync_state_n(i) <= NO_SYNC_2a;                
            --         Vcounter_n(i)        <= Vcounter_n(i) + '1';                                          
            --     -- /COMMA/  
            --     elsif (code_group_valid(i*2+1) = '1' and RXCHARISCOMMA(i*2+1) = '1') then --RXCHARISK(i*2+1) = '1' and RXDATA(i*16+15 downto i*16+8) = x"BC") then
            --         -- (Kcounter[n] > 126) & (Vcounter[n] > Vmin-1) 
            --         if Kcounter_n(i) >= Kmin and Vcounter_n(i) >= Vmin then 
            --             lane_sync_state_n(i) <= SYNCa;                              
            --         -- (Kcounter[n] < 127) | (Vcounter[n] < Vmin) 
            --         else                                  
            --             lane_sync_state_n(i) <= NO_SYNC_2a;               
            --             Kcounter_n(i)        <= Kcounter_n(i) + '1';       
            --             Vcounter_n(i)        <= Vcounter_n(i) + '1';                               
            --         end if;                           
            --     -- /INVALID/  
            --     elsif (code_group_valid(i*2+1) = '0') then
            --         lane_sync_state_n(i) <= NO_SYNC;                           
            --         lane_sync_n(i)       <= '0';      
            --         Kcounter_n(i)        <= (others => '0');       
            --         Vcounter_n(i)        <= (others => '0');                       
            --     end if;
                
            -- when NO_SYNC_3 => 
            
            when SYNC =>                      
                -- Both /VALID/  
                if (code_group_valid(i*2) = '1' and code_group_valid(i*2+1) = '1') then                              
                    lane_sync_n(i)       <= '1';        
                    Icounter_n(i)        <= (others => '0');                      
                -- One of both /INVALID/  
                elsif (code_group_valid(i*2) = '1' or code_group_valid(i*2+1) = '1') then      
                    Icounter_n(i)        <= Icounter_n(i) + '1';                      
                    lane_sync_state_n(i) <= SYNC_2;                         
                -- Both /INVALID/        
                else 
                    Icounter_n(i)        <= Icounter_n(i) + "10";                      
                    lane_sync_state_n(i) <= SYNC_2;                                 
                end if;
            -- 
            -- when SYNCa =>                      
            --     -- /INVALID/  
            --     if (code_group_valid(i*2) = '0') then      
            --         Icounter_n(i)        <= Icounter_n(i) + '1';                      
            --         lane_sync_state_n(i) <= SYNC_2b;                         
            --     -- /VALID/      
            --     else 
            --         lane_sync_state_n(i) <= SYNCb;                           
            --         lane_sync_n(i)       <= '1';        
            --         Icounter_n(i)        <= (others => '0');                       
            --     end if;
            --     
            -- when SYNCb =>                      
            --     -- /INVALID/  
            --     if (code_group_valid(i*2+1) = '0') then
            --         Icounter_n(i)        <= Icounter_n(i) + '1';        
            --         lane_sync_state_n(i) <= SYNC_2a;     
            --     -- /VALID/    
            --     else 
            --         lane_sync_state_n(i) <= SYNCa;                              
            --         lane_sync_n(i)       <= '1';        
            --         Icounter_n(i)        <= (others => '0');                      
            --     end if;
            
            -- when SYNC_1 => 
            
            when SYNC_2 =>      
                -- Both /VALID/  
                if (code_group_valid(i*2) = '1' and code_group_valid(i*2+1) = '1') then        
                    Vcounter_n(i)  <= Vcounter_n(i) + "10";  
                    -- (Vcounter[n] < 255) 
                    if Vcounter_n(i) < x"FF" then
                        -- do nothing
                        lane_sync_state_n(i) <= SYNC_2;  
                    -- (Vcounter[n] = 255) 
                    else
                        Icounter_n(i)   <= Icounter_n(i) - '1';
                        Vcounter_n(i)   <= (others => '0'); 
                        -- (Icounter[n] > 0) 
                        if Icounter_n(i) > Ione then
                            -- do nothing
                            lane_sync_state_n(i) <= SYNC_2;  
                        -- (Icounter[n] = 0) 
                        else
                            lane_sync_state_n(i) <= SYNC;        
                        end if;  
                    end if;  
                -- One of both /INVALID/  
                elsif (code_group_valid(i*2) = '1' or code_group_valid(i*2+1) = '1') then      
                    Icounter_n(i)        <= Icounter_n(i) + '1';      
                    Vcounter_n(i)        <= (others => '0');                     
                    -- (Icounter[n] = Imax) 
                    if Icounter_n(i) = Imax then 
                        lane_sync_state_n(i) <= NO_SYNC;                           
                        lane_sync_n(i)       <= '0';      
                        Kcounter_n(i)        <= (others => '0');     
                    -- (Icounter[n] < Imax) 
                    else      
                        -- do nothing
                        lane_sync_state_n(i) <= SYNC_2;       
                    end if;                      
                -- Both /INVALID/        
                else 
                    Icounter_n(i)        <= Icounter_n(i) + "10";      
                    Vcounter_n(i)        <= (others => '0');                     
                    -- (Icounter[n] = Imax) 
                    if Icounter_n(i) = Imax then 
                        lane_sync_state_n(i) <= NO_SYNC;                           
                        lane_sync_n(i)       <= '0';      
                        Kcounter_n(i)        <= (others => '0');     
                    -- (Icounter[n] < Imax) 
                    else      
                        -- do nothing
                        lane_sync_state_n(i) <= SYNC_2;       
                    end if;                            
                end if;
                ----------------------------------------------
                
            -- when SYNC_2a =>                  
            --     -- /INVALID/  
            --     if (code_group_valid(i*2+1) = '0') then
            --         Icounter_n(i)        <= Icounter_n(i) + '1';      
            --         Vcounter_n(i)        <= (others => '0');                     
            --         -- (Icounter[n] = Imax) 
            --         if Icounter_n(i) = Imax then 
            --             lane_sync_state_n(i) <= NO_SYNC;                           
            --             lane_sync_n(i)       <= '0';      
            --             Kcounter_n(i)        <= (others => '0');     
            --         -- (Icounter[n] < Imax) 
            --         else      
            --             lane_sync_state_n(i) <= SYNC_2b;       
            --         end if;                             
            --     -- /VALID/    
            --     else     
            --         Vcounter_n(i)  <= Vcounter_n(i) + '1';  
            --         -- (Vcounter[n] < 255) 
            --         if Vcounter_n(i) < x"FF" then
            --             lane_sync_state_n(i) <= SYNC_2b;  
            --         -- (Vcounter[n] = 255) 
            --         else
            --             Icounter_n(i)   <= Icounter_n(i) - '1';
            --             Vcounter_n(i)   <= (others => '0'); 
            --             -- (Icounter[n] > 0) 
            --             if Icounter_n(i) > Izero then
            --                 lane_sync_state_n(i) <= SYNC_2b;  
            --             -- (Icounter[n] = 0) 
            --             else
            --                 lane_sync_state_n(i) <= SYNCb;        
            --             end if;  
            --         end if;                                 
            --     end if;
            -- 
            -- when SYNC_2b =>                 
            --     -- /INVALID/  
            --     if (code_group_valid(i*2+1) = '0') then
            --         Icounter_n(i)        <= Icounter_n(i) + '1';      
            --         Vcounter_n(i)        <= (others => '0');                     
            --         -- (Icounter[n] = Imax) 
            --         if Icounter_n(i) = Imax then 
            --             lane_sync_state_n(i) <= NO_SYNC;                           
            --             lane_sync_n(i)       <= '0';      
            --             Kcounter_n(i)        <= (others => '0');     
            --         -- (Icounter[n] < Imax) 
            --         else      
            --             lane_sync_state_n(i) <= SYNC_2a;       
            --         end if;                             
            --     -- /VALID/    
            --     else     
            --         Vcounter_n(i)  <= Vcounter_n(i) + '1';  
            --         -- (Vcounter[n] < 255) 
            --         if Vcounter_n(i) < x"FF" then
            --             lane_sync_state_n(i) <= SYNC_2a;  
            --         -- (Vcounter[n] = 255) 
            --         else
            --             Icounter_n(i)   <= Icounter_n(i) - '1';
            --             Vcounter_n(i)   <= (others => '0'); 
            --             -- (Icounter[n] > 0) 
            --             if Icounter_n(i) > Izero then
            --                 lane_sync_state_n(i) <= SYNC_2a;  
            --             -- (Icounter[n] = 0) 
            --             else
            --                 lane_sync_state_n(i) <= SYNCa;        
            --             end if;  
            --         end if;                                 
            --     end if; 
            
            -- when SYNC_3 => 
            
            -- when SYNC_4 =>  
            
            when others =>     
                lane_sync_state_n(i) <= NO_SYNC;
                lane_sync_n(i)       <= '0';      
                Kcounter_n(i)        <= (others => '0');       
                Vcounter_n(i)        <= (others => '0');         
        
        end case;
    end if;
end process;

end generate GEN_LANE_SYNC_FSM;
----------------------------------------------------------------
-- Figure 4-15. Lane_Alignment State Machine (for N lanes)

N_lane_sync           <= '1' when lane_sync_n = N_lanes_all_high else '0';
lane_alignment_reset  <= N_lane_sync and rst_n;
A_column_valid_upper  <= '1' when (RXCHARIS_A_upper = N_lanes_all_high) else '0'; 
A_column_valid_lower  <= '1' when (RXCHARIS_A_lower = N_lanes_all_high) else '0'; 
A_column_valid        <= A_column_valid_upper or A_column_valid_lower; 
align_error_upper     <= '1' when (RXCHARIS_A_upper /= N_lanes_all_low) and (RXCHARIS_A_upper /= N_lanes_all_high) else '0';  
align_error_lower     <= '1' when (RXCHARIS_A_lower /= N_lanes_all_low) and (RXCHARIS_A_lower /= N_lanes_all_high) else '0'; 
align_error           <= align_error_upper or align_error_lower; 
GEN_CHAR_A_CHECKER: for i in 0 to N-1 generate    
RXCHARIS_A_upper(i)    <=  '1' when (code_group_valid(i*2+1) = '1') and (RXCHARISK(i*2+1) = '1') and (RXDATA(i*16+15 downto i*16+8) = A_align) else '0';
RXCHARIS_A_lower(i)    <=  '1' when (code_group_valid(i*2) = '1'  ) and (RXCHARISK(i*2) = '1'  ) and (RXDATA(i*16+7 downto i*16   ) = A_align) else '0';
end generate GEN_CHAR_A_CHECKER;

process(lane_alignment_reset, UCLK)
    begin
    
    if lane_alignment_reset = '0'  then
    
        lane_alignment_state <= NOT_ALIGNED;
        N_lanes_aligned      <= '0';      
        Acounter             <= (others => '0');       
        -- Mcounter             <= (others => '0');    
        
    elsif rising_edge(UCLK) then    
    
    -- if lane_alignment_reset = '1'  then
    
        case lane_alignment_state is
            when NOT_ALIGNED => 
                -- N_lane_sync & ||A||
                if N_lane_sync = '1' and A_column_valid = '1' then
                    Acounter  <= Acounter + '1';  
                    lane_alignment_state <= NOT_ALIGNED_2;            
                end if;
                
            -- when NOT_ALIGNED_1 =>
                
            when NOT_ALIGNED_2 =>
                -- align_error
                if align_error = '1' then
                    lane_alignment_state <= NOT_ALIGNED;
                    N_lanes_aligned      <= '0';      
                    Acounter             <= (others => '0');  
                -- ||A||    
                elsif A_column_valid = '1' then
                    Acounter  <= Acounter + '1';  
                    -- Acounter = 4 
                    if Acounter = "100" then
                        lane_alignment_state <= ALIGNED;                        
                    -- Acounter < 4
                    else
                        lane_alignment_state <= NOT_ALIGNED_2;                        
                    end if;                     
                -- !align_error & !||A||    
                else 
                    -- Do nothing: Wait for the next column
                end if;                
                
            when ALIGNED =>
                N_lanes_aligned      <= '1';          
                Mcounter             <= (others => '0');   
                -- align_error
                if align_error = '1' then
                    Acounter    <= (others => '0');  
                    Mcounter    <= Mcounter + '1';  
                    lane_alignment_state <= ALIGNED_2;            
                -- !(align_error)
                else 
                    -- Do nothing extra: Wait for the next column
                end if;
                
            -- when ALIGNED_1 =>
                
            when ALIGNED_2 => 
                -- align_error
                if align_error = '1' then 
                    Acounter             <= (others => '0');  
                    Mcounter             <= Mcounter + '1';  
                    -- Mcounter = Mmax
                    if Mcounter = Mmax then
                        lane_alignment_state <= NOT_ALIGNED;
                        N_lanes_aligned      <= '0';                      
                    -- Mcounter < Mmax
                    else
                        -- Do nothing extra: Wait for the next column                    
                    end if;                       
                -- ||A||    
                elsif A_column_valid = '1' then
                    Acounter  <= Acounter + '1';  
                    -- Acounter = 4 
                    if Acounter = "100" then
                        lane_alignment_state <= ALIGNED;                        
                    -- Acounter < 4
                    else
                        -- Do nothing extra: Wait for the next column                          
                    end if;                     
                -- !align_error & !||A||    
                else 
                    -- Do nothing: Wait for the next column
                end if;                
                
            -- when ALIGNED_3 =>
                
            when others =>     
                lane_alignment_state <= NOT_ALIGNED;
                N_lanes_aligned      <= '0';      
                Acounter             <= (others => '0');       
                Mcounter             <= (others => '0');          
        
        end case;
    -- else
    --     lane_alignment_state <= NOT_ALIGNED;
    --     N_lanes_aligned      <= '0';      
    --     Acounter             <= (others => '0'); 
    -- end if;
    end if;
end process;

-- Figure 4-18. 1x/Nx_Initialization State Machine for N = 4
TXINHIBIT_02        <= not(lanes02_drvr_oe);
TXINHIBIT_others    <= not(N_lanes_drvr_oe);
rcvr_trained_n      <= CHBONDDONE; -- TBD
lane_ready_n        <= lane_sync_n and rcvr_trained_n;
-- lane_ready_n        <= lane_sync_n; -- and rcvr_trained_n;
N_lanes_ready       <= '1' when N_lanes_aligned = '1' and lane_ready_n = N_lanes_all_high else '0';

-- process(UCLK)
--     begin    
--     if rising_edge(UCLK) then  
--         mode_sel         <= Nx_mode_active;
--         mode_0_lane_sel  <= receive_lane2;
--         port_initalized  <= port_initalized_reg;
--     end if;
-- end process;
mode_sel         <= Nx_mode_active;
mode_0_lane_sel  <= receive_lane2;
port_initalized  <= port_initalized_reg;

process(rst_n, UCLK)
    begin    
    if rst_n = '0'  then
    
        mode_init_state     <= SILENT;
        disc_tmr_en         <= '0';
        lanes02_drvr_oe     <= '0';
        N_lanes_drvr_oe     <= '0';
        port_initalized_reg <= '0';
        Nx_mode_active      <= '0';
        receive_lane2       <= '0';
        force_reinit_clear  <= '0';
        silence_timer_en    <= '0';     
        idle_selected       <= '1';
        
    elsif rising_edge(UCLK) then     
        case mode_init_state is
        
            when SILENT => 
                disc_tmr_en         <= '0';
                lanes02_drvr_oe     <= '0';
                N_lanes_drvr_oe     <= '0';
                port_initalized_reg <= '0';
                Nx_mode_active      <= '0';
                receive_lane2       <= '0';
                force_reinit_clear  <= '1'; -- = force_reinit <= '0';
                silence_timer_en    <= '1';  
                -- force_reinit
                if force_reinit_reg = '1' then
                    mode_init_state     <= SILENT;
                -- silence_timer_done
                elsif silence_timer_done = '1' then
                    mode_init_state     <= SEEK;
                end if;
        
            when SEEK => 
                lanes02_drvr_oe     <= '1';
                silence_timer_en    <= '0';   
                -- (lane_sync_0 | lane_sync_2) & idle_selected
                if (lane_sync_n(0) = '1' or lane_sync_n(2) = '1') and idle_selected = '1' then
                    mode_init_state     <= DISCOVERY;
                end if;
            
            when DISCOVERY => 
                port_initalized_reg <= '0';
                Nx_mode_active      <= '0';
                N_lanes_drvr_oe     <= Nx_mode_enabled;
                disc_tmr_en         <= '1';
                -- Nx_mode_enabled & N_lanes_ready
                if Nx_mode_enabled = '1' and N_lanes_ready = '1' then
                
                    mode_init_state     <= Nx_MODE;
                
                -- lane_ready[0] & (force_1x_mode & (!force_laneR | force_laneR & disc_tmr_done & !lane_ready[2]) 
                --               | !force_1x_mode & disc_tmr_done & !N_lanes_ready)
                elsif lane_ready_n(0) = '1' and ((force_1x_mode = '1' and (force_laneR = '0' or (force_laneR = '1' and disc_tmr_done = '1' and lane_ready_n(2) = '0')))
                                             or  (force_1x_mode = '0' and disc_tmr_done = '1' and N_lanes_ready = '0')) then
                
                    mode_init_state     <= x1_MODE_LANE0;
                
                -- lane_ready[2] & (force_1x_mode & force_laneR | disc_tmr_done & !lane_ready[0] 
                --               & (force_1x_mode & !force_laneR | !force_1x_mode & !N_lanes_ready))
                elsif lane_ready_n(2) = '1' and ((force_1x_mode = '1' and force_laneR = '1') or 
                                                 (disc_tmr_done = '1' and lane_ready_n(0) = '0' and 
                                                  ((force_1x_mode = '1' and force_laneR = '0') or (force_1x_mode = '0' and N_lanes_ready = '0')))) then
                                             
                    mode_init_state     <= x1_MODE_LANE2;       
                    
                ---- -- !lane_sync[0] & !lane_sync[2] | disc_tmr_done & !lane_ready[0] & !lane_ready[2]    
                ---- elsif (lane_sync_n(0) = '0' and lane_sync_n(2) = '0') or (disc_tmr_done = '1' and lane_ready_n(0) = '0' and lane_ready_n(2) = '0')  then   
                -- disc_tmr_done & !lane_ready[0] & !lane_ready[2]    
                elsif (disc_tmr_done = '1' and lane_ready_n(0) = '0' and lane_ready_n(2) = '0')  then   
                
                    mode_init_state     <= SILENT;
                    
                end if;
            
            when Nx_MODE => 
                disc_tmr_en         <= '0';
                port_initalized_reg <= '1';
                Nx_mode_active      <= '1';
                -- !N_lanes_ready & (lane_sync[0] | lane_sync[2])                
                if N_lanes_ready = '0' and (lane_sync_n(0) = '1' or lane_sync_n(2) = '1') then                
                    mode_init_state     <= DISCOVERY;                    
                -- !N_lanes_ready & !lane_sync[0] & !lane_sync[2]
                elsif N_lanes_ready = '0' and lane_sync_n(0) = '0' and lane_sync_n(2) = '0' then                    
                    mode_init_state     <= SILENT;                    
                end if;
            
            when x1_MODE_LANE0 => 
                disc_tmr_en         <= '0';
                N_lanes_drvr_oe     <= '0';
                port_initalized_reg <= '1';      
                -- !lane_sync[0]               
                if lane_sync_n(0) = '0' then                             
                    mode_init_state     <= SILENT;    
                -- !lane_ready[0] & lane_sync[0]
                elsif lane_ready_n(0) = '0' and lane_sync_n(0) = '1' then      
                    mode_init_state     <= x1_RECOVERY;                                     
                end if;                
            
            when x1_MODE_LANE2 => 
                disc_tmr_en         <= '0';
                receive_lane2       <= '1';
                N_lanes_drvr_oe     <= '0';
                port_initalized_reg <= '1';      
                -- !lane_sync[2]               
                if lane_sync_n(2) = '0' then                             
                    mode_init_state     <= SILENT;    
                -- !lane_ready[2] & lane_sync[2]
                elsif lane_ready_n(2) = '0' and lane_sync_n(2) = '1' then      
                    mode_init_state     <= x1_RECOVERY;                                     
                end if;            
            
            when x1_RECOVERY => 
                port_initalized_reg <= '0';  
                disc_tmr_en         <= '1';
                -- !lane_sync[0] & !lane_sync[2] & disc_tmr_done   (!!!)
                if lane_sync_n(0) = '0' and lane_sync_n(2) = '0' and disc_tmr_done = '1' then
                
                    mode_init_state     <= SILENT;  
                
                -- lane_ready[0] & !receive_lane2 & !disc_tmr_done
                elsif lane_sync_n(0) = '1' and receive_lane2 = '0' and disc_tmr_done = '0' then
                
                    mode_init_state     <= x1_MODE_LANE0; 
                
                -- lane_ready[2] & receive_lane2 & !disc_tmr_done
                elsif lane_sync_n(2) = '1' and receive_lane2 = '1' and disc_tmr_done = '0' then
                
                    mode_init_state     <= x1_MODE_LANE2; 
                
                end if;   
            
            when others =>
                port_initalized_reg <= '0'; 
                mode_init_state     <= SILENT;
            
        end case;
        
    end if;
    
end process;

-- Sticky force_reinit set-reset register
process(rst_n, UCLK)
    begin    
    if rst_n = '0'  then    
        force_reinit_reg       <= '0';      
    elsif rising_edge(UCLK) then    
        case force_reinit_reg is
            when '0' => 
                force_reinit_reg <= force_reinit or rxbuferr_reg;            
            when '1' => 
                -- force_reinit_reg <= not(force_reinit_clear) and not(force_reinit);
                force_reinit_reg <= not(force_reinit_clear and not(force_reinit) and not(rxbuferr_reg));
            when others =>
                force_reinit_reg <= '0';
        end case;
    end if;
end process;

-- RXBUFRST handler
process(rst_n, UCLK)
    begin    
    if rst_n = '0'  then    
        rxbufrst_cntr    <= (others => '0');  
        rxbuferr_reg     <= '0';  
        RXBUFRST         <= '0';
        
    elsif rising_edge(UCLK) then    
        case rxbuferr_reg is
            when '0' => 
                rxbuferr_reg     <= RXBUFERR;   
                RXBUFRST         <= '0';
            when '1' =>                 
                if rxbufrst_cntr = "111" then
                    rxbuferr_reg     <= '0'; 
                    rxbufrst_cntr    <= (others => '0');  
                else
                    RXBUFRST         <= '1';
                    rxbufrst_cntr    <= rxbufrst_cntr + '1';  
                end if;                
            when others =>
                rxbuferr_reg     <= '0';   
        end case;
    end if;
end process;


-- Silence Timer Process
-- silence_timer_done: Asserted when silence_timer_en has been continuously asserted
-- for 120 +/- 40 µs and the state machine is in the SILENT state. The assertion of
-- silence_timer_done causes silence_timer_en to be de-asserted. When the state
-- machine is not in the SILENT state, silence_timer_done is de-asserted.
process(rst_n, UCLK_DV_1024)
    begin    
    if rst_n = '0'  then        
        silence_timer_done  <= '0'; 
        silence_timer       <= (others => '0');         
    elsif rising_edge(UCLK_DV_1024) then 
    
        case silence_timer_en is            
            when '0' =>   
                silence_timer       <= (others => '0');  
                silence_timer_done  <= '0'; 
            when '1' => 
                if silence_timer = SILENT_ENOUGH then
                    if mode_init_state = SILENT then
                        silence_timer_done  <= '1'; 
                    else
                        silence_timer_done  <= '0'; 
                    end if;
                else
                    silence_timer   <= silence_timer + '1';
                end if;
            when others =>
                silence_timer   <= (others => '0');              
        end case; 
    end if;
end process;

-- Discovery Timer Process
-- disc_tmr_done: Asserted when disc_tmr_en has been continuously asserted for 28 +/- 4 ms
-- and the state machine is in the DISCOVERY or a RECOVERY state. The assertion of 
-- disc_tmr_done causes disc_tmr_en to be de-asserted. When the state machine is in
-- a state other than the DISCOVERY or a RECOVERY state, disc_tmr_done is de-asserted.
process(rst_n, UCLK_DV_1024)
    begin    
    if rst_n = '0'  then        
        disc_tmr_done  <= '0'; 
        disc_tmr       <= (others => '0');         
    elsif rising_edge(UCLK_DV_1024) then 
    
        case disc_tmr_en is            
            when '0' =>   
                disc_tmr       <= (others => '0');  
                disc_tmr_done  <= '0'; 
            when '1' => 
                if disc_tmr = DISCOVERY_ENDS then
                    if mode_init_state = DISCOVERY or mode_init_state = x1_RECOVERY then
                        disc_tmr_done  <= '1'; 
                    else
                        disc_tmr_done  <= '0'; 
                    end if;
                else
                    disc_tmr   <= disc_tmr + '1';
                end if;
            when others =>
                disc_tmr   <= (others => '0');              
        end case; 
    end if;
end process;

ENCHANSYNC <= '0';

end rtl;
-------------------------------------------------------------------------------
-- 
-- RapidIO IP Library Core
-- 
-- This file is part of the RapidIO IP library project
-- http://www.opencores.org/cores/rio/
-- 
-- To Do:
-- -
-- 
-- Author(s): 
-- - A. Demirezen, azdem@opencores.org 
-- 
-------------------------------------------------------------------------------
-- 
-- Copyright (C) 2013 Authors and OPENCORES.ORG 
-- 
-- This source file may be used and distributed without 
-- restriction provided that this copyright statement is not 
-- removed from the file and that any derivative work contains 
-- the original copyright notice and the associated disclaimer. 
-- 
-- This source file is free software; you can redistribute it 
-- and/or modify it under the terms of the GNU Lesser General 
-- Public License as published by the Free Software Foundation; 
-- either version 2.1 of the License, or (at your option) any 
-- later version. 
-- 
-- This source is distributed in the hope that it will be 
-- useful, but WITHOUT ANY WARRANTY; without even the implied 
-- warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR 
-- PURPOSE. See the GNU Lesser General Public License for more 
-- details. 
-- 
-- You should have received a copy of the GNU Lesser General 
-- Public License along with this source; if not, download it 
-- from http://www.opencores.org/lgpl.shtml 
-- 
------------------------------------------------------------------------------
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity pseudo_random_number_generator is
    Generic (
            lfsr_init   : std_logic_vector(7 downto 0) := x"01"
           );
    Port    ( 
            clk      : in  STD_LOGIC;
            rst_n    : in  STD_LOGIC;
            -- Pseudo random number
            q        : out STD_LOGIC_VECTOR(7 downto 0)           
           );
end pseudo_random_number_generator;

architecture Behavioral of pseudo_random_number_generator is
    
signal lfsr   : std_logic_vector(7 downto 0) := x"01"; 
signal q0     : std_logic; 

 begin 

q  <= lfsr;

-- Polynomial: x^7 + x^6 + 1
q0 <= lfsr(7) xnor lfsr(6) xnor lfsr(0) ;

process (clk, rst_n) begin 
    
  if rst_n = '0' then 
  
    lfsr <= lfsr_init; -- x"01"; --(others => '0');
    
  elsif rising_edge(clk) then 
  
    lfsr <= lfsr(6 downto 0) & q0; 
      
  end if; 
  
end process;
     
end Behavioral;

-------------------------------------------------------------------------------
-- 
-- RapidIO IP Library Core
-- 
-- This file is part of the RapidIO IP library project
-- http://www.opencores.org/cores/rio/
-- 
-- To Do:
-- -
-- 
-- Author(s): 
-- - A. Demirezen, azdem@opencores.org 
-- 
-------------------------------------------------------------------------------
-- 
-- Copyright (C) 2013 Authors and OPENCORES.ORG 
-- 
-- This source file may be used and distributed without 
-- restriction provided that this copyright statement is not 
-- removed from the file and that any derivative work contains 
-- the original copyright notice and the associated disclaimer. 
-- 
-- This source file is free software; you can redistribute it 
-- and/or modify it under the terms of the GNU Lesser General 
-- Public License as published by the Free Software Foundation; 
-- either version 2.1 of the License, or (at your option) any 
-- later version. 
-- 
-- This source is distributed in the hope that it will be 
-- useful, but WITHOUT ANY WARRANTY; without even the implied 
-- warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR 
-- PURPOSE. See the GNU Lesser General Public License for more 
-- details. 
-- 
-- You should have received a copy of the GNU Lesser General 
-- Public License along with this source; if not, download it 
-- from http://www.opencores.org/lgpl.shtml 
-- 
------------------------------------------------------------------------------
------------------------------------------------------------------------------
--
-- File name:    serdes_wrapper_v0.vhd
-- Rev:          0.0
-- Description:  This entity instantiates 4-Lane SerDes (GTX-Quad) of Virtex-6
-- 
------------------------------------------------------------------------------
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.rio_common.all;

entity serdes_wrapper_v0 is
  port ( 
         REFCLK              : in std_logic;
         RXUSRCLK            : in std_logic;
         RXUSRCLK2           : in std_logic;
         TXUSRCLK            : in std_logic;
         TXUSRCLK2           : in std_logic;
         GTXRESET            : in std_logic;
         RXBUFRST            : in std_logic;
          
         -- RXN                 : in  std_logic_vector(N-1 downto 0);
         -- RXP                 : in  std_logic_vector(N-1 downto 0);
         RXN                 : in  std_logic_vector(0 to N-1);
         RXP                 : in  std_logic_vector(0 to N-1);
         TXINHIBIT_02        : in  std_logic;
         TXINHIBIT_others    : in  std_logic;
         ENCHANSYNC          : in  std_logic;
         TXDATA              : in  std_logic_vector(N*16-1 downto 0);
         TXCHARISK           : in  std_logic_vector(N*2-1 downto 0);
         -- TXN                 : out std_logic_vector(N-1 downto 0);
         -- TXP                 : out std_logic_vector(N-1 downto 0);
         TXN                 : out std_logic_vector(0 to N-1);
         TXP                 : out std_logic_vector(0 to N-1);
         PLLLKDET            : out std_logic;
         RXDATA              : out std_logic_vector(N*16-1 downto 0);
         RXCHARISK           : out std_logic_vector(N*2-1 downto 0);
         RXCHARISCOMMA       : out std_logic_vector(N*2-1 downto 0);
         RXBYTEISALIGNED     : out std_logic_vector(N-1 downto 0);
         RXBYTEREALIGN       : out std_logic_vector(N-1 downto 0);
         RXELECIDLE          : out std_logic_vector(N-1 downto 0);
         RXDISPERR           : out std_logic_vector(N*2-1 downto 0);
         RXNOTINTABLE        : out std_logic_vector(N*2-1 downto 0);
         RXBUFERR            : out std_logic;
         CHBONDDONE          : out std_logic_vector(N-1 downto 0)
  );
end serdes_wrapper_v0;

architecture struct of serdes_wrapper_v0 is

	COMPONENT srio_gt_wrapper_v6_4x
	PORT(
		REFCLK : IN std_logic;
		RXUSRCLK : IN std_logic;
		RXUSRCLK2 : IN std_logic;
		TXUSRCLK : IN std_logic;
		TXUSRCLK2 : IN std_logic;
		GTXRESET : IN std_logic;
		RXBUFRST : IN std_logic;
		RXN0 : IN std_logic;
		RXN1 : IN std_logic;
		RXN2 : IN std_logic;
		RXN3 : IN std_logic;
		RXP0 : IN std_logic;
		RXP1 : IN std_logic;
		RXP2 : IN std_logic;
		RXP3 : IN std_logic;
		TXINHIBIT_02 : IN std_logic;
		TXINHIBIT_13 : IN std_logic;
		ENCHANSYNC : IN std_logic;
		TXDATA0 : IN std_logic_vector(15 downto 0);
		TXDATA1 : IN std_logic_vector(15 downto 0);
		TXDATA2 : IN std_logic_vector(15 downto 0);
		TXDATA3 : IN std_logic_vector(15 downto 0);
		TXCHARISK0 : IN std_logic_vector(1 downto 0);
		TXCHARISK1 : IN std_logic_vector(1 downto 0);
		TXCHARISK2 : IN std_logic_vector(1 downto 0);
		TXCHARISK3 : IN std_logic_vector(1 downto 0);          
		TXN0 : OUT std_logic;
		TXN1 : OUT std_logic;
		TXN2 : OUT std_logic;
		TXN3 : OUT std_logic;
		TXP0 : OUT std_logic;
		TXP1 : OUT std_logic;
		TXP2 : OUT std_logic;
		TXP3 : OUT std_logic;
		PLLLKDET : OUT std_logic;
		RXDATA0 : OUT std_logic_vector(15 downto 0);
		RXDATA1 : OUT std_logic_vector(15 downto 0);
		RXDATA2 : OUT std_logic_vector(15 downto 0);
		RXDATA3 : OUT std_logic_vector(15 downto 0);
		RXCHARISK0 : OUT std_logic_vector(1 downto 0);
		RXCHARISK1 : OUT std_logic_vector(1 downto 0);
		RXCHARISK2 : OUT std_logic_vector(1 downto 0);
		RXCHARISK3 : OUT std_logic_vector(1 downto 0);
		RXCHARISCOMMA0 : OUT std_logic_vector(1 downto 0);
		RXCHARISCOMMA1 : OUT std_logic_vector(1 downto 0);
		RXCHARISCOMMA2 : OUT std_logic_vector(1 downto 0);
		RXCHARISCOMMA3 : OUT std_logic_vector(1 downto 0);
        RXBYTEISALIGNED: OUT  std_logic_vector(3 downto 0);
        RXBYTEREALIGN  : OUT  std_logic_vector(3 downto 0);
        RXELECIDLE     : OUT std_logic_vector(3 downto 0);
		RXDISPERR0 : OUT std_logic_vector(1 downto 0);
		RXDISPERR1 : OUT std_logic_vector(1 downto 0);
		RXDISPERR2 : OUT std_logic_vector(1 downto 0);
		RXDISPERR3 : OUT std_logic_vector(1 downto 0);
		RXNOTINTABLE0 : OUT std_logic_vector(1 downto 0);
		RXNOTINTABLE1 : OUT std_logic_vector(1 downto 0);
		RXNOTINTABLE2 : OUT std_logic_vector(1 downto 0);
		RXNOTINTABLE3 : OUT std_logic_vector(1 downto 0);
		RXBUFERR : OUT std_logic;
		CHBONDDONE0 : OUT std_logic;
		CHBONDDONE1 : OUT std_logic;
		CHBONDDONE2 : OUT std_logic;
		CHBONDDONE3 : OUT std_logic
		);
	END COMPONENT;

begin

	Inst_srio_gt_wrapper_v6_4x: srio_gt_wrapper_v6_4x PORT MAP(
		REFCLK              => REFCLK                       ,
		RXUSRCLK            => RXUSRCLK                     ,
		RXUSRCLK2           => RXUSRCLK2                    ,
		TXUSRCLK            => TXUSRCLK                     ,
		TXUSRCLK2           => TXUSRCLK2                    ,
		GTXRESET            => GTXRESET                     ,
		RXBUFRST            => RXBUFRST                     ,
		RXN0                => RXN(0)                       ,
		RXN1                => RXN(1)                       ,
		RXN2                => RXN(2)                       ,
		RXN3                => RXN(3)                       ,
		RXP0                => RXP(0)                       ,
		RXP1                => RXP(1)                       ,
		RXP2                => RXP(2)                       ,
		RXP3                => RXP(3)                       ,
		TXINHIBIT_02        => TXINHIBIT_02                 ,
		TXINHIBIT_13        => TXINHIBIT_others             ,
		ENCHANSYNC          => ENCHANSYNC                   ,
		TXDATA0             => TXDATA(15 downto 0)          ,
		TXDATA1             => TXDATA(31 downto 16)         ,
		TXDATA2             => TXDATA(47 downto 32)         ,
		TXDATA3             => TXDATA(63 downto 48)         ,
		TXCHARISK0          => TXCHARISK(1 downto 0)        ,
		TXCHARISK1          => TXCHARISK(3 downto 2)        ,
		TXCHARISK2          => TXCHARISK(5 downto 4)        ,
		TXCHARISK3          => TXCHARISK(7 downto 6)        ,
		TXN0                => TXN(0)                       ,
		TXN1                => TXN(1)                       ,
		TXN2                => TXN(2)                       ,
		TXN3                => TXN(3)                       ,
		TXP0                => TXP(0)                       ,
		TXP1                => TXP(1)                       ,
		TXP2                => TXP(2)                       ,
		TXP3                => TXP(3)                       ,
		PLLLKDET            => PLLLKDET                     ,
		RXDATA0             => RXDATA(15 downto 0)          ,
		RXDATA1             => RXDATA(31 downto 16)         ,
		RXDATA2             => RXDATA(47 downto 32)         ,
		RXDATA3             => RXDATA(63 downto 48)         ,
		RXCHARISK0          => RXCHARISK(1 downto 0)        ,
		RXCHARISK1          => RXCHARISK(3 downto 2)        ,
		RXCHARISK2          => RXCHARISK(5 downto 4)        ,
		RXCHARISK3          => RXCHARISK(7 downto 6)        ,
		RXCHARISCOMMA0      => RXCHARISCOMMA(1 downto 0)    ,
		RXCHARISCOMMA1      => RXCHARISCOMMA(3 downto 2)    ,
		RXCHARISCOMMA2      => RXCHARISCOMMA(5 downto 4)    ,
		RXCHARISCOMMA3      => RXCHARISCOMMA(7 downto 6)    ,        
        RXBYTEISALIGNED     => RXBYTEISALIGNED              ,
        RXBYTEREALIGN       => RXBYTEREALIGN                ,
        RXELECIDLE          => RXELECIDLE                   ,
		RXDISPERR0          => RXDISPERR(1 downto 0)        ,
		RXDISPERR1          => RXDISPERR(3 downto 2)        ,
		RXDISPERR2          => RXDISPERR(5 downto 4)        ,
		RXDISPERR3          => RXDISPERR(7 downto 6)        ,
		RXNOTINTABLE0       => RXNOTINTABLE(1 downto 0)     ,
		RXNOTINTABLE1       => RXNOTINTABLE(3 downto 2)     ,
		RXNOTINTABLE2       => RXNOTINTABLE(5 downto 4)     ,
		RXNOTINTABLE3       => RXNOTINTABLE(7 downto 6)     ,
		RXBUFERR            => RXBUFERR                     ,
		CHBONDDONE0         => CHBONDDONE(0)                ,
		CHBONDDONE1         => CHBONDDONE(1)                ,
		CHBONDDONE2         => CHBONDDONE(2)                ,
		CHBONDDONE3         => CHBONDDONE(3)      
	);

end struct;
-------------------------------------------------------------------------------
-- 
-- RapidIO IP Library Core
-- 
-- This file is part of the RapidIO IP library project
-- http://www.opencores.org/cores/rio/
-- 
-- To Do:
-- -
-- 
-- Author(s): 
-- - A. Demirezen, azdem@opencores.org 
-- 
-------------------------------------------------------------------------------
-- 
-- Copyright (C) 2013 Authors and OPENCORES.ORG 
-- 
-- This source file may be used and distributed without 
-- restriction provided that this copyright statement is not 
-- removed from the file and that any derivative work contains 
-- the original copyright notice and the associated disclaimer. 
-- 
-- This source file is free software; you can redistribute it 
-- and/or modify it under the terms of the GNU Lesser General 
-- Public License as published by the Free Software Foundation; 
-- either version 2.1 of the License, or (at your option) any 
-- later version. 
-- 
-- This source is distributed in the hope that it will be 
-- useful, but WITHOUT ANY WARRANTY; without even the implied 
-- warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR 
-- PURPOSE. See the GNU Lesser General Public License for more 
-- details. 
-- 
-- You should have received a copy of the GNU Lesser General 
-- Public License along with this source; if not, download it 
-- from http://www.opencores.org/lgpl.shtml 
-- 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.ALL;
library UNISIM;
use UNISIM.Vcomponents.ALL;

entity srio_pcs_struct is
   port ( CHBONDDONE         : in    std_logic_vector (3 downto 0); 
          force_reinit_i     : in    std_logic; 
          inboundRead_i      : in    std_logic; 
          outboundSymbol_i   : in    std_logic_vector (33 downto 0); 
          outboundWrite_i    : in    std_logic; 
          PLLLKDET           : in    std_logic; 
          rio_clk            : in    std_logic; 
          rst_n              : in    std_logic; 
          RXBUFERR           : in    std_logic; 
          RXBYTEISALIGNED    : in    std_logic_vector (3 downto 0); 
          RXBYTEREALIGN      : in    std_logic_vector (3 downto 0); 
          RXCAHRISCOMMA      : in    std_logic_vector (7 downto 0); 
          RXCAHRISK          : in    std_logic_vector (7 downto 0); 
          RXDATA             : in    std_logic_vector (63 downto 0); 
          RXDISPERR          : in    std_logic_vector (7 downto 0); 
          RXELECIDLE         : in    std_logic_vector (3 downto 0); 
          RXNOTINTABLE       : in    std_logic_vector (7 downto 0); 
          UCLK               : in    std_logic; 
          UCLK_DV4           : in    std_logic; 
          UCLK_DV1024        : in    std_logic; 
          UCLK_or_DV4        : in    std_logic; 
          UCLK_x2            : in    std_logic; 
          UCLK_x2_DV2        : in    std_logic; 
          ENCHANSYNC         : out   std_logic; 
          inboundEmpty_o     : out   std_logic; 
          inboundSymbol_o    : out   std_logic_vector (33 downto 0); 
          lane_sync_o        : out   std_logic_vector (3 downto 0); 
          mode_sel_o         : out   std_logic; 
          mode_0_lane_sel_o  : out   std_logic; 
          outboundFull_o     : out   std_logic; 
          port_initialized_o : out   std_logic; 
          RXBUFRST           : out   std_logic; 
          TXCAHRISK          : out   std_logic_vector (7 downto 0); 
          TXDATA             : out   std_logic_vector (63 downto 0); 
          TXINHIBIT_others   : out   std_logic; 
          TXINHIBIT_02       : out   std_logic);
end srio_pcs_struct;

architecture BEHAVIORAL of srio_pcs_struct is
   signal ccs_timer_rst            : std_logic;
   signal RXCAHRISvalid            : std_logic_vector (7 downto 0);
   signal send_A                   : std_logic_vector (1 downto 0);
   signal send_ccs                 : std_logic;
   signal send_idle                : std_logic_vector (1 downto 0);
   signal send_K                   : std_logic_vector (1 downto 0);
   signal send_R                   : std_logic_vector (1 downto 0);
   signal mode_0_lane_sel_o_DUMMY  : std_logic;
   signal TXINHIBIT_02_DUMMY       : std_logic;
   signal mode_sel_o_DUMMY         : std_logic;
   signal port_initialized_o_DUMMY : std_logic;
   signal TXINHIBIT_others_DUMMY   : std_logic;
   component ccs_timer
      port ( rst_n         : in    std_logic; 
             ccs_timer_rst : in    std_logic; 
             send_ccs      : out   std_logic; 
             UCLK          : in    std_logic);
   end component;
   
   component idle_generator_dual
      port ( UCLK      : in    std_logic; 
             rst_n     : in    std_logic; 
             send_K    : out   std_logic_vector (1 downto 0); 
             send_A    : out   std_logic_vector (1 downto 0); 
             send_R    : out   std_logic_vector (1 downto 0); 
             send_idle : in    std_logic_vector (1 downto 0));
   end component;
   
   component port_init_fsms
      port ( rst_n            : in    std_logic; 
             UCLK_x2          : in    std_logic; 
             UCLK             : in    std_logic; 
             UCLK_DV4         : in    std_logic; 
             UCLK_DV_1024     : in    std_logic; 
             force_reinit     : in    std_logic; 
             PLLLKDET         : in    std_logic; 
             RXBUFERR         : in    std_logic; 
             RXDATA           : in    std_logic_vector (63 downto 0); 
             RXCHARISK        : in    std_logic_vector (7 downto 0); 
             RXCHARISCOMMA    : in    std_logic_vector (7 downto 0); 
             RXBYTEISALIGNED  : in    std_logic_vector (3 downto 0); 
             RXBYTEREALIGN    : in    std_logic_vector (3 downto 0); 
             RXELECIDLE       : in    std_logic_vector (3 downto 0); 
             RXDISPERR        : in    std_logic_vector (7 downto 0); 
             RXNOTINTABLE     : in    std_logic_vector (7 downto 0); 
             CHBONDDONE       : in    std_logic_vector (3 downto 0); 
             mode_sel         : out   std_logic; 
             port_initalized  : out   std_logic; 
             TXINHIBIT_02     : out   std_logic; 
             TXINHIBIT_others : out   std_logic; 
             ENCHANSYNC       : out   std_logic; 
             RXBUFRST         : out   std_logic; 
             lane_sync        : out   std_logic_vector (3 downto 0); 
             mode_0_lane_sel  : out   std_logic; 
             RXCHARISvalid    : out   std_logic_vector (7 downto 0));
   end component;
   
   component pcs_rx_controller
      port ( rst_n             : in    std_logic; 
             rio_clk           : in    std_logic; 
             UCLK_x2           : in    std_logic; 
             UCLK              : in    std_logic; 
             UCLK_x2_DV2       : in    std_logic; 
             inboundRead_i     : in    std_logic; 
             port_initalized_i : in    std_logic; 
             mode_sel_i        : in    std_logic; 
             mode_0_lane_sel_i : in    std_logic; 
             RXDATA_i          : in    std_logic_vector (63 downto 0); 
             RXCHARISK_i       : in    std_logic_vector (7 downto 0); 
             RXCHARISvalid_i   : in    std_logic_vector (7 downto 0); 
             inboundEmpty_o    : out   std_logic; 
             inboundSymbol_o   : out   std_logic_vector (33 downto 0); 
             UCLK_or_DV4       : in    std_logic);
   end component;
   
   component pcs_tx_controller
      port ( rst_n             : in    std_logic; 
             rio_clk           : in    std_logic; 
             UCLK_x2           : in    std_logic; 
             UCLK              : in    std_logic; 
             UCLK_x2_DV2       : in    std_logic; 
             UCLK_or_DV4       : in    std_logic; 
             outboundWrite_i   : in    std_logic; 
             send_ccs_i        : in    std_logic; 
             TXINHIBIT_02      : in    std_logic; 
             TXINHIBIT_others  : in    std_logic; 
             port_initalized_i : in    std_logic; 
             mode_sel_i        : in    std_logic; 
             mode_0_lane_sel_i : in    std_logic; 
             outboundSymbol_i  : in    std_logic_vector (33 downto 0); 
             send_K_i          : in    std_logic_vector (1 downto 0); 
             send_A_i          : in    std_logic_vector (1 downto 0); 
             send_R_i          : in    std_logic_vector (1 downto 0); 
             outboundFull_o    : out   std_logic; 
             ccs_timer_rst_o   : out   std_logic; 
             TXDATA_o          : out   std_logic_vector (63 downto 0); 
             TXCHARISK_o       : out   std_logic_vector (7 downto 0); 
             send_idle_o       : out   std_logic_vector (1 downto 0));
   end component;
   
begin
   mode_sel_o <= mode_sel_o_DUMMY;
   mode_0_lane_sel_o <= mode_0_lane_sel_o_DUMMY;
   port_initialized_o <= port_initialized_o_DUMMY;
   TXINHIBIT_others <= TXINHIBIT_others_DUMMY;
   TXINHIBIT_02 <= TXINHIBIT_02_DUMMY;
   ccs_timer_inst : ccs_timer
      port map (ccs_timer_rst=>ccs_timer_rst,
                rst_n=>rst_n,
                UCLK=>UCLK,
                send_ccs=>send_ccs);
   
   dual_idle_generator : idle_generator_dual
      port map (rst_n=>rst_n,
                send_idle(1 downto 0)=>send_idle(1 downto 0),
                UCLK=>UCLK,
                send_A(1 downto 0)=>send_A(1 downto 0),
                send_K(1 downto 0)=>send_K(1 downto 0),
                send_R(1 downto 0)=>send_R(1 downto 0));
   
   port_init_fsms_inst : port_init_fsms
      port map (CHBONDDONE(3 downto 0)=>CHBONDDONE(3 downto 0),
                force_reinit=>force_reinit_i,
                PLLLKDET=>PLLLKDET,
                rst_n=>rst_n,
                RXBUFERR=>RXBUFERR,
                RXBYTEISALIGNED(3 downto 0)=>RXBYTEISALIGNED(3 downto 0),
                RXBYTEREALIGN(3 downto 0)=>RXBYTEREALIGN(3 downto 0),
                RXCHARISCOMMA(7 downto 0)=>RXCAHRISCOMMA(7 downto 0),
                RXCHARISK(7 downto 0)=>RXCAHRISK(7 downto 0),
                RXDATA(63 downto 0)=>RXDATA(63 downto 0),
                RXDISPERR(7 downto 0)=>RXDISPERR(7 downto 0),
                RXELECIDLE(3 downto 0)=>RXELECIDLE(3 downto 0),
                RXNOTINTABLE(7 downto 0)=>RXNOTINTABLE(7 downto 0),
                UCLK=>UCLK,
                UCLK_DV_1024=>UCLK_DV1024,
                UCLK_DV4=>UCLK_DV4,
                UCLK_x2=>UCLK_x2,
                ENCHANSYNC=>ENCHANSYNC,
                lane_sync(3 downto 0)=>lane_sync_o(3 downto 0),
                mode_sel=>mode_sel_o_DUMMY,
                mode_0_lane_sel=>mode_0_lane_sel_o_DUMMY,
                port_initalized=>port_initialized_o_DUMMY,
                RXBUFRST=>RXBUFRST,
                RXCHARISvalid(7 downto 0)=>RXCAHRISvalid(7 downto 0),
                TXINHIBIT_others=>TXINHIBIT_others_DUMMY,
                TXINHIBIT_02=>TXINHIBIT_02_DUMMY);
   
   rx_controller_inst : pcs_rx_controller
      port map (inboundRead_i=>inboundRead_i,
                mode_sel_i=>mode_sel_o_DUMMY,
                mode_0_lane_sel_i=>mode_0_lane_sel_o_DUMMY,
                port_initalized_i=>port_initialized_o_DUMMY,
                rio_clk=>rio_clk,
                rst_n=>rst_n,
                RXCHARISK_i(7 downto 0)=>RXCAHRISK(7 downto 0),
                RXCHARISvalid_i(7 downto 0)=>RXCAHRISvalid(7 downto 0),
                RXDATA_i(63 downto 0)=>RXDATA(63 downto 0),
                UCLK=>UCLK,
                UCLK_or_DV4=>UCLK_or_DV4,
                UCLK_x2=>UCLK_x2,
                UCLK_x2_DV2=>UCLK_x2_DV2,
                inboundEmpty_o=>inboundEmpty_o,
                inboundSymbol_o(33 downto 0)=>inboundSymbol_o(33 downto 0));
   
   tx_controller_inst : pcs_tx_controller
      port map (mode_sel_i=>mode_sel_o_DUMMY,
                mode_0_lane_sel_i=>mode_0_lane_sel_o_DUMMY,
                outboundSymbol_i(33 downto 0)=>outboundSymbol_i(33 downto 0),
                outboundWrite_i=>outboundWrite_i,
                port_initalized_i=>port_initialized_o_DUMMY,
                rio_clk=>rio_clk,
                rst_n=>rst_n,
                send_A_i(1 downto 0)=>send_A(1 downto 0),
                send_ccs_i=>send_ccs,
                send_K_i(1 downto 0)=>send_K(1 downto 0),
                send_R_i(1 downto 0)=>send_R(1 downto 0),
                TXINHIBIT_others=>TXINHIBIT_others_DUMMY,
                TXINHIBIT_02=>TXINHIBIT_02_DUMMY,
                UCLK=>UCLK,
                UCLK_or_DV4=>UCLK_or_DV4,
                UCLK_x2=>UCLK_x2,
                UCLK_x2_DV2=>UCLK_x2_DV2,
                ccs_timer_rst_o=>ccs_timer_rst,
                outboundFull_o=>outboundFull_o,
                send_idle_o(1 downto 0)=>send_idle(1 downto 0),
                TXCHARISK_o(7 downto 0)=>TXCAHRISK(7 downto 0),
                TXDATA_o(63 downto 0)=>TXDATA(63 downto 0));
   
end BEHAVIORAL;


