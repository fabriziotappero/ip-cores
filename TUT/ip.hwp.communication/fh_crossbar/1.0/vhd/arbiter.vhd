-----------------------------------------------------------------
-- File         : arbiter.vhd
-- Description  : Sub-block for allocator
-- Designer     : Hannu Penttinen 29.08.2006
--
-- Note: If there's problems with synthesis concerning the carry
--       chain. Try dublicating the first arbiter and
--       connecting '0' to the carry in of the first arbiter and
--       ORing the grants of the first and second arbiter.
--       Done with carry1 and carry2
--
--      Req and hold must be asserted simultanesouly. When granted, req can be
--      de-asserted
--
--      The structure shown in Dally,Towles, fig 18.5, 18.6 and 18.7
--      
-- Note:          arb_type_g  0 - round-robin
--                            1 - fixed priority
--                            2 - variable priority
-----------------------------------------------------------------
-------------------------------------------------------------------------------
-- Copyright (c) 2011 Tampere University of Technology
-------------------------------------------------------------------------------
--  This file is part of Transaction Generator.
--
--  Transaction Generator is free software: you can redistribute it and/or
--  modify it under the terms of the Lesser GNU General Public License as
--  published by the Free Software Foundation, either version 3 of the License,
--  or (at your option) any later version.
--
--  Transaction Generator is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  Lesser GNU General Public License for more details.
--
--  You should have received a copy of the Lesser GNU General Public License
--  along with Transaction Generator.  If not, see
--  <http://www.gnu.org/licenses/>.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity arbiter is
  generic (
    arb_width_g : integer;
    arb_type_g  : integer := 0
    );
  port(
    clk       : in  std_logic;
    rst_n     : in  std_logic;
    req_in    : in  std_logic_vector(arb_width_g - 1 downto 0);
    hold_in   : in  std_logic_vector(arb_width_g - 1 downto 0);
    grant_out : out std_logic_vector(arb_width_g - 1 downto 0)
    );
end arbiter;

architecture rtl of arbiter is

  signal priority_r   : std_logic_vector (arb_width_g - 1 downto 0);
  signal carry_1      : std_logic_vector (arb_width_g - 1 downto 0);
  signal carry_2      : std_logic_vector (arb_width_g - 1 downto 0);
  signal gc           : std_logic_vector (arb_width_g - 1 downto 0);
  signal grant_i      : std_logic_vector (arb_width_g - 1 downto 0);
  signal last_grant_r : std_logic_vector (arb_width_g - 1 downto 0);

begin  -- rtl

  grant_out <= grant_i;

  -- Generate intermediate grant with aid of carry signals
  -- Carry means that no higher prior has asserted any requests
  -- Carry logic is dupliacted to avoid combinatorial loop,
  -- only difference is in the bit carry_x(0)
  arbiter : process (rst_n, priority_r, req_in, carry_1, carry_2)
  begin  -- process arbiter

    if rst_n = '0' then
      carry_1 <= (others => '0');
      carry_2 <= (others => '0');
      gc      <= (others => '0');

    else

      -- generate carry signal
      carry_1(0) <= '0';
      for i in 1 to arb_width_g - 1 loop
        carry_1(i) <= ( (priority_r(i-1) or carry_1(i-1)) and not(req_in(i-1)));
      end loop;  -- i

      carry_2(0) <= ((priority_r(arb_width_g - 1) or carry_1(arb_width_g - 1))
                   and not(req_in(arb_width_g - 1)));

      for i in 1 to arb_width_g - 1 loop
        carry_2(i) <= ( (priority_r(i-1) or carry_2(i-1)) and not(req_in(i-1)));
      end loop;  -- i

      -- generate intermediate grant signal
      for i in 0 to arb_width_g - 1 loop
        gc(i) <= ((priority_r(i) or carry_1(i)) and req_in(i)) or
                 ((priority_r(i) or carry_2(i)) and req_in(i));
      end loop;  -- i

    end if;
  end process arbiter;

  -- grant-hold circuit
  -- a) Previous grant remains if hold is active
  -- b) new grant is given if no holds are asserted
  grant_hold_async : process(gc, last_grant_r, hold_in)
    variable anyhold_v : std_logic;
  begin  -- process grant_hold_async

    anyhold_v := '0';
    for i in 0 to arb_width_g - 1 loop
      anyhold_v := anyhold_v or (hold_in(i) and last_grant_r(i));
    end loop;  -- i

    for i in 0 to arb_width_g - 1 loop
      grant_i(i) <= (last_grant_r(i) and hold_in(i))
                    or (gc(i) and not(anyhold_v));
    end loop;  -- i
  end process grant_hold_async;

  
  -- grant-hold: register previous grant signal (one-hot)
  grant_hold_sync : process (clk, rst_n)
  begin  -- process grant_hold_sync
    if rst_n = '0' then                 -- asynchronous reset (active low)
      last_grant_r <= (others => '0');
    elsif clk'event and clk = '1' then  -- rising clock edge
      last_grant_r <= grant_i;
    end if;
  end process grant_hold_sync;


  -- purpose: update priority register(round-robin)
  -- Input that got grant is put to the lowest priority
  -- One-hot encoded: one bit shows the highest priority,
  -- if prior(i)=1, i has highest prior, i+1 has 2nd highest and so on
  pri_round_robin : process (clk, rst_n)
    variable anyg_v : std_logic;
  begin  -- process pri_round_robin
    if rst_n = '0' then                 -- asynchronous reset (active low)
      priority_r <= std_logic_vector (to_unsigned(1, arb_width_g));
      
    elsif clk'event and clk = '1' then  -- rising clock edge

      case arb_type_g is


        when 0 =>
          -- round-robin
          anyg_v := '0';
          for i in 0 to arb_width_g - 1 loop
            anyg_v := anyg_v or grant_i(i);
          end loop;  -- i

          priority_r(0) <= ( priority_r(0) and not(anyg_v) ) or grant_i(arb_width_g - 1);

          for i in 1 to arb_width_g - 1 loop
            priority_r(i) <= (priority_r(i) and not(anyg_v)) or grant_i(i-1);
          end loop;  -- i

        when 1 =>
          -- fixed_priority
          priority_r <= priority_r;

        when 2 =>

          -- variable priority
          if grant_i /= std_logic_vector(to_unsigned(0, grant_i'length)) then
            priority_r <= priority_r(priority_r'length - 2 downto 0) & priority_r(priority_r'length - 1);
          else
            priority_r <= priority_r;
          end if;         
        when others => null;
      end case;
    end if;

  end process pri_round_robin;

end rtl;
