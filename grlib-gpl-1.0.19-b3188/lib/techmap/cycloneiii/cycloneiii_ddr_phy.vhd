------------------------------------------------------------------------------
--  This file is a part of the GRLIB VHDL IP LIBRARY
--  Copyright (C) 2003, Gaisler Research
--
--  This program is free software; you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published by
--  the Free Software Foundation; either version 2 of the License, or
--  (at your option) any later version.
--
--  This program is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  GNU General Public License for more details.
--
--  You should have received a copy of the GNU General Public License
--  along with this program; if not, write to the Free Software
--  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA 
-----------------------------------------------------------------------------
-- Entity: 	cycloneiii_ddr_phy
-- File:	cycloneiii_ddr_phy.vhd
-- Author:	Jiri Gaisler, Gaisler Research
-- Description:	DDR PHY for Altera FPGAs
------------------------------------------------------------------------------

 LIBRARY cycloneiii;
 USE cycloneiii.all;

 LIBRARY ieee;
 USE ieee.std_logic_1164.all;

 ENTITY  altdqs_cyciii_adqs_n7i2 IS 
	 generic (width : integer := 2; period : string := "10000ps");
	 PORT 
	 ( 
		 dll_delayctrlout	:	OUT  STD_LOGIC_VECTOR (5 DOWNTO 0);
		 dqinclk	:	OUT  STD_LOGIC_VECTOR (width-1 downto 0);
		 dqs_datain_h	:	IN  STD_LOGIC_VECTOR (width-1 downto 0);
		 dqs_datain_l	:	IN  STD_LOGIC_VECTOR (width-1 downto 0);
		 dqs_padio	:	INOUT  STD_LOGIC_VECTOR (width-1 downto 0);
		 dqsundelayedout	:	OUT  STD_LOGIC_VECTOR (width-1 downto 0);
		 inclk	:	IN  STD_LOGIC := '0';
		 oe	:	IN  STD_LOGIC_VECTOR (width-1 downto 0) := (OTHERS => '1');
		 outclk	:	IN  STD_LOGIC_VECTOR (width-1 downto 0);
		 outclkena	:	IN  STD_LOGIC_VECTOR (width-1 downto 0) := (OTHERS => '1')
	 ); 
 END altdqs_cyciii_adqs_n7i2;

 ARCHITECTURE RTL OF altdqs_cyciii_adqs_n7i2 IS

