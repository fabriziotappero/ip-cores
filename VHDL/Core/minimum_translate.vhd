-- Xilinx Vhdl netlist produced by netgen application (version G.26)
-- Command       : -intstyle ise -rpw 100 -tpw 0 -ar Structure -xon true -w -ofmt vhdl -sim minimum.ngd minimum_translate.vhd 
-- Input file    : minimum.ngd
-- Output file   : minimum_translate.vhd
-- Design name   : minimum
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

entity minimum is
  port (
    A : in STD_LOGIC_VECTOR ( 7 downto 0 ); 
    B : in STD_LOGIC_VECTOR ( 7 downto 0 ); 
    C : out STD_LOGIC_VECTOR ( 7 downto 0 ) 
  );
end minimum;

architecture Structure of minimum is
  signal B_2_IBUF : STD_LOGIC; 
  signal B_1_IBUF : STD_LOGIC; 
  signal B_3_IBUF : STD_LOGIC; 
  signal Q_n0000 : STD_LOGIC; 
  signal B_0_IBUF : STD_LOGIC; 
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
  signal B_7_IBUF : STD_LOGIC; 
  signal B_6_IBUF : STD_LOGIC; 
  signal B_5_IBUF : STD_LOGIC; 
  signal B_4_IBUF : STD_LOGIC; 
  signal N81 : STD_LOGIC; 
  signal Mcompar_n0000_inst_lut2_7 : STD_LOGIC; 
  signal Mcompar_n0000_inst_cy_6 : STD_LOGIC; 
  signal Mcompar_n0000_inst_lut2_6 : STD_LOGIC; 
  signal Mcompar_n0000_inst_cy_5 : STD_LOGIC; 
  signal Mcompar_n0000_inst_lut2_5 : STD_LOGIC; 
  signal Mcompar_n0000_inst_cy_4 : STD_LOGIC; 
  signal Mcompar_n0000_inst_lut2_4 : STD_LOGIC; 
  signal Mcompar_n0000_inst_cy_3 : STD_LOGIC; 
  signal Mcompar_n0000_inst_lut2_3 : STD_LOGIC; 
  signal Mcompar_n0000_inst_cy_2 : STD_LOGIC; 
  signal Mcompar_n0000_inst_lut2_2 : STD_LOGIC; 
  signal Mcompar_n0000_inst_cy_1 : STD_LOGIC; 
  signal Mcompar_n0000_inst_lut2_1 : STD_LOGIC; 
  signal Mcompar_n0000_inst_cy_0 : STD_LOGIC; 
  signal Mcompar_n0000_inst_lut2_0 : STD_LOGIC; 
  signal C_0_OBUF_GTS_TRI : STD_LOGIC; 
  signal GTS : STD_LOGIC; 
  signal C_7_OBUF_GTS_TRI : STD_LOGIC; 
  signal C_6_OBUF_GTS_TRI : STD_LOGIC; 
  signal C_5_OBUF_GTS_TRI : STD_LOGIC; 
  signal C_4_OBUF_GTS_TRI : STD_LOGIC; 
  signal C_3_OBUF_GTS_TRI : STD_LOGIC; 
  signal C_2_OBUF_GTS_TRI : STD_LOGIC; 
  signal C_1_OBUF_GTS_TRI : STD_LOGIC; 
  signal NlwInverterSignal_C_0_OBUF_GTS_TRI_CTL : STD_LOGIC; 
  signal NlwInverterSignal_C_7_OBUF_GTS_TRI_CTL : STD_LOGIC; 
  signal NlwInverterSignal_C_6_OBUF_GTS_TRI_CTL : STD_LOGIC; 
  signal NlwInverterSignal_C_5_OBUF_GTS_TRI_CTL : STD_LOGIC; 
  signal NlwInverterSignal_C_4_OBUF_GTS_TRI_CTL : STD_LOGIC; 
  signal NlwInverterSignal_C_3_OBUF_GTS_TRI_CTL : STD_LOGIC; 
  signal NlwInverterSignal_C_2_OBUF_GTS_TRI_CTL : STD_LOGIC; 
  signal NlwInverterSignal_C_1_OBUF_GTS_TRI_CTL : STD_LOGIC; 
