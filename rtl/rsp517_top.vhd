--------------------------------------------------------------------------
-- 
-- Title        :   RSP-517 Mitrion platform support
-- Platform     :   Platform is rsp517-vlx160 (ROSTA RSP-517 V4VLX160)
-- Design       :   Top design module
-- Project      :   rsp517_mitrion 
-- Author       :   Alexey Shmatok <alexey.shmatok@gmail.com>
-- Company      :   Rosta Ltd, www.rosta.ru
-- 
--------------------------------------------------------------------------
--
-- Description  :  This top module provides instantiation of interface cores for
--                 Mitrion virtual processor (MVP), Host (PCI-Bus) & External memory (DDR).
--
--------------------------------------------------------------------------
--
-- Declaimer    : This design is distributed on an "as is" basis, 
--		  without warranty of any kind, either express
--		  or implied. 
--
--------------------------------------------------------------------------
--
-- License      : This design is licensed under the GPL. 
--
--------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library UNISIM;
use UNISIM.VComponents.all;
use work.ctrl_types.all;
use work.rsp517_pack.all;
use work.rsp517_exp.all;

--mvp ports configuration
--port 0 : external memory (mvp rw)
--port 1 : bram memory 0 (mvp read only)
--port 2 : bram memory 1 (mvp write only)
--port 3 : stream port (input/output)
--port 4 : scalar port 0(input/output)
-- ...
--port 4+N : scalar port N(input/output) N=0..7

entity rsp517_top is
generic( 
-- mvp port presence, 0 - disabled, 1- enabled
c_mvp_port_presence : natural_array_type(0 to 4):= (1,1,1,1,1);
-- number of scalar ports
c_mvp_scalar_port_num : integer:=8;
-- DDR host port presence, 0 - disabled, 1- enabled
c_ddr_host_presence : integer:=1;
-- memory ports data & address widths
 dwa : natural:=32; -- mem a data width
 awa : natural:=27; -- mem a address width
 dwb : natural:=32; -- mem b data width
 awb : natural:=14; -- mem b address width
 dwc : natural:=32; -- mem c data width
 awc : natural:=14 -- mem c address width
);
Port (
SYSCLK : in std_logic;-- Local clock 50MHz by default
SYSRST : in std_logic;-- Local Reset
LCLK : in std_logic;-- Local clock 50MHz by default
LRST : in std_logic;-- Local Reset
LAD : inout std_logic_vector  (63 downto 0);-- Local Address/Data
LCBE : inout std_logic_vector   (7 downto 0);-- Local Command/Byte Enable
LRNW : in std_logic;-- Local Read/Not Write
LADD : in std_logic;-- Local Address Strobe
LDAT : in std_logic;-- Local Data strobe
LWAIT : out std_logic;-- Local Wait cycle
-- add Vlad 01.10.08
LREADY	: inout std_logic; -- Local Ready or Data Ready
FPGAS		: in std_logic; -- FPGA Select -- '1'
--
LEDS : out std_logic_vector(0 to 2);  -- LEDs
--
DDR_DQ : INOUT std_logic_vector(31 downto 0);      
DDR_Addr_pin : OUT std_logic_vector(12 downto 0);
DDR_BankAddr_pin : OUT std_logic_vector(1 downto 0);
DDR_CAS_n_pin : OUT std_logic;
DDR_CE_pin : OUT std_logic;
DDR_CS_n_pin : OUT std_logic;
DDR_RAS_n_pin : OUT std_logic;
DDR_WE_n_pin : OUT std_logic;
DDR_DM_pin : OUT std_logic_vector(3 downto 0);
DDR_DQS_pin : OUT std_logic_vector(3 downto 0);
DDR_Clk_pin : OUT std_logic_vector(1 downto 0);
DDR_Clk_n_pin : OUT std_logic_vector(1 downto 0)
);
end rsp517_top;

architecture rsp517_rtl of rsp517_top is

component blk_mem_gen_v2_6
	port (
	clka: IN std_logic;
	dina: IN std_logic_VECTOR(31 downto 0);
	addra: IN std_logic_VECTOR(13 downto 0);
	wea: IN std_logic_VECTOR(0 downto 0);
	douta: OUT std_logic_VECTOR(31 downto 0);
	clkb: IN std_logic;
	dinb: IN std_logic_VECTOR(31 downto 0);
	addrb: IN std_logic_VECTOR(13 downto 0);
	web: IN std_logic_VECTOR(0 downto 0);
	doutb: OUT std_logic_VECTOR(31 downto 0));
end component;

component rsp517_Mitrion_wrapper is
generic( 
-- mvp port presence, 0 - disabled, 1- enabled
c_mvp_port_presence : natural_array_type(0 to 4):= (1,1,1,1,1);
-- number of scalar ports
c_mvp_scalar_port_num : integer:=1;
-- memory ports data & address widths
 dwa : natural:=32; -- mem a data width
 awa : natural:=14; -- mem a address width
 dwb : natural:=32; -- mem b data width
 awb : natural:=14; -- mem b address width
 dwc : natural:=32; -- mem c data width
 awc : natural:=14 -- mem c address width
);
port (rst, clk: in std_logic;
  Din0:  in std_logic_vector(0 downto 0);
  Vin0:  in std_logic;
  Cin0:  out std_logic;
  Din1:  in std_logic_vector(0 downto 0);
  Vin1:  in std_logic;
  Cin1:  out std_logic;
  Din2:  in std_logic_vector(0 downto 0);
  Vin2:  in std_logic;
  Cin2:  out std_logic;
  Din3:  in std_logic_vector(33 downto 0);
  Vin3:  in std_logic;
  Cin3:  out std_logic;
  Din4:  in std_logic_vector(31 downto 0);
  Vin4:  in std_logic;
  Cin4:  out std_logic;
  Din5:  in std_logic_vector(31 downto 0);
  Vin5:  in std_logic;
  Cin5:  out std_logic;
  Din6:  in std_logic_vector(31 downto 0);
  Vin6:  in std_logic;
  Cin6:  out std_logic;
  Din7:  in std_logic_vector(31 downto 0);
  Vin7:  in std_logic;
  Cin7:  out std_logic;
  Din8:  in std_logic_vector(31 downto 0);
  Vin8:  in std_logic;
  Cin8:  out std_logic;
  Din9:  in std_logic_vector(31 downto 0);
  Vin9:  in std_logic;
  Cin9:  out std_logic;
  Din10:  in std_logic_vector(31 downto 0);
  Vin10:  in std_logic;
  Cin10:  out std_logic;
  Din11:  in std_logic_vector(31 downto 0);
  Vin11:  in std_logic;
  Cin11:  out std_logic;
  Dout0:  out std_logic_vector(0 downto 0);
  Vout0:  out std_logic;
  Cout0:  in std_logic;
  Dout1:  out std_logic_vector(0 downto 0);
  Vout1:  out std_logic;
  Cout1:  in std_logic;
  Dout2:  out std_logic_vector(0 downto 0);
  Vout2:  out std_logic;
  Cout2:  in std_logic;
  Dout3:  out std_logic_vector(33 downto 0);
  Vout3:  out std_logic;
  Cout3:  in std_logic;
  Dout4:  out std_logic_vector(31 downto 0);
  Vout4:  out std_logic;
  Cout4:  in std_logic;
  Dout5:  out std_logic_vector(31 downto 0);
  Vout5:  out std_logic;
  Cout5:  in std_logic;
  Dout6:  out std_logic_vector(31 downto 0);
  Vout6:  out std_logic;
  Cout6:  in std_logic;
  Dout7:  out std_logic_vector(31 downto 0);
  Vout7:  out std_logic;
  Cout7:  in std_logic;
  Dout8:  out std_logic_vector(31 downto 0);
  Vout8:  out std_logic;
  Cout8:  in std_logic;
  Dout9:  out std_logic_vector(31 downto 0);
  Vout9:  out std_logic;
  Cout9:  in std_logic;
  Dout10:  out std_logic_vector(31 downto 0);
  Vout10:  out std_logic;
  Cout10:  in std_logic;
  Dout11:  out std_logic_vector(31 downto 0);
  Vout11:  out std_logic;
  Cout11:  in std_logic;
  
  
  -- extram interface
         REA     : out std_logic;
         RAckA   : in std_logic;
         RAddrA  : out std_logic_vector(awa-1 downto 0);
         RDataA  : in  std_logic_vector(dwa-1 downto 0);
         RStallA : in  std_logic;
         WEA     : out std_logic;
         WAddrA  : out std_logic_vector(awa-1 downto 0);
         WDataA  : out std_logic_vector(dwa-1 downto 0);
         WStallA : in  std_logic
;
         REB     : out std_logic;
         RAckB   : in std_logic;
         RAddrB  : out std_logic_vector(awb-1 downto 0);
         RDataB  : in  std_logic_vector(dwb-1 downto 0);
         RStallB : in  std_logic;
         WEB     : out std_logic;
         WAddrB  : out std_logic_vector(awb-1 downto 0);
         WDataB  : out std_logic_vector(dwb-1 downto 0);
         WStallB : in  std_logic
;
         REC     : out std_logic;
         RAckC   : in std_logic;
         RAddrC  : out std_logic_vector(awc-1 downto 0);
         RDataC  : in  std_logic_vector(dwc-1 downto 0);
         RStallC : in  std_logic;
         WEC     : out std_logic;
         WAddrC  : out std_logic_vector(awc-1 downto 0);
         WDataC  : out std_logic_vector(dwc-1 downto 0);
         WStallC : in  std_logic

  -- watchpoints 

);
end component; 

-- MPMC XPS core