--	 ATTRIBUTE synthesis_clearbox : boolean;
--	 ATTRIBUTE synthesis_clearbox OF RTL : ARCHITECTURE IS true;
	 SIGNAL  wire_cyciii_dll1_delayctrlout	:	STD_LOGIC_VECTOR (5 DOWNTO 0);
	 SIGNAL  wire_cyciii_dll1_dqsupdate	:	STD_LOGIC;
	 SIGNAL  wire_cyciii_dll1_offsetctrlout	:	STD_LOGIC_VECTOR (5 DOWNTO 0);
	 SIGNAL  wire_cyciii_io2a_combout	:	STD_LOGIC_VECTOR (width-1 downto 0);
	 SIGNAL  wire_cyciii_io2a_datain	:	STD_LOGIC_VECTOR (width-1 downto 0);
	 SIGNAL  wire_cyciii_io2a_ddiodatain	:	STD_LOGIC_VECTOR (width-1 downto 0);
	 SIGNAL  wire_cyciii_io2a_dqsbusout	:	STD_LOGIC_VECTOR (width-1 downto 0);
	 SIGNAL  wire_cyciii_io2a_oe	:	STD_LOGIC_VECTOR (width-1 downto 0);
	 SIGNAL  wire_cyciii_io2a_outclk	:	STD_LOGIC_VECTOR (width-1 downto 0);
	 SIGNAL  wire_cyciii_io2a_outclkena	:	STD_LOGIC_VECTOR (width-1 downto 0);
	 SIGNAL  delay_ctrl :	STD_LOGIC_VECTOR (5 DOWNTO 0);
	 SIGNAL  dqs_update :	STD_LOGIC;
	 SIGNAL  offset_ctrl :	STD_LOGIC_VECTOR (5 DOWNTO 0);
	 COMPONENT  cycloneiii_dll
	 GENERIC 
	 (
		DELAY_BUFFER_MODE	:	STRING := "low";
		DELAY_CHAIN_LENGTH	:	NATURAL := 12;
		DELAYCTRLOUT_MODE	:	STRING := "normal";
		INPUT_FREQUENCY	:	STRING;
		JITTER_REDUCTION	:	STRING := "false";
		OFFSETCTRLOUT_MODE	:	STRING := "static";
		SIM_LOOP_DELAY_INCREMENT	:	NATURAL := 0;
		SIM_LOOP_INTRINSIC_DELAY	:	NATURAL := 0;
		SIM_VALID_LOCK	:	NATURAL := 5;
		SIM_VALID_LOCKCOUNT	:	NATURAL := 0;
		STATIC_DELAY_CTRL	:	NATURAL := 0;
		STATIC_OFFSET	:	STRING;
		USE_UPNDNIN	:	STRING := "false";
		USE_UPNDNINCLKENA	:	STRING := "false";
		lpm_type	:	STRING := "cycloneiii_dll"
	 );
	 PORT
	 ( 
		addnsub	:	IN STD_LOGIC := '1';
		aload	:	IN STD_LOGIC := '0';
		clk	:	IN STD_LOGIC;
		delayctrlout	:	OUT STD_LOGIC_VECTOR(5 DOWNTO 0);
		dqsupdate	:	OUT STD_LOGIC;
		offset	:	IN STD_LOGIC_VECTOR(5 DOWNTO 0) := (OTHERS => '0');
		offsetctrlout	:	OUT STD_LOGIC_VECTOR(5 DOWNTO 0);
		upndnin	:	IN STD_LOGIC := '0';
		upndninclkena	:	IN STD_LOGIC := '1';
		upndnout	:	OUT STD_LOGIC
	 ); 
	 END COMPONENT;
	 COMPONENT  cycloneiii_io
	 GENERIC 
	 (
		BUS_HOLD	:	STRING := "false";
		DDIO_MODE	:	STRING := "none";
		DDIOINCLK_INPUT	:	STRING := "negated_inclk";
		DQS_CTRL_LATCHES_ENABLE	:	STRING := "false";
		DQS_DELAY_BUFFER_MODE	:	STRING := "none";
		DQS_EDGE_DETECT_ENABLE	:	STRING := "false";
		DQS_INPUT_FREQUENCY	:	STRING := "unused";
		DQS_OFFSETCTRL_ENABLE	:	STRING := "false";
		DQS_OUT_MODE	:	STRING := "none";
		DQS_PHASE_SHIFT	:	NATURAL := 0;
		EXTEND_OE_DISABLE	:	STRING := "false";
		GATED_DQS	:	STRING := "false";
		INCLK_INPUT	:	STRING := "normal";
		INPUT_ASYNC_RESET	:	STRING := "none";
		INPUT_POWER_UP	:	STRING := "low";
		INPUT_REGISTER_MODE	:	STRING := "none";
		INPUT_SYNC_RESET	:	STRING := "none";
		OE_ASYNC_RESET	:	STRING := "none";
		OE_POWER_UP	:	STRING := "low";
		OE_REGISTER_MODE	:	STRING := "none";
		OE_SYNC_RESET	:	STRING := "none";
		OPEN_DRAIN_OUTPUT	:	STRING := "false";
		OPERATION_MODE	:	STRING;
		OUTPUT_ASYNC_RESET	:	STRING := "none";
		OUTPUT_POWER_UP	:	STRING := "low";
		OUTPUT_REGISTER_MODE	:	STRING := "none";
		OUTPUT_SYNC_RESET	:	STRING := "none";
		SIM_DQS_DELAY_INCREMENT	:	NATURAL := 0;
		SIM_DQS_INTRINSIC_DELAY	:	NATURAL := 0;
		SIM_DQS_OFFSET_INCREMENT	:	NATURAL := 0;
		TIE_OFF_OE_CLOCK_ENABLE	:	STRING := "false";
		TIE_OFF_OUTPUT_CLOCK_ENABLE	:	STRING := "false";
		lpm_type	:	STRING := "cycloneiii_io"
	 );
	 PORT
	 ( 
		areset	:	IN STD_LOGIC := '0';
		combout	:	OUT STD_LOGIC;
		datain	:	IN STD_LOGIC := '0';
		ddiodatain	:	IN STD_LOGIC := '0';
		ddioinclk	:	IN STD_LOGIC := '0';
		ddioregout	:	OUT STD_LOGIC;
		delayctrlin	:	IN STD_LOGIC_VECTOR(5 DOWNTO 0) := (OTHERS => '0');
		dqsbusout	:	OUT STD_LOGIC;
		dqsupdateen	:	IN STD_LOGIC := '1';
		inclk	:	IN STD_LOGIC := '0';
		inclkena	:	IN STD_LOGIC := '1';
		linkin	:	IN STD_LOGIC := '0';
		linkout	:	OUT STD_LOGIC;
		oe	:	IN STD_LOGIC := '1';
		offsetctrlin	:	IN STD_LOGIC_VECTOR(5 DOWNTO 0) := (OTHERS => '0');
		outclk	:	IN STD_LOGIC := '0';
		outclkena	:	IN STD_LOGIC := '1';
		padio	:	INOUT STD_LOGIC;
		regout	:	OUT STD_LOGIC;
		sreset	:	IN STD_LOGIC := '0';
		terminationcontrol	:	IN STD_LOGIC_VECTOR(13 DOWNTO 0) := (OTHERS => '0')
	 ); 
	 END COMPONENT;
 BEGIN

	delay_ctrl <= wire_cyciii_dll1_delayctrlout;
	dll_delayctrlout <= delay_ctrl;
	dqinclk <= wire_cyciii_io2a_dqsbusout;
	dqs_update <= wire_cyciii_dll1_dqsupdate;
	dqsundelayedout <= wire_cyciii_io2a_combout;
	offset_ctrl <= wire_cyciii_dll1_offsetctrlout;
	cyciii_dll1 :  cycloneiii_dll
	  GENERIC MAP (
		DELAY_BUFFER_MODE => "low",
		DELAY_CHAIN_LENGTH => 12,
		DELAYCTRLOUT_MODE => "normal",
		INPUT_FREQUENCY => period, --"10000ps",
		JITTER_REDUCTION => "false",
		OFFSETCTRLOUT_MODE => "static",
		SIM_LOOP_DELAY_INCREMENT => 132,
		SIM_LOOP_INTRINSIC_DELAY => 3840,
		SIM_VALID_LOCK => 1,
		SIM_VALID_LOCKCOUNT => 46,
		STATIC_OFFSET => "0",
		USE_UPNDNIN => "false",
		USE_UPNDNINCLKENA => "false"
	  )
	  PORT MAP ( 
		clk => inclk,
		delayctrlout => wire_cyciii_dll1_delayctrlout,
		dqsupdate => wire_cyciii_dll1_dqsupdate,
		offsetctrlout => wire_cyciii_dll1_offsetctrlout
	  );
	wire_cyciii_io2a_datain <= dqs_datain_h;
	wire_cyciii_io2a_ddiodatain <= dqs_datain_l;
	wire_cyciii_io2a_oe <= oe;
	wire_cyciii_io2a_outclk <= outclk;
	wire_cyciii_io2a_outclkena <= outclkena;
	loop0 : FOR i IN 0 TO width-1 GENERATE 
	  cyciii_io2a :  cycloneiii_io
	  GENERIC MAP (
		DDIO_MODE => "output",
		DQS_CTRL_LATCHES_ENABLE => "true",
		DQS_DELAY_BUFFER_MODE => "low",
		DQS_EDGE_DETECT_ENABLE => "false",
		DQS_INPUT_FREQUENCY => period, --"10000ps",
		DQS_OFFSETCTRL_ENABLE => "true",
		DQS_OUT_MODE => "delay_chain3",
		DQS_PHASE_SHIFT => 9000,
		EXTEND_OE_DISABLE => "false",
		GATED_DQS => "false",
		OE_ASYNC_RESET => "none",
		OE_POWER_UP => "low",
		OE_REGISTER_MODE => "register",
		OE_SYNC_RESET => "none",
		OPEN_DRAIN_OUTPUT => "false",
		OPERATION_MODE => "bidir",
		OUTPUT_ASYNC_RESET => "none",
		OUTPUT_POWER_UP => "low",
		OUTPUT_REGISTER_MODE => "register",
		OUTPUT_SYNC_RESET => "none",
		SIM_DQS_DELAY_INCREMENT => 22,
		SIM_DQS_INTRINSIC_DELAY => 960,
		SIM_DQS_OFFSET_INCREMENT => 11,
		TIE_OFF_OE_CLOCK_ENABLE => "false",
		TIE_OFF_OUTPUT_CLOCK_ENABLE => "false"
	  )
	  PORT MAP ( 
		combout => wire_cyciii_io2a_combout(i),
		datain => wire_cyciii_io2a_datain(i),
		ddiodatain => wire_cyciii_io2a_ddiodatain(i),
		delayctrlin => delay_ctrl,
		dqsbusout => wire_cyciii_io2a_dqsbusout(i),
		dqsupdateen => dqs_update,
		oe => wire_cyciii_io2a_oe(i),
		offsetctrlin => offset_ctrl,
		outclk => wire_cyciii_io2a_outclk(i),
		outclkena => wire_cyciii_io2a_outclkena(i),
		padio => dqs_padio(i)
	  );
	END GENERATE loop0;

 END RTL; --altdqs_cyciii_adqs_n7i2

LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY altdqs_cyciii IS
	generic (width : integer := 2; period : string := "10000ps");
	PORT
	(
		dqs_datain_h		: IN STD_LOGIC_VECTOR (width-1 downto 0);
		dqs_datain_l		: IN STD_LOGIC_VECTOR (width-1 downto 0);
		inclk		: IN STD_LOGIC ;
		oe		: IN STD_LOGIC_VECTOR (width-1 downto 0);
		outclk		: IN STD_LOGIC_VECTOR (width-1 downto 0);
		dll_delayctrlout		: OUT STD_LOGIC_VECTOR (5 DOWNTO 0);
		dqinclk		: OUT STD_LOGIC_VECTOR (width-1 downto 0);
		dqs_padio		: INOUT STD_LOGIC_VECTOR (width-1 downto 0);
		dqsundelayedout		: OUT STD_LOGIC_VECTOR (width-1 downto 0)
	);
END;


ARCHITECTURE RTL OF altdqs_cyciii IS

--	ATTRIBUTE synthesis_clearbox: boolean;
--	ATTRIBUTE synthesis_clearbox OF RTL: ARCHITECTURE IS TRUE;
	SIGNAL sub_wire0	: STD_LOGIC_VECTOR (5 DOWNTO 0);
	SIGNAL sub_wire1	: STD_LOGIC_VECTOR (width-1 downto 0);
	SIGNAL sub_wire2	: STD_LOGIC_VECTOR (width-1 downto 0);
	SIGNAL sub_wire3_bv	: BIT_VECTOR (width-1 downto 0);
	SIGNAL sub_wire3	: STD_LOGIC_VECTOR (width-1 downto 0);



	COMPONENT altdqs_cyciii_adqs_n7i2
	generic (width : integer := 2; period : string := "10000ps");
	PORT (
			outclk	: IN STD_LOGIC_VECTOR (width-1 downto 0);
			dqs_padio	: INOUT STD_LOGIC_VECTOR (width-1 downto 0);
			outclkena	: IN STD_LOGIC_VECTOR (width-1 downto 0);
			oe	: IN STD_LOGIC_VECTOR (width-1 downto 0);
			dqs_datain_h	: IN STD_LOGIC_VECTOR (width-1 downto 0);
			inclk	: IN STD_LOGIC ;
			dqs_datain_l	: IN STD_LOGIC_VECTOR (width-1 downto 0);
			dll_delayctrlout	: OUT STD_LOGIC_VECTOR (5 DOWNTO 0);
			dqinclk	: OUT STD_LOGIC_VECTOR (width-1 downto 0);
			dqsundelayedout	: OUT STD_LOGIC_VECTOR (width-1 downto 0)
	);
	END COMPONENT;

