library ieee;
use ieee.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;

entity serirq is
	port (
		clock : in std_logic;
		reset_n : in std_logic;
		slot_sel : in std_logic_vector(4 downto 0); --clk no of IRQ defined in Ser irq for PCI systems spec.
		serirq : inout std_logic;
		irq : in std_logic		
	);
end entity serirq;

architecture RTL of serirq is
	
	type reg_type is
	record
		irq_idle  :  boolean; --idle mode only host can start irq cycles quiet mode is entered by 2 clock stop, 3 clock stop keeps or enters idle mode 
		irq_frame :  boolean; --currently in running irq frame  
		serirq_oe : std_logic; --oe does pulldown
		low_count : std_logic_vector(3 downto 0);
		slot_count : std_logic_vector(7 downto 0);
		irq_count : std_logic_vector(3 downto 0); --wait before irq auto issue
		
		irq_sync   : std_logic; --sync stage
	end record;
		
	signal reg, reg_in : reg_type;
	signal comb_oe : std_logic;
	
	
begin
	
	serirq<='0' when comb_oe='1' else
			'Z';
	
	
	-- Design pattern process 1 Implementation 
	comb : process (serirq,slot_sel,irq,reg)
			variable reg_v : reg_type;
		begin
			-- Design pattern 
			reg_v:=reg; --pre set default var state
			------------------------------------
			---  <implementation>			---
			------------------------------------
			reg_v.irq_sync:=irq;
			--clear signel cycle oe
			reg_v.serirq_oe:='0'; --disable pulldown (this can never be longer than 1 cycle)
			
			--Frame start contition wait
			if reg_v.irq_idle and not reg_v.irq_frame then	-- Idle mode wait for host to start
				if serirq='0' then -- count low cycles
					reg_v.low_count:=reg_v.low_count + 1;
				else -- see if the event is a start frame event
					if reg_v.low_count>"0011" then -- cycle start
						reg_v.irq_frame:=true;
					end if;
					reg_v.low_count:=(others=>'0');
				end if;
			elsif not reg_v.irq_idle and not reg_v.irq_frame and reg.irq_sync='1' then 	-- in active mode we can start the irq frame
				if reg_v.irq_count>"0010" then
					reg_v.serirq_oe:='1'; --enable pulldonw
					reg_v.irq_frame:=true; -- frame should start
				else
					reg_v.irq_count:=reg_v.irq_count + 1;
				end if;
			else -- in frame
				reg_v.irq_count:=(others=>'0');  --
			end if;
			
			--In IRQ frame
			if reg_v.irq_frame and reg_v.slot_count<x"FF" then  --don't allow cnt overflow for slots
				reg_v.slot_count:=reg_v.slot_count + 1;
			else
				reg_v.slot_count:=(others=>'0'); --reset when out of frame
			end if;
			
			--Slot sel must use register value as it is incremented above in the variable for next cycle
			if reg_v.irq_frame and slot_sel/="00000" and reg.slot_count(7 downto 0)="000"&slot_sel and reg.irq_sync='1' then --when slot and irq active to pull on the serirq
				reg_v.serirq_oe:='1'; --enable pulldonw
			end if;
				
			-- End irq frame and enter idle or active mode
			if reg_v.irq_frame then
				if serirq='0' then -- count low cycles
					reg_v.low_count:=reg_v.low_count + 1;
				else -- see type of stop frame frame event
					if reg_v.low_count=x"2" then
						reg_v.irq_frame:=false;
						reg_v.irq_idle:=false; --enter active mode 
					elsif reg_v.low_count>x"2" then
						reg_v.irq_idle:=true; --enter idle mode 
						reg_v.irq_frame:=false;																		
					end if;
					reg_v.low_count:=(others=>'0');
				end if;								
			end if;
			
			-- Design pattern 
			-- drive register input signals
			reg_in<=reg_v;
			-- drive module outputs signals
			--port_comb_out<= reg_v.port_comb;  --combinatorial output example
			--port_reg_out<= reg.port_reg; --registered output example
			comb_oe<=reg_v.serirq_oe; --cominatorial out
		end process;

	-- Pattern process 2, Registers
	regs : process (clock,reset_n)
		begin
			if reset_n='0' then
				reg.irq_idle<=true; -- start up in idle mode
				reg.irq_frame<=false; --start up out of irq frame
				reg.slot_count<=(others=>'0');
				reg.low_count<=(others=>'0');
				reg.irq_count<=(others=>'0');
				reg.irq_sync<='0';
				reg.serirq_oe<='0'; -- on reset all agents enter tristated mode
			elsif rising_edge(clock) then
				reg<=reg_in;
			end if;
		end process;
			

end architecture RTL;