COMPONENT system
	PORT(
		sys_clk_pin : IN std_logic;
		sys_rst_pin : IN std_logic;    
		DDR_DQ : INOUT std_logic_vector(31 downto 0);      
--		fpga_0_LEDS_GPIO_d_out_pin : OUT std_logic_vector(0 to 2);
		DDR_Addr_pin : OUT std_logic_vector(12 downto 0);
		DDR_BankAddr_pin : OUT std_logic_vector(1 downto 0);
		DDR_CAS_n_pin : OUT std_logic;
		DDR_CE_pin : OUT std_logic;
		DDR_CS_n_pin : OUT std_logic;
		DDR_RAS_n_pin : OUT std_logic;
		DDR_WE_n_pin : OUT std_logic;
		DDR_DM_pin : OUT std_logic_vector(3 downto 0);
		DDR_DQS_pin : OUT std_logic_vector(3 downto 0);
		DDR_Clk_pin : OUT std_logic_vector(1 downto 0);
		DDR_Clk_n_pin : OUT std_logic_vector(1 downto 0);
		sys_clk_s_pin : OUT std_logic;
		
		MPMC3_DDR_PIM1_InitDone_pin : OUT std_logic;
		MPMC3_DDR_PIM1_RdFIFO_Flush_pin : IN std_logic;
		MPMC3_DDR_PIM1_WrFIFO_Flush_pin : IN std_logic;
		MPMC3_DDR_PIM1_RdFIFO_Pop_pin : IN std_logic;
		MPMC3_DDR_PIM1_WrFIFO_Push_pin : IN std_logic;
		MPMC3_DDR_PIM1_WrFIFO_BE_pin : IN std_logic_vector(3 downto 0);
		MPMC3_DDR_PIM1_WrFIFO_Data_pin : IN std_logic_vector(31 downto 0);
		MPMC3_DDR_PIM1_RdModWr_pin : IN std_logic;
		MPMC3_DDR_PIM1_Size_pin : IN std_logic_vector(3 downto 0);
		MPMC3_DDR_PIM1_RNW_pin : IN std_logic;
		MPMC3_DDR_PIM1_AddrReq_pin : IN std_logic;
		MPMC3_DDR_PIM1_Addr_pin : IN std_logic_vector(31 downto 0);    
		MPMC3_DDR_PIM1_RdFIFO_Latency_pin : OUT std_logic_vector(1 downto 0);
		MPMC3_DDR_PIM1_RdFIFO_Empty_pin : OUT std_logic;
		MPMC3_DDR_PIM1_WrFIFO_AlmostFull_pin : OUT std_logic;
		MPMC3_DDR_PIM1_WrFIFO_Empty_pin : OUT std_logic;
		MPMC3_DDR_PIM1_RdFIFO_RdWdAddr_pin : OUT std_logic_vector(3 downto 0);
		MPMC3_DDR_PIM1_RdFIFO_Data_pin : OUT std_logic_vector(31 downto 0);
		MPMC3_DDR_PIM1_AddrAck_pin : OUT std_logic;
		
		MPMC3_DDR_PIM2_InitDone_pin : OUT std_logic;
		MPMC3_DDR_PIM2_RdFIFO_Flush_pin : IN std_logic;
		MPMC3_DDR_PIM2_WrFIFO_Flush_pin : IN std_logic;
		MPMC3_DDR_PIM2_RdFIFO_Pop_pin : IN std_logic;
		MPMC3_DDR_PIM2_WrFIFO_Push_pin : IN std_logic;
		MPMC3_DDR_PIM2_WrFIFO_BE_pin : IN std_logic_vector(3 downto 0);
		MPMC3_DDR_PIM2_WrFIFO_Data_pin : IN std_logic_vector(31 downto 0);
		MPMC3_DDR_PIM2_RdModWr_pin : IN std_logic;
		MPMC3_DDR_PIM2_Size_pin : IN std_logic_vector(3 downto 0);
		MPMC3_DDR_PIM2_RNW_pin : IN std_logic;
		MPMC3_DDR_PIM2_AddrReq_pin : IN std_logic;
		MPMC3_DDR_PIM2_Addr_pin : IN std_logic_vector(31 downto 0);    
		MPMC3_DDR_PIM2_RdFIFO_Latency_pin : OUT std_logic_vector(1 downto 0);
		MPMC3_DDR_PIM2_RdFIFO_Empty_pin : OUT std_logic;
		MPMC3_DDR_PIM2_WrFIFO_AlmostFull_pin : OUT std_logic;
		MPMC3_DDR_PIM2_WrFIFO_Empty_pin : OUT std_logic;
		MPMC3_DDR_PIM2_RdFIFO_RdWdAddr_pin : OUT std_logic_vector(3 downto 0);
		MPMC3_DDR_PIM2_RdFIFO_Data_pin : OUT std_logic_vector(31 downto 0);
		MPMC3_DDR_PIM2_AddrAck_pin : OUT std_logic;

		MPMC3_DDR_PIM3_InitDone_pin : OUT std_logic;
		MPMC3_DDR_PIM3_RdFIFO_Flush_pin : IN std_logic;
		MPMC3_DDR_PIM3_WrFIFO_Flush_pin : IN std_logic;
		MPMC3_DDR_PIM3_RdFIFO_Pop_pin : IN std_logic;
		MPMC3_DDR_PIM3_WrFIFO_Push_pin : IN std_logic;
		MPMC3_DDR_PIM3_WrFIFO_BE_pin : IN std_logic_vector(3 downto 0);
		MPMC3_DDR_PIM3_WrFIFO_Data_pin : IN std_logic_vector(31 downto 0);
		MPMC3_DDR_PIM3_RdModWr_pin : IN std_logic;
		MPMC3_DDR_PIM3_Size_pin : IN std_logic_vector(3 downto 0);
		MPMC3_DDR_PIM3_RNW_pin : IN std_logic;
		MPMC3_DDR_PIM3_AddrReq_pin : IN std_logic;
		MPMC3_DDR_PIM3_Addr_pin : IN std_logic_vector(31 downto 0);    
		MPMC3_DDR_PIM3_RdFIFO_Latency_pin : OUT std_logic_vector(1 downto 0);
		MPMC3_DDR_PIM3_RdFIFO_Empty_pin : OUT std_logic;
		MPMC3_DDR_PIM3_WrFIFO_AlmostFull_pin : OUT std_logic;
		MPMC3_DDR_PIM3_WrFIFO_Empty_pin : OUT std_logic;
		MPMC3_DDR_PIM3_RdFIFO_RdWdAddr_pin : OUT std_logic_vector(3 downto 0);
		MPMC3_DDR_PIM3_RdFIFO_Data_pin : OUT std_logic_vector(31 downto 0);
		MPMC3_DDR_PIM3_AddrAck_pin : OUT std_logic;

		MPMC3_DDR_PIM4_InitDone_pin : OUT std_logic;
		MPMC3_DDR_PIM4_RdFIFO_Flush_pin : IN std_logic;
		MPMC3_DDR_PIM4_WrFIFO_Flush_pin : IN std_logic;
		MPMC3_DDR_PIM4_RdFIFO_Pop_pin : IN std_logic;
		MPMC3_DDR_PIM4_WrFIFO_Push_pin : IN std_logic;
		MPMC3_DDR_PIM4_WrFIFO_BE_pin : IN std_logic_vector(3 downto 0);
		MPMC3_DDR_PIM4_WrFIFO_Data_pin : IN std_logic_vector(31 downto 0);
		MPMC3_DDR_PIM4_RdModWr_pin : IN std_logic;
		MPMC3_DDR_PIM4_Size_pin : IN std_logic_vector(3 downto 0);
		MPMC3_DDR_PIM4_RNW_pin : IN std_logic;
		MPMC3_DDR_PIM4_AddrReq_pin : IN std_logic;
		MPMC3_DDR_PIM4_Addr_pin : IN std_logic_vector(31 downto 0);    
		MPMC3_DDR_PIM4_RdFIFO_Latency_pin : OUT std_logic_vector(1 downto 0);
		MPMC3_DDR_PIM4_RdFIFO_Empty_pin : OUT std_logic;
		MPMC3_DDR_PIM4_WrFIFO_AlmostFull_pin : OUT std_logic;
		MPMC3_DDR_PIM4_WrFIFO_Empty_pin : OUT std_logic;
		MPMC3_DDR_PIM4_RdFIFO_RdWdAddr_pin : OUT std_logic_vector(3 downto 0);
		MPMC3_DDR_PIM4_RdFIFO_Data_pin : OUT std_logic_vector(31 downto 0);
		MPMC3_DDR_PIM4_AddrAck_pin : OUT std_logic
		
		);
	END COMPONENT;

signal CLKx,CLKxx : std_logic;
signal CLK,CLK2X, RNW, RST : std_logic;
signal SCMD: std_logic_vector (7 downto 0);
signal SADDR: std_logic_vector (63 downto 0);
signal INDATA : std_logic_vector (63 downto 0);
signal CBE_REG :  std_logic_vector (7 downto 0);

signal clk_counter : std_logic_vector(31 downto 0)   := X"00000000";
signal clk2x_counter : std_logic_vector(31 downto 0) := X"00000000";

signal mvp_rst:std_logic;                   
signal boot0_reg : std_logic_vector(31 downto 0);
signal boot1_reg : std_logic_vector(31 downto 0);  


--signal bram0_dina: std_logic_VECTOR(31 downto 0) := (others => '0');
--signal bram0_addra: std_logic_VECTOR(awa-1 downto 0) := (others => '0');
--signal bram0_wea: std_logic_VECTOR(0 downto 0) := (others => '0');
--signal bram0_ena: std_logic := '0';
--signal bram0_douta: std_logic_VECTOR(31 downto 0) := (others => '0');
--signal bram0_dinb: std_logic_VECTOR(31 downto 0) := (others => '0');
--signal bram0_addrb: std_logic_VECTOR(awa-1 downto 0) := (others => '0');
--signal bram0_web: std_logic_VECTOR(0 downto 0) := (others => '0');
--signal bram0_enb: std_logic :='0';
--signal bram0_doutb:  std_logic_VECTOR(31 downto 0) := (others => '0');

signal bram1_dina: std_logic_VECTOR(31 downto 0) := (others => '0');
signal bram1_addra: std_logic_VECTOR(awb-1 downto 0) := (others => '0');
signal bram1_wea: std_logic_VECTOR(0 downto 0) := (others => '0');
signal bram1_ena: std_logic := '0';
signal bram1_douta: std_logic_VECTOR(31 downto 0) := (others => '0');
signal bram1_dinb: std_logic_VECTOR(31 downto 0) := (others => '0');
signal bram1_addrb: std_logic_VECTOR(awb-1 downto 0) := (others => '0');
signal bram1_raddrb: std_logic_VECTOR(awb-1 downto 0) := (others => '0');
signal bram1_waddrb: std_logic_VECTOR(awb-1 downto 0) := (others => '0');
signal bram1_web: std_logic_VECTOR(0 downto 0) := (others => '0');
signal bram1_enb: std_logic :='0';
signal bram1_doutb:  std_logic_VECTOR(31 downto 0) := (others => '0');

signal bram2_dina: std_logic_VECTOR(31 downto 0) := (others => '0');
signal bram2_addra: std_logic_VECTOR(awc-1 downto 0) := (others => '0');
signal bram2_wea: std_logic_VECTOR(0 downto 0) := (others => '0');
signal bram2_ena: std_logic := '0';
signal bram2_douta: std_logic_VECTOR(31 downto 0) := (others => '0');
signal bram2_dinb: std_logic_VECTOR(31 downto 0) := (others => '0');
signal bram2_addrb: std_logic_VECTOR(awc-1 downto 0) := (others => '0');
signal bram2_raddrb: std_logic_VECTOR(awc-1 downto 0) := (others => '0');
signal bram2_waddrb: std_logic_VECTOR(awc-1 downto 0) := (others => '0');
signal bram2_web: std_logic_VECTOR(0 downto 0) := (others => '0');
signal bram2_enb: std_logic :='0';
signal bram2_doutb:  std_logic_VECTOR(31 downto 0) := (others => '0');

signal  Din0:  std_logic_vector(0 downto 0);
signal  Vin0:  std_logic;
signal  Cin0:  std_logic;
signal  Din1:  std_logic_vector(0 downto 0);
signal  Vin1:  std_logic;
signal  Cin1:  std_logic;
signal  Din2:  std_logic_vector(0 downto 0);
signal  Vin2:  std_logic;
signal  Cin2:  std_logic;
signal  Din3:  std_logic_vector(33 downto 0);
signal  Vin3:  std_logic;
signal  Cin3:  std_logic;
signal  Din4:  std_logic_vector(31 downto 0); -- 0
signal  Vin4:  std_logic;
signal  Cin4:  std_logic;
signal  Din5:  std_logic_vector(31 downto 0); -- 1
signal  Vin5:  std_logic;
signal  Cin5:  std_logic;
signal  Din6:  std_logic_vector(31 downto 0); -- 2
signal  Vin6:  std_logic;
signal  Cin6:  std_logic;
signal  Din7:  std_logic_vector(31 downto 0); -- 3
signal  Vin7:  std_logic;
signal  Cin7:  std_logic;
signal  Din8:  std_logic_vector(31 downto 0); -- 4
signal  Vin8:  std_logic;
signal  Cin8:  std_logic;
signal  Din9:  std_logic_vector(31 downto 0); -- 5
signal  Vin9:  std_logic;
signal  Cin9:  std_logic;
signal  Din10:  std_logic_vector(31 downto 0); -- 6
signal  Vin10:  std_logic;
signal  Cin10:  std_logic;
signal  Din11:  std_logic_vector(31 downto 0); -- 7
signal  Vin11:  std_logic;
signal  Cin11:  std_logic;
signal  Dout0: std_logic_vector(0 downto 0);
signal  Vout0: std_logic;
signal  Cout0: std_logic;
signal  Dout1: std_logic_vector(0 downto 0);
signal  Vout1: std_logic;
signal  Cout1: std_logic;
signal  Dout2:  std_logic_vector(0 downto 0);
signal  Vout2:  std_logic;
signal  Cout2:  std_logic;
signal  Dout3:  std_logic_vector(33 downto 0);
signal  Vout3:  std_logic;
signal  Cout3:  std_logic;
signal  Dout4:  std_logic_vector(31 downto 0); -- 0
signal  Vout4:  std_logic;
signal  Cout4:  std_logic;
signal  Dout5:  std_logic_vector(31 downto 0); -- 1
signal  Vout5:  std_logic;
signal  Cout5:  std_logic;
signal  Dout6:  std_logic_vector(31 downto 0); -- 2
signal  Vout6:  std_logic;
signal  Cout6:  std_logic;
signal  Dout7:  std_logic_vector(31 downto 0); -- 3
signal  Vout7:  std_logic;
signal  Cout7:  std_logic;
signal  Dout8:  std_logic_vector(31 downto 0); -- 4
signal  Vout8:  std_logic;
signal  Cout8:  std_logic;
signal  Dout9:  std_logic_vector(31 downto 0); -- 5
signal  Vout9:  std_logic;
signal  Cout9:  std_logic;
signal  Dout10:  std_logic_vector(31 downto 0); -- 6
signal  Vout10:  std_logic;
signal  Cout10:  std_logic;
signal  Dout11:  std_logic_vector(31 downto 0); -- 7
signal  Vout11:  std_logic;
signal  Cout11:  std_logic;
signal         REA     :  std_logic;
signal         RAckA   :  std_logic;
signal         RAddrA  :  std_logic_vector(awa-1 downto 0);
signal         RDataA  :   std_logic_vector(dwa-1 downto 0);
signal         RStallA :   std_logic;
signal         WEA     :  std_logic;
signal         WAddrA  :  std_logic_vector(awa-1 downto 0);
signal         WDataA  :  std_logic_vector(dwa-1 downto 0);
signal         WStallA :  std_logic;
signal         REB     :  std_logic;
signal         RAckB   : std_logic;
signal         RAddrB  :  std_logic_vector(awb-1 downto 0);
signal         RDataB  :   std_logic_vector(dwb-1 downto 0);
signal         RStallB :   std_logic;
signal         WEB     :  std_logic;
signal         WAddrB  :  std_logic_vector(awb-1 downto 0);
signal         WDataB  :  std_logic_vector(dwb-1 downto 0);
signal         WStallB :  std_logic;
signal         REC     :  std_logic;
signal         RAckC   :  std_logic;
signal         RAddrC  :  std_logic_vector(awc-1 downto 0);
signal         RDataC  :  std_logic_vector(dwc-1 downto 0);
signal         RStallC :  std_logic;
signal         WEC     :  std_logic;
signal         WAddrC  :  std_logic_vector(awc-1 downto 0);
signal         WDataC  :  std_logic_vector(dwc-1 downto 0);
signal         WStallC :  std_logic;

