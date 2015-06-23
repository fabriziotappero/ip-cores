--Core module. 
--This module is basically connects everything and decodes the opcodes.
--The only thing above this is toplevel.vhd which actually sets the pinout for the FPGA


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.tinycpu.all;

entity core is 
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
end core;

architecture Behavioral of core is
  component fetch is 
    port(
      Enable: in std_logic;
      AddressIn: in std_logic_vector(15 downto 0);
      Clock: in std_logic;
      DataIn: in std_logic_vector(15 downto 0); --interface from memory
      IROut: out std_logic_vector(15 downto 0);
      AddressOut: out std_logic_vector(15 downto 0) --interface to memory
    );
  end component;
  component alu is
    port(
      Op: in std_logic_vector(4 downto 0);
      DataIn1: in std_logic_vector(7 downto 0);
      DataIn2: in std_logic_vector(7 downto 0);
      DataOut: out std_logic_vector(7 downto 0);
      TR: out std_logic
    );
  end component;
  component carryover is 
    port(
      EnableCarry: in std_logic; --When disabled, SegmentIn goes to SegmentOut
      DataIn: in std_logic_vector(7 downto 0);
      SegmentIn: in std_logic_vector(7 downto 0);
      Addend: in std_logic_vector(7 downto 0); --How much to increase DataIn by (as a signed number). Believe it or not, that's the actual word for what we need.
      DataOut: out std_logic_vector(7 downto 0);
      SegmentOut: out std_logic_vector(7 downto 0);
      Clock: in std_logic
    );
  end component;
  component registerfile is
  port(
    WriteEnable: in regwritetype;
    DataIn: in regdatatype;
    Clock: in std_logic;
    DataOut: out regdatatype
  );
  end component;

  constant REGIP: integer := 7;
  constant REGSP: integer := 6;
  constant REGSS: integer := 15;
  constant REGES: integer := 14;
  constant REGDS: integer := 13;
  constant REGCS: integer := 12;

  type ProcessorState is (
    ResetProcessor,
    FirstFetch1, --the fetcher needs two clock cycles to catch up
    FirstFetch2,
    Firstfetch3,
    Execute,
    WaitForMemory,
    HoldMemory,
    WaitForAlu -- wait for settling is needed when using the ALU
  );
  signal state: ProcessorState;
  signal HeldState: ProcessorState; --state the processor was in when HOLD was activated

  --carryout signals
  signal CarryCS: std_logic;
  signal CarrySS: std_logic;
  signal IPAddend: std_logic_vector(7 downto 0);
  signal SPAddend: std_logic_vector(7 downto 0);
  signal IPCarryOut: std_logic_vector(7 downto 0);
  signal CSCarryOut: std_logic_vector(7 downto 0);
  signal SPCarryOut: std_logic_vector(7 downto 0);
  signal SSCarryOut: std_logic_vector(7 downto 0);

  --register signals
  signal regWE:regwritetype;
  signal regIn: regdatatype;
  signal regOut: regdatatype;
  --fetch signals
  signal fetchEN: std_logic;
  signal IR: std_logic_vector(15 downto 0);
  --alu signals
  signal AluOp: std_logic_vector(4 downto 0);
  signal AluIn1: std_logic_vector(7 downto 0);
  signal AluIn2: std_logic_vector(7 downto 0);
  signal AluOut: std_logic_vector(7 downto 0);
  signal AluTR: std_logic;
  signal TR: std_logic;
  signal TRData: std_logic;
  signal UseAluTR: std_logic;
  
  --control signals
  signal InReset: std_logic;
  signal OpAddress: std_logic_vector(15 downto 0); --memory address to use for operation of an instruction
  signal OpDataIn: std_logic_vector(15 downto 0); 
  signal OpDataOut: std_logic_vector(15 downto 0);
  signal OpWW: std_logic;
  signal OpWE: std_logic;
  signal OpDestReg1: std_logic_vector(3 downto 0);
  signal OpUseReg2: std_logic;
  signal OpDestReg2: std_logic_vector(3 downto 0);

  --opcode shortcut signals
  signal opmain: std_logic_vector(3 downto 0);
  signal opimmd: std_logic_vector(7 downto 0);
  signal opcond1: std_logic; --first conditional bit
  signal opcond2: std_logic; --second conditional bit
  signal opreg1: std_logic_vector(2 downto 0);
  signal opreg2: std_logic_vector(2 downto 0);
  signal opreg3: std_logic_vector(2 downto 0);
  signal opseges: std_logic; --use ES segment

  signal regbank: std_logic;
  
  signal fetcheraddress: std_logic_vector(15 downto 0);

  
  signal bankreg1: std_logic_vector(3 downto 0); --these signals have register bank stuff baked in
  signal bankreg2: std_logic_vector(3 downto 0);
  signal bankreg3: std_logic_vector(3 downto 0);
  signal FetchMemAddr: std_logic_vector(15 downto 0);

  signal UsuallySS: std_logic_vector(3 downto 0);
  signal UsuallyDS: std_logic_vector(3 downto 0);
  signal AluRegOut: std_logic_vector(3 downto 0);
