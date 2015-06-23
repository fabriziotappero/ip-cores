------------------------------------------------------------------
-- Universal dongle board source code
-- 
-- Copyright (C) 2006 Artec Design <jyrit@artecdesign.ee>
-- 
-- This source code is free hardware; you can redistribute it and/or
-- modify it under the terms of the GNU Lesser General Public
-- License as published by the Free Software Foundation; either
-- version 2.1 of the License, or (at your option) any later version.
-- 
-- This source code is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
-- Lesser General Public License for more details.
-- 
-- You should have received a copy of the GNU Lesser General Public
-- License along with this library; if not, write to the Free Software
-- Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
-- 
-- 
-- The complete text of the GNU Lesser General Public License can be found in 
-- the file 'lesser.txt'.


-- Coding for seg_out(7:0)  "01101101"
--
--                bit 0,A 
--                 ----------
--                |          |
--                |          |
--             5,F|          |  1,B
--                |    6,G   |
--                 ----------
--                |          |
--                |          |
--             4,E|          |  2,C
--                |    3,D   |
--                 ----------  
--                              # 7,H

-- Revision history
--
-- Version 1.01
-- 15 oct 2006	version code 86 01	jyrit
-- Added IO write to address 0x0088  with commands F1 and F4 to
-- enable switching dongle to 4Meg mode for external reads
-- Changed USB interface to address all 4 Meg on any mode jumper configuration
--
-- Version 1.02
-- 04 dec 2006 version code 86 02 jyrit
-- Added listen only mode for mode pin configuration "00" to enable post code
-- spy mode (does not respond to external reads).


library ieee;
use ieee.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;
use work.serial_usb_package.all;
use work.dongle_arch.all;

entity design_top is
	port(
		--system signals
		sys_clk      : in    std_logic; --25 MHz clk
		resetn       : in    std_logic;
		hdr          : inout std_logic_vector(15 downto 0);
		hdr_b        : inout std_logic_vector(15 downto 0);
		--alt_clk    : out    std_logic;    

		mode         : inout std_logic_vector(2 downto 0); --sel upper addr bits
		--lpc slave interf
		lad          : inout std_logic_vector(3 downto 0);
		lframe_n     : in    std_logic;
		lreset_n     : in    std_logic;
		lclk         : in    std_logic;
		ldev_present : out   std_logic;
		lserirq      : inout std_logic;
		--led system    
		seg_out      : out   std_logic_vector(7 downto 0);
		scn_seg      : out   std_logic_vector(3 downto 0);
		scn_seg2     : out   std_logic_vector(3 downto 0); --parallel line to get more current

		led_green    : out   std_logic;
		led_red      : out   std_logic;
		--flash interface
		fl_addr      : out   std_logic_vector(23 downto 0);
		fl_ce_n      : out   std_logic; --chip select
		fl_oe_n      : out   std_logic; --output enable for flash
		fl_we_n      : out   std_logic; --write enable
		fl_data      : inout std_logic_vector(15 downto 0);
		fl_rp_n      : out   std_logic; --reset signal
		fl_sts       : in    std_logic; --status signal
		fl_sts_en    : out   std_logic; --enable status signal wiht highZ out
		-- PSRAM aditional signals to flash
		ps_ram_en    : out   std_logic;
		ps_clk       : out   std_logic; --PSRAM clock
		ps_wait      : in    std_logic;
		ps_addr_val  : out   std_logic; --active low
		ps_confr_en  : out   std_logic;
		ps_lsb_en    : out   std_logic;
		ps_msb_en    : out   std_logic;
		-- EEPROM signals
--		ee_di        : out   std_logic;
--		ee_do        : in    std_logic;
--		ee_hold_n    : out   std_logic;
--		ee_cs_n      : out   std_logic;
--		ee_clk       : out   std_logic;
--		ee_write     : out   std_logic;
		-- PROG enable
		buf_oe_n     : out   std_logic;
		--USB parallel interface
		usb_rd_n     : out std_logic; -- enables out data if low (next byte detected by edge / in usb chip)
		usb_wr       : out std_logic; -- write performed on edge \ of signal
		usb_txe_n    : in    std_logic; -- transmit enable (redy for new data if low)
		usb_rxf_n    : in    std_logic; -- rx fifo has data if low
		usb_bd       : inout std_logic_vector(7 downto 0) --bus data
	);
end design_top;

