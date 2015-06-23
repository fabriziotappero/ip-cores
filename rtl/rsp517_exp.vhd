--------------------------------------------------------------------------
-- 
-- Title        :   RSP-517 Mitrion platform support
-- Platform     :   Platform is rsp517-vlx160 (ROSTA RSP-517 V4VLX160)
-- Design       :   external memory interface cores design module
-- Project      :   rsp517_mitrion 
-- Package      :   rsp517_exp
-- Author       :   Alexey Shmatok <alexey.shmatok@gmail.com>
-- Company      :   Rosta Ltd, www.rosta.ru
-- 
--------------------------------------------------------------------------
--
-- Description  :  This library module provides interface cores for
--		   Host to DDR & MVP to DDR Cores
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

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.ctrl_types.all;
package rsp517_exp is
--------------------------------------------------------------------------
-- Component        : my_host_npi_rd_fifo
-- Description      : Host read data from MPMC port (NPI) 
--------------------------------------------------------------------------
component my_host_npi_rd_fifo is
generic(
aw : integer := 32;
dw : integer := 32
);
port(
CLK0 : in std_logic;
RST : in std_logic;
ra_fifo_wr_cmd   : in std_logic;
ra_fifo_wr_data : in std_logic_vector (aw-1 downto 0);
rd_fifo_rd_cmd   : in std_logic;
rd_fifo_rd_data : out std_logic_vector (dw-1 downto 0);
NPI_InitDone: in std_logic;
NPI_Addr : out std_logic_vector(aw-1 downto 0);
NPI_AddrReq : out std_logic;
NPI_AddrAck : in std_logic;
NPI_RNW : out std_logic;
NPI_Size : out std_logic_vector(3 downto 0);
NPI_WrFIFO_Data : out std_logic_vector(dw-1 downto 0);
NPI_WrFIFO_BE : out std_logic_vector(3 downto 0);
NPI_WrFIFO_Push : out std_logic;
NPI_WrFIFO_Empty: in std_logic;
NPI_WrFIFO_AlmostFull: in std_logic;
NPI_WrFIFO_Flush: out std_logic;
NPI_RdFIFO_Data : in std_logic_vector(dw-1 downto 0);
NPI_RdFIFO_Pop : out std_logic;
NPI_RdFIFO_RdWdAddr: in std_logic_vector(3 downto 0);
NPI_RdFIFO_Empty: in std_logic;
NPI_RdFIFO_Flush: out std_logic;
NPI_RdFIFO_Latency: in std_logic_vector(1 downto 0);
NPI_RdModWr: out std_logic;
--LED: out std_logic;
cmd:  in std_logic;
data: out std_logic_vector(31 downto 0);
status:  out std_logic_vector(31 downto 0);
counter1 : out std_logic_vector(31 downto 0);
counter2 : out std_logic_vector(31 downto 0)
);
end component;
--------------------------------------------------------------------------
-- Component        : my_host_npi_we
-- Description      : Host write data to MPMC port (NPI) 
--------------------------------------------------------------------------
component my_host_npi_we is
generic(
aw : integer := 32;
dw : integer := 32
);
port(
CLK0 : in std_logic;
RST : in std_logic;
RE     : in std_logic;
Addr  : in std_logic_vector(aw-1 downto 0);
RData  : out  std_logic_vector(dw-1 downto 0);
RAck : out std_logic;
WE     : in std_logic;
WData  : in std_logic_vector(dw-1 downto 0);
NPI_Addr : out std_logic_vector(aw-1 downto 0);
NPI_AddrReq : out std_logic;
NPI_AddrAck : in std_logic;
NPI_RNW : out std_logic;
NPI_Size : out std_logic_vector(3 downto 0);
NPI_WrFIFO_Data : out std_logic_vector(dw-1 downto 0);
NPI_WrFIFO_BE : out std_logic_vector(3 downto 0);
NPI_WrFIFO_Push : out std_logic;
NPI_RdFIFO_Data : in std_logic_vector(dw-1 downto 0);
NPI_RdFIFO_Pop : out std_logic;
NPI_RdFIFO_RdWdAddr: in std_logic_vector(3 downto 0);
NPI_WrFIFO_Empty: in std_logic;
NPI_WrFIFO_AlmostFull: in std_logic;
NPI_WrFIFO_Flush: out std_logic;
NPI_RdFIFO_Empty: in std_logic;
NPI_RdFIFO_Flush: out std_logic;
NPI_RdFIFO_Latency: in std_logic_vector(1 downto 0);
NPI_RdModWr: out std_logic;
NPI_InitDone: in std_logic;
--LED: out std_logic;
cmd:  in std_logic;
data: out std_logic_vector(31 downto 0);
status:  out std_logic_vector(31 downto 0);
counter1 : out std_logic_vector(31 downto 0);
counter2 : out std_logic_vector(31 downto 0)
);
end component;
--------------------------------------------------------------------------
-- Component        : my_mvp_npi_rw_fifo
-- Description      : MVP read/write data to MPMC, one port for read (NPI), one port for write (NPI)
--------------------------------------------------------------------------
component my_mvp_npi_rw_fifo is
generic(
rd_fifo_depth : natural:=32;
wr_fifo_depth : natural:=32;
aw : integer := 32;
dw : integer := 32
);
port(
mvp_clk : in std_logic;
RST : in std_logic;
-- mvp
  Din:  out std_logic_vector(0 downto 0);
  Vin:  out std_logic;
  Cin:  in std_logic;
  Dout:  in std_logic_vector(0 downto 0);
  Vout:  in std_logic;
  Cout:  out std_logic;
  RE     : in std_logic;
  RAck   : out std_logic;
  RAddr  : in std_logic_vector(aw-1 downto 0);
  RData  : out  std_logic_vector(dw-1 downto 0);
  RStall : out  std_logic;
  WE     : in std_logic;
  WAddr  : in std_logic_vector(aw-1 downto 0);
  WData  : in std_logic_vector(dw-1 downto 0);
  WStall : out  std_logic;
-- npi rd port
RD_NPI_InitDone: in std_logic;
RD_NPI_Addr : out std_logic_vector(aw-1 downto 0);
RD_NPI_AddrReq : out std_logic;
RD_NPI_AddrAck : in std_logic;
RD_NPI_RNW : out std_logic;
RD_NPI_Size : out std_logic_vector(3 downto 0);
RD_NPI_WrFIFO_Data : out std_logic_vector(dw-1 downto 0);
RD_NPI_WrFIFO_BE : out std_logic_vector(3 downto 0);
RD_NPI_WrFIFO_Push : out std_logic;
RD_NPI_WrFIFO_Empty: in std_logic;
RD_NPI_WrFIFO_AlmostFull: in std_logic;
RD_NPI_WrFIFO_Flush: out std_logic;
RD_NPI_RdFIFO_Data : in std_logic_vector(dw-1 downto 0);
RD_NPI_RdFIFO_Pop : out std_logic;
RD_NPI_RdFIFO_RdWdAddr: in std_logic_vector(3 downto 0);
RD_NPI_RdFIFO_Empty: in std_logic;
RD_NPI_RdFIFO_Flush: out std_logic;
RD_NPI_RdFIFO_Latency: in std_logic_vector(1 downto 0);
RD_NPI_RdModWr: out std_logic;
-- npi wr port
WR_NPI_InitDone: in std_logic;
WR_NPI_Addr : out std_logic_vector(aw-1 downto 0);
WR_NPI_AddrReq : out std_logic;
WR_NPI_AddrAck : in std_logic;
WR_NPI_RNW : out std_logic;
WR_NPI_Size : out std_logic_vector(3 downto 0);
WR_NPI_WrFIFO_Data : out std_logic_vector(dw-1 downto 0);
WR_NPI_WrFIFO_BE : out std_logic_vector(3 downto 0);
WR_NPI_WrFIFO_Push : out std_logic;
WR_NPI_WrFIFO_Empty: in std_logic;
WR_NPI_WrFIFO_AlmostFull: in std_logic;
WR_NPI_WrFIFO_Flush: out std_logic;
WR_NPI_RdFIFO_Data : in std_logic_vector(dw-1 downto 0);
WR_NPI_RdFIFO_Pop : out std_logic;
WR_NPI_RdFIFO_RdWdAddr: in std_logic_vector(3 downto 0);
WR_NPI_RdFIFO_Empty: in std_logic;
WR_NPI_RdFIFO_Flush: out std_logic;
WR_NPI_RdFIFO_Latency: in std_logic_vector(1 downto 0);
WR_NPI_RdModWr: out std_logic;
  -- ctrl
  cmd:  in std_logic;
  status:  out std_logic;
  initial_handshaking : out std_logic;
  farewell_handshaking: out std_logic;
  rcnt:  out std_logic_vector(15 downto 0);
  wcnt:  out std_logic_vector(15 downto 0);
  -- dbg
--LED: out std_logic;
npi_status:  out std_logic_vector(31 downto 0);
counter1 : out std_logic_vector(31 downto 0);
counter2 : out std_logic_vector(31 downto 0)
);
end component;
end package;
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.ctrl_types.all;
package rsp517_exp2 is
component liquid_srl2 is
    generic (data_bits  :integer;
             length  :integer);
  port ( clk      : in std_logic;
         en       : in boolean;
         inData   : in std_logic_vector((data_bits-1) downto 0);
         outStage : in integer range (length-1) downto 0;
         outData  : out std_logic_vector((data_bits-1) downto 0)
         );