BEGIN
	sub_wire3_bv(width-1 downto 0) <= (others => '1');
	sub_wire3    <= To_stdlogicvector(sub_wire3_bv);
	dll_delayctrlout    <= sub_wire0(5 DOWNTO 0);
	dqinclk    <= not sub_wire1(width-1 downto 0);
	dqsundelayedout    <= sub_wire2(width-1 downto 0);

	altdqs_cyciii_adqs_n7i2_component : altdqs_cyciii_adqs_n7i2
	generic map (width, period)
	PORT MAP (
		outclk => outclk,
		outclkena => sub_wire3,
		oe => oe,
		dqs_datain_h => dqs_datain_h,
		inclk => inclk,
		dqs_datain_l => dqs_datain_l,
		dll_delayctrlout => sub_wire0,
		dqinclk => sub_wire1,
		dqsundelayedout => sub_wire2,
		dqs_padio => dqs_padio
	);



END RTL;

library ieee;
use ieee.std_logic_1164.all;

library grlib;
use grlib.stdlib.all;
library techmap;
use techmap.gencomp.all;

library altera_mf;
use altera_mf.altera_mf_components.all;


------------------------------------------------------------------
-- CYCLONEIII DDR PHY --------------------------------------------
------------------------------------------------------------------

entity cycloneiii_ddr_phy is
  generic (MHz : integer := 100; rstdelay : integer := 200;
	dbits : integer := 16; clk_mul : integer := 2 ;
	clk_div : integer := 2);

  port (
    rst       : in  std_ulogic;
    clk       : in  std_logic;          	-- input clock
    clkout    : out std_ulogic;			-- system clock
    lock      : out std_ulogic;			-- DCM locked

    ddr_clk 	: out std_logic_vector(2 downto 0);
    ddr_clkb	: out std_logic_vector(2 downto 0);
    ddr_clk_fb_out  : out std_logic;
    ddr_clk_fb  : in std_logic;
    ddr_cke  	: out std_logic_vector(1 downto 0);
    ddr_csb  	: out std_logic_vector(1 downto 0);
    ddr_web  	: out std_ulogic;                       -- ddr write enable
    ddr_rasb  	: out std_ulogic;                       -- ddr ras
    ddr_casb  	: out std_ulogic;                       -- ddr cas
    ddr_dm   	: out std_logic_vector (dbits/8-1 downto 0);    -- ddr dm
    ddr_dqs  	: inout std_logic_vector (dbits/8-1 downto 0);    -- ddr dqs
    ddr_ad      : out std_logic_vector (13 downto 0);   -- ddr address
    ddr_ba      : out std_logic_vector (1 downto 0);    -- ddr bank address
    ddr_dq    	: inout  std_logic_vector (dbits-1 downto 0); -- ddr data
 
    addr  	: in  std_logic_vector (13 downto 0); -- data mask
    ba    	: in  std_logic_vector ( 1 downto 0); -- data mask
    dqin  	: out std_logic_vector (dbits*2-1 downto 0); -- ddr input data
    dqout 	: in  std_logic_vector (dbits*2-1 downto 0); -- ddr input data
    dm    	: in  std_logic_vector (dbits/4-1 downto 0); -- data mask
    oen       	: in  std_ulogic;
    dqs       	: in  std_ulogic;
    dqsoen     	: in  std_ulogic;
    rasn      	: in  std_ulogic;
    casn      	: in  std_ulogic;
    wen       	: in  std_ulogic;
    csn       	: in  std_logic_vector(1 downto 0);
    cke       	: in  std_logic_vector(1 downto 0)
  );

