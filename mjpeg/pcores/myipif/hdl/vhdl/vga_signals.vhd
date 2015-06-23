---------------------------------------------------------------
-- This code is a simplified port from the Verilog sources that can be found here:
-- http://embedded.olin.edu/xilinx_docs/projects/bitvga-v2p.php
--
-- The Verilog sources are based on code from Xilinx and released under 
-- "Creative Commons Attribution-NonCommercial-ShareAlike 2.5 License"
--
-- with the note, that Xilinx claims the following copyright for their 
-- initial code:
--  XILINX IS PROVIDING THIS DESIGN, CODE, OR INFORMATION "AS IS"
--  SOLELY FOR USE IN DEVELOPING PROGRAMS AND SOLUTIONS FOR
--  XILINX DEVICES.  BY PROVIDING THIS DESIGN, CODE, OR INFORMATION
--  AS ONE POSSIBLE IMPLEMENTATION OF THIS FEATURE, APPLICATION
--  OR STANDARD, XILINX IS MAKING NO REPRESENTATION THAT THIS
--  IMPLEMENTATION IS FREE FROM ANY CLAIMS OF INFRINGEMENT,
--  AND YOU ARE RESPONSIBLE FOR OBTAINING ANY RIGHTS YOU MAY REQUIRE
--  FOR YOUR IMPLEMENTATION.  XILINX EXPRESSLY DISCLAIMS ANY
--  WARRANTY WHATSOEVER WITH RESPECT TO THE ADEQUACY OF THE
--  IMPLEMENTATION, INCLUDING BUT NOT LIMITED TO ANY WARRANTIES OR
--  REPRESENTATIONS THAT THIS IMPLEMENTATION IS FREE FROM CLAIMS OF
--  INFRINGEMENT, IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
--  FOR A PARTICULAR PURPOSE.  
-- 
--  (c) Copyright 2004 Xilinx, Inc.
--  All rights reserved.
---------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Needed for 'OFDDRTRSE' 
library UNISIM;
use UNISIM.VCOMPONENTS.all;


entity vga_signals is
	Generic(
		CHARACTER_DECODE_DELAY	: integer := 4;

		--  640 X 480 @ 60Hz with a 25.175MHz pixel clock
		H_ACTIVE				: integer := 640;	-- pixels
		H_FRONT_PORCH			: integer := 16;	-- pixels
		H_SYNCH					: integer := 96;	-- pixels
		H_BACK_PORCH			: integer := 48;	-- pixels
		H_TOTAL					: integer := 800;	-- pixels
		V_ACTIVE				: integer := 480;	-- lines
		V_FRONT_PORCH			: integer := 11;	-- lines
		V_SYNCH					: integer := 2;		-- lines
		V_BACK_PORCH			: integer := 31;	-- lines
		V_TOTAL					: integer := 524;	-- lines
		CLK_MULTIPLY			: integer := 2;		-- 100 * 2/8 = 25.000 MHz
		CLK_DIVIDE				: integer := 8
	);
    Port ( 
		system_clock : in std_logic;
		
		VGA_OUT_PIXEL_CLOCK : out std_logic;
		VGA_COMP_SYNCH : out std_logic;
		VGA_OUT_BLANK_Z : out std_logic;
		VGA_HSYNCH : out std_logic;
		VGA_VSYNCH : out std_logic;

		o_pixel_clock : out std_logic;
		o_pixel_count : out std_logic_vector(10 downto 0);
		o_line_count  : out std_logic_vector( 9 downto 0)
	);
end vga_signals;


architecture Behavioral of vga_signals is	

--******************************************************
--** Components
--******************************************************

-- Clock Buffer
component BUFG 
	port (
		I: in  STD_LOGIC;  
		O: out STD_LOGIC
	); 
end component; 

-- DCM to generate pixel_clock
component DCM 
  generic (  
      DLL_FREQUENCY_MODE : string := "LOW"; 
      DFS_FREQUENCY_MODE : string := "LOW";
		CLK_FEEDBACK : string := "1X";
      DUTY_CYCLE_CORRECTION : boolean := TRUE; 
      CLKFX_MULTIPLY : integer :=  CLK_MULTIPLY; 
      CLKFX_DIVIDE : integer := CLK_DIVIDE; 
      CLKIN_DIVIDE_BY_2 : boolean := FALSE; 
      CLKIN_PERIOD : real := 10.0;
      CLKOUT_PHASE_SHIFT : string := "NONE"; 
      STARTUP_WAIT : boolean := false; 
      PHASE_SHIFT  : integer := 0 ; 
      CLKDV_DIVIDE : real := 4.0 
         );   
  port ( CLKIN : in std_logic; 
         CLKFB : in std_logic; 
         DSSEN : in std_logic; 
         PSINCDEC : in std_logic; 
         PSEN : in std_logic; 
         PSCLK : in std_logic; 
         RST : in std_logic; 
         CLK0 : out std_logic; 
         CLK90 : out std_logic; 
         CLK180 : out std_logic; 
         CLK270 : out std_logic; 
         CLK2X : out std_logic; 
         CLK2X180 : out std_logic; 
         CLKDV : out std_logic; 
         CLKFX : out std_logic; 
         CLKFX180 : out std_logic; 
         LOCKED : out std_logic; 
         PSDONE : out std_logic; 
         STATUS : out std_logic_vector(7 downto 0) 
       ); 
