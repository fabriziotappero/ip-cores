-- 	Copyright © 2006.	GSI Technology
-- 						Jeff Daugherty
-- 						apps@gsitechnology.com
--  Version: 3.2
--
-- 	FileName: core.vhd
-- 	Unified Sram Core Model for Sync Burst/NBT Sram
--
-- 	Revision History:
--   04/23/02  1.0  1) Created VHDL Core.VHD from Verilog Core.V
--   06/05/02  1.1  1) added new signals, DELAY and tKQX.  These signals will
--                     be used to setup the Clock to Data Invalid  spec.
--   07/17/02  1.2  1) Fixed the JTAG State machine
--                  2) changed the SR register to shift out the MSB and shift
--                     in the LSB
--   09/25/02  1.3  1) Removed all nPE pin features
--                  2) Max number of Core addresses is now dynamic
--                  3) Max width of Core data is now dynamic
--                  4) Removed alll reference of JTAG from core, seperate JTAG
--                     model file: GSI_JTAG
--   01/10/03  1.4  1) Created a Write_Array process to remove race conditions
--                  2) Created a Read_Array proccess to remove race conditions
--   02/20/03  1.5  1) Added We and Waddr to Read_Array sensitivity list.
--                  2) Changed the Read_Array process to look at the last
--                     write's byte write setting and determine where to pull the
--                     read data from, either coherency(byte write on) or the
--                     array(byte write off).
--                  3) Added signal Iscd to fix SCD to the right state for NBT
-- 04/03/03   1.6   1) Added a write clock W_k to trigger the Write_Array function
-- 07/09/03   1.7   1) changed NBT write clock to clock off of we2.
--                  2) Delayed the internal clock by 1ns to control the write
--                  3) changed ce to take into account NBT mode
-- 07/23/03   1.8   1) Changed W_K to ignore the byte writes
-- 08/12/03   1.9   1) updated state machine to include seperate read and write
--                     burst states
--                  2) Changed internal bytewrite signal to ignore nW
-- 10/29/03   2.0   1) updated the state machine, changed reference to suspend
--                     to deselect. 
--                  2) added timing functions to core
-- 03/25/04   2.1   1) Updated state machine.  Added deselect and suspend states
--                  2) Fixed other issues with the state machine
-- 04/28/04   2.2   1) Rearranged state that determins Deselect, Burst and Suspend
--
-- 11/01/05   3.0   1) Created BurstRAM only Model
-- 06/21/06   3.1   1) Added Qswitch to control when the IOs turn on or off
--                  2) Delayed the Qxi inteernal data busses instead of the DQx
--                  external Data busses.
--                  3) Added CLK_i2 to control the setting of Qswitch
--                  4) All these changes removed Negative time issue for some simulations
--07/18/06    3.2   1) Initialized ce and re to 0 so that Qswitch is not
--                     undfined which can cause bus contention on startup.
--
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
ENTITY VHDL_BURST_CORE IS
  GENERIC (
    CONSTANT bank_size : integer ;-- *16M /4 bytes in parallel
    CONSTANT A_size    : integer;
    CONSTANT DQ_size   : integer);
  PORT (
    SIGNAL A     : IN std_logic_vector(A_size - 1 DOWNTO 0);-- address
    SIGNAL DQa   : INOUT std_logic_vector(DQ_size DOWNTO 1);-- byte A data
    SIGNAL DQb   : INOUT std_logic_vector(DQ_size DOWNTO 1);-- byte B data
    SIGNAL DQc   : INOUT std_logic_vector(DQ_size DOWNTO 1);-- byte C data
    SIGNAL DQd   : INOUT std_logic_vector(DQ_size DOWNTO 1);-- byte D data
    SIGNAL DQe   : inout std_logic_vector(DQ_size DOWNTO 1);-- byte E data
    SIGNAL DQf   : inout std_logic_vector(DQ_size DOWNTO 1);-- byte F data
    SIGNAL DQg   : inout std_logic_vector(DQ_size DOWNTO 1);-- byte G data
    SIGNAL DQh   : inout std_logic_vector(DQ_size DOWNTO 1);-- byte H data
    SIGNAL nBa   : IN std_logic;-- bank A write enable
    SIGNAL nBb   : IN std_logic;-- bank B write enable
    SIGNAL nBc   : IN std_logic;-- bank C write enable
    SIGNAL nBd   : IN std_logic;-- bank D write enable
    SIGNAL nBe   : IN std_logic;-- bank E write enable
    SIGNAL nBf   : IN std_logic;-- bank F write enable
    SIGNAL nBg   : IN std_logic;-- bank G write enable
    SIGNAL nBh   : IN std_logic;-- bank H write enable
    SIGNAL CK    : IN std_logic;-- clock
    SIGNAL nBW   : IN std_logic;-- byte write enable
    SIGNAL nGW   : IN std_logic;-- Global write enable
    SIGNAL nE1   : IN std_logic;-- chip enable 1
    SIGNAL E2    : IN std_logic;-- chip enable 2
    SIGNAL nE3   : IN std_logic;-- chip enable 3
    SIGNAL nG    : IN std_logic;-- output enable
    SIGNAL nADV  : IN std_logic;-- Advance not / load
    SIGNAL nADSC : IN std_logic;
    SIGNAL nADSP : IN std_logic;
    SIGNAL ZZ    : IN std_logic;-- power down
    SIGNAL nFT   : IN std_logic;-- Pipeline / Flow through
    SIGNAL nLBO  : IN std_logic;-- Linear Burst Order
    SIGNAL SCD   : IN std_logic;
    SIGNAL HighZ : std_logic_vector(DQ_size downto 1);
    SIGNAL tKQ   : time;
    SIGNAL tKQX  : time);
