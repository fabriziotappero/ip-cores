----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    21:25:57 02/09/2009 
-- Design Name: 
-- Module Name:    top - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
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
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity top is
   Port (
		CLK_50M : in  STD_LOGIC;
		CLK_AUX : in STD_LOGIC;   -- 133.33 MHz
		LED : out std_logic_vector(7 downto 0) := (others=>'0');
		SW : in std_logic_vector(3 downto 0);
		AWAKE : out std_logic := '0';
		
		-- SPI is in use for DAC outputs to oscilloscope
		SPI_MOSI : OUT std_logic := 'L';
		DAC_CS : OUT std_logic := '1';
		SPI_SCK : OUT std_logic := 'L';
		DAC_CLR : OUT std_logic := 'L';
		DAC_OUT : IN std_logic := 'L';
		
		-- VGA is (planned) for emulated vector graphics
		VGA_R : out  STD_LOGIC_VECTOR (3 downto 0);
      VGA_G : out  STD_LOGIC_VECTOR (3 downto 0);
      VGA_B : out  STD_LOGIC_VECTOR (3 downto 0);
      VGA_HSYNC : out  STD_LOGIC := '1';
      VGA_VSYNC : out  STD_LOGIC := '0';
		
		-- DCE serial port is used for communications with PC
		RS232_DCE_RXD : IN std_logic;
		RS232_DCE_TXD : OUT std_logic := '1';
		
		-- pushbutton to be debounced
		BTN_EAST : IN std_logic := '0'
	);
end top;

architecture Behavioral of top is
	subtype word is std_logic_vector(0 to 17);
		component vga is
			Port ( VGA_R : out  STD_LOGIC_VECTOR (3 downto 0);
           VGA_G : out  STD_LOGIC_VECTOR (3 downto 0);
           VGA_B : out  STD_LOGIC_VECTOR (3 downto 0);
           VGA_HSYNC : out  STD_LOGIC := '1';
           VGA_VSYNC : out  STD_LOGIC := '0';
           CLK_50M : in STD_LOGIC;
			  CLK_133M33 : in STD_LOGIC);
		end component;

        component pdp1io is
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
        end component;

        COMPONENT flagcross
	generic ( width : integer := 0 );
	PORT(
		ClkA, ClkB, FastClk : IN std_logic;
		A : IN std_logic;          
		B : OUT std_logic;
		A_reg : in STD_LOGIC_VECTOR(0 to width-1);
		B_reg : out STD_LOGIC_VECTOR(0 to width-1)
		);
	END COMPONENT;

	component coremem
    Port ( A : in  STD_LOGIC_VECTOR (0 to 11);
           CLK : in  STD_LOGIC;
           WE : in  STD_LOGIC;
           DI : in  word;
           DO : inout word);
	end component;

	component clockdiv
    Port ( CLK_50M : in  STD_LOGIC;
           CLK : out  STD_LOGIC;	-- 2MHz
			  LOCKED : out STD_LOGIC);
	end component;

	component pdp1cpu
    Port ( M_DO : in word;
           M_DI : out word;
           MW : inout  STD_LOGIC;
           MA : out  STD_LOGIC_VECTOR (0 to 11);

           AWAKE : out STD_LOGIC;

           CLK : in  STD_LOGIC;

           IOT : out STD_LOGIC_VECTOR(0 to 63);
           IODOPULSE : out STD_LOGIC;
           IODONE : in STD_LOGIC;
           IO_set : in STD_LOGIC;
           IO_IN : in STD_LOGIC_VECTOR(0 to 17);

           PC : inout unsigned(0 to 11);  -- program counter
           AC, IO : inout word;
           SW_SENSE : in STD_LOGIC_VECTOR(1 to 6);			  
			  
           RESET : in STD_LOGIC);
	end component;

	COMPONENT debounce
	PORT(
		clk : IN std_logic;
		clken : IN std_logic;
		input : IN std_logic;       
		output : INOUT std_logic
		);
	END COMPONENT;

	signal CLK, CLK_LOCKED, RESET : std_logic := '0';
	signal mem_we : std_logic := '0';
	signal mem_di, mem_do, io, ac, io_in : word := (others=>'0');
	signal sw_sense : std_logic_vector(1 to 6) := o"00";
	signal mem_a : std_logic_vector(0 to 11) := (others=>'0');

        signal pc : unsigned(0 to 11);
        
	signal io_dopulse, io_done, io_set : std_logic := '0';
	signal IOT : std_logic_vector(0 to 63) := (others=>'0');
	signal display_trig, display_done: std_logic;
	
	constant pdp1_enabled : boolean := true;
begin
	RESET <= (not CLK_LOCKED) or BTN_EAST;

	vga_out : vga port map (
		CLK_50M => CLK_50M,
		CLK_133M33 => CLK_AUX,
		VGA_R => VGA_R,
		VGA_G => VGA_G,
		VGA_B => VGA_B,
		VGA_HSYNC => VGA_HSYNC,
		VGA_VSYNC => VGA_VSYNC
	);

dummy: if not pdp1_enabled generate
begin
	LED <= (others => '0');
	SPI_SCK <= '0';
	RS232_DCE_TXD <= '1';
	SPI_MOSI <= '0';
	DAC_CLR <= '0';
	AWAKE <= '1';
	DAC_CS <= '1';
end generate;

disabled: if pdp1_enabled generate
begin
	clock : clockdiv
	port map (
		CLK_50M => CLK_50M,
		CLK => CLK,
		LOCKED => CLK_LOCKED
	);

	core : coremem
	port map (
		CLK => CLK,
		WE => mem_we,
		DI => mem_di,
		DO => mem_do,
		A => mem_a
	);
--        AWAKE <= '1';
	cpu : pdp1cpu
	port map (
		CLK => CLK,
                AWAKE => AWAKE,

		M_DO => mem_do,
		M_DI => mem_di,
		MW => mem_we,
		MA => mem_a,

		IOT => IOT,
		IODOPULSE => io_dopulse,
		IODONE => io_done,
		IO_IN => io_in,
                IO_SET => io_set,

                PC => pc,
		IO => IO,
		AC => AC,
		SW_SENSE => SW_SENSE,
		
		RESET => RESET
	);
        iodevices : pdp1io port map (
          CLK_50M       => CLK_50M,
          CLK_PDP       => CLK,
          IO_SET        => io_set,
          IO_TO_CPU     => io_in,
          IO_FROM_CPU   => IO,
          AC            => AC,
          IOT           => iot,
          IO_RESTART    => io_done,
          IO_DORESTART  => io_dopulse,
          -- display device uses DAC
          SPI_MOSI      => SPI_MOSI,
          DAC_CS        => DAC_CS,
          SPI_SCK       => SPI_SCK,
          DAC_CLR       => DAC_CLR,
          DAC_OUT       => DAC_OUT,
          -- paper tape reader uses RS232
          RS232_DCE_RXD => RS232_DCE_RXD,
          RS232_DCE_TXD => RS232_DCE_TXD);

        with SW select
          LED <=
          std_logic_vector(PC(11-7 to 11)) when "0000",
          IO(0 to 7) when others;
	SW_SENSE(1 to 4) <= SW(3 downto 0);

	Inst_debounce: debounce PORT MAP(
		clk => CLK,
		clken => '1',
		input => BTN_EAST,
		output => SW_SENSE(5)
	);
end generate;

end Behavioral;
