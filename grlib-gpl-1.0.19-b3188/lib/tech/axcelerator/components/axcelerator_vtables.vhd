library IEEE;
use IEEE.STD_LOGIC_1164.all;

use IEEE.VITAL_Timing.all;
use IEEE.VITAL_Primitives.all;

package VTABLES is

   CONSTANT L : VitalTableSymbolType := '0';
   CONSTANT H : VitalTableSymbolType := '1';
   CONSTANT x : VitalTableSymbolType := '-';
   CONSTANT S : VitalTableSymbolType := 'S';
   CONSTANT R : VitalTableSymbolType := '/';
   CONSTANT U : VitalTableSymbolType := 'X';
   CONSTANT V : VitalTableSymbolType := 'B'; -- valid clock signal (non-rising)

-- CLR_ipd, CLK_delayed, Q_zd, D, E_delayed, PRE_ipd, CLK_ipd
CONSTANT DFEG_Q_tab : VitalStateTableType := (
( L,  x,  x,  x,  x,  x,  x,  x,  L ),
( H,  L,  H,  H,  x,  x,  H,  x,  H ),
( H,  L,  H,  x,  H,  x,  H,  x,  H ),
( H,  L,  x,  H,  L,  x,  H,  x,  H ),
( H,  H,  x,  x,  x,  H,  x,  x,  S ),
( H,  x,  x,  x,  x,  L,  x,  x,  H ),
( H,  x,  x,  x,  x,  H,  L,  x,  S ),
( x,  L,  L,  L,  x,  H,  H,  x,  L ),
( x,  L,  L,  x,  H,  H,  H,  x,  L ),
( x,  L,  x,  L,  L,  H,  H,  x,  L ),
( U,  x,  L,  x,  x,  H,  x,  x,  L ),
( H,  x,  H,  x,  x,  U,  x,  x,  H ));

-- CLR_ipd, CLK_delayed, T_delayed, Q_zd, CLK_ipd
CONSTANT tflipflop_Q_tab : VitalStateTableType := (
( L,  x,  x,  x,  x,  x,  L ),
( H,  L,  L,  H,  H,  x,  H ),
( H,  L,  H,  L,  H,  x,  H ),
( H,  H,  x,  x,  x,  x,  S ),
( H,  x,  x,  x,  L,  x,  S ),
( x,  L,  L,  L,  H,  x,  L ),
( x,  L,  H,  H,  H,  x,  L ));

-- CLR_ipd, CLK_delayed, PRE_delayed,K_delayed,J_delayed, Q_zd, CLK_ipd
CONSTANT jkflipflop_Q_tab : VitalStateTableType := (
( L,  x,  H,  x,  x,  x,  x,  x,  U ),
( L,  x,  L,  x,  x,  x,  x,  x,  L ),
( H,  L,  x,  L,  H,  x,  H,  x,  H ),
( H,  L,  x,  L,  x,  H,  H,  x,  H ),
( H,  L,  x,  x,  H,  L,  H,  x,  H ),
( H,  H,  L,  x,  x,  x,  x,  x,  S ),
( H,  x,  L,  x,  x,  x,  L,  x,  S ),
( H,  x,  H,  x,  x,  x,  x,  x,  H ),
( x,  L,  L,  H,  L,  x,  H,  x,  L ),
( x,  L,  L,  H,  x,  H,  H,  x,  L ),
( x,  L,  L,  x,  L,  L,  H,  x,  L ),
( U,  x,  L,  x,  x,  L,  x,  x,  L ),
( H,  x,  U,  x,  x,  H,  x,  x,  H ));

CONSTANT JKF2A_Q_tab : VitalStateTableType := (
( L,  x,  x,  x,  x,  x,  x,  L ),
( H,  L,  L,  H,  x,  H,  x,  H ),
( H,  L,  L,  x,  H,  H,  x,  H ),
( H,  L,  x,  H,  L,  H,  x,  H ),
( H,  H,  x,  x,  x,  x,  x,  S ),
( H,  x,  x,  x,  x,  L,  x,  S ),
( x,  L,  H,  L,  x,  H,  x,  L ),
( x,  L,  H,  x,  H,  H,  x,  L ),
( x,  L,  x,  L,  L,  H,  x,  L ),
( U,  x,  x,  x,  L,  x,  x,  L ));

