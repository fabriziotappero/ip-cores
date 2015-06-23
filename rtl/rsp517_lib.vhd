--------------------------------------------------------------------------
-- 
-- Title        :   RSP-517 Mitrion platform support
-- Platform     :   Platform is rsp517-vlx160 (ROSTA RSP-517 V4VLX160)
-- Design       :   Library design module
-- Project      :   rsp517_mitrion 
-- Package      :   rsp517_pack
-- Author       :   Alexey Shmatok <alexey.shmatok@gmail.com>
-- Company      :   Rosta Ltd, www.rosta.ru
-- 
--------------------------------------------------------------------------
--
-- Description  :  This library module provides interface cores for
--                 Mitrion virtual processor (MVP)
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
package rsp517_pack is
component mvp_ctrl is
port (
  -- system
  rst, mvp_clk: in std_logic;
  -- mvp
  mvp_rst: out std_logic;
  -- ctrl
  cmd:  in std_logic;
  status:  out std_logic
);
end component;
component mvp_ram_inout_port is
generic (
  dw : natural:=32; -- mem a data width
  aw : natural:=8 -- mem a address width
);
port (
  -- system
  rst, mvp_clk: in std_logic;
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
  -- ram 
  -- port to write
  RAMAI  : out std_logic_vector(aw-1 downto 0);
  RAMDI  : out std_logic_vector(dw-1 downto 0);
  RAMWE  : out std_logic;
  -- port to read
  RAMAO  : out std_logic_vector(aw-1 downto 0);
  RAMDO  : in std_logic_vector(dw-1 downto 0);
  -- ctrl
  cmd:  in std_logic;
  status:  out std_logic;
  initial_handshaking : out std_logic;
  farewell_handshaking: out std_logic;
  rcnt:  out std_logic_vector(15 downto 0);
  wcnt:  out std_logic_vector(15 downto 0)

);
end component;
component mvp_stream_out_port is
generic (data_bits : integer := 32);
port (
  -- system
  rst, mvp_clk: in std_logic;
  -- out from mvp 
  Dout:  in std_logic_vector(data_bits+1 downto 0);
  Vout:  in std_logic;
  Cout:  out std_logic;
  -- ctrl
  cmd:  in std_logic;
  data: out std_logic_vector(data_bits-1 downto 0);
  status:  out std_logic;
  tail:  out std_logic;
  enable:  out std_logic
);
end component;
component mvp_stream_in_port is
generic (data_bits : integer := 32);
port (
  -- system
  rst, mvp_clk: in std_logic;
  -- in to mvp 
  Din:  out std_logic_vector(data_bits+1 downto 0);
  Vin:  out std_logic;
  Cin:  in std_logic;
  -- ctrl
  cmd:  in std_logic;
  bk:  in std_logic;
  data: in std_logic_vector(data_bits-1 downto 0);
  status:  out std_logic;
  wt:  out std_logic;
  tail:  in std_logic;
  enable:  in std_logic
);
end component;
component mvp_scalar_out_port is
generic (data_bits : integer := 32);
port (
  -- system
  rst, mvp_clk: in std_logic;
  -- out from mvp 
  Dout:  in std_logic_vector(data_bits-1 downto 0);
  Vout:  in std_logic;
  Cout:  out std_logic;
  -- ctrl
  cmd : in std_logic;
  data: out std_logic_vector(data_bits-1 downto 0);
  status: out std_logic
);
end component;
component mvp_scalar_in_port is
generic (data_bits : integer := 32; log_len : integer:=32);
port (
  -- system
  rst, mvp_clk: in std_logic;
  -- out from mvp 
  Din:  out std_logic_vector(data_bits-1 downto 0);
  Vin:  out std_logic;
  Cin:  in std_logic;
  -- ctrl
  cmd:  in std_logic;
  bk:  in std_logic;
  data: in std_logic_vector(data_bits-1 downto 0);
  status:  out std_logic;
  wt:  out std_logic
);
end component;
component gen_tribuf
generic(width : positive);
Port ( pass : in STD_LOGIC;
i : in STD_LOGIC_VECTOR (width-1 downto 0);
o : out STD_LOGIC_VECTOR (width-1 downto 0)
);
end component;
component gen_tribuf2
Port ( pass : in STD_LOGIC;
i : in STD_LOGIC;
o : out STD_LOGIC
);
end component;
component d_reg is 
    port (CLK: in std_logic;
	  DATA: in STD_LOGIC; 
          Q: out STD_LOGIC); 
