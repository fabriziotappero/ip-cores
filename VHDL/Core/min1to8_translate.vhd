-- Xilinx Vhdl netlist produced by netgen application (version G.26)
-- Command       : -intstyle ise -rpw 100 -tpw 0 -ar Structure -xon true -w -ofmt vhdl -sim min1to8.ngd min1to8_translate.vhd 
-- Input file    : min1to8.ngd
-- Output file   : min1to8_translate.vhd
-- Design name   : min1to8
-- # of Entities : 1
-- Xilinx        : C:/Xilinx
-- Device        : 2s300eft256-7

-- This vhdl netlist is a simulation model and uses simulation 
-- primitives which may not represent the true implementation of the 
-- device, however the netlist is functionally correct and should not 
-- be modified. This file cannot be synthesized and should only be used 
-- with supported simulation tools.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library SIMPRIM;
use SIMPRIM.VCOMPONENTS.ALL;
use SIMPRIM.VPACKAGE.ALL;

entity min1to8 is
  port (
    A : in STD_LOGIC_VECTOR ( 7 downto 0 ); 
    B : in STD_LOGIC_VECTOR ( 63 downto 0 ); 
    C : out STD_LOGIC_VECTOR ( 63 downto 0 ) 
  );
end min1to8;

architecture Structure of min1to8 is
  signal B_17_IBUF : STD_LOGIC; 
  signal B_16_IBUF : STD_LOGIC; 
  signal B_18_IBUF : STD_LOGIC; 
  signal B_3_IBUF : STD_LOGIC; 
  signal B_11_IBUF : STD_LOGIC; 
  signal B_4_IBUF : STD_LOGIC; 
  signal B_12_IBUF : STD_LOGIC; 
  signal B_5_IBUF : STD_LOGIC; 
  signal B_10_IBUF : STD_LOGIC; 
  signal B_13_IBUF : STD_LOGIC; 
  signal B_0_IBUF : STD_LOGIC; 
  signal B_6_IBUF : STD_LOGIC; 
  signal B_9_IBUF : STD_LOGIC; 
  signal B_14_IBUF : STD_LOGIC; 
  signal B_1_IBUF : STD_LOGIC; 
  signal B_7_IBUF : STD_LOGIC; 
  signal B_8_IBUF : STD_LOGIC; 
  signal B_15_IBUF : STD_LOGIC; 
  signal B_2_IBUF : STD_LOGIC; 
  signal C_63_OBUF : STD_LOGIC; 
  signal C_62_OBUF : STD_LOGIC; 
  signal C_61_OBUF : STD_LOGIC; 
  signal C_60_OBUF : STD_LOGIC; 
  signal C_59_OBUF : STD_LOGIC; 
  signal C_58_OBUF : STD_LOGIC; 
  signal C_57_OBUF : STD_LOGIC; 
  signal C_56_OBUF : STD_LOGIC; 
  signal C_55_OBUF : STD_LOGIC; 
  signal C_54_OBUF : STD_LOGIC; 
  signal C_53_OBUF : STD_LOGIC; 
  signal C_52_OBUF : STD_LOGIC; 
  signal C_51_OBUF : STD_LOGIC; 
  signal C_50_OBUF : STD_LOGIC; 
  signal C_49_OBUF : STD_LOGIC; 
  signal C_48_OBUF : STD_LOGIC; 
  signal C_47_OBUF : STD_LOGIC; 
  signal C_46_OBUF : STD_LOGIC; 
  signal C_45_OBUF : STD_LOGIC; 
  signal C_44_OBUF : STD_LOGIC; 
  signal C_43_OBUF : STD_LOGIC; 
  signal C_42_OBUF : STD_LOGIC; 
  signal C_41_OBUF : STD_LOGIC; 
  signal C_40_OBUF : STD_LOGIC; 
  signal C_39_OBUF : STD_LOGIC; 
  signal C_38_OBUF : STD_LOGIC; 
  signal C_37_OBUF : STD_LOGIC; 
  signal C_36_OBUF : STD_LOGIC; 
  signal C_35_OBUF : STD_LOGIC; 
  signal C_34_OBUF : STD_LOGIC; 
  signal C_33_OBUF : STD_LOGIC; 
  signal C_32_OBUF : STD_LOGIC; 
  signal C_31_OBUF : STD_LOGIC; 
  signal C_30_OBUF : STD_LOGIC; 
  signal C_29_OBUF : STD_LOGIC; 
  signal C_28_OBUF : STD_LOGIC; 
  signal C_27_OBUF : STD_LOGIC; 
  signal C_26_OBUF : STD_LOGIC; 
  signal C_25_OBUF : STD_LOGIC; 
  signal C_24_OBUF : STD_LOGIC; 
  signal C_23_OBUF : STD_LOGIC; 
  signal C_22_OBUF : STD_LOGIC; 
  signal C_21_OBUF : STD_LOGIC; 
  signal C_20_OBUF : STD_LOGIC; 
  signal C_19_OBUF : STD_LOGIC; 
  signal C_18_OBUF : STD_LOGIC; 
  signal C_17_OBUF : STD_LOGIC; 
  signal C_16_OBUF : STD_LOGIC; 
  signal C_15_OBUF : STD_LOGIC; 
  signal C_14_OBUF : STD_LOGIC; 
  signal C_13_OBUF : STD_LOGIC; 
  signal C_12_OBUF : STD_LOGIC; 
  signal C_11_OBUF : STD_LOGIC; 
  signal C_10_OBUF : STD_LOGIC; 
  signal C_9_OBUF : STD_LOGIC; 
  signal C_8_OBUF : STD_LOGIC; 
  signal C_7_OBUF : STD_LOGIC; 
  signal C_6_OBUF : STD_LOGIC; 
  signal C_5_OBUF : STD_LOGIC; 
  signal C_4_OBUF : STD_LOGIC; 
  signal C_3_OBUF : STD_LOGIC; 
  signal C_2_OBUF : STD_LOGIC; 
  signal C_1_OBUF : STD_LOGIC; 
  signal C_0_OBUF : STD_LOGIC; 
  signal A_7_IBUF : STD_LOGIC; 
  signal A_6_IBUF : STD_LOGIC; 
  signal A_5_IBUF : STD_LOGIC; 
  signal A_4_IBUF : STD_LOGIC; 
  signal A_3_IBUF : STD_LOGIC; 
  signal A_2_IBUF : STD_LOGIC; 
  signal A_1_IBUF : STD_LOGIC; 
  signal A_0_IBUF : STD_LOGIC; 
  signal B_63_IBUF : STD_LOGIC; 
  signal B_62_IBUF : STD_LOGIC; 
  signal B_61_IBUF : STD_LOGIC; 
  signal B_60_IBUF : STD_LOGIC; 
  signal B_59_IBUF : STD_LOGIC; 
  signal B_58_IBUF : STD_LOGIC; 
  signal B_57_IBUF : STD_LOGIC; 
  signal B_56_IBUF : STD_LOGIC; 
  signal B_55_IBUF : STD_LOGIC; 
  signal B_54_IBUF : STD_LOGIC; 
  signal B_53_IBUF : STD_LOGIC; 
  signal B_52_IBUF : STD_LOGIC; 
  signal B_51_IBUF : STD_LOGIC; 
  signal B_50_IBUF : STD_LOGIC; 
  signal B_49_IBUF : STD_LOGIC; 
  signal B_48_IBUF : STD_LOGIC; 
  signal B_47_IBUF : STD_LOGIC; 
  signal B_46_IBUF : STD_LOGIC; 
  signal B_45_IBUF : STD_LOGIC; 
  signal B_44_IBUF : STD_LOGIC; 
  signal B_43_IBUF : STD_LOGIC; 
  signal B_42_IBUF : STD_LOGIC; 
  signal B_41_IBUF : STD_LOGIC; 
  signal B_40_IBUF : STD_LOGIC; 
  signal B_39_IBUF : STD_LOGIC; 
  signal B_38_IBUF : STD_LOGIC; 
  signal B_37_IBUF : STD_LOGIC; 
  signal B_36_IBUF : STD_LOGIC; 
  signal B_35_IBUF : STD_LOGIC; 
  signal B_34_IBUF : STD_LOGIC; 
  signal B_33_IBUF : STD_LOGIC; 
  signal B_32_IBUF : STD_LOGIC; 
  signal B_31_IBUF : STD_LOGIC; 
  signal B_30_IBUF : STD_LOGIC; 
  signal B_29_IBUF : STD_LOGIC; 
  signal B_28_IBUF : STD_LOGIC; 
  signal B_27_IBUF : STD_LOGIC; 
  signal B_26_IBUF : STD_LOGIC; 
  signal B_25_IBUF : STD_LOGIC; 
  signal B_24_IBUF : STD_LOGIC; 
  signal B_23_IBUF : STD_LOGIC; 
  signal B_22_IBUF : STD_LOGIC; 
  signal B_21_IBUF : STD_LOGIC; 
  signal B_20_IBUF : STD_LOGIC; 
  signal B_19_IBUF : STD_LOGIC; 
  signal Inst_minimum63to56_n0000 : STD_LOGIC; 
  signal Inst_minimum55to48_n0000 : STD_LOGIC; 
  signal Inst_minimum47to40_n0000 : STD_LOGIC; 
  signal Inst_minimum39to32_n0000 : STD_LOGIC; 
  signal Inst_minimum31to24_n0000 : STD_LOGIC; 
  signal Inst_minimum23to16_n0000 : STD_LOGIC; 
  signal Inst_minimum15to8_n0000 : STD_LOGIC; 
  signal Inst_minimum7to0_n0000 : STD_LOGIC; 
  signal N183 : STD_LOGIC; 
  signal Inst_minimum7to0_Mcompar_n0000_inst_lut2_7 : STD_LOGIC; 
  signal Inst_minimum7to0_Mcompar_n0000_inst_cy_6 : STD_LOGIC; 
  signal Inst_minimum7to0_Mcompar_n0000_inst_lut2_6 : STD_LOGIC; 
  signal Inst_minimum7to0_Mcompar_n0000_inst_cy_5 : STD_LOGIC; 
  signal Inst_minimum7to0_Mcompar_n0000_inst_lut2_5 : STD_LOGIC; 
  signal Inst_minimum7to0_Mcompar_n0000_inst_cy_4 : STD_LOGIC; 
  signal Inst_minimum7to0_Mcompar_n0000_inst_lut2_4 : STD_LOGIC; 
  signal Inst_minimum7to0_Mcompar_n0000_inst_cy_3 : STD_LOGIC; 
  signal Inst_minimum7to0_Mcompar_n0000_inst_lut2_3 : STD_LOGIC; 
  signal Inst_minimum7to0_Mcompar_n0000_inst_cy_2 : STD_LOGIC; 
  signal Inst_minimum7to0_Mcompar_n0000_inst_lut2_2 : STD_LOGIC; 
  signal Inst_minimum7to0_Mcompar_n0000_inst_cy_1 : STD_LOGIC; 
  signal Inst_minimum7to0_Mcompar_n0000_inst_lut2_1 : STD_LOGIC; 
  signal Inst_minimum7to0_Mcompar_n0000_inst_cy_0 : STD_LOGIC; 
  signal Inst_minimum7to0_Mcompar_n0000_inst_lut2_0 : STD_LOGIC; 
  signal Inst_minimum15to8_Mcompar_n0000_inst_cy_0 : STD_LOGIC; 
  signal Inst_minimum15to8_Mcompar_n0000_inst_lut2_0 : STD_LOGIC; 
  signal Inst_minimum15to8_Mcompar_n0000_inst_lut2_7 : STD_LOGIC; 
  signal Inst_minimum15to8_Mcompar_n0000_inst_cy_6 : STD_LOGIC; 
  signal Inst_minimum15to8_Mcompar_n0000_inst_lut2_6 : STD_LOGIC; 
  signal Inst_minimum15to8_Mcompar_n0000_inst_cy_5 : STD_LOGIC; 
  signal Inst_minimum15to8_Mcompar_n0000_inst_lut2_5 : STD_LOGIC; 
  signal Inst_minimum15to8_Mcompar_n0000_inst_cy_4 : STD_LOGIC; 
  signal Inst_minimum15to8_Mcompar_n0000_inst_lut2_4 : STD_LOGIC; 
  signal Inst_minimum15to8_Mcompar_n0000_inst_cy_3 : STD_LOGIC; 
  signal Inst_minimum15to8_Mcompar_n0000_inst_lut2_3 : STD_LOGIC; 
  signal Inst_minimum15to8_Mcompar_n0000_inst_cy_2 : STD_LOGIC; 
  signal Inst_minimum15to8_Mcompar_n0000_inst_lut2_2 : STD_LOGIC; 
  signal Inst_minimum15to8_Mcompar_n0000_inst_cy_1 : STD_LOGIC; 
  signal Inst_minimum15to8_Mcompar_n0000_inst_lut2_1 : STD_LOGIC; 
  signal Inst_minimum23to16_Mcompar_n0000_inst_cy_0 : STD_LOGIC; 
  signal Inst_minimum23to16_Mcompar_n0000_inst_lut2_0 : STD_LOGIC; 
  signal Inst_minimum23to16_Mcompar_n0000_inst_lut2_7 : STD_LOGIC; 
  signal Inst_minimum23to16_Mcompar_n0000_inst_cy_6 : STD_LOGIC; 
  signal Inst_minimum23to16_Mcompar_n0000_inst_lut2_6 : STD_LOGIC; 
  signal Inst_minimum23to16_Mcompar_n0000_inst_cy_5 : STD_LOGIC; 
  signal Inst_minimum23to16_Mcompar_n0000_inst_lut2_5 : STD_LOGIC; 
  signal Inst_minimum23to16_Mcompar_n0000_inst_cy_4 : STD_LOGIC; 
  signal Inst_minimum23to16_Mcompar_n0000_inst_lut2_4 : STD_LOGIC; 
  signal Inst_minimum23to16_Mcompar_n0000_inst_cy_3 : STD_LOGIC; 
  signal Inst_minimum23to16_Mcompar_n0000_inst_lut2_3 : STD_LOGIC; 
  signal Inst_minimum23to16_Mcompar_n0000_inst_cy_2 : STD_LOGIC; 
  signal Inst_minimum23to16_Mcompar_n0000_inst_lut2_2 : STD_LOGIC; 
  signal Inst_minimum23to16_Mcompar_n0000_inst_cy_1 : STD_LOGIC; 
  signal Inst_minimum23to16_Mcompar_n0000_inst_lut2_1 : STD_LOGIC; 
  signal Inst_minimum31to24_Mcompar_n0000_inst_cy_0 : STD_LOGIC; 
  signal Inst_minimum31to24_Mcompar_n0000_inst_lut2_0 : STD_LOGIC; 
  signal Inst_minimum31to24_Mcompar_n0000_inst_lut2_7 : STD_LOGIC; 
  signal Inst_minimum31to24_Mcompar_n0000_inst_cy_6 : STD_LOGIC; 
  signal Inst_minimum31to24_Mcompar_n0000_inst_lut2_6 : STD_LOGIC; 
  signal Inst_minimum31to24_Mcompar_n0000_inst_cy_5 : STD_LOGIC; 
  signal Inst_minimum31to24_Mcompar_n0000_inst_lut2_5 : STD_LOGIC; 
  signal Inst_minimum31to24_Mcompar_n0000_inst_cy_4 : STD_LOGIC; 
  signal Inst_minimum31to24_Mcompar_n0000_inst_lut2_4 : STD_LOGIC; 
  signal Inst_minimum31to24_Mcompar_n0000_inst_cy_3 : STD_LOGIC; 
  signal Inst_minimum31to24_Mcompar_n0000_inst_lut2_3 : STD_LOGIC; 
  signal Inst_minimum31to24_Mcompar_n0000_inst_cy_2 : STD_LOGIC; 
  signal Inst_minimum31to24_Mcompar_n0000_inst_lut2_2 : STD_LOGIC; 
  signal Inst_minimum31to24_Mcompar_n0000_inst_cy_1 : STD_LOGIC; 
  signal Inst_minimum31to24_Mcompar_n0000_inst_lut2_1 : STD_LOGIC; 
  signal Inst_minimum39to32_Mcompar_n0000_inst_cy_0 : STD_LOGIC; 
  signal Inst_minimum39to32_Mcompar_n0000_inst_lut2_0 : STD_LOGIC; 
  signal Inst_minimum39to32_Mcompar_n0000_inst_lut2_7 : STD_LOGIC; 
  signal Inst_minimum39to32_Mcompar_n0000_inst_cy_6 : STD_LOGIC; 
  signal Inst_minimum39to32_Mcompar_n0000_inst_lut2_6 : STD_LOGIC; 
  signal Inst_minimum39to32_Mcompar_n0000_inst_cy_5 : STD_LOGIC; 
  signal Inst_minimum39to32_Mcompar_n0000_inst_lut2_5 : STD_LOGIC; 
  signal Inst_minimum39to32_Mcompar_n0000_inst_cy_4 : STD_LOGIC; 
  signal Inst_minimum39to32_Mcompar_n0000_inst_lut2_4 : STD_LOGIC; 
  signal Inst_minimum39to32_Mcompar_n0000_inst_cy_3 : STD_LOGIC; 
  signal Inst_minimum39to32_Mcompar_n0000_inst_lut2_3 : STD_LOGIC; 
  signal Inst_minimum39to32_Mcompar_n0000_inst_cy_2 : STD_LOGIC; 
  signal Inst_minimum39to32_Mcompar_n0000_inst_lut2_2 : STD_LOGIC; 
  signal Inst_minimum39to32_Mcompar_n0000_inst_cy_1 : STD_LOGIC; 
  signal Inst_minimum39to32_Mcompar_n0000_inst_lut2_1 : STD_LOGIC; 
  signal Inst_minimum47to40_Mcompar_n0000_inst_cy_0 : STD_LOGIC; 
  signal Inst_minimum47to40_Mcompar_n0000_inst_lut2_0 : STD_LOGIC; 
  signal Inst_minimum47to40_Mcompar_n0000_inst_lut2_7 : STD_LOGIC; 
  signal Inst_minimum47to40_Mcompar_n0000_inst_cy_6 : STD_LOGIC; 
  signal Inst_minimum47to40_Mcompar_n0000_inst_lut2_6 : STD_LOGIC; 
  signal Inst_minimum47to40_Mcompar_n0000_inst_cy_5 : STD_LOGIC; 
  signal Inst_minimum47to40_Mcompar_n0000_inst_lut2_5 : STD_LOGIC; 
  signal Inst_minimum47to40_Mcompar_n0000_inst_cy_4 : STD_LOGIC; 
  signal Inst_minimum47to40_Mcompar_n0000_inst_lut2_4 : STD_LOGIC; 
  signal Inst_minimum47to40_Mcompar_n0000_inst_cy_3 : STD_LOGIC; 
  signal Inst_minimum47to40_Mcompar_n0000_inst_lut2_3 : STD_LOGIC; 
  signal Inst_minimum47to40_Mcompar_n0000_inst_cy_2 : STD_LOGIC; 
  signal Inst_minimum47to40_Mcompar_n0000_inst_lut2_2 : STD_LOGIC; 
  signal Inst_minimum47to40_Mcompar_n0000_inst_cy_1 : STD_LOGIC; 
  signal Inst_minimum47to40_Mcompar_n0000_inst_lut2_1 : STD_LOGIC; 
  signal Inst_minimum55to48_Mcompar_n0000_inst_cy_0 : STD_LOGIC; 
  signal Inst_minimum55to48_Mcompar_n0000_inst_lut2_0 : STD_LOGIC; 
  signal Inst_minimum55to48_Mcompar_n0000_inst_lut2_7 : STD_LOGIC; 
  signal Inst_minimum55to48_Mcompar_n0000_inst_cy_6 : STD_LOGIC; 
  signal Inst_minimum55to48_Mcompar_n0000_inst_lut2_6 : STD_LOGIC; 
  signal Inst_minimum55to48_Mcompar_n0000_inst_cy_5 : STD_LOGIC; 
  signal Inst_minimum55to48_Mcompar_n0000_inst_lut2_5 : STD_LOGIC; 
  signal Inst_minimum55to48_Mcompar_n0000_inst_cy_4 : STD_LOGIC; 
  signal Inst_minimum55to48_Mcompar_n0000_inst_lut2_4 : STD_LOGIC; 
  signal Inst_minimum55to48_Mcompar_n0000_inst_cy_3 : STD_LOGIC; 
  signal Inst_minimum55to48_Mcompar_n0000_inst_lut2_3 : STD_LOGIC; 
  signal Inst_minimum55to48_Mcompar_n0000_inst_cy_2 : STD_LOGIC; 
  signal Inst_minimum55to48_Mcompar_n0000_inst_lut2_2 : STD_LOGIC; 
  signal Inst_minimum55to48_Mcompar_n0000_inst_cy_1 : STD_LOGIC; 
  signal Inst_minimum55to48_Mcompar_n0000_inst_lut2_1 : STD_LOGIC; 
  signal Inst_minimum63to56_Mcompar_n0000_inst_cy_0 : STD_LOGIC; 
  signal Inst_minimum63to56_Mcompar_n0000_inst_lut2_0 : STD_LOGIC; 
  signal Inst_minimum63to56_Mcompar_n0000_inst_lut2_7 : STD_LOGIC; 
  signal Inst_minimum63to56_Mcompar_n0000_inst_cy_6 : STD_LOGIC; 
  signal Inst_minimum63to56_Mcompar_n0000_inst_lut2_6 : STD_LOGIC; 
  signal Inst_minimum63to56_Mcompar_n0000_inst_cy_5 : STD_LOGIC; 
  signal Inst_minimum63to56_Mcompar_n0000_inst_lut2_5 : STD_LOGIC; 
  signal Inst_minimum63to56_Mcompar_n0000_inst_cy_4 : STD_LOGIC; 
  signal Inst_minimum63to56_Mcompar_n0000_inst_lut2_4 : STD_LOGIC; 
  signal Inst_minimum63to56_Mcompar_n0000_inst_cy_3 : STD_LOGIC; 
  signal Inst_minimum63to56_Mcompar_n0000_inst_lut2_3 : STD_LOGIC; 
  signal Inst_minimum63to56_Mcompar_n0000_inst_cy_2 : STD_LOGIC; 
  signal Inst_minimum63to56_Mcompar_n0000_inst_lut2_2 : STD_LOGIC; 
  signal Inst_minimum63to56_Mcompar_n0000_inst_cy_1 : STD_LOGIC; 
  signal Inst_minimum63to56_Mcompar_n0000_inst_lut2_1 : STD_LOGIC; 
  signal C_0_OBUF_GTS_TRI : STD_LOGIC; 
  signal GTS : STD_LOGIC; 
  signal C_63_OBUF_GTS_TRI : STD_LOGIC; 
  signal C_62_OBUF_GTS_TRI : STD_LOGIC; 
  signal C_61_OBUF_GTS_TRI : STD_LOGIC; 
  signal C_60_OBUF_GTS_TRI : STD_LOGIC; 
  signal C_59_OBUF_GTS_TRI : STD_LOGIC; 
  signal C_58_OBUF_GTS_TRI : STD_LOGIC; 
  signal C_57_OBUF_GTS_TRI : STD_LOGIC; 
  signal C_56_OBUF_GTS_TRI : STD_LOGIC; 
  signal C_55_OBUF_GTS_TRI : STD_LOGIC; 
  signal C_54_OBUF_GTS_TRI : STD_LOGIC; 
  signal C_53_OBUF_GTS_TRI : STD_LOGIC; 
  signal C_52_OBUF_GTS_TRI : STD_LOGIC; 
  signal C_51_OBUF_GTS_TRI : STD_LOGIC; 
  signal C_50_OBUF_GTS_TRI : STD_LOGIC; 
  signal C_49_OBUF_GTS_TRI : STD_LOGIC; 
  signal C_48_OBUF_GTS_TRI : STD_LOGIC; 
  signal C_47_OBUF_GTS_TRI : STD_LOGIC; 
  signal C_46_OBUF_GTS_TRI : STD_LOGIC; 
  signal C_45_OBUF_GTS_TRI : STD_LOGIC; 
  signal C_44_OBUF_GTS_TRI : STD_LOGIC; 
  signal C_43_OBUF_GTS_TRI : STD_LOGIC; 
  signal C_42_OBUF_GTS_TRI : STD_LOGIC; 
  signal C_41_OBUF_GTS_TRI : STD_LOGIC; 
  signal C_40_OBUF_GTS_TRI : STD_LOGIC; 
  signal C_39_OBUF_GTS_TRI : STD_LOGIC; 
  signal C_38_OBUF_GTS_TRI : STD_LOGIC; 
  signal C_37_OBUF_GTS_TRI : STD_LOGIC; 
  signal C_36_OBUF_GTS_TRI : STD_LOGIC; 
  signal C_35_OBUF_GTS_TRI : STD_LOGIC; 
  signal C_34_OBUF_GTS_TRI : STD_LOGIC; 
  signal C_33_OBUF_GTS_TRI : STD_LOGIC; 
  signal C_32_OBUF_GTS_TRI : STD_LOGIC; 
  signal C_31_OBUF_GTS_TRI : STD_LOGIC; 
  signal C_30_OBUF_GTS_TRI : STD_LOGIC; 
  signal C_29_OBUF_GTS_TRI : STD_LOGIC; 
  signal C_28_OBUF_GTS_TRI : STD_LOGIC; 
  signal C_27_OBUF_GTS_TRI : STD_LOGIC; 
  signal C_26_OBUF_GTS_TRI : STD_LOGIC; 
  signal C_25_OBUF_GTS_TRI : STD_LOGIC; 
  signal C_24_OBUF_GTS_TRI : STD_LOGIC; 
  signal C_23_OBUF_GTS_TRI : STD_LOGIC; 
  signal C_22_OBUF_GTS_TRI : STD_LOGIC; 
  signal C_21_OBUF_GTS_TRI : STD_LOGIC; 
  signal C_20_OBUF_GTS_TRI : STD_LOGIC; 
  signal C_19_OBUF_GTS_TRI : STD_LOGIC; 
  signal C_18_OBUF_GTS_TRI : STD_LOGIC; 
  signal C_17_OBUF_GTS_TRI : STD_LOGIC; 
  signal C_16_OBUF_GTS_TRI : STD_LOGIC; 
  signal C_15_OBUF_GTS_TRI : STD_LOGIC; 
  signal C_14_OBUF_GTS_TRI : STD_LOGIC; 
  signal C_13_OBUF_GTS_TRI : STD_LOGIC; 
  signal C_12_OBUF_GTS_TRI : STD_LOGIC; 
  signal C_11_OBUF_GTS_TRI : STD_LOGIC; 
  signal C_10_OBUF_GTS_TRI : STD_LOGIC; 
  signal C_9_OBUF_GTS_TRI : STD_LOGIC; 
  signal C_8_OBUF_GTS_TRI : STD_LOGIC; 
  signal C_7_OBUF_GTS_TRI : STD_LOGIC; 
  signal C_6_OBUF_GTS_TRI : STD_LOGIC; 
  signal C_5_OBUF_GTS_TRI : STD_LOGIC; 
  signal C_4_OBUF_GTS_TRI : STD_LOGIC; 
  signal C_3_OBUF_GTS_TRI : STD_LOGIC; 
  signal C_2_OBUF_GTS_TRI : STD_LOGIC; 
  signal C_1_OBUF_GTS_TRI : STD_LOGIC; 
  signal NlwInverterSignal_C_0_OBUF_GTS_TRI_CTL : STD_LOGIC; 
  signal NlwInverterSignal_C_63_OBUF_GTS_TRI_CTL : STD_LOGIC; 
  signal NlwInverterSignal_C_62_OBUF_GTS_TRI_CTL : STD_LOGIC; 
  signal NlwInverterSignal_C_61_OBUF_GTS_TRI_CTL : STD_LOGIC; 
  signal NlwInverterSignal_C_60_OBUF_GTS_TRI_CTL : STD_LOGIC; 
  signal NlwInverterSignal_C_59_OBUF_GTS_TRI_CTL : STD_LOGIC; 
  signal NlwInverterSignal_C_58_OBUF_GTS_TRI_CTL : STD_LOGIC; 
  signal NlwInverterSignal_C_57_OBUF_GTS_TRI_CTL : STD_LOGIC; 
  signal NlwInverterSignal_C_56_OBUF_GTS_TRI_CTL : STD_LOGIC; 
  signal NlwInverterSignal_C_55_OBUF_GTS_TRI_CTL : STD_LOGIC; 
  signal NlwInverterSignal_C_54_OBUF_GTS_TRI_CTL : STD_LOGIC; 
  signal NlwInverterSignal_C_53_OBUF_GTS_TRI_CTL : STD_LOGIC; 
  signal NlwInverterSignal_C_52_OBUF_GTS_TRI_CTL : STD_LOGIC; 
  signal NlwInverterSignal_C_51_OBUF_GTS_TRI_CTL : STD_LOGIC; 
  signal NlwInverterSignal_C_50_OBUF_GTS_TRI_CTL : STD_LOGIC; 
  signal NlwInverterSignal_C_49_OBUF_GTS_TRI_CTL : STD_LOGIC; 
  signal NlwInverterSignal_C_48_OBUF_GTS_TRI_CTL : STD_LOGIC; 
  signal NlwInverterSignal_C_47_OBUF_GTS_TRI_CTL : STD_LOGIC; 
  signal NlwInverterSignal_C_46_OBUF_GTS_TRI_CTL : STD_LOGIC; 
  signal NlwInverterSignal_C_45_OBUF_GTS_TRI_CTL : STD_LOGIC; 
  signal NlwInverterSignal_C_44_OBUF_GTS_TRI_CTL : STD_LOGIC; 
  signal NlwInverterSignal_C_43_OBUF_GTS_TRI_CTL : STD_LOGIC; 
  signal NlwInverterSignal_C_42_OBUF_GTS_TRI_CTL : STD_LOGIC; 
  signal NlwInverterSignal_C_41_OBUF_GTS_TRI_CTL : STD_LOGIC; 
  signal NlwInverterSignal_C_40_OBUF_GTS_TRI_CTL : STD_LOGIC; 
  signal NlwInverterSignal_C_39_OBUF_GTS_TRI_CTL : STD_LOGIC; 
  signal NlwInverterSignal_C_38_OBUF_GTS_TRI_CTL : STD_LOGIC; 
  signal NlwInverterSignal_C_37_OBUF_GTS_TRI_CTL : STD_LOGIC; 
  signal NlwInverterSignal_C_36_OBUF_GTS_TRI_CTL : STD_LOGIC; 
  signal NlwInverterSignal_C_35_OBUF_GTS_TRI_CTL : STD_LOGIC; 
  signal NlwInverterSignal_C_34_OBUF_GTS_TRI_CTL : STD_LOGIC; 
  signal NlwInverterSignal_C_33_OBUF_GTS_TRI_CTL : STD_LOGIC; 
  signal NlwInverterSignal_C_32_OBUF_GTS_TRI_CTL : STD_LOGIC; 
  signal NlwInverterSignal_C_31_OBUF_GTS_TRI_CTL : STD_LOGIC; 
  signal NlwInverterSignal_C_30_OBUF_GTS_TRI_CTL : STD_LOGIC; 
  signal NlwInverterSignal_C_29_OBUF_GTS_TRI_CTL : STD_LOGIC; 
  signal NlwInverterSignal_C_28_OBUF_GTS_TRI_CTL : STD_LOGIC; 
  signal NlwInverterSignal_C_27_OBUF_GTS_TRI_CTL : STD_LOGIC; 
  signal NlwInverterSignal_C_26_OBUF_GTS_TRI_CTL : STD_LOGIC; 
  signal NlwInverterSignal_C_25_OBUF_GTS_TRI_CTL : STD_LOGIC; 
  signal NlwInverterSignal_C_24_OBUF_GTS_TRI_CTL : STD_LOGIC; 
  signal NlwInverterSignal_C_23_OBUF_GTS_TRI_CTL : STD_LOGIC; 
  signal NlwInverterSignal_C_22_OBUF_GTS_TRI_CTL : STD_LOGIC; 
  signal NlwInverterSignal_C_21_OBUF_GTS_TRI_CTL : STD_LOGIC; 
  signal NlwInverterSignal_C_20_OBUF_GTS_TRI_CTL : STD_LOGIC; 
  signal NlwInverterSignal_C_19_OBUF_GTS_TRI_CTL : STD_LOGIC; 
  signal NlwInverterSignal_C_18_OBUF_GTS_TRI_CTL : STD_LOGIC; 
  signal NlwInverterSignal_C_17_OBUF_GTS_TRI_CTL : STD_LOGIC; 
  signal NlwInverterSignal_C_16_OBUF_GTS_TRI_CTL : STD_LOGIC; 
  signal NlwInverterSignal_C_15_OBUF_GTS_TRI_CTL : STD_LOGIC; 
  signal NlwInverterSignal_C_14_OBUF_GTS_TRI_CTL : STD_LOGIC; 
  signal NlwInverterSignal_C_13_OBUF_GTS_TRI_CTL : STD_LOGIC; 
  signal NlwInverterSignal_C_12_OBUF_GTS_TRI_CTL : STD_LOGIC; 
  signal NlwInverterSignal_C_11_OBUF_GTS_TRI_CTL : STD_LOGIC; 
  signal NlwInverterSignal_C_10_OBUF_GTS_TRI_CTL : STD_LOGIC; 
  signal NlwInverterSignal_C_9_OBUF_GTS_TRI_CTL : STD_LOGIC; 
  signal NlwInverterSignal_C_8_OBUF_GTS_TRI_CTL : STD_LOGIC; 
  signal NlwInverterSignal_C_7_OBUF_GTS_TRI_CTL : STD_LOGIC; 
  signal NlwInverterSignal_C_6_OBUF_GTS_TRI_CTL : STD_LOGIC; 
  signal NlwInverterSignal_C_5_OBUF_GTS_TRI_CTL : STD_LOGIC; 
  signal NlwInverterSignal_C_4_OBUF_GTS_TRI_CTL : STD_LOGIC; 
  signal NlwInverterSignal_C_3_OBUF_GTS_TRI_CTL : STD_LOGIC; 
  signal NlwInverterSignal_C_2_OBUF_GTS_TRI_CTL : STD_LOGIC; 
  signal NlwInverterSignal_C_1_OBUF_GTS_TRI_CTL : STD_LOGIC; 
