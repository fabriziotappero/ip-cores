library ieee;
use ieee.std_logic_1164.all;

-- PREFIX: ash_xxx
package armshiefter is

-- Addressing modes:
-- DAta PRocessing Addressing Modes      : DAPRAM
-- LoaD/STore Addressing Modes           : LDSTAM
-- Load/Store misc (V4) Addressing Modes : LSV4AM

-- Share shiefter for DAPRAM  and LDSTAM addressing modes
-- operands:
--                               data1  data2   value   shieftval
-- ade_styp_immrot(DAPRAM):        -      -      imm      imm 
-- ade_styp_simm(DAPRAM+LDSTAM):   -     use    data2     imm
-- ade_styp_sreg(DAPRAM):         use    use    data1    data2
-- ade_styp_none:                  -     use    data2      0

type ash_styp is (
  ash_styp_none,  -- no shieft
  ash_styp_immrot,-- DAPRAM: OP2 immidiate rotated
  ash_styp_simm,  -- DAPRAM: OP2 shieft with imm, LDSTAM: addr v1 reg (adm_LDSTAM_reg) 
  ash_styp_sreg   -- DAPRAM: OP2 shieft with reg  
);       

type ash_sdir is (
  ash_sdir_snone,    -- no shieft
  ash_sdir_slsl,     -- LSL #: logical shieft left 
  ash_sdir_slsr,     -- LSR #: logical shieft righ
  ash_sdir_sasr,     -- ASR #: arithmetic shieft left
  ash_sdir_sror,     -- ROR #: rotate 
  ash_sdir_srrx      -- RRX #: rotate 1 with carry
);

-- Shiefter of rsstg
procedure aas_shieft(
  insn  : in std_logic_vector(31 downto 0);
  dir   : in ash_sdir;
  typ   : in ash_styp;
  data1 : in std_logic_vector(31 downto 0);
  data2 : in std_logic_vector(31 downto 0);
  carry : in std_logic;
  shieftout      : out std_logic_vector(31 downto 0);
  shieftcarryout : out std_logic
);

end armshiefter;

package body armshiefter is

constant ASH_DAPRAMxLDSTAM_IMMROT_U : integer := 11; -- imm rot amount
constant ASH_DAPRAMxLDSTAM_IMMROT_D : integer := 8;   
constant ASH_DAPRAMxLDSTAM_IMM_U    : integer := 7;  -- imm const
constant ASH_DAPRAMxLDSTAM_IMM_D    : integer := 0;   
constant ASH_DAPRAMxLDSTAM_SIMM_U   : integer := 11; -- shieft immidiate amount
constant ASH_DAPRAMxLDSTAM_SIMM_D   : integer := 7;

type shift_src is (shiftin_00,shiftin_32,shiftin_33,shiftin_prev);