end component;
component liquid_smallfifo2 is
    generic (data_bits  : integer;
             length     : integer);
  port ( clk      : in std_logic;
         rst    : in std_logic;
         wr_en    : in std_logic;
         wr_data  : in std_logic_vector((data_bits-1) downto 0);
         rd_en    : in std_logic;
         rd_data  : out std_logic_vector((data_bits-1) downto 0);
         empty    : out std_logic;
		 full    : out std_logic		 
         );
end component;
end package;
Library IEEE;
Use IEEE.std_logic_1164.ALL;
entity srl_vector2 is
 generic (data_bits : integer := 16);
 port (CLK, CE : in std_logic;
    D : in std_logic_vector(data_bits-1 downto 0);
    A : in std_logic_vector(3 downto 0);
    Q, Q15 : out std_logic_vector(data_bits-1 downto 0));
end entity;
architecture rtl of srl_vector2 is
component SRLC16E is
 port(
  Q : out std_logic;
  Q15 : out std_logic;
  A0 : in std_logic;
  A1 : in std_logic;
  A2 : in std_logic;
  A3 : in std_logic;
  CE : in std_logic;
  CLK : in std_logic;
  D : in std_logic);
end component;
begin
 srl16_primitives : for i in D'RANGE generate
 begin
  SRL_i : SRLC16E port map(Q(i), Q15(i), A(0), A(1), A(2), A(3), CE, CLK, D(i));
 end generate;
end architecture rtl;
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.ALL;
entity liquid_srl2 is
    generic (data_bits  :integer;
             length  :integer);
  port ( clk      : in std_logic;
         en       : in boolean;
         inData   : in std_logic_vector((data_bits-1) downto 0);
         outStage : in integer range (length-1) downto 0;
         outData  : out std_logic_vector((data_bits-1) downto 0)
);
end liquid_srl2;
architecture rtl of liquid_srl2 is
component srl_vector2 is
 generic (data_bits : integer := data_bits);
 port (CLK, CE : in std_logic;
    D : in std_logic_vector(data_bits-1 downto 0);
    A : in std_logic_vector(3 downto 0);
    Q, Q15 : out std_logic_vector(data_bits-1 downto 0));
end component;
constant noOfSRLs : integer := (length+15)/16;
type dataArrayType is array(noOfSRLs-1 downto 0) of std_logic_vector((data_bits-1) downto 0);
signal Q, Q15 : dataArrayType;
signal A : std_logic_vector(15 downto 0);
signal en_std : std_logic;
begin
  A <= CONV_STD_LOGIC_VECTOR(outStage, 16);
 en_std <= '1' when en else '0';
 srl0 : srl_vector2 port map(clk, en_std, inData, A(3 downto 0), Q(0), Q15(0));
 cascaded_SRLs : for i in 1 to noOfSRLs-1 generate
 begin
  srl_i : srl_vector2 port map(clk, en_std, Q15(i-1), A(3 downto 0), Q(i), Q15(i));
 end generate;
 outData <= Q(outStage/16);
