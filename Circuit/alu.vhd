--##############################################################################
--
--  alu
--      The processor ALU
--
--      Arithmetic and logic unit.
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
--      Used by "nanoblaze/nanoProcessor/aluAndRegisters".
--
--##############################################################################

LIBRARY ieee;
  USE ieee.std_logic_1164.all;
  USE ieee.numeric_std.all;

ENTITY alu IS
  GENERIC( 
    aluCodeBitNb : positive := 5;
    dataBitNb    : positive := 8
  );
  PORT( 
    aluCode : IN  std_ulogic_vector(aluCodeBitNb-1 DOWNTO 0);
    opA     : IN  signed(dataBitNb-1 DOWNTO 0);
    opB     : IN  signed(dataBitNb-1 DOWNTO 0);
    cIn     : IN  std_ulogic;
    aluOut  : OUT signed(dataBitNb-1 DOWNTO 0);
    cOut    : OUT std_ulogic;
    zero    : OUT std_ulogic
  );
END alu ;

--==============================================================================

ARCHITECTURE RTL OF alu IS

  signal aluCodeInt: unsigned(aluCode'range);
  signal aArith: signed(opA'high+1 downto 0);
  signal bArith: signed(opA'high+1 downto 0);
  signal cInArith: signed(1 downto 0);
  signal cInShift: std_ulogic;
  signal yArith: signed(aluOut'high+1 downto 0);
  signal aluOutInt: signed(aluOut'range);

BEGIN
  ------------------------------------------------------------------------------
                                      -- clear aluCode don't care LSB for shifts
  aluCodeInt(aluCode'high downto 1) <= unsigned(aluCode(aluCode'high downto 1));

  cleanupLsb: process(aluCode)
  begin
    if aluCode(aluCode'high) = '1' then
      aluCodeInt(0) <= '0';
    else
      aluCodeInt(0) <= aluCode(0);
    end if;
  end process cleanupLsb;

  ------------------------------------------------------------------------------
                                             -- values for arithmetic operations
  aArith <= signed(resize(unsigned(opA), aArith'length));
  bArith <= signed(resize(unsigned(opB), bArith'length));
  cInArith <= (0 => cIn, others => '0');

  process(aluCode, cIn, opA)
  begin
    case aluCode(2 downto 1) is
      when "00"   => cInShift <= cIn;
      when "01"   => cInShift <= opA(opA'high);
      when "10"   => cInShift <= opA(opA'low);
      when "11"   => cInShift <= aluCode(0);
      when others => cInShift <= '-';
    end case;
  end process;

  ------------------------------------------------------------------------------
                                                               -- alu operations
  aluOperation: process(
    aluCodeInt,
    opA, opB,
    aArith, bArith, cInArith,
    cInShift,
    yArith, aluOutInt
  )
    variable xorAcc: std_ulogic;
  begin
    yArith <= (others => '-');
    cOut   <= '-';
    aluOutInt <= (others => '-');
    case to_integer(aluCodeInt) is
      when  0 =>                                        -- LOAD sX, kk
        aluOutInt <= opB;
      when  2 =>                                        -- INPUT sX, pp
        aluOutInt <= opB;
      when  3 =>                                        -- FETCH sX, ss
        aluOutInt <= opB;
      when  5 =>                                        -- AND sX, kk
        aluOutInt <= opA and opB;
        cOut      <= '0';
      when  6 =>                                        -- OR sX, kk
        aluOutInt <= opA or opB;
        cOut      <= '0';
      when  7 =>                                        -- XOR sX, kk
        aluOutInt <= opA xor opB;
        cOut      <= '0';
      when  9 =>                                        -- TEST sX, kk
        aluOutInt <= opA and opB;
        xorAcc := '0';
        for index in aluOutInt'range loop
          xorAcc := xorAcc xor aluOutInt(index);
        end loop;
        cOut      <= xorAcc;
      when 10 =>                                        -- COMPARE sX, kk
        yArith    <= aArith - bArith;
        aluOutInt <= yArith(aluOut'range);
        cOut      <= yArith(yArith'high);
      when 12 =>                                        -- ADD sX, kk
        yArith    <= aArith + bArith;
        aluOutInt <= yArith(aluOut'range);
        cOut      <= yArith(yArith'high);
      when 13 =>                                        -- ADDCY sX, kk
        yArith    <= (aArith + bArith) + cInArith;
        aluOutInt <= yArith(aluOut'range);
        cOut      <= yArith(yArith'high);
      when 14 =>                                        -- SUB sX, kk
        yArith    <= aArith - bArith;
        aluOutInt <= yArith(aluOut'range);
        cOut      <= yArith(yArith'high);
      when 15 =>                                        -- SUBCY sX, kk
        yArith    <= (aArith - bArith) - cInArith;
        aluOutInt <= yArith(aluOut'range);
        cOut      <= yArith(yArith'high);
      when 16 to 23 =>                                  -- SL sX
        aluOutInt <= opA(opA'high-1 downto 0) & cInShift;
        cOut      <= opA(opA'high);
      when 24 to 31 =>                                  -- SR sX
        aluOutInt <= cInShift & opA(opA'high downto 1);
        cOut      <= opA(0);
      when others =>
        aluOutInt <= (others => '-');
    end case;
  end process aluOperation;

  aluOut <= aluOutInt;
  zero <= '1' when aluOutInt = 0 else '0';

END ARCHITECTURE RTL;
