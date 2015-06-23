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



-- Coding for seg_out(7:0)  
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

entity design_top_thincandbg is
  port (
	--system signals
	sys_clk    : in    std_logic;         --25 MHz clk
	resetn     : in    std_logic;     
	hdr		   : inout    std_logic_vector(9 downto 0);
	--alt_clk    : out    std_logic;    
	mode       : in    std_logic_vector(1 downto 0);  --sel upper addr bits
    --lpc slave interf
    lad        : inout std_logic_vector(3 downto 0);
    lframe_n   : in    std_logic;
    lreset_n   : in    std_logic;
    lclk       : in    std_logic;
    --led system    
    seg_out    : out   std_logic_vector(7 downto 0);
    scn_seg    : out   std_logic_vector(3 downto 0);
    led_green  : out   std_logic;
    led_red    : out   std_logic;
    --flash interface
    fl_addr    : out   std_logic_vector(23 downto 0);
    fl_ce_n    : out   std_logic;       --chip select
    fl_oe_n    : out   std_logic;       --output enable for flash
    fl_we_n    : out   std_logic;       --write enable
    fl_data    : inout std_logic_vector(15 downto 0);
    fl_rp_n    : out   std_logic;       --reset signal
    fl_sts     : in    std_logic;        --status signal
	fl_sts_en  : out std_logic;       --enable status signal wiht highZ out
    --USB parallel interface
    usb_rd_n   : inout  std_logic;  -- enables out data if low (next byte detected by edge / in usb chip)
    usb_wr     : inout  std_logic;  -- write performed on edge \ of signal
    usb_txe_n  : in   std_logic;  -- transmit enable (redy for new data if low)
    usb_rxf_n  : in   std_logic;  -- rx fifo has data if low
    usb_bd     : inout  std_logic_vector(7 downto 0) --bus data
    );
end design_top_thincandbg;



architecture rtl of design_top_thincandbg is

component led_sys   --toplevel for led system
  generic(
	msn_hib : std_logic_vector(7 downto 0);  --Most signif. of hi byte
	lsn_hib : std_logic_vector(7 downto 0);  --Least signif. of hi byte
 	msn_lob : std_logic_vector(7 downto 0);  --Most signif. of hi byte
	lsn_lob : std_logic_vector(7 downto 0)  --Least signif. of hi byte	
  );
  port (
    clk				: in std_logic;
    reset_n			: in std_logic;
	led_data_i		: in  std_logic_vector(15 downto 0);   --binary data in
    seg_out			: out std_logic_vector(7 downto 0); --one segment out
    sel_out			: out std_logic_vector(3 downto 0)  --segment scanner with one bit low
    );
end component;


component lpc_iow
  port (
    --system signals
    lreset_n   : in  std_logic;
    lclk       : in  std_logic;
	lena_mem_r : in  std_logic;  --enable full adress range covering memory read block
	lena_reads : in  std_logic;  --enable read capabilities
	--LPC bus from host
    lad_i      : in  std_logic_vector(3 downto 0);
    lad_o      : out std_logic_vector(3 downto 0);
    lad_oe     : out std_logic;
    lframe_n   : in  std_logic;
	--memory interface
    lpc_addr   : out std_logic_vector(23 downto 0); --shared address
    lpc_wr     : out std_logic;         --shared write not read
    lpc_data_i : in  std_logic_vector(7 downto 0);
    lpc_data_o : out std_logic_vector(7 downto 0);  
    lpc_val    : out std_logic;
    lpc_ack    : in  std_logic
    );
end component;


component flash_if
  port (
    clk       : in  std_logic;
    reset_n   : in  std_logic;
    --flash Bus
    fl_addr   : out std_logic_vector(23 downto 0);
    fl_ce_n      : out std_logic;       --chip select
    fl_oe_n      : out std_logic;    --output enable for flash
    fl_we_n      : out std_logic;       --write enable
    fl_data      : inout std_logic_vector(15 downto 0);
    fl_rp_n      : out std_logic;       --reset signal
    fl_byte_n    : out std_logic;     --hold in byte mode
    fl_sts       : in std_logic;        --status signal
    -- mem Bus
    mem_addr  : in std_logic_vector(23 downto 0);
    mem_do    : out std_logic_vector(15 downto 0);
    mem_di    : in  std_logic_vector(15 downto 0);     
    mem_wr    : in  std_logic;  --write not read signal
    mem_val   : in  std_logic;
    mem_ack   : out std_logic
    ); 
