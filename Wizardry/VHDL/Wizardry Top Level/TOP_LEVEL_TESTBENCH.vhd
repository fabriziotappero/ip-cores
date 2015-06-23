----------------------------------------------------------------------------------
--
--  This file is a part of Technica Corporation Wizardry Project
--
--  Copyright (C) 2004-2009, Technica Corporation  
--
--  This program is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published by
--  the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.
--
--  This program is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  GNU General Public License for more details.
--
--  You should have received a copy of the GNU General Public License
--  along with this program.  If not, see <http://www.gnu.org/licenses/>.
--
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
-- Module Name: Top_Level_TESTBENCH - Structural 
-- Project Name: Wizardry
-- Target Devices: Virtex 4 ML401
-- Description: Top-level structural description for Wizardry.
-- Revision: 1.0
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity TOP_LEVEL_TESTBENCH is
port(
		FPGA_reset 									 : in std_logic;
		FPGA_clk_100_top 								 : in std_logic;
		rx				  : in  std_logic;
		tx				  : out  std_logic;
--		leds : out std_logic_vector(8 downto 0);
--		FIFO_empty										: out std_logic;
--	   read_enable									: out std_logic;
--	   write_enable									: out std_logic;
		cntrl0_ddr_dq                        : inout  std_logic_vector(31 downto 0);
		cntrl0_ddr_dqs                       : inout  std_logic_vector(3 downto 0);
		cntrl0_ddr_a                         : out  std_logic_vector(12 downto 0);
		cntrl0_ddr_ba                        : out  std_logic_vector(1 downto 0);
		cntrl0_ddr_cke                       : out std_logic;
		cntrl0_ddr_cs_n                      : out std_logic;
		cntrl0_ddr_ras_n                     : out std_logic;
		cntrl0_ddr_cas_n                     : out std_logic;
		cntrl0_ddr_we_n                      : out std_logic;
		cntrl0_ddr_dm                        : out  std_logic_vector(3 downto 0);
		cntrl0_ddr_ck                        : out  std_logic_vector(1 downto 0);
		cntrl0_ddr_ck_n                      : out  std_logic_vector(1 downto 0);
		
			 -- eRCP and EmPAC Signals to/from top level
	 phy_clock : in std_logic;
	 phy_reset : out std_logic;
	 phy_data_in : in  STD_LOGIC_VECTOR (3 downto 0);
		phy_data_valid_in : in  STD_LOGIC;
--		WIZ_rx_sdata : in  STD_LOGIC;
--		WIZ_tx_sdata : out  STD_LOGIC;
		
	--  Debug Signals to top level
--	rdcount : out std_logic_vector(11 downto 0);
--			   wrcount0 : out std_logic_vector(6 downto 0);
--				empac_empty_debug: out std_logic;
--				empac_full_debug : out std_logic;
				
	---==========================================================--
----===========Virtex-4 SRAM Port============================--
	wd : out std_logic;
	sram_clk : out std_logic;
	sram_feedback_clk : out std_logic;
	
	sram_addr : out std_logic_vector(22 downto 0);
	
	sram_we_n : out std_logic;
	sram_oe_n : out std_logic;

	sram_data : inout std_logic_vector(31 downto 0);
	
	sram_bw0: out std_logic;
	sram_bw1 : out std_logic;
	
	sram_bw2 : out std_Logic;
	sram_bw3 : out std_logic;
	
	sram_adv_ld_n : out std_logic;
	sram_mode : out std_logic;
	sram_cen : out std_logic;
	sram_cen_test : out std_logic;
	sram_zz : out std_logic

---=========================================================---
---=========================================================---
		
		);
end TOP_LEVEL_TESTBENCH;

architecture Behavioral of TOP_LEVEL_TESTBENCH is

signal rdcount : std_logic_Vector(11 downto 0);
signal WIZ_rx_sdata : sTD_LOGIC;
signal WIZ_tx_sdata : STD_LOGIC;
--signal leds : std_logic_vector(8 downto 0);
signal FIFO_empty	: std_logic;
signal read_enable	: std_logic;
signal write_enable	: std_logic;