-- ctrl
  signal mvp_ctrl_cmd:  std_logic;
  signal mvp_ctrl_status : std_logic;
-- port 0
  signal mvp_port0_cmd:  std_logic;--_vector(31 downto 0);
  signal mvp_port0_data: std_logic_vector(31 downto 0);
  signal mvp_port0_status : std_logic;--_vector(31 downto 0);
  signal mvp_port0_initial_handshaking      :  std_logic;
  signal mvp_port0_farewell_handshaking      :  std_logic;
-- port 1
  signal mvp_port1_cmd:  std_logic;--_vector(31 downto 0);
  signal mvp_port1_data: std_logic_vector(31 downto 0);
  signal mvp_port1_status : std_logic;--_vector(31 downto 0);
  signal mvp_port1_initial_handshaking      :  std_logic;
  signal mvp_port1_farewell_handshaking      :  std_logic;
-- port 2
  signal mvp_port2_cmd:  std_logic;--_vector(31 downto 0);
  signal mvp_port2_data: std_logic_vector(31 downto 0);
  signal mvp_port2_status : std_logic;--_vector(31 downto 0);
  signal mvp_port2_initial_handshaking      :  std_logic;
  signal mvp_port2_farewell_handshaking      :  std_logic;
-- port 3
  signal mvp_out_port3_cmd:  std_logic;--_vector(31 downto 0);
  signal mvp_out_port3_data: std_logic_vector(31 downto 0);
  signal mvp_out_port3_status : std_logic;--_vector(31 downto 0);
  signal mvp_out_port3_tail : std_logic;
  signal mvp_out_port3_enable : std_logic;
  signal mvp_in_port3_cmd:  std_logic;--_vector(31 downto 0);
  signal mvp_in_port3_data: std_logic_vector(31 downto 0);
  signal mvp_in_port3_status : std_logic;--_vector(31 downto 0);
  signal mvp_in_port3_bk : std_logic;
  signal mvp_in_port3_wt : std_logic;
  signal mvp_in_port3_tail : std_logic;
  signal mvp_in_port3_enable : std_logic;
-- port 4
 signal mvp_scalar_out_port_array : mvp_scalar_out_port_array_type(0 to 7);
 signal mvp_scalar_in_port_array : mvp_scalar_in_port_array_type(0 to 7);
  

 signal wr_counter : std_logic_vector(15 downto 0) := X"0000";
 signal rd_counter : std_logic_vector(15 downto 0) := X"0000";


signal	MPMC3_DDR_PIM1_RdFIFO_Flush_pin :  std_logic;
signal	MPMC3_DDR_PIM1_WrFIFO_Flush_pin :  std_logic;
signal	MPMC3_DDR_PIM1_RdFIFO_Pop_pin :  std_logic;
signal	MPMC3_DDR_PIM1_WrFIFO_Push_pin :  std_logic;
signal	MPMC3_DDR_PIM1_WrFIFO_BE_pin :  std_logic_vector(3 downto 0);
signal	MPMC3_DDR_PIM1_WrFIFO_Data_pin :  std_logic_vector(31 downto 0);
signal	MPMC3_DDR_PIM1_RdModWr_pin :  std_logic;
signal	MPMC3_DDR_PIM1_Size_pin :  std_logic_vector(3 downto 0);
signal	MPMC3_DDR_PIM1_RNW_pin :  std_logic;
signal	MPMC3_DDR_PIM1_AddrReq_pin :  std_logic;
signal	MPMC3_DDR_PIM1_Addr_pin :  std_logic_vector(31 downto 0);    
signal	MPMC3_DDR_PIM1_InitDone_pin :  std_logic;
signal	MPMC3_DDR_PIM1_RdFIFO_Latency_pin :  std_logic_vector(1 downto 0);
signal	MPMC3_DDR_PIM1_RdFIFO_Empty_pin :  std_logic;
signal	MPMC3_DDR_PIM1_WrFIFO_AlmostFull_pin :  std_logic;
signal	MPMC3_DDR_PIM1_WrFIFO_Empty_pin :  std_logic;
signal	MPMC3_DDR_PIM1_RdFIFO_RdWdAddr_pin :  std_logic_vector(3 downto 0);
signal	MPMC3_DDR_PIM1_RdFIFO_Data_pin : std_logic_vector(31 downto 0);
signal	MPMC3_DDR_PIM1_AddrAck_pin : std_logic;

signal	MPMC3_DDR_PIM2_RdFIFO_Flush_pin :  std_logic;
signal	MPMC3_DDR_PIM2_WrFIFO_Flush_pin :  std_logic;
signal	MPMC3_DDR_PIM2_RdFIFO_Pop_pin :  std_logic;
signal	MPMC3_DDR_PIM2_WrFIFO_Push_pin :  std_logic;
signal	MPMC3_DDR_PIM2_WrFIFO_BE_pin :  std_logic_vector(3 downto 0);
signal	MPMC3_DDR_PIM2_WrFIFO_Data_pin :  std_logic_vector(31 downto 0);
signal	MPMC3_DDR_PIM2_RdModWr_pin :  std_logic;
signal	MPMC3_DDR_PIM2_Size_pin :  std_logic_vector(3 downto 0);
signal	MPMC3_DDR_PIM2_RNW_pin :  std_logic;
signal	MPMC3_DDR_PIM2_AddrReq_pin :  std_logic;
signal	MPMC3_DDR_PIM2_Addr_pin :  std_logic_vector(31 downto 0);    
signal	MPMC3_DDR_PIM2_InitDone_pin :  std_logic;
signal	MPMC3_DDR_PIM2_RdFIFO_Latency_pin :  std_logic_vector(1 downto 0);
signal	MPMC3_DDR_PIM2_RdFIFO_Empty_pin :  std_logic;
signal	MPMC3_DDR_PIM2_WrFIFO_AlmostFull_pin :  std_logic;
signal	MPMC3_DDR_PIM2_WrFIFO_Empty_pin :  std_logic;
signal	MPMC3_DDR_PIM2_RdFIFO_RdWdAddr_pin :  std_logic_vector(3 downto 0);
signal	MPMC3_DDR_PIM2_RdFIFO_Data_pin : std_logic_vector(31 downto 0);
signal	MPMC3_DDR_PIM2_AddrAck_pin : std_logic;

signal	MPMC3_DDR_PIM3_RdFIFO_Flush_pin :  std_logic;
signal	MPMC3_DDR_PIM3_WrFIFO_Flush_pin :  std_logic;
signal	MPMC3_DDR_PIM3_RdFIFO_Pop_pin :  std_logic;
signal	MPMC3_DDR_PIM3_WrFIFO_Push_pin :  std_logic;
signal	MPMC3_DDR_PIM3_WrFIFO_BE_pin :  std_logic_vector(3 downto 0);
signal	MPMC3_DDR_PIM3_WrFIFO_Data_pin :  std_logic_vector(31 downto 0);
signal	MPMC3_DDR_PIM3_RdModWr_pin :  std_logic;
signal	MPMC3_DDR_PIM3_Size_pin :  std_logic_vector(3 downto 0);
signal	MPMC3_DDR_PIM3_RNW_pin :  std_logic;
signal	MPMC3_DDR_PIM3_AddrReq_pin :  std_logic;
signal	MPMC3_DDR_PIM3_Addr_pin :  std_logic_vector(31 downto 0);    
signal	MPMC3_DDR_PIM3_InitDone_pin :  std_logic;
signal	MPMC3_DDR_PIM3_RdFIFO_Latency_pin :  std_logic_vector(1 downto 0);
signal	MPMC3_DDR_PIM3_RdFIFO_Empty_pin :  std_logic;
signal	MPMC3_DDR_PIM3_WrFIFO_AlmostFull_pin :  std_logic;
signal	MPMC3_DDR_PIM3_WrFIFO_Empty_pin :  std_logic;
signal	MPMC3_DDR_PIM3_RdFIFO_RdWdAddr_pin :  std_logic_vector(3 downto 0);
signal	MPMC3_DDR_PIM3_RdFIFO_Data_pin : std_logic_vector(31 downto 0);
signal	MPMC3_DDR_PIM3_AddrAck_pin : std_logic;

signal	MPMC3_DDR_PIM4_RdFIFO_Flush_pin :  std_logic;
signal	MPMC3_DDR_PIM4_WrFIFO_Flush_pin :  std_logic;
signal	MPMC3_DDR_PIM4_RdFIFO_Pop_pin :  std_logic;
signal	MPMC3_DDR_PIM4_WrFIFO_Push_pin :  std_logic;
signal	MPMC3_DDR_PIM4_WrFIFO_BE_pin :  std_logic_vector(3 downto 0);
signal	MPMC3_DDR_PIM4_WrFIFO_Data_pin :  std_logic_vector(31 downto 0);
signal	MPMC3_DDR_PIM4_RdModWr_pin :  std_logic;
signal	MPMC3_DDR_PIM4_Size_pin :  std_logic_vector(3 downto 0);
signal	MPMC3_DDR_PIM4_RNW_pin :  std_logic;
signal	MPMC3_DDR_PIM4_AddrReq_pin :  std_logic;
signal	MPMC3_DDR_PIM4_Addr_pin :  std_logic_vector(31 downto 0);    
signal	MPMC3_DDR_PIM4_InitDone_pin :  std_logic;
signal	MPMC3_DDR_PIM4_RdFIFO_Latency_pin :  std_logic_vector(1 downto 0);
signal	MPMC3_DDR_PIM4_RdFIFO_Empty_pin :  std_logic;
signal	MPMC3_DDR_PIM4_WrFIFO_AlmostFull_pin :  std_logic;
signal	MPMC3_DDR_PIM4_WrFIFO_Empty_pin :  std_logic;
signal	MPMC3_DDR_PIM4_RdFIFO_RdWdAddr_pin :  std_logic_vector(3 downto 0);
signal	MPMC3_DDR_PIM4_RdFIFO_Data_pin : std_logic_vector(31 downto 0);
signal	MPMC3_DDR_PIM4_AddrAck_pin : std_logic;

signal npi_RE     :  std_logic;
signal npi_RAck     :  std_logic;
signal npi_Addr  :  std_logic_vector(31 downto 0);
signal npi_RData  :   std_logic_vector(31 downto 0);
signal npi_WE     :  std_logic;
signal npi_WData  :  std_logic_vector(31 downto 0);
signal npi_cmd:  std_logic;
signal npi_data:  std_logic_vector(31 downto 0);
signal npi_status:  std_logic_vector(31 downto 0);


signal npi_RE2     :  std_logic;
signal npi_RAck2     :  std_logic;
signal npi_Addr2  :  std_logic_vector(31 downto 0);
signal npi_RData2  :   std_logic_vector(31 downto 0);
signal npi_WE2     :  std_logic;
signal npi_WData2  :  std_logic_vector(31 downto 0);
signal npi_cmd2:  std_logic;
signal npi_data2:  std_logic_vector(31 downto 0);
signal npi_status2:  std_logic_vector(31 downto 0);

signal npi_counter12:  std_logic_vector(31 downto 0);
signal npi_counter22:  std_logic_vector(31 downto 0);

signal npi_counter11:  std_logic_vector(31 downto 0);
signal npi_counter21:  std_logic_vector(31 downto 0);