end component;


component usb2mem
  port (
    clk25     : in  std_logic;
    reset_n   : in  std_logic;
	dongle_ver: in std_logic_vector(15 downto 0);
    -- mem Bus
    mem_busy_n: in std_logic;
	mem_idle  : out std_logic; -- '1' if controller is idle (flash is safe for LPC reads)
    mem_addr  : out std_logic_vector(23 downto 0);
    mem_do    : out std_logic_vector(15 downto 0);
    mem_di    : in std_logic_vector(15 downto 0);
    mem_wr    : out std_logic;
    mem_val   : out std_logic;
    mem_ack   : in  std_logic;
    mem_cmd   : out std_logic;
    -- USB port
	usb_mode_en: in   std_logic;  -- enable this block 
    usb_rd_n   : out  std_logic;  -- enables out data if low (next byte detected by edge / in usb chip)
    usb_wr     : out  std_logic;  -- write performed on edge \ of signal
    usb_txe_n  : in   std_logic;  -- tx fifo empty (redy for new data if low)
    usb_rxf_n  : in   std_logic;  -- rx fifo empty (data redy if low)
    usb_bd     : inout  std_logic_vector(7 downto 0) --bus data
    ); 
end component;

component pc_serializer 
    Port ( --system signals
           sys_clk : in  STD_LOGIC;
           resetn  : in  STD_LOGIC;		   
		   --postcode data port
           dbg_data : in  STD_LOGIC_VECTOR (7 downto 0);
           dbg_wr   : in  STD_LOGIC;   --write not read
		   dbg_full : out STD_LOGIC;   --write not read
		   dbg_almost_full	: out STD_LOGIC;
		   dbg_usedw		: out STD_LOGIC_VECTOR (12 DOWNTO 0);		
		   --debug USB port
		   dbg_usb_mode_en: in   std_logic;  -- enable this debug mode
		   dbg_usb_wr     : out  std_logic;  -- write performed on edge \ of signal
		   dbg_usb_txe_n  : in   std_logic;  -- tx fifo not full (redy for new data if low)
		   dbg_usb_bd     : inout  std_logic_vector(7 downto 0) --bus data
);
end component;


--LED signals
signal data_to_disp : std_logic_vector(15 downto 0);
--END LED SIGNALS

--lpc signals
signal    lad_i      : std_logic_vector(3 downto 0);
signal    lad_o      : std_logic_vector(3 downto 0);
signal    lad_oe     : std_logic;

signal    lpc_debug  : std_logic_vector(31 downto 0);
signal    lpc_debug_cnt  : std_logic_vector(15 downto 0);
signal    lpc_addr   : std_logic_vector(23 downto 0); --shared address
signal 	  lpc_data_o : std_logic_vector(7 downto 0); 
signal 	  lpc_data_i : std_logic_vector(7 downto 0); 
signal    lpc_wr     : std_logic;        --shared write not read
signal    lpc_ack    : std_logic;
signal    lpc_val    : std_logic;
signal    lena_mem_r : std_logic;  --enable full adress range covering memory read block
signal    lena_reads : std_logic;  --enable/disables all read capabilty to make the device post code capturer

signal    c25_lpc_val  : std_logic;
signal    c25_lpc_wr     : std_logic;        --shared write not read
signal    c25_lpc_wr_long : std_logic;        --for led debug data latching

signal    c33_lpc_wr_long : std_logic;        --for led debug data latching
signal    c33_lpc_wr     : std_logic;        --for led debug data latching
signal    c33_lpc_wr_wait: std_logic;        --for led debug data latching
signal    c33_lpc_wr_waitd: std_logic;        --for led debug data latching
signal    c33_wr_cnt     : std_logic_vector(23 downto 0);        --for led debug data latching


--End lpc signals

--Flash signals
signal    mem_addr  : std_logic_vector(23 downto 0);
signal    mem_do    : std_logic_vector(15 downto 0);
signal    mem_di    : std_logic_vector(15 downto 0);
signal    mem_wr    : std_logic;  --write not read signal
signal    mem_val   : std_logic;
signal    mem_ack   : std_logic;

signal    c33_mem_ack   : std_logic;  --sync signal



signal    fl_ce_n_w : std_logic;       --chip select
signal    fl_oe_n_w : std_logic;    --output enable for flash

--END flash signals