end rtl;
library IEEE;
use IEEE.std_logic_1164.all;
entity liquid_smallfifo2 is
    generic (data_bits  : integer;
             length     : integer);
  port ( clk      : in std_logic;
         rst      : in std_logic;
         wr_en    : in std_logic;
         wr_data  : in std_logic_vector(data_bits-1 downto 0);
         rd_en    : in std_logic;
         rd_data  : out std_logic_vector(data_bits-1 downto 0);
         empty    : out std_logic;
		 full    : out std_logic
         );
end liquid_smallfifo2;
architecture rtl of liquid_smallfifo2 is
  component liquid_srl2 is
    generic (data_bits  :integer;
             length  :integer);
  port ( clk      : in std_logic;
         en       : in boolean;
         inData   : in std_logic_vector((data_bits-1) downto 0);
         outStage : in integer range (length-1) downto 0;
         outData  : out std_logic_vector((data_bits-1) downto 0)
  );
  end component;
  signal elements   : integer range (length-1) downto 0;
  signal addr       : integer range (length-1) downto 0;
  signal wr_en_bool : boolean;
begin
  wr_en_bool <= wr_en = '1';
  addr <= 0 when elements = 0 else elements - 1;
  nisse : liquid_srl2
    generic map(data_bits => data_bits, length => length)
    port map(clk, en => wr_en_bool , inData => wr_data, outStage => addr, outData => rd_data);
  empty <= '1' when elements = 0 else '0';
  full <= '1' when elements >= (length - 2 ) else '0';
  process (clk)
     variable els : integer range (length-1) downto 0;
  begin
    if clk'event and clk='1' then
      if rst = '1' then
        elements <= 0;
      else
        els := elements;
        if wr_en = '1' and els < length then
          els := els + 1;
        end if;
        if rd_en = '1' and els > 0 then
          els := els - 1;
        end if;
        elements <= els;
      end if;
    end if;
  end process;
end rtl;
LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
library work;
use work.ctrl_types.all;
use work.rsp517_pack.all;
use work.rsp517_exp.all;
use work.rsp517_exp2.all;
entity my_host_npi_rd_fifo is
generic(
fifo_depth : natural:=128;
aw : integer := 32;
dw : integer := 32
);
port(
CLK0 : in std_logic;
RST : in std_logic;
ra_fifo_wr_cmd   : in std_logic;
ra_fifo_wr_data : in std_logic_vector (aw-1 downto 0);
rd_fifo_rd_cmd   : in std_logic;
rd_fifo_rd_data : out std_logic_vector (dw-1 downto 0);
NPI_InitDone: in std_logic;
NPI_Addr : out std_logic_vector(aw-1 downto 0);
NPI_AddrReq : out std_logic;
NPI_AddrAck : in std_logic;
NPI_RNW : out std_logic;
NPI_Size : out std_logic_vector(3 downto 0);
NPI_WrFIFO_Data : out std_logic_vector(dw-1 downto 0);
NPI_WrFIFO_BE : out std_logic_vector(3 downto 0);
NPI_WrFIFO_Push : out std_logic;
NPI_WrFIFO_Empty: in std_logic;
NPI_WrFIFO_AlmostFull: in std_logic;
NPI_WrFIFO_Flush: out std_logic;
NPI_RdFIFO_Data : in std_logic_vector(dw-1 downto 0);
NPI_RdFIFO_Pop : out std_logic;
NPI_RdFIFO_RdWdAddr: in std_logic_vector(3 downto 0);
NPI_RdFIFO_Empty: in std_logic;
NPI_RdFIFO_Flush: out std_logic;
NPI_RdFIFO_Latency: in std_logic_vector(1 downto 0);
NPI_RdModWr: out std_logic;
--LED: out std_logic;
cmd:  in std_logic;
data: out std_logic_vector(31 downto 0);
status:  out std_logic_vector(31 downto 0);
counter1 : out std_logic_vector(31 downto 0);
counter2 : out std_logic_vector(31 downto 0)
);
end entity;
architecture arc_my_host_npi_rd_fifo OF my_host_npi_rd_fifo IS
signal NPI_RdFIFO_Empty_d : std_logic;
signal NPI_RdFIFO_Empty_d2 : std_logic;
signal NPI_AddrAck_d : std_logic;
shared variable ext_cmd : std_logic :='0';
shared variable int_cmd : std_logic :='0';
shared variable ext_cmd_ra : std_logic :='0';
shared variable int_cmd_ra : std_logic :='0';
shared variable ext_cmd_rd : std_logic :='0';
shared variable int_cmd_rd : std_logic :='0';
signal clk_counter : std_logic_vector(31 downto 0)   := X"00000000";
signal intcounter1 : std_logic_vector(31 downto 0)   := X"00000000";
signal intcounter2 : std_logic_vector(31 downto 0)   := X"00000000";
signal NPI_AddrReq_sent : std_logic :='1';
signal ra_fifo_wr_en   :std_logic;
signal ra_fifo_rd_en   :std_logic;
signal ra_fifo_rd_en_d   :std_logic;
signal ra_fifo_rd_en_d2   :std_logic;
signal ra_fifo_rd_data :std_logic_vector (aw-1 downto 0);
signal ra_fifo_count   :integer range fifo_depth downto 0;
signal ra_fifo_full    :std_logic;
signal ra_fifo_empty   :std_logic;
signal ra_fifo_empty_d   :std_logic;
signal ra_fifo_empty_d2   :std_logic;
signal rd_fifo_wr_en   :std_logic;
signal rd_fifo_wr_data :std_logic_vector (dw-1 downto 0);
signal rd_fifo_rd_en   :std_logic;
signal rd_fifo_rd_en_d   :std_logic;
signal rd_fifo_rd_en_d2   :std_logic;
signal rd_fifo_count   :integer range fifo_depth downto 0;
signal rd_fifo_full    :std_logic;
signal rd_fifo_empty   :std_logic;
signal rd_fifo_empty_d   :std_logic;
signal rd_fifo_empty_d2   :std_logic;
begin
Inst_mfifo_syncRa : liquid_smallfifo2
    generic map(data_bits=>aw, -- <read requests: address>
             length=>fifo_depth)
    port map(rst=>rst,
          clk=>CLK0,
          wr_en=>ra_fifo_wr_en,
          wr_data=>ra_fifo_wr_data,
          rd_en=>ra_fifo_rd_en,
          rd_data=>ra_fifo_rd_data,
          full=>ra_fifo_full,
          empty=>ra_fifo_empty
         );
		 