signal npi_status3:  std_logic_vector(31 downto 0);
signal npi_counter13:  std_logic_vector(31 downto 0);
signal npi_counter23:  std_logic_vector(31 downto 0);

signal ra_fifo_wr_cmd   : std_logic;
signal ra_fifo_wr_data : std_logic_vector (31 downto 0);
signal rd_fifo_rd_cmd   : std_logic;
signal rd_fifo_rd_data :  std_logic_vector (31 downto 0);

signal		sys_clk_s_pin :  std_logic;
signal		clk_200MHz_pin : std_logic;		

signal sys_clk_counter : std_logic_vector(31 downto 0)   := X"00000000";
signal clk_200MHz_counter : std_logic_vector(31 downto 0) := X"00000000";


signal LEDSREG: std_logic_vector(2 downto 0);

-- LocBUS Signals
signal L_READY, L_READY_D, L_READY_D2, LREADY_I, LREADY_O : std_logic;
signal LREADY_T : std_logic; -- '1' - 'z'

attribute PERIOD : string;
attribute PERIOD of CLK: signal is "33 Mhz";
attribute PERIOD of CLK2X: signal is "100 Mhz";
attribute PERIOD of sys_clk_s_pin: signal is "100 Mhz";

signal DUMMYRAMDO  : std_logic_vector(dwc-1 downto 0);
signal DUMMYRAMAO  : std_logic_vector(awc-1 downto 0); 
 
signal DummyWAddrA  : std_logic_vector(31 downto 0);
signal DummyRAddrA  : std_logic_vector(31 downto 0);

signal OpenRAMAI  : std_logic_vector(awb-1 downto 0);
signal OpenRAMDI  : std_logic_vector(dwb-1 downto 0);
signal OpenRAMWE  : std_logic;

begin

-------------------------------------------------------------------------------------------------------------------------
-- system signals
-------------------------------------------------------------------------------------------------------------------------

Inst_RST_IBUF : IBUF port map (I => LRST, O => RST);
Inst_RNW_IBUF : IBUF port map (I => LRNW, O => RNW);
Inst_LocalClock : IBUFG port map (I => LCLK, O => CLK);
CLK2X <= sys_clk_s_pin; -- 100 MHz system clock

-------------------------------------------------------------------------------------------------------------------------
-- DDR MPMC CORE & Clock generator XPS system
-------------------------------------------------------------------------------------------------------------------------
Inst_system: system PORT MAP(
		DDR_DQ => DDR_DQ,
		DDR_Addr_pin => DDR_Addr_pin,
		DDR_BankAddr_pin => DDR_BankAddr_pin,
		DDR_CAS_n_pin => DDR_CAS_n_pin,
		DDR_CE_pin => DDR_CE_pin,
		DDR_CS_n_pin => DDR_CS_n_pin,
		DDR_RAS_n_pin => DDR_RAS_n_pin,
		DDR_WE_n_pin => DDR_WE_n_pin,
		DDR_DM_pin => DDR_DM_pin,
		DDR_DQS_pin => DDR_DQS_pin,
		DDR_Clk_pin => DDR_Clk_pin,
		DDR_Clk_n_pin => DDR_Clk_n_pin,
		sys_clk_pin => SYSCLK,
		sys_rst_pin => SYSRST,
		sys_clk_s_pin => sys_clk_s_pin,
	
		MPMC3_DDR_PIM1_InitDone_pin => MPMC3_DDR_PIM1_InitDone_pin,
		MPMC3_DDR_PIM1_RdFIFO_Latency_pin => MPMC3_DDR_PIM1_RdFIFO_Latency_pin,
		MPMC3_DDR_PIM1_RdFIFO_Flush_pin => MPMC3_DDR_PIM1_RdFIFO_Flush_pin,
		MPMC3_DDR_PIM1_RdFIFO_Empty_pin => MPMC3_DDR_PIM1_RdFIFO_Empty_pin,
		MPMC3_DDR_PIM1_WrFIFO_Flush_pin => MPMC3_DDR_PIM1_WrFIFO_Flush_pin,
		MPMC3_DDR_PIM1_WrFIFO_AlmostFull_pin => MPMC3_DDR_PIM1_WrFIFO_AlmostFull_pin,
		MPMC3_DDR_PIM1_WrFIFO_Empty_pin => MPMC3_DDR_PIM1_WrFIFO_Empty_pin,
		MPMC3_DDR_PIM1_RdFIFO_RdWdAddr_pin => MPMC3_DDR_PIM1_RdFIFO_RdWdAddr_pin,
		MPMC3_DDR_PIM1_RdFIFO_Pop_pin => MPMC3_DDR_PIM1_RdFIFO_Pop_pin,
		MPMC3_DDR_PIM1_RdFIFO_Data_pin => MPMC3_DDR_PIM1_RdFIFO_Data_pin,
		MPMC3_DDR_PIM1_WrFIFO_Push_pin => MPMC3_DDR_PIM1_WrFIFO_Push_pin,
		MPMC3_DDR_PIM1_WrFIFO_BE_pin => MPMC3_DDR_PIM1_WrFIFO_BE_pin,
		MPMC3_DDR_PIM1_WrFIFO_Data_pin => MPMC3_DDR_PIM1_WrFIFO_Data_pin,
		MPMC3_DDR_PIM1_RdModWr_pin => MPMC3_DDR_PIM1_RdModWr_pin,
		MPMC3_DDR_PIM1_Size_pin => MPMC3_DDR_PIM1_Size_pin,
		MPMC3_DDR_PIM1_RNW_pin => MPMC3_DDR_PIM1_RNW_pin,
		MPMC3_DDR_PIM1_AddrAck_pin => MPMC3_DDR_PIM1_AddrAck_pin,
		MPMC3_DDR_PIM1_AddrReq_pin => MPMC3_DDR_PIM1_AddrReq_pin,
		MPMC3_DDR_PIM1_Addr_pin => MPMC3_DDR_PIM1_Addr_pin,
		
		MPMC3_DDR_PIM2_InitDone_pin => MPMC3_DDR_PIM2_InitDone_pin,
		MPMC3_DDR_PIM2_RdFIFO_Latency_pin => MPMC3_DDR_PIM2_RdFIFO_Latency_pin,
		MPMC3_DDR_PIM2_RdFIFO_Flush_pin => MPMC3_DDR_PIM2_RdFIFO_Flush_pin,
		MPMC3_DDR_PIM2_RdFIFO_Empty_pin => MPMC3_DDR_PIM2_RdFIFO_Empty_pin,
		MPMC3_DDR_PIM2_WrFIFO_Flush_pin => MPMC3_DDR_PIM2_WrFIFO_Flush_pin,
		MPMC3_DDR_PIM2_WrFIFO_AlmostFull_pin => MPMC3_DDR_PIM2_WrFIFO_AlmostFull_pin,
		MPMC3_DDR_PIM2_WrFIFO_Empty_pin => MPMC3_DDR_PIM2_WrFIFO_Empty_pin,
		MPMC3_DDR_PIM2_RdFIFO_RdWdAddr_pin => MPMC3_DDR_PIM2_RdFIFO_RdWdAddr_pin,
		MPMC3_DDR_PIM2_RdFIFO_Pop_pin => MPMC3_DDR_PIM2_RdFIFO_Pop_pin,
		MPMC3_DDR_PIM2_RdFIFO_Data_pin => MPMC3_DDR_PIM2_RdFIFO_Data_pin,
		MPMC3_DDR_PIM2_WrFIFO_Push_pin => MPMC3_DDR_PIM2_WrFIFO_Push_pin,
		MPMC3_DDR_PIM2_WrFIFO_BE_pin => MPMC3_DDR_PIM2_WrFIFO_BE_pin,
		MPMC3_DDR_PIM2_WrFIFO_Data_pin => MPMC3_DDR_PIM2_WrFIFO_Data_pin,
		MPMC3_DDR_PIM2_RdModWr_pin => MPMC3_DDR_PIM2_RdModWr_pin,
		MPMC3_DDR_PIM2_Size_pin => MPMC3_DDR_PIM2_Size_pin,
		MPMC3_DDR_PIM2_RNW_pin => MPMC3_DDR_PIM2_RNW_pin,
		MPMC3_DDR_PIM2_AddrAck_pin => MPMC3_DDR_PIM2_AddrAck_pin,
		MPMC3_DDR_PIM2_AddrReq_pin => MPMC3_DDR_PIM2_AddrReq_pin,
		MPMC3_DDR_PIM2_Addr_pin => MPMC3_DDR_PIM2_Addr_pin,

		MPMC3_DDR_PIM3_InitDone_pin => MPMC3_DDR_PIM3_InitDone_pin,
		MPMC3_DDR_PIM3_RdFIFO_Latency_pin => MPMC3_DDR_PIM3_RdFIFO_Latency_pin,
		MPMC3_DDR_PIM3_RdFIFO_Flush_pin => MPMC3_DDR_PIM3_RdFIFO_Flush_pin,
		MPMC3_DDR_PIM3_RdFIFO_Empty_pin => MPMC3_DDR_PIM3_RdFIFO_Empty_pin,
		MPMC3_DDR_PIM3_WrFIFO_Flush_pin => MPMC3_DDR_PIM3_WrFIFO_Flush_pin,
		MPMC3_DDR_PIM3_WrFIFO_AlmostFull_pin => MPMC3_DDR_PIM3_WrFIFO_AlmostFull_pin,
		MPMC3_DDR_PIM3_WrFIFO_Empty_pin => MPMC3_DDR_PIM3_WrFIFO_Empty_pin,
		MPMC3_DDR_PIM3_RdFIFO_RdWdAddr_pin => MPMC3_DDR_PIM3_RdFIFO_RdWdAddr_pin,
		MPMC3_DDR_PIM3_RdFIFO_Pop_pin => MPMC3_DDR_PIM3_RdFIFO_Pop_pin,
		MPMC3_DDR_PIM3_RdFIFO_Data_pin => MPMC3_DDR_PIM3_RdFIFO_Data_pin,
		MPMC3_DDR_PIM3_WrFIFO_Push_pin => MPMC3_DDR_PIM3_WrFIFO_Push_pin,
		MPMC3_DDR_PIM3_WrFIFO_BE_pin => MPMC3_DDR_PIM3_WrFIFO_BE_pin,
		MPMC3_DDR_PIM3_WrFIFO_Data_pin => MPMC3_DDR_PIM3_WrFIFO_Data_pin,
		MPMC3_DDR_PIM3_RdModWr_pin => MPMC3_DDR_PIM3_RdModWr_pin,
		MPMC3_DDR_PIM3_Size_pin => MPMC3_DDR_PIM3_Size_pin,
		MPMC3_DDR_PIM3_RNW_pin => MPMC3_DDR_PIM3_RNW_pin,
		MPMC3_DDR_PIM3_AddrAck_pin => MPMC3_DDR_PIM3_AddrAck_pin,
		MPMC3_DDR_PIM3_AddrReq_pin => MPMC3_DDR_PIM3_AddrReq_pin,
		MPMC3_DDR_PIM3_Addr_pin => MPMC3_DDR_PIM3_Addr_pin,
		
		MPMC3_DDR_PIM4_InitDone_pin => MPMC3_DDR_PIM4_InitDone_pin,
		MPMC3_DDR_PIM4_RdFIFO_Latency_pin => MPMC3_DDR_PIM4_RdFIFO_Latency_pin,
		MPMC3_DDR_PIM4_RdFIFO_Flush_pin => MPMC3_DDR_PIM4_RdFIFO_Flush_pin,
		MPMC3_DDR_PIM4_RdFIFO_Empty_pin => MPMC3_DDR_PIM4_RdFIFO_Empty_pin,
		MPMC3_DDR_PIM4_WrFIFO_Flush_pin => MPMC3_DDR_PIM4_WrFIFO_Flush_pin,
		MPMC3_DDR_PIM4_WrFIFO_AlmostFull_pin => MPMC3_DDR_PIM4_WrFIFO_AlmostFull_pin,
		MPMC3_DDR_PIM4_WrFIFO_Empty_pin => MPMC3_DDR_PIM4_WrFIFO_Empty_pin,
		MPMC3_DDR_PIM4_RdFIFO_RdWdAddr_pin => MPMC3_DDR_PIM4_RdFIFO_RdWdAddr_pin,
		MPMC3_DDR_PIM4_RdFIFO_Pop_pin => MPMC3_DDR_PIM4_RdFIFO_Pop_pin,
		MPMC3_DDR_PIM4_RdFIFO_Data_pin => MPMC3_DDR_PIM4_RdFIFO_Data_pin,
		MPMC3_DDR_PIM4_WrFIFO_Push_pin => MPMC3_DDR_PIM4_WrFIFO_Push_pin,
		MPMC3_DDR_PIM4_WrFIFO_BE_pin => MPMC3_DDR_PIM4_WrFIFO_BE_pin,
		MPMC3_DDR_PIM4_WrFIFO_Data_pin => MPMC3_DDR_PIM4_WrFIFO_Data_pin,
		MPMC3_DDR_PIM4_RdModWr_pin => MPMC3_DDR_PIM4_RdModWr_pin,
		MPMC3_DDR_PIM4_Size_pin => MPMC3_DDR_PIM4_Size_pin,
		MPMC3_DDR_PIM4_RNW_pin => MPMC3_DDR_PIM4_RNW_pin,
		MPMC3_DDR_PIM4_AddrAck_pin => MPMC3_DDR_PIM4_AddrAck_pin,
		MPMC3_DDR_PIM4_AddrReq_pin => MPMC3_DDR_PIM4_AddrReq_pin,
		MPMC3_DDR_PIM4_Addr_pin => MPMC3_DDR_PIM4_Addr_pin
	);
	