END VHDL_BURST_CORE;

LIBRARY GSI;
LIBRARY Std;
ARCHITECTURE GSI_BURST_CORE OF VHDL_BURST_CORE IS
  USE GSI.FUNCTIONS.ALL;
  USE Std.textio.ALL;
  TYPE MEMORY_0 IS ARRAY (0 TO bank_size) OF std_logic_vector(DQ_size - 1 DOWNTO 0);
  TYPE MEMORY_1 IS ARRAY (0 TO bank_size) OF std_logic_vector(DQ_size - 1 DOWNTO 0);
  TYPE MEMORY_2 IS ARRAY (0 TO bank_size) OF std_logic_vector(DQ_size - 1 DOWNTO 0);
  TYPE MEMORY_3 IS ARRAY (0 TO bank_size) OF std_logic_vector(DQ_size - 1 DOWNTO 0);
  TYPE MEMORY_4 IS ARRAY (0 TO bank_size) OF std_logic_vector(DQ_size - 1 DOWNTO 0);
  TYPE MEMORY_5 IS ARRAY (0 TO bank_size) OF std_logic_vector(DQ_size - 1 DOWNTO 0);
  TYPE MEMORY_6 IS ARRAY (0 TO bank_size) OF std_logic_vector(DQ_size - 1 DOWNTO 0);
  TYPE MEMORY_7 IS ARRAY (0 TO bank_size) OF std_logic_vector(DQ_size - 1 DOWNTO 0);
--   ******** Define Sram Operation Mode    **********************
  shared variable bank0 : MEMORY_0 ;
  shared variable bank1 : MEMORY_1 ;
  shared variable bank2 : MEMORY_2 ;
  shared variable bank3 : MEMORY_3 ;
  shared variable bank4 : MEMORY_4 ;
  shared variable bank5 : MEMORY_5 ;
  shared variable bank6 : MEMORY_6 ;
  shared variable bank7 : MEMORY_7 ;
-- ---------------------------------------------------------------
--   	Gated SRAM Clock
-- ---------------------------------------------------------------
  SIGNAL clk_i : std_logic;
  SIGNAL clk_i2 : std_logic;