end;

architecture rtl of cycloneiii_ddr_phy is

signal vcc, gnd, dqsn, oe, lockl : std_logic;
signal ddr_clk_fb_outr : std_ulogic;
signal ddr_clk_fbl, fbclk : std_ulogic;
signal ddr_rasnr, ddr_casnr, ddr_wenr : std_ulogic;
signal ddr_clkl, ddr_clkbl : std_logic_vector(2 downto 0);
signal ddr_csnr, ddr_ckenr, ckel : std_logic_vector(1 downto 0);
signal clk_0ro, clk_90ro, clk_180ro, clk_270ro : std_ulogic;
signal clk_0r, clk_90r, clk_180r, clk_270r : std_ulogic;
signal clk0r, clk90r, clk180r, clk270r : std_ulogic;
signal locked, vlockl, ddrclkfbl : std_ulogic;
signal clk4, clk5 : std_logic;

signal ddr_dqin  	: std_logic_vector (dbits-1 downto 0); -- ddr data
signal ddr_dqout  	: std_logic_vector (dbits-1 downto 0); -- ddr data
signal ddr_dqoen  	: std_logic_vector (dbits-1 downto 0); -- ddr data
signal ddr_adr      	: std_logic_vector (13 downto 0);   -- ddr address
signal ddr_bar      	: std_logic_vector (1 downto 0);   -- ddr address
signal ddr_dmr      	: std_logic_vector (dbits/8-1 downto 0);   -- ddr address
signal ddr_dqsin  	: std_logic_vector (dbits/8-1 downto 0);    -- ddr dqs
signal ddr_dqsoen 	: std_logic_vector (dbits/8-1 downto 0);    -- ddr dqs
signal ddr_dqsoutl 	: std_logic_vector (dbits/8-1 downto 0);    -- ddr dqs
signal dqsdel, dqsclk 	: std_logic_vector (dbits/8-1 downto 0);    -- ddr dqs
signal da     		: std_logic_vector (dbits-1 downto 0); -- ddr data
signal dqinl		: std_logic_vector (dbits-1 downto 0); -- ddr data
signal dllrst		: std_logic_vector(0 to 3);
signal dll0rst		: std_logic_vector(0 to 3);
signal mlock, mclkfb, mclk, mclkfx, mclk0 : std_ulogic;
signal gndv             : std_logic_vector (dbits-1 downto 0);    -- ddr dqs
signal pclkout	: std_logic_vector (5 downto 1);
signal ddr_clkin	: std_logic_vector(0 to 2);
signal dqinclk  	: std_logic_vector (dbits/8-1 downto 0);    -- ddr dqs
signal dqsoclk  	: std_logic_vector (dbits/8-1 downto 0);    -- ddr dqs
signal dqsnv  		: std_logic_vector (dbits/8-1 downto 0);    -- ddr dqs