Component MIG is
  port(
    cntrl0_ddr_dq                        : inout  std_logic_vector(31 downto 0);
    cntrl0_ddr_a                         : out  std_logic_vector(12 downto 0);
    cntrl0_ddr_ba                        : out  std_logic_vector(1 downto 0);
    cntrl0_ddr_cke                       : out std_logic;
    cntrl0_ddr_cs_n                      : out std_logic;
    cntrl0_ddr_ras_n                     : out std_logic;
    cntrl0_ddr_cas_n                     : out std_logic;
    cntrl0_ddr_we_n                      : out std_logic;
    cntrl0_ddr_dm                        : out  std_logic_vector(3 downto 0);
    sys_clk_p                            : in std_logic;
    sys_clk_n                            : in std_logic;
    clk200_p                             : in std_logic;
    clk200_n                             : in std_logic;
	 clk_100_top				: in std_logic;
	 clk_200_top				: in std_logic;
    init_done                            : out std_logic;
    sys_reset_in_n                       : in std_logic;
    cntrl0_clk_tb                        : out std_logic;
    cntrl0_reset_tb                      : out std_logic;
    cntrl0_wdf_almost_full               : out std_logic;
    cntrl0_af_almost_full                : out std_logic;
    cntrl0_read_data_valid               : out std_logic;
    cntrl0_app_wdf_wren                  : in std_logic;
    cntrl0_app_af_wren                   : in std_logic;
    cntrl0_burst_length_div2             : out  std_logic_vector(2 downto 0);
    cntrl0_app_af_addr                   : in  std_logic_vector(35 downto 0);
    cntrl0_app_wdf_data                  : in  std_logic_vector(63 downto 0);
    cntrl0_read_data_fifo_out            : out  std_logic_vector(63 downto 0);
    cntrl0_app_mask_data                 : in  std_logic_vector(7 downto 0);
    cntrl0_ddr_dqs                       : inout  std_logic_vector(3 downto 0);
    cntrl0_ddr_ck                        : out  std_logic_vector(1 downto 0);
    cntrl0_ddr_ck_n                      : out  std_logic_vector(1 downto 0)
         );
end Component;

--signal    cntrl0_ddr_dq                        :   std_logic_vector(31 downto 0);
--signal    cntrl0_ddr_a                         :   std_logic_vector(12 downto 0);
--signal    cntrl0_ddr_ba                        :   std_logic_vector(1 downto 0);
--signal    cntrl0_ddr_cke                       :  std_logic;
--signal    cntrl0_ddr_cs_n                      :  std_logic;
--signal    cntrl0_ddr_ras_n                     :  std_logic;
--signal    cntrl0_ddr_cas_n                     :  std_logic;
--signal    cntrl0_ddr_we_n                      :  std_logic;
--signal    cntrl0_ddr_dm                        :   std_logic_vector(3 downto 0);
signal    sys_clk_p                            : std_logic;
signal    sys_clk_n                            :  std_logic;
signal    clk200_p                             :  std_logic;
signal    clk200_n                             :  std_logic;
signal    init_done                            :  std_logic := '0';
signal    sys_reset_in_n                       :  std_logic;
signal    cntrl0_clk_tb                        :  std_logic;
signal    cntrl0_reset_tb                      :  std_logic;
signal    cntrl0_wdf_almost_full               :  std_logic;
signal    cntrl0_af_almost_full                :  std_logic;
signal    cntrl0_read_data_valid               :  std_logic;
signal    cntrl0_app_wdf_wren                  : std_logic;
signal    cntrl0_app_af_wren                   :  std_logic;
signal    cntrl0_burst_length_div2             :   std_logic_vector(2 downto 0);
signal    cntrl0_app_af_addr                   :   std_logic_vector(35 downto 0);
signal    cntrl0_app_wdf_data                  :   std_logic_vector(63 downto 0);
signal    cntrl0_read_data_fifo_out            :   std_logic_vector(63 downto 0);
signal    cntrl0_app_mask_data                 :   std_logic_vector(7 downto 0);
--signal    cntrl0_ddr_dqs                       :   std_logic_vector(3 downto 0);
--signal    cntrl0_ddr_ck                        :   std_logic_vector(1 downto 0);
--signal    cntrl0_ddr_ck_n                      :   std_logic_vector(1 downto 0);
signal 	 bkend_wraddr_en_s 						  : std_logic;
signal clk_100_top : std_logic;
signal clk_200_top : std_logic;
signal system_clock_100, system_clock_200 : std_logic;
signal clk_100_top_fb : std_logic;
signal dcm_lock : std_logic;