-- ---------------------------------------------------------------
--   	Combinatorial Logic
-- ---------------------------------------------------------------
  SIGNAL E     : std_logic;-- internal chip enable
  SIGNAL ADV   : std_logic;-- internal address advance
  SIGNAL ADS   : std_logic;
  SIGNAL ADSP  : std_logic;
  SIGNAL ADSC  : std_logic;
  SIGNAL W     : std_logic;
  SIGNAL R     : std_logic;
  SIGNAL W_k   : std_logic;
  SIGNAL R_k   : std_logic;
  SIGNAL BW    : std_logic_vector(7 DOWNTO 0);-- internal byte write enable
  SIGNAL Qai   : std_logic_vector(DQ_size - 1 DOWNTO 0);-- read data
  SIGNAL Qbi   : std_logic_vector(DQ_size - 1 DOWNTO 0);-- .
  SIGNAL Qci   : std_logic_vector(DQ_size - 1 DOWNTO 0);-- .
  SIGNAL Qdi   : std_logic_vector(DQ_size - 1 DOWNTO 0);-- .
  SIGNAL Qei   : std_logic_vector(DQ_size - 1 DOWNTO 0);-- .
  SIGNAL Qfi   : std_logic_vector(DQ_size - 1 DOWNTO 0);-- .
  SIGNAL Qgi   : std_logic_vector(DQ_size - 1 DOWNTO 0);-- .
  SIGNAL Qhi   : std_logic_vector(DQ_size - 1 DOWNTO 0);-- read data
  SIGNAL Dai   : std_logic_vector(DQ_size - 1 DOWNTO 0);-- write data
  SIGNAL Dbi   : std_logic_vector(DQ_size - 1 DOWNTO 0);-- .
  SIGNAL Dci   : std_logic_vector(DQ_size - 1 DOWNTO 0);-- .
  SIGNAL Ddi   : std_logic_vector(DQ_size - 1 DOWNTO 0);-- .
  SIGNAL Dei   : std_logic_vector(DQ_size - 1 DOWNTO 0);-- .
  SIGNAL Dfi   : std_logic_vector(DQ_size - 1 DOWNTO 0);-- .
  SIGNAL Dgi   : std_logic_vector(DQ_size - 1 DOWNTO 0);-- .
  SIGNAL Dhi   : std_logic_vector(DQ_size - 1 DOWNTO 0);-- write data
  SIGNAL bwi   : std_logic_vector(7 DOWNTO 0);
  SIGNAL addr0 : std_logic_vector(A_size - 1 DOWNTO 0);-- saved address
  SIGNAL addr1 : std_logic_vector(A_size - 1 DOWNTO 0);-- address buffer 1
  SIGNAL baddr : std_logic_vector(A_size - 1 DOWNTO 0);-- burst memory address
  SIGNAL waddr : std_logic_vector(A_size - 1 DOWNTO 0);-- write memory address
  SIGNAL raddr : std_logic_vector(A_size - 1 DOWNTO 0);-- read memory address
  SIGNAL bcnt  : std_logic_vector(1 DOWNTO 0)  := to_stdlogicvector(0, 2);-- burst counter
  SIGNAL we0   : std_logic := '0';
  SIGNAL re0   : std_logic := '0';
  SIGNAL re1   : std_logic := '0';
  SIGNAL re2   : std_logic := '0';
  SIGNAL ce0   : std_logic := '0';
  SIGNAL ce1   : std_logic := '0';
  SIGNAL ce    : std_logic := '0';
  SIGNAL re    : std_logic := '0';
  SIGNAL oe    : std_logic;
  SIGNAL we    : std_logic;
  SIGNAL Qswitch: std_logic ;
  SIGNAL state : string (9 DOWNTO 1) := "IDLE     ";

  SIGNAL Check_Time : time   := 1 ns;
  SIGNAL DELAY      : time   := 1 ns;
  SIGNAL GUARD      : boolean:= TRUE;

--  TIMING FUNCTIONS
  function POSEDGE (SIGNAL s : std_ulogic) return BOOLEAN IS
  begin
    RETURN (s'EVENT AND ((To_X01(s'LAST_VALUE) = '0') OR (s = '1')));
  end; 
  function NEGEDGE (SIGNAL s : std_ulogic) return BOOLEAN IS
  begin
    RETURN (s'EVENT AND ((To_X01(s'LAST_VALUE) = '1') OR (s = '0')) );
  end; 