--USB signals
signal    dbg_data :  STD_LOGIC_VECTOR (7 downto 0);
signal    c25_dbg_addr_d :  STD_LOGIC_VECTOR (7 downto 0);
signal    c33_dbg_addr_d :  STD_LOGIC_VECTOR (7 downto 0);

signal    dbg_wr   : STD_LOGIC;   --write not read
signal    dbg_full : STD_LOGIC;   --write not read
signal	  dbg_almost_full	: STD_LOGIC;
signal	  dbg_usedw		: STD_LOGIC_VECTOR (12 DOWNTO 0);

signal    force_4meg_n    : std_logic;
signal    dbg_usb_mode_en    : std_logic;
signal    usb_mode_en    : std_logic;
signal    mem_idle   : std_logic;
signal    umem_addr  : std_logic_vector(23 downto 0);
signal    umem_do    : std_logic_vector(15 downto 0);
signal    umem_wr    : std_logic;
signal    umem_val   : std_logic;
signal    umem_ack   : std_logic;
signal    umem_cmd   : std_logic;
signal    enable_4meg: std_logic;
signal    dongle_con_n : std_logic;

constant dongle_ver  : std_logic_vector(15 downto 0):=x"8606";
--END USB signals

begin

--GPIO PINS START
fl_sts_en <='Z';

hdr(1) <= dongle_con_n;
--hdr(1) <= fl_sts when resetn='1' else
--		  '0';

--when jumper on then mem read and firmware read enabled else only firmware read
hdr(0) <= 'Z';
lena_mem_r <= not hdr(0); -- disabled if jumper is not on header pins 1-2

-- jumper on pins 5,6 then postcode only mode (no mem device)
hdr(2) <= '0'; --create low pin for jumper pair 5-6 (this pin is 6 on J1 header)
lena_reads <= hdr(3) and mem_idle and (not dongle_con_n); -- disabled if jumper is on (jumper makes it a postcode only device) paired with hdr(2) pins 5,6 and when usb control is not accessing flash


-- when jumper on pins 7,8 then post code capture mode enabled
hdr(4)<= '0';
dbg_usb_mode_en <= not hdr(5);  --weak pullup on hdr(5) paired with hdr(4)
usb_mode_en <= not dbg_usb_mode_en;  

-- when jumper on pins 9,10 then 4M window is forced
hdr(6)<= '0';
force_4meg_n <= hdr(7);  --weak pullup on hdr(7) paired with hdr(6)

--GPIO PINS END

--LED SUBSYSTEM START
data_to_disp <= x"86"&lpc_debug(7 downto 0) when usb_mode_en='1' else	--x"C0DE"; -- ASSIGN data to be displayed (should be regitered)
				"000"&dbg_usedw;  --show tx fifo state on leds when postcode capture mode
--########################################--
	  		--VERSION CONSTATNS
--########################################--
led_red <= enable_4meg;

LEDS: led_sys   --toplevel for led system
  generic map(
	msn_hib => "01111111",--8  --Most signif. of hi byte  
	lsn_hib => "01111101",--6   --Least signif. of hi byte
 	msn_lob => "10111111",--0  --Most signif. of hi byte   This is version code
	--lsn_lob => "01001111" --3   --Least signif. of hi byte	This is version code
	--lsn_lob => "01100110" --4   --Least signif. of hi byte	This is version code
    --lsn_lob => "01101101" --5    --sync with dongle version const.  Least signif. of hi byte This is version code
    lsn_lob => "01111101" --6    --sync with dongle version const.  Least signif. of hi byte This is version code
	
  )
  port map(
    clk				=> sys_clk , -- in std_logic;
    reset_n			=> resetn, -- in std_logic;
	led_data_i		=> data_to_disp, -- in  std_logic_vector(15 downto 0);   --binary data in
    seg_out			=> seg_out, -- out std_logic_vector(7 downto 0); --one segment out
    sel_out			=> scn_seg -- out std_logic_vector(3 downto 0)  --segment scanner with one bit low
    );

--LED SUBSYSTEM END


--MAIN DATAPATH CONNECTIONS
--LPC bus logic
lad_i <= lad;
lad <=	lad_o when lad_oe='1' else
		(others=>'Z');

--END LPC bus logic

