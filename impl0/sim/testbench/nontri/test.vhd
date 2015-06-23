--------------------------------------------------------------
-- test.vhd
--------------------------------------------------------------
-- project: HPC-16 Microprocessor
--
-- usage: basic testbench top-level
--
-- dependency: cpu.vhd, ramNx16.vhd, ram8x16.vhd
--
-- Author: M. Umair Siddiqui (umairsiddiqui@opencores.org)
---------------------------------------------------------------
------------------------------------------------------------------------------------
--                                                                                --
--    Copyright (c) 2005, M. Umair Siddiqui all rights reserved                   --
--                                                                                --
--    This file is part of HPC-16.                                                --
--                                                                                --
--    HPC-16 is free software; you can redistribute it and/or modify              --
--    it under the terms of the GNU Lesser General Public License as published by --
--    the Free Software Foundation; either version 2.1 of the License, or         --
--    (at your option) any later version.                                         --
--                                                                                --
--    HPC-16 is distributed in the hope that it will be useful,                   --
--    but WITHOUT ANY WARRANTY; without even the implied warranty of              --
--    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the               --
--    GNU Lesser General Public License for more details.                         --
--                                                                                --
--    You should have received a copy of the GNU Lesser General Public License    --
--    along with HPC-16; if not, write to the Free Software                       --
--    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA   --
--                                                                                --
------------------------------------------------------------------------------------
--------------------------------
--                            --
--    non-tristate version    --
--                            --
--------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
-----------------------------------------------------------
entity test is
  generic 
  (
    clk_period          : time    := 40 ns;
    half_clk_period     : time    := 20 ns;
    --
    cpu_pc_preset_value : std_logic_vector(15 downto 0) := X"0000";
    cpu_sp_preset_value : std_logic_vector(15 downto 0) := X"001e";
    --
    ram_adr_width       : integer := 4;
     
    file_name_prefix    : string  := "add2";
    sim_stop_time       : time    := 3000 ns;
    --
    ram2_adr            : std_logic_vector(15 downto 0) := X"ff00";
    
    ram2_init_0         : std_logic_vector(15 downto 0) := X"7fff";
    ram2_init_1         : std_logic_vector(15 downto 0) := X"0001";
    ram2_init_2         : std_logic_vector(15 downto 0) := (others => '0');
    ram2_init_3         : std_logic_vector(15 downto 0) := (others => '0');
    ram2_init_4         : std_logic_vector(15 downto 0) := (others => '0');
    ram2_init_5         : std_logic_vector(15 downto 0) := (others => '0');
    ram2_init_6         : std_logic_vector(15 downto 0) := (others => '0');
    ram2_init_7         : std_logic_vector(15 downto 0) := (others => '0')      
  );
end test;

architecture sim of test is
  ----------------------------------------
  -- cpu interface signal
  ----------------------------------------
  signal clk_i : std_logic;
  signal rst_i : std_logic;
  signal ack_i : std_logic;
  signal intr_i : std_logic;
  --
  signal sel_o : std_logic_vector(1 downto 0);
  signal stb_o : std_logic;
  signal cyc_o : std_logic;
  signal we_o  : std_logic;
  --
  signal inta_cyc_o : std_logic;
  signal i_cyc_o    : std_logic;
  signal c_cyc_o    : std_logic;
  signal d_cyc_o    : std_logic;
  --
  signal adr_o : std_logic_vector(15 downto 0);
  --
  signal dat_i : std_logic_vector(15 downto 0);
  signal dat_o : std_logic_vector(15 downto 0);
  signal ram_dat_o : std_logic_vector(15 downto 0);
  signal ram2_dat_o : std_logic_vector(15 downto 0);
  -----------------------------------------
  -- ram interfacing
  -----------------------------------------
  signal ram_cs : std_logic;
  signal ram_oe : std_logic; 
  --
  signal ram2_cs : std_logic;
  signal ram2_oe : std_logic;