begin
  Inst_minimum63to56_Mmux_C_Result_7_1 : X_LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      ADR0 => Inst_minimum63to56_n0000,
      ADR1 => B_63_IBUF,
      ADR2 => A_7_IBUF,
      O => C_63_OBUF
    );
  Inst_minimum55to48_Mmux_C_Result_7_1 : X_LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      ADR0 => Inst_minimum55to48_n0000,
      ADR1 => B_55_IBUF,
      ADR2 => A_7_IBUF,
      O => C_55_OBUF
    );
  Inst_minimum7to0_Mmux_C_Result_7_1 : X_LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      ADR0 => Inst_minimum7to0_n0000,
      ADR1 => B_7_IBUF,
      ADR2 => A_7_IBUF,
      O => C_7_OBUF
    );
  Inst_minimum15to8_Mmux_C_Result_7_1 : X_LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      ADR0 => Inst_minimum15to8_n0000,
      ADR1 => B_15_IBUF,
      ADR2 => A_7_IBUF,
      O => C_15_OBUF
    );
  Inst_minimum23to16_Mmux_C_Result_7_1 : X_LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      ADR0 => Inst_minimum23to16_n0000,
      ADR1 => B_23_IBUF,
      ADR2 => A_7_IBUF,
      O => C_23_OBUF
    );
  Inst_minimum31to24_Mmux_C_Result_7_1 : X_LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      ADR0 => Inst_minimum31to24_n0000,
      ADR1 => B_31_IBUF,
      ADR2 => A_7_IBUF,
      O => C_31_OBUF
    );
  Inst_minimum39to32_Mmux_C_Result_7_1 : X_LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      ADR0 => Inst_minimum39to32_n0000,
      ADR1 => B_39_IBUF,
      ADR2 => A_7_IBUF,
      O => C_39_OBUF
    );
  Inst_minimum47to40_Mmux_C_Result_7_1 : X_LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      ADR0 => Inst_minimum47to40_n0000,
      ADR1 => B_47_IBUF,
      ADR2 => A_7_IBUF,
      O => C_47_OBUF
    );
  Inst_minimum63to56_Mcompar_n0000_inst_cy_6_0 : X_MUX2
    port map (
      IB => Inst_minimum63to56_Mcompar_n0000_inst_cy_5,
      IA => B_62_IBUF,
      SEL => Inst_minimum63to56_Mcompar_n0000_inst_lut2_6,
      O => Inst_minimum63to56_Mcompar_n0000_inst_cy_6
    );
  Inst_minimum55to48_Mcompar_n0000_inst_cy_6_1 : X_MUX2
    port map (
      IB => Inst_minimum55to48_Mcompar_n0000_inst_cy_5,
      IA => B_54_IBUF,
      SEL => Inst_minimum55to48_Mcompar_n0000_inst_lut2_6,
      O => Inst_minimum55to48_Mcompar_n0000_inst_cy_6
    );
  Inst_minimum47to40_Mcompar_n0000_inst_cy_6_2 : X_MUX2
    port map (
      IB => Inst_minimum47to40_Mcompar_n0000_inst_cy_5,
      IA => B_46_IBUF,
      SEL => Inst_minimum47to40_Mcompar_n0000_inst_lut2_6,
      O => Inst_minimum47to40_Mcompar_n0000_inst_cy_6
    );
  Inst_minimum39to32_Mcompar_n0000_inst_cy_6_3 : X_MUX2
    port map (
      IB => Inst_minimum39to32_Mcompar_n0000_inst_cy_5,
      IA => B_38_IBUF,
      SEL => Inst_minimum39to32_Mcompar_n0000_inst_lut2_6,
      O => Inst_minimum39to32_Mcompar_n0000_inst_cy_6
    );
  Inst_minimum31to24_Mcompar_n0000_inst_cy_6_4 : X_MUX2
    port map (
      IB => Inst_minimum31to24_Mcompar_n0000_inst_cy_5,
      IA => B_30_IBUF,
      SEL => Inst_minimum31to24_Mcompar_n0000_inst_lut2_6,
      O => Inst_minimum31to24_Mcompar_n0000_inst_cy_6
    );
  Inst_minimum23to16_Mcompar_n0000_inst_cy_6_5 : X_MUX2
    port map (
      IB => Inst_minimum23to16_Mcompar_n0000_inst_cy_5,
      IA => B_22_IBUF,
      SEL => Inst_minimum23to16_Mcompar_n0000_inst_lut2_6,
      O => Inst_minimum23to16_Mcompar_n0000_inst_cy_6
    );
  Inst_minimum15to8_Mcompar_n0000_inst_cy_6_6 : X_MUX2
    port map (
      IB => Inst_minimum15to8_Mcompar_n0000_inst_cy_5,
      IA => B_14_IBUF,
      SEL => Inst_minimum15to8_Mcompar_n0000_inst_lut2_6,
      O => Inst_minimum15to8_Mcompar_n0000_inst_cy_6
    );
  Inst_minimum7to0_Mcompar_n0000_inst_cy_7 : X_MUX2
    port map (
      IB => Inst_minimum7to0_Mcompar_n0000_inst_cy_6,
      IA => B_7_IBUF,
      SEL => Inst_minimum7to0_Mcompar_n0000_inst_lut2_7,
      O => Inst_minimum7to0_n0000
    );
  XST_GND : X_ZERO
    port map (
      O => N183
    );
  C_0_OBUF_7 : X_BUF
    port map (
      I => C_0_OBUF,
      O => C_0_OBUF_GTS_TRI
    );
  Inst_minimum7to0_Mcompar_n0000_inst_lut2_01 : X_LUT2
    generic map(
      INIT => X"9"
    )
    port map (
      ADR0 => B_0_IBUF,
      ADR1 => A_0_IBUF,
      O => Inst_minimum7to0_Mcompar_n0000_inst_lut2_0
    );
  Inst_minimum7to0_Mcompar_n0000_inst_cy_0_8 : X_MUX2
    port map (
      IB => N183,
      IA => B_0_IBUF,
      SEL => Inst_minimum7to0_Mcompar_n0000_inst_lut2_0,
      O => Inst_minimum7to0_Mcompar_n0000_inst_cy_0
    );
  Inst_minimum7to0_Mcompar_n0000_inst_lut2_11 : X_LUT2
    generic map(
      INIT => X"9"
    )
    port map (
      ADR0 => B_1_IBUF,
      ADR1 => A_1_IBUF,
      O => Inst_minimum7to0_Mcompar_n0000_inst_lut2_1
    );
  Inst_minimum7to0_Mcompar_n0000_inst_cy_1_9 : X_MUX2
    port map (
      IB => Inst_minimum7to0_Mcompar_n0000_inst_cy_0,
      IA => B_1_IBUF,
      SEL => Inst_minimum7to0_Mcompar_n0000_inst_lut2_1,
      O => Inst_minimum7to0_Mcompar_n0000_inst_cy_1
    );
  Inst_minimum7to0_Mcompar_n0000_inst_lut2_21 : X_LUT2
    generic map(
      INIT => X"9"
    )
    port map (
      ADR0 => B_2_IBUF,
      ADR1 => A_2_IBUF,
      O => Inst_minimum7to0_Mcompar_n0000_inst_lut2_2
    );
  Inst_minimum7to0_Mcompar_n0000_inst_cy_2_10 : X_MUX2
    port map (
      IB => Inst_minimum7to0_Mcompar_n0000_inst_cy_1,
      IA => B_2_IBUF,
      SEL => Inst_minimum7to0_Mcompar_n0000_inst_lut2_2,
      O => Inst_minimum7to0_Mcompar_n0000_inst_cy_2
    );
  Inst_minimum7to0_Mcompar_n0000_inst_lut2_31 : X_LUT2
    generic map(
      INIT => X"9"
    )
    port map (
      ADR0 => B_3_IBUF,
      ADR1 => A_3_IBUF,
      O => Inst_minimum7to0_Mcompar_n0000_inst_lut2_3
    );
  Inst_minimum7to0_Mcompar_n0000_inst_cy_3_11 : X_MUX2
    port map (
      IB => Inst_minimum7to0_Mcompar_n0000_inst_cy_2,
      IA => B_3_IBUF,
      SEL => Inst_minimum7to0_Mcompar_n0000_inst_lut2_3,
      O => Inst_minimum7to0_Mcompar_n0000_inst_cy_3
    );
  Inst_minimum7to0_Mcompar_n0000_inst_lut2_41 : X_LUT2
    generic map(
      INIT => X"9"
    )
    port map (
      ADR0 => B_4_IBUF,
      ADR1 => A_4_IBUF,
      O => Inst_minimum7to0_Mcompar_n0000_inst_lut2_4
    );
  Inst_minimum7to0_Mcompar_n0000_inst_cy_4_12 : X_MUX2
    port map (
      IB => Inst_minimum7to0_Mcompar_n0000_inst_cy_3,
      IA => B_4_IBUF,
      SEL => Inst_minimum7to0_Mcompar_n0000_inst_lut2_4,
      O => Inst_minimum7to0_Mcompar_n0000_inst_cy_4
    );
  Inst_minimum7to0_Mcompar_n0000_inst_lut2_51 : X_LUT2
    generic map(
      INIT => X"9"
    )
    port map (
      ADR0 => B_5_IBUF,
      ADR1 => A_5_IBUF,
      O => Inst_minimum7to0_Mcompar_n0000_inst_lut2_5
    );
  Inst_minimum7to0_Mcompar_n0000_inst_cy_5_13 : X_MUX2
    port map (
      IB => Inst_minimum7to0_Mcompar_n0000_inst_cy_4,
      IA => B_5_IBUF,
      SEL => Inst_minimum7to0_Mcompar_n0000_inst_lut2_5,
      O => Inst_minimum7to0_Mcompar_n0000_inst_cy_5
    );
  Inst_minimum7to0_Mcompar_n0000_inst_lut2_61 : X_LUT2
    generic map(
      INIT => X"9"
    )
    port map (
      ADR0 => B_6_IBUF,
      ADR1 => A_6_IBUF,
      O => Inst_minimum7to0_Mcompar_n0000_inst_lut2_6
    );
  Inst_minimum7to0_Mcompar_n0000_inst_cy_6_14 : X_MUX2
    port map (
      IB => Inst_minimum7to0_Mcompar_n0000_inst_cy_5,
      IA => B_6_IBUF,
      SEL => Inst_minimum7to0_Mcompar_n0000_inst_lut2_6,
      O => Inst_minimum7to0_Mcompar_n0000_inst_cy_6
    );
  Inst_minimum7to0_Mcompar_n0000_inst_lut2_71 : X_LUT2
    generic map(
      INIT => X"9"
    )
    port map (
      ADR0 => B_7_IBUF,
      ADR1 => A_7_IBUF,
      O => Inst_minimum7to0_Mcompar_n0000_inst_lut2_7
    );
  Inst_minimum15to8_Mcompar_n0000_inst_lut2_71 : X_LUT2
    generic map(
      INIT => X"9"
    )
    port map (
      ADR0 => B_15_IBUF,
      ADR1 => A_7_IBUF,
      O => Inst_minimum15to8_Mcompar_n0000_inst_lut2_7
    );
  Inst_minimum15to8_Mcompar_n0000_inst_cy_7 : X_MUX2
    port map (
      IB => Inst_minimum15to8_Mcompar_n0000_inst_cy_6,
      IA => B_15_IBUF,
      SEL => Inst_minimum15to8_Mcompar_n0000_inst_lut2_7,
      O => Inst_minimum15to8_n0000
    );
  Inst_minimum15to8_Mcompar_n0000_inst_lut2_01 : X_LUT2
    generic map(
      INIT => X"9"
    )
    port map (
      ADR0 => B_8_IBUF,
      ADR1 => A_0_IBUF,
      O => Inst_minimum15to8_Mcompar_n0000_inst_lut2_0
    );
  Inst_minimum15to8_Mcompar_n0000_inst_cy_0_15 : X_MUX2
    port map (
      IB => N183,
      IA => B_8_IBUF,
      SEL => Inst_minimum15to8_Mcompar_n0000_inst_lut2_0,
      O => Inst_minimum15to8_Mcompar_n0000_inst_cy_0
    );
  Inst_minimum15to8_Mcompar_n0000_inst_lut2_11 : X_LUT2
    generic map(
      INIT => X"9"
    )
    port map (
      ADR0 => B_9_IBUF,
      ADR1 => A_1_IBUF,
      O => Inst_minimum15to8_Mcompar_n0000_inst_lut2_1
    );
  Inst_minimum15to8_Mcompar_n0000_inst_cy_1_16 : X_MUX2
    port map (
      IB => Inst_minimum15to8_Mcompar_n0000_inst_cy_0,
      IA => B_9_IBUF,
      SEL => Inst_minimum15to8_Mcompar_n0000_inst_lut2_1,
      O => Inst_minimum15to8_Mcompar_n0000_inst_cy_1
    );
  Inst_minimum15to8_Mcompar_n0000_inst_lut2_21 : X_LUT2
    generic map(
      INIT => X"9"
    )
    port map (
      ADR0 => B_10_IBUF,
      ADR1 => A_2_IBUF,
      O => Inst_minimum15to8_Mcompar_n0000_inst_lut2_2
    );
  Inst_minimum15to8_Mcompar_n0000_inst_cy_2_17 : X_MUX2
    port map (
      IB => Inst_minimum15to8_Mcompar_n0000_inst_cy_1,
      IA => B_10_IBUF,
      SEL => Inst_minimum15to8_Mcompar_n0000_inst_lut2_2,
      O => Inst_minimum15to8_Mcompar_n0000_inst_cy_2
    );
  Inst_minimum15to8_Mcompar_n0000_inst_lut2_31 : X_LUT2
    generic map(
      INIT => X"9"
    )
    port map (
      ADR0 => B_11_IBUF,
      ADR1 => A_3_IBUF,
      O => Inst_minimum15to8_Mcompar_n0000_inst_lut2_3
    );
  Inst_minimum15to8_Mcompar_n0000_inst_cy_3_18 : X_MUX2
    port map (
      IB => Inst_minimum15to8_Mcompar_n0000_inst_cy_2,
      IA => B_11_IBUF,
      SEL => Inst_minimum15to8_Mcompar_n0000_inst_lut2_3,
      O => Inst_minimum15to8_Mcompar_n0000_inst_cy_3
    );
  Inst_minimum15to8_Mcompar_n0000_inst_lut2_41 : X_LUT2
    generic map(
      INIT => X"9"
    )
    port map (
      ADR0 => B_12_IBUF,
      ADR1 => A_4_IBUF,
      O => Inst_minimum15to8_Mcompar_n0000_inst_lut2_4
    );
  Inst_minimum15to8_Mcompar_n0000_inst_cy_4_19 : X_MUX2
    port map (
      IB => Inst_minimum15to8_Mcompar_n0000_inst_cy_3,
      IA => B_12_IBUF,
      SEL => Inst_minimum15to8_Mcompar_n0000_inst_lut2_4,
      O => Inst_minimum15to8_Mcompar_n0000_inst_cy_4
    );
  Inst_minimum15to8_Mcompar_n0000_inst_lut2_51 : X_LUT2
    generic map(
      INIT => X"9"
    )
    port map (
      ADR0 => B_13_IBUF,
      ADR1 => A_5_IBUF,
      O => Inst_minimum15to8_Mcompar_n0000_inst_lut2_5
    );
  Inst_minimum15to8_Mcompar_n0000_inst_cy_5_20 : X_MUX2
    port map (
      IB => Inst_minimum15to8_Mcompar_n0000_inst_cy_4,
      IA => B_13_IBUF,
      SEL => Inst_minimum15to8_Mcompar_n0000_inst_lut2_5,
      O => Inst_minimum15to8_Mcompar_n0000_inst_cy_5
    );
  Inst_minimum15to8_Mcompar_n0000_inst_lut2_61 : X_LUT2
    generic map(
      INIT => X"9"
    )
    port map (
      ADR0 => B_14_IBUF,
      ADR1 => A_6_IBUF,
      O => Inst_minimum15to8_Mcompar_n0000_inst_lut2_6
    );
  Inst_minimum23to16_Mcompar_n0000_inst_lut2_71 : X_LUT2
    generic map(
      INIT => X"9"
    )
    port map (
      ADR0 => B_23_IBUF,
      ADR1 => A_7_IBUF,
      O => Inst_minimum23to16_Mcompar_n0000_inst_lut2_7
    );
  Inst_minimum23to16_Mcompar_n0000_inst_cy_7 : X_MUX2
    port map (
      IB => Inst_minimum23to16_Mcompar_n0000_inst_cy_6,
      IA => B_23_IBUF,
      SEL => Inst_minimum23to16_Mcompar_n0000_inst_lut2_7,
      O => Inst_minimum23to16_n0000
    );
  Inst_minimum23to16_Mcompar_n0000_inst_lut2_01 : X_LUT2
    generic map(
      INIT => X"9"
    )
    port map (
      ADR0 => B_16_IBUF,
      ADR1 => A_0_IBUF,
      O => Inst_minimum23to16_Mcompar_n0000_inst_lut2_0
    );
  Inst_minimum23to16_Mcompar_n0000_inst_cy_0_21 : X_MUX2
    port map (
      IB => N183,
      IA => B_16_IBUF,
      SEL => Inst_minimum23to16_Mcompar_n0000_inst_lut2_0,
      O => Inst_minimum23to16_Mcompar_n0000_inst_cy_0
    );
  Inst_minimum23to16_Mcompar_n0000_inst_lut2_11 : X_LUT2
    generic map(
      INIT => X"9"
    )
    port map (
      ADR0 => B_17_IBUF,
      ADR1 => A_1_IBUF,
      O => Inst_minimum23to16_Mcompar_n0000_inst_lut2_1
    );
  Inst_minimum23to16_Mcompar_n0000_inst_cy_1_22 : X_MUX2
    port map (
      IB => Inst_minimum23to16_Mcompar_n0000_inst_cy_0,
      IA => B_17_IBUF,
      SEL => Inst_minimum23to16_Mcompar_n0000_inst_lut2_1,
      O => Inst_minimum23to16_Mcompar_n0000_inst_cy_1
    );
  Inst_minimum23to16_Mcompar_n0000_inst_lut2_21 : X_LUT2
    generic map(
      INIT => X"9"
    )
    port map (
      ADR0 => B_18_IBUF,
      ADR1 => A_2_IBUF,
      O => Inst_minimum23to16_Mcompar_n0000_inst_lut2_2
    );
  Inst_minimum23to16_Mcompar_n0000_inst_cy_2_23 : X_MUX2
    port map (
      IB => Inst_minimum23to16_Mcompar_n0000_inst_cy_1,
      IA => B_18_IBUF,
      SEL => Inst_minimum23to16_Mcompar_n0000_inst_lut2_2,
      O => Inst_minimum23to16_Mcompar_n0000_inst_cy_2
    );
  Inst_minimum23to16_Mcompar_n0000_inst_lut2_31 : X_LUT2
    generic map(
      INIT => X"9"
    )
    port map (
      ADR0 => B_19_IBUF,
      ADR1 => A_3_IBUF,
      O => Inst_minimum23to16_Mcompar_n0000_inst_lut2_3
    );
  Inst_minimum23to16_Mcompar_n0000_inst_cy_3_24 : X_MUX2
    port map (
      IB => Inst_minimum23to16_Mcompar_n0000_inst_cy_2,
      IA => B_19_IBUF,
      SEL => Inst_minimum23to16_Mcompar_n0000_inst_lut2_3,
      O => Inst_minimum23to16_Mcompar_n0000_inst_cy_3
    );
  Inst_minimum23to16_Mcompar_n0000_inst_lut2_41 : X_LUT2
    generic map(
      INIT => X"9"
    )
    port map (
      ADR0 => B_20_IBUF,
      ADR1 => A_4_IBUF,
      O => Inst_minimum23to16_Mcompar_n0000_inst_lut2_4
    );
  Inst_minimum23to16_Mcompar_n0000_inst_cy_4_25 : X_MUX2
    port map (
      IB => Inst_minimum23to16_Mcompar_n0000_inst_cy_3,
      IA => B_20_IBUF,
      SEL => Inst_minimum23to16_Mcompar_n0000_inst_lut2_4,
      O => Inst_minimum23to16_Mcompar_n0000_inst_cy_4
    );
  Inst_minimum23to16_Mcompar_n0000_inst_lut2_51 : X_LUT2
    generic map(
      INIT => X"9"
    )
    port map (
      ADR0 => B_21_IBUF,
      ADR1 => A_5_IBUF,
      O => Inst_minimum23to16_Mcompar_n0000_inst_lut2_5
    );
  Inst_minimum23to16_Mcompar_n0000_inst_cy_5_26 : X_MUX2
    port map (
      IB => Inst_minimum23to16_Mcompar_n0000_inst_cy_4,
      IA => B_21_IBUF,
      SEL => Inst_minimum23to16_Mcompar_n0000_inst_lut2_5,
      O => Inst_minimum23to16_Mcompar_n0000_inst_cy_5
    );
  Inst_minimum23to16_Mcompar_n0000_inst_lut2_61 : X_LUT2
    generic map(
      INIT => X"9"
    )
    port map (
      ADR0 => B_22_IBUF,
      ADR1 => A_6_IBUF,
      O => Inst_minimum23to16_Mcompar_n0000_inst_lut2_6
    );
  Inst_minimum31to24_Mcompar_n0000_inst_lut2_71 : X_LUT2
    generic map(
      INIT => X"9"
    )
    port map (
      ADR0 => B_31_IBUF,
      ADR1 => A_7_IBUF,
      O => Inst_minimum31to24_Mcompar_n0000_inst_lut2_7
    );
  Inst_minimum31to24_Mcompar_n0000_inst_cy_7 : X_MUX2
    port map (
      IB => Inst_minimum31to24_Mcompar_n0000_inst_cy_6,
      IA => B_31_IBUF,
      SEL => Inst_minimum31to24_Mcompar_n0000_inst_lut2_7,
      O => Inst_minimum31to24_n0000
    );
  Inst_minimum31to24_Mcompar_n0000_inst_lut2_01 : X_LUT2
    generic map(
      INIT => X"9"
    )
    port map (
      ADR0 => B_24_IBUF,
      ADR1 => A_0_IBUF,
      O => Inst_minimum31to24_Mcompar_n0000_inst_lut2_0
    );
  Inst_minimum31to24_Mcompar_n0000_inst_cy_0_27 : X_MUX2
    port map (
      IB => N183,
      IA => B_24_IBUF,
      SEL => Inst_minimum31to24_Mcompar_n0000_inst_lut2_0,
      O => Inst_minimum31to24_Mcompar_n0000_inst_cy_0
    );
  Inst_minimum31to24_Mcompar_n0000_inst_lut2_11 : X_LUT2
    generic map(
      INIT => X"9"
    )
    port map (
      ADR0 => B_25_IBUF,
      ADR1 => A_1_IBUF,
      O => Inst_minimum31to24_Mcompar_n0000_inst_lut2_1
    );
  Inst_minimum31to24_Mcompar_n0000_inst_cy_1_28 : X_MUX2
    port map (
      IB => Inst_minimum31to24_Mcompar_n0000_inst_cy_0,
      IA => B_25_IBUF,
      SEL => Inst_minimum31to24_Mcompar_n0000_inst_lut2_1,
      O => Inst_minimum31to24_Mcompar_n0000_inst_cy_1
    );
  Inst_minimum31to24_Mcompar_n0000_inst_lut2_21 : X_LUT2
    generic map(
      INIT => X"9"
    )
    port map (
      ADR0 => B_26_IBUF,
      ADR1 => A_2_IBUF,
      O => Inst_minimum31to24_Mcompar_n0000_inst_lut2_2
    );
  Inst_minimum31to24_Mcompar_n0000_inst_cy_2_29 : X_MUX2
    port map (
      IB => Inst_minimum31to24_Mcompar_n0000_inst_cy_1,
      IA => B_26_IBUF,
      SEL => Inst_minimum31to24_Mcompar_n0000_inst_lut2_2,
      O => Inst_minimum31to24_Mcompar_n0000_inst_cy_2
    );
  Inst_minimum31to24_Mcompar_n0000_inst_lut2_31 : X_LUT2
    generic map(
      INIT => X"9"
    )
    port map (
      ADR0 => B_27_IBUF,
      ADR1 => A_3_IBUF,
      O => Inst_minimum31to24_Mcompar_n0000_inst_lut2_3
    );
  Inst_minimum31to24_Mcompar_n0000_inst_cy_3_30 : X_MUX2
    port map (
      IB => Inst_minimum31to24_Mcompar_n0000_inst_cy_2,
      IA => B_27_IBUF,
      SEL => Inst_minimum31to24_Mcompar_n0000_inst_lut2_3,
      O => Inst_minimum31to24_Mcompar_n0000_inst_cy_3
    );
  Inst_minimum31to24_Mcompar_n0000_inst_lut2_41 : X_LUT2
    generic map(
      INIT => X"9"
    )
    port map (
      ADR0 => B_28_IBUF,
      ADR1 => A_4_IBUF,
      O => Inst_minimum31to24_Mcompar_n0000_inst_lut2_4
    );
  Inst_minimum31to24_Mcompar_n0000_inst_cy_4_31 : X_MUX2
    port map (
      IB => Inst_minimum31to24_Mcompar_n0000_inst_cy_3,
      IA => B_28_IBUF,
      SEL => Inst_minimum31to24_Mcompar_n0000_inst_lut2_4,
      O => Inst_minimum31to24_Mcompar_n0000_inst_cy_4
    );
  Inst_minimum31to24_Mcompar_n0000_inst_lut2_51 : X_LUT2
    generic map(
      INIT => X"9"
    )
    port map (
      ADR0 => B_29_IBUF,
      ADR1 => A_5_IBUF,
      O => Inst_minimum31to24_Mcompar_n0000_inst_lut2_5
    );
  Inst_minimum31to24_Mcompar_n0000_inst_cy_5_32 : X_MUX2
    port map (
      IB => Inst_minimum31to24_Mcompar_n0000_inst_cy_4,
      IA => B_29_IBUF,
      SEL => Inst_minimum31to24_Mcompar_n0000_inst_lut2_5,
      O => Inst_minimum31to24_Mcompar_n0000_inst_cy_5
    );
  Inst_minimum31to24_Mcompar_n0000_inst_lut2_61 : X_LUT2
    generic map(
      INIT => X"9"
    )
    port map (
      ADR0 => B_30_IBUF,
      ADR1 => A_6_IBUF,
      O => Inst_minimum31to24_Mcompar_n0000_inst_lut2_6
    );
  Inst_minimum39to32_Mcompar_n0000_inst_lut2_71 : X_LUT2
    generic map(
      INIT => X"9"
    )
    port map (
      ADR0 => B_39_IBUF,
      ADR1 => A_7_IBUF,
      O => Inst_minimum39to32_Mcompar_n0000_inst_lut2_7
    );
  Inst_minimum39to32_Mcompar_n0000_inst_cy_7 : X_MUX2
    port map (
      IB => Inst_minimum39to32_Mcompar_n0000_inst_cy_6,
      IA => B_39_IBUF,
      SEL => Inst_minimum39to32_Mcompar_n0000_inst_lut2_7,
      O => Inst_minimum39to32_n0000
    );
  Inst_minimum39to32_Mcompar_n0000_inst_lut2_01 : X_LUT2
    generic map(
      INIT => X"9"
    )
    port map (
      ADR0 => B_32_IBUF,
      ADR1 => A_0_IBUF,
      O => Inst_minimum39to32_Mcompar_n0000_inst_lut2_0
    );
  Inst_minimum39to32_Mcompar_n0000_inst_cy_0_33 : X_MUX2
    port map (
      IB => N183,
      IA => B_32_IBUF,
      SEL => Inst_minimum39to32_Mcompar_n0000_inst_lut2_0,
      O => Inst_minimum39to32_Mcompar_n0000_inst_cy_0
    );
  Inst_minimum39to32_Mcompar_n0000_inst_lut2_11 : X_LUT2
    generic map(
      INIT => X"9"
    )
    port map (
      ADR0 => B_33_IBUF,
      ADR1 => A_1_IBUF,
      O => Inst_minimum39to32_Mcompar_n0000_inst_lut2_1
    );
  Inst_minimum39to32_Mcompar_n0000_inst_cy_1_34 : X_MUX2
    port map (
      IB => Inst_minimum39to32_Mcompar_n0000_inst_cy_0,
      IA => B_33_IBUF,
      SEL => Inst_minimum39to32_Mcompar_n0000_inst_lut2_1,
      O => Inst_minimum39to32_Mcompar_n0000_inst_cy_1
    );
  Inst_minimum39to32_Mcompar_n0000_inst_lut2_21 : X_LUT2
    generic map(
      INIT => X"9"
    )
    port map (
      ADR0 => B_34_IBUF,
      ADR1 => A_2_IBUF,
      O => Inst_minimum39to32_Mcompar_n0000_inst_lut2_2
    );
  Inst_minimum39to32_Mcompar_n0000_inst_cy_2_35 : X_MUX2
    port map (
      IB => Inst_minimum39to32_Mcompar_n0000_inst_cy_1,
      IA => B_34_IBUF,
      SEL => Inst_minimum39to32_Mcompar_n0000_inst_lut2_2,
      O => Inst_minimum39to32_Mcompar_n0000_inst_cy_2
    );
  Inst_minimum39to32_Mcompar_n0000_inst_lut2_31 : X_LUT2
    generic map(
      INIT => X"9"
    )
    port map (
      ADR0 => B_35_IBUF,
      ADR1 => A_3_IBUF,
      O => Inst_minimum39to32_Mcompar_n0000_inst_lut2_3
    );
  Inst_minimum39to32_Mcompar_n0000_inst_cy_3_36 : X_MUX2
    port map (
      IB => Inst_minimum39to32_Mcompar_n0000_inst_cy_2,
      IA => B_35_IBUF,
      SEL => Inst_minimum39to32_Mcompar_n0000_inst_lut2_3,
      O => Inst_minimum39to32_Mcompar_n0000_inst_cy_3
    );
  Inst_minimum39to32_Mcompar_n0000_inst_lut2_41 : X_LUT2
    generic map(
      INIT => X"9"
    )
    port map (
      ADR0 => B_36_IBUF,
      ADR1 => A_4_IBUF,
      O => Inst_minimum39to32_Mcompar_n0000_inst_lut2_4
    );
  Inst_minimum39to32_Mcompar_n0000_inst_cy_4_37 : X_MUX2
    port map (
      IB => Inst_minimum39to32_Mcompar_n0000_inst_cy_3,
      IA => B_36_IBUF,
      SEL => Inst_minimum39to32_Mcompar_n0000_inst_lut2_4,
      O => Inst_minimum39to32_Mcompar_n0000_inst_cy_4
    );
  Inst_minimum39to32_Mcompar_n0000_inst_lut2_51 : X_LUT2
    generic map(
      INIT => X"9"
    )
    port map (
      ADR0 => B_37_IBUF,
      ADR1 => A_5_IBUF,
      O => Inst_minimum39to32_Mcompar_n0000_inst_lut2_5
    );
  Inst_minimum39to32_Mcompar_n0000_inst_cy_5_38 : X_MUX2
    port map (
      IB => Inst_minimum39to32_Mcompar_n0000_inst_cy_4,
      IA => B_37_IBUF,
      SEL => Inst_minimum39to32_Mcompar_n0000_inst_lut2_5,
      O => Inst_minimum39to32_Mcompar_n0000_inst_cy_5
    );
  Inst_minimum39to32_Mcompar_n0000_inst_lut2_61 : X_LUT2
    generic map(
      INIT => X"9"
    )
    port map (
      ADR0 => B_38_IBUF,
      ADR1 => A_6_IBUF,
      O => Inst_minimum39to32_Mcompar_n0000_inst_lut2_6
    );
  Inst_minimum47to40_Mcompar_n0000_inst_lut2_71 : X_LUT2
    generic map(
      INIT => X"9"
    )
    port map (
      ADR0 => B_47_IBUF,
      ADR1 => A_7_IBUF,
      O => Inst_minimum47to40_Mcompar_n0000_inst_lut2_7
    );
  Inst_minimum47to40_Mcompar_n0000_inst_cy_7 : X_MUX2
    port map (
      IB => Inst_minimum47to40_Mcompar_n0000_inst_cy_6,
      IA => B_47_IBUF,
      SEL => Inst_minimum47to40_Mcompar_n0000_inst_lut2_7,
      O => Inst_minimum47to40_n0000
    );
  Inst_minimum47to40_Mcompar_n0000_inst_lut2_01 : X_LUT2
    generic map(
      INIT => X"9"
    )
    port map (
      ADR0 => B_40_IBUF,
      ADR1 => A_0_IBUF,
      O => Inst_minimum47to40_Mcompar_n0000_inst_lut2_0
    );
  Inst_minimum47to40_Mcompar_n0000_inst_cy_0_39 : X_MUX2
    port map (
      IB => N183,
      IA => B_40_IBUF,
      SEL => Inst_minimum47to40_Mcompar_n0000_inst_lut2_0,
      O => Inst_minimum47to40_Mcompar_n0000_inst_cy_0
    );
  Inst_minimum47to40_Mcompar_n0000_inst_lut2_11 : X_LUT2
    generic map(
      INIT => X"9"
    )
    port map (
      ADR0 => B_41_IBUF,
      ADR1 => A_1_IBUF,
      O => Inst_minimum47to40_Mcompar_n0000_inst_lut2_1
    );
  Inst_minimum47to40_Mcompar_n0000_inst_cy_1_40 : X_MUX2
    port map (
      IB => Inst_minimum47to40_Mcompar_n0000_inst_cy_0,
      IA => B_41_IBUF,
      SEL => Inst_minimum47to40_Mcompar_n0000_inst_lut2_1,
      O => Inst_minimum47to40_Mcompar_n0000_inst_cy_1
    );
  Inst_minimum47to40_Mcompar_n0000_inst_lut2_21 : X_LUT2
    generic map(
      INIT => X"9"
    )
    port map (
      ADR0 => B_42_IBUF,
      ADR1 => A_2_IBUF,
      O => Inst_minimum47to40_Mcompar_n0000_inst_lut2_2
    );
  Inst_minimum47to40_Mcompar_n0000_inst_cy_2_41 : X_MUX2
    port map (
      IB => Inst_minimum47to40_Mcompar_n0000_inst_cy_1,
      IA => B_42_IBUF,
      SEL => Inst_minimum47to40_Mcompar_n0000_inst_lut2_2,
      O => Inst_minimum47to40_Mcompar_n0000_inst_cy_2
    );
  Inst_minimum47to40_Mcompar_n0000_inst_lut2_31 : X_LUT2
    generic map(
      INIT => X"9"
    )
    port map (
      ADR0 => B_43_IBUF,
      ADR1 => A_3_IBUF,
      O => Inst_minimum47to40_Mcompar_n0000_inst_lut2_3
    );
  Inst_minimum47to40_Mcompar_n0000_inst_cy_3_42 : X_MUX2
    port map (
      IB => Inst_minimum47to40_Mcompar_n0000_inst_cy_2,
      IA => B_43_IBUF,
      SEL => Inst_minimum47to40_Mcompar_n0000_inst_lut2_3,
      O => Inst_minimum47to40_Mcompar_n0000_inst_cy_3
    );
  Inst_minimum47to40_Mcompar_n0000_inst_lut2_41 : X_LUT2
    generic map(
      INIT => X"9"
    )
    port map (
      ADR0 => B_44_IBUF,
      ADR1 => A_4_IBUF,
      O => Inst_minimum47to40_Mcompar_n0000_inst_lut2_4
    );
  Inst_minimum47to40_Mcompar_n0000_inst_cy_4_43 : X_MUX2
    port map (
      IB => Inst_minimum47to40_Mcompar_n0000_inst_cy_3,
      IA => B_44_IBUF,
      SEL => Inst_minimum47to40_Mcompar_n0000_inst_lut2_4,
      O => Inst_minimum47to40_Mcompar_n0000_inst_cy_4
    );
  Inst_minimum47to40_Mcompar_n0000_inst_lut2_51 : X_LUT2
    generic map(
      INIT => X"9"
    )
    port map (
      ADR0 => B_45_IBUF,
      ADR1 => A_5_IBUF,
      O => Inst_minimum47to40_Mcompar_n0000_inst_lut2_5
    );
  Inst_minimum47to40_Mcompar_n0000_inst_cy_5_44 : X_MUX2
    port map (
      IB => Inst_minimum47to40_Mcompar_n0000_inst_cy_4,
      IA => B_45_IBUF,
      SEL => Inst_minimum47to40_Mcompar_n0000_inst_lut2_5,
      O => Inst_minimum47to40_Mcompar_n0000_inst_cy_5
    );
  Inst_minimum47to40_Mcompar_n0000_inst_lut2_61 : X_LUT2
    generic map(
      INIT => X"9"
    )
    port map (
      ADR0 => B_46_IBUF,
      ADR1 => A_6_IBUF,
      O => Inst_minimum47to40_Mcompar_n0000_inst_lut2_6
    );
  Inst_minimum55to48_Mcompar_n0000_inst_lut2_71 : X_LUT2
    generic map(
      INIT => X"9"
    )
    port map (
      ADR0 => B_55_IBUF,
      ADR1 => A_7_IBUF,
      O => Inst_minimum55to48_Mcompar_n0000_inst_lut2_7
    );
  Inst_minimum55to48_Mcompar_n0000_inst_cy_7 : X_MUX2
    port map (
      IB => Inst_minimum55to48_Mcompar_n0000_inst_cy_6,
      IA => B_55_IBUF,
      SEL => Inst_minimum55to48_Mcompar_n0000_inst_lut2_7,
      O => Inst_minimum55to48_n0000
    );
  Inst_minimum55to48_Mcompar_n0000_inst_lut2_01 : X_LUT2
    generic map(
      INIT => X"9"
    )
    port map (
      ADR0 => B_48_IBUF,
      ADR1 => A_0_IBUF,
      O => Inst_minimum55to48_Mcompar_n0000_inst_lut2_0
    );
  Inst_minimum55to48_Mcompar_n0000_inst_cy_0_45 : X_MUX2
    port map (
      IB => N183,
      IA => B_48_IBUF,
      SEL => Inst_minimum55to48_Mcompar_n0000_inst_lut2_0,
      O => Inst_minimum55to48_Mcompar_n0000_inst_cy_0
    );
  Inst_minimum55to48_Mcompar_n0000_inst_lut2_11 : X_LUT2
    generic map(
      INIT => X"9"
    )
    port map (
      ADR0 => B_49_IBUF,
      ADR1 => A_1_IBUF,
      O => Inst_minimum55to48_Mcompar_n0000_inst_lut2_1
    );
  Inst_minimum55to48_Mcompar_n0000_inst_cy_1_46 : X_MUX2
    port map (
      IB => Inst_minimum55to48_Mcompar_n0000_inst_cy_0,
      IA => B_49_IBUF,
      SEL => Inst_minimum55to48_Mcompar_n0000_inst_lut2_1,
      O => Inst_minimum55to48_Mcompar_n0000_inst_cy_1
    );
  Inst_minimum55to48_Mcompar_n0000_inst_lut2_21 : X_LUT2
    generic map(
      INIT => X"9"
    )
    port map (
      ADR0 => B_50_IBUF,
      ADR1 => A_2_IBUF,
      O => Inst_minimum55to48_Mcompar_n0000_inst_lut2_2
    );
  Inst_minimum55to48_Mcompar_n0000_inst_cy_2_47 : X_MUX2
    port map (
      IB => Inst_minimum55to48_Mcompar_n0000_inst_cy_1,
      IA => B_50_IBUF,
      SEL => Inst_minimum55to48_Mcompar_n0000_inst_lut2_2,
      O => Inst_minimum55to48_Mcompar_n0000_inst_cy_2
    );
  Inst_minimum55to48_Mcompar_n0000_inst_lut2_31 : X_LUT2
    generic map(
      INIT => X"9"
    )
    port map (
      ADR0 => B_51_IBUF,
      ADR1 => A_3_IBUF,
      O => Inst_minimum55to48_Mcompar_n0000_inst_lut2_3
    );
  Inst_minimum55to48_Mcompar_n0000_inst_cy_3_48 : X_MUX2
    port map (
      IB => Inst_minimum55to48_Mcompar_n0000_inst_cy_2,
      IA => B_51_IBUF,
      SEL => Inst_minimum55to48_Mcompar_n0000_inst_lut2_3,
      O => Inst_minimum55to48_Mcompar_n0000_inst_cy_3
    );
  Inst_minimum55to48_Mcompar_n0000_inst_lut2_41 : X_LUT2
    generic map(
      INIT => X"9"
    )
    port map (
      ADR0 => B_52_IBUF,
      ADR1 => A_4_IBUF,
      O => Inst_minimum55to48_Mcompar_n0000_inst_lut2_4
    );
  Inst_minimum55to48_Mcompar_n0000_inst_cy_4_49 : X_MUX2
    port map (
      IB => Inst_minimum55to48_Mcompar_n0000_inst_cy_3,
      IA => B_52_IBUF,
      SEL => Inst_minimum55to48_Mcompar_n0000_inst_lut2_4,
      O => Inst_minimum55to48_Mcompar_n0000_inst_cy_4
    );
  Inst_minimum55to48_Mcompar_n0000_inst_lut2_51 : X_LUT2
    generic map(
      INIT => X"9"
    )
    port map (
      ADR0 => B_53_IBUF,
      ADR1 => A_5_IBUF,
      O => Inst_minimum55to48_Mcompar_n0000_inst_lut2_5
    );
  Inst_minimum55to48_Mcompar_n0000_inst_cy_5_50 : X_MUX2
    port map (
      IB => Inst_minimum55to48_Mcompar_n0000_inst_cy_4,
      IA => B_53_IBUF,
      SEL => Inst_minimum55to48_Mcompar_n0000_inst_lut2_5,
      O => Inst_minimum55to48_Mcompar_n0000_inst_cy_5
    );
  Inst_minimum55to48_Mcompar_n0000_inst_lut2_61 : X_LUT2
    generic map(
      INIT => X"9"
    )
    port map (
      ADR0 => B_54_IBUF,
      ADR1 => A_6_IBUF,
      O => Inst_minimum55to48_Mcompar_n0000_inst_lut2_6
    );
  Inst_minimum63to56_Mcompar_n0000_inst_lut2_71 : X_LUT2
    generic map(
      INIT => X"9"
    )
    port map (
      ADR0 => B_63_IBUF,
      ADR1 => A_7_IBUF,
      O => Inst_minimum63to56_Mcompar_n0000_inst_lut2_7
    );
  Inst_minimum63to56_Mcompar_n0000_inst_cy_7 : X_MUX2
    port map (
      IB => Inst_minimum63to56_Mcompar_n0000_inst_cy_6,
      IA => B_63_IBUF,
      SEL => Inst_minimum63to56_Mcompar_n0000_inst_lut2_7,
      O => Inst_minimum63to56_n0000
    );
  Inst_minimum63to56_Mcompar_n0000_inst_lut2_01 : X_LUT2
    generic map(
      INIT => X"9"
    )
    port map (
      ADR0 => B_56_IBUF,
      ADR1 => A_0_IBUF,
      O => Inst_minimum63to56_Mcompar_n0000_inst_lut2_0
    );
  Inst_minimum63to56_Mcompar_n0000_inst_cy_0_51 : X_MUX2
    port map (
      IB => N183,
      IA => B_56_IBUF,
      SEL => Inst_minimum63to56_Mcompar_n0000_inst_lut2_0,
      O => Inst_minimum63to56_Mcompar_n0000_inst_cy_0
    );
  Inst_minimum63to56_Mcompar_n0000_inst_lut2_11 : X_LUT2
    generic map(
      INIT => X"9"
    )
    port map (
      ADR0 => B_57_IBUF,
      ADR1 => A_1_IBUF,
      O => Inst_minimum63to56_Mcompar_n0000_inst_lut2_1
    );
  Inst_minimum63to56_Mcompar_n0000_inst_cy_1_52 : X_MUX2
    port map (
      IB => Inst_minimum63to56_Mcompar_n0000_inst_cy_0,
      IA => B_57_IBUF,
      SEL => Inst_minimum63to56_Mcompar_n0000_inst_lut2_1,
      O => Inst_minimum63to56_Mcompar_n0000_inst_cy_1
    );
  Inst_minimum63to56_Mcompar_n0000_inst_lut2_21 : X_LUT2
    generic map(
      INIT => X"9"
    )
    port map (
      ADR0 => B_58_IBUF,
      ADR1 => A_2_IBUF,
      O => Inst_minimum63to56_Mcompar_n0000_inst_lut2_2
    );
  Inst_minimum63to56_Mcompar_n0000_inst_cy_2_53 : X_MUX2
    port map (
      IB => Inst_minimum63to56_Mcompar_n0000_inst_cy_1,
      IA => B_58_IBUF,
      SEL => Inst_minimum63to56_Mcompar_n0000_inst_lut2_2,
      O => Inst_minimum63to56_Mcompar_n0000_inst_cy_2
    );
  Inst_minimum63to56_Mcompar_n0000_inst_lut2_31 : X_LUT2
    generic map(
      INIT => X"9"
    )
    port map (
      ADR0 => B_59_IBUF,
      ADR1 => A_3_IBUF,
      O => Inst_minimum63to56_Mcompar_n0000_inst_lut2_3
    );
  Inst_minimum63to56_Mcompar_n0000_inst_cy_3_54 : X_MUX2
    port map (
      IB => Inst_minimum63to56_Mcompar_n0000_inst_cy_2,
      IA => B_59_IBUF,
      SEL => Inst_minimum63to56_Mcompar_n0000_inst_lut2_3,
      O => Inst_minimum63to56_Mcompar_n0000_inst_cy_3
    );
  Inst_minimum63to56_Mcompar_n0000_inst_lut2_41 : X_LUT2
    generic map(
      INIT => X"9"
    )
    port map (
      ADR0 => B_60_IBUF,
      ADR1 => A_4_IBUF,
      O => Inst_minimum63to56_Mcompar_n0000_inst_lut2_4
    );
  Inst_minimum63to56_Mcompar_n0000_inst_cy_4_55 : X_MUX2
    port map (
      IB => Inst_minimum63to56_Mcompar_n0000_inst_cy_3,
      IA => B_60_IBUF,
      SEL => Inst_minimum63to56_Mcompar_n0000_inst_lut2_4,
      O => Inst_minimum63to56_Mcompar_n0000_inst_cy_4
    );
  Inst_minimum63to56_Mcompar_n0000_inst_lut2_51 : X_LUT2
    generic map(
      INIT => X"9"
    )
    port map (
      ADR0 => B_61_IBUF,
      ADR1 => A_5_IBUF,
      O => Inst_minimum63to56_Mcompar_n0000_inst_lut2_5
    );
  Inst_minimum63to56_Mcompar_n0000_inst_cy_5_56 : X_MUX2
    port map (
      IB => Inst_minimum63to56_Mcompar_n0000_inst_cy_4,
      IA => B_61_IBUF,
      SEL => Inst_minimum63to56_Mcompar_n0000_inst_lut2_5,
      O => Inst_minimum63to56_Mcompar_n0000_inst_cy_5
    );
  Inst_minimum63to56_Mcompar_n0000_inst_lut2_61 : X_LUT2
    generic map(
      INIT => X"9"
    )
    port map (
      ADR0 => B_62_IBUF,
      ADR1 => A_6_IBUF,
      O => Inst_minimum63to56_Mcompar_n0000_inst_lut2_6
    );
  Inst_minimum7to0_Mmux_C_Result_0_1 : X_LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      ADR0 => Inst_minimum7to0_n0000,
      ADR1 => B_0_IBUF,
      ADR2 => A_0_IBUF,
      O => C_0_OBUF
    );
  Inst_minimum7to0_Mmux_C_Result_1_1 : X_LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      ADR0 => Inst_minimum7to0_n0000,
      ADR1 => B_1_IBUF,
      ADR2 => A_1_IBUF,
      O => C_1_OBUF
    );
  Inst_minimum7to0_Mmux_C_Result_2_1 : X_LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      ADR0 => Inst_minimum7to0_n0000,
      ADR1 => B_2_IBUF,
      ADR2 => A_2_IBUF,
      O => C_2_OBUF
    );
  Inst_minimum7to0_Mmux_C_Result_3_1 : X_LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      ADR0 => Inst_minimum7to0_n0000,
      ADR1 => B_3_IBUF,
      ADR2 => A_3_IBUF,
      O => C_3_OBUF
    );
  Inst_minimum7to0_Mmux_C_Result_4_1 : X_LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      ADR0 => Inst_minimum7to0_n0000,
      ADR1 => B_4_IBUF,
      ADR2 => A_4_IBUF,
      O => C_4_OBUF
    );
  Inst_minimum7to0_Mmux_C_Result_5_1 : X_LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      ADR0 => Inst_minimum7to0_n0000,
      ADR1 => B_5_IBUF,
      ADR2 => A_5_IBUF,
      O => C_5_OBUF
    );
  Inst_minimum7to0_Mmux_C_Result_6_1 : X_LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      ADR0 => Inst_minimum7to0_n0000,
      ADR1 => B_6_IBUF,
      ADR2 => A_6_IBUF,
      O => C_6_OBUF
    );
  Inst_minimum15to8_Mmux_C_Result_0_1 : X_LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      ADR0 => Inst_minimum15to8_n0000,
      ADR1 => B_8_IBUF,
      ADR2 => A_0_IBUF,
      O => C_8_OBUF
    );
  Inst_minimum15to8_Mmux_C_Result_1_1 : X_LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      ADR0 => Inst_minimum15to8_n0000,
      ADR1 => B_9_IBUF,
      ADR2 => A_1_IBUF,
      O => C_9_OBUF
    );
  Inst_minimum15to8_Mmux_C_Result_2_1 : X_LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      ADR0 => Inst_minimum15to8_n0000,
      ADR1 => B_10_IBUF,
      ADR2 => A_2_IBUF,
      O => C_10_OBUF
    );
  Inst_minimum15to8_Mmux_C_Result_3_1 : X_LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      ADR0 => Inst_minimum15to8_n0000,
      ADR1 => B_11_IBUF,
      ADR2 => A_3_IBUF,
      O => C_11_OBUF
    );
  Inst_minimum15to8_Mmux_C_Result_4_1 : X_LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      ADR0 => Inst_minimum15to8_n0000,
      ADR1 => B_12_IBUF,
      ADR2 => A_4_IBUF,
      O => C_12_OBUF
    );
  Inst_minimum15to8_Mmux_C_Result_5_1 : X_LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      ADR0 => Inst_minimum15to8_n0000,
      ADR1 => B_13_IBUF,
      ADR2 => A_5_IBUF,
      O => C_13_OBUF
    );
  Inst_minimum15to8_Mmux_C_Result_6_1 : X_LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      ADR0 => Inst_minimum15to8_n0000,
      ADR1 => B_14_IBUF,
      ADR2 => A_6_IBUF,
      O => C_14_OBUF
    );
  Inst_minimum23to16_Mmux_C_Result_0_1 : X_LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      ADR0 => Inst_minimum23to16_n0000,
      ADR1 => B_16_IBUF,
      ADR2 => A_0_IBUF,
      O => C_16_OBUF
    );
  Inst_minimum23to16_Mmux_C_Result_1_1 : X_LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      ADR0 => Inst_minimum23to16_n0000,
      ADR1 => B_17_IBUF,
      ADR2 => A_1_IBUF,
      O => C_17_OBUF
    );
  Inst_minimum23to16_Mmux_C_Result_2_1 : X_LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      ADR0 => Inst_minimum23to16_n0000,
      ADR1 => B_18_IBUF,
      ADR2 => A_2_IBUF,
      O => C_18_OBUF
    );
  Inst_minimum23to16_Mmux_C_Result_3_1 : X_LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      ADR0 => Inst_minimum23to16_n0000,
      ADR1 => B_19_IBUF,
      ADR2 => A_3_IBUF,
      O => C_19_OBUF
    );
  Inst_minimum23to16_Mmux_C_Result_4_1 : X_LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      ADR0 => Inst_minimum23to16_n0000,
      ADR1 => B_20_IBUF,
      ADR2 => A_4_IBUF,
      O => C_20_OBUF
    );
  Inst_minimum23to16_Mmux_C_Result_5_1 : X_LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      ADR0 => Inst_minimum23to16_n0000,
      ADR1 => B_21_IBUF,
      ADR2 => A_5_IBUF,
      O => C_21_OBUF
    );
  Inst_minimum23to16_Mmux_C_Result_6_1 : X_LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      ADR0 => Inst_minimum23to16_n0000,
      ADR1 => B_22_IBUF,
      ADR2 => A_6_IBUF,
      O => C_22_OBUF
    );
  Inst_minimum31to24_Mmux_C_Result_0_1 : X_LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      ADR0 => Inst_minimum31to24_n0000,
      ADR1 => B_24_IBUF,
      ADR2 => A_0_IBUF,
      O => C_24_OBUF
    );
  Inst_minimum31to24_Mmux_C_Result_1_1 : X_LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      ADR0 => Inst_minimum31to24_n0000,
      ADR1 => B_25_IBUF,
      ADR2 => A_1_IBUF,
      O => C_25_OBUF
    );
  Inst_minimum31to24_Mmux_C_Result_2_1 : X_LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      ADR0 => Inst_minimum31to24_n0000,
      ADR1 => B_26_IBUF,
      ADR2 => A_2_IBUF,
      O => C_26_OBUF
    );
  Inst_minimum31to24_Mmux_C_Result_3_1 : X_LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      ADR0 => Inst_minimum31to24_n0000,
      ADR1 => B_27_IBUF,
      ADR2 => A_3_IBUF,
      O => C_27_OBUF
    );
  Inst_minimum31to24_Mmux_C_Result_4_1 : X_LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      ADR0 => Inst_minimum31to24_n0000,
      ADR1 => B_28_IBUF,
      ADR2 => A_4_IBUF,
      O => C_28_OBUF
    );
  Inst_minimum31to24_Mmux_C_Result_5_1 : X_LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      ADR0 => Inst_minimum31to24_n0000,
      ADR1 => B_29_IBUF,
      ADR2 => A_5_IBUF,
      O => C_29_OBUF
    );
  Inst_minimum31to24_Mmux_C_Result_6_1 : X_LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      ADR0 => Inst_minimum31to24_n0000,
      ADR1 => B_30_IBUF,
      ADR2 => A_6_IBUF,
      O => C_30_OBUF
    );
  Inst_minimum39to32_Mmux_C_Result_0_1 : X_LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      ADR0 => Inst_minimum39to32_n0000,
      ADR1 => B_32_IBUF,
      ADR2 => A_0_IBUF,
      O => C_32_OBUF
    );
  Inst_minimum39to32_Mmux_C_Result_1_1 : X_LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      ADR0 => Inst_minimum39to32_n0000,
      ADR1 => B_33_IBUF,
      ADR2 => A_1_IBUF,
      O => C_33_OBUF
    );
  Inst_minimum39to32_Mmux_C_Result_2_1 : X_LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      ADR0 => Inst_minimum39to32_n0000,
      ADR1 => B_34_IBUF,
      ADR2 => A_2_IBUF,
      O => C_34_OBUF
    );
  Inst_minimum39to32_Mmux_C_Result_3_1 : X_LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      ADR0 => Inst_minimum39to32_n0000,
      ADR1 => B_35_IBUF,
      ADR2 => A_3_IBUF,
      O => C_35_OBUF
    );
  Inst_minimum39to32_Mmux_C_Result_4_1 : X_LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      ADR0 => Inst_minimum39to32_n0000,
      ADR1 => B_36_IBUF,
      ADR2 => A_4_IBUF,
      O => C_36_OBUF
    );
  Inst_minimum39to32_Mmux_C_Result_5_1 : X_LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      ADR0 => Inst_minimum39to32_n0000,
      ADR1 => B_37_IBUF,
      ADR2 => A_5_IBUF,
      O => C_37_OBUF
    );
  Inst_minimum39to32_Mmux_C_Result_6_1 : X_LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      ADR0 => Inst_minimum39to32_n0000,
      ADR1 => B_38_IBUF,
      ADR2 => A_6_IBUF,
      O => C_38_OBUF
    );
  Inst_minimum47to40_Mmux_C_Result_0_1 : X_LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      ADR0 => Inst_minimum47to40_n0000,
      ADR1 => B_40_IBUF,
      ADR2 => A_0_IBUF,
      O => C_40_OBUF
    );
  Inst_minimum47to40_Mmux_C_Result_1_1 : X_LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      ADR0 => Inst_minimum47to40_n0000,
      ADR1 => B_41_IBUF,
      ADR2 => A_1_IBUF,
      O => C_41_OBUF
    );
  Inst_minimum47to40_Mmux_C_Result_2_1 : X_LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      ADR0 => Inst_minimum47to40_n0000,
      ADR1 => B_42_IBUF,
      ADR2 => A_2_IBUF,
      O => C_42_OBUF
    );
  Inst_minimum47to40_Mmux_C_Result_3_1 : X_LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      ADR0 => Inst_minimum47to40_n0000,
      ADR1 => B_43_IBUF,
      ADR2 => A_3_IBUF,
      O => C_43_OBUF
    );
  Inst_minimum47to40_Mmux_C_Result_4_1 : X_LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      ADR0 => Inst_minimum47to40_n0000,
      ADR1 => B_44_IBUF,
      ADR2 => A_4_IBUF,
      O => C_44_OBUF
    );
  Inst_minimum47to40_Mmux_C_Result_5_1 : X_LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      ADR0 => Inst_minimum47to40_n0000,
      ADR1 => B_45_IBUF,
      ADR2 => A_5_IBUF,
      O => C_45_OBUF
    );
  Inst_minimum47to40_Mmux_C_Result_6_1 : X_LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      ADR0 => Inst_minimum47to40_n0000,
      ADR1 => B_46_IBUF,
      ADR2 => A_6_IBUF,
      O => C_46_OBUF
    );
  Inst_minimum55to48_Mmux_C_Result_0_1 : X_LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      ADR0 => Inst_minimum55to48_n0000,
      ADR1 => B_48_IBUF,
      ADR2 => A_0_IBUF,
      O => C_48_OBUF
    );
  Inst_minimum55to48_Mmux_C_Result_1_1 : X_LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      ADR0 => Inst_minimum55to48_n0000,
      ADR1 => B_49_IBUF,
      ADR2 => A_1_IBUF,
      O => C_49_OBUF
    );
  Inst_minimum55to48_Mmux_C_Result_2_1 : X_LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      ADR0 => Inst_minimum55to48_n0000,
      ADR1 => B_50_IBUF,
      ADR2 => A_2_IBUF,
      O => C_50_OBUF
    );
  Inst_minimum55to48_Mmux_C_Result_3_1 : X_LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      ADR0 => Inst_minimum55to48_n0000,
      ADR1 => B_51_IBUF,
      ADR2 => A_3_IBUF,
      O => C_51_OBUF
    );
  Inst_minimum55to48_Mmux_C_Result_4_1 : X_LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      ADR0 => Inst_minimum55to48_n0000,
      ADR1 => B_52_IBUF,
      ADR2 => A_4_IBUF,
      O => C_52_OBUF
    );
  Inst_minimum55to48_Mmux_C_Result_5_1 : X_LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      ADR0 => Inst_minimum55to48_n0000,
      ADR1 => B_53_IBUF,
      ADR2 => A_5_IBUF,
      O => C_53_OBUF
    );
  Inst_minimum55to48_Mmux_C_Result_6_1 : X_LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      ADR0 => Inst_minimum55to48_n0000,
      ADR1 => B_54_IBUF,
      ADR2 => A_6_IBUF,
      O => C_54_OBUF
    );
  Inst_minimum63to56_Mmux_C_Result_0_1 : X_LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      ADR0 => Inst_minimum63to56_n0000,
      ADR1 => B_56_IBUF,
      ADR2 => A_0_IBUF,
      O => C_56_OBUF
    );
  Inst_minimum63to56_Mmux_C_Result_1_1 : X_LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      ADR0 => Inst_minimum63to56_n0000,
      ADR1 => B_57_IBUF,
      ADR2 => A_1_IBUF,
      O => C_57_OBUF
    );
  Inst_minimum63to56_Mmux_C_Result_2_1 : X_LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      ADR0 => Inst_minimum63to56_n0000,
      ADR1 => B_58_IBUF,
      ADR2 => A_2_IBUF,
      O => C_58_OBUF
    );
  Inst_minimum63to56_Mmux_C_Result_3_1 : X_LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      ADR0 => Inst_minimum63to56_n0000,
      ADR1 => B_59_IBUF,
      ADR2 => A_3_IBUF,
      O => C_59_OBUF
    );
  Inst_minimum63to56_Mmux_C_Result_4_1 : X_LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      ADR0 => Inst_minimum63to56_n0000,
      ADR1 => B_60_IBUF,
      ADR2 => A_4_IBUF,
      O => C_60_OBUF
    );
  Inst_minimum63to56_Mmux_C_Result_5_1 : X_LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      ADR0 => Inst_minimum63to56_n0000,
      ADR1 => B_61_IBUF,
      ADR2 => A_5_IBUF,
      O => C_61_OBUF
    );
  Inst_minimum63to56_Mmux_C_Result_6_1 : X_LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      ADR0 => Inst_minimum63to56_n0000,
      ADR1 => B_62_IBUF,
      ADR2 => A_6_IBUF,
      O => C_62_OBUF
    );
  A_7_IBUF_57 : X_BUF
    port map (
      I => A(7),
      O => A_7_IBUF
    );
  A_6_IBUF_58 : X_BUF
    port map (
      I => A(6),
      O => A_6_IBUF
    );
  A_5_IBUF_59 : X_BUF
    port map (
      I => A(5),
      O => A_5_IBUF
    );
  A_4_IBUF_60 : X_BUF
    port map (
      I => A(4),
      O => A_4_IBUF
    );
  A_3_IBUF_61 : X_BUF
    port map (
      I => A(3),
      O => A_3_IBUF
    );
  A_2_IBUF_62 : X_BUF
    port map (
      I => A(2),
      O => A_2_IBUF
    );
  A_1_IBUF_63 : X_BUF
    port map (
      I => A(1),
      O => A_1_IBUF
    );
  A_0_IBUF_64 : X_BUF
    port map (
      I => A(0),
      O => A_0_IBUF
    );
  B_63_IBUF_65 : X_BUF
    port map (
      I => B(63),
      O => B_63_IBUF
    );
  B_62_IBUF_66 : X_BUF
    port map (
      I => B(62),
      O => B_62_IBUF
    );
  B_61_IBUF_67 : X_BUF
    port map (
      I => B(61),
      O => B_61_IBUF
    );
  B_60_IBUF_68 : X_BUF
    port map (
      I => B(60),
      O => B_60_IBUF
    );
  B_59_IBUF_69 : X_BUF
    port map (
      I => B(59),
      O => B_59_IBUF
    );
  B_58_IBUF_70 : X_BUF
    port map (
      I => B(58),
      O => B_58_IBUF
    );
  B_57_IBUF_71 : X_BUF
    port map (
      I => B(57),
      O => B_57_IBUF
    );
  B_56_IBUF_72 : X_BUF
    port map (
      I => B(56),
      O => B_56_IBUF
    );
  B_55_IBUF_73 : X_BUF
    port map (
      I => B(55),
      O => B_55_IBUF
    );
  B_54_IBUF_74 : X_BUF
    port map (
      I => B(54),
      O => B_54_IBUF
    );
  B_53_IBUF_75 : X_BUF
    port map (
      I => B(53),
      O => B_53_IBUF
    );
  B_52_IBUF_76 : X_BUF
    port map (
      I => B(52),
      O => B_52_IBUF
    );
  B_51_IBUF_77 : X_BUF
    port map (
      I => B(51),
      O => B_51_IBUF
    );
  B_50_IBUF_78 : X_BUF
    port map (
      I => B(50),
      O => B_50_IBUF
    );
  B_49_IBUF_79 : X_BUF
    port map (
      I => B(49),
      O => B_49_IBUF
    );
  B_48_IBUF_80 : X_BUF
    port map (
      I => B(48),
      O => B_48_IBUF
    );
  B_47_IBUF_81 : X_BUF
    port map (
      I => B(47),
      O => B_47_IBUF
    );
  B_46_IBUF_82 : X_BUF
    port map (
      I => B(46),
      O => B_46_IBUF
    );
  B_45_IBUF_83 : X_BUF
    port map (
      I => B(45),
      O => B_45_IBUF
    );
  B_44_IBUF_84 : X_BUF
    port map (
      I => B(44),
      O => B_44_IBUF
    );
  B_43_IBUF_85 : X_BUF
    port map (
      I => B(43),
      O => B_43_IBUF
    );
  B_42_IBUF_86 : X_BUF
    port map (
      I => B(42),
      O => B_42_IBUF
    );
  B_41_IBUF_87 : X_BUF
    port map (
      I => B(41),
      O => B_41_IBUF
    );
  B_40_IBUF_88 : X_BUF
    port map (
      I => B(40),
      O => B_40_IBUF
    );
  B_39_IBUF_89 : X_BUF
    port map (
      I => B(39),
      O => B_39_IBUF
    );
  B_38_IBUF_90 : X_BUF
    port map (
      I => B(38),
      O => B_38_IBUF
    );
  B_37_IBUF_91 : X_BUF
    port map (
      I => B(37),
      O => B_37_IBUF
    );
  B_36_IBUF_92 : X_BUF
    port map (
      I => B(36),
      O => B_36_IBUF
    );
  B_35_IBUF_93 : X_BUF
    port map (
      I => B(35),
      O => B_35_IBUF
    );
  B_34_IBUF_94 : X_BUF
    port map (
      I => B(34),
      O => B_34_IBUF
    );
  B_33_IBUF_95 : X_BUF
    port map (
      I => B(33),
      O => B_33_IBUF
    );
  B_32_IBUF_96 : X_BUF
    port map (
      I => B(32),
      O => B_32_IBUF
    );
  B_31_IBUF_97 : X_BUF
    port map (
      I => B(31),
      O => B_31_IBUF
    );
  B_30_IBUF_98 : X_BUF
    port map (
      I => B(30),
      O => B_30_IBUF
    );
  B_29_IBUF_99 : X_BUF
    port map (
      I => B(29),
      O => B_29_IBUF
    );
  B_28_IBUF_100 : X_BUF
    port map (
      I => B(28),
      O => B_28_IBUF
    );
  B_27_IBUF_101 : X_BUF
    port map (
      I => B(27),
      O => B_27_IBUF
    );
  B_26_IBUF_102 : X_BUF
    port map (
      I => B(26),
      O => B_26_IBUF
    );
  B_25_IBUF_103 : X_BUF
    port map (
      I => B(25),
      O => B_25_IBUF
    );
  B_24_IBUF_104 : X_BUF
    port map (
      I => B(24),
      O => B_24_IBUF
    );
  B_23_IBUF_105 : X_BUF
    port map (
      I => B(23),
      O => B_23_IBUF
    );
  B_22_IBUF_106 : X_BUF
    port map (
      I => B(22),
      O => B_22_IBUF
    );
  B_21_IBUF_107 : X_BUF
    port map (
      I => B(21),
      O => B_21_IBUF
    );
  B_20_IBUF_108 : X_BUF
    port map (
      I => B(20),
      O => B_20_IBUF
    );
  B_19_IBUF_109 : X_BUF
    port map (
      I => B(19),
      O => B_19_IBUF
    );
  B_18_IBUF_110 : X_BUF
    port map (
      I => B(18),
      O => B_18_IBUF
    );
  B_17_IBUF_111 : X_BUF
    port map (
      I => B(17),
      O => B_17_IBUF
    );
  B_16_IBUF_112 : X_BUF
    port map (
      I => B(16),
      O => B_16_IBUF
    );
  B_15_IBUF_113 : X_BUF
    port map (
      I => B(15),
      O => B_15_IBUF
    );
  B_14_IBUF_114 : X_BUF
    port map (
      I => B(14),
      O => B_14_IBUF
    );
  B_13_IBUF_115 : X_BUF
    port map (
      I => B(13),
      O => B_13_IBUF
    );
  B_12_IBUF_116 : X_BUF
    port map (
      I => B(12),
      O => B_12_IBUF
    );
  B_11_IBUF_117 : X_BUF
    port map (
      I => B(11),
      O => B_11_IBUF
    );
  B_10_IBUF_118 : X_BUF
    port map (
      I => B(10),
      O => B_10_IBUF
    );
  B_9_IBUF_119 : X_BUF
    port map (
      I => B(9),
      O => B_9_IBUF
    );
  B_8_IBUF_120 : X_BUF
    port map (
      I => B(8),
      O => B_8_IBUF
    );
  B_7_IBUF_121 : X_BUF
    port map (
      I => B(7),
      O => B_7_IBUF
    );
  B_6_IBUF_122 : X_BUF
    port map (
      I => B(6),
      O => B_6_IBUF
    );
  B_5_IBUF_123 : X_BUF
    port map (
      I => B(5),
      O => B_5_IBUF
    );
  B_4_IBUF_124 : X_BUF
    port map (
      I => B(4),
      O => B_4_IBUF
    );
  B_3_IBUF_125 : X_BUF
    port map (
      I => B(3),
      O => B_3_IBUF
    );
  B_2_IBUF_126 : X_BUF
    port map (
      I => B(2),
      O => B_2_IBUF
    );
  B_1_IBUF_127 : X_BUF
    port map (
      I => B(1),
      O => B_1_IBUF
    );
  B_0_IBUF_128 : X_BUF
    port map (
      I => B(0),
      O => B_0_IBUF
    );
  C_63_OBUF_129 : X_BUF
    port map (
      I => C_63_OBUF,
      O => C_63_OBUF_GTS_TRI
    );
  C_62_OBUF_130 : X_BUF
    port map (
      I => C_62_OBUF,
      O => C_62_OBUF_GTS_TRI
    );
  C_61_OBUF_131 : X_BUF
    port map (
      I => C_61_OBUF,
      O => C_61_OBUF_GTS_TRI
    );
  C_60_OBUF_132 : X_BUF
    port map (
      I => C_60_OBUF,
      O => C_60_OBUF_GTS_TRI
    );
  C_59_OBUF_133 : X_BUF
    port map (
      I => C_59_OBUF,
      O => C_59_OBUF_GTS_TRI
    );
  C_58_OBUF_134 : X_BUF
    port map (
      I => C_58_OBUF,
      O => C_58_OBUF_GTS_TRI
    );
  C_57_OBUF_135 : X_BUF
    port map (
      I => C_57_OBUF,
      O => C_57_OBUF_GTS_TRI
    );
  C_56_OBUF_136 : X_BUF
    port map (
      I => C_56_OBUF,
      O => C_56_OBUF_GTS_TRI
    );
  C_55_OBUF_137 : X_BUF
    port map (
      I => C_55_OBUF,
      O => C_55_OBUF_GTS_TRI
    );
  C_54_OBUF_138 : X_BUF
    port map (
      I => C_54_OBUF,
      O => C_54_OBUF_GTS_TRI
    );
  C_53_OBUF_139 : X_BUF
    port map (
      I => C_53_OBUF,
      O => C_53_OBUF_GTS_TRI
    );
  C_52_OBUF_140 : X_BUF
    port map (
      I => C_52_OBUF,
      O => C_52_OBUF_GTS_TRI
    );
  C_51_OBUF_141 : X_BUF
    port map (
      I => C_51_OBUF,
      O => C_51_OBUF_GTS_TRI
    );
  C_50_OBUF_142 : X_BUF
    port map (
      I => C_50_OBUF,
      O => C_50_OBUF_GTS_TRI
    );
  C_49_OBUF_143 : X_BUF
    port map (
      I => C_49_OBUF,
      O => C_49_OBUF_GTS_TRI
    );
  C_48_OBUF_144 : X_BUF
    port map (
      I => C_48_OBUF,
      O => C_48_OBUF_GTS_TRI
    );
  C_47_OBUF_145 : X_BUF
    port map (
      I => C_47_OBUF,
      O => C_47_OBUF_GTS_TRI
    );
  C_46_OBUF_146 : X_BUF
    port map (
      I => C_46_OBUF,
      O => C_46_OBUF_GTS_TRI
    );
  C_45_OBUF_147 : X_BUF
    port map (
      I => C_45_OBUF,
      O => C_45_OBUF_GTS_TRI
    );
  C_44_OBUF_148 : X_BUF
    port map (
      I => C_44_OBUF,
      O => C_44_OBUF_GTS_TRI
    );
  C_43_OBUF_149 : X_BUF
    port map (
      I => C_43_OBUF,
      O => C_43_OBUF_GTS_TRI
    );
  C_42_OBUF_150 : X_BUF
    port map (
      I => C_42_OBUF,
      O => C_42_OBUF_GTS_TRI
    );
  C_41_OBUF_151 : X_BUF
    port map (
      I => C_41_OBUF,
      O => C_41_OBUF_GTS_TRI
    );
  C_40_OBUF_152 : X_BUF
    port map (
      I => C_40_OBUF,
      O => C_40_OBUF_GTS_TRI
    );
  C_39_OBUF_153 : X_BUF
    port map (
      I => C_39_OBUF,
      O => C_39_OBUF_GTS_TRI
    );
  C_38_OBUF_154 : X_BUF
    port map (
      I => C_38_OBUF,
      O => C_38_OBUF_GTS_TRI
    );
  C_37_OBUF_155 : X_BUF
    port map (
      I => C_37_OBUF,
      O => C_37_OBUF_GTS_TRI
    );
  C_36_OBUF_156 : X_BUF
    port map (
      I => C_36_OBUF,
      O => C_36_OBUF_GTS_TRI
    );
  C_35_OBUF_157 : X_BUF
    port map (
      I => C_35_OBUF,
      O => C_35_OBUF_GTS_TRI
    );
  C_34_OBUF_158 : X_BUF
    port map (
      I => C_34_OBUF,
      O => C_34_OBUF_GTS_TRI
    );
  C_33_OBUF_159 : X_BUF
    port map (
      I => C_33_OBUF,
      O => C_33_OBUF_GTS_TRI
    );
  C_32_OBUF_160 : X_BUF
    port map (
      I => C_32_OBUF,
      O => C_32_OBUF_GTS_TRI
    );
  C_31_OBUF_161 : X_BUF
    port map (
      I => C_31_OBUF,
      O => C_31_OBUF_GTS_TRI
    );
  C_30_OBUF_162 : X_BUF
    port map (
      I => C_30_OBUF,
      O => C_30_OBUF_GTS_TRI
    );
  C_29_OBUF_163 : X_BUF
    port map (
      I => C_29_OBUF,
      O => C_29_OBUF_GTS_TRI
    );
  C_28_OBUF_164 : X_BUF
    port map (
      I => C_28_OBUF,
      O => C_28_OBUF_GTS_TRI
    );
  C_27_OBUF_165 : X_BUF
    port map (
      I => C_27_OBUF,
      O => C_27_OBUF_GTS_TRI
    );
  C_26_OBUF_166 : X_BUF
    port map (
      I => C_26_OBUF,
      O => C_26_OBUF_GTS_TRI
    );
  C_25_OBUF_167 : X_BUF
    port map (
      I => C_25_OBUF,
      O => C_25_OBUF_GTS_TRI
    );
  C_24_OBUF_168 : X_BUF
    port map (
      I => C_24_OBUF,
      O => C_24_OBUF_GTS_TRI
    );
  C_23_OBUF_169 : X_BUF
    port map (
      I => C_23_OBUF,
      O => C_23_OBUF_GTS_TRI
    );
  C_22_OBUF_170 : X_BUF
    port map (
      I => C_22_OBUF,
      O => C_22_OBUF_GTS_TRI
    );
  C_21_OBUF_171 : X_BUF
    port map (
      I => C_21_OBUF,
      O => C_21_OBUF_GTS_TRI
    );
  C_20_OBUF_172 : X_BUF
    port map (
      I => C_20_OBUF,
      O => C_20_OBUF_GTS_TRI
    );
  C_19_OBUF_173 : X_BUF
    port map (
      I => C_19_OBUF,
      O => C_19_OBUF_GTS_TRI
    );
  C_18_OBUF_174 : X_BUF
    port map (
      I => C_18_OBUF,
      O => C_18_OBUF_GTS_TRI
    );
  C_17_OBUF_175 : X_BUF
    port map (
      I => C_17_OBUF,
      O => C_17_OBUF_GTS_TRI
    );
  C_16_OBUF_176 : X_BUF
    port map (
      I => C_16_OBUF,
      O => C_16_OBUF_GTS_TRI
    );
  C_15_OBUF_177 : X_BUF
    port map (
      I => C_15_OBUF,
      O => C_15_OBUF_GTS_TRI
    );
  C_14_OBUF_178 : X_BUF
    port map (
      I => C_14_OBUF,
      O => C_14_OBUF_GTS_TRI
    );
  C_13_OBUF_179 : X_BUF
    port map (
      I => C_13_OBUF,
      O => C_13_OBUF_GTS_TRI
    );
  C_12_OBUF_180 : X_BUF
    port map (
      I => C_12_OBUF,
      O => C_12_OBUF_GTS_TRI
    );
  C_11_OBUF_181 : X_BUF
    port map (
      I => C_11_OBUF,
      O => C_11_OBUF_GTS_TRI
    );
  C_10_OBUF_182 : X_BUF
    port map (
      I => C_10_OBUF,
      O => C_10_OBUF_GTS_TRI
    );
  C_9_OBUF_183 : X_BUF
    port map (
      I => C_9_OBUF,
      O => C_9_OBUF_GTS_TRI
    );
  C_8_OBUF_184 : X_BUF
    port map (
      I => C_8_OBUF,
      O => C_8_OBUF_GTS_TRI
    );
  C_7_OBUF_185 : X_BUF
    port map (
      I => C_7_OBUF,
      O => C_7_OBUF_GTS_TRI
    );
  C_6_OBUF_186 : X_BUF
    port map (
      I => C_6_OBUF,
      O => C_6_OBUF_GTS_TRI
    );
  C_5_OBUF_187 : X_BUF
    port map (
      I => C_5_OBUF,
      O => C_5_OBUF_GTS_TRI
    );
  C_4_OBUF_188 : X_BUF
    port map (
      I => C_4_OBUF,
      O => C_4_OBUF_GTS_TRI
    );
  C_3_OBUF_189 : X_BUF
    port map (
      I => C_3_OBUF,
      O => C_3_OBUF_GTS_TRI
    );
  C_2_OBUF_190 : X_BUF
    port map (
      I => C_2_OBUF,
      O => C_2_OBUF_GTS_TRI
    );
  C_1_OBUF_191 : X_BUF
    port map (
      I => C_1_OBUF,
      O => C_1_OBUF_GTS_TRI
    );
  C_0_OBUF_GTS_TRI_192 : X_TRI
    port map (
      I => C_0_OBUF_GTS_TRI,
      CTL => NlwInverterSignal_C_0_OBUF_GTS_TRI_CTL,
      O => C(0)
    );
  C_63_OBUF_GTS_TRI_193 : X_TRI
    port map (
      I => C_63_OBUF_GTS_TRI,
      CTL => NlwInverterSignal_C_63_OBUF_GTS_TRI_CTL,
      O => C(63)
    );
  C_62_OBUF_GTS_TRI_194 : X_TRI
    port map (
      I => C_62_OBUF_GTS_TRI,
      CTL => NlwInverterSignal_C_62_OBUF_GTS_TRI_CTL,
      O => C(62)
    );
  C_61_OBUF_GTS_TRI_195 : X_TRI
    port map (
      I => C_61_OBUF_GTS_TRI,
      CTL => NlwInverterSignal_C_61_OBUF_GTS_TRI_CTL,
      O => C(61)
    );
  C_60_OBUF_GTS_TRI_196 : X_TRI
    port map (
      I => C_60_OBUF_GTS_TRI,
      CTL => NlwInverterSignal_C_60_OBUF_GTS_TRI_CTL,
      O => C(60)
    );
  C_59_OBUF_GTS_TRI_197 : X_TRI
    port map (
      I => C_59_OBUF_GTS_TRI,
      CTL => NlwInverterSignal_C_59_OBUF_GTS_TRI_CTL,
      O => C(59)
    );
  C_58_OBUF_GTS_TRI_198 : X_TRI
    port map (
      I => C_58_OBUF_GTS_TRI,
      CTL => NlwInverterSignal_C_58_OBUF_GTS_TRI_CTL,
      O => C(58)
    );
  C_57_OBUF_GTS_TRI_199 : X_TRI
    port map (
      I => C_57_OBUF_GTS_TRI,
      CTL => NlwInverterSignal_C_57_OBUF_GTS_TRI_CTL,
      O => C(57)
    );
  C_56_OBUF_GTS_TRI_200 : X_TRI
    port map (
      I => C_56_OBUF_GTS_TRI,
      CTL => NlwInverterSignal_C_56_OBUF_GTS_TRI_CTL,
      O => C(56)
    );
  C_55_OBUF_GTS_TRI_201 : X_TRI
    port map (
      I => C_55_OBUF_GTS_TRI,
      CTL => NlwInverterSignal_C_55_OBUF_GTS_TRI_CTL,
      O => C(55)
    );
  C_54_OBUF_GTS_TRI_202 : X_TRI
    port map (
      I => C_54_OBUF_GTS_TRI,
      CTL => NlwInverterSignal_C_54_OBUF_GTS_TRI_CTL,
      O => C(54)
    );
  C_53_OBUF_GTS_TRI_203 : X_TRI
    port map (
      I => C_53_OBUF_GTS_TRI,
      CTL => NlwInverterSignal_C_53_OBUF_GTS_TRI_CTL,
      O => C(53)
    );
  C_52_OBUF_GTS_TRI_204 : X_TRI
    port map (
      I => C_52_OBUF_GTS_TRI,
      CTL => NlwInverterSignal_C_52_OBUF_GTS_TRI_CTL,
      O => C(52)
    );
  C_51_OBUF_GTS_TRI_205 : X_TRI
    port map (
      I => C_51_OBUF_GTS_TRI,
      CTL => NlwInverterSignal_C_51_OBUF_GTS_TRI_CTL,
      O => C(51)
    );
  C_50_OBUF_GTS_TRI_206 : X_TRI
    port map (
      I => C_50_OBUF_GTS_TRI,
      CTL => NlwInverterSignal_C_50_OBUF_GTS_TRI_CTL,
      O => C(50)
    );
  C_49_OBUF_GTS_TRI_207 : X_TRI
    port map (
      I => C_49_OBUF_GTS_TRI,
      CTL => NlwInverterSignal_C_49_OBUF_GTS_TRI_CTL,
      O => C(49)
    );
  C_48_OBUF_GTS_TRI_208 : X_TRI
    port map (
      I => C_48_OBUF_GTS_TRI,
      CTL => NlwInverterSignal_C_48_OBUF_GTS_TRI_CTL,
      O => C(48)
    );
  C_47_OBUF_GTS_TRI_209 : X_TRI
    port map (
      I => C_47_OBUF_GTS_TRI,
      CTL => NlwInverterSignal_C_47_OBUF_GTS_TRI_CTL,
      O => C(47)
    );
  C_46_OBUF_GTS_TRI_210 : X_TRI
    port map (
      I => C_46_OBUF_GTS_TRI,
      CTL => NlwInverterSignal_C_46_OBUF_GTS_TRI_CTL,
      O => C(46)
    );
  C_45_OBUF_GTS_TRI_211 : X_TRI
    port map (
      I => C_45_OBUF_GTS_TRI,
      CTL => NlwInverterSignal_C_45_OBUF_GTS_TRI_CTL,
      O => C(45)
    );
  C_44_OBUF_GTS_TRI_212 : X_TRI
    port map (
      I => C_44_OBUF_GTS_TRI,
      CTL => NlwInverterSignal_C_44_OBUF_GTS_TRI_CTL,
      O => C(44)
    );
  C_43_OBUF_GTS_TRI_213 : X_TRI
    port map (
      I => C_43_OBUF_GTS_TRI,
      CTL => NlwInverterSignal_C_43_OBUF_GTS_TRI_CTL,
      O => C(43)
    );
  C_42_OBUF_GTS_TRI_214 : X_TRI
    port map (
      I => C_42_OBUF_GTS_TRI,
      CTL => NlwInverterSignal_C_42_OBUF_GTS_TRI_CTL,
      O => C(42)
    );
  C_41_OBUF_GTS_TRI_215 : X_TRI
    port map (
      I => C_41_OBUF_GTS_TRI,
      CTL => NlwInverterSignal_C_41_OBUF_GTS_TRI_CTL,
      O => C(41)
    );
  C_40_OBUF_GTS_TRI_216 : X_TRI
    port map (
      I => C_40_OBUF_GTS_TRI,
      CTL => NlwInverterSignal_C_40_OBUF_GTS_TRI_CTL,
      O => C(40)
    );
  C_39_OBUF_GTS_TRI_217 : X_TRI
    port map (
      I => C_39_OBUF_GTS_TRI,
      CTL => NlwInverterSignal_C_39_OBUF_GTS_TRI_CTL,
      O => C(39)
    );
  C_38_OBUF_GTS_TRI_218 : X_TRI
    port map (
      I => C_38_OBUF_GTS_TRI,
      CTL => NlwInverterSignal_C_38_OBUF_GTS_TRI_CTL,
      O => C(38)
    );
  C_37_OBUF_GTS_TRI_219 : X_TRI
    port map (
      I => C_37_OBUF_GTS_TRI,
      CTL => NlwInverterSignal_C_37_OBUF_GTS_TRI_CTL,
      O => C(37)
    );
  C_36_OBUF_GTS_TRI_220 : X_TRI
    port map (
      I => C_36_OBUF_GTS_TRI,
      CTL => NlwInverterSignal_C_36_OBUF_GTS_TRI_CTL,
      O => C(36)
    );
  C_35_OBUF_GTS_TRI_221 : X_TRI
    port map (
      I => C_35_OBUF_GTS_TRI,
      CTL => NlwInverterSignal_C_35_OBUF_GTS_TRI_CTL,
      O => C(35)
    );
  C_34_OBUF_GTS_TRI_222 : X_TRI
    port map (
      I => C_34_OBUF_GTS_TRI,
      CTL => NlwInverterSignal_C_34_OBUF_GTS_TRI_CTL,
      O => C(34)
    );
  C_33_OBUF_GTS_TRI_223 : X_TRI
    port map (
      I => C_33_OBUF_GTS_TRI,
      CTL => NlwInverterSignal_C_33_OBUF_GTS_TRI_CTL,
      O => C(33)
    );
  C_32_OBUF_GTS_TRI_224 : X_TRI
    port map (
      I => C_32_OBUF_GTS_TRI,
      CTL => NlwInverterSignal_C_32_OBUF_GTS_TRI_CTL,
      O => C(32)
    );
  C_31_OBUF_GTS_TRI_225 : X_TRI
    port map (
      I => C_31_OBUF_GTS_TRI,
      CTL => NlwInverterSignal_C_31_OBUF_GTS_TRI_CTL,
      O => C(31)
    );
  C_30_OBUF_GTS_TRI_226 : X_TRI
    port map (
      I => C_30_OBUF_GTS_TRI,
      CTL => NlwInverterSignal_C_30_OBUF_GTS_TRI_CTL,
      O => C(30)
    );
  C_29_OBUF_GTS_TRI_227 : X_TRI
    port map (
      I => C_29_OBUF_GTS_TRI,
      CTL => NlwInverterSignal_C_29_OBUF_GTS_TRI_CTL,
      O => C(29)
    );
  C_28_OBUF_GTS_TRI_228 : X_TRI
    port map (
      I => C_28_OBUF_GTS_TRI,
      CTL => NlwInverterSignal_C_28_OBUF_GTS_TRI_CTL,
      O => C(28)
    );
  C_27_OBUF_GTS_TRI_229 : X_TRI
    port map (
      I => C_27_OBUF_GTS_TRI,
      CTL => NlwInverterSignal_C_27_OBUF_GTS_TRI_CTL,
      O => C(27)
    );
  C_26_OBUF_GTS_TRI_230 : X_TRI
    port map (
      I => C_26_OBUF_GTS_TRI,
      CTL => NlwInverterSignal_C_26_OBUF_GTS_TRI_CTL,
      O => C(26)
    );
  C_25_OBUF_GTS_TRI_231 : X_TRI
    port map (
      I => C_25_OBUF_GTS_TRI,
      CTL => NlwInverterSignal_C_25_OBUF_GTS_TRI_CTL,
      O => C(25)
    );
  C_24_OBUF_GTS_TRI_232 : X_TRI
    port map (
      I => C_24_OBUF_GTS_TRI,
      CTL => NlwInverterSignal_C_24_OBUF_GTS_TRI_CTL,
      O => C(24)
    );
  C_23_OBUF_GTS_TRI_233 : X_TRI
    port map (
      I => C_23_OBUF_GTS_TRI,
      CTL => NlwInverterSignal_C_23_OBUF_GTS_TRI_CTL,
      O => C(23)
    );
  C_22_OBUF_GTS_TRI_234 : X_TRI
    port map (
      I => C_22_OBUF_GTS_TRI,
      CTL => NlwInverterSignal_C_22_OBUF_GTS_TRI_CTL,
      O => C(22)
    );
  C_21_OBUF_GTS_TRI_235 : X_TRI
    port map (
      I => C_21_OBUF_GTS_TRI,
      CTL => NlwInverterSignal_C_21_OBUF_GTS_TRI_CTL,
      O => C(21)
    );
  C_20_OBUF_GTS_TRI_236 : X_TRI
    port map (
      I => C_20_OBUF_GTS_TRI,
      CTL => NlwInverterSignal_C_20_OBUF_GTS_TRI_CTL,
      O => C(20)
    );
  C_19_OBUF_GTS_TRI_237 : X_TRI
    port map (
      I => C_19_OBUF_GTS_TRI,
      CTL => NlwInverterSignal_C_19_OBUF_GTS_TRI_CTL,
      O => C(19)
    );
  C_18_OBUF_GTS_TRI_238 : X_TRI
    port map (
      I => C_18_OBUF_GTS_TRI,
      CTL => NlwInverterSignal_C_18_OBUF_GTS_TRI_CTL,
      O => C(18)
    );
  C_17_OBUF_GTS_TRI_239 : X_TRI
    port map (
      I => C_17_OBUF_GTS_TRI,
      CTL => NlwInverterSignal_C_17_OBUF_GTS_TRI_CTL,
      O => C(17)
    );
  C_16_OBUF_GTS_TRI_240 : X_TRI
    port map (
      I => C_16_OBUF_GTS_TRI,
      CTL => NlwInverterSignal_C_16_OBUF_GTS_TRI_CTL,
      O => C(16)
    );
  C_15_OBUF_GTS_TRI_241 : X_TRI
    port map (
      I => C_15_OBUF_GTS_TRI,
      CTL => NlwInverterSignal_C_15_OBUF_GTS_TRI_CTL,
      O => C(15)
    );
  C_14_OBUF_GTS_TRI_242 : X_TRI
    port map (
      I => C_14_OBUF_GTS_TRI,
      CTL => NlwInverterSignal_C_14_OBUF_GTS_TRI_CTL,
      O => C(14)
    );
  C_13_OBUF_GTS_TRI_243 : X_TRI
    port map (
      I => C_13_OBUF_GTS_TRI,
      CTL => NlwInverterSignal_C_13_OBUF_GTS_TRI_CTL,
      O => C(13)
    );
  C_12_OBUF_GTS_TRI_244 : X_TRI
    port map (
      I => C_12_OBUF_GTS_TRI,
      CTL => NlwInverterSignal_C_12_OBUF_GTS_TRI_CTL,
      O => C(12)
    );
  C_11_OBUF_GTS_TRI_245 : X_TRI
    port map (
      I => C_11_OBUF_GTS_TRI,
      CTL => NlwInverterSignal_C_11_OBUF_GTS_TRI_CTL,
      O => C(11)
    );
  C_10_OBUF_GTS_TRI_246 : X_TRI
    port map (
      I => C_10_OBUF_GTS_TRI,
      CTL => NlwInverterSignal_C_10_OBUF_GTS_TRI_CTL,
      O => C(10)
    );
  C_9_OBUF_GTS_TRI_247 : X_TRI
    port map (
      I => C_9_OBUF_GTS_TRI,
      CTL => NlwInverterSignal_C_9_OBUF_GTS_TRI_CTL,
      O => C(9)
    );
  C_8_OBUF_GTS_TRI_248 : X_TRI
    port map (
      I => C_8_OBUF_GTS_TRI,
      CTL => NlwInverterSignal_C_8_OBUF_GTS_TRI_CTL,
      O => C(8)
    );
  C_7_OBUF_GTS_TRI_249 : X_TRI
    port map (
      I => C_7_OBUF_GTS_TRI,
      CTL => NlwInverterSignal_C_7_OBUF_GTS_TRI_CTL,
      O => C(7)
    );
  C_6_OBUF_GTS_TRI_250 : X_TRI
    port map (
      I => C_6_OBUF_GTS_TRI,
      CTL => NlwInverterSignal_C_6_OBUF_GTS_TRI_CTL,
      O => C(6)
    );
  C_5_OBUF_GTS_TRI_251 : X_TRI
    port map (
      I => C_5_OBUF_GTS_TRI,
      CTL => NlwInverterSignal_C_5_OBUF_GTS_TRI_CTL,
      O => C(5)
    );
  C_4_OBUF_GTS_TRI_252 : X_TRI
    port map (
      I => C_4_OBUF_GTS_TRI,
      CTL => NlwInverterSignal_C_4_OBUF_GTS_TRI_CTL,
      O => C(4)
    );
  C_3_OBUF_GTS_TRI_253 : X_TRI
    port map (
      I => C_3_OBUF_GTS_TRI,
      CTL => NlwInverterSignal_C_3_OBUF_GTS_TRI_CTL,
      O => C(3)
    );
  C_2_OBUF_GTS_TRI_254 : X_TRI
    port map (
      I => C_2_OBUF_GTS_TRI,
      CTL => NlwInverterSignal_C_2_OBUF_GTS_TRI_CTL,
      O => C(2)
    );
  C_1_OBUF_GTS_TRI_255 : X_TRI
    port map (
      I => C_1_OBUF_GTS_TRI,
      CTL => NlwInverterSignal_C_1_OBUF_GTS_TRI_CTL,
      O => C(1)
    );
  NlwInverterBlock_C_0_OBUF_GTS_TRI_CTL : X_INV
    port map (
      I => GTS,
      O => NlwInverterSignal_C_0_OBUF_GTS_TRI_CTL
    );
  NlwInverterBlock_C_63_OBUF_GTS_TRI_CTL : X_INV
    port map (
      I => GTS,
      O => NlwInverterSignal_C_63_OBUF_GTS_TRI_CTL
    );
  NlwInverterBlock_C_62_OBUF_GTS_TRI_CTL : X_INV
    port map (
      I => GTS,
      O => NlwInverterSignal_C_62_OBUF_GTS_TRI_CTL
    );
  NlwInverterBlock_C_61_OBUF_GTS_TRI_CTL : X_INV
    port map (
      I => GTS,
      O => NlwInverterSignal_C_61_OBUF_GTS_TRI_CTL
    );
  NlwInverterBlock_C_60_OBUF_GTS_TRI_CTL : X_INV
    port map (
      I => GTS,
      O => NlwInverterSignal_C_60_OBUF_GTS_TRI_CTL
    );
  NlwInverterBlock_C_59_OBUF_GTS_TRI_CTL : X_INV
    port map (
      I => GTS,
      O => NlwInverterSignal_C_59_OBUF_GTS_TRI_CTL
    );
  NlwInverterBlock_C_58_OBUF_GTS_TRI_CTL : X_INV
    port map (
      I => GTS,
      O => NlwInverterSignal_C_58_OBUF_GTS_TRI_CTL
    );
  NlwInverterBlock_C_57_OBUF_GTS_TRI_CTL : X_INV
    port map (
      I => GTS,
      O => NlwInverterSignal_C_57_OBUF_GTS_TRI_CTL
    );
  NlwInverterBlock_C_56_OBUF_GTS_TRI_CTL : X_INV
    port map (
      I => GTS,
      O => NlwInverterSignal_C_56_OBUF_GTS_TRI_CTL
    );
  NlwInverterBlock_C_55_OBUF_GTS_TRI_CTL : X_INV
    port map (
      I => GTS,
      O => NlwInverterSignal_C_55_OBUF_GTS_TRI_CTL
    );
  NlwInverterBlock_C_54_OBUF_GTS_TRI_CTL : X_INV
    port map (
      I => GTS,
      O => NlwInverterSignal_C_54_OBUF_GTS_TRI_CTL
    );
  NlwInverterBlock_C_53_OBUF_GTS_TRI_CTL : X_INV
    port map (
      I => GTS,
      O => NlwInverterSignal_C_53_OBUF_GTS_TRI_CTL
    );
  NlwInverterBlock_C_52_OBUF_GTS_TRI_CTL : X_INV
    port map (
      I => GTS,
      O => NlwInverterSignal_C_52_OBUF_GTS_TRI_CTL
    );
  NlwInverterBlock_C_51_OBUF_GTS_TRI_CTL : X_INV
    port map (
      I => GTS,
      O => NlwInverterSignal_C_51_OBUF_GTS_TRI_CTL
    );
  NlwInverterBlock_C_50_OBUF_GTS_TRI_CTL : X_INV
    port map (
      I => GTS,
      O => NlwInverterSignal_C_50_OBUF_GTS_TRI_CTL
    );
  NlwInverterBlock_C_49_OBUF_GTS_TRI_CTL : X_INV
    port map (
      I => GTS,
      O => NlwInverterSignal_C_49_OBUF_GTS_TRI_CTL
    );
  NlwInverterBlock_C_48_OBUF_GTS_TRI_CTL : X_INV
    port map (
      I => GTS,
      O => NlwInverterSignal_C_48_OBUF_GTS_TRI_CTL
    );
  NlwInverterBlock_C_47_OBUF_GTS_TRI_CTL : X_INV
    port map (
      I => GTS,
      O => NlwInverterSignal_C_47_OBUF_GTS_TRI_CTL
    );
  NlwInverterBlock_C_46_OBUF_GTS_TRI_CTL : X_INV
    port map (
      I => GTS,
      O => NlwInverterSignal_C_46_OBUF_GTS_TRI_CTL
    );
  NlwInverterBlock_C_45_OBUF_GTS_TRI_CTL : X_INV
    port map (
      I => GTS,
      O => NlwInverterSignal_C_45_OBUF_GTS_TRI_CTL
    );
  NlwInverterBlock_C_44_OBUF_GTS_TRI_CTL : X_INV
    port map (
      I => GTS,
      O => NlwInverterSignal_C_44_OBUF_GTS_TRI_CTL
    );
  NlwInverterBlock_C_43_OBUF_GTS_TRI_CTL : X_INV
    port map (
      I => GTS,
      O => NlwInverterSignal_C_43_OBUF_GTS_TRI_CTL
    );
  NlwInverterBlock_C_42_OBUF_GTS_TRI_CTL : X_INV
    port map (
      I => GTS,
      O => NlwInverterSignal_C_42_OBUF_GTS_TRI_CTL
    );
  NlwInverterBlock_C_41_OBUF_GTS_TRI_CTL : X_INV
    port map (
      I => GTS,
      O => NlwInverterSignal_C_41_OBUF_GTS_TRI_CTL
    );
  NlwInverterBlock_C_40_OBUF_GTS_TRI_CTL : X_INV
    port map (
      I => GTS,
      O => NlwInverterSignal_C_40_OBUF_GTS_TRI_CTL
    );
  NlwInverterBlock_C_39_OBUF_GTS_TRI_CTL : X_INV
    port map (
      I => GTS,
      O => NlwInverterSignal_C_39_OBUF_GTS_TRI_CTL
    );
  NlwInverterBlock_C_38_OBUF_GTS_TRI_CTL : X_INV
    port map (
      I => GTS,
      O => NlwInverterSignal_C_38_OBUF_GTS_TRI_CTL
    );
  NlwInverterBlock_C_37_OBUF_GTS_TRI_CTL : X_INV
    port map (
      I => GTS,
      O => NlwInverterSignal_C_37_OBUF_GTS_TRI_CTL
    );
  NlwInverterBlock_C_36_OBUF_GTS_TRI_CTL : X_INV
    port map (
      I => GTS,
      O => NlwInverterSignal_C_36_OBUF_GTS_TRI_CTL
    );
  NlwInverterBlock_C_35_OBUF_GTS_TRI_CTL : X_INV
    port map (
      I => GTS,
      O => NlwInverterSignal_C_35_OBUF_GTS_TRI_CTL
    );
  NlwInverterBlock_C_34_OBUF_GTS_TRI_CTL : X_INV
    port map (
      I => GTS,
      O => NlwInverterSignal_C_34_OBUF_GTS_TRI_CTL
    );
  NlwInverterBlock_C_33_OBUF_GTS_TRI_CTL : X_INV
    port map (
      I => GTS,
      O => NlwInverterSignal_C_33_OBUF_GTS_TRI_CTL
    );
  NlwInverterBlock_C_32_OBUF_GTS_TRI_CTL : X_INV
    port map (
      I => GTS,
      O => NlwInverterSignal_C_32_OBUF_GTS_TRI_CTL
    );
  NlwInverterBlock_C_31_OBUF_GTS_TRI_CTL : X_INV
    port map (
      I => GTS,
      O => NlwInverterSignal_C_31_OBUF_GTS_TRI_CTL
    );
  NlwInverterBlock_C_30_OBUF_GTS_TRI_CTL : X_INV
    port map (
      I => GTS,
      O => NlwInverterSignal_C_30_OBUF_GTS_TRI_CTL
    );
  NlwInverterBlock_C_29_OBUF_GTS_TRI_CTL : X_INV
    port map (
      I => GTS,
      O => NlwInverterSignal_C_29_OBUF_GTS_TRI_CTL
    );
  NlwInverterBlock_C_28_OBUF_GTS_TRI_CTL : X_INV
    port map (
      I => GTS,
      O => NlwInverterSignal_C_28_OBUF_GTS_TRI_CTL
    );
  NlwInverterBlock_C_27_OBUF_GTS_TRI_CTL : X_INV
    port map (
      I => GTS,
      O => NlwInverterSignal_C_27_OBUF_GTS_TRI_CTL
    );
  NlwInverterBlock_C_26_OBUF_GTS_TRI_CTL : X_INV
    port map (
      I => GTS,
      O => NlwInverterSignal_C_26_OBUF_GTS_TRI_CTL
    );
  NlwInverterBlock_C_25_OBUF_GTS_TRI_CTL : X_INV
    port map (
      I => GTS,
      O => NlwInverterSignal_C_25_OBUF_GTS_TRI_CTL
    );
  NlwInverterBlock_C_24_OBUF_GTS_TRI_CTL : X_INV
    port map (
      I => GTS,
      O => NlwInverterSignal_C_24_OBUF_GTS_TRI_CTL
    );
  NlwInverterBlock_C_23_OBUF_GTS_TRI_CTL : X_INV
    port map (
      I => GTS,
      O => NlwInverterSignal_C_23_OBUF_GTS_TRI_CTL
    );
  NlwInverterBlock_C_22_OBUF_GTS_TRI_CTL : X_INV
    port map (
      I => GTS,
      O => NlwInverterSignal_C_22_OBUF_GTS_TRI_CTL
    );
  NlwInverterBlock_C_21_OBUF_GTS_TRI_CTL : X_INV
    port map (
      I => GTS,
      O => NlwInverterSignal_C_21_OBUF_GTS_TRI_CTL
    );
  NlwInverterBlock_C_20_OBUF_GTS_TRI_CTL : X_INV
    port map (
      I => GTS,
      O => NlwInverterSignal_C_20_OBUF_GTS_TRI_CTL
    );
  NlwInverterBlock_C_19_OBUF_GTS_TRI_CTL : X_INV
    port map (
      I => GTS,
      O => NlwInverterSignal_C_19_OBUF_GTS_TRI_CTL
    );
  NlwInverterBlock_C_18_OBUF_GTS_TRI_CTL : X_INV
    port map (
      I => GTS,
      O => NlwInverterSignal_C_18_OBUF_GTS_TRI_CTL
    );
  NlwInverterBlock_C_17_OBUF_GTS_TRI_CTL : X_INV
    port map (
      I => GTS,
      O => NlwInverterSignal_C_17_OBUF_GTS_TRI_CTL
    );
  NlwInverterBlock_C_16_OBUF_GTS_TRI_CTL : X_INV
    port map (
      I => GTS,
      O => NlwInverterSignal_C_16_OBUF_GTS_TRI_CTL
    );
  NlwInverterBlock_C_15_OBUF_GTS_TRI_CTL : X_INV
    port map (
      I => GTS,
      O => NlwInverterSignal_C_15_OBUF_GTS_TRI_CTL
    );
  NlwInverterBlock_C_14_OBUF_GTS_TRI_CTL : X_INV
    port map (
      I => GTS,
      O => NlwInverterSignal_C_14_OBUF_GTS_TRI_CTL
    );
  NlwInverterBlock_C_13_OBUF_GTS_TRI_CTL : X_INV
    port map (
      I => GTS,
      O => NlwInverterSignal_C_13_OBUF_GTS_TRI_CTL
    );
  NlwInverterBlock_C_12_OBUF_GTS_TRI_CTL : X_INV
    port map (
      I => GTS,
      O => NlwInverterSignal_C_12_OBUF_GTS_TRI_CTL
    );
  NlwInverterBlock_C_11_OBUF_GTS_TRI_CTL : X_INV
    port map (
      I => GTS,
      O => NlwInverterSignal_C_11_OBUF_GTS_TRI_CTL
    );
  NlwInverterBlock_C_10_OBUF_GTS_TRI_CTL : X_INV
    port map (
      I => GTS,
      O => NlwInverterSignal_C_10_OBUF_GTS_TRI_CTL
    );
  NlwInverterBlock_C_9_OBUF_GTS_TRI_CTL : X_INV
    port map (
      I => GTS,
      O => NlwInverterSignal_C_9_OBUF_GTS_TRI_CTL
    );
  NlwInverterBlock_C_8_OBUF_GTS_TRI_CTL : X_INV
    port map (
      I => GTS,
      O => NlwInverterSignal_C_8_OBUF_GTS_TRI_CTL
    );
  NlwInverterBlock_C_7_OBUF_GTS_TRI_CTL : X_INV
    port map (
      I => GTS,
      O => NlwInverterSignal_C_7_OBUF_GTS_TRI_CTL
    );
  NlwInverterBlock_C_6_OBUF_GTS_TRI_CTL : X_INV
    port map (
      I => GTS,
      O => NlwInverterSignal_C_6_OBUF_GTS_TRI_CTL
    );
  NlwInverterBlock_C_5_OBUF_GTS_TRI_CTL : X_INV
    port map (
      I => GTS,
      O => NlwInverterSignal_C_5_OBUF_GTS_TRI_CTL
    );
  NlwInverterBlock_C_4_OBUF_GTS_TRI_CTL : X_INV
    port map (
      I => GTS,
      O => NlwInverterSignal_C_4_OBUF_GTS_TRI_CTL
    );
  NlwInverterBlock_C_3_OBUF_GTS_TRI_CTL : X_INV
    port map (
      I => GTS,
      O => NlwInverterSignal_C_3_OBUF_GTS_TRI_CTL
    );
  NlwInverterBlock_C_2_OBUF_GTS_TRI_CTL : X_INV
    port map (
      I => GTS,
      O => NlwInverterSignal_C_2_OBUF_GTS_TRI_CTL
    );
  NlwInverterBlock_C_1_OBUF_GTS_TRI_CTL : X_INV
    port map (
      I => GTS,
      O => NlwInverterSignal_C_1_OBUF_GTS_TRI_CTL
    );
  NlwBlockTOC : X_TOC
    port map (O => GTS);

end Structure;

