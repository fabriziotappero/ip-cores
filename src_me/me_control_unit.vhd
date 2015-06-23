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
--  entity       = me_control_unit  --
--  version      = 1.0              --
--  last update  = 20/07/09         --
--  author       = Jose Nunez       --
--------------------------------------


-- main control unit for the motion estimation process

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned."+";
use IEEE.std_logic_unsigned."-";
use IEEE.std_logic_unsigned."=";
use IEEE.std_logic_unsigned.">";
use IEEE.std_logic_unsigned."<";
use IEEE.std_logic_unsigned.">=";
use IEEE.Numeric_STD.all;
use work.config.all;


entity me_control_unit is
generic ( integer_pipeline_count : integer := 1);
 port ( clk : in std_logic;
        clear : in std_logic;
        reset : in std_logic;
        start : in std_logic;
        range_ok : in std_logic; --keep track of the mv range
	  best_sad_in : in std_logic_vector(15 downto 0); -- to make SAD-based decisions
	  mv_length_in : in std_logic_vector(15 downto 0); -- to make LENGTH-based decisions
        mode_in : in mode_type;
 	     qp_on : in std_logic; -- qp on
 	  mvc_done : in std_logic; -- all motion vector candidates evaluated
	  mvc_to_do : in std_logic_vector(3 downto 0);
        partition_count_out : out std_logic_vector(3 downto 0); --identify the partition active
	  start_pipelines : out std_logic_vector((integer_pipeline_count-1) downto 0);
	  active_pipelines : out std_logic_vector((integer_pipeline_count-1) downto 0); -- so sad selector ignores the non active ones
        shift_concatenate_valid : in std_logic; -- valid output from the concantenate unit 
        interpolation_done : in std_logic; -- interpolation completes
        interpolate_data_request : in std_logic; -- interpolator requests data
        instruction_address : out std_logic_vector(7 downto 0); -- address to fetch next instruction
	  instruction_opcode : in std_logic_vector(3 downto 0); -- opcode
        point_count : in std_logic_vector(7 downto 0); -- how many points to test
        point_address : in std_logic_vector(7 downto 0); -- which is the first point to test
        calculate_sad_done : in std_logic; -- signals when the distance engine has finished
	  distance_engine_active : in std_logic; -- signals when distance engine is not running
        next_point : out std_logic_vector(7 downto 0); -- next point address to ROM
        line_offset : out std_logic_vector(5 downto 0); -- multiple line reading
	  enable_concatenate_unit : out std_logic;
	    -- enable_dist_engine : out std_logic;
        write_register : out std_logic;
	   best_eu : in std_logic_vector(3 downto 0); -- best execution unit
        load_mv : out std_logic;
        update : out std_logic;
	  instruction_zero : out std_logic; -- program completes after hitting instruction zero points
        all_done : out std_logic; -- fp part completes or program completes
	  partition_done : out std_logic;
        qpel_loc_x : in std_logic_vector(1 downto 0); -- detect qp mode
        qpel_loc_y : in std_logic_vector(1 downto 0);
        start_qp : out std_logic;
        enable_hp_inter : out std_logic; -- start the interpolation core
       --  write_block1 : out std_logic;
      --  next_rm_address_ready : in std_logic;
        next_rm_addresss : in std_logic_vector(13 downto 0); --physical address for reference (macroblock upper left corner 
        rm_address : out std_logic_vector(13 downto 0) -- reference memory read from address
	  --cm_address : out std_logic_vector(4 downto 0);  -- address to extract 4x4 blocks from current macroblock
	--  rma_address : out std_logic_vector(4 downto 0); -- reference macroblock write to address
  --   rma_we : out std_logic
      );
end;  

architecture struct of me_control_unit is



type state_type is (terminate,idle,fetch_instruction,access_point_memory,next_phy_address_ready,update_mv,wait_for_distance_engine,wait_for_distance_engine2,enable_concatenate_2,enable_concatenate,wait_for_phy_address,wait_for_phy_address2); -- me control unit states

type state_register_type is record

	state : state_type;
	partition_count : std_logic_vector(3 downto 0); -- to keep track of the sub-partitions
	best_eu : std_logic_vector(3 downto 0); -- for jump conditions
	  qp_mode : std_logic; -- processing a fraction instruction
      invalidate : std_logic; -- flag to invalidate instructions that follow jumps
	   enable_concatenate_unit : std_logic;
	   data_block : std_logic_vector(1 downto 0); --9 data blocks of 8 rows and 8 pixels for interpolation	 
	   enable_hp_inter : std_logic;
      instruction_address : std_logic_vector(7 downto 0); --counter keeps track of next instruction to execute
      instruction_opcode : std_logic_vector(3 downto 0);
	point_count : std_logic_vector(7 downto 0);  --register stores the number of points to test
	point_address : std_logic_vector(7 downto 0); -- register stores the first address of the points to test	
      points_tested : std_logic_vector(7 downto 0); -- counter that keeps track of the number of points tested
      phy_address : std_logic_vector(13 downto 0); -- address for the reference memory
      phy_address_ready : std_logic_vector(13 downto 0); -- stores a ready copy of the next reference memory address
      --rma_address : std_logic_vector(4 downto 0); -- address for the reference macroblock memory
      line_offset : std_logic_vector(5 downto 0); -- reading of multiple lines control
      line_count : std_logic_vector(4 downto 0); -- counter to keep track of the number of lines loaded in reference macroblock
      interpolation_done : std_logic; -- remember when interpolation has been done so not to do it again
	active_pipelines_r : std_logic_vector((integer_pipeline_count-1) downto 0); 
	condition_bit : std_logic; -- condition bit for jump instructions
  --    calculate_sad_done : std_logic;
      --write_block1 : std_logic; -- flag
end record;

signal r, r_in: state_register_type; -- state register
signal finish : std_logic;


begin
    

--rma_address <= (others => '0'); -- reference macroblock write to address
--cm_address <= (others => '0');  -- address to extract 4x4 blocks from current macroblock
all_done <= finish;

control: process(mvc_done,mvc_to_do,range_ok,instruction_opcode,best_eu,mode_in,r,qpel_loc_x,qpel_loc_y,interpolation_done,interpolate_data_request,start,next_rm_addresss,shift_concatenate_valid,calculate_sad_done,point_address,point_count)

variable v : state_register_type;
variable vfinish,vstart,vrma_we,vload_mv,vupdate,vstart_qp,vpartition_done,vinstruction_zero : std_logic; 
variable vwrite_register,venable_dist_engine : std_logic;
variable vrm_address : std_logic_vector(13 downto 0); -- generate rm address as soon as possible
variable vstart_pipelines : std_logic_vector((integer_pipeline_count-1) downto 0);

begin

--v.calculate_sad_done := calculate_sad_done;
vstart_qp := '0';
vpartition_done := '0';
vfinish := '0';
vinstruction_zero := '0'; --instruction zero points hit
v.qp_mode := r.qp_mode;
v.partition_count := r.partition_count;
v.data_block := r.data_block;
v.invalidate := r.invalidate;
v.best_eu := r.best_eu;
v.points_tested := r.points_tested;
v.instruction_address := r.instruction_address;
v.phy_address_ready := next_rm_addresss;
v.line_offset := r.line_offset;
v.point_count := r.point_count;
v.point_address := r.point_address;
v.phy_address := r.phy_address;
v.line_count := r.line_count;
v.enable_concatenate_unit := r.enable_concatenate_unit;
v.enable_hp_inter := r.enable_hp_inter;
v.instruction_opcode := (others =>'0');
--vnext_rm_address_ready := next_rm_address_ready;
v.state := r.state;
v.interpolation_done := r.interpolation_done;
vstart := start;
vload_mv := '0';
vrma_we := '0';
vupdate := '0';
vwrite_register := '0';
venable_dist_engine := '0';
vrm_address := r.phy_address;
vstart_pipelines :=  (others => '0'); -- all pipelines disable
v.active_pipelines_r := r.active_pipelines_r;
v.condition_bit := r.condition_bit;

-- std_logic_vector(to_unsigned(,integer_pipeline_count));



case v.state is

	when idle =>  -- first state, waiting for command register bit 31 to go high
		if (vstart = '1') then
			v.state := fetch_instruction;
			v.interpolation_done := '0';
			--if (mvc_done = '1') then  -- first evaluate all the mvcs
				v.instruction_address := v.instruction_address + x"01";
			--end if;
		end if;
			
	when fetch_instruction => -- execute instructions in the program firmware memory 
		--v.instruction_address := v.instruction_address + x"01";
		v.point_count := point_count;
      v.point_address := point_address;
		v.instruction_opcode := instruction_opcode;
	      case v.instruction_opcode is
			when "0000" => --full pel pattern instruction
				if (v.invalidate = '0') then
      				if (v.point_count = x"00") then -- finish => all instructions executed
						v.state := terminate;
 						v.instruction_address := (others => '0');
						v.condition_bit := '0'; -- reset condition bit
						--vfinish := '1'; -- clear the state when completing program
					else
						v.state := access_point_memory;	
					end if;		
				else
				    v.invalidate := '0'; -- clear flag
				    v.instruction_address := v.instruction_address + x"01";
				end if;
			when "0001" => -- fractional pel pattern instruction
				if CFG_PIPELINE_COUNT_QP = 1 then
					if (v.invalidate = '0') then
    						v.state := access_point_memory;	
				      		v.qp_mode := '1';	
					else
				    		v.invalidate := '0'; -- clear flag
				    		v.instruction_address := v.instruction_address + x"01";
					end if;
				end if;
			when "0010" => -- condional jump instruction (if best_eu == field A in instruction (point count) jumpp to point_address
			    if (v.best_eu = point_count(3 downto 0)) then
			        v.instruction_address := point_address;
			    	  v.invalidate := '1'; -- invalidate the next instruction so it does not execute
			     else
				  v.instruction_address := v.instruction_address + x"01";
			    	  v.invalidate := '0';
			     end if;
			when "0100" => -- conditional jump to label (if condition bit set jump to label)
			     if (v.condition_bit = '1') then
				  v.instruction_address := point_address;
			    	  v.invalidate := '1'; -- invalidate the next instruction so it does not execute
			     else
				  v.instruction_address := v.instruction_address + x"01";
			    	  v.invalidate := '0';
			     end if;
			     v.condition_bit := '0'; -- reset condition bit
			when "0101" => -- compare (if less than set condition bit)
				 if (point_count(7 downto 6) = "00") then -- reg field
				 	if (best_sad_in < point_count(5 downto 0) & point_address(7 downto 0)) then
				  		v.condition_bit := '1'; -- set condition bit
			     	end if;
				 else
				 	if (mv_length_in(14 downto 7) & mv_length_in(6 downto 0)) < (point_count(5 downto 0) & point_address(7 downto 0)) then
				  		v.condition_bit := '1'; -- set condition bit
			     	end if;
				 end if;
			     v.instruction_address := v.instruction_address + x"01";
			when "0110" => -- compare (if greater than set condition bit)
				 if (point_count(7 downto 6) = "00") then -- reg field
			     	if (best_sad_in > point_count(5 downto 0) & point_address(7 downto 0)) then
				  		v.condition_bit := '1'; -- set condition bit
			     	end if;
				 else
				 	if (mv_length_in(14 downto 7) & mv_length_in(6 downto 0)) > (point_count(5 downto 0) & point_address(7 downto 0)) then
				  		v.condition_bit := '1'; -- set condition bit
			     	end if;
				 end if;
			     v.instruction_address := v.instruction_address + x"01";
			when others => null;
			end case;
			-- unconditional jump
			-- conditional jump if condition bit
			-- compare instruction (less than)
	when access_point_memory => 
		v.enable_concatenate_unit := '0';
		 v.state := wait_for_phy_address;
	      if (r.qp_mode = '0') then   --only use slave fp pipelines if not qp mode
		v.active_pipelines_r(0) := '1';
		vstart_pipelines(0) := '1';
		for i in 1 to integer_pipeline_count-1 loop
						if (v.point_count-v.points_tested > i) then 
							vstart_pipelines(i) := '1';
							v.active_pipelines_r(i) := '1';
						else
							vstart_pipelines(i) := '0';
							v.active_pipelines_r(i) := '0';
                  			end if;
		end loop;
		end if;
	when wait_for_phy_address =>-- waiting for translation to finish
	  if (range_ok = '1')then
	  		v.state := wait_for_phy_address2;
			if CFG_PIPELINE_COUNT_QP = 1 then
	    		if (r.qp_mode = '1' and r.interpolation_done = '0') then -- jump if mvx or mvy qp instruction are qp fractional
		    		v.enable_hp_inter := '1';
		    		v.instruction_address := v.instruction_address + x"FF"; -- -1
		     		--v.qp_mode := '1';
		    		-- v.state := inter_wait_for_phy_address2;
		 		end if;
			end if;
	  else     --bypass point calculation if range is not good
			v.point_address := v.point_address + std_logic_vector(to_unsigned(integer_pipeline_count,8));  -- next point memory position
   	            v.points_tested := v.points_tested + std_logic_vector(to_unsigned(integer_pipeline_count,8)); -- new point ajusted depending of the number of integer pipelines
   	            if (v.points_tested >= r.point_count) then -- current instruction completes
   	                   v.state := wait_for_distance_engine2;
   	                   v.points_tested := (others => '0');
   	            else
   	                   v.state := access_point_memory;  
   	            end if; 
	  end if;
	when wait_for_phy_address2 => -- two cycles to get phy address
		 v.phy_address := next_rm_addresss; -- store phy address in register
		 v.line_offset := v.line_offset + "000001"; -- +1 to increase the y component
		 v.state := next_phy_address_ready;
		-- v.point_address := v.point_address + std_logic_vector(to_unsigned(integer_pipeline_count,8));  -- next 

    
      
    when next_phy_address_ready => -- start accessing reference memory
		v.enable_concatenate_unit := '0';
		v.phy_address := (v.phy_address(13 downto 3) + "00000000001") & next_rm_addresss(2 downto 0); -- plus 1 to read again part of the data (simple alignment)
        v.state := enable_concatenate;

		--v.point_address := v.point_address + std_logic_vector(to_unsigned(integer_pipeline_count,8));  -- next point memory position
		--vload_mv := '1'; -- load mv candidate in distance engine for future use
   	when enable_concatenate => 
   	        v.phy_address := v.phy_address + "00000000001000";
   	        v.enable_concatenate_unit := '1';
   	       -- if (shift_concatenate_valid = '1') then -- first part of line
   	           v.state := enable_concatenate_2;
   	           v.line_offset := v.line_offset + "000001"; -- +1 to increase the y componenent
			if (r.line_count = "01111") then
      			

				v.line_offset := (others => '0');
			end if;
			if (r.line_count = "01110") then
				vload_mv := '1'; -- load mv candidate in distance engine for future use
				v.point_address := v.point_address + std_logic_vector(to_unsigned(integer_pipeline_count,8));  -- next 
			end if;

   	       -- end if;   
   	   when enable_concatenate_2 =>
		--	if (r.line_offset = "10000") then
		--		v.line_offset := (others => '0'); 
		--	end if;
   	    --    v.phy_address := (v.phy_address(13 downto 3) + "00000000010") & "000";
   	      --  v.enable_concatenate_unit := '1';
   	    --    if (shift_concatenate_valid = '1') then -- second part of line
			v.enable_concatenate_unit := '1';
   	            --v.state := enable_interpolate;
   	            v.line_count := v.line_count + "00001";
   	            --vrm_address := next_rm_addresss(12 downto 3) & "000"; -- set to "000" so the first new access does not interfere with the concatenation of the last bytes in the previous access        
   	            vrm_address := r.phy_address_ready;
   	            v.phy_address := next_rm_addresss + "00000000001000"; -- (plus 1 as well?) store phy address in register
		       --v.phy_address := (v.phy_address(11 downto 3) + "000000001") & next_rm_addresss(2 downto 0)
   	            v.state := enable_concatenate; -- next line  
   	      --  end if; 
	     	 if (r.line_count = "01110") then
				v.line_offset := (others => '0'); 
				--v.point_address := v.point_address + std_logic_vector(to_unsigned(integer_pipeline_count,8));  -- next 
			end if;
   	        if (r.line_count = "01111") then -- all the lines done
   	                 --v.enable_concatenate_unit := '0';
   	                --v.point_address := v.point_address + std_logic_vector(to_unsigned(integer_pipeline_count,8));  -- next point memory position
   	                v.points_tested := v.points_tested + std_logic_vector(to_unsigned(integer_pipeline_count,8)); -- new point ajusted depending of the number of integer pipelines
   	                v.line_count := (others=>'0');
		 	    v.phy_address := next_rm_addresss; -- store phy address in register
		          v.line_offset := v.line_offset + "000001"; -- +1 to increase the y component
	                if (v.points_tested >= r.point_count) then -- current instruction completes
   	                   v.state := wait_for_distance_engine;
   	                   v.points_tested := (others => '0');
				 v.line_offset := (others => '0'); 
				-- v.point_address := point_address; -- start accesing point memory earlier
   	                else
   	                   v.state := next_phy_address_ready; -- access should be ready;  
				 if (r.qp_mode = '0') then   --only use slave fp pipelines if not qp mode
					v.active_pipelines_r(0) := '1';
					vstart_pipelines(0) := '1';
					for i in 1 to integer_pipeline_count-1 loop
						if (v.point_count-v.points_tested > i) then
							vstart_pipelines(i) := '1';
							v.active_pipelines_r(i) := '1';
						else
							vstart_pipelines(i) := '0';
							v.active_pipelines_r(i) := '0';
                			end if;
					end loop;
				end if;
   	                end if;
   	              --  v.line_offset := (others => '0'); 
   	        end if;   
   	 when   wait_for_distance_engine=>
		v.enable_concatenate_unit := '0';
		if (calculate_sad_done= '1') then
	           v.state := update_mv;
		end if;  
	when wait_for_distance_engine2 =>
	     v.enable_concatenate_unit := '0';
	     if (distance_engine_active = '0') then
	          v.state := update_mv;
	     end if;
	when update_mv =>
		vupdate := '1';
	      v.best_eu := best_eu; --update the condition bit
		v.state := fetch_instruction;
		--if (mvc_done = '1') then  -- first evaluate all the mvcs
			v.instruction_address := v.instruction_address + x"01"; -- start reading the next instruction when arriving in fetch instruction state
  		--end if;
        when terminate =>
	   if (qp_on = '0') then -- qp must have finished
		    --  if (mode_in = m16x16) then
				vfinish := '1';
				vinstruction_zero := '1';
		      	v.state := idle;
		      	vpartition_done := '1';			
		end if;
	      --v.state := idle;
	  when others => null;
	
end case;

if (interpolation_done = '1') then
	v.interpolation_done := '1';
end if;

r_in <= v;
partition_count_out <= r.partition_count;
write_register <= vwrite_register;
load_mv <= vload_mv;
update <= vupdate;
rm_address <= vrm_address;
finish <= vfinish;
start_qp <= vstart_qp;
start_pipelines <= vstart_pipelines; --enable extra pipelines as required
partition_done <= vpartition_done;
instruction_zero <= vinstruction_zero;
		
end process control;

instruction_address <= r.instruction_address;
next_point <= r.point_address;
line_offset <= r.line_offset;
enable_hp_inter <= r.enable_hp_inter;
enable_concatenate_unit <= r_in.enable_concatenate_unit when r.enable_hp_inter = '0' else r.enable_concatenate_unit;
active_pipelines <= r.active_pipelines_r;

	  
-- sequential part

regs: process (clk,clear)

begin

if (clear = '1') then
	r.partition_count <= (others => '0');
	r.state <= idle;
	r.qp_mode <= '0';
   r.instruction_address <= (others => '0');
   r.point_count <= (others => '0');
	r.point_address <= (others => '0');
	r.phy_address <= (others => '0');
	r.phy_address_ready <= (others => '0');
	r.line_count <= (others => '0');
   r.line_offset <= (others => '0');
   r.points_tested <= (others => '0');
	r.enable_hp_inter <= '0';
	r.data_block <= (others => '0');
	r.interpolation_done <= '0';
	r.invalidate <= '0';
	r.enable_concatenate_unit <= '0';
	 r.best_eu <= (others => '0');
	r.active_pipelines_r <= (others => '0');
	r.condition_bit <= '0';
  -- r.calculate_sad_done <= '0';
elsif rising_edge(clk) then
	if (reset = '1') then
	r.partition_count <= (others => '0');
		r.state <= idle;
		r.invalidate <= '0';
			r.qp_mode <= '0';
		r.instruction_address <= (others => '0');
   	  r.point_count <= (others => '0');
		r.point_address <= (others => '0');
	   r.phy_address <= (others => '0');
	  r.best_eu <= (others => '0');
	   r.phy_address_ready <= (others => '0');
	   r.line_count <= (others => '0');
	   r.line_offset <= (others => '0');
	   r.points_tested <= (others => '0');
	   r.enable_hp_inter <= '0';
	   r.data_block <= (others => '0');
	   r.interpolation_done <= '0';
	   r.enable_concatenate_unit <= '0';
	r.active_pipelines_r <= (others => '0');
	r.condition_bit <= '0';
	--   r.calculate_sad_done <= '0';
	else
		r <= r_in;
	end if;
end if;

end process regs;

end;









       