constant DDR_FREQ : integer := (MHz * clk_mul) / clk_div;

component altdqs_cyciii
	generic (width : integer := 2; period : string := "10000ps");
	PORT
	(
		dqs_datain_h		: IN STD_LOGIC_VECTOR (width-1 downto 0);
		dqs_datain_l		: IN STD_LOGIC_VECTOR (width-1 downto 0);
		inclk		: IN STD_LOGIC ;
		oe		: IN STD_LOGIC_VECTOR (width-1 downto 0);
		outclk		: IN STD_LOGIC_VECTOR (width-1 downto 0);
		dll_delayctrlout		: OUT STD_LOGIC_VECTOR (5 DOWNTO 0);
		dqinclk		: OUT STD_LOGIC_VECTOR (width-1 downto 0);
		dqs_padio		: INOUT STD_LOGIC_VECTOR (width-1 downto 0);
		dqsundelayedout		: OUT STD_LOGIC_VECTOR (width-1 downto 0)
	);
END component;

type phasevec is array (1 to 3) of string(1 to 4);
type phasevecarr is array (10 to 13) of phasevec;

constant phasearr : phasevecarr := (
	("2500", "5000", "7500"), ("2273", "4545", "6818"),   -- 100 & 110 MHz
	("2083", "4167", "6250"), ("1923", "3846", "5769"));  -- 120 & 130 MHz

