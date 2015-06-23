library ieee;
use ieee.std_logic_1164.all;
use IEEE.std_logic_unsigned."+";
use IEEE.std_logic_unsigned."-";
use IEEE.std_logic_unsigned.conv_integer;
use IEEE.std_logic_arith.conv_unsigned;
use IEEE.std_logic_arith.all;

-- PREFIX: lin_xxx
package int is

constant LIN_ZERO    : std_logic_vector(31 downto 0) := "00000000000000000000000000000000";
constant LIN_ONE     : std_logic_vector(31 downto 0) := "00000000000000000000000000000001";
constant LIN_TWO     : std_logic_vector(31 downto 0) := "00000000000000000000000000000010";
constant LIN_THREE   : std_logic_vector(31 downto 0) := "00000000000000000000000000000011";
constant LIN_FOUR    : std_logic_vector(31 downto 0) := "00000000000000000000000000000100";
constant LIN_MINFOUR : std_logic_vector(31 downto 0) := "11111111111111111111111111111100";

-- increment/decrement wrapper
procedure lin_incdec(
  source : in    std_logic_vector;
  dest   : inout std_logic_vector;
  do     : in    std_logic;
  inc    : in    std_logic
);
  
-- convert std_logic_vector to integer
function lin_convint(
  op   : in std_logic_vector
) return integer;

-- set bit integer(v)
function lin_decode(
  v : std_logic_vector
) return std_logic_vector;

-- pos of first '1' from left
function lin_countzero(
  data : in    std_logic_vector
) return std_logic_vector;

-- adder with carryin
procedure lin_adder(
  op1   : in std_logic_vector(31 downto 0);
  op2   : in std_logic_vector(31 downto 0);
  carry : in std_logic;
  sub   : in std_logic;
  sum   : out std_logic_vector(31 downto 0)
);

----------------------------------------------------------------------------
-- log2 tables
----------------------------------------------------------------------------

type lin_log2arr is array(1 to 64) of integer;
constant lin_log2  : lin_log2arr := (0,1,2,2,3,3,3,3,4,4,4,4,4,4,4,4,
				5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,others => 6);
constant lin_log2x : lin_log2arr := (1,1,2,2,3,3,3,3,4,4,4,4,4,4,4,4,
				5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,others => 6);

end int;

package body int is
  