-------------------------------------------------------------------------------------------------------------------------
-- MVP WRAPPER INSTANTIATION
-------------------------------------------------------------------------------------------------------------------------	

MITI : rsp517_Mitrion_wrapper
generic map (
 c_mvp_port_presence=>c_mvp_port_presence,
 c_mvp_scalar_port_num=>c_mvp_scalar_port_num,
 dwa=>dwa,
 awa=>awa,
 dwb=>dwb,
 awb=>awb,
 dwc=>dwc,
 awc=>awc
)
port map (
rst=>mvp_rst, 
clk=>CLK2X,

Din0 => Din0,
Vin0 => Vin0,
Cin0 => Cin0,
Dout0 => Dout0,
Vout0 => Vout0,
Cout0 => Cout0,

Din1 => Din1,
Vin1 => Vin1,
Cin1 => Cin1,
Dout1 => Dout1,
Vout1 => Vout1,
Cout1 => Cout1,

Din2 => Din2,
Vin2 => Vin2,
Cin2 => Cin2,
Dout2 => Dout2,
Vout2 => Vout2,
Cout2 => Cout2,

Din3 => Din3,
Vin3 => Vin3,
Cin3 => Cin3,
Dout3 => Dout3,
Vout3 => Vout3,
Cout3 => Cout3,

Din4 => mvp_scalar_in_port_array(0).Din,
Vin4 => mvp_scalar_in_port_array(0).Vin,
Cin4 => mvp_scalar_in_port_array(0).Cin,
Dout4 => mvp_scalar_out_port_array(0).Dout,
Vout4 => mvp_scalar_out_port_array(0).Vout,
Cout4 => mvp_scalar_out_port_array(0).Cout,

Din5 => mvp_scalar_in_port_array(1).Din,
Vin5 => mvp_scalar_in_port_array(1).Vin,
Cin5 => mvp_scalar_in_port_array(1).Cin,
Dout5 => mvp_scalar_out_port_array(1).Dout,
Vout5 => mvp_scalar_out_port_array(1).Vout,
Cout5 => mvp_scalar_out_port_array(1).Cout,

Din6 => mvp_scalar_in_port_array(2).Din,
Vin6 => mvp_scalar_in_port_array(2).Vin,
Cin6 => mvp_scalar_in_port_array(2).Cin,
Dout6 => mvp_scalar_out_port_array(2).Dout,
Vout6 => mvp_scalar_out_port_array(2).Vout,
Cout6 => mvp_scalar_out_port_array(2).Cout,

Din7 => mvp_scalar_in_port_array(3).Din,
Vin7 => mvp_scalar_in_port_array(3).Vin,
Cin7 => mvp_scalar_in_port_array(3).Cin,
Dout7 => mvp_scalar_out_port_array(3).Dout,
Vout7 => mvp_scalar_out_port_array(3).Vout,
Cout7 => mvp_scalar_out_port_array(3).Cout,

Din8 => mvp_scalar_in_port_array(4).Din,
Vin8 => mvp_scalar_in_port_array(4).Vin,
Cin8 => mvp_scalar_in_port_array(4).Cin,
Dout8 => mvp_scalar_out_port_array(4).Dout,
Vout8 => mvp_scalar_out_port_array(4).Vout,
Cout8 => mvp_scalar_out_port_array(4).Cout,

Din9 => mvp_scalar_in_port_array(5).Din,
Vin9 => mvp_scalar_in_port_array(5).Vin,
Cin9 => mvp_scalar_in_port_array(5).Cin,
Dout9 => mvp_scalar_out_port_array(5).Dout,
Vout9 => mvp_scalar_out_port_array(5).Vout,
Cout9 => mvp_scalar_out_port_array(5).Cout,

Din10 => mvp_scalar_in_port_array(6).Din,
Vin10 => mvp_scalar_in_port_array(6).Vin,
Cin10 => mvp_scalar_in_port_array(6).Cin,
Dout10 => mvp_scalar_out_port_array(6).Dout,
Vout10 => mvp_scalar_out_port_array(6).Vout,
Cout10 => mvp_scalar_out_port_array(6).Cout,

Din11 => mvp_scalar_in_port_array(7).Din,
Vin11 => mvp_scalar_in_port_array(7).Vin,
Cin11 => mvp_scalar_in_port_array(7).Cin,
Dout11 => mvp_scalar_out_port_array(7).Dout,
Vout11 => mvp_scalar_out_port_array(7).Vout,
Cout11 => mvp_scalar_out_port_array(7).Cout,


  -- extram interface
         REA=>REA,
         RAckA=>RAckA,
         RAddrA=>RAddrA,
         RDataA=>RDataA,
         RStallA=>RStallA,
         WEA=>WEA,
         WAddrA=>WAddrA,
         WDataA=>WDataA,
         WStallA=>WStallA,
         REB=>REB,
         RAckB=>RAckB,
         RAddrB=>RAddrB,
         RDataB=>RDataB,
         RStallB=>RStallB,
         WEB=>WEB,
         WAddrB=>WAddrB,
         WDataB=>WDataB,
         WStallB=>WStallB,
         REC=>REC,
         RAckC=>RAckC,
         RAddrC=>RAddrC,
         RDataC=>RDataC,
         RStallC=>RStallC,
         WEC=>WEC,
         WAddrC=>WAddrC,
         WDataC=>WDataC,
         WStallC=>WStallC
);

-------------------------------------------------------------------------------------------------------------------------
-- PIM1 : DDR MPMC NPI HOST READ INTERFACE
-------------------------------------------------------------------------------------------------------------------------

NPI_HOST_RD:		
if c_ddr_host_presence = 1 generate	
Inst_my_npi_1: my_host_npi_rd_fifo
port map(
CLK0=>sys_clk_s_pin,
RST=>RST,
ra_fifo_wr_cmd=>ra_fifo_wr_cmd,
ra_fifo_wr_data=>ra_fifo_wr_data,
rd_fifo_rd_cmd=>rd_fifo_rd_cmd,
rd_fifo_rd_data=>rd_fifo_rd_data,
NPI_Addr=>MPMC3_DDR_PIM1_Addr_pin,
NPI_AddrReq=>MPMC3_DDR_PIM1_AddrReq_pin,
NPI_AddrAck=>MPMC3_DDR_PIM1_AddrAck_pin,
NPI_RNW => MPMC3_DDR_PIM1_RNW_pin,
NPI_Size => MPMC3_DDR_PIM1_Size_pin,
NPI_WrFIFO_Data => MPMC3_DDR_PIM1_WrFIFO_Data_pin,
NPI_WrFIFO_BE => MPMC3_DDR_PIM1_WrFIFO_BE_pin,
NPI_WrFIFO_Push => MPMC3_DDR_PIM1_WrFIFO_Push_pin,
NPI_RdFIFO_Data => MPMC3_DDR_PIM1_RdFIFO_Data_pin,
NPI_RdFIFO_Pop => MPMC3_DDR_PIM1_RdFIFO_Pop_pin,
NPI_RdFIFO_RdWdAddr => MPMC3_DDR_PIM1_RdFIFO_RdWdAddr_pin,
NPI_WrFIFO_Empty => MPMC3_DDR_PIM1_RdFIFO_Empty_pin,
NPI_WrFIFO_AlmostFull => MPMC3_DDR_PIM1_WrFIFO_AlmostFull_pin,
NPI_WrFIFO_Flush => MPMC3_DDR_PIM1_WrFIFO_Flush_pin,
NPI_RdFIFO_Empty => MPMC3_DDR_PIM1_RdFIFO_Empty_pin,
NPI_RdFIFO_Flush => MPMC3_DDR_PIM1_RdFIFO_Flush_pin,
NPI_RdFIFO_Latency => MPMC3_DDR_PIM1_RdFIFO_Latency_pin,
NPI_RdModWr => MPMC3_DDR_PIM1_RdModWr_pin,
NPI_InitDone => MPMC3_DDR_PIM1_InitDone_pin,
--LED=>open,
cmd=>npi_cmd,
data=>npi_data,
status=>npi_status,
counter1=>npi_counter11,
counter2=>npi_counter21
);	
end generate;

-------------------------------------------------------------------------------------------------------------------------
-- PIM2 : DDR MPMC NPI HOST WRITE INTERFACE
-------------------------------------------------------------------------------------------------------------------------

NPI_HOST_WR:		
if c_ddr_host_presence = 1 generate	
Inst_my_npi_2: my_host_npi_we
port map(
CLK0=>sys_clk_s_pin,
RST=>RST,
RE=>npi_RE2,
RAck=>npi_RAck2,
Addr=>npi_Addr2,
RData=>npi_RData2,
WE=>npi_WE2,
WData=>npi_WData2,
NPI_Addr=>MPMC3_DDR_PIM2_Addr_pin,
NPI_AddrReq=>MPMC3_DDR_PIM2_AddrReq_pin,
NPI_AddrAck=>MPMC3_DDR_PIM2_AddrAck_pin,
NPI_RNW => MPMC3_DDR_PIM2_RNW_pin,
NPI_Size => MPMC3_DDR_PIM2_Size_pin,
NPI_WrFIFO_Data => MPMC3_DDR_PIM2_WrFIFO_Data_pin,
NPI_WrFIFO_BE => MPMC3_DDR_PIM2_WrFIFO_BE_pin,
NPI_WrFIFO_Push => MPMC3_DDR_PIM2_WrFIFO_Push_pin,
NPI_RdFIFO_Data => MPMC3_DDR_PIM2_RdFIFO_Data_pin,
NPI_RdFIFO_Pop => MPMC3_DDR_PIM2_RdFIFO_Pop_pin,
NPI_RdFIFO_RdWdAddr => MPMC3_DDR_PIM2_RdFIFO_RdWdAddr_pin,
NPI_WrFIFO_Empty => MPMC3_DDR_PIM2_RdFIFO_Empty_pin,
NPI_WrFIFO_AlmostFull => MPMC3_DDR_PIM2_WrFIFO_AlmostFull_pin,
NPI_WrFIFO_Flush => MPMC3_DDR_PIM2_WrFIFO_Flush_pin,
NPI_RdFIFO_Empty => MPMC3_DDR_PIM2_RdFIFO_Empty_pin,
NPI_RdFIFO_Flush => MPMC3_DDR_PIM2_RdFIFO_Flush_pin,
NPI_RdFIFO_Latency => MPMC3_DDR_PIM2_RdFIFO_Latency_pin,
NPI_RdModWr => MPMC3_DDR_PIM2_RdModWr_pin,
NPI_InitDone => MPMC3_DDR_PIM2_InitDone_pin,
--LED=>open,
cmd=>npi_cmd2,
data=>npi_data2,
status=>npi_status2,
counter1=>npi_counter12,
counter2=>npi_counter22
);	
end generate;

-------------------------------------------------------------------------------------------------------------------------
-- PIM 3 & 4 DDR MPMC NPI  MVP INTERFACE
-------------------------------------------------------------------------------------------------------------------------

DummyRAddrA<="00000" & RAddrA(26 downto 0);
DummyWAddrA<="00000" & WAddrA(26 downto 0);


