----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    21:25:57 02/09/2009 
-- Design Name: 
-- Module Name:    pdp1io - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: I/O subsystem for PDP-1, connect to CPU. Instantiates I/O devices.
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity pdp1io is
   Port (
		CLK_50M : in  STD_LOGIC;
                CLK_PDP : in STD_LOGIC;

		IO_SET : out STD_LOGIC;
                IO_TO_CPU : out STD_LOGIC_VECTOR(0 to 17);
                AC, IO_FROM_CPU : in STD_LOGIC_VECTOR(0 to 17);
                IOT : in STD_LOGIC_VECTOR(0 to 63);
                IO_RESTART : out STD_LOGIC;
                IO_DORESTART : in STD_LOGIC;

		-- SPI is in use for DAC outputs to oscilloscope
		SPI_MOSI : OUT std_logic;
		DAC_CS : OUT std_logic;
		SPI_SCK : OUT std_logic;
		DAC_CLR : OUT std_logic;
		DAC_OUT : IN std_logic;
		
		-- DCE serial port is used for communications with PC
		RS232_DCE_RXD : IN std_logic;
		RS232_DCE_TXD : OUT std_logic
	);
end pdp1io;

architecture Behavioral of pdp1io is
	subtype word is std_logic_vector(0 to 17);

	COMPONENT flagcross
	generic ( width : integer := 0 );
	PORT(
		ClkA, ClkB, FastClk : IN std_logic;
		A : IN std_logic := '0';
		B : OUT std_logic;
		A_reg : in STD_LOGIC_VECTOR(0 to width-1) := (others => '0');
		B_reg : out STD_LOGIC_VECTOR(0 to width-1)
		);
	END COMPONENT;

	COMPONENT display
	PORT(
		X : IN std_logic_vector(0 to 9);
		Y : IN std_logic_vector(0 to 9);
		CLK : IN std_logic;

		TRIG, DOPULSE : IN std_logic;          
		DONE : OUT std_logic;
		
		SPI_MOSI : OUT std_logic;
		DAC_CS : OUT std_logic;
		SPI_SCK : OUT std_logic;
		DAC_CLR : OUT std_logic
		);
	END COMPONENT;

	COMPONENT papertapereader
	PORT(
		clk : IN std_logic;
		dopulse : IN std_logic;
		ptr_rpa : IN std_logic;
		ptr_rpb : IN std_logic;
		ptr_rrb : IN std_logic;
		RXD : IN std_logic;          
		done : OUT std_logic;
		io : OUT std_logic_vector(0 to 17);
                io_set : out  STD_LOGIC := 'L';
		rb_loaded : OUT std_logic;
		TXD : OUT std_logic
		);
	END COMPONENT;
	signal ptr_rpa, ptr_rpb, ptr_rrb, ptr_done, ptr_io_set: std_logic;
	signal ptr_io : word;

	signal display_trig, display_done, combined_done: std_logic;
begin
	-- no need to cross-transfer I/O because display is faster than cpu
	disppulse: flagcross PORT MAP(
		ClkA => CLK_PDP,
		ClkB => CLK_50M,
		FastCLK => CLK_50M,
		A => IOT(7),
		B => display_trig,
                A_reg => open,
                B_reg => open
	);
	Inst_display: display PORT MAP(
		X => AC(0 to 9),
		Y => IO_FROM_CPU(0 to 9),
		CLK => CLK_50M,

		TRIG => display_trig,
		DONE => display_done,
		DOPULSE => IO_DORESTART,

		SPI_MOSI => SPI_MOSI,
		DAC_CS => DAC_CS,
		SPI_SCK => SPI_SCK,
		DAC_CLR => DAC_CLR
	);

	Inst_papertapereader: papertapereader PORT MAP(
		clk => CLK_50M,
		dopulse => IO_DORESTART,
		done => ptr_done,
		io => ptr_io,
                io_set => ptr_io_set,
		ptr_rpa => ptr_rpa,
		ptr_rpb => ptr_rpb,
		ptr_rrb => ptr_rrb,
		rb_loaded => open,      -- for sequence break
		RXD => RS232_DCE_RXD,
		TXD => RS232_DCE_TXD
	);
	ptrio: flagcross GENERIC MAP(width=>18) PORT MAP(
		ClkA => CLK_50M,
		ClkB => CLK_PDP,
		FastClk => CLK_50M,
		A => ptr_io_set,
		B => io_set,
		A_reg => ptr_io,
		B_reg => IO_TO_CPU
	);
	ptrrpa: flagcross PORT MAP(
		ClkA => CLK_PDP,
		ClkB => CLK_50M,
		FastClk => CLK_50M,
		A => iot(1),
		B => ptr_rpa,
                A_reg => open,
                B_reg => open
	);
	ptrrpb: flagcross PORT MAP(
		ClkA => CLK_PDP,
		ClkB => CLK_50M,
		FastClk => CLK_50M,
		A => iot(2),
		B => ptr_rpb,
                A_reg => open,
                B_reg => open
	);
	ptrrrb: flagcross PORT MAP(
		ClkA => CLK_PDP,
		ClkB => CLK_50M,
		FastClk => CLK_50M,
		A => iot(8#30#),		-- I/O manual and PDP-1 manual disagree on IOT#.
		B => ptr_rrb,
                A_reg => open,
                B_reg => open
	);

        combined_done <= display_done or ptr_done;
        restart : flagcross port map (
          ClkA    => CLK_50M,
          ClkB    => CLK_PDP,
          FastClk => CLK_50M,
          A       => combined_done,
          B       => IO_RESTART,
          A_reg => open,
          B_reg => open);
end Behavioral;