procedure aas_shieft(
  insn  : in std_logic_vector(31 downto 0);
  dir   : in ash_sdir;
  typ   : in ash_styp;
  data1 : in std_logic_vector(31 downto 0);
  data2 : in std_logic_vector(31 downto 0);
  carry : in std_logic;
  shieftout      : out std_logic_vector(31 downto 0);
  shieftcarryout : out std_logic
) is  
variable op1 : std_logic_vector(31 downto 0);
variable op2 : std_logic_vector(4 downto 0);                        
variable shiftin : std_logic_vector(64 downto 0);
variable carryout : std_logic;
variable carryoutsrc : shift_src;
begin
  
  carryoutsrc := shiftin_prev;
  carryout := carry;
  
  op1 := data1;
  op2 := (others => '0');
  shiftin := (others => '0');
  shiftin(32 downto 1) := data1;
  
  --                                       data1  data2   value   shieftval
  -- adm_DAPRAMxLDSTAM_DAPRAM_immrot:        -      -      imm      imm 
  -- adm_DAPRAMxLDSTAM_DAPRAMxLDSTAM_simm:   -     use    data2     imm
  -- adm_DAPRAMxLDSTAM_DAPRAM_sreg:         use    use    data1    data2
  -- adm_DAPRAMxLDSTAM_DAPRAM_none:          -     use    data2      0
  
  case typ is
    when ash_styp_immrot  => -- (special msr case also)
      
      --  64  63               33  32 31          1  0
      -- +---+---+---------------+===+=============+---+
      -- |           op1         |       op1       | 0 |
      -- +---+---+---------------+ccc+=============+---+
      --         |    op1            |                   <<  1 (>>1) 
      --                      |       op1       |        << 31 (>>31)
      
      op1 := (others => '0');
      op1(7 downto 0) := insn(ASH_DAPRAMxLDSTAM_IMM_U downto ASH_DAPRAMxLDSTAM_IMM_D);
      
      shiftin := (others => '0');
      shiftin(32 downto 1) := op1;
      shiftin(64 downto 33) := op1;
      op2 := insn(ASH_DAPRAMxLDSTAM_IMMROT_U downto ASH_DAPRAMxLDSTAM_IMMROT_D) & "0";
      
      carryoutsrc := shiftin_32;

      if op2 = "00000" then -- == 0
        carryoutsrc := shiftin_prev;
        carryout := carry;
      end if;
      
    when ash_styp_simm =>

      shiftin := (others => '0');
      shiftin(32 downto 1) := data2;
      
      case dir  is 
        when ash_sdir_slsl =>
          
          --$(del)
          --if shift_imm == 0 then /* Register Operand */
          --  shifter_operand = Rm
          --  shifter_carry_out = C Flag
          --else /* shift_imm > 0 */
          --  shifter_operand = Rm Logical_Shift_Left shift_imm
          --  shifter_carry_out = Rm[32 - shift_imm]
          --$(/del)

          --  64  63               33  32 31          1  0
          -- +---+---+---------------+===+=============+---+
          -- | c |           op1         |    000      | 0 |
          -- +---+---+------------ccc+===+=============+---+
          --       c |    op1            |                   << 31 (>>0)
          --                       c |       op1       |     << 0 (>>31)
            
          shiftin := (others => '0');
          shiftin(64) := carry;
          shiftin(63 downto 32) := data2;
          op2 := not insn(ASH_DAPRAMxLDSTAM_SIMM_U downto ASH_DAPRAMxLDSTAM_SIMM_D);
          
          carryoutsrc := shiftin_33;
          
        when ash_sdir_slsr =>
          
          --$(del)
          --if shift_imm == 0 then
          --  shifter_operand = 0
          --  shifter_carry_out = Rm[31]
          --else /* shift_imm > 0 */
          --  shifter_operand = Rm Logical_Shift_Right shift_imm
          --  shifter_carry_out = Rm[shift_imm - 1]
          --$(/del)
          
          --  64  63               33  32 31          1  0
          -- +---+---+---------------+===+=============+---+
          -- | 0 | 0 |    000        |        op1      | c |
          -- +---+---+---------------+===+=============+ccc+
          --                         |     op1         |     >> 0
          --                                       |op1|     >> 31 
          
          shiftin := (others => '0');
          shiftin(0) := carry;
          shiftin(32 downto 1) := data2;
          op2 := insn(ASH_DAPRAMxLDSTAM_SIMM_U downto ASH_DAPRAMxLDSTAM_SIMM_D);

          carryoutsrc := shiftin_00;
          
        when ash_sdir_sasr =>
          --$(del)
          --if shift_imm == 0 then
          --  if Rm[31] == 0 then
          --    shifter_operand = 0
          --    shifter_carry_out = Rm[31]
          --  else /* Rm[31] == 1 */
          --    shifter_operand = 0xFFFFFFFF
          --    shifter_carry_out = Rm[31]
          --else /* shift_imm > 0 */
          --  shifter_operand = Rm Arithmetic_Shift_Right <shift_imm>
          --  shifter_carry_out = Rm[shift_imm - 1]
          --$(/del)

          --  64  63               33  32 31          1  0
          -- +---+---+---------------+===+=============+---+
          -- | s | s |    sss        |        op1      | c |
          -- +---+---+---------------+===+=============+ccc+
          --                           s |    op1      |     >> 1
          --                                  sss  |op1|     >> 31 
          --                                  000      | 0   >> 0 (s=0)
          --                                  111      | 1   >> 0 (s=1)
          if data2(31) = '1' then
            shiftin(64 downto 33) := (others => '1');
          else
            shiftin(64 downto 33) := (others => '0');
          end if;
          shiftin(0) := carry;
          shiftin(32 downto 1) := data2;
          op2 := insn(ASH_DAPRAMxLDSTAM_SIMM_U downto ASH_DAPRAMxLDSTAM_SIMM_D);
          
          if op2 = "00000" then
            if data2(31) = '1' then
              shiftin(32 downto 0) := (others => '1');
            else
              shiftin(32 downto 0) := (others => '0');
            end if;
          end if;
          
          carryoutsrc := shiftin_00;
      
        when ash_sdir_sror =>
          
          --$(del)
          --if shift_imm == 0 then
          --  ash_sdir_srrx case
          --else /* shift_imm > 0 */
          --  shifter_operand = Rm Rotate_Right shift_imm
          --  shifter_carry_out = Rm[shift_imm - 1]
          --$(/del)

          --  64  63               33  32 31          1  0
          -- +---+---+---------------+===+=============+---+
          -- |           op1         |       op1       | 0 |
          -- +---+---+---------------+ccc+=============+---+
          --         |    op1            |                   <<  1 (>>1) 
          --                      |       op1       |        << 31 (>>31)

          shiftin := (others => '0');
          shiftin(64 downto 33) := data2;
          shiftin(32 downto 1) := data2;
          op2 := insn(ASH_DAPRAMxLDSTAM_SIMM_U downto ASH_DAPRAMxLDSTAM_SIMM_D);
          
          carryoutsrc := shiftin_32;
          
        when ash_sdir_srrx =>
      
          --$(del)
          --shifter_operand = (C Flag Logical_Shift_Left 31) OR (Rm Logical_Shift_Right 1)
          --shifter_carry_out = Rm[0]
          --$(/del)

          --  64  63               33  32 31          1  0
          -- +---+---+---------------+===+=============+---+
          -- |           000         | c |    op1-1        |
          -- +---+---+---------------+===+=============+ccc+
          --                                                 : rrx 
          
          shiftin(31 downto 0) := data2;
          shiftin(32) := carry;
          op2 := (others => '0');
          
          carryoutsrc := shiftin_00;
          
        when ash_sdir_snone =>
          op2 := (others => '0');
        when others => null;
      end case;


      
    when ash_styp_sreg =>

      shiftin := (others => '0');
      shiftin(32 downto 1) := data1;

      case dir  is 
        when ash_sdir_slsl =>
      
          --$(del)
          --if Rs[7:0] == 0 then
          --  shifter_operand = Rm
          --  shifter_carry_out = C Flag
          --else if Rs[7:0] < 32 then
          --  shifter_operand = Rm Logical_Shift_Left Rs[7:0]
          --  shifter_carry_out = Rm[32 - Rs[7:0]]
          --else if Rs[7:0] == 32 then
          --  shifter_operand = 0
          --  shifter_carry_out = Rm[0]
          --else /* Rs[7:0] > 32 */
          --  shifter_operand = 0
          --  shifter_carry_out = 0
          --$(/del)

          --  64  63               33  32 31          1  0
          -- +---+---+---------------+===+=============+---+
          -- | c |           op1         |    000      | 0 |
          -- +---+---+------------ccc+===+=============+---+
          --       c |    op1            |                   << 31 (>>0)
          --                       c |       op1       |     << 0 (>>31)
            
          shiftin := (others => '0');
          shiftin(64) := carry;
          shiftin(63 downto 32) := data1;
          op2 := not data2(4 downto 0);
          
          carryoutsrc := shiftin_33;
          
          if not (data2(7 downto 5) = "000") then -- >= 32
            shiftin := (others => '0');
            if data2(7 downto 0) = "00100000" then  -- == 32
              carryoutsrc := shiftin_prev;
              carryout := data1(0);
            end if;
          end if;
          
        when ash_sdir_slsr =>

          --$(del)
          --if Rs[7:0] == 0 then
          --  shifter_operand = Rm
          --  shifter_carry_out = C Flag
          --else if Rs[7:0] < 32 then
          --  shifter_operand = Rm Logical_Shift_Right Rs[7:0]
          --  shifter_carry_out = Rm[Rs[7:0] - 1]
          --else if Rs[7:0] == 32 then
          --  shifter_operand = 0
          --  shifter_carry_out = Rm[31]
          --else /* Rs[7:0] > 32 */
          --  shifter_operand = 0
          --  shifter_carry_out = 0
          --$(/del)
      
          --  64  63               33  32 31          1  0
          -- +---+---+---------------+===+=============+---+
          -- | 0 | 0 |    000        |        op1      | c |
          -- +---+---+---------------+===+=============+ccc+
          --                         |     op1         |     >> 0
          --                                       |op1|     >> 31 
          
          shiftin := (others => '0');
          shiftin(0) := carry;
          shiftin(32 downto 1) := data1;
          op2 := data2(4 downto 0);

          carryoutsrc := shiftin_00;
          
          if not (data2(7 downto 5) = "000") then -- >= 32
            shiftin := (others => '0');
            if data2(7 downto 0) = "00100000" then  -- == 32
              carryoutsrc := shiftin_prev;
              carryout := data1(31);
            end if;
          end if;
          
        when ash_sdir_sasr =>
          --$(del)
          --if Rs[7:0] == 0 then
          --  shifter_operand = Rm
          --  shifter_carry_out = C Flag
          --else if Rs[7:0] < 32 then
          --  shifter_operand = Rm Arithmetic_Shift_Right Rs[7:0]
          --  shifter_carry_out = Rm[Rs[7:0] - 1]
          --else /* Rs[7:0] >= 32 */
          --  if Rm[31] == 0 then
          --    shifter_operand = 0
          --    shifter_carry_out = Rm[31]
          --  else /* Rm[31] == 1 */
          --    shifter_operand = 0xFFFFFFFF
          --    shifter_carry_out = Rm[31]
          --$(/del)

          --  64  63               33  32 31          1  0
          -- +---+---+---------------+===+=============+---+
          -- | s | s |    sss        |        op1      | c |
          -- +---+---+---------------+===+=============+ccc+
          --                           s |    op1      |     >> 1
          --                                  sss  |op1|     >> 31 
          --                                  000      | 0   >> 0 (s=0)
          --                                  111      | 1   >> 0 (s=1)
          if data1(31) = '1' then
            shiftin(64 downto 33) := (others => '1');
          else
            shiftin(64 downto 33) := (others => '0');
          end if;
          shiftin(0) := carry;
          shiftin(32 downto 1) := data1;
          op2 := data2(4 downto 0);
          
          if not (data2(7 downto 5) = "000") then -- >= 32
            if data1(31) = '1' then
              shiftin(32 downto 0) := (others => '1');
            else
              shiftin(32 downto 0) := (others => '0');
            end if;
          end if;
          
          carryoutsrc := shiftin_00;
      
        when ash_sdir_sror =>
      
          --$(del)
          --if Rs[7:0] == 0 then
          --  shifter_operand = Rm
          --  shifter_carry_out = C Flag
          --else if Rs[4:0] == 0 then
          --  shifter_operand = Rm 
          --  shifter_carry_out = Rm[31]
          --else /* Rs[4:0] > 0 */
          --  shifter_operand = Rm Rotate_Right Rs[4:0]
          --  shifter_carry_out = Rm[Rs[4:0] - 1]
          --$(/del)

          --  64  63               33  32 31          1  0
          -- +---+---+---------------+===+=============+---+
          -- |           op1         |       op1       | 0 |
          -- +---+---+---------------+ccc+=============+---+
          --         |    op1            |                   <<  1 (>>1) 
          --                      |       op1       |        << 31 (>>31)

          shiftin := (others => '0');
          shiftin(64 downto 33) := data1;
          shiftin(32 downto 1) := data1;
          op2 := data2(4 downto 0);
          
          carryoutsrc := shiftin_32;
          
          if data2(7 downto 0) = "00000000" then -- == 0
            carryoutsrc := shiftin_prev;
            carryout := carry;
          end if;
          
        when ash_sdir_srrx =>
      
          --$(del)
          --shifter_operand = (C Flag Logical_Shift_Left 31) OR (Rm Logical_Shift_Right 1)
          --shifter_carry_out = Rm[0]
          --$(/del)
          
          --  64  63               33  32 31          1  0
          -- +---+---+---------------+===+=============+---+
          -- |           000         | c |    op1-1        |
          -- +---+---+---------------+===+=============+ccc+
          --                                                 : rrx
          
          op2 := (others => '0');
          shiftin(31 downto 0) := carry & shiftin(31 downto 1);
          
        when ash_sdir_snone =>
        when others => null;
      end case;
      
    when ash_styp_none =>
      
      shiftin := (others => '0');
      shiftin(32 downto 1) := data2;
      
    when others => 
  end case;
  
  -- shifter
  if op2 (4) = '1' then
    shiftin(48 downto 0) := shiftin(64 downto 16);
  end if;
  if op2 (3) = '1' then
    shiftin(40 downto 0) := shiftin(48 downto 8);
  end if;
  if op2 (2) = '1' then
    shiftin(36 downto 0) := shiftin(40 downto 4);
  end if;
  if op2 (1) = '1' then
    shiftin(34 downto 0) := shiftin(36 downto 2);
  end if;
  if op2 (0) = '1' then
    shiftin(32 downto 0) := shiftin(33 downto 1);
  end if;

  -- carry out select
  case carryoutsrc is
    when shiftin_00   => carryout := shiftin(0);
    when shiftin_33   => carryout := shiftin(33);
    when shiftin_32   => carryout := shiftin(32);
    when shiftin_prev => 
    when others => null;
  end case;
    
  shieftout := shiftin(32 downto 1);
  shieftcarryout := carryout;
  
end;

end armshiefter;