type periodtype is array (10 to 13) of string(1 to 6);
constant periodstr : periodtype := ("9999ps", "9090ps", "8333ps", "7692ps");
begin

  oe <= not oen; vcc <= '1'; gnd <= '0'; gndv <= (others => '0');

  mclk <= clk;
--  clkout <= clk_270r; 
--  clkout <= clk_0r when DDR_FREQ >= 110 else clk_270r; 
  clkout <= clk_90r when DDR_FREQ > 120 else clk_0r; 
  clk0r <= clk_270r; clk90r <= clk_0r;
  clk180r <= clk_90r; clk270r <= clk_180r;

  dll : altpll
  generic map (   
    intended_device_family => "CycloneIII",
    operation_mode => "NORMAL",
    inclk0_input_frequency   => 1000000/MHz,
    inclk1_input_frequency   => 1000000/MHz,
    clk4_multiply_by => clk_mul, clk4_divide_by => clk_div, 
    clk3_multiply_by => clk_mul, clk3_divide_by => clk_div, 
    clk2_multiply_by => clk_mul, clk2_divide_by => clk_div, 
    clk1_multiply_by => clk_mul, clk1_divide_by => clk_div,
    clk0_multiply_by => clk_mul, clk0_divide_by => clk_div, 
    clk3_phase_shift => phasearr(DDR_FREQ/10)(3), 
    clk2_phase_shift => phasearr(DDR_FREQ/10)(2), 
    clk1_phase_shift => phasearr(DDR_FREQ/10)(1) 
--    clk3_phase_shift => "6250", clk2_phase_shift => "4167", clk1_phase_shift => "2083"
--    clk3_phase_shift => "7500", clk2_phase_shift => "5000", clk1_phase_shift => "2500"
  )
  port map ( inclk(0) => mclk, inclk(1) => gnd,  clk(0) => clk_0r, 
        clk(1) => clk_90r, clk(2) => clk_180r, clk(3) => clk_270r, 
        clk(4) => clk4, clk(5) => clk5, locked => lockl);

  rstdel : process (mclk, rst, lockl)
  begin
      if rst = '0' then dllrst <= (others => '1');
      elsif rising_edge(mclk) then
	dllrst <= dllrst(1 to 3) & '0';
      end if;
  end process;

  rdel : if rstdelay /= 0 generate
    rcnt : process (clk_0r)
    variable cnt : std_logic_vector(15 downto 0);
    variable vlock, co : std_ulogic;
    begin
      if rising_edge(clk_0r) then
        co := cnt(15);
        vlockl <= vlock;
        if lockl = '0' then
	  cnt := conv_std_logic_vector(rstdelay*DDR_FREQ, 16); vlock := '0';
        else
	  if vlock = '0' then
	    cnt := cnt -1;  vlock := cnt(15) and not co;
	  end if;
        end if;
      end if;
      if lockl = '0' then
	vlock := '0';
      end if;
    end process;
  end generate;

  locked <= lockl when rstdelay = 0 else vlockl;
  lock <= locked;

  -- Generate external DDR clock