signal 		DCM_reset : std_logic;
signal 		DCM_reset_0 : std_logic;
signal 		DCM_reset_1 : std_logic;
signal 		DCM_reset_2 : std_logic;
signal 		DCM_reset_3 : std_logic;

signal 		system_reset : std_logic;
signal 		system_reset_0 : std_logic;
signal 		system_reset_1 : std_logic;
signal 		system_reset_2 : std_logic;
signal 		system_reset_3 : std_logic;
signal 		phy_reset_dummy : std_logic;
signal wrcount : std_logic_vector(11 downto 0);

component MIG_addr_gen is
  port (
    clk0            : in  std_logic;
    rst             : in  std_logic;
    bkend_wraddr_en : in  std_logic;
	 rx				  : in  std_logic;
	 tx				  : out  std_logic;
--	 leds : out std_logic_vector(8 downto 0);
    cntrl0_app_af_addr     : out std_logic_vector(35 downto 0);
    cntrl0_app_af_wren     : out std_logic;
	 cntrl0_app_mask_data                 : out  std_logic_vector(7 downto 0);
	 cntrl0_app_wdf_wren                  : out std_logic;
	 cntrl0_app_wdf_data                  : out  std_logic_vector(63 downto 0);
	 cntrl0_read_data_valid               : in std_logic;
	 cntrl0_read_data_fifo_out            : in  std_logic_vector(63 downto 0);
	 init_done									  : in std_logic;
	 FIFO_empty										: out std_logic;
	 read_enable									: out std_logic;
	 write_enable									: out std_logic;
	 
	 -- eRCP and EmPAC Signals to/from top level
	 phy_clock : in std_logic;
	 phy_reset : out std_logic;
	 phy_data_in : in  STD_LOGIC_VECTOR (3 downto 0);
		phy_data_valid_in : in  STD_LOGIC;
		WIZ_rx_sdata : in  STD_LOGIC;
		WIZ_tx_sdata : out  STD_LOGIC;
		
	--  Debug Signals to top level
--	rdcount : out std_logic_vector(11 downto 0);
--			   wrcount : out std_logic_vector(11 downto 0);
--				empac_empty_debug: out std_logic;
--				empac_full_debug : out std_logic;
				
	---==========================================================--
----===========Virtex-4 SRAM Port============================--
	wd : out std_logic;
	sram_clk : out std_logic;
	sram_feedback_clk : out std_logic;
	
	sram_addr : out std_logic_vector(22 downto 0);
	
	sram_we_n : out std_logic;
	sram_oe_n : out std_logic;

	sram_data : inout std_logic_vector(31 downto 0);
	
	sram_bw0: out std_logic;
	sram_bw1 : out std_logic;
	
	sram_bw2 : out std_Logic;
	sram_bw3 : out std_logic;
	
	sram_adv_ld_n : out std_logic;
	sram_mode : out std_logic;
	sram_cen : out std_logic;
	sram_cen_test : out std_logic;
	sram_zz : out std_logic	
		
	
    );
end component;

Component MT46V16M16 IS
    GENERIC (                                   -- Timing for -75Z CL2
        tCK       : TIME    :=  7.500 ns;
        tCH       : TIME    :=  3.375 ns;       -- 0.45*tCK
        tCL       : TIME    :=  3.375 ns;       -- 0.45*tCK
        tDH       : TIME    :=  0.500 ns;
        tDS       : TIME    :=  0.500 ns;
        tIH       : TIME    :=  0.900 ns;
        tIS       : TIME    :=  0.900 ns;
        tMRD      : TIME    := 15.000 ns;
        tRAS      : TIME    := 40.000 ns;
        tRAP      : TIME    := 20.000 ns;
        tRC       : TIME    := 65.000 ns;
        tRFC      : TIME    := 75.000 ns;
        tRCD      : TIME    := 20.000 ns;
        tRP       : TIME    := 20.000 ns;
        tRRD      : TIME    := 15.000 ns;
        tWR       : TIME    := 15.000 ns;
        addr_bits : INTEGER := 13;
        data_bits : INTEGER := 16;
        cols_bits : INTEGER :=  9
    );
    PORT (
        Dq    : INOUT STD_LOGIC_VECTOR (data_bits - 1 DOWNTO 0) := (OTHERS => 'Z');
        Dqs   : INOUT STD_LOGIC_VECTOR (1 DOWNTO 0) := "ZZ";
        Addr  : IN    STD_LOGIC_VECTOR (addr_bits - 1 DOWNTO 0);
        Ba    : IN    STD_LOGIC_VECTOR (1 DOWNTO 0);
        Clk   : IN    STD_LOGIC;
        Clk_n : IN    STD_LOGIC;
        Cke   : IN    STD_LOGIC;
        Cs_n  : IN    STD_LOGIC;
        Ras_n : IN    STD_LOGIC;
        Cas_n : IN    STD_LOGIC;
        We_n  : IN    STD_LOGIC;
        Dm    : IN    STD_LOGIC_VECTOR (1 DOWNTO 0)
    );
