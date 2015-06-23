library ieee;
use ieee.std_logic_1164.all;
use IEEE.std_logic_unsigned.conv_integer;
use IEEE.std_logic_arith.conv_unsigned;
use work.int.all;
use work.memdef.all;
use work.armpctrl.all;
use work.armpmodel.all;
use work.armdecode.all;
use work.gendc_lib.all;

-- PREFIX: als_xxx
package armldst is
  
constant ALS_REGLIST_SZ : integer := 16;
constant ALS_REGLIST_U  : integer := 15;
constant ALS_REGLIST_D  : integer := 0;
constant ALS_REGLIST_pc : integer := 15;
constant ALS_REGLIST_ZERO : std_logic_vector(ALS_REGLIST_SZ-1 downto 0):= "0000000000000000";


-------------------------------------------------------------------------------
-- single load / store

-- Init size and signed for LDSTAM
procedure als_LDSTAM_init_size(
  insn : in std_logic_vector(31 downto 0);
  pctrl : inout apc_pctrl
);

-- Init size and signed for LSV4AM
procedure als_LSV4AM_init_size(
  insn : in std_logic_vector(31 downto 0);
  pctrl : inout apc_pctrl
);

-- Init address calc exop
procedure als_LDSTAMxLSV4AM_init_addsub(
  insn : in std_logic_vector(31 downto 0);
  pctrl : inout apc_pctrl
);

-------------------------------------------------------------------------------
-- multiple load / store

-- Count leading zeros
function als_getnextpos (
  insn    : in std_logic_vector(31 downto 0);
  reglist : in std_logic_vector(APM_REGLIST_SZ-1 downto 0)
) return std_logic_vector;

-- get inc/decrement offsets
procedure als_offsets (
  insn : in std_logic_vector(31 downto 0);
  startoff  : inout std_logic_vector(31 downto 0);
  endoff    : inout std_logic_vector(31 downto 0);
  incval    : inout std_logic_vector(31 downto 0)
);

-------------------------------------------------------------------------------

end armldst;

package body armldst is

procedure als_LDSTAM_init_size(
  insn : in std_logic_vector(31 downto 0);
  pctrl : inout apc_pctrl
) is
begin
  -- unsigned byte / word
  if insn(ADE_LDSTAM_UBYTE) = '1' then
    pctrl.me.meop_param.size  := lmd_byte;
    pctrl.me.meop_param.signed := '0';
  else
    pctrl.me.meop_param.size  := lmd_word;
    pctrl.me.meop_param.signed := '1';
  end if;
end;

procedure als_LSV4AM_init_size(
  insn : in std_logic_vector(31 downto 0);
  pctrl : inout apc_pctrl
) is
begin
  if insn(ADE_LSV4AM_SIGNED) = '1' then
    pctrl.me.meop_param.signed := '1';
  else
    pctrl.me.meop_param.signed := '0';
  end if;

  if insn(ADE_LSV4AM_HALF) = '1' then
    pctrl.me.meop_param.size  := lmd_half;
  else
    pctrl.me.meop_param.size  := lmd_byte;
  end if;
end;

procedure als_LDSTAMxLSV4AM_init_addsub(
  insn : in std_logic_vector(31 downto 0);
  pctrl : inout apc_pctrl
) is
begin
  if insn(ADE_LDSTAMxLSV4AM_ADD) = '1' then
    pctrl.ex.exop_aluop := ADE_OP_ADD;
  else
    pctrl.ex.exop_aluop := ADE_OP_SUB;
  end if;
end;

function als_getnextpos (
  insn    : in std_logic_vector(31 downto 0);
  reglist : in std_logic_vector(APM_REGLIST_SZ-1 downto 0)
) return std_logic_vector is
  variable part03_00   : std_logic_vector(3 downto 0);
  variable part07_04   : std_logic_vector(3 downto 0);
  variable part11_08   : std_logic_vector(3 downto 0);
  variable part15_12   : std_logic_vector(3 downto 0);
  variable part03_00ui : integer;
  variable part03_00di : integer;
  variable part07_04ui : integer;
  variable part07_04di : integer;
  variable part11_08ui : integer;
  variable part11_08di : integer;
  variable part15_12ui : integer;
  variable part15_12di : integer;
  variable src4        : std_logic_vector(3 downto 0);
  variable src4ui        : integer;
  variable src4di        : integer;
  variable srcu        : std_logic_vector(1 downto 0);
  variable srcd        : std_logic_vector(1 downto 0);
  variable posu        : std_logic_vector(3 downto 0);
  variable posd        : std_logic_vector(3 downto 0);
  variable i           : integer;
begin
  part03_00 := reglist( 3 downto  0);  
  part07_04 := reglist( 7 downto  4);
  part11_08 := reglist(11 downto  8);
  part15_12 := reglist(15 downto 12);

  -- priority 0-3
  part03_00ui := 0;
L1u:  for i in 0 to 3 loop
    if part03_00(i) = '1' then
      part03_00ui := i;
      exit L1u;
    end if;
  end loop;  
  part03_00di := 3;
L1d:  for i in 3 downto 0 loop
    if part03_00(i) = '1' then
      part03_00di := i;
      exit L1d;
    end if;
  end loop;  

  -- priority 4-7
  part07_04ui := 0;