end component; 

-- 16 Bit Shift Register for Clockgen
component SRL16
   -- synthesis translate_off
	generic (
		INIT : std_logic_vector := X"000F"
	);
   -- synthesis translate_on
	port (
		Q	: out STD_ULOGIC;
		A0	: in  STD_ULOGIC;
		A1	: in  STD_ULOGIC;
		A2	: in  STD_ULOGIC;
		A3	: in  STD_ULOGIC;
		CLK	: in  STD_ULOGIC;
		D	: in  STD_ULOGIC
	);
end component; 

-- ** End Components *************************************

	signal pixel_count : std_logic_vector(10 downto 0);
	signal line_count : std_logic_vector(9 downto 0);
	signal reset, hsynch, vsynch, comp_synch, blank : std_logic;
	signal dcm_reset, dcm_locked: std_logic;
	signal pixel_clock, pixel_clock_buffered, n_pixel_clock_buffered, system_clock_dcm_in, system_clock_dcm_out : std_logic;
	signal v_c_synch, h_c_synch, h_blank, v_blank : std_logic;
	signal hsynch_delay, hsynch_delay0, vsynch_delay, vsynch_delay0 : std_logic;

begin
	

--******************************************************
--** Clockgen: generate and buffer clocks
--******************************************************

-- buffering clocks
buffg_for_system_clock: BUFG 
	port map (
		I => system_clock_dcm_out, 
		O => system_clock_dcm_in
	); 
buffg_for_pixel_clock: BUFG 
	port map (
		I => pixel_clock, 
		O => pixel_clock_buffered
	); 

-- DCM for generating pixel_clock
dcm_for_pixel_clock: DCM   
  port map ( 
         CLKIN	=> system_clock,
         CLKFB	=> system_clock_dcm_in,
         DSSEN	=> '0',
         PSINCDEC => '0',
         PSEN 	=> '0',
         PSCLK	=> '0',
         RST	=> dcm_reset,
         CLK0	=> system_clock_dcm_out,
         CLKFX	=> pixel_clock,
         LOCKED	=> dcm_locked
       );  

-- 16 Bit Shift Register
SRL16_INSTANCE_NAME : SRL16
   -- synthesis translate_off
	generic map(
		INIT => X"000F"
	)
   -- synthesis translate_on
	port map (
		Q	=> dcm_reset,
		A0	=> '1',
		A1	=> '1',
		A2	=> '1',
		A3	=> '1',
		CLK	=> system_clock,
		D 	=> '0'
	); 

reset <= not dcm_locked;
-- ** End Clockgen *************************************



--******************************************************
--** Timings: generate timing signals
--******************************************************