procedure lin_incdec(
  source : in    std_logic_vector;
  dest   : inout std_logic_vector;
  do     : in    std_logic;
  inc    : in    std_logic
) is
variable tmp : std_logic_vector(source'range);
begin

  tmp := (others => '0');
-- pragma translate_off
    if not is_x(source) then
-- pragma translate_on
      if inc = '1' then
        tmp := source(source'range) + 1;
      else
        tmp := source(source'range) - 1;
      end if;
-- pragma translate_off
    else
      tmp := (others => 'X');
    end if;
-- pragma translate_on

    if (do) = '1' then
      dest := tmp;
    end if;

end;


function lin_countzero(
  data : in    std_logic_vector
) return std_logic_vector is
variable z02 : std_logic_vector((data'length/2)-1 downto 0);
variable z04 : std_logic_vector((data'length/4)-1 downto 0);
variable d04 : std_logic_vector(3 downto 0);
variable z08 : std_logic_vector((data'length/8)-1 downto 0);
variable d08 : std_logic_vector(7 downto 0);
variable z16 : std_logic_vector((data'length/16)-1 downto 0);
variable d16 : std_logic_vector(15 downto 0);
variable z32 : std_logic_vector((data'length/32)-1 downto 0);
variable d32 : std_logic_vector(31 downto 0);
variable z64 : std_logic_vector((data'length/64)-1 downto 0);
variable d64 : std_logic_vector(63 downto 0);
variable res : std_logic_vector(lin_log2x(data'length)-1 downto 0);
variable length : integer;
variable tmp : integer;
begin

  res := (others => '0');
  z32 := (others => '0');
  z02 := (others => '0');
  z04 := (others => '0');
  length := data'length;
  
  if (length / 2) >= 1 then
    tmp := 0;
L02:
    for i in (length/2)-1 downto 0 loop
      tmp := i;
      if    (data((i*2)+0) = '1') then
        z02(i) := '1';
        exit L02;
      elsif (data((i*2)+1) = '1') then
        z02(i) := '0';
        exit L02;
      else
        z02(i) := '0';
      end if;
    end loop;  -- i
    if (length = 2) then
      res(0) := z02(tmp);
    end if;
  end if;
  
  if (length / 4) >= 1 then
    tmp := 0;
L04:
    for i in (length/4)-1 downto 0 loop
      tmp := i;
      d04 := data((i*4)+3 downto i*4);
      z04(i) := '1';
      if    not (d04(3 downto 2) = "00") then
        z04(i) := '1';
        res(0) := z02(i*2);
        exit L04;
      elsif not (d04(1 downto 0) = "00") then
        z04(i) := '0';
        res(0) := z02((i*2)+1);
        exit L04;
      else
        z04(i) := '0';
      end if;
    end loop;  -- i
    if (length = 4) then
      res(1) := z04(tmp);
    end if;
  end if;
  
  if (length / 8) >= 1 then
    tmp := 0;
L08:
    for i in (length/8)-1 downto 0 loop
      tmp := i;
      d08 := data((i*8)+7 downto i*8);
      z08(i) := '1';
      if    not (d08(7 downto 4) = "0000") then
        z08(i) := '1';
        res(1) := z04(i*2);
        exit L08;
      elsif not (d08(3 downto 0) = "0000") then
        z08(i) := '0';
        res(1) := z04((i*2)+1);
        exit L08;
      else
        z08(i) := '0';
      end if;
    end loop;  -- i
    if (length = 8) then
      res(2) := z08(tmp);
    end if;
  end if;
  
  if (length / 16) >= 1 then
    tmp := 0;
L16:
    for i in (length/16)-1 downto 0 loop
      tmp := i;
      d16 := data((i*16)+15 downto i*16);
      z16(i) := '1';
      if    not (d16(15 downto 8) = "00000000") then
        z16(i) := '1';
        res(2) := z08(i*2);
        exit L16;
      elsif not (d16(7 downto 0) = "00000000") then
        z16(i) := '0';
        res(2) := z08((i*2)+1);
        exit L16;
      else
        z16(i) := '0';
      end if;
    end loop;  -- i
    if (length = 16) then
      res(3) := z16(tmp);
    end if;
  end if;

  if (length / 32) >= 1 then
    tmp := 0;
L32:
    for i in (length/32)-1 downto 0 loop
      tmp := i;
      d32 := data((i*32)+31 downto i*32);
      z32(i) := '1';
      if    not (d32(31 downto 16) = "0000000000000000") then
        z32(i) := '1';
        res(3) := z16(i*2);
        exit L32;
      elsif not (d32(15 downto 0) = "0000000000000000") then
        z32(i) := '0';
        res(3) := z16((i*2)+1);
        exit L32;
      else
        z32(i) := '0';
      end if;
    end loop;  -- i
    if (length = 32) then
      res(4) := z32(tmp);
    end if;
  end if;
  
  if (length / 64) >= 1 then
    tmp := 0;
L64:
    for i in (length/64)-1 downto 0 loop
      tmp := i;
      d64 := data((i*64)+63 downto i*64);
      z64(i) := '1';
      if    not (d64(63 downto 32) = "00000000000000000000000000000000") then
        z64(i) := '1';
        res(4) := z32(i*2);
        exit L64;
      elsif not (d64(31 downto 0) = "00000000000000000000000000000000") then
        z64(i) := '0';
        res(4) := z32((i*2)+1);
        exit L64;
      else
        z64(i) := '0';
      end if;
    end loop;  -- i
    if (length = 64) then
      res(5) := z64(tmp);
    end if;
  end if;

  return res;
end;

function lin_convint (
  op   : in std_logic_vector
) return integer is
variable tmp : integer;
begin
  tmp := 0;
-- pragma translate_off
    if not (is_x(op)) then
-- pragma translate_on
      tmp := conv_integer(op);
-- pragma translate_off
    end if;
-- pragma translate_on
  return tmp;
end;

function lin_decode(
  v : std_logic_vector
) return std_logic_vector is
variable res : std_logic_vector((2**v'length)-1 downto 0); --'
variable i : natural;
begin
  res := (others => '0');
-- pragma translate_off
  i := 0;
  if not is_x(v) then
-- pragma translate_on
    i := conv_integer(unsigned(v));
    res(i) := '1';
-- pragma translate_off
  else
    res := (others => 'X');
  end if;
-- pragma translate_on
  return(res);
end;

procedure lin_adder(
  op1   : in std_logic_vector(31 downto 0);
  op2   : in std_logic_vector(31 downto 0);
  carry : in std_logic;
  sub   : in std_logic;
  sum   : out std_logic_vector(31 downto 0)
) is
begin
-- pragma translate_off
    if not (is_x(op1) or is_x(op2) or is_x(carry)) then
-- pragma translate_on
      if sub = '1' then
        sum := op1 - op2 - carry;
      else
        sum := op1 + op2 + carry;
      end if;
-- pragma translate_off
    else
      sum := (others => 'X');
    end if;
-- pragma translate_on

end;

end int;