L2u:  for i in 0 to 3 loop
    if part07_04(i) = '1' then
      part07_04ui := i;
      exit L2u;
    end if;
  end loop;  
  part07_04di := 3;
L2d:  for i in 3 downto 0 loop
    if part07_04(i) = '1' then
      part07_04di := i;
      exit L2d;
    end if;
  end loop;  

  -- priority 8-11
  part11_08ui := 0;
L3u:  for i in 0 to 3 loop
    if part11_08(i) = '1' then
      part11_08ui := i;
      exit L3u;
    end if;
  end loop;  
  part11_08di := 3;
L3d:  for i in 3 downto 0 loop
    if part11_08(i) = '1' then
      part11_08di := i;
      exit L3d;
    end if;
  end loop;  

  -- priority 12-15
  part15_12ui := 0;
L4u:  for i in 0 to 3 loop
    if part15_12(i) = '1' then
      part15_12ui := i;
      exit L4u;
    end if;
  end loop;  
  part15_12di := 0;
L4d:  for i in 3 downto 0 loop
    if part15_12(i) = '1' then
      part15_12di := i;
      exit L4d;
    end if;
  end loop;  

  src4 := (others => '0');
  if part03_00 /= "0000" then
    src4(0) := '1';
  end if;
  if part07_04 /= "0000" then
    src4(1) := '1';
  end if;
  if part11_08 /= "0000" then
    src4(2) := '1';
  end if;
  if part15_12 /= "0000" then
    src4(3) := '1';
  end if;

  -- priority upper blocks
  src4ui := 0;
S4u:  for i in 0 to 3 loop
    if src4(i) = '1' then
      src4ui := i;
      exit S4u;
    end if;
  end loop;  
  src4di := 3;
S4d:  for i in 3 downto 0 loop
    if src4(i) = '1' then
      src4di := i;
      exit S4d;
    end if;
  end loop;  

  srcu := std_logic_vector(conv_unsigned(src4ui, 2));
  srcd := std_logic_vector(conv_unsigned(src4di, 2));
    
  posu(3 downto 2) := srcu;
  case srcu is
    when "11" => posu(1 downto 0) := std_logic_vector(conv_unsigned(part15_12ui, 2));
    when "10" => posu(1 downto 0) := std_logic_vector(conv_unsigned(part11_08ui, 2));
    when "01" => posu(1 downto 0) := std_logic_vector(conv_unsigned(part07_04ui, 2));
    when "00" => posu(1 downto 0) := std_logic_vector(conv_unsigned(part03_00ui, 2));
    when others => null;
  end case;
  posd(3 downto 2) := srcd;
  case srcd is
    when "11" => posd(1 downto 0) := std_logic_vector(conv_unsigned(part15_12di, 2));
    when "10" => posd(1 downto 0) := std_logic_vector(conv_unsigned(part11_08di, 2));
    when "01" => posd(1 downto 0) := std_logic_vector(conv_unsigned(part07_04di, 2));
    when "00" => posd(1 downto 0) := std_logic_vector(conv_unsigned(part03_00di, 2));
    when others => null;
  end case;

  if insn(ADE_UID_U) = '1' then
    return posu; -- Increment regorder [0-15]
  else
    return posd; -- Decrement regorder [15-0]
  end if;

  return posu;
end;

procedure als_offsets (
  insn : in std_logic_vector(31 downto 0);
  startoff  : inout std_logic_vector(31 downto 0);
  endoff    : inout std_logic_vector(31 downto 0);
  incval    : inout std_logic_vector(31 downto 0)
) is
variable mode : std_logic_vector(1 downto 0);
variable regnum_mul4 : std_logic_vector(31 downto 0);
begin
  mode := insn(ADE_PAB_U)&insn(ADE_UID_U);
    
  startoff := (others => '0');
  endoff   := (others => '0');
  incval   := (others => '0');

  -- LRM/STM: Increment after  (regorder [0-15],start:+0,end(onwb):+4) :ldmia|stmia <rn>,{<reglist>}
  -- LRM/STM: Increment before (regorder [0-15],start:+4,end(onwb):+0) :ldmib|stmib <rn>,{<reglist>}
  -- LRM/STM: Decrement after  (regorder [15-0],start:-0,end(onwb):-4) :ldmda|stmda <rn>,{<reglist>}
  -- LRM/STM: Decrement before (regorder [15-0],start:-4,end(onwb):-0) :ldmdb|stmdb <rn>,{<reglist>}
  case mode is
    when "01" => incval := LIN_FOUR   ; startoff := (others=> '0'); endoff := LIN_FOUR;       -- increment after
    when "11" => incval := LIN_FOUR   ; startoff := LIN_FOUR      ; endoff := (others=> '0'); -- increment before
    when "00" => incval := LIN_MINFOUR; startoff := (others=> '0'); endoff := LIN_MINFOUR;    -- decrement after
    when "10" => incval := LIN_MINFOUR; startoff := LIN_MINFOUR   ; endoff := (others=> '0'); -- decrement before
    when others => 
  end case;
   
end;


end armldst;