LPCBUS : lpc_iow
  port map(
    --system signals
    lreset_n   => lreset_n, -- in  std_logic;
    lclk       => lclk, -- in  std_logic;
	lena_mem_r => lena_mem_r, --: in  std_logic;    --enable full adress range covering memory read block
	lena_reads => lena_reads, -- : in  std_logic;  --enable read capabilities, : in  std_logic;  --enable read capabilities
	--LPC bus from host
    lad_i      => lad_i, -- in  std_logic_vector(3 downto 0);
    lad_o      => lad_o, -- out std_logic_vector(3 downto 0);
    lad_oe     => lad_oe, -- out std_logic;
    lframe_n   => lframe_n, -- in  std_logic;
	--memory interface
    lpc_addr   => lpc_addr, -- out std_logic_vector(23 downto 0); --shared address
    lpc_wr     => lpc_wr, -- out std_logic;         --shared write not read
    lpc_data_i => lpc_data_i, -- in  std_logic_vector(7 downto 0);
    lpc_data_o => lpc_data_o, -- out std_logic_vector(7 downto 0);  
    lpc_val    => lpc_val, -- out std_logic;
    lpc_ack    => lpc_ack -- in  std_logic
    );


--memory data bus logic
	mem_addr <= mode&"11"&lpc_addr(19 downto 0) when c25_lpc_val='1' and enable_4meg='0' else  --use mode bist
				mode&lpc_addr(21 downto 0) when c25_lpc_val='1' and enable_4meg='1' else  --use mode bist
				mode&umem_addr(21 downto 0) when umem_val='1' else  --use mode bist
				(others=>'Z');
				
	mem_di <=	(others=>'Z') when c25_lpc_val='1' else
				umem_do when umem_val='1' else
				(others=>'Z'); 	
				
			
	mem_wr <= c25_lpc_wr when c25_lpc_val='1' and c25_lpc_wr='0' else  --pass read olny
			  umem_wr when umem_val='1' else
			  '0';
			
	mem_val <= c25_lpc_val or umem_val;
	
	

	umem_ack <= mem_ack when umem_val='1' else
				'0';
	
	
	lpc_data_i <= mem_do(7 downto 0) when lpc_addr(0)='0' else
				  mem_do(15 downto 8);
				
	lpc_ack <= c33_mem_ack when lpc_val='1' and lpc_wr='0' else
			   (not dbg_almost_full) when lpc_val='1' and lpc_wr='1' else
			   '0';
			


	SYNC1: process (lclk, lreset_n)  --c33
	begin  
 		if lclk'event and lclk = '1' then    -- rising clock edge
			c33_mem_ack <= mem_ack;
			
  		end if;
	end process SYNC1;
	
	
	dbg_data <= lpc_debug(7 downto 0);
	SYNC2: process (sys_clk) --c25
	begin 
 		if sys_clk'event and sys_clk = '1' then    -- rising clock edge
			c25_lpc_val <= lpc_val;		--syncro two clock domains
			c25_lpc_wr <= c33_lpc_wr;	--syncro two clock domains
			c25_dbg_addr_d <= c33_dbg_addr_d; --syncro two clock domains
			if usb_mode_en ='0' and c25_dbg_addr_d=x"80" then  --don't fill fifo in regular mode
				dbg_wr<= c25_lpc_wr; --c33_lpc_wr_wait;--c33_lpc_wr_wait;
			else
				dbg_wr<='0';   --write never rises when usb_mode_en = 1
			end if;
		end if;
	end process SYNC2;	

				

	LATCHled: process (lclk,lreset_n)  --c33
	begin  
		if lreset_n='0' then
			lpc_debug(7 downto 0)<=(others=>'0');
			c33_dbg_addr_d <=(others=>'0');
			enable_4meg <='0';
			c33_lpc_wr <='0';
			dongle_con_n <='0';  -- pin 3 in GPIO make it toggleable
 		elsif lclk'event and lclk = '1' then    -- rising clock edge
			c33_lpc_wr <= lpc_wr;
			if c33_lpc_wr='0' and  lpc_wr='1' then
				c33_dbg_addr_d <= lpc_addr(7 downto 0);
				lpc_debug(7 downto 0)<= lpc_data_o;
				if lpc_addr(7 downto 0)=x"88" and lpc_data_o=x"F4" then   --Flash 4 Mega enable (LSN is first MSN is second)
					enable_4meg <='1';
				elsif lpc_addr(7 downto 0)=x"88" and lpc_data_o=x"F1" then --Flash 1 Mega enalbe
					enable_4meg <='0';
				elsif lpc_addr(7 downto 0)=x"88" and lpc_data_o=x"D1" then --Set Dongle not attached signal
					dongle_con_n <='1';  -- pin 3 in GPIO make it 1
				elsif lpc_addr(7 downto 0)=x"88" and lpc_data_o=x"D0" then --Set Dongle attached signal
					dongle_con_n <='0';  -- pin 3 in GPIO make it 1										
				end if;
			else
				if force_4meg_n='0' then -- active low (always force when jumper on)
					enable_4meg <='1';
				end if;
			end if;
  		end if;
	end process LATCHled;
	
	


	
				