--CREATE THE HORIZONTAL LINE PIXEL COUNTER
process (pixel_clock_buffered, reset)
begin
	pixel_count <= pixel_count;
	if (reset='1') then
		pixel_count <= (others => '0');
	elsif (pixel_clock_buffered'event and pixel_clock_buffered='1') then
		pixel_count <= pixel_count + 1; --"00000000001";
		if (pixel_count=H_TOTAL-1) then
			pixel_count <= (others => '0'); --"00000000000";
		end if;	
	end if;
end process;


-- CREATE THE HORIZONTAL SYNCH PULSE
process (pixel_clock_buffered, reset)
begin
	hsynch <= hsynch;
	if (reset='1') then
		hsynch <= '0';
	elsif (pixel_clock_buffered'event and pixel_clock_buffered='1') then --or (reset'event and reset='1') then 	
		if (pixel_count = (H_ACTIVE + H_FRONT_PORCH -1)) then
			hsynch <= '1';
		elsif (pixel_count = (H_TOTAL - H_BACK_PORCH -1)) then
			hsynch <= '0';
		end if;
	end if;
end process;


-- CREATE THE VERTICAL FRAME LINE COUNTER
process (pixel_clock_buffered, reset)
begin
	line_count <= line_count;
	if (reset='1') then
		line_count <= (others => '0');
	elsif (pixel_clock_buffered'event and pixel_clock_buffered='1') then --or (reset'event and reset='1') then 	
		if ((line_count = (V_TOTAL - 1)) and (pixel_count = (H_TOTAL - 1))) then
			line_count <= (others => '0');
		elsif ((pixel_count = (H_TOTAL - 1))) then
			line_count <= line_count + 1;
		end if;
	end if;
end process;


-- CREATE THE VERTICAL SYNCH PULSE
process (pixel_clock_buffered, reset)
begin
	vsynch <= vsynch;
	if (reset='1') then
		vsynch <= '0';
	elsif (pixel_clock_buffered'event and pixel_clock_buffered='1') then --or (reset'event and reset='1') then 	
		if ((line_count = V_ACTIVE + V_FRONT_PORCH -1) and (pixel_count = H_TOTAL - 1)) then
			vsynch <= '1';
		elsif ((line_count = (V_TOTAL - V_BACK_PORCH - 1)) and (pixel_count = (H_TOTAL - 1))) then
			vsynch <= '0';
		end if;
	end if;
end process;


-- ADD TWO PIPELINE DELAYS TO THE SYNCHs COMPENSATE FOR THE DAC PIPELINE DELAY
process (pixel_clock_buffered, reset)
begin
	if (reset='1') then				
		hsynch_delay0 <= '0';
		vsynch_delay0 <= '0';
		hsynch_delay  <= '0';
		vsynch_delay  <= '0';
	elsif (pixel_clock_buffered'event and pixel_clock_buffered='1') then --or (reset'event and reset='1') then 	
		hsynch_delay0 <= hsynch;
		vsynch_delay0 <= vsynch;
		hsynch_delay  <= hsynch_delay0;
		vsynch_delay  <= vsynch_delay0;
	end if;
end process;


-- CREATE THE HORIZONTAL BLANKING SIGNAL
-- the "-2" is used instead of "-1" because of the extra register delay
-- for the composite blanking signal
process (pixel_clock_buffered, reset)
begin
	h_blank <= h_blank; 
	if (reset='1') then
		h_blank <= '0';
	elsif (pixel_clock_buffered'event and pixel_clock_buffered='1') then --or (reset'event and reset='1') then 
		if (pixel_count = (H_ACTIVE -2)) then
			h_blank <= '1';
		elsif (pixel_count = (H_TOTAL -2)) then
			h_blank <= '0';
		end if;
	end if;
end process;


-- CREATE THE VERTICAL BLANKING SIGNAL
-- the "-2" is used instead of "-1"  in the horizontal factor because of the extra
-- register delay for the composite blanking signal
process (pixel_clock_buffered, reset)
begin
	if (reset='1') then
		v_blank <= '0';
	elsif (pixel_clock_buffered'event and pixel_clock_buffered='1') then --or (reset'event and reset='1') then 	
		if ((line_count = (V_ACTIVE - 1) and (pixel_count = H_TOTAL - 2))) then
			v_blank <= '1';
		elsif ((line_count = (V_TOTAL - 1)) and (pixel_count = (H_TOTAL - 2))) then
			v_blank <= '0';
		end if;
	end if;
end process;


-- CREATE THE COMPOSITE BLANKING SIGNAL
process (pixel_clock_buffered, reset)
begin
	if (pixel_clock_buffered'event and pixel_clock_buffered='1') then --or (reset'event and reset='1') then 
		blank <= (not reset) and (h_blank or v_blank);	
	end if;
end process;


--******************************************************
--** Output: connect output signals
--******************************************************

-- don't ask me why I do this,
-- generate VGA_OUT_PIXEL_CLOCK:
OFDDRTRSE_inst : OFDDRTRSE
port map (
	O 	=> VGA_OUT_PIXEL_CLOCK,
	C0 	=> pixel_clock_buffered,
	C1 	=> n_pixel_clock_buffered,
	CE 	=> '1',
	D0 	=> '0',
	D1 	=> '1',
	R 	=> reset,
	S 	=> '0',
	T 	=> '0'
);
n_pixel_clock_buffered <= not pixel_clock_buffered;

o_pixel_clock <= pixel_clock_buffered;

process (pixel_clock_buffered, reset)
begin
--	if rising_edge(pixel_clock_buffered) then 
	if (pixel_clock_buffered'event and pixel_clock_buffered='1') then --or (reset'event and reset='1') then	
		VGA_COMP_SYNCH		<= not reset;
		VGA_OUT_BLANK_Z 	<= not blank and not reset;
		VGA_HSYNCH			<= hsynch or reset;
		VGA_VSYNCH			<= vsynch or reset;
		o_pixel_count		<= pixel_count;
		o_line_count		<= line_count;
	end if;
end process;
-- ** End Output *************************************

end Behavioral;

