-- Xilinx Vhdl produced by program ngd2vhdl F.28
-- Command: -quiet -rpw 100 -tpw 0 -ar Structure -xon true -w -log __projnav/ngd2vhdl.log data_gen.ngd data_gen_translate.vhd 
-- Input file: data_gen.ngd
-- Output file: data_gen_translate.vhd
-- Design name: data_gen
-- Xilinx: E:/xilinx
-- # of Entities: 1
-- Device: 2s100tq144-6

-- The output of ngd2vhdl is a simulation model. This file cannot be synthesized,
-- or used in any other manner other than simulation. This netlist uses simulation
-- primitives which may not represent the true implementation of the device, however
-- the netlist is functionally correct. Do not modify this file.

-- Model for  ROC (Reset-On-Configuration) Cell
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.VITAL_Timing.all;
entity ROC is
  generic (InstancePath: STRING := "*";
           WIDTH : Time := 100 ns);
  port(O : out std_ulogic := '1') ;
  attribute VITAL_LEVEL0 of ROC : entity is TRUE;
end ROC;

architecture ROC_V of ROC is
attribute VITAL_LEVEL0 of ROC_V : architecture is TRUE;
begin
  ONE_SHOT : process
  begin
    if (WIDTH <= 0 ns) then
       assert FALSE report
       "*** Error: a positive value of WIDTH must be specified ***"
       severity failure;
    else
       wait for WIDTH;
       O <= '0';
    end if;
    wait;
  end process ONE_SHOT;
end ROC_V;

-- Model for  TOC (Tristate-On-Configuration) Cell
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.VITAL_Timing.all;
entity TOC is
  generic (InstancePath: STRING := "*";
           WIDTH : Time := 0 ns);
  port(O : out std_ulogic := '0');
  attribute VITAL_LEVEL0 of TOC : entity is TRUE;
end TOC;

architecture TOC_V of TOC is
attribute VITAL_LEVEL0 of TOC_V : architecture is TRUE;
begin
  ONE_SHOT : process
  begin
    O <= '1';
    if (WIDTH <= 0 ns) then
       O <= '0';
    else
       wait for WIDTH;
       O <= '0';
    end if;
    wait;
  end process ONE_SHOT;
end TOC_V;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library SIMPRIM;
use SIMPRIM.VCOMPONENTS.ALL;
use SIMPRIM.VPACKAGE.ALL;
entity data_gen is
  port (
    reset : in STD_LOGIC := 'X'; 
    clock : in STD_LOGIC := 'X'; 
    dxout : out STD_LOGIC_VECTOR ( 7 downto 0 ); 
    xout : out STD_LOGIC_VECTOR ( 7 downto 0 ) 
  );
end data_gen;