Inst_mfifo_syncRd : liquid_smallfifo2
    generic map(data_bits=>dw, -- <read requests: data>
             length=>fifo_depth)
    port map(rst=>rst,
          clk=>CLK0,
          wr_en=>rd_fifo_wr_en,
          wr_data=>rd_fifo_wr_data,
          rd_en=>rd_fifo_rd_en,
          rd_data=>rd_fifo_rd_data,
          full=>rd_fifo_full,
          empty=>rd_fifo_empty
         );
counter1<=intcounter1;
counter2<=intcounter2;
process (CLK0,RST)
begin
if RST = '1' then
clk_counter <= (others => '0');
elsif CLK0 = '1' and CLK0'event then	-- PROCESS
clk_counter <= clk_counter + 1;
end if;
end process;
cmd_process : process (cmd,rst)
begin
if rst = '1' then
 ext_cmd:='0';
elsif cmd = '1' and cmd'event then
 ext_cmd:=not ext_cmd;
end if;
end process;
cmd_process_ra : process (ra_fifo_wr_cmd,rst)
begin
if rst = '1' then
 ext_cmd_ra:='0';
elsif ra_fifo_wr_cmd = '1' and ra_fifo_wr_cmd'event then
 ext_cmd_ra:=not ext_cmd_ra;
end if;
end process;
cmd_process_rd : process (rd_fifo_rd_cmd,rst)
begin
if rst = '1' then
 ext_cmd_rd:='0';
elsif rd_fifo_rd_cmd = '1' and rd_fifo_rd_cmd'event then
 ext_cmd_rd:=not ext_cmd_rd;
end if;
end process;
core_process_ra : process (CLK0, rst)
begin
if rst = '1'  then	-- RESET
int_cmd_ra:='0';
elsif CLK0 = '1' and CLK0'event then
if int_cmd_ra /= ext_cmd_ra then 
int_cmd_ra := ext_cmd_ra;
ra_fifo_wr_en<='1';
else
ra_fifo_wr_en<='0';
end if; -- cmd
end if; -- elsif mvp_clk = '1' and mvp_clk'event
end process; -- core_process : process (mvp_clk, RST)
core_process_rd : process (CLK0, rst)
begin
if rst = '1'  then	-- RESET
int_cmd_rd:='0';
elsif CLK0 = '1' and CLK0'event then
if int_cmd_rd /= ext_cmd_rd then 
int_cmd_rd := ext_cmd_rd;
rd_fifo_rd_en<='1';
else
rd_fifo_rd_en<='0';
end if;--cmd
end if; -- elsif mvp_clk = '1' and mvp_clk'event
end process; -- core_process : process (mvp_clk, RST)
NPI_AddrReq <= not NPI_AddrReq_sent;
NPI_RdFIFO_Pop <= not NPI_RdFIFO_Empty;
core_process : process (CLK0, rst)
begin
if rst = '1'  then	-- RESET
int_cmd:='0';
status<=(others=>'0');
NPI_Addr<=(others=>'0');
NPI_RNW<='1';
NPI_Size<=(others=>'0');
NPI_WrFIFO_Data<=(others=>'0');
NPI_WrFIFO_BE<=(others=>'1');
NPI_WrFIFO_Push<='0';
NPI_WrFIFO_Flush<='0';
NPI_RdFIFO_Flush<='0';
NPI_RdModWr<='0';
NPI_AddrReq_sent <= '1';
elsif CLK0 = '1' and CLK0'event then
if int_cmd /= ext_cmd then 
int_cmd := ext_cmd;
NPI_Addr<=ra_fifo_rd_data;
ra_fifo_rd_en<='1';
NPI_AddrReq_sent <= '0';
status<=(others=>'0');
status(0)<='1';
else
ra_fifo_rd_en<='0';
status(1)<='1';
end if;
if NPI_AddrAck = '1' then
 intcounter2<=clk_counter;
 status(2)<='1';
 NPI_AddrReq_sent <= '1';
end if;
if NPI_RdFIFO_Latency = "00" and NPI_RdFIFO_Empty = '0' then
	rd_fifo_wr_data <= NPI_RdFIFO_Data;
	rd_fifo_wr_en  <= '1';
	status(4)<='1';
elsif NPI_RdFIFO_Latency = "01" and NPI_RdFIFO_Empty_d = '0' then
	rd_fifo_wr_data <= NPI_RdFIFO_Data;
	rd_fifo_wr_en  <= '1';
	status(5)<='1';
elsif NPI_RdFIFO_Latency = "10" and NPI_RdFIFO_Empty_d2 = '0' then
	rd_fifo_wr_data <= NPI_RdFIFO_Data;
	rd_fifo_wr_en  <= '1';
	status(6)<='1';
else
	rd_fifo_wr_en <= '0';
	status(7)<='1';