CONSTANT JKF3A_Q_tab : VitalStateTableType := (
( L,  H,  L,  x,  H,  H,  x,  L ),
( L,  H,  x,  H,  H,  H,  x,  L ),
( L,  L,  H,  x,  x,  H,  x,  H ),
( L,  L,  x,  H,  x,  H,  x,  H ),
( L,  x,  L,  L,  H,  H,  x,  L ),
( L,  x,  H,  L,  x,  H,  x,  H ),
( H,  x,  x,  x,  H,  x,  x,  S ),
( x,  x,  x,  x,  L,  x,  x,  H ),
( x,  x,  x,  x,  H,  L,  x,  S ),
( x,  x,  x,  H,  U,  x,  x,  H ));

CONSTANT dlatch_DLE3B_Q_tab : VitalStateTableType := (
( x,  x,  x,  H,  x,  H ),   --active high preset

( H,  x,  x,  L,  x,  S ),   --latch
( x,  H,  x,  L,  x,  S ),   --latch

( L,  L,  H,  L,  x,  H ),   --transparent
( L,  L,  L,  L,  x,  L ),   --transparent

( U,  x,  H,  L,  H,  H ),   --o/p mux pessimism
( x,  U,  H,  L,  H,  H ),   --o/p mux pessimism
( U,  x,  L,  L,  L,  L ),   --o/p mux pessimism
( x,  U,  L,  L,  L,  L ),   --o/p mux pessimism

( L,  L,  H,  U,  x,  H ),   --PRE==X
( H,  x,  x,  U,  H,  H ),   --PRE==X
( x,  H,  x,  U,  H,  H ),   --PRE==X
( L,  U,  H,  U,  H,  H ),   --PRE==X
( U,  L,  H,  U,  H,  H ),   --PRE==X
( U,  U,  H,  U,  H,  H ));  --PRE==X
--G, E, D, P, Qn, Qn+1

CONSTANT dlatch_DLE2B_Q_tab : VitalStateTableType := (
( L,  x,  x,  x,  x,  L ),   --active low clear

( H,  H,  x,  x,  x,  S ),   --latch
( H,  x,  H,  x,  x,  S ),   --latch

( H,  L,  L,  H,  x,  H ),   --transparent
( H,  L,  L,  L,  x,  L ),   --transparent

( H,  x,  x,  L,  L,  L ),   --o/p mux pessimism
( H,  x,  x,  H,  H,  H ),   --o/p mux pessimism

( U,  x,  x,  L,  L,  L ),   --CLR==X, o/p mux pessimism
( U,  H,  x,  x,  L,  L ),   --CLR==X, o/p mux pessimism, latch
( U,  x,  H,  x,  L,  L ),   --CLR==X, o/p mux pessimism, latch
( U,  L,  L,  L,  x,  L ));  --CLR==X, i/p mux pessimism
--C, G, E, D, Qn, Qn+1


CONSTANT dlatch_DL2C_Q_tab : VitalStateTableType := (
( L,  x,  x,  x,  x,  L ),   --active low clear
( H,  x,  x,  H,  x,  H ),   --active high preset

( H,  H,  x,  L,  x,  S ),   --latch
( H,  L,  L,  L,  x,  L ),   --transparent

( U,  L,  L,  L,  x,  L ),   --CLR==U
( U,  H,  x,  L,  L,  L ),   --CLR==U
( x,  U,  L,  L,  L,  L ),   --CLR,G==U

( H,  U,  H,  x,  H,  H ),   --PRE==U/x,G==U
( H,  L,  H,  x,  x,  H ),   --PRE==U/x
( H,  H,  x,  U,  H,  H ));  --PRE==U
--CLR, G, D, PRE, Qn, Qn+1

end VTABLES;



--------------------- END OF VITABLE TABLE SECTION  ----------------
