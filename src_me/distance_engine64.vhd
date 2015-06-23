----------------------------------------------------------------------------
--  This file is a part of the LM VHDL IP LIBRARY
--  Copyright (C) 2009 Jose Nunez-Yanez
--
--  This program is free software; you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published by
--  the Free Software Foundation; either version 2 of the License, or
--  (at your option) any later version.
--
--  See the file COPYING for the full details of the license.
--
--  The license allows free and unlimited use of the library and tools for research and education purposes. 
--  The full LM core supports many more advanced motion estimation features and it is available under a 
--  low-cost commercial license. See the readme file to learn more or contact us at 
--  eejlny@byacom.co.uk or www.byacom.co.uk
-----------------------------------------------------------------------------
-- Entity: 	register_file
-- File:	register_file.vhd
-- Author:	Jose Luis Nunez 
-- Description:	register file that holds the command and the first mv
------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.Numeric_STD.all;
use IEEE.std_logic_unsigned."-";
use IEEE.std_logic_unsigned."+";
use IEEE.std_logic_arith."abs";
use work.config.all;


entity distance_engine64 is
   generic( qp_mode : std_logic := '0');
	port(
	clk : in std_logic;
	clear : in std_logic;
	reset : in std_logic;
	enable : in std_logic;
	update : in std_logic;
	load_mv : in std_logic;
	mv_cost_on : in std_logic;
	mode_in : in mode_type;
      mv_cost_in : in std_logic_vector(15 downto 0);
	candidate_mvx : in std_logic_vector(7 downto 0);
	candidate_mvy : in std_logic_vector(7 downto 0);
	reference_data_in : in std_logic_vector(63 downto 0);
	residue_out : out std_logic_vector(63 downto 0);
	enable_fifo : out std_logic;
	reset_fifo : out std_logic;
	winner1 : out std_logic;
	calculate_sad_done : out std_logic; 
	distance_engine_active : out std_logic;
	current_data_in : in std_logic_vector(63 downto 0);
   best_sad : out std_logic_vector(15 downto 0);
   best_mv : out std_logic_vector(15 downto 0));
end;

architecture behav of distance_engine64 is


type state_type is (idle,calculate_sad,select_mv,wait_for_sad); -- dist engine control unit states

type state_register_type is record
   enable_fifo : std_logic; -- enable the residue fifo
   winner1 : std_logic; -- winner flag controls residue store in block1 or 2
	state : state_type;
   current_sad : std_logic_vector(15 downto 0); -- stored partial and current sad
 --  current_mv : std_logic_vector(15 downto 0); -- stored the future motion vector to be evaluated
   current_mv2 : std_logic_vector(15 downto 0); -- stored the current motion vector being evaluated
   pipeline_cm : std_logic_vector(63 downto 0); -- pipeline for cm register directly from memory
   pipeline_rm : std_logic_vector(63 downto 0); -- pipeline for rm register directly from memory
   pipeline : std_logic_vector(63 downto 0); -- pipeline register
end record;

signal r, r_in: state_register_type; -- state register


--signal sad_value_out, sad_value_in : std_logic_vector(15 downto 0);

begin
    
    
residue_out <= r.pipeline; -- write the residue to FIFOs
r_in.enable_fifo <= '1' when r.state = calculate_sad else '0';
r_in.pipeline_cm <= current_data_in;
r_in.pipeline_rm <= reference_data_in;
enable_fifo <= r.enable_fifo;
--reset_fifo <= '1' when r.state = memory_read else '0'; -- empty the fifo before start writing to it

tree_process : process(r)

variable vpipeline : std_logic_vector(63 downto 0);
variable vsad_value : std_logic_vector(15 downto 0);

begin
    
   vpipeline := r.pipeline;
   vsad_value := r.current_sad;
   
   if (r.state = calculate_sad or r.state = wait_for_sad) then
   --if (r.state /= idle) then
    
      for i in 8 downto 1 loop
            vsad_value := vsad_value + (x"00" & vpipeline((8*i-1) downto (8*i-8)));
   	  end loop;
   elsif (qp_mode = '0') then
      vsad_value := (others => '0');
   elsif (r.state  = idle) then
      vsad_value := (others => '0');
   end if;

   r_in.current_sad <= vsad_value;

end process tree_process;


sad_process : process(r)

variable vpipeline : std_logic_vector(71 downto 0); -- 8 extra bits to accomodate signs
--variable vpipeline2 : std_logic_vector(63 downto 0);