--END memory data bus logic
fl_ce_n<= fl_ce_n_w;
fl_oe_n<= fl_oe_n_w;

FLASH : flash_if
  port map(
    clk       => sys_clk, -- in  std_logic;
    reset_n   => resetn, -- in  std_logic;
    --flash Bus
    fl_addr   => fl_addr, -- out std_logic_vector(23 downto 0);
    fl_ce_n      => fl_ce_n_w, -- out std_logic;       --chip select
    fl_oe_n      => fl_oe_n_w, -- buffer std_logic;    --output enable for flash
    fl_we_n      => fl_we_n, -- out std_logic;       --write enable
    fl_data      => fl_data, -- inout std_logic_vector(15 downto 0);
    fl_rp_n      => fl_rp_n, -- out std_logic;       --reset signal
    --fl_byte_n    => fl_byte_n, -- out std_logic;     --hold in byte mode
    fl_sts       => fl_sts, -- in std_logic;        --status signal
    -- mem Bus
    mem_addr  => mem_addr, -- in std_logic_vector(23 downto 0);
    mem_do    => mem_do, -- out std_logic_vector(15 downto 0);
    mem_di    => mem_di, -- in  std_logic_vector(15 downto 0);
     
    mem_wr    => mem_wr, -- in  std_logic;  --write not read signal
    mem_val   => mem_val, -- in  std_logic;
    mem_ack   => mem_ack  -- out std_logic
    ); 


 
USB: usb2mem
  port map(
    clk25     => sys_clk, -- in  std_logic;
    reset_n   => resetn, -- in  std_logic;
	dongle_ver => dongle_ver,
    -- mem Bus
    mem_busy_n=> fl_sts,  --check flash status before starting new command on flash
	mem_idle  => mem_idle,
    mem_addr  => umem_addr, -- out std_logic_vector(23 downto 0);
    mem_do    => umem_do, -- out std_logic_vector(15 downto 0);
    mem_di    => mem_do, -- in std_logic_vector(15 downto 0);   --from flash
    mem_wr    => umem_wr, -- out std_logic;
    mem_val   => umem_val, -- out std_logic;
    mem_ack   => umem_ack, -- in  std_logic;  --from flash
    mem_cmd   => umem_cmd, -- out std_logic;
    -- USB port
	usb_mode_en => usb_mode_en,
    usb_rd_n   => usb_rd_n, -- out  std_logic;  -- enables out data if low (next byte detected by edge / in usb chip)
    usb_wr     => usb_wr, -- out  std_logic;  -- write performed on edge \ of signal
    usb_txe_n  => usb_txe_n, -- in   std_logic;  -- tx fifo empty (redy for new data if low)
    usb_rxf_n  => usb_rxf_n, -- in   std_logic;  -- rx fifo empty (data redy if low)
    usb_bd     => usb_bd -- inout  std_logic_vector(7 downto 0) --bus data
    ); 


DBG : pc_serializer
    port map ( --system signals
           sys_clk => sys_clk, -- in  STD_LOGIC;
           resetn  => resetn, -- in  STD_LOGIC;		   
		   --postcode data port
           dbg_data => dbg_data, -- in  STD_LOGIC_VECTOR (7 downto 0);
           dbg_wr   => dbg_wr, -- in  STD_LOGIC;   --write not read
		   dbg_full => dbg_full,--: out STD_LOGIC;   --write not read
		   dbg_almost_full	 => dbg_almost_full,
		   dbg_usedw	 => dbg_usedw,

		   --debug USB port
		   dbg_usb_mode_en=> dbg_usb_mode_en, -- in   std_logic;  -- enable this debug mode
		   dbg_usb_wr     => usb_wr, -- out  std_logic;  -- write performed on edge \ of signal
		   dbg_usb_txe_n  => usb_txe_n, -- in   std_logic;  -- tx fifo not full (redy for new data if low)
		   dbg_usb_bd     => usb_bd -- inout  std_logic_vector(7 downto 0) --bus data
);


--END MAIN DATAPATH CONNECTIONS

end rtl;