architecture rtl of design_top is
	component led_sys                   --toplevel for led system
		generic(
			msn_hib : std_logic_vector(7 downto 0); --Most signif. of hi byte
			lsn_hib : std_logic_vector(7 downto 0); --Least signif. of hi byte
			msn_lob : std_logic_vector(7 downto 0); --Most signif. of hi byte
			lsn_lob : std_logic_vector(7 downto 0) --Least signif. of hi byte	
		);
		port(
			clk        : in  std_logic;
			reset_n    : in  std_logic;
			led_data_i : in  std_logic_vector(15 downto 0); --binary data in
			seg_out    : out std_logic_vector(7 downto 0); --one segment out
			sel_out    : out std_logic_vector(3 downto 0) --segment scanner with one bit low
		);
	end component;

	component lpc_iow
		port(
			--system signals
			lreset_n   : in  std_logic;
			lclk       : in  std_logic;
			lena_mem_r : in  std_logic; --enable full adress range covering memory read block
			lena_reads : in  std_logic; --enable read capabilities
			uart_addr  : in  std_logic_vector(15 downto 0); -- define UART address to listen to					
			--LPC bus from host
			lad_i      : in  std_logic_vector(3 downto 0);
			lad_o      : out std_logic_vector(3 downto 0);
			lad_oe     : out std_logic;
			lframe_n   : in  std_logic;
			--memory interface
			lpc_addr   : out std_logic_vector(23 downto 0); --shared address
			lpc_wr     : out std_logic; --shared write not read
			lpc_io     : out std_logic;     --io access not mem access select
			lpc_uart   : out std_logic;     --uart mapped cycle coming
			lpc_gpioled: out std_logic;     --gpio led cycle coming
			lpc_data_i : in  std_logic_vector(7 downto 0);
			lpc_data_o : out std_logic_vector(7 downto 0);
			lpc_val    : out std_logic;
			lpc_ack    : in  std_logic
		);
	end component;

	component flash_if
		port(
			clk       : in    std_logic;
			reset_n   : in    std_logic;
			mode      : in    std_logic_vector(2 downto 0); --sel upper addr bits
			--flash Bus
			fl_addr   : out   std_logic_vector(23 downto 0);
			fl_ce_n   : out   std_logic; --chip select
			fl_oe_n   : out   std_logic; --output enable for flash
			fl_we_n   : out   std_logic; --write enable
			fl_data   : inout std_logic_vector(15 downto 0);
			fl_rp_n   : out   std_logic; --reset signal
			fl_byte_n : out   std_logic; --hold in byte mode
			fl_sts    : in    std_logic; --status signal
			-- mem Bus
			mem_addr  : in    std_logic_vector(23 downto 0);
			mem_do    : out   std_logic_vector(15 downto 0);
			mem_di    : in    std_logic_vector(15 downto 0);
			mem_wr    : in    std_logic; --write not read signal
			mem_val   : in    std_logic;
			mem_ack   : out   std_logic
		);
	end component;

	component usb2mem
		port(
			clk25         : in    std_logic;
			reset_n       : in    std_logic;
			dongle_ver    : in    std_logic_vector(15 downto 0);
			pcb_ver       : in    std_logic_vector(15 downto 0);
			mode          : in    std_logic_vector(2 downto 0); --sel upper addr bits
			usb_buf_en    : out   std_logic;
			dev_present_n : out   std_logic;
			-- mem Bus
			mem_busy_n    : in    std_logic;
			mem_idle      : out   std_logic; -- '1' if controller is idle (flash is safe for LPC reads)
			mem_addr      : out   std_logic_vector(23 downto 0);
			mem_do        : out   std_logic_vector(15 downto 0);
			mem_di        : in    std_logic_vector(15 downto 0);
			mem_wr        : out   std_logic;
			mem_val       : out   std_logic;
			mem_ack       : in    std_logic;
			mem_cmd       : out   std_logic;
			-- USB port
			usb_mode_en   : in    std_logic; -- enable this block 
			usb_rd_n      : out   std_logic; -- enables out data if low (next byte detected by edge / in usb chip)
			usb_wr        : out   std_logic; -- write performed on edge \ of signal
			usb_txe_n     : in    std_logic; -- tx fifo empty (redy for new data if low)
			usb_rxf_n     : in    std_logic; -- rx fifo empty (data redy if low)
			usb_bd_o   	  : out   std_logic_vector(7 downto 0); --bus data			
			usb_bd        : in    std_logic_vector(7 downto 0) --bus data
		);
	end component;

	component pc_serializer
		Port(                           --system signals
			sys_clk         : in    STD_LOGIC;
			resetn          : in    STD_LOGIC;
			--postcode data port
			dbg_data        : in    STD_LOGIC_VECTOR(7 downto 0);
			dbg_wr          : in    STD_LOGIC; --write not read
			dbg_full        : out   STD_LOGIC; --write not read
			dbg_almost_full : out   STD_LOGIC;
			dbg_usedw       : out   STD_LOGIC_VECTOR(12 DOWNTO 0);
			--debug USB port
			dbg_usb_mode_en : in    std_logic; -- enable this debug mode
			dbg_usb_wr      : out   std_logic; -- write performed on edge \ of signal
			dbg_usb_txe_n   : in    std_logic; -- tx fifo not full (redy for new data if low)
			dbg_usb_bd      : out std_logic_vector(7 downto 0) --bus data
		);
	end component;

	component serial_usb
		port(
			clock		: in  std_logic;
			reset_n		: in  std_logic;		
			--VCI Port
			vci_in		: in vci_slave_in;
			vci_out		: out vci_slave_out;
			--FTDI fifo interface
			uart_ena	: in usbser_ctrl;
			fifo_out	: out usb_out;
			fifo_in		: in usb_in
		);
	end component;
	
	component serirq
		port (
			clock : in std_logic;
			reset_n : in std_logic;
			slot_sel : in std_logic_vector(4 downto 0); --clk no of IRQ defined in Ser irq for PCI systems spec.
			serirq : inout std_logic;
			irq : in std_logic		
		);
	end component;	
	
	
	--LED signals
	signal data_to_disp : std_logic_vector(15 downto 0);

	signal scn_seg_w : std_logic_vector(3 downto 0);
	--END LED SIGNALS

	--lpc signals
	signal lad_i  : std_logic_vector(3 downto 0);
	signal lad_o  : std_logic_vector(3 downto 0);
	signal lad_oe : std_logic;

	signal lpc_debug     : std_logic_vector(31 downto 0);
	signal lpc_debug_cnt : std_logic_vector(15 downto 0);
	signal lpc_addr      : std_logic_vector(23 downto 0); --shared address
	signal lpc_data_o    : std_logic_vector(7 downto 0);
	signal lpc_data_i    : std_logic_vector(7 downto 0);
	signal lpc_wr        : std_logic;   --shared write not read
	signal lpc_io		 : std_logic; --io cycle not mem cycle
	signal lpc_uart   	 : std_logic;     --uart mapped cycle coming
	signal lpc_gpioled	 : std_logic;     --gpio led cycle coming			
	signal lpc_ack       : std_logic;
	signal lpc_val       : std_logic;
	signal lena_mem_r    : std_logic;   --enable full adress range covering memory read block
	signal lena_reads    : std_logic;   --enable/disables all read capabilty to make the device post code capturer

	signal c25_lpc_val     : std_logic;
	signal c25_lpc_io	   : std_logic;
	signal c25_lpc_uart	   : std_logic;
	signal c25_lpc_wr      : std_logic; --shared write not read
	signal c25_lpc_wr_long : std_logic; --for led debug data latching

	signal c33_lpc_wr_long  : std_logic; --for led debug data latching
	signal c33_lpc_wr       : std_logic; --for led debug data latching
	signal c33_lpc_wr_wait  : std_logic; --for led debug data latching
	signal c33_lpc_wr_waitd : std_logic; --for led debug data latching
	signal c33_wr_cnt       : std_logic_vector(23 downto 0); --for led debug data latching
	signal c33_led_ack      : std_logic; --for led debug data latching


	--End lpc signals

	--Flash signals
	signal mem_addr : std_logic_vector(23 downto 0);
	signal mem_do   : std_logic_vector(15 downto 0);
	signal mem_di   : std_logic_vector(15 downto 0);
	signal mem_wr   : std_logic;        --write not read signal
	signal mem_val  : std_logic;
	signal mem_ack  : std_logic;

	signal c33_mem_ack : std_logic;     --sync signal


	signal fl_ce_n_w : std_logic;       --chip select
	signal fl_oe_n_w : std_logic;       --output enable for flash
	signal fl_we_n_w : std_logic;       --output enable for flash


	--END flash signals

	-- UART signals
	signal uart_addr    : std_logic_vector(15 downto 0); -- define UART address to listen to
   signal uart_name    : STD_LOGIC_VECTOR(7 downto 0);	
	signal clock		: std_logic;
	signal reset_n		: std_logic;
	
	signal pc_loop_en :  std_logic;
			--VCI Port
	signal uart_vci_in		: vci_slave_in;
	signal uart_vci_out		: vci_slave_out;
			--FTDI fifo interface
	signal uart_ena		: usbser_ctrl;
	signal uart_fifo_out		: usb_out;
	signal uart_fifo_in		: usb_in;
	signal c33_uart_ack		: std_logic;
	-- end UART

	--USB signals
	signal dbg_data       : STD_LOGIC_VECTOR(7 downto 0);
	signal c25_dbg_addr_d : STD_LOGIC_VECTOR(7 downto 0);
	signal c33_dbg_addr_d : STD_LOGIC_VECTOR(7 downto 0);

	signal dbg_wr          : STD_LOGIC; --write not read
	signal c25_dbg_wr 		: STD_LOGIC; --write not read
	signal dbg_usb_wr		  : STD_LOGIC;
	--signal dbg_full        : STD_LOGIC; --write not read
	signal dbg_almost_full : STD_LOGIC;
	signal dbg_usedw       : STD_LOGIC_VECTOR(12 DOWNTO 0);
	signal dbg_usb_bd		  : STD_LOGIC_VECTOR(7 downto 0);
	
	signal dbg_usb_mode_en : std_logic;
	signal usb_mode_en     : std_logic;
	signal mem_usb_rd_n	  : std_logic;
	signal mem_usb_wr		  : std_logic;
	signal mem_usb_bd_o   : STD_LOGIC_VECTOR(7 downto 0);
	
	signal mem_idle        : std_logic;
	signal umem_addr       : std_logic_vector(23 downto 0);
	signal umem_do         : std_logic_vector(15 downto 0);
	signal umem_wr         : std_logic;
	signal umem_val        : std_logic;
	signal umem_ack        : std_logic;
	--signal umem_cmd        : std_logic;
	signal enable_4meg     : std_logic;
	signal enable_4meg_r     : std_logic;  --4 meg ena register
	
	signal dongle_con_n    : std_logic; -- set by device side/unset with IO write to enable/disalbe dongle memory

	signal ldev_present_w : std_logic;  --output from USB subsystem to show what command has been sent by PC

	signal slot_sel : std_logic_vector(4 downto 0);

	signal com_force : std_logic_vector(3 downto 0);
	signal jmp_io_leds : std_logic_vector(7 downto 0);

	signal c33_jmp_settings : std_logic_vector(7 downto 0);
	signal jmp_settings : std_logic_vector(7 downto 0);
	signal jmp_value    : std_logic_vector(7 downto 0);
	signal jmp_leds     : std_logic_vector(7 downto 0);
	signal jmp_cnt      : std_logic_vector(7 downto 0);

	constant dongle_ver : std_logic_vector(15 downto 0) := x"8623";
	constant pcb_ver    : std_logic_vector(15 downto 0) := x"0836"; -- proj. no and PCB ver in hexademical