architecture Structure of data_gen is
  component ROC
    generic (InstancePath: STRING := "*";
             WIDTH : Time := 100 ns);
    port (O : out STD_ULOGIC := '1');
  end component;
  component TOC
    generic (InstancePath: STRING := "*";
             WIDTH : Time := 0 ns);
    port (O : out STD_ULOGIC := '1');
  end component;
  signal data_0_Q : STD_LOGIC; 
  signal reset_ibuf : STD_LOGIC; 
  signal clock_bufgp : STD_LOGIC; 
  signal Q_n0003 : STD_LOGIC; 
  signal xout_1_obuf : STD_LOGIC; 
  signal n2175 : STD_LOGIC; 
  signal channel_tap2_madd_add_out_inst_lut2_5 : STD_LOGIC; 
  signal xout_2_obuf : STD_LOGIC; 
  signal channel_tap2_madd_add_out_inst_lut2_4 : STD_LOGIC; 
  signal data_7_Q : STD_LOGIC; 
  signal channel_tap2_madd_add_out_inst_cy_3 : STD_LOGIC; 
  signal channel_tap3_madd_add_out_inst_lut2_3 : STD_LOGIC; 
  signal channel_tap1_madd_add_out_inst_cy_6 : STD_LOGIC; 
  signal channel_tap2_madd_add_out_inst_cy_5 : STD_LOGIC; 
  signal xout_7_obuf : STD_LOGIC; 
  signal xout_6_obuf : STD_LOGIC; 
  signal xout_5_obuf : STD_LOGIC; 
  signal xout_4_obuf : STD_LOGIC; 
  signal xout_3_obuf : STD_LOGIC; 
  signal channel_tap2_madd_add_out_inst_lut2_3 : STD_LOGIC; 
  signal channel_tap3_madd_add_out_inst_cy_1 : STD_LOGIC; 
  signal channel_tap2_madd_add_out_inst_lut2_6 : STD_LOGIC; 
  signal channel_tap3_madd_add_out_inst_lut2_7 : STD_LOGIC; 
  signal channel_tap2_madd_add_out_inst_cy_6 : STD_LOGIC; 
  signal channel_tap2_madd_add_out_inst_cy_1 : STD_LOGIC; 
  signal channel_tap3_madd_add_out_inst_cy_4 : STD_LOGIC; 
  signal channel_tap3_madd_add_out_inst_cy_3 : STD_LOGIC; 
  signal channel_tap2_madd_add_out_inst_lut2_1 : STD_LOGIC; 
  signal channel_tap3_madd_add_out_inst_lut2_5 : STD_LOGIC; 
  signal channel_tap3_madd_add_out_inst_lut2_2 : STD_LOGIC; 
  signal channel_tap2_madd_add_out_inst_lut2_2 : STD_LOGIC; 
  signal channel_tap3_madd_add_out_inst_lut2_1 : STD_LOGIC; 
  signal channel_tap2_madd_add_out_inst_cy_2 : STD_LOGIC; 
  signal channel_tap3_madd_add_out_inst_cy_2 : STD_LOGIC; 
  signal channel_tap3_madd_add_out_inst_lut2_6 : STD_LOGIC; 
  signal channel_tap3_madd_add_out_inst_cy_5 : STD_LOGIC; 
  signal channel_tap3_madd_add_out_inst_cy_6 : STD_LOGIC; 
  signal channel_tap2_madd_add_out_inst_cy_4 : STD_LOGIC; 
  signal channel_tap3_madd_add_out_inst_lut2_4 : STD_LOGIC; 
  signal Q_n0003_O : STD_LOGIC; 
  signal clock_bufgp_IBUFG : STD_LOGIC; 
  signal GSR : STD_LOGIC; 
  signal dxout_7_obuf_GTS_TRI : STD_LOGIC; 
  signal GTS : STD_LOGIC; 
  signal dxout_6_obuf_GTS_TRI : STD_LOGIC; 
  signal dxout_5_obuf_GTS_TRI : STD_LOGIC; 
  signal dxout_4_obuf_GTS_TRI : STD_LOGIC; 
  signal dxout_3_obuf_GTS_TRI : STD_LOGIC; 
  signal dxout_2_obuf_GTS_TRI : STD_LOGIC; 
  signal dxout_1_obuf_GTS_TRI : STD_LOGIC; 
  signal dxout_0_obuf_GTS_TRI : STD_LOGIC; 
  signal xout_7_obuf_GTS_TRI : STD_LOGIC; 
  signal xout_6_obuf_GTS_TRI : STD_LOGIC; 
  signal xout_5_obuf_GTS_TRI : STD_LOGIC; 
  signal xout_4_obuf_GTS_TRI : STD_LOGIC; 
  signal xout_3_obuf_GTS_TRI : STD_LOGIC; 
  signal xout_2_obuf_GTS_TRI : STD_LOGIC; 
  signal xout_1_obuf_GTS_TRI : STD_LOGIC; 
  signal xout_0_obuf_GTS_TRI : STD_LOGIC; 
  signal VCC : STD_LOGIC; 
  signal GND : STD_LOGIC; 
  signal NlwInverterSignal_dxout_7_obuf_GTS_TRI_CTL : STD_LOGIC; 
  signal NlwInverterSignal_dxout_6_obuf_GTS_TRI_CTL : STD_LOGIC; 
  signal NlwInverterSignal_dxout_5_obuf_GTS_TRI_CTL : STD_LOGIC; 
  signal NlwInverterSignal_dxout_4_obuf_GTS_TRI_CTL : STD_LOGIC; 
  signal NlwInverterSignal_dxout_3_obuf_GTS_TRI_CTL : STD_LOGIC; 
  signal NlwInverterSignal_dxout_2_obuf_GTS_TRI_CTL : STD_LOGIC; 
  signal NlwInverterSignal_dxout_1_obuf_GTS_TRI_CTL : STD_LOGIC; 
  signal NlwInverterSignal_dxout_0_obuf_GTS_TRI_CTL : STD_LOGIC; 
  signal NlwInverterSignal_xout_7_obuf_GTS_TRI_CTL : STD_LOGIC; 
  signal NlwInverterSignal_xout_6_obuf_GTS_TRI_CTL : STD_LOGIC; 
  signal NlwInverterSignal_xout_5_obuf_GTS_TRI_CTL : STD_LOGIC; 
  signal NlwInverterSignal_xout_4_obuf_GTS_TRI_CTL : STD_LOGIC; 
  signal NlwInverterSignal_xout_3_obuf_GTS_TRI_CTL : STD_LOGIC; 
  signal NlwInverterSignal_xout_2_obuf_GTS_TRI_CTL : STD_LOGIC; 
  signal NlwInverterSignal_xout_1_obuf_GTS_TRI_CTL : STD_LOGIC; 
  signal NlwInverterSignal_xout_0_obuf_GTS_TRI_CTL : STD_LOGIC; 
  signal channel_tap3_dout : STD_LOGIC_VECTOR ( 7 downto 7 ); 
  signal channel_tap1_dout : STD_LOGIC_VECTOR ( 7 downto 7 ); 
  signal channel_t_res_out2 : STD_LOGIC_VECTOR ( 7 downto 2 ); 
  signal channel_tap2_mul_res : STD_LOGIC_VECTOR ( 2 downto 2 ); 
  signal channel_tap3_mul_res : STD_LOGIC_VECTOR ( 5 downto 5 ); 
  signal channel_tap2_dout : STD_LOGIC_VECTOR ( 7 downto 7 ); 
