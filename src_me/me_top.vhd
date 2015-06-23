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
--  entity       = me_top	      --
--  version      = 1.0              --
--  last update  = 16/08/09         --
--  author       = Jose Nunez       --
--------------------------------------


-- me top of the hierarchy

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.Numeric_STD.all;
use IEEE.std_logic_unsigned."+";
use IEEE.std_logic_unsigned."-";
use IEEE.std_logic_signed.">";
use IEEE.std_logic_signed."<";
use work.config.all;


entity me_top is
 port ( clk : in std_logic;
        clear : in std_logic;
        reset : in std_logic;
	     register_file_address : in std_logic_vector(4 downto 0); -- 32 general purpose registers
        register_file_write : in std_logic;
	     register_file_data_in : in std_logic_vector(31 downto 0);
	     register_file_data_out : out std_logic_vector(31 downto 0);
	     done_interrupt : out std_logic; -- high when macroblock processing has completed
	     best_sad_debug : out std_logic_vector(15 downto 0); --debugging ports
	     best_mv_debug : out std_logic_vector(15 downto 0);
		 best_eu_debug : out std_logic_vector(3 downto 0);
		 partition_mode_debug : out std_logic_vector(3 downto 0);
		 qp_on_debug : out std_logic;	   --running qp
	     dma_rm_re_debug : in std_logic; --set to one to enable reading the reference area
	     dma_rm_debug : out std_logic_vector(63 downto 0); -- reference area data out
	     dma_address : in std_logic_vector(10 downto 0); -- next reference memory address
        dma_data_in : in std_logic_vector(63 downto 0); -- pixel in for reference memory or macroblock memory
        dma_rm_we : in std_logic; --enable writing to reference memory
	   dma_cm_we : in std_logic; --enable writing to current macroblock memory
	   dma_pom_we : in std_logic; -- enable writing to point memory
	   dma_prm_we : in std_logic;  -- enable writing to program memory
	     dma_residue_out : out std_logic_vector(63 downto 0); -- get residue from winner mv
	     dma_re_re : in std_logic -- enable reading residue
      );
end;  

architecture struct of me_top is

component mv_cost --calculate mv cost using Lagrangian optimization
generic (pipelines : integer);
port (
clk : in std_logic;
clear : in std_logic;
reset : in std_logic;
load  : in std_logic; -- start 
mvp_x : in std_logic_vector(7 downto 0); --predicted mv x
mvp_y : in std_logic_vector(7 downto 0); -- predicted mv y
mvx_c : in std_logic_vector(7 downto 0); -- motion vector candidate x
mvy_c : in std_logic_vector(7 downto 0); -- motion vector candidate y
rest_mvx_c : in rest_type_points; -- rest of motion vector candidates x
rest_mvy_c : in rest_type_points; -- rest of motion vector candidates y 
quant_parameter : in std_logic_vector(5 downto 0); -- quantization parameter 
p_cost_mv : out std_logic_vector(15 downto 0);
rest_p_cost_mv : out rest_type_displacement
); 
end component;
    
    
component phy_address
port (
    clk : in std_logic;
	clear : in std_logic;
	reset : in std_logic;
  partition_count : in std_logic_vector(3 downto 0); --identify the subpartition active
   line_offset : in std_logic_vector(5 downto 0); -- read multiple lines
	mvx : in std_logic_vector(7 downto 0);
	mvy : in std_logic_vector(7 downto 0);
	phy_address : out std_logic_vector(13 downto 0));
end component;

component sad_selector
generic (integer_pipeline_count : integer);
port (
      clk : in std_logic;
	reset : in std_logic;
	clear : in std_logic;
      calculate_sad_done : in std_logic;
	active_pipelines : in std_logic_vector(CFG_PIPELINE_COUNT-1 downto 0);
      update : in std_logic; -- completed program reset the stored sad
	update_fp : in std_logic; -- end of iteraction
	best_eu : out std_logic_vector(3 downto 0);
	best_sad : in std_logic_vector(15 downto 0);
	best_mv : in std_logic_vector(15 downto 0);
      rest_best_sad : in rest_type_displacement;
	rest_best_mv : in rest_type_displacement;
	best_sad_out : out std_logic_vector(15 downto 0);
	best_mv_out : out std_logic_vector(15 downto 0));
end component;

component sad_selector_qp
port (
      clk : in std_logic;
	reset : in std_logic;
	clear : in std_logic;
      calculate_sad_done : in std_logic;
	active_pipelines : in std_logic_vector(CFG_PIPELINE_COUNT_QP-1 downto 0);
      update : in std_logic; -- completed fp part set the stored sad
	update_qp : in std_logic; -- end of iteraction
      best_eu : out std_logic_vector(3 downto 0);
	best_sad : in std_logic_vector(15 downto 0);
	best_mv : in std_logic_vector(15 downto 0);
	rest_best_sad : in rest_type_displacement_qp;
	rest_best_mv : in rest_type_displacement_qp;    	
	best_sad_out : out std_logic_vector(15 downto 0);
	best_mv_out : out std_logic_vector(15 downto 0));
end component;

component distance_engine64
generic (qp_mode : std_logic);
port(
   clk : in std_logic;
	clear : in std_logic;
	reset : in std_logic;
	enable : in std_logic;
	update : in std_logic;
	load_mv : in std_logic;
	mode_in : in mode_type;
	mv_cost_on : in std_logic;
   mv_cost_in : in std_logic_vector(15 downto 0);
	candidate_mvx : in std_logic_vector(7 downto 0);
	candidate_mvy : in std_logic_vector(7 downto 0);
	reference_data_in : in std_logic_vector(63 downto 0);
	current_data_in : in std_logic_vector(63 downto 0);
	residue_out : out std_logic_vector(63 downto 0);
	enable_fifo : out std_logic;
	reset_fifo : out std_logic;
	winner1 : out std_logic;
	calculate_sad_done : out std_logic;
	distance_engine_active : out std_logic;
   best_sad : out std_logic_vector(15 downto 0);
   best_mv : out std_logic_vector(15 downto 0));
end component;


component register_file
generic (integer_pipeline_count : integer);
	port(
      clk : in std_logic;
      clear : in std_logic;
      reset : in std_logic;
	addr : in std_logic_vector(4 downto 0);
	write : in std_logic;
	data_in : in std_logic_vector(31 downto 0);
      data_out : out std_logic_vector(31 downto 0);
	start : out std_logic;
	   all_done_qp : in std_logic; -- program completes
	   all_done_fp : in std_logic; -- fp part completes
  	mvc_done : out std_logic; -- all motion vector candidates evaluated
  	mvc_to_do : out std_logic_vector;
	instruction_zero : in std_logic;
	partition_done_fp : in std_logic; -- fp partition terminates
	partition_done_qp : in std_logic; -- qp partition terminates
	   done_interrupt : out std_logic;
		start_row : out std_logic;
		update_fp : in std_logic; 
	load_mv : in std_logic; -- force the mvc to move foward
        mode_out : out mode_type;
	mv_cost_on : out std_logic; -- activate the costing of mvs
	   best_sad_fp : in std_logic_vector(15 downto 0);
   best_mv_fp : in std_logic_vector(15 downto 0);
      first_mv_fp : out std_logic_vector(15 downto 0);
	rest_first_mv_fp : out rest_type_displacement;
      mbx_coordinate : out std_logic_vector(7 downto 0);
	mby_coordinate : out std_logic_vector(7 downto 0);
	mvp_x : out std_logic_vector(7 downto 0);
	mvp_y : out std_logic_vector(7 downto 0);
      quant_parameter : out std_logic_vector(5 downto 0);
frame_dimension_x : out std_logic_vector(7 downto 0);
frame_dimension_y : out std_logic_vector(7 downto 0);
      		update_qp : in std_logic; 
partition_count : in std_logic_vector(3 downto 0); --identify the subpartition active
	   best_sad_qp : in std_logic_vector(15 downto 0);
   best_mv_qp : in std_logic_vector(15 downto 0);
      first_mv_qp : out std_logic_vector(15 downto 0));
