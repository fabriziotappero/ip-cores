-------------------------------------------------------------------------------
-- Title      : UART
-- Project    : UART
-------------------------------------------------------------------------------
-- File        : utils.vhd
-- Author      : Philippe CARTON 
--               (philippe.carton2@libertysurf.fr)
-- Organization:
-- Created     : 15/12/2001
-- Last update : 8/1/2003
-- Platform    : Foundation 3.1i
-- Simulators  : ModelSim 5.5b
-- Synthesizers: Xilinx Synthesis
-- Targets     : Xilinx Spartan
-- Dependency  : IEEE std_logic_1164
-------------------------------------------------------------------------------
-- Description: VHDL utility file
-------------------------------------------------------------------------------
-- Copyright (c) notice
--    This core adheres to the GNU public license 
--
-------------------------------------------------------------------------------
-- Revisions       :
-- Revision Number :
-- Version         :
-- Date    :
-- Modifier        : name <email>
-- Description     :
--
------------------------------------------------------------------------------


-------------------------------------------------------------------------------
-- Revision list
-- Version   Author                 Date                        Changes
--
-- 1.0      Philippe CARTON  19 December 2001                   New model
--	    philippe.carton2@libertysurf.fr
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------- 
-- Synchroniser: 
--    Synchronize an input signal (C1) with an input clock (C).
--    The result is the O signal which is synchronous of C, and persist for
--    one C clock period.
-------------------------------------------------------------------------------- 
library IEEE,STD;
use IEEE.std_logic_1164.all;

entity synchroniser is
   port (
      C1 : in std_logic;-- Asynchronous signal
      C :  in std_logic;-- Clock
      O :  out std_logic);-- Synchronised signal
end synchroniser;

architecture Behaviour of synchroniser is
   signal C1A : std_logic;
   signal C1S : std_logic;
   signal R : std_logic;
begin
   RiseC1A : process(C1,R)
   begin
      if Rising_Edge(C1) then
         C1A <= '1';
      end if;
      if (R = '1') then
         C1A <= '0';
      end if;
   end process;

   SyncP : process(C,R)
   begin
      if Rising_Edge(C) then
         if (C1A = '1') then
            C1S <= '1';
         else C1S <= '0';
         end if;
         if (C1S = '1') then
            R <= '1';
         else R <= '0';
         end if;
      end if;
      if (R = '1') then
         C1S <= '0';
      end if;
   end process;
   O <= C1S;
end Behaviour;

-------------------------------------------------------------------------------
-- Counter
--    This counter is a parametrizable clock divider.
--    The count value is the generic parameter Count.
--    It is CE enabled. (it will count only if CE is high).
--    When it overflow, it will emit a pulse on O. 
--    It can be reseted to 0. 
-------------------------------------------------------------------------------
library IEEE,STD;
use IEEE.std_logic_1164.all;

entity Counter is
  generic(Count: INTEGER range 0 to 65535); -- Count revolution
  port (
     Clk      : in  std_logic;  -- Clock
     Reset    : in  std_logic;  -- Reset input
     CE       : in  std_logic;  -- Chip Enable
     O        : out std_logic); -- Output
end Counter;

architecture Behaviour of Counter is
begin
  counter : process(Clk,Reset)
     variable Cnt : INTEGER range 0 to Count-1;
  begin
     if Reset = '1' then
        Cnt := Count - 1;
        O <= '0';
     elsif Rising_Edge(Clk) then
        if CE = '1' then
           if Cnt = 0 then
              O <= '1';
              Cnt := Count - 1;
           else
              O <= '0';
              Cnt := Cnt - 1;
           end if;
        else O <= '0';
        end if;
     end if;
  end process;
end Behaviour;