begin
    
     if (r.state = idle) then
		vpipeline := (others => '0');
     elsif (r.state = select_mv and qp_mode = '1') then
		vpipeline := (others => '0');
	else
    
         for i in 8 downto 1 loop
            --vpipeline1((8*i-1) downto (8*i-8)) := signed(reference_data_in((8*i-1) downto (8*i-8)) - current_data_in((8*i-1) downto (8*i-8)));
            vpipeline((9*i-1) downto (9*i-9)) := std_logic_vector(ABS(signed(("0" & r.pipeline_rm((8*i-1) downto (8*i-8))) - ("0" & r.pipeline_cm((8*i-1) downto (8*i-8))))));
            --vpipeline((9*i-1) downto (9*i-9)) := std_logic_vector(ABS(signed(("0" & reference_data_in((8*i-1) downto (8*i-8))) - ("0" & current_data_in((8*i-1) downto (8*i-8))))));

         end loop;
     
  
     end if;
 
   for i in 8 downto 1 loop
      r_in.pipeline((8*i-1) downto (8*i-8)) <= vpipeline((9*i-2) downto (9*i-9));
   end loop;
   
end process sad_process;


sad_control : process(r,enable,load_mv,update,candidate_mvx,candidate_mvy,mode_in)
variable vcalculate_sad_done,vdistance_engine_active : std_logic;
variable v : state_register_type;
begin
    
   vdistance_engine_active := '0';
   v.state := r.state;
   v.winner1 := r.winner1;
   vcalculate_sad_done := '0';
  -- v.current_mv := r.current_mv;
   v.current_mv2 := r.current_mv2;


   
   case v.state is

	   when idle =>  -- first state, waiting for enable signal
		   if (enable = '1') then
			   v.state := calculate_sad;
		   end if;	
	when calculate_sad => -- read and evaluate sad 
		  vdistance_engine_active := '1';
              if (enable = '0') then -- wait for sad
		      	v.state := wait_for_sad;	
		   end if;
       when wait_for_sad => 
		vdistance_engine_active := '1';
		v.state := select_mv;
	when select_mv => -- select best mv
		vdistance_engine_active := '1';
	      --v.current_mv := (others => '0'); -- clear in preparation for new calculation
		if (qp_mode = '0') then
			vcalculate_sad_done := '1';
	      end if;
		if (enable = '0') then 
			if (qp_mode = '1') then
				vcalculate_sad_done := '1';
	      	end if;
			v.state := idle;
		else
			--vcalculate_sad_done := '1';
			v.state := calculate_sad;
            end if;
	   when others => null;
	end case;

 --  if (enable = '1') then
--	v.current_mv2 := v.current_mv;
 --  end if;

   if (load_mv = '1') then    
--	v.current_mv2 := v.current_mv;  
      v.current_mv2 := candidate_mvx & candidate_mvy;
   end if;	
	

	
r_in.state <= v.state;
--r_in.current_mv <= v.current_mv;
r_in.current_mv2 <= v.current_mv2;
r_in.winner1 <= v.winner1;
calculate_sad_done <= vcalculate_sad_done;
distance_engine_active <= vdistance_engine_active;
    
end process sad_control;


best_sad <= (r.current_sad + mv_cost_in) when mv_cost_on = '1' else r.current_sad;
best_mv <= r.current_mv2;
winner1 <= r.winner1;

regs : process(clk,clear)

begin

 if (clear = '1') then
   r.enable_fifo <= '0';
   r.winner1 <= '0';
	r.state <= idle;
	r.current_sad <= (others => '0');
	r.pipeline <= (others => '0');
	r.pipeline_cm <= (others => '0');
	r.pipeline_rm <= (others => '0');
	--r.current_mv <= (others => '0');
	r.current_mv2 <= (others => '0');
 elsif rising_edge(clk) then 
		if (reset = '1') then -- general enable
		      r.enable_fifo <= '0';
		      r.winner1 <= '0';
			 	r.state <= idle;
	         r.current_sad <= (others => '0');
	         r.pipeline <= (others => '0');
	         r.pipeline_cm <= (others => '0');
	         r.pipeline_rm <= (others => '0');
	         --r.current_mv <= (others => '0');
	         r.current_mv2 <= (others => '0');
		else
			 r <= r_in;
		end if;
 end if;


end process regs; 


end behav;