END component;


begin
phy_reset <= fpga_reset;
MEMORY_DESIGN : MIG
  port map(
    cntrl0_ddr_dq                        => cntrl0_ddr_dq,
    cntrl0_ddr_a                         => cntrl0_ddr_a,
    cntrl0_ddr_ba                        => cntrl0_ddr_ba,
    cntrl0_ddr_cke                       => cntrl0_ddr_cke,
    cntrl0_ddr_cs_n                      => cntrl0_ddr_cs_n,
    cntrl0_ddr_ras_n                     => cntrl0_ddr_ras_n,
    cntrl0_ddr_cas_n                     => cntrl0_ddr_cas_n,
    cntrl0_ddr_we_n                      => cntrl0_ddr_we_n,
    cntrl0_ddr_dm                        => cntrl0_ddr_dm,
    sys_clk_p                            => sys_clk_p,
    sys_clk_n                            => sys_clk_n,
    clk200_p                             => clk200_p,
    clk200_n                             => clk200_n,
	 clk_100_top				=> clk_100_top,
	 clk_200_top				=> clk_200_top,
    init_done                            => init_done,
    sys_reset_in_n                       => system_reset,
    cntrl0_clk_tb                        => cntrl0_clk_tb,
    cntrl0_reset_tb                      => cntrl0_reset_tb,
    cntrl0_wdf_almost_full               => cntrl0_wdf_almost_full,
    cntrl0_af_almost_full                => cntrl0_af_almost_full,
    cntrl0_read_data_valid               => cntrl0_read_data_valid,
    cntrl0_app_wdf_wren                  => cntrl0_app_wdf_wren,
    cntrl0_app_af_wren                   => cntrl0_app_af_wren,
    cntrl0_burst_length_div2             => cntrl0_burst_length_div2,
    cntrl0_app_af_addr                   => cntrl0_app_af_addr,
    cntrl0_app_wdf_data                  => cntrl0_app_wdf_data,
    cntrl0_read_data_fifo_out            => cntrl0_read_data_fifo_out,
    cntrl0_app_mask_data                 => cntrl0_app_mask_data,
    cntrl0_ddr_dqs                       => cntrl0_ddr_dqs,
    cntrl0_ddr_ck                        => cntrl0_ddr_ck,
    cntrl0_ddr_ck_n                      => cntrl0_ddr_ck_n
         );