begin
  channel_tap2_madd_add_out_inst_lut2_511 : X_LUT2
    generic map(
      INIT => X"6"
    )
    port map (
      ADR0 => channel_tap2_mul_res(2),
      ADR1 => data_7_Q,
      O => n2175
    );
  channel_tap3_madd_add_out_inst_sum_1 : X_XOR2
    port map (
      I0 => data_0_Q,
      I1 => channel_tap3_madd_add_out_inst_lut2_1,
      O => xout_1_obuf
    );
  channel_tap2_madd_add_out_inst_lut2_41 : X_LUT2
    generic map(
      INIT => X"6"
    )
    port map (
      ADR0 => channel_tap1_dout(7),
      ADR1 => data_7_Q,
      O => channel_tap2_madd_add_out_inst_lut2_4
    );
  channel_tap3_madd_add_out_inst_sum_6 : X_XOR2
    port map (
      I0 => channel_tap3_madd_add_out_inst_cy_5,
      I1 => channel_tap3_madd_add_out_inst_lut2_6,
      O => xout_6_obuf
    );
  data_7 : X_SFF
    port map (
      I => Q_n0003,
      SRST => reset_ibuf,
      CLK => clock_bufgp,
      O => data_7_Q,
      CE => VCC,
      SET => GND,
      RST => GSR,
      SSET => GND
    );
  xout_0_obuf : X_BUF
    port map (
      I => channel_tap1_madd_add_out_inst_cy_6,
      O => xout_0_obuf_GTS_TRI
    );
  channel_tap2_madd_add_out_inst_sum_6 : X_XOR2
    port map (
      I0 => channel_tap2_madd_add_out_inst_cy_5,
      I1 => channel_tap2_madd_add_out_inst_lut2_6,
      O => channel_t_res_out2(6)
    );
  dxout_0_obuf : X_BUF
    port map (
      I => data_0_Q,
      O => dxout_0_obuf_GTS_TRI
    );
  channel_tap3_madd_add_out_inst_lut2_21 : X_LUT2
    generic map(
      INIT => X"6"
    )
    port map (
      ADR0 => channel_t_res_out2(2),
      ADR1 => channel_tap2_dout(7),
      O => channel_tap3_madd_add_out_inst_lut2_2
    );
  channel_tap2_madd_add_out_inst_cy_1_0 : X_MUX2
    port map (
      IA => data_0_Q,
      IB => channel_tap1_madd_add_out_inst_cy_6,
      SEL => channel_tap2_madd_add_out_inst_lut2_1,
      O => channel_tap2_madd_add_out_inst_cy_1
    );
  channel_tap2_madd_add_out_inst_lut2_111 : X_LUT2
    generic map(
      INIT => X"5"
    )
    port map (
      ADR0 => data_7_Q,
      O => channel_tap2_madd_add_out_inst_lut2_1,
      ADR1 => GND
    );
  xst_vcc : X_ONE
    port map (
      O => data_0_Q
    );
  xst_gnd : X_ZERO
    port map (
      O => channel_tap1_madd_add_out_inst_cy_6
    );
  channel_tap3_madd_add_out_inst_cy_6_1 : X_MUX2
    port map (
      IA => channel_t_res_out2(6),
      IB => channel_tap3_madd_add_out_inst_cy_5,
      SEL => channel_tap3_madd_add_out_inst_lut2_6,
      O => channel_tap3_madd_add_out_inst_cy_6
    );
  channel_tap2_madd_add_out_inst_cy_6_2 : X_MUX2
    port map (
      IA => channel_tap2_mul_res(2),
      IB => channel_tap2_madd_add_out_inst_cy_5,
      SEL => channel_tap2_madd_add_out_inst_lut2_6,
      O => channel_tap2_madd_add_out_inst_cy_6
    );
  channel_tap3_madd_add_out_inst_lut2_61 : X_LUT2
    generic map(
      INIT => X"6"
    )
    port map (
      ADR0 => channel_t_res_out2(6),
      ADR1 => channel_tap2_dout(7),
      O => channel_tap3_madd_add_out_inst_lut2_6
    );
  channel_tap2_madd_add_out_inst_lut2_31 : X_LUT2
    generic map(
      INIT => X"9"
    )
    port map (
      ADR0 => channel_tap1_dout(7),
      ADR1 => data_7_Q,
      O => channel_tap2_madd_add_out_inst_lut2_3
    );
  channel_tap3_madd_add_out_inst_lut2_71 : X_LUT2
    generic map(
      INIT => X"6"
    )
    port map (
      ADR0 => channel_tap2_dout(7),
      ADR1 => channel_t_res_out2(7),
      O => channel_tap3_madd_add_out_inst_lut2_7
    );
  channel_tap3_madd_add_out_inst_sum_5 : X_XOR2
    port map (
      I0 => channel_tap3_madd_add_out_inst_cy_4,
      I1 => channel_tap3_madd_add_out_inst_lut2_5,
      O => xout_5_obuf
    );
  channel_tap3_dout_7 : X_FF
    port map (
      I => channel_tap2_dout(7),
      CLK => clock_bufgp,
      O => channel_tap3_dout(7),
      CE => VCC,
      SET => GND,
      RST => GSR
    );
  channel_tap2_madd_add_out_inst_cy_5_3 : X_MUX2
    port map (
      IA => channel_tap2_mul_res(2),
      IB => channel_tap2_madd_add_out_inst_cy_4,
      SEL => n2175,
      O => channel_tap2_madd_add_out_inst_cy_5
    );
  dxout_5_obuf : X_BUF
    port map (
      I => channel_tap3_dout(7),
      O => dxout_5_obuf_GTS_TRI
    );
  xout_7_obuf_4 : X_BUF
    port map (
      I => xout_7_obuf,
      O => xout_7_obuf_GTS_TRI
    );
  xout_1_obuf_5 : X_BUF
    port map (
      I => xout_1_obuf,
      O => xout_1_obuf_GTS_TRI
    );
  dxout_4_obuf : X_BUF
    port map (
      I => channel_tap3_dout(7),
      O => dxout_4_obuf_GTS_TRI
    );
  reset_ibuf_6 : X_BUF
    port map (
      I => reset,
      O => reset_ibuf
    );
  xout_5_obuf_7 : X_BUF
    port map (
      I => xout_5_obuf,
      O => xout_5_obuf_GTS_TRI
    );
  channel_tap2_madd_add_out_inst_lut2_51 : X_LUT2
    generic map(
      INIT => X"6"
    )
    port map (
      ADR0 => channel_tap2_mul_res(2),
      ADR1 => data_7_Q,
      O => channel_tap2_madd_add_out_inst_lut2_5
    );
  channel_tap3_madd_add_out_inst_cy_5_8 : X_MUX2
    port map (
      IA => channel_t_res_out2(5),
      IB => channel_tap3_madd_add_out_inst_cy_4,
      SEL => channel_tap3_madd_add_out_inst_lut2_5,
      O => channel_tap3_madd_add_out_inst_cy_5
    );
  channel_tap3_madd_add_out_inst_lut2_41 : X_LUT2
    generic map(
      INIT => X"9"
    )
    port map (
      ADR0 => channel_t_res_out2(4),
      ADR1 => channel_tap2_dout(7),
      O => channel_tap3_madd_add_out_inst_lut2_4
    );
  channel_tap3_madd_add_out_inst_cy_1_9 : X_MUX2
    port map (
      IA => channel_tap3_mul_res(5),
      IB => data_0_Q,
      SEL => channel_tap3_madd_add_out_inst_lut2_1,
      O => channel_tap3_madd_add_out_inst_cy_1
    );
  channel_tap3_mmux_mul_res_i2_result1 : X_LUT2
    generic map(
      INIT => X"5"
    )
    port map (
      ADR0 => channel_tap2_dout(7),
      O => channel_tap3_mul_res(5),
      ADR1 => GND
    );
  channel_tap2_madd_add_out_inst_sum_4 : X_XOR2
    port map (
      I0 => channel_tap2_madd_add_out_inst_cy_3,
      I1 => channel_tap2_madd_add_out_inst_lut2_4,
      O => channel_t_res_out2(4)
    );
  channel_tap2_madd_add_out_inst_cy_2_10 : X_MUX2
    port map (
      IA => channel_tap2_mul_res(2),
      IB => channel_tap2_madd_add_out_inst_cy_1,
      SEL => channel_tap2_madd_add_out_inst_lut2_2,
      O => channel_tap2_madd_add_out_inst_cy_2
    );
  channel_tap2_madd_add_out_inst_cy_3_11 : X_MUX2
    port map (
      IA => channel_tap1_dout(7),
      IB => channel_tap2_madd_add_out_inst_cy_2,
      SEL => channel_tap2_madd_add_out_inst_lut2_3,
      O => channel_tap2_madd_add_out_inst_cy_3
    );
  channel_tap2_dout_7 : X_FF
    port map (
      I => channel_tap1_dout(7),
      CLK => clock_bufgp,
      O => channel_tap2_dout(7),
      CE => VCC,
      SET => GND,
      RST => GSR
    );
  channel_tap2_madd_add_out_inst_sum_5 : X_XOR2
    port map (
      I0 => channel_tap2_madd_add_out_inst_cy_4,
      I1 => n2175,
      O => channel_t_res_out2(5)
    );
  dxout_6_obuf : X_BUF
    port map (
      I => channel_tap3_dout(7),
      O => dxout_6_obuf_GTS_TRI
    );
  dxout_3_obuf : X_BUF
    port map (
      I => channel_tap3_dout(7),
      O => dxout_3_obuf_GTS_TRI
    );
  dxout_2_obuf : X_BUF
    port map (
      I => channel_tap3_dout(7),
      O => dxout_2_obuf_GTS_TRI
    );
  xout_3_obuf_12 : X_BUF
    port map (
      I => xout_3_obuf,
      O => xout_3_obuf_GTS_TRI
    );
  channel_tap3_madd_add_out_inst_sum_2 : X_XOR2
    port map (
      I0 => channel_tap3_madd_add_out_inst_cy_1,
      I1 => channel_tap3_madd_add_out_inst_lut2_2,
      O => xout_2_obuf
    );
  channel_tap3_madd_add_out_inst_cy_2_13 : X_MUX2
    port map (
      IA => channel_t_res_out2(2),
      IB => channel_tap3_madd_add_out_inst_cy_1,
      SEL => channel_tap3_madd_add_out_inst_lut2_2,
      O => channel_tap3_madd_add_out_inst_cy_2
    );
  channel_tap3_madd_add_out_inst_sum_4 : X_XOR2
    port map (
      I0 => channel_tap3_madd_add_out_inst_cy_3,
      I1 => channel_tap3_madd_add_out_inst_lut2_4,
      O => xout_4_obuf
    );
  channel_tap2_madd_add_out_inst_lut2_21 : X_LUT2
    generic map(
      INIT => X"9"
    )
    port map (
      ADR0 => channel_tap2_mul_res(2),
      ADR1 => data_7_Q,
      O => channel_tap2_madd_add_out_inst_lut2_2
    );
  channel_tap2_mmux_mul_res_i5_result1 : X_LUT2
    generic map(
      INIT => X"5"
    )
    port map (
      ADR0 => channel_tap1_dout(7),
      O => channel_tap2_mul_res(2),
      ADR1 => GND
    );
  channel_tap3_madd_add_out_inst_cy_4_14 : X_MUX2
    port map (
      IA => channel_t_res_out2(4),
      IB => channel_tap3_madd_add_out_inst_cy_3,
      SEL => channel_tap3_madd_add_out_inst_lut2_4,
      O => channel_tap3_madd_add_out_inst_cy_4
    );
  channel_tap3_madd_add_out_inst_lut2_31 : X_LUT2
    generic map(
      INIT => X"6"
    )
    port map (
      ADR0 => channel_t_res_out2(3),
      ADR1 => channel_tap2_dout(7),
      O => channel_tap3_madd_add_out_inst_lut2_3
    );
  channel_tap2_madd_add_out_inst_sum_3 : X_XOR2
    port map (
      I0 => channel_tap2_madd_add_out_inst_cy_2,
      I1 => channel_tap2_madd_add_out_inst_lut2_3,
      O => channel_t_res_out2(3)
    );
  channel_tap3_madd_add_out_inst_lut2_51 : X_LUT2
    generic map(
      INIT => X"9"
    )
    port map (
      ADR0 => channel_t_res_out2(5),
      ADR1 => channel_tap2_dout(7),
      O => channel_tap3_madd_add_out_inst_lut2_5
    );
  xout_6_obuf_15 : X_BUF
    port map (
      I => xout_6_obuf,
      O => xout_6_obuf_GTS_TRI
    );
  channel_tap3_madd_add_out_inst_sum_3 : X_XOR2
    port map (
      I0 => channel_tap3_madd_add_out_inst_cy_2,
      I1 => channel_tap3_madd_add_out_inst_lut2_3,
      O => xout_3_obuf
    );
  channel_tap1_dout_7 : X_FF
    port map (
      I => data_7_Q,
      CLK => clock_bufgp,
      O => channel_tap1_dout(7),
      CE => VCC,
      SET => GND,
      RST => GSR
    );
  channel_tap2_madd_add_out_inst_lut2_61 : X_LUT2
    generic map(
      INIT => X"6"
    )
    port map (
      ADR0 => channel_tap2_mul_res(2),
      ADR1 => data_7_Q,
      O => channel_tap2_madd_add_out_inst_lut2_6
    );
  dxout_7_obuf : X_BUF
    port map (
      I => channel_tap3_dout(7),
      O => dxout_7_obuf_GTS_TRI
    );
  xout_2_obuf_16 : X_BUF
    port map (
      I => xout_2_obuf,
      O => xout_2_obuf_GTS_TRI
    );
  xout_4_obuf_17 : X_BUF
    port map (
      I => xout_4_obuf,
      O => xout_4_obuf_GTS_TRI
    );
  channel_tap2_madd_add_out_inst_sum_7 : X_XOR2
    port map (
      I0 => channel_tap2_madd_add_out_inst_cy_6,
      I1 => channel_tap2_madd_add_out_inst_lut2_5,
      O => channel_t_res_out2(7)
    );
  channel_tap2_madd_add_out_inst_cy_4_18 : X_MUX2
    port map (
      IA => channel_tap1_dout(7),
      IB => channel_tap2_madd_add_out_inst_cy_3,
      SEL => channel_tap2_madd_add_out_inst_lut2_4,
      O => channel_tap2_madd_add_out_inst_cy_4
    );
  channel_tap2_madd_add_out_inst_sum_2 : X_XOR2
    port map (
      I0 => channel_tap2_madd_add_out_inst_cy_1,
      I1 => channel_tap2_madd_add_out_inst_lut2_2,
      O => channel_t_res_out2(2)
    );
  channel_tap3_madd_add_out_inst_cy_3_19 : X_MUX2
    port map (
      IA => channel_t_res_out2(3),
      IB => channel_tap3_madd_add_out_inst_cy_2,
      SEL => channel_tap3_madd_add_out_inst_lut2_3,
      O => channel_tap3_madd_add_out_inst_cy_3
    );
  dxout_1_obuf : X_BUF
    port map (
      I => channel_tap3_dout(7),
      O => dxout_1_obuf_GTS_TRI
    );
  channel_tap3_madd_add_out_inst_sum_7 : X_XOR2
    port map (
      I0 => channel_tap3_madd_add_out_inst_cy_6,
      I1 => channel_tap3_madd_add_out_inst_lut2_7,
      O => xout_7_obuf
    );
  channel_tap3_madd_add_out_inst_lut2_11 : X_LUT2
    generic map(
      INIT => X"6"
    )
    port map (
      ADR0 => channel_tap2_dout(7),
      ADR1 => data_7_Q,
      O => channel_tap3_madd_add_out_inst_lut2_1
    );
  Q_n0003_22 : X_LUT2
    generic map(
      INIT => X"5"
    )
    port map (
      ADR0 => data_7_Q,
      ADR1 => GND,
      O => Q_n0003_O
    );
  Q_n0003_LUT1_L_BUF : X_BUF
    port map (
      I => Q_n0003_O,
      O => Q_n0003
    );
  clock_bufgp_IBUFG_23 : X_CKBUF
    port map (
      I => clock,
      O => clock_bufgp_IBUFG
    );
  clock_bufgp_BUFG : X_CKBUF
    port map (
      I => clock_bufgp_IBUFG,
      O => clock_bufgp
    );
  dxout_7_obuf_GTS_TRI_24 : X_TRI
    port map (
      I => dxout_7_obuf_GTS_TRI,
      CTL => NlwInverterSignal_dxout_7_obuf_GTS_TRI_CTL,
      O => dxout(7)
    );
  dxout_6_obuf_GTS_TRI_25 : X_TRI
    port map (
      I => dxout_6_obuf_GTS_TRI,
      CTL => NlwInverterSignal_dxout_6_obuf_GTS_TRI_CTL,
      O => dxout(6)
    );
  dxout_5_obuf_GTS_TRI_26 : X_TRI
    port map (
      I => dxout_5_obuf_GTS_TRI,
      CTL => NlwInverterSignal_dxout_5_obuf_GTS_TRI_CTL,
      O => dxout(5)
    );
  dxout_4_obuf_GTS_TRI_27 : X_TRI
    port map (
      I => dxout_4_obuf_GTS_TRI,
      CTL => NlwInverterSignal_dxout_4_obuf_GTS_TRI_CTL,
      O => dxout(4)
    );
  dxout_3_obuf_GTS_TRI_28 : X_TRI
    port map (
      I => dxout_3_obuf_GTS_TRI,
      CTL => NlwInverterSignal_dxout_3_obuf_GTS_TRI_CTL,
      O => dxout(3)
    );
  dxout_2_obuf_GTS_TRI_29 : X_TRI
    port map (
      I => dxout_2_obuf_GTS_TRI,
      CTL => NlwInverterSignal_dxout_2_obuf_GTS_TRI_CTL,
      O => dxout(2)
    );
  dxout_1_obuf_GTS_TRI_30 : X_TRI
    port map (
      I => dxout_1_obuf_GTS_TRI,
      CTL => NlwInverterSignal_dxout_1_obuf_GTS_TRI_CTL,
      O => dxout(1)
    );
  dxout_0_obuf_GTS_TRI_31 : X_TRI
    port map (
      I => dxout_0_obuf_GTS_TRI,
      CTL => NlwInverterSignal_dxout_0_obuf_GTS_TRI_CTL,
      O => dxout(0)
    );
  xout_7_obuf_GTS_TRI_32 : X_TRI
    port map (
      I => xout_7_obuf_GTS_TRI,
      CTL => NlwInverterSignal_xout_7_obuf_GTS_TRI_CTL,
      O => xout(7)
    );
  xout_6_obuf_GTS_TRI_33 : X_TRI
    port map (
      I => xout_6_obuf_GTS_TRI,
      CTL => NlwInverterSignal_xout_6_obuf_GTS_TRI_CTL,
      O => xout(6)
    );
  xout_5_obuf_GTS_TRI_34 : X_TRI
    port map (
      I => xout_5_obuf_GTS_TRI,
      CTL => NlwInverterSignal_xout_5_obuf_GTS_TRI_CTL,
      O => xout(5)
    );
  xout_4_obuf_GTS_TRI_35 : X_TRI
    port map (
      I => xout_4_obuf_GTS_TRI,
      CTL => NlwInverterSignal_xout_4_obuf_GTS_TRI_CTL,
      O => xout(4)
    );
  xout_3_obuf_GTS_TRI_36 : X_TRI
    port map (
      I => xout_3_obuf_GTS_TRI,
      CTL => NlwInverterSignal_xout_3_obuf_GTS_TRI_CTL,
      O => xout(3)
    );
  xout_2_obuf_GTS_TRI_37 : X_TRI
    port map (
      I => xout_2_obuf_GTS_TRI,
      CTL => NlwInverterSignal_xout_2_obuf_GTS_TRI_CTL,
      O => xout(2)
    );
  xout_1_obuf_GTS_TRI_38 : X_TRI
    port map (
      I => xout_1_obuf_GTS_TRI,
      CTL => NlwInverterSignal_xout_1_obuf_GTS_TRI_CTL,
      O => xout(1)
    );
  xout_0_obuf_GTS_TRI_39 : X_TRI
    port map (
      I => xout_0_obuf_GTS_TRI,
      CTL => NlwInverterSignal_xout_0_obuf_GTS_TRI_CTL,
      O => xout(0)
    );
  NlwBlock_data_gen_VCC : X_ONE
    port map (
      O => VCC
    );
  NlwBlock_data_gen_GND : X_ZERO
    port map (
      O => GND
    );
  NlwInverterBlock_dxout_7_obuf_GTS_TRI_CTL : X_INV
    port map (
      I => GTS,
      O => NlwInverterSignal_dxout_7_obuf_GTS_TRI_CTL
    );
  NlwInverterBlock_dxout_6_obuf_GTS_TRI_CTL : X_INV
    port map (
      I => GTS,
      O => NlwInverterSignal_dxout_6_obuf_GTS_TRI_CTL
    );
  NlwInverterBlock_dxout_5_obuf_GTS_TRI_CTL : X_INV
    port map (
      I => GTS,
      O => NlwInverterSignal_dxout_5_obuf_GTS_TRI_CTL
    );
  NlwInverterBlock_dxout_4_obuf_GTS_TRI_CTL : X_INV
    port map (
      I => GTS,
      O => NlwInverterSignal_dxout_4_obuf_GTS_TRI_CTL
    );
  NlwInverterBlock_dxout_3_obuf_GTS_TRI_CTL : X_INV
    port map (
      I => GTS,
      O => NlwInverterSignal_dxout_3_obuf_GTS_TRI_CTL
    );
  NlwInverterBlock_dxout_2_obuf_GTS_TRI_CTL : X_INV
    port map (
      I => GTS,
      O => NlwInverterSignal_dxout_2_obuf_GTS_TRI_CTL
    );
  NlwInverterBlock_dxout_1_obuf_GTS_TRI_CTL : X_INV
    port map (
      I => GTS,
      O => NlwInverterSignal_dxout_1_obuf_GTS_TRI_CTL
    );
  NlwInverterBlock_dxout_0_obuf_GTS_TRI_CTL : X_INV
    port map (
      I => GTS,
      O => NlwInverterSignal_dxout_0_obuf_GTS_TRI_CTL
    );
  NlwInverterBlock_xout_7_obuf_GTS_TRI_CTL : X_INV
    port map (
      I => GTS,
      O => NlwInverterSignal_xout_7_obuf_GTS_TRI_CTL
    );
  NlwInverterBlock_xout_6_obuf_GTS_TRI_CTL : X_INV
    port map (
      I => GTS,
      O => NlwInverterSignal_xout_6_obuf_GTS_TRI_CTL
    );
  NlwInverterBlock_xout_5_obuf_GTS_TRI_CTL : X_INV
    port map (
      I => GTS,
      O => NlwInverterSignal_xout_5_obuf_GTS_TRI_CTL
    );
  NlwInverterBlock_xout_4_obuf_GTS_TRI_CTL : X_INV
    port map (
      I => GTS,
      O => NlwInverterSignal_xout_4_obuf_GTS_TRI_CTL
    );
  NlwInverterBlock_xout_3_obuf_GTS_TRI_CTL : X_INV
    port map (
      I => GTS,
      O => NlwInverterSignal_xout_3_obuf_GTS_TRI_CTL
    );
  NlwInverterBlock_xout_2_obuf_GTS_TRI_CTL : X_INV
    port map (
      I => GTS,
      O => NlwInverterSignal_xout_2_obuf_GTS_TRI_CTL
    );
  NlwInverterBlock_xout_1_obuf_GTS_TRI_CTL : X_INV
    port map (
      I => GTS,
      O => NlwInverterSignal_xout_1_obuf_GTS_TRI_CTL
    );
  NlwInverterBlock_xout_0_obuf_GTS_TRI_CTL : X_INV
    port map (
      I => GTS,
      O => NlwInverterSignal_xout_0_obuf_GTS_TRI_CTL
    );
  NlwBlockROC : ROC generic map ( WIDTH => 100 ns)
     port map (O => GSR);
  NlwBlockTOC : TOC     port map (O => GTS);
end Structure;