-- END TIMING FUNCTIONS
  
  PROCEDURE shiftnow (SIGNAL addr1 : INOUT std_logic_vector(A_size - 1 DOWNTO 0);
                      SIGNAL re2   : INOUT std_logic;
                      SIGNAL re1   : INOUT std_logic;
                      SIGNAL ce1   : INOUT std_logic;
                      SIGNAL Dai   : INOUT std_logic_vector(DQ_size - 1 DOWNTO 0);
                      SIGNAL Dbi   : INOUT std_logic_vector(DQ_size - 1 DOWNTO 0);
                      SIGNAL Dci   : INOUT std_logic_vector(DQ_size - 1 DOWNTO 0);
                      SIGNAL Ddi   : INOUT std_logic_vector(DQ_size - 1 DOWNTO 0);
                      SIGNAL Dei   : INOUT std_logic_vector(DQ_size - 1 DOWNTO 0);
                      SIGNAL Dfi   : INOUT std_logic_vector(DQ_size - 1 DOWNTO 0);
                      SIGNAL Dgi   : INOUT std_logic_vector(DQ_size - 1 DOWNTO 0);
                      SIGNAL Dhi   : INOUT std_logic_vector(DQ_size - 1 DOWNTO 0))
  IS
  BEGIN
    addr1 <= baddr;
    re2 <= re1;
    re1 <= re0;
    ce1 <= ce0;
    Dai <= DQa;
    Dbi <= DQb;
    Dci <= DQc;
    Ddi <= DQd;
    Dei <= DQe;
    Dfi <= DQf;
    Dgi <= DQg;
    Dhi <= DQh;
  END;

BEGIN
  PROCESS
  BEGIN
    WAIT UNTIL POSEDGE(CK);
    clk_i  <= NOT ZZ after 100 ps;
    clk_i2 <= NOT ZZ after 200 ps;
    WAIT UNTIL NEGEDGE(CK);
    clk_i  <= '0' after 100 ps;
    clk_i2 <= '0' after 200 ps;
  END PROCESS;

-- ---------------------------------------------------------------
--   	State Machine
-- ---------------------------------------------------------------
  st : PROCESS
    variable tstate : string(9 DOWNTO 1) :="DESELECT ";
    variable twe0 : std_logic := '0';
    variable tre0 : std_logic := '0';
    variable tce0 : std_logic := '0';
  BEGIN
    WAIT UNTIL POSEDGE(CK);
    CASE state IS
      WHEN "DESELECT " =>
        if (E = '1') then
--Checking for ADSC Control
          if (ADSC = '1') then
            shiftnow(addr1, re2, re1, ce1, Dai, Dbi, Dci, Ddi, Dei, Dfi, Dgi, Dhi);
            tre0 := R;
            twe0 := W;
            tce0 := '1';
            addr0 <= A;
            bwi <= BW;
            bcnt <= to_stdlogicvector(0, 2);
            tstate := "NEWCYCLE ";
          end if;
--  Checking for ADSP Control
          if (ADSP = '1') then
            shiftnow(addr1, re2, re1, ce1, Dai, Dbi, Dci, Ddi, Dei, Dfi, Dgi, Dhi);
            tre0 := R;
            tce0 := '1';
            addr0 <= A;
            bcnt <= to_stdlogicvector(0, 2);
            tstate := "LATEWRITE";
          end if;
        END IF;
-- Checking for Deselect
        if ((E /= '1' and ADSC = '1') or (nADSP and (E2 = '0' or nE3 = '1'))) then
          shiftnow(addr1, re2, re1, ce1, Dai, Dbi, Dci, Ddi, Dei, Dfi, Dgi, Dhi);
          tstate := "DESELECT ";
          twe0 := '0';
          tre0 := '0';
          tce0 := '0';
        END IF;
-- **************************************************
      WHEN "NEWCYCLE " | "BURST    " | "SUSPBR   " | "LATEWRITE" =>