NPI_MVP_RW:	
if c_mvp_port_presence(0) = 1  generate
Inst_my_npi_3: my_mvp_npi_rw_fifo
generic map(
rd_fifo_depth=>32,
wr_fifo_depth=>32,
aw=>32,
dw=>32
)
port map(
mvp_clk=>sys_clk_s_pin,
RST=>mvp_rst,
Din => Din0,
Vin => Vin0,
Cin => Cin0,
Dout => Dout0,
Vout => Vout0,
Cout => Cout0,
RE=>REA,
RAck=>RAckA,
RAddr=>DummyRAddrA,
RData=>RDataA,
RStall=>RStallA,
WE=>WEA,
WAddr=>DummyWAddrA,
WData=>WDataA,
WStall=>WStallA,

RD_NPI_Addr=>MPMC3_DDR_PIM3_Addr_pin,
RD_NPI_AddrReq=>MPMC3_DDR_PIM3_AddrReq_pin,
RD_NPI_AddrAck=>MPMC3_DDR_PIM3_AddrAck_pin,
RD_NPI_RNW => MPMC3_DDR_PIM3_RNW_pin,
RD_NPI_Size => MPMC3_DDR_PIM3_Size_pin,
RD_NPI_WrFIFO_Data => MPMC3_DDR_PIM3_WrFIFO_Data_pin,
RD_NPI_WrFIFO_BE => MPMC3_DDR_PIM3_WrFIFO_BE_pin,
RD_NPI_WrFIFO_Push => MPMC3_DDR_PIM3_WrFIFO_Push_pin,
RD_NPI_RdFIFO_Data => MPMC3_DDR_PIM3_RdFIFO_Data_pin,
RD_NPI_RdFIFO_Pop => MPMC3_DDR_PIM3_RdFIFO_Pop_pin,
RD_NPI_RdFIFO_RdWdAddr => MPMC3_DDR_PIM3_RdFIFO_RdWdAddr_pin,
RD_NPI_WrFIFO_Empty => MPMC3_DDR_PIM3_RdFIFO_Empty_pin,
RD_NPI_WrFIFO_AlmostFull => MPMC3_DDR_PIM3_WrFIFO_AlmostFull_pin,
RD_NPI_WrFIFO_Flush => MPMC3_DDR_PIM3_WrFIFO_Flush_pin,
RD_NPI_RdFIFO_Empty => MPMC3_DDR_PIM3_RdFIFO_Empty_pin,
RD_NPI_RdFIFO_Flush => MPMC3_DDR_PIM3_RdFIFO_Flush_pin,
RD_NPI_RdFIFO_Latency => MPMC3_DDR_PIM3_RdFIFO_Latency_pin,
RD_NPI_RdModWr => MPMC3_DDR_PIM3_RdModWr_pin,
RD_NPI_InitDone => MPMC3_DDR_PIM3_InitDone_pin,

WR_NPI_Addr=>MPMC3_DDR_PIM4_Addr_pin,
WR_NPI_AddrReq=>MPMC3_DDR_PIM4_AddrReq_pin,
WR_NPI_AddrAck=>MPMC3_DDR_PIM4_AddrAck_pin,
WR_NPI_RNW => MPMC3_DDR_PIM4_RNW_pin,
WR_NPI_Size => MPMC3_DDR_PIM4_Size_pin,
WR_NPI_WrFIFO_Data => MPMC3_DDR_PIM4_WrFIFO_Data_pin,
WR_NPI_WrFIFO_BE => MPMC3_DDR_PIM4_WrFIFO_BE_pin,
WR_NPI_WrFIFO_Push => MPMC3_DDR_PIM4_WrFIFO_Push_pin,
WR_NPI_RdFIFO_Data => MPMC3_DDR_PIM4_RdFIFO_Data_pin,
WR_NPI_RdFIFO_Pop => MPMC3_DDR_PIM4_RdFIFO_Pop_pin,
WR_NPI_RdFIFO_RdWdAddr => MPMC3_DDR_PIM4_RdFIFO_RdWdAddr_pin,
WR_NPI_WrFIFO_Empty => MPMC3_DDR_PIM4_RdFIFO_Empty_pin,
WR_NPI_WrFIFO_AlmostFull => MPMC3_DDR_PIM4_WrFIFO_AlmostFull_pin,
WR_NPI_WrFIFO_Flush => MPMC3_DDR_PIM4_WrFIFO_Flush_pin,
WR_NPI_RdFIFO_Empty => MPMC3_DDR_PIM4_RdFIFO_Empty_pin,
WR_NPI_RdFIFO_Flush => MPMC3_DDR_PIM4_RdFIFO_Flush_pin,
WR_NPI_RdFIFO_Latency => MPMC3_DDR_PIM4_RdFIFO_Latency_pin,
WR_NPI_RdModWr => MPMC3_DDR_PIM4_RdModWr_pin,
WR_NPI_InitDone => MPMC3_DDR_PIM4_InitDone_pin,

  -- ctrl
  status=>mvp_port0_status,
  initial_handshaking=>mvp_port0_initial_handshaking,
  farewell_handshaking=>mvp_port0_farewell_handshaking,
  cmd=>mvp_port0_cmd,
  rcnt=>mvp_port0_data(31 downto 16),
  wcnt=>mvp_port0_data(15 downto 0),
  -- dbg
--LED=>open,  
npi_status=>npi_status3,
counter1=>npi_counter13,
counter2=>npi_counter23
);	
end generate;


-------------------------------------------------------------------------------------------------------------------------
-- MVP CTRL CORE
-------------------------------------------------------------------------------------------------------------------------

Inst_mvp_ctrl: mvp_ctrl 
port map (
  -- system
  rst=>RST,mvp_clk=>CLK2X,
  -- mvp
  mvp_rst=>mvp_rst,
  -- ctrl
  cmd=>mvp_ctrl_cmd,
  status=>mvp_ctrl_status
);


-------------------------------------------------------------------------------------------------------------------------
-- BRAM1 (host write,MVP read only)
-------------------------------------------------------------------------------------------------------------------------

BRAM1:
if c_mvp_port_presence(1) = 1 generate
bram2_instance : blk_mem_gen_v2_6
port map (
clka => CLK,
dina => bram1_dina,
addra => bram1_addra,
wea => bram1_wea,
douta => bram1_douta,
clkb => CLK2X,
dinb => bram1_dinb,
addrb => bram1_addrb,
web => bram1_web,
doutb => bram1_doutb
);
end generate;

-------------------------------------------------------------------------------------------------------------------------
-- BRAM2 (host read,MVP write only)
-------------------------------------------------------------------------------------------------------------------------

BRAM2:
if c_mvp_port_presence(2) = 1 generate
bram3_instance : blk_mem_gen_v2_6
port map (
clka => CLK,
dina => bram2_dina,
addra => bram2_addra,
wea => bram2_wea,
douta => bram2_douta,
clkb => CLK2X,
dinb => bram2_dinb,
addrb => bram2_addrb,
web => bram2_web,
doutb => bram2_doutb
);
end generate;

-------------------------------------------------------------------------------------------------------------------------
-- MVP read only BRAM1 port
-------------------------------------------------------------------------------------------------------------------------

PORT1:
if c_mvp_port_presence(1) = 1  generate
Inst_mvp_ram_inout_port1 : mvp_ram_inout_port
generic map ( 
  dw=>32,
  aw=>awb
)
port map(
  -- sys
  rst=>mvp_rst, 
  mvp_clk=>CLK2X,
  -- mvp 
  Din=>Din1,
  Vin=>Vin1,
  Cin=>Cin1,
  Dout=>Dout1,
  Vout=>Vout1,
  Cout=>Cout1,
  RE=>REB,
  RAck=>RAckB,
  RAddr=>RAddrB,
  RData=>RDataB,
  RStall=>RStallB,
  WE=>WEB,
  WAddr=>WAddrB,
  WData=>WDataB,
  WStall=>WStallB,
  -- ram READ ONLY
  RAMAI=>OpenRAMAI,
  RAMDI=>OpenRAMDI,
  RAMWE=>OpenRAMWE,
  RAMAO=>bram1_addrb,
  RAMDO=>bram1_doutb,
  -- ctrl
  status=>mvp_port1_status,
  initial_handshaking=>mvp_port1_initial_handshaking,
  farewell_handshaking=>mvp_port1_farewell_handshaking,
  cmd=>mvp_port1_cmd,
  rcnt=>mvp_port1_data(31 downto 16),
  wcnt=>mvp_port1_data(15 downto 0)
);
end generate;

-------------------------------------------------------------------------------------------------------------------------
-- MVP write only BRAM2 port
-------------------------------------------------------------------------------------------------------------------------

PORT2:
if c_mvp_port_presence(2) = 1  generate
Inst_mvp_ram_inout_port2 : mvp_ram_inout_port
generic map ( 
  dw=>32,
  aw=>awc
)
port map(
  -- sys
  rst=>mvp_rst, 
  mvp_clk=>CLK2X,
  -- mvp 
  Din=>Din2,
  Vin=>Vin2,
  Cin=>Cin2,
  Dout=>Dout2,
  Vout=>Vout2,
  Cout=>Cout2,
  RE=>REC,
  RAck=>RAckC,
  RAddr=>RAddrC,
  RData=>RDataC,
  RStall=>RStallC,
  WE=>WEC,
  WAddr=>WAddrC,
  WData=>WDataC,
  WStall=>WStallC,
  -- ram WRITE ONLY
  RAMAI=>bram2_addrb,
  RAMDI=>bram2_dinb,
  RAMWE=>bram2_web(0),
  RAMAO=>DUMMYRAMAO,
  RAMDO=>DUMMYRAMDO,
  -- ctrl
  status=>mvp_port2_status,
  cmd=>mvp_port2_cmd,
  initial_handshaking=>mvp_port2_initial_handshaking,
  farewell_handshaking=>mvp_port2_farewell_handshaking,
  rcnt=>mvp_port2_data(31 downto 16),
  wcnt=>mvp_port2_data(15 downto 0)
);
end generate;

-------------------------------------------------------------------------------------------------------------------------
-- MVP stream out port
-------------------------------------------------------------------------------------------------------------------------

PORT3:
if c_mvp_port_presence(3) = 1 generate
Inst_mvp_stream_out_port3 : mvp_stream_out_port
port map(
  -- system
  rst=>mvp_rst, mvp_clk=>CLK2X,
  -- out from mvp 
  Dout=>Dout3,
  Vout=>Vout3,
  Cout=>Cout3,
  -- ctrl
  cmd=>mvp_out_port3_cmd,
  data=>mvp_out_port3_data,
  status=>mvp_out_port3_status,
  tail=>mvp_out_port3_tail,
  enable=>mvp_out_port3_enable

);

-------------------------------------------------------------------------------------------------------------------------
-- MVP stream in port
-------------------------------------------------------------------------------------------------------------------------

Inst_mvp_stream_in_port3 : mvp_stream_in_port
port map(
  -- sys
  rst=>mvp_rst, 
  mvp_clk=>CLK2X,
  -- mvp
  Din=>Din3,
  Vin=>Vin3,
  Cin=>Cin3,
  -- ctrl
  cmd=>mvp_in_port3_cmd,
  data=>mvp_in_port3_data,
  status=>mvp_in_port3_status,
  bk=>mvp_in_port3_bk,
  wt=>mvp_in_port3_wt,
  tail=>mvp_in_port3_tail,
  enable=>mvp_in_port3_enable
);
end generate;

-------------------------------------------------------------------------------------------------------------------------
-- MVP scalar in/out ports
-------------------------------------------------------------------------------------------------------------------------

PORT4:
FOR i in 0 to c_mvp_scalar_port_num-1 generate
PORT4I:
if c_mvp_port_presence(4) = 1 generate
Inst_mvp_scalar_out_port4 : mvp_scalar_out_port
port map(
  -- system
  rst=>mvp_rst, 
  mvp_clk=>CLK2X,
  -- mvp 
  Dout=>mvp_scalar_out_port_array(i).Dout,
  Vout=>mvp_scalar_out_port_array(i).Vout,
  Cout=>mvp_scalar_out_port_array(i).Cout,
  -- ctrl
  cmd=>mvp_scalar_out_port_array(i).cmd,
  data=>mvp_scalar_out_port_array(i).data,
  status=>mvp_scalar_out_port_array(i).status
);
Inst_mvp_scalar_in_port4 : mvp_scalar_in_port
port map(
  -- sys
  rst=>mvp_rst, 
  mvp_clk=>CLK2X,
  -- mvp
  Din=>mvp_scalar_in_port_array(i).Din,
  Vin=>mvp_scalar_in_port_array(i).Vin,
  Cin=>mvp_scalar_in_port_array(i).Cin,
  -- ctrl
  cmd=>mvp_scalar_in_port_array(i).cmd,
  bk=>mvp_scalar_in_port_array(i).bk,
  data=>mvp_scalar_in_port_array(i).data,
  status=>mvp_scalar_in_port_array(i).status,
  wt=>mvp_scalar_in_port_array(i).wt
);
end generate;
end generate;


