LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
use work.tinycpu.all;

ENTITY core_tb IS
END core_tb;
 
ARCHITECTURE behavior OF core_tb IS 
 
-- Component Declaration for the Unit Under Test (UUT)
 
  component core is 
    port(
      --memory interface 
      MemAddr: out std_logic_vector(15 downto 0); --memory address (in bytes)
      MemWW: out std_logic; --memory writeword
      MemWE: out std_logic; --memory writeenable
      MemIn: in std_logic_vector(15 downto 0);
      MemOut: out std_logic_vector(15 downto 0);
      --general interface
      Clock: in std_logic;
      Reset: in std_logic; --When this is high, CPU will reset within 1 clock cycles. 
      --Enable: in std_logic; --When this is high, the CPU executes as normal, when low the CPU stops at the next clock cycle(maintaining all state)
      Hold: in std_logic; --when high, CPU pauses execution and places Memory interfaces into high impendance state so the memory can be used by other components
      HoldAck: out std_logic; --when high, CPU acknowledged hold and buses are in high Z
      --todo: port interface

      --debug ports:
      DebugIR: out std_logic_vector(15 downto 0); --current instruction
      DebugIP: out std_logic_vector(7 downto 0); --current IP
      DebugCS: out std_logic_vector(7 downto 0); --current code segment
      DebugTR: out std_logic; --current value of TR
      DebugR0: out std_logic_vector(7 downto 0)
    );
  end component;
    

  --memory interface 
  signal MemAddr: std_logic_vector(15 downto 0); --memory address (in bytes)
  signal MemWW: std_logic; --memory writeword
  signal MemWE: std_logic; --memory writeenable
  signal MemOut: std_logic_vector(15 downto 0);
  signal MemIn: std_logic_vector(15 downto 0):=x"0000";
  --general interface
  signal Reset: std_logic:='0'; --When this is high, CPU will reset within 1 clock cycles. 
  --Enable: in std_logic; --When this is high, the CPU executes as normal, when low the CPU stops at the next clock cycle(maintaining all state)
  signal Hold: std_logic:='0'; --when high, CPU pauses execution and places Memory interfaces into high impendance state so the memory can be used by other components
  signal HoldAck: std_logic; --when high, CPU acknowledged hold and buses are in high Z
  --todo: port interface

  --debug ports:
  signal DebugIR: std_logic_vector(15 downto 0); --current instruction
  signal DebugIP: std_logic_vector(7 downto 0); --current IP
  signal DebugCS: std_logic_vector(7 downto 0); --current code segment
  signal DebugTR: std_logic; --current value of TR
  signal DebugR0: std_logic_vector(7 downto 0);

  signal Clock: std_logic;
  constant clock_period : time := 10 ns;
 