--Checking for ADSC Control
        if (ADSC = '1') then
          shiftnow(addr1, re2, re1, ce1, Dai, Dbi, Dci, Ddi, Dei, Dfi, Dgi, Dhi);
          tre0 := R;
          twe0 := W;
          tce0 := '1';
          addr0 <= A;
          bwi <= BW;
          bcnt <= to_stdlogicvector(0, 2);
          tstate := "NEWCYCLE ";
        end if;
--  Checking for ADSP Control
        if (ADSP = '1') then
          shiftnow(addr1, re2, re1, ce1, Dai, Dbi, Dci, Ddi, Dei, Dfi, Dgi, Dhi);
          tre0 := R;
          tce0 := '1';
          addr0 <= A;
          bcnt <= to_stdlogicvector(0, 2);
          tstate := "LATEWRITE";
        end if;
-- Checking for Deselect
        if ((E /= '1' and nADSC = '0') or (nADSP = '0' and (E2 = '0' or nE3 = '1'))) then
          shiftnow(addr1, re2, re1, ce1, Dai, Dbi, Dci, Ddi, Dei, Dfi, Dgi, Dhi);
          tstate := "DESELECT ";
          twe0 := '0';
          tre0 := '0';
          tce0 := '0';
        end if;
--  Checking for Burst Start
        if (ADSC = '0' and ADSP = '0' AND ADV = '1') THEN
          shiftnow(addr1, re2, re1, ce1, Dai, Dbi, Dci, Ddi, Dei, Dfi, Dgi, Dhi);
          tstate := "BURST    ";
          if we0 = '1' then
            twe0 := W;
            tre0 := '0';
            bwi <= BW;
          end if;
          if re0 = '1' then
            twe0 := '0';
            tre0 := R;
          end if;
          tce0 := '1';
          bcnt <= to_stdlogicvector(bcnt + "01", 2);
        end if;
--  Checking for a Suspended Burst
        if (ADSC = '0' and ADSP = '0' AND ADV = '0') THEN
          shiftnow(addr1, re2, re1, ce1, Dai, Dbi, Dci, Ddi, Dei, Dfi, Dgi, Dhi);
          tstate := "SUSPBR   ";
          if we0 = '1' or W = '1' then
            twe0 := W;
            tre0 := '0';
            re1 <= '0';
            bwi <= BW;
          elsif re0 = '1' then
            twe0 := '0';
            tre0 := R;
          end if;
          tce0 := '1';
        end if;
      WHEN OTHERS =>
        shiftnow(addr1, re2, re1, ce1, Dai, Dbi, Dci, Ddi, Dei, Dfi, Dgi, Dhi);
        tstate := "DESELECT ";
        twe0 := '0';
        tre0 := '0';
        tce0 := '0';
        bcnt <= to_stdlogicvector(0, 2);
    END CASE;
    state <= tstate;
    we0 <= twe0;
    re0 <= tre0;
    ce0 <= tce0;
  END PROCESS;
-- ---------------------------------------------------------------
--               Data IO Logic
-- ---------------------------------------------------------------
  Write_Array: process (W_k)
  begin  -- process Write_Array
    IF (POSEDGE(W_k)) THEN
      IF (we = '1') THEN
        IF bwi(0) = '1' THEN
          bank0(to_integer(waddr)) := Dai;
        END IF;
        IF bwi(1) = '1' THEN
          bank1(to_integer(waddr)) := Dbi;
        END IF;
        IF bwi(2) = '1' THEN
          bank2(to_integer(waddr)) := Dci;
        END IF;
        IF bwi(3) = '1' THEN
          bank3(to_integer(waddr)) := Ddi;
        END IF;
        IF bwi(4) = '1' THEN
          bank4(to_integer(waddr)) := Dei;
        END IF;
        IF bwi(5) = '1' THEN
          bank5(to_integer(waddr)) := Dfi;
        END IF;
        IF bwi(6) = '1'  THEN
          bank6(to_integer(waddr)) := Dgi;
        END IF;
        IF bwi(7) = '1'  THEN
          bank7(to_integer(waddr)) := Dhi;
        END IF;
      END IF;
    END IF;
  end process Write_Array;

  Read_Array: process (r_k)
  begin  -- process Read_Array
    IF (we = '0') then
      Qai <= transport bank0(to_integer(raddr)) after DELAY - 200 ps;
      Qbi <= transport bank1(to_integer(raddr)) after DELAY - 200 ps;
      Qci <= transport bank2(to_integer(raddr)) after DELAY - 200 ps;
      Qdi <= transport bank3(to_integer(raddr)) after DELAY - 200 ps;
      Qei <= transport bank4(to_integer(raddr)) after DELAY - 200 ps;
      Qfi <= transport bank5(to_integer(raddr)) after DELAY - 200 ps;
      Qgi <= transport bank6(to_integer(raddr)) after DELAY - 200 ps;
      Qhi <= transport bank7(to_integer(raddr)) after DELAY - 200 ps;
    END IF;