end if;
end if; -- elsif mvp_clk = '1' and mvp_clk'event
end process; -- core_process : process (mvp_clk, RST)
d_reg0 : d_reg  port map(CLK0, NPI_RdFIFO_Empty,NPI_RdFIFO_Empty_d);
d_reg1 : d_reg  port map(CLK0, NPI_RdFIFO_Empty_d,NPI_RdFIFO_Empty_d2);
end arc_my_host_npi_rd_fifo; 
LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
library work;
use work.ctrl_types.all;
use work.rsp517_pack.all;
use work.rsp517_exp.all;
use work.rsp517_exp2.all;
entity my_host_npi_we is
generic(
aw : integer := 32;
dw : integer := 32
);
port(
CLK0 : in std_logic;
RST : in std_logic;
RE     : in std_logic;
Addr  : in std_logic_vector(aw-1 downto 0);
RData  : out  std_logic_vector(dw-1 downto 0);
RAck : out std_logic;
WE     : in std_logic;
WData  : in std_logic_vector(dw-1 downto 0);

NPI_InitDone: in std_logic;
NPI_Addr : out std_logic_vector(aw-1 downto 0);
NPI_AddrReq : out std_logic;
NPI_AddrAck : in std_logic;
NPI_RNW : out std_logic;
NPI_Size : out std_logic_vector(3 downto 0);

NPI_WrFIFO_Data : out std_logic_vector(dw-1 downto 0);
NPI_WrFIFO_BE : out std_logic_vector(3 downto 0);
NPI_WrFIFO_Push : out std_logic;
NPI_WrFIFO_Empty: in std_logic;
NPI_WrFIFO_AlmostFull: in std_logic;
NPI_WrFIFO_Flush: out std_logic;

NPI_RdFIFO_Data : in std_logic_vector(dw-1 downto 0);
NPI_RdFIFO_Pop : out std_logic;
NPI_RdFIFO_RdWdAddr: in std_logic_vector(3 downto 0);
NPI_RdFIFO_Empty: in std_logic;
NPI_RdFIFO_Flush: out std_logic;
NPI_RdFIFO_Latency: in std_logic_vector(1 downto 0);
NPI_RdModWr: out std_logic;
--LED: out std_logic;
cmd:  in std_logic;
data: out std_logic_vector(31 downto 0);
status:  out std_logic_vector(31 downto 0);
counter1 : out std_logic_vector(31 downto 0);
counter2 : out std_logic_vector(31 downto 0)
);
end entity;
architecture arc_my_host_npi_we OF my_host_npi_we IS
signal NPI_AddrAck_d : std_logic;
shared variable ext_cmd : std_logic :='0';
shared variable int_cmd : std_logic :='0';
signal clk_counter : std_logic_vector(31 downto 0)   := X"00000000";
signal intcounter1 : std_logic_vector(31 downto 0)   := X"00000000";
signal intcounter2 : std_logic_vector(31 downto 0)   := X"00000000";
signal NPI_AddrReq_sent : std_logic :='1';
begin
counter1<=intcounter1;
counter2<=intcounter2;
process (CLK0,RST)
begin
if RST = '1' then
clk_counter <= (others => '0');
elsif CLK0 = '1' and CLK0'event then	-- PROCESS
clk_counter <= clk_counter + 1;
end if;
end process;
cmd_process : process (cmd,rst)
begin
if rst = '1' then
 ext_cmd:='0';
elsif cmd = '1' and cmd'event then
 ext_cmd:=not ext_cmd;
end if;
end process;
d_reg0 : d_reg  port map(CLK0, NPI_AddrAck,NPI_AddrAck_d);
NPI_AddrReq <= not NPI_AddrReq_sent;
core_process : process (CLK0, rst)
begin
if rst = '1'  then	-- RESET
status<=(others=>'0');
int_cmd:='0';
NPI_Addr<=(others=>'0');
NPI_RNW<='1';
NPI_Size<=(others=>'0');
NPI_WrFIFO_Data<=(others=>'0');
NPI_WrFIFO_BE<=(others=>'1');
NPI_WrFIFO_Push<='0';
NPI_WrFIFO_Flush<='0';
NPI_RdFIFO_Pop<='0';
NPI_RdFIFO_Flush<='0';
NPI_RdModWr<='0';
--LED<='0';
NPI_AddrReq_sent <= '1';
elsif CLK0 = '1' and CLK0'event then
NPI_Addr<=Addr;
NPI_WrFIFO_Data<=WData;
if int_cmd /= ext_cmd then 
int_cmd := ext_cmd;
status<=(others=>'0');
status(0)<='1';
NPI_RNW<='0';
NPI_RdModWr<='1';
intcounter1<=clk_counter;
NPI_AddrReq_sent<='0';
end if;
if NPI_AddrAck = '1' then
 NPI_AddrReq_sent <= '1';
 status(1)<='1';
 intcounter2<=clk_counter;
end if;
if NPI_AddrAck_d = '1' then
 NPI_WrFIFO_Push<='1';
-- LED<='1';
 status(2)<='1';
else
 NPI_WrFIFO_Push<='0'; 
 status(3)<='1';
