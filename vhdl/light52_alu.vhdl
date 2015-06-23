--------------------------------------------------------------------------------
-- light52_alu.vhdl -- ALU and its input operand multiplexors.
--------------------------------------------------------------------------------
-- This module contains the ALU, its input operand registers (called T and V)
-- and the input multiplexors for those registers.
-- It contains the ACC and B SFRs, whose operation is tightly coupled to the 
-- ALU functionality.
--
-- Note that the ALU has a strong dependence on the CPU state machine: the 
-- state is used to control the input register multiplexors, to sequence the 
-- operation of the DA function and to control when (and with what) the ACC
-- is loaded.
--
--------------------------------------------------------------------------------
-- GENERICS:
--
-- IMPLEMENT_BCD_INSTRUCTIONS   -- Whether or not to implement BCD instructions.
--  When true, instructions DA and XCHD will work as in the original MCS51.
--  When false, those instructions will work as NOP, saving some logic.
--
-- SEQUENTIAL_MULTIPLIER        -- Sequential vs. combinational multiplier.
--  When true, a sequential implementation will be used for the multiplier, 
--  which will usually save a lot of logic or a dedicated multiplier.
--  When false, a combinational registered multiplier will be used.
--  (NOT IMPLEMENTED -- setting it to true will raise an assertion failure).
--
--------------------------------------------------------------------------------
-- SIGNAL INTERFACE:
--
-- A description of the many signals will be of little use because most of them
-- are self-explaining, I hope. Instead, I will only describe those signals 
-- whose purpose may be somewhat more obscure:
--
-- nobit_result :       ALU result that excludes the 'bit operations' .
--                      Used only to load DPTR; it's faster because we bypass
--                      the 'bit' mux (DPH & DPL aren't bit addressable).
--
-- FIXME the ALU needs to be diagrammed and coeumtnted in a design doc.
--------------------------------------------------------------------------------
-- Copyright (C) 2012 Jose A. Ruiz
--
-- This source file may be used and distributed without
-- restriction provided that this copyright statement is not
-- removed from the file and that any derivative work contains
-- the original copyright notice and the associated disclaimer.
--
-- This source file is free software; you can redistribute it
-- and/or modify it under the terms of the GNU Lesser General
-- Public License as published by the Free Software Foundation;
-- either version 2.1 of the License, or (at your option) any
-- later version.
--
-- This source is distributed in the hope that it will be
-- useful, but WITHOUT ANY WARRANTY; without even the implied
-- warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
-- PURPOSE.  See the GNU Lesser General Public License for more
-- details.
--
-- You should have received a copy of the GNU Lesser General
-- Public License along with this source; if not, download it
-- from http://www.opencores.org/lgpl.shtml
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.light52_pkg.all;
use work.light52_ucode_pkg.all;

entity light52_alu is
    generic (
        SEQUENTIAL_MULTIPLIER : boolean := false;
        IMPLEMENT_BCD_INSTRUCTIONS : boolean := false
    );
    port(
        clk             : in std_logic;
        reset           : in std_logic;

        result          : out t_byte;
        nobit_result    : out t_byte;

        xdata_wr        : out std_logic_vector(7 downto 0);
        xdata_rd        : in std_logic_vector(7 downto 0);

        iram_sfr_rd     : in t_byte;
        code_rd         : in std_logic_vector(7 downto 0);
        ACC             : out t_byte;
        B               : out t_byte;

        cy_in           : in std_logic;
        ac_in           : in std_logic;

        result_is_zero  : out std_logic;
        acc_is_zero     : out std_logic;
        cy_out          : out std_logic;
        ov_out          : out std_logic;
        p_out           : out std_logic;
        op_sel          : in t_alu_op_sel;


        alu_fn_reg      : in t_alu_fns;
        bit_index_reg   : in unsigned(2 downto 0);
        load_acc_sfr    : in std_logic;
        load_acc_out    : out std_logic;
        bit_input_out   : out std_logic;
        ac_out          : out std_logic;

        load_b_sfr      : in std_logic;
        mul_ready       : out std_logic;
        div_ready       : out std_logic;

        use_bitfield    : in std_logic;

        ps              : t_cpu_state
    );
end entity light52_alu;


architecture plain of light52_alu is

---- Datapath ------------------------------------------------------------------

-- ALU control signals
signal alu_ctrl_fn_arith :  unsigned(2 downto 0);
signal alu_ctrl_fn_logic :  unsigned(1 downto 0);
signal alu_ctrl_fn_shift :  unsigned(1 downto 0);
signal alu_ctrl_mux_2 :     std_logic;
signal alu_ctrl_mux_1 :     std_logic;
signal alu_ctrl_mux_0 :     std_logic;

-- ALU operands and intermediate results
signal alu_op_0 :           t_byte;
signal alu_op_sel :         t_alu_op_sel;
signal alu_op_1 :           t_byte;
-- adder_cy_in: carry input into the adder/subtractor
signal adder_cy_in :        std_logic;
-- adder_cy_integer: integer version of adder_cy_in.
signal adder_cy_integer :   integer range 0 to 1;
signal adder_op_0 :         t_ebyte;
signal adder_op_1 :         t_ebyte;
signal adder_op_1_comp :    t_ebyte;
signal alu_adder_result :   t_ebyte;
signal alu_logic_result :   t_byte;
signal alu_swap_result :    t_byte;
signal alu_shift_result :   t_byte;
signal alu_ext_result :     t_byte;
signal alu_shift_ext_result : t_byte;
signal alu_log_shift_result : t_byte;

signal div_ov :             std_logic;
signal mul_ov :             std_logic;
signal ext_ov :             std_logic;
signal arith_ov :           std_logic;
signal arith_ov_add :       std_logic;
signal arith_ov_sub :       std_logic;

signal bitfield_result :    t_byte;
signal bitfield_mask :      t_byte;

signal alu_cy_shift :       std_logic;
signal alu_cy_arith :       std_logic;
signal alu_cy_arith_shift : std_logic;
signal alu_bit_result :     std_logic;
signal bit_input :          std_logic;
signal P_flag :             std_logic;


signal alu_result :         t_byte;
signal result_internal :    t_byte;

signal alu_bit_fn_reg :     t_bit_fns;

---- CPU programmer's model registers & temp registers -------------------------

signal A_reg :              t_byte;
signal B_reg :              t_byte;
signal parity_4 :           unsigned(3 downto 0);
signal parity_2 :           unsigned(1 downto 0);
signal T_reg :              t_byte;
signal V_reg :              t_byte;
signal P_flag_reg :         std_logic;

signal load_acc_implicit :  std_logic;
-- load_acc: asserted for implicit ACC updates and for SFR writes to ACC
signal load_acc :           std_logic;
signal load_acc_div :       std_logic;
signal load_acc_mul :       std_logic;
-- acc_input: value to be loaded on ACC
signal acc_input :          t_byte;
signal load_t :             std_logic_vector(1 downto 0);
signal load_v :             std_logic;

---- Interface to MUL/DIV unit -------------------------------------------------

signal product :            t_word;
signal quotient :           t_byte;
signal remainder :          t_byte;
signal start_muldiv :       std_logic;
signal mul_ready_internal : std_logic;
signal div_ready_internal : std_logic;

---- BCD logic -----------------------------------------------------------------

signal da_add :             unsigned(8 downto 0);
signal da_add_lsn :         unsigned(3 downto 0);
signal da_add_msn :         unsigned(3 downto 0);
signal A_reg_ext :          unsigned(8 downto 0);
signal da_res :             unsigned(8 downto 0);
signal da_cy :              std_logic;
signal da_int_cy :          std_logic;
signal ext_cy :             std_logic;

signal xchd_res :           unsigned(7 downto 0);

-- Function to compute carry out of a given adder stage
function carry_stage(sub:  std_logic;
                     a_in: std_logic;
                     b_in: std_logic;
                     outp: std_logic) return std_logic is
variable bits : std_logic_vector(3 downto 0);
begin
    bits := (sub, a_in, b_in, outp);

    case bits is
    when "0010" | "0100" | "0110" | "0111" |
         "1001" | "1010" | "1011" | "1101" |
         "1111" =>                          return '1';
    when others =>                          return '0';
    end case;
end function carry_stage;


begin

-- Extract the ALU control bits from the decoded ALU operation code.
-- First the function selector code...
alu_ctrl_fn_arith <= alu_fn_reg(5 downto 3);
alu_ctrl_fn_logic <= alu_fn_reg(4 downto 3);
alu_ctrl_fn_shift <= alu_fn_reg(4 downto 3);
-- ...then the multiplexor control bits.
alu_ctrl_mux_2 <= alu_fn_reg(2);
alu_ctrl_mux_1 <= alu_fn_reg(1);
alu_ctrl_mux_0 <= alu_fn_reg(0);


-- Parity logic.
-- Note that these intermediate signals will be optimized away; the parity logic
-- will take the equivalent of 3 4-input LUTs.
parity_4 <= acc_input(7 downto 4) xor acc_input(3 downto 0);

parity_2 <= parity_4(3 downto 2) xor parity_4(1 downto 0);
P_flag <= parity_2(1) xor parity_2(0);

parity_flag_register:
process(clk)
begin
    if clk'event and clk='1' then
        if reset = '1' then
            -- Reset value is unnecessary; we use it so we don't have to argue
            -- for an exception to the design rules (@note2).
            P_flag_reg <= '0';
        else
            if load_acc = '1' then
                -- Load P flag register whenever ACC is updated.
                P_flag_reg <= P_flag;
            end if;
        end if;
    end if;
end process parity_flag_register;

p_out <= P_flag_reg;

-- FIXMe move this to some other code section
acc_is_zero <= '1' when A_reg=X"00" else '0';




ACC <= A_reg;

xdata_wr <= std_logic_vector(A_reg);

---- Datapath: ALU and ALU operand multiplexors --------------------------------


-- ALU input operand mux control. All instructions that use the ALU shall
-- have a say in this logic through the state machine register.
with ps select alu_op_sel <=
    AI_A_T              when cjne_a_imm_1,
    AI_A_T              when cjne_a_dir_2,
    AI_V_T              when cjne_ri_imm_4,
    AI_V_T              when cjne_rn_imm_2,
    AI_T_0              when djnz_dir_2,
    AI_T_0              when djnz_dir_3,
    AI_T_0              when push_2,
    AI_T_0              when mov_dptr_1,
    AI_T_0              when mov_dptr_2,
    AI_A_0              when xch_2,
    AI_T_0              when xch_3,
    AI_A_T              when alu_xchd_4 | alu_xchd_5,
    op_sel              when others; -- by default, use logic for ALU class


-- ALU input operand multiplexor: OP0 can be A, V or T.
with alu_op_sel(3 downto 2) select alu_op_0 <=
    A_reg           when "01",
    V_reg           when "10",
    T_reg           when others;

-- ALU input operand multiplexor: OP1 can be T or 0.
with alu_op_sel(1 downto 0) select alu_op_1 <=
    T_reg           when "01",
    X"00"           when others;


-- Datapath: ALU ---------------------------------------------------------------

-- ALU: logic operations (1-LUT deep)
with alu_ctrl_fn_logic select alu_logic_result <=
    alu_op_0 and alu_op_1       when "00",
    alu_op_0 or  alu_op_1       when "01",
    alu_op_0 xor alu_op_1       when "10",
    not alu_op_0                when others;

-- ALU: SWAP logic; operates on logic result
with alu_ctrl_mux_2 select alu_swap_result <=
    alu_logic_result(3 downto 0) & alu_logic_result(7 downto 4) when '1',
    alu_logic_result                                            when others;

-- ALU: shift operations
with alu_ctrl_fn_shift select alu_shift_result <=
    alu_op_0(0) & alu_op_0(7 downto 1)      when "00",      -- RR
    cy_in & alu_op_0(7 downto 1)            when "01",      -- RRC
    alu_op_0(6 downto 0) & alu_op_0(7)      when "10",      -- RL
    alu_op_0(6 downto 0) & cy_in            when others;    -- RLC

with alu_ctrl_fn_logic(1) select alu_cy_shift <=
    alu_op_0(0) when '0',
    alu_op_0(7) when others;

-- ALU: adder/subtractor (2 LUTs deep, 8-bit carry chain)

-- Carry/borrow input, accounting for all operations that need it
with alu_ctrl_fn_arith(2 downto 0) select adder_cy_in <=
    '0'             when "000", -- ADD
    '1'             when "001", -- SUB
    cy_in           when "010", -- ADDC
    not cy_in       when "011", -- SUBB
    '1'             when "110", -- INC
    '0'             when others;-- DEC

-- Note we do zero-extension and not sign-extension because we just want to
-- get the value of CY from bit 7 and this is most easily done with zero-ext.

-- ALU operands are ZERO extended before entering the adder...
adder_op_0 <= '0' & alu_op_0;
-- ...and op1 (subtrahend) is negated for substract operations.
-- Note this is a complement-to-1 only; we need to adjust the carry input for
-- the adder op to be performed (see @note5).
with alu_ctrl_fn_arith(0) select adder_op_1_comp <=
    ('0' & alu_op_1)        when '0',
    ('1' & not alu_op_1)    when others;
-- The adder carry input needs some syntactic trickery: std_logic to integer.
adder_cy_integer <= 1 when adder_cy_in='1' else 0;

adder_op_1 <= adder_op_1_comp;-- + adder_cy_integer;
-- This is the actual adder/subtractor.
alu_adder_result <= adder_op_0 + adder_op_1 + adder_cy_integer;

-- Compute OV by comparing operand and result signs.
arith_ov_add <= '1' when
    (alu_op_0(7)='0' and alu_op_1(7)='0' and alu_adder_result(7)='1') or
    (alu_op_0(7)='1' and alu_op_1(7)='1' and alu_adder_result(7)='0')
    else '0';

arith_ov_sub <= '1' when
    (alu_op_0(7)='0' and alu_op_1(7)='1' and alu_adder_result(7)='1') or
    (alu_op_0(7)='1' and alu_op_1(7)='0' and alu_adder_result(7)='0')
    else '0';

arith_ov <= arith_ov_add when alu_ctrl_fn_arith(0)='0' else arith_ov_sub;

-- Carry/borrow output is the 9th bit of the result.
alu_cy_arith <= alu_adder_result(8);

-- This is the 'half carry' or 'aux carry': carry out of stage 3.
ac_out <= carry_stage(alu_ctrl_fn_arith(0),
                      alu_op_0(3),alu_op_1(3),
                      alu_adder_result(3));



-- ALU: result path multiplexors

with alu_ctrl_mux_2 select alu_shift_ext_result <=
    alu_ext_result      when '1',
    alu_shift_result    when others;

with alu_ctrl_mux_1 select alu_log_shift_result <=
    alu_swap_result         when '0',
    alu_shift_ext_result    when others;

with alu_ctrl_mux_0 select alu_result <=
    alu_log_shift_result            when '0',
    alu_adder_result(7 downto 0)    when others;


alu_cy_arith_shift <= alu_cy_arith when alu_ctrl_mux_0='1' else alu_cy_shift;

ext_cy <= da_cy when ps=alu_daa_1 or ps=alu_daa_0 else '0';

with alu_fn_reg(2 downto 0) select cy_out <=
    alu_bit_result      when "011" | "111", -- bit operations
    ext_cy              when "110",         -- mul/div/bcd
    alu_cy_arith_shift  when others;

with alu_fn_reg(3) select ext_ov <=
    mul_ov  when '0',
    div_ov  when others;

with alu_fn_reg(2 downto 0) select ov_out <=
    ext_ov          when "110", -- mul/div
    arith_ov        when others;

result_is_zero <= '1' when alu_result=X"00" else '0';


-- Datapath: BIT ALU -----------------------------------------------------------


bit_input <= T_reg(to_integer(bit_index_reg));
bit_input_out <= bit_input;

-- Extract BIT ALU operation selector encoded into ALU operation field.
alu_bit_fn_reg <= alu_fn_reg(5 downto 2);

-- Part of the BIT ALU: unary/binary operations between C and bit_input.
with alu_bit_fn_reg select alu_bit_result <=
    '0'                         when AB_CLR,
    '1'                         when AB_SET,
    not cy_in                   when AB_CPLC,
    cy_in                       when AB_C,
    bit_input                   when AB_B,
    bit_input and cy_in         when AB_ANL,
    bit_input or cy_in          when AB_ORL,
    (not bit_input) and cy_in   when AB_ANL_NB,
    (not bit_input) or cy_in    when AB_ORL_NB,
    not bit_input               when others;

-- Highlight the operand bit within its byte. Useful when reassembling the
-- byte after operating on the bit. This should synth as an 8-LUT block.
with bit_index_reg select bitfield_mask <=
    "10000000" when "111",
    "01000000" when "110",
    "00100000" when "101",
    "00010000" when "100",
    "00001000" when "011",
    "00000100" when "010",
    "00000010" when "001",
    "00000001" when others;

-- Reassemble the byte; replace the operand bit with the op result and leave
-- all other bits unchanged. Ideally this is a single LUT row.
bitfield_mask_logic:
for i in 0 to 7 generate
    bitfield_result(i) <=
        alu_bit_result when bitfield_mask(i)='1' else
        T_reg(i);
end generate;


-- Datapath: ALU result load enable signals ------------------------------------

nobit_result <= alu_result; -- FIXME remove remnants of this

with use_bitfield select result_internal <=
    bitfield_result     when '1',
    alu_result          when others;

result <= result_internal;

-- Assert load_acc_implicit for all states that update ACC implicitly, that is,
-- do not account for SFR accesses to ACC.
with ps select load_acc_implicit <=
    '1' when alu_res_to_a,
    '1' when movx_a_dptr_0,
    '1' when movx_a_ri_3,
    '1' when movc_1,
    '1' when xch_3,
    '1' when alu_xchd_5,
    '1' when alu_daa_0 | alu_daa_1,
    '0' when others;


load_acc_mul <= '1' when ps=alu_mul_0 and mul_ready_internal='1' else '0';
load_acc_div <= '1' when ps=alu_div_0 and div_ready_internal='1' else '0';

-- ACC will be loaded by implicit addressing and by explicit SFR addressing.
-- Note the data source is the same in both cases.
load_acc <= load_acc_implicit or load_acc_sfr or load_acc_mul or load_acc_div;
load_acc_out <= load_acc;
-- FIXME explain
with ps select acc_input <=
    unsigned(xdata_rd)      when movx_a_dptr_0 | movx_a_ri_3,
    unsigned(code_rd)       when movc_1,
    result_internal         when others;


ACC_register:
process(clk)
begin
    if clk'event and clk='1' then
        if reset = '1' then
            A_reg <= (others => '0');
        elsif load_acc='1' then
            A_reg <= acc_input;
        end if;
    end if;
end process ACC_register;

-- T_reg will have the 2nd alu operand when needed: #imm, dir or xram data
with ps select load_t <=
    -- Load T with RAM/SFR data...
    "10" when alu_ram_to_t_code_to_ab,
    "10" when alu_ram_to_t_rx_to_ab,
    "10" when alu_ram_to_t,
    "10" when cjne_a_dir_1,
    "10" when djnz_dir_1,
    "10" when jrb_bit_1,
    "10" when bit_op_1,
    "10" when push_1,
    "10" when pop_1,
    "10" when xch_1,
    "10" when alu_xchd_3,
    -- ... or with #imm data...
    "11" when alu_ram_to_v_code_to_t,
    "11" when alu_code_to_t_rx_to_ab,
    "11" when alu_code_to_t,
    "11" when cjne_a_imm_0,
    "11" when cjne_rn_imm_1,
    "11" when cjne_ri_imm_3,
    "11" when mov_dptr_0,
    "11" when mov_dptr_1,
    -- ...or don't load T
    "00" when others;

with ps select load_v <=
    '1' when alu_ram_to_v_code_to_t,
    '1' when cjne_ri_imm_3,
    '1' when cjne_rn_imm_1,
    '0' when others;

-- FIXME Temp registers have no reset value.
TEMP_registers:
process(clk)
begin
    if clk'event and clk='1' then
        if load_t(1)='1' then
            if load_t(0)='1' then
                T_reg <= unsigned(code_rd); -- #imm data
            else
                T_reg <= unsigned(iram_sfr_rd); -- [dir] data
            end if;
        end if;

        if load_v='1' then
            V_reg <= unsigned(iram_sfr_rd);
        end if;
    end if;
end process TEMP_registers;

-- Multiplication/division unit ------------------------------------------------

muldiv : entity work.light52_muldiv
generic map (
    SEQUENTIAL_MULTIPLIER => SEQUENTIAL_MULTIPLIER
)
port map (
    clk =>              clk,
    reset =>            reset,

    data_a =>           A_reg,
    data_b =>           B_reg,
    start =>            start_muldiv,

    prod_out =>         product,
    quot_out =>         quotient,
    rem_out =>          remainder,
    div_ov_out =>       div_ov,
    mul_ov_out =>       mul_ov,

    mul_ready =>        mul_ready_internal,
    div_ready =>        div_ready_internal
);

start_muldiv <= load_acc or load_b_sfr;


mul_ready <= mul_ready_internal;
div_ready <= div_ready_internal;

b_register:
process(clk)
begin
    if clk'event and clk='1' then
        if load_b_sfr='1' then
            B_reg <= result_internal;
        elsif load_acc_mul='1' then
            B_reg <= product(15 downto 8);
        elsif load_acc_div='1' then
            B_reg <= remainder;
        end if;
    end if;
end process b_register;

B <= B_reg;

full_alu_mux:
if IMPLEMENT_BCD_INSTRUCTIONS generate
with ps select alu_ext_result <=
    quotient                when alu_div_0,
    da_res(7 downto 0)      when alu_daa_0 | alu_daa_1,
    xchd_res                when alu_xchd_4 | alu_xchd_5,
    product(7 downto 0)     when others;
end generate;

unimplemented_bcd_alu_mux:
if not IMPLEMENT_BCD_INSTRUCTIONS generate
with ps select alu_ext_result <=
    quotient                when alu_div_0,
    product(7 downto 0)     when others;
end generate;

---- BCD logic -----------------------------------------------------------------


bcd_logic:
if IMPLEMENT_BCD_INSTRUCTIONS generate

-- DA logic ---------- Done in 2 cycles mimicking the datasheet description.
 
-- IF A(low)>9 OR AC='1' then A+=0x06. This is done in state alu_daa_0.
da_add_lsn <= "0110" when (ac_in='1' or to_integer(A_reg(3 downto 0))>9) and
                          ps=alu_daa_0
              else "0000";

-- IF A(high)>9 OR the previous addition of 0x06 generated a carry OR 
-- the carry flag was already set, then A+=0x60. Done in state alu_daa_1.
da_add_msn <= "0110" when (da_int_cy='1' or cy_in='1' or 
                           to_integer(A_reg(7 downto 4))>9) and
                          ps=alu_daa_1
              else "0000";

da_add <= '0' & da_add_msn & da_add_lsn;
A_reg_ext <= '0' & A_reg;
da_res <= A_reg_ext + da_add;

-- Carry generated in the 1st state od DAA
da_cy_ff:
process(clk)
begin
    if clk'event and clk='1' then
        da_int_cy <= da_res(8);
    end if;
end process da_cy_ff;

-- Final carry is 1 if either sum generated a carry OR if it was already set.
da_cy <= (da_res(8) xor da_int_cy) or cy_in;


-- XCHD logic --------- Done in 2 cycles to simplify the state machine.

-- This operation is state-dependent. An ugly hack that saves logic.
with ps select xchd_res <= 
    alu_op_1(7 downto 4) & alu_op_0(3 downto 0)     when alu_xchd_4,
    alu_op_0(7 downto 4) & alu_op_1(3 downto 0)     when others;


end generate;

dummy_bcd_logic:
if not IMPLEMENT_BCD_INSTRUCTIONS generate
da_cy <= '0';
end  generate;

    

end architecture plain;