end component;
component d_reg_vector is 
generic(w : positive:=1);
    port (CLK: in std_logic;
	  DATA: in STD_LOGIC_VECTOR(w-1 downto 0); 
          Q: out STD_LOGIC_VECTOR(w-1 downto 0)); 
end component;
end package;
-----------------------------------------------------------------------------------------------gen_tribuf;
library ieee;
use ieee.std_logic_1164.all;
entity gen_tribuf is
generic(width : positive);
Port ( pass : in STD_LOGIC;
i : in STD_LOGIC_VECTOR (width-1 downto 0);
o : out STD_LOGIC_VECTOR (width-1 downto 0));
end gen_tribuf;
architecture Behavioral of gen_tribuf is
constant hi_imp : STD_LOGIC_VECTOR(width-1 downto 0) := (others => 'Z');
begin
o <= i when pass ='1' else hi_imp;
end Behavioral;
-----------------------------------------------------------------------------------------------gen_tribuf2;
library ieee;
use ieee.std_logic_1164.all;
entity gen_tribuf2 is
Port ( pass : in STD_LOGIC;
i : in STD_LOGIC;
o : out STD_LOGIC);
end gen_tribuf2;
architecture Behavioral of gen_tribuf2 is
constant hi_imp : STD_LOGIC := 'Z';
begin
o <= i when pass ='1' else hi_imp;
end Behavioral;
-----------------------------------------------------------------------------------------------d_reg;
library IEEE; 
use IEEE.std_logic_1164.all; 
entity d_reg is 
    port (CLK, DATA: in STD_LOGIC; 
          Q: out STD_LOGIC); 
