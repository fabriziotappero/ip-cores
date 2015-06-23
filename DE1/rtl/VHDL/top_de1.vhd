-------------------------------------------------------------------------------------------------
-- Z80 Control Microprocessor
--
-- Version history:
-------------------
-- Version 0.2 Alpha for for Altera DE1
-- Developer: Tyler Pohl
-- Release Date: 2010 / 10 / 01
--
-- Based on the T80 core: http://www.opencores.org/projects.cgi/web/t80
-- This version developed and tested on: Altera DE1 Development Board
--
-- Peripherals configured (Using Ports):
--
--	40 KB Internal ROM		Read		(0x0000h - 0x9FFFh) -- Location 1FFFH will be used to unlock locked RAM in future
--
--  08 KB Shared Memory     Read/Write  (0xA000h - 0xBFFFh)
--
--        Locked Supr1                  (0xC000h - 0xC7FFh)
--		  Supr2				            (0xC800h - 0xCFFFh) 
--        Supr3                         (0xD000h - 0xD7FFh) 
--        Supr4                         (0xD800h - 0xDFFFh) -- Stack starts at DFEA and goes down initialize this in z80 code
--        Supr5                         (0xE000h - 0xE7FFh) 
--        Supr6							(0xE800h - 0xEFFFh) 
--        Lacoked Pram					(0xF000h - 0xF7FFh) -- Switched between 5 banks
--        Sram                          (0xF800h - 0xF8FFh) -- Switched between 5 banks
--		  Ram                           (0xF900h - 0xFFFFh) -- Switched between 5 banks

--	08 Green Leds			Out			(Port 0x01h)
--	08 Red Leds				Out			(Port 0x02h)
--	04 Seven Seg displays	Out			(Ports 0x10h and 0x11h)

--  01 Uart0				In/Out		(Port 0x24h)

--  01 Rom Switching        Out         (Port 0xDDh)
--  02 Rom Switching        Out         (Port 0xDDh)
--  03 Rom Switching        Out         (Port 0xDDh)

--  00 to 04 Ram Bank Switching  Out         (Port 0xDCh)

-- Future Ports (Registers)
--PRF F0h
--STATS,RTCIN F0h	--Brown Out and Pwr Fail Stat 60Hz
--PFKILL F1h
--RTCRST F2h
--SFTPRT F3h
--MEXPON F4h
--MEXPOFF F5h
--IOXPON F6h
--IOXPOFF F7h
--EPPAGE1 FCh
--EPPAGE2 FDh
--
--  Revision history:
--
-- 2010/10/01 - Modified RAM layout to support new and future improvements
--            - Changed ROM to support 16 bit addresses
--			  - Serial port Recived works under Interrupt -- Load z80test and data ends up on hex display	
--
--
-- Getting Started
	-- Use CII_Starter_USB_API_v1 project to load flash chip - don't forget to erase chip first
	-- Load rom.bin to flash chip starting at address 0
	-- Connect the serial port up to hyperterminal or minicom
	-- Sends data out serial port and displays on hex display data sent
	-- Type chars to send from PC serial port - z80 recieves and displays on hex display under interrupt