--  fbclkpad : altddio_out generic map (width => 1)
--    port map ( datain_h(0) => vcc, datain_l(0) => gnd,
--	outclock => clk90r, dataout(0) => ddr_clk_fb_out);

  ddrclocks : for i in 0 to 2 generate
    clkpad : altddio_out generic map (width => 1, INTENDED_DEVICE_FAMILY => "CYCLONEIII")
    port map ( datain_h(0) => vcc, datain_l(0) => gnd,
	outclock => clk90r, dataout(0) => ddr_clk(i));

    clknpad : altddio_out generic map (width => 1, INTENDED_DEVICE_FAMILY => "CYCLONEIII")
    port map ( datain_h(0) => gnd, datain_l(0) => vcc,
	outclock => clk90r, dataout(0) => ddr_clkb(i));

  end generate;

  csnpads : altddio_out generic map (width => 2, INTENDED_DEVICE_FAMILY => "CYCLONEIII")
    port map ( datain_h => csn(1 downto 0), datain_l => csn(1 downto 0),
	outclock => clk0r, dataout => ddr_csb(1 downto 0));

  ckepads : altddio_out generic map (width => 2, INTENDED_DEVICE_FAMILY => "CYCLONEIII")
    port map ( datain_h => ckel(1 downto 0), datain_l => ckel(1 downto 0),
	outclock => clk0r, dataout => ddr_cke(1 downto 0));

  ddrbanks : for i in 0 to 1 generate
    ckel(i) <= cke(i) and locked;
  end generate;

  rasnpad : altddio_out generic map (width => 1,
	INTENDED_DEVICE_FAMILY => "CYCLONEIII")
    port map ( datain_h(0) => rasn, datain_l(0) => rasn,
	outclock => clk0r, dataout(0) => ddr_rasb);

  casnpad : altddio_out generic map (width => 1,
	INTENDED_DEVICE_FAMILY => "CYCLONEIII")
    port map ( datain_h(0) => casn, datain_l(0) => casn,
	outclock => clk0r, dataout(0) => ddr_casb);

  wenpad : altddio_out generic map (width => 1,
	INTENDED_DEVICE_FAMILY => "CYCLONEIII")
    port map ( datain_h(0) => wen, datain_l(0) => wen,
	outclock => clk0r, dataout(0) => ddr_web);

  dmpads : altddio_out generic map (width => dbits/8,
	INTENDED_DEVICE_FAMILY => "CYCLONEIII")
    port map (
	datain_h => dm(dbits/8*2-1 downto dbits/8),
	datain_l => dm(dbits/8-1 downto 0),
	outclock => clk0r, dataout => ddr_dm
    );

  bapads : altddio_out generic map (width => 2)
    port map (
	datain_h => ba, datain_l => ba,
	outclock => clk0r, dataout => ddr_ba
    );

  addrpads : altddio_out generic map (width => 14)
    port map (
	datain_h => addr, datain_l => addr,
	outclock => clk0r, dataout => ddr_ad
    );

  -- DQS generation

  dqsnv <= (others => dqsn);
  dqsoclk <= (others => clk90r);
         
  altdqs0 : altdqs_cyciii generic map (dbits/8, periodstr(DDR_FREQ/10))
    port map (dqs_datain_h => dqsnv, dqs_datain_l => gndv(dbits/8-1 downto 0), 
	inclk => clk270r, oe => ddr_dqsoen, outclk => dqsoclk, 
	dll_delayctrlout => open, dqinclk => dqinclk, dqs_padio => ddr_dqs, 
	dqsundelayedout	=> open );

  -- Data bus

  dqgen : for i in 0 to dbits/8-1 generate
    qi : altddio_bidir generic map (width => 8, oe_reg =>"REGISTERED",
	INTENDED_DEVICE_FAMILY => "CYCLONEIII")
    port map (
	datain_l => dqout(i*8+7 downto i*8),
	datain_h => dqout(i*8+7+dbits downto dbits+i*8), 
	inclock => dqinclk(i), --clk270r, 
	outclock => clk0r, oe => oe,
	dataout_h => dqin(i*8+7 downto i*8),
	dataout_l => dqin(i*8+7+dbits downto dbits+i*8), --dqinl(i*8+7 downto i*8),
	padio => ddr_dq(i*8+7 downto i*8));
  end generate;

  dqsreg : process(clk180r)
  begin
    if rising_edge(clk180r) then
      dqsn <= oe;
    end if;
  end process;
  oereg : process(clk0r)
  begin
    if rising_edge(clk0r) then
      ddr_dqsoen(dbits/8-1 downto 0) <= (others => not dqsoen);
    end if;
  end process;

end;
