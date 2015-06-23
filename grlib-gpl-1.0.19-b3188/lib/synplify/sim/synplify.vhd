-----------------------------------------------------------------------------
--                                                                         --
-- Copyright (c) 1997 by Synplicity, Inc.  All rights reserved.            --
--                                                                         --
-- This source file may be used and distributed without restriction        --
-- provided that this copyright statement is not removed from the file     --
-- and that any derivative work contains this copyright notice.            --
--                                                                         --
-- Primitive library for post synthesis simulation                         --
-- These models are not intended for efficient synthesis                   --
--                                                                         --
-----------------------------------------------------------------------------
--pragma translate_off
library ieee;
use ieee.std_logic_1164.all;
entity prim_counter is
    generic (w : integer := 8);
    port (
        q : buffer std_logic_vector(w - 1 downto 0);
        cout : out std_logic;
        d : in std_logic_vector(w - 1 downto 0);
        cin : in std_logic;
        clk : in std_logic;
        rst : in std_logic;
        load : in std_logic;
        en : in std_logic;
        updn : in std_logic
    );
end prim_counter;

architecture beh of prim_counter is
    signal nextq : std_logic_vector(w - 1 downto 0);
begin
    nxt: process (q, cin, updn)
        variable i : integer;
        variable nextc, c : std_logic;
    begin
        nextc := cin;
        for i in 0 to w - 1 loop
            c := nextc;
            nextq(i) <= c xor (not updn) xor q(i);
            nextc := (c and (not updn)) or 
                 (c and q(i)) or
                 ((not updn) and q(i));
        end loop;
        cout <= nextc;
    end process;

    ff : process (clk, rst)
    begin
        if rst = '1' then
            q <= (others => '0');
        elsif rising_edge(clk) then
            q <= nextq;
        end if;
    end process ff;
end beh;

library ieee;
use ieee.std_logic_1164.all;
entity prim_dff is
    port (q : out std_logic;
          d : in std_logic;
          clk : in std_logic;
          r : in std_logic := '0';
          s : in std_logic := '0');
end prim_dff;

architecture beh of prim_dff is
begin
    ff : process (clk, r, s)
    begin
        if r = '1' then
            q <= '0';
        elsif s = '1' then
            q <= '1';
        elsif rising_edge(clk) then
            q <= d;
        end if;
    end process ff;
end beh;

library ieee;
use ieee.std_logic_1164.all;

library ieee;
use ieee.std_logic_1164.all;
entity prim_sdff is 
	port (q : out std_logic;
		  d : in std_logic;
		  c : in std_logic;
		  r : in std_logic := '0';
		  s : in std_logic := '0');
end prim_sdff;

architecture beh of prim_sdff is 

begin
	ff : process(c)
	begin
		if rising_edge(c) then
			if r = '1' then
				q <= '0';
			elsif s = '1' then
				q <= '1';
			else
				q <= d;
			end if;
		end if;
   end process ff;
end beh;



library ieee;
use ieee.std_logic_1164.all;
entity prim_latch is
    port (q : out std_logic;
          d : in std_logic;
          clk : in std_logic;
          r : in std_logic := '0';
          s : in std_logic := '0');
end prim_latch;

architecture beh of prim_latch is
begin
    q <= '0' when r = '1' else
         '1' when s = '1' else
         d when clk = '1';
end beh;

----------------------------------------------------------------------------
-- Zero ohm resistors: Hardi's solution to connect two inout ports. 

----------------------------------------------------------------------------
-- Copyright (c) 1995, Ben Cohen.   All rights reserved.
-- This model can be used in conjunction with the Kluwer Academic book
-- "VHDL Coding Styles and Methodologies", ISBN: 0-7923-9598-0
-- "VHDL Amswers to Frequently Asked Questions", Kluwer Academic
-- which discusses guidelines and testbench design issues.
--
-- This source file for the ZERO Ohm resistor model may be used and
-- distributed without restriction provided that this copyright
-- statement is not removed from the file and that any derivative work
-- contains this copyright notice.

-- File name  : Zohm_ea.vhd
-- Description: This package, entity, and architecture provide
--   the definition of a zero ohm component (A, B).
--
--   The applications of this component include:
--     . Normal operation of a jumper wire (data flowing in both directions)
--
--   The component consists of 2 ports:
--      . Port A: One side of the pass-through switch
--      . Port B: The other side of the pass-through switch

