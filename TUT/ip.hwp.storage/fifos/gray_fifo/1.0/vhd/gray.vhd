library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package gray_code is

  function gray_encode (B : unsigned)   -- binary input
    return std_logic_vector;            -- gray coded output

  function gray_decode (G : std_logic_vector)  -- gray coded input
    return unsigned;                           -- binary output

end package gray_code;

package body gray_code is

  function gray_encode (B : unsigned)
    return std_logic_vector is
    variable G : std_logic_vector(B'range);
  begin
    G(B'left) := B(B'left);
    for i in B'left - 1 downto B'right loop
      G(i) := B(i+1) xor B(i);
    end loop;  -- i
    return G;
  end gray_encode;

  function gray_decode (G : std_logic_vector)
    return unsigned is
    variable B : unsigned(G'range);
  begin
    B(G'left) := G(G'left);
    for i in G'left - 1 downto G'right loop
      B(i) := B(i+1) xor G(i);
    end loop;  -- i
    return B;
  end gray_decode;

end package body gray_code;