begin
  reg: registerfile port map(
    WriteEnable => regWE,
    DataIn => regIn,
    Clock => Clock,
    DataOut => regOut
  );
  carryovercs: carryover port map(
    EnableCarry => CarryCS,
    DataIn => regOut(REGIP),
    SegmentIn => regOut(REGCS),
    Addend => IPAddend,
    DataOut => IPCarryOut,
    SegmentOut => CSCarryOut,
    Clock => Clock
  );
  carryoverss: carryover port map(
    EnableCarry => CarrySS,
    DataIn => regOut(REGSP),
    SegmentIn => RegOut(REGSS),
    Addend => SPAddend,
    DataOut => SPCarryOut,
    SegmentOut => SSCarryOut,
    Clock => Clock
  );
  fetcher: fetch port map(
    Enable => fetchEN,
    AddressIn => fetcheraddress, 
    Clock => Clock,
    DataIn => MemIn,
    IROut => IR,
    AddressOut => FetchMemAddr
  );
  cpualu: alu port map(
    Op => AluOp,
    DataIn1 => AluIn1,
    DataIn2 => AluIn2,
    DataOut => AluOut,
    TR => AluTR
  );
  fetcheraddress <= regIn(REGCS) & regIn(REGIP);
  MemAddr <= OpAddress when state=WaitForMemory else FetchMemAddr;
  MemOut <= OpDataOut when (state=WaitForMemory and OpWE='1') else "ZZZZZZZZZZZZZZZZ" when state=HoldMemory else x"0000";
  MemWE <= OpWE when state=WaitForMemory else 'Z' when state=HoldMemory else '0';
  MemWW <= OpWW when state=WaitForMemory else 'Z' when state=HoldMEmory else '0';
  OpDataIn <= MemIn;
  --opcode shortcuts
  opmain <= IR(15 downto 12);
  opimmd <= IR(7 downto 0);
  opcond1 <= IR(8);
  opcond2 <= IR(7);
  opreg1 <= IR(11 downto 9);
  opreg3 <= IR(2 downto 0);
  opreg2 <= IR(6 downto 4);
  opseges <= IR(3);
  --debug ports
  DebugCS <= regOut(REGCS);
  DebugIP <= regOut(REGIP);
  DebugR0 <= regOut(0);
  DebugIR <= IR;
  DebugTR <= TR;
  --register addresses with registerbank baked in
  bankreg1 <= ('1' & opreg1) when (regbank='1' and opreg1(2)='0') else '0' & opreg1;
  bankreg2 <= ('1' & opreg2) when (regbank='1' and opreg2(2)='0') else '0' & opreg2;
  bankreg3 <= ('1' & opreg3) when (regbank='1' and opreg3(2)='0') else '0' & opreg3;
  --UsuallySegment shortcuts (only used when not an immediate
  UsuallyDS <= "1101" when opseges='0' else "1110";
  UsuallySS <= "1111" when opseges='0' else "1110";
  TR <= TRData when UseAluTR='0' else AluTR;
  
  foo: process(Clock, Hold, state, IR, inreset, reset, regin, regout, IPCarryOut, CSCarryOut)
  begin
    if rising_edge(Clock) then

    --states
      if reset='1' and hold='0' then
        InReset <= '1';
        state <= ResetProcessor;
        HoldAck <= '0';
        CarryCS <= '1';
        CarrySS <= '0';
        regWE <= (others => '1');
        regIn <= (others => "00000000");
        regIn(REGCS) <= x"01";
        regIn(REGSS) <= x"02";
        IPAddend <= x"00";
        SPAddend <= x"00";
        AluOp <= "10001"; --reset TR in ALU
        regbank <= '0';
        fetchEN <= '1';
        OpDataOut <= "ZZZZZZZZZZZZZZZZ";
        OpAddress <= x"0000";
        OpWE <= '0';
        opWW <= '0';
        TRData <= '0';
        UseAluTR <= '0';
        OpDestReg1<= x"0";
        OpDestReg2 <= x"0";
        OpUseReg2 <= '0';
        --finish up
      elsif InReset='1' and reset='0' and Hold='0' then --reset is done, start executing
        InReset <= '0';
        fetchEN <= '1';
        state <= FirstFetch1;
      elsif Hold = '1' and (state=HoldMemory or state=Execute or state=ResetProcessor) then
        --do not hold immediately if waiting on memory or if waiting on the first fetch of an instruction after reset
        state <= HoldMemory;
        HoldAck <= '1';
        FetchEN <= '0';
      elsif Hold='0' and state=HoldMemory then
        if reset='1' or InReset='1' then
          state <= ResetProcessor;
        else
          state <= Execute;
        end if;
        FetchEN <= '1';
      elsif state=FirstFetch1 then --we have to let IR get loaded before we can execute.
        --regWE <= (others => '0');
        fetchEN <= '1'; --already enabled, but anyway
        --regWE <= (others => '0');
        IPAddend <= x"02";
        SPAddend <= x"00"; --no addend unless pushing or popping
        RegWE <= (others => '0');
        regIn(REGIP) <= IPCarryOut;
        regWE(REGIP) <= '1';
        regWE(REGCS) <= '1';
        regIn(REGCS) <= CSCarryOut;
        state <= Execute; 
      elsif state=FirstFetch2 then
        state <= FirstFetch3;
        
      elsif state=FirstFetch3 then
        state <= Execute;
      elsif state=WaitForMemory then
        state <= Execute;
        FetchEn <= '1';
        IpAddend <= x"02";
        --SpAddend <= x"00";
        --SP can change here... really I don't *think* it can change from within Execute... so maybe that's redundant
        regIn(REGSP) <= SPCarryOut; --with addend being 0, it'll just write SP to SP so it won't change, but this makes code easier for me
        regIn(REGSS) <= SSCarryOut;
        regWE(REGSP) <= '1';
        regWE(REGSS) <= '1';
        if OpWE='0' then
          regIn(to_integer(unsigned(OpDestReg1))) <= OpDataIn(7 downto 0);
          regWE(to_integer(unsigned(OpDestReg1))) <= '1';
          if OpUseReg2='1' then
            regIn(to_integer(unsigned(OpDestReg2))) <= OpDataIn(15 downto 8);
            regWE(to_integer(unsigned(OpDestReg2))) <= '1';
          end if;
        end if;
      elsif state=WaitForAlu then
        state <= Execute;
        regIn(to_integer(unsigned(AluRegOut))) <= AluOut;
        regWE(to_integer(unsigned(AluRegOut))) <= '1';
        FetchEN <= '1';
        IPAddend <= x"02";
        SPAddend <= x"00";
      end if;


      if state=Execute then
        fetchEN <= '1';
        --reset to "usual"
        IPAddend <= x"02";
        SPAddend <= x"00"; --no addend unless pushing or popping
        RegWE <= (others => '0');
        regIn(REGIP) <= IPCarryOut;
        regWE(REGIP) <= '1';
        regWE(REGCS) <= '1';
        regIn(REGCS) <= CSCarryOut;
        OpUseReg2 <= '0';
        OpAddress <= "ZZZZZZZZZZZZZZZZ";
        if UseAluTR='1' then
          UseAluTR<='0';
        end if;
        --actual decoding
        if opcond1='0' or (opcond1='1' and TR='1') then
          case opmain is 
            when "0000" => --mov reg,imm
              regIn(to_integer(unsigned(bankreg1))) <= opimmd;
              regWE(to_integer(unsigned(bankreg1))) <= '1';
            when "0001" => --mov [reg],imm
              OpAddress <= regOut(REGDS) & regOut(to_integer(unsigned(bankreg1)));
              OpWE <= '1';
              OpDataOut <= x"00" & opimmd;
              OpWW <= '0';
              state <= WaitForMemory;
              IPAddend <= x"00"; --disable all this because we have to wait a cycle to write memory
              FetchEN <= '0';
            when "0011" => --group 3 comparisons
              TRData <= AluTR;
              UseAluTR <= '1';
              AluOp <= "01" & opreg3; --nothing hard here, ALU does it all for us
              AluIn1 <= regOut(to_integer(unsigned(bankreg1)));
              AluIn2 <= regOut(to_integer(unsigned(bankreg2)));
            when "0100" => --group 4 bitwise operations
              --setup wait state
              State <= WaitForAlu;
              FetchEN <= '0';
              IPAddend <= x"00";
              AluOp <= "00" & opreg3; --nothing hard here, ALU does it all for us
              AluIn1 <= regOut(to_integer(unsigned(bankreg1)));
              AluIn2 <= regOut(to_integer(unsigned(bankreg2)));
              AluRegOut <= bankreg1;
              --regIn(to_integer(unsigned(bankreg1))) <= AluOut;
              --regWE(to_integer(unsigned(bankreg1))) <= '1';
           when "0101" => --group 5
              case opreg3 is
                when "000" => --subgroup 5-0
                  case opreg2 is
                    when "000" => --push reg
                      SpAddend <= x"02"; --set SP to increment
                      OpAddress <= regOut(to_integer(unsigned(UsuallySS))) & regOut(REGSP);
                      OpWE <= '1';
                      OpDataOut <= x"00" & regOut(to_integer(unsigned(bankreg1)));
                      OpWW <= '1';
                      state <= WaitForMemory;
                      IPAddend <= x"00";
                      FetchEN <= '0';
                    when "001" => --pop reg
                      SPAddend <= x"FE"; --set SP to decrement
                      --TODO account for carryover properties
                      OpAddress <= regOut(to_integer(unsigned(UsuallySS))) & std_logic_vector(unsigned(regOut(REGSP))-2); --decrement 2 here "early" 
                      OpWE <= '0';
                      OpDestReg1 <= bankreg1;
                      --regIn(to_integer(unsigned(bankreg1))) <= OpData(7 downto 0);
                      OpWW <= '0';
                      state <= WaitForMemory;
                      IPAddend <= x"00";
                      FetchEN <= '0';
                    when others =>
                      --synthesis off
                      report "Not implemented subgroup 5-0" severity error;
                      --synthesis on
                  end case;
                when "001" => --mov reg, reg
                  regIn(to_integer(unsigned(bankreg1))) <= regOut(to_integer(unsigned(bankreg2)));
                  regWE(to_integer(unsigned(bankreg1))) <= '1';
                when "010" => --mov reg, [reg] (load)
                  OpDestReg1 <= bankreg1;
                  OpWE <= '0';
                  OpAddress <= regOut(to_integer(unsigned(UsuallyDS))) & regOut(to_integer(unsigned(bankreg2)));
                  IpAddend <= x"00";
                  FetchEN <= '0';
                  state <= WaitForMemory;
                when "011" => --mov [reg], reg (store)
                  OpDataOut <= x"00" & regOut(to_integer(unsigned(bankreg2)));
                  OpWW <= '0';
                  OpWE <= '1';
                  OpAddress <= regOut(to_integer(unsigned(UsuallyDS))) & regOut(to_integer(unsigned(bankreg1)));
                  IpAddend <= x"00";
                  FetchEN <= '0';
                  state <= WaitForMemory;
                when others =>
                  --synthesis off
                  report "Not implemented group 5" severity error;
                  --synthesis on
              end case;
            when others => 
              --synthesis off
              report "Not implemented" severity error;
              --synthesis on
          end case;
        end if;
      end if;

    end if;


    
  end process;








  
end Behavioral;