end if;
end if;
end process;
end arc_my_host_npi_we; 
LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
library work;
use work.ctrl_types.all;
use work.rsp517_pack.all;
use work.rsp517_exp.all;
use work.rsp517_exp2.all;
entity my_mvp_npi_rw_fifo is
generic(
rd_fifo_depth : natural:=32;
wr_fifo_depth : natural:=32;
aw : integer := 32;
dw : integer := 32
);
port(
mvp_clk : in std_logic;
RST : in std_logic;
-- mvp
  Din:  out std_logic_vector(0 downto 0);
  Vin:  out std_logic;
  Cin:  in std_logic;
  Dout:  in std_logic_vector(0 downto 0);
  Vout:  in std_logic;
  Cout:  out std_logic;
  RE     : in std_logic;
  RAck   : out std_logic;
  RAddr  : in std_logic_vector(aw-1 downto 0);
  RData  : out  std_logic_vector(dw-1 downto 0);
  RStall : out  std_logic;
  WE     : in std_logic;
  WAddr  : in std_logic_vector(aw-1 downto 0);
  WData  : in std_logic_vector(dw-1 downto 0);
  WStall : out  std_logic;
-- npi rd port
RD_NPI_InitDone: in std_logic;
RD_NPI_Addr : out std_logic_vector(aw-1 downto 0);
RD_NPI_AddrReq : out std_logic;
RD_NPI_AddrAck : in std_logic;
RD_NPI_RNW : out std_logic;
RD_NPI_Size : out std_logic_vector(3 downto 0);
RD_NPI_WrFIFO_Data : out std_logic_vector(dw-1 downto 0);
RD_NPI_WrFIFO_BE : out std_logic_vector(3 downto 0);
RD_NPI_WrFIFO_Push : out std_logic;
RD_NPI_WrFIFO_Empty: in std_logic;
RD_NPI_WrFIFO_AlmostFull: in std_logic;
RD_NPI_WrFIFO_Flush: out std_logic;
RD_NPI_RdFIFO_Data : in std_logic_vector(dw-1 downto 0);
RD_NPI_RdFIFO_Pop : out std_logic;
RD_NPI_RdFIFO_RdWdAddr: in std_logic_vector(3 downto 0);
RD_NPI_RdFIFO_Empty: in std_logic;
RD_NPI_RdFIFO_Flush: out std_logic;
RD_NPI_RdFIFO_Latency: in std_logic_vector(1 downto 0);
RD_NPI_RdModWr: out std_logic;
-- npi wr port
WR_NPI_InitDone: in std_logic;
WR_NPI_Addr : out std_logic_vector(aw-1 downto 0);
WR_NPI_AddrReq : out std_logic;
WR_NPI_AddrAck : in std_logic;
WR_NPI_RNW : out std_logic;
WR_NPI_Size : out std_logic_vector(3 downto 0);
WR_NPI_WrFIFO_Data : out std_logic_vector(dw-1 downto 0);
WR_NPI_WrFIFO_BE : out std_logic_vector(3 downto 0);
WR_NPI_WrFIFO_Push : out std_logic;
WR_NPI_WrFIFO_Empty: in std_logic;
WR_NPI_WrFIFO_AlmostFull: in std_logic;
WR_NPI_WrFIFO_Flush: out std_logic;
WR_NPI_RdFIFO_Data : in std_logic_vector(dw-1 downto 0);
WR_NPI_RdFIFO_Pop : out std_logic;
WR_NPI_RdFIFO_RdWdAddr: in std_logic_vector(3 downto 0);
WR_NPI_RdFIFO_Empty: in std_logic;
WR_NPI_RdFIFO_Flush: out std_logic;
WR_NPI_RdFIFO_Latency: in std_logic_vector(1 downto 0);
WR_NPI_RdModWr: out std_logic;
  -- ctrl
  cmd:  in std_logic;
  status:  out std_logic;
  initial_handshaking : out std_logic;
  farewell_handshaking: out std_logic;
  rcnt:  out std_logic_vector(15 downto 0);
  wcnt:  out std_logic_vector(15 downto 0);
  -- dbg
--LED: out std_logic;
npi_status:  out std_logic_vector(31 downto 0);
counter1 : out std_logic_vector(31 downto 0);
counter2 : out std_logic_vector(31 downto 0)
);
end entity;
architecture arc_my_mvp_npi_rw_fifo OF my_mvp_npi_rw_fifo IS
signal Vin_sent : std_logic;
signal Vout_received: std_logic;
signal Init : std_logic;
signal RD_NPI_RdFIFO_Empty_d : std_logic;
signal RD_NPI_RdFIFO_Empty_d2 : std_logic;
signal RD_NPI_AddrAck_d : std_logic;
shared variable ext_cmd : std_logic :='0';
shared variable int_cmd : std_logic :='0';
shared variable ext_cmd_ra : std_logic :='0';
shared variable int_cmd_ra : std_logic :='0';
shared variable ext_cmd_rd : std_logic :='0';
shared variable int_cmd_rd : std_logic :='0';
signal clk_counter : std_logic_vector(31 downto 0)   := X"00000000";
signal intcounter1 : std_logic_vector(31 downto 0)   := X"00000000";
signal intcounter2 : std_logic_vector(31 downto 0)   := X"00000000";
signal RD_NPI_AddrReq_sent : std_logic :='1';
signal ra_fifo_wr_en   :std_logic;
signal ra_fifo_wr_data :std_logic_vector (aw-1 downto 0);
signal ra_fifo_rd_en   :std_logic;
signal ra_fifo_rd_en_d   :std_logic;
signal ra_fifo_rd_en_d2   :std_logic;
signal ra_fifo_rd_data :std_logic_vector (aw-1 downto 0);
signal ra_fifo_count   :integer range rd_fifo_depth downto 0;
signal ra_fifo_full    :std_logic;
signal ra_fifo_empty   :std_logic;
signal ra_fifo_empty_d   :std_logic;
signal ra_fifo_empty_d2   :std_logic;
signal rd_fifo_wr_en   :std_logic;
signal rd_fifo_wr_data :std_logic_vector (dw-1 downto 0);
signal rd_fifo_rd_en   :std_logic;
signal rd_fifo_rd_en_d   :std_logic;
signal rd_fifo_rd_en_d2   :std_logic;
signal rd_fifo_rd_data :std_logic_vector (dw-1 downto 0);
signal rd_fifo_count   :integer range rd_fifo_depth downto 0;
signal rd_fifo_full    :std_logic;
signal rd_fifo_empty   :std_logic;
signal rd_fifo_empty_d   :std_logic;
signal rd_fifo_empty_d2   :std_logic;
signal int_ra_cmd_busy   :std_logic;
signal int_ra_cmd_busy_d   :std_logic;
signal int_ra_cmd_busy_d2   :std_logic;
signal ext_ra_cmd   :std_logic;
signal  int_rcnt:   std_logic_vector(15 downto 0);
signal  int_wcnt:   std_logic_vector(15 downto 0);
signal busy_counter : std_logic_vector(3 downto 0)   := X"0";
signal WR_NPI_AddrReq_sent : std_logic :='1';
signal WR_NPI_AddrAck_d : std_logic;
signal wa_fifo_wr_en   :std_logic;
signal wa_fifo_wr_data :std_logic_vector (aw-1 downto 0);
signal wa_fifo_rd_en   :std_logic;
signal wa_fifo_rd_en_d   :std_logic;
signal wa_fifo_rd_en_d2   :std_logic;
signal wa_fifo_rd_data :std_logic_vector (aw-1 downto 0);
signal wa_fifo_count   :integer range rd_fifo_depth downto 0;
signal wa_fifo_full    :std_logic;
signal wa_fifo_empty   :std_logic;
signal wa_fifo_empty_d   :std_logic;
signal wa_fifo_empty_d2   :std_logic;
signal wd_fifo_wr_en   :std_logic;
signal wd_fifo_wr_data :std_logic_vector (dw-1 downto 0);
signal wd_fifo_rd_en   :std_logic;
signal wd_fifo_rd_en_d   :std_logic;
signal wd_fifo_rd_en_d2   :std_logic;
signal wd_fifo_rd_data :std_logic_vector (dw-1 downto 0);
signal wd_fifo_count   :integer range rd_fifo_depth downto 0;
signal wd_fifo_full    :std_logic;
signal wd_fifo_empty   :std_logic;
signal wd_fifo_empty_d   :std_logic;
signal wd_fifo_empty_d2   :std_logic;
signal ext_wad_cmd :std_logic;
signal int_wad_cmd_busy   :std_logic;
signal int_wad_cmd_busy_d   :std_logic;
signal int_wad_cmd_busy_d2   :std_logic;
begin
Inst_mfifo_syncRa : liquid_smallfifo2
    generic map(data_bits=>aw, -- <read requests: address>
             length=>rd_fifo_depth)
    port map(rst=>rst,
          clk=>mvp_clk,
          wr_en=>ra_fifo_wr_en,
          wr_data=>ra_fifo_wr_data,
          rd_en=>ra_fifo_rd_en,
          rd_data=>ra_fifo_rd_data,
          full=>ra_fifo_full,
          empty=>ra_fifo_empty
         );
		 