end process Read_Array;

-- check it -t option is active and set correctly
time_ck : process (CLK_i)
begin
  check_time <= CK'last_event;
  assert check_time /= 0 ns report "Resolution needs to be set to 100ps for modelSIM use vsim -t 100ps <>" severity FAILURE;
end process time_ck;

ADS_SET : process (CLK_i)
begin
  if posedge(clk_i) then
    ADS  <= ADSP OR ADSC;
  end if;
end process ADS_SET;

q_switch : process (CLK_i2)
begin                                 --read clock controls outputs
  Qswitch <= transport re and ce after DELAY - 200 ps;
end process q_switch;


E     <= (NOT nE1 AND E2 AND NOT nE3);
ADV   <=  not nADV;
ADSP  <=  NOT nADSP AND ( E2 or NOT nE3);
ADSC  <=  NOT nADSC AND ( not nE1 or E2 or NOT nE3);
W     <= (NOT nGW OR NOT nBW );
W_k   <=((NOT ADSP or not ADSC) AND (NOT nGW OR NOT nBW )) and clk_i after 100 ps;
R     <=  nGW and nBW;
R_k   <= (TERNARY((ADS or ADV) and not W, TERNARY( nFT, re1, re0), '0') and clk_i) after 100 ps;
BW(0) <=  not nGW or (NOT nBa and not nBW);
BW(1) <=  not nGW or (NOT nBb and not nBW);
BW(2) <=  not nGW or (NOT nBc and not nBW);
BW(3) <=  not nGW or (NOT nBd and not nBW);
BW(4) <=  not nGW or (NOT nBe and not nBW);
BW(5) <=  not nGW or (NOT nBf and not nBW);
BW(6) <=  not nGW or (NOT nBg and not nBW);
BW(7) <=  not nGW or (NOT nBh and not nBW);
baddr <=  to_stdlogicvector(TERNARY(nLBO, addr0(A_size - 1 DOWNTO 2) & (bcnt(1) XOR addr0(1)) &
                                   (bcnt(0) XOR addr0(0)), addr0(A_size - 1 DOWNTO 2) & (addr0(1 DOWNTO 0) + bcnt)), A_size);

waddr <=  to_stdlogicvector(TERNARY(not ADV, addr0, baddr), A_size);
raddr <=  to_stdlogicvector(TERNARY(nFT, addr1, baddr), A_size);
we    <=  we0;
re    <=  TERNARY(nFT, re1, re0);
ce    <= (TERNARY(not SCD AND re2 = '1', ce1, ce0));
oe    <=  re AND ce;

DELAY <=  TERNARY(nG OR not ((we and re) or oe) OR ZZ, tKQ, tKQX);

DQa   <=  GUARDED TERNARY(Qswitch, Qai, HighZ);
DQb   <=  GUARDED TERNARY(Qswitch, Qbi, HighZ);
DQc   <=  GUARDED TERNARY(Qswitch, Qci, HighZ);
DQd   <=  GUARDED TERNARY(Qswitch, Qdi, HighZ);
DQe   <=  GUARDED TERNARY(Qswitch, Qei, HighZ);
DQf   <=  GUARDED TERNARY(Qswitch, Qfi, HighZ);
DQg   <=  GUARDED TERNARY(Qswitch, Qgi, HighZ);
DQh   <=  GUARDED TERNARY(Qswitch, Qhi, HighZ);
END GSI_BURST_CORE;