-------------------------------------------------------------------------------------------------------------------------
-- Local Bus transactions hadler process
-------------------------------------------------------------------------------------------------------------------------

LB_SUPERVISOR:
process (CLK, RST)
variable index: integer := 0 ;
variable rst_cnt: integer := 0 ; 
begin
if RST = '1' then	-- RESET
-- LB
LWAIT <= '1';
SCMD <= "00000000";
SADDR(31 downto 0) <= X"00000000";
SADDR(63 downto 32) <= X"00000000";
LCBE <= "ZZZZZZZZ";
LAD <= "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
-- BRAM
--bram0_ena <= '1';
bram1_ena <= '1';
bram2_ena <= '1';
--bram0_wea(0) <= '0';
bram1_wea(0) <= '0';
bram2_wea(0) <= '0';
-- MVP
mvp_port0_cmd <= '0';
mvp_port1_cmd <= '0';
mvp_port2_cmd <= '0';
-- NPI
npi_cmd<='0';
npi_cmd2<='0';
ra_fifo_wr_cmd<='0';
rd_fifo_rd_cmd<='0';
elsif CLK = '1' and CLK'event then	-- PROCESS
index:=conv_integer(unsigned(SADDR(15 downto 2)));--2^13 words
LWAIT <= '0';
-- MVP cmds
--  MVP ctrl
mvp_ctrl_cmd<='0';
--  MVP mem ports
mvp_port0_cmd <= '0';
mvp_port1_cmd <= '0';
mvp_port2_cmd <= '0';
-- MVP stream port
mvp_out_port3_cmd<='0';
mvp_in_port3_cmd<='0';
mvp_in_port3_bk<='0';
mvp_in_port3_tail<='0';
mvp_in_port3_enable<='1';
-- MVP scalar ports
mvp_scalar_out_port_array(0).cmd<='0';
mvp_scalar_in_port_array(0).cmd<='0';
mvp_scalar_out_port_array(1).cmd<='0';
mvp_scalar_in_port_array(1).cmd<='0';
mvp_scalar_out_port_array(2).cmd<='0';
mvp_scalar_in_port_array(2).cmd<='0';
mvp_scalar_out_port_array(3).cmd<='0';
mvp_scalar_in_port_array(3).cmd<='0';
mvp_scalar_out_port_array(4).cmd<='0';
mvp_scalar_in_port_array(4).cmd<='0';
mvp_scalar_out_port_array(5).cmd<='0';
mvp_scalar_in_port_array(5).cmd<='0';
mvp_scalar_out_port_array(6).cmd<='0';
mvp_scalar_in_port_array(6).cmd<='0';
mvp_scalar_out_port_array(7).cmd<='0';
mvp_scalar_in_port_array(7).cmd<='0';
-- BRAM 
--bram0_wea(0) <= '0';
bram1_wea(0) <= '0';
bram2_wea(0) <= '0';
-- NPI
npi_cmd<='0';
npi_cmd2<='0';
ra_fifo_wr_cmd<='0';
rd_fifo_rd_cmd<='0';

-- MAIN TRANSACTION HANDLER
if FPGAS = '1' then -- FPGA SELECT
	if LADD = '1' then -- ADDRESS PHASE
		SCMD <= LCBE;
		SADDR <= LAD; -- !!! SAVE ADDRESS PHASE
	elsif LDAT = '1' then -- WRITE/READ DATA PHASE SADDR
		if RNW = '1' then
----------------------- WRITE
			CBE_REG <= LCBE;
			case SADDR(19 downto 16) is
			when "0000" => -- (8K of 32-bit words)
				case SADDR(13 downto 2) is
----------------------- boot (0..3)
				when X"000" => -- boot reg0
				boot0_reg<=LAD(31 downto 0);
				when X"001" => -- boot reg1
				boot1_reg<=LAD(31 downto 0);				
----------------------- ctrl (4..7)
				when X"004" => -- ctrl cmd
				mvp_ctrl_cmd<=LAD(0);
				when X"005" => -- ram  port cmd
				mvp_port0_cmd<=LAD(0);
				mvp_port1_cmd<=LAD(2);
				mvp_port2_cmd<=LAD(4);
				when X"006" => -- ram  port cmd				
				npi_cmd<=LAD(0);
				npi_cmd2<=LAD(1);				
----------------------- port 0 (8..b)
				when X"008" => -- ram inout port cmd
				npi_Addr<=LAD(31 downto 0);
				when X"009" => -- ram inout port cmd
				npi_Addr2<=LAD(31 downto 0);
				when X"00a" => -- ram inout port cmd
				npi_WData2<=LAD(31 downto 0);
----------------------- port 1 (c..f)
				when X"00c" => -- ram inout port cmd
				ra_fifo_wr_data<=LAD(31 downto 0);
				when X"00d" => -- ram inout port cmd
				ra_fifo_wr_cmd<=LAD(0);
				when X"00e" => -- ram inout port cmd
				rd_fifo_rd_cmd<=LAD(0);
----------------------- port 2 (10..13)
--				when X"010" => -- ram inout port cmd
----------------------- port 3 in (14..17)
				when X"014" => -- stream in port cmd
				mvp_in_port3_cmd<=LAD(0);
				when X"015" => -- stream in port data
				mvp_in_port3_data(31 downto 0)<=
					LAD(31 downto 0);
				when X"016" => -- stream in port bits
				mvp_in_port3_tail<=LAD(0);
				mvp_in_port3_enable<=LAD(1);
				mvp_in_port3_bk<=LAD(2);
----------------------- port 3 out (18..1b)
				when X"018" => -- stream out port cmd
				mvp_out_port3_cmd<=LAD(0);
----------------------- port 4 in (1c..1f)
				when X"01c" => -- scalar in port cmd
				mvp_scalar_in_port_array(0).cmd<=LAD(0); 
				mvp_scalar_in_port_array(0).bk<=LAD(1);
				when X"01d" => -- scalar in port data
				mvp_scalar_in_port_array(0).data(31 downto 0)<=LAD(31 downto 0);
----------------------- port 4 out (20..23)
				when X"020" => -- scalar out port cmd
				mvp_scalar_out_port_array(0).cmd<=LAD(0);
----------------------- port 5 in (24..27)
				when X"024" => -- scalar in port cmd
				mvp_scalar_in_port_array(1).cmd<=LAD(0); 
				mvp_scalar_in_port_array(1).bk<=LAD(1);
				when X"025" => -- scalar in port data
				mvp_scalar_in_port_array(1).data(31 downto 0)<=LAD(31 downto 0);
----------------------- port 5 out (28..2b)
				when X"028" => -- scalar out port cmd
				mvp_scalar_out_port_array(1).cmd<=LAD(0);
----------------------- port 6 in (2c..2f)
				when X"02c" => -- scalar in port cmd
				mvp_scalar_in_port_array(2).cmd<=LAD(0); 
				mvp_scalar_in_port_array(2).bk<=LAD(1);
				when X"02d" => -- scalar in port data
				mvp_scalar_in_port_array(2).data(31 downto 0)<=LAD(31 downto 0);
----------------------- port 6 out (30..33)
				when X"030" => -- scalar out port cmd
				mvp_scalar_out_port_array(2).cmd<=LAD(0);
----------------------- port 7 in (34..37)
				when X"034" => -- scalar in port cmd
				mvp_scalar_in_port_array(3).cmd<=LAD(0); 
				mvp_scalar_in_port_array(3).bk<=LAD(1);
				when X"035" => -- scalar in port data
				mvp_scalar_in_port_array(3).data(31 downto 0)<=LAD(31 downto 0);
----------------------- port 7 out (38..3b)
				when X"038" => -- scalar out port cmd
				mvp_scalar_out_port_array(3).cmd<=LAD(0);
----------------------- port 8 in (3c..3f)
				when X"03c" => -- scalar in port cmd
				mvp_scalar_in_port_array(4).cmd<=LAD(0); 
				mvp_scalar_in_port_array(4).bk<=LAD(1);
				when X"03d" => -- scalar in port data
				mvp_scalar_in_port_array(4).data(31 downto 0)<=LAD(31 downto 0);
----------------------- port 8 out (40..43)
				when X"040" => -- scalar out port cmd
				mvp_scalar_out_port_array(4).cmd<=LAD(0);
----------------------- port 9 in (44..47)
				when X"044" => -- scalar in port cmd
				mvp_scalar_in_port_array(5).cmd<=LAD(0); 
				mvp_scalar_in_port_array(5).bk<=LAD(1);
				when X"045" => -- scalar in port data
				mvp_scalar_in_port_array(5).data(31 downto 0)<=LAD(31 downto 0);
----------------------- port 9 out (48..4b)
				when X"048" => -- scalar out port cmd
				mvp_scalar_out_port_array(5).cmd<=LAD(0);
----------------------- port 10 in (4c..4f)
				when X"04c" => -- scalar in port cmd
				mvp_scalar_in_port_array(6).cmd<=LAD(0); 
				mvp_scalar_in_port_array(6).bk<=LAD(1);
				when X"04d" => -- scalar in port data
				mvp_scalar_in_port_array(6).data(31 downto 0)<=LAD(31 downto 0);
----------------------- port 10 out (50..53)
				when X"050" => -- scalar out port cmd
				mvp_scalar_out_port_array(6).cmd<=LAD(0);
----------------------- port 11 in (54..57)
				when X"054" => -- scalar in port cmd
				mvp_scalar_in_port_array(7).cmd<=LAD(0); 
				mvp_scalar_in_port_array(7).bk<=LAD(1);
				when X"055" => -- scalar in port data
				mvp_scalar_in_port_array(7).data(31 downto 0)<=LAD(31 downto 0);
----------------------- port 11 out (58..5b)
				when X"058" => -- scalar out port cmd
				mvp_scalar_out_port_array(7).cmd<=LAD(0);
				
--				when X"100" =>
--               	bram0_addra(awa-1 downto 0) <= LAD(awa-1 downto 0);
				when X"101" =>
               	bram1_addra(awb-1 downto 0) <= LAD(awb-1 downto 0);
				when X"102" =>
               	bram2_addra(awc-1 downto 0) <= LAD(awc-1 downto 0);
--				when X"103" =>
--               	bram0_dina(dwa-1 downto 0) <= LAD(dwa-1 downto 0);
				when X"104" =>
               	bram1_dina(dwb-1 downto 0) <= LAD(dwb-1 downto 0);
				when X"105" =>
               	bram2_dina(dwc-1 downto 0) <= LAD(dwc-1 downto 0);
--				when X"106" =>
--               	bram0_wea(0)<= LAD(0);
				when X"107" =>
               	bram1_wea(0)<= LAD(0);
				when X"108" =>
               	bram2_wea(0)<= LAD(0);
-----------------------------------------------				
				when others => INDATA <= LAD;	
				end case;
--			when "0001"=> -- (8K of 32-bit words)
----------------------- bram 0
--              bram0_addra(awa-1 downto 0) <= SADDR(15 downto 2);
--	        bram0_dina(31 downto 0) <= LAD(31 downto 0);
--              bram0_wea(0)<= '1';
			when "0010"=> -- (8K of 32-bit words)
----------------------- bram 1
	        bram1_addra(awb-1 downto 0) <= SADDR(15 downto 2);
		bram1_dina(31 downto 0) <= LAD(31 downto 0);
                bram1_wea(0)<= '1';
			when "0011"=> -- (8K of 32-bit words)
----------------------- bram 2
                bram2_addra(awc-1 downto 0) <= SADDR(15 downto 2);
                bram2_dina(31 downto 0) <= LAD(31 downto 0);
                bram2_wea(0)<= '1';
			when others =>
				INDATA <= LAD;	
			end case; -- case SADDR(19 downto 16)
		else -- if RNW = '1' 
----------------------- READ
			case SADDR(19 downto 16) is
			when "0000" =>  -- (8K of 32-bit words)
				case SADDR(13 downto 2) is
----------------------- boot (0..3)
				when X"000" => -- boot reg0
				LAD(31 downto 0)<=
					boot0_reg(31 downto 0);
				when X"001" => -- boot reg1
				LAD(31 downto 0)<=
					boot1_reg(31 downto 0);
				when X"002" => -- ctrl status
					LAD(31 downto 0)<=npi_status3;