Inst_mfifo_syncRd : liquid_smallfifo2
    generic map(data_bits=>dw, -- <read requests: data>
             length=>rd_fifo_depth)
    port map(rst=>rst,
          clk=>mvp_clk,
          wr_en=>rd_fifo_wr_en,
          wr_data=>rd_fifo_wr_data,
          rd_en=>rd_fifo_rd_en,
          rd_data=>rd_fifo_rd_data,
          full=>rd_fifo_full,
          empty=>rd_fifo_empty
         );
Inst_mfifo_syncWa : liquid_smallfifo2
    generic map(data_bits=>aw, -- <read requests: data>
             length=>wr_fifo_depth)
    port map(rst=>rst,
          clk=>mvp_clk,
          wr_en=>wa_fifo_wr_en,
          wr_data=>wa_fifo_wr_data,
          rd_en=>wa_fifo_rd_en,
          rd_data=>wa_fifo_rd_data,
          full=>wa_fifo_full,
          empty=>wa_fifo_empty
         );

Inst_mfifo_syncWd : liquid_smallfifo2
    generic map(data_bits=>dw, -- <read requests: data>
             length=>wr_fifo_depth)
    port map(rst=>rst,
          clk=>mvp_clk,
          wr_en=>wd_fifo_wr_en,
          wr_data=>wd_fifo_wr_data,
          rd_en=>wd_fifo_rd_en,
          rd_data=>wd_fifo_rd_data,
          full=>wd_fifo_full,
          empty=>wd_fifo_empty
         );
counter1<=intcounter1;
counter2<=intcounter2;
status<=Init;
initial_handshaking<=Vin_sent;
farewell_handshaking<=Vout_received;
rcnt<=int_rcnt;
wcnt<=int_wcnt;
cmd_process : process (cmd)
begin
if rst = '1' then
 ext_cmd:='0';
elsif cmd = '1' and cmd'event then
 ext_cmd:=not ext_cmd;
end if;
end process;
init_process : process (mvp_clk, rst)
begin
if rst = '1'  then	-- RESET
 Init <= '0';
 int_cmd:= '0';
elsif mvp_clk = '1' and mvp_clk'event then
 if int_cmd /= ext_cmd then 
  Init<='1';
  int_cmd:= ext_cmd;
 end if;