--   The model is sensitive to transactions on all ports.  Once a
--   transaction is detected, all other transactions are ignored
--   for that simulation time (i.e. further transactions in that
--   delta time are ignored).
--
--   The width of the pass-through switch is defined through the
--   generic "width_g".  The pass-through control and operation
--   is defined on a per bit basis (i.e. one process per bit).
--
-- Model Limitations and Restrictions:
--   Signals asserted on the ports of the error injector should not have
--   transactions occuring in multiple delta times because the model
--   is sensitive to transactions on port A, B ONLY ONCE during
--   a simulation time.  Thus, once fired, a process will
--   not refire if there are multiple transactions occuring in delta times.
--   This condition may occur in gate level simulations with
--   ZERO delays because transactions may occur in multiple delta times.
--
--
-- Acknowledgement: The author thanks Steve Schoessow and Johan Sandstrom
--   for their contributions and discussions in the enhancement and
--   verification of this model.
--
--=================================================================
-- Revisions:
--   Date   Author       Revision  Comment
-- 07-13-95 Ben Cohen    Rev A     Creation
--          VhdlCohen@aol.com
-------------------------------------------------------------
library IEEE;
  use IEEE.Std_Logic_1164.all;

entity ZeroOhm1 is
  port
    (A : inout Std_Logic;
     B : inout Std_Logic
     );
end ZeroOhm1;


architecture ZeroOhm1_a of ZeroOhm1 is
--    attribute syn_black_box : boolean;
--    attribute syn_feedthrough : boolean;
--    attribute syn_black_box of all : architecture is true;
--    attribute syn_feedthrough of all : architecture is true;
begin
  ABC0_Lbl: process
    variable ThenTime_v : time;
  begin

    wait on A'transaction, B'transaction
                      until ThenTime_v /= now;

    -- Break
    ThenTime_v := now;
    A <= 'Z';
    B <= 'Z';
    wait for 0 ns;
    -- Make
    A <= B;
    B <= A;
   
  end process ABC0_Lbl;
end ZeroOhm1_a;

-------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
library grlib;
use grlib.stdlib.all;

entity prim_ramd is
generic (
   data_width : integer := 4;
    addr_width : integer := 5);
port (
    dout : out std_logic_vector(data_width-1 downto 0);
    aout : in std_logic_vector(addr_width-1 downto 0);
    din  : in std_logic_vector(data_width-1 downto 0);
    ain : in std_logic_vector(addr_width-1 downto 0);
    we   : in std_logic;
    clk  : in std_logic);
end prim_ramd;

architecture beh of prim_ramd is

constant depth : integer := 2** addr_width;
type mem_type is array (depth-1 downto 0) of std_logic_vector (data_width-1 downto 0);
signal mem: mem_type;

begin  

dout <= mem(conv_integer(aout));

process (clk)
    begin
        if rising_edge(clk) then    
            if (we = '1') then
                mem(conv_integer(ain)) <= din;
            end if;
        end if;
end process;

end beh ;


library ieee;
use ieee.std_logic_1164.all;
package components is
    component prim_counter
        generic (w : integer);
        port (
            q : buffer std_logic_vector(w - 1 downto 0);
            cout : out std_logic;
            d : in std_logic_vector(w - 1 downto 0);
            cin : in std_logic;
            clk : in std_logic;
            rst : in std_logic;
            load : in std_logic;
            en : in std_logic;
            updn : in std_logic
        );
    end component;
    component prim_dff
        port (q : out std_logic;
              d : in std_logic;
              clk : in std_logic;
              r : in std_logic := '0';
              s : in std_logic := '0');
    end component;
	component prim_sdff
		port(q : out std_logic;
			 d : in std_logic;
			 c : in std_logic;
			 r : in std_logic := '0';
			 s : in std_logic := '0');
	end component;
    component prim_latch
        port (q : out std_logic;
              d : in std_logic;
              clk : in std_logic;
              r : in std_logic := '0';
              s : in std_logic := '0');
    end component;

    component prim_ramd is
    generic (
        data_width : integer := 4;
        addr_width : integer := 5);
    port (
        dout : out std_logic_vector(data_width-1 downto 0);
        aout : in std_logic_vector(addr_width-1 downto 0);
        din  : in std_logic_vector(data_width-1 downto 0);
        ain : in std_logic_vector(addr_width-1 downto 0);
        we   : in std_logic;
        clk  : in std_logic);
    end component;

end components;
-- pragma translate_on
