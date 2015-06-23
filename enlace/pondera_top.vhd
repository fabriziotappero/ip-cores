library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

--  Uncomment the following lines to use the declarations that are
--  provided for instantiating Xilinx primitive components.
--library UNISIM;
--use UNISIM.VComponents.all;

entity pondera_top is
	port(
		clk: 	in std_logic;
		reset:	in std_logic;
		bin_HL:	in std_logic_vector(7 downto 0);
		new_data:	in std_logic;
		trama_ok: in std_logic;	
		bin:		out std_logic_vector(7 downto 0);
		bin_ok:	out std_logic
	);
end pondera_top;


architecture Behavioral of pondera_top is

signal Sdata_H :std_logic_vector(7 downto 0):=(others=>'0'); 
signal Sdata_L :std_logic_vector(7 downto 0):=(others=>'0'); 

--Insert the following in the architecture before the begin keyword
   --Use descriptive names for the states, like st1_reset, st2_search
   type state_type is (st1_espera, st2_data_H, st3_data_L, st4_calculo); 
   signal state, next_state : state_type; 
   --Declare internal signals for all outputs of the state machine
   signal Sbin_ok: std_logic:='0';
begin

-- This is a sample state machine using enumerated types.
-- This will allow the synthesis tool to select the appropriate
-- encoding style and will make the code more readable.
 

   --other outputs
 
--Insert the following in the architecture after the begin keyword
   SYNC_PROC: process (clk, reset)
   begin
      if (reset='1') then
         state <= st1_espera;
      elsif (clk'event and clk = '1') then
         state <= next_state;
         --bin <= Sbin;
	    bin_ok <= Sbin_ok;
         -- assign other outputs to internal signals"        
      end if;
   end process;
 
   --MOORE State Machine - Outputs based on state only
   OUTPUT_DECODE: process (state)
   begin
      --insert statements to decode internal output signals
      --below is simple example
      if state = st1_espera then
		Sbin_ok <= '0';
      end if;

      if state = st2_data_H  then
         Sdata_H <= bin_HL; --almacena el primer dato en una señal para ser ponderada
	 end if;
	 
	 if state = st3_data_L  then
	 	Sdata_L <= bin_HL; --almacena el segundo dato en una señal para ser ponderada
	 end if;

	 if state = st4_calculo then
	 	bin <= Sdata_H(3 downto 0)&"0000" + Sdata_L;
		Sbin_ok <= '1';
	 end if;		   
   end process;
 
   NEXT_STATE_DECODE: process (state, new_data)
   begin
      --declare default state for next_state to avoid latches
      next_state <= state;  --default is to stay in current state
      --insert statements to decode next_state
      --below is a simple example
      case (state) is
	    when st1_espera =>
			if new_data = '1' and trama_ok = '1' then
				next_state <= st2_data_H;					    		
			end if;
	    when st2_data_H =>
         		if new_data = '1' then
               	next_state <= st3_data_L;
            	end if;
         when st3_data_L=>
               next_state <= st4_calculo;
         when st4_calculo =>
            	next_state <= st1_espera;
         when others =>
            	next_state <= st1_espera;
      end case;      
   end process;

end Behavioral;