Address_Generation : MIG_addr_gen
  port map(
    clk0            => cntrl0_clk_tb,
    rst             => cntrl0_reset_tb,
    bkend_wraddr_en => bkend_wraddr_en_s,
	 rx				  => rx,
	 tx				  => tx,
--	 leds 			  => leds,
	 cntrl0_app_af_addr     => cntrl0_app_af_addr,
    cntrl0_app_af_wren     => cntrl0_app_af_wren,
	 cntrl0_app_mask_data                 => cntrl0_app_mask_data,
	 cntrl0_app_wdf_wren                  => cntrl0_app_wdf_wren,
	 cntrl0_app_wdf_data                  => cntrl0_app_wdf_data,
	 cntrl0_read_data_valid               => cntrl0_read_data_valid,
	 cntrl0_read_data_fifo_out            => cntrl0_read_data_fifo_out,
	 init_done									  => init_done,
	 FIFO_empty									=> FIFO_empty,
	 read_enable								=> read_enable,
	 write_enable								=> write_enable,
	 
	 -- eRCP and EmPAC Signals to/from top level
	 phy_clock => phy_clock,
	 phy_reset => phy_reset_dummy, --open,--phy_reset,
	 phy_data_in => phy_data_in,
	 phy_data_valid_in => phy_data_valid_in,
				WIZ_rx_sdata => WIZ_rx_sdata,
				WIZ_tx_sdata => WIZ_tx_sdata,
--				,
	
	--  Debug Signals to top level
--	rdcount => rdcount,
--			   wrcount => wrcount,
--				empac_empty_debug => empac_empty_debug,
--				empac_full_debug => empac_full_debug,
				
	---==========================================================--
----===========Virtex-4 SRAM Port============================--
	wd => wd,
	sram_clk => sram_clk,
	sram_feedback_clk => sram_feedback_clk,
	
	sram_addr => sram_addr,
	
	sram_we_n => sram_we_n, 
	sram_oe_n => sram_oe_n,

	sram_data => sram_data,
	
	sram_bw0 => sram_bw0,
	sram_bw1 => sram_bw1,
	
	sram_bw2 => sram_bw2,
	sram_bw3 => sram_bw3,
	
	sram_adv_ld_n => sram_adv_ld_n,
	sram_mode => sram_mode,
	sram_cen => sram_cen,
	sram_cen_test => sram_cen_test,
	sram_zz =>sram_zz

---=========================================================---
---=========================================================---
				
    );
--wrcount0 <= wrcount(6 downto 0);
--SIM_RAM_0 : MT46V16M16
-- --   GENERIC MAP(                                   -- Timing for -75Z CL2
----        tCK       : TIME    :=  7.500 ns;
----        tCH       : TIME    :=  3.375 ns;       -- 0.45*tCK
----        tCL       : TIME    :=  3.375 ns;       -- 0.45*tCK
----        tDH       : TIME    :=  0.500 ns;
----        tDS       : TIME    :=  0.500 ns;
----        tIH       : TIME    :=  0.900 ns;
----        tIS       : TIME    :=  0.900 ns;
----        tMRD      : TIME    := 15.000 ns;
----        tRAS      : TIME    := 40.000 ns;
----        tRAP      : TIME    := 20.000 ns;
----        tRC       : TIME    := 65.000 ns;
----        tRFC      : TIME    := 75.000 ns;
----        tRCD      : TIME    := 20.000 ns;
----        tRP       : TIME    := 20.000 ns;
----        tRRD      : TIME    := 15.000 ns;
----        tWR       : TIME    := 15.000 ns;
----        addr_bits : INTEGER := 13;
-- --       data_bits : INTEGER := 32;
----        cols_bits : INTEGER :=  9
----    );
--    PORT MAP(
--        Dq    => cntrl0_ddr_dq(15 downto 0),
--        Dqs   => cntrl0_ddr_dqs(1 downto 0),
--        Addr  => cntrl0_ddr_a,
--        Ba    => cntrl0_ddr_ba,
--        Clk   => cntrl0_ddr_ck(0),
--        Clk_n => cntrl0_ddr_ck_n(0),
--        Cke   => cntrl0_ddr_cke,
--        Cs_n  => cntrl0_ddr_cs_n,
--        Ras_n => cntrl0_ddr_ras_n,
--        Cas_n => cntrl0_ddr_cas_n,
--        We_n  => cntrl0_ddr_we_n,
--        Dm    => cntrl0_ddr_dm(1 downto 0)
--    );
--
--
--SIM_RAM_1 : MT46V16M16
-- --   GENERIC MAP(                                   -- Timing for -75Z CL2
----        tCK       : TIME    :=  7.500 ns;
----        tCH       : TIME    :=  3.375 ns;       -- 0.45*tCK
----        tCL       : TIME    :=  3.375 ns;       -- 0.45*tCK
----        tDH       : TIME    :=  0.500 ns;
----        tDS       : TIME    :=  0.500 ns;
----        tIH       : TIME    :=  0.900 ns;
----        tIS       : TIME    :=  0.900 ns;
----        tMRD      : TIME    := 15.000 ns;
----        tRAS      : TIME    := 40.000 ns;
----        tRAP      : TIME    := 20.000 ns;
----        tRC       : TIME    := 65.000 ns;
----        tRFC      : TIME    := 75.000 ns;
----        tRCD      : TIME    := 20.000 ns;
----        tRP       : TIME    := 20.000 ns;
----        tRRD      : TIME    := 15.000 ns;
----        tWR       : TIME    := 15.000 ns;
----        addr_bits : INTEGER := 13;
-- --       data_bits : INTEGER := 32;
----        cols_bits : INTEGER :=  9
----    );
--    PORT MAP(
--        Dq    => cntrl0_ddr_dq(31 downto 16),
--        Dqs   => cntrl0_ddr_dqs(3 downto 2),
--        Addr  => cntrl0_ddr_a,
--        Ba    => cntrl0_ddr_ba,
--        Clk   => cntrl0_ddr_ck(0),
--        Clk_n => cntrl0_ddr_ck_n(0),
--        Cke   => cntrl0_ddr_cke,
--        Cs_n  => cntrl0_ddr_cs_n,
--        Ras_n => cntrl0_ddr_ras_n,
--        Cas_n => cntrl0_ddr_cas_n,
--        We_n  => cntrl0_ddr_we_n,
--        Dm    => cntrl0_ddr_dm(3 downto 2)
--    );
--	 
	 DCM_BASE0: DCM_BASE
    generic map(
             CLKDV_DIVIDE      => 16.0,
             CLKFX_DIVIDE      => 8,
             CLKFX_MULTIPLY    => 2,
             DCM_PERFORMANCE_MODE  => "MAX_SPEED",
             DFS_FREQUENCY_MODE    => "LOW",
             DLL_FREQUENCY_MODE    => "LOW",
             DUTY_CYCLE_CORRECTION => TRUE,
             FACTORY_JF            => X"F0F0"
           )
    port map(
          CLK0      => clk_100_top,
          CLK180    => open,
          CLK270    => open,
          CLK2X     => clk_200_top,
          CLK2X180  => open,
          CLK90     => open,
          CLKDV     => open,
          CLKFX     => open,
          CLKFX180  => open,
          LOCKED    => dcm_lock,
          CLKFB     => clk_100_top_fb,
          CLKIN     => FPGA_clk_100_top,
          RST       => DCM_reset
        );
		  
	system_clock_100_bufg: BUFG
    port map (
      O => clk_100_top_fb,
      I => clk_100_top
    );