end d_reg; 
architecture BEHAV of d_reg is 
begin 
D_REG: process (CLK, DATA)  
   begin  
   if (CLK'event and CLK='1') then 
       Q <= DATA; 
    end if; 
    end process;
end BEHAV; 
-----------------------------------------------------------------------------------------------d_reg_vector;
library IEEE; 
use IEEE.std_logic_1164.all; 
entity d_reg_vector is 
generic(w : positive:=1);
    port (CLK: in std_logic; 
	  DATA: in STD_LOGIC_VECTOR(w-1 downto 0); 
          Q: out STD_LOGIC_VECTOR(w-1 downto 0)); 
end d_reg_vector; 
architecture BEHAV of d_reg_vector is 
begin 
D_REG: process (CLK, DATA)  
   begin  
   if (CLK'event and CLK='1') then 
       Q <= DATA; 
    end if; 
    end process;
end BEHAV; 
-----------------------------------------------------------------------------------------------mvp_ctrl;
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.ctrl_types.all;
entity mvp_ctrl is
port (
  -- system
  rst, mvp_clk: in std_logic;
  -- mvp
  mvp_rst: out std_logic;
  -- ctrl
  cmd:  in std_logic;
  status:  out std_logic
);
end mvp_ctrl;
architecture arch_mvp_ctrl of mvp_ctrl is
shared variable counter : std_logic_vector(1 downto 0) := "00";
shared variable ext_cmd : std_logic :='0';
shared variable int_cmd : std_logic :='0';
begin
cmd_process : process (cmd,rst)
begin
if rst = '1' then
 ext_cmd:='0';
elsif cmd = '1' and cmd'event then
 ext_cmd:=not ext_cmd;
end if;
end process;
core_process : process (mvp_clk, rst)
begin
if rst = '1'  then	-- RESET
mvp_rst <= '0';
counter:="00";
int_cmd:= '0';
status<='0';
elsif mvp_clk = '1' and mvp_clk'event then
if counter = "00" then
 if int_cmd /= ext_cmd then 
  mvp_rst<='1';
  int_cmd:= ext_cmd;
  counter:="01";
 end if;
elsif counter = "11" then
 counter:="00";
 mvp_rst<='0';
 status<='1';
else 
counter:=counter+1;
end if;-- counter
end if;-- clk
end process;
end arch_mvp_ctrl;
-----------------------------------------------------------------------------------------------mvp_scalar_out_port;
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.ctrl_types.all;
--use work.rsp517_pack.all;
entity mvp_scalar_out_port is
generic (data_bits : integer := 32);
port (
  -- system
  rst, mvp_clk: in std_logic;
  -- out from mvp 
  Dout:  in std_logic_vector(data_bits-1 downto 0);
  Vout:  in std_logic;
  Cout:  out std_logic;
  -- ctrl
  cmd : in std_logic;
  data: out std_logic_vector(data_bits-1 downto 0);
  status: out std_logic
--  wt:  out std_logic --_vector(31 downto 0);
);
end mvp_scalar_out_port;
architecture arch_mvp_scalar_out_port of mvp_scalar_out_port is
shared variable counter : std_logic_vector(1 downto 0) := "00";
shared variable ext_cmd : std_logic :='0';
shared variable int_cmd : std_logic :='0';
begin
cmd_process : process (cmd,rst)
begin
if rst = '1' then
 ext_cmd:='0';
elsif cmd = '1' and cmd'event then
 ext_cmd:=not ext_cmd;
end if;
end process;
core_process : process (mvp_clk, rst, Vout)
variable var_data: std_logic_vector(data_bits-1 downto 0):=X"00000000";
begin
 data<=var_data;
if rst = '1'  then	-- RESET
 Cout<='0';
 status<='0';
 int_cmd:='0';
 counter:="00";
elsif mvp_clk = '1' and mvp_clk'event then
 if counter = "01" then
   Cout<='0'; -- data consumed 
   counter:= "00";
 end if; -- if counter = "01"
 if int_cmd /= ext_cmd then 
  int_cmd := ext_cmd;
  if Vout = '1' then
   Cout<='1';
   status<='1';
   var_data(31 downto 0):=Dout(31 downto 0); -- consume data
   counter:= "01";
  else -- if Vout = '1'
   Cout<='0';
   status<='0';
  end if; -- else if Vout = '1'
 end if; -- if int_cmd = '1'
end if; -- elsif mvp_clk = '1' and mvp_clk'event
end process; -- core_process : process (mvp_clk, RST)
end arch_mvp_scalar_out_port;
-----------------------------------------------------------------------------------------------mvp_scalar_in_port;
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.ctrl_types.all;
--use work.rsp517_pack.all;
entity mvp_scalar_in_port is
generic (data_bits : integer := 32; log_len : integer:=32);
port (
  -- system
  rst, mvp_clk: in std_logic;
  -- in to mvp 
  Din:  out std_logic_vector(data_bits-1 downto 0);
  Vin:  out std_logic;
  Cin:  in std_logic;
  -- ctrl
  cmd:  in std_logic;--_vector(31 downto 0);
  bk:  in std_logic;--_vector(31 downto 0);
  data: in std_logic_vector(data_bits-1 downto 0);
  status:  out std_logic; --_vector(31 downto 0);
  wt:  out std_logic --_vector(31 downto 0);
);
end mvp_scalar_in_port;
architecture arch_mvp_scalar_in_port of mvp_scalar_in_port is
shared variable ext_cmd : std_logic :='0';
shared variable int_cmd : std_logic :='0';
shared variable int_bk : std_logic :='0';
shared variable ext_bk : std_logic :='0';
shared variable counter : std_logic_vector(1 downto 0) := "00";
begin
cmd_process : process (cmd,rst)
begin
if rst = '1' then
 ext_cmd:='0';
elsif cmd = '1' and cmd'event then
 ext_cmd:=not ext_cmd;
end if;
end process;
bk_process : process (bk,rst)
begin
if rst = '1' then
 ext_bk:='0';
elsif bk = '1' and bk'event then
 ext_bk:='1';
end if;
end process;
core_process : process(rst,mvp_clk,data)
variable var_data: std_logic_vector(data_bits-1 downto 0):=X"00000000";
begin
 var_data:=data;
if rst = '1'  then	-- RESET
 counter:="00";
 status<='0';
 Vin <= '0';
 int_cmd:='0';
 int_bk:='0';
elsif mvp_clk = '1' and mvp_clk'event then
if counter = "00" then
 wt<='0';
 if int_cmd /= ext_cmd then 
 int_cmd := ext_cmd;
 Din(31 downto 0)<=var_data(31 downto 0);
 Vin <= '1';
 counter := "01";
 end if;
elsif counter = "01" then
 wt<='1';
 if int_bk /= ext_bk then
  counter := "00";
  int_bk := '0';
 end if; -- if int_bk = '1'
 if Cin = '1' then
  status<='1';
  Vin <= '0';
  counter := "00";
 else -- if Cin = '1'
  status<='0';
 end if; -- else if Cin = '1'
end if; -- counter = 01
end if; -- clk
end process; -- core_process : process (mvp_clk, RST)
end arch_mvp_scalar_in_port;
-----------------------------------------------------------------------------------------------mvp_stream_out_port;
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.ctrl_types.all;
--use work.rsp517_pack.all;
entity mvp_stream_out_port is
generic (data_bits : integer := 32);
port (
  -- system
  rst, mvp_clk: in std_logic;
  -- out from mvp 
  Dout:  in std_logic_vector(data_bits+1 downto 0);
  Vout:  in std_logic;
  Cout:  out std_logic;
  -- ctrl
  cmd:  in std_logic;
  data: out std_logic_vector(data_bits-1 downto 0);
  status:  out std_logic;
  tail:  out std_logic;
  enable:  out std_logic
);
end mvp_stream_out_port;
architecture arch_mvp_stream_out_port of mvp_stream_out_port is
shared variable counter : std_logic_vector(1 downto 0) := "00";
shared variable ext_cmd : std_logic :='0';
shared variable int_cmd : std_logic :='0';
begin
cmd_process : process (cmd,rst)
begin
if rst = '1' then
 ext_cmd:='0';
elsif cmd = '1' and cmd'event then
 ext_cmd:=not ext_cmd;
end if;
end process;
core_process : process (mvp_clk, rst, Vout)
variable var_data: std_logic_vector(data_bits-1 downto 0):=X"00000000";
variable var_tail: std_logic:='0';
variable var_enable: std_logic:='0';
begin
 data<=var_data;
 tail<=var_tail;
 enable<=var_enable;
if rst = '1'  then	-- RESET
 Cout<='0';
 status<='0';
 int_cmd:='0';
 counter:="00";
 var_tail:='0';
 var_enable:='0';
elsif mvp_clk = '1' and mvp_clk'event then
 var_enable:=Dout(data_bits+1);
 var_tail:=Dout(data_bits);
 if counter = "01" then
   Cout<='0'; -- data consumed 
   counter:= "00";
 end if; -- if counter = "01"
 if int_cmd /= ext_cmd then 
  int_cmd := ext_cmd;
  if Vout = '1' and var_enable = '1' then
   Cout<='1';
   status<='1';
   var_data(data_bits-1 downto 0):=Dout(data_bits-1 downto 0); -- consume data
   counter:= "01";
  else -- if Vout = '1'
   Cout<='0';
   status<='0';
  end if; -- else if Vout = '1'
 end if; -- if int_cmd = '1'
end if; -- elsif mvp_clk = '1' and mvp_clk'event
end process; -- core_process : process (mvp_clk, RST)
end arch_mvp_stream_out_port;
-----------------------------------------------------------------------------------------------mvp_stream_in_port;
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.ctrl_types.all;
--use work.rsp517_pack.all;
entity mvp_stream_in_port is
generic (data_bits : integer := 32; log_len : integer:=32);
port (
  -- system
  rst, mvp_clk: in std_logic;
  -- in to mvp 
  Din:  out std_logic_vector(data_bits+1 downto 0);
  Vin:  out std_logic;
  Cin:  in std_logic;
  -- ctrl
  cmd:  in std_logic;
  bk:  in std_logic;
  data: in std_logic_vector(data_bits-1 downto 0);
  status:  out std_logic;
  wt:  out std_logic;
  tail:  in std_logic;
  enable:  in std_logic
);
end mvp_stream_in_port;
architecture arch_mvp_stream_in_port of mvp_stream_in_port is
shared variable ext_cmd : std_logic :='0';
shared variable int_cmd : std_logic :='0';
shared variable int_bk : std_logic :='0';
shared variable ext_bk : std_logic :='0';
shared variable counter : std_logic_vector(1 downto 0) := "00";
begin
cmd_process : process (cmd,rst)
begin
if rst = '1' then
 ext_cmd:='0';
elsif cmd = '1' and cmd'event then
 ext_cmd:=not ext_cmd;
end if;
end process;
bk_process : process (bk,rst)
begin
if rst = '1' then
 ext_bk:='0';
elsif bk = '1' and bk'event then
 ext_bk:='1';
end if;
end process;
core_process : process(rst,mvp_clk,data,tail,enable)
variable var_data: std_logic_vector(data_bits+1 downto 0):="00" & X"00000000";
begin
 var_data(data_bits-1 downto 0):=data(data_bits-1 downto 0);
 var_data(data_bits):=tail;
 var_data(data_bits+1):=enable;
if rst = '1'  then	-- RESET
 counter:="00";
 status<='0';
 Vin <= '0';
 int_cmd:='0';
 int_bk:='0';
 wt<= '0';
elsif mvp_clk = '1' and mvp_clk'event then
if counter = "00" then
 if int_cmd /= ext_cmd then 
 int_cmd := ext_cmd;
 Din<=var_data;
 Vin <= '1';
 counter := "01";
 wt<='1';
 end if;
elsif counter = "01" then
 if int_bk /= ext_bk then
  counter := "00";
  int_bk := '0';
  wt<='0';
 end if; -- if int_bk = '1'
 if Cin = '1' then
  status<='1';
  Vin <= '0';
  counter := "00";
  wt<='0';
 else -- if Cin = '1'
  status<='0';
 end if; -- else if Cin = '1'
end if; -- counter = 01
end if; -- clk
end process; -- core_process : process (mvp_clk, RST)
end arch_mvp_stream_in_port;
-----------------------------------------------------------------------------------------------mvp_ram_inout_port;
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library work;
use work.ctrl_types.all;
use work.rsp517_pack.all;
entity mvp_ram_inout_port is
generic (
  dw : natural:=32; -- mem a data width
  aw : natural:=8 -- mem a address width
);
port (
  -- system
  rst, mvp_clk: in std_logic;
  -- mvp 
  Din:  out std_logic_vector(0 downto 0);
  Vin:  out std_logic;
  Cin:  in std_logic;
  Dout:  in std_logic_vector(0 downto 0);
  Vout:  in std_logic;
  Cout:  out std_logic;
  -- read
  RE     : in std_logic;
  RAck   : out std_logic;
  RAddr  : in std_logic_vector(aw-1 downto 0);
  RData  : out  std_logic_vector(dw-1 downto 0);
  RStall : out  std_logic;
  -- write
  WE     : in std_logic;
  WAddr  : in std_logic_vector(aw-1 downto 0);
  WData  : in std_logic_vector(dw-1 downto 0);
  WStall : out  std_logic;
  -- ram 
  -- port to write
  RAMAI  : out std_logic_vector(aw-1 downto 0);
  RAMDI  : out std_logic_vector(dw-1 downto 0);
  RAMWE  : out std_logic;
  -- port to read
  RAMAO  : out std_logic_vector(aw-1 downto 0);
  RAMDO  : in std_logic_vector(dw-1 downto 0);
  -- ctrl
  cmd:  in std_logic;
  status:  out std_logic;
  initial_handshaking : out std_logic;
  farewell_handshaking: out std_logic;
  rcnt:  out std_logic_vector(15 downto 0);
  wcnt:  out std_logic_vector(15 downto 0)
);
end mvp_ram_inout_port;
architecture arch_mvp_ram_inout_port of mvp_ram_inout_port is
shared variable int_cmd : std_logic :='0';
shared variable ext_cmd : std_logic :='0';
signal Vin_sent : std_logic;
signal Vout_received: std_logic;
signal Init : std_logic;

signal int_RAck : std_logic;
signal int_RAck2 : std_logic;
signal int_RAck3 : std_logic;
signal int_RData  : std_logic_vector(dw-1 downto 0);
signal int_rcnt  : std_logic_vector(15 downto 0);
signal int_wcnt  : std_logic_vector(15 downto 0);
begin
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
core_process : process (mvp_clk, rst)
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
d_reg0 : d_reg  port map(mvp_clk, RE,RAck);
RAMAO<=RAddr;
RData<=RAMDO;
RAMAI<=WAddr;
RAMDI<=WData;
RAMWE<=WE;
RStall <= '0'; -- Never stall a read
WStall <= '0'; -- Never stall a write
end arch_mvp_ram_inout_port;
