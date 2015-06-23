--##############################################################################
--
--  controller
--      Main processor controller
--
--      Controls all other blocks: ALU, program counter, stack, …
--
--------------------------------------------------------------------------------
--
--  Versions / Authors
--      1.0 Francois Corthay    first implementation
--
--  Provided under GNU LGPL licence: <http://www.gnu.org/copyleft/lesser.html>
--
--  by the electronics group of "HES-SO//Valais Wallis", in Switzerland:
--  <http://www.hevs.ch/en/rad-instituts/institut-systemes-industriels/>.
--
--------------------------------------------------------------------------------
--
--  Hierarchy
--      Used by "nanoblaze/nanoProcessor".
--
--##############################################################################

LIBRARY ieee;
  USE ieee.std_logic_1164.all;
  USE ieee.numeric_std.all;

ENTITY controller IS
  GENERIC( 
    intCodeBitNb    : positive := 5;
    branchCondBitNb : positive := 3;
    opCodeBitNb     : positive := 5
  );
  PORT( 
    reset            : IN  std_ulogic;
    clock            : IN  std_ulogic;
    en               : IN  std_ulogic;
    opCode           : IN  std_ulogic_vector(opCodeBitNb-1 DOWNTO 0);
    twoRegInstr      : IN  std_ulogic;
    registerFileSel  : OUT std_ulogic;
    instrDataSel     : OUT std_ulogic;
    portInSel        : OUT std_ulogic;
    scratchpadSel    : OUT std_ulogic;
    regWrite         : OUT std_ulogic;
    readStrobe       : OUT std_ulogic;
    writeStrobe      : OUT std_uLogic;
    scratchpadWrite  : OUT std_ulogic;
    branchCond       : IN  std_ulogic_vector(branchCondBitNb-1 DOWNTO 0);
    cOut             : IN  std_ulogic;
    zero             : IN  std_ulogic;
    cIn              : OUT std_ulogic;
    incPC            : OUT std_ulogic;
    loadInstrAddress : OUT std_ulogic;
    loadStoredPC     : OUT std_ulogic;
    prevPC           : OUT std_ulogic;
    storePC          : OUT std_ulogic;
    intCode          : IN  std_ulogic_vector(intCodeBitNb-1 DOWNTO 0);
    int              : IN  std_ulogic;
    intAck           : OUT std_ulogic
  );
END controller ;

--==============================================================================

ARCHITECTURE RTL OF controller IS

  signal en1, enInt: std_ulogic;

  constant opCodeLength : integer := 5;
  subtype opCodeType is std_ulogic_vector(opCodeLength-1 downto 0);
  constant opLoad  : opCodeType := "00000";
  constant opInput : opCodeType := "00010";
  constant opFetch : opCodeType := "00011";
  constant opAnd   : opCodeType := "00101";
  constant opOr    : opCodeType := "00110";
  constant opXor   : opCodeType := "00111";
  constant opTest  : opCodeType := "01001";
  constant opComp  : opCodeType := "01010";
  constant opAdd   : opCodeType := "01100";
  constant opAddCy : opCodeType := "01101";
  constant opSub   : opCodeType := "01110";
  constant opSubCy : opCodeType := "01111";
  constant opShRot : opCodeType := "10000";
  constant opRet   : opCodeType := "10101";
  constant opOutput: opCodeType := "10110";
  constant opStore : opCodeType := "10111";
  constant opCall  : opCodeType := "11000";
  constant opJump  : opCodeType := "11010";
  constant opIntF  : opCodeType := "11110";

  constant branchConditionLength : integer := 3;
  subtype branchConditionType is std_ulogic_vector(branchConditionLength-1 downto 0);
  constant brAw  : branchConditionType := "000";
  constant brZ   : branchConditionType := "100";
  constant brNZ  : branchConditionType := "101";
  constant brC   : branchConditionType := "110";
  constant brNC  : branchConditionType := "111";

  signal aluOpSel: std_ulogic;
  signal regWriteEn: std_ulogic;

  signal flagsEn, flagsEnable: std_ulogic;
  signal carrySaved: std_ulogic;
  signal zeroSaved: std_ulogic;

  signal branchEnable1, branchEnable: std_ulogic;
  signal discardOpCode: std_ulogic;

  signal updateIntFlag: std_ulogic;