end component;



component fp_pipeline 
 port ( clk : in std_logic;
        clear : in std_logic;
        reset : in std_logic;
        next_point_displacement_fp : in std_logic_vector(15 downto 0); --next point to be processed
        first_mv_fp : in std_logic_vector(15 downto 0); -- first point to start the search from
        start : in std_logic;
 	 start_mb : in std_logic; -- once per macroblock
		   mode_in : in mode_type;
        partition_count : in std_logic_vector(3 downto 0); --identify the subpartition active
	  frame_dimension_x : in std_logic_vector(7 downto 0); --in mb  
	  frame_dimension_y : in std_logic_vector(7 downto 0);
	  mbx_coordinate : in std_logic_vector(7 downto 0); --in mb
	  mby_coordinate : in std_logic_vector(7 downto 0);
	  candidate_mvx : out std_logic_vector(7 downto 0); -- port for Lagrangian optimizaton
	  candidate_mvy : out std_logic_vector(7 downto 0);
	  mv_cost : in std_logic_vector(15 downto 0);
	  mv_cost_on : in std_logic; -- enable mv cost
	  all_done_fp : in std_logic; -- program completes
        calculate_sad_done : out std_logic;
        best_sad_fp : out std_logic_vector(15 downto 0);
        best_mv_fp : out std_logic_vector(15 downto 0);
	  dma_address : in std_logic_vector(10 downto 0); -- next reference memory address
        mb_data_in : in std_logic_vector(63 downto 0); -- pixel in for macroblock memory (shared this memory among the pipelines)
        dma_data_in : in std_logic_vector(63 downto 0); -- pixel in for reference memory
        dma_rm_we : in std_logic; --enable writing to reference memory
	  --dma_cm_we : in std_logic; --enable writing to current macroblock memory
	  dma_residue_out : out std_logic_vector(63 downto 0); -- get residue from winner mv
	  dma_re_re : in std_logic -- enable reading residue
      );
end component;  


component program_memory
	port (
	addr: in std_logic_vector(7 downto 0);
	clk: in std_logic;
	din: in std_logic_vector(19 downto 0);
	dout: out std_logic_vector(19 downto 0);
	we: in std_logic);
end component;

component reference_memory64_remap -- This memory stores the 5x7 reference data (1120 words of 64 bit)
	port (                          -- It also remaps the addresses
	addr_r: in std_logic_vector(10 downto 0);
	addr_w: in std_logic_vector(10 downto 0);
	enable_hp_inter : in std_logic; -- working in interpolation mode
	clk: in std_logic;
	start : in std_logic;
	next_configuration : in std_logic; -- move to the next configuration
	start_row : in std_logic;
	reset : in std_logic;
	clear : in std_logic;
	din: in std_logic_vector(63 downto 0);
	dout: out std_logic_vector(63 downto 0);
	dout2: out std_logic_vector(63 downto 0);
	we: in std_logic);
end component;

component reference_memory64_remap_compact -- This memory stores the 5x5 reference data (800 words of 64 bit)
	port (                          -- It also remaps the addresses
	addr: in std_logic_vector(9 downto 0);
      enable_hp_inter : in std_logic; -- working in interpolation mode
	clk: in std_logic;
	next_configuration : in std_logic; -- move to the next configuration
	start_row : in std_logic;
	reset : in std_logic;
	clear : in std_logic;
	din: in std_logic_vector(63 downto 0);
	dout: out std_logic_vector(63 downto 0);
   dout2 : out std_logic_vector(63 downto 0); -- from the second read port
	we: in std_logic);
end component;

component concatenate64_qp
	port(
	addr : in std_logic_vector(2 downto 0);
	clk : in std_logic;
	clear : in std_logic;
	reset : in std_logic;
	din : in std_logic_vector(63 downto 0);
	din2 : in std_logic_vector(63 downto 0);
	dout : out std_logic_vector(63 downto 0);
	enable : in std_logic;
    quick_valid : out std_logic; --as valid but one cycle earlier
	valid : out std_logic);  -- indicates when 64 valid bits are in the output
end component;


component concatenate64 -- this unit makes sure that 16 valid pixels are assemble depending on byte address
	port(
	addr : in std_logic_vector(2 downto 0);
	clk : in std_logic;
	clear : in std_logic;
	reset : in std_logic;
	din : in std_logic_vector(63 downto 0);
	din2 : in std_logic_vector(63 downto 0);
	dout : out std_logic_vector(63 downto 0);
	enable_hp_inter : in std_logic; -- working in interpolation mode
	enable : in std_logic;
      quick_valid : out std_logic; --as valid but one cycle earlier
	valid : out std_logic);  -- indicates when 16 valid bytes are in the output
end component;

component qp_interpolate_engine
port(
    clk : in std_logic;
    clear : in std_logic;
    reset : in std_logic;
    qp_mode : in std_logic; -- in qp mode two lines must be written to interpolate
    enable_hp_inter : in std_logic;
   write_interpolate_register : in std_logic;
    interpolate_in_pixels_a : in std_logic_vector(63 downto 0);
    interpolate_in_pixels_b : in std_logic_vector(63 downto 0);
    write_block1 : out std_logic;  -- control which of the two blocks is being read and written (interpolate and dist engine)
    rma_address : out std_logic_vector(4 downto 0); -- extracted reference pixels use this address
     rma_we : out std_logic;
    interpolate_out_pixels : out std_logic_vector(63 downto 0)
    );
end component;

component forward_engine
port(
    clk : in std_logic;
    clear : in std_logic;
    reset : in std_logic;
    enable_hp_inter : in std_logic; -- when hp interpolation is being performed in the background
    write_register : in std_logic;
   mode_in : in mode_type;
    partition_count_in : in std_logic_vector(3 downto 0); 
    in_pixels : in std_logic_vector(63 downto 0);
    write_block1 : out std_logic;  -- control which of the two blocks is being read and written (interpolate and dist engine)
    rma_address : out std_logic_vector(4 downto 0); -- extracted reference pixels use this address
	 rma_we : out std_logic;
    out_pixels : out std_logic_vector(63 downto 0)
    );
end component;

-- half pel interpolation engine