--
--
-- TO-DO:
-- - MOST IMPORTANT !!!! - This is halting my progress
-- - Search for this ????? and figure out why it stops the CPU from running 
-- -
-- - Serial communication, to download assembly code from PC
-- - SD/MMC card interface to read/store data and programs
-- - Get Flash Write to Work -- Why does the CPU not run when connecting DO_CPU to the FL_DQ pins ?
-- - Figure out why cpu does not run when having LED, and uart enabled in the Port output section
-- - Get all the memory above working and document.
-- - Get the serial Tx Interrupt to work.
-- - Add registers to uart so baudrate, parity, interrupts can be modified.
-- - Document this project in the form of Microprocessor Datasheets.
-- - Design Template of Software to communicate to the Board
-------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity 	TOP_DE1 is
	port(

    -- Clocks
    CLOCK_27,                                      	-- 27 MHz
    CLOCK_50,                                      	-- 50 MHz
    EXT_CLOCK : in std_logic;                      	-- External Clock

    -- Buttons and switches
    KEY : in std_logic_vector(3 downto 0);         	-- Push buttons
    SW : in std_logic_vector(9 downto 0);          	-- Switches

    -- LED displays
    HEX0, HEX1, HEX2, HEX3                         	-- 7-segment displays
			: out std_logic_vector(6 downto 0);
    LEDG : out std_logic_vector(7 downto 0);       	-- Green LEDs
    LEDR : out std_logic_vector(9 downto 0);       	-- Red LEDs

    -- RS-232 interface
    UART_TXD : out std_logic;                      	-- UART transmitter   
    UART_RXD : in std_logic;                       	-- UART receiver

    -- IRDA interface

    -- IRDA_TXD : out std_logic;                    -- IRDA Transmitter
    IRDA_RXD : in std_logic;                       	-- IRDA Receiver

    -- SDRAM
    DRAM_DQ : inout std_logic_vector(15 downto 0); 	-- Data Bus
    DRAM_ADDR : out std_logic_vector(11 downto 0); 	-- Address Bus    
    DRAM_LDQM,                                     	-- Low-byte Data Mask 
    DRAM_UDQM,                                     	-- High-byte Data Mask
    DRAM_WE_N,                                     	-- Write Enable
    DRAM_CAS_N,                                    	-- Column Address Strobe
    DRAM_RAS_N,                                    	-- Row Address Strobe
    DRAM_CS_N,                                     	-- Chip Select
    DRAM_BA_0,                                     	-- Bank Address 0
    DRAM_BA_1,                                     	-- Bank Address 0
    DRAM_CLK,                                      	-- Clock
    DRAM_CKE : out std_logic;                      	-- Clock Enable

    -- FLASH
    FL_DQ : inout std_logic_vector(7 downto 0); 	-- Data bus
    FL_ADDR : out std_logic_vector(21 downto 0);    -- Address bus
    FL_WE_N : out std_logic;                                         -- Write Enable
    FL_RST_N : out std_logic;                                        -- Reset
    FL_OE_N : out std_logic;                                         -- Output Enable
    FL_CE_N : out std_logic;                        -- Chip Enable

    -- SRAM
    SRAM_DQ : inout std_logic_vector(15 downto 0); 	-- Data bus 16 Bits
    SRAM_ADDR : out std_logic_vector(17 downto 0); 	-- Address bus 18 Bits
    SRAM_UB_N,                                     	-- High-byte Data Mask 
    SRAM_LB_N,                                     	-- Low-byte Data Mask 
    SRAM_WE_N,                                     	-- Write Enable
    SRAM_CE_N,                                     	-- Chip Enable
    SRAM_OE_N : out std_logic;                     	-- Output Enable

    -- SD card interface
    SD_DAT : in std_logic;      -- SD Card Data      SD pin 7 "DAT 0/DataOut"
    SD_DAT3 : out std_logic;    -- SD Card Data 3    SD pin 1 "DAT 3/nCS"
    SD_CMD : out std_logic;     -- SD Card Command   SD pin 2 "CMD/DataIn"
    SD_CLK : out std_logic;     -- SD Card Clock     SD pin 5 "CLK"

    -- USB JTAG link
    TDI,                        -- CPLD -> FPGA (data in)
    TCK,                        -- CPLD -> FPGA (clk)
    TCS : in std_logic;         -- CPLD -> FPGA (CS)
    TDO : out std_logic;        -- FPGA -> CPLD (data out)

    -- I2C bus
    I2C_SDAT : inout std_logic; -- I2C Data
    I2C_SCLK : out std_logic;   -- I2C Clock

    -- PS/2 port
    PS2_DAT,                    						-- Data
    PS2_CLK : inout std_logic;     						-- Clock

    -- VGA output
    VGA_HS,                                             -- H_SYNC
    VGA_VS 			: out std_logic;                    -- SYNC
    VGA_R,                                              -- Red[3:0]
    VGA_G,                                              -- Green[3:0]
    VGA_B 			: out std_logic_vector(3 downto 0); -- Blue[3:0]
   
    -- Audio CODEC
    AUD_ADCLRCK 	: inout std_logic;                 	-- ADC LR Clock
    AUD_ADCDAT 		: in std_logic;                     -- ADC Data
    AUD_DACLRCK 	: inout std_logic;                  -- DAC LR Clock
    AUD_DACDAT 		: out std_logic;                    -- DAC Data
    AUD_BCLK 		: inout std_logic;                  -- Bit-Stream Clock
    AUD_XCK 		: out std_logic;             		-- Chip Clock
      
    -- General-purpose I/O
    GPIO_0,                                      		-- GPIO Connection 0
    GPIO_1 : inout std_logic_vector(35 downto 0) 		-- GPIO Connection 1	
);
end TOP_DE1;