----------------------- ctrl (4..7)
				when X"004" => -- ctrl status
					LAD(31 downto 0)<=X"0000000"& "000" & mvp_ctrl_status;
				when X"005" => -- ctrl status
					LAD(31 downto 0)<=npi_status;
				when X"006" => -- ctrl status
					LAD(31 downto 0)<=npi_status2;
				when X"007" => -- ctrl status
					LAD(31 downto 0)<=npi_RData;
----------------------- port 0 (8..b)
				when X"008" =>  -- ram inout port status
					LAD(31 downto 0)<=X"0000000"& "0" & mvp_port0_farewell_handshaking & mvp_port0_initial_handshaking & mvp_port0_status;
				when X"009" =>  -- ram inout port reserved
					LAD(31 downto 0)<=npi_Addr;
				when X"00a" =>  -- ram inout port reserved
					LAD(31 downto 0)<=npi_Addr2;
				when X"00b" =>  -- ram inout port reserved
					LAD(31 downto 0)<=npi_WData2;
----------------------- port 1 (c..f)
				when X"00c" =>  -- ram inout port status
					LAD(31 downto 0)<=X"0000000"& "0" & mvp_port1_farewell_handshaking & mvp_port1_initial_handshaking & mvp_port1_status;
				when X"00d" =>  -- ram inout reserved
					LAD(31 downto 0)<=mvp_port1_data;
				when X"00e" =>  -- ram inout reserved
					LAD(31 downto 0)<=mvp_port0_data;
				when X"00f" =>  -- ram inout reserved
					LAD(31 downto 0)<=rd_fifo_rd_data;
----------------------- port 2 (10..13)
				when X"010" =>  -- ram inout port status
					LAD(31 downto 0)<=X"0000000"& "0" & mvp_port2_farewell_handshaking & mvp_port2_initial_handshaking & mvp_port2_status;
				when X"011" =>  -- ram inout reserved
					LAD(31 downto 0)<=mvp_port2_data;
				when X"012" =>  -- ram inout reserved
					LAD(31 downto 0)<=ra_fifo_wr_data;
----------------------- port 3 in (14..17)
				when X"014" =>  -- stream in port status
					LAD(31 downto 0)<=X"0000000"& mvp_in_port3_enable & mvp_in_port3_tail & mvp_in_port3_wt & mvp_in_port3_status;
				when X"015" =>  -- stream in port reserved
					LAD(31 downto 0)<=mvp_in_port3_data;
----------------------- port 3 out (18..1b)
				when X"018" =>  -- stream out port status
					LAD(31 downto 0)<=X"0000000"& '0' & mvp_out_port3_enable & mvp_out_port3_tail & mvp_out_port3_status;
				when X"019" =>  -- stream out port data
					LAD(31 downto 0)<=mvp_out_port3_data;
----------------------- port 4 in (1c..1f)
				when X"01c" =>  -- scalar in port status
					LAD(31 downto 0)<=X"0000000" & "00" & mvp_scalar_in_port_array(0).wt & mvp_scalar_in_port_array(0).status;
				when X"01d" =>  -- scalar in port reserved
					LAD(31 downto 0)<=mvp_scalar_in_port_array(0).data;
----------------------- port 4 out (20..23)
				when X"020" =>  -- scalar out port status
					LAD(31 downto 0)<=X"0000000" & "000" & mvp_scalar_out_port_array(0).status;
				when X"021" =>  -- scalar out port data
					LAD(31 downto 0)<=mvp_scalar_out_port_array(0).data;
----------------------- port 5 in (24..27)
				when X"024" =>  -- scalar in port status
					LAD(31 downto 0)<=X"0000000" & "00" & mvp_scalar_in_port_array(1).wt & mvp_scalar_in_port_array(1).status;
				when X"025" =>  -- scalar in port reserved
					LAD(31 downto 0)<=mvp_scalar_in_port_array(1).data;
----------------------- port 5 out (28..2b)
				when X"028" =>  -- scalar out port status
					LAD(31 downto 0)<=X"0000000" & "000" & mvp_scalar_out_port_array(1).status;
				when X"029" =>  -- scalar out port data
					LAD(31 downto 0)<=mvp_scalar_out_port_array(1).data;
----------------------- port 6 in (2c..2f)
				when X"02c" =>  -- scalar in port status
					LAD(31 downto 0)<=X"0000000" & "00" & mvp_scalar_in_port_array(2).wt & mvp_scalar_in_port_array(2).status;
				when X"02d" =>  -- scalar in port reserved
					LAD(31 downto 0)<=mvp_scalar_in_port_array(2).data;
----------------------- port 6 out (30..33)
				when X"030" =>  -- scalar out port status
					LAD(31 downto 0)<=X"0000000" & "000" & mvp_scalar_out_port_array(2).status;
				when X"031" =>  -- scalar out port data
					LAD(31 downto 0)<=mvp_scalar_out_port_array(2).data;
----------------------- port 7 in (34..37)
				when X"034" =>  -- scalar in port status
					LAD(31 downto 0)<=X"0000000" & "00" & mvp_scalar_in_port_array(3).wt & mvp_scalar_in_port_array(3).status;
				when X"035" =>  -- scalar in port reserved
					LAD(31 downto 0)<=mvp_scalar_in_port_array(3).data;
----------------------- port 7 out (38..3b)
				when X"038" =>  -- scalar out port status
					LAD(31 downto 0)<=X"0000000" & "000" & mvp_scalar_out_port_array(3).status;
				when X"039" =>  -- scalar out port data
					LAD(31 downto 0)<=mvp_scalar_out_port_array(3).data;
----------------------- port 8 in (3c..3f)
				when X"03c" =>  -- scalar in port status
					LAD(31 downto 0)<=X"0000000" & "00" & mvp_scalar_in_port_array(4).wt & mvp_scalar_in_port_array(4).status;
				when X"03d" =>  -- scalar in port reserved
					LAD(31 downto 0)<=mvp_scalar_in_port_array(4).data;
----------------------- port 8 out (40..43)
				when X"040" =>  -- scalar out port status
					LAD(31 downto 0)<=X"0000000" & "000" & mvp_scalar_out_port_array(4).status;
				when X"041" =>  -- scalar out port data
					LAD(31 downto 0)<=mvp_scalar_out_port_array(4).data;
----------------------- port 9 in (44..47)
				when X"044" =>  -- scalar in port status
					LAD(31 downto 0)<=X"0000000" & "00" & mvp_scalar_in_port_array(5).wt & mvp_scalar_in_port_array(5).status;
				when X"045" =>  -- scalar in port reserved
					LAD(31 downto 0)<=mvp_scalar_in_port_array(5).data;
----------------------- port 9 out (48..4b)
				when X"048" =>  -- scalar out port status
					LAD(31 downto 0)<=X"0000000" & "000" & mvp_scalar_out_port_array(5).status;
				when X"049" =>  -- scalar out port data
					LAD(31 downto 0)<=mvp_scalar_out_port_array(5).data;
----------------------- port 10 in (4c..4f)
				when X"04c" =>  -- scalar in port status
					LAD(31 downto 0)<=X"0000000" & "00" & mvp_scalar_in_port_array(6).wt & mvp_scalar_in_port_array(6).status;
				when X"04d" =>  -- scalar in port reserved
					LAD(31 downto 0)<=mvp_scalar_in_port_array(6).data;
----------------------- port 10 out (50..53)
				when X"050" =>  -- scalar out port status
					LAD(31 downto 0)<=X"0000000" & "000" & mvp_scalar_out_port_array(6).status;
				when X"051" =>  -- scalar out port data
					LAD(31 downto 0)<=mvp_scalar_out_port_array(6).data;
----------------------- port 11 in (54..57)
				when X"054" =>  -- scalar in port status
					LAD(31 downto 0)<=X"0000000" & "00" & mvp_scalar_in_port_array(7).wt & mvp_scalar_in_port_array(7).status;
				when X"055" =>  -- scalar in port reserved
					LAD(31 downto 0)<=mvp_scalar_in_port_array(7).data;
----------------------- port 11 out (58..5b)
				when X"058" =>  -- scalar out port status
					LAD(31 downto 0)<=X"0000000" & "000" & mvp_scalar_out_port_array(7).status;
				when X"059" =>  -- scalar out port data
					LAD(31 downto 0)<=mvp_scalar_out_port_array(7).data;
----------------------- port brams out (100..)					
--				when X"100" => 
--					LAD(31 downto 0)<=X"0000" & "00" & bram0_addra;
				when X"101" => 
					LAD(31 downto 0)<=X"0000" & "00" & bram1_addra;
				when X"102" => 
					LAD(31 downto 0)<=X"0000" & "00" & bram2_addra;
--				when X"103" =>  -- scalar out port data
--					LAD(31 downto 0)<=bram0_dina;
				when X"104" => 
					LAD(31 downto 0)<=bram1_dina;
				when X"105" => 
					LAD(31 downto 0)<=bram2_dina;
--				when X"106" => 
--					LAD(31 downto 0)<=bram0_douta;
				when X"107" => 
					LAD(31 downto 0)<=bram1_douta;
				when X"108" => 
					LAD(31 downto 0)<=bram2_douta;
					
				when others => LAD(31 downto 0)<=(others => '1');
				end case; -- case index1
--			when "0001" =>	-- (8K of 32-bit words)		
----------------------- bram 0 (4000
--				bram0_addra(awa-1 downto 0) <= SADDR(15 downto 2);
--				LAD(31 downto 0) <= bram0_douta;
--				LAD(31 downto 0)<=(others => '1');
            when "0010" =>	-- (8K of 32-bit words)
----------------------- bram 1 (8000
				bram1_addra(awb-1 downto 0) <= SADDR(15 downto 2);
				LAD(31 downto 0) <= bram1_douta(31 downto 0);
			when "0011" =>	
----------------------- bram 2 (c000
				bram2_addra(awc-1 downto 0) <= SADDR(15 downto 2);
				LAD(31 downto 0) <= bram2_douta(31 downto 0);
			when "0100" =>	
				LAD(31 downto 0)<=(others => '1');	
			LAD(31 downto 0)<=(others => '1');
 			when others =>
			LAD(31 downto 0)<=(others => '1');
			end case; -- case SADDR(19 downto 16)
		end if; -- if RNW = '1' then
	else -- if SADDR(20)= '0' 
-- FPGA to Z-STATE
		LAD <= "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
	end if; -- if SADDR(20)= '0'
else -- elsif LDAT = '1' 
-- EOF WRITE READ PGASE
LAD <= "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
LCBE <= "ZZZZZZZZ";
end if;-- elsif LDAT = '1' 
end if;-- if LADD = '1'
end process LB_SUPERVISOR;

LOCALREADY: IOBUF port map (I => LREADY_I, O => LREADY_O, IO => LREADY, T => LREADY_T );
LREADY_T <= '0' when (FPGAS = '1') else '1';

LREADY_FORM:
process (CLK)
begin
	if CLK = '1' and CLK'event then 
		if LDAT = '1' and FPGAS = '1' then
			L_READY <= '0';
		else
			L_READY <= '1';
		end if;
		L_READY_D <=L_READY;
--		L_READY_D2 <= L_READY_D;
		LREADY_I <= L_READY_D;		
	end if;
end process LREADY_FORM;

CLK_COUNTER_PROCESS:
process (CLK,RST)
begin
if RST = '1' then
clk_counter <= (others => '0');
elsif CLK = '1' and CLK'event then	-- PROCESS
clk_counter <= clk_counter + 1;
LEDS(1)<=clk_counter(24); -- 33 MHz
end if;
end process;

sys_clk_s_COUNTER_PROCESS:
process (sys_clk_s_pin,RST)
begin
if RST = '1' then
sys_clk_counter <= (others => '0');
elsif sys_clk_s_pin = '1' and sys_clk_s_pin'event then	-- PROCESS
LEDS(0)<=sys_clk_counter(24); -- 100 MHz
sys_clk_counter <= sys_clk_counter + 1;
end if;
end process;

clk_200MHz_counter_COUNTER_PROCESS:
process (clk_200MHz_pin,RST)
begin
if RST = '1' then
clk_200MHz_counter <= (others => '0');
elsif clk_200MHz_pin = '1' and clk_200MHz_pin'event then	-- PROCESS
clk_200MHz_counter <= clk_200MHz_counter + 1;
end if;
end process;

CLK2X_COUNTER_PROCESS:
process (CLK2X,RST)
begin
if RST = '1' then
clk2x_counter <= (others => '0');
elsif CLK2X = '1' and CLK2X'event then	-- PROCESS
clk2x_counter <= clk2x_counter + 1;
LEDS(2)<=clk2x_counter(24);-- 100 MHz
end if;
end process;

end rsp517_rtl;