component systolic_array_top
port (
    clear            : in std_logic;
    reset            : in std_logic;
    enable_interpolation   : in std_logic;
    enable_estimation : in std_logic;
    clk              : in std_logic;
    data_in          : in std_logic_vector(63 downto 0);
    data_in_valid    : in std_logic;
    data_request : out std_logic;
    all_done   : out std_logic;
    next_point : out std_logic; -- tell the main control unit that the next point is required
    shift_concatenate_valid : in std_logic; -- need to know when 64 bits are valid
    -- memory interface for o,h,v and d memories
    candidate_mvx   : in std_logic_vector(7 downto 0);
    candidate_mvy   : in std_logic_vector(7 downto 0);
    hp_address_a   : out std_logic_vector(2 downto 0);
    hp_address_b   : out std_logic_vector(2 downto 0);
    data_out_a   : out std_logic_vector(63 downto 0);   --interpolated data out 
    data_out2_a   : out std_logic_vector(63 downto 0);   --interpolated data out 
    data_out_b   : out std_logic_vector(63 downto 0);   --interpolated data out 
    data_out2_b   : out std_logic_vector(63 downto 0);   --interpolated data out 
    data_out_valid : out std_logic --signal to indicate 8 bytes of data valid

    );
end component;



component current_macroblock_memory64 -- This memory stores the current macroblock(256 bytes))
	port (
	addr: in std_logic_vector(4 downto 0);
	clk: in std_logic;
	din: in std_logic_vector(63 downto 0);
	dout: out std_logic_vector(63 downto 0);
	we: in std_logic);
end component;


component point_memory
	port (
	addr: IN std_logic_VECTOR(7 downto 0);
	clk: IN std_logic;
	din: IN std_logic_VECTOR(15 downto 0);
	dout: OUT std_logic_VECTOR(15 downto 0);
	we: IN std_logic);
end component;

--component point_memory
--	port (
--	addr: in std_logic_vector(7 downto 0);
--	clk: in std_logic;
--	dout: out std_logic_vector(15 downto 0));
--end component;