architecture rtl of TOP_DE1 is

	component T80se
	generic(
		Mode 		: integer := 0;	-- 0 => Z80, 1 => Fast Z80, 2 => 8080, 3 => GB
		T2Write 	: integer := 1;	-- 0 => WR_n active in T3, /=0 => WR_n active in T2
		IOWait 		: integer := 1	-- 0 => Single cycle I/O, 1 => Std I/O cycle
	);
	port(
		RESET_n		: in std_logic;
		CLK_n		: in std_logic;
		CLKEN		: in std_logic;
		WAIT_n		: in std_logic;
		INT_n		: in std_logic;
		NMI_n		: in std_logic;
		BUSRQ_n		: in std_logic;
		M1_n		: out std_logic;
		MREQ_n		: out std_logic;
		IORQ_n		: out std_logic;
		RD_n		: out std_logic;
		WR_n		: out std_logic;
		RFSH_n		: out std_logic;
		HALT_n		: out std_logic;
		BUSAK_n		: out std_logic;
		A			: out std_logic_vector(15 downto 0);
		DI			: in std_logic_vector(7 downto 0);
		DO			: out std_logic_vector(7 downto 0)
	);
	end component;



	component Clock_357Mhz
	PORT (
		clock_50Mhz		: IN	STD_LOGIC;
		clock_357Mhz	: OUT	STD_LOGIC);
	end component;
	
	component clk_div
	PORT
	(
		clock_25Mhz		: IN	STD_LOGIC;
		clock_1MHz		: OUT	STD_LOGIC;
		clock_100KHz	: OUT	STD_LOGIC;
		clock_10KHz		: OUT	STD_LOGIC;
		clock_1KHz		: OUT	STD_LOGIC;
		clock_100Hz		: OUT	STD_LOGIC;
		clock_10Hz		: OUT	STD_LOGIC;
		clock_1Hz		: OUT	STD_LOGIC;
		clock_10sec		: OUT	STD_LOGIC;
		clock_1min		: OUT	STD_LOGIC;
		clock_1hr		: OUT	STD_LOGIC);
	end component;

	component decoder_7seg
	port (
		NUMBER			: in std_logic_vector(3 downto 0);
		HEX_DISP		: out std_logic_vector(6 downto 0));
	end component;


	
	COMPONENT miniUART 
	PORT (
		SysClk   : in  Std_Logic;  -- System Clock
		Reset    : in  Std_Logic;  -- Reset input
		CS_N     : in  Std_Logic;
		RD_N     : in  Std_Logic;
		WR_N     : in  Std_Logic;
		RxD      : in  Std_Logic;
		TxD      : out Std_Logic;
		IntRx_N  : out Std_Logic;  -- Receive interrupt
		IntTx_N  : out Std_Logic;  -- Transmit interrupt
		Addr     : in  Std_Logic_Vector(1 downto 0); -- 
		DataIn   : in  Std_Logic_Vector(7 downto 0); -- 
		DataOut  : out Std_Logic_Vector(7 downto 0)); --     
	END COMPONENT;
	
	
	signal INT_n	: std_logic;
	signal M1_n		: std_logic;
	signal MREQ_n	: std_logic;
	signal IORQ_n	: std_logic;
	signal RD_n		: std_logic;
	signal WR_n		: std_logic;
	signal MWr_n	: std_logic;
	signal Rst_n_s	: std_logic;
	
	signal Clk_Z80		: std_logic;
	signal Clk_357Mhz 	: std_logic;
	
	signal DI_CPU	: std_logic_vector(7 downto 0);
	signal DO_CPU	: std_logic_vector(7 downto 0);
	signal A		: std_logic_vector(15 downto 0);
	signal One		: std_logic;
	signal AA		: std_logic_vector(21 downto 0);
	
	signal D_ROM	: std_logic_vector(7 downto 0);

	signal clk25mhz		: std_logic;
	signal clk1hz		: std_logic;
	signal clk10hz		: std_logic;
	signal clk100hz		: std_logic;
	signal clk10sec		: std_logic;
	--signal clk1min		: std_logic;
	--signal clk1hr		: std_logic;
	
	signal HEX_DISP0	: std_logic_vector(6 downto 0);
	signal HEX_DISP1	: std_logic_vector(6 downto 0);
	signal HEX_DISP2	: std_logic_vector(6 downto 0);
	signal HEX_DISP3	: std_logic_vector(6 downto 0);

	signal NUMBER0		: std_logic_vector(3 downto 0);
	signal NUMBER1		: std_logic_vector(3 downto 0);	
	signal NUMBER2		: std_logic_vector(3 downto 0);
	signal NUMBER3		: std_logic_vector(3 downto 0);
	

	
	signal uart0_CS			: std_Logic;
	signal uart0_RD			: std_Logic;
	signal uart0_WR			: std_Logic;
	signal uart0_RxInt		: std_Logic;
	signal uart0_TxInt		: std_Logic;
	signal uart0_Addr   	: std_Logic_Vector(1 downto 0);
	signal uart0_DataIn 	: std_Logic_Vector(7 downto 0);
	signal uart0_DataOut 	: std_logic_Vector(7 downto 0);
	signal UartIntVector	: std_logic_Vector(7 downto 0);
	

	
	signal IntVector		: std_logic_Vector(7 downto 0);	

	signal LEDRED		: std_logic_Vector(7 downto 0);
	
	