begin
  Mcompar_n0000_inst_cy_7 : X_MUX2
    port map (
      IB => Mcompar_n0000_inst_cy_6,
      IA => B_7_IBUF,
      SEL => Mcompar_n0000_inst_lut2_7,
      O => Q_n0000
    );
  Mmux_C_Result_7_1 : X_LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      ADR0 => Q_n0000,
      ADR1 => B_7_IBUF,
      ADR2 => A_7_IBUF,
      O => C_7_OBUF
    );
  XST_GND : X_ZERO
    port map (
      O => N81
    );
  C_0_OBUF_0 : X_BUF
    port map (
      I => C_0_OBUF,
      O => C_0_OBUF_GTS_TRI
    );
  Mcompar_n0000_inst_lut2_01 : X_LUT2
    generic map(
      INIT => X"9"
    )
    port map (
      ADR0 => B_0_IBUF,
      ADR1 => A_0_IBUF,
      O => Mcompar_n0000_inst_lut2_0
    );
  Mcompar_n0000_inst_cy_0_1 : X_MUX2
    port map (
      IB => N81,
      IA => B_0_IBUF,
      SEL => Mcompar_n0000_inst_lut2_0,
      O => Mcompar_n0000_inst_cy_0
    );
  Mcompar_n0000_inst_lut2_11 : X_LUT2
    generic map(
      INIT => X"9"
    )
    port map (
      ADR0 => B_1_IBUF,
      ADR1 => A_1_IBUF,
      O => Mcompar_n0000_inst_lut2_1
    );
  Mcompar_n0000_inst_cy_1_2 : X_MUX2
    port map (
      IB => Mcompar_n0000_inst_cy_0,
      IA => B_1_IBUF,
      SEL => Mcompar_n0000_inst_lut2_1,
      O => Mcompar_n0000_inst_cy_1
    );
  Mcompar_n0000_inst_lut2_21 : X_LUT2
    generic map(
      INIT => X"9"
    )
    port map (
      ADR0 => B_2_IBUF,
      ADR1 => A_2_IBUF,
      O => Mcompar_n0000_inst_lut2_2
    );
  Mcompar_n0000_inst_cy_2_3 : X_MUX2
    port map (
      IB => Mcompar_n0000_inst_cy_1,
      IA => B_2_IBUF,
      SEL => Mcompar_n0000_inst_lut2_2,
      O => Mcompar_n0000_inst_cy_2
    );
  Mcompar_n0000_inst_lut2_31 : X_LUT2
    generic map(
      INIT => X"9"
    )
    port map (
      ADR0 => B_3_IBUF,
      ADR1 => A_3_IBUF,
      O => Mcompar_n0000_inst_lut2_3
    );
  Mcompar_n0000_inst_cy_3_4 : X_MUX2
    port map (
      IB => Mcompar_n0000_inst_cy_2,
      IA => B_3_IBUF,
      SEL => Mcompar_n0000_inst_lut2_3,
      O => Mcompar_n0000_inst_cy_3
    );
  Mcompar_n0000_inst_lut2_41 : X_LUT2
    generic map(
      INIT => X"9"
    )
    port map (
      ADR0 => B_4_IBUF,
      ADR1 => A_4_IBUF,
      O => Mcompar_n0000_inst_lut2_4
    );
  Mcompar_n0000_inst_cy_4_5 : X_MUX2
    port map (
      IB => Mcompar_n0000_inst_cy_3,
      IA => B_4_IBUF,
      SEL => Mcompar_n0000_inst_lut2_4,
      O => Mcompar_n0000_inst_cy_4
    );
  Mcompar_n0000_inst_lut2_51 : X_LUT2
    generic map(
      INIT => X"9"
    )
    port map (
      ADR0 => B_5_IBUF,
      ADR1 => A_5_IBUF,
      O => Mcompar_n0000_inst_lut2_5
    );
  Mcompar_n0000_inst_cy_5_6 : X_MUX2
    port map (
      IB => Mcompar_n0000_inst_cy_4,
      IA => B_5_IBUF,
      SEL => Mcompar_n0000_inst_lut2_5,
      O => Mcompar_n0000_inst_cy_5
    );
  Mcompar_n0000_inst_lut2_61 : X_LUT2
    generic map(
      INIT => X"9"
    )
    port map (
      ADR0 => B_6_IBUF,
      ADR1 => A_6_IBUF,
      O => Mcompar_n0000_inst_lut2_6
    );
  Mcompar_n0000_inst_cy_6_7 : X_MUX2
    port map (
      IB => Mcompar_n0000_inst_cy_5,
      IA => B_6_IBUF,
      SEL => Mcompar_n0000_inst_lut2_6,
      O => Mcompar_n0000_inst_cy_6
    );
  Mcompar_n0000_inst_lut2_71 : X_LUT2
    generic map(
      INIT => X"9"
    )
    port map (
      ADR0 => B_7_IBUF,
      ADR1 => A_7_IBUF,
      O => Mcompar_n0000_inst_lut2_7
    );
  Mmux_C_Result_0_1 : X_LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      ADR0 => Q_n0000,
      ADR1 => B_0_IBUF,
      ADR2 => A_0_IBUF,
      O => C_0_OBUF
    );
  Mmux_C_Result_1_1 : X_LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      ADR0 => Q_n0000,
      ADR1 => B_1_IBUF,
      ADR2 => A_1_IBUF,
      O => C_1_OBUF
    );
  Mmux_C_Result_2_1 : X_LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      ADR0 => Q_n0000,
      ADR1 => B_2_IBUF,
      ADR2 => A_2_IBUF,
      O => C_2_OBUF
    );
  Mmux_C_Result_3_1 : X_LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      ADR0 => Q_n0000,
      ADR1 => B_3_IBUF,
      ADR2 => A_3_IBUF,
      O => C_3_OBUF
    );
  Mmux_C_Result_4_1 : X_LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      ADR0 => Q_n0000,
      ADR1 => B_4_IBUF,
      ADR2 => A_4_IBUF,
      O => C_4_OBUF
    );
  Mmux_C_Result_5_1 : X_LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      ADR0 => Q_n0000,
      ADR1 => B_5_IBUF,
      ADR2 => A_5_IBUF,
      O => C_5_OBUF
    );
  Mmux_C_Result_6_1 : X_LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      ADR0 => Q_n0000,
      ADR1 => B_6_IBUF,
      ADR2 => A_6_IBUF,
      O => C_6_OBUF
    );
  A_7_IBUF_8 : X_BUF
    port map (
      I => A(7),
      O => A_7_IBUF
    );
  A_6_IBUF_9 : X_BUF
    port map (
      I => A(6),
      O => A_6_IBUF
    );
  A_5_IBUF_10 : X_BUF
    port map (
      I => A(5),
      O => A_5_IBUF
    );
  A_4_IBUF_11 : X_BUF
    port map (
      I => A(4),
      O => A_4_IBUF
    );
  A_3_IBUF_12 : X_BUF
    port map (
      I => A(3),
      O => A_3_IBUF
    );
  A_2_IBUF_13 : X_BUF
    port map (
      I => A(2),
      O => A_2_IBUF
    );
  A_1_IBUF_14 : X_BUF
    port map (
      I => A(1),
      O => A_1_IBUF
    );
  A_0_IBUF_15 : X_BUF
    port map (
      I => A(0),
      O => A_0_IBUF
    );
  B_7_IBUF_16 : X_BUF
    port map (
      I => B(7),
      O => B_7_IBUF
    );
  B_6_IBUF_17 : X_BUF
    port map (
      I => B(6),
      O => B_6_IBUF
    );
  B_5_IBUF_18 : X_BUF
    port map (
      I => B(5),
      O => B_5_IBUF
    );
  B_4_IBUF_19 : X_BUF
    port map (
      I => B(4),
      O => B_4_IBUF
    );
  B_3_IBUF_20 : X_BUF
    port map (
      I => B(3),
      O => B_3_IBUF
    );
  B_2_IBUF_21 : X_BUF
    port map (
      I => B(2),
      O => B_2_IBUF
    );
  B_1_IBUF_22 : X_BUF
    port map (
      I => B(1),
      O => B_1_IBUF
    );
  B_0_IBUF_23 : X_BUF
    port map (
      I => B(0),
      O => B_0_IBUF
    );
  C_7_OBUF_24 : X_BUF
    port map (
      I => C_7_OBUF,
      O => C_7_OBUF_GTS_TRI
    );
  C_6_OBUF_25 : X_BUF
    port map (
      I => C_6_OBUF,
      O => C_6_OBUF_GTS_TRI
    );
  C_5_OBUF_26 : X_BUF
    port map (
      I => C_5_OBUF,
      O => C_5_OBUF_GTS_TRI
    );
  C_4_OBUF_27 : X_BUF
    port map (
      I => C_4_OBUF,
      O => C_4_OBUF_GTS_TRI
    );
  C_3_OBUF_28 : X_BUF
    port map (
      I => C_3_OBUF,
      O => C_3_OBUF_GTS_TRI
    );
  C_2_OBUF_29 : X_BUF
    port map (
      I => C_2_OBUF,
      O => C_2_OBUF_GTS_TRI
    );
  C_1_OBUF_30 : X_BUF
    port map (
      I => C_1_OBUF,
      O => C_1_OBUF_GTS_TRI
    );
  C_0_OBUF_GTS_TRI_31 : X_TRI
    port map (
      I => C_0_OBUF_GTS_TRI,
      CTL => NlwInverterSignal_C_0_OBUF_GTS_TRI_CTL,
      O => C(0)
    );
  C_7_OBUF_GTS_TRI_32 : X_TRI
    port map (
      I => C_7_OBUF_GTS_TRI,
      CTL => NlwInverterSignal_C_7_OBUF_GTS_TRI_CTL,
      O => C(7)
    );
  C_6_OBUF_GTS_TRI_33 : X_TRI
    port map (
      I => C_6_OBUF_GTS_TRI,
      CTL => NlwInverterSignal_C_6_OBUF_GTS_TRI_CTL,
      O => C(6)
    );
  C_5_OBUF_GTS_TRI_34 : X_TRI
    port map (
      I => C_5_OBUF_GTS_TRI,
      CTL => NlwInverterSignal_C_5_OBUF_GTS_TRI_CTL,
      O => C(5)
    );
  C_4_OBUF_GTS_TRI_35 : X_TRI
    port map (
      I => C_4_OBUF_GTS_TRI,
      CTL => NlwInverterSignal_C_4_OBUF_GTS_TRI_CTL,
      O => C(4)
    );
  C_3_OBUF_GTS_TRI_36 : X_TRI
    port map (
      I => C_3_OBUF_GTS_TRI,
      CTL => NlwInverterSignal_C_3_OBUF_GTS_TRI_CTL,
      O => C(3)
    );
  C_2_OBUF_GTS_TRI_37 : X_TRI
    port map (
      I => C_2_OBUF_GTS_TRI,
      CTL => NlwInverterSignal_C_2_OBUF_GTS_TRI_CTL,
      O => C(2)
    );
  C_1_OBUF_GTS_TRI_38 : X_TRI
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