reset_DCM : process(FPGA_clk_100_top,FPGA_reset)
begin
	if(FPGA_reset = '0') then
		DCM_reset <= '1';
		DCM_reset_0 <= '1';
		DCM_reset_1 <= '1';
		DCM_reset_2 <= '1';
		DCM_reset_3 <= '1';
	elsif (FPGA_clk_100_top'event and FPGA_clk_100_top = '1') then
		DCM_reset <= DCM_reset_0;
		DCM_reset_0 <= DCM_reset_1;
		DCM_reset_1 <= DCM_reset_2;
		DCM_reset_2 <= DCM_reset_3;
		DCM_reset_3 <= '0';
	end if;
end process reset_DCM;

-- Backup Version
--reset_DCM : process(FPGA_clk_100_top,FPGA_reset)
--begin
--	if(FPGA_reset = '0') then
--		DCM_reset <= '1';
--		DCM_reset_0 <= '1';
--		DCM_reset_1 <= '1';
--		DCM_reset_2 <= '1';
--		DCM_reset_3 <= '1';
--	else
--		DCM_reset <= DCM_reset_0;
--		DCM_reset_0 <= DCM_reset_1;
--		DCM_reset_1 <= DCM_reset_2;
--		DCM_reset_2 <= DCM_reset_3;
--		DCM_reset_3 <= '0';
--	end if;
--end process reset_DCM;

  process(clk_100_top, dcm_lock)
  begin
    if (dcm_lock = '0') then
      system_reset <= '0';
		system_reset_0 <= '0';
		system_reset_1 <= '0';
		system_reset_2 <= '0';
		system_reset_3 <= '0';
    elsif (clk_100_top'event and clk_100_top = '1') then
      system_reset <= system_reset_0;
		system_reset_0 <= system_reset_1;
		system_reset_1 <= system_reset_2;
		system_reset_2 <= system_reset_3;
		system_reset_3 <= '1';
    end if;
  end process;


end Behavioral;