begin
	


	Rst_n_s <= not SW(9);			-- Switch 9 toggles Reset on z80
	

	HEX0 <= HEX_DISP0;				-- Move Signal to Output Pins
	HEX1 <= HEX_DISP1;				-- Move Signal to Output Pins
	HEX2 <= HEX_DISP2;				-- Move Signal to Output Pins	
	HEX3 <= HEX_DISP3;				-- Move Signal to Output Pins
	
	-- SRAM control signals
	SRAM_ADDR(15 downto 0) <= A - x"C000" when (A >= x"C000" and MREQ_n = '0');
	SRAM_DQ(7 downto 0) <= DO_CPU when (Wr_n = '0' and MREQ_n = '0' and A >= x"C000") else (others => 'Z');
	SRAM_WE_N <= Wr_n or MREQ_n when A >= x"C000";
	SRAM_OE_N <= Rd_n or MREQ_n when A >= x"C000";  --Rd_n;
	
	-- ???? Why can't this pin be connected to MREQ_n CPU will not run unless its is connected to zero
	SRAM_CE_N <= '0';
	--------------------------------------------------------------------------------------------------

	--1FFFH is used for unlocking ram in future.  Auto lock after one read or write.
	
	-- FLASH control signals	

	--FL_ADDR(15 downto 0) <= A(15 downto 0) when (Clk_Z80 = '1' and A < x"A000");
	FL_ADDR(15 downto 0) <= A(15 downto 0) when (A < x"A000" and MREQ_n = '0');
    --D_ROM(7 downto 0) <=  FL_DQ when (Clk_Z80 = '1' and A < x"A000");
	D_ROM(7 downto 0) <=  FL_DQ when (A < x"A000" and MREQ_n = '0');   
    
    -- ????? Unblock this and CPU will not run
    --FL_DQ <= DO_CPU when (Wr_n = '0' and MREQ_n = '0' and A < x"A000") else (others => 'Z');
    -----------------------------------------------------------
    
    FL_DQ       <= (others => 'Z');	

    FL_WE_N <= '1';              --'1';   		-- Write Enable

    FL_OE_N <= Rd_n;	-- Output Enable
    
    FL_CE_N <= MREQ_n when A < x"A000";	-- Chip Enable
    	    


    
    --Buffer Flash Data Lines
	--D_ROM(0) <= '1' when FL_DQ(0) = '1' else '0';
	--D_ROM(1) <= '1' when FL_DQ(1) = '1' else '0';
	--D_ROM(2) <= '1' when FL_DQ(2) = '1' else '0';
	--D_ROM(3) <= '1' when FL_DQ(3) = '1' else '0';
	--D_ROM(4) <= '1' when FL_DQ(4) = '1' else '0';
	--D_ROM(5) <= '1' when FL_DQ(5) = '1' else '0';
	--D_ROM(6) <= '1' when FL_DQ(6) = '1' else '0';
	--D_ROM(7) <= '1' when FL_DQ(7) = '1' else '0';	

    	
 

	
	-- UART control signals
	uart0_CS <= IORQ_n when (A(7 downto 0) = x"24" and IORQ_n = '0');
	uart0_RD <= Rd_n when (A(7 downto 0) = x"24" and IORQ_n = '0'); 
	uart0_WR <= Wr_n when (A(7 downto 0) = x"24" and IORQ_n = '0'); 
	uart0_Addr <= b"00";
    ----------------------------------------------
    ----------------------------------------------
	--Z80 Interrupt Vectors
	--               IBMVECT
	--0040 AA1C      	  DW	    COMMBOUT  	;CHAN-B TRANSMIT BUFFER EMPTY
	--0042 101B      	  DW	    COMBCLI    	;BSTATUS
	--0044 F21C      	  DW	    COMMBIN   	;BRECEIVE
	--0046 FF1A      	  DW	    COMBCLII   	;BEXTINT
	--0048 281C      	  DW	    COMMAOUT   	;ATRBMTY
	--004A 691C      	  DW	    COMACLI    	;WAS CRTEXINT	;ASTATUS
	--004C 2F1B      	  DW	    COMMAIN    	;WAS CRTINP     ;ARECEIVE
	--004E 971C      	  DW	    COMACLII   	;WAS CRTEXIN?	;AEXTINT	
	IntVector(7 downto 0) <= x"4C"  when (IORQ_n = '0' and MREQ_n = '1' and M1_n = '0' and uart0_RxInt = '1');
    ----------------------------------------------------------	
       



	
	-- Depending on bus signals DI_CPU gets loaded with one of these values.  
	-- Note: bus signals change while z80 is executing different instructions.
	-- Input to Z80
	DI_CPU <= 
			SRAM_DQ(7 downto 0) when (Rd_n = '0' and MREQ_n = '0' and IORQ_n = '1' and A >= x"C000") else
			
			--Input ROM Code
			D_ROM when (Rd_n = '0' and MREQ_n = '0' and IORQ_n = '1' and A < x"A000") else

			uart0_DataIn(7 downto 0) when (IORQ_n = '0' and MREQ_n = '1' and Rd_n = '0' and A(7 downto 0) = x"24") else
			
			IntVector(7 downto 0) when (IORQ_n = '0' and MREQ_n = '1' and M1_n = '0' and uart0_RxInt = '1') else  

			"ZZZZZZZZ";
	
	-- Process to latch leds and hex displays
	pinout_process: process(Clk_Z80)
	variable NUMBER0_sig	: std_logic_vector(3 downto 0);
	variable NUMBER1_sig	: std_logic_vector(3 downto 0);	
	variable NUMBER2_sig	: std_logic_vector(3 downto 0);
	variable NUMBER3_sig	: std_logic_vector(3 downto 0);
	variable LEDG_sig		: std_logic_vector(7 downto 0);
	variable LEDR_sig		: std_logic_vector(9 downto 0);
	variable GPIO_0_buf_out: std_logic_vector(35 downto 0);
	variable uart0_buf_DataOut: std_logic_vector(7 downto 0);
	--variable GPIO_1_buf_out: std_logic_vector(35 downto 0);
	begin		
        if Clk_Z80'event and Clk_Z80 = '1' then	
		  if IORQ_n = '0' and MREQ_n = '1' and Wr_n = '0' then
			-- LEDG
			if A(7 downto 0) = x"01" then
			-- LEDR
			elsif A(7 downto 0) = x"02" then
				LEDR_sig(7 downto 0) := DO_CPU;
			-- HEX1 and HEX0
			elsif A(7 downto 0) = x"10" then
				NUMBER0_sig := DO_CPU(3 downto 0);
				NUMBER1_sig := DO_CPU(7 downto 4);
			-- HEX3 and HEX2
			elsif A(7 downto 0) = x"11" then
				NUMBER2_sig := DO_CPU(3 downto 0);
				NUMBER3_sig := DO_CPU(7 downto 4);
			elsif A(7 downto 0) = x"24" then
				uart0_buf_DataOut := DO_CPU;		--load data to uart output buffer
				
			end if;
		  end if;
		end if;		
		-- Latches the signals
		NUMBER0 <= NUMBER0_sig;
		NUMBER1 <= NUMBER1_sig;
		NUMBER2 <= NUMBER2_sig;
		NUMBER3 <= NUMBER3_sig;
		
		
		-- ???? Unblock this and CPU will not run
		-- NOTE it will work if you block uart0_DataOut below
		--LEDRED(7 downto 0) <= LEDR_sig(7 downto 0);
		---------------------------------------------
		
		
		uart0_DataOut <= uart0_buf_DataOut;
	end process;		

	One <= '1';
	z80_inst: T80se
		port map (
			M1_n => M1_n,       
			MREQ_n => MREQ_n,
			IORQ_n => IORQ_n,
			RD_n => Rd_n,
			WR_n => Wr_n,
			RFSH_n => open,
			HALT_n => open,
			WAIT_n => One,
			INT_n => INT_n,           
			NMI_n => clk1hz,
			RESET_n => Rst_n_s,
			BUSRQ_n => One,
			BUSAK_n => open,
			CLK_n => Clk_Z80,
			CLKEN => One,
			A => A,
			DI => DI_CPU,
			DO => DO_CPU
		);
		

	clkdiv_inst: clk_div
	port map (
		clock_25Mhz				=> CLOCK_27,
		clock_1MHz				=> open,
		clock_100KHz			=> open,
		clock_10KHz				=> open,
		clock_1KHz				=> open,
		clock_100Hz				=> clk100hz,
		clock_10Hz				=> clk10hz,
		clock_1Hz				=> clk1hz,
		clock_10sec				=> clk10sec,
		clock_1min				=> open,
		clock_1hr				=> open
	);
		
	clock_z80_inst : Clock_357Mhz
		port map (
			clock_50Mhz		=> CLOCK_50,
			clock_357Mhz	=> Clk_Z80    
	);

	DISPHEX0 : decoder_7seg PORT MAP (
		NUMBER			=>	NUMBER0,
		HEX_DISP		=>	HEX_DISP0
	);		

	DISPHEX1 : decoder_7seg PORT MAP (
		NUMBER			=>	NUMBER1,
		HEX_DISP		=>	HEX_DISP1
	);		

	DISPHEX2 : decoder_7seg PORT MAP (
		NUMBER			=>	NUMBER2,
		HEX_DISP		=>	HEX_DISP2
	);		

	DISPHEX3 : decoder_7seg PORT MAP (
		NUMBER			=>	NUMBER3,
		HEX_DISP		=>	HEX_DISP3
	);

	
	U1 : miniUART PORT MAP ( 
		SysClk   => CLOCK_50, 		--: in  Std_Logic;  -- System Clock
		Reset    => Key(0), 		--: in  Std_Logic;  -- Reset input
		CS_N     => uart0_cs, 		--: in  Std_Logic;
		RD_N     => uart0_Rd, 		--: in  Std_Logic;
		WR_N     => uart0_Wr, 		--: in  Std_Logic;
		RxD      => UART_RXD, 		--: in  Std_Logic;
		TxD      => UART_TXD, 		--: out Std_Logic;
		IntRx_N  => uart0_RxInt, 		--: out Std_Logic;  -- Received Byte
		IntTx_N  => uart0_TxInt, 		--: out Std_Logic;  -- Transmit Buffer Empty
		Addr     => uart0_Addr, 	--: in  Std_Logic_Vector(1 downto 0); -- 
		DataIn   => uart0_DataOut,	--: in  Std_Logic_Vector(7 downto 0); -- 
		DataOut  => uart0_DataIn	--: out Std_Logic_Vector(7 downto 0)); -- 				
	);		
		




		
	LEDR(0) <= '1' when LEDRED(0) = '1' else '0';
	LEDR(1) <= '1' when LEDRED(1) = '1' else '0';
	LEDR(2) <= '1' when LEDRED(2) = '1' else '0';
	LEDR(3) <= '1' when LEDRED(3) = '1' else '0';
	LEDR(4) <= '1' when LEDRED(4) = '1' else '0';
	LEDR(5) <= '1' when LEDRED(5) = '1' else '0';
	LEDR(6) <= '1' when LEDRED(6) = '1' else '0';
	LEDR(7) <= '1' when LEDRED(7) = '1' else '0';	

    	
    	
	INT_n <= '0' when uart0_RxInt ='1' else '1'; 
    
    
    -- Block any of these and CPU will not run -- ?????
	LEDG(0) <= uart0_RxInt;
	LEDG(1) <= uart0_TxInt;
	LEDG(5) <= INT_n;
	------------------------------------------------------
	
	LEDG(6) <= clk10sec;
	LEDG(7) <= clk1hz;
	
	SRAM_DQ(15 downto 8) <= (others => 'Z');
	SRAM_ADDR(17 downto 16) <= "00";
	SRAM_UB_N <= '1';
	SRAM_LB_N <= '0';
	SRAM_CE_N <= '0';
	--
	UART_TXD <= 'Z';
	DRAM_ADDR <= (others => '0');
	DRAM_LDQM <= '0';
	DRAM_UDQM <= '0';
	DRAM_WE_N <= '1';
	DRAM_CAS_N <= '1';
	DRAM_RAS_N <= '1';
	DRAM_CS_N <= '1';
	DRAM_BA_0 <= '0';
	DRAM_BA_1 <= '0';
	DRAM_CLK <= '0';
	DRAM_CKE <= '0';

    FL_ADDR(21 downto 16) <= b"000000";
    FL_RST_N <= '1';    	-- Reset
    
	TDO <= '0';
	I2C_SCLK <= '0';
	AUD_DACDAT <= '0';
	AUD_XCK <= '0';
	-- Set all bidirectional ports to tri-state
	DRAM_DQ     <= (others => 'Z');

	I2C_SDAT    <= 'Z';
	AUD_ADCLRCK <= 'Z';
	AUD_DACLRCK <= 'Z';
	AUD_BCLK    <= 'Z';
	GPIO_0 <= (others => 'Z');
	GPIO_1 <= (others => 'Z');	
end;