BEGIN

  -- Instantiate the Unit Under Test (UUT)
  uut: core PORT MAP (
    MemAddr => MemAddr,
    MemWW => MemWW,
    MemWE => MemWE,
    MemOut => MemOut,
    MemIn => MemIn,
    --general interface
    Clock => Clock,
    Reset => Reset,
    --Enable: in std_logic; --When this is high, the CPU executes as normal, when low the CPU stops at the next clock cycle(maintaining all state)
    Hold => Hold,
    HoldAck => HoldAck,
    DebugIR => DebugIR,
    DebugIP => DebugIP,
    DebugCS => DebugCS,
    DebugTR => DebugTR,
    DebugR0 => DebugR0
  );


  -- Clock process definitions
  clock_process :process
  begin
    Clock <= '0';
    wait for clock_period/2;
    Clock <= '1';
    wait for clock_period/2;
  end process;
 

  -- Stimulus process
  stim_proc: process
    variable err_cnt: integer :=0;
  begin         
    Reset <= '1';
    wait for 20 ns;    
    
    --state tests:
    Hold <= '1';
    wait for 10 ns;
    assert(HoldAck = '1') report "hold state is not acknowledged" severity error;
    --assert(MemAddr = "ZZZZZZZZZZZZZZZZ" and MemWW="Z" and MemWE="Z" and MemOut = "ZZZZZZZZZZZZZZZZZZZZ")
    --  report "hold state does not set high-Z" severity error;
    Hold <= '0';
    wait for 10 ns;
    assert(HoldAck = '0') report "hold state lasts longer than it should" severity error;
    
    Reset <= '0';
    MemIn <= x"0012"; --mov r0, 0xFF
    wait for 20 ns; --fetcher needs two clock cycles to catch up
    assert(MemAddr = x"0100") report "Not fetching from correct start address" severity error;
    MemIn <= x"00F1"; --mov r0, 0xF1
    wait for 10 ns;
    assert(MemAddr = x"0102") report "fetcher is not incrementing address" severity error;
    assert(DebugIR = x"00F1" and DebugR0 /= x"12") report "IR is not correct. Execution occurs during first fetch";
    MemIn <= x"0056";
    wait for 10 ns;
    assert(DebugR0 = x"56") report "loaded value of R0 is not correct" severity error;
    MemIn <= x"0E50"; --mov IP, 0x50
    wait for 10 ns; 
    assert( MemAddr = x"0150") report "mov to IP doesn't work" severity error; --DebugIP uses regOut, so it won't be updated until next clock cycle actually, but it's correct.
    MemIn <= x"0020"; --mov r0, 0x20
    wait for 10 ns;
    assert (MemAddr = x"0152" and DebugIP=x"52") report "fetching is wrong after move to IP" severity error; --DebugIP uses regOut, Fetchaddress uses regIn, so this is correct
    MemIn <= x"0160"; --mov r0,0x60 if TR is set
    wait for 10 ns; --wait until register write happens
    assert(DebugR0 = x"20") report "mov to r0 is wrong after move to IP" severity error;
    MemIn <= x"1050"; --mov [r0], 0x50 (r0 is 0x20)
    wait for 10 ns;
    MemIn <= x"0025"; --mov r0,0x25
    assert(DebugR0 = x"20" and DebugTR='0') report "moved to r0 conditional thought TR is 0" severity error;
    assert(MemAddr = x"0020" and MemWE='1' and MemWW='0' and MemOut=x"0050") report "Write to memory doesn't work" severity error;
    wait for 20 ns; --wait an extra cycle because of WaitForMemory state
    MemIn <= x"0235"; --mov r1,0x35
    wait for 10 ns;
    MemIn <= "0011000000010000"; --compare greater than r0, r1 : TR=r0 > r1
    wait for 10 ns;
    assert(DebugTR ='0') report "ALU compare is not correct for greater than" severity error;
    MemIn <= "0011000000010010"; --TR=r0 < r1
    wait for 10 ns;
    MemIn <= x"0F20"; --jmp to 0x20 if TR=1
    assert(DebugTR='1') report "ALU compare is not correct for less than" severity error;
    wait for 10 ns;
    assert(DebugIP=x"20") report "conditional TR is not correct after ALU compare" severity error;

    --now test bitwise
    MemIn <= x"0E50"; --mov IP, 0x50 -- do this just so we can count IP easily
    wait for 10 ns;
    MemIn <= x"00F0"; --mov r0, 0xFO
    wait for 10 ns;
    MemIn <= x"0218"; --mov r1, 0x18
    wait for 10 ns;
    MemIn <= "0100000000010001"; --or r0, r1 (r0 = r0 or r1)
    wait for 10 ns;
    wait for 10 ns; --wait for settling
    assert(DebugR0 = x"F8") report "ALU OR is not correct" severity error;
    assert( MemAddr=x"0156") report "Fetching is wrong after WaitForAlu" severity error;
    MemIn <= x"0070"; --mov r0, 0x70 -- for debugging
    wait for 10 ns;
    assert( MemAddr=x"0158") report "IP increment is wrong after WaitForAlu" severity error;
    MemIn <= "0101000000000000"; --push r0
    wait for 10 ns;
    assert(MemAddr=x"0200" and MemOut=x"0070") report "push is not correct" severity error;
    wait for 10 ns;
    MemIn <= "0101000001100001"; --mov r0, SP
    wait for 10 ns;
    assert(Debugr0 = x"02") report "SP is not correct" severity error;
    
    MemIn <= "0101000000010000"; --pop r0 
    assert(MemAddr=x"015C") report "IP increment is wrong after push" severity error;
    wait for 10 ns;
    MemIn <= x"0020"; --the value to be popped into r0
    assert(MemAddr=x"0200") report "Pop is not fetching from correct address" severity error;
    wait for 10 ns;
    assert(DebugR0=x"20") report "Pop is not assigning to R0 correct" severity error;
    MemIn <= x"0040"; --mov r0, 0x40
    wait for 10 ns;
    MemIn <= b"0101_0010_0000_0001"; --mov r1,r0
    wait for 10 ns;
    MemIn <= b"0101_0000_0001_0010"; --mov r0, [r1]
    wait for 10 ns;
    assert(MemAddr=x"0040") report "load operation doesn't fetch from proper address" severity error;
    MemIn <= x"1234"; --value to be loaded to r0 (lower value only)
    wait for 10 ns;
    assert(DebugR0=x"34") report "load operation doesn't load into r0 properly" severity error;

    MemIn <= b"0101_0000_0001_0011"; --mov [r0], r1
    wait for 10 ns;
    assert(MemAddr=x"0034") report "store operation doesn't store to proper address" severity error;
    assert(MemOut=x"0040") report "store operation doesn't have proper value" severity error;
    wait for 10 ns;
    MemIn <= x"0010";
    

    -- summary of testbench
    assert false
    report "Testbench of core completed successfully!"
    severity note;

    wait;

    -- insert stimulus here 

    wait;
  end process;


END;