--END USB signals

begin

	--PSRAM static signals
	ps_lsb_en   <= '0';
	ps_msb_en   <= '0';
	ps_addr_val <= '0';                 --use async PSRAM access
	ps_clk      <= '0';
	ps_confr_en <= '0';

	ps_ram_en <= fl_ce_n_w when mode(2) = '1' else
		'1';

	--GPIO PINS START
	fl_sts_en <= 'Z';

	JMP_FETCH : process(sys_clk, resetn) --c33
	begin
		if resetn = '0' then
			jmp_settings <= x"00";
			jmp_cnt      <= x"00";
			jmp_leds     <= x"FF";
		elsif sys_clk'event and sys_clk = '1' then -- rising clock edge
			jmp_cnt <= jmp_cnt + 1;
			if jmp_cnt = x"FE" then
				jmp_leds <= x"00";      --light leds
			elsif jmp_cnt = x"00" then
				jmp_settings <= jmp_value;
				jmp_leds     <= jmp_io_leds; --show last settings this is ok as leds are slow
			end if;

		end if;
	end process JMP_FETCH;

	hdr(14) <= jmp_leds(7);
	hdr(12) <= jmp_leds(6);
	hdr(10) <= jmp_leds(5);
	hdr(8) <= jmp_leds(4);
	hdr(6) <= jmp_leds(3);
	hdr(4) <= jmp_leds(2);
	hdr(2) <= jmp_leds(1);
	hdr(0) <= jmp_leds(0);

	jmp_value(0) <= hdr(1); --3,4
	jmp_value(1) <= hdr(3); --5,6
	jmp_value(2) <= hdr(5); --7,8
	jmp_value(3) <= hdr(7); --9,10
	jmp_value(4) <= hdr(9); --11,12
	jmp_value(5) <= hdr(11);--13,14
	jmp_value(6) <= hdr(13);
	jmp_value(7) <= hdr(15);

	--hdr(1) <= dongle_con_n;  --commented out for firm rev 0x20

	--hdr(1) <= fl_sts when resetn='1' else
	--		  '0';

	--SETTING #0
	--when jumper on then mem read and firmware read enabled else only firmware read
	--hdr(0) <= '0';  --commented out for firm rev 0x20
	lena_mem_r <= not jmp_settings(0);  -- disabled if jumper is not on header pins 1-2

	--SETTING #1
	-- jumper on pins 5,6 then postcode only mode (no mem device)
	--hdr(2) <= '0'; --create low pin for jumper pair 5-6 (this pin is 6 on J1 header)  --commented out for firm rev 0x20
	lena_reads <= jmp_settings(1) and mem_idle and(not dongle_con_n); -- disabled if jumper is on (jumper makes it a postcode only device) paired with hdr(2) pins 5,6 and when usb control is not accessing flash

	--ldev_present_w is active low '1' menaing not present ;)
	ldev_present <= '1' when lena_reads = '0' and ldev_present_w = '0' else --when jumper or IO disable and USB ena bit is default then look disconnected
		'1' when ldev_present_w = '1' else --when dev present is removed from USB override jumper and LPC IO
		'0';

	--SETTING #2
	-- when jumpers on pins 7,8| 9,10 | 11,12 > jmp_settings (2,3,4)  (need inverting as on is '0')
	-- off,off,off PC utility access enabled     > 111
	-- off,off,on UART on base address 0x3F8     > 110
	-- off,on,off UART on base address 0x2F8     > 101
	-- off,on,on UART on base address 0x3E8      > 100
	-- on,on,on UART on base address 0x2E8	      > 000
	-- on,on,off pc side UART loop ena			   > 001
	-- on,off,off post code capture mode enabled > 011

	uart_addr <=x"03F8" when com_force(2 downto 0)="001" else
				x"02F8" when com_force(2 downto 0)="010" else
				x"03E8" when com_force(2 downto 0)="011" else
				x"02E8" when com_force(2 downto 0)="100" else 
				x"03F8" when jmp_settings(4 downto 2)="011" else
				x"02F8" when jmp_settings(4 downto 2)="101" else
				x"03E8" when jmp_settings(4 downto 2)="001" else
				x"02E8" when jmp_settings(4 downto 2)="000" else
				x"0000"; --uart diabled as bit 3 is 0
	
	slot_sel <= "01011" when com_force(2 downto 0)="010" or com_force(2 downto 0)="100" else
				"01110" when com_force(2 downto 0)="001" or com_force(2 downto 0)="011" else 
				"01011" when jmp_settings(4 downto 2)="101" or jmp_settings(4 downto 2)="000" else
				"01110" when jmp_settings(4 downto 2)="011" or jmp_settings(4 downto 2)="001" else
				"00000";
		
	uart_name<=x"C1" when com_force(2 downto 0)="001" else
				x"C2" when com_force(2 downto 0)="010" else
				x"C3" when com_force(2 downto 0)="011" else
				x"C4" when com_force(2 downto 0)="100" else 
				x"C1" when jmp_settings(4 downto 2)="011" else
				x"C2" when jmp_settings(4 downto 2)="101" else
				x"C3" when jmp_settings(4 downto 2)="001" else
				x"C4" when jmp_settings(4 downto 2)="000" else
				x"00"; --uart diabled as bit 3 is 0
		
	--SETTING #3			
	-- when jumper on pins 13, 14 mem window override to 4Meg mode (Used for intel atom boot) jmp_settings(5)
	-- look at the LATCHled process enable_4meg signal 
	
	
	uart_ena.mode_en <= uart_addr(3); -- when bit3 is up in addr uart is enabled
		
	dbg_usb_mode_en <= '1' when jmp_settings(4 downto 2)="110" else  --post code logging
						'0';
	
	usb_mode_en <= '1' when jmp_settings(4 downto 2)="111" else  --all off is pc mode
					'0';



	--GPIO PINS END


	--LED SUBSYSTEM START
	data_to_disp <= x"86" & lpc_debug(7 downto 0) when usb_mode_en = '1' and resetn = '1' else --x"C0DE"; -- ASSIGN data to be displayed (should be regitered)
						uart_name&lpc_debug(7 downto 0)  when uart_ena.mode_en='1' and resetn = '1' else
						"000" & dbg_usedw when usb_mode_en = '0' and resetn = '1' else
						dongle_ver;                     --show tx fifo state on leds when postcode capture mode


	--########################################--
	--VERSION CONSTATNS
	--########################################--
	led_red   <= not enable_4meg;
	led_green <= not mem_val;

	LEDS : led_sys                      --toplevel for led system
		generic map(
			msn_hib => "10111111",      -- not used			"01111111",--8  --Most signif. of hi byte  
			lsn_hib => "10111111",      -- not used			"01111101",--6   --Least signif. of hi byte
			msn_lob => "10111111",      -- not used			0  --Most signif. of hi byte   This is version code
			--lsn_lob => "01001111"-- not used			3   --Least signif. of hi byte	This is version code
			--lsn_lob => "01100110"-- not used			4   --Least signif. of hi byte	This is version code
			--lsn_lob => "01101101"-- not used			5    --sync with dongle version const.  Least signif. of hi byte This is version code
			lsn_lob => "10111111"       -- not used
		)
		port map(
			clk        => sys_clk,      -- in std_logic;
			reset_n    => resetn,       -- in std_logic;
			led_data_i => data_to_disp, -- in  std_logic_vector(15 downto 0);   --binary data in
			seg_out    => seg_out,      -- out std_logic_vector(7 downto 0); --one segment out
			sel_out    => scn_seg_w     -- out std_logic_vector(3 downto 0)  --segment scanner with one bit low
		);

	scn_seg  <= scn_seg_w;
	scn_seg2 <= scn_seg_w;

	--LED SUBSYSTEM END


	--MAIN DATAPATH CONNECTIONS
	--LPC bus logic
	lad_i <= lad;
	lad   <= lad_o when lad_oe = '1' else(others => 'Z');

	--END LPC bus logic

	LPCBUS : lpc_iow
		port map(
			--system signals
			lreset_n   => lreset_n,     -- in  std_logic;
			lclk       => lclk,         -- in  std_logic;
			lena_mem_r => lena_mem_r,   --: in  std_logic;    --enable full adress range covering memory read block
			lena_reads => lena_reads,   -- : in  std_logic;  --enable read capabilities, : in  std_logic;  --enable read capabilities
			uart_addr  => uart_addr,
			--LPC bus from host
			lad_i      => lad_i,        -- in  std_logic_vector(3 downto 0);
			lad_o      => lad_o,        -- out std_logic_vector(3 downto 0);
			lad_oe     => lad_oe,       -- out std_logic;
			lframe_n   => lframe_n,     -- in  std_logic;
			--memory interface
			lpc_addr   => lpc_addr,     -- out std_logic_vector(23 downto 0); --shared address
			lpc_wr     => lpc_wr,       -- out std_logic;         --shared write not read
			lpc_io     => lpc_io, --: out std_logic;     --io access not mem access select
			lpc_uart   => lpc_uart,
			lpc_gpioled=> lpc_gpioled, --: out std_logic;     --gpio led cycle coming
			lpc_data_i => lpc_data_i,   -- in  std_logic_vector(7 downto 0);
			lpc_data_o => lpc_data_o,   -- out std_logic_vector(7 downto 0);  
			lpc_val    => lpc_val,      -- out std_logic;
			lpc_ack    => lpc_ack       -- in  std_logic
		);

	--memory data bus logic
	mem_addr <= mode(1 downto 0) & "11" & lpc_addr(19 downto 0) when c25_lpc_val = '1' and enable_4meg = '0' else --use mode bist
		mode(1 downto 0) & lpc_addr(21 downto 0) when c25_lpc_val = '1' and enable_4meg = '1' else --use mode bist
		mode(1 downto 0) & umem_addr(21 downto 0) when umem_val = '1' else --use mode bist