component me_control_unit
generic ( integer_pipeline_count : integer);
port ( clk : in std_logic;
        clear : in std_logic;
        reset : in std_logic;
        start : in std_logic;
 	  range_ok : in std_logic; --keep track of the mv range
	  best_sad_in : in std_logic_vector(15 downto 0); -- to make SAD-based decisions
	  mv_length_in : in std_logic_vector(15 downto 0); -- to make LENGTH-based decisions
	  mode_in : in mode_type;
	  mvc_done : in std_logic; -- all motion vector candidates evaluated
	  mvc_to_do : in std_logic_vector(3 downto 0);
	  qp_on : in std_logic; -- qp on
 	  partition_count_out : out std_logic_vector(3 downto 0); --identify the subpartition active
        start_pipelines : out std_logic_vector(CFG_PIPELINE_COUNT-1 downto 0);
 	  active_pipelines : out std_logic_vector(CFG_PIPELINE_COUNT-1 downto 0); -- so sad selector ignores the non active ones
        shift_concatenate_valid : in std_logic; -- valid output from the concantenate unit (64 bit ready)
        instruction_address : out std_logic_vector(7 downto 0); -- address to fetch next instruction
	  instruction_opcode : in std_logic_vector(3 downto 0); -- opcode
        point_count : in std_logic_vector(7 downto 0); -- how many points to test
        point_address : in std_logic_vector(7 downto 0); -- which is the first point to test
	  best_eu : in std_logic_vector(3 downto 0);
        calculate_sad_done : in std_logic;
	   distance_engine_active : in std_logic; 
        interpolation_done : in std_logic; -- interpolation completes
        interpolate_data_request : in std_logic; -- interpolator requests data
        next_point : out std_logic_vector(7 downto 0); -- next point address to ROM
        line_offset : out std_logic_vector(5 downto 0); -- multiple line reading
	  enable_concatenate_unit : out std_logic;
	    --enable_dist_engine : out std_logic;
        write_register : out std_logic;
        load_mv : out std_logic;
         update : out std_logic;
	  instruction_zero : out std_logic;
        all_done : out std_logic; -- program completes or qp mode started (fp finished)
	  partition_done : out std_logic;
        qpel_loc_x : in std_logic_vector(1 downto 0); -- detect qp mode
        qpel_loc_y : in std_logic_vector(1 downto 0);
        start_qp : out std_logic;
        enable_hp_inter : out std_logic; -- start the interpolation core
       --  write_block1 : out std_logic;
      --  next_rm_address_ready : in std_logic;
        next_rm_addresss : in std_logic_vector(13 downto 0); --physical address for reference (macroblock upper left corner        
        rm_address : out std_logic_vector(13 downto 0) -- reference memory write from address
	--  cm_address : out std_logic_vector(4 downto 0);  -- address to extract 4x4 blocks from current macroblock
	--  rma_address : out std_logic_vector(4 downto 0); -- reference macroblock write to address
	--  rma_we : out std_logic
	);
end component;

component me_control_unit_qp
 port ( clk : in std_logic;
        clear : in std_logic;
        reset : in std_logic;
        start : in std_logic; -- start qp refinement
        next_point_inter : in std_logic; -- tell the main control unit that the next point is required by the interpolation unit
        shift_concatenate_valid : in std_logic; -- valid output from the concantenate unit 
        qp_starting_address : in std_logic_vector(7 downto 0); -- start fetching qp instructions from this point
        instruction_address : out std_logic_vector(7 downto 0); -- address to fetch next instruction
        point_count : in std_logic_vector(7 downto 0); -- how many points to test
        point_address : in std_logic_vector(7 downto 0); -- which is the first point to test
        calculate_sad_done : in std_logic; -- signals when the distance engine has finished
         instruction_opcode : in std_logic_vector(3 downto 0); -- opcode
         best_eu : in std_logic_vector(3 downto 0); -- best execution unit
        next_point : out std_logic_vector(7 downto 0); -- next point address to ROM
	     qp_mode : out std_logic; --enable qp estimation
	     qp_on : out std_logic; -- qp active
        load_mv : out std_logic;
        update : out std_logic;
        all_done : out std_logic -- program completes
    );
end component; 

component range_checker --make sure that MVs are not out of range
port (
clk : in std_logic;
clear : in std_logic;
reset : in std_logic;
candidate_mvx : in std_logic_vector(7 downto 0);
candidate_mvy : in std_logic_vector(7 downto 0);
frame_dimension_x : in std_logic_vector(7 downto 0); --in mb  
frame_dimension_y : in std_logic_vector(7 downto 0);
mbx_coordinate : in std_logic_vector(7 downto 0); --in mb
mby_coordinate : in std_logic_vector(7 downto 0);
range_ok : out std_logic
); 
end component;


signal rest_next_point_fp : rest_type_points;
signal rest_point_memory_address : rest_type_points;
signal rest_next_point_displacement_fp : rest_type_displacement;
signal rest_start_pipeline,rest_calculate_sad_done : std_logic_vector(CFG_PIPELINE_COUNT-1 downto 0);
signal rest_best_sad_fp,rest_best_mv_fp,rest_first_mv_fp: rest_type_displacement;

signal rest_next_point_qp : rest_type_points_qp;
signal rest_point_memory_address_qp : rest_type_points_qp;
signal rest_next_point_displacement_qqp : rest_type_displacement_qp;
signal rest_start_pipeline_qp,rest_calculate_sad_done_qp : std_logic_vector(CFG_PIPELINE_COUNT_QP-1 downto 0);
signal rest_best_sad_qp,rest_best_mv_qp: rest_type_displacement_qp;

signal mvp_x,mvp_y,frame_dimension_x,frame_dimension_y,mby_coordinate,mbx_coordinate,program_memory_address,program_memory_address_qp,instruction_address_fp,instruction_address_qp,point_count_fp,point_count_qp,point_address_fp,point_address_qp,candidate_mvx_fp,candidate_mvy_fp,candidate_mvx_qp,candidate_mvy_qp : std_logic_vector(7 downto 0);
signal quant_parameter,line_offset : std_logic_vector(5 downto 0);
signal partition_count,instruction_fp,instruction_qp : std_logic_vector(3 downto 0); --op code
signal next_point_fp,point_memory_address,next_point_qp,point_memory_address_qp,candidate_mvx_int,candidate_mvy_int : std_logic_vector(7 downto 0);
signal one_bit,zero_bit,distance_engine_active_fp,range_ok,quick_valid,quick_valid_qp,next_point_inter,enable_concatenate_unit,dma_cm_we_m1,dma_cm_we_m2,dma_cm_we_fp,dma_cm_we_qp,done_interrupt_int,mv_cost_on : std_logic;
signal distance_engine_address_m2,distance_engine_address_m1,distance_engine_address_qp,cm_address_m1,cm_address_m2,address1_fp,address2_fp,address1_qp,address2_qp: std_logic_vector(4 downto 0);
signal zero,best_sad_out_qp,best_mv_out_qp,next_point_displacement_qp,next_point_displacement_fp,best_sad_fp,best_sad_qp,best_sad_qp_distance_engine,best_mv_fp,best_mv_qp,best_sad_out_fp,best_mv_out_fp,p_cost_mv,p_cost_mv_qp : std_logic_vector(15 downto 0);
signal point_count_position_qp,point_count_position_fp : std_logic_vector(19 downto 0);
signal mv_length_in,first_mv_fp,first_mv_qp,mv_displacement_fp,mv_displacement_qp : std_logic_vector(15 downto 0);
signal mvc_done,instruction_zero,qp_on,partition_done_fp,partition_done_qp,mux_control_write,mux_control_read,qp_mode,start_qp,qp_pixels_valid,hp_pixels_valid,hp_interpolation_done,data_request_hp_inter,all_done_fp,all_done_qp,start_row,reset_fifo_fp,reset_fifo_qp,reset_fifo1_qp,reset_fifo2_qp,reset_fifo1_fp,reset_fifo2_fp,fifo_enable_w1,fifo_enable_w2,fifo_enable_r1,fifo_enable_r2,enable_fifo_fp,enable_fifo_qp,winner1_fp,winner1_qp,start,write_register,write_interpolate_register,next_rm_address_ready,shift_concatenate_valid_qp,shift_concatenate_valid_fp,rma_we_qp,rma_we_fp,rma_we1_qp,rma_we2_qp,rma_we1_fp,rma_we2_fp,write_block1_qp,load_mv_fp,load_mv_qp,update_fp,update_qp,calculate_sad_done_qp,calculate_sad_done_fp,enable_hp_inter : std_logic;
signal rm_address_r,rm_address_w : std_logic_vector(10 downto 0);
signal rm_address_c : std_logic_vector(9 downto 0);
signal best_eu,best_eu_qp,mvc_to_do : std_logic_vector(3 downto 0);
signal next_rm_address,int_rm_address : std_logic_vector(13 downto 0);
signal current_pixels,current_pixels_fp,current_pixels_qp,current_pixels_m1,current_pixels_m2,reference_data_in1_fp,reference_data_in2_fp,reference_data_in1_qp,reference_data_in2_qp,reference_data_in_fp,reference_data_in_qp : std_logic_vector(63 downto 0);
signal reference_pixels_in,reference_pixels_in2,residue_out_fp,residue_out_qp,residue_out_1_2,residue_out_2_2,residue_out_1_1,residue_out_2_1 : std_logic_vector(63 downto 0);
signal out_pixels_fp,out_pixels_qp,qp_pixels_out_a,qp_pixels_out_b,hp_pixels_out_a,hp_pixels_out2_a,hp_pixels_out_b,hp_pixels_out2_b,reference_pixels_out_qp_a,reference_pixels_out_qp_b,reference_pixels_out_fp : std_logic_vector(63 downto 0); --for the interpolate unit
signal rma_address_qp,rma_address_fp  : std_logic_vector(4 downto 0);
signal hp_address_a, hp_address_b : std_logic_vector(2 downto 0);
--signal sad : std_logic_vector(15 downto 0);
signal qpel_loc_x,qpel_loc_y : std_logic_vector(1 downto 0);
signal point_memory_data_in : std_logic_vector(15 downto 0);
signal program_memory_data_in : std_logic_vector(19 downto 0);
signal partition_mode : mode_type;
signal active_pipelines : std_logic_vector(CFG_PIPELINE_COUNT-1 downto 0);
signal active_pipelines_qp : std_logic_vector(CFG_PIPELINE_COUNT_QP-1 downto 0);
signal rest_mvx_c,rest_mvy_c : rest_type_points;
signal rest_p_cost_mv : rest_type_displacement;
  
begin
  

-- program memory for fp engine    
program_memory_data_in <= dma_data_in(19 downto 0);
program_memory_address <= dma_address(7 downto 0) when dma_prm_we = '1' else instruction_address_fp;
qp_on_debug <= qp_on;
zero_bit <= '0';
one_bit <= '1';

mode_process : process(partition_mode)

begin

case partition_mode is

	when m16x16 => partition_mode_debug <= "0000";
	when m8x8 => partition_mode_debug <= "0001";
	when others => partition_mode_debug <= "0000";

end case;

end process;


program_memory1 : program_memory
	port map(
	addr =>program_memory_address,
	clk =>clk,
	din =>program_memory_data_in,
	dout => point_count_position_fp,
	we => dma_prm_we 
);

-- program memory for qp engine

program_memory2_qp : if CFG_PIPELINE_COUNT_QP = 1 generate

program_memory_address_qp <= dma_address(7 downto 0) when dma_prm_we = '1' else instruction_address_qp;

program_memory2 : program_memory
	port map(
	addr =>program_memory_address_qp,
	clk =>clk,
	din =>program_memory_data_in,
	dout => point_count_position_qp,
	we => dma_prm_we 
);

end generate;

no_qpgen0 : if CFG_PIPELINE_COUNT_QP = 0 generate

	point_count_position_qp <= (others => '0');

end generate;

range_checker1 : range_checker --make sure that MVs are not out of range
port map(
clk => clk,
clear => clear,
reset => reset,
candidate_mvx => candidate_mvx_fp,
candidate_mvy => candidate_mvy_fp,
frame_dimension_x =>frame_dimension_x, 
frame_dimension_y =>frame_dimension_y,
mbx_coordinate => mbx_coordinate,
mby_coordinate => mby_coordinate,
range_ok => range_ok
);

phy_address1 : phy_address
port map(
   clk => clk,
	clear => clear,
	reset => reset,
  partition_count => partition_count, --identify the subpartition active
   line_offset => line_offset,
	mvx => candidate_mvx_int,
	mvy => candidate_mvy_int,
	phy_address => next_rm_address
);

instruction_fp <= point_count_position_fp(19 downto 16);
point_count_fp <= point_count_position_fp(15 downto 8);
point_address_fp <= point_count_position_fp(7 downto 0);
instruction_qp <= point_count_position_qp(19 downto 16);
point_count_qp <= point_count_position_qp(15 downto 8);
point_address_qp <= point_count_position_qp(7 downto 0);
candidate_mvx_fp <= first_mv_fp(15 downto 8)+mv_displacement_fp(15 downto 8); 
candidate_mvy_fp <= first_mv_fp(7 downto 0)+mv_displacement_fp(7 downto 0);

-- check that MVX is in the reference area
in_range_x : process(candidate_mvx_fp)
begin
	if candidate_mvx_fp > 47 then
		candidate_mvx_int <= x"2f";
	elsif candidate_mvx_fp < -48 then
		candidate_mvx_int <= x"d0";
	else
	    candidate_mvx_int <= candidate_mvx_fp;
	end if;
end process;

-- check that MVY is in the reference area
in_range_y: process(candidate_mvy_fp)
begin
	if candidate_mvy_fp > 31 then
		candidate_mvy_int <= x"1f";
	elsif candidate_mvy_fp < -32 then
		candidate_mvy_int <= x"e0";
	else
	    candidate_mvy_int <= candidate_mvy_fp;
	end if;
end process;


--this has to change the first mv for qp should be the winner from fo
candidate_mvx_qp <= first_mv_qp(15 downto 8)+mv_displacement_qp(15 downto 8); 
candidate_mvy_qp <= first_mv_qp(7 downto 0)+mv_displacement_qp(7 downto 0);
no_qpgen11 : if CFG_PIPELINE_COUNT_QP = 0 generate
	qpel_loc_x <= (others => '0');
	qpel_loc_y <= (others => '0');
end generate;
qpgen11 : if CFG_PIPELINE_COUNT_QP = 1 generate
	qpel_loc_x <= candidate_mvx_fp(1 downto 0);
	qpel_loc_y <= candidate_mvy_fp(1 downto 0);
end generate;

-- fp point memory

--point_memory_fp : point_memory
--	port map(
--	addr =>next_point_fp,
--	clk =>clk,
--	dout => next_point_displacement_fp
--);

point_memory_address <= dma_address(7 downto 0) when dma_pom_we = '1' else next_point_fp;
point_memory_data_in <= dma_data_in(15 downto 0);

point_memory_fp : point_memory
	port map(
	addr =>point_memory_address,
	clk =>clk,
	din =>point_memory_data_in,
	dout =>next_point_displacement_fp,
	we => dma_pom_we
);


--generate enough memories to hold the point memories for each aditional pipeline

generate_pipelines1 : for i in 1 to (CFG_PIPELINE_COUNT-1) generate
begin
	rest_next_point_fp(i) <= next_point_fp when mvc_done = '0' else next_point_fp + i;
	rest_point_memory_address(i) <=  dma_address(7 downto 0) when dma_pom_we = '1' else rest_next_point_fp(i);
	rest_point_memory_fp : point_memory
	port map ( 
	addr =>  rest_point_memory_address(i),
	clk => clk,
	din =>point_memory_data_in,
	dout => rest_next_point_displacement_fp(i),
	we => dma_pom_we
	);
end generate;


--generate integer pipelines 

generate_pipelines2 : for i in 1 to (CFG_PIPELINE_COUNT-1) generate
begin

fp_pipelines1 : fp_pipeline
 port map( clk =>clk,
        clear =>clear,
        reset =>reset,
        next_point_displacement_fp =>rest_next_point_displacement_fp(i), --next point to be processed
        first_mv_fp =>rest_first_mv_fp(i), -- first point to start the search from
        start =>rest_start_pipeline(i), -- enable the pipeline by main me
	  start_mb => start, -- once per macroblock
	  mode_in => partition_mode,
        partition_count => partition_count, --identify the subpartition active
	  frame_dimension_x =>frame_dimension_x, --in mb  
        frame_dimension_y =>frame_dimension_y,
        mbx_coordinate =>mbx_coordinate, --in mb
        mby_coordinate =>mby_coordinate,
	  candidate_mvx =>rest_mvx_c(i), -- port for Lagrangian optimizaton
	  candidate_mvy =>rest_mvy_c(i),
	  mv_cost =>rest_p_cost_mv(i), 
	  mv_cost_on => mv_cost_on, -- enable mv cost
	  all_done_fp => all_done_fp,
        calculate_sad_done => rest_calculate_sad_done(i),
        best_sad_fp =>rest_best_sad_fp(i),
        best_mv_fp =>rest_best_mv_fp(i),
	  dma_address =>dma_address, -- next reference memory address
 	  mb_data_in => current_pixels_fp, -- shared mb memory 
        dma_data_in =>dma_data_in, -- pixel in for reference memory
        dma_rm_we =>dma_rm_we, --enable writing to reference memory
	  --dma_cm_we =>dma_cm_we, --enable writing to current macroblock memory
	  dma_residue_out =>open, -- get residue from winner mv
	  dma_re_re => dma_re_re-- enable reading residue
      );
end generate;  



point_memory_qp_qp : if CFG_PIPELINE_COUNT_QP = 1 generate
-- qp point memory

point_memory_qp : point_memory
	port map(
	addr =>point_memory_address_qp,
	din =>point_memory_data_in,
	clk =>clk,
	dout => next_point_displacement_qp,
	we => dma_pom_we
);		
	
point_memory_address_qp <=  dma_address(7 downto 0) when dma_pom_we = '1' else next_point_qp;



end generate;

no_qpgen1 : if CFG_PIPELINE_COUNT_QP= 0 generate

	next_point_displacement_qp <= (others => '0');

end generate;

-- displace the mv by 2 pixels to define the interpolation area when interpolation active

mv_displacement_fp <= next_point_displacement_fp when enable_hp_inter = '0' else x"14FC"; --(20,-4)
mv_displacement_qp <= next_point_displacement_qp;
done_interrupt <= done_interrupt_int;

register_file1 : register_file
generic map(integer_pipeline_count => (CFG_PIPELINE_COUNT))
	port map(
      clk => clk,
      clear => clear,
      reset => reset,
	addr =>  register_file_address,
	write => register_file_write,
	data_in => register_file_data_in,
      data_out => register_file_data_out,
	start => start,
      mode_out => partition_mode,
	mv_cost_on => mv_cost_on,  -- activate the costing of mvs	
 all_done_fp => all_done_fp,
	all_done_qp => all_done_qp,
	mvc_to_do => mvc_to_do,
  	mvc_done => mvc_done, -- all motion vector candidates evaluated
	instruction_zero => instruction_zero,
	  partition_done_fp => partition_done_fp,
	  partition_done_qp => partition_done_qp,
		   done_interrupt => done_interrupt_int,
		start_row => start_row,
		load_mv => load_mv_fp, -- force the mvc to move foward
		update_fp => update_fp,
	   best_sad_fp => best_sad_out_fp,
   best_mv_fp => best_mv_out_fp,
      first_mv_fp => first_mv_fp,
	rest_first_mv_fp => rest_first_mv_fp,
	mbx_coordinate =>mbx_coordinate,
	mby_coordinate =>mby_coordinate,
	mvp_x =>  mvp_x,
	mvp_y =>  mvp_y,
      quant_parameter => quant_parameter,
frame_dimension_x =>frame_dimension_x,
frame_dimension_y =>frame_dimension_y,
partition_count => partition_count,
      		update_qp => update_qp,
	   best_sad_qp => best_sad_out_qp,
   best_mv_qp => best_mv_out_qp,
      first_mv_qp => first_mv_qp

); 


compact_memory0 : if CFG_CM = 0 generate

reference_memory_large : reference_memory64_remap  --This memory stores the 7x5 
port map(
	addr_r => rm_address_r,
	addr_w => rm_address_w,
	enable_hp_inter => enable_hp_inter, -- working in interpolation mode
	clk => clk,
	next_configuration => start, -- use the start signal to move between configurations all_done_fp, -- move to the next configuration when programs completes
	start => start,
	start_row => start_row,
	reset => reset,
	clear => clear,
	din =>dma_data_in,
	dout =>reference_pixels_in,
	dout2 => reference_pixels_in2,
	we => dma_rm_we
);

end generate;

compact_memory1 : if CFG_CM = 1 generate 

rm_address_c <= rm_address_w(9 downto 0) when dma_rm_we = '1' else rm_address_r(9 downto 0);

reference_memory_compact : reference_memory64_remap_compact -- This memory stores the 5x5 reference data (800 words of 64 bit)
	port map(                          -- It also remaps the addresses
	addr => rm_address_c,
      enable_hp_inter => enable_hp_inter, -- working in interpolation mode
	clk => clk,
	next_configuration => start, -- move to the next configuration
	start_row => start_row,
	reset => reset,
	clear => clear,
	din => dma_data_in,
	dout => reference_pixels_in,
      dout2 => reference_pixels_in2, -- from the second read port
	we => dma_rm_we
);

end generate;


--when qp mode it is the systolic array which decides when data is valid

concatenate_qp_qp : if CFG_PIPELINE_COUNT_QP = 1 generate

concatenate_qp_a : concatenate64_qp -- this unit makes sure that 8 valid pixels are assemble depending on byte address
	port map(
	addr => hp_address_a,
	clk => clk,
	clear => clear,
	reset => reset,
	din => hp_pixels_out_a,
	din2 => hp_pixels_out2_a,
	dout => reference_pixels_out_qp_a,
	enable => hp_pixels_valid,
	quick_valid => quick_valid_qp, --as valid but one cycle earlier
	valid => shift_concatenate_valid_qp  -- indicates when 64 valid bits are in the output
);


concatenate_qp_b : concatenate64_qp -- this unit makes sure that 8 valid pixels are assemble depending on byte address
	port map(
	addr => hp_address_b,
	clk => clk,
	clear => clear,
	reset => reset,
	din => hp_pixels_out_b,
	din2 => hp_pixels_out2_b,
	dout => reference_pixels_out_qp_b,
	enable => hp_pixels_valid,
	quick_valid => open, --as valid but one cycle earlier
	valid => open  -- indicates when 64 valid bits are in the output
);


end generate;

no_qpgen2 : if CFG_PIPELINE_COUNT_QP = 0 generate

	reference_pixels_out_qp_a <= (others => '0');
	reference_pixels_out_qp_b <= (others => '0');
	shift_concatenate_valid_qp <= '0';

end generate;

-- when no qp mode different concatenate unit

concatenate_fp : concatenate64 -- this unit makes sure that 8 valid pixels are assemble depending on byte address
	port map(
	addr => int_rm_address(2 downto 0),
	clk => clk,
	clear => clear,
	reset => reset,
	din => reference_pixels_in,
      din2 => reference_pixels_in2,
	dout => reference_pixels_out_fp,
	enable => enable_concatenate_unit,
	enable_hp_inter => enable_hp_inter, -- working in interpolation mode
      quick_valid => quick_valid, --as valid but one cycle earlier
	valid => shift_concatenate_valid_fp  -- indicates when 64 valid bits are in the output
);

-- half pel interpolation engine

interpolate2_qp : if CFG_PIPELINE_COUNT_QP = 1 generate

interpolate2 :  systolic_array_top
port map(
    clear =>clear,
    reset => reset,
    enable_interpolation =>enable_hp_inter,
    enable_estimation =>qp_mode,
    clk =>clk,
    data_in =>reference_pixels_out_fp,
    data_in_valid =>shift_concatenate_valid_fp,
    data_request =>data_request_hp_inter,
    all_done =>hp_interpolation_done,
    next_point => next_point_inter, -- tell the main control unit that the next point is required
    shift_concatenate_valid =>shift_concatenate_valid_qp, -- need to know when 64 bits are valid
    -- memory interface for o,h,v and d memories
    candidate_mvx => candidate_mvx_qp,
    candidate_mvy => candidate_mvy_qp,
    hp_address_a => hp_address_a,
    hp_address_b => hp_address_b,
    data_out_a  => hp_pixels_out_a,   --interpolated data out port a
    data_out2_a => hp_pixels_out2_a,  --interpolated data out 
    data_out_b  => hp_pixels_out_b,   --interpolated data out port b
    data_out2_b  => hp_pixels_out2_b,   --interpolated data out 
    data_out_valid => hp_pixels_valid --signal to indicate 8 bytes of data valid

);

end generate;

no_qpgen3 : if CFG_PIPELINE_COUNT_QP = 0 generate

  data_request_hp_inter <= '0';
  hp_interpolation_done  <= '0';
  next_point_inter <= '0';
  hp_address_a <= (others => '0');
  hp_address_b <= (others => '0');
  hp_pixels_out_a <= (others => '0');   --interpolated data out 
  hp_pixels_out_b <= (others => '0');
  hp_pixels_valid <= '0'; 

end generate;

-- data for qp engine always comes from the concatenate unit
qp_pixels_valid <= shift_concatenate_valid_qp;
qp_pixels_out_a <= reference_pixels_out_qp_a;
qp_pixels_out_b <= reference_pixels_out_qp_b;

forward1 : forward_engine
port map(
    clk =>clk,
    clear =>clear,
    reset =>reset,
   mode_in => partition_mode,
    partition_count_in => partition_count,
    enable_hp_inter =>enable_hp_inter, -- when hp interpolation is being performed in the background
    write_register =>shift_concatenate_valid_fp,
    in_pixels =>reference_pixels_out_fp,
    write_block1 =>open,  -- control which of the two blocks is being read and written (interpolate and dist engine)
    rma_address =>rma_address_fp, -- extracted reference pixels use this address
	 rma_we => rma_we_fp,
    out_pixels => out_pixels_fp
    );

interpolate1_qp : if CFG_PIPELINE_COUNT_QP = 1 generate

interpolate1 : qp_interpolate_engine
port map(
    clk=>clk,
    clear=>clear,
    reset=>reset,
    qp_mode => qp_mode, -- in qp mode two lines must be written to interpolate
    enable_hp_inter => enable_hp_inter,
    write_interpolate_register=> qp_pixels_valid,
    interpolate_in_pixels_a => qp_pixels_out_a,
    interpolate_in_pixels_b => qp_pixels_out_b, 
    write_block1 => open, -- control which of the two blocks is being read and written (interpolate and dist engine)
    rma_address => rma_address_qp, -- extracted reference pixels use this address
	 rma_we => rma_we_qp,
    interpolate_out_pixels => out_pixels_qp
    );

end generate;

no_qpgen4 : if CFG_PIPELINE_COUNT_QP = 0 generate

    write_block1_qp <= '0';  -- control which of the two blocks is being read and written (interpolate and dist engine)
    rma_address_qp <= (others => '0'); -- extracted reference pixels use this address
    rma_we_qp <= '0';
    out_pixels_qp <= (others => '0');

end generate;

reference_data_in_fp <= out_pixels_fp;
rm_address_r <= int_rm_address(13 downto 3) when (dma_rm_re_debug = '0') else dma_address;
rm_address_w <= dma_address;
dma_rm_debug <= reference_pixels_in;


reference_data_in_qp <= out_pixels_qp;

--These two memories will alternate if they are fp or qp

dma_cm_we_m2 <= dma_cm_we when mux_control_write = '1' else '0';
dma_cm_we_m1 <= dma_cm_we when mux_control_write = '0' else '0';

current_pixels_fp <= current_pixels_m1 when mux_control_read = '0' else current_pixels_m2;
current_pixels_qp <= current_pixels_m1 when mux_control_read = '1' else current_pixels_m2;
distance_engine_address_m1 <= rma_address_fp when mux_control_read = '0' else rma_address_qp;
distance_engine_address_m2 <= rma_address_fp when mux_control_read = '1' else rma_address_qp;

--two so you can write one while you read the other. Dual port is not enough since you cannot destroy the contents

current_macroblock_memory1 : current_macroblock_memory64 -- This memory stores the current macroblock(256 bytes (32 words x 64 bits))
	port map(
	addr => cm_address_m1, 
	clk => clk,
	din => dma_data_in, 
	dout => current_pixels_m1,
	we => dma_cm_we_m1
);

current_macroblock_memory2 : current_macroblock_memory64 -- This memory stores the current macroblock(256 bytes (32 words x 64 bits))
	port map(
	addr => cm_address_m2, 
	clk => clk,
	din => dma_data_in, 
	dout => current_pixels_m2,
	we => dma_cm_we_m2
);


cm_address_m1 <= distance_engine_address_m1 when dma_cm_we_m1 = '0' else dma_address(4 downto 0);
cm_address_m2 <= distance_engine_address_m2 when dma_cm_we_m2 = '0' else dma_address(4 downto 0); 

me_control_unit_qp1_qp : if CFG_PIPELINE_COUNT_QP = 1 generate

me_control_unit_qp1 : me_control_unit_qp
 port map( clk =>clk,
        clear =>clear,
        reset =>reset,
        start =>start_qp,
        next_point_inter => next_point_inter, -- next point address to ROM
        shift_concatenate_valid =>quick_valid_qp, 
        qp_starting_address =>instruction_address_fp,
        instruction_address =>instruction_address_qp,
        point_count =>point_count_qp,
        point_address =>point_address_qp,
        calculate_sad_done =>calculate_sad_done_qp,
        instruction_opcode => instruction_qp,
        best_eu => best_eu_qp,
        next_point =>next_point_qp,
	     qp_mode =>qp_mode, --enable qp estimation
	     qp_on => qp_on, -- qp active
        load_mv => load_mv_qp,
        update =>update_qp,
        all_done =>all_done_qp -- program completes
    );

end generate;

no_qpgen7 : if CFG_PIPELINE_COUNT_QP = 0 generate

        instruction_address_qp <= (others => '0'); -- address to fetch next instruction
        next_point_qp <= (others => '0');
        qp_mode <= '0'; --enable qp estimation
        load_mv_qp <= '0';
        update_qp <= '0';
        all_done_qp <= '0'; -- program completes
		qp_on <= '0';

end generate;

best_eu_debug <= best_eu;

me_control_unit1 : me_control_unit
generic map(
integer_pipeline_count => (CFG_PIPELINE_COUNT)
)
port map( clk =>clk,
        clear =>clear,
        reset =>reset,
        start => start,
 	  range_ok => range_ok,
	  mode_in => partition_mode,
	  best_sad_in => best_sad_out_fp, -- to make SAD-based decisions
	  mv_length_in => mv_length_in, -- to make LENGTH-based decisions
	  qp_on => qp_on, -- qp on
 	  mvc_done => mvc_done, -- all motion vector candidates evaluated
	  mvc_to_do => mvc_to_do,
  	  partition_count_out => partition_count, --identify the subpartition active
        start_pipelines => rest_start_pipeline,
	  active_pipelines => active_pipelines,
        shift_concatenate_valid => quick_valid, -- valid output from the concantenate unit (64 bit ready)
        instruction_address => instruction_address_fp, -- address to fetch next instruction
	  instruction_opcode => instruction_fp, -- the opcode
        point_count => point_count_fp, -- how many points to test
        point_address => point_address_fp, -- which is the first point to test
        calculate_sad_done => calculate_sad_done_fp,
	  distance_engine_active => distance_engine_active_fp,
        interpolation_done => hp_interpolation_done,-- interpolation completes
        interpolate_data_request => data_request_hp_inter,-- interpolator requests data
        line_offset => line_offset, -- read the different lines of the reference macroblock
	  enable_concatenate_unit => enable_concatenate_unit,
    --    enable_dist_engine => enable_dist_engine,
        write_register => write_register,
        load_mv => load_mv_fp,
	  best_eu => best_eu,
         update => update_fp,
	   instruction_zero => instruction_zero,
            all_done => all_done_fp,
	  partition_done => partition_done_fp,
        qpel_loc_x =>qpel_loc_x, -- detect qp mode
        qpel_loc_y =>qpel_loc_y,
         next_point => next_point_fp,
        start_qp => start_qp,
        enable_hp_inter =>enable_hp_inter,
    --    write_block1 => write_block1, -- control which of the two blocks is being read and written (interpolate and dist engine)
      --  next_rm_address_ready => next_rm_address_ready,
        next_rm_addresss => next_rm_address, --physical address for reference (macroblock upper left corner        
        rm_address => int_rm_address -- internal reference memory addresses
    --    rma_address => rma_address, -- extracted reference pixels use this address
	 --    rma_we => rma_we
	);


-- calculate the length of the motion vector 
mv_length_in <=	(best_mv_out_fp(15 downto 8) -  mvp_x) & (best_mv_out_fp(7 downto 0)  -  mvp_y);



gen_mv_cost_qp : if (CFG_MV_COST = 1 and CFG_PIPELINE_COUNT_QP = 1) generate
-- mv cost unit
mv_cost_qp : mv_cost
generic map(pipelines => CFG_PIPELINE_COUNT_QP)
port map(
	clk => clk,
	clear => clear,
	reset => reset,
	load  =>  load_mv_qp, -- start calculation of mv costs for qp
	mvp_x => mvp_x, -- predicted mv x
	mvp_y => mvp_y, -- predicted mv y
	mvx_c =>candidate_mvx_qp, -- motion vector candidate x
	mvy_c =>candidate_mvy_qp, -- motion vector candidate y
	rest_mvx_c =>rest_mvx_c, -- rest of motion vector candidates x
	rest_mvy_c =>rest_mvy_c, -- rest of motion vector candidates y 
	quant_parameter => quant_parameter, 
	p_cost_mv => p_cost_mv_qp,
	rest_p_cost_mv => open
); 

end generate;

no_gen_mv_cost_qp : if (CFG_MV_COST = 0 or CFG_PIPELINE_COUNT_QP = 0) generate
	p_cost_mv_qp <= (others => '0');
end generate;

gen_mv_cost_fp : if CFG_MV_COST = 1 generate
-- mv cost unit
mv_cost_fp : mv_cost
generic map(pipelines => CFG_PIPELINE_COUNT)
port map(
	clk => clk,
	clear => clear,
	reset => reset,
	load  =>  rest_start_pipeline(0), -- start calculation of mv costs for fp
	mvp_x => mvp_x, -- predicted mv x
	mvp_y => mvp_y, -- predicted mv y
	mvx_c =>candidate_mvx_int, -- motion vector candidate x
	mvy_c =>candidate_mvy_int, -- motion vector candidate y
	rest_mvx_c =>rest_mvx_c, -- rest of motion vector candidates x
	rest_mvy_c =>rest_mvy_c, -- rest of motion vector candidates y 
	quant_parameter => quant_parameter, 
	p_cost_mv => p_cost_mv,
	rest_p_cost_mv => rest_p_cost_mv
); 

end generate;


no_gen_mv_cost_fp : if CFG_MV_COST = 0 generate
	p_cost_mv <= (others => '0');
end generate;

-- fp distance engine	

distance_engine_fp : distance_engine64
generic map (qp_mode => '0')
port map(
	clk =>clk,
	clear =>clear,
	reset =>reset,
	enable => rma_we_fp, -- calculate when new data available
	update => update_fp,  -- instruction completes set the best sad register to FFFF
	load_mv => load_mv_fp,
	mode_in => partition_mode,
	mv_cost_on => mv_cost_on,
	mv_cost_in => p_cost_mv,
	candidate_mvx => candidate_mvx_fp,
	candidate_mvy => candidate_mvy_fp,
	reference_data_in => reference_data_in_fp,
	current_data_in => current_pixels_fp,
	residue_out => residue_out_fp,
	enable_fifo => enable_fifo_fp,
	reset_fifo => reset_fifo_fp,
	winner1 => winner1_fp,
	calculate_sad_done => calculate_sad_done_fp,
	distance_engine_active => distance_engine_active_fp,
   best_sad => best_sad_fp,
   best_mv => best_mv_fp

);

-- mv/sad selector

sad_selector_fp : sad_selector
generic map(integer_pipeline_count => CFG_PIPELINE_COUNT)
port map(
      clk =>clk,
	reset =>reset,
	clear =>clear,
      calculate_sad_done =>calculate_sad_done_fp, 
      update =>partition_done_fp,
	update_fp => update_fp,  -- end of iteraction
      best_eu => best_eu, --id of best execution unit
	active_pipelines => active_pipelines,
	best_sad => best_sad_fp,
	best_mv => best_mv_fp,
      rest_best_sad => rest_best_sad_fp,
	rest_best_mv => rest_best_mv_fp,
	best_sad_out => best_sad_out_fp,
	best_mv_out => best_mv_out_fp
);
 
best_sad_debug <= best_sad_fp;
best_mv_debug <= best_mv_fp; --debugging port
    
--qp distance engine

pipeline_qp_qp : if CFG_PIPELINE_COUNT_QP = 1 generate

sad_selector_qp1 : sad_selector_qp
port map (
      clk =>clk,
	reset =>reset,
	clear =>clear,
      calculate_sad_done =>calculate_sad_done_qp,
	active_pipelines => active_pipelines_qp,
      update =>all_done_fp, -- complete fp part set the stored sad
      update_qp =>update_qp,
        best_eu => best_eu_qp,
	best_sad =>best_sad_qp,
	best_mv =>best_mv_qp,
      rest_best_sad =>rest_best_sad_qp,
	rest_best_mv =>rest_best_mv_qp,
	best_sad_out =>best_sad_out_qp,
	best_mv_out =>best_mv_out_qp
);

distance_engine_qp : distance_engine64
generic map (qp_mode => '0')
port map(
	clk =>clk,
	clear =>clear,
	reset =>reset,
	enable =>rma_we_qp,
	update => update_qp,  -- instruction completes set the best sad register to FFFF
	load_mv => load_mv_qp,
	mode_in => partition_mode,
	mv_cost_on => mv_cost_on,
	mv_cost_in => p_cost_mv_qp,
	candidate_mvx => candidate_mvx_qp,
	candidate_mvy => candidate_mvy_qp,
	reference_data_in => reference_data_in_qp,
	current_data_in => current_pixels_qp,
	residue_out => residue_out_qp,
	enable_fifo => enable_fifo_qp,
	reset_fifo => reset_fifo_qp,
	winner1 => winner1_qp,
	calculate_sad_done => calculate_sad_done_qp,
	distance_engine_active => open,
   best_sad => best_sad_qp_distance_engine,
   best_mv => best_mv_qp

);

best_sad_qp <= best_sad_qp_distance_engine when all_done_fp = '0' else best_sad_out_fp; -- stored best sad fp in qp part


end generate;


no_qpgen8 : if CFG_PIPELINE_COUNT_QP = 0 generate

	distance_engine_address_qp <= (others => '0');
	residue_out_qp <= (others => '0');
	enable_fifo_qp <= '0';
	reset_fifo_qp <= '0';
	winner1_qp <= '0';
	calculate_sad_done_qp <= '0';
   	best_sad_qp <= (others => '0');
   	best_mv_qp <= (others => '0');

end generate;

next_rm_address_ready <= '1';

-- control the wiring of the memories

regs : process(clk,clear)

begin

 if (clear = '1') then
	mux_control_write <= '0';
	mux_control_read <= '0';
 elsif rising_edge(clk) then 
	if (reset = '1') then	
		mux_control_write <= '0';
		mux_control_read <= '0';
	elsif (start = '1') then
		mux_control_write <= not(mux_control_write);
	elsif (all_done_fp = '1') then
		mux_control_read <= not(mux_control_read);
	end if;
 end if;

end process regs; 


end;









       