BEGIN
  ------------------------------------------------------------------------------
                                                                -- Enable signal
  buildEnable: process(reset, clock)
  begin
    if reset = '1' then
      en1 <= '0';
    elsif rising_edge(clock) then
      en1 <= '1';
    end if;
  end process buildEnable;

  enInt <= en1 and en;  -- don't enable very first instruction twice

  ------------------------------------------------------------------------------
                                                                 -- ALU controls
  selectdataSource: process(opCode)
  begin
    aluOpSel      <= '0';
    portInSel     <= '0';
    scratchpadSel <= '0';
    case opCode(opCodeLength-1 downto 0) is
      when opLoad  => aluOpSel      <= '1';
      when opInput => portInSel     <= '1';
      when opFetch => scratchpadSel <= '1';
      when opAnd   => aluOpSel      <= '1';
      when opOr    => aluOpSel      <= '1';
      when opXor   => aluOpSel      <= '1';
      when opTest  => aluOpSel      <= '1';
      when opComp  => aluOpSel      <= '1';
      when opAdd   => aluOpSel      <= '1';
      when opAddCy => aluOpSel      <= '1';
      when opSub   => aluOpSel      <= '1';
      when opSubCy => aluOpSel      <= '1';
      when opShRot => aluOpSel      <= '1';
      when others  => aluOpSel      <= '-';
                      portInSel     <= '-';
                      scratchpadSel <= '-';
    end case;
  end process selectdataSource;

  registerFileSel <= aluOpSel and      twoRegInstr;
  instrDataSel    <= aluOpSel and (not twoRegInstr);

  regWriteEn <= enInt and (not discardOpCode);

  regWriteTable: process(opCode, regWriteEn)
  begin
    case opCode(opCodeLength-1 downto 0) is
      when opLoad  => regWrite <= regWriteEn;
      when opInput => regWrite <= regWriteEn;
      when opFetch => regWrite <= regWriteEn;
      when opAnd   => regWrite <= regWriteEn;
      when opOr    => regWrite <= regWriteEn;
      when opXor   => regWrite <= regWriteEn;
      when opAdd   => regWrite <= regWriteEn;
      when opAddCy => regWrite <= regWriteEn;
      when opSub   => regWrite <= regWriteEn;
      when opSubCy => regWrite <= regWriteEn;
      when opShRot => regWrite <= regWriteEn;
      when others  => regWrite <= '0';
    end case;
  end process regWriteTable;

  ------------------------------------------------------------------------------
                                                                 -- I/O controls
  readStrobe  <= enInt when (opCode = opInput) and (discardOpCode = '0')
    else '0';
  writeStrobe <= enInt when (opCode = opOutput) and (discardOpCode = '0')
    else '0';

  ------------------------------------------------------------------------------
                                                          -- scratchpad controls
  scratchpadWrite <= '1' when opCode = opStore else '0';

  ------------------------------------------------------------------------------
                                                                  -- Carry logic
  flagsEn <= enInt and (not branchEnable);

  flagsEnableTable: process(opCode, flagsEn)
  begin
    case opCode(opCodeLength-1 downto 0) is
      when opAnd   => flagsEnable <= flagsEn;
      when opOr    => flagsEnable <= flagsEn;
      when opXor   => flagsEnable <= flagsEn;
      when opTest  => flagsEnable <= flagsEn;
      when opComp  => flagsEnable <= flagsEn;
      when opAdd   => flagsEnable <= flagsEn;
      when opAddCy => flagsEnable <= flagsEn;
      when opSub   => flagsEnable <= flagsEn;
      when opSubCy => flagsEnable <= flagsEn;
      when opShRot => flagsEnable <= flagsEn;
      when others  => flagsEnable <= '0';
    end case;
  end process flagsEnableTable;

  saveCarries: process(reset, clock)
  begin
    if reset = '1' then
      carrySaved <= '0';
      zeroSaved <= '0';
    elsif rising_edge(clock) then
      if flagsEnable = '1' then
        carrySaved <= cOut;
        zeroSaved <= zero;
      end if;
    end if;
  end process saveCarries;

  cIn <= carrySaved;

  ------------------------------------------------------------------------------
                                                     -- Program counter controls
  checkBranchCondition: process(branchCond, zeroSaved, carrySaved)
  begin
    case branchCond(branchConditionLength-1 downto 0) is
      when brAw => branchEnable1 <= '1';
      when brZ  => branchEnable1 <= zeroSaved;
      when brNZ => branchEnable1 <= not zeroSaved;
      when brC  => branchEnable1 <= carrySaved;
      when brNC => branchEnable1 <= not carrySaved;
      when others => branchEnable1 <= '-';
    end case;
  end process checkBranchCondition;

  branchEnableTable: process(opCode, branchEnable1, discardOpCode)
  begin
    if discardOpCode = '0' then
      case opCode(opCodeLength-1 downto 0) is
        when opRet  => branchEnable <= branchEnable1;
        when opCall => branchEnable <= branchEnable1;
        when opJump => branchEnable <= branchEnable1;
        when others  => branchEnable <= '0';
      end case;
    else
      branchEnable <= '0';
    end if;
  end process branchEnableTable;

  progCounterControlTable: process(opCode, enInt, branchEnable)
  begin
    incPC <= enInt;
    loadInstrAddress <= '0';
    loadStoredPC     <= '0';
    case opCode(opCodeLength-1 downto 0) is
      when opRet  => incPC <= not branchEnable;
                     loadStoredPC <= enInt and branchEnable;
      when opCall => incPC <= not branchEnable;
                     loadInstrAddress <= enInt and branchEnable;
      when opJump => incPC <= not branchEnable;
                     loadInstrAddress <= enInt and branchEnable;
      when others => null;
    end case;
  end process progCounterControlTable;

  -- If a branch condition is met, the next operation has to be discarded.
  -- This is due to the synchronous operation of the program ROM: the
  -- instructions are provided one clock period after the program counter.
  -- so while the branch operation is processed, the next instruction is
  -- already being fetched.
  delayBranchEnable: process(reset, clock)
  begin
    if reset = '1' then
      discardOpCode <= '0';
    elsif rising_edge(clock) then
      discardOpCode <= branchEnable;
    end if;
  end process delayBranchEnable;

  ------------------------------------------------------------------------------
                                                       -- Stack pointer controls
  pcStackControlTable: process(discardOpCode, opCode, enInt)
  begin
    storePC <= '0';
    prevPC  <= '0';
    if discardOpCode = '0' then
      case opCode(opCodeLength-1 downto 0) is
        when opRet  => prevPC <= enInt;
        when opCall => storePC <= enInt;
        when others  => null;
      end case;
    end if;
  end process pcStackControlTable;


  ------------------------------------------------------------------------------
                                                            -- interrupt control
  updateIntFlag <= '1' when opCode = opIntF else '0';

END ARCHITECTURE RTL;