begin
  ----------------------------------------------------------------------
  clk_gen : process
  begin
    wait for half_clk_period;
    clk_i <= '1';
    wait for half_clk_period;
    clk_i <= '0';    
    if now >= sim_stop_time then
      assert false
        report "simulation completed (not an error)"
        severity error;
      wait;
    end if;    
  end process;
  -----------------------------------------------------------------------
  rst_gen : process
  begin
    wait for half_clk_period;
    rst_i <= '1';
    wait for 4 * clk_period;
    rst_i <= '0';
    wait;
  end process;
  -------------------------------------------------------------------------
  cpu : entity work.cpu 
  generic map
  ( 
    pc_preset_value => cpu_pc_preset_value,  
    sp_preset_value => cpu_sp_preset_value
  )
  port map
  (
     CLK_I => clk_i,
     RST_I => rst_i,
     ACK_I => ack_i,
     INTR_I => intr_i,
     --
     SEL_O => sel_o,
     STB_O => stb_o, 
     CYC_O => cyc_o,
     WE_O => we_o,
     --
     INTA_CYC_O => inta_cyc_o,
     I_CYC_O => i_cyc_o,
     C_CYC_O => c_cyc_o,
     D_CYC_O => d_cyc_o,
     --
     DAT_I => dat_i,
     DAT_O => dat_o,
     ADR_O => adr_o
  );   
-------------------------------------------------- 
  ack_gen : ack_i <= stb_o;
-----------------------------------------------------------------------
  ram_cs_gen : process(stb_o, adr_o)
    variable temp : integer;
    constant max_loc : integer := (2 ** (ram_adr_width + 1)) - 1;
  begin
    if stb_o = '1' then
      temp := conv_integer(adr_o);
      if 0 <= temp and temp <= max_loc then
        ram_cs <= '1';
      else
        ram_cs <= '0';
      end if;
    end if;
  end process ram_cs_gen;
  ----------------------------------------------------------------------
  ram_oe <= not we_o;
  ----------------------------------------------------------------------
  ram: entity work.ramNx16(async)  
  generic map
  (
    init_file_name => file_name_prefix & "_init_ram.txt",    
    adr_width => ram_adr_width
    
  )
  port map
  (
    clk => clk_i,
    adr => adr_o(ram_adr_width downto 1),
    dat_i => dat_o, -- connected to output of cpu
    --
    cs => ram_cs,
    we => we_o,
    ub => sel_o(1),
    lb => sel_o(0),
    oe => ram_oe, 
    --
    dat_o => ram_dat_o
  ); 
--------------------------------------------------
	ram2: entity work.ram8x16 
  generic map
  (
    init_0 => ram2_init_0,
    init_1 => ram2_init_1,
    init_2 => ram2_init_2,
    init_3 => ram2_init_3,
    init_4 => ram2_init_4,
    init_5 => ram2_init_5,
    init_6 => ram2_init_6,
    init_7 => ram2_init_7
    
  )
  port map
  (
    clk => clk_i,
    adr => adr_o(3 downto 1), 
    dat_i => dat_o, -- connected to cpu output
    --
    cs => ram2_cs,
    we => we_o,
    ub => sel_o(1),
    lb => sel_o(0),
    oe => ram2_oe,
    --
    dat_o => ram2_dat_o
  );
-----------------------------------------------
  ram2_oe <= not we_o;
----------------------------------------------
  ram2_cs_gen : process(stb_o, adr_o)
    variable temp : integer;
    constant max_loc : integer := conv_integer(ram2_adr) + 15;
  begin
    if stb_o = '1' then
      temp := conv_integer(adr_o);
      if ram2_adr <= temp and temp <= max_loc then
        ram2_cs <= '1';
      else
        ram2_cs <= '0';
      end if;
    end if;
  end process ram2_cs_gen;
----------------------------------------------
	ram_out_mux : process(ram_cs, ram2_cs, ram_dat_o, ram2_dat_o)
	-- which ram output will drive the cpu's dat_i 
		variable cs : std_logic_vector(1 downto 0);
	begin
		cs := ram_cs & ram2_cs;
		case cs is
			when "10" => dat_i <= ram_dat_o;
			when "01" => dat_i <= ram2_dat_o;
			when others => dat_i <= (others => '0');
		end case;
	end process ram_out_mux;
end sim;