end if;-- clk
end process;
intf_process: process(mvp_clk, rst)
begin
if (mvp_clk'event and mvp_clk = '1') then
 if(rst = '1') then
   Vout_received <= '0'; 
   Vin_sent <= '0';
 else
  if Vout = '1' then
   Vout_received <= '1';
  end if;
  if Cin = '1' then
   Vin_sent <= '1';
   end if;
 end if;
end if;
end process;
Vin <= '0' when Init='0' else not Vin_sent;
Din <= (others => '0') when Init='0' else (others => '1');
Cout <= '0' when Init='0' else Vout;
ra_fifo_wr_data<=RAddr;
ra_fifo_wr_en<=RE;
read_process : process (mvp_clk, rst)
begin
if rst = '1'  then	-- RESET
int_rcnt<=X"0000";
RStall <= '0'; -- Never stall a read
elsif mvp_clk = '1' and mvp_clk'event then
if RE = '1' then 
int_rcnt<=int_rcnt+1;
end if;
end if; -- clk
end process;
write_process : process (mvp_clk, rst)
begin
if rst = '1'  then	-- RESET
int_wcnt<=X"0000";
elsif mvp_clk = '1' and mvp_clk'event then
if WE = '1' then 
int_wcnt<=int_wcnt+1;
end if;
end if; -- clk
end process;
ext_ra_cmd<=not ra_fifo_empty; 
write_and_read_fifo_d_process : process (mvp_clk, rst)
begin
if rst = '1'  then	-- RESET
 rd_fifo_rd_en<='0';
 RAck<='0';
elsif mvp_clk = '1' and mvp_clk'event then
 rd_fifo_rd_en<=not rd_fifo_empty; 
 if rd_fifo_rd_en = '1' and rd_fifo_empty = '0' then 
 RData<=rd_fifo_rd_data;
 RAck<='1';
 else
 RAck<='0';
 RData<=(others=>'X');
 end if;
end if; -- clk
end process;
RD_NPI_AddrReq <= not RD_NPI_AddrReq_sent;
RD_NPI_RdFIFO_Pop <= not RD_NPI_RdFIFO_Empty;
core_process : process (mvp_clk, rst)
begin
if rst = '1'  then	-- RESET
 npi_status<=(others=>'0');
 RD_NPI_Addr<=(others=>'0');
 RD_NPI_RNW<='1';
 RD_NPI_Size<=(others=>'0');
 RD_NPI_WrFIFO_Data<=(others=>'0');
 RD_NPI_WrFIFO_BE<=(others=>'1');
 RD_NPI_WrFIFO_Push<='0';
 RD_NPI_WrFIFO_Flush<='0';
 RD_NPI_RdFIFO_Flush<='0';
 RD_NPI_RdModWr<='0';
 RD_NPI_AddrReq_sent <= '1';
 int_ra_cmd_busy <= '0';
 busy_counter<=(others=>'0');
elsif mvp_clk = '1' and mvp_clk'event then
if busy_counter/=X"0" then
 busy_counter<=busy_counter+1;
end if;
if ext_ra_cmd = '1' and int_ra_cmd_busy = '0' and int_ra_cmd_busy_d = '0' and int_ra_cmd_busy_d2 = '0' then 
 int_ra_cmd_busy <= '1';
 RD_NPI_Addr(31 downto 0)<=ra_fifo_rd_data(29 downto 0) & "00";
 ra_fifo_rd_en<='1';
 RD_NPI_AddrReq_sent <= '0';
 npi_status<=(others=>'0');
 npi_status(0)<='1';
else
 ra_fifo_rd_en<='0';
 npi_status(1)<='1';
end if;
if RD_NPI_AddrAck = '1' then
 intcounter2<=clk_counter;
 npi_status(2)<='1';
 RD_NPI_AddrReq_sent <= '1';
end if;
if RD_NPI_RdFIFO_Latency = "00" and RD_NPI_RdFIFO_Empty = '0' then
 rd_fifo_wr_data <= RD_NPI_RdFIFO_Data;
 rd_fifo_wr_en  <= '1';
 npi_status(4)<='1';
 int_ra_cmd_busy<='0';busy_counter<=X"1";
elsif RD_NPI_RdFIFO_Latency = "01" and RD_NPI_RdFIFO_Empty_d = '0' then
 rd_fifo_wr_data <= RD_NPI_RdFIFO_Data;
 rd_fifo_wr_en  <= '1';
 npi_status(5)<='1';
 int_ra_cmd_busy<='0';busy_counter<=X"1";
elsif RD_NPI_RdFIFO_Latency = "10" and RD_NPI_RdFIFO_Empty_d2 = '0' then
 rd_fifo_wr_data <= RD_NPI_RdFIFO_Data;
 rd_fifo_wr_en  <= '1';
 npi_status(6)<='1';
 int_ra_cmd_busy<='0';busy_counter<=X"1";
else
 rd_fifo_wr_en <= '0';
 npi_status(7)<='1';
end if;
-----------------------------------------------cmd
end if; -- elsif mvp_clk = '1' and mvp_clk'event
end process; -- core_process : process (mvp_clk, RST)
d_reg0 : d_reg  port map(mvp_clk, RD_NPI_RdFIFO_Empty,RD_NPI_RdFIFO_Empty_d);
d_reg1 : d_reg  port map(mvp_clk, RD_NPI_RdFIFO_Empty_d,RD_NPI_RdFIFO_Empty_d2);
d_reg2 : d_reg  port map(mvp_clk, int_ra_cmd_busy,int_ra_cmd_busy_d);
d_reg3 : d_reg  port map(mvp_clk, int_ra_cmd_busy_d,int_ra_cmd_busy_d2);
----------------------------------------------------------------------------------------------------------------------------------wad
WStall<='1' when wa_fifo_full='1' and WE='1' else '0';
wa_fifo_wr_data<=WAddr;wd_fifo_wr_data<=WData;
wa_fifo_wr_en<='1' when WE='1' and wa_fifo_full='0' else '0';
wd_fifo_wr_en<='1' when WE='1' and wd_fifo_full='0' else '0';
wa_fifo_wr_data<=WAddr;wd_fifo_wr_data<=WData;
----------------------------------------------------------------------------------------------------------------------------------wad
ext_wad_cmd<=not wa_fifo_empty; 
d_reg4 : d_reg  port map(mvp_clk, WR_NPI_AddrAck,WR_NPI_AddrAck_d);
WR_NPI_AddrReq <= not WR_NPI_AddrReq_sent;
wad_core_process : process (mvp_clk, rst)
begin
if rst = '1'  then	-- RESET
 WR_NPI_Addr<=(others=>'0');
 WR_NPI_RNW<='0';
 WR_NPI_Size<=(others=>'0');
 WR_NPI_WrFIFO_Data<=(others=>'0');
 WR_NPI_WrFIFO_BE<=(others=>'1');
 WR_NPI_WrFIFO_Push<='0';
 WR_NPI_WrFIFO_Flush<='0';
 WR_NPI_RdFIFO_Pop<='0';
 WR_NPI_RdFIFO_Flush<='0';
 WR_NPI_RdModWr<='1';
 WR_NPI_AddrReq_sent <= '1';
 wa_fifo_rd_en<='0';wd_fifo_rd_en<='0';
elsif mvp_clk = '1' and mvp_clk'event then
if ext_wad_cmd = '1' and int_wad_cmd_busy = '0' and int_wad_cmd_busy_d = '0' and int_wad_cmd_busy_d2 = '0' then 
 int_wad_cmd_busy <= '1';
 WR_NPI_Addr(31 downto 0)<=wa_fifo_rd_data(29 downto 0) & "00";
 WR_NPI_WrFIFO_Data<=wd_fifo_rd_data(dw-1 downto 0);
 wa_fifo_rd_en<='1';wd_fifo_rd_en<='1';
 WR_NPI_AddrReq_sent <= '0';
else
 wa_fifo_rd_en<='0';wd_fifo_rd_en<='0';
end if;
if WR_NPI_AddrAck = '1' then
 WR_NPI_AddrReq_sent <= '1';
end if;
if WR_NPI_AddrAck_d = '1' then
 WR_NPI_WrFIFO_Push<='1';
 int_wad_cmd_busy <= '0';
else
 WR_NPI_WrFIFO_Push<='0'; 
end if;
end if;--mvp_clk
end process;
x_reg2 : d_reg  port map(mvp_clk, int_wad_cmd_busy,int_wad_cmd_busy_d);
x_reg3 : d_reg  port map(mvp_clk, int_wad_cmd_busy_d,int_wad_cmd_busy_d2);
end arc_my_mvp_npi_rw_fifo; 