(others => 'Z');

	mem_di <=(others => 'Z') when c25_lpc_val = '1' else
		umem_do when umem_val = '1' else(others => 'Z');

	mem_wr <= c25_lpc_wr when c25_lpc_val = '1' and c25_lpc_wr = '0' else --pass read olny
		umem_wr when umem_val = '1' else
		'0';

	mem_val <= (c25_lpc_val and not c25_lpc_io) or umem_val;

	umem_ack <= mem_ack when umem_val = '1' else
		'0';

	uart_vci_in.lpc_val <= c25_lpc_val when c25_lpc_uart='1' else
							'0';
	uart_vci_in.lpc_wr <= c25_lpc_wr;  --can be connected as val is needed to do the cycle
						  
	uart_vci_in.lpc_addr <= x"000"&'0'&lpc_addr(2 downto 0); --these are stable when val is up so sync needed
	uart_vci_in.lpc_data_o <= lpc_data_o; --these are stable when val is up so sync needed

	lpc_data_i <= mem_do(7 downto 0) when lpc_addr(0) = '0' and lpc_io='0' else
				  mem_do(15 downto 8) when lpc_io='0' else
				  c33_jmp_settings when lpc_gpioled='1' and lpc_io='1' else -- IO read to 0x84 (jumper status)
				  uart_vci_out.lpc_data_i when lpc_uart='1' and lpc_io='1' else  --IO read data for UART 
				  (others=>'0');

	lpc_ack <= c33_mem_ack when lpc_val = '1' and lpc_wr = '0' and lpc_io='0' else --all mem cycles
			   c33_uart_ack when lpc_val = '1' and lpc_io='1' and lpc_uart='1' else --we have UART bound IO cycle
			   c33_led_ack when lpc_val = '1' and lpc_io='1' and lpc_gpioled='1' else --we have IO 0x84 acking bound IO cycle this needs no wait so the ack can be looped back			   
			   (not dbg_almost_full) when lpc_val = '1' and lpc_wr = '1' and lpc_io='1' else --debug write to 80 and 88 IO cycle
			   '0';

	SYNC1 : process(lclk, lreset_n)     --c33
	begin
		if lclk'event and lclk = '1' then -- rising clock edge
			c33_mem_ack <= mem_ack;
			c33_uart_ack <= uart_vci_out.lpc_ack;
			c33_led_ack<= lpc_val; --loop val back to ack for leds
		end if;
	end process SYNC1;

	dbg_data <= lpc_debug(7 downto 0);
	SYNC2 : process(sys_clk)            --c25
	begin
		if sys_clk'event and sys_clk = '1' then -- rising clock edge
			c25_lpc_val <= lpc_val;  --syncro two clock domains
			c25_lpc_io <= lpc_io;
			c25_lpc_uart <= lpc_uart;
			c25_lpc_uart <= lpc_uart;
			c25_lpc_wr <= lpc_wr; --syncro two clock domains
			c25_dbg_wr <= c33_lpc_wr; --delayed write
			c25_dbg_addr_d <= c33_dbg_addr_d; --syncro two clock domains
			if uart_ena.mode_en='0' and usb_mode_en = '0' and c25_dbg_addr_d = x"80" and c25_lpc_io='1' then --don't fill fifo in regular mode
				dbg_wr <= c25_lpc_wr;   --c33_lpc_wr_wait;--c33_lpc_wr_wait;
			else
				dbg_wr <= '0';          --write never rises when usb_mode_en = 1
			end if;
		end if;
	end process SYNC2;

	LATCHled : process(lclk, lreset_n)  --c33
	begin
		if lreset_n = '0' then
			lpc_debug(7 downto 0) <=(others => '0');
			c33_dbg_addr_d <=(others => '0');
			jmp_io_leds<=(others => '1');
			com_force<=(others =>'0');
			enable_4meg    <= '0';
			enable_4meg_r  <= '0';
			c33_lpc_wr     <= '0';
			dongle_con_n   <= '0';      -- pin 3 in GPIO make it toggleable
		elsif lclk'event and lclk = '1' then -- rising clock edge

			
			if lpc_val = '1' and lpc_io='1' and lpc_gpioled='1' then
				jmp_io_leds<=not lpc_data_o;
			end if;
			c33_jmp_settings<=not jmp_settings; --invert for better understanding jumper on is
			c33_lpc_wr <= lpc_wr;
			if c33_lpc_wr = '0' and lpc_wr = '1' and lpc_io='1' then
				c33_dbg_addr_d        <= lpc_addr(7 downto 0);
				if lpc_addr(7 downto 0) = x"80" then
          lpc_debug(7 downto 0) <= lpc_data_o;
				end if;
				
				if lpc_addr(7 downto 0) = x"88" and lpc_data_o = x"F4" then --Flash 4 Mega enable (LSN is first MSN is second)
					enable_4meg_r <= '1';
				elsif lpc_addr(7 downto 0) = x"88" and lpc_data_o = x"F1" then --Flash 1 Mega enalbe
					enable_4meg_r <= '0';
				elsif lpc_addr(7 downto 0) = x"88" and lpc_data_o = x"D1" then --Set Dongle not attached signal
					dongle_con_n <= '1'; -- pin 3 in GPIO make it 1
				elsif lpc_addr(7 downto 0) = x"88" and lpc_data_o = x"D0" then --Set Dongle attached signal
					dongle_con_n <= '0'; -- pin 3 in GPIO make it 1
				elsif lpc_addr(7 downto 0) = x"88" and lpc_data_o = x"C1" then --Set Dongle attached signal
					com_force<=x"1";
				elsif lpc_addr(7 downto 0) = x"88" and lpc_data_o = x"C2" then --Set Dongle attached signal
					com_force<=x"2";				
				elsif lpc_addr(7 downto 0) = x"88" and lpc_data_o = x"C3" then --Set Dongle attached signal
					com_force<=x"3";				
				elsif lpc_addr(7 downto 0) = x"88" and lpc_data_o = x"C4" then --Set Dongle attached signal
					com_force<=x"4";															
				end if;
			end if;
			if jmp_settings(5)='0' then --0 is jumper on, meaning force 4 M mode
				enable_4meg<='1';
			else 
				enable_4meg<=enable_4meg_r;
			end if;
			
		end if;
	end process LATCHled;

	--END memory data bus logic
	fl_ce_n <= fl_ce_n_w when mode(2) = '0' else
		'1';
	fl_oe_n <= fl_oe_n_w;
	fl_we_n <= fl_we_n_w;

	FLASH : flash_if
		port map(
			clk      => sys_clk,        -- in  std_logic;
			reset_n  => resetn,         -- in  std_logic;
			mode     => mode,           -- : in    std_logic_vector(2 downto 0);  --sel upper addr bits
			--flash Bus
			fl_addr  => fl_addr,        -- out std_logic_vector(23 downto 0);
			fl_ce_n  => fl_ce_n_w,      -- out std_logic;       --chip select
			fl_oe_n  => fl_oe_n_w,      -- buffer std_logic;    --output enable for flash
			fl_we_n  => fl_we_n_w,      -- out std_logic;       --write enable
			fl_data  => fl_data,        -- inout std_logic_vector(15 downto 0);
			fl_rp_n  => fl_rp_n,        -- out std_logic;       --reset signal
			--fl_byte_n    => fl_byte_n, -- out std_logic;     --hold in byte mode

			fl_sts   => fl_sts,         -- in std_logic;        --status signal
			-- mem Bus
			mem_addr => mem_addr,       -- in std_logic_vector(23 downto 0);
			mem_do   => mem_do,         -- out std_logic_vector(15 downto 0);
			mem_di   => mem_di,         -- in  std_logic_vector(15 downto 0);

			mem_wr   => mem_wr,         -- in  std_logic;  --write not read signal
			mem_val  => mem_val,        -- in  std_logic;
			mem_ack  => mem_ack         -- out std_logic
		);

	USB : usb2mem
		port map(
			clk25         => sys_clk,   -- in  std_logic;
			reset_n       => resetn,    -- in  std_logic;
			dongle_ver    => dongle_ver,
			pcb_ver       => pcb_ver,   --: in std_logic_vector(15 downto 0);
			mode          => mode,      -- : in    std_logic_vector(2 downto 0);  --sel upper addr bits
			usb_buf_en    => buf_oe_n,  --: out  std_logic;
			dev_present_n => ldev_present_w, --: out  std_logic;
			-- mem Bus
			mem_busy_n    => fl_sts,    --check flash status before starting new command on flash
			mem_idle      => mem_idle,
			mem_addr      => umem_addr, -- out std_logic_vector(23 downto 0);
			mem_do        => umem_do,   -- out std_logic_vector(15 downto 0);
			mem_di        => mem_do,    -- in std_logic_vector(15 downto 0);   --from flash
			mem_wr        => umem_wr,   -- out std_logic;
			mem_val       => umem_val,  -- out std_logic;
			mem_ack       => umem_ack,  -- in  std_logic;  --from flash
			mem_cmd       => open,  -- out std_logic;
			-- USB port
			usb_mode_en   => usb_mode_en,
			usb_rd_n      => mem_usb_rd_n,  -- out  std_logic;  -- enables out data if low (next byte detected by edge / in usb chip)
			usb_wr        => mem_usb_wr,    -- out  std_logic;  -- write performed on edge \ of signal
			usb_txe_n     => usb_txe_n, -- in   std_logic;  -- tx fifo empty (redy for new data if low)
			usb_rxf_n     => usb_rxf_n, -- in   std_logic;  -- rx fifo empty (data redy if low)
			usb_bd_o		  => mem_usb_bd_o,
			usb_bd        => usb_bd     -- in  std_logic_vector(7 downto 0) --bus data
		);

	DBG : pc_serializer
		port map(                       --system signals
			sys_clk         => sys_clk, -- in  STD_LOGIC;
			resetn          => resetn,  -- in  STD_LOGIC;		   
			--postcode data port
			dbg_data        => dbg_data, -- in  STD_LOGIC_VECTOR (7 downto 0);
			dbg_wr          => dbg_wr,  -- in  STD_LOGIC;   --write not read
			dbg_full        => open, --: out STD_LOGIC;   --write not read
			dbg_almost_full => dbg_almost_full,
			dbg_usedw       => dbg_usedw,

			--debug USB port
			dbg_usb_mode_en => dbg_usb_mode_en, -- in   std_logic;  -- enable this debug mode
			dbg_usb_wr      => dbg_usb_wr,  -- out  std_logic;  -- write performed on edge \ of signal
			dbg_usb_txe_n   => usb_txe_n, -- in   std_logic;  -- tx fifo not full (redy for new data if low)
			dbg_usb_bd      => dbg_usb_bd   -- out  std_logic_vector(7 downto 0) --bus data
		);

	UART : serial_usb
		port map (
			clock		=> sys_clk, -- in  std_logic;
			reset_n		=> resetn, -- in  std_logic;
			--VCI Port
			vci_in		=> uart_vci_in, -- in vci_slave_in;
			vci_out		=> uart_vci_out, -- out vci_slave_out;
			--FTDI fifo interface
			uart_ena	=> uart_ena, -- in usbser_ctrl;
			fifo_out	=> uart_fifo_out, -- out usb_out;
			fifo_in		=> uart_fifo_in -- in usb_in
		);
		
	usb_rd_n <= mem_usb_rd_n when usb_mode_en='1' else  --usb to mem reads fom fifo	
				uart_fifo_out.rx_oe_n when uart_ena.mode_en='1' else  --UART read	
				'1'; --keep high
		
	usb_wr <= uart_fifo_out.tx_wr when uart_ena.mode_en='1' else
				 mem_usb_wr when usb_mode_en='1' else
				 dbg_usb_wr when dbg_usb_mode_en='1' else
			    '0';
	
	usb_bd <= uart_fifo_out.txdata when uart_ena.mode_en='1' and uart_fifo_out.tx_wr='1' else
				 dbg_usb_bd when dbg_usb_mode_en='1' and dbg_usb_wr='1' else
				 mem_usb_bd_o when usb_mode_en='1' and mem_usb_wr='1' else
				 (others=>'Z');
			
			
	uart_fifo_in.rxdata <= usb_bd; --this can be in most of the time
	uart_fifo_in.rx_full_n <= usb_rxf_n; --if low there is data
	uart_fifo_in.tx_empty_n <= usb_txe_n; --if low data can be transmitted


	irqgen : serirq
		port map (
			clock => lclk, -- in std_logic;
			reset_n => lreset_n, -- in std_logic;
			slot_sel => slot_sel, -- in std_logic_vector(4 downto 0); --clk no of IRQ defined in Ser irq for PCI systems spec.
			serirq => lserirq, -- inout std_logic;
			irq => uart_vci_out.lpc_irq -- in std_logic;		
		);

--END MAIN DATAPATH CONNECTIONS

end rtl;



