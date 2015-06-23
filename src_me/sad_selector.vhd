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
--------------------------------------
--  entity       = sad_selector     --
--  version      = 1.0              --
--  last update  = 30/12/07         --
--  author       = Jose Nunez       --
--------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned."<";
use IEEE.std_logic_unsigned."+";
use IEEE.Numeric_STD.all;
use work.config.all;

entity sad_selector is
generic (integer_pipeline_count : integer);
port (
      clk : in std_logic;
	reset : in std_logic;
	clear : in std_logic;
      calculate_sad_done : in std_logic;
	active_pipelines : in std_logic_vector(CFG_PIPELINE_COUNT-1 downto 0);
      update : in std_logic; --end of program
	update_fp : in std_logic; -- end of iteraction
	best_eu : out std_logic_vector(3 downto 0);
	best_sad : in std_logic_vector(15 downto 0);
	best_mv : in std_logic_vector(15 downto 0);
      rest_best_sad : in rest_type_displacement;
	rest_best_mv : in rest_type_displacement;
	best_sad_out : out std_logic_vector(15 downto 0);
	best_mv_out : out std_logic_vector(15 downto 0));
end sad_selector;

architecture behavioral of sad_selector is

type eu_id_type is array(CFG_PIPELINE_COUNT-1 downto 0) of std_logic_vector(3 downto 0); -- max number of integer eu is 15
-- zero identifies when there is no winner
type active_pipelines_type is array(5 downto 0) of std_logic_vector(CFG_PIPELINE_COUNT-1 downto 0);

type state_register_type is record
   best_sad_candidate : std_logic_vector(15 downto 0); -- found sad for the best mv
   best_sad : std_logic_vector(15 downto 0); -- stored sad for the best mv
   best_mv  : std_logic_vector(15 downto 0); -- mv associated to best sad
   best_eu : std_logic_vector(3 downto 0);
   eu_id : eu_id_type; -- keep track of the winning eu
   active_pipelines_r : active_pipelines_type; -- reproduce pipeline effects
   calculate_sad_done_int : std_logic; -- pipeline for performance

end record;

signal r, r_in: state_register_type; -- state register
    
begin
    
    selection : process(best_sad,best_mv,rest_best_sad,rest_best_mv,update,calculate_sad_done,update_fp)
    variable vbest_sad_fp,vbest_mv_fp : std_logic_vector(15 downto 0);
    variable v : state_register_type; -- state register
    variable veu_id : std_logic_vector(3 downto 0); -- execution unit identifier 
  
	begin
      
      vbest_sad_fp := best_sad;
      vbest_mv_fp := best_mv;
	veu_id := r.eu_id(0); 
	   v := r;      

    for i in 1 to (integer_pipeline_count-1) loop
 	 if (v.active_pipelines_r(5)(i) = '1') then
          if rest_best_sad(i) < vbest_sad_fp then
              vbest_sad_fp := rest_best_sad(i);
              vbest_mv_fp := rest_best_mv(i);
		  veu_id := r.eu_id(i);
          end if;
	  end if;
      end loop;

   v.best_sad_candidate := vbest_sad_fp;




   v.active_pipelines_r(5) := v.active_pipelines_r(4);
   v.active_pipelines_r(4) := v.active_pipelines_r(3);
   v.active_pipelines_r(3) := v.active_pipelines_r(2);
   v.active_pipelines_r(2) := v.active_pipelines_r(1);
   v.active_pipelines_r(1) := v.active_pipelines_r(0);
   v.active_pipelines_r(0) := active_pipelines; -- pipeline effect




  if (r.best_sad_candidate < r.best_sad and v.calculate_sad_done_int = '1') then
			v.best_sad := r.best_sad_candidate;
   			v.best_mv := vbest_mv_fp;
   			v.best_eu := veu_id;
			best_sad_out <= r.best_sad_candidate;
			best_mv_out <= vbest_mv_fp;
			best_eu <= veu_id;
   else
	      	best_sad_out <= r.best_sad;
			best_mv_out <= r.best_mv;
			best_eu <= r.best_eu;
   end if;
    

   if (update = '1') then
      v.best_sad := x"FFFF"; --new program new max value
    elsif (update_fp = '1') then --iteraction completes
		for i in 0 to (CFG_PIPELINE_COUNT-1) loop
			v.eu_id(i) := std_logic_vector(to_unsigned((i+1),4));
		end loop; 
		v.best_eu := (others => '0');
   elsif (v.calculate_sad_done_int = '1') then
  	 	   for i in 0 to (CFG_PIPELINE_COUNT-1) loop
			v.eu_id(i) := v.eu_id(i)+CFG_PIPELINE_COUNT;
			end loop;		

    end if;

   v.calculate_sad_done_int := calculate_sad_done;

   r_in <= v;
   
  end process;


regs : process(clk,clear)

begin

 if (clear = '1') then
	r.best_sad <= x"FFFF"; -- start with the highest value
   	r.best_sad_candidate <= (others => '0');
	r.best_mv <= (others => '0');
	r.best_eu <= (others => '0');
	for i in 0 to 5 loop
		r.active_pipelines_r(i) <= (others => '0');
	end loop;
	for i in 0 to (CFG_PIPELINE_COUNT-1) loop
		r.eu_id(i) <= std_logic_vector(to_unsigned((i+1),4));
	end loop; 
      r.calculate_sad_done_int <= '0';
 elsif rising_edge(clk) then 
		if (reset = '1') then -- general enable
	         r.best_sad <= x"FFFF"; -- start with the highest value
   	   	   r.best_sad_candidate <= (others => '0');
	         r.best_mv <= (others => '0');
		   r.best_eu <= (others => '0');
		   for i in 0 to 5 loop
			r.active_pipelines_r(i) <= (others => '0');
		   end loop;
	    	   for i in 0 to (CFG_PIPELINE_COUNT-1) loop
			r.eu_id(i) <= std_logic_vector(to_unsigned((i+1),4));
		   end loop; 
 		   r.calculate_sad_done_int <= '0';
	     	else
			 r <= r_in;
		end if;
 end if;


end process regs; 
  
end  behavioral;
      
        