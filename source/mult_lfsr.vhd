library IEEE;
USE ieee.std_logic_1164.ALL;
--USE IEEE.std_logic_arith.all;
--use IEEE.NUMERIC_STD.ALL;
--use IEEE.STD_LOGIC_UNSIGNED.ALL;
entity mult_lfsr is		
    port (clock_top : in std_logic;
	  reset_top : in std_logic;
	  sel_top   : in std_logic;
	  X_top     : in std_logic_vector(31 DOWNTO 0);
     Y_top     : in std_logic_vector(31 DOWNTO 0);
     Hi_to_out : out STD_LOGIC_VECTOR (31 downto 0);
     Lo_to_out : out STD_LOGIC_VECTOR (31 downto 0);
	  pass      : out std_logic
	);
end mult_lfsr;      


architecture Stractural of mult_lfsr is

component mult_32x32
  PORT
    (
     X :IN STD_LOGIC_VECTOR(31 DOWNTO 0);
     Y :IN STD_LOGIC_VECTOR(31 DOWNTO 0);
     P :OUT STD_LOGIC_VECTOR(63 DOWNTO 0)
     );
END component;


component LFSR
  port 	( clock: in std_logic;
	  reset: in std_logic;
	  sel_top   : in std_logic;
	  data_out: out std_logic_vector(63 downto 0)
	);
end component;


component mux32
    Port ( A : in std_logic_vector(31 downto 0);
           B : in std_logic_vector(31 downto 0);
           SEL : in std_logic;
           MUX_OUT : out std_logic_vector(31 downto 0));
end component;

component misr is
port (
  clock    : in std_logic;
  reset    : in std_logic;
  sel_top   : in std_logic;
  data_in   : in std_logic_vector(63 downto 0);
  pass      : out std_logic
);
end component;
Signal data_out_signal,P_temp,seed_top : std_logic_vector(63 downto 0);
Signal X_signal : std_logic_vector(31 downto 0);
Signal Y_signal : std_logic_vector(31 downto 0);
     

begin

u1: lfsr port map (clock=>clock_top,reset=>reset_top,sel_top=>sel_top,data_out=>data_out_signal);
u2: mux32 port map (A=>X_top,B=>data_out_signal(63 downto 32),SEL=>sel_top,MUX_OUT=>X_signal);
u3: mux32 port map (A=>Y_top,B=>data_out_signal(31 downto 0),SEL=>sel_top,MUX_OUT=>Y_signal);
u4: mult_32x32 port map (X=>X_signal,Y=>Y_signal,P=>P_temp);
u5: misr port map (clock=>clock_top,reset=>reset_top,sel_top=>sel_top,data_in=>P_temp,pass=>pass);
  
Hi_to_out <= P_temp(63 downto 32);
Lo_to_out <= P_temp(31 downto 0);


end Stractural;  

