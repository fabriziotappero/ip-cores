--------------------------------------------------------------------------------
-- Copyright (c) 1995-2012 Xilinx, Inc.  All rights reserved.
--------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor: Xilinx
-- \   \   \/     Version: P.40xd
--  \   \         Application: netgen
--  /   /         Filename: CCITT4_v2_synthesis.vhd
-- /___/   /\     Timestamp: Fri Dec  6 11:46:01 2013
-- \   \  /  \ 
--  \___\/\___\
--             
-- Command	: -intstyle ise -ar Structure -tm CCITT4_v2 -w -dir netgen/synthesis -ofmt vhdl -sim CCITT4_v2.ngc CCITT4_v2_synthesis.vhd 
-- Device	: xc3s1200e-4-fg320
-- Input file	: CCITT4_v2.ngc
-- Output file	: /home/aart/Documents/Programming/Xilinx_ise/tiff_comp_send_prj_14.3/netgen/synthesis/CCITT4_v2_synthesis.vhd
-- # of Entities	: 1
-- Design Name	: CCITT4_v2
-- Xilinx	: /opt/Xilinx/14.3/ISE_DS/ISE/
--             
-- Purpose:    
--     This VHDL netlist is a verification model and uses simulation 
--     primitives which may not represent the true implementation of the 
--     device, however the netlist is functionally correct and should not 
--     be modified. This file cannot be synthesized and should only be used 
--     with supported simulation tools.
--             
-- Reference:  
--     Command Line Tools User Guide, Chapter 23
--     Synthesis and Simulation Design Guide, Chapter 6
--             
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
use UNISIM.VPKG.ALL;

entity CCITT4_v2 is
  port (
    pclk_i : in STD_LOGIC := 'X'; 
    frame_finished_o : out STD_LOGIC; 
    fsync_i : in STD_LOGIC := 'X'; 
    pix_i : in STD_LOGIC := 'X'; 
    run_len_code_valid_o : out STD_LOGIC; 
    rsync_i : in STD_LOGIC := 'X'; 
    run_len_code_o : out STD_LOGIC_VECTOR ( 27 downto 0 ); 
    fax4_x : out STD_LOGIC_VECTOR ( 9 downto 0 ); 
    fax4_y : out STD_LOGIC_VECTOR ( 8 downto 0 ); 
    run_len_code_width_o : out STD_LOGIC_VECTOR ( 4 downto 0 ) 
  );
end CCITT4_v2;

architecture Structure of CCITT4_v2 is
  signal N1 : STD_LOGIC; 
  signal N10 : STD_LOGIC; 
  signal N101 : STD_LOGIC; 
  signal N103 : STD_LOGIC; 
  signal N105 : STD_LOGIC; 
  signal N111 : STD_LOGIC; 
  signal N113 : STD_LOGIC; 
  signal N115 : STD_LOGIC; 
  signal N117 : STD_LOGIC; 
  signal N119 : STD_LOGIC; 
  signal N12 : STD_LOGIC; 
  signal N121 : STD_LOGIC; 
  signal N123 : STD_LOGIC; 
  signal N125 : STD_LOGIC; 
  signal N127 : STD_LOGIC; 
  signal N133 : STD_LOGIC; 
  signal N142 : STD_LOGIC; 
  signal N144 : STD_LOGIC; 
  signal N146 : STD_LOGIC; 
  signal N148 : STD_LOGIC; 
  signal N160 : STD_LOGIC; 
  signal N161 : STD_LOGIC; 
  signal N165 : STD_LOGIC; 
  signal N167 : STD_LOGIC; 
  signal N172 : STD_LOGIC; 
  signal N174 : STD_LOGIC; 
  signal N176 : STD_LOGIC; 
  signal N177 : STD_LOGIC; 
  signal N179 : STD_LOGIC; 
  signal N18 : STD_LOGIC; 
  signal N180 : STD_LOGIC; 
  signal N182 : STD_LOGIC; 
  signal N184 : STD_LOGIC; 
  signal N2 : STD_LOGIC; 
  signal N208 : STD_LOGIC; 
  signal N218 : STD_LOGIC; 
  signal N220 : STD_LOGIC; 
  signal N221 : STD_LOGIC; 
  signal N223 : STD_LOGIC; 
  signal N225 : STD_LOGIC; 
  signal N227 : STD_LOGIC; 
  signal N229 : STD_LOGIC; 
  signal N231 : STD_LOGIC; 
  signal N233 : STD_LOGIC; 
  signal N235 : STD_LOGIC; 
  signal N237 : STD_LOGIC; 
  signal N239 : STD_LOGIC; 
  signal N24 : STD_LOGIC; 
  signal N240 : STD_LOGIC; 
  signal N242 : STD_LOGIC; 
  signal N243 : STD_LOGIC; 
  signal N245 : STD_LOGIC; 
  signal N246 : STD_LOGIC; 
  signal N248 : STD_LOGIC; 
  signal N249 : STD_LOGIC; 
  signal N251 : STD_LOGIC; 
  signal N252 : STD_LOGIC; 
  signal N254 : STD_LOGIC; 
  signal N255 : STD_LOGIC; 
  signal N257 : STD_LOGIC; 
  signal N258 : STD_LOGIC; 
  signal N26 : STD_LOGIC; 
  signal N260 : STD_LOGIC; 
  signal N261 : STD_LOGIC; 
  signal N263 : STD_LOGIC; 
  signal N264 : STD_LOGIC; 
  signal N266 : STD_LOGIC; 
  signal N267 : STD_LOGIC; 
  signal N269 : STD_LOGIC; 
  signal N271 : STD_LOGIC; 
  signal N285 : STD_LOGIC; 
  signal N287 : STD_LOGIC; 
  signal N288 : STD_LOGIC; 
  signal N305 : STD_LOGIC; 
  signal N315 : STD_LOGIC; 
  signal N317 : STD_LOGIC; 
  signal N319 : STD_LOGIC; 
  signal N333 : STD_LOGIC; 
  signal N337 : STD_LOGIC; 
  signal N339 : STD_LOGIC; 
  signal N341 : STD_LOGIC; 
  signal N343 : STD_LOGIC; 
  signal N345 : STD_LOGIC; 
  signal N349 : STD_LOGIC; 
  signal N351 : STD_LOGIC; 
  signal N355 : STD_LOGIC; 
  signal N359 : STD_LOGIC; 
  signal N361 : STD_LOGIC; 
  signal N363 : STD_LOGIC; 
  signal N365 : STD_LOGIC; 
  signal N367 : STD_LOGIC; 
  signal N369 : STD_LOGIC; 
  signal N371 : STD_LOGIC; 
  signal N373 : STD_LOGIC; 
  signal N375 : STD_LOGIC; 
  signal N377 : STD_LOGIC; 
  signal N381 : STD_LOGIC; 
  signal N383 : STD_LOGIC; 
  signal N385 : STD_LOGIC; 
  signal N387 : STD_LOGIC; 
  signal N388 : STD_LOGIC; 
  signal N389 : STD_LOGIC; 
  signal N390 : STD_LOGIC; 
  signal N391 : STD_LOGIC; 
  signal N392 : STD_LOGIC; 
  signal N393 : STD_LOGIC; 
  signal N394 : STD_LOGIC; 
  signal N395 : STD_LOGIC; 
  signal N396 : STD_LOGIC; 
  signal N397 : STD_LOGIC; 
  signal N398 : STD_LOGIC; 
  signal N399 : STD_LOGIC; 
  signal N400 : STD_LOGIC; 
  signal N401 : STD_LOGIC; 
  signal N402 : STD_LOGIC; 
  signal N403 : STD_LOGIC; 
  signal N404 : STD_LOGIC; 
  signal N405 : STD_LOGIC; 
  signal N406 : STD_LOGIC; 
  signal N407 : STD_LOGIC; 
  signal N408 : STD_LOGIC; 
  signal N409 : STD_LOGIC; 
  signal N410 : STD_LOGIC; 
  signal N411 : STD_LOGIC; 
  signal N412 : STD_LOGIC; 
  signal N413 : STD_LOGIC; 
  signal N414 : STD_LOGIC; 
  signal N415 : STD_LOGIC; 
  signal N416 : STD_LOGIC; 
  signal N417 : STD_LOGIC; 
  signal N418 : STD_LOGIC; 
  signal N419 : STD_LOGIC; 
  signal N420 : STD_LOGIC; 
  signal N421 : STD_LOGIC; 
  signal N422 : STD_LOGIC; 
  signal N423 : STD_LOGIC; 
  signal N424 : STD_LOGIC; 
  signal N425 : STD_LOGIC; 
  signal N426 : STD_LOGIC; 
  signal N427 : STD_LOGIC; 
  signal N428 : STD_LOGIC; 
  signal N429 : STD_LOGIC; 
  signal N430 : STD_LOGIC; 
  signal N431 : STD_LOGIC; 
  signal N432 : STD_LOGIC; 
  signal N433 : STD_LOGIC; 
  signal N434 : STD_LOGIC; 
  signal N435 : STD_LOGIC; 
  signal N436 : STD_LOGIC; 
  signal N437 : STD_LOGIC; 
  signal N438 : STD_LOGIC; 
  signal N439 : STD_LOGIC; 
  signal N440 : STD_LOGIC; 
  signal N441 : STD_LOGIC; 
  signal N442 : STD_LOGIC; 
  signal N443 : STD_LOGIC; 
  signal N444 : STD_LOGIC; 
  signal N445 : STD_LOGIC; 
  signal N446 : STD_LOGIC; 
  signal N447 : STD_LOGIC; 
  signal N448 : STD_LOGIC; 
  signal N449 : STD_LOGIC; 
  signal N450 : STD_LOGIC; 
  signal N451 : STD_LOGIC; 
  signal N452 : STD_LOGIC; 
  signal N453 : STD_LOGIC; 
  signal N454 : STD_LOGIC; 
  signal N455 : STD_LOGIC; 
  signal N456 : STD_LOGIC; 
  signal N457 : STD_LOGIC; 
  signal N458 : STD_LOGIC; 
  signal N459 : STD_LOGIC; 
  signal N460 : STD_LOGIC; 
  signal N461 : STD_LOGIC; 
  signal N462 : STD_LOGIC; 
  signal N463 : STD_LOGIC; 
  signal N464 : STD_LOGIC; 
  signal N465 : STD_LOGIC; 
  signal N466 : STD_LOGIC; 
  signal N467 : STD_LOGIC; 
  signal N468 : STD_LOGIC; 
  signal N469 : STD_LOGIC; 
  signal N470 : STD_LOGIC; 
  signal N471 : STD_LOGIC; 
  signal N472 : STD_LOGIC; 
  signal N473 : STD_LOGIC; 
  signal N474 : STD_LOGIC; 
  signal N475 : STD_LOGIC; 
  signal N476 : STD_LOGIC; 
  signal N477 : STD_LOGIC; 
  signal N478 : STD_LOGIC; 
  signal N479 : STD_LOGIC; 
  signal N480 : STD_LOGIC; 
  signal N481 : STD_LOGIC; 
  signal N482 : STD_LOGIC; 
  signal N483 : STD_LOGIC; 
  signal N484 : STD_LOGIC; 
  signal N485 : STD_LOGIC; 
  signal N486 : STD_LOGIC; 
  signal N487 : STD_LOGIC; 
  signal N488 : STD_LOGIC; 
  signal N489 : STD_LOGIC; 
  signal N490 : STD_LOGIC; 
  signal N491 : STD_LOGIC; 
  signal N492 : STD_LOGIC; 
  signal N493 : STD_LOGIC; 
  signal N494 : STD_LOGIC; 
  signal N495 : STD_LOGIC; 
  signal N496 : STD_LOGIC; 
  signal N497 : STD_LOGIC; 
  signal N498 : STD_LOGIC; 
  signal N56 : STD_LOGIC; 
  signal N7 : STD_LOGIC; 
  signal N73 : STD_LOGIC; 
  signal N75 : STD_LOGIC; 
  signal N77 : STD_LOGIC; 
  signal N79 : STD_LOGIC; 
  signal N80 : STD_LOGIC; 
  signal N82 : STD_LOGIC; 
  signal N83 : STD_LOGIC; 
  signal N85 : STD_LOGIC; 
  signal N87 : STD_LOGIC; 
  signal N89 : STD_LOGIC; 
  signal N9 : STD_LOGIC; 
  signal N93 : STD_LOGIC; 
  signal N95 : STD_LOGIC; 
  signal N97 : STD_LOGIC; 
  signal N99 : STD_LOGIC; 
  signal fax4_ins_EOF_prev_228 : STD_LOGIC; 
  signal fax4_ins_EOL : STD_LOGIC; 
  signal fax4_ins_EOL_prev_230 : STD_LOGIC; 
  signal fax4_ins_EOL_prev_prev_231 : STD_LOGIC; 
  signal fax4_ins_FIFO1_multi_read_ins_Mcount_read_pos_cy_1_rt_234 : STD_LOGIC; 
  signal fax4_ins_FIFO1_multi_read_ins_Mcount_read_pos_cy_2_rt_236 : STD_LOGIC; 
  signal fax4_ins_FIFO1_multi_read_ins_Mcount_read_pos_cy_3_rt_238 : STD_LOGIC; 
  signal fax4_ins_FIFO1_multi_read_ins_Mcount_read_pos_cy_4_rt_240 : STD_LOGIC; 
  signal fax4_ins_FIFO1_multi_read_ins_Mcount_read_pos_cy_5_rt_242 : STD_LOGIC; 
  signal fax4_ins_FIFO1_multi_read_ins_Mcount_read_pos_cy_6_rt_244 : STD_LOGIC; 
  signal fax4_ins_FIFO1_multi_read_ins_Mcount_read_pos_cy_7_rt_246 : STD_LOGIC; 
  signal fax4_ins_FIFO1_multi_read_ins_Mcount_read_pos_cy_8_rt_248 : STD_LOGIC; 
  signal fax4_ins_FIFO1_multi_read_ins_Mcount_read_pos_eqn_0 : STD_LOGIC; 
  signal fax4_ins_FIFO1_multi_read_ins_Mcount_read_pos_eqn_1 : STD_LOGIC; 
  signal fax4_ins_FIFO1_multi_read_ins_Mcount_read_pos_eqn_2 : STD_LOGIC; 
  signal fax4_ins_FIFO1_multi_read_ins_Mcount_read_pos_eqn_3 : STD_LOGIC; 
  signal fax4_ins_FIFO1_multi_read_ins_Mcount_read_pos_eqn_4 : STD_LOGIC; 
  signal fax4_ins_FIFO1_multi_read_ins_Mcount_read_pos_eqn_5 : STD_LOGIC; 
  signal fax4_ins_FIFO1_multi_read_ins_Mcount_read_pos_eqn_6 : STD_LOGIC; 
  signal fax4_ins_FIFO1_multi_read_ins_Mcount_read_pos_eqn_7 : STD_LOGIC; 
  signal fax4_ins_FIFO1_multi_read_ins_Mcount_read_pos_eqn_8 : STD_LOGIC; 
  signal fax4_ins_FIFO1_multi_read_ins_Mcount_read_pos_eqn_9 : STD_LOGIC; 
  signal fax4_ins_FIFO1_multi_read_ins_Mcount_read_pos_xor_9_rt_260 : STD_LOGIC; 
  signal fax4_ins_FIFO1_multi_read_ins_Mcount_write_pos_cy_1_rt_282 : STD_LOGIC; 
  signal fax4_ins_FIFO1_multi_read_ins_Mcount_write_pos_cy_2_rt_284 : STD_LOGIC; 
  signal fax4_ins_FIFO1_multi_read_ins_Mcount_write_pos_cy_3_rt_286 : STD_LOGIC; 
  signal fax4_ins_FIFO1_multi_read_ins_Mcount_write_pos_cy_4_rt_288 : STD_LOGIC; 
  signal fax4_ins_FIFO1_multi_read_ins_Mcount_write_pos_cy_5_rt_290 : STD_LOGIC; 
  signal fax4_ins_FIFO1_multi_read_ins_Mcount_write_pos_cy_6_rt_292 : STD_LOGIC; 
  signal fax4_ins_FIFO1_multi_read_ins_Mcount_write_pos_cy_7_rt_294 : STD_LOGIC; 
  signal fax4_ins_FIFO1_multi_read_ins_Mcount_write_pos_cy_8_rt_296 : STD_LOGIC; 
  signal fax4_ins_FIFO1_multi_read_ins_Mcount_write_pos_eqn_0 : STD_LOGIC; 
  signal fax4_ins_FIFO1_multi_read_ins_Mcount_write_pos_eqn_1 : STD_LOGIC; 
  signal fax4_ins_FIFO1_multi_read_ins_Mcount_write_pos_eqn_2 : STD_LOGIC; 
  signal fax4_ins_FIFO1_multi_read_ins_Mcount_write_pos_eqn_3 : STD_LOGIC; 
  signal fax4_ins_FIFO1_multi_read_ins_Mcount_write_pos_eqn_4 : STD_LOGIC; 
  signal fax4_ins_FIFO1_multi_read_ins_Mcount_write_pos_eqn_5 : STD_LOGIC; 
  signal fax4_ins_FIFO1_multi_read_ins_Mcount_write_pos_eqn_6 : STD_LOGIC; 
  signal fax4_ins_FIFO1_multi_read_ins_Mcount_write_pos_eqn_7 : STD_LOGIC; 
  signal fax4_ins_FIFO1_multi_read_ins_Mcount_write_pos_eqn_8 : STD_LOGIC; 
  signal fax4_ins_FIFO1_multi_read_ins_Mcount_write_pos_eqn_9 : STD_LOGIC; 
  signal fax4_ins_FIFO1_multi_read_ins_Mcount_write_pos_xor_9_rt_308 : STD_LOGIC; 
  signal fax4_ins_FIFO1_multi_read_ins_N11 : STD_LOGIC; 
  signal fax4_ins_FIFO1_multi_read_ins_N4 : STD_LOGIC; 
  signal fax4_ins_FIFO1_multi_read_ins_N7 : STD_LOGIC; 
  signal fax4_ins_FIFO1_multi_read_ins_N8 : STD_LOGIC; 
  signal fax4_ins_FIFO1_multi_read_ins_Result_0_1 : STD_LOGIC; 
  signal fax4_ins_FIFO1_multi_read_ins_Result_0_2 : STD_LOGIC; 
  signal fax4_ins_FIFO1_multi_read_ins_Result_1_1 : STD_LOGIC; 
  signal fax4_ins_FIFO1_multi_read_ins_Result_1_2 : STD_LOGIC; 
  signal fax4_ins_FIFO1_multi_read_ins_Result_2_1 : STD_LOGIC; 
  signal fax4_ins_FIFO1_multi_read_ins_Result_2_2 : STD_LOGIC; 
  signal fax4_ins_FIFO1_multi_read_ins_Result_3_1 : STD_LOGIC; 
  signal fax4_ins_FIFO1_multi_read_ins_Result_3_2 : STD_LOGIC; 
  signal fax4_ins_FIFO1_multi_read_ins_Result_4_1 : STD_LOGIC; 
  signal fax4_ins_FIFO1_multi_read_ins_Result_4_2 : STD_LOGIC; 
  signal fax4_ins_FIFO1_multi_read_ins_Result_5_1 : STD_LOGIC; 
  signal fax4_ins_FIFO1_multi_read_ins_Result_5_2 : STD_LOGIC; 
  signal fax4_ins_FIFO1_multi_read_ins_Result_6_1 : STD_LOGIC; 
  signal fax4_ins_FIFO1_multi_read_ins_Result_6_2 : STD_LOGIC; 
  signal fax4_ins_FIFO1_multi_read_ins_Result_7_1 : STD_LOGIC; 
  signal fax4_ins_FIFO1_multi_read_ins_Result_7_2 : STD_LOGIC; 
  signal fax4_ins_FIFO1_multi_read_ins_Result_8_1 : STD_LOGIC; 
  signal fax4_ins_FIFO1_multi_read_ins_Result_8_2 : STD_LOGIC; 
  signal fax4_ins_FIFO1_multi_read_ins_Result_9_1 : STD_LOGIC; 
  signal fax4_ins_FIFO1_multi_read_ins_Result_9_2 : STD_LOGIC; 
  signal fax4_ins_FIFO1_multi_read_ins_latch1 : STD_LOGIC; 
  signal fax4_ins_FIFO1_multi_read_ins_latch2 : STD_LOGIC; 
  signal fax4_ins_FIFO1_multi_read_ins_latch3 : STD_LOGIC; 
  signal fax4_ins_FIFO1_multi_read_ins_mem_rd_387 : STD_LOGIC; 
  signal fax4_ins_FIFO1_multi_read_ins_mux1_to_white : STD_LOGIC; 
  signal fax4_ins_FIFO1_multi_read_ins_mux1_valid : STD_LOGIC; 
  signal fax4_ins_FIFO1_multi_read_ins_mux2 : STD_LOGIC; 
  signal fax4_ins_FIFO1_multi_read_ins_mux2_to_white : STD_LOGIC; 
  signal fax4_ins_FIFO1_multi_read_ins_mux2_valid : STD_LOGIC; 
  signal fax4_ins_FIFO1_multi_read_ins_mux3 : STD_LOGIC; 
  signal fax4_ins_FIFO1_multi_read_ins_mux3_to_white : STD_LOGIC; 
  signal fax4_ins_FIFO1_multi_read_ins_mux3_valid : STD_LOGIC; 
  signal fax4_ins_FIFO1_multi_read_ins_read_as_last_operation_426 : STD_LOGIC; 
  signal fax4_ins_FIFO1_multi_read_ins_read_as_last_operation_rstpot_427 : STD_LOGIC; 
  signal fax4_ins_FIFO1_multi_read_ins_read_pos_cmp_eq0000 : STD_LOGIC; 
  signal fax4_ins_FIFO1_multi_read_ins_read_pos_cmp_eq000015_439 : STD_LOGIC; 
  signal fax4_ins_FIFO1_multi_read_ins_read_pos_cmp_eq00007_440 : STD_LOGIC; 
  signal fax4_ins_FIFO1_multi_read_ins_to_white1_o_441 : STD_LOGIC; 
  signal fax4_ins_FIFO1_multi_read_ins_to_white2_o_442 : STD_LOGIC; 
  signal fax4_ins_FIFO1_multi_read_ins_to_white3_o_443 : STD_LOGIC; 
  signal fax4_ins_FIFO1_multi_read_ins_used_not0002_454 : STD_LOGIC; 
  signal fax4_ins_FIFO1_multi_read_ins_used_not0003_inv : STD_LOGIC; 
  signal fax4_ins_FIFO1_multi_read_ins_valid1_o_456 : STD_LOGIC; 
  signal fax4_ins_FIFO1_multi_read_ins_valid2_o_457 : STD_LOGIC; 
  signal fax4_ins_FIFO1_multi_read_ins_valid3_o_458 : STD_LOGIC; 
  signal fax4_ins_FIFO1_multi_read_ins_wr_459 : STD_LOGIC; 
  signal fax4_ins_FIFO1_multi_read_ins_write_pos_cmp_eq0000 : STD_LOGIC; 
  signal fax4_ins_FIFO1_multi_read_ins_write_pos_cmp_eq000015_471 : STD_LOGIC; 
  signal fax4_ins_FIFO1_multi_read_ins_write_pos_cmp_eq00007_472 : STD_LOGIC; 
  signal fax4_ins_FIFO2_multi_read_ins_Mcount_read_pos_cy_1_rt_475 : STD_LOGIC; 
  signal fax4_ins_FIFO2_multi_read_ins_Mcount_read_pos_cy_2_rt_477 : STD_LOGIC; 
  signal fax4_ins_FIFO2_multi_read_ins_Mcount_read_pos_cy_3_rt_479 : STD_LOGIC; 
  signal fax4_ins_FIFO2_multi_read_ins_Mcount_read_pos_cy_4_rt_481 : STD_LOGIC; 
  signal fax4_ins_FIFO2_multi_read_ins_Mcount_read_pos_cy_5_rt_483 : STD_LOGIC; 
  signal fax4_ins_FIFO2_multi_read_ins_Mcount_read_pos_cy_6_rt_485 : STD_LOGIC; 
  signal fax4_ins_FIFO2_multi_read_ins_Mcount_read_pos_cy_7_rt_487 : STD_LOGIC; 
  signal fax4_ins_FIFO2_multi_read_ins_Mcount_read_pos_cy_8_rt_489 : STD_LOGIC; 
  signal fax4_ins_FIFO2_multi_read_ins_Mcount_read_pos_eqn_0 : STD_LOGIC; 
  signal fax4_ins_FIFO2_multi_read_ins_Mcount_read_pos_eqn_1 : STD_LOGIC; 
  signal fax4_ins_FIFO2_multi_read_ins_Mcount_read_pos_eqn_2 : STD_LOGIC; 
  signal fax4_ins_FIFO2_multi_read_ins_Mcount_read_pos_eqn_3 : STD_LOGIC; 
  signal fax4_ins_FIFO2_multi_read_ins_Mcount_read_pos_eqn_4 : STD_LOGIC; 
  signal fax4_ins_FIFO2_multi_read_ins_Mcount_read_pos_eqn_5 : STD_LOGIC; 
  signal fax4_ins_FIFO2_multi_read_ins_Mcount_read_pos_eqn_6 : STD_LOGIC; 
  signal fax4_ins_FIFO2_multi_read_ins_Mcount_read_pos_eqn_7 : STD_LOGIC; 
  signal fax4_ins_FIFO2_multi_read_ins_Mcount_read_pos_eqn_8 : STD_LOGIC; 
  signal fax4_ins_FIFO2_multi_read_ins_Mcount_read_pos_eqn_9 : STD_LOGIC; 
  signal fax4_ins_FIFO2_multi_read_ins_Mcount_read_pos_xor_9_rt_501 : STD_LOGIC; 
  signal fax4_ins_FIFO2_multi_read_ins_Mcount_write_pos_cy_1_rt_523 : STD_LOGIC; 
  signal fax4_ins_FIFO2_multi_read_ins_Mcount_write_pos_cy_2_rt_525 : STD_LOGIC; 
  signal fax4_ins_FIFO2_multi_read_ins_Mcount_write_pos_cy_3_rt_527 : STD_LOGIC; 
  signal fax4_ins_FIFO2_multi_read_ins_Mcount_write_pos_cy_4_rt_529 : STD_LOGIC; 
  signal fax4_ins_FIFO2_multi_read_ins_Mcount_write_pos_cy_5_rt_531 : STD_LOGIC; 
  signal fax4_ins_FIFO2_multi_read_ins_Mcount_write_pos_cy_6_rt_533 : STD_LOGIC; 
  signal fax4_ins_FIFO2_multi_read_ins_Mcount_write_pos_cy_7_rt_535 : STD_LOGIC; 
  signal fax4_ins_FIFO2_multi_read_ins_Mcount_write_pos_cy_8_rt_537 : STD_LOGIC; 
  signal fax4_ins_FIFO2_multi_read_ins_Mcount_write_pos_eqn_0 : STD_LOGIC; 
  signal fax4_ins_FIFO2_multi_read_ins_Mcount_write_pos_eqn_1 : STD_LOGIC; 
  signal fax4_ins_FIFO2_multi_read_ins_Mcount_write_pos_eqn_2 : STD_LOGIC; 
  signal fax4_ins_FIFO2_multi_read_ins_Mcount_write_pos_eqn_3 : STD_LOGIC; 
  signal fax4_ins_FIFO2_multi_read_ins_Mcount_write_pos_eqn_4 : STD_LOGIC; 
  signal fax4_ins_FIFO2_multi_read_ins_Mcount_write_pos_eqn_5 : STD_LOGIC; 
  signal fax4_ins_FIFO2_multi_read_ins_Mcount_write_pos_eqn_6 : STD_LOGIC; 
  signal fax4_ins_FIFO2_multi_read_ins_Mcount_write_pos_eqn_7 : STD_LOGIC; 
  signal fax4_ins_FIFO2_multi_read_ins_Mcount_write_pos_eqn_8 : STD_LOGIC; 
  signal fax4_ins_FIFO2_multi_read_ins_Mcount_write_pos_eqn_9 : STD_LOGIC; 
  signal fax4_ins_FIFO2_multi_read_ins_Mcount_write_pos_xor_9_rt_549 : STD_LOGIC; 
  signal fax4_ins_FIFO2_multi_read_ins_N11 : STD_LOGIC; 
  signal fax4_ins_FIFO2_multi_read_ins_N4 : STD_LOGIC; 
  signal fax4_ins_FIFO2_multi_read_ins_N7 : STD_LOGIC; 
  signal fax4_ins_FIFO2_multi_read_ins_N8 : STD_LOGIC; 
  signal fax4_ins_FIFO2_multi_read_ins_Result_0_1 : STD_LOGIC; 
  signal fax4_ins_FIFO2_multi_read_ins_Result_0_2 : STD_LOGIC; 
  signal fax4_ins_FIFO2_multi_read_ins_Result_1_1 : STD_LOGIC; 
  signal fax4_ins_FIFO2_multi_read_ins_Result_1_2 : STD_LOGIC; 
  signal fax4_ins_FIFO2_multi_read_ins_Result_2_1 : STD_LOGIC; 
  signal fax4_ins_FIFO2_multi_read_ins_Result_2_2 : STD_LOGIC; 
  signal fax4_ins_FIFO2_multi_read_ins_Result_3_1 : STD_LOGIC; 
  signal fax4_ins_FIFO2_multi_read_ins_Result_3_2 : STD_LOGIC; 
  signal fax4_ins_FIFO2_multi_read_ins_Result_4_1 : STD_LOGIC; 
  signal fax4_ins_FIFO2_multi_read_ins_Result_4_2 : STD_LOGIC; 
  signal fax4_ins_FIFO2_multi_read_ins_Result_5_1 : STD_LOGIC; 
  signal fax4_ins_FIFO2_multi_read_ins_Result_5_2 : STD_LOGIC; 
  signal fax4_ins_FIFO2_multi_read_ins_Result_6_1 : STD_LOGIC; 
  signal fax4_ins_FIFO2_multi_read_ins_Result_6_2 : STD_LOGIC; 
  signal fax4_ins_FIFO2_multi_read_ins_Result_7_1 : STD_LOGIC; 
  signal fax4_ins_FIFO2_multi_read_ins_Result_7_2 : STD_LOGIC; 
  signal fax4_ins_FIFO2_multi_read_ins_Result_8_1 : STD_LOGIC; 
  signal fax4_ins_FIFO2_multi_read_ins_Result_8_2 : STD_LOGIC; 
  signal fax4_ins_FIFO2_multi_read_ins_Result_9_1 : STD_LOGIC; 
  signal fax4_ins_FIFO2_multi_read_ins_Result_9_2 : STD_LOGIC; 
  signal fax4_ins_FIFO2_multi_read_ins_latch1 : STD_LOGIC; 
  signal fax4_ins_FIFO2_multi_read_ins_latch2 : STD_LOGIC; 
  signal fax4_ins_FIFO2_multi_read_ins_latch3 : STD_LOGIC; 
  signal fax4_ins_FIFO2_multi_read_ins_mem_rd_628 : STD_LOGIC; 
  signal fax4_ins_FIFO2_multi_read_ins_mux1_to_white : STD_LOGIC; 
  signal fax4_ins_FIFO2_multi_read_ins_mux1_valid : STD_LOGIC; 
  signal fax4_ins_FIFO2_multi_read_ins_mux2 : STD_LOGIC; 
  signal fax4_ins_FIFO2_multi_read_ins_mux2_to_white : STD_LOGIC; 
  signal fax4_ins_FIFO2_multi_read_ins_mux2_valid : STD_LOGIC; 
  signal fax4_ins_FIFO2_multi_read_ins_mux3 : STD_LOGIC; 
  signal fax4_ins_FIFO2_multi_read_ins_mux3_and0000 : STD_LOGIC; 
  signal fax4_ins_FIFO2_multi_read_ins_mux3_to_white : STD_LOGIC; 
  signal fax4_ins_FIFO2_multi_read_ins_mux3_valid : STD_LOGIC; 
  signal fax4_ins_FIFO2_multi_read_ins_read_as_last_operation_668 : STD_LOGIC; 
  signal fax4_ins_FIFO2_multi_read_ins_read_as_last_operation_rstpot_669 : STD_LOGIC; 
  signal fax4_ins_FIFO2_multi_read_ins_read_pos_cmp_eq0000 : STD_LOGIC; 
  signal fax4_ins_FIFO2_multi_read_ins_read_pos_cmp_eq000015_681 : STD_LOGIC; 
  signal fax4_ins_FIFO2_multi_read_ins_read_pos_cmp_eq00007_682 : STD_LOGIC; 
  signal fax4_ins_FIFO2_multi_read_ins_to_white1_o_683 : STD_LOGIC; 
  signal fax4_ins_FIFO2_multi_read_ins_to_white2_o_684 : STD_LOGIC; 
  signal fax4_ins_FIFO2_multi_read_ins_to_white3_o_685 : STD_LOGIC; 
  signal fax4_ins_FIFO2_multi_read_ins_used_not0002_696 : STD_LOGIC; 
  signal fax4_ins_FIFO2_multi_read_ins_used_not0003_inv : STD_LOGIC; 
  signal fax4_ins_FIFO2_multi_read_ins_valid1_o_698 : STD_LOGIC; 
  signal fax4_ins_FIFO2_multi_read_ins_valid2_o_699 : STD_LOGIC; 
  signal fax4_ins_FIFO2_multi_read_ins_valid3_o_700 : STD_LOGIC; 
  signal fax4_ins_FIFO2_multi_read_ins_wr : STD_LOGIC; 
  signal fax4_ins_FIFO2_multi_read_ins_wr1_702 : STD_LOGIC; 
  signal fax4_ins_FIFO2_multi_read_ins_write_pos_cmp_eq0000 : STD_LOGIC; 
  signal fax4_ins_FIFO2_multi_read_ins_write_pos_cmp_eq000015_714 : STD_LOGIC; 
  signal fax4_ins_FIFO2_multi_read_ins_write_pos_cmp_eq00007_715 : STD_LOGIC; 
  signal fax4_ins_Madd_a1b1_addsub0001_cy_1_rt_717 : STD_LOGIC; 
  signal fax4_ins_Madd_a1b1_addsub0001_cy_4_rt_721 : STD_LOGIC; 
  signal fax4_ins_Madd_a1b1_addsub0001_cy_5_rt_723 : STD_LOGIC; 
  signal fax4_ins_Madd_a1b1_addsub0001_cy_6_rt_725 : STD_LOGIC; 
  signal fax4_ins_Madd_a1b1_addsub0001_cy_7_rt_727 : STD_LOGIC; 
  signal fax4_ins_Madd_a1b1_addsub0001_cy_9_rt_730 : STD_LOGIC; 
  signal fax4_ins_Madd_fifo_rd_addsub0000_cy_1_rt_733 : STD_LOGIC; 
  signal fax4_ins_Madd_fifo_rd_addsub0000_cy_2_rt_735 : STD_LOGIC; 
  signal fax4_ins_Madd_fifo_rd_addsub0000_cy_3_rt_737 : STD_LOGIC; 
  signal fax4_ins_Madd_fifo_rd_addsub0000_cy_4_rt_739 : STD_LOGIC; 
  signal fax4_ins_Madd_fifo_rd_addsub0000_cy_5_rt_741 : STD_LOGIC; 
  signal fax4_ins_Madd_fifo_rd_addsub0000_cy_6_rt_743 : STD_LOGIC; 
  signal fax4_ins_Madd_fifo_rd_addsub0000_cy_7_rt_745 : STD_LOGIC; 
  signal fax4_ins_Madd_fifo_rd_addsub0000_cy_8_rt_747 : STD_LOGIC; 
  signal fax4_ins_Madd_fifo_rd_addsub0000_xor_9_rt_749 : STD_LOGIC; 
  signal fax4_ins_N01 : STD_LOGIC; 
  signal fax4_ins_N13 : STD_LOGIC; 
  signal fax4_ins_N15 : STD_LOGIC; 
  signal fax4_ins_N19 : STD_LOGIC; 
  signal fax4_ins_N20 : STD_LOGIC; 
  signal fax4_ins_N53 : STD_LOGIC; 
  signal fax4_ins_a0_to_white_946 : STD_LOGIC; 
  signal fax4_ins_a0_to_white_mux0000 : STD_LOGIC; 
  signal fax4_ins_a0_to_white_mux000026_948 : STD_LOGIC; 
  signal fax4_ins_a0_to_white_mux00007_949 : STD_LOGIC; 
  signal fax4_ins_a0_value_o_950 : STD_LOGIC; 
  signal fax4_ins_a1b1_not0000_2_Q : STD_LOGIC; 
  signal fax4_ins_a1b1_not0000_3_Q : STD_LOGIC; 
  signal fax4_ins_a1b1_not0000_8_Q : STD_LOGIC; 
  signal fax4_ins_b1_mux0004_0_18_1027 : STD_LOGIC; 
  signal fax4_ins_b1_mux0004_1_12_1029 : STD_LOGIC; 
  signal fax4_ins_b1_mux0004_1_42 : STD_LOGIC; 
  signal fax4_ins_b1_mux0004_1_421_1031 : STD_LOGIC; 
  signal fax4_ins_b1_mux0004_2_12_1033 : STD_LOGIC; 
  signal fax4_ins_b1_mux0004_2_42 : STD_LOGIC; 
  signal fax4_ins_b1_mux0004_2_421_1035 : STD_LOGIC; 
  signal fax4_ins_b1_mux0004_3_12_1037 : STD_LOGIC; 
  signal fax4_ins_b1_mux0004_3_42 : STD_LOGIC; 
  signal fax4_ins_b1_mux0004_3_421_1039 : STD_LOGIC; 
  signal fax4_ins_b1_mux0004_4_18_1041 : STD_LOGIC; 
  signal fax4_ins_b1_mux0004_5_18_1043 : STD_LOGIC; 
  signal fax4_ins_b1_mux0004_6_18_1045 : STD_LOGIC; 
  signal fax4_ins_b1_mux0004_7_18_1047 : STD_LOGIC; 
  signal fax4_ins_b1_mux0004_8_12_1049 : STD_LOGIC; 
  signal fax4_ins_b1_mux0004_8_42 : STD_LOGIC; 
  signal fax4_ins_b1_mux0004_8_421_1051 : STD_LOGIC; 
  signal fax4_ins_b1_mux0004_9_18_1053 : STD_LOGIC; 
  signal fax4_ins_b2_mux0004_0_10_1065 : STD_LOGIC; 
  signal fax4_ins_b2_mux0004_0_36_1066 : STD_LOGIC; 
  signal fax4_ins_b2_mux0004_1_10_1068 : STD_LOGIC; 
  signal fax4_ins_b2_mux0004_1_33_1069 : STD_LOGIC; 
  signal fax4_ins_b2_mux0004_2_10_1071 : STD_LOGIC; 
  signal fax4_ins_b2_mux0004_2_33_1072 : STD_LOGIC; 
  signal fax4_ins_b2_mux0004_3_10_1074 : STD_LOGIC; 
  signal fax4_ins_b2_mux0004_3_33_1075 : STD_LOGIC; 
  signal fax4_ins_b2_mux0004_4_10_1077 : STD_LOGIC; 
  signal fax4_ins_b2_mux0004_4_36_1078 : STD_LOGIC; 
  signal fax4_ins_b2_mux0004_5_10_1080 : STD_LOGIC; 
  signal fax4_ins_b2_mux0004_5_36_1081 : STD_LOGIC; 
  signal fax4_ins_b2_mux0004_6_10_1083 : STD_LOGIC; 
  signal fax4_ins_b2_mux0004_6_36_1084 : STD_LOGIC; 
  signal fax4_ins_b2_mux0004_7_10_1086 : STD_LOGIC; 
  signal fax4_ins_b2_mux0004_7_36_1087 : STD_LOGIC; 
  signal fax4_ins_b2_mux0004_8_10_1089 : STD_LOGIC; 
  signal fax4_ins_b2_mux0004_8_33_1090 : STD_LOGIC; 
  signal fax4_ins_b2_mux0004_9_10_1092 : STD_LOGIC; 
  signal fax4_ins_b2_mux0004_9_36_1093 : STD_LOGIC; 
  signal fax4_ins_b2_to_white_1094 : STD_LOGIC; 
  signal fax4_ins_b2_to_white_and0000 : STD_LOGIC; 
  signal fax4_ins_b2_to_white_and0001 : STD_LOGIC; 
  signal fax4_ins_b2_to_white_mux0004 : STD_LOGIC; 
  signal fax4_ins_b2_to_white_mux000410_1098 : STD_LOGIC; 
  signal fax4_ins_b2_to_white_mux000452_1099 : STD_LOGIC; 
  signal fax4_ins_counter_xy_v2_ins_cnt_x_en : STD_LOGIC; 
  signal fax4_ins_counter_xy_v2_ins_cnt_x_overflow_prev_1101 : STD_LOGIC; 
  signal fax4_ins_counter_xy_v2_ins_cnt_x_reset_1102 : STD_LOGIC; 
  signal fax4_ins_counter_xy_v2_ins_cnt_x_reset_or0000 : STD_LOGIC; 
  signal fax4_ins_counter_xy_v2_ins_cnt_y_overflow_prev_1104 : STD_LOGIC; 
  signal fax4_ins_counter_xy_v2_ins_cnt_y_reset_1105 : STD_LOGIC; 
  signal fax4_ins_counter_xy_v2_ins_cnt_y_reset_or0000 : STD_LOGIC; 
  signal fax4_ins_counter_xy_v2_ins_counter_x_ins_Madd_cnt_addsub0000_cy_1_rt_1109 : STD_LOGIC; 
  signal fax4_ins_counter_xy_v2_ins_counter_x_ins_Madd_cnt_addsub0000_cy_2_rt_1111 : STD_LOGIC; 
  signal fax4_ins_counter_xy_v2_ins_counter_x_ins_Madd_cnt_addsub0000_cy_3_rt_1113 : STD_LOGIC; 
  signal fax4_ins_counter_xy_v2_ins_counter_x_ins_Madd_cnt_addsub0000_cy_4_rt_1115 : STD_LOGIC; 
  signal fax4_ins_counter_xy_v2_ins_counter_x_ins_Madd_cnt_addsub0000_cy_5_rt_1117 : STD_LOGIC; 
  signal fax4_ins_counter_xy_v2_ins_counter_x_ins_Madd_cnt_addsub0000_cy_6_rt_1119 : STD_LOGIC; 
  signal fax4_ins_counter_xy_v2_ins_counter_x_ins_Madd_cnt_addsub0000_cy_7_rt_1121 : STD_LOGIC; 
  signal fax4_ins_counter_xy_v2_ins_counter_x_ins_Madd_cnt_addsub0000_cy_8_rt_1123 : STD_LOGIC; 
  signal fax4_ins_counter_xy_v2_ins_counter_x_ins_Madd_cnt_addsub0000_xor_9_rt_1125 : STD_LOGIC; 
  signal fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt_cmp_ge0000 : STD_LOGIC; 
  signal fax4_ins_counter_xy_v2_ins_counter_x_ins_overflow_o_1157 : STD_LOGIC; 
  signal fax4_ins_counter_xy_v2_ins_counter_x_ins_overflow_o_mux0002 : STD_LOGIC; 
  signal fax4_ins_counter_xy_v2_ins_counter_y_ins_Madd_cnt_addsub0000_cy_1_rt_1161 : STD_LOGIC; 
  signal fax4_ins_counter_xy_v2_ins_counter_y_ins_Madd_cnt_addsub0000_cy_2_rt_1163 : STD_LOGIC; 
  signal fax4_ins_counter_xy_v2_ins_counter_y_ins_Madd_cnt_addsub0000_cy_3_rt_1165 : STD_LOGIC; 
  signal fax4_ins_counter_xy_v2_ins_counter_y_ins_Madd_cnt_addsub0000_cy_4_rt_1167 : STD_LOGIC; 
  signal fax4_ins_counter_xy_v2_ins_counter_y_ins_Madd_cnt_addsub0000_cy_5_rt_1169 : STD_LOGIC; 
  signal fax4_ins_counter_xy_v2_ins_counter_y_ins_Madd_cnt_addsub0000_cy_6_rt_1171 : STD_LOGIC; 
  signal fax4_ins_counter_xy_v2_ins_counter_y_ins_Madd_cnt_addsub0000_cy_7_rt_1173 : STD_LOGIC; 
  signal fax4_ins_counter_xy_v2_ins_counter_y_ins_Madd_cnt_addsub0000_xor_8_rt_1175 : STD_LOGIC; 
  signal fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt_cmp_ge0000 : STD_LOGIC; 
  signal fax4_ins_counter_xy_v2_ins_counter_y_ins_overflow_o_1204 : STD_LOGIC; 
  signal fax4_ins_counter_xy_v2_ins_counter_y_ins_overflow_o_mux0002 : STD_LOGIC; 
  signal fax4_ins_counter_xy_v2_ins_frame_valid_1206 : STD_LOGIC; 
  signal fax4_ins_counter_xy_v2_ins_frame_valid_and0000 : STD_LOGIC; 
  signal fax4_ins_counter_xy_v2_ins_frame_valid_and0001 : STD_LOGIC; 
  signal fax4_ins_counter_xy_v2_ins_fsync_i_prev_1209 : STD_LOGIC; 
  signal fax4_ins_counter_xy_v2_ins_line_valid_1210 : STD_LOGIC; 
  signal fax4_ins_counter_xy_v2_ins_line_valid_and0000 : STD_LOGIC; 
  signal fax4_ins_counter_xy_v2_ins_rsync_i_prev_1212 : STD_LOGIC; 
  signal fax4_ins_fifo1_rd : STD_LOGIC; 
  signal fax4_ins_fifo1_wr : STD_LOGIC; 
  signal fax4_ins_fifo2_rd : STD_LOGIC; 
  signal fax4_ins_fifo2_wr : STD_LOGIC; 
  signal fax4_ins_fifo_out1_to_white : STD_LOGIC; 
  signal fax4_ins_fifo_out2_valid : STD_LOGIC; 
  signal fax4_ins_fifo_out_prev1_to_white_1239 : STD_LOGIC; 
  signal fax4_ins_fifo_out_prev1_valid_1240 : STD_LOGIC; 
  signal fax4_ins_fifo_out_prev1_valid_mux0001 : STD_LOGIC; 
  signal fax4_ins_fifo_out_prev2_to_white_1252 : STD_LOGIC; 
  signal fax4_ins_fifo_out_prev2_valid_1253 : STD_LOGIC; 
  signal fax4_ins_fifo_out_prev2_valid_mux0001 : STD_LOGIC; 
  signal fax4_ins_fifo_rd : STD_LOGIC; 
  signal fax4_ins_fifo_rd0_1266 : STD_LOGIC; 
  signal fax4_ins_fifo_rd22_1267 : STD_LOGIC; 
  signal fax4_ins_fifo_rd3_1268 : STD_LOGIC; 
  signal fax4_ins_fifo_sel_prev_1279 : STD_LOGIC; 
  signal fax4_ins_load_a0 : STD_LOGIC; 
  signal fax4_ins_load_a1_or0000 : STD_LOGIC; 
  signal fax4_ins_load_a1_or0001 : STD_LOGIC; 
  signal fax4_ins_load_a2 : STD_LOGIC; 
  signal fax4_ins_load_mux_a0_1284 : STD_LOGIC; 
  signal fax4_ins_load_mux_b_1285 : STD_LOGIC; 
  signal fax4_ins_mode_indicator_o_0_rstpot_1287 : STD_LOGIC; 
  signal fax4_ins_mode_indicator_o_1_rstpot_1289 : STD_LOGIC; 
  signal fax4_ins_mode_indicator_o_2_rstpot_1291 : STD_LOGIC; 
  signal fax4_ins_mode_indicator_o_2_rstpot_SW1 : STD_LOGIC; 
  signal fax4_ins_mode_indicator_o_2_rstpot_SW11_1293 : STD_LOGIC; 
  signal fax4_ins_mode_indicator_o_3_rstpot_1295 : STD_LOGIC; 
  signal fax4_ins_mode_indicator_o_mux0001_2_232_1296 : STD_LOGIC; 
  signal fax4_ins_mode_indicator_o_mux0001_2_261_1297 : STD_LOGIC; 
  signal fax4_ins_mode_indicator_o_mux0001_2_3111_1298 : STD_LOGIC; 
  signal fax4_ins_mode_indicator_o_mux0001_2_341_1299 : STD_LOGIC; 
  signal fax4_ins_mode_indicator_o_mux0001_2_36_1300 : STD_LOGIC; 
  signal fax4_ins_mode_indicator_o_mux0001_3_9_1302 : STD_LOGIC; 
  signal fax4_ins_mux_a0_0_Q : STD_LOGIC; 
  signal fax4_ins_mux_a0_1_Q : STD_LOGIC; 
  signal fax4_ins_mux_a0_3_Q : STD_LOGIC; 
  signal fax4_ins_mux_b1_2_and000019_1310 : STD_LOGIC; 
  signal fax4_ins_output_valid_o_1311 : STD_LOGIC; 
  signal fax4_ins_output_valid_o_mux000315 : STD_LOGIC; 
  signal fax4_ins_output_valid_o_mux0003151_1313 : STD_LOGIC; 
  signal fax4_ins_output_valid_o_mux000336 : STD_LOGIC; 
  signal fax4_ins_pass_mode : STD_LOGIC; 
  signal fax4_ins_pclk_not : STD_LOGIC; 
  signal fax4_ins_pix_change_detector_reset : STD_LOGIC; 
  signal fax4_ins_pix_change_detector_reset_inv : STD_LOGIC; 
  signal fax4_ins_pix_changed_1319 : STD_LOGIC; 
  signal fax4_ins_pix_changed_mux0001 : STD_LOGIC; 
  signal fax4_ins_pix_prev_1321 : STD_LOGIC; 
  signal fax4_ins_state_FSM_FFd1_1322 : STD_LOGIC; 
  signal fax4_ins_state_FSM_FFd10_1323 : STD_LOGIC; 
  signal fax4_ins_state_FSM_FFd10_In_1324 : STD_LOGIC; 
  signal fax4_ins_state_FSM_FFd11_1325 : STD_LOGIC; 
  signal fax4_ins_state_FSM_FFd11_In1 : STD_LOGIC; 
  signal fax4_ins_state_FSM_FFd2_1327 : STD_LOGIC; 
  signal fax4_ins_state_FSM_FFd2_In_1328 : STD_LOGIC; 
  signal fax4_ins_state_FSM_FFd3_1329 : STD_LOGIC; 
  signal fax4_ins_state_FSM_FFd3_In : STD_LOGIC; 
  signal fax4_ins_state_FSM_FFd4_1331 : STD_LOGIC; 
  signal fax4_ins_state_FSM_FFd4_In11 : STD_LOGIC; 
  signal fax4_ins_state_FSM_FFd5_1333 : STD_LOGIC; 
  signal fax4_ins_state_FSM_FFd5_In : STD_LOGIC; 
  signal fax4_ins_state_FSM_FFd5_In5_1335 : STD_LOGIC; 
  signal fax4_ins_state_FSM_FFd6_1336 : STD_LOGIC; 
  signal fax4_ins_state_FSM_FFd6_In_1337 : STD_LOGIC; 
  signal fax4_ins_state_FSM_FFd8_1338 : STD_LOGIC; 
  signal fax4_ins_state_FSM_FFd8_In25 : STD_LOGIC; 
  signal fax4_ins_state_FSM_FFd8_In7_1340 : STD_LOGIC; 
  signal fax4_ins_state_FSM_FFd9_1341 : STD_LOGIC; 
  signal fax4_ins_state_FSM_FFd9_In1 : STD_LOGIC; 
  signal fax4_ins_state_FSM_N12 : STD_LOGIC; 
  signal fax4_ins_state_FSM_N7 : STD_LOGIC; 
  signal fax4_ins_state_updated_1345 : STD_LOGIC; 
  signal fax4_ins_state_updated_mux000824_1346 : STD_LOGIC; 
  signal fax4_ins_state_updated_mux000840_1347 : STD_LOGIC; 
  signal fax4_ins_state_updated_mux000854_1348 : STD_LOGIC; 
  signal fax4_ins_to_white_1349 : STD_LOGIC; 
  signal fax4_ins_to_white_mux0000 : STD_LOGIC; 
  signal fax4_ins_vertical_mode_cmp_le0000 : STD_LOGIC; 
  signal fax4_ins_vertical_mode_cmp_le000020_1361 : STD_LOGIC; 
  signal fax4_ins_vertical_mode_cmp_le00002114_1362 : STD_LOGIC; 
  signal fax4_ins_vertical_mode_cmp_le0000213_1363 : STD_LOGIC; 
  signal fax4_ins_vertical_mode_cmp_le00002169_1364 : STD_LOGIC; 
  signal fax4_ins_vertical_mode_cmp_le0000226_1365 : STD_LOGIC; 
  signal fax4_ins_vertical_mode_cmp_le0000245_1366 : STD_LOGIC; 
  signal fax4_ins_vertical_mode_cmp_le0000281_1367 : STD_LOGIC; 
  signal frame_finished_wire : STD_LOGIC; 
  signal huffman_ins_v2_Madd_code_black_width_add0000_cy_1_Q : STD_LOGIC; 
  signal huffman_ins_v2_Madd_code_black_width_add0000_cy_3_Q : STD_LOGIC; 
  signal huffman_ins_v2_Madd_code_black_width_add0000_cy_3_1 : STD_LOGIC; 
  signal huffman_ins_v2_Madd_code_black_width_add0000_cy_3_11_1373 : STD_LOGIC; 
  signal huffman_ins_v2_Madd_code_black_width_add0000_xor_3_11 : STD_LOGIC; 
  signal huffman_ins_v2_Madd_code_black_width_add0000_xor_3_111_1376 : STD_LOGIC; 
  signal huffman_ins_v2_Madd_code_white_width_add0000_cy_1_Q : STD_LOGIC; 
  signal huffman_ins_v2_Madd_code_white_width_add0000_cy_3_Q : STD_LOGIC; 
  signal huffman_ins_v2_Madd_code_white_width_add0000_cy_3_1 : STD_LOGIC; 
  signal huffman_ins_v2_Madd_code_white_width_add0000_cy_3_11_1380 : STD_LOGIC; 
  signal huffman_ins_v2_Madd_code_white_width_add0000_xor_3_11 : STD_LOGIC; 
  signal huffman_ins_v2_Madd_code_white_width_add0000_xor_3_111_1383 : STD_LOGIC; 
  signal huffman_ins_v2_Mrom_run_length_i_rom0000111 : STD_LOGIC; 
  signal huffman_ins_v2_Mrom_run_length_i_rom000012 : STD_LOGIC; 
  signal huffman_ins_v2_Mrom_run_length_i_rom00002 : STD_LOGIC; 
  signal huffman_ins_v2_Mrom_run_length_i_rom00003 : STD_LOGIC; 
  signal huffman_ins_v2_Mrom_run_length_i_rom00005 : STD_LOGIC; 
  signal huffman_ins_v2_Mshreg_a0_value_2_1394 : STD_LOGIC; 
  signal huffman_ins_v2_Mshreg_frame_finished_o_1395 : STD_LOGIC; 
  signal huffman_ins_v2_Mshreg_horizontal_mode_3_1396 : STD_LOGIC; 
  signal huffman_ins_v2_Mshreg_pass_vert_code_3_0_1397 : STD_LOGIC; 
  signal huffman_ins_v2_Mshreg_pass_vert_code_3_1_1398 : STD_LOGIC; 
  signal huffman_ins_v2_Mshreg_pass_vert_code_3_2_1399 : STD_LOGIC; 
  signal huffman_ins_v2_Mshreg_pass_vert_code_width_3_0_1400 : STD_LOGIC; 
  signal huffman_ins_v2_Mshreg_pass_vert_code_width_3_2_1401 : STD_LOGIC; 
  signal huffman_ins_v2_Mshreg_run_len_code_valid_o_1402 : STD_LOGIC; 
  signal huffman_ins_v2_Msub_run_length_white_addsub0000_cy_0_rt_1404 : STD_LOGIC; 
  signal huffman_ins_v2_N100 : STD_LOGIC; 
  signal huffman_ins_v2_N102 : STD_LOGIC; 
  signal huffman_ins_v2_N103 : STD_LOGIC; 
  signal huffman_ins_v2_N105 : STD_LOGIC; 
  signal huffman_ins_v2_N107 : STD_LOGIC; 
  signal huffman_ins_v2_N109 : STD_LOGIC; 
  signal huffman_ins_v2_N11 : STD_LOGIC; 
  signal huffman_ins_v2_N110 : STD_LOGIC; 
  signal huffman_ins_v2_N14 : STD_LOGIC; 
  signal huffman_ins_v2_N16 : STD_LOGIC; 
  signal huffman_ins_v2_N166 : STD_LOGIC; 
  signal huffman_ins_v2_N169 : STD_LOGIC; 
  signal huffman_ins_v2_N170 : STD_LOGIC; 
  signal huffman_ins_v2_N186 : STD_LOGIC; 
  signal huffman_ins_v2_N203 : STD_LOGIC; 
  signal huffman_ins_v2_N223 : STD_LOGIC; 
  signal huffman_ins_v2_N228 : STD_LOGIC; 
  signal huffman_ins_v2_N232 : STD_LOGIC; 
  signal huffman_ins_v2_N239 : STD_LOGIC; 
  signal huffman_ins_v2_N244 : STD_LOGIC; 
  signal huffman_ins_v2_N245 : STD_LOGIC; 
  signal huffman_ins_v2_N246 : STD_LOGIC; 
  signal huffman_ins_v2_N248 : STD_LOGIC; 
  signal huffman_ins_v2_N250 : STD_LOGIC; 
  signal huffman_ins_v2_N251 : STD_LOGIC; 
  signal huffman_ins_v2_N3 : STD_LOGIC; 
  signal huffman_ins_v2_N34 : STD_LOGIC; 
  signal huffman_ins_v2_N38 : STD_LOGIC; 
  signal huffman_ins_v2_N39 : STD_LOGIC; 
  signal huffman_ins_v2_N40 : STD_LOGIC; 
  signal huffman_ins_v2_N44 : STD_LOGIC; 
  signal huffman_ins_v2_N45 : STD_LOGIC; 
  signal huffman_ins_v2_N48 : STD_LOGIC; 
  signal huffman_ins_v2_N51 : STD_LOGIC; 
  signal huffman_ins_v2_N52 : STD_LOGIC; 
  signal huffman_ins_v2_N55 : STD_LOGIC; 
  signal huffman_ins_v2_N59 : STD_LOGIC; 
  signal huffman_ins_v2_N60 : STD_LOGIC; 
  signal huffman_ins_v2_N62 : STD_LOGIC; 
  signal huffman_ins_v2_N65 : STD_LOGIC; 
  signal huffman_ins_v2_N67 : STD_LOGIC; 
  signal huffman_ins_v2_N70 : STD_LOGIC; 
  signal huffman_ins_v2_N71 : STD_LOGIC; 
  signal huffman_ins_v2_N78 : STD_LOGIC; 
  signal huffman_ins_v2_N82 : STD_LOGIC; 
  signal huffman_ins_v2_N87 : STD_LOGIC; 
  signal huffman_ins_v2_N89 : STD_LOGIC; 
  signal huffman_ins_v2_N95 : STD_LOGIC; 
  signal huffman_ins_v2_N98 : STD_LOGIC; 
  signal huffman_ins_v2_N99 : STD_LOGIC; 
  signal huffman_ins_v2_a0_value_2_1510 : STD_LOGIC; 
  signal huffman_ins_v2_code_black_0_mux0000 : STD_LOGIC; 
  signal huffman_ins_v2_code_black_10_mux0000 : STD_LOGIC; 
  signal huffman_ins_v2_code_black_10_mux000010_1516 : STD_LOGIC; 
  signal huffman_ins_v2_code_black_10_mux00001103_1517 : STD_LOGIC; 
  signal huffman_ins_v2_code_black_10_mux00001116_1518 : STD_LOGIC; 
  signal huffman_ins_v2_code_black_10_mux0000115_1519 : STD_LOGIC; 
  signal huffman_ins_v2_code_black_10_mux0000152 : STD_LOGIC; 
  signal huffman_ins_v2_code_black_10_mux00001521_1521 : STD_LOGIC; 
  signal huffman_ins_v2_code_black_10_mux00001522_1522 : STD_LOGIC; 
  signal huffman_ins_v2_code_black_10_mux0000_bdd2 : STD_LOGIC; 
  signal huffman_ins_v2_code_black_10_mux0000_bdd3 : STD_LOGIC; 
  signal huffman_ins_v2_code_black_10_mux0000_bdd4 : STD_LOGIC; 
  signal huffman_ins_v2_code_black_10_mux0000_bdd5 : STD_LOGIC; 
  signal huffman_ins_v2_code_black_11_mux0000 : STD_LOGIC; 
  signal huffman_ins_v2_code_black_11_mux00001107_1529 : STD_LOGIC; 
  signal huffman_ins_v2_code_black_11_mux0000112_1530 : STD_LOGIC; 
  signal huffman_ins_v2_code_black_11_mux0000143 : STD_LOGIC; 
  signal huffman_ins_v2_code_black_11_mux00001431_1532 : STD_LOGIC; 
  signal huffman_ins_v2_code_black_11_mux00001432_1533 : STD_LOGIC; 
  signal huffman_ins_v2_code_black_11_mux0000_bdd0 : STD_LOGIC; 
  signal huffman_ins_v2_code_black_11_mux0000_bdd2 : STD_LOGIC; 
  signal huffman_ins_v2_code_black_11_mux0000_bdd3 : STD_LOGIC; 
  signal huffman_ins_v2_code_black_11_mux0000_bdd5 : STD_LOGIC; 
  signal huffman_ins_v2_code_black_12_mux0000 : STD_LOGIC; 
  signal huffman_ins_v2_code_black_12_mux00001107_1540 : STD_LOGIC; 
  signal huffman_ins_v2_code_black_12_mux0000112_1541 : STD_LOGIC; 
  signal huffman_ins_v2_code_black_12_mux0000143 : STD_LOGIC; 
  signal huffman_ins_v2_code_black_12_mux00001431_1543 : STD_LOGIC; 
  signal huffman_ins_v2_code_black_12_mux00001432_1544 : STD_LOGIC; 
  signal huffman_ins_v2_code_black_13_mux0000 : STD_LOGIC; 
  signal huffman_ins_v2_code_black_13_mux00001107_1547 : STD_LOGIC; 
  signal huffman_ins_v2_code_black_13_mux0000112_1548 : STD_LOGIC; 
  signal huffman_ins_v2_code_black_13_mux0000143 : STD_LOGIC; 
  signal huffman_ins_v2_code_black_13_mux00001431_1550 : STD_LOGIC; 
  signal huffman_ins_v2_code_black_13_mux00001432_1551 : STD_LOGIC; 
  signal huffman_ins_v2_code_black_14_mux0000 : STD_LOGIC; 
  signal huffman_ins_v2_code_black_14_mux00001107_1554 : STD_LOGIC; 
  signal huffman_ins_v2_code_black_14_mux0000112_1555 : STD_LOGIC; 
  signal huffman_ins_v2_code_black_14_mux0000143 : STD_LOGIC; 
  signal huffman_ins_v2_code_black_14_mux00001431_1557 : STD_LOGIC; 
  signal huffman_ins_v2_code_black_14_mux00001432_1558 : STD_LOGIC; 
  signal huffman_ins_v2_code_black_15_mux0000 : STD_LOGIC; 
  signal huffman_ins_v2_code_black_15_mux00001107 : STD_LOGIC; 
  signal huffman_ins_v2_code_black_15_mux000011071_1562 : STD_LOGIC; 
  signal huffman_ins_v2_code_black_15_mux000011072_1563 : STD_LOGIC; 
  signal huffman_ins_v2_code_black_15_mux0000112_1564 : STD_LOGIC; 
  signal huffman_ins_v2_code_black_15_mux0000143 : STD_LOGIC; 
  signal huffman_ins_v2_code_black_15_mux00001431_1566 : STD_LOGIC; 
  signal huffman_ins_v2_code_black_15_mux00001432_1567 : STD_LOGIC; 
  signal huffman_ins_v2_code_black_15_mux0000_bdd1 : STD_LOGIC; 
  signal huffman_ins_v2_code_black_16_mux0000 : STD_LOGIC; 
  signal huffman_ins_v2_code_black_16_mux00001 : STD_LOGIC; 
  signal huffman_ins_v2_code_black_16_mux000011_1572 : STD_LOGIC; 
  signal huffman_ins_v2_code_black_16_mux000012_1573 : STD_LOGIC; 
  signal huffman_ins_v2_code_black_16_mux00001_f5_1574 : STD_LOGIC; 
  signal huffman_ins_v2_code_black_17_mux0000 : STD_LOGIC; 
  signal huffman_ins_v2_code_black_17_mux00001 : STD_LOGIC; 
  signal huffman_ins_v2_code_black_17_mux000011_1578 : STD_LOGIC; 
  signal huffman_ins_v2_code_black_17_mux000012_1579 : STD_LOGIC; 
  signal huffman_ins_v2_code_black_17_mux000013_1580 : STD_LOGIC; 
  signal huffman_ins_v2_code_black_17_mux00001_f5_1581 : STD_LOGIC; 
  signal huffman_ins_v2_code_black_17_mux00001_f51 : STD_LOGIC; 
  signal huffman_ins_v2_code_black_18_mux0000 : STD_LOGIC; 
  signal huffman_ins_v2_code_black_18_mux00001 : STD_LOGIC; 
  signal huffman_ins_v2_code_black_18_mux000011_1586 : STD_LOGIC; 
  signal huffman_ins_v2_code_black_18_mux000012_1587 : STD_LOGIC; 
  signal huffman_ins_v2_code_black_18_mux00001_f5_1588 : STD_LOGIC; 
  signal huffman_ins_v2_code_black_19_mux0000 : STD_LOGIC; 
  signal huffman_ins_v2_code_black_19_mux00001 : STD_LOGIC; 
  signal huffman_ins_v2_code_black_19_mux000011_1592 : STD_LOGIC; 
  signal huffman_ins_v2_code_black_19_mux00001_f5_1593 : STD_LOGIC; 
  signal huffman_ins_v2_code_black_19_mux00001_f5_rt_1594 : STD_LOGIC; 
  signal huffman_ins_v2_code_black_1_mux0000 : STD_LOGIC; 
  signal huffman_ins_v2_code_black_20_mux0000166_1598 : STD_LOGIC; 
  signal huffman_ins_v2_code_black_20_mux0000187_1599 : STD_LOGIC; 
  signal huffman_ins_v2_code_black_21_mux0000 : STD_LOGIC; 
  signal huffman_ins_v2_code_black_21_mux00001 : STD_LOGIC; 
  signal huffman_ins_v2_code_black_21_mux000011_1603 : STD_LOGIC; 
  signal huffman_ins_v2_code_black_21_mux000012_1604 : STD_LOGIC; 
  signal huffman_ins_v2_code_black_21_mux00001_f5_1605 : STD_LOGIC; 
  signal huffman_ins_v2_code_black_22_mux0000112_1607 : STD_LOGIC; 
  signal huffman_ins_v2_code_black_22_mux0000123 : STD_LOGIC; 
  signal huffman_ins_v2_code_black_22_mux0000128_1609 : STD_LOGIC; 
  signal huffman_ins_v2_code_black_22_mux0000169_1610 : STD_LOGIC; 
  signal huffman_ins_v2_code_black_22_mux0000172 : STD_LOGIC; 
  signal huffman_ins_v2_code_black_23_mux0000112_1613 : STD_LOGIC; 
  signal huffman_ins_v2_code_black_23_mux0000128_1614 : STD_LOGIC; 
  signal huffman_ins_v2_code_black_23_mux0000169_1615 : STD_LOGIC; 
  signal huffman_ins_v2_code_black_23_mux0000172 : STD_LOGIC; 
  signal huffman_ins_v2_code_black_24_mux0000 : STD_LOGIC; 
  signal huffman_ins_v2_code_black_2_mux0000 : STD_LOGIC; 
  signal huffman_ins_v2_code_black_2_mux00002 : STD_LOGIC; 
  signal huffman_ins_v2_code_black_2_mux000021_1621 : STD_LOGIC; 
  signal huffman_ins_v2_code_black_2_mux000022_1622 : STD_LOGIC; 
  signal huffman_ins_v2_code_black_2_mux000023_1623 : STD_LOGIC; 
  signal huffman_ins_v2_code_black_2_mux00002_f5_1624 : STD_LOGIC; 
  signal huffman_ins_v2_code_black_2_mux00002_f51 : STD_LOGIC; 
  signal huffman_ins_v2_code_black_3_mux0000 : STD_LOGIC; 
  signal huffman_ins_v2_code_black_3_mux00001 : STD_LOGIC; 
  signal huffman_ins_v2_code_black_3_mux000011_1629 : STD_LOGIC; 
  signal huffman_ins_v2_code_black_3_mux000012_1630 : STD_LOGIC; 
  signal huffman_ins_v2_code_black_3_mux000013_1631 : STD_LOGIC; 
  signal huffman_ins_v2_code_black_3_mux00001_f5_1632 : STD_LOGIC; 
  signal huffman_ins_v2_code_black_3_mux00001_f51 : STD_LOGIC; 
  signal huffman_ins_v2_code_black_4_mux0000 : STD_LOGIC; 
  signal huffman_ins_v2_code_black_4_mux00001 : STD_LOGIC; 
  signal huffman_ins_v2_code_black_4_mux000011_1637 : STD_LOGIC; 
  signal huffman_ins_v2_code_black_4_mux000012_1638 : STD_LOGIC; 
  signal huffman_ins_v2_code_black_4_mux000013_1639 : STD_LOGIC; 
  signal huffman_ins_v2_code_black_4_mux00001_f5_1640 : STD_LOGIC; 
  signal huffman_ins_v2_code_black_4_mux00001_f51 : STD_LOGIC; 
  signal huffman_ins_v2_code_black_5_mux0000 : STD_LOGIC; 
  signal huffman_ins_v2_code_black_5_mux00001 : STD_LOGIC; 
  signal huffman_ins_v2_code_black_5_mux000011_1645 : STD_LOGIC; 
  signal huffman_ins_v2_code_black_5_mux000012_1646 : STD_LOGIC; 
  signal huffman_ins_v2_code_black_5_mux000013_1647 : STD_LOGIC; 
  signal huffman_ins_v2_code_black_5_mux00001_f5_1648 : STD_LOGIC; 
  signal huffman_ins_v2_code_black_5_mux00001_f51 : STD_LOGIC; 
  signal huffman_ins_v2_code_black_6_mux0000 : STD_LOGIC; 
  signal huffman_ins_v2_code_black_6_mux00002126_1652 : STD_LOGIC; 
  signal huffman_ins_v2_code_black_6_mux00002155 : STD_LOGIC; 
  signal huffman_ins_v2_code_black_6_mux0000282_1654 : STD_LOGIC; 
  signal huffman_ins_v2_code_black_7_mux0000 : STD_LOGIC; 
  signal huffman_ins_v2_code_black_7_mux00001 : STD_LOGIC; 
  signal huffman_ins_v2_code_black_7_mux000011_1658 : STD_LOGIC; 
  signal huffman_ins_v2_code_black_7_mux000012_1659 : STD_LOGIC; 
  signal huffman_ins_v2_code_black_7_mux000013_1660 : STD_LOGIC; 
  signal huffman_ins_v2_code_black_7_mux00001_f5_1661 : STD_LOGIC; 
  signal huffman_ins_v2_code_black_7_mux00001_f51 : STD_LOGIC; 
  signal huffman_ins_v2_code_black_8_mux0000 : STD_LOGIC; 
  signal huffman_ins_v2_code_black_8_mux00001126_1665 : STD_LOGIC; 
  signal huffman_ins_v2_code_black_8_mux0000172_1666 : STD_LOGIC; 
  signal huffman_ins_v2_code_black_9_mux0000 : STD_LOGIC; 
  signal huffman_ins_v2_code_black_9_mux00002107_1669 : STD_LOGIC; 
  signal huffman_ins_v2_code_black_9_mux0000212_1670 : STD_LOGIC; 
  signal huffman_ins_v2_code_black_9_mux0000243 : STD_LOGIC; 
  signal huffman_ins_v2_code_black_9_mux00002431_1672 : STD_LOGIC; 
  signal huffman_ins_v2_code_black_9_mux00002432_1673 : STD_LOGIC; 
  signal huffman_ins_v2_code_table_ins_Mrom_makeup_black_mux00011 : STD_LOGIC; 
  signal huffman_ins_v2_code_table_ins_Mrom_makeup_black_mux0001101 : STD_LOGIC; 
  signal huffman_ins_v2_code_table_ins_Mrom_makeup_black_mux000112 : STD_LOGIC; 
  signal huffman_ins_v2_code_table_ins_Mrom_makeup_black_mux000115 : STD_LOGIC; 
  signal huffman_ins_v2_code_table_ins_Mrom_makeup_black_mux00012 : STD_LOGIC; 
  signal huffman_ins_v2_code_table_ins_Mrom_makeup_black_mux00013 : STD_LOGIC; 
  signal huffman_ins_v2_code_table_ins_Mrom_makeup_black_mux00014 : STD_LOGIC; 
  signal huffman_ins_v2_code_table_ins_Mrom_makeup_black_mux00015 : STD_LOGIC; 
  signal huffman_ins_v2_code_table_ins_Mrom_makeup_black_mux000161 : STD_LOGIC; 
  signal huffman_ins_v2_code_table_ins_Mrom_makeup_black_mux000171 : STD_LOGIC; 
  signal huffman_ins_v2_code_table_ins_Mrom_makeup_white_mux0001 : STD_LOGIC; 
  signal huffman_ins_v2_code_table_ins_Mrom_makeup_white_mux00011 : STD_LOGIC; 
  signal huffman_ins_v2_code_table_ins_Mrom_makeup_white_mux0001101 : STD_LOGIC; 
  signal huffman_ins_v2_code_table_ins_Mrom_makeup_white_mux00011111 : STD_LOGIC; 
  signal huffman_ins_v2_code_table_ins_Mrom_makeup_white_mux0001121 : STD_LOGIC; 
  signal huffman_ins_v2_code_table_ins_Mrom_makeup_white_mux00012 : STD_LOGIC; 
  signal huffman_ins_v2_code_table_ins_Mrom_makeup_white_mux00013 : STD_LOGIC; 
  signal huffman_ins_v2_code_table_ins_Mrom_makeup_white_mux00014 : STD_LOGIC; 
  signal huffman_ins_v2_code_table_ins_Mrom_makeup_white_mux00015 : STD_LOGIC; 
  signal huffman_ins_v2_code_table_ins_Mrom_makeup_white_mux000161 : STD_LOGIC; 
  signal huffman_ins_v2_code_table_ins_Mrom_makeup_white_mux00017 : STD_LOGIC; 
  signal huffman_ins_v2_code_table_ins_Mrom_makeup_white_mux000181 : STD_LOGIC; 
  signal huffman_ins_v2_code_table_ins_Mrom_makeup_white_mux00019 : STD_LOGIC; 
  signal huffman_ins_v2_code_table_ins_makeup_black_0_Q : STD_LOGIC; 
  signal huffman_ins_v2_code_table_ins_makeup_black_1_Q : STD_LOGIC; 
  signal huffman_ins_v2_code_table_ins_makeup_black_13_Q : STD_LOGIC; 
  signal huffman_ins_v2_code_table_ins_makeup_black_14_Q : STD_LOGIC; 
  signal huffman_ins_v2_code_table_ins_makeup_black_15_Q : STD_LOGIC; 
  signal huffman_ins_v2_code_table_ins_makeup_black_16_Q : STD_LOGIC; 
  signal huffman_ins_v2_code_table_ins_makeup_black_2_Q : STD_LOGIC; 
  signal huffman_ins_v2_code_table_ins_makeup_black_3_Q : STD_LOGIC; 
  signal huffman_ins_v2_code_table_ins_makeup_black_4_Q : STD_LOGIC; 
  signal huffman_ins_v2_code_table_ins_makeup_black_5_Q : STD_LOGIC; 
  signal huffman_ins_v2_code_table_ins_makeup_black_6_Q : STD_LOGIC; 
  signal huffman_ins_v2_code_table_ins_makeup_black_7_Q : STD_LOGIC; 
  signal huffman_ins_v2_code_table_ins_makeup_black_8_Q : STD_LOGIC; 
  signal huffman_ins_v2_code_white_0_mux0000 : STD_LOGIC; 
  signal huffman_ins_v2_code_white_10_mux000010_1735 : STD_LOGIC; 
  signal huffman_ins_v2_code_white_10_mux000021_1736 : STD_LOGIC; 
  signal huffman_ins_v2_code_white_10_mux00004_1737 : STD_LOGIC; 
  signal huffman_ins_v2_code_white_10_mux00009_1738 : STD_LOGIC; 
  signal huffman_ins_v2_code_white_11_mux000010_1740 : STD_LOGIC; 
  signal huffman_ins_v2_code_white_11_mux000021_1741 : STD_LOGIC; 
  signal huffman_ins_v2_code_white_11_mux00004_1742 : STD_LOGIC; 
  signal huffman_ins_v2_code_white_11_mux00009_1743 : STD_LOGIC; 
  signal huffman_ins_v2_code_white_12_mux000010_1745 : STD_LOGIC; 
  signal huffman_ins_v2_code_white_12_mux000021_1746 : STD_LOGIC; 
  signal huffman_ins_v2_code_white_12_mux00004_1747 : STD_LOGIC; 
  signal huffman_ins_v2_code_white_12_mux00009_1748 : STD_LOGIC; 
  signal huffman_ins_v2_code_white_13_mux000015_1750 : STD_LOGIC; 
  signal huffman_ins_v2_code_white_13_mux00006_1751 : STD_LOGIC; 
  signal huffman_ins_v2_code_white_14_mux000014 : STD_LOGIC; 
  signal huffman_ins_v2_code_white_14_mux00004_1754 : STD_LOGIC; 
  signal huffman_ins_v2_code_white_15_mux00001_1756 : STD_LOGIC; 
  signal huffman_ins_v2_code_white_16_mux0000 : STD_LOGIC; 
  signal huffman_ins_v2_code_white_1_mux0000 : STD_LOGIC; 
  signal huffman_ins_v2_code_white_2_mux0000 : STD_LOGIC; 
  signal huffman_ins_v2_code_white_3_mux0000 : STD_LOGIC; 
  signal huffman_ins_v2_code_white_4_mux000016_1765 : STD_LOGIC; 
  signal huffman_ins_v2_code_white_4_mux000028 : STD_LOGIC; 
  signal huffman_ins_v2_code_white_4_mux0000281_1767 : STD_LOGIC; 
  signal huffman_ins_v2_code_white_4_mux0000282_1768 : STD_LOGIC; 
  signal huffman_ins_v2_code_white_4_mux000039_1769 : STD_LOGIC; 
  signal huffman_ins_v2_code_white_5_mux000028 : STD_LOGIC; 
  signal huffman_ins_v2_code_white_5_mux0000281_1772 : STD_LOGIC; 
  signal huffman_ins_v2_code_white_5_mux0000282_1773 : STD_LOGIC; 
  signal huffman_ins_v2_code_white_5_mux000039_1774 : STD_LOGIC; 
  signal huffman_ins_v2_code_white_6_mux000014_1776 : STD_LOGIC; 
  signal huffman_ins_v2_code_white_6_mux000021_1777 : STD_LOGIC; 
  signal huffman_ins_v2_code_white_6_mux00004_1778 : STD_LOGIC; 
  signal huffman_ins_v2_code_white_7_mux000010_1780 : STD_LOGIC; 
  signal huffman_ins_v2_code_white_7_mux000021_1781 : STD_LOGIC; 
  signal huffman_ins_v2_code_white_7_mux00004_1782 : STD_LOGIC; 
  signal huffman_ins_v2_code_white_7_mux00009_1783 : STD_LOGIC; 
  signal huffman_ins_v2_code_white_8_cmp_eq0000 : STD_LOGIC; 
  signal huffman_ins_v2_code_white_8_cmp_eq0001 : STD_LOGIC; 
  signal huffman_ins_v2_code_white_8_cmp_eq0004 : STD_LOGIC; 
  signal huffman_ins_v2_code_white_8_mux000010_1788 : STD_LOGIC; 
  signal huffman_ins_v2_code_white_8_mux000021_1789 : STD_LOGIC; 
  signal huffman_ins_v2_code_white_8_mux00004_1790 : STD_LOGIC; 
  signal huffman_ins_v2_code_white_8_mux00009_1791 : STD_LOGIC; 
  signal huffman_ins_v2_code_white_8_or0000 : STD_LOGIC; 
  signal huffman_ins_v2_code_white_9_mux000010_1794 : STD_LOGIC; 
  signal huffman_ins_v2_code_white_9_mux000021_1795 : STD_LOGIC; 
  signal huffman_ins_v2_code_white_9_mux00004_1796 : STD_LOGIC; 
  signal huffman_ins_v2_code_white_9_mux00009_1797 : STD_LOGIC; 
  signal huffman_ins_v2_frame_finished_o_1814 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_0_mux000310_1816 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_0_mux000322_1817 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_0_mux000324_1818 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_0_mux000352_1819 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_10_mux0003112_1822 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_10_mux000329_1823 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_10_mux000359_1824 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_10_mux000362_1825 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_10_mux000369_1826 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_10_mux000393_1827 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_10_mux000399_1828 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_11_mux0003121 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_11_mux0003129_1831 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_11_mux0003141 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_11_mux000321_1833 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_11_mux000338_1834 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_11_mux000373_1835 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_11_mux000374_1836 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_12_mux0003104_1838 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_12_mux000311_1839 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_12_mux0003117_1840 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_12_mux0003135_1841 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_12_mux0003163_1842 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_12_mux0003175_1843 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_12_mux0003216_1844 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_12_mux0003219_1845 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_12_mux000324_1846 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_12_mux0003249_1847 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_12_mux000339_1848 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_12_mux000364_1849 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_13_cmp_eq0000 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_13_mux0003137_1852 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_13_mux0003161_1853 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_13_mux0003181_1854 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_13_mux0003198 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_13_mux000320_1856 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_13_mux000325_1857 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_13_mux000350_1858 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_13_mux000386_1859 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_13_mux000389_1860 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_13_mux00039_1861 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_13_or0003 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_13_or0005 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_14_mux0003117_1865 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_14_mux0003126_1866 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_14_mux0003139_1867 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_14_mux0003155_1868 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_14_mux0003173_1869 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_14_mux0003186_1870 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_14_mux0003203_1871 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_14_mux0003213_1872 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_14_mux0003227_1873 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_14_mux0003256_1874 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_14_mux0003264_1875 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_14_mux000327_1876 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_14_mux0003277_1877 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_14_mux0003301_1878 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_14_mux000343_1879 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_14_mux000371_1880 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_14_mux000379_1881 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_14_mux00038_1882 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_15_mux0003122_1884 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_15_mux0003157 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_15_mux000321 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_15_mux000326_1887 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_15_mux00035_1888 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_15_mux000355 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_15_mux0003551_1890 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_15_mux0003552_1891 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_15_mux000378_1892 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_15_mux00038_1893 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_15_mux000380_1894 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_16_mux0003102_1896 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_16_mux0003117_1897 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_16_mux0003136_1898 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_16_mux0003138_1899 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_16_mux000359_1900 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_16_mux000393_1901 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_16_mux000394_1902 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_17_mux0003110_1904 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_17_mux0003153 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_17_mux00031531 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_17_mux000316_1907 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_17_mux000319_1908 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_17_mux000350_1909 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_17_mux000353_1910 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_17_mux000371_1911 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_17_mux000378_1912 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_18_and0001 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_18_mux0003127_1915 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_18_mux0003130_1916 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_18_mux0003164_1917 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_18_mux0003181_1918 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_18_mux0003199_1919 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_18_mux0003230_1920 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_18_mux000328_1921 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_18_mux000346_1922 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_18_mux000381_1923 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_19_mux0003138_1925 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_19_mux000323_1926 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_19_mux00036_1927 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_19_mux000380_1928 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_1_mux0003116_1929 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_1_mux0003120_1930 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_1_mux000339_1931 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_1_mux000347_1932 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_1_mux000354_1933 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_1_mux000379_1934 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_1_mux000386_1935 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_20_mux00030_1938 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_20_mux0003105_1939 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_20_mux0003127_1940 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_20_mux0003145_1941 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_20_mux000315_1942 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_20_mux0003158_1943 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_20_mux0003171 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_20_mux000346_1945 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_20_mux000350_1946 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_20_mux000370_1947 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_21_mux000310_1949 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_21_mux0003123_1950 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_21_mux0003168_1951 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_21_mux0003179_1952 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_21_mux000334_1953 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_21_mux000335_1954 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_21_mux000376_1955 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_21_mux000379_1956 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_21_mux000395_1957 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_22_mux0003112_1959 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_22_mux0003135_1960 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_22_mux000317_1961 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_22_mux000320_1962 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_22_mux000360_1963 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_22_mux000375_1964 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_22_mux000385_1965 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_23_and0000 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_23_mux000322_1968 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_23_mux000356_1969 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_23_mux000373 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_23_mux00039_1971 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_24_mux000312_1973 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_24_mux000316_1974 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_24_mux000335_1975 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_24_mux000348_1976 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_24_mux000371_1977 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_25_mux00030_1979 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_25_mux0003112 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_25_mux000342_1981 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_25_mux000380_1982 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_2_mux0003104_1983 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_2_mux0003117_1984 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_2_mux0003129 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_2_mux000330_1986 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_2_mux000335_1987 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_2_mux000379_1988 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_2_mux000385_1989 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_3_mux000318_1991 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_3_mux00033_1992 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_3_mux000340_1993 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_3_mux000342_1994 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_3_mux000397_1995 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_4_mux000310_1997 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_4_mux0003110 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_4_mux00033_1999 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_4_mux000331_2000 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_4_mux000333_2001 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_4_mux000358_2002 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_4_mux000384_2003 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_4_mux000388_2004 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_5_mux0003102 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_5_mux000315_2007 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_5_mux000327_2008 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_5_mux000349_2009 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_5_mux00037_2010 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_5_mux000376_2011 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_5_mux000380_2012 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_6_mux000310_2014 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_6_mux000327_2015 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_6_mux000329_2016 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_6_mux000343_2017 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_6_mux000361_2018 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_6_mux000367_2019 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_6_mux000371 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_7_mux000324_2022 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_7_mux000325_2023 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_7_mux00035_2024 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_7_mux000356_2025 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_7_mux000368_2026 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_7_mux000370_2027 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_7_mux000381 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_8_mux0003129_2030 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_8_mux000313_2031 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_8_mux0003149_2032 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_8_mux0003151_2033 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_8_mux0003165 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_8_mux000327_2035 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_8_mux000341_2036 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_8_mux000390_2037 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_8_mux000392_2038 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_9_mux0003104_2040 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_9_mux0003114_2041 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_9_mux000313_2042 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_9_mux0003147 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_9_mux000320_2044 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_9_mux000342_2045 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_9_mux000366 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_9_mux0003661_2047 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_9_mux0003662_2048 : STD_LOGIC; 
  signal huffman_ins_v2_hor_code_9_mux000398_2049 : STD_LOGIC; 
  signal huffman_ins_v2_horizontal_mode_1_2060 : STD_LOGIC; 
  signal huffman_ins_v2_horizontal_mode_1_cmp_eq0001 : STD_LOGIC; 
  signal huffman_ins_v2_horizontal_mode_1_or0000 : STD_LOGIC; 
  signal huffman_ins_v2_horizontal_mode_3_2063 : STD_LOGIC; 
  signal huffman_ins_v2_horizontal_mode_part_1_2064 : STD_LOGIC; 
  signal huffman_ins_v2_horizontal_mode_part_2_2065 : STD_LOGIC; 
  signal huffman_ins_v2_pass_vert_code_width_1_0_Q : STD_LOGIC; 
  signal huffman_ins_v2_pass_vert_code_width_1_2_Q : STD_LOGIC; 
  signal huffman_ins_v2_pass_vert_code_width_3_0_Q : STD_LOGIC; 
  signal huffman_ins_v2_pass_vert_code_width_3_2_Q : STD_LOGIC; 
  signal huffman_ins_v2_run_len_code_valid_o_2082 : STD_LOGIC; 
  signal huffman_ins_v2_run_length_white_0_1_2094 : STD_LOGIC; 
  signal huffman_ins_v2_run_length_white_0_2_2095 : STD_LOGIC; 
  signal huffman_ins_v2_run_length_white_1_1_2097 : STD_LOGIC; 
  signal huffman_ins_v2_run_length_white_1_2_2098 : STD_LOGIC; 
  signal huffman_ins_v2_run_length_white_2_1_2100 : STD_LOGIC; 
  signal huffman_ins_v2_run_length_white_2_2_2101 : STD_LOGIC; 
  signal huffman_ins_v2_run_length_white_3_1_2103 : STD_LOGIC; 
  signal huffman_ins_v2_run_length_white_3_2_2104 : STD_LOGIC; 
  signal huffman_ins_v2_run_length_white_4_1_2106 : STD_LOGIC; 
  signal huffman_ins_v2_run_length_white_4_2_2107 : STD_LOGIC; 
  signal huffman_ins_v2_run_length_white_5_1_2109 : STD_LOGIC; 
  signal huffman_ins_v2_run_length_white_5_2_2110 : STD_LOGIC; 
  signal huffman_ins_v2_run_length_white_6_1_2112 : STD_LOGIC; 
  signal huffman_ins_v2_run_length_white_6_2_2113 : STD_LOGIC; 
  signal huffman_ins_v2_run_length_white_7_1_2115 : STD_LOGIC; 
  signal huffman_ins_v2_run_length_white_7_2_2116 : STD_LOGIC; 
  signal huffman_ins_v2_run_length_white_8_1_2118 : STD_LOGIC; 
  signal huffman_ins_v2_run_length_white_8_2_2119 : STD_LOGIC; 
  signal huffman_ins_v2_run_length_white_9_1_2121 : STD_LOGIC; 
  signal huffman_ins_v2_run_length_white_9_2_2122 : STD_LOGIC; 
  signal huffman_ins_v2_run_length_white_and0000 : STD_LOGIC; 
  signal huffman_ins_v2_run_length_white_and000020_2134 : STD_LOGIC; 
  signal huffman_ins_v2_run_length_white_and000043_2135 : STD_LOGIC; 
  signal huffman_ins_v2_run_length_white_and00007_2136 : STD_LOGIC; 
  signal NLW_huffman_ins_v2_code_table_ins_Mrom_white_code_mux0001_DO_15_UNCONNECTED : STD_LOGIC; 
  signal NLW_huffman_ins_v2_code_table_ins_Mrom_white_code_mux0001_DO_14_UNCONNECTED : STD_LOGIC; 
  signal NLW_huffman_ins_v2_code_table_ins_Mrom_white_code_mux0001_DO_13_UNCONNECTED : STD_LOGIC; 
  signal NLW_huffman_ins_v2_code_table_ins_Mrom_white_code_mux0001_DO_12_UNCONNECTED : STD_LOGIC; 
  signal NLW_huffman_ins_v2_code_table_ins_Mrom_white_code_mux0001_DOP_1_UNCONNECTED : STD_LOGIC; 
  signal NLW_huffman_ins_v2_code_table_ins_Mrom_white_code_mux0001_DOP_0_UNCONNECTED : STD_LOGIC; 
  signal NLW_huffman_ins_v2_code_table_ins_Mrom_black_code_mux0001_DOP_1_UNCONNECTED : STD_LOGIC; 
  signal NLW_huffman_ins_v2_code_table_ins_Mrom_black_code_mux0001_DOP_0_UNCONNECTED : STD_LOGIC; 
  signal NLW_fax4_ins_FIFO1_multi_read_ins_RAM_ins_Mram_mem_DIB_15_UNCONNECTED : STD_LOGIC; 
  signal NLW_fax4_ins_FIFO1_multi_read_ins_RAM_ins_Mram_mem_DIB_14_UNCONNECTED : STD_LOGIC; 
  signal NLW_fax4_ins_FIFO1_multi_read_ins_RAM_ins_Mram_mem_DIB_13_UNCONNECTED : STD_LOGIC; 
  signal NLW_fax4_ins_FIFO1_multi_read_ins_RAM_ins_Mram_mem_DIB_12_UNCONNECTED : STD_LOGIC; 
  signal NLW_fax4_ins_FIFO1_multi_read_ins_RAM_ins_Mram_mem_DIB_11_UNCONNECTED : STD_LOGIC; 
  signal NLW_fax4_ins_FIFO1_multi_read_ins_RAM_ins_Mram_mem_DIB_10_UNCONNECTED : STD_LOGIC; 
  signal NLW_fax4_ins_FIFO1_multi_read_ins_RAM_ins_Mram_mem_DIB_9_UNCONNECTED : STD_LOGIC; 
  signal NLW_fax4_ins_FIFO1_multi_read_ins_RAM_ins_Mram_mem_DIB_8_UNCONNECTED : STD_LOGIC; 
  signal NLW_fax4_ins_FIFO1_multi_read_ins_RAM_ins_Mram_mem_DIB_7_UNCONNECTED : STD_LOGIC; 
  signal NLW_fax4_ins_FIFO1_multi_read_ins_RAM_ins_Mram_mem_DIB_6_UNCONNECTED : STD_LOGIC; 
  signal NLW_fax4_ins_FIFO1_multi_read_ins_RAM_ins_Mram_mem_DIB_5_UNCONNECTED : STD_LOGIC; 
  signal NLW_fax4_ins_FIFO1_multi_read_ins_RAM_ins_Mram_mem_DIB_4_UNCONNECTED : STD_LOGIC; 
  signal NLW_fax4_ins_FIFO1_multi_read_ins_RAM_ins_Mram_mem_DIB_3_UNCONNECTED : STD_LOGIC; 
  signal NLW_fax4_ins_FIFO1_multi_read_ins_RAM_ins_Mram_mem_DIB_2_UNCONNECTED : STD_LOGIC; 
  signal NLW_fax4_ins_FIFO1_multi_read_ins_RAM_ins_Mram_mem_DIB_1_UNCONNECTED : STD_LOGIC; 
  signal NLW_fax4_ins_FIFO1_multi_read_ins_RAM_ins_Mram_mem_DIB_0_UNCONNECTED : STD_LOGIC; 
  signal NLW_fax4_ins_FIFO1_multi_read_ins_RAM_ins_Mram_mem_DIPB_1_UNCONNECTED : STD_LOGIC; 
  signal NLW_fax4_ins_FIFO1_multi_read_ins_RAM_ins_Mram_mem_DIPB_0_UNCONNECTED : STD_LOGIC; 
  signal NLW_fax4_ins_FIFO1_multi_read_ins_RAM_ins_Mram_mem_DOA_15_UNCONNECTED : STD_LOGIC; 
  signal NLW_fax4_ins_FIFO1_multi_read_ins_RAM_ins_Mram_mem_DOA_14_UNCONNECTED : STD_LOGIC; 
  signal NLW_fax4_ins_FIFO1_multi_read_ins_RAM_ins_Mram_mem_DOA_13_UNCONNECTED : STD_LOGIC; 
  signal NLW_fax4_ins_FIFO1_multi_read_ins_RAM_ins_Mram_mem_DOA_12_UNCONNECTED : STD_LOGIC; 
  signal NLW_fax4_ins_FIFO1_multi_read_ins_RAM_ins_Mram_mem_DOA_11_UNCONNECTED : STD_LOGIC; 
  signal NLW_fax4_ins_FIFO1_multi_read_ins_RAM_ins_Mram_mem_DOA_10_UNCONNECTED : STD_LOGIC; 
  signal NLW_fax4_ins_FIFO1_multi_read_ins_RAM_ins_Mram_mem_DOA_9_UNCONNECTED : STD_LOGIC; 
  signal NLW_fax4_ins_FIFO1_multi_read_ins_RAM_ins_Mram_mem_DOA_8_UNCONNECTED : STD_LOGIC; 
  signal NLW_fax4_ins_FIFO1_multi_read_ins_RAM_ins_Mram_mem_DOA_7_UNCONNECTED : STD_LOGIC; 
  signal NLW_fax4_ins_FIFO1_multi_read_ins_RAM_ins_Mram_mem_DOA_6_UNCONNECTED : STD_LOGIC; 
  signal NLW_fax4_ins_FIFO1_multi_read_ins_RAM_ins_Mram_mem_DOA_5_UNCONNECTED : STD_LOGIC; 
  signal NLW_fax4_ins_FIFO1_multi_read_ins_RAM_ins_Mram_mem_DOA_4_UNCONNECTED : STD_LOGIC; 
  signal NLW_fax4_ins_FIFO1_multi_read_ins_RAM_ins_Mram_mem_DOA_3_UNCONNECTED : STD_LOGIC; 
  signal NLW_fax4_ins_FIFO1_multi_read_ins_RAM_ins_Mram_mem_DOA_2_UNCONNECTED : STD_LOGIC; 
  signal NLW_fax4_ins_FIFO1_multi_read_ins_RAM_ins_Mram_mem_DOA_1_UNCONNECTED : STD_LOGIC; 
  signal NLW_fax4_ins_FIFO1_multi_read_ins_RAM_ins_Mram_mem_DOA_0_UNCONNECTED : STD_LOGIC; 
  signal NLW_fax4_ins_FIFO1_multi_read_ins_RAM_ins_Mram_mem_DOPA_1_UNCONNECTED : STD_LOGIC; 
  signal NLW_fax4_ins_FIFO1_multi_read_ins_RAM_ins_Mram_mem_DOPA_0_UNCONNECTED : STD_LOGIC; 
  signal NLW_fax4_ins_FIFO1_multi_read_ins_RAM_ins_Mram_mem_DOB_15_UNCONNECTED : STD_LOGIC; 
  signal NLW_fax4_ins_FIFO1_multi_read_ins_RAM_ins_Mram_mem_DOB_14_UNCONNECTED : STD_LOGIC; 
  signal NLW_fax4_ins_FIFO1_multi_read_ins_RAM_ins_Mram_mem_DOB_13_UNCONNECTED : STD_LOGIC; 
  signal NLW_fax4_ins_FIFO1_multi_read_ins_RAM_ins_Mram_mem_DOB_12_UNCONNECTED : STD_LOGIC; 
  signal NLW_fax4_ins_FIFO1_multi_read_ins_RAM_ins_Mram_mem_DOB_11_UNCONNECTED : STD_LOGIC; 
  signal NLW_fax4_ins_FIFO1_multi_read_ins_RAM_ins_Mram_mem_DOPB_1_UNCONNECTED : STD_LOGIC; 
  signal NLW_fax4_ins_FIFO1_multi_read_ins_RAM_ins_Mram_mem_DOPB_0_UNCONNECTED : STD_LOGIC; 
  signal NLW_fax4_ins_FIFO2_multi_read_ins_RAM_ins_Mram_mem_DIB_15_UNCONNECTED : STD_LOGIC; 
  signal NLW_fax4_ins_FIFO2_multi_read_ins_RAM_ins_Mram_mem_DIB_14_UNCONNECTED : STD_LOGIC; 
  signal NLW_fax4_ins_FIFO2_multi_read_ins_RAM_ins_Mram_mem_DIB_13_UNCONNECTED : STD_LOGIC; 
  signal NLW_fax4_ins_FIFO2_multi_read_ins_RAM_ins_Mram_mem_DIB_12_UNCONNECTED : STD_LOGIC; 
  signal NLW_fax4_ins_FIFO2_multi_read_ins_RAM_ins_Mram_mem_DIB_11_UNCONNECTED : STD_LOGIC; 
  signal NLW_fax4_ins_FIFO2_multi_read_ins_RAM_ins_Mram_mem_DIB_10_UNCONNECTED : STD_LOGIC; 
  signal NLW_fax4_ins_FIFO2_multi_read_ins_RAM_ins_Mram_mem_DIB_9_UNCONNECTED : STD_LOGIC; 
  signal NLW_fax4_ins_FIFO2_multi_read_ins_RAM_ins_Mram_mem_DIB_8_UNCONNECTED : STD_LOGIC; 
  signal NLW_fax4_ins_FIFO2_multi_read_ins_RAM_ins_Mram_mem_DIB_7_UNCONNECTED : STD_LOGIC; 
  signal NLW_fax4_ins_FIFO2_multi_read_ins_RAM_ins_Mram_mem_DIB_6_UNCONNECTED : STD_LOGIC; 
  signal NLW_fax4_ins_FIFO2_multi_read_ins_RAM_ins_Mram_mem_DIB_5_UNCONNECTED : STD_LOGIC; 
  signal NLW_fax4_ins_FIFO2_multi_read_ins_RAM_ins_Mram_mem_DIB_4_UNCONNECTED : STD_LOGIC; 
  signal NLW_fax4_ins_FIFO2_multi_read_ins_RAM_ins_Mram_mem_DIB_3_UNCONNECTED : STD_LOGIC; 
  signal NLW_fax4_ins_FIFO2_multi_read_ins_RAM_ins_Mram_mem_DIB_2_UNCONNECTED : STD_LOGIC; 
  signal NLW_fax4_ins_FIFO2_multi_read_ins_RAM_ins_Mram_mem_DIB_1_UNCONNECTED : STD_LOGIC; 
  signal NLW_fax4_ins_FIFO2_multi_read_ins_RAM_ins_Mram_mem_DIB_0_UNCONNECTED : STD_LOGIC; 
  signal NLW_fax4_ins_FIFO2_multi_read_ins_RAM_ins_Mram_mem_DIPB_1_UNCONNECTED : STD_LOGIC; 
  signal NLW_fax4_ins_FIFO2_multi_read_ins_RAM_ins_Mram_mem_DIPB_0_UNCONNECTED : STD_LOGIC; 
  signal NLW_fax4_ins_FIFO2_multi_read_ins_RAM_ins_Mram_mem_DOA_15_UNCONNECTED : STD_LOGIC; 
  signal NLW_fax4_ins_FIFO2_multi_read_ins_RAM_ins_Mram_mem_DOA_14_UNCONNECTED : STD_LOGIC; 
  signal NLW_fax4_ins_FIFO2_multi_read_ins_RAM_ins_Mram_mem_DOA_13_UNCONNECTED : STD_LOGIC; 
  signal NLW_fax4_ins_FIFO2_multi_read_ins_RAM_ins_Mram_mem_DOA_12_UNCONNECTED : STD_LOGIC; 
  signal NLW_fax4_ins_FIFO2_multi_read_ins_RAM_ins_Mram_mem_DOA_11_UNCONNECTED : STD_LOGIC; 
  signal NLW_fax4_ins_FIFO2_multi_read_ins_RAM_ins_Mram_mem_DOA_10_UNCONNECTED : STD_LOGIC; 
  signal NLW_fax4_ins_FIFO2_multi_read_ins_RAM_ins_Mram_mem_DOA_9_UNCONNECTED : STD_LOGIC; 
  signal NLW_fax4_ins_FIFO2_multi_read_ins_RAM_ins_Mram_mem_DOA_8_UNCONNECTED : STD_LOGIC; 
  signal NLW_fax4_ins_FIFO2_multi_read_ins_RAM_ins_Mram_mem_DOA_7_UNCONNECTED : STD_LOGIC; 
  signal NLW_fax4_ins_FIFO2_multi_read_ins_RAM_ins_Mram_mem_DOA_6_UNCONNECTED : STD_LOGIC; 
  signal NLW_fax4_ins_FIFO2_multi_read_ins_RAM_ins_Mram_mem_DOA_5_UNCONNECTED : STD_LOGIC; 
  signal NLW_fax4_ins_FIFO2_multi_read_ins_RAM_ins_Mram_mem_DOA_4_UNCONNECTED : STD_LOGIC; 
  signal NLW_fax4_ins_FIFO2_multi_read_ins_RAM_ins_Mram_mem_DOA_3_UNCONNECTED : STD_LOGIC; 
  signal NLW_fax4_ins_FIFO2_multi_read_ins_RAM_ins_Mram_mem_DOA_2_UNCONNECTED : STD_LOGIC; 
  signal NLW_fax4_ins_FIFO2_multi_read_ins_RAM_ins_Mram_mem_DOA_1_UNCONNECTED : STD_LOGIC; 
  signal NLW_fax4_ins_FIFO2_multi_read_ins_RAM_ins_Mram_mem_DOA_0_UNCONNECTED : STD_LOGIC; 
  signal NLW_fax4_ins_FIFO2_multi_read_ins_RAM_ins_Mram_mem_DOPA_1_UNCONNECTED : STD_LOGIC; 
  signal NLW_fax4_ins_FIFO2_multi_read_ins_RAM_ins_Mram_mem_DOPA_0_UNCONNECTED : STD_LOGIC; 
  signal NLW_fax4_ins_FIFO2_multi_read_ins_RAM_ins_Mram_mem_DOB_15_UNCONNECTED : STD_LOGIC; 
  signal NLW_fax4_ins_FIFO2_multi_read_ins_RAM_ins_Mram_mem_DOB_14_UNCONNECTED : STD_LOGIC; 
  signal NLW_fax4_ins_FIFO2_multi_read_ins_RAM_ins_Mram_mem_DOB_13_UNCONNECTED : STD_LOGIC; 
  signal NLW_fax4_ins_FIFO2_multi_read_ins_RAM_ins_Mram_mem_DOB_12_UNCONNECTED : STD_LOGIC; 
  signal NLW_fax4_ins_FIFO2_multi_read_ins_RAM_ins_Mram_mem_DOB_11_UNCONNECTED : STD_LOGIC; 
  signal NLW_fax4_ins_FIFO2_multi_read_ins_RAM_ins_Mram_mem_DOPB_1_UNCONNECTED : STD_LOGIC; 
  signal NLW_fax4_ins_FIFO2_multi_read_ins_RAM_ins_Mram_mem_DOPB_0_UNCONNECTED : STD_LOGIC; 
  signal fax4_ins_FIFO1_multi_read_ins_Mcount_read_pos_cy : STD_LOGIC_VECTOR ( 8 downto 0 ); 
  signal fax4_ins_FIFO1_multi_read_ins_Mcount_read_pos_lut : STD_LOGIC_VECTOR ( 0 downto 0 ); 
  signal fax4_ins_FIFO1_multi_read_ins_Mcount_used_cy : STD_LOGIC_VECTOR ( 8 downto 0 ); 
  signal fax4_ins_FIFO1_multi_read_ins_Mcount_used_lut : STD_LOGIC_VECTOR ( 9 downto 0 ); 
  signal fax4_ins_FIFO1_multi_read_ins_Mcount_write_pos_cy : STD_LOGIC_VECTOR ( 8 downto 0 ); 
  signal fax4_ins_FIFO1_multi_read_ins_Mcount_write_pos_lut : STD_LOGIC_VECTOR ( 0 downto 0 ); 
  signal fax4_ins_FIFO1_multi_read_ins_Result : STD_LOGIC_VECTOR ( 9 downto 0 ); 
  signal fax4_ins_FIFO1_multi_read_ins_data1_o : STD_LOGIC_VECTOR ( 9 downto 0 ); 
  signal fax4_ins_FIFO1_multi_read_ins_data2_o : STD_LOGIC_VECTOR ( 9 downto 0 ); 
  signal fax4_ins_FIFO1_multi_read_ins_data3_o : STD_LOGIC_VECTOR ( 9 downto 0 ); 
  signal fax4_ins_FIFO1_multi_read_ins_mem_data_out : STD_LOGIC_VECTOR ( 10 downto 0 ); 
  signal fax4_ins_FIFO1_multi_read_ins_mux1_x : STD_LOGIC_VECTOR ( 9 downto 0 ); 
  signal fax4_ins_FIFO1_multi_read_ins_mux2_x : STD_LOGIC_VECTOR ( 9 downto 0 ); 
  signal fax4_ins_FIFO1_multi_read_ins_mux3_x : STD_LOGIC_VECTOR ( 9 downto 0 ); 
  signal fax4_ins_FIFO1_multi_read_ins_read_pos : STD_LOGIC_VECTOR ( 9 downto 0 ); 
  signal fax4_ins_FIFO1_multi_read_ins_used : STD_LOGIC_VECTOR ( 9 downto 0 ); 
  signal fax4_ins_FIFO1_multi_read_ins_write_pos : STD_LOGIC_VECTOR ( 9 downto 0 ); 
  signal fax4_ins_FIFO2_multi_read_ins_Mcount_read_pos_cy : STD_LOGIC_VECTOR ( 8 downto 0 ); 
  signal fax4_ins_FIFO2_multi_read_ins_Mcount_read_pos_lut : STD_LOGIC_VECTOR ( 0 downto 0 ); 
  signal fax4_ins_FIFO2_multi_read_ins_Mcount_used_cy : STD_LOGIC_VECTOR ( 8 downto 0 ); 
  signal fax4_ins_FIFO2_multi_read_ins_Mcount_used_lut : STD_LOGIC_VECTOR ( 9 downto 0 ); 
  signal fax4_ins_FIFO2_multi_read_ins_Mcount_write_pos_cy : STD_LOGIC_VECTOR ( 8 downto 0 ); 
  signal fax4_ins_FIFO2_multi_read_ins_Mcount_write_pos_lut : STD_LOGIC_VECTOR ( 0 downto 0 ); 
  signal fax4_ins_FIFO2_multi_read_ins_Result : STD_LOGIC_VECTOR ( 9 downto 0 ); 
  signal fax4_ins_FIFO2_multi_read_ins_data1_o : STD_LOGIC_VECTOR ( 9 downto 0 ); 
  signal fax4_ins_FIFO2_multi_read_ins_data2_o : STD_LOGIC_VECTOR ( 9 downto 0 ); 
  signal fax4_ins_FIFO2_multi_read_ins_data3_o : STD_LOGIC_VECTOR ( 9 downto 0 ); 
  signal fax4_ins_FIFO2_multi_read_ins_mem_data_out : STD_LOGIC_VECTOR ( 10 downto 0 ); 
  signal fax4_ins_FIFO2_multi_read_ins_mux1_x : STD_LOGIC_VECTOR ( 9 downto 0 ); 
  signal fax4_ins_FIFO2_multi_read_ins_mux2_x : STD_LOGIC_VECTOR ( 9 downto 0 ); 
  signal fax4_ins_FIFO2_multi_read_ins_mux3_x : STD_LOGIC_VECTOR ( 9 downto 0 ); 
  signal fax4_ins_FIFO2_multi_read_ins_read_pos : STD_LOGIC_VECTOR ( 9 downto 0 ); 
  signal fax4_ins_FIFO2_multi_read_ins_used : STD_LOGIC_VECTOR ( 9 downto 0 ); 
  signal fax4_ins_FIFO2_multi_read_ins_write_pos : STD_LOGIC_VECTOR ( 9 downto 0 ); 
  signal fax4_ins_Madd_a1b1_addsub0001_cy : STD_LOGIC_VECTOR ( 9 downto 1 ); 
  signal fax4_ins_Madd_fifo_rd_addsub0000_cy : STD_LOGIC_VECTOR ( 8 downto 0 ); 
  signal fax4_ins_Madd_fifo_rd_addsub0000_lut : STD_LOGIC_VECTOR ( 0 downto 0 ); 
  signal fax4_ins_Madd_vertical_mode_addsub0000_cy : STD_LOGIC_VECTOR ( 9 downto 0 ); 
  signal fax4_ins_Madd_vertical_mode_not0000 : STD_LOGIC_VECTOR ( 10 downto 1 ); 
  signal fax4_ins_Mcompar_fifo_rd_cmp_lt0000_cy : STD_LOGIC_VECTOR ( 9 downto 0 ); 
  signal fax4_ins_Mcompar_fifo_rd_cmp_lt0000_lut : STD_LOGIC_VECTOR ( 9 downto 0 ); 
  signal fax4_ins_Mcompar_mux_b1_0_cmp_gt0000_cy : STD_LOGIC_VECTOR ( 9 downto 0 ); 
  signal fax4_ins_Mcompar_mux_b1_0_cmp_gt0000_lut : STD_LOGIC_VECTOR ( 9 downto 0 ); 
  signal fax4_ins_Mcompar_mux_b1_1_cmp_gt0000_cy : STD_LOGIC_VECTOR ( 9 downto 0 ); 
  signal fax4_ins_Mcompar_mux_b1_1_cmp_gt0000_lut : STD_LOGIC_VECTOR ( 9 downto 0 ); 
  signal fax4_ins_Mcompar_mux_b1_2_cmp_gt0000_cy : STD_LOGIC_VECTOR ( 9 downto 0 ); 
  signal fax4_ins_Mcompar_mux_b1_2_cmp_gt0000_lut : STD_LOGIC_VECTOR ( 9 downto 0 ); 
  signal fax4_ins_Mcompar_mux_b1_3_cmp_gt0000_cy : STD_LOGIC_VECTOR ( 9 downto 0 ); 
  signal fax4_ins_Mcompar_mux_b1_3_cmp_gt0000_lut : STD_LOGIC_VECTOR ( 9 downto 0 ); 
  signal fax4_ins_Mcompar_pass_mode_cmp_lt0000_cy : STD_LOGIC_VECTOR ( 9 downto 0 ); 
  signal fax4_ins_Mcompar_pass_mode_cmp_lt0000_lut : STD_LOGIC_VECTOR ( 9 downto 0 ); 
  signal fax4_ins_Msub_a1b1_addsub0000_cy : STD_LOGIC_VECTOR ( 9 downto 0 ); 
  signal fax4_ins_Msub_a1b1_addsub0000_lut : STD_LOGIC_VECTOR ( 9 downto 0 ); 
  signal fax4_ins_a0 : STD_LOGIC_VECTOR ( 9 downto 0 ); 
  signal fax4_ins_a0_mux0000 : STD_LOGIC_VECTOR ( 9 downto 0 ); 
  signal fax4_ins_a0_o : STD_LOGIC_VECTOR ( 9 downto 0 ); 
  signal fax4_ins_a1_o : STD_LOGIC_VECTOR ( 9 downto 0 ); 
  signal fax4_ins_a1_o_mux0000 : STD_LOGIC_VECTOR ( 9 downto 0 ); 
  signal fax4_ins_a1b1 : STD_LOGIC_VECTOR ( 10 downto 0 ); 
  signal fax4_ins_a1b1_addsub0000 : STD_LOGIC_VECTOR ( 10 downto 0 ); 
  signal fax4_ins_a1b1_addsub0001 : STD_LOGIC_VECTOR ( 10 downto 1 ); 
  signal fax4_ins_a2_o : STD_LOGIC_VECTOR ( 9 downto 0 ); 
  signal fax4_ins_b1 : STD_LOGIC_VECTOR ( 9 downto 0 ); 
  signal fax4_ins_b1_mux0004 : STD_LOGIC_VECTOR ( 9 downto 0 ); 
  signal fax4_ins_b2 : STD_LOGIC_VECTOR ( 9 downto 0 ); 
  signal fax4_ins_b2_mux0004 : STD_LOGIC_VECTOR ( 9 downto 0 ); 
  signal fax4_ins_counter_xy_v2_ins_counter_x_ins_Madd_cnt_addsub0000_cy : STD_LOGIC_VECTOR ( 8 downto 0 ); 
  signal fax4_ins_counter_xy_v2_ins_counter_x_ins_Madd_cnt_addsub0000_lut : STD_LOGIC_VECTOR ( 0 downto 0 ); 
  signal NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt : STD_LOGIC_VECTOR ( 9 downto 0 ); 
  signal fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt_addsub0000 : STD_LOGIC_VECTOR ( 9 downto 0 ); 
  signal fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt_mux0000 : STD_LOGIC_VECTOR ( 9 downto 0 ); 
  signal fax4_ins_counter_xy_v2_ins_counter_y_ins_Madd_cnt_addsub0000_cy : STD_LOGIC_VECTOR ( 7 downto 0 ); 
  signal fax4_ins_counter_xy_v2_ins_counter_y_ins_Madd_cnt_addsub0000_lut : STD_LOGIC_VECTOR ( 0 downto 0 ); 
  signal NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt : STD_LOGIC_VECTOR ( 8 downto 0 ); 
  signal fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt_addsub0000 : STD_LOGIC_VECTOR ( 8 downto 0 ); 
  signal fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt_mux0000 : STD_LOGIC_VECTOR ( 8 downto 0 ); 
  signal fax4_ins_fifo_out1_x : STD_LOGIC_VECTOR ( 9 downto 0 ); 
  signal fax4_ins_fifo_out2_x : STD_LOGIC_VECTOR ( 9 downto 0 ); 
  signal fax4_ins_fifo_out_prev1_x : STD_LOGIC_VECTOR ( 9 downto 0 ); 
  signal fax4_ins_fifo_out_prev2_x : STD_LOGIC_VECTOR ( 9 downto 0 ); 
  signal fax4_ins_fifo_rd_addsub0000 : STD_LOGIC_VECTOR ( 9 downto 0 ); 
  signal fax4_ins_mode_indicator_o : STD_LOGIC_VECTOR ( 3 downto 0 ); 
  signal fax4_ins_mode_indicator_o_mux0001 : STD_LOGIC_VECTOR ( 3 downto 3 ); 
  signal fax4_ins_mux_b1 : STD_LOGIC_VECTOR ( 3 downto 0 ); 
  signal fax4_ins_vertical_mode_addsub0000 : STD_LOGIC_VECTOR ( 10 downto 2 ); 
  signal huffman_ins_v2_Madd_code_black_width_add0000_lut : STD_LOGIC_VECTOR ( 0 downto 0 ); 
  signal huffman_ins_v2_Madd_code_white_width_add0000_lut : STD_LOGIC_VECTOR ( 0 downto 0 ); 
  signal huffman_ins_v2_Madd_hor_code_width_addsub0000_cy : STD_LOGIC_VECTOR ( 1 downto 0 ); 
  signal huffman_ins_v2_Madd_hor_code_width_addsub0000_lut : STD_LOGIC_VECTOR ( 4 downto 2 ); 
  signal huffman_ins_v2_Msub_run_length_white_addsub0000_cy : STD_LOGIC_VECTOR ( 8 downto 0 ); 
  signal huffman_ins_v2_Msub_run_length_white_addsub0000_lut : STD_LOGIC_VECTOR ( 9 downto 1 ); 
  signal huffman_ins_v2_Msub_run_length_white_sub0000_cy : STD_LOGIC_VECTOR ( 8 downto 0 ); 
  signal huffman_ins_v2_Msub_run_length_white_sub0000_lut : STD_LOGIC_VECTOR ( 9 downto 0 ); 
  signal huffman_ins_v2_Msub_run_length_white_sub0001_cy : STD_LOGIC_VECTOR ( 8 downto 0 ); 
  signal huffman_ins_v2_Msub_run_length_white_sub0001_lut : STD_LOGIC_VECTOR ( 9 downto 0 ); 
  signal huffman_ins_v2_code_black : STD_LOGIC_VECTOR ( 24 downto 0 ); 
  signal huffman_ins_v2_code_black_width : STD_LOGIC_VECTOR ( 4 downto 0 ); 
  signal huffman_ins_v2_code_black_width_add0000 : STD_LOGIC_VECTOR ( 3 downto 1 ); 
  signal huffman_ins_v2_code_table_ins_makeup_white : STD_LOGIC_VECTOR ( 12 downto 0 ); 
  signal huffman_ins_v2_code_white : STD_LOGIC_VECTOR ( 16 downto 0 ); 
  signal huffman_ins_v2_code_white_width : STD_LOGIC_VECTOR ( 4 downto 0 ); 
  signal huffman_ins_v2_code_white_width_add0000 : STD_LOGIC_VECTOR ( 3 downto 1 ); 
  signal huffman_ins_v2_codetab_ter_black_width : STD_LOGIC_VECTOR ( 3 downto 0 ); 
  signal huffman_ins_v2_codetab_ter_white_width : STD_LOGIC_VECTOR ( 3 downto 0 ); 
  signal huffman_ins_v2_hor_code : STD_LOGIC_VECTOR ( 25 downto 0 ); 
  signal huffman_ins_v2_hor_code_width : STD_LOGIC_VECTOR ( 4 downto 0 ); 
  signal huffman_ins_v2_hor_code_width_mux0001 : STD_LOGIC_VECTOR ( 4 downto 0 ); 
  signal huffman_ins_v2_mux_code_black_width : STD_LOGIC_VECTOR ( 4 downto 0 ); 
  signal huffman_ins_v2_mux_code_white_width : STD_LOGIC_VECTOR ( 1 downto 1 ); 
  signal huffman_ins_v2_pass_vert_code_1 : STD_LOGIC_VECTOR ( 2 downto 0 ); 
  signal huffman_ins_v2_pass_vert_code_3 : STD_LOGIC_VECTOR ( 2 downto 0 ); 
  signal huffman_ins_v2_run_length_black : STD_LOGIC_VECTOR ( 9 downto 0 ); 
  signal huffman_ins_v2_run_length_white : STD_LOGIC_VECTOR ( 9 downto 0 ); 
  signal huffman_ins_v2_run_length_white_addsub0000 : STD_LOGIC_VECTOR ( 9 downto 0 ); 
  signal huffman_ins_v2_run_length_white_sub0000 : STD_LOGIC_VECTOR ( 9 downto 0 ); 
  signal huffman_ins_v2_run_length_white_sub0001 : STD_LOGIC_VECTOR ( 9 downto 0 ); 
  signal huffman_ins_v2_ter_black_code : STD_LOGIC_VECTOR ( 11 downto 0 ); 
  signal huffman_ins_v2_ter_white_code : STD_LOGIC_VECTOR ( 7 downto 0 ); 
  signal NlwRenamedSig_OI_run_len_code_o : STD_LOGIC_VECTOR ( 26 downto 26 ); 
begin
  frame_finished_o <= huffman_ins_v2_frame_finished_o_1814;
  run_len_code_valid_o <= huffman_ins_v2_run_len_code_valid_o_2082;
  run_len_code_o(27) <= NlwRenamedSig_OI_run_len_code_o(26);
  run_len_code_o(26) <= NlwRenamedSig_OI_run_len_code_o(26);
  fax4_x(9) <= NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(9);
  fax4_x(8) <= NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(8);
  fax4_x(7) <= NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(7);
  fax4_x(6) <= NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(6);
  fax4_x(5) <= NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(5);
  fax4_x(4) <= NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(4);
  fax4_x(3) <= NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(3);
  fax4_x(2) <= NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(2);
  fax4_x(1) <= NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(1);
  fax4_x(0) <= NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(0);
  fax4_y(8) <= NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt(8);
  fax4_y(7) <= NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt(7);
  fax4_y(6) <= NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt(6);
  fax4_y(5) <= NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt(5);
  fax4_y(4) <= NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt(4);
  fax4_y(3) <= NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt(3);
  fax4_y(2) <= NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt(2);
  fax4_y(1) <= NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt(1);
  fax4_y(0) <= NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt(0);
  XST_GND : GND
    port map (
      G => NlwRenamedSig_OI_run_len_code_o(26)
    );
  XST_VCC : VCC
    port map (
      P => N1
    );
  huffman_ins_v2_code_table_ins_makeup_white_0 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      D => huffman_ins_v2_code_table_ins_Mrom_makeup_white_mux0001,
      Q => huffman_ins_v2_code_table_ins_makeup_white(0)
    );
  huffman_ins_v2_code_table_ins_makeup_white_1 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      D => huffman_ins_v2_code_table_ins_Mrom_makeup_white_mux00011,
      Q => huffman_ins_v2_code_table_ins_makeup_white(1)
    );
  huffman_ins_v2_code_table_ins_makeup_white_2 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      D => huffman_ins_v2_code_table_ins_Mrom_makeup_white_mux00012,
      Q => huffman_ins_v2_code_table_ins_makeup_white(2)
    );
  huffman_ins_v2_code_table_ins_makeup_white_3 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      D => huffman_ins_v2_code_table_ins_Mrom_makeup_white_mux00013,
      Q => huffman_ins_v2_code_table_ins_makeup_white(3)
    );
  huffman_ins_v2_code_table_ins_makeup_white_4 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      D => huffman_ins_v2_code_table_ins_Mrom_makeup_white_mux00014,
      Q => huffman_ins_v2_code_table_ins_makeup_white(4)
    );
  huffman_ins_v2_code_table_ins_makeup_white_5 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      D => huffman_ins_v2_code_table_ins_Mrom_makeup_white_mux00015,
      Q => huffman_ins_v2_code_table_ins_makeup_white(5)
    );
  huffman_ins_v2_code_table_ins_makeup_white_7 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      D => huffman_ins_v2_code_table_ins_Mrom_makeup_white_mux00017,
      Q => huffman_ins_v2_code_table_ins_makeup_white(7)
    );
  huffman_ins_v2_code_table_ins_makeup_white_9 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      D => huffman_ins_v2_code_table_ins_Mrom_makeup_white_mux00019,
      Q => huffman_ins_v2_code_table_ins_makeup_white(9)
    );
  huffman_ins_v2_code_table_ins_makeup_black_1 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      D => huffman_ins_v2_code_table_ins_Mrom_makeup_black_mux00011,
      Q => huffman_ins_v2_code_table_ins_makeup_black_1_Q
    );
  huffman_ins_v2_code_table_ins_makeup_black_2 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      D => huffman_ins_v2_code_table_ins_Mrom_makeup_black_mux00012,
      Q => huffman_ins_v2_code_table_ins_makeup_black_2_Q
    );
  huffman_ins_v2_code_table_ins_makeup_black_3 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      D => huffman_ins_v2_code_table_ins_Mrom_makeup_black_mux00013,
      Q => huffman_ins_v2_code_table_ins_makeup_black_3_Q
    );
  huffman_ins_v2_code_table_ins_makeup_black_4 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      D => huffman_ins_v2_code_table_ins_Mrom_makeup_black_mux00014,
      Q => huffman_ins_v2_code_table_ins_makeup_black_4_Q
    );
  huffman_ins_v2_code_table_ins_makeup_black_5 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      D => huffman_ins_v2_code_table_ins_Mrom_makeup_black_mux00015,
      Q => huffman_ins_v2_code_table_ins_makeup_black_5_Q
    );
  huffman_ins_v2_code_table_ins_makeup_black_13 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      D => huffman_ins_v2_run_length_black(9),
      Q => huffman_ins_v2_code_table_ins_makeup_black_13_Q
    );
  huffman_ins_v2_code_table_ins_makeup_black_15 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      D => huffman_ins_v2_code_table_ins_Mrom_makeup_black_mux000115,
      Q => huffman_ins_v2_code_table_ins_makeup_black_15_Q
    );
  huffman_ins_v2_Msub_run_length_white_addsub0000_xor_9_Q : XORCY
    port map (
      CI => huffman_ins_v2_Msub_run_length_white_addsub0000_cy(8),
      LI => huffman_ins_v2_Msub_run_length_white_addsub0000_lut(9),
      O => huffman_ins_v2_run_length_white_addsub0000(9)
    );
  huffman_ins_v2_Msub_run_length_white_addsub0000_xor_8_Q : XORCY
    port map (
      CI => huffman_ins_v2_Msub_run_length_white_addsub0000_cy(7),
      LI => huffman_ins_v2_Msub_run_length_white_addsub0000_lut(8),
      O => huffman_ins_v2_run_length_white_addsub0000(8)
    );
  huffman_ins_v2_Msub_run_length_white_addsub0000_cy_8_Q : MUXCY
    port map (
      CI => huffman_ins_v2_Msub_run_length_white_addsub0000_cy(7),
      DI => N1,
      S => huffman_ins_v2_Msub_run_length_white_addsub0000_lut(8),
      O => huffman_ins_v2_Msub_run_length_white_addsub0000_cy(8)
    );
  huffman_ins_v2_Msub_run_length_white_addsub0000_xor_7_Q : XORCY
    port map (
      CI => huffman_ins_v2_Msub_run_length_white_addsub0000_cy(6),
      LI => huffman_ins_v2_Msub_run_length_white_addsub0000_lut(7),
      O => huffman_ins_v2_run_length_white_addsub0000(7)
    );
  huffman_ins_v2_Msub_run_length_white_addsub0000_cy_7_Q : MUXCY
    port map (
      CI => huffman_ins_v2_Msub_run_length_white_addsub0000_cy(6),
      DI => N1,
      S => huffman_ins_v2_Msub_run_length_white_addsub0000_lut(7),
      O => huffman_ins_v2_Msub_run_length_white_addsub0000_cy(7)
    );
  huffman_ins_v2_Msub_run_length_white_addsub0000_xor_6_Q : XORCY
    port map (
      CI => huffman_ins_v2_Msub_run_length_white_addsub0000_cy(5),
      LI => huffman_ins_v2_Msub_run_length_white_addsub0000_lut(6),
      O => huffman_ins_v2_run_length_white_addsub0000(6)
    );
  huffman_ins_v2_Msub_run_length_white_addsub0000_cy_6_Q : MUXCY
    port map (
      CI => huffman_ins_v2_Msub_run_length_white_addsub0000_cy(5),
      DI => N1,
      S => huffman_ins_v2_Msub_run_length_white_addsub0000_lut(6),
      O => huffman_ins_v2_Msub_run_length_white_addsub0000_cy(6)
    );
  huffman_ins_v2_Msub_run_length_white_addsub0000_xor_5_Q : XORCY
    port map (
      CI => huffman_ins_v2_Msub_run_length_white_addsub0000_cy(4),
      LI => huffman_ins_v2_Msub_run_length_white_addsub0000_lut(5),
      O => huffman_ins_v2_run_length_white_addsub0000(5)
    );
  huffman_ins_v2_Msub_run_length_white_addsub0000_cy_5_Q : MUXCY
    port map (
      CI => huffman_ins_v2_Msub_run_length_white_addsub0000_cy(4),
      DI => N1,
      S => huffman_ins_v2_Msub_run_length_white_addsub0000_lut(5),
      O => huffman_ins_v2_Msub_run_length_white_addsub0000_cy(5)
    );
  huffman_ins_v2_Msub_run_length_white_addsub0000_xor_4_Q : XORCY
    port map (
      CI => huffman_ins_v2_Msub_run_length_white_addsub0000_cy(3),
      LI => huffman_ins_v2_Msub_run_length_white_addsub0000_lut(4),
      O => huffman_ins_v2_run_length_white_addsub0000(4)
    );
  huffman_ins_v2_Msub_run_length_white_addsub0000_cy_4_Q : MUXCY
    port map (
      CI => huffman_ins_v2_Msub_run_length_white_addsub0000_cy(3),
      DI => N1,
      S => huffman_ins_v2_Msub_run_length_white_addsub0000_lut(4),
      O => huffman_ins_v2_Msub_run_length_white_addsub0000_cy(4)
    );
  huffman_ins_v2_Msub_run_length_white_addsub0000_xor_3_Q : XORCY
    port map (
      CI => huffman_ins_v2_Msub_run_length_white_addsub0000_cy(2),
      LI => huffman_ins_v2_Msub_run_length_white_addsub0000_lut(3),
      O => huffman_ins_v2_run_length_white_addsub0000(3)
    );
  huffman_ins_v2_Msub_run_length_white_addsub0000_cy_3_Q : MUXCY
    port map (
      CI => huffman_ins_v2_Msub_run_length_white_addsub0000_cy(2),
      DI => N1,
      S => huffman_ins_v2_Msub_run_length_white_addsub0000_lut(3),
      O => huffman_ins_v2_Msub_run_length_white_addsub0000_cy(3)
    );
  huffman_ins_v2_Msub_run_length_white_addsub0000_xor_2_Q : XORCY
    port map (
      CI => huffman_ins_v2_Msub_run_length_white_addsub0000_cy(1),
      LI => huffman_ins_v2_Msub_run_length_white_addsub0000_lut(2),
      O => huffman_ins_v2_run_length_white_addsub0000(2)
    );
  huffman_ins_v2_Msub_run_length_white_addsub0000_cy_2_Q : MUXCY
    port map (
      CI => huffman_ins_v2_Msub_run_length_white_addsub0000_cy(1),
      DI => N1,
      S => huffman_ins_v2_Msub_run_length_white_addsub0000_lut(2),
      O => huffman_ins_v2_Msub_run_length_white_addsub0000_cy(2)
    );
  huffman_ins_v2_Msub_run_length_white_addsub0000_xor_1_Q : XORCY
    port map (
      CI => huffman_ins_v2_Msub_run_length_white_addsub0000_cy(0),
      LI => huffman_ins_v2_Msub_run_length_white_addsub0000_lut(1),
      O => huffman_ins_v2_run_length_white_addsub0000(1)
    );
  huffman_ins_v2_Msub_run_length_white_addsub0000_cy_1_Q : MUXCY
    port map (
      CI => huffman_ins_v2_Msub_run_length_white_addsub0000_cy(0),
      DI => N1,
      S => huffman_ins_v2_Msub_run_length_white_addsub0000_lut(1),
      O => huffman_ins_v2_Msub_run_length_white_addsub0000_cy(1)
    );
  huffman_ins_v2_Msub_run_length_white_addsub0000_xor_0_Q : XORCY
    port map (
      CI => N1,
      LI => huffman_ins_v2_Msub_run_length_white_addsub0000_cy_0_rt_1404,
      O => huffman_ins_v2_run_length_white_addsub0000(0)
    );
  huffman_ins_v2_Msub_run_length_white_addsub0000_cy_0_Q : MUXCY
    port map (
      CI => N1,
      DI => NlwRenamedSig_OI_run_len_code_o(26),
      S => huffman_ins_v2_Msub_run_length_white_addsub0000_cy_0_rt_1404,
      O => huffman_ins_v2_Msub_run_length_white_addsub0000_cy(0)
    );
  huffman_ins_v2_Msub_run_length_white_sub0001_xor_9_Q : XORCY
    port map (
      CI => huffman_ins_v2_Msub_run_length_white_sub0001_cy(8),
      LI => huffman_ins_v2_Msub_run_length_white_sub0001_lut(9),
      O => huffman_ins_v2_run_length_white_sub0001(9)
    );
  huffman_ins_v2_Msub_run_length_white_sub0001_lut_9_Q : LUT2
    generic map(
      INIT => X"9"
    )
    port map (
      I0 => fax4_ins_a2_o(9),
      I1 => fax4_ins_a1_o(9),
      O => huffman_ins_v2_Msub_run_length_white_sub0001_lut(9)
    );
  huffman_ins_v2_Msub_run_length_white_sub0001_xor_8_Q : XORCY
    port map (
      CI => huffman_ins_v2_Msub_run_length_white_sub0001_cy(7),
      LI => huffman_ins_v2_Msub_run_length_white_sub0001_lut(8),
      O => huffman_ins_v2_run_length_white_sub0001(8)
    );
  huffman_ins_v2_Msub_run_length_white_sub0001_cy_8_Q : MUXCY
    port map (
      CI => huffman_ins_v2_Msub_run_length_white_sub0001_cy(7),
      DI => fax4_ins_a2_o(8),
      S => huffman_ins_v2_Msub_run_length_white_sub0001_lut(8),
      O => huffman_ins_v2_Msub_run_length_white_sub0001_cy(8)
    );
  huffman_ins_v2_Msub_run_length_white_sub0001_lut_8_Q : LUT2
    generic map(
      INIT => X"9"
    )
    port map (
      I0 => fax4_ins_a2_o(8),
      I1 => fax4_ins_a1_o(8),
      O => huffman_ins_v2_Msub_run_length_white_sub0001_lut(8)
    );
  huffman_ins_v2_Msub_run_length_white_sub0001_xor_7_Q : XORCY
    port map (
      CI => huffman_ins_v2_Msub_run_length_white_sub0001_cy(6),
      LI => huffman_ins_v2_Msub_run_length_white_sub0001_lut(7),
      O => huffman_ins_v2_run_length_white_sub0001(7)
    );
  huffman_ins_v2_Msub_run_length_white_sub0001_cy_7_Q : MUXCY
    port map (
      CI => huffman_ins_v2_Msub_run_length_white_sub0001_cy(6),
      DI => fax4_ins_a2_o(7),
      S => huffman_ins_v2_Msub_run_length_white_sub0001_lut(7),
      O => huffman_ins_v2_Msub_run_length_white_sub0001_cy(7)
    );
  huffman_ins_v2_Msub_run_length_white_sub0001_lut_7_Q : LUT2
    generic map(
      INIT => X"9"
    )
    port map (
      I0 => fax4_ins_a2_o(7),
      I1 => fax4_ins_a1_o(7),
      O => huffman_ins_v2_Msub_run_length_white_sub0001_lut(7)
    );
  huffman_ins_v2_Msub_run_length_white_sub0001_xor_6_Q : XORCY
    port map (
      CI => huffman_ins_v2_Msub_run_length_white_sub0001_cy(5),
      LI => huffman_ins_v2_Msub_run_length_white_sub0001_lut(6),
      O => huffman_ins_v2_run_length_white_sub0001(6)
    );
  huffman_ins_v2_Msub_run_length_white_sub0001_cy_6_Q : MUXCY
    port map (
      CI => huffman_ins_v2_Msub_run_length_white_sub0001_cy(5),
      DI => fax4_ins_a2_o(6),
      S => huffman_ins_v2_Msub_run_length_white_sub0001_lut(6),
      O => huffman_ins_v2_Msub_run_length_white_sub0001_cy(6)
    );
  huffman_ins_v2_Msub_run_length_white_sub0001_lut_6_Q : LUT2
    generic map(
      INIT => X"9"
    )
    port map (
      I0 => fax4_ins_a2_o(6),
      I1 => fax4_ins_a1_o(6),
      O => huffman_ins_v2_Msub_run_length_white_sub0001_lut(6)
    );
  huffman_ins_v2_Msub_run_length_white_sub0001_xor_5_Q : XORCY
    port map (
      CI => huffman_ins_v2_Msub_run_length_white_sub0001_cy(4),
      LI => huffman_ins_v2_Msub_run_length_white_sub0001_lut(5),
      O => huffman_ins_v2_run_length_white_sub0001(5)
    );
  huffman_ins_v2_Msub_run_length_white_sub0001_cy_5_Q : MUXCY
    port map (
      CI => huffman_ins_v2_Msub_run_length_white_sub0001_cy(4),
      DI => fax4_ins_a2_o(5),
      S => huffman_ins_v2_Msub_run_length_white_sub0001_lut(5),
      O => huffman_ins_v2_Msub_run_length_white_sub0001_cy(5)
    );
  huffman_ins_v2_Msub_run_length_white_sub0001_lut_5_Q : LUT2
    generic map(
      INIT => X"9"
    )
    port map (
      I0 => fax4_ins_a2_o(5),
      I1 => fax4_ins_a1_o(5),
      O => huffman_ins_v2_Msub_run_length_white_sub0001_lut(5)
    );
  huffman_ins_v2_Msub_run_length_white_sub0001_xor_4_Q : XORCY
    port map (
      CI => huffman_ins_v2_Msub_run_length_white_sub0001_cy(3),
      LI => huffman_ins_v2_Msub_run_length_white_sub0001_lut(4),
      O => huffman_ins_v2_run_length_white_sub0001(4)
    );
  huffman_ins_v2_Msub_run_length_white_sub0001_cy_4_Q : MUXCY
    port map (
      CI => huffman_ins_v2_Msub_run_length_white_sub0001_cy(3),
      DI => fax4_ins_a2_o(4),
      S => huffman_ins_v2_Msub_run_length_white_sub0001_lut(4),
      O => huffman_ins_v2_Msub_run_length_white_sub0001_cy(4)
    );
  huffman_ins_v2_Msub_run_length_white_sub0001_lut_4_Q : LUT2
    generic map(
      INIT => X"9"
    )
    port map (
      I0 => fax4_ins_a2_o(4),
      I1 => fax4_ins_a1_o(4),
      O => huffman_ins_v2_Msub_run_length_white_sub0001_lut(4)
    );
  huffman_ins_v2_Msub_run_length_white_sub0001_xor_3_Q : XORCY
    port map (
      CI => huffman_ins_v2_Msub_run_length_white_sub0001_cy(2),
      LI => huffman_ins_v2_Msub_run_length_white_sub0001_lut(3),
      O => huffman_ins_v2_run_length_white_sub0001(3)
    );
  huffman_ins_v2_Msub_run_length_white_sub0001_cy_3_Q : MUXCY
    port map (
      CI => huffman_ins_v2_Msub_run_length_white_sub0001_cy(2),
      DI => fax4_ins_a2_o(3),
      S => huffman_ins_v2_Msub_run_length_white_sub0001_lut(3),
      O => huffman_ins_v2_Msub_run_length_white_sub0001_cy(3)
    );
  huffman_ins_v2_Msub_run_length_white_sub0001_lut_3_Q : LUT2
    generic map(
      INIT => X"9"
    )
    port map (
      I0 => fax4_ins_a2_o(3),
      I1 => fax4_ins_a1_o(3),
      O => huffman_ins_v2_Msub_run_length_white_sub0001_lut(3)
    );
  huffman_ins_v2_Msub_run_length_white_sub0001_xor_2_Q : XORCY
    port map (
      CI => huffman_ins_v2_Msub_run_length_white_sub0001_cy(1),
      LI => huffman_ins_v2_Msub_run_length_white_sub0001_lut(2),
      O => huffman_ins_v2_run_length_white_sub0001(2)
    );
  huffman_ins_v2_Msub_run_length_white_sub0001_cy_2_Q : MUXCY
    port map (
      CI => huffman_ins_v2_Msub_run_length_white_sub0001_cy(1),
      DI => fax4_ins_a2_o(2),
      S => huffman_ins_v2_Msub_run_length_white_sub0001_lut(2),
      O => huffman_ins_v2_Msub_run_length_white_sub0001_cy(2)
    );
  huffman_ins_v2_Msub_run_length_white_sub0001_lut_2_Q : LUT2
    generic map(
      INIT => X"9"
    )
    port map (
      I0 => fax4_ins_a2_o(2),
      I1 => fax4_ins_a1_o(2),
      O => huffman_ins_v2_Msub_run_length_white_sub0001_lut(2)
    );
  huffman_ins_v2_Msub_run_length_white_sub0001_xor_1_Q : XORCY
    port map (
      CI => huffman_ins_v2_Msub_run_length_white_sub0001_cy(0),
      LI => huffman_ins_v2_Msub_run_length_white_sub0001_lut(1),
      O => huffman_ins_v2_run_length_white_sub0001(1)
    );
  huffman_ins_v2_Msub_run_length_white_sub0001_cy_1_Q : MUXCY
    port map (
      CI => huffman_ins_v2_Msub_run_length_white_sub0001_cy(0),
      DI => fax4_ins_a2_o(1),
      S => huffman_ins_v2_Msub_run_length_white_sub0001_lut(1),
      O => huffman_ins_v2_Msub_run_length_white_sub0001_cy(1)
    );
  huffman_ins_v2_Msub_run_length_white_sub0001_lut_1_Q : LUT2
    generic map(
      INIT => X"9"
    )
    port map (
      I0 => fax4_ins_a2_o(1),
      I1 => fax4_ins_a1_o(1),
      O => huffman_ins_v2_Msub_run_length_white_sub0001_lut(1)
    );
  huffman_ins_v2_Msub_run_length_white_sub0001_xor_0_Q : XORCY
    port map (
      CI => N1,
      LI => huffman_ins_v2_Msub_run_length_white_sub0001_lut(0),
      O => huffman_ins_v2_run_length_white_sub0001(0)
    );
  huffman_ins_v2_Msub_run_length_white_sub0001_cy_0_Q : MUXCY
    port map (
      CI => N1,
      DI => fax4_ins_a2_o(0),
      S => huffman_ins_v2_Msub_run_length_white_sub0001_lut(0),
      O => huffman_ins_v2_Msub_run_length_white_sub0001_cy(0)
    );
  huffman_ins_v2_Msub_run_length_white_sub0001_lut_0_Q : LUT2
    generic map(
      INIT => X"9"
    )
    port map (
      I0 => fax4_ins_a2_o(0),
      I1 => fax4_ins_a1_o(0),
      O => huffman_ins_v2_Msub_run_length_white_sub0001_lut(0)
    );
  huffman_ins_v2_Msub_run_length_white_sub0000_xor_9_Q : XORCY
    port map (
      CI => huffman_ins_v2_Msub_run_length_white_sub0000_cy(8),
      LI => huffman_ins_v2_Msub_run_length_white_sub0000_lut(9),
      O => huffman_ins_v2_run_length_white_sub0000(9)
    );
  huffman_ins_v2_Msub_run_length_white_sub0000_lut_9_Q : LUT2
    generic map(
      INIT => X"9"
    )
    port map (
      I0 => fax4_ins_a1_o(9),
      I1 => fax4_ins_a0_o(9),
      O => huffman_ins_v2_Msub_run_length_white_sub0000_lut(9)
    );
  huffman_ins_v2_Msub_run_length_white_sub0000_xor_8_Q : XORCY
    port map (
      CI => huffman_ins_v2_Msub_run_length_white_sub0000_cy(7),
      LI => huffman_ins_v2_Msub_run_length_white_sub0000_lut(8),
      O => huffman_ins_v2_run_length_white_sub0000(8)
    );
  huffman_ins_v2_Msub_run_length_white_sub0000_cy_8_Q : MUXCY
    port map (
      CI => huffman_ins_v2_Msub_run_length_white_sub0000_cy(7),
      DI => fax4_ins_a1_o(8),
      S => huffman_ins_v2_Msub_run_length_white_sub0000_lut(8),
      O => huffman_ins_v2_Msub_run_length_white_sub0000_cy(8)
    );
  huffman_ins_v2_Msub_run_length_white_sub0000_lut_8_Q : LUT2
    generic map(
      INIT => X"9"
    )
    port map (
      I0 => fax4_ins_a1_o(8),
      I1 => fax4_ins_a0_o(8),
      O => huffman_ins_v2_Msub_run_length_white_sub0000_lut(8)
    );
  huffman_ins_v2_Msub_run_length_white_sub0000_xor_7_Q : XORCY
    port map (
      CI => huffman_ins_v2_Msub_run_length_white_sub0000_cy(6),
      LI => huffman_ins_v2_Msub_run_length_white_sub0000_lut(7),
      O => huffman_ins_v2_run_length_white_sub0000(7)
    );
  huffman_ins_v2_Msub_run_length_white_sub0000_cy_7_Q : MUXCY
    port map (
      CI => huffman_ins_v2_Msub_run_length_white_sub0000_cy(6),
      DI => fax4_ins_a1_o(7),
      S => huffman_ins_v2_Msub_run_length_white_sub0000_lut(7),
      O => huffman_ins_v2_Msub_run_length_white_sub0000_cy(7)
    );
  huffman_ins_v2_Msub_run_length_white_sub0000_lut_7_Q : LUT2
    generic map(
      INIT => X"9"
    )
    port map (
      I0 => fax4_ins_a1_o(7),
      I1 => fax4_ins_a0_o(7),
      O => huffman_ins_v2_Msub_run_length_white_sub0000_lut(7)
    );
  huffman_ins_v2_Msub_run_length_white_sub0000_xor_6_Q : XORCY
    port map (
      CI => huffman_ins_v2_Msub_run_length_white_sub0000_cy(5),
      LI => huffman_ins_v2_Msub_run_length_white_sub0000_lut(6),
      O => huffman_ins_v2_run_length_white_sub0000(6)
    );
  huffman_ins_v2_Msub_run_length_white_sub0000_cy_6_Q : MUXCY
    port map (
      CI => huffman_ins_v2_Msub_run_length_white_sub0000_cy(5),
      DI => fax4_ins_a1_o(6),
      S => huffman_ins_v2_Msub_run_length_white_sub0000_lut(6),
      O => huffman_ins_v2_Msub_run_length_white_sub0000_cy(6)
    );
  huffman_ins_v2_Msub_run_length_white_sub0000_lut_6_Q : LUT2
    generic map(
      INIT => X"9"
    )
    port map (
      I0 => fax4_ins_a1_o(6),
      I1 => fax4_ins_a0_o(6),
      O => huffman_ins_v2_Msub_run_length_white_sub0000_lut(6)
    );
  huffman_ins_v2_Msub_run_length_white_sub0000_xor_5_Q : XORCY
    port map (
      CI => huffman_ins_v2_Msub_run_length_white_sub0000_cy(4),
      LI => huffman_ins_v2_Msub_run_length_white_sub0000_lut(5),
      O => huffman_ins_v2_run_length_white_sub0000(5)
    );
  huffman_ins_v2_Msub_run_length_white_sub0000_cy_5_Q : MUXCY
    port map (
      CI => huffman_ins_v2_Msub_run_length_white_sub0000_cy(4),
      DI => fax4_ins_a1_o(5),
      S => huffman_ins_v2_Msub_run_length_white_sub0000_lut(5),
      O => huffman_ins_v2_Msub_run_length_white_sub0000_cy(5)
    );
  huffman_ins_v2_Msub_run_length_white_sub0000_lut_5_Q : LUT2
    generic map(
      INIT => X"9"
    )
    port map (
      I0 => fax4_ins_a1_o(5),
      I1 => fax4_ins_a0_o(5),
      O => huffman_ins_v2_Msub_run_length_white_sub0000_lut(5)
    );
  huffman_ins_v2_Msub_run_length_white_sub0000_xor_4_Q : XORCY
    port map (
      CI => huffman_ins_v2_Msub_run_length_white_sub0000_cy(3),
      LI => huffman_ins_v2_Msub_run_length_white_sub0000_lut(4),
      O => huffman_ins_v2_run_length_white_sub0000(4)
    );
  huffman_ins_v2_Msub_run_length_white_sub0000_cy_4_Q : MUXCY
    port map (
      CI => huffman_ins_v2_Msub_run_length_white_sub0000_cy(3),
      DI => fax4_ins_a1_o(4),
      S => huffman_ins_v2_Msub_run_length_white_sub0000_lut(4),
      O => huffman_ins_v2_Msub_run_length_white_sub0000_cy(4)
    );
  huffman_ins_v2_Msub_run_length_white_sub0000_lut_4_Q : LUT2
    generic map(
      INIT => X"9"
    )
    port map (
      I0 => fax4_ins_a1_o(4),
      I1 => fax4_ins_a0_o(4),
      O => huffman_ins_v2_Msub_run_length_white_sub0000_lut(4)
    );
  huffman_ins_v2_Msub_run_length_white_sub0000_xor_3_Q : XORCY
    port map (
      CI => huffman_ins_v2_Msub_run_length_white_sub0000_cy(2),
      LI => huffman_ins_v2_Msub_run_length_white_sub0000_lut(3),
      O => huffman_ins_v2_run_length_white_sub0000(3)
    );
  huffman_ins_v2_Msub_run_length_white_sub0000_cy_3_Q : MUXCY
    port map (
      CI => huffman_ins_v2_Msub_run_length_white_sub0000_cy(2),
      DI => fax4_ins_a1_o(3),
      S => huffman_ins_v2_Msub_run_length_white_sub0000_lut(3),
      O => huffman_ins_v2_Msub_run_length_white_sub0000_cy(3)
    );
  huffman_ins_v2_Msub_run_length_white_sub0000_lut_3_Q : LUT2
    generic map(
      INIT => X"9"
    )
    port map (
      I0 => fax4_ins_a1_o(3),
      I1 => fax4_ins_a0_o(3),
      O => huffman_ins_v2_Msub_run_length_white_sub0000_lut(3)
    );
  huffman_ins_v2_Msub_run_length_white_sub0000_xor_2_Q : XORCY
    port map (
      CI => huffman_ins_v2_Msub_run_length_white_sub0000_cy(1),
      LI => huffman_ins_v2_Msub_run_length_white_sub0000_lut(2),
      O => huffman_ins_v2_run_length_white_sub0000(2)
    );
  huffman_ins_v2_Msub_run_length_white_sub0000_cy_2_Q : MUXCY
    port map (
      CI => huffman_ins_v2_Msub_run_length_white_sub0000_cy(1),
      DI => fax4_ins_a1_o(2),
      S => huffman_ins_v2_Msub_run_length_white_sub0000_lut(2),
      O => huffman_ins_v2_Msub_run_length_white_sub0000_cy(2)
    );
  huffman_ins_v2_Msub_run_length_white_sub0000_lut_2_Q : LUT2
    generic map(
      INIT => X"9"
    )
    port map (
      I0 => fax4_ins_a1_o(2),
      I1 => fax4_ins_a0_o(2),
      O => huffman_ins_v2_Msub_run_length_white_sub0000_lut(2)
    );
  huffman_ins_v2_Msub_run_length_white_sub0000_xor_1_Q : XORCY
    port map (
      CI => huffman_ins_v2_Msub_run_length_white_sub0000_cy(0),
      LI => huffman_ins_v2_Msub_run_length_white_sub0000_lut(1),
      O => huffman_ins_v2_run_length_white_sub0000(1)
    );
  huffman_ins_v2_Msub_run_length_white_sub0000_cy_1_Q : MUXCY
    port map (
      CI => huffman_ins_v2_Msub_run_length_white_sub0000_cy(0),
      DI => fax4_ins_a1_o(1),
      S => huffman_ins_v2_Msub_run_length_white_sub0000_lut(1),
      O => huffman_ins_v2_Msub_run_length_white_sub0000_cy(1)
    );
  huffman_ins_v2_Msub_run_length_white_sub0000_lut_1_Q : LUT2
    generic map(
      INIT => X"9"
    )
    port map (
      I0 => fax4_ins_a1_o(1),
      I1 => fax4_ins_a0_o(1),
      O => huffman_ins_v2_Msub_run_length_white_sub0000_lut(1)
    );
  huffman_ins_v2_Msub_run_length_white_sub0000_xor_0_Q : XORCY
    port map (
      CI => N1,
      LI => huffman_ins_v2_Msub_run_length_white_sub0000_lut(0),
      O => huffman_ins_v2_run_length_white_sub0000(0)
    );
  huffman_ins_v2_Msub_run_length_white_sub0000_cy_0_Q : MUXCY
    port map (
      CI => N1,
      DI => fax4_ins_a1_o(0),
      S => huffman_ins_v2_Msub_run_length_white_sub0000_lut(0),
      O => huffman_ins_v2_Msub_run_length_white_sub0000_cy(0)
    );
  huffman_ins_v2_Msub_run_length_white_sub0000_lut_0_Q : LUT2
    generic map(
      INIT => X"9"
    )
    port map (
      I0 => fax4_ins_a1_o(0),
      I1 => fax4_ins_a0_o(0),
      O => huffman_ins_v2_Msub_run_length_white_sub0000_lut(0)
    );
  huffman_ins_v2_code_white_width_4 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      D => huffman_ins_v2_Madd_code_white_width_add0000_cy_3_Q,
      Q => huffman_ins_v2_code_white_width(4)
    );
  huffman_ins_v2_code_white_width_3 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      D => huffman_ins_v2_code_white_width_add0000(3),
      Q => huffman_ins_v2_code_white_width(3)
    );
  huffman_ins_v2_code_white_width_2 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      D => huffman_ins_v2_code_white_width_add0000(2),
      Q => huffman_ins_v2_code_white_width(2)
    );
  huffman_ins_v2_code_white_width_1 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      D => huffman_ins_v2_code_white_width_add0000(1),
      Q => huffman_ins_v2_code_white_width(1)
    );
  huffman_ins_v2_code_white_width_0 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      D => huffman_ins_v2_Madd_code_white_width_add0000_lut(0),
      Q => huffman_ins_v2_code_white_width(0)
    );
  huffman_ins_v2_code_black_width_4 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      D => huffman_ins_v2_Madd_code_black_width_add0000_cy_3_Q,
      Q => huffman_ins_v2_code_black_width(4)
    );
  huffman_ins_v2_code_black_width_3 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      D => huffman_ins_v2_code_black_width_add0000(3),
      Q => huffman_ins_v2_code_black_width(3)
    );
  huffman_ins_v2_code_black_width_2 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      D => huffman_ins_v2_code_black_width_add0000(2),
      Q => huffman_ins_v2_code_black_width(2)
    );
  huffman_ins_v2_code_black_width_1 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      D => huffman_ins_v2_code_black_width_add0000(1),
      Q => huffman_ins_v2_code_black_width(1)
    );
  huffman_ins_v2_code_black_width_0 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      D => huffman_ins_v2_Madd_code_black_width_add0000_lut(0),
      Q => huffman_ins_v2_code_black_width(0)
    );
  huffman_ins_v2_horizontal_mode_part_2 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      D => huffman_ins_v2_horizontal_mode_part_1_2064,
      Q => huffman_ins_v2_horizontal_mode_part_2_2065
    );
  huffman_ins_v2_pass_vert_code_width_1_2 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      D => huffman_ins_v2_Mrom_run_length_i_rom00002,
      Q => huffman_ins_v2_pass_vert_code_width_1_2_Q
    );
  huffman_ins_v2_pass_vert_code_1_2 : FD
    generic map(
      INIT => '1'
    )
    port map (
      C => pclk_i,
      D => huffman_ins_v2_Mrom_run_length_i_rom00005,
      Q => huffman_ins_v2_pass_vert_code_1(2)
    );
  huffman_ins_v2_pass_vert_code_1_0 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      D => huffman_ins_v2_Mrom_run_length_i_rom00003,
      Q => huffman_ins_v2_pass_vert_code_1(0)
    );
  huffman_ins_v2_code_white_2 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      D => huffman_ins_v2_code_white_2_mux0000,
      Q => huffman_ins_v2_code_white(2)
    );
  huffman_ins_v2_code_white_1 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      D => huffman_ins_v2_code_white_1_mux0000,
      Q => huffman_ins_v2_code_white(1)
    );
  huffman_ins_v2_code_white_3 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      D => huffman_ins_v2_code_white_3_mux0000,
      Q => huffman_ins_v2_code_white(3)
    );
  huffman_ins_v2_hor_code_width_4 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      D => huffman_ins_v2_hor_code_width_mux0001(4),
      Q => huffman_ins_v2_hor_code_width(4)
    );
  huffman_ins_v2_hor_code_width_3 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      D => huffman_ins_v2_hor_code_width_mux0001(3),
      Q => huffman_ins_v2_hor_code_width(3)
    );
  huffman_ins_v2_hor_code_width_2 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      D => huffman_ins_v2_hor_code_width_mux0001(2),
      Q => huffman_ins_v2_hor_code_width(2)
    );
  huffman_ins_v2_hor_code_width_1 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      D => huffman_ins_v2_hor_code_width_mux0001(1),
      Q => huffman_ins_v2_hor_code_width(1)
    );
  huffman_ins_v2_hor_code_width_0 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      D => huffman_ins_v2_hor_code_width_mux0001(0),
      Q => huffman_ins_v2_hor_code_width(0)
    );
  huffman_ins_v2_code_white_0 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      D => huffman_ins_v2_code_white_0_mux0000,
      Q => huffman_ins_v2_code_white(0)
    );
  huffman_ins_v2_code_black_24 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      D => huffman_ins_v2_code_black_24_mux0000,
      Q => huffman_ins_v2_code_black(24)
    );
  huffman_ins_v2_code_black_19 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      D => huffman_ins_v2_code_black_19_mux0000,
      Q => huffman_ins_v2_code_black(19)
    );
  huffman_ins_v2_code_black_18 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      D => huffman_ins_v2_code_black_18_mux0000,
      Q => huffman_ins_v2_code_black(18)
    );
  huffman_ins_v2_code_black_17 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      D => huffman_ins_v2_code_black_17_mux0000,
      Q => huffman_ins_v2_code_black(17)
    );
  huffman_ins_v2_code_black_21 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      D => huffman_ins_v2_code_black_21_mux0000,
      Q => huffman_ins_v2_code_black(21)
    );
  huffman_ins_v2_code_black_16 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      D => huffman_ins_v2_code_black_16_mux0000,
      Q => huffman_ins_v2_code_black(16)
    );
  huffman_ins_v2_code_black_15 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      D => huffman_ins_v2_code_black_15_mux0000,
      Q => huffman_ins_v2_code_black(15)
    );
  huffman_ins_v2_code_black_14 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      D => huffman_ins_v2_code_black_14_mux0000,
      Q => huffman_ins_v2_code_black(14)
    );
  huffman_ins_v2_horizontal_mode_1 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      D => huffman_ins_v2_horizontal_mode_1_or0000,
      Q => huffman_ins_v2_horizontal_mode_1_2060
    );
  huffman_ins_v2_code_black_13 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      D => huffman_ins_v2_code_black_13_mux0000,
      Q => huffman_ins_v2_code_black(13)
    );
  huffman_ins_v2_code_black_9 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      D => huffman_ins_v2_code_black_9_mux0000,
      Q => huffman_ins_v2_code_black(9)
    );
  huffman_ins_v2_code_black_12 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      D => huffman_ins_v2_code_black_12_mux0000,
      Q => huffman_ins_v2_code_black(12)
    );
  huffman_ins_v2_code_black_11 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      D => huffman_ins_v2_code_black_11_mux0000,
      Q => huffman_ins_v2_code_black(11)
    );
  huffman_ins_v2_code_black_8 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      D => huffman_ins_v2_code_black_8_mux0000,
      Q => huffman_ins_v2_code_black(8)
    );
  huffman_ins_v2_code_black_10 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      D => huffman_ins_v2_code_black_10_mux0000,
      Q => huffman_ins_v2_code_black(10)
    );
  huffman_ins_v2_code_black_6 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      D => huffman_ins_v2_code_black_6_mux0000,
      Q => huffman_ins_v2_code_black(6)
    );
  huffman_ins_v2_code_black_7 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      D => huffman_ins_v2_code_black_7_mux0000,
      Q => huffman_ins_v2_code_black(7)
    );
  huffman_ins_v2_code_black_5 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      D => huffman_ins_v2_code_black_5_mux0000,
      Q => huffman_ins_v2_code_black(5)
    );
  huffman_ins_v2_horizontal_mode_part_1 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      D => huffman_ins_v2_horizontal_mode_1_cmp_eq0001,
      Q => huffman_ins_v2_horizontal_mode_part_1_2064
    );
  huffman_ins_v2_code_black_4 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      D => huffman_ins_v2_code_black_4_mux0000,
      Q => huffman_ins_v2_code_black(4)
    );
  huffman_ins_v2_code_black_3 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      D => huffman_ins_v2_code_black_3_mux0000,
      Q => huffman_ins_v2_code_black(3)
    );
  huffman_ins_v2_code_black_2 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      D => huffman_ins_v2_code_black_2_mux0000,
      Q => huffman_ins_v2_code_black(2)
    );
  huffman_ins_v2_code_black_1 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      D => huffman_ins_v2_code_black_1_mux0000,
      Q => huffman_ins_v2_code_black(1)
    );
  huffman_ins_v2_code_black_0 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      D => huffman_ins_v2_code_black_0_mux0000,
      Q => huffman_ins_v2_code_black(0)
    );
  huffman_ins_v2_code_white_16 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      D => huffman_ins_v2_code_white_16_mux0000,
      Q => huffman_ins_v2_code_white(16)
    );
  fax4_ins_counter_xy_v2_ins_line_valid : FDSE
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      CE => fax4_ins_counter_xy_v2_ins_cnt_x_reset_or0000,
      D => NlwRenamedSig_OI_run_len_code_o(26),
      S => fax4_ins_counter_xy_v2_ins_line_valid_and0000,
      Q => fax4_ins_counter_xy_v2_ins_line_valid_1210
    );
  fax4_ins_counter_xy_v2_ins_rsync_i_prev : FD
    generic map(
      INIT => '1'
    )
    port map (
      C => pclk_i,
      D => rsync_i,
      Q => fax4_ins_counter_xy_v2_ins_rsync_i_prev_1212
    );
  fax4_ins_counter_xy_v2_ins_cnt_y_reset : FDR
    generic map(
      INIT => '1'
    )
    port map (
      C => pclk_i,
      D => N1,
      R => fax4_ins_counter_xy_v2_ins_cnt_y_reset_or0000,
      Q => fax4_ins_counter_xy_v2_ins_cnt_y_reset_1105
    );
  fax4_ins_counter_xy_v2_ins_cnt_x_reset : FDRS
    generic map(
      INIT => '1'
    )
    port map (
      C => pclk_i,
      D => NlwRenamedSig_OI_run_len_code_o(26),
      R => fax4_ins_counter_xy_v2_ins_line_valid_and0000,
      S => fax4_ins_counter_xy_v2_ins_cnt_x_reset_or0000,
      Q => fax4_ins_counter_xy_v2_ins_cnt_x_reset_1102
    );
  fax4_ins_counter_xy_v2_ins_fsync_i_prev : FD
    generic map(
      INIT => '1'
    )
    port map (
      C => pclk_i,
      D => fsync_i,
      Q => fax4_ins_counter_xy_v2_ins_fsync_i_prev_1209
    );
  fax4_ins_counter_xy_v2_ins_frame_valid : FDSE
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      CE => fax4_ins_counter_xy_v2_ins_frame_valid_and0001,
      D => NlwRenamedSig_OI_run_len_code_o(26),
      S => fax4_ins_counter_xy_v2_ins_frame_valid_and0000,
      Q => fax4_ins_counter_xy_v2_ins_frame_valid_1206
    );
  fax4_ins_counter_xy_v2_ins_cnt_x_overflow_prev : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      D => fax4_ins_counter_xy_v2_ins_counter_x_ins_overflow_o_1157,
      Q => fax4_ins_counter_xy_v2_ins_cnt_x_overflow_prev_1101
    );
  fax4_ins_counter_xy_v2_ins_cnt_y_overflow_prev : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      D => fax4_ins_counter_xy_v2_ins_counter_y_ins_overflow_o_1204,
      Q => fax4_ins_counter_xy_v2_ins_cnt_y_overflow_prev_1104
    );
  fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt_2 : FDCE
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      CE => fax4_ins_counter_xy_v2_ins_cnt_x_en,
      CLR => fax4_ins_counter_xy_v2_ins_cnt_x_reset_1102,
      D => fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt_mux0000(7),
      Q => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(2)
    );
  fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt_0 : FDPE
    generic map(
      INIT => '1'
    )
    port map (
      C => pclk_i,
      CE => fax4_ins_counter_xy_v2_ins_cnt_x_en,
      D => fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt_mux0000(9),
      PRE => fax4_ins_counter_xy_v2_ins_cnt_x_reset_1102,
      Q => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(0)
    );
  fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt_1 : FDCE
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      CE => fax4_ins_counter_xy_v2_ins_cnt_x_en,
      CLR => fax4_ins_counter_xy_v2_ins_cnt_x_reset_1102,
      D => fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt_mux0000(8),
      Q => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(1)
    );
  fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt_3 : FDCE
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      CE => fax4_ins_counter_xy_v2_ins_cnt_x_en,
      CLR => fax4_ins_counter_xy_v2_ins_cnt_x_reset_1102,
      D => fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt_mux0000(6),
      Q => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(3)
    );
  fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt_4 : FDCE
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      CE => fax4_ins_counter_xy_v2_ins_cnt_x_en,
      CLR => fax4_ins_counter_xy_v2_ins_cnt_x_reset_1102,
      D => fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt_mux0000(5),
      Q => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(4)
    );
  fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt_7 : FDCE
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      CE => fax4_ins_counter_xy_v2_ins_cnt_x_en,
      CLR => fax4_ins_counter_xy_v2_ins_cnt_x_reset_1102,
      D => fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt_mux0000(2),
      Q => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(7)
    );
  fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt_5 : FDCE
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      CE => fax4_ins_counter_xy_v2_ins_cnt_x_en,
      CLR => fax4_ins_counter_xy_v2_ins_cnt_x_reset_1102,
      D => fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt_mux0000(4),
      Q => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(5)
    );
  fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt_6 : FDCE
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      CE => fax4_ins_counter_xy_v2_ins_cnt_x_en,
      CLR => fax4_ins_counter_xy_v2_ins_cnt_x_reset_1102,
      D => fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt_mux0000(3),
      Q => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(6)
    );
  fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt_8 : FDCE
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      CE => fax4_ins_counter_xy_v2_ins_cnt_x_en,
      CLR => fax4_ins_counter_xy_v2_ins_cnt_x_reset_1102,
      D => fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt_mux0000(1),
      Q => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(8)
    );
  fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt_9 : FDCE
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      CE => fax4_ins_counter_xy_v2_ins_cnt_x_en,
      CLR => fax4_ins_counter_xy_v2_ins_cnt_x_reset_1102,
      D => fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt_mux0000(0),
      Q => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(9)
    );
  fax4_ins_counter_xy_v2_ins_counter_x_ins_Madd_cnt_addsub0000_xor_9_Q : XORCY
    port map (
      CI => fax4_ins_counter_xy_v2_ins_counter_x_ins_Madd_cnt_addsub0000_cy(8),
      LI => fax4_ins_counter_xy_v2_ins_counter_x_ins_Madd_cnt_addsub0000_xor_9_rt_1125,
      O => fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt_addsub0000(9)
    );
  fax4_ins_counter_xy_v2_ins_counter_x_ins_Madd_cnt_addsub0000_xor_8_Q : XORCY
    port map (
      CI => fax4_ins_counter_xy_v2_ins_counter_x_ins_Madd_cnt_addsub0000_cy(7),
      LI => fax4_ins_counter_xy_v2_ins_counter_x_ins_Madd_cnt_addsub0000_cy_8_rt_1123,
      O => fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt_addsub0000(8)
    );
  fax4_ins_counter_xy_v2_ins_counter_x_ins_Madd_cnt_addsub0000_cy_8_Q : MUXCY
    port map (
      CI => fax4_ins_counter_xy_v2_ins_counter_x_ins_Madd_cnt_addsub0000_cy(7),
      DI => NlwRenamedSig_OI_run_len_code_o(26),
      S => fax4_ins_counter_xy_v2_ins_counter_x_ins_Madd_cnt_addsub0000_cy_8_rt_1123,
      O => fax4_ins_counter_xy_v2_ins_counter_x_ins_Madd_cnt_addsub0000_cy(8)
    );
  fax4_ins_counter_xy_v2_ins_counter_x_ins_Madd_cnt_addsub0000_xor_7_Q : XORCY
    port map (
      CI => fax4_ins_counter_xy_v2_ins_counter_x_ins_Madd_cnt_addsub0000_cy(6),
      LI => fax4_ins_counter_xy_v2_ins_counter_x_ins_Madd_cnt_addsub0000_cy_7_rt_1121,
      O => fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt_addsub0000(7)
    );
  fax4_ins_counter_xy_v2_ins_counter_x_ins_Madd_cnt_addsub0000_cy_7_Q : MUXCY
    port map (
      CI => fax4_ins_counter_xy_v2_ins_counter_x_ins_Madd_cnt_addsub0000_cy(6),
      DI => NlwRenamedSig_OI_run_len_code_o(26),
      S => fax4_ins_counter_xy_v2_ins_counter_x_ins_Madd_cnt_addsub0000_cy_7_rt_1121,
      O => fax4_ins_counter_xy_v2_ins_counter_x_ins_Madd_cnt_addsub0000_cy(7)
    );
  fax4_ins_counter_xy_v2_ins_counter_x_ins_Madd_cnt_addsub0000_xor_6_Q : XORCY
    port map (
      CI => fax4_ins_counter_xy_v2_ins_counter_x_ins_Madd_cnt_addsub0000_cy(5),
      LI => fax4_ins_counter_xy_v2_ins_counter_x_ins_Madd_cnt_addsub0000_cy_6_rt_1119,
      O => fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt_addsub0000(6)
    );
  fax4_ins_counter_xy_v2_ins_counter_x_ins_Madd_cnt_addsub0000_cy_6_Q : MUXCY
    port map (
      CI => fax4_ins_counter_xy_v2_ins_counter_x_ins_Madd_cnt_addsub0000_cy(5),
      DI => NlwRenamedSig_OI_run_len_code_o(26),
      S => fax4_ins_counter_xy_v2_ins_counter_x_ins_Madd_cnt_addsub0000_cy_6_rt_1119,
      O => fax4_ins_counter_xy_v2_ins_counter_x_ins_Madd_cnt_addsub0000_cy(6)
    );
  fax4_ins_counter_xy_v2_ins_counter_x_ins_Madd_cnt_addsub0000_xor_5_Q : XORCY
    port map (
      CI => fax4_ins_counter_xy_v2_ins_counter_x_ins_Madd_cnt_addsub0000_cy(4),
      LI => fax4_ins_counter_xy_v2_ins_counter_x_ins_Madd_cnt_addsub0000_cy_5_rt_1117,
      O => fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt_addsub0000(5)
    );
  fax4_ins_counter_xy_v2_ins_counter_x_ins_Madd_cnt_addsub0000_cy_5_Q : MUXCY
    port map (
      CI => fax4_ins_counter_xy_v2_ins_counter_x_ins_Madd_cnt_addsub0000_cy(4),
      DI => NlwRenamedSig_OI_run_len_code_o(26),
      S => fax4_ins_counter_xy_v2_ins_counter_x_ins_Madd_cnt_addsub0000_cy_5_rt_1117,
      O => fax4_ins_counter_xy_v2_ins_counter_x_ins_Madd_cnt_addsub0000_cy(5)
    );
  fax4_ins_counter_xy_v2_ins_counter_x_ins_Madd_cnt_addsub0000_xor_4_Q : XORCY
    port map (
      CI => fax4_ins_counter_xy_v2_ins_counter_x_ins_Madd_cnt_addsub0000_cy(3),
      LI => fax4_ins_counter_xy_v2_ins_counter_x_ins_Madd_cnt_addsub0000_cy_4_rt_1115,
      O => fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt_addsub0000(4)
    );
  fax4_ins_counter_xy_v2_ins_counter_x_ins_Madd_cnt_addsub0000_cy_4_Q : MUXCY
    port map (
      CI => fax4_ins_counter_xy_v2_ins_counter_x_ins_Madd_cnt_addsub0000_cy(3),
      DI => NlwRenamedSig_OI_run_len_code_o(26),
      S => fax4_ins_counter_xy_v2_ins_counter_x_ins_Madd_cnt_addsub0000_cy_4_rt_1115,
      O => fax4_ins_counter_xy_v2_ins_counter_x_ins_Madd_cnt_addsub0000_cy(4)
    );
  fax4_ins_counter_xy_v2_ins_counter_x_ins_Madd_cnt_addsub0000_xor_3_Q : XORCY
    port map (
      CI => fax4_ins_counter_xy_v2_ins_counter_x_ins_Madd_cnt_addsub0000_cy(2),
      LI => fax4_ins_counter_xy_v2_ins_counter_x_ins_Madd_cnt_addsub0000_cy_3_rt_1113,
      O => fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt_addsub0000(3)
    );
  fax4_ins_counter_xy_v2_ins_counter_x_ins_Madd_cnt_addsub0000_cy_3_Q : MUXCY
    port map (
      CI => fax4_ins_counter_xy_v2_ins_counter_x_ins_Madd_cnt_addsub0000_cy(2),
      DI => NlwRenamedSig_OI_run_len_code_o(26),
      S => fax4_ins_counter_xy_v2_ins_counter_x_ins_Madd_cnt_addsub0000_cy_3_rt_1113,
      O => fax4_ins_counter_xy_v2_ins_counter_x_ins_Madd_cnt_addsub0000_cy(3)
    );
  fax4_ins_counter_xy_v2_ins_counter_x_ins_Madd_cnt_addsub0000_xor_2_Q : XORCY
    port map (
      CI => fax4_ins_counter_xy_v2_ins_counter_x_ins_Madd_cnt_addsub0000_cy(1),
      LI => fax4_ins_counter_xy_v2_ins_counter_x_ins_Madd_cnt_addsub0000_cy_2_rt_1111,
      O => fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt_addsub0000(2)
    );
  fax4_ins_counter_xy_v2_ins_counter_x_ins_Madd_cnt_addsub0000_cy_2_Q : MUXCY
    port map (
      CI => fax4_ins_counter_xy_v2_ins_counter_x_ins_Madd_cnt_addsub0000_cy(1),
      DI => NlwRenamedSig_OI_run_len_code_o(26),
      S => fax4_ins_counter_xy_v2_ins_counter_x_ins_Madd_cnt_addsub0000_cy_2_rt_1111,
      O => fax4_ins_counter_xy_v2_ins_counter_x_ins_Madd_cnt_addsub0000_cy(2)
    );
  fax4_ins_counter_xy_v2_ins_counter_x_ins_Madd_cnt_addsub0000_xor_1_Q : XORCY
    port map (
      CI => fax4_ins_counter_xy_v2_ins_counter_x_ins_Madd_cnt_addsub0000_cy(0),
      LI => fax4_ins_counter_xy_v2_ins_counter_x_ins_Madd_cnt_addsub0000_cy_1_rt_1109,
      O => fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt_addsub0000(1)
    );
  fax4_ins_counter_xy_v2_ins_counter_x_ins_Madd_cnt_addsub0000_cy_1_Q : MUXCY
    port map (
      CI => fax4_ins_counter_xy_v2_ins_counter_x_ins_Madd_cnt_addsub0000_cy(0),
      DI => NlwRenamedSig_OI_run_len_code_o(26),
      S => fax4_ins_counter_xy_v2_ins_counter_x_ins_Madd_cnt_addsub0000_cy_1_rt_1109,
      O => fax4_ins_counter_xy_v2_ins_counter_x_ins_Madd_cnt_addsub0000_cy(1)
    );
  fax4_ins_counter_xy_v2_ins_counter_x_ins_Madd_cnt_addsub0000_xor_0_Q : XORCY
    port map (
      CI => NlwRenamedSig_OI_run_len_code_o(26),
      LI => fax4_ins_counter_xy_v2_ins_counter_x_ins_Madd_cnt_addsub0000_lut(0),
      O => fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt_addsub0000(0)
    );
  fax4_ins_counter_xy_v2_ins_counter_x_ins_Madd_cnt_addsub0000_cy_0_Q : MUXCY
    port map (
      CI => NlwRenamedSig_OI_run_len_code_o(26),
      DI => N1,
      S => fax4_ins_counter_xy_v2_ins_counter_x_ins_Madd_cnt_addsub0000_lut(0),
      O => fax4_ins_counter_xy_v2_ins_counter_x_ins_Madd_cnt_addsub0000_cy(0)
    );
  fax4_ins_counter_xy_v2_ins_counter_x_ins_overflow_o : FDC
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      CLR => fax4_ins_counter_xy_v2_ins_cnt_x_reset_1102,
      D => fax4_ins_counter_xy_v2_ins_counter_x_ins_overflow_o_mux0002,
      Q => fax4_ins_counter_xy_v2_ins_counter_x_ins_overflow_o_1157
    );
  fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt_2 : FDCE
    generic map(
      INIT => '0'
    )
    port map (
      C => fax4_ins_counter_xy_v2_ins_counter_x_ins_overflow_o_1157,
      CE => fax4_ins_counter_xy_v2_ins_frame_valid_1206,
      CLR => fax4_ins_counter_xy_v2_ins_cnt_y_reset_1105,
      D => fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt_mux0000(6),
      Q => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt(2)
    );
  fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt_0 : FDPE
    generic map(
      INIT => '1'
    )
    port map (
      C => fax4_ins_counter_xy_v2_ins_counter_x_ins_overflow_o_1157,
      CE => fax4_ins_counter_xy_v2_ins_frame_valid_1206,
      D => fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt_mux0000(8),
      PRE => fax4_ins_counter_xy_v2_ins_cnt_y_reset_1105,
      Q => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt(0)
    );
  fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt_1 : FDCE
    generic map(
      INIT => '0'
    )
    port map (
      C => fax4_ins_counter_xy_v2_ins_counter_x_ins_overflow_o_1157,
      CE => fax4_ins_counter_xy_v2_ins_frame_valid_1206,
      CLR => fax4_ins_counter_xy_v2_ins_cnt_y_reset_1105,
      D => fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt_mux0000(7),
      Q => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt(1)
    );
  fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt_3 : FDCE
    generic map(
      INIT => '0'
    )
    port map (
      C => fax4_ins_counter_xy_v2_ins_counter_x_ins_overflow_o_1157,
      CE => fax4_ins_counter_xy_v2_ins_frame_valid_1206,
      CLR => fax4_ins_counter_xy_v2_ins_cnt_y_reset_1105,
      D => fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt_mux0000(5),
      Q => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt(3)
    );
  fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt_4 : FDCE
    generic map(
      INIT => '0'
    )
    port map (
      C => fax4_ins_counter_xy_v2_ins_counter_x_ins_overflow_o_1157,
      CE => fax4_ins_counter_xy_v2_ins_frame_valid_1206,
      CLR => fax4_ins_counter_xy_v2_ins_cnt_y_reset_1105,
      D => fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt_mux0000(4),
      Q => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt(4)
    );
  fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt_5 : FDCE
    generic map(
      INIT => '0'
    )
    port map (
      C => fax4_ins_counter_xy_v2_ins_counter_x_ins_overflow_o_1157,
      CE => fax4_ins_counter_xy_v2_ins_frame_valid_1206,
      CLR => fax4_ins_counter_xy_v2_ins_cnt_y_reset_1105,
      D => fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt_mux0000(3),
      Q => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt(5)
    );
  fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt_6 : FDCE
    generic map(
      INIT => '0'
    )
    port map (
      C => fax4_ins_counter_xy_v2_ins_counter_x_ins_overflow_o_1157,
      CE => fax4_ins_counter_xy_v2_ins_frame_valid_1206,
      CLR => fax4_ins_counter_xy_v2_ins_cnt_y_reset_1105,
      D => fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt_mux0000(2),
      Q => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt(6)
    );
  fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt_7 : FDCE
    generic map(
      INIT => '0'
    )
    port map (
      C => fax4_ins_counter_xy_v2_ins_counter_x_ins_overflow_o_1157,
      CE => fax4_ins_counter_xy_v2_ins_frame_valid_1206,
      CLR => fax4_ins_counter_xy_v2_ins_cnt_y_reset_1105,
      D => fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt_mux0000(1),
      Q => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt(7)
    );
  fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt_8 : FDCE
    generic map(
      INIT => '0'
    )
    port map (
      C => fax4_ins_counter_xy_v2_ins_counter_x_ins_overflow_o_1157,
      CE => fax4_ins_counter_xy_v2_ins_frame_valid_1206,
      CLR => fax4_ins_counter_xy_v2_ins_cnt_y_reset_1105,
      D => fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt_mux0000(0),
      Q => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt(8)
    );
  fax4_ins_counter_xy_v2_ins_counter_y_ins_Madd_cnt_addsub0000_xor_8_Q : XORCY
    port map (
      CI => fax4_ins_counter_xy_v2_ins_counter_y_ins_Madd_cnt_addsub0000_cy(7),
      LI => fax4_ins_counter_xy_v2_ins_counter_y_ins_Madd_cnt_addsub0000_xor_8_rt_1175,
      O => fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt_addsub0000(8)
    );
  fax4_ins_counter_xy_v2_ins_counter_y_ins_Madd_cnt_addsub0000_xor_7_Q : XORCY
    port map (
      CI => fax4_ins_counter_xy_v2_ins_counter_y_ins_Madd_cnt_addsub0000_cy(6),
      LI => fax4_ins_counter_xy_v2_ins_counter_y_ins_Madd_cnt_addsub0000_cy_7_rt_1173,
      O => fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt_addsub0000(7)
    );
  fax4_ins_counter_xy_v2_ins_counter_y_ins_Madd_cnt_addsub0000_cy_7_Q : MUXCY
    port map (
      CI => fax4_ins_counter_xy_v2_ins_counter_y_ins_Madd_cnt_addsub0000_cy(6),
      DI => NlwRenamedSig_OI_run_len_code_o(26),
      S => fax4_ins_counter_xy_v2_ins_counter_y_ins_Madd_cnt_addsub0000_cy_7_rt_1173,
      O => fax4_ins_counter_xy_v2_ins_counter_y_ins_Madd_cnt_addsub0000_cy(7)
    );
  fax4_ins_counter_xy_v2_ins_counter_y_ins_Madd_cnt_addsub0000_xor_6_Q : XORCY
    port map (
      CI => fax4_ins_counter_xy_v2_ins_counter_y_ins_Madd_cnt_addsub0000_cy(5),
      LI => fax4_ins_counter_xy_v2_ins_counter_y_ins_Madd_cnt_addsub0000_cy_6_rt_1171,
      O => fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt_addsub0000(6)
    );
  fax4_ins_counter_xy_v2_ins_counter_y_ins_Madd_cnt_addsub0000_cy_6_Q : MUXCY
    port map (
      CI => fax4_ins_counter_xy_v2_ins_counter_y_ins_Madd_cnt_addsub0000_cy(5),
      DI => NlwRenamedSig_OI_run_len_code_o(26),
      S => fax4_ins_counter_xy_v2_ins_counter_y_ins_Madd_cnt_addsub0000_cy_6_rt_1171,
      O => fax4_ins_counter_xy_v2_ins_counter_y_ins_Madd_cnt_addsub0000_cy(6)
    );
  fax4_ins_counter_xy_v2_ins_counter_y_ins_Madd_cnt_addsub0000_xor_5_Q : XORCY
    port map (
      CI => fax4_ins_counter_xy_v2_ins_counter_y_ins_Madd_cnt_addsub0000_cy(4),
      LI => fax4_ins_counter_xy_v2_ins_counter_y_ins_Madd_cnt_addsub0000_cy_5_rt_1169,
      O => fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt_addsub0000(5)
    );
  fax4_ins_counter_xy_v2_ins_counter_y_ins_Madd_cnt_addsub0000_cy_5_Q : MUXCY
    port map (
      CI => fax4_ins_counter_xy_v2_ins_counter_y_ins_Madd_cnt_addsub0000_cy(4),
      DI => NlwRenamedSig_OI_run_len_code_o(26),
      S => fax4_ins_counter_xy_v2_ins_counter_y_ins_Madd_cnt_addsub0000_cy_5_rt_1169,
      O => fax4_ins_counter_xy_v2_ins_counter_y_ins_Madd_cnt_addsub0000_cy(5)
    );
  fax4_ins_counter_xy_v2_ins_counter_y_ins_Madd_cnt_addsub0000_xor_4_Q : XORCY
    port map (
      CI => fax4_ins_counter_xy_v2_ins_counter_y_ins_Madd_cnt_addsub0000_cy(3),
      LI => fax4_ins_counter_xy_v2_ins_counter_y_ins_Madd_cnt_addsub0000_cy_4_rt_1167,
      O => fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt_addsub0000(4)
    );
  fax4_ins_counter_xy_v2_ins_counter_y_ins_Madd_cnt_addsub0000_cy_4_Q : MUXCY
    port map (
      CI => fax4_ins_counter_xy_v2_ins_counter_y_ins_Madd_cnt_addsub0000_cy(3),
      DI => NlwRenamedSig_OI_run_len_code_o(26),
      S => fax4_ins_counter_xy_v2_ins_counter_y_ins_Madd_cnt_addsub0000_cy_4_rt_1167,
      O => fax4_ins_counter_xy_v2_ins_counter_y_ins_Madd_cnt_addsub0000_cy(4)
    );
  fax4_ins_counter_xy_v2_ins_counter_y_ins_Madd_cnt_addsub0000_xor_3_Q : XORCY
    port map (
      CI => fax4_ins_counter_xy_v2_ins_counter_y_ins_Madd_cnt_addsub0000_cy(2),
      LI => fax4_ins_counter_xy_v2_ins_counter_y_ins_Madd_cnt_addsub0000_cy_3_rt_1165,
      O => fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt_addsub0000(3)
    );
  fax4_ins_counter_xy_v2_ins_counter_y_ins_Madd_cnt_addsub0000_cy_3_Q : MUXCY
    port map (
      CI => fax4_ins_counter_xy_v2_ins_counter_y_ins_Madd_cnt_addsub0000_cy(2),
      DI => NlwRenamedSig_OI_run_len_code_o(26),
      S => fax4_ins_counter_xy_v2_ins_counter_y_ins_Madd_cnt_addsub0000_cy_3_rt_1165,
      O => fax4_ins_counter_xy_v2_ins_counter_y_ins_Madd_cnt_addsub0000_cy(3)
    );
  fax4_ins_counter_xy_v2_ins_counter_y_ins_Madd_cnt_addsub0000_xor_2_Q : XORCY
    port map (
      CI => fax4_ins_counter_xy_v2_ins_counter_y_ins_Madd_cnt_addsub0000_cy(1),
      LI => fax4_ins_counter_xy_v2_ins_counter_y_ins_Madd_cnt_addsub0000_cy_2_rt_1163,
      O => fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt_addsub0000(2)
    );
  fax4_ins_counter_xy_v2_ins_counter_y_ins_Madd_cnt_addsub0000_cy_2_Q : MUXCY
    port map (
      CI => fax4_ins_counter_xy_v2_ins_counter_y_ins_Madd_cnt_addsub0000_cy(1),
      DI => NlwRenamedSig_OI_run_len_code_o(26),
      S => fax4_ins_counter_xy_v2_ins_counter_y_ins_Madd_cnt_addsub0000_cy_2_rt_1163,
      O => fax4_ins_counter_xy_v2_ins_counter_y_ins_Madd_cnt_addsub0000_cy(2)
    );
  fax4_ins_counter_xy_v2_ins_counter_y_ins_Madd_cnt_addsub0000_xor_1_Q : XORCY
    port map (
      CI => fax4_ins_counter_xy_v2_ins_counter_y_ins_Madd_cnt_addsub0000_cy(0),
      LI => fax4_ins_counter_xy_v2_ins_counter_y_ins_Madd_cnt_addsub0000_cy_1_rt_1161,
      O => fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt_addsub0000(1)
    );
  fax4_ins_counter_xy_v2_ins_counter_y_ins_Madd_cnt_addsub0000_cy_1_Q : MUXCY
    port map (
      CI => fax4_ins_counter_xy_v2_ins_counter_y_ins_Madd_cnt_addsub0000_cy(0),
      DI => NlwRenamedSig_OI_run_len_code_o(26),
      S => fax4_ins_counter_xy_v2_ins_counter_y_ins_Madd_cnt_addsub0000_cy_1_rt_1161,
      O => fax4_ins_counter_xy_v2_ins_counter_y_ins_Madd_cnt_addsub0000_cy(1)
    );
  fax4_ins_counter_xy_v2_ins_counter_y_ins_Madd_cnt_addsub0000_xor_0_Q : XORCY
    port map (
      CI => NlwRenamedSig_OI_run_len_code_o(26),
      LI => fax4_ins_counter_xy_v2_ins_counter_y_ins_Madd_cnt_addsub0000_lut(0),
      O => fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt_addsub0000(0)
    );
  fax4_ins_counter_xy_v2_ins_counter_y_ins_Madd_cnt_addsub0000_cy_0_Q : MUXCY
    port map (
      CI => NlwRenamedSig_OI_run_len_code_o(26),
      DI => N1,
      S => fax4_ins_counter_xy_v2_ins_counter_y_ins_Madd_cnt_addsub0000_lut(0),
      O => fax4_ins_counter_xy_v2_ins_counter_y_ins_Madd_cnt_addsub0000_cy(0)
    );
  fax4_ins_counter_xy_v2_ins_counter_y_ins_overflow_o : FDC
    generic map(
      INIT => '0'
    )
    port map (
      C => fax4_ins_counter_xy_v2_ins_counter_x_ins_overflow_o_1157,
      CLR => fax4_ins_counter_xy_v2_ins_cnt_y_reset_1105,
      D => fax4_ins_counter_xy_v2_ins_counter_y_ins_overflow_o_mux0002,
      Q => fax4_ins_counter_xy_v2_ins_counter_y_ins_overflow_o_1204
    );
  fax4_ins_FIFO1_multi_read_ins_to_white3_o : FDPE
    generic map(
      INIT => '0'
    )
    port map (
      C => fax4_ins_pclk_not,
      CE => fax4_ins_FIFO1_multi_read_ins_latch3,
      D => fax4_ins_FIFO1_multi_read_ins_mux3_to_white,
      PRE => frame_finished_wire,
      Q => fax4_ins_FIFO1_multi_read_ins_to_white3_o_443
    );
  fax4_ins_FIFO1_multi_read_ins_data1_o_0 : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => fax4_ins_pclk_not,
      CE => fax4_ins_FIFO1_multi_read_ins_latch1,
      D => fax4_ins_FIFO1_multi_read_ins_mux1_x(0),
      Q => fax4_ins_FIFO1_multi_read_ins_data1_o(0)
    );
  fax4_ins_FIFO1_multi_read_ins_data1_o_1 : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => fax4_ins_pclk_not,
      CE => fax4_ins_FIFO1_multi_read_ins_latch1,
      D => fax4_ins_FIFO1_multi_read_ins_mux1_x(1),
      Q => fax4_ins_FIFO1_multi_read_ins_data1_o(1)
    );
  fax4_ins_FIFO1_multi_read_ins_data1_o_2 : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => fax4_ins_pclk_not,
      CE => fax4_ins_FIFO1_multi_read_ins_latch1,
      D => fax4_ins_FIFO1_multi_read_ins_mux1_x(2),
      Q => fax4_ins_FIFO1_multi_read_ins_data1_o(2)
    );
  fax4_ins_FIFO1_multi_read_ins_data1_o_3 : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => fax4_ins_pclk_not,
      CE => fax4_ins_FIFO1_multi_read_ins_latch1,
      D => fax4_ins_FIFO1_multi_read_ins_mux1_x(3),
      Q => fax4_ins_FIFO1_multi_read_ins_data1_o(3)
    );
  fax4_ins_FIFO1_multi_read_ins_data1_o_4 : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => fax4_ins_pclk_not,
      CE => fax4_ins_FIFO1_multi_read_ins_latch1,
      D => fax4_ins_FIFO1_multi_read_ins_mux1_x(4),
      Q => fax4_ins_FIFO1_multi_read_ins_data1_o(4)
    );
  fax4_ins_FIFO1_multi_read_ins_data1_o_5 : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => fax4_ins_pclk_not,
      CE => fax4_ins_FIFO1_multi_read_ins_latch1,
      D => fax4_ins_FIFO1_multi_read_ins_mux1_x(5),
      Q => fax4_ins_FIFO1_multi_read_ins_data1_o(5)
    );
  fax4_ins_FIFO1_multi_read_ins_data1_o_6 : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => fax4_ins_pclk_not,
      CE => fax4_ins_FIFO1_multi_read_ins_latch1,
      D => fax4_ins_FIFO1_multi_read_ins_mux1_x(6),
      Q => fax4_ins_FIFO1_multi_read_ins_data1_o(6)
    );
  fax4_ins_FIFO1_multi_read_ins_data1_o_7 : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => fax4_ins_pclk_not,
      CE => fax4_ins_FIFO1_multi_read_ins_latch1,
      D => fax4_ins_FIFO1_multi_read_ins_mux1_x(7),
      Q => fax4_ins_FIFO1_multi_read_ins_data1_o(7)
    );
  fax4_ins_FIFO1_multi_read_ins_data1_o_8 : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => fax4_ins_pclk_not,
      CE => fax4_ins_FIFO1_multi_read_ins_latch1,
      D => fax4_ins_FIFO1_multi_read_ins_mux1_x(8),
      Q => fax4_ins_FIFO1_multi_read_ins_data1_o(8)
    );
  fax4_ins_FIFO1_multi_read_ins_data1_o_9 : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => fax4_ins_pclk_not,
      CE => fax4_ins_FIFO1_multi_read_ins_latch1,
      D => fax4_ins_FIFO1_multi_read_ins_mux1_x(9),
      Q => fax4_ins_FIFO1_multi_read_ins_data1_o(9)
    );
  fax4_ins_FIFO1_multi_read_ins_valid1_o : FDCE
    generic map(
      INIT => '0'
    )
    port map (
      C => fax4_ins_pclk_not,
      CE => fax4_ins_FIFO1_multi_read_ins_latch1,
      CLR => frame_finished_wire,
      D => fax4_ins_FIFO1_multi_read_ins_mux1_valid,
      Q => fax4_ins_FIFO1_multi_read_ins_valid1_o_456
    );
  fax4_ins_FIFO1_multi_read_ins_data2_o_0 : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => fax4_ins_pclk_not,
      CE => fax4_ins_FIFO1_multi_read_ins_latch2,
      D => fax4_ins_FIFO1_multi_read_ins_mux2_x(0),
      Q => fax4_ins_FIFO1_multi_read_ins_data2_o(0)
    );
  fax4_ins_FIFO1_multi_read_ins_data2_o_1 : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => fax4_ins_pclk_not,
      CE => fax4_ins_FIFO1_multi_read_ins_latch2,
      D => fax4_ins_FIFO1_multi_read_ins_mux2_x(1),
      Q => fax4_ins_FIFO1_multi_read_ins_data2_o(1)
    );
  fax4_ins_FIFO1_multi_read_ins_data2_o_2 : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => fax4_ins_pclk_not,
      CE => fax4_ins_FIFO1_multi_read_ins_latch2,
      D => fax4_ins_FIFO1_multi_read_ins_mux2_x(2),
      Q => fax4_ins_FIFO1_multi_read_ins_data2_o(2)
    );
  fax4_ins_FIFO1_multi_read_ins_data2_o_3 : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => fax4_ins_pclk_not,
      CE => fax4_ins_FIFO1_multi_read_ins_latch2,
      D => fax4_ins_FIFO1_multi_read_ins_mux2_x(3),
      Q => fax4_ins_FIFO1_multi_read_ins_data2_o(3)
    );
  fax4_ins_FIFO1_multi_read_ins_data2_o_4 : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => fax4_ins_pclk_not,
      CE => fax4_ins_FIFO1_multi_read_ins_latch2,
      D => fax4_ins_FIFO1_multi_read_ins_mux2_x(4),
      Q => fax4_ins_FIFO1_multi_read_ins_data2_o(4)
    );
  fax4_ins_FIFO1_multi_read_ins_data2_o_5 : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => fax4_ins_pclk_not,
      CE => fax4_ins_FIFO1_multi_read_ins_latch2,
      D => fax4_ins_FIFO1_multi_read_ins_mux2_x(5),
      Q => fax4_ins_FIFO1_multi_read_ins_data2_o(5)
    );
  fax4_ins_FIFO1_multi_read_ins_data2_o_6 : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => fax4_ins_pclk_not,
      CE => fax4_ins_FIFO1_multi_read_ins_latch2,
      D => fax4_ins_FIFO1_multi_read_ins_mux2_x(6),
      Q => fax4_ins_FIFO1_multi_read_ins_data2_o(6)
    );
  fax4_ins_FIFO1_multi_read_ins_data2_o_7 : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => fax4_ins_pclk_not,
      CE => fax4_ins_FIFO1_multi_read_ins_latch2,
      D => fax4_ins_FIFO1_multi_read_ins_mux2_x(7),
      Q => fax4_ins_FIFO1_multi_read_ins_data2_o(7)
    );
  fax4_ins_FIFO1_multi_read_ins_data2_o_8 : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => fax4_ins_pclk_not,
      CE => fax4_ins_FIFO1_multi_read_ins_latch2,
      D => fax4_ins_FIFO1_multi_read_ins_mux2_x(8),
      Q => fax4_ins_FIFO1_multi_read_ins_data2_o(8)
    );
  fax4_ins_FIFO1_multi_read_ins_data2_o_9 : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => fax4_ins_pclk_not,
      CE => fax4_ins_FIFO1_multi_read_ins_latch2,
      D => fax4_ins_FIFO1_multi_read_ins_mux2_x(9),
      Q => fax4_ins_FIFO1_multi_read_ins_data2_o(9)
    );
  fax4_ins_FIFO1_multi_read_ins_valid2_o : FDCE
    generic map(
      INIT => '0'
    )
    port map (
      C => fax4_ins_pclk_not,
      CE => fax4_ins_FIFO1_multi_read_ins_latch2,
      CLR => frame_finished_wire,
      D => fax4_ins_FIFO1_multi_read_ins_mux2_valid,
      Q => fax4_ins_FIFO1_multi_read_ins_valid2_o_457
    );
  fax4_ins_FIFO1_multi_read_ins_data3_o_0 : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => fax4_ins_pclk_not,
      CE => fax4_ins_FIFO1_multi_read_ins_latch3,
      D => fax4_ins_FIFO1_multi_read_ins_mux3_x(0),
      Q => fax4_ins_FIFO1_multi_read_ins_data3_o(0)
    );
  fax4_ins_FIFO1_multi_read_ins_data3_o_1 : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => fax4_ins_pclk_not,
      CE => fax4_ins_FIFO1_multi_read_ins_latch3,
      D => fax4_ins_FIFO1_multi_read_ins_mux3_x(1),
      Q => fax4_ins_FIFO1_multi_read_ins_data3_o(1)
    );
  fax4_ins_FIFO1_multi_read_ins_data3_o_2 : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => fax4_ins_pclk_not,
      CE => fax4_ins_FIFO1_multi_read_ins_latch3,
      D => fax4_ins_FIFO1_multi_read_ins_mux3_x(2),
      Q => fax4_ins_FIFO1_multi_read_ins_data3_o(2)
    );
  fax4_ins_FIFO1_multi_read_ins_data3_o_3 : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => fax4_ins_pclk_not,
      CE => fax4_ins_FIFO1_multi_read_ins_latch3,
      D => fax4_ins_FIFO1_multi_read_ins_mux3_x(3),
      Q => fax4_ins_FIFO1_multi_read_ins_data3_o(3)
    );
  fax4_ins_FIFO1_multi_read_ins_data3_o_4 : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => fax4_ins_pclk_not,
      CE => fax4_ins_FIFO1_multi_read_ins_latch3,
      D => fax4_ins_FIFO1_multi_read_ins_mux3_x(4),
      Q => fax4_ins_FIFO1_multi_read_ins_data3_o(4)
    );
  fax4_ins_FIFO1_multi_read_ins_data3_o_5 : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => fax4_ins_pclk_not,
      CE => fax4_ins_FIFO1_multi_read_ins_latch3,
      D => fax4_ins_FIFO1_multi_read_ins_mux3_x(5),
      Q => fax4_ins_FIFO1_multi_read_ins_data3_o(5)
    );
  fax4_ins_FIFO1_multi_read_ins_data3_o_6 : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => fax4_ins_pclk_not,
      CE => fax4_ins_FIFO1_multi_read_ins_latch3,
      D => fax4_ins_FIFO1_multi_read_ins_mux3_x(6),
      Q => fax4_ins_FIFO1_multi_read_ins_data3_o(6)
    );
  fax4_ins_FIFO1_multi_read_ins_data3_o_7 : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => fax4_ins_pclk_not,
      CE => fax4_ins_FIFO1_multi_read_ins_latch3,
      D => fax4_ins_FIFO1_multi_read_ins_mux3_x(7),
      Q => fax4_ins_FIFO1_multi_read_ins_data3_o(7)
    );
  fax4_ins_FIFO1_multi_read_ins_data3_o_8 : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => fax4_ins_pclk_not,
      CE => fax4_ins_FIFO1_multi_read_ins_latch3,
      D => fax4_ins_FIFO1_multi_read_ins_mux3_x(8),
      Q => fax4_ins_FIFO1_multi_read_ins_data3_o(8)
    );
  fax4_ins_FIFO1_multi_read_ins_data3_o_9 : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => fax4_ins_pclk_not,
      CE => fax4_ins_FIFO1_multi_read_ins_latch3,
      D => fax4_ins_FIFO1_multi_read_ins_mux3_x(9),
      Q => fax4_ins_FIFO1_multi_read_ins_data3_o(9)
    );
  fax4_ins_FIFO1_multi_read_ins_valid3_o : FDCE
    generic map(
      INIT => '0'
    )
    port map (
      C => fax4_ins_pclk_not,
      CE => fax4_ins_FIFO1_multi_read_ins_latch3,
      CLR => frame_finished_wire,
      D => fax4_ins_FIFO1_multi_read_ins_mux3_valid,
      Q => fax4_ins_FIFO1_multi_read_ins_valid3_o_458
    );
  fax4_ins_FIFO1_multi_read_ins_to_white1_o : FDPE
    generic map(
      INIT => '0'
    )
    port map (
      C => fax4_ins_pclk_not,
      CE => fax4_ins_FIFO1_multi_read_ins_latch1,
      D => fax4_ins_FIFO1_multi_read_ins_mux1_to_white,
      PRE => frame_finished_wire,
      Q => fax4_ins_FIFO1_multi_read_ins_to_white1_o_441
    );
  fax4_ins_FIFO1_multi_read_ins_to_white2_o : FDPE
    generic map(
      INIT => '0'
    )
    port map (
      C => fax4_ins_pclk_not,
      CE => fax4_ins_FIFO1_multi_read_ins_latch2,
      D => fax4_ins_FIFO1_multi_read_ins_mux2_to_white,
      PRE => frame_finished_wire,
      Q => fax4_ins_FIFO1_multi_read_ins_to_white2_o_442
    );
  fax4_ins_FIFO1_multi_read_ins_read_pos_0 : FDCE
    generic map(
      INIT => '0'
    )
    port map (
      C => fax4_ins_pclk_not,
      CE => fax4_ins_FIFO1_multi_read_ins_mem_rd_387,
      CLR => frame_finished_wire,
      D => fax4_ins_FIFO1_multi_read_ins_Mcount_read_pos_eqn_0,
      Q => fax4_ins_FIFO1_multi_read_ins_read_pos(0)
    );
  fax4_ins_FIFO1_multi_read_ins_read_pos_1 : FDCE
    generic map(
      INIT => '0'
    )
    port map (
      C => fax4_ins_pclk_not,
      CE => fax4_ins_FIFO1_multi_read_ins_mem_rd_387,
      CLR => frame_finished_wire,
      D => fax4_ins_FIFO1_multi_read_ins_Mcount_read_pos_eqn_1,
      Q => fax4_ins_FIFO1_multi_read_ins_read_pos(1)
    );
  fax4_ins_FIFO1_multi_read_ins_read_pos_2 : FDCE
    generic map(
      INIT => '0'
    )
    port map (
      C => fax4_ins_pclk_not,
      CE => fax4_ins_FIFO1_multi_read_ins_mem_rd_387,
      CLR => frame_finished_wire,
      D => fax4_ins_FIFO1_multi_read_ins_Mcount_read_pos_eqn_2,
      Q => fax4_ins_FIFO1_multi_read_ins_read_pos(2)
    );
  fax4_ins_FIFO1_multi_read_ins_read_pos_3 : FDCE
    generic map(
      INIT => '0'
    )
    port map (
      C => fax4_ins_pclk_not,
      CE => fax4_ins_FIFO1_multi_read_ins_mem_rd_387,
      CLR => frame_finished_wire,
      D => fax4_ins_FIFO1_multi_read_ins_Mcount_read_pos_eqn_3,
      Q => fax4_ins_FIFO1_multi_read_ins_read_pos(3)
    );
  fax4_ins_FIFO1_multi_read_ins_read_pos_4 : FDCE
    generic map(
      INIT => '0'
    )
    port map (
      C => fax4_ins_pclk_not,
      CE => fax4_ins_FIFO1_multi_read_ins_mem_rd_387,
      CLR => frame_finished_wire,
      D => fax4_ins_FIFO1_multi_read_ins_Mcount_read_pos_eqn_4,
      Q => fax4_ins_FIFO1_multi_read_ins_read_pos(4)
    );
  fax4_ins_FIFO1_multi_read_ins_read_pos_5 : FDCE
    generic map(
      INIT => '0'
    )
    port map (
      C => fax4_ins_pclk_not,
      CE => fax4_ins_FIFO1_multi_read_ins_mem_rd_387,
      CLR => frame_finished_wire,
      D => fax4_ins_FIFO1_multi_read_ins_Mcount_read_pos_eqn_5,
      Q => fax4_ins_FIFO1_multi_read_ins_read_pos(5)
    );
  fax4_ins_FIFO1_multi_read_ins_read_pos_6 : FDCE
    generic map(
      INIT => '0'
    )
    port map (
      C => fax4_ins_pclk_not,
      CE => fax4_ins_FIFO1_multi_read_ins_mem_rd_387,
      CLR => frame_finished_wire,
      D => fax4_ins_FIFO1_multi_read_ins_Mcount_read_pos_eqn_6,
      Q => fax4_ins_FIFO1_multi_read_ins_read_pos(6)
    );
  fax4_ins_FIFO1_multi_read_ins_read_pos_7 : FDCE
    generic map(
      INIT => '0'
    )
    port map (
      C => fax4_ins_pclk_not,
      CE => fax4_ins_FIFO1_multi_read_ins_mem_rd_387,
      CLR => frame_finished_wire,
      D => fax4_ins_FIFO1_multi_read_ins_Mcount_read_pos_eqn_7,
      Q => fax4_ins_FIFO1_multi_read_ins_read_pos(7)
    );
  fax4_ins_FIFO1_multi_read_ins_read_pos_8 : FDCE
    generic map(
      INIT => '0'
    )
    port map (
      C => fax4_ins_pclk_not,
      CE => fax4_ins_FIFO1_multi_read_ins_mem_rd_387,
      CLR => frame_finished_wire,
      D => fax4_ins_FIFO1_multi_read_ins_Mcount_read_pos_eqn_8,
      Q => fax4_ins_FIFO1_multi_read_ins_read_pos(8)
    );
  fax4_ins_FIFO1_multi_read_ins_read_pos_9 : FDCE
    generic map(
      INIT => '0'
    )
    port map (
      C => fax4_ins_pclk_not,
      CE => fax4_ins_FIFO1_multi_read_ins_mem_rd_387,
      CLR => frame_finished_wire,
      D => fax4_ins_FIFO1_multi_read_ins_Mcount_read_pos_eqn_9,
      Q => fax4_ins_FIFO1_multi_read_ins_read_pos(9)
    );
  fax4_ins_FIFO1_multi_read_ins_write_pos_0 : FDCE
    generic map(
      INIT => '0'
    )
    port map (
      C => fax4_ins_pclk_not,
      CE => fax4_ins_FIFO1_multi_read_ins_wr_459,
      CLR => frame_finished_wire,
      D => fax4_ins_FIFO1_multi_read_ins_Mcount_write_pos_eqn_0,
      Q => fax4_ins_FIFO1_multi_read_ins_write_pos(0)
    );
  fax4_ins_FIFO1_multi_read_ins_write_pos_1 : FDCE
    generic map(
      INIT => '0'
    )
    port map (
      C => fax4_ins_pclk_not,
      CE => fax4_ins_FIFO1_multi_read_ins_wr_459,
      CLR => frame_finished_wire,
      D => fax4_ins_FIFO1_multi_read_ins_Mcount_write_pos_eqn_1,
      Q => fax4_ins_FIFO1_multi_read_ins_write_pos(1)
    );
  fax4_ins_FIFO1_multi_read_ins_write_pos_2 : FDCE
    generic map(
      INIT => '0'
    )
    port map (
      C => fax4_ins_pclk_not,
      CE => fax4_ins_FIFO1_multi_read_ins_wr_459,
      CLR => frame_finished_wire,
      D => fax4_ins_FIFO1_multi_read_ins_Mcount_write_pos_eqn_2,
      Q => fax4_ins_FIFO1_multi_read_ins_write_pos(2)
    );
  fax4_ins_FIFO1_multi_read_ins_write_pos_3 : FDCE
    generic map(
      INIT => '0'
    )
    port map (
      C => fax4_ins_pclk_not,
      CE => fax4_ins_FIFO1_multi_read_ins_wr_459,
      CLR => frame_finished_wire,
      D => fax4_ins_FIFO1_multi_read_ins_Mcount_write_pos_eqn_3,
      Q => fax4_ins_FIFO1_multi_read_ins_write_pos(3)
    );
  fax4_ins_FIFO1_multi_read_ins_write_pos_4 : FDCE
    generic map(
      INIT => '0'
    )
    port map (
      C => fax4_ins_pclk_not,
      CE => fax4_ins_FIFO1_multi_read_ins_wr_459,
      CLR => frame_finished_wire,
      D => fax4_ins_FIFO1_multi_read_ins_Mcount_write_pos_eqn_4,
      Q => fax4_ins_FIFO1_multi_read_ins_write_pos(4)
    );
  fax4_ins_FIFO1_multi_read_ins_write_pos_5 : FDCE
    generic map(
      INIT => '0'
    )
    port map (
      C => fax4_ins_pclk_not,
      CE => fax4_ins_FIFO1_multi_read_ins_wr_459,
      CLR => frame_finished_wire,
      D => fax4_ins_FIFO1_multi_read_ins_Mcount_write_pos_eqn_5,
      Q => fax4_ins_FIFO1_multi_read_ins_write_pos(5)
    );
  fax4_ins_FIFO1_multi_read_ins_write_pos_6 : FDCE
    generic map(
      INIT => '0'
    )
    port map (
      C => fax4_ins_pclk_not,
      CE => fax4_ins_FIFO1_multi_read_ins_wr_459,
      CLR => frame_finished_wire,
      D => fax4_ins_FIFO1_multi_read_ins_Mcount_write_pos_eqn_6,
      Q => fax4_ins_FIFO1_multi_read_ins_write_pos(6)
    );
  fax4_ins_FIFO1_multi_read_ins_write_pos_7 : FDCE
    generic map(
      INIT => '0'
    )
    port map (
      C => fax4_ins_pclk_not,
      CE => fax4_ins_FIFO1_multi_read_ins_wr_459,
      CLR => frame_finished_wire,
      D => fax4_ins_FIFO1_multi_read_ins_Mcount_write_pos_eqn_7,
      Q => fax4_ins_FIFO1_multi_read_ins_write_pos(7)
    );
  fax4_ins_FIFO1_multi_read_ins_write_pos_8 : FDCE
    generic map(
      INIT => '0'
    )
    port map (
      C => fax4_ins_pclk_not,
      CE => fax4_ins_FIFO1_multi_read_ins_wr_459,
      CLR => frame_finished_wire,
      D => fax4_ins_FIFO1_multi_read_ins_Mcount_write_pos_eqn_8,
      Q => fax4_ins_FIFO1_multi_read_ins_write_pos(8)
    );
  fax4_ins_FIFO1_multi_read_ins_write_pos_9 : FDCE
    generic map(
      INIT => '0'
    )
    port map (
      C => fax4_ins_pclk_not,
      CE => fax4_ins_FIFO1_multi_read_ins_wr_459,
      CLR => frame_finished_wire,
      D => fax4_ins_FIFO1_multi_read_ins_Mcount_write_pos_eqn_9,
      Q => fax4_ins_FIFO1_multi_read_ins_write_pos(9)
    );
  fax4_ins_FIFO1_multi_read_ins_used_0 : FDCE
    generic map(
      INIT => '0'
    )
    port map (
      C => fax4_ins_pclk_not,
      CE => fax4_ins_FIFO1_multi_read_ins_used_not0002_454,
      CLR => frame_finished_wire,
      D => fax4_ins_FIFO1_multi_read_ins_Result_0_2,
      Q => fax4_ins_FIFO1_multi_read_ins_used(0)
    );
  fax4_ins_FIFO1_multi_read_ins_used_1 : FDCE
    generic map(
      INIT => '0'
    )
    port map (
      C => fax4_ins_pclk_not,
      CE => fax4_ins_FIFO1_multi_read_ins_used_not0002_454,
      CLR => frame_finished_wire,
      D => fax4_ins_FIFO1_multi_read_ins_Result_1_2,
      Q => fax4_ins_FIFO1_multi_read_ins_used(1)
    );
  fax4_ins_FIFO1_multi_read_ins_used_2 : FDCE
    generic map(
      INIT => '0'
    )
    port map (
      C => fax4_ins_pclk_not,
      CE => fax4_ins_FIFO1_multi_read_ins_used_not0002_454,
      CLR => frame_finished_wire,
      D => fax4_ins_FIFO1_multi_read_ins_Result_2_2,
      Q => fax4_ins_FIFO1_multi_read_ins_used(2)
    );
  fax4_ins_FIFO1_multi_read_ins_used_3 : FDCE
    generic map(
      INIT => '0'
    )
    port map (
      C => fax4_ins_pclk_not,
      CE => fax4_ins_FIFO1_multi_read_ins_used_not0002_454,
      CLR => frame_finished_wire,
      D => fax4_ins_FIFO1_multi_read_ins_Result_3_2,
      Q => fax4_ins_FIFO1_multi_read_ins_used(3)
    );
  fax4_ins_FIFO1_multi_read_ins_used_4 : FDCE
    generic map(
      INIT => '0'
    )
    port map (
      C => fax4_ins_pclk_not,
      CE => fax4_ins_FIFO1_multi_read_ins_used_not0002_454,
      CLR => frame_finished_wire,
      D => fax4_ins_FIFO1_multi_read_ins_Result_4_2,
      Q => fax4_ins_FIFO1_multi_read_ins_used(4)
    );
  fax4_ins_FIFO1_multi_read_ins_used_5 : FDCE
    generic map(
      INIT => '0'
    )
    port map (
      C => fax4_ins_pclk_not,
      CE => fax4_ins_FIFO1_multi_read_ins_used_not0002_454,
      CLR => frame_finished_wire,
      D => fax4_ins_FIFO1_multi_read_ins_Result_5_2,
      Q => fax4_ins_FIFO1_multi_read_ins_used(5)
    );
  fax4_ins_FIFO1_multi_read_ins_used_6 : FDCE
    generic map(
      INIT => '0'
    )
    port map (
      C => fax4_ins_pclk_not,
      CE => fax4_ins_FIFO1_multi_read_ins_used_not0002_454,
      CLR => frame_finished_wire,
      D => fax4_ins_FIFO1_multi_read_ins_Result_6_2,
      Q => fax4_ins_FIFO1_multi_read_ins_used(6)
    );
  fax4_ins_FIFO1_multi_read_ins_used_7 : FDCE
    generic map(
      INIT => '0'
    )
    port map (
      C => fax4_ins_pclk_not,
      CE => fax4_ins_FIFO1_multi_read_ins_used_not0002_454,
      CLR => frame_finished_wire,
      D => fax4_ins_FIFO1_multi_read_ins_Result_7_2,
      Q => fax4_ins_FIFO1_multi_read_ins_used(7)
    );
  fax4_ins_FIFO1_multi_read_ins_used_8 : FDCE
    generic map(
      INIT => '0'
    )
    port map (
      C => fax4_ins_pclk_not,
      CE => fax4_ins_FIFO1_multi_read_ins_used_not0002_454,
      CLR => frame_finished_wire,
      D => fax4_ins_FIFO1_multi_read_ins_Result_8_2,
      Q => fax4_ins_FIFO1_multi_read_ins_used(8)
    );
  fax4_ins_FIFO1_multi_read_ins_used_9 : FDCE
    generic map(
      INIT => '0'
    )
    port map (
      C => fax4_ins_pclk_not,
      CE => fax4_ins_FIFO1_multi_read_ins_used_not0002_454,
      CLR => frame_finished_wire,
      D => fax4_ins_FIFO1_multi_read_ins_Result_9_2,
      Q => fax4_ins_FIFO1_multi_read_ins_used(9)
    );
  fax4_ins_FIFO1_multi_read_ins_Mcount_used_cy_0_Q : MUXCY
    port map (
      CI => fax4_ins_FIFO1_multi_read_ins_used_not0003_inv,
      DI => fax4_ins_FIFO1_multi_read_ins_used(0),
      S => fax4_ins_FIFO1_multi_read_ins_Mcount_used_lut(0),
      O => fax4_ins_FIFO1_multi_read_ins_Mcount_used_cy(0)
    );
  fax4_ins_FIFO1_multi_read_ins_Mcount_used_xor_0_Q : XORCY
    port map (
      CI => fax4_ins_FIFO1_multi_read_ins_used_not0003_inv,
      LI => fax4_ins_FIFO1_multi_read_ins_Mcount_used_lut(0),
      O => fax4_ins_FIFO1_multi_read_ins_Result_0_2
    );
  fax4_ins_FIFO1_multi_read_ins_Mcount_used_cy_1_Q : MUXCY
    port map (
      CI => fax4_ins_FIFO1_multi_read_ins_Mcount_used_cy(0),
      DI => fax4_ins_FIFO1_multi_read_ins_used(1),
      S => fax4_ins_FIFO1_multi_read_ins_Mcount_used_lut(1),
      O => fax4_ins_FIFO1_multi_read_ins_Mcount_used_cy(1)
    );
  fax4_ins_FIFO1_multi_read_ins_Mcount_used_xor_1_Q : XORCY
    port map (
      CI => fax4_ins_FIFO1_multi_read_ins_Mcount_used_cy(0),
      LI => fax4_ins_FIFO1_multi_read_ins_Mcount_used_lut(1),
      O => fax4_ins_FIFO1_multi_read_ins_Result_1_2
    );
  fax4_ins_FIFO1_multi_read_ins_Mcount_used_cy_2_Q : MUXCY
    port map (
      CI => fax4_ins_FIFO1_multi_read_ins_Mcount_used_cy(1),
      DI => fax4_ins_FIFO1_multi_read_ins_used(2),
      S => fax4_ins_FIFO1_multi_read_ins_Mcount_used_lut(2),
      O => fax4_ins_FIFO1_multi_read_ins_Mcount_used_cy(2)
    );
  fax4_ins_FIFO1_multi_read_ins_Mcount_used_xor_2_Q : XORCY
    port map (
      CI => fax4_ins_FIFO1_multi_read_ins_Mcount_used_cy(1),
      LI => fax4_ins_FIFO1_multi_read_ins_Mcount_used_lut(2),
      O => fax4_ins_FIFO1_multi_read_ins_Result_2_2
    );
  fax4_ins_FIFO1_multi_read_ins_Mcount_used_cy_3_Q : MUXCY
    port map (
      CI => fax4_ins_FIFO1_multi_read_ins_Mcount_used_cy(2),
      DI => fax4_ins_FIFO1_multi_read_ins_used(3),
      S => fax4_ins_FIFO1_multi_read_ins_Mcount_used_lut(3),
      O => fax4_ins_FIFO1_multi_read_ins_Mcount_used_cy(3)
    );
  fax4_ins_FIFO1_multi_read_ins_Mcount_used_xor_3_Q : XORCY
    port map (
      CI => fax4_ins_FIFO1_multi_read_ins_Mcount_used_cy(2),
      LI => fax4_ins_FIFO1_multi_read_ins_Mcount_used_lut(3),
      O => fax4_ins_FIFO1_multi_read_ins_Result_3_2
    );
  fax4_ins_FIFO1_multi_read_ins_Mcount_used_cy_4_Q : MUXCY
    port map (
      CI => fax4_ins_FIFO1_multi_read_ins_Mcount_used_cy(3),
      DI => fax4_ins_FIFO1_multi_read_ins_used(4),
      S => fax4_ins_FIFO1_multi_read_ins_Mcount_used_lut(4),
      O => fax4_ins_FIFO1_multi_read_ins_Mcount_used_cy(4)
    );
  fax4_ins_FIFO1_multi_read_ins_Mcount_used_xor_4_Q : XORCY
    port map (
      CI => fax4_ins_FIFO1_multi_read_ins_Mcount_used_cy(3),
      LI => fax4_ins_FIFO1_multi_read_ins_Mcount_used_lut(4),
      O => fax4_ins_FIFO1_multi_read_ins_Result_4_2
    );
  fax4_ins_FIFO1_multi_read_ins_Mcount_used_cy_5_Q : MUXCY
    port map (
      CI => fax4_ins_FIFO1_multi_read_ins_Mcount_used_cy(4),
      DI => fax4_ins_FIFO1_multi_read_ins_used(5),
      S => fax4_ins_FIFO1_multi_read_ins_Mcount_used_lut(5),
      O => fax4_ins_FIFO1_multi_read_ins_Mcount_used_cy(5)
    );
  fax4_ins_FIFO1_multi_read_ins_Mcount_used_xor_5_Q : XORCY
    port map (
      CI => fax4_ins_FIFO1_multi_read_ins_Mcount_used_cy(4),
      LI => fax4_ins_FIFO1_multi_read_ins_Mcount_used_lut(5),
      O => fax4_ins_FIFO1_multi_read_ins_Result_5_2
    );
  fax4_ins_FIFO1_multi_read_ins_Mcount_used_cy_6_Q : MUXCY
    port map (
      CI => fax4_ins_FIFO1_multi_read_ins_Mcount_used_cy(5),
      DI => fax4_ins_FIFO1_multi_read_ins_used(6),
      S => fax4_ins_FIFO1_multi_read_ins_Mcount_used_lut(6),
      O => fax4_ins_FIFO1_multi_read_ins_Mcount_used_cy(6)
    );
  fax4_ins_FIFO1_multi_read_ins_Mcount_used_xor_6_Q : XORCY
    port map (
      CI => fax4_ins_FIFO1_multi_read_ins_Mcount_used_cy(5),
      LI => fax4_ins_FIFO1_multi_read_ins_Mcount_used_lut(6),
      O => fax4_ins_FIFO1_multi_read_ins_Result_6_2
    );
  fax4_ins_FIFO1_multi_read_ins_Mcount_used_cy_7_Q : MUXCY
    port map (
      CI => fax4_ins_FIFO1_multi_read_ins_Mcount_used_cy(6),
      DI => fax4_ins_FIFO1_multi_read_ins_used(7),
      S => fax4_ins_FIFO1_multi_read_ins_Mcount_used_lut(7),
      O => fax4_ins_FIFO1_multi_read_ins_Mcount_used_cy(7)
    );
  fax4_ins_FIFO1_multi_read_ins_Mcount_used_xor_7_Q : XORCY
    port map (
      CI => fax4_ins_FIFO1_multi_read_ins_Mcount_used_cy(6),
      LI => fax4_ins_FIFO1_multi_read_ins_Mcount_used_lut(7),
      O => fax4_ins_FIFO1_multi_read_ins_Result_7_2
    );
  fax4_ins_FIFO1_multi_read_ins_Mcount_used_cy_8_Q : MUXCY
    port map (
      CI => fax4_ins_FIFO1_multi_read_ins_Mcount_used_cy(7),
      DI => fax4_ins_FIFO1_multi_read_ins_used(8),
      S => fax4_ins_FIFO1_multi_read_ins_Mcount_used_lut(8),
      O => fax4_ins_FIFO1_multi_read_ins_Mcount_used_cy(8)
    );
  fax4_ins_FIFO1_multi_read_ins_Mcount_used_xor_8_Q : XORCY
    port map (
      CI => fax4_ins_FIFO1_multi_read_ins_Mcount_used_cy(7),
      LI => fax4_ins_FIFO1_multi_read_ins_Mcount_used_lut(8),
      O => fax4_ins_FIFO1_multi_read_ins_Result_8_2
    );
  fax4_ins_FIFO1_multi_read_ins_Mcount_used_xor_9_Q : XORCY
    port map (
      CI => fax4_ins_FIFO1_multi_read_ins_Mcount_used_cy(8),
      LI => fax4_ins_FIFO1_multi_read_ins_Mcount_used_lut(9),
      O => fax4_ins_FIFO1_multi_read_ins_Result_9_2
    );
  fax4_ins_FIFO1_multi_read_ins_Mcount_read_pos_cy_0_Q : MUXCY
    port map (
      CI => NlwRenamedSig_OI_run_len_code_o(26),
      DI => N1,
      S => fax4_ins_FIFO1_multi_read_ins_Mcount_read_pos_lut(0),
      O => fax4_ins_FIFO1_multi_read_ins_Mcount_read_pos_cy(0)
    );
  fax4_ins_FIFO1_multi_read_ins_Mcount_read_pos_xor_0_Q : XORCY
    port map (
      CI => NlwRenamedSig_OI_run_len_code_o(26),
      LI => fax4_ins_FIFO1_multi_read_ins_Mcount_read_pos_lut(0),
      O => fax4_ins_FIFO1_multi_read_ins_Result(0)
    );
  fax4_ins_FIFO1_multi_read_ins_Mcount_read_pos_cy_1_Q : MUXCY
    port map (
      CI => fax4_ins_FIFO1_multi_read_ins_Mcount_read_pos_cy(0),
      DI => NlwRenamedSig_OI_run_len_code_o(26),
      S => fax4_ins_FIFO1_multi_read_ins_Mcount_read_pos_cy_1_rt_234,
      O => fax4_ins_FIFO1_multi_read_ins_Mcount_read_pos_cy(1)
    );
  fax4_ins_FIFO1_multi_read_ins_Mcount_read_pos_xor_1_Q : XORCY
    port map (
      CI => fax4_ins_FIFO1_multi_read_ins_Mcount_read_pos_cy(0),
      LI => fax4_ins_FIFO1_multi_read_ins_Mcount_read_pos_cy_1_rt_234,
      O => fax4_ins_FIFO1_multi_read_ins_Result(1)
    );
  fax4_ins_FIFO1_multi_read_ins_Mcount_read_pos_cy_2_Q : MUXCY
    port map (
      CI => fax4_ins_FIFO1_multi_read_ins_Mcount_read_pos_cy(1),
      DI => NlwRenamedSig_OI_run_len_code_o(26),
      S => fax4_ins_FIFO1_multi_read_ins_Mcount_read_pos_cy_2_rt_236,
      O => fax4_ins_FIFO1_multi_read_ins_Mcount_read_pos_cy(2)
    );
  fax4_ins_FIFO1_multi_read_ins_Mcount_read_pos_xor_2_Q : XORCY
    port map (
      CI => fax4_ins_FIFO1_multi_read_ins_Mcount_read_pos_cy(1),
      LI => fax4_ins_FIFO1_multi_read_ins_Mcount_read_pos_cy_2_rt_236,
      O => fax4_ins_FIFO1_multi_read_ins_Result(2)
    );
  fax4_ins_FIFO1_multi_read_ins_Mcount_read_pos_cy_3_Q : MUXCY
    port map (
      CI => fax4_ins_FIFO1_multi_read_ins_Mcount_read_pos_cy(2),
      DI => NlwRenamedSig_OI_run_len_code_o(26),
      S => fax4_ins_FIFO1_multi_read_ins_Mcount_read_pos_cy_3_rt_238,
      O => fax4_ins_FIFO1_multi_read_ins_Mcount_read_pos_cy(3)
    );
  fax4_ins_FIFO1_multi_read_ins_Mcount_read_pos_xor_3_Q : XORCY
    port map (
      CI => fax4_ins_FIFO1_multi_read_ins_Mcount_read_pos_cy(2),
      LI => fax4_ins_FIFO1_multi_read_ins_Mcount_read_pos_cy_3_rt_238,
      O => fax4_ins_FIFO1_multi_read_ins_Result(3)
    );
  fax4_ins_FIFO1_multi_read_ins_Mcount_read_pos_cy_4_Q : MUXCY
    port map (
      CI => fax4_ins_FIFO1_multi_read_ins_Mcount_read_pos_cy(3),
      DI => NlwRenamedSig_OI_run_len_code_o(26),
      S => fax4_ins_FIFO1_multi_read_ins_Mcount_read_pos_cy_4_rt_240,
      O => fax4_ins_FIFO1_multi_read_ins_Mcount_read_pos_cy(4)
    );
  fax4_ins_FIFO1_multi_read_ins_Mcount_read_pos_xor_4_Q : XORCY
    port map (
      CI => fax4_ins_FIFO1_multi_read_ins_Mcount_read_pos_cy(3),
      LI => fax4_ins_FIFO1_multi_read_ins_Mcount_read_pos_cy_4_rt_240,
      O => fax4_ins_FIFO1_multi_read_ins_Result(4)
    );
  fax4_ins_FIFO1_multi_read_ins_Mcount_read_pos_cy_5_Q : MUXCY
    port map (
      CI => fax4_ins_FIFO1_multi_read_ins_Mcount_read_pos_cy(4),
      DI => NlwRenamedSig_OI_run_len_code_o(26),
      S => fax4_ins_FIFO1_multi_read_ins_Mcount_read_pos_cy_5_rt_242,
      O => fax4_ins_FIFO1_multi_read_ins_Mcount_read_pos_cy(5)
    );
  fax4_ins_FIFO1_multi_read_ins_Mcount_read_pos_xor_5_Q : XORCY
    port map (
      CI => fax4_ins_FIFO1_multi_read_ins_Mcount_read_pos_cy(4),
      LI => fax4_ins_FIFO1_multi_read_ins_Mcount_read_pos_cy_5_rt_242,
      O => fax4_ins_FIFO1_multi_read_ins_Result(5)
    );
  fax4_ins_FIFO1_multi_read_ins_Mcount_read_pos_cy_6_Q : MUXCY
    port map (
      CI => fax4_ins_FIFO1_multi_read_ins_Mcount_read_pos_cy(5),
      DI => NlwRenamedSig_OI_run_len_code_o(26),
      S => fax4_ins_FIFO1_multi_read_ins_Mcount_read_pos_cy_6_rt_244,
      O => fax4_ins_FIFO1_multi_read_ins_Mcount_read_pos_cy(6)
    );
  fax4_ins_FIFO1_multi_read_ins_Mcount_read_pos_xor_6_Q : XORCY
    port map (
      CI => fax4_ins_FIFO1_multi_read_ins_Mcount_read_pos_cy(5),
      LI => fax4_ins_FIFO1_multi_read_ins_Mcount_read_pos_cy_6_rt_244,
      O => fax4_ins_FIFO1_multi_read_ins_Result(6)
    );
  fax4_ins_FIFO1_multi_read_ins_Mcount_read_pos_cy_7_Q : MUXCY
    port map (
      CI => fax4_ins_FIFO1_multi_read_ins_Mcount_read_pos_cy(6),
      DI => NlwRenamedSig_OI_run_len_code_o(26),
      S => fax4_ins_FIFO1_multi_read_ins_Mcount_read_pos_cy_7_rt_246,
      O => fax4_ins_FIFO1_multi_read_ins_Mcount_read_pos_cy(7)
    );
  fax4_ins_FIFO1_multi_read_ins_Mcount_read_pos_xor_7_Q : XORCY
    port map (
      CI => fax4_ins_FIFO1_multi_read_ins_Mcount_read_pos_cy(6),
      LI => fax4_ins_FIFO1_multi_read_ins_Mcount_read_pos_cy_7_rt_246,
      O => fax4_ins_FIFO1_multi_read_ins_Result(7)
    );
  fax4_ins_FIFO1_multi_read_ins_Mcount_read_pos_cy_8_Q : MUXCY
    port map (
      CI => fax4_ins_FIFO1_multi_read_ins_Mcount_read_pos_cy(7),
      DI => NlwRenamedSig_OI_run_len_code_o(26),
      S => fax4_ins_FIFO1_multi_read_ins_Mcount_read_pos_cy_8_rt_248,
      O => fax4_ins_FIFO1_multi_read_ins_Mcount_read_pos_cy(8)
    );
  fax4_ins_FIFO1_multi_read_ins_Mcount_read_pos_xor_8_Q : XORCY
    port map (
      CI => fax4_ins_FIFO1_multi_read_ins_Mcount_read_pos_cy(7),
      LI => fax4_ins_FIFO1_multi_read_ins_Mcount_read_pos_cy_8_rt_248,
      O => fax4_ins_FIFO1_multi_read_ins_Result(8)
    );
  fax4_ins_FIFO1_multi_read_ins_Mcount_read_pos_xor_9_Q : XORCY
    port map (
      CI => fax4_ins_FIFO1_multi_read_ins_Mcount_read_pos_cy(8),
      LI => fax4_ins_FIFO1_multi_read_ins_Mcount_read_pos_xor_9_rt_260,
      O => fax4_ins_FIFO1_multi_read_ins_Result(9)
    );
  fax4_ins_FIFO1_multi_read_ins_Mcount_write_pos_cy_0_Q : MUXCY
    port map (
      CI => NlwRenamedSig_OI_run_len_code_o(26),
      DI => N1,
      S => fax4_ins_FIFO1_multi_read_ins_Mcount_write_pos_lut(0),
      O => fax4_ins_FIFO1_multi_read_ins_Mcount_write_pos_cy(0)
    );
  fax4_ins_FIFO1_multi_read_ins_Mcount_write_pos_xor_0_Q : XORCY
    port map (
      CI => NlwRenamedSig_OI_run_len_code_o(26),
      LI => fax4_ins_FIFO1_multi_read_ins_Mcount_write_pos_lut(0),
      O => fax4_ins_FIFO1_multi_read_ins_Result_0_1
    );
  fax4_ins_FIFO1_multi_read_ins_Mcount_write_pos_cy_1_Q : MUXCY
    port map (
      CI => fax4_ins_FIFO1_multi_read_ins_Mcount_write_pos_cy(0),
      DI => NlwRenamedSig_OI_run_len_code_o(26),
      S => fax4_ins_FIFO1_multi_read_ins_Mcount_write_pos_cy_1_rt_282,
      O => fax4_ins_FIFO1_multi_read_ins_Mcount_write_pos_cy(1)
    );
  fax4_ins_FIFO1_multi_read_ins_Mcount_write_pos_xor_1_Q : XORCY
    port map (
      CI => fax4_ins_FIFO1_multi_read_ins_Mcount_write_pos_cy(0),
      LI => fax4_ins_FIFO1_multi_read_ins_Mcount_write_pos_cy_1_rt_282,
      O => fax4_ins_FIFO1_multi_read_ins_Result_1_1
    );
  fax4_ins_FIFO1_multi_read_ins_Mcount_write_pos_cy_2_Q : MUXCY
    port map (
      CI => fax4_ins_FIFO1_multi_read_ins_Mcount_write_pos_cy(1),
      DI => NlwRenamedSig_OI_run_len_code_o(26),
      S => fax4_ins_FIFO1_multi_read_ins_Mcount_write_pos_cy_2_rt_284,
      O => fax4_ins_FIFO1_multi_read_ins_Mcount_write_pos_cy(2)
    );
  fax4_ins_FIFO1_multi_read_ins_Mcount_write_pos_xor_2_Q : XORCY
    port map (
      CI => fax4_ins_FIFO1_multi_read_ins_Mcount_write_pos_cy(1),
      LI => fax4_ins_FIFO1_multi_read_ins_Mcount_write_pos_cy_2_rt_284,
      O => fax4_ins_FIFO1_multi_read_ins_Result_2_1
    );
  fax4_ins_FIFO1_multi_read_ins_Mcount_write_pos_cy_3_Q : MUXCY
    port map (
      CI => fax4_ins_FIFO1_multi_read_ins_Mcount_write_pos_cy(2),
      DI => NlwRenamedSig_OI_run_len_code_o(26),
      S => fax4_ins_FIFO1_multi_read_ins_Mcount_write_pos_cy_3_rt_286,
      O => fax4_ins_FIFO1_multi_read_ins_Mcount_write_pos_cy(3)
    );
  fax4_ins_FIFO1_multi_read_ins_Mcount_write_pos_xor_3_Q : XORCY
    port map (
      CI => fax4_ins_FIFO1_multi_read_ins_Mcount_write_pos_cy(2),
      LI => fax4_ins_FIFO1_multi_read_ins_Mcount_write_pos_cy_3_rt_286,
      O => fax4_ins_FIFO1_multi_read_ins_Result_3_1
    );
  fax4_ins_FIFO1_multi_read_ins_Mcount_write_pos_cy_4_Q : MUXCY
    port map (
      CI => fax4_ins_FIFO1_multi_read_ins_Mcount_write_pos_cy(3),
      DI => NlwRenamedSig_OI_run_len_code_o(26),
      S => fax4_ins_FIFO1_multi_read_ins_Mcount_write_pos_cy_4_rt_288,
      O => fax4_ins_FIFO1_multi_read_ins_Mcount_write_pos_cy(4)
    );
  fax4_ins_FIFO1_multi_read_ins_Mcount_write_pos_xor_4_Q : XORCY
    port map (
      CI => fax4_ins_FIFO1_multi_read_ins_Mcount_write_pos_cy(3),
      LI => fax4_ins_FIFO1_multi_read_ins_Mcount_write_pos_cy_4_rt_288,
      O => fax4_ins_FIFO1_multi_read_ins_Result_4_1
    );
  fax4_ins_FIFO1_multi_read_ins_Mcount_write_pos_cy_5_Q : MUXCY
    port map (
      CI => fax4_ins_FIFO1_multi_read_ins_Mcount_write_pos_cy(4),
      DI => NlwRenamedSig_OI_run_len_code_o(26),
      S => fax4_ins_FIFO1_multi_read_ins_Mcount_write_pos_cy_5_rt_290,
      O => fax4_ins_FIFO1_multi_read_ins_Mcount_write_pos_cy(5)
    );
  fax4_ins_FIFO1_multi_read_ins_Mcount_write_pos_xor_5_Q : XORCY
    port map (
      CI => fax4_ins_FIFO1_multi_read_ins_Mcount_write_pos_cy(4),
      LI => fax4_ins_FIFO1_multi_read_ins_Mcount_write_pos_cy_5_rt_290,
      O => fax4_ins_FIFO1_multi_read_ins_Result_5_1
    );
  fax4_ins_FIFO1_multi_read_ins_Mcount_write_pos_cy_6_Q : MUXCY
    port map (
      CI => fax4_ins_FIFO1_multi_read_ins_Mcount_write_pos_cy(5),
      DI => NlwRenamedSig_OI_run_len_code_o(26),
      S => fax4_ins_FIFO1_multi_read_ins_Mcount_write_pos_cy_6_rt_292,
      O => fax4_ins_FIFO1_multi_read_ins_Mcount_write_pos_cy(6)
    );
  fax4_ins_FIFO1_multi_read_ins_Mcount_write_pos_xor_6_Q : XORCY
    port map (
      CI => fax4_ins_FIFO1_multi_read_ins_Mcount_write_pos_cy(5),
      LI => fax4_ins_FIFO1_multi_read_ins_Mcount_write_pos_cy_6_rt_292,
      O => fax4_ins_FIFO1_multi_read_ins_Result_6_1
    );
  fax4_ins_FIFO1_multi_read_ins_Mcount_write_pos_cy_7_Q : MUXCY
    port map (
      CI => fax4_ins_FIFO1_multi_read_ins_Mcount_write_pos_cy(6),
      DI => NlwRenamedSig_OI_run_len_code_o(26),
      S => fax4_ins_FIFO1_multi_read_ins_Mcount_write_pos_cy_7_rt_294,
      O => fax4_ins_FIFO1_multi_read_ins_Mcount_write_pos_cy(7)
    );
  fax4_ins_FIFO1_multi_read_ins_Mcount_write_pos_xor_7_Q : XORCY
    port map (
      CI => fax4_ins_FIFO1_multi_read_ins_Mcount_write_pos_cy(6),
      LI => fax4_ins_FIFO1_multi_read_ins_Mcount_write_pos_cy_7_rt_294,
      O => fax4_ins_FIFO1_multi_read_ins_Result_7_1
    );
  fax4_ins_FIFO1_multi_read_ins_Mcount_write_pos_cy_8_Q : MUXCY
    port map (
      CI => fax4_ins_FIFO1_multi_read_ins_Mcount_write_pos_cy(7),
      DI => NlwRenamedSig_OI_run_len_code_o(26),
      S => fax4_ins_FIFO1_multi_read_ins_Mcount_write_pos_cy_8_rt_296,
      O => fax4_ins_FIFO1_multi_read_ins_Mcount_write_pos_cy(8)
    );
  fax4_ins_FIFO1_multi_read_ins_Mcount_write_pos_xor_8_Q : XORCY
    port map (
      CI => fax4_ins_FIFO1_multi_read_ins_Mcount_write_pos_cy(7),
      LI => fax4_ins_FIFO1_multi_read_ins_Mcount_write_pos_cy_8_rt_296,
      O => fax4_ins_FIFO1_multi_read_ins_Result_8_1
    );
  fax4_ins_FIFO1_multi_read_ins_Mcount_write_pos_xor_9_Q : XORCY
    port map (
      CI => fax4_ins_FIFO1_multi_read_ins_Mcount_write_pos_cy(8),
      LI => fax4_ins_FIFO1_multi_read_ins_Mcount_write_pos_xor_9_rt_308,
      O => fax4_ins_FIFO1_multi_read_ins_Result_9_1
    );
  fax4_ins_FIFO2_multi_read_ins_to_white3_o : FDPE
    generic map(
      INIT => '0'
    )
    port map (
      C => fax4_ins_pclk_not,
      CE => fax4_ins_FIFO2_multi_read_ins_latch3,
      D => fax4_ins_FIFO2_multi_read_ins_mux3_to_white,
      PRE => frame_finished_wire,
      Q => fax4_ins_FIFO2_multi_read_ins_to_white3_o_685
    );
  fax4_ins_FIFO2_multi_read_ins_data1_o_0 : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => fax4_ins_pclk_not,
      CE => fax4_ins_FIFO2_multi_read_ins_latch1,
      D => fax4_ins_FIFO2_multi_read_ins_mux1_x(0),
      Q => fax4_ins_FIFO2_multi_read_ins_data1_o(0)
    );
  fax4_ins_FIFO2_multi_read_ins_data1_o_1 : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => fax4_ins_pclk_not,
      CE => fax4_ins_FIFO2_multi_read_ins_latch1,
      D => fax4_ins_FIFO2_multi_read_ins_mux1_x(1),
      Q => fax4_ins_FIFO2_multi_read_ins_data1_o(1)
    );
  fax4_ins_FIFO2_multi_read_ins_data1_o_2 : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => fax4_ins_pclk_not,
      CE => fax4_ins_FIFO2_multi_read_ins_latch1,
      D => fax4_ins_FIFO2_multi_read_ins_mux1_x(2),
      Q => fax4_ins_FIFO2_multi_read_ins_data1_o(2)
    );
  fax4_ins_FIFO2_multi_read_ins_data1_o_3 : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => fax4_ins_pclk_not,
      CE => fax4_ins_FIFO2_multi_read_ins_latch1,
      D => fax4_ins_FIFO2_multi_read_ins_mux1_x(3),
      Q => fax4_ins_FIFO2_multi_read_ins_data1_o(3)
    );
  fax4_ins_FIFO2_multi_read_ins_data1_o_4 : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => fax4_ins_pclk_not,
      CE => fax4_ins_FIFO2_multi_read_ins_latch1,
      D => fax4_ins_FIFO2_multi_read_ins_mux1_x(4),
      Q => fax4_ins_FIFO2_multi_read_ins_data1_o(4)
    );
  fax4_ins_FIFO2_multi_read_ins_data1_o_5 : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => fax4_ins_pclk_not,
      CE => fax4_ins_FIFO2_multi_read_ins_latch1,
      D => fax4_ins_FIFO2_multi_read_ins_mux1_x(5),
      Q => fax4_ins_FIFO2_multi_read_ins_data1_o(5)
    );
  fax4_ins_FIFO2_multi_read_ins_data1_o_6 : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => fax4_ins_pclk_not,
      CE => fax4_ins_FIFO2_multi_read_ins_latch1,
      D => fax4_ins_FIFO2_multi_read_ins_mux1_x(6),
      Q => fax4_ins_FIFO2_multi_read_ins_data1_o(6)
    );
  fax4_ins_FIFO2_multi_read_ins_data1_o_7 : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => fax4_ins_pclk_not,
      CE => fax4_ins_FIFO2_multi_read_ins_latch1,
      D => fax4_ins_FIFO2_multi_read_ins_mux1_x(7),
      Q => fax4_ins_FIFO2_multi_read_ins_data1_o(7)
    );
  fax4_ins_FIFO2_multi_read_ins_data1_o_8 : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => fax4_ins_pclk_not,
      CE => fax4_ins_FIFO2_multi_read_ins_latch1,
      D => fax4_ins_FIFO2_multi_read_ins_mux1_x(8),
      Q => fax4_ins_FIFO2_multi_read_ins_data1_o(8)
    );
  fax4_ins_FIFO2_multi_read_ins_data1_o_9 : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => fax4_ins_pclk_not,
      CE => fax4_ins_FIFO2_multi_read_ins_latch1,
      D => fax4_ins_FIFO2_multi_read_ins_mux1_x(9),
      Q => fax4_ins_FIFO2_multi_read_ins_data1_o(9)
    );
  fax4_ins_FIFO2_multi_read_ins_valid1_o : FDCE
    generic map(
      INIT => '0'
    )
    port map (
      C => fax4_ins_pclk_not,
      CE => fax4_ins_FIFO2_multi_read_ins_latch1,
      CLR => frame_finished_wire,
      D => fax4_ins_FIFO2_multi_read_ins_mux1_valid,
      Q => fax4_ins_FIFO2_multi_read_ins_valid1_o_698
    );
  fax4_ins_FIFO2_multi_read_ins_data2_o_0 : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => fax4_ins_pclk_not,
      CE => fax4_ins_FIFO2_multi_read_ins_latch2,
      D => fax4_ins_FIFO2_multi_read_ins_mux2_x(0),
      Q => fax4_ins_FIFO2_multi_read_ins_data2_o(0)
    );
  fax4_ins_FIFO2_multi_read_ins_data2_o_1 : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => fax4_ins_pclk_not,
      CE => fax4_ins_FIFO2_multi_read_ins_latch2,
      D => fax4_ins_FIFO2_multi_read_ins_mux2_x(1),
      Q => fax4_ins_FIFO2_multi_read_ins_data2_o(1)
    );
  fax4_ins_FIFO2_multi_read_ins_data2_o_2 : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => fax4_ins_pclk_not,
      CE => fax4_ins_FIFO2_multi_read_ins_latch2,
      D => fax4_ins_FIFO2_multi_read_ins_mux2_x(2),
      Q => fax4_ins_FIFO2_multi_read_ins_data2_o(2)
    );
  fax4_ins_FIFO2_multi_read_ins_data2_o_3 : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => fax4_ins_pclk_not,
      CE => fax4_ins_FIFO2_multi_read_ins_latch2,
      D => fax4_ins_FIFO2_multi_read_ins_mux2_x(3),
      Q => fax4_ins_FIFO2_multi_read_ins_data2_o(3)
    );
  fax4_ins_FIFO2_multi_read_ins_data2_o_4 : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => fax4_ins_pclk_not,
      CE => fax4_ins_FIFO2_multi_read_ins_latch2,
      D => fax4_ins_FIFO2_multi_read_ins_mux2_x(4),
      Q => fax4_ins_FIFO2_multi_read_ins_data2_o(4)
    );
  fax4_ins_FIFO2_multi_read_ins_data2_o_5 : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => fax4_ins_pclk_not,
      CE => fax4_ins_FIFO2_multi_read_ins_latch2,
      D => fax4_ins_FIFO2_multi_read_ins_mux2_x(5),
      Q => fax4_ins_FIFO2_multi_read_ins_data2_o(5)
    );
  fax4_ins_FIFO2_multi_read_ins_data2_o_6 : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => fax4_ins_pclk_not,
      CE => fax4_ins_FIFO2_multi_read_ins_latch2,
      D => fax4_ins_FIFO2_multi_read_ins_mux2_x(6),
      Q => fax4_ins_FIFO2_multi_read_ins_data2_o(6)
    );
  fax4_ins_FIFO2_multi_read_ins_data2_o_7 : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => fax4_ins_pclk_not,
      CE => fax4_ins_FIFO2_multi_read_ins_latch2,
      D => fax4_ins_FIFO2_multi_read_ins_mux2_x(7),
      Q => fax4_ins_FIFO2_multi_read_ins_data2_o(7)
    );
  fax4_ins_FIFO2_multi_read_ins_data2_o_8 : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => fax4_ins_pclk_not,
      CE => fax4_ins_FIFO2_multi_read_ins_latch2,
      D => fax4_ins_FIFO2_multi_read_ins_mux2_x(8),
      Q => fax4_ins_FIFO2_multi_read_ins_data2_o(8)
    );
  fax4_ins_FIFO2_multi_read_ins_data2_o_9 : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => fax4_ins_pclk_not,
      CE => fax4_ins_FIFO2_multi_read_ins_latch2,
      D => fax4_ins_FIFO2_multi_read_ins_mux2_x(9),
      Q => fax4_ins_FIFO2_multi_read_ins_data2_o(9)
    );
  fax4_ins_FIFO2_multi_read_ins_valid2_o : FDCE
    generic map(
      INIT => '0'
    )
    port map (
      C => fax4_ins_pclk_not,
      CE => fax4_ins_FIFO2_multi_read_ins_latch2,
      CLR => frame_finished_wire,
      D => fax4_ins_FIFO2_multi_read_ins_mux2_valid,
      Q => fax4_ins_FIFO2_multi_read_ins_valid2_o_699
    );
  fax4_ins_FIFO2_multi_read_ins_data3_o_0 : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => fax4_ins_pclk_not,
      CE => fax4_ins_FIFO2_multi_read_ins_latch3,
      D => fax4_ins_FIFO2_multi_read_ins_mux3_x(0),
      Q => fax4_ins_FIFO2_multi_read_ins_data3_o(0)
    );
  fax4_ins_FIFO2_multi_read_ins_data3_o_1 : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => fax4_ins_pclk_not,
      CE => fax4_ins_FIFO2_multi_read_ins_latch3,
      D => fax4_ins_FIFO2_multi_read_ins_mux3_x(1),
      Q => fax4_ins_FIFO2_multi_read_ins_data3_o(1)
    );
  fax4_ins_FIFO2_multi_read_ins_data3_o_2 : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => fax4_ins_pclk_not,
      CE => fax4_ins_FIFO2_multi_read_ins_latch3,
      D => fax4_ins_FIFO2_multi_read_ins_mux3_x(2),
      Q => fax4_ins_FIFO2_multi_read_ins_data3_o(2)
    );
  fax4_ins_FIFO2_multi_read_ins_data3_o_3 : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => fax4_ins_pclk_not,
      CE => fax4_ins_FIFO2_multi_read_ins_latch3,
      D => fax4_ins_FIFO2_multi_read_ins_mux3_x(3),
      Q => fax4_ins_FIFO2_multi_read_ins_data3_o(3)
    );
  fax4_ins_FIFO2_multi_read_ins_data3_o_4 : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => fax4_ins_pclk_not,
      CE => fax4_ins_FIFO2_multi_read_ins_latch3,
      D => fax4_ins_FIFO2_multi_read_ins_mux3_x(4),
      Q => fax4_ins_FIFO2_multi_read_ins_data3_o(4)
    );
  fax4_ins_FIFO2_multi_read_ins_data3_o_5 : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => fax4_ins_pclk_not,
      CE => fax4_ins_FIFO2_multi_read_ins_latch3,
      D => fax4_ins_FIFO2_multi_read_ins_mux3_x(5),
      Q => fax4_ins_FIFO2_multi_read_ins_data3_o(5)
    );
  fax4_ins_FIFO2_multi_read_ins_data3_o_6 : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => fax4_ins_pclk_not,
      CE => fax4_ins_FIFO2_multi_read_ins_latch3,
      D => fax4_ins_FIFO2_multi_read_ins_mux3_x(6),
      Q => fax4_ins_FIFO2_multi_read_ins_data3_o(6)
    );
  fax4_ins_FIFO2_multi_read_ins_data3_o_7 : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => fax4_ins_pclk_not,
      CE => fax4_ins_FIFO2_multi_read_ins_latch3,
      D => fax4_ins_FIFO2_multi_read_ins_mux3_x(7),
      Q => fax4_ins_FIFO2_multi_read_ins_data3_o(7)
    );
  fax4_ins_FIFO2_multi_read_ins_data3_o_8 : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => fax4_ins_pclk_not,
      CE => fax4_ins_FIFO2_multi_read_ins_latch3,
      D => fax4_ins_FIFO2_multi_read_ins_mux3_x(8),
      Q => fax4_ins_FIFO2_multi_read_ins_data3_o(8)
    );
  fax4_ins_FIFO2_multi_read_ins_data3_o_9 : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => fax4_ins_pclk_not,
      CE => fax4_ins_FIFO2_multi_read_ins_latch3,
      D => fax4_ins_FIFO2_multi_read_ins_mux3_x(9),
      Q => fax4_ins_FIFO2_multi_read_ins_data3_o(9)
    );
  fax4_ins_FIFO2_multi_read_ins_valid3_o : FDCE
    generic map(
      INIT => '0'
    )
    port map (
      C => fax4_ins_pclk_not,
      CE => fax4_ins_FIFO2_multi_read_ins_latch3,
      CLR => frame_finished_wire,
      D => fax4_ins_FIFO2_multi_read_ins_mux3_valid,
      Q => fax4_ins_FIFO2_multi_read_ins_valid3_o_700
    );
  fax4_ins_FIFO2_multi_read_ins_to_white1_o : FDPE
    generic map(
      INIT => '0'
    )
    port map (
      C => fax4_ins_pclk_not,
      CE => fax4_ins_FIFO2_multi_read_ins_latch1,
      D => fax4_ins_FIFO2_multi_read_ins_mux1_to_white,
      PRE => frame_finished_wire,
      Q => fax4_ins_FIFO2_multi_read_ins_to_white1_o_683
    );
  fax4_ins_FIFO2_multi_read_ins_to_white2_o : FDPE
    generic map(
      INIT => '0'
    )
    port map (
      C => fax4_ins_pclk_not,
      CE => fax4_ins_FIFO2_multi_read_ins_latch2,
      D => fax4_ins_FIFO2_multi_read_ins_mux2_to_white,
      PRE => frame_finished_wire,
      Q => fax4_ins_FIFO2_multi_read_ins_to_white2_o_684
    );
  fax4_ins_FIFO2_multi_read_ins_read_pos_0 : FDCE
    generic map(
      INIT => '0'
    )
    port map (
      C => fax4_ins_pclk_not,
      CE => fax4_ins_FIFO2_multi_read_ins_mem_rd_628,
      CLR => frame_finished_wire,
      D => fax4_ins_FIFO2_multi_read_ins_Mcount_read_pos_eqn_0,
      Q => fax4_ins_FIFO2_multi_read_ins_read_pos(0)
    );
  fax4_ins_FIFO2_multi_read_ins_read_pos_1 : FDCE
    generic map(
      INIT => '0'
    )
    port map (
      C => fax4_ins_pclk_not,
      CE => fax4_ins_FIFO2_multi_read_ins_mem_rd_628,
      CLR => frame_finished_wire,
      D => fax4_ins_FIFO2_multi_read_ins_Mcount_read_pos_eqn_1,
      Q => fax4_ins_FIFO2_multi_read_ins_read_pos(1)
    );
  fax4_ins_FIFO2_multi_read_ins_read_pos_2 : FDCE
    generic map(
      INIT => '0'
    )
    port map (
      C => fax4_ins_pclk_not,
      CE => fax4_ins_FIFO2_multi_read_ins_mem_rd_628,
      CLR => frame_finished_wire,
      D => fax4_ins_FIFO2_multi_read_ins_Mcount_read_pos_eqn_2,
      Q => fax4_ins_FIFO2_multi_read_ins_read_pos(2)
    );
  fax4_ins_FIFO2_multi_read_ins_read_pos_3 : FDCE
    generic map(
      INIT => '0'
    )
    port map (
      C => fax4_ins_pclk_not,
      CE => fax4_ins_FIFO2_multi_read_ins_mem_rd_628,
      CLR => frame_finished_wire,
      D => fax4_ins_FIFO2_multi_read_ins_Mcount_read_pos_eqn_3,
      Q => fax4_ins_FIFO2_multi_read_ins_read_pos(3)
    );
  fax4_ins_FIFO2_multi_read_ins_read_pos_4 : FDCE
    generic map(
      INIT => '0'
    )
    port map (
      C => fax4_ins_pclk_not,
      CE => fax4_ins_FIFO2_multi_read_ins_mem_rd_628,
      CLR => frame_finished_wire,
      D => fax4_ins_FIFO2_multi_read_ins_Mcount_read_pos_eqn_4,
      Q => fax4_ins_FIFO2_multi_read_ins_read_pos(4)
    );
  fax4_ins_FIFO2_multi_read_ins_read_pos_5 : FDCE
    generic map(
      INIT => '0'
    )
    port map (
      C => fax4_ins_pclk_not,
      CE => fax4_ins_FIFO2_multi_read_ins_mem_rd_628,
      CLR => frame_finished_wire,
      D => fax4_ins_FIFO2_multi_read_ins_Mcount_read_pos_eqn_5,
      Q => fax4_ins_FIFO2_multi_read_ins_read_pos(5)
    );
  fax4_ins_FIFO2_multi_read_ins_read_pos_6 : FDCE
    generic map(
      INIT => '0'
    )
    port map (
      C => fax4_ins_pclk_not,
      CE => fax4_ins_FIFO2_multi_read_ins_mem_rd_628,
      CLR => frame_finished_wire,
      D => fax4_ins_FIFO2_multi_read_ins_Mcount_read_pos_eqn_6,
      Q => fax4_ins_FIFO2_multi_read_ins_read_pos(6)
    );
  fax4_ins_FIFO2_multi_read_ins_read_pos_7 : FDCE
    generic map(
      INIT => '0'
    )
    port map (
      C => fax4_ins_pclk_not,
      CE => fax4_ins_FIFO2_multi_read_ins_mem_rd_628,
      CLR => frame_finished_wire,
      D => fax4_ins_FIFO2_multi_read_ins_Mcount_read_pos_eqn_7,
      Q => fax4_ins_FIFO2_multi_read_ins_read_pos(7)
    );
  fax4_ins_FIFO2_multi_read_ins_read_pos_8 : FDCE
    generic map(
      INIT => '0'
    )
    port map (
      C => fax4_ins_pclk_not,
      CE => fax4_ins_FIFO2_multi_read_ins_mem_rd_628,
      CLR => frame_finished_wire,
      D => fax4_ins_FIFO2_multi_read_ins_Mcount_read_pos_eqn_8,
      Q => fax4_ins_FIFO2_multi_read_ins_read_pos(8)
    );
  fax4_ins_FIFO2_multi_read_ins_read_pos_9 : FDCE
    generic map(
      INIT => '0'
    )
    port map (
      C => fax4_ins_pclk_not,
      CE => fax4_ins_FIFO2_multi_read_ins_mem_rd_628,
      CLR => frame_finished_wire,
      D => fax4_ins_FIFO2_multi_read_ins_Mcount_read_pos_eqn_9,
      Q => fax4_ins_FIFO2_multi_read_ins_read_pos(9)
    );
  fax4_ins_FIFO2_multi_read_ins_write_pos_0 : FDCE
    generic map(
      INIT => '0'
    )
    port map (
      C => fax4_ins_pclk_not,
      CE => fax4_ins_FIFO2_multi_read_ins_wr,
      CLR => frame_finished_wire,
      D => fax4_ins_FIFO2_multi_read_ins_Mcount_write_pos_eqn_0,
      Q => fax4_ins_FIFO2_multi_read_ins_write_pos(0)
    );
  fax4_ins_FIFO2_multi_read_ins_write_pos_1 : FDCE
    generic map(
      INIT => '0'
    )
    port map (
      C => fax4_ins_pclk_not,
      CE => fax4_ins_FIFO2_multi_read_ins_wr,
      CLR => frame_finished_wire,
      D => fax4_ins_FIFO2_multi_read_ins_Mcount_write_pos_eqn_1,
      Q => fax4_ins_FIFO2_multi_read_ins_write_pos(1)
    );
  fax4_ins_FIFO2_multi_read_ins_write_pos_2 : FDCE
    generic map(
      INIT => '0'
    )
    port map (
      C => fax4_ins_pclk_not,
      CE => fax4_ins_FIFO2_multi_read_ins_wr,
      CLR => frame_finished_wire,
      D => fax4_ins_FIFO2_multi_read_ins_Mcount_write_pos_eqn_2,
      Q => fax4_ins_FIFO2_multi_read_ins_write_pos(2)
    );
  fax4_ins_FIFO2_multi_read_ins_write_pos_3 : FDCE
    generic map(
      INIT => '0'
    )
    port map (
      C => fax4_ins_pclk_not,
      CE => fax4_ins_FIFO2_multi_read_ins_wr,
      CLR => frame_finished_wire,
      D => fax4_ins_FIFO2_multi_read_ins_Mcount_write_pos_eqn_3,
      Q => fax4_ins_FIFO2_multi_read_ins_write_pos(3)
    );
  fax4_ins_FIFO2_multi_read_ins_write_pos_4 : FDCE
    generic map(
      INIT => '0'
    )
    port map (
      C => fax4_ins_pclk_not,
      CE => fax4_ins_FIFO2_multi_read_ins_wr,
      CLR => frame_finished_wire,
      D => fax4_ins_FIFO2_multi_read_ins_Mcount_write_pos_eqn_4,
      Q => fax4_ins_FIFO2_multi_read_ins_write_pos(4)
    );
  fax4_ins_FIFO2_multi_read_ins_write_pos_5 : FDCE
    generic map(
      INIT => '0'
    )
    port map (
      C => fax4_ins_pclk_not,
      CE => fax4_ins_FIFO2_multi_read_ins_wr,
      CLR => frame_finished_wire,
      D => fax4_ins_FIFO2_multi_read_ins_Mcount_write_pos_eqn_5,
      Q => fax4_ins_FIFO2_multi_read_ins_write_pos(5)
    );
  fax4_ins_FIFO2_multi_read_ins_write_pos_6 : FDCE
    generic map(
      INIT => '0'
    )
    port map (
      C => fax4_ins_pclk_not,
      CE => fax4_ins_FIFO2_multi_read_ins_wr,
      CLR => frame_finished_wire,
      D => fax4_ins_FIFO2_multi_read_ins_Mcount_write_pos_eqn_6,
      Q => fax4_ins_FIFO2_multi_read_ins_write_pos(6)
    );
  fax4_ins_FIFO2_multi_read_ins_write_pos_7 : FDCE
    generic map(
      INIT => '0'
    )
    port map (
      C => fax4_ins_pclk_not,
      CE => fax4_ins_FIFO2_multi_read_ins_wr,
      CLR => frame_finished_wire,
      D => fax4_ins_FIFO2_multi_read_ins_Mcount_write_pos_eqn_7,
      Q => fax4_ins_FIFO2_multi_read_ins_write_pos(7)
    );
  fax4_ins_FIFO2_multi_read_ins_write_pos_8 : FDCE
    generic map(
      INIT => '0'
    )
    port map (
      C => fax4_ins_pclk_not,
      CE => fax4_ins_FIFO2_multi_read_ins_wr,
      CLR => frame_finished_wire,
      D => fax4_ins_FIFO2_multi_read_ins_Mcount_write_pos_eqn_8,
      Q => fax4_ins_FIFO2_multi_read_ins_write_pos(8)
    );
  fax4_ins_FIFO2_multi_read_ins_write_pos_9 : FDCE
    generic map(
      INIT => '0'
    )
    port map (
      C => fax4_ins_pclk_not,
      CE => fax4_ins_FIFO2_multi_read_ins_wr,
      CLR => frame_finished_wire,
      D => fax4_ins_FIFO2_multi_read_ins_Mcount_write_pos_eqn_9,
      Q => fax4_ins_FIFO2_multi_read_ins_write_pos(9)
    );
  fax4_ins_FIFO2_multi_read_ins_used_0 : FDCE
    generic map(
      INIT => '0'
    )
    port map (
      C => fax4_ins_pclk_not,
      CE => fax4_ins_FIFO2_multi_read_ins_used_not0002_696,
      CLR => frame_finished_wire,
      D => fax4_ins_FIFO2_multi_read_ins_Result_0_2,
      Q => fax4_ins_FIFO2_multi_read_ins_used(0)
    );
  fax4_ins_FIFO2_multi_read_ins_used_1 : FDCE
    generic map(
      INIT => '0'
    )
    port map (
      C => fax4_ins_pclk_not,
      CE => fax4_ins_FIFO2_multi_read_ins_used_not0002_696,
      CLR => frame_finished_wire,
      D => fax4_ins_FIFO2_multi_read_ins_Result_1_2,
      Q => fax4_ins_FIFO2_multi_read_ins_used(1)
    );
  fax4_ins_FIFO2_multi_read_ins_used_2 : FDCE
    generic map(
      INIT => '0'
    )
    port map (
      C => fax4_ins_pclk_not,
      CE => fax4_ins_FIFO2_multi_read_ins_used_not0002_696,
      CLR => frame_finished_wire,
      D => fax4_ins_FIFO2_multi_read_ins_Result_2_2,
      Q => fax4_ins_FIFO2_multi_read_ins_used(2)
    );
  fax4_ins_FIFO2_multi_read_ins_used_3 : FDCE
    generic map(
      INIT => '0'
    )
    port map (
      C => fax4_ins_pclk_not,
      CE => fax4_ins_FIFO2_multi_read_ins_used_not0002_696,
      CLR => frame_finished_wire,
      D => fax4_ins_FIFO2_multi_read_ins_Result_3_2,
      Q => fax4_ins_FIFO2_multi_read_ins_used(3)
    );
  fax4_ins_FIFO2_multi_read_ins_used_4 : FDCE
    generic map(
      INIT => '0'
    )
    port map (
      C => fax4_ins_pclk_not,
      CE => fax4_ins_FIFO2_multi_read_ins_used_not0002_696,
      CLR => frame_finished_wire,
      D => fax4_ins_FIFO2_multi_read_ins_Result_4_2,
      Q => fax4_ins_FIFO2_multi_read_ins_used(4)
    );
  fax4_ins_FIFO2_multi_read_ins_used_5 : FDCE
    generic map(
      INIT => '0'
    )
    port map (
      C => fax4_ins_pclk_not,
      CE => fax4_ins_FIFO2_multi_read_ins_used_not0002_696,
      CLR => frame_finished_wire,
      D => fax4_ins_FIFO2_multi_read_ins_Result_5_2,
      Q => fax4_ins_FIFO2_multi_read_ins_used(5)
    );
  fax4_ins_FIFO2_multi_read_ins_used_6 : FDCE
    generic map(
      INIT => '0'
    )
    port map (
      C => fax4_ins_pclk_not,
      CE => fax4_ins_FIFO2_multi_read_ins_used_not0002_696,
      CLR => frame_finished_wire,
      D => fax4_ins_FIFO2_multi_read_ins_Result_6_2,
      Q => fax4_ins_FIFO2_multi_read_ins_used(6)
    );
  fax4_ins_FIFO2_multi_read_ins_used_7 : FDCE
    generic map(
      INIT => '0'
    )
    port map (
      C => fax4_ins_pclk_not,
      CE => fax4_ins_FIFO2_multi_read_ins_used_not0002_696,
      CLR => frame_finished_wire,
      D => fax4_ins_FIFO2_multi_read_ins_Result_7_2,
      Q => fax4_ins_FIFO2_multi_read_ins_used(7)
    );
  fax4_ins_FIFO2_multi_read_ins_used_8 : FDCE
    generic map(
      INIT => '0'
    )
    port map (
      C => fax4_ins_pclk_not,
      CE => fax4_ins_FIFO2_multi_read_ins_used_not0002_696,
      CLR => frame_finished_wire,
      D => fax4_ins_FIFO2_multi_read_ins_Result_8_2,
      Q => fax4_ins_FIFO2_multi_read_ins_used(8)
    );
  fax4_ins_FIFO2_multi_read_ins_used_9 : FDCE
    generic map(
      INIT => '0'
    )
    port map (
      C => fax4_ins_pclk_not,
      CE => fax4_ins_FIFO2_multi_read_ins_used_not0002_696,
      CLR => frame_finished_wire,
      D => fax4_ins_FIFO2_multi_read_ins_Result_9_2,
      Q => fax4_ins_FIFO2_multi_read_ins_used(9)
    );
  fax4_ins_FIFO2_multi_read_ins_Mcount_used_cy_0_Q : MUXCY
    port map (
      CI => fax4_ins_FIFO2_multi_read_ins_used_not0003_inv,
      DI => fax4_ins_FIFO2_multi_read_ins_used(0),
      S => fax4_ins_FIFO2_multi_read_ins_Mcount_used_lut(0),
      O => fax4_ins_FIFO2_multi_read_ins_Mcount_used_cy(0)
    );
  fax4_ins_FIFO2_multi_read_ins_Mcount_used_xor_0_Q : XORCY
    port map (
      CI => fax4_ins_FIFO2_multi_read_ins_used_not0003_inv,
      LI => fax4_ins_FIFO2_multi_read_ins_Mcount_used_lut(0),
      O => fax4_ins_FIFO2_multi_read_ins_Result_0_2
    );
  fax4_ins_FIFO2_multi_read_ins_Mcount_used_cy_1_Q : MUXCY
    port map (
      CI => fax4_ins_FIFO2_multi_read_ins_Mcount_used_cy(0),
      DI => fax4_ins_FIFO2_multi_read_ins_used(1),
      S => fax4_ins_FIFO2_multi_read_ins_Mcount_used_lut(1),
      O => fax4_ins_FIFO2_multi_read_ins_Mcount_used_cy(1)
    );
  fax4_ins_FIFO2_multi_read_ins_Mcount_used_xor_1_Q : XORCY
    port map (
      CI => fax4_ins_FIFO2_multi_read_ins_Mcount_used_cy(0),
      LI => fax4_ins_FIFO2_multi_read_ins_Mcount_used_lut(1),
      O => fax4_ins_FIFO2_multi_read_ins_Result_1_2
    );
  fax4_ins_FIFO2_multi_read_ins_Mcount_used_cy_2_Q : MUXCY
    port map (
      CI => fax4_ins_FIFO2_multi_read_ins_Mcount_used_cy(1),
      DI => fax4_ins_FIFO2_multi_read_ins_used(2),
      S => fax4_ins_FIFO2_multi_read_ins_Mcount_used_lut(2),
      O => fax4_ins_FIFO2_multi_read_ins_Mcount_used_cy(2)
    );
  fax4_ins_FIFO2_multi_read_ins_Mcount_used_xor_2_Q : XORCY
    port map (
      CI => fax4_ins_FIFO2_multi_read_ins_Mcount_used_cy(1),
      LI => fax4_ins_FIFO2_multi_read_ins_Mcount_used_lut(2),
      O => fax4_ins_FIFO2_multi_read_ins_Result_2_2
    );
  fax4_ins_FIFO2_multi_read_ins_Mcount_used_cy_3_Q : MUXCY
    port map (
      CI => fax4_ins_FIFO2_multi_read_ins_Mcount_used_cy(2),
      DI => fax4_ins_FIFO2_multi_read_ins_used(3),
      S => fax4_ins_FIFO2_multi_read_ins_Mcount_used_lut(3),
      O => fax4_ins_FIFO2_multi_read_ins_Mcount_used_cy(3)
    );
  fax4_ins_FIFO2_multi_read_ins_Mcount_used_xor_3_Q : XORCY
    port map (
      CI => fax4_ins_FIFO2_multi_read_ins_Mcount_used_cy(2),
      LI => fax4_ins_FIFO2_multi_read_ins_Mcount_used_lut(3),
      O => fax4_ins_FIFO2_multi_read_ins_Result_3_2
    );
  fax4_ins_FIFO2_multi_read_ins_Mcount_used_cy_4_Q : MUXCY
    port map (
      CI => fax4_ins_FIFO2_multi_read_ins_Mcount_used_cy(3),
      DI => fax4_ins_FIFO2_multi_read_ins_used(4),
      S => fax4_ins_FIFO2_multi_read_ins_Mcount_used_lut(4),
      O => fax4_ins_FIFO2_multi_read_ins_Mcount_used_cy(4)
    );
  fax4_ins_FIFO2_multi_read_ins_Mcount_used_xor_4_Q : XORCY
    port map (
      CI => fax4_ins_FIFO2_multi_read_ins_Mcount_used_cy(3),
      LI => fax4_ins_FIFO2_multi_read_ins_Mcount_used_lut(4),
      O => fax4_ins_FIFO2_multi_read_ins_Result_4_2
    );
  fax4_ins_FIFO2_multi_read_ins_Mcount_used_cy_5_Q : MUXCY
    port map (
      CI => fax4_ins_FIFO2_multi_read_ins_Mcount_used_cy(4),
      DI => fax4_ins_FIFO2_multi_read_ins_used(5),
      S => fax4_ins_FIFO2_multi_read_ins_Mcount_used_lut(5),
      O => fax4_ins_FIFO2_multi_read_ins_Mcount_used_cy(5)
    );
  fax4_ins_FIFO2_multi_read_ins_Mcount_used_xor_5_Q : XORCY
    port map (
      CI => fax4_ins_FIFO2_multi_read_ins_Mcount_used_cy(4),
      LI => fax4_ins_FIFO2_multi_read_ins_Mcount_used_lut(5),
      O => fax4_ins_FIFO2_multi_read_ins_Result_5_2
    );
  fax4_ins_FIFO2_multi_read_ins_Mcount_used_cy_6_Q : MUXCY
    port map (
      CI => fax4_ins_FIFO2_multi_read_ins_Mcount_used_cy(5),
      DI => fax4_ins_FIFO2_multi_read_ins_used(6),
      S => fax4_ins_FIFO2_multi_read_ins_Mcount_used_lut(6),
      O => fax4_ins_FIFO2_multi_read_ins_Mcount_used_cy(6)
    );
  fax4_ins_FIFO2_multi_read_ins_Mcount_used_xor_6_Q : XORCY
    port map (
      CI => fax4_ins_FIFO2_multi_read_ins_Mcount_used_cy(5),
      LI => fax4_ins_FIFO2_multi_read_ins_Mcount_used_lut(6),
      O => fax4_ins_FIFO2_multi_read_ins_Result_6_2
    );
  fax4_ins_FIFO2_multi_read_ins_Mcount_used_cy_7_Q : MUXCY
    port map (
      CI => fax4_ins_FIFO2_multi_read_ins_Mcount_used_cy(6),
      DI => fax4_ins_FIFO2_multi_read_ins_used(7),
      S => fax4_ins_FIFO2_multi_read_ins_Mcount_used_lut(7),
      O => fax4_ins_FIFO2_multi_read_ins_Mcount_used_cy(7)
    );
  fax4_ins_FIFO2_multi_read_ins_Mcount_used_xor_7_Q : XORCY
    port map (
      CI => fax4_ins_FIFO2_multi_read_ins_Mcount_used_cy(6),
      LI => fax4_ins_FIFO2_multi_read_ins_Mcount_used_lut(7),
      O => fax4_ins_FIFO2_multi_read_ins_Result_7_2
    );
  fax4_ins_FIFO2_multi_read_ins_Mcount_used_cy_8_Q : MUXCY
    port map (
      CI => fax4_ins_FIFO2_multi_read_ins_Mcount_used_cy(7),
      DI => fax4_ins_FIFO2_multi_read_ins_used(8),
      S => fax4_ins_FIFO2_multi_read_ins_Mcount_used_lut(8),
      O => fax4_ins_FIFO2_multi_read_ins_Mcount_used_cy(8)
    );
  fax4_ins_FIFO2_multi_read_ins_Mcount_used_xor_8_Q : XORCY
    port map (
      CI => fax4_ins_FIFO2_multi_read_ins_Mcount_used_cy(7),
      LI => fax4_ins_FIFO2_multi_read_ins_Mcount_used_lut(8),
      O => fax4_ins_FIFO2_multi_read_ins_Result_8_2
    );
  fax4_ins_FIFO2_multi_read_ins_Mcount_used_xor_9_Q : XORCY
    port map (
      CI => fax4_ins_FIFO2_multi_read_ins_Mcount_used_cy(8),
      LI => fax4_ins_FIFO2_multi_read_ins_Mcount_used_lut(9),
      O => fax4_ins_FIFO2_multi_read_ins_Result_9_2
    );
  fax4_ins_FIFO2_multi_read_ins_Mcount_read_pos_cy_0_Q : MUXCY
    port map (
      CI => NlwRenamedSig_OI_run_len_code_o(26),
      DI => N1,
      S => fax4_ins_FIFO2_multi_read_ins_Mcount_read_pos_lut(0),
      O => fax4_ins_FIFO2_multi_read_ins_Mcount_read_pos_cy(0)
    );
  fax4_ins_FIFO2_multi_read_ins_Mcount_read_pos_xor_0_Q : XORCY
    port map (
      CI => NlwRenamedSig_OI_run_len_code_o(26),
      LI => fax4_ins_FIFO2_multi_read_ins_Mcount_read_pos_lut(0),
      O => fax4_ins_FIFO2_multi_read_ins_Result(0)
    );
  fax4_ins_FIFO2_multi_read_ins_Mcount_read_pos_cy_1_Q : MUXCY
    port map (
      CI => fax4_ins_FIFO2_multi_read_ins_Mcount_read_pos_cy(0),
      DI => NlwRenamedSig_OI_run_len_code_o(26),
      S => fax4_ins_FIFO2_multi_read_ins_Mcount_read_pos_cy_1_rt_475,
      O => fax4_ins_FIFO2_multi_read_ins_Mcount_read_pos_cy(1)
    );
  fax4_ins_FIFO2_multi_read_ins_Mcount_read_pos_xor_1_Q : XORCY
    port map (
      CI => fax4_ins_FIFO2_multi_read_ins_Mcount_read_pos_cy(0),
      LI => fax4_ins_FIFO2_multi_read_ins_Mcount_read_pos_cy_1_rt_475,
      O => fax4_ins_FIFO2_multi_read_ins_Result(1)
    );
  fax4_ins_FIFO2_multi_read_ins_Mcount_read_pos_cy_2_Q : MUXCY
    port map (
      CI => fax4_ins_FIFO2_multi_read_ins_Mcount_read_pos_cy(1),
      DI => NlwRenamedSig_OI_run_len_code_o(26),
      S => fax4_ins_FIFO2_multi_read_ins_Mcount_read_pos_cy_2_rt_477,
      O => fax4_ins_FIFO2_multi_read_ins_Mcount_read_pos_cy(2)
    );
  fax4_ins_FIFO2_multi_read_ins_Mcount_read_pos_xor_2_Q : XORCY
    port map (
      CI => fax4_ins_FIFO2_multi_read_ins_Mcount_read_pos_cy(1),
      LI => fax4_ins_FIFO2_multi_read_ins_Mcount_read_pos_cy_2_rt_477,
      O => fax4_ins_FIFO2_multi_read_ins_Result(2)
    );
  fax4_ins_FIFO2_multi_read_ins_Mcount_read_pos_cy_3_Q : MUXCY
    port map (
      CI => fax4_ins_FIFO2_multi_read_ins_Mcount_read_pos_cy(2),
      DI => NlwRenamedSig_OI_run_len_code_o(26),
      S => fax4_ins_FIFO2_multi_read_ins_Mcount_read_pos_cy_3_rt_479,
      O => fax4_ins_FIFO2_multi_read_ins_Mcount_read_pos_cy(3)
    );
  fax4_ins_FIFO2_multi_read_ins_Mcount_read_pos_xor_3_Q : XORCY
    port map (
      CI => fax4_ins_FIFO2_multi_read_ins_Mcount_read_pos_cy(2),
      LI => fax4_ins_FIFO2_multi_read_ins_Mcount_read_pos_cy_3_rt_479,
      O => fax4_ins_FIFO2_multi_read_ins_Result(3)
    );
  fax4_ins_FIFO2_multi_read_ins_Mcount_read_pos_cy_4_Q : MUXCY
    port map (
      CI => fax4_ins_FIFO2_multi_read_ins_Mcount_read_pos_cy(3),
      DI => NlwRenamedSig_OI_run_len_code_o(26),
      S => fax4_ins_FIFO2_multi_read_ins_Mcount_read_pos_cy_4_rt_481,
      O => fax4_ins_FIFO2_multi_read_ins_Mcount_read_pos_cy(4)
    );
  fax4_ins_FIFO2_multi_read_ins_Mcount_read_pos_xor_4_Q : XORCY
    port map (
      CI => fax4_ins_FIFO2_multi_read_ins_Mcount_read_pos_cy(3),
      LI => fax4_ins_FIFO2_multi_read_ins_Mcount_read_pos_cy_4_rt_481,
      O => fax4_ins_FIFO2_multi_read_ins_Result(4)
    );
  fax4_ins_FIFO2_multi_read_ins_Mcount_read_pos_cy_5_Q : MUXCY
    port map (
      CI => fax4_ins_FIFO2_multi_read_ins_Mcount_read_pos_cy(4),
      DI => NlwRenamedSig_OI_run_len_code_o(26),
      S => fax4_ins_FIFO2_multi_read_ins_Mcount_read_pos_cy_5_rt_483,
      O => fax4_ins_FIFO2_multi_read_ins_Mcount_read_pos_cy(5)
    );
  fax4_ins_FIFO2_multi_read_ins_Mcount_read_pos_xor_5_Q : XORCY
    port map (
      CI => fax4_ins_FIFO2_multi_read_ins_Mcount_read_pos_cy(4),
      LI => fax4_ins_FIFO2_multi_read_ins_Mcount_read_pos_cy_5_rt_483,
      O => fax4_ins_FIFO2_multi_read_ins_Result(5)
    );
  fax4_ins_FIFO2_multi_read_ins_Mcount_read_pos_cy_6_Q : MUXCY
    port map (
      CI => fax4_ins_FIFO2_multi_read_ins_Mcount_read_pos_cy(5),
      DI => NlwRenamedSig_OI_run_len_code_o(26),
      S => fax4_ins_FIFO2_multi_read_ins_Mcount_read_pos_cy_6_rt_485,
      O => fax4_ins_FIFO2_multi_read_ins_Mcount_read_pos_cy(6)
    );
  fax4_ins_FIFO2_multi_read_ins_Mcount_read_pos_xor_6_Q : XORCY
    port map (
      CI => fax4_ins_FIFO2_multi_read_ins_Mcount_read_pos_cy(5),
      LI => fax4_ins_FIFO2_multi_read_ins_Mcount_read_pos_cy_6_rt_485,
      O => fax4_ins_FIFO2_multi_read_ins_Result(6)
    );
  fax4_ins_FIFO2_multi_read_ins_Mcount_read_pos_cy_7_Q : MUXCY
    port map (
      CI => fax4_ins_FIFO2_multi_read_ins_Mcount_read_pos_cy(6),
      DI => NlwRenamedSig_OI_run_len_code_o(26),
      S => fax4_ins_FIFO2_multi_read_ins_Mcount_read_pos_cy_7_rt_487,
      O => fax4_ins_FIFO2_multi_read_ins_Mcount_read_pos_cy(7)
    );
  fax4_ins_FIFO2_multi_read_ins_Mcount_read_pos_xor_7_Q : XORCY
    port map (
      CI => fax4_ins_FIFO2_multi_read_ins_Mcount_read_pos_cy(6),
      LI => fax4_ins_FIFO2_multi_read_ins_Mcount_read_pos_cy_7_rt_487,
      O => fax4_ins_FIFO2_multi_read_ins_Result(7)
    );
  fax4_ins_FIFO2_multi_read_ins_Mcount_read_pos_cy_8_Q : MUXCY
    port map (
      CI => fax4_ins_FIFO2_multi_read_ins_Mcount_read_pos_cy(7),
      DI => NlwRenamedSig_OI_run_len_code_o(26),
      S => fax4_ins_FIFO2_multi_read_ins_Mcount_read_pos_cy_8_rt_489,
      O => fax4_ins_FIFO2_multi_read_ins_Mcount_read_pos_cy(8)
    );
  fax4_ins_FIFO2_multi_read_ins_Mcount_read_pos_xor_8_Q : XORCY
    port map (
      CI => fax4_ins_FIFO2_multi_read_ins_Mcount_read_pos_cy(7),
      LI => fax4_ins_FIFO2_multi_read_ins_Mcount_read_pos_cy_8_rt_489,
      O => fax4_ins_FIFO2_multi_read_ins_Result(8)
    );
  fax4_ins_FIFO2_multi_read_ins_Mcount_read_pos_xor_9_Q : XORCY
    port map (
      CI => fax4_ins_FIFO2_multi_read_ins_Mcount_read_pos_cy(8),
      LI => fax4_ins_FIFO2_multi_read_ins_Mcount_read_pos_xor_9_rt_501,
      O => fax4_ins_FIFO2_multi_read_ins_Result(9)
    );
  fax4_ins_FIFO2_multi_read_ins_Mcount_write_pos_cy_0_Q : MUXCY
    port map (
      CI => NlwRenamedSig_OI_run_len_code_o(26),
      DI => N1,
      S => fax4_ins_FIFO2_multi_read_ins_Mcount_write_pos_lut(0),
      O => fax4_ins_FIFO2_multi_read_ins_Mcount_write_pos_cy(0)
    );
  fax4_ins_FIFO2_multi_read_ins_Mcount_write_pos_xor_0_Q : XORCY
    port map (
      CI => NlwRenamedSig_OI_run_len_code_o(26),
      LI => fax4_ins_FIFO2_multi_read_ins_Mcount_write_pos_lut(0),
      O => fax4_ins_FIFO2_multi_read_ins_Result_0_1
    );
  fax4_ins_FIFO2_multi_read_ins_Mcount_write_pos_cy_1_Q : MUXCY
    port map (
      CI => fax4_ins_FIFO2_multi_read_ins_Mcount_write_pos_cy(0),
      DI => NlwRenamedSig_OI_run_len_code_o(26),
      S => fax4_ins_FIFO2_multi_read_ins_Mcount_write_pos_cy_1_rt_523,
      O => fax4_ins_FIFO2_multi_read_ins_Mcount_write_pos_cy(1)
    );
  fax4_ins_FIFO2_multi_read_ins_Mcount_write_pos_xor_1_Q : XORCY
    port map (
      CI => fax4_ins_FIFO2_multi_read_ins_Mcount_write_pos_cy(0),
      LI => fax4_ins_FIFO2_multi_read_ins_Mcount_write_pos_cy_1_rt_523,
      O => fax4_ins_FIFO2_multi_read_ins_Result_1_1
    );
  fax4_ins_FIFO2_multi_read_ins_Mcount_write_pos_cy_2_Q : MUXCY
    port map (
      CI => fax4_ins_FIFO2_multi_read_ins_Mcount_write_pos_cy(1),
      DI => NlwRenamedSig_OI_run_len_code_o(26),
      S => fax4_ins_FIFO2_multi_read_ins_Mcount_write_pos_cy_2_rt_525,
      O => fax4_ins_FIFO2_multi_read_ins_Mcount_write_pos_cy(2)
    );
  fax4_ins_FIFO2_multi_read_ins_Mcount_write_pos_xor_2_Q : XORCY
    port map (
      CI => fax4_ins_FIFO2_multi_read_ins_Mcount_write_pos_cy(1),
      LI => fax4_ins_FIFO2_multi_read_ins_Mcount_write_pos_cy_2_rt_525,
      O => fax4_ins_FIFO2_multi_read_ins_Result_2_1
    );
  fax4_ins_FIFO2_multi_read_ins_Mcount_write_pos_cy_3_Q : MUXCY
    port map (
      CI => fax4_ins_FIFO2_multi_read_ins_Mcount_write_pos_cy(2),
      DI => NlwRenamedSig_OI_run_len_code_o(26),
      S => fax4_ins_FIFO2_multi_read_ins_Mcount_write_pos_cy_3_rt_527,
      O => fax4_ins_FIFO2_multi_read_ins_Mcount_write_pos_cy(3)
    );
  fax4_ins_FIFO2_multi_read_ins_Mcount_write_pos_xor_3_Q : XORCY
    port map (
      CI => fax4_ins_FIFO2_multi_read_ins_Mcount_write_pos_cy(2),
      LI => fax4_ins_FIFO2_multi_read_ins_Mcount_write_pos_cy_3_rt_527,
      O => fax4_ins_FIFO2_multi_read_ins_Result_3_1
    );
  fax4_ins_FIFO2_multi_read_ins_Mcount_write_pos_cy_4_Q : MUXCY
    port map (
      CI => fax4_ins_FIFO2_multi_read_ins_Mcount_write_pos_cy(3),
      DI => NlwRenamedSig_OI_run_len_code_o(26),
      S => fax4_ins_FIFO2_multi_read_ins_Mcount_write_pos_cy_4_rt_529,
      O => fax4_ins_FIFO2_multi_read_ins_Mcount_write_pos_cy(4)
    );
  fax4_ins_FIFO2_multi_read_ins_Mcount_write_pos_xor_4_Q : XORCY
    port map (
      CI => fax4_ins_FIFO2_multi_read_ins_Mcount_write_pos_cy(3),
      LI => fax4_ins_FIFO2_multi_read_ins_Mcount_write_pos_cy_4_rt_529,
      O => fax4_ins_FIFO2_multi_read_ins_Result_4_1
    );
  fax4_ins_FIFO2_multi_read_ins_Mcount_write_pos_cy_5_Q : MUXCY
    port map (
      CI => fax4_ins_FIFO2_multi_read_ins_Mcount_write_pos_cy(4),
      DI => NlwRenamedSig_OI_run_len_code_o(26),
      S => fax4_ins_FIFO2_multi_read_ins_Mcount_write_pos_cy_5_rt_531,
      O => fax4_ins_FIFO2_multi_read_ins_Mcount_write_pos_cy(5)
    );
  fax4_ins_FIFO2_multi_read_ins_Mcount_write_pos_xor_5_Q : XORCY
    port map (
      CI => fax4_ins_FIFO2_multi_read_ins_Mcount_write_pos_cy(4),
      LI => fax4_ins_FIFO2_multi_read_ins_Mcount_write_pos_cy_5_rt_531,
      O => fax4_ins_FIFO2_multi_read_ins_Result_5_1
    );
  fax4_ins_FIFO2_multi_read_ins_Mcount_write_pos_cy_6_Q : MUXCY
    port map (
      CI => fax4_ins_FIFO2_multi_read_ins_Mcount_write_pos_cy(5),
      DI => NlwRenamedSig_OI_run_len_code_o(26),
      S => fax4_ins_FIFO2_multi_read_ins_Mcount_write_pos_cy_6_rt_533,
      O => fax4_ins_FIFO2_multi_read_ins_Mcount_write_pos_cy(6)
    );
  fax4_ins_FIFO2_multi_read_ins_Mcount_write_pos_xor_6_Q : XORCY
    port map (
      CI => fax4_ins_FIFO2_multi_read_ins_Mcount_write_pos_cy(5),
      LI => fax4_ins_FIFO2_multi_read_ins_Mcount_write_pos_cy_6_rt_533,
      O => fax4_ins_FIFO2_multi_read_ins_Result_6_1
    );
  fax4_ins_FIFO2_multi_read_ins_Mcount_write_pos_cy_7_Q : MUXCY
    port map (
      CI => fax4_ins_FIFO2_multi_read_ins_Mcount_write_pos_cy(6),
      DI => NlwRenamedSig_OI_run_len_code_o(26),
      S => fax4_ins_FIFO2_multi_read_ins_Mcount_write_pos_cy_7_rt_535,
      O => fax4_ins_FIFO2_multi_read_ins_Mcount_write_pos_cy(7)
    );
  fax4_ins_FIFO2_multi_read_ins_Mcount_write_pos_xor_7_Q : XORCY
    port map (
      CI => fax4_ins_FIFO2_multi_read_ins_Mcount_write_pos_cy(6),
      LI => fax4_ins_FIFO2_multi_read_ins_Mcount_write_pos_cy_7_rt_535,
      O => fax4_ins_FIFO2_multi_read_ins_Result_7_1
    );
  fax4_ins_FIFO2_multi_read_ins_Mcount_write_pos_cy_8_Q : MUXCY
    port map (
      CI => fax4_ins_FIFO2_multi_read_ins_Mcount_write_pos_cy(7),
      DI => NlwRenamedSig_OI_run_len_code_o(26),
      S => fax4_ins_FIFO2_multi_read_ins_Mcount_write_pos_cy_8_rt_537,
      O => fax4_ins_FIFO2_multi_read_ins_Mcount_write_pos_cy(8)
    );
  fax4_ins_FIFO2_multi_read_ins_Mcount_write_pos_xor_8_Q : XORCY
    port map (
      CI => fax4_ins_FIFO2_multi_read_ins_Mcount_write_pos_cy(7),
      LI => fax4_ins_FIFO2_multi_read_ins_Mcount_write_pos_cy_8_rt_537,
      O => fax4_ins_FIFO2_multi_read_ins_Result_8_1
    );
  fax4_ins_FIFO2_multi_read_ins_Mcount_write_pos_xor_9_Q : XORCY
    port map (
      CI => fax4_ins_FIFO2_multi_read_ins_Mcount_write_pos_cy(8),
      LI => fax4_ins_FIFO2_multi_read_ins_Mcount_write_pos_xor_9_rt_549,
      O => fax4_ins_FIFO2_multi_read_ins_Result_9_1
    );
  fax4_ins_state_FSM_FFd10 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      D => fax4_ins_state_FSM_FFd10_In_1324,
      Q => fax4_ins_state_FSM_FFd10_1323
    );
  fax4_ins_state_FSM_FFd5 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      D => fax4_ins_state_FSM_FFd5_In,
      Q => fax4_ins_state_FSM_FFd5_1333
    );
  fax4_ins_state_FSM_FFd6 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      D => fax4_ins_state_FSM_FFd6_In_1337,
      Q => fax4_ins_state_FSM_FFd6_1336
    );
  fax4_ins_state_FSM_FFd2 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      D => fax4_ins_state_FSM_FFd2_In_1328,
      Q => fax4_ins_state_FSM_FFd2_1327
    );
  fax4_ins_state_FSM_FFd3 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      D => fax4_ins_state_FSM_FFd3_In,
      Q => fax4_ins_state_FSM_FFd3_1329
    );
  fax4_ins_Mcompar_fifo_rd_cmp_lt0000_cy_9_Q : MUXCY
    port map (
      CI => fax4_ins_Mcompar_fifo_rd_cmp_lt0000_cy(8),
      DI => fax4_ins_fifo_out1_x(9),
      S => fax4_ins_Mcompar_fifo_rd_cmp_lt0000_lut(9),
      O => fax4_ins_Mcompar_fifo_rd_cmp_lt0000_cy(9)
    );
  fax4_ins_Mcompar_fifo_rd_cmp_lt0000_lut_9_Q : LUT2
    generic map(
      INIT => X"9"
    )
    port map (
      I0 => fax4_ins_fifo_out1_x(9),
      I1 => fax4_ins_fifo_rd_addsub0000(9),
      O => fax4_ins_Mcompar_fifo_rd_cmp_lt0000_lut(9)
    );
  fax4_ins_Mcompar_fifo_rd_cmp_lt0000_cy_8_Q : MUXCY
    port map (
      CI => fax4_ins_Mcompar_fifo_rd_cmp_lt0000_cy(7),
      DI => fax4_ins_fifo_out1_x(8),
      S => fax4_ins_Mcompar_fifo_rd_cmp_lt0000_lut(8),
      O => fax4_ins_Mcompar_fifo_rd_cmp_lt0000_cy(8)
    );
  fax4_ins_Mcompar_fifo_rd_cmp_lt0000_lut_8_Q : LUT2
    generic map(
      INIT => X"9"
    )
    port map (
      I0 => fax4_ins_fifo_out1_x(8),
      I1 => fax4_ins_fifo_rd_addsub0000(8),
      O => fax4_ins_Mcompar_fifo_rd_cmp_lt0000_lut(8)
    );
  fax4_ins_Mcompar_fifo_rd_cmp_lt0000_cy_7_Q : MUXCY
    port map (
      CI => fax4_ins_Mcompar_fifo_rd_cmp_lt0000_cy(6),
      DI => fax4_ins_fifo_out1_x(7),
      S => fax4_ins_Mcompar_fifo_rd_cmp_lt0000_lut(7),
      O => fax4_ins_Mcompar_fifo_rd_cmp_lt0000_cy(7)
    );
  fax4_ins_Mcompar_fifo_rd_cmp_lt0000_lut_7_Q : LUT2
    generic map(
      INIT => X"9"
    )
    port map (
      I0 => fax4_ins_fifo_out1_x(7),
      I1 => fax4_ins_fifo_rd_addsub0000(7),
      O => fax4_ins_Mcompar_fifo_rd_cmp_lt0000_lut(7)
    );
  fax4_ins_Mcompar_fifo_rd_cmp_lt0000_cy_6_Q : MUXCY
    port map (
      CI => fax4_ins_Mcompar_fifo_rd_cmp_lt0000_cy(5),
      DI => fax4_ins_fifo_out1_x(6),
      S => fax4_ins_Mcompar_fifo_rd_cmp_lt0000_lut(6),
      O => fax4_ins_Mcompar_fifo_rd_cmp_lt0000_cy(6)
    );
  fax4_ins_Mcompar_fifo_rd_cmp_lt0000_lut_6_Q : LUT2
    generic map(
      INIT => X"9"
    )
    port map (
      I0 => fax4_ins_fifo_out1_x(6),
      I1 => fax4_ins_fifo_rd_addsub0000(6),
      O => fax4_ins_Mcompar_fifo_rd_cmp_lt0000_lut(6)
    );
  fax4_ins_Mcompar_fifo_rd_cmp_lt0000_cy_5_Q : MUXCY
    port map (
      CI => fax4_ins_Mcompar_fifo_rd_cmp_lt0000_cy(4),
      DI => fax4_ins_fifo_out1_x(5),
      S => fax4_ins_Mcompar_fifo_rd_cmp_lt0000_lut(5),
      O => fax4_ins_Mcompar_fifo_rd_cmp_lt0000_cy(5)
    );
  fax4_ins_Mcompar_fifo_rd_cmp_lt0000_lut_5_Q : LUT2
    generic map(
      INIT => X"9"
    )
    port map (
      I0 => fax4_ins_fifo_out1_x(5),
      I1 => fax4_ins_fifo_rd_addsub0000(5),
      O => fax4_ins_Mcompar_fifo_rd_cmp_lt0000_lut(5)
    );
  fax4_ins_Mcompar_fifo_rd_cmp_lt0000_cy_4_Q : MUXCY
    port map (
      CI => fax4_ins_Mcompar_fifo_rd_cmp_lt0000_cy(3),
      DI => fax4_ins_fifo_out1_x(4),
      S => fax4_ins_Mcompar_fifo_rd_cmp_lt0000_lut(4),
      O => fax4_ins_Mcompar_fifo_rd_cmp_lt0000_cy(4)
    );
  fax4_ins_Mcompar_fifo_rd_cmp_lt0000_lut_4_Q : LUT2
    generic map(
      INIT => X"9"
    )
    port map (
      I0 => fax4_ins_fifo_out1_x(4),
      I1 => fax4_ins_fifo_rd_addsub0000(4),
      O => fax4_ins_Mcompar_fifo_rd_cmp_lt0000_lut(4)
    );
  fax4_ins_Mcompar_fifo_rd_cmp_lt0000_cy_3_Q : MUXCY
    port map (
      CI => fax4_ins_Mcompar_fifo_rd_cmp_lt0000_cy(2),
      DI => fax4_ins_fifo_out1_x(3),
      S => fax4_ins_Mcompar_fifo_rd_cmp_lt0000_lut(3),
      O => fax4_ins_Mcompar_fifo_rd_cmp_lt0000_cy(3)
    );
  fax4_ins_Mcompar_fifo_rd_cmp_lt0000_lut_3_Q : LUT2
    generic map(
      INIT => X"9"
    )
    port map (
      I0 => fax4_ins_fifo_out1_x(3),
      I1 => fax4_ins_fifo_rd_addsub0000(3),
      O => fax4_ins_Mcompar_fifo_rd_cmp_lt0000_lut(3)
    );
  fax4_ins_Mcompar_fifo_rd_cmp_lt0000_cy_2_Q : MUXCY
    port map (
      CI => fax4_ins_Mcompar_fifo_rd_cmp_lt0000_cy(1),
      DI => fax4_ins_fifo_out1_x(2),
      S => fax4_ins_Mcompar_fifo_rd_cmp_lt0000_lut(2),
      O => fax4_ins_Mcompar_fifo_rd_cmp_lt0000_cy(2)
    );
  fax4_ins_Mcompar_fifo_rd_cmp_lt0000_lut_2_Q : LUT2
    generic map(
      INIT => X"9"
    )
    port map (
      I0 => fax4_ins_fifo_out1_x(2),
      I1 => fax4_ins_fifo_rd_addsub0000(2),
      O => fax4_ins_Mcompar_fifo_rd_cmp_lt0000_lut(2)
    );
  fax4_ins_Mcompar_fifo_rd_cmp_lt0000_cy_1_Q : MUXCY
    port map (
      CI => fax4_ins_Mcompar_fifo_rd_cmp_lt0000_cy(0),
      DI => fax4_ins_fifo_out1_x(1),
      S => fax4_ins_Mcompar_fifo_rd_cmp_lt0000_lut(1),
      O => fax4_ins_Mcompar_fifo_rd_cmp_lt0000_cy(1)
    );
  fax4_ins_Mcompar_fifo_rd_cmp_lt0000_lut_1_Q : LUT2
    generic map(
      INIT => X"9"
    )
    port map (
      I0 => fax4_ins_fifo_out1_x(1),
      I1 => fax4_ins_fifo_rd_addsub0000(1),
      O => fax4_ins_Mcompar_fifo_rd_cmp_lt0000_lut(1)
    );
  fax4_ins_Mcompar_fifo_rd_cmp_lt0000_cy_0_Q : MUXCY
    port map (
      CI => N1,
      DI => fax4_ins_fifo_out1_x(0),
      S => fax4_ins_Mcompar_fifo_rd_cmp_lt0000_lut(0),
      O => fax4_ins_Mcompar_fifo_rd_cmp_lt0000_cy(0)
    );
  fax4_ins_Mcompar_fifo_rd_cmp_lt0000_lut_0_Q : LUT2
    generic map(
      INIT => X"9"
    )
    port map (
      I0 => fax4_ins_fifo_out1_x(0),
      I1 => fax4_ins_fifo_rd_addsub0000(0),
      O => fax4_ins_Mcompar_fifo_rd_cmp_lt0000_lut(0)
    );
  fax4_ins_Mcompar_pass_mode_cmp_lt0000_cy_9_Q : MUXCY
    port map (
      CI => fax4_ins_Mcompar_pass_mode_cmp_lt0000_cy(8),
      DI => fax4_ins_b2(9),
      S => fax4_ins_Mcompar_pass_mode_cmp_lt0000_lut(9),
      O => fax4_ins_Mcompar_pass_mode_cmp_lt0000_cy(9)
    );
  fax4_ins_Mcompar_pass_mode_cmp_lt0000_lut_9_Q : LUT2
    generic map(
      INIT => X"9"
    )
    port map (
      I0 => fax4_ins_b2(9),
      I1 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(9),
      O => fax4_ins_Mcompar_pass_mode_cmp_lt0000_lut(9)
    );
  fax4_ins_Mcompar_pass_mode_cmp_lt0000_cy_8_Q : MUXCY
    port map (
      CI => fax4_ins_Mcompar_pass_mode_cmp_lt0000_cy(7),
      DI => fax4_ins_b2(8),
      S => fax4_ins_Mcompar_pass_mode_cmp_lt0000_lut(8),
      O => fax4_ins_Mcompar_pass_mode_cmp_lt0000_cy(8)
    );
  fax4_ins_Mcompar_pass_mode_cmp_lt0000_lut_8_Q : LUT2
    generic map(
      INIT => X"9"
    )
    port map (
      I0 => fax4_ins_b2(8),
      I1 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(8),
      O => fax4_ins_Mcompar_pass_mode_cmp_lt0000_lut(8)
    );
  fax4_ins_Mcompar_pass_mode_cmp_lt0000_cy_7_Q : MUXCY
    port map (
      CI => fax4_ins_Mcompar_pass_mode_cmp_lt0000_cy(6),
      DI => fax4_ins_b2(7),
      S => fax4_ins_Mcompar_pass_mode_cmp_lt0000_lut(7),
      O => fax4_ins_Mcompar_pass_mode_cmp_lt0000_cy(7)
    );
  fax4_ins_Mcompar_pass_mode_cmp_lt0000_lut_7_Q : LUT2
    generic map(
      INIT => X"9"
    )
    port map (
      I0 => fax4_ins_b2(7),
      I1 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(7),
      O => fax4_ins_Mcompar_pass_mode_cmp_lt0000_lut(7)
    );
  fax4_ins_Mcompar_pass_mode_cmp_lt0000_cy_6_Q : MUXCY
    port map (
      CI => fax4_ins_Mcompar_pass_mode_cmp_lt0000_cy(5),
      DI => fax4_ins_b2(6),
      S => fax4_ins_Mcompar_pass_mode_cmp_lt0000_lut(6),
      O => fax4_ins_Mcompar_pass_mode_cmp_lt0000_cy(6)
    );
  fax4_ins_Mcompar_pass_mode_cmp_lt0000_lut_6_Q : LUT2
    generic map(
      INIT => X"9"
    )
    port map (
      I0 => fax4_ins_b2(6),
      I1 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(6),
      O => fax4_ins_Mcompar_pass_mode_cmp_lt0000_lut(6)
    );
  fax4_ins_Mcompar_pass_mode_cmp_lt0000_cy_5_Q : MUXCY
    port map (
      CI => fax4_ins_Mcompar_pass_mode_cmp_lt0000_cy(4),
      DI => fax4_ins_b2(5),
      S => fax4_ins_Mcompar_pass_mode_cmp_lt0000_lut(5),
      O => fax4_ins_Mcompar_pass_mode_cmp_lt0000_cy(5)
    );
  fax4_ins_Mcompar_pass_mode_cmp_lt0000_lut_5_Q : LUT2
    generic map(
      INIT => X"9"
    )
    port map (
      I0 => fax4_ins_b2(5),
      I1 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(5),
      O => fax4_ins_Mcompar_pass_mode_cmp_lt0000_lut(5)
    );
  fax4_ins_Mcompar_pass_mode_cmp_lt0000_cy_4_Q : MUXCY
    port map (
      CI => fax4_ins_Mcompar_pass_mode_cmp_lt0000_cy(3),
      DI => fax4_ins_b2(4),
      S => fax4_ins_Mcompar_pass_mode_cmp_lt0000_lut(4),
      O => fax4_ins_Mcompar_pass_mode_cmp_lt0000_cy(4)
    );
  fax4_ins_Mcompar_pass_mode_cmp_lt0000_lut_4_Q : LUT2
    generic map(
      INIT => X"9"
    )
    port map (
      I0 => fax4_ins_b2(4),
      I1 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(4),
      O => fax4_ins_Mcompar_pass_mode_cmp_lt0000_lut(4)
    );
  fax4_ins_Mcompar_pass_mode_cmp_lt0000_cy_3_Q : MUXCY
    port map (
      CI => fax4_ins_Mcompar_pass_mode_cmp_lt0000_cy(2),
      DI => fax4_ins_b2(3),
      S => fax4_ins_Mcompar_pass_mode_cmp_lt0000_lut(3),
      O => fax4_ins_Mcompar_pass_mode_cmp_lt0000_cy(3)
    );
  fax4_ins_Mcompar_pass_mode_cmp_lt0000_lut_3_Q : LUT2
    generic map(
      INIT => X"9"
    )
    port map (
      I0 => fax4_ins_b2(3),
      I1 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(3),
      O => fax4_ins_Mcompar_pass_mode_cmp_lt0000_lut(3)
    );
  fax4_ins_Mcompar_pass_mode_cmp_lt0000_cy_2_Q : MUXCY
    port map (
      CI => fax4_ins_Mcompar_pass_mode_cmp_lt0000_cy(1),
      DI => fax4_ins_b2(2),
      S => fax4_ins_Mcompar_pass_mode_cmp_lt0000_lut(2),
      O => fax4_ins_Mcompar_pass_mode_cmp_lt0000_cy(2)
    );
  fax4_ins_Mcompar_pass_mode_cmp_lt0000_lut_2_Q : LUT2
    generic map(
      INIT => X"9"
    )
    port map (
      I0 => fax4_ins_b2(2),
      I1 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(2),
      O => fax4_ins_Mcompar_pass_mode_cmp_lt0000_lut(2)
    );
  fax4_ins_Mcompar_pass_mode_cmp_lt0000_cy_1_Q : MUXCY
    port map (
      CI => fax4_ins_Mcompar_pass_mode_cmp_lt0000_cy(0),
      DI => fax4_ins_b2(1),
      S => fax4_ins_Mcompar_pass_mode_cmp_lt0000_lut(1),
      O => fax4_ins_Mcompar_pass_mode_cmp_lt0000_cy(1)
    );
  fax4_ins_Mcompar_pass_mode_cmp_lt0000_lut_1_Q : LUT2
    generic map(
      INIT => X"9"
    )
    port map (
      I0 => fax4_ins_b2(1),
      I1 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(1),
      O => fax4_ins_Mcompar_pass_mode_cmp_lt0000_lut(1)
    );
  fax4_ins_Mcompar_pass_mode_cmp_lt0000_cy_0_Q : MUXCY
    port map (
      CI => N1,
      DI => fax4_ins_b2(0),
      S => fax4_ins_Mcompar_pass_mode_cmp_lt0000_lut(0),
      O => fax4_ins_Mcompar_pass_mode_cmp_lt0000_cy(0)
    );
  fax4_ins_Mcompar_pass_mode_cmp_lt0000_lut_0_Q : LUT2
    generic map(
      INIT => X"9"
    )
    port map (
      I0 => fax4_ins_b2(0),
      I1 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(0),
      O => fax4_ins_Mcompar_pass_mode_cmp_lt0000_lut(0)
    );
  fax4_ins_Madd_fifo_rd_addsub0000_xor_9_Q : XORCY
    port map (
      CI => fax4_ins_Madd_fifo_rd_addsub0000_cy(8),
      LI => fax4_ins_Madd_fifo_rd_addsub0000_xor_9_rt_749,
      O => fax4_ins_fifo_rd_addsub0000(9)
    );
  fax4_ins_Madd_fifo_rd_addsub0000_xor_8_Q : XORCY
    port map (
      CI => fax4_ins_Madd_fifo_rd_addsub0000_cy(7),
      LI => fax4_ins_Madd_fifo_rd_addsub0000_cy_8_rt_747,
      O => fax4_ins_fifo_rd_addsub0000(8)
    );
  fax4_ins_Madd_fifo_rd_addsub0000_cy_8_Q : MUXCY
    port map (
      CI => fax4_ins_Madd_fifo_rd_addsub0000_cy(7),
      DI => NlwRenamedSig_OI_run_len_code_o(26),
      S => fax4_ins_Madd_fifo_rd_addsub0000_cy_8_rt_747,
      O => fax4_ins_Madd_fifo_rd_addsub0000_cy(8)
    );
  fax4_ins_Madd_fifo_rd_addsub0000_xor_7_Q : XORCY
    port map (
      CI => fax4_ins_Madd_fifo_rd_addsub0000_cy(6),
      LI => fax4_ins_Madd_fifo_rd_addsub0000_cy_7_rt_745,
      O => fax4_ins_fifo_rd_addsub0000(7)
    );
  fax4_ins_Madd_fifo_rd_addsub0000_cy_7_Q : MUXCY
    port map (
      CI => fax4_ins_Madd_fifo_rd_addsub0000_cy(6),
      DI => NlwRenamedSig_OI_run_len_code_o(26),
      S => fax4_ins_Madd_fifo_rd_addsub0000_cy_7_rt_745,
      O => fax4_ins_Madd_fifo_rd_addsub0000_cy(7)
    );
  fax4_ins_Madd_fifo_rd_addsub0000_xor_6_Q : XORCY
    port map (
      CI => fax4_ins_Madd_fifo_rd_addsub0000_cy(5),
      LI => fax4_ins_Madd_fifo_rd_addsub0000_cy_6_rt_743,
      O => fax4_ins_fifo_rd_addsub0000(6)
    );
  fax4_ins_Madd_fifo_rd_addsub0000_cy_6_Q : MUXCY
    port map (
      CI => fax4_ins_Madd_fifo_rd_addsub0000_cy(5),
      DI => NlwRenamedSig_OI_run_len_code_o(26),
      S => fax4_ins_Madd_fifo_rd_addsub0000_cy_6_rt_743,
      O => fax4_ins_Madd_fifo_rd_addsub0000_cy(6)
    );
  fax4_ins_Madd_fifo_rd_addsub0000_xor_5_Q : XORCY
    port map (
      CI => fax4_ins_Madd_fifo_rd_addsub0000_cy(4),
      LI => fax4_ins_Madd_fifo_rd_addsub0000_cy_5_rt_741,
      O => fax4_ins_fifo_rd_addsub0000(5)
    );
  fax4_ins_Madd_fifo_rd_addsub0000_cy_5_Q : MUXCY
    port map (
      CI => fax4_ins_Madd_fifo_rd_addsub0000_cy(4),
      DI => NlwRenamedSig_OI_run_len_code_o(26),
      S => fax4_ins_Madd_fifo_rd_addsub0000_cy_5_rt_741,
      O => fax4_ins_Madd_fifo_rd_addsub0000_cy(5)
    );
  fax4_ins_Madd_fifo_rd_addsub0000_xor_4_Q : XORCY
    port map (
      CI => fax4_ins_Madd_fifo_rd_addsub0000_cy(3),
      LI => fax4_ins_Madd_fifo_rd_addsub0000_cy_4_rt_739,
      O => fax4_ins_fifo_rd_addsub0000(4)
    );
  fax4_ins_Madd_fifo_rd_addsub0000_cy_4_Q : MUXCY
    port map (
      CI => fax4_ins_Madd_fifo_rd_addsub0000_cy(3),
      DI => NlwRenamedSig_OI_run_len_code_o(26),
      S => fax4_ins_Madd_fifo_rd_addsub0000_cy_4_rt_739,
      O => fax4_ins_Madd_fifo_rd_addsub0000_cy(4)
    );
  fax4_ins_Madd_fifo_rd_addsub0000_xor_3_Q : XORCY
    port map (
      CI => fax4_ins_Madd_fifo_rd_addsub0000_cy(2),
      LI => fax4_ins_Madd_fifo_rd_addsub0000_cy_3_rt_737,
      O => fax4_ins_fifo_rd_addsub0000(3)
    );
  fax4_ins_Madd_fifo_rd_addsub0000_cy_3_Q : MUXCY
    port map (
      CI => fax4_ins_Madd_fifo_rd_addsub0000_cy(2),
      DI => NlwRenamedSig_OI_run_len_code_o(26),
      S => fax4_ins_Madd_fifo_rd_addsub0000_cy_3_rt_737,
      O => fax4_ins_Madd_fifo_rd_addsub0000_cy(3)
    );
  fax4_ins_Madd_fifo_rd_addsub0000_xor_2_Q : XORCY
    port map (
      CI => fax4_ins_Madd_fifo_rd_addsub0000_cy(1),
      LI => fax4_ins_Madd_fifo_rd_addsub0000_cy_2_rt_735,
      O => fax4_ins_fifo_rd_addsub0000(2)
    );
  fax4_ins_Madd_fifo_rd_addsub0000_cy_2_Q : MUXCY
    port map (
      CI => fax4_ins_Madd_fifo_rd_addsub0000_cy(1),
      DI => NlwRenamedSig_OI_run_len_code_o(26),
      S => fax4_ins_Madd_fifo_rd_addsub0000_cy_2_rt_735,
      O => fax4_ins_Madd_fifo_rd_addsub0000_cy(2)
    );
  fax4_ins_Madd_fifo_rd_addsub0000_xor_1_Q : XORCY
    port map (
      CI => fax4_ins_Madd_fifo_rd_addsub0000_cy(0),
      LI => fax4_ins_Madd_fifo_rd_addsub0000_cy_1_rt_733,
      O => fax4_ins_fifo_rd_addsub0000(1)
    );
  fax4_ins_Madd_fifo_rd_addsub0000_cy_1_Q : MUXCY
    port map (
      CI => fax4_ins_Madd_fifo_rd_addsub0000_cy(0),
      DI => NlwRenamedSig_OI_run_len_code_o(26),
      S => fax4_ins_Madd_fifo_rd_addsub0000_cy_1_rt_733,
      O => fax4_ins_Madd_fifo_rd_addsub0000_cy(1)
    );
  fax4_ins_Madd_fifo_rd_addsub0000_xor_0_Q : XORCY
    port map (
      CI => NlwRenamedSig_OI_run_len_code_o(26),
      LI => fax4_ins_Madd_fifo_rd_addsub0000_lut(0),
      O => fax4_ins_fifo_rd_addsub0000(0)
    );
  fax4_ins_Madd_fifo_rd_addsub0000_cy_0_Q : MUXCY
    port map (
      CI => NlwRenamedSig_OI_run_len_code_o(26),
      DI => N1,
      S => fax4_ins_Madd_fifo_rd_addsub0000_lut(0),
      O => fax4_ins_Madd_fifo_rd_addsub0000_cy(0)
    );
  fax4_ins_Msub_a1b1_addsub0000_xor_10_Q : XORCY
    port map (
      CI => fax4_ins_Msub_a1b1_addsub0000_cy(9),
      LI => N1,
      O => fax4_ins_a1b1_addsub0000(10)
    );
  fax4_ins_Msub_a1b1_addsub0000_xor_9_Q : XORCY
    port map (
      CI => fax4_ins_Msub_a1b1_addsub0000_cy(8),
      LI => fax4_ins_Msub_a1b1_addsub0000_lut(9),
      O => fax4_ins_a1b1_addsub0000(9)
    );
  fax4_ins_Msub_a1b1_addsub0000_cy_9_Q : MUXCY
    port map (
      CI => fax4_ins_Msub_a1b1_addsub0000_cy(8),
      DI => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(9),
      S => fax4_ins_Msub_a1b1_addsub0000_lut(9),
      O => fax4_ins_Msub_a1b1_addsub0000_cy(9)
    );
  fax4_ins_Msub_a1b1_addsub0000_lut_9_Q : LUT2
    generic map(
      INIT => X"9"
    )
    port map (
      I0 => fax4_ins_b1(9),
      I1 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(9),
      O => fax4_ins_Msub_a1b1_addsub0000_lut(9)
    );
  fax4_ins_Msub_a1b1_addsub0000_xor_8_Q : XORCY
    port map (
      CI => fax4_ins_Msub_a1b1_addsub0000_cy(7),
      LI => fax4_ins_Msub_a1b1_addsub0000_lut(8),
      O => fax4_ins_a1b1_addsub0000(8)
    );
  fax4_ins_Msub_a1b1_addsub0000_cy_8_Q : MUXCY
    port map (
      CI => fax4_ins_Msub_a1b1_addsub0000_cy(7),
      DI => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(8),
      S => fax4_ins_Msub_a1b1_addsub0000_lut(8),
      O => fax4_ins_Msub_a1b1_addsub0000_cy(8)
    );
  fax4_ins_Msub_a1b1_addsub0000_lut_8_Q : LUT2
    generic map(
      INIT => X"9"
    )
    port map (
      I0 => fax4_ins_b1(8),
      I1 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(8),
      O => fax4_ins_Msub_a1b1_addsub0000_lut(8)
    );
  fax4_ins_Msub_a1b1_addsub0000_xor_7_Q : XORCY
    port map (
      CI => fax4_ins_Msub_a1b1_addsub0000_cy(6),
      LI => fax4_ins_Msub_a1b1_addsub0000_lut(7),
      O => fax4_ins_a1b1_addsub0000(7)
    );
  fax4_ins_Msub_a1b1_addsub0000_cy_7_Q : MUXCY
    port map (
      CI => fax4_ins_Msub_a1b1_addsub0000_cy(6),
      DI => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(7),
      S => fax4_ins_Msub_a1b1_addsub0000_lut(7),
      O => fax4_ins_Msub_a1b1_addsub0000_cy(7)
    );
  fax4_ins_Msub_a1b1_addsub0000_lut_7_Q : LUT2
    generic map(
      INIT => X"9"
    )
    port map (
      I0 => fax4_ins_b1(7),
      I1 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(7),
      O => fax4_ins_Msub_a1b1_addsub0000_lut(7)
    );
  fax4_ins_Msub_a1b1_addsub0000_xor_6_Q : XORCY
    port map (
      CI => fax4_ins_Msub_a1b1_addsub0000_cy(5),
      LI => fax4_ins_Msub_a1b1_addsub0000_lut(6),
      O => fax4_ins_a1b1_addsub0000(6)
    );
  fax4_ins_Msub_a1b1_addsub0000_cy_6_Q : MUXCY
    port map (
      CI => fax4_ins_Msub_a1b1_addsub0000_cy(5),
      DI => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(6),
      S => fax4_ins_Msub_a1b1_addsub0000_lut(6),
      O => fax4_ins_Msub_a1b1_addsub0000_cy(6)
    );
  fax4_ins_Msub_a1b1_addsub0000_lut_6_Q : LUT2
    generic map(
      INIT => X"9"
    )
    port map (
      I0 => fax4_ins_b1(6),
      I1 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(6),
      O => fax4_ins_Msub_a1b1_addsub0000_lut(6)
    );
  fax4_ins_Msub_a1b1_addsub0000_xor_5_Q : XORCY
    port map (
      CI => fax4_ins_Msub_a1b1_addsub0000_cy(4),
      LI => fax4_ins_Msub_a1b1_addsub0000_lut(5),
      O => fax4_ins_a1b1_addsub0000(5)
    );
  fax4_ins_Msub_a1b1_addsub0000_cy_5_Q : MUXCY
    port map (
      CI => fax4_ins_Msub_a1b1_addsub0000_cy(4),
      DI => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(5),
      S => fax4_ins_Msub_a1b1_addsub0000_lut(5),
      O => fax4_ins_Msub_a1b1_addsub0000_cy(5)
    );
  fax4_ins_Msub_a1b1_addsub0000_lut_5_Q : LUT2
    generic map(
      INIT => X"9"
    )
    port map (
      I0 => fax4_ins_b1(5),
      I1 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(5),
      O => fax4_ins_Msub_a1b1_addsub0000_lut(5)
    );
  fax4_ins_Msub_a1b1_addsub0000_xor_4_Q : XORCY
    port map (
      CI => fax4_ins_Msub_a1b1_addsub0000_cy(3),
      LI => fax4_ins_Msub_a1b1_addsub0000_lut(4),
      O => fax4_ins_a1b1_addsub0000(4)
    );
  fax4_ins_Msub_a1b1_addsub0000_cy_4_Q : MUXCY
    port map (
      CI => fax4_ins_Msub_a1b1_addsub0000_cy(3),
      DI => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(4),
      S => fax4_ins_Msub_a1b1_addsub0000_lut(4),
      O => fax4_ins_Msub_a1b1_addsub0000_cy(4)
    );
  fax4_ins_Msub_a1b1_addsub0000_lut_4_Q : LUT2
    generic map(
      INIT => X"9"
    )
    port map (
      I0 => fax4_ins_b1(4),
      I1 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(4),
      O => fax4_ins_Msub_a1b1_addsub0000_lut(4)
    );
  fax4_ins_Msub_a1b1_addsub0000_xor_3_Q : XORCY
    port map (
      CI => fax4_ins_Msub_a1b1_addsub0000_cy(2),
      LI => fax4_ins_Msub_a1b1_addsub0000_lut(3),
      O => fax4_ins_a1b1_addsub0000(3)
    );
  fax4_ins_Msub_a1b1_addsub0000_cy_3_Q : MUXCY
    port map (
      CI => fax4_ins_Msub_a1b1_addsub0000_cy(2),
      DI => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(3),
      S => fax4_ins_Msub_a1b1_addsub0000_lut(3),
      O => fax4_ins_Msub_a1b1_addsub0000_cy(3)
    );
  fax4_ins_Msub_a1b1_addsub0000_lut_3_Q : LUT2
    generic map(
      INIT => X"9"
    )
    port map (
      I0 => fax4_ins_b1(3),
      I1 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(3),
      O => fax4_ins_Msub_a1b1_addsub0000_lut(3)
    );
  fax4_ins_Msub_a1b1_addsub0000_xor_2_Q : XORCY
    port map (
      CI => fax4_ins_Msub_a1b1_addsub0000_cy(1),
      LI => fax4_ins_Msub_a1b1_addsub0000_lut(2),
      O => fax4_ins_a1b1_addsub0000(2)
    );
  fax4_ins_Msub_a1b1_addsub0000_cy_2_Q : MUXCY
    port map (
      CI => fax4_ins_Msub_a1b1_addsub0000_cy(1),
      DI => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(2),
      S => fax4_ins_Msub_a1b1_addsub0000_lut(2),
      O => fax4_ins_Msub_a1b1_addsub0000_cy(2)
    );
  fax4_ins_Msub_a1b1_addsub0000_lut_2_Q : LUT2
    generic map(
      INIT => X"9"
    )
    port map (
      I0 => fax4_ins_b1(2),
      I1 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(2),
      O => fax4_ins_Msub_a1b1_addsub0000_lut(2)
    );
  fax4_ins_Msub_a1b1_addsub0000_xor_1_Q : XORCY
    port map (
      CI => fax4_ins_Msub_a1b1_addsub0000_cy(0),
      LI => fax4_ins_Msub_a1b1_addsub0000_lut(1),
      O => fax4_ins_a1b1_addsub0000(1)
    );
  fax4_ins_Msub_a1b1_addsub0000_cy_1_Q : MUXCY
    port map (
      CI => fax4_ins_Msub_a1b1_addsub0000_cy(0),
      DI => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(1),
      S => fax4_ins_Msub_a1b1_addsub0000_lut(1),
      O => fax4_ins_Msub_a1b1_addsub0000_cy(1)
    );
  fax4_ins_Msub_a1b1_addsub0000_lut_1_Q : LUT2
    generic map(
      INIT => X"9"
    )
    port map (
      I0 => fax4_ins_b1(1),
      I1 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(1),
      O => fax4_ins_Msub_a1b1_addsub0000_lut(1)
    );
  fax4_ins_Msub_a1b1_addsub0000_xor_0_Q : XORCY
    port map (
      CI => N1,
      LI => fax4_ins_Msub_a1b1_addsub0000_lut(0),
      O => fax4_ins_a1b1_addsub0000(0)
    );
  fax4_ins_Msub_a1b1_addsub0000_cy_0_Q : MUXCY
    port map (
      CI => N1,
      DI => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(0),
      S => fax4_ins_Msub_a1b1_addsub0000_lut(0),
      O => fax4_ins_Msub_a1b1_addsub0000_cy(0)
    );
  fax4_ins_Msub_a1b1_addsub0000_lut_0_Q : LUT2
    generic map(
      INIT => X"9"
    )
    port map (
      I0 => fax4_ins_b1(0),
      I1 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(0),
      O => fax4_ins_Msub_a1b1_addsub0000_lut(0)
    );
  fax4_ins_Mcompar_mux_b1_3_cmp_gt0000_cy_9_Q : MUXCY
    port map (
      CI => fax4_ins_Mcompar_mux_b1_3_cmp_gt0000_cy(8),
      DI => fax4_ins_a0(9),
      S => fax4_ins_Mcompar_mux_b1_3_cmp_gt0000_lut(9),
      O => fax4_ins_Mcompar_mux_b1_3_cmp_gt0000_cy(9)
    );
  fax4_ins_Mcompar_mux_b1_3_cmp_gt0000_cy_8_Q : MUXCY
    port map (
      CI => fax4_ins_Mcompar_mux_b1_3_cmp_gt0000_cy(7),
      DI => fax4_ins_a0(8),
      S => fax4_ins_Mcompar_mux_b1_3_cmp_gt0000_lut(8),
      O => fax4_ins_Mcompar_mux_b1_3_cmp_gt0000_cy(8)
    );
  fax4_ins_Mcompar_mux_b1_3_cmp_gt0000_cy_7_Q : MUXCY
    port map (
      CI => fax4_ins_Mcompar_mux_b1_3_cmp_gt0000_cy(6),
      DI => fax4_ins_a0(7),
      S => fax4_ins_Mcompar_mux_b1_3_cmp_gt0000_lut(7),
      O => fax4_ins_Mcompar_mux_b1_3_cmp_gt0000_cy(7)
    );
  fax4_ins_Mcompar_mux_b1_3_cmp_gt0000_cy_6_Q : MUXCY
    port map (
      CI => fax4_ins_Mcompar_mux_b1_3_cmp_gt0000_cy(5),
      DI => fax4_ins_a0(6),
      S => fax4_ins_Mcompar_mux_b1_3_cmp_gt0000_lut(6),
      O => fax4_ins_Mcompar_mux_b1_3_cmp_gt0000_cy(6)
    );
  fax4_ins_Mcompar_mux_b1_3_cmp_gt0000_cy_5_Q : MUXCY
    port map (
      CI => fax4_ins_Mcompar_mux_b1_3_cmp_gt0000_cy(4),
      DI => fax4_ins_a0(5),
      S => fax4_ins_Mcompar_mux_b1_3_cmp_gt0000_lut(5),
      O => fax4_ins_Mcompar_mux_b1_3_cmp_gt0000_cy(5)
    );
  fax4_ins_Mcompar_mux_b1_3_cmp_gt0000_cy_4_Q : MUXCY
    port map (
      CI => fax4_ins_Mcompar_mux_b1_3_cmp_gt0000_cy(3),
      DI => fax4_ins_a0(4),
      S => fax4_ins_Mcompar_mux_b1_3_cmp_gt0000_lut(4),
      O => fax4_ins_Mcompar_mux_b1_3_cmp_gt0000_cy(4)
    );
  fax4_ins_Mcompar_mux_b1_3_cmp_gt0000_cy_3_Q : MUXCY
    port map (
      CI => fax4_ins_Mcompar_mux_b1_3_cmp_gt0000_cy(2),
      DI => fax4_ins_a0(3),
      S => fax4_ins_Mcompar_mux_b1_3_cmp_gt0000_lut(3),
      O => fax4_ins_Mcompar_mux_b1_3_cmp_gt0000_cy(3)
    );
  fax4_ins_Mcompar_mux_b1_3_cmp_gt0000_cy_2_Q : MUXCY
    port map (
      CI => fax4_ins_Mcompar_mux_b1_3_cmp_gt0000_cy(1),
      DI => fax4_ins_a0(2),
      S => fax4_ins_Mcompar_mux_b1_3_cmp_gt0000_lut(2),
      O => fax4_ins_Mcompar_mux_b1_3_cmp_gt0000_cy(2)
    );
  fax4_ins_Mcompar_mux_b1_3_cmp_gt0000_cy_1_Q : MUXCY
    port map (
      CI => fax4_ins_Mcompar_mux_b1_3_cmp_gt0000_cy(0),
      DI => fax4_ins_a0(1),
      S => fax4_ins_Mcompar_mux_b1_3_cmp_gt0000_lut(1),
      O => fax4_ins_Mcompar_mux_b1_3_cmp_gt0000_cy(1)
    );
  fax4_ins_Mcompar_mux_b1_3_cmp_gt0000_cy_0_Q : MUXCY
    port map (
      CI => N1,
      DI => fax4_ins_a0(0),
      S => fax4_ins_Mcompar_mux_b1_3_cmp_gt0000_lut(0),
      O => fax4_ins_Mcompar_mux_b1_3_cmp_gt0000_cy(0)
    );
  fax4_ins_Mcompar_mux_b1_2_cmp_gt0000_cy_9_Q : MUXCY
    port map (
      CI => fax4_ins_Mcompar_mux_b1_2_cmp_gt0000_cy(8),
      DI => fax4_ins_a0(9),
      S => fax4_ins_Mcompar_mux_b1_2_cmp_gt0000_lut(9),
      O => fax4_ins_Mcompar_mux_b1_2_cmp_gt0000_cy(9)
    );
  fax4_ins_Mcompar_mux_b1_2_cmp_gt0000_cy_8_Q : MUXCY
    port map (
      CI => fax4_ins_Mcompar_mux_b1_2_cmp_gt0000_cy(7),
      DI => fax4_ins_a0(8),
      S => fax4_ins_Mcompar_mux_b1_2_cmp_gt0000_lut(8),
      O => fax4_ins_Mcompar_mux_b1_2_cmp_gt0000_cy(8)
    );
  fax4_ins_Mcompar_mux_b1_2_cmp_gt0000_cy_7_Q : MUXCY
    port map (
      CI => fax4_ins_Mcompar_mux_b1_2_cmp_gt0000_cy(6),
      DI => fax4_ins_a0(7),
      S => fax4_ins_Mcompar_mux_b1_2_cmp_gt0000_lut(7),
      O => fax4_ins_Mcompar_mux_b1_2_cmp_gt0000_cy(7)
    );
  fax4_ins_Mcompar_mux_b1_2_cmp_gt0000_cy_6_Q : MUXCY
    port map (
      CI => fax4_ins_Mcompar_mux_b1_2_cmp_gt0000_cy(5),
      DI => fax4_ins_a0(6),
      S => fax4_ins_Mcompar_mux_b1_2_cmp_gt0000_lut(6),
      O => fax4_ins_Mcompar_mux_b1_2_cmp_gt0000_cy(6)
    );
  fax4_ins_Mcompar_mux_b1_2_cmp_gt0000_cy_5_Q : MUXCY
    port map (
      CI => fax4_ins_Mcompar_mux_b1_2_cmp_gt0000_cy(4),
      DI => fax4_ins_a0(5),
      S => fax4_ins_Mcompar_mux_b1_2_cmp_gt0000_lut(5),
      O => fax4_ins_Mcompar_mux_b1_2_cmp_gt0000_cy(5)
    );
  fax4_ins_Mcompar_mux_b1_2_cmp_gt0000_cy_4_Q : MUXCY
    port map (
      CI => fax4_ins_Mcompar_mux_b1_2_cmp_gt0000_cy(3),
      DI => fax4_ins_a0(4),
      S => fax4_ins_Mcompar_mux_b1_2_cmp_gt0000_lut(4),
      O => fax4_ins_Mcompar_mux_b1_2_cmp_gt0000_cy(4)
    );
  fax4_ins_Mcompar_mux_b1_2_cmp_gt0000_cy_3_Q : MUXCY
    port map (
      CI => fax4_ins_Mcompar_mux_b1_2_cmp_gt0000_cy(2),
      DI => fax4_ins_a0(3),
      S => fax4_ins_Mcompar_mux_b1_2_cmp_gt0000_lut(3),
      O => fax4_ins_Mcompar_mux_b1_2_cmp_gt0000_cy(3)
    );
  fax4_ins_Mcompar_mux_b1_2_cmp_gt0000_cy_2_Q : MUXCY
    port map (
      CI => fax4_ins_Mcompar_mux_b1_2_cmp_gt0000_cy(1),
      DI => fax4_ins_a0(2),
      S => fax4_ins_Mcompar_mux_b1_2_cmp_gt0000_lut(2),
      O => fax4_ins_Mcompar_mux_b1_2_cmp_gt0000_cy(2)
    );
  fax4_ins_Mcompar_mux_b1_2_cmp_gt0000_cy_1_Q : MUXCY
    port map (
      CI => fax4_ins_Mcompar_mux_b1_2_cmp_gt0000_cy(0),
      DI => fax4_ins_a0(1),
      S => fax4_ins_Mcompar_mux_b1_2_cmp_gt0000_lut(1),
      O => fax4_ins_Mcompar_mux_b1_2_cmp_gt0000_cy(1)
    );
  fax4_ins_Mcompar_mux_b1_2_cmp_gt0000_cy_0_Q : MUXCY
    port map (
      CI => N1,
      DI => fax4_ins_a0(0),
      S => fax4_ins_Mcompar_mux_b1_2_cmp_gt0000_lut(0),
      O => fax4_ins_Mcompar_mux_b1_2_cmp_gt0000_cy(0)
    );
  fax4_ins_Mcompar_mux_b1_2_cmp_gt0000_lut_0_Q : LUT2
    generic map(
      INIT => X"9"
    )
    port map (
      I0 => fax4_ins_a0(0),
      I1 => fax4_ins_fifo_out1_x(0),
      O => fax4_ins_Mcompar_mux_b1_2_cmp_gt0000_lut(0)
    );
  fax4_ins_Mcompar_mux_b1_1_cmp_gt0000_cy_9_Q : MUXCY
    port map (
      CI => fax4_ins_Mcompar_mux_b1_1_cmp_gt0000_cy(8),
      DI => fax4_ins_a0(9),
      S => fax4_ins_Mcompar_mux_b1_1_cmp_gt0000_lut(9),
      O => fax4_ins_Mcompar_mux_b1_1_cmp_gt0000_cy(9)
    );
  fax4_ins_Mcompar_mux_b1_1_cmp_gt0000_lut_9_Q : LUT2
    generic map(
      INIT => X"9"
    )
    port map (
      I0 => fax4_ins_fifo_out_prev1_x(9),
      I1 => fax4_ins_a0(9),
      O => fax4_ins_Mcompar_mux_b1_1_cmp_gt0000_lut(9)
    );
  fax4_ins_Mcompar_mux_b1_1_cmp_gt0000_cy_8_Q : MUXCY
    port map (
      CI => fax4_ins_Mcompar_mux_b1_1_cmp_gt0000_cy(7),
      DI => fax4_ins_a0(8),
      S => fax4_ins_Mcompar_mux_b1_1_cmp_gt0000_lut(8),
      O => fax4_ins_Mcompar_mux_b1_1_cmp_gt0000_cy(8)
    );
  fax4_ins_Mcompar_mux_b1_1_cmp_gt0000_lut_8_Q : LUT2
    generic map(
      INIT => X"9"
    )
    port map (
      I0 => fax4_ins_fifo_out_prev1_x(8),
      I1 => fax4_ins_a0(8),
      O => fax4_ins_Mcompar_mux_b1_1_cmp_gt0000_lut(8)
    );
  fax4_ins_Mcompar_mux_b1_1_cmp_gt0000_cy_7_Q : MUXCY
    port map (
      CI => fax4_ins_Mcompar_mux_b1_1_cmp_gt0000_cy(6),
      DI => fax4_ins_a0(7),
      S => fax4_ins_Mcompar_mux_b1_1_cmp_gt0000_lut(7),
      O => fax4_ins_Mcompar_mux_b1_1_cmp_gt0000_cy(7)
    );
  fax4_ins_Mcompar_mux_b1_1_cmp_gt0000_lut_7_Q : LUT2
    generic map(
      INIT => X"9"
    )
    port map (
      I0 => fax4_ins_fifo_out_prev1_x(7),
      I1 => fax4_ins_a0(7),
      O => fax4_ins_Mcompar_mux_b1_1_cmp_gt0000_lut(7)
    );
  fax4_ins_Mcompar_mux_b1_1_cmp_gt0000_cy_6_Q : MUXCY
    port map (
      CI => fax4_ins_Mcompar_mux_b1_1_cmp_gt0000_cy(5),
      DI => fax4_ins_a0(6),
      S => fax4_ins_Mcompar_mux_b1_1_cmp_gt0000_lut(6),
      O => fax4_ins_Mcompar_mux_b1_1_cmp_gt0000_cy(6)
    );
  fax4_ins_Mcompar_mux_b1_1_cmp_gt0000_lut_6_Q : LUT2
    generic map(
      INIT => X"9"
    )
    port map (
      I0 => fax4_ins_fifo_out_prev1_x(6),
      I1 => fax4_ins_a0(6),
      O => fax4_ins_Mcompar_mux_b1_1_cmp_gt0000_lut(6)
    );
  fax4_ins_Mcompar_mux_b1_1_cmp_gt0000_cy_5_Q : MUXCY
    port map (
      CI => fax4_ins_Mcompar_mux_b1_1_cmp_gt0000_cy(4),
      DI => fax4_ins_a0(5),
      S => fax4_ins_Mcompar_mux_b1_1_cmp_gt0000_lut(5),
      O => fax4_ins_Mcompar_mux_b1_1_cmp_gt0000_cy(5)
    );
  fax4_ins_Mcompar_mux_b1_1_cmp_gt0000_lut_5_Q : LUT2
    generic map(
      INIT => X"9"
    )
    port map (
      I0 => fax4_ins_fifo_out_prev1_x(5),
      I1 => fax4_ins_a0(5),
      O => fax4_ins_Mcompar_mux_b1_1_cmp_gt0000_lut(5)
    );
  fax4_ins_Mcompar_mux_b1_1_cmp_gt0000_cy_4_Q : MUXCY
    port map (
      CI => fax4_ins_Mcompar_mux_b1_1_cmp_gt0000_cy(3),
      DI => fax4_ins_a0(4),
      S => fax4_ins_Mcompar_mux_b1_1_cmp_gt0000_lut(4),
      O => fax4_ins_Mcompar_mux_b1_1_cmp_gt0000_cy(4)
    );
  fax4_ins_Mcompar_mux_b1_1_cmp_gt0000_lut_4_Q : LUT2
    generic map(
      INIT => X"9"
    )
    port map (
      I0 => fax4_ins_fifo_out_prev1_x(4),
      I1 => fax4_ins_a0(4),
      O => fax4_ins_Mcompar_mux_b1_1_cmp_gt0000_lut(4)
    );
  fax4_ins_Mcompar_mux_b1_1_cmp_gt0000_cy_3_Q : MUXCY
    port map (
      CI => fax4_ins_Mcompar_mux_b1_1_cmp_gt0000_cy(2),
      DI => fax4_ins_a0(3),
      S => fax4_ins_Mcompar_mux_b1_1_cmp_gt0000_lut(3),
      O => fax4_ins_Mcompar_mux_b1_1_cmp_gt0000_cy(3)
    );
  fax4_ins_Mcompar_mux_b1_1_cmp_gt0000_lut_3_Q : LUT2
    generic map(
      INIT => X"9"
    )
    port map (
      I0 => fax4_ins_fifo_out_prev1_x(3),
      I1 => fax4_ins_a0(3),
      O => fax4_ins_Mcompar_mux_b1_1_cmp_gt0000_lut(3)
    );
  fax4_ins_Mcompar_mux_b1_1_cmp_gt0000_cy_2_Q : MUXCY
    port map (
      CI => fax4_ins_Mcompar_mux_b1_1_cmp_gt0000_cy(1),
      DI => fax4_ins_a0(2),
      S => fax4_ins_Mcompar_mux_b1_1_cmp_gt0000_lut(2),
      O => fax4_ins_Mcompar_mux_b1_1_cmp_gt0000_cy(2)
    );
  fax4_ins_Mcompar_mux_b1_1_cmp_gt0000_lut_2_Q : LUT2
    generic map(
      INIT => X"9"
    )
    port map (
      I0 => fax4_ins_fifo_out_prev1_x(2),
      I1 => fax4_ins_a0(2),
      O => fax4_ins_Mcompar_mux_b1_1_cmp_gt0000_lut(2)
    );
  fax4_ins_Mcompar_mux_b1_1_cmp_gt0000_cy_1_Q : MUXCY
    port map (
      CI => fax4_ins_Mcompar_mux_b1_1_cmp_gt0000_cy(0),
      DI => fax4_ins_a0(1),
      S => fax4_ins_Mcompar_mux_b1_1_cmp_gt0000_lut(1),
      O => fax4_ins_Mcompar_mux_b1_1_cmp_gt0000_cy(1)
    );
  fax4_ins_Mcompar_mux_b1_1_cmp_gt0000_lut_1_Q : LUT2
    generic map(
      INIT => X"9"
    )
    port map (
      I0 => fax4_ins_fifo_out_prev1_x(1),
      I1 => fax4_ins_a0(1),
      O => fax4_ins_Mcompar_mux_b1_1_cmp_gt0000_lut(1)
    );
  fax4_ins_Mcompar_mux_b1_1_cmp_gt0000_cy_0_Q : MUXCY
    port map (
      CI => N1,
      DI => fax4_ins_a0(0),
      S => fax4_ins_Mcompar_mux_b1_1_cmp_gt0000_lut(0),
      O => fax4_ins_Mcompar_mux_b1_1_cmp_gt0000_cy(0)
    );
  fax4_ins_Mcompar_mux_b1_1_cmp_gt0000_lut_0_Q : LUT2
    generic map(
      INIT => X"9"
    )
    port map (
      I0 => fax4_ins_fifo_out_prev1_x(0),
      I1 => fax4_ins_a0(0),
      O => fax4_ins_Mcompar_mux_b1_1_cmp_gt0000_lut(0)
    );
  fax4_ins_Mcompar_mux_b1_0_cmp_gt0000_cy_9_Q : MUXCY
    port map (
      CI => fax4_ins_Mcompar_mux_b1_0_cmp_gt0000_cy(8),
      DI => fax4_ins_a0(9),
      S => fax4_ins_Mcompar_mux_b1_0_cmp_gt0000_lut(9),
      O => fax4_ins_Mcompar_mux_b1_0_cmp_gt0000_cy(9)
    );
  fax4_ins_Mcompar_mux_b1_0_cmp_gt0000_lut_9_Q : LUT2
    generic map(
      INIT => X"9"
    )
    port map (
      I0 => fax4_ins_fifo_out_prev2_x(9),
      I1 => fax4_ins_a0(9),
      O => fax4_ins_Mcompar_mux_b1_0_cmp_gt0000_lut(9)
    );
  fax4_ins_Mcompar_mux_b1_0_cmp_gt0000_cy_8_Q : MUXCY
    port map (
      CI => fax4_ins_Mcompar_mux_b1_0_cmp_gt0000_cy(7),
      DI => fax4_ins_a0(8),
      S => fax4_ins_Mcompar_mux_b1_0_cmp_gt0000_lut(8),
      O => fax4_ins_Mcompar_mux_b1_0_cmp_gt0000_cy(8)
    );
  fax4_ins_Mcompar_mux_b1_0_cmp_gt0000_lut_8_Q : LUT2
    generic map(
      INIT => X"9"
    )
    port map (
      I0 => fax4_ins_fifo_out_prev2_x(8),
      I1 => fax4_ins_a0(8),
      O => fax4_ins_Mcompar_mux_b1_0_cmp_gt0000_lut(8)
    );
  fax4_ins_Mcompar_mux_b1_0_cmp_gt0000_cy_7_Q : MUXCY
    port map (
      CI => fax4_ins_Mcompar_mux_b1_0_cmp_gt0000_cy(6),
      DI => fax4_ins_a0(7),
      S => fax4_ins_Mcompar_mux_b1_0_cmp_gt0000_lut(7),
      O => fax4_ins_Mcompar_mux_b1_0_cmp_gt0000_cy(7)
    );
  fax4_ins_Mcompar_mux_b1_0_cmp_gt0000_lut_7_Q : LUT2
    generic map(
      INIT => X"9"
    )
    port map (
      I0 => fax4_ins_fifo_out_prev2_x(7),
      I1 => fax4_ins_a0(7),
      O => fax4_ins_Mcompar_mux_b1_0_cmp_gt0000_lut(7)
    );
  fax4_ins_Mcompar_mux_b1_0_cmp_gt0000_cy_6_Q : MUXCY
    port map (
      CI => fax4_ins_Mcompar_mux_b1_0_cmp_gt0000_cy(5),
      DI => fax4_ins_a0(6),
      S => fax4_ins_Mcompar_mux_b1_0_cmp_gt0000_lut(6),
      O => fax4_ins_Mcompar_mux_b1_0_cmp_gt0000_cy(6)
    );
  fax4_ins_Mcompar_mux_b1_0_cmp_gt0000_lut_6_Q : LUT2
    generic map(
      INIT => X"9"
    )
    port map (
      I0 => fax4_ins_fifo_out_prev2_x(6),
      I1 => fax4_ins_a0(6),
      O => fax4_ins_Mcompar_mux_b1_0_cmp_gt0000_lut(6)
    );
  fax4_ins_Mcompar_mux_b1_0_cmp_gt0000_cy_5_Q : MUXCY
    port map (
      CI => fax4_ins_Mcompar_mux_b1_0_cmp_gt0000_cy(4),
      DI => fax4_ins_a0(5),
      S => fax4_ins_Mcompar_mux_b1_0_cmp_gt0000_lut(5),
      O => fax4_ins_Mcompar_mux_b1_0_cmp_gt0000_cy(5)
    );
  fax4_ins_Mcompar_mux_b1_0_cmp_gt0000_lut_5_Q : LUT2
    generic map(
      INIT => X"9"
    )
    port map (
      I0 => fax4_ins_fifo_out_prev2_x(5),
      I1 => fax4_ins_a0(5),
      O => fax4_ins_Mcompar_mux_b1_0_cmp_gt0000_lut(5)
    );
  fax4_ins_Mcompar_mux_b1_0_cmp_gt0000_cy_4_Q : MUXCY
    port map (
      CI => fax4_ins_Mcompar_mux_b1_0_cmp_gt0000_cy(3),
      DI => fax4_ins_a0(4),
      S => fax4_ins_Mcompar_mux_b1_0_cmp_gt0000_lut(4),
      O => fax4_ins_Mcompar_mux_b1_0_cmp_gt0000_cy(4)
    );
  fax4_ins_Mcompar_mux_b1_0_cmp_gt0000_lut_4_Q : LUT2
    generic map(
      INIT => X"9"
    )
    port map (
      I0 => fax4_ins_fifo_out_prev2_x(4),
      I1 => fax4_ins_a0(4),
      O => fax4_ins_Mcompar_mux_b1_0_cmp_gt0000_lut(4)
    );
  fax4_ins_Mcompar_mux_b1_0_cmp_gt0000_cy_3_Q : MUXCY
    port map (
      CI => fax4_ins_Mcompar_mux_b1_0_cmp_gt0000_cy(2),
      DI => fax4_ins_a0(3),
      S => fax4_ins_Mcompar_mux_b1_0_cmp_gt0000_lut(3),
      O => fax4_ins_Mcompar_mux_b1_0_cmp_gt0000_cy(3)
    );
  fax4_ins_Mcompar_mux_b1_0_cmp_gt0000_lut_3_Q : LUT2
    generic map(
      INIT => X"9"
    )
    port map (
      I0 => fax4_ins_fifo_out_prev2_x(3),
      I1 => fax4_ins_a0(3),
      O => fax4_ins_Mcompar_mux_b1_0_cmp_gt0000_lut(3)
    );
  fax4_ins_Mcompar_mux_b1_0_cmp_gt0000_cy_2_Q : MUXCY
    port map (
      CI => fax4_ins_Mcompar_mux_b1_0_cmp_gt0000_cy(1),
      DI => fax4_ins_a0(2),
      S => fax4_ins_Mcompar_mux_b1_0_cmp_gt0000_lut(2),
      O => fax4_ins_Mcompar_mux_b1_0_cmp_gt0000_cy(2)
    );
  fax4_ins_Mcompar_mux_b1_0_cmp_gt0000_lut_2_Q : LUT2
    generic map(
      INIT => X"9"
    )
    port map (
      I0 => fax4_ins_fifo_out_prev2_x(2),
      I1 => fax4_ins_a0(2),
      O => fax4_ins_Mcompar_mux_b1_0_cmp_gt0000_lut(2)
    );
  fax4_ins_Mcompar_mux_b1_0_cmp_gt0000_cy_1_Q : MUXCY
    port map (
      CI => fax4_ins_Mcompar_mux_b1_0_cmp_gt0000_cy(0),
      DI => fax4_ins_a0(1),
      S => fax4_ins_Mcompar_mux_b1_0_cmp_gt0000_lut(1),
      O => fax4_ins_Mcompar_mux_b1_0_cmp_gt0000_cy(1)
    );
  fax4_ins_Mcompar_mux_b1_0_cmp_gt0000_lut_1_Q : LUT2
    generic map(
      INIT => X"9"
    )
    port map (
      I0 => fax4_ins_fifo_out_prev2_x(1),
      I1 => fax4_ins_a0(1),
      O => fax4_ins_Mcompar_mux_b1_0_cmp_gt0000_lut(1)
    );
  fax4_ins_Mcompar_mux_b1_0_cmp_gt0000_cy_0_Q : MUXCY
    port map (
      CI => N1,
      DI => fax4_ins_a0(0),
      S => fax4_ins_Mcompar_mux_b1_0_cmp_gt0000_lut(0),
      O => fax4_ins_Mcompar_mux_b1_0_cmp_gt0000_cy(0)
    );
  fax4_ins_Mcompar_mux_b1_0_cmp_gt0000_lut_0_Q : LUT2
    generic map(
      INIT => X"9"
    )
    port map (
      I0 => fax4_ins_fifo_out_prev2_x(0),
      I1 => fax4_ins_a0(0),
      O => fax4_ins_Mcompar_mux_b1_0_cmp_gt0000_lut(0)
    );
  fax4_ins_Madd_a1b1_addsub0001_xor_10_Q : XORCY
    port map (
      CI => fax4_ins_Madd_a1b1_addsub0001_cy(9),
      LI => N1,
      O => fax4_ins_a1b1_addsub0001(10)
    );
  fax4_ins_Madd_a1b1_addsub0001_xor_9_Q : XORCY
    port map (
      CI => fax4_ins_Madd_a1b1_addsub0001_cy(8),
      LI => fax4_ins_Madd_a1b1_addsub0001_cy_9_rt_730,
      O => fax4_ins_a1b1_addsub0001(9)
    );
  fax4_ins_Madd_a1b1_addsub0001_cy_9_Q : MUXCY
    port map (
      CI => fax4_ins_Madd_a1b1_addsub0001_cy(8),
      DI => N1,
      S => fax4_ins_Madd_a1b1_addsub0001_cy_9_rt_730,
      O => fax4_ins_Madd_a1b1_addsub0001_cy(9)
    );
  fax4_ins_Madd_a1b1_addsub0001_xor_8_Q : XORCY
    port map (
      CI => fax4_ins_Madd_a1b1_addsub0001_cy(7),
      LI => fax4_ins_a1b1_not0000_8_Q,
      O => fax4_ins_a1b1_addsub0001(8)
    );
  fax4_ins_Madd_a1b1_addsub0001_cy_8_Q : MUXCY
    port map (
      CI => fax4_ins_Madd_a1b1_addsub0001_cy(7),
      DI => NlwRenamedSig_OI_run_len_code_o(26),
      S => fax4_ins_a1b1_not0000_8_Q,
      O => fax4_ins_Madd_a1b1_addsub0001_cy(8)
    );
  fax4_ins_Madd_a1b1_addsub0001_xor_7_Q : XORCY
    port map (
      CI => fax4_ins_Madd_a1b1_addsub0001_cy(6),
      LI => fax4_ins_Madd_a1b1_addsub0001_cy_7_rt_727,
      O => fax4_ins_a1b1_addsub0001(7)
    );
  fax4_ins_Madd_a1b1_addsub0001_cy_7_Q : MUXCY
    port map (
      CI => fax4_ins_Madd_a1b1_addsub0001_cy(6),
      DI => N1,
      S => fax4_ins_Madd_a1b1_addsub0001_cy_7_rt_727,
      O => fax4_ins_Madd_a1b1_addsub0001_cy(7)
    );
  fax4_ins_Madd_a1b1_addsub0001_xor_6_Q : XORCY
    port map (
      CI => fax4_ins_Madd_a1b1_addsub0001_cy(5),
      LI => fax4_ins_Madd_a1b1_addsub0001_cy_6_rt_725,
      O => fax4_ins_a1b1_addsub0001(6)
    );
  fax4_ins_Madd_a1b1_addsub0001_cy_6_Q : MUXCY
    port map (
      CI => fax4_ins_Madd_a1b1_addsub0001_cy(5),
      DI => N1,
      S => fax4_ins_Madd_a1b1_addsub0001_cy_6_rt_725,
      O => fax4_ins_Madd_a1b1_addsub0001_cy(6)
    );
  fax4_ins_Madd_a1b1_addsub0001_xor_5_Q : XORCY
    port map (
      CI => fax4_ins_Madd_a1b1_addsub0001_cy(4),
      LI => fax4_ins_Madd_a1b1_addsub0001_cy_5_rt_723,
      O => fax4_ins_a1b1_addsub0001(5)
    );
  fax4_ins_Madd_a1b1_addsub0001_cy_5_Q : MUXCY
    port map (
      CI => fax4_ins_Madd_a1b1_addsub0001_cy(4),
      DI => N1,
      S => fax4_ins_Madd_a1b1_addsub0001_cy_5_rt_723,
      O => fax4_ins_Madd_a1b1_addsub0001_cy(5)
    );
  fax4_ins_Madd_a1b1_addsub0001_xor_4_Q : XORCY
    port map (
      CI => fax4_ins_Madd_a1b1_addsub0001_cy(3),
      LI => fax4_ins_Madd_a1b1_addsub0001_cy_4_rt_721,
      O => fax4_ins_a1b1_addsub0001(4)
    );
  fax4_ins_Madd_a1b1_addsub0001_cy_4_Q : MUXCY
    port map (
      CI => fax4_ins_Madd_a1b1_addsub0001_cy(3),
      DI => N1,
      S => fax4_ins_Madd_a1b1_addsub0001_cy_4_rt_721,
      O => fax4_ins_Madd_a1b1_addsub0001_cy(4)
    );
  fax4_ins_Madd_a1b1_addsub0001_xor_3_Q : XORCY
    port map (
      CI => fax4_ins_Madd_a1b1_addsub0001_cy(2),
      LI => fax4_ins_a1b1_not0000_3_Q,
      O => fax4_ins_a1b1_addsub0001(3)
    );
  fax4_ins_Madd_a1b1_addsub0001_cy_3_Q : MUXCY
    port map (
      CI => fax4_ins_Madd_a1b1_addsub0001_cy(2),
      DI => NlwRenamedSig_OI_run_len_code_o(26),
      S => fax4_ins_a1b1_not0000_3_Q,
      O => fax4_ins_Madd_a1b1_addsub0001_cy(3)
    );
  fax4_ins_Madd_a1b1_addsub0001_xor_2_Q : XORCY
    port map (
      CI => fax4_ins_Madd_a1b1_addsub0001_cy(1),
      LI => fax4_ins_a1b1_not0000_2_Q,
      O => fax4_ins_a1b1_addsub0001(2)
    );
  fax4_ins_Madd_a1b1_addsub0001_cy_2_Q : MUXCY
    port map (
      CI => fax4_ins_Madd_a1b1_addsub0001_cy(1),
      DI => NlwRenamedSig_OI_run_len_code_o(26),
      S => fax4_ins_a1b1_not0000_2_Q,
      O => fax4_ins_Madd_a1b1_addsub0001_cy(2)
    );
  fax4_ins_Madd_a1b1_addsub0001_xor_1_Q : XORCY
    port map (
      CI => NlwRenamedSig_OI_run_len_code_o(26),
      LI => fax4_ins_Madd_a1b1_addsub0001_cy_1_rt_717,
      O => fax4_ins_a1b1_addsub0001(1)
    );
  fax4_ins_Madd_a1b1_addsub0001_cy_1_Q : MUXCY
    port map (
      CI => NlwRenamedSig_OI_run_len_code_o(26),
      DI => N1,
      S => fax4_ins_Madd_a1b1_addsub0001_cy_1_rt_717,
      O => fax4_ins_Madd_a1b1_addsub0001_cy(1)
    );
  fax4_ins_Madd_vertical_mode_addsub0000_xor_10_Q : XORCY
    port map (
      CI => fax4_ins_Madd_vertical_mode_addsub0000_cy(9),
      LI => fax4_ins_Madd_vertical_mode_not0000(10),
      O => fax4_ins_vertical_mode_addsub0000(10)
    );
  fax4_ins_Madd_vertical_mode_addsub0000_xor_9_Q : XORCY
    port map (
      CI => fax4_ins_Madd_vertical_mode_addsub0000_cy(8),
      LI => fax4_ins_Madd_vertical_mode_not0000(9),
      O => fax4_ins_vertical_mode_addsub0000(9)
    );
  fax4_ins_Madd_vertical_mode_addsub0000_cy_9_Q : MUXCY
    port map (
      CI => fax4_ins_Madd_vertical_mode_addsub0000_cy(8),
      DI => NlwRenamedSig_OI_run_len_code_o(26),
      S => fax4_ins_Madd_vertical_mode_not0000(9),
      O => fax4_ins_Madd_vertical_mode_addsub0000_cy(9)
    );
  fax4_ins_Madd_vertical_mode_addsub0000_xor_8_Q : XORCY
    port map (
      CI => fax4_ins_Madd_vertical_mode_addsub0000_cy(7),
      LI => fax4_ins_Madd_vertical_mode_not0000(8),
      O => fax4_ins_vertical_mode_addsub0000(8)
    );
  fax4_ins_Madd_vertical_mode_addsub0000_cy_8_Q : MUXCY
    port map (
      CI => fax4_ins_Madd_vertical_mode_addsub0000_cy(7),
      DI => NlwRenamedSig_OI_run_len_code_o(26),
      S => fax4_ins_Madd_vertical_mode_not0000(8),
      O => fax4_ins_Madd_vertical_mode_addsub0000_cy(8)
    );
  fax4_ins_Madd_vertical_mode_addsub0000_xor_7_Q : XORCY
    port map (
      CI => fax4_ins_Madd_vertical_mode_addsub0000_cy(6),
      LI => fax4_ins_Madd_vertical_mode_not0000(7),
      O => fax4_ins_vertical_mode_addsub0000(7)
    );
  fax4_ins_Madd_vertical_mode_addsub0000_cy_7_Q : MUXCY
    port map (
      CI => fax4_ins_Madd_vertical_mode_addsub0000_cy(6),
      DI => NlwRenamedSig_OI_run_len_code_o(26),
      S => fax4_ins_Madd_vertical_mode_not0000(7),
      O => fax4_ins_Madd_vertical_mode_addsub0000_cy(7)
    );
  fax4_ins_Madd_vertical_mode_addsub0000_xor_6_Q : XORCY
    port map (
      CI => fax4_ins_Madd_vertical_mode_addsub0000_cy(5),
      LI => fax4_ins_Madd_vertical_mode_not0000(6),
      O => fax4_ins_vertical_mode_addsub0000(6)
    );
  fax4_ins_Madd_vertical_mode_addsub0000_cy_6_Q : MUXCY
    port map (
      CI => fax4_ins_Madd_vertical_mode_addsub0000_cy(5),
      DI => NlwRenamedSig_OI_run_len_code_o(26),
      S => fax4_ins_Madd_vertical_mode_not0000(6),
      O => fax4_ins_Madd_vertical_mode_addsub0000_cy(6)
    );
  fax4_ins_Madd_vertical_mode_addsub0000_xor_5_Q : XORCY
    port map (
      CI => fax4_ins_Madd_vertical_mode_addsub0000_cy(4),
      LI => fax4_ins_Madd_vertical_mode_not0000(5),
      O => fax4_ins_vertical_mode_addsub0000(5)
    );
  fax4_ins_Madd_vertical_mode_addsub0000_cy_5_Q : MUXCY
    port map (
      CI => fax4_ins_Madd_vertical_mode_addsub0000_cy(4),
      DI => NlwRenamedSig_OI_run_len_code_o(26),
      S => fax4_ins_Madd_vertical_mode_not0000(5),
      O => fax4_ins_Madd_vertical_mode_addsub0000_cy(5)
    );
  fax4_ins_Madd_vertical_mode_addsub0000_xor_4_Q : XORCY
    port map (
      CI => fax4_ins_Madd_vertical_mode_addsub0000_cy(3),
      LI => fax4_ins_Madd_vertical_mode_not0000(4),
      O => fax4_ins_vertical_mode_addsub0000(4)
    );
  fax4_ins_Madd_vertical_mode_addsub0000_cy_4_Q : MUXCY
    port map (
      CI => fax4_ins_Madd_vertical_mode_addsub0000_cy(3),
      DI => NlwRenamedSig_OI_run_len_code_o(26),
      S => fax4_ins_Madd_vertical_mode_not0000(4),
      O => fax4_ins_Madd_vertical_mode_addsub0000_cy(4)
    );
  fax4_ins_Madd_vertical_mode_addsub0000_xor_3_Q : XORCY
    port map (
      CI => fax4_ins_Madd_vertical_mode_addsub0000_cy(2),
      LI => fax4_ins_Madd_vertical_mode_not0000(3),
      O => fax4_ins_vertical_mode_addsub0000(3)
    );
  fax4_ins_Madd_vertical_mode_addsub0000_cy_3_Q : MUXCY
    port map (
      CI => fax4_ins_Madd_vertical_mode_addsub0000_cy(2),
      DI => NlwRenamedSig_OI_run_len_code_o(26),
      S => fax4_ins_Madd_vertical_mode_not0000(3),
      O => fax4_ins_Madd_vertical_mode_addsub0000_cy(3)
    );
  fax4_ins_Madd_vertical_mode_addsub0000_xor_2_Q : XORCY
    port map (
      CI => fax4_ins_Madd_vertical_mode_addsub0000_cy(1),
      LI => fax4_ins_Madd_vertical_mode_not0000(2),
      O => fax4_ins_vertical_mode_addsub0000(2)
    );
  fax4_ins_Madd_vertical_mode_addsub0000_cy_2_Q : MUXCY
    port map (
      CI => fax4_ins_Madd_vertical_mode_addsub0000_cy(1),
      DI => NlwRenamedSig_OI_run_len_code_o(26),
      S => fax4_ins_Madd_vertical_mode_not0000(2),
      O => fax4_ins_Madd_vertical_mode_addsub0000_cy(2)
    );
  fax4_ins_Madd_vertical_mode_addsub0000_cy_1_Q : MUXCY
    port map (
      CI => fax4_ins_Madd_vertical_mode_addsub0000_cy(0),
      DI => NlwRenamedSig_OI_run_len_code_o(26),
      S => fax4_ins_Madd_vertical_mode_not0000(1),
      O => fax4_ins_Madd_vertical_mode_addsub0000_cy(1)
    );
  fax4_ins_Madd_vertical_mode_addsub0000_cy_0_Q : MUXCY
    port map (
      CI => NlwRenamedSig_OI_run_len_code_o(26),
      DI => N1,
      S => fax4_ins_a1b1(0),
      O => fax4_ins_Madd_vertical_mode_addsub0000_cy(0)
    );
  fax4_ins_pix_prev : FDP
    generic map(
      INIT => '1'
    )
    port map (
      C => pclk_i,
      D => fax4_ins_to_white_mux0000,
      PRE => fax4_ins_pix_change_detector_reset,
      Q => fax4_ins_pix_prev_1321
    );
  fax4_ins_to_white : FDE
    generic map(
      INIT => '1'
    )
    port map (
      C => pclk_i,
      CE => fax4_ins_pix_change_detector_reset_inv,
      D => fax4_ins_to_white_mux0000,
      Q => fax4_ins_to_white_1349
    );
  fax4_ins_EOL_prev_prev : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      D => fax4_ins_EOL_prev_230,
      Q => fax4_ins_EOL_prev_prev_231
    );
  fax4_ins_fifo_out_prev2_x_9 : FDE_1
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      CE => fax4_ins_fifo_rd,
      D => fax4_ins_fifo_out_prev1_x(9),
      Q => fax4_ins_fifo_out_prev2_x(9)
    );
  fax4_ins_fifo_out_prev2_x_8 : FDE_1
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      CE => fax4_ins_fifo_rd,
      D => fax4_ins_fifo_out_prev1_x(8),
      Q => fax4_ins_fifo_out_prev2_x(8)
    );
  fax4_ins_fifo_out_prev2_x_7 : FDE_1
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      CE => fax4_ins_fifo_rd,
      D => fax4_ins_fifo_out_prev1_x(7),
      Q => fax4_ins_fifo_out_prev2_x(7)
    );
  fax4_ins_fifo_out_prev2_x_6 : FDE_1
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      CE => fax4_ins_fifo_rd,
      D => fax4_ins_fifo_out_prev1_x(6),
      Q => fax4_ins_fifo_out_prev2_x(6)
    );
  fax4_ins_fifo_out_prev2_x_5 : FDE_1
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      CE => fax4_ins_fifo_rd,
      D => fax4_ins_fifo_out_prev1_x(5),
      Q => fax4_ins_fifo_out_prev2_x(5)
    );
  fax4_ins_fifo_out_prev2_x_4 : FDE_1
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      CE => fax4_ins_fifo_rd,
      D => fax4_ins_fifo_out_prev1_x(4),
      Q => fax4_ins_fifo_out_prev2_x(4)
    );
  fax4_ins_fifo_out_prev2_x_3 : FDE_1
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      CE => fax4_ins_fifo_rd,
      D => fax4_ins_fifo_out_prev1_x(3),
      Q => fax4_ins_fifo_out_prev2_x(3)
    );
  fax4_ins_fifo_out_prev2_x_2 : FDE_1
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      CE => fax4_ins_fifo_rd,
      D => fax4_ins_fifo_out_prev1_x(2),
      Q => fax4_ins_fifo_out_prev2_x(2)
    );
  fax4_ins_fifo_out_prev2_x_1 : FDE_1
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      CE => fax4_ins_fifo_rd,
      D => fax4_ins_fifo_out_prev1_x(1),
      Q => fax4_ins_fifo_out_prev2_x(1)
    );
  fax4_ins_fifo_out_prev2_x_0 : FDE_1
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      CE => fax4_ins_fifo_rd,
      D => fax4_ins_fifo_out_prev1_x(0),
      Q => fax4_ins_fifo_out_prev2_x(0)
    );
  fax4_ins_fifo_out_prev2_to_white : FDE_1
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      CE => fax4_ins_fifo_rd,
      D => fax4_ins_fifo_out_prev1_to_white_1239,
      Q => fax4_ins_fifo_out_prev2_to_white_1252
    );
  fax4_ins_fifo_sel_prev : FDE_1
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      CE => fax4_ins_fifo_rd,
      D => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt(0),
      Q => fax4_ins_fifo_sel_prev_1279
    );
  fax4_ins_a0_value_o : FDE_1
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      CE => fax4_ins_load_a0,
      D => fax4_ins_a0_to_white_946,
      Q => fax4_ins_a0_value_o_950
    );
  fax4_ins_EOL_prev : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      D => fax4_ins_EOL,
      Q => fax4_ins_EOL_prev_230
    );
  fax4_ins_a0_o_9 : FDE_1
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      CE => fax4_ins_load_a0,
      D => fax4_ins_a0(9),
      Q => fax4_ins_a0_o(9)
    );
  fax4_ins_a0_o_8 : FDE_1
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      CE => fax4_ins_load_a0,
      D => fax4_ins_a0(8),
      Q => fax4_ins_a0_o(8)
    );
  fax4_ins_a0_o_7 : FDE_1
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      CE => fax4_ins_load_a0,
      D => fax4_ins_a0(7),
      Q => fax4_ins_a0_o(7)
    );
  fax4_ins_a0_o_6 : FDE_1
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      CE => fax4_ins_load_a0,
      D => fax4_ins_a0(6),
      Q => fax4_ins_a0_o(6)
    );
  fax4_ins_a0_o_5 : FDE_1
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      CE => fax4_ins_load_a0,
      D => fax4_ins_a0(5),
      Q => fax4_ins_a0_o(5)
    );
  fax4_ins_a0_o_4 : FDE_1
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      CE => fax4_ins_load_a0,
      D => fax4_ins_a0(4),
      Q => fax4_ins_a0_o(4)
    );
  fax4_ins_a0_o_3 : FDE_1
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      CE => fax4_ins_load_a0,
      D => fax4_ins_a0(3),
      Q => fax4_ins_a0_o(3)
    );
  fax4_ins_a0_o_2 : FDE_1
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      CE => fax4_ins_load_a0,
      D => fax4_ins_a0(2),
      Q => fax4_ins_a0_o(2)
    );
  fax4_ins_a0_o_1 : FDE_1
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      CE => fax4_ins_load_a0,
      D => fax4_ins_a0(1),
      Q => fax4_ins_a0_o(1)
    );
  fax4_ins_a0_o_0 : FDE_1
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      CE => fax4_ins_load_a0,
      D => fax4_ins_a0(0),
      Q => fax4_ins_a0_o(0)
    );
  fax4_ins_fifo_out_prev1_valid : FDE_1
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      CE => fax4_ins_fifo_rd,
      D => fax4_ins_fifo_out_prev1_valid_mux0001,
      Q => fax4_ins_fifo_out_prev1_valid_1240
    );
  fax4_ins_fifo_out_prev2_valid : FDE_1
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      CE => fax4_ins_fifo_rd,
      D => fax4_ins_fifo_out_prev2_valid_mux0001,
      Q => fax4_ins_fifo_out_prev2_valid_1253
    );
  fax4_ins_fifo_out_prev1_x_9 : FDE_1
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      CE => fax4_ins_fifo_rd,
      D => fax4_ins_fifo_out1_x(9),
      Q => fax4_ins_fifo_out_prev1_x(9)
    );
  fax4_ins_fifo_out_prev1_x_8 : FDE_1
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      CE => fax4_ins_fifo_rd,
      D => fax4_ins_fifo_out1_x(8),
      Q => fax4_ins_fifo_out_prev1_x(8)
    );
  fax4_ins_fifo_out_prev1_x_7 : FDE_1
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      CE => fax4_ins_fifo_rd,
      D => fax4_ins_fifo_out1_x(7),
      Q => fax4_ins_fifo_out_prev1_x(7)
    );
  fax4_ins_fifo_out_prev1_x_6 : FDE_1
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      CE => fax4_ins_fifo_rd,
      D => fax4_ins_fifo_out1_x(6),
      Q => fax4_ins_fifo_out_prev1_x(6)
    );
  fax4_ins_fifo_out_prev1_x_5 : FDE_1
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      CE => fax4_ins_fifo_rd,
      D => fax4_ins_fifo_out1_x(5),
      Q => fax4_ins_fifo_out_prev1_x(5)
    );
  fax4_ins_fifo_out_prev1_x_4 : FDE_1
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      CE => fax4_ins_fifo_rd,
      D => fax4_ins_fifo_out1_x(4),
      Q => fax4_ins_fifo_out_prev1_x(4)
    );
  fax4_ins_fifo_out_prev1_x_3 : FDE_1
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      CE => fax4_ins_fifo_rd,
      D => fax4_ins_fifo_out1_x(3),
      Q => fax4_ins_fifo_out_prev1_x(3)
    );
  fax4_ins_fifo_out_prev1_x_2 : FDE_1
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      CE => fax4_ins_fifo_rd,
      D => fax4_ins_fifo_out1_x(2),
      Q => fax4_ins_fifo_out_prev1_x(2)
    );
  fax4_ins_fifo_out_prev1_x_1 : FDE_1
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      CE => fax4_ins_fifo_rd,
      D => fax4_ins_fifo_out1_x(1),
      Q => fax4_ins_fifo_out_prev1_x(1)
    );
  fax4_ins_fifo_out_prev1_x_0 : FDE_1
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      CE => fax4_ins_fifo_rd,
      D => fax4_ins_fifo_out1_x(0),
      Q => fax4_ins_fifo_out_prev1_x(0)
    );
  fax4_ins_b2_9 : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      CE => fax4_ins_load_mux_b_1285,
      D => fax4_ins_b2_mux0004(9),
      Q => fax4_ins_b2(9)
    );
  fax4_ins_b2_8 : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      CE => fax4_ins_load_mux_b_1285,
      D => fax4_ins_b2_mux0004(8),
      Q => fax4_ins_b2(8)
    );
  fax4_ins_b2_7 : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      CE => fax4_ins_load_mux_b_1285,
      D => fax4_ins_b2_mux0004(7),
      Q => fax4_ins_b2(7)
    );
  fax4_ins_b2_6 : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      CE => fax4_ins_load_mux_b_1285,
      D => fax4_ins_b2_mux0004(6),
      Q => fax4_ins_b2(6)
    );
  fax4_ins_b2_5 : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      CE => fax4_ins_load_mux_b_1285,
      D => fax4_ins_b2_mux0004(5),
      Q => fax4_ins_b2(5)
    );
  fax4_ins_b2_4 : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      CE => fax4_ins_load_mux_b_1285,
      D => fax4_ins_b2_mux0004(4),
      Q => fax4_ins_b2(4)
    );
  fax4_ins_b2_3 : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      CE => fax4_ins_load_mux_b_1285,
      D => fax4_ins_b2_mux0004(3),
      Q => fax4_ins_b2(3)
    );
  fax4_ins_b2_2 : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      CE => fax4_ins_load_mux_b_1285,
      D => fax4_ins_b2_mux0004(2),
      Q => fax4_ins_b2(2)
    );
  fax4_ins_b2_1 : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      CE => fax4_ins_load_mux_b_1285,
      D => fax4_ins_b2_mux0004(1),
      Q => fax4_ins_b2(1)
    );
  fax4_ins_b2_0 : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      CE => fax4_ins_load_mux_b_1285,
      D => fax4_ins_b2_mux0004(0),
      Q => fax4_ins_b2(0)
    );
  fax4_ins_a0_9 : FDE_1
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      CE => fax4_ins_load_mux_a0_1284,
      D => fax4_ins_a0_mux0000(0),
      Q => fax4_ins_a0(9)
    );
  fax4_ins_a0_8 : FDE_1
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      CE => fax4_ins_load_mux_a0_1284,
      D => fax4_ins_a0_mux0000(1),
      Q => fax4_ins_a0(8)
    );
  fax4_ins_a0_7 : FDE_1
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      CE => fax4_ins_load_mux_a0_1284,
      D => fax4_ins_a0_mux0000(2),
      Q => fax4_ins_a0(7)
    );
  fax4_ins_a0_6 : FDE_1
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      CE => fax4_ins_load_mux_a0_1284,
      D => fax4_ins_a0_mux0000(3),
      Q => fax4_ins_a0(6)
    );
  fax4_ins_a0_5 : FDE_1
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      CE => fax4_ins_load_mux_a0_1284,
      D => fax4_ins_a0_mux0000(4),
      Q => fax4_ins_a0(5)
    );
  fax4_ins_a0_4 : FDE_1
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      CE => fax4_ins_load_mux_a0_1284,
      D => fax4_ins_a0_mux0000(5),
      Q => fax4_ins_a0(4)
    );
  fax4_ins_a0_3 : FDE_1
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      CE => fax4_ins_load_mux_a0_1284,
      D => fax4_ins_a0_mux0000(6),
      Q => fax4_ins_a0(3)
    );
  fax4_ins_a0_2 : FDE_1
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      CE => fax4_ins_load_mux_a0_1284,
      D => fax4_ins_a0_mux0000(7),
      Q => fax4_ins_a0(2)
    );
  fax4_ins_a0_1 : FDE_1
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      CE => fax4_ins_load_mux_a0_1284,
      D => fax4_ins_a0_mux0000(8),
      Q => fax4_ins_a0(1)
    );
  fax4_ins_a0_0 : FDE_1
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      CE => fax4_ins_load_mux_a0_1284,
      D => fax4_ins_a0_mux0000(9),
      Q => fax4_ins_a0(0)
    );
  fax4_ins_b1_9 : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      CE => fax4_ins_load_mux_b_1285,
      D => fax4_ins_b1_mux0004(9),
      Q => fax4_ins_b1(9)
    );
  fax4_ins_b1_8 : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      CE => fax4_ins_load_mux_b_1285,
      D => fax4_ins_b1_mux0004(8),
      Q => fax4_ins_b1(8)
    );
  fax4_ins_b1_7 : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      CE => fax4_ins_load_mux_b_1285,
      D => fax4_ins_b1_mux0004(7),
      Q => fax4_ins_b1(7)
    );
  fax4_ins_b1_6 : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      CE => fax4_ins_load_mux_b_1285,
      D => fax4_ins_b1_mux0004(6),
      Q => fax4_ins_b1(6)
    );
  fax4_ins_b1_5 : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      CE => fax4_ins_load_mux_b_1285,
      D => fax4_ins_b1_mux0004(5),
      Q => fax4_ins_b1(5)
    );
  fax4_ins_b1_4 : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      CE => fax4_ins_load_mux_b_1285,
      D => fax4_ins_b1_mux0004(4),
      Q => fax4_ins_b1(4)
    );
  fax4_ins_b1_3 : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      CE => fax4_ins_load_mux_b_1285,
      D => fax4_ins_b1_mux0004(3),
      Q => fax4_ins_b1(3)
    );
  fax4_ins_b1_2 : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      CE => fax4_ins_load_mux_b_1285,
      D => fax4_ins_b1_mux0004(2),
      Q => fax4_ins_b1(2)
    );
  fax4_ins_b1_1 : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      CE => fax4_ins_load_mux_b_1285,
      D => fax4_ins_b1_mux0004(1),
      Q => fax4_ins_b1(1)
    );
  fax4_ins_b1_0 : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      CE => fax4_ins_load_mux_b_1285,
      D => fax4_ins_b1_mux0004(0),
      Q => fax4_ins_b1(0)
    );
  fax4_ins_a0_to_white : FDE_1
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      CE => fax4_ins_load_mux_a0_1284,
      D => fax4_ins_a0_to_white_mux0000,
      Q => fax4_ins_a0_to_white_946
    );
  fax4_ins_a2_o_9 : FDE_1
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      CE => fax4_ins_load_a2,
      D => fax4_ins_a1_o_mux0000(0),
      Q => fax4_ins_a2_o(9)
    );
  fax4_ins_a2_o_8 : FDE_1
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      CE => fax4_ins_load_a2,
      D => fax4_ins_a1_o_mux0000(1),
      Q => fax4_ins_a2_o(8)
    );
  fax4_ins_a2_o_7 : FDE_1
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      CE => fax4_ins_load_a2,
      D => fax4_ins_a1_o_mux0000(2),
      Q => fax4_ins_a2_o(7)
    );
  fax4_ins_a2_o_6 : FDE_1
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      CE => fax4_ins_load_a2,
      D => fax4_ins_a1_o_mux0000(3),
      Q => fax4_ins_a2_o(6)
    );
  fax4_ins_a2_o_5 : FDE_1
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      CE => fax4_ins_load_a2,
      D => fax4_ins_a1_o_mux0000(4),
      Q => fax4_ins_a2_o(5)
    );
  fax4_ins_a2_o_4 : FDE_1
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      CE => fax4_ins_load_a2,
      D => fax4_ins_a1_o_mux0000(5),
      Q => fax4_ins_a2_o(4)
    );
  fax4_ins_a2_o_3 : FDE_1
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      CE => fax4_ins_load_a2,
      D => fax4_ins_a1_o_mux0000(6),
      Q => fax4_ins_a2_o(3)
    );
  fax4_ins_a2_o_2 : FDE_1
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      CE => fax4_ins_load_a2,
      D => fax4_ins_a1_o_mux0000(7),
      Q => fax4_ins_a2_o(2)
    );
  fax4_ins_a2_o_1 : FDE_1
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      CE => fax4_ins_load_a2,
      D => fax4_ins_a1_o_mux0000(8),
      Q => fax4_ins_a2_o(1)
    );
  fax4_ins_a2_o_0 : FDE_1
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      CE => fax4_ins_load_a2,
      D => fax4_ins_a1_o_mux0000(9),
      Q => fax4_ins_a2_o(0)
    );
  fax4_ins_a1_o_9 : FDE_1
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      CE => fax4_ins_load_a0,
      D => fax4_ins_a1_o_mux0000(0),
      Q => fax4_ins_a1_o(9)
    );
  fax4_ins_a1_o_8 : FDE_1
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      CE => fax4_ins_load_a0,
      D => fax4_ins_a1_o_mux0000(1),
      Q => fax4_ins_a1_o(8)
    );
  fax4_ins_a1_o_7 : FDE_1
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      CE => fax4_ins_load_a0,
      D => fax4_ins_a1_o_mux0000(2),
      Q => fax4_ins_a1_o(7)
    );
  fax4_ins_a1_o_6 : FDE_1
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      CE => fax4_ins_load_a0,
      D => fax4_ins_a1_o_mux0000(3),
      Q => fax4_ins_a1_o(6)
    );
  fax4_ins_a1_o_5 : FDE_1
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      CE => fax4_ins_load_a0,
      D => fax4_ins_a1_o_mux0000(4),
      Q => fax4_ins_a1_o(5)
    );
  fax4_ins_a1_o_4 : FDE_1
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      CE => fax4_ins_load_a0,
      D => fax4_ins_a1_o_mux0000(5),
      Q => fax4_ins_a1_o(4)
    );
  fax4_ins_a1_o_3 : FDE_1
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      CE => fax4_ins_load_a0,
      D => fax4_ins_a1_o_mux0000(6),
      Q => fax4_ins_a1_o(3)
    );
  fax4_ins_a1_o_2 : FDE_1
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      CE => fax4_ins_load_a0,
      D => fax4_ins_a1_o_mux0000(7),
      Q => fax4_ins_a1_o(2)
    );
  fax4_ins_a1_o_1 : FDE_1
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      CE => fax4_ins_load_a0,
      D => fax4_ins_a1_o_mux0000(8),
      Q => fax4_ins_a1_o(1)
    );
  fax4_ins_a1_o_0 : FDE_1
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      CE => fax4_ins_load_a0,
      D => fax4_ins_a1_o_mux0000(9),
      Q => fax4_ins_a1_o(0)
    );
  fax4_ins_b2_to_white : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      CE => fax4_ins_load_mux_b_1285,
      D => fax4_ins_b2_to_white_mux0004,
      Q => fax4_ins_b2_to_white_1094
    );
  fax4_ins_fifo_out_prev1_to_white : FDE_1
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      CE => fax4_ins_fifo_rd,
      D => fax4_ins_fifo_out1_to_white,
      Q => fax4_ins_fifo_out_prev1_to_white_1239
    );
  fax4_ins_pix_changed : FDC
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      CLR => fax4_ins_pix_change_detector_reset,
      D => fax4_ins_pix_changed_mux0001,
      Q => fax4_ins_pix_changed_1319
    );
  fax4_ins_to_white_mux00001 : LUT2
    generic map(
      INIT => X"D"
    )
    port map (
      I0 => rsync_i,
      I1 => pix_i,
      O => fax4_ins_to_white_mux0000
    );
  huffman_ins_v2_run_len_code_width_o_4_1 : LUT2
    generic map(
      INIT => X"8"
    )
    port map (
      I0 => huffman_ins_v2_horizontal_mode_3_2063,
      I1 => huffman_ins_v2_hor_code_width(4),
      O => run_len_code_width_o(4)
    );
  huffman_ins_v2_run_len_code_width_o_3_1 : LUT2
    generic map(
      INIT => X"8"
    )
    port map (
      I0 => huffman_ins_v2_horizontal_mode_3_2063,
      I1 => huffman_ins_v2_hor_code_width(3),
      O => run_len_code_width_o(3)
    );
  huffman_ins_v2_run_len_code_o_9_1 : LUT2
    generic map(
      INIT => X"8"
    )
    port map (
      I0 => huffman_ins_v2_horizontal_mode_3_2063,
      I1 => huffman_ins_v2_hor_code(9),
      O => run_len_code_o(9)
    );
  huffman_ins_v2_run_len_code_o_8_1 : LUT2
    generic map(
      INIT => X"8"
    )
    port map (
      I0 => huffman_ins_v2_horizontal_mode_3_2063,
      I1 => huffman_ins_v2_hor_code(8),
      O => run_len_code_o(8)
    );
  huffman_ins_v2_run_len_code_o_7_1 : LUT2
    generic map(
      INIT => X"8"
    )
    port map (
      I0 => huffman_ins_v2_horizontal_mode_3_2063,
      I1 => huffman_ins_v2_hor_code(7),
      O => run_len_code_o(7)
    );
  huffman_ins_v2_run_len_code_o_25_1 : LUT2
    generic map(
      INIT => X"8"
    )
    port map (
      I0 => huffman_ins_v2_horizontal_mode_3_2063,
      I1 => huffman_ins_v2_hor_code(25),
      O => run_len_code_o(25)
    );
  huffman_ins_v2_run_len_code_o_24_1 : LUT2
    generic map(
      INIT => X"8"
    )
    port map (
      I0 => huffman_ins_v2_horizontal_mode_3_2063,
      I1 => huffman_ins_v2_hor_code(24),
      O => run_len_code_o(24)
    );
  huffman_ins_v2_run_len_code_o_23_1 : LUT2
    generic map(
      INIT => X"8"
    )
    port map (
      I0 => huffman_ins_v2_horizontal_mode_3_2063,
      I1 => huffman_ins_v2_hor_code(23),
      O => run_len_code_o(23)
    );
  huffman_ins_v2_run_len_code_o_22_1 : LUT2
    generic map(
      INIT => X"8"
    )
    port map (
      I0 => huffman_ins_v2_horizontal_mode_3_2063,
      I1 => huffman_ins_v2_hor_code(22),
      O => run_len_code_o(22)
    );
  huffman_ins_v2_run_len_code_o_21_1 : LUT2
    generic map(
      INIT => X"8"
    )
    port map (
      I0 => huffman_ins_v2_horizontal_mode_3_2063,
      I1 => huffman_ins_v2_hor_code(21),
      O => run_len_code_o(21)
    );
  huffman_ins_v2_run_len_code_o_20_1 : LUT2
    generic map(
      INIT => X"8"
    )
    port map (
      I0 => huffman_ins_v2_horizontal_mode_3_2063,
      I1 => huffman_ins_v2_hor_code(20),
      O => run_len_code_o(20)
    );
  huffman_ins_v2_run_len_code_o_19_1 : LUT2
    generic map(
      INIT => X"8"
    )
    port map (
      I0 => huffman_ins_v2_horizontal_mode_3_2063,
      I1 => huffman_ins_v2_hor_code(19),
      O => run_len_code_o(19)
    );
  huffman_ins_v2_run_len_code_o_18_1 : LUT2
    generic map(
      INIT => X"8"
    )
    port map (
      I0 => huffman_ins_v2_horizontal_mode_3_2063,
      I1 => huffman_ins_v2_hor_code(18),
      O => run_len_code_o(18)
    );
  huffman_ins_v2_run_len_code_o_17_1 : LUT2
    generic map(
      INIT => X"8"
    )
    port map (
      I0 => huffman_ins_v2_horizontal_mode_3_2063,
      I1 => huffman_ins_v2_hor_code(17),
      O => run_len_code_o(17)
    );
  huffman_ins_v2_run_len_code_o_16_1 : LUT2
    generic map(
      INIT => X"8"
    )
    port map (
      I0 => huffman_ins_v2_horizontal_mode_3_2063,
      I1 => huffman_ins_v2_hor_code(16),
      O => run_len_code_o(16)
    );
  huffman_ins_v2_run_len_code_o_15_1 : LUT2
    generic map(
      INIT => X"8"
    )
    port map (
      I0 => huffman_ins_v2_horizontal_mode_3_2063,
      I1 => huffman_ins_v2_hor_code(15),
      O => run_len_code_o(15)
    );
  huffman_ins_v2_run_len_code_o_14_1 : LUT2
    generic map(
      INIT => X"8"
    )
    port map (
      I0 => huffman_ins_v2_horizontal_mode_3_2063,
      I1 => huffman_ins_v2_hor_code(14),
      O => run_len_code_o(14)
    );
  huffman_ins_v2_run_len_code_o_13_1 : LUT2
    generic map(
      INIT => X"8"
    )
    port map (
      I0 => huffman_ins_v2_horizontal_mode_3_2063,
      I1 => huffman_ins_v2_hor_code(13),
      O => run_len_code_o(13)
    );
  huffman_ins_v2_run_len_code_o_12_1 : LUT2
    generic map(
      INIT => X"8"
    )
    port map (
      I0 => huffman_ins_v2_horizontal_mode_3_2063,
      I1 => huffman_ins_v2_hor_code(12),
      O => run_len_code_o(12)
    );
  huffman_ins_v2_run_len_code_o_11_1 : LUT2
    generic map(
      INIT => X"8"
    )
    port map (
      I0 => huffman_ins_v2_horizontal_mode_3_2063,
      I1 => huffman_ins_v2_hor_code(11),
      O => run_len_code_o(11)
    );
  huffman_ins_v2_run_len_code_o_10_1 : LUT2
    generic map(
      INIT => X"8"
    )
    port map (
      I0 => huffman_ins_v2_horizontal_mode_3_2063,
      I1 => huffman_ins_v2_hor_code(10),
      O => run_len_code_o(10)
    );
  huffman_ins_v2_run_len_code_width_o_2_1 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => huffman_ins_v2_horizontal_mode_3_2063,
      I1 => huffman_ins_v2_pass_vert_code_width_3_2_Q,
      I2 => huffman_ins_v2_hor_code_width(2),
      O => run_len_code_width_o(2)
    );
  huffman_ins_v2_run_len_code_width_o_1_1 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => huffman_ins_v2_horizontal_mode_3_2063,
      I1 => huffman_ins_v2_pass_vert_code_3(1),
      I2 => huffman_ins_v2_hor_code_width(1),
      O => run_len_code_width_o(1)
    );
  huffman_ins_v2_run_len_code_width_o_0_1 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => huffman_ins_v2_horizontal_mode_3_2063,
      I1 => huffman_ins_v2_pass_vert_code_width_3_0_Q,
      I2 => huffman_ins_v2_hor_code_width(0),
      O => run_len_code_width_o(0)
    );
  huffman_ins_v2_run_len_code_o_6_1 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => huffman_ins_v2_horizontal_mode_3_2063,
      I1 => huffman_ins_v2_pass_vert_code_3(2),
      I2 => huffman_ins_v2_hor_code(6),
      O => run_len_code_o(6)
    );
  huffman_ins_v2_run_len_code_o_5_1 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => huffman_ins_v2_horizontal_mode_3_2063,
      I1 => huffman_ins_v2_pass_vert_code_3(2),
      I2 => huffman_ins_v2_hor_code(5),
      O => run_len_code_o(5)
    );
  huffman_ins_v2_run_len_code_o_4_1 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => huffman_ins_v2_horizontal_mode_3_2063,
      I1 => huffman_ins_v2_pass_vert_code_3(2),
      I2 => huffman_ins_v2_hor_code(4),
      O => run_len_code_o(4)
    );
  huffman_ins_v2_run_len_code_o_3_1 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => huffman_ins_v2_horizontal_mode_3_2063,
      I1 => huffman_ins_v2_pass_vert_code_3(2),
      I2 => huffman_ins_v2_hor_code(3),
      O => run_len_code_o(3)
    );
  huffman_ins_v2_run_len_code_o_2_1 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => huffman_ins_v2_horizontal_mode_3_2063,
      I1 => huffman_ins_v2_pass_vert_code_3(2),
      I2 => huffman_ins_v2_hor_code(2),
      O => run_len_code_o(2)
    );
  huffman_ins_v2_run_len_code_o_1_1 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => huffman_ins_v2_horizontal_mode_3_2063,
      I1 => huffman_ins_v2_pass_vert_code_3(1),
      I2 => huffman_ins_v2_hor_code(1),
      O => run_len_code_o(1)
    );
  huffman_ins_v2_run_len_code_o_0_1 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => huffman_ins_v2_horizontal_mode_3_2063,
      I1 => huffman_ins_v2_pass_vert_code_3(0),
      I2 => huffman_ins_v2_hor_code(0),
      O => run_len_code_o(0)
    );
  fax4_ins_pix_changed_mux00011 : LUT3
    generic map(
      INIT => X"28"
    )
    port map (
      I0 => rsync_i,
      I1 => pix_i,
      I2 => fax4_ins_pix_prev_1321,
      O => fax4_ins_pix_changed_mux0001
    );
  fax4_ins_fifo_out_prev2_valid_mux00011 : LUT3
    generic map(
      INIT => X"82"
    )
    port map (
      I0 => fax4_ins_fifo_out_prev1_valid_1240,
      I1 => fax4_ins_fifo_sel_prev_1279,
      I2 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt(0),
      O => fax4_ins_fifo_out_prev2_valid_mux0001
    );
  fax4_ins_fifo_out_prev1_valid_mux00011 : LUT4
    generic map(
      INIT => X"9810"
    )
    port map (
      I0 => fax4_ins_fifo_sel_prev_1279,
      I1 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt(0),
      I2 => fax4_ins_FIFO2_multi_read_ins_valid1_o_698,
      I3 => fax4_ins_FIFO1_multi_read_ins_valid1_o_456,
      O => fax4_ins_fifo_out_prev1_valid_mux0001
    );
  fax4_ins_counter_xy_v2_ins_frame_valid_and00011 : LUT2
    generic map(
      INIT => X"2"
    )
    port map (
      I0 => fax4_ins_counter_xy_v2_ins_counter_y_ins_overflow_o_1204,
      I1 => fax4_ins_counter_xy_v2_ins_cnt_y_overflow_prev_1104,
      O => fax4_ins_counter_xy_v2_ins_frame_valid_and0001
    );
  fax4_ins_counter_xy_v2_ins_line_valid_and00001 : LUT2
    generic map(
      INIT => X"2"
    )
    port map (
      I0 => rsync_i,
      I1 => fax4_ins_counter_xy_v2_ins_rsync_i_prev_1212,
      O => fax4_ins_counter_xy_v2_ins_line_valid_and0000
    );
  fax4_ins_counter_xy_v2_ins_frame_valid_and00001 : LUT2
    generic map(
      INIT => X"2"
    )
    port map (
      I0 => fsync_i,
      I1 => fax4_ins_counter_xy_v2_ins_fsync_i_prev_1209,
      O => fax4_ins_counter_xy_v2_ins_frame_valid_and0000
    );
  fax4_ins_counter_xy_v2_ins_cnt_y_reset_or00001 : LUT4
    generic map(
      INIT => X"AEFF"
    )
    port map (
      I0 => fax4_ins_counter_xy_v2_ins_cnt_y_overflow_prev_1104,
      I1 => fsync_i,
      I2 => fax4_ins_counter_xy_v2_ins_fsync_i_prev_1209,
      I3 => fax4_ins_counter_xy_v2_ins_counter_y_ins_overflow_o_1204,
      O => fax4_ins_counter_xy_v2_ins_cnt_y_reset_or0000
    );
  fax4_ins_counter_xy_v2_ins_cnt_x_reset_or00001 : LUT4
    generic map(
      INIT => X"22F2"
    )
    port map (
      I0 => fax4_ins_counter_xy_v2_ins_rsync_i_prev_1212,
      I1 => rsync_i,
      I2 => fax4_ins_counter_xy_v2_ins_counter_x_ins_overflow_o_1157,
      I3 => fax4_ins_counter_xy_v2_ins_cnt_x_overflow_prev_1101,
      O => fax4_ins_counter_xy_v2_ins_cnt_x_reset_or0000
    );
  fax4_ins_counter_xy_v2_ins_counter_y_ins_overflow_o_mux00021 : LUT2
    generic map(
      INIT => X"8"
    )
    port map (
      I0 => fax4_ins_counter_xy_v2_ins_frame_valid_1206,
      I1 => fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt_cmp_ge0000,
      O => fax4_ins_counter_xy_v2_ins_counter_y_ins_overflow_o_mux0002
    );
  fax4_ins_counter_xy_v2_ins_cnt_x_en1 : LUT2
    generic map(
      INIT => X"8"
    )
    port map (
      I0 => fax4_ins_counter_xy_v2_ins_line_valid_1210,
      I1 => fax4_ins_counter_xy_v2_ins_frame_valid_1206,
      O => fax4_ins_counter_xy_v2_ins_cnt_x_en
    );
  fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt_cmp_ge00001 : LUT4
    generic map(
      INIT => X"8000"
    )
    port map (
      I0 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt(7),
      I1 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt(8),
      I2 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt(5),
      I3 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt(6),
      O => fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt_cmp_ge0000
    );
  huffman_ins_v2_hor_code_width_mux0001_1_1 : LUT4
    generic map(
      INIT => X"EB41"
    )
    port map (
      I0 => huffman_ins_v2_horizontal_mode_part_2_2065,
      I1 => huffman_ins_v2_Madd_hor_code_width_addsub0000_cy(0),
      I2 => huffman_ins_v2_mux_code_white_width(1),
      I3 => huffman_ins_v2_mux_code_black_width(1),
      O => huffman_ins_v2_hor_code_width_mux0001(1)
    );
  fax4_ins_state_FSM_Out151 : LUT3
    generic map(
      INIT => X"FE"
    )
    port map (
      I0 => fax4_ins_state_FSM_FFd11_1325,
      I1 => fax4_ins_state_FSM_FFd3_1329,
      I2 => fax4_ins_state_FSM_FFd9_1341,
      O => fax4_ins_pix_change_detector_reset
    );
  fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt_mux0000_8_1 : LUT2
    generic map(
      INIT => X"E"
    )
    port map (
      I0 => fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt_cmp_ge0000,
      I1 => fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt_addsub0000(0),
      O => fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt_mux0000(8)
    );
  fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt_mux0000_9_1 : LUT2
    generic map(
      INIT => X"E"
    )
    port map (
      I0 => fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt_cmp_ge0000,
      I1 => fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt_addsub0000(0),
      O => fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt_mux0000(9)
    );
  fax4_ins_FIFO2_multi_read_ins_Mcount_write_pos_eqn_01 : LUT2
    generic map(
      INIT => X"2"
    )
    port map (
      I0 => fax4_ins_FIFO2_multi_read_ins_Result_0_1,
      I1 => fax4_ins_FIFO2_multi_read_ins_write_pos_cmp_eq0000,
      O => fax4_ins_FIFO2_multi_read_ins_Mcount_write_pos_eqn_0
    );
  fax4_ins_FIFO2_multi_read_ins_Mcount_read_pos_eqn_01 : LUT2
    generic map(
      INIT => X"2"
    )
    port map (
      I0 => fax4_ins_FIFO2_multi_read_ins_Result(0),
      I1 => fax4_ins_FIFO2_multi_read_ins_read_pos_cmp_eq0000,
      O => fax4_ins_FIFO2_multi_read_ins_Mcount_read_pos_eqn_0
    );
  fax4_ins_FIFO1_multi_read_ins_Mcount_write_pos_eqn_01 : LUT2
    generic map(
      INIT => X"2"
    )
    port map (
      I0 => fax4_ins_FIFO1_multi_read_ins_Result_0_1,
      I1 => fax4_ins_FIFO1_multi_read_ins_write_pos_cmp_eq0000,
      O => fax4_ins_FIFO1_multi_read_ins_Mcount_write_pos_eqn_0
    );
  fax4_ins_FIFO1_multi_read_ins_Mcount_read_pos_eqn_01 : LUT2
    generic map(
      INIT => X"2"
    )
    port map (
      I0 => fax4_ins_FIFO1_multi_read_ins_Result(0),
      I1 => fax4_ins_FIFO1_multi_read_ins_read_pos_cmp_eq0000,
      O => fax4_ins_FIFO1_multi_read_ins_Mcount_read_pos_eqn_0
    );
  fax4_ins_state_FSM_FFd6_In11 : LUT4
    generic map(
      INIT => X"FFFE"
    )
    port map (
      I0 => fax4_ins_state_FSM_FFd10_1323,
      I1 => fax4_ins_state_FSM_FFd2_1327,
      I2 => fax4_ins_state_FSM_FFd5_1333,
      I3 => fax4_ins_state_FSM_FFd6_1336,
      O => fax4_ins_load_a1_or0000
    );
  huffman_ins_v2_hor_code_width_mux0001_2_1 : LUT4
    generic map(
      INIT => X"BE14"
    )
    port map (
      I0 => huffman_ins_v2_horizontal_mode_part_2_2065,
      I1 => huffman_ins_v2_Madd_hor_code_width_addsub0000_lut(2),
      I2 => huffman_ins_v2_Madd_hor_code_width_addsub0000_cy(1),
      I3 => huffman_ins_v2_mux_code_black_width(2),
      O => huffman_ins_v2_hor_code_width_mux0001(2)
    );
  fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt_cmp_ge00001_SW0 : LUT3
    generic map(
      INIT => X"80"
    )
    port map (
      I0 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(5),
      I1 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(6),
      I2 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(7),
      O => N2
    );
  fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt_cmp_ge00001 : LUT4
    generic map(
      INIT => X"AA80"
    )
    port map (
      I0 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(9),
      I1 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(4),
      I2 => N2,
      I3 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(8),
      O => fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt_cmp_ge0000
    );
  fax4_ins_FIFO2_multi_read_ins_write_pos_cmp_eq00007 : LUT4
    generic map(
      INIT => X"2000"
    )
    port map (
      I0 => fax4_ins_FIFO2_multi_read_ins_write_pos(6),
      I1 => fax4_ins_FIFO2_multi_read_ins_write_pos(4),
      I2 => fax4_ins_FIFO2_multi_read_ins_write_pos(5),
      I3 => fax4_ins_FIFO2_multi_read_ins_write_pos(7),
      O => fax4_ins_FIFO2_multi_read_ins_write_pos_cmp_eq00007_715
    );
  fax4_ins_FIFO2_multi_read_ins_write_pos_cmp_eq000015 : LUT4
    generic map(
      INIT => X"8000"
    )
    port map (
      I0 => fax4_ins_FIFO2_multi_read_ins_write_pos(3),
      I1 => fax4_ins_FIFO2_multi_read_ins_write_pos(2),
      I2 => fax4_ins_FIFO2_multi_read_ins_write_pos(1),
      I3 => fax4_ins_FIFO2_multi_read_ins_write_pos(0),
      O => fax4_ins_FIFO2_multi_read_ins_write_pos_cmp_eq000015_714
    );
  fax4_ins_FIFO2_multi_read_ins_read_pos_cmp_eq00007 : LUT4
    generic map(
      INIT => X"2000"
    )
    port map (
      I0 => fax4_ins_FIFO2_multi_read_ins_read_pos(6),
      I1 => fax4_ins_FIFO2_multi_read_ins_read_pos(4),
      I2 => fax4_ins_FIFO2_multi_read_ins_read_pos(5),
      I3 => fax4_ins_FIFO2_multi_read_ins_read_pos(7),
      O => fax4_ins_FIFO2_multi_read_ins_read_pos_cmp_eq00007_682
    );
  fax4_ins_FIFO2_multi_read_ins_read_pos_cmp_eq000015 : LUT4
    generic map(
      INIT => X"8000"
    )
    port map (
      I0 => fax4_ins_FIFO2_multi_read_ins_read_pos(3),
      I1 => fax4_ins_FIFO2_multi_read_ins_read_pos(2),
      I2 => fax4_ins_FIFO2_multi_read_ins_read_pos(1),
      I3 => fax4_ins_FIFO2_multi_read_ins_read_pos(0),
      O => fax4_ins_FIFO2_multi_read_ins_read_pos_cmp_eq000015_681
    );
  fax4_ins_FIFO1_multi_read_ins_write_pos_cmp_eq00007 : LUT4
    generic map(
      INIT => X"2000"
    )
    port map (
      I0 => fax4_ins_FIFO1_multi_read_ins_write_pos(6),
      I1 => fax4_ins_FIFO1_multi_read_ins_write_pos(4),
      I2 => fax4_ins_FIFO1_multi_read_ins_write_pos(5),
      I3 => fax4_ins_FIFO1_multi_read_ins_write_pos(7),
      O => fax4_ins_FIFO1_multi_read_ins_write_pos_cmp_eq00007_472
    );
  fax4_ins_FIFO1_multi_read_ins_write_pos_cmp_eq000015 : LUT4
    generic map(
      INIT => X"8000"
    )
    port map (
      I0 => fax4_ins_FIFO1_multi_read_ins_write_pos(3),
      I1 => fax4_ins_FIFO1_multi_read_ins_write_pos(2),
      I2 => fax4_ins_FIFO1_multi_read_ins_write_pos(1),
      I3 => fax4_ins_FIFO1_multi_read_ins_write_pos(0),
      O => fax4_ins_FIFO1_multi_read_ins_write_pos_cmp_eq000015_471
    );
  fax4_ins_FIFO1_multi_read_ins_read_pos_cmp_eq00007 : LUT4
    generic map(
      INIT => X"2000"
    )
    port map (
      I0 => fax4_ins_FIFO1_multi_read_ins_read_pos(6),
      I1 => fax4_ins_FIFO1_multi_read_ins_read_pos(4),
      I2 => fax4_ins_FIFO1_multi_read_ins_read_pos(5),
      I3 => fax4_ins_FIFO1_multi_read_ins_read_pos(7),
      O => fax4_ins_FIFO1_multi_read_ins_read_pos_cmp_eq00007_440
    );
  fax4_ins_FIFO1_multi_read_ins_read_pos_cmp_eq000015 : LUT4
    generic map(
      INIT => X"8000"
    )
    port map (
      I0 => fax4_ins_FIFO1_multi_read_ins_read_pos(3),
      I1 => fax4_ins_FIFO1_multi_read_ins_read_pos(2),
      I2 => fax4_ins_FIFO1_multi_read_ins_read_pos(1),
      I3 => fax4_ins_FIFO1_multi_read_ins_read_pos(0),
      O => fax4_ins_FIFO1_multi_read_ins_read_pos_cmp_eq000015_439
    );
  huffman_ins_v2_Mrom_run_length_i_rom000051 : LUT4
    generic map(
      INIT => X"6AAA"
    )
    port map (
      I0 => fax4_ins_mode_indicator_o(3),
      I1 => fax4_ins_mode_indicator_o(1),
      I2 => fax4_ins_mode_indicator_o(0),
      I3 => fax4_ins_mode_indicator_o(2),
      O => huffman_ins_v2_Mrom_run_length_i_rom00005
    );
  huffman_ins_v2_Mrom_run_length_i_rom000031 : LUT4
    generic map(
      INIT => X"9501"
    )
    port map (
      I0 => fax4_ins_mode_indicator_o(3),
      I1 => fax4_ins_mode_indicator_o(0),
      I2 => fax4_ins_mode_indicator_o(1),
      I3 => fax4_ins_mode_indicator_o(2),
      O => huffman_ins_v2_Mrom_run_length_i_rom00003
    );
  huffman_ins_v2_Mrom_run_length_i_rom000021 : LUT4
    generic map(
      INIT => X"8078"
    )
    port map (
      I0 => fax4_ins_mode_indicator_o(2),
      I1 => fax4_ins_mode_indicator_o(0),
      I2 => fax4_ins_mode_indicator_o(1),
      I3 => fax4_ins_mode_indicator_o(3),
      O => huffman_ins_v2_Mrom_run_length_i_rom00002
    );
  fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt_mux0000_7_1 : LUT2
    generic map(
      INIT => X"2"
    )
    port map (
      I0 => fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt_addsub0000(1),
      I1 => fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt_cmp_ge0000,
      O => fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt_mux0000(7)
    );
  fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt_mux0000_8_1 : LUT2
    generic map(
      INIT => X"2"
    )
    port map (
      I0 => fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt_addsub0000(1),
      I1 => fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt_cmp_ge0000,
      O => fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt_mux0000(8)
    );
  fax4_ins_FIFO2_multi_read_ins_Mcount_write_pos_eqn_11 : LUT2
    generic map(
      INIT => X"2"
    )
    port map (
      I0 => fax4_ins_FIFO2_multi_read_ins_Result_1_1,
      I1 => fax4_ins_FIFO2_multi_read_ins_write_pos_cmp_eq0000,
      O => fax4_ins_FIFO2_multi_read_ins_Mcount_write_pos_eqn_1
    );
  fax4_ins_FIFO2_multi_read_ins_Mcount_read_pos_eqn_11 : LUT2
    generic map(
      INIT => X"2"
    )
    port map (
      I0 => fax4_ins_FIFO2_multi_read_ins_Result(1),
      I1 => fax4_ins_FIFO2_multi_read_ins_read_pos_cmp_eq0000,
      O => fax4_ins_FIFO2_multi_read_ins_Mcount_read_pos_eqn_1
    );
  fax4_ins_FIFO1_multi_read_ins_Mcount_write_pos_eqn_11 : LUT2
    generic map(
      INIT => X"2"
    )
    port map (
      I0 => fax4_ins_FIFO1_multi_read_ins_Result_1_1,
      I1 => fax4_ins_FIFO1_multi_read_ins_write_pos_cmp_eq0000,
      O => fax4_ins_FIFO1_multi_read_ins_Mcount_write_pos_eqn_1
    );
  fax4_ins_FIFO1_multi_read_ins_Mcount_read_pos_eqn_11 : LUT2
    generic map(
      INIT => X"2"
    )
    port map (
      I0 => fax4_ins_FIFO1_multi_read_ins_Result(1),
      I1 => fax4_ins_FIFO1_multi_read_ins_read_pos_cmp_eq0000,
      O => fax4_ins_FIFO1_multi_read_ins_Mcount_read_pos_eqn_1
    );
  fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt_mux0000_6_1 : LUT2
    generic map(
      INIT => X"2"
    )
    port map (
      I0 => fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt_addsub0000(2),
      I1 => fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt_cmp_ge0000,
      O => fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt_mux0000(6)
    );
  fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt_mux0000_7_1 : LUT2
    generic map(
      INIT => X"2"
    )
    port map (
      I0 => fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt_addsub0000(2),
      I1 => fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt_cmp_ge0000,
      O => fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt_mux0000(7)
    );
  fax4_ins_FIFO2_multi_read_ins_Mcount_write_pos_eqn_21 : LUT2
    generic map(
      INIT => X"2"
    )
    port map (
      I0 => fax4_ins_FIFO2_multi_read_ins_Result_2_1,
      I1 => fax4_ins_FIFO2_multi_read_ins_write_pos_cmp_eq0000,
      O => fax4_ins_FIFO2_multi_read_ins_Mcount_write_pos_eqn_2
    );
  fax4_ins_FIFO2_multi_read_ins_Mcount_read_pos_eqn_21 : LUT2
    generic map(
      INIT => X"2"
    )
    port map (
      I0 => fax4_ins_FIFO2_multi_read_ins_Result(2),
      I1 => fax4_ins_FIFO2_multi_read_ins_read_pos_cmp_eq0000,
      O => fax4_ins_FIFO2_multi_read_ins_Mcount_read_pos_eqn_2
    );
  fax4_ins_FIFO1_multi_read_ins_Mcount_write_pos_eqn_21 : LUT2
    generic map(
      INIT => X"2"
    )
    port map (
      I0 => fax4_ins_FIFO1_multi_read_ins_Result_2_1,
      I1 => fax4_ins_FIFO1_multi_read_ins_write_pos_cmp_eq0000,
      O => fax4_ins_FIFO1_multi_read_ins_Mcount_write_pos_eqn_2
    );
  fax4_ins_FIFO1_multi_read_ins_Mcount_read_pos_eqn_21 : LUT2
    generic map(
      INIT => X"2"
    )
    port map (
      I0 => fax4_ins_FIFO1_multi_read_ins_Result(2),
      I1 => fax4_ins_FIFO1_multi_read_ins_read_pos_cmp_eq0000,
      O => fax4_ins_FIFO1_multi_read_ins_Mcount_read_pos_eqn_2
    );
  fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt_mux0000_5_1 : LUT2
    generic map(
      INIT => X"2"
    )
    port map (
      I0 => fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt_addsub0000(3),
      I1 => fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt_cmp_ge0000,
      O => fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt_mux0000(5)
    );
  fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt_mux0000_6_1 : LUT2
    generic map(
      INIT => X"2"
    )
    port map (
      I0 => fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt_addsub0000(3),
      I1 => fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt_cmp_ge0000,
      O => fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt_mux0000(6)
    );
  fax4_ins_FIFO2_multi_read_ins_Mcount_write_pos_eqn_31 : LUT2
    generic map(
      INIT => X"2"
    )
    port map (
      I0 => fax4_ins_FIFO2_multi_read_ins_Result_3_1,
      I1 => fax4_ins_FIFO2_multi_read_ins_write_pos_cmp_eq0000,
      O => fax4_ins_FIFO2_multi_read_ins_Mcount_write_pos_eqn_3
    );
  fax4_ins_FIFO2_multi_read_ins_Mcount_read_pos_eqn_31 : LUT2
    generic map(
      INIT => X"2"
    )
    port map (
      I0 => fax4_ins_FIFO2_multi_read_ins_Result(3),
      I1 => fax4_ins_FIFO2_multi_read_ins_read_pos_cmp_eq0000,
      O => fax4_ins_FIFO2_multi_read_ins_Mcount_read_pos_eqn_3
    );
  fax4_ins_FIFO1_multi_read_ins_Mcount_write_pos_eqn_31 : LUT2
    generic map(
      INIT => X"2"
    )
    port map (
      I0 => fax4_ins_FIFO1_multi_read_ins_Result_3_1,
      I1 => fax4_ins_FIFO1_multi_read_ins_write_pos_cmp_eq0000,
      O => fax4_ins_FIFO1_multi_read_ins_Mcount_write_pos_eqn_3
    );
  fax4_ins_FIFO1_multi_read_ins_Mcount_read_pos_eqn_31 : LUT2
    generic map(
      INIT => X"2"
    )
    port map (
      I0 => fax4_ins_FIFO1_multi_read_ins_Result(3),
      I1 => fax4_ins_FIFO1_multi_read_ins_read_pos_cmp_eq0000,
      O => fax4_ins_FIFO1_multi_read_ins_Mcount_read_pos_eqn_3
    );
  fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt_mux0000_4_1 : LUT2
    generic map(
      INIT => X"2"
    )
    port map (
      I0 => fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt_addsub0000(4),
      I1 => fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt_cmp_ge0000,
      O => fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt_mux0000(4)
    );
  fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt_mux0000_5_1 : LUT2
    generic map(
      INIT => X"2"
    )
    port map (
      I0 => fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt_addsub0000(4),
      I1 => fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt_cmp_ge0000,
      O => fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt_mux0000(5)
    );
  fax4_ins_FIFO2_multi_read_ins_Mcount_write_pos_eqn_41 : LUT2
    generic map(
      INIT => X"2"
    )
    port map (
      I0 => fax4_ins_FIFO2_multi_read_ins_Result_4_1,
      I1 => fax4_ins_FIFO2_multi_read_ins_write_pos_cmp_eq0000,
      O => fax4_ins_FIFO2_multi_read_ins_Mcount_write_pos_eqn_4
    );
  fax4_ins_FIFO2_multi_read_ins_Mcount_read_pos_eqn_41 : LUT2
    generic map(
      INIT => X"2"
    )
    port map (
      I0 => fax4_ins_FIFO2_multi_read_ins_Result(4),
      I1 => fax4_ins_FIFO2_multi_read_ins_read_pos_cmp_eq0000,
      O => fax4_ins_FIFO2_multi_read_ins_Mcount_read_pos_eqn_4
    );
  fax4_ins_FIFO1_multi_read_ins_Mcount_write_pos_eqn_41 : LUT2
    generic map(
      INIT => X"2"
    )
    port map (
      I0 => fax4_ins_FIFO1_multi_read_ins_Result_4_1,
      I1 => fax4_ins_FIFO1_multi_read_ins_write_pos_cmp_eq0000,
      O => fax4_ins_FIFO1_multi_read_ins_Mcount_write_pos_eqn_4
    );
  fax4_ins_FIFO1_multi_read_ins_Mcount_read_pos_eqn_41 : LUT2
    generic map(
      INIT => X"2"
    )
    port map (
      I0 => fax4_ins_FIFO1_multi_read_ins_Result(4),
      I1 => fax4_ins_FIFO1_multi_read_ins_read_pos_cmp_eq0000,
      O => fax4_ins_FIFO1_multi_read_ins_Mcount_read_pos_eqn_4
    );
  fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt_mux0000_3_1 : LUT2
    generic map(
      INIT => X"2"
    )
    port map (
      I0 => fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt_addsub0000(5),
      I1 => fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt_cmp_ge0000,
      O => fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt_mux0000(3)
    );
  fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt_mux0000_4_1 : LUT2
    generic map(
      INIT => X"2"
    )
    port map (
      I0 => fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt_addsub0000(5),
      I1 => fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt_cmp_ge0000,
      O => fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt_mux0000(4)
    );
  fax4_ins_FIFO2_multi_read_ins_Mcount_write_pos_eqn_51 : LUT2
    generic map(
      INIT => X"2"
    )
    port map (
      I0 => fax4_ins_FIFO2_multi_read_ins_Result_5_1,
      I1 => fax4_ins_FIFO2_multi_read_ins_write_pos_cmp_eq0000,
      O => fax4_ins_FIFO2_multi_read_ins_Mcount_write_pos_eqn_5
    );
  fax4_ins_FIFO2_multi_read_ins_Mcount_read_pos_eqn_51 : LUT2
    generic map(
      INIT => X"2"
    )
    port map (
      I0 => fax4_ins_FIFO2_multi_read_ins_Result(5),
      I1 => fax4_ins_FIFO2_multi_read_ins_read_pos_cmp_eq0000,
      O => fax4_ins_FIFO2_multi_read_ins_Mcount_read_pos_eqn_5
    );
  fax4_ins_FIFO1_multi_read_ins_Mcount_write_pos_eqn_51 : LUT2
    generic map(
      INIT => X"2"
    )
    port map (
      I0 => fax4_ins_FIFO1_multi_read_ins_Result_5_1,
      I1 => fax4_ins_FIFO1_multi_read_ins_write_pos_cmp_eq0000,
      O => fax4_ins_FIFO1_multi_read_ins_Mcount_write_pos_eqn_5
    );
  fax4_ins_FIFO1_multi_read_ins_Mcount_read_pos_eqn_51 : LUT2
    generic map(
      INIT => X"2"
    )
    port map (
      I0 => fax4_ins_FIFO1_multi_read_ins_Result(5),
      I1 => fax4_ins_FIFO1_multi_read_ins_read_pos_cmp_eq0000,
      O => fax4_ins_FIFO1_multi_read_ins_Mcount_read_pos_eqn_5
    );
  fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt_mux0000_2_1 : LUT2
    generic map(
      INIT => X"2"
    )
    port map (
      I0 => fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt_addsub0000(6),
      I1 => fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt_cmp_ge0000,
      O => fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt_mux0000(2)
    );
  fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt_mux0000_3_1 : LUT2
    generic map(
      INIT => X"2"
    )
    port map (
      I0 => fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt_addsub0000(6),
      I1 => fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt_cmp_ge0000,
      O => fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt_mux0000(3)
    );
  fax4_ins_FIFO2_multi_read_ins_Mcount_write_pos_eqn_61 : LUT2
    generic map(
      INIT => X"2"
    )
    port map (
      I0 => fax4_ins_FIFO2_multi_read_ins_Result_6_1,
      I1 => fax4_ins_FIFO2_multi_read_ins_write_pos_cmp_eq0000,
      O => fax4_ins_FIFO2_multi_read_ins_Mcount_write_pos_eqn_6
    );
  fax4_ins_FIFO2_multi_read_ins_Mcount_read_pos_eqn_61 : LUT2
    generic map(
      INIT => X"2"
    )
    port map (
      I0 => fax4_ins_FIFO2_multi_read_ins_Result(6),
      I1 => fax4_ins_FIFO2_multi_read_ins_read_pos_cmp_eq0000,
      O => fax4_ins_FIFO2_multi_read_ins_Mcount_read_pos_eqn_6
    );
  fax4_ins_FIFO1_multi_read_ins_Mcount_write_pos_eqn_61 : LUT2
    generic map(
      INIT => X"2"
    )
    port map (
      I0 => fax4_ins_FIFO1_multi_read_ins_Result_6_1,
      I1 => fax4_ins_FIFO1_multi_read_ins_write_pos_cmp_eq0000,
      O => fax4_ins_FIFO1_multi_read_ins_Mcount_write_pos_eqn_6
    );
  fax4_ins_FIFO1_multi_read_ins_Mcount_read_pos_eqn_61 : LUT2
    generic map(
      INIT => X"2"
    )
    port map (
      I0 => fax4_ins_FIFO1_multi_read_ins_Result(6),
      I1 => fax4_ins_FIFO1_multi_read_ins_read_pos_cmp_eq0000,
      O => fax4_ins_FIFO1_multi_read_ins_Mcount_read_pos_eqn_6
    );
  fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt_mux0000_1_1 : LUT2
    generic map(
      INIT => X"2"
    )
    port map (
      I0 => fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt_addsub0000(7),
      I1 => fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt_cmp_ge0000,
      O => fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt_mux0000(1)
    );
  fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt_mux0000_2_1 : LUT2
    generic map(
      INIT => X"2"
    )
    port map (
      I0 => fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt_addsub0000(7),
      I1 => fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt_cmp_ge0000,
      O => fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt_mux0000(2)
    );
  fax4_ins_FIFO2_multi_read_ins_Mcount_write_pos_eqn_71 : LUT2
    generic map(
      INIT => X"2"
    )
    port map (
      I0 => fax4_ins_FIFO2_multi_read_ins_Result_7_1,
      I1 => fax4_ins_FIFO2_multi_read_ins_write_pos_cmp_eq0000,
      O => fax4_ins_FIFO2_multi_read_ins_Mcount_write_pos_eqn_7
    );
  fax4_ins_FIFO2_multi_read_ins_Mcount_read_pos_eqn_71 : LUT2
    generic map(
      INIT => X"2"
    )
    port map (
      I0 => fax4_ins_FIFO2_multi_read_ins_Result(7),
      I1 => fax4_ins_FIFO2_multi_read_ins_read_pos_cmp_eq0000,
      O => fax4_ins_FIFO2_multi_read_ins_Mcount_read_pos_eqn_7
    );
  fax4_ins_FIFO1_multi_read_ins_Mcount_write_pos_eqn_71 : LUT2
    generic map(
      INIT => X"2"
    )
    port map (
      I0 => fax4_ins_FIFO1_multi_read_ins_Result_7_1,
      I1 => fax4_ins_FIFO1_multi_read_ins_write_pos_cmp_eq0000,
      O => fax4_ins_FIFO1_multi_read_ins_Mcount_write_pos_eqn_7
    );
  fax4_ins_FIFO1_multi_read_ins_Mcount_read_pos_eqn_71 : LUT2
    generic map(
      INIT => X"2"
    )
    port map (
      I0 => fax4_ins_FIFO1_multi_read_ins_Result(7),
      I1 => fax4_ins_FIFO1_multi_read_ins_read_pos_cmp_eq0000,
      O => fax4_ins_FIFO1_multi_read_ins_Mcount_read_pos_eqn_7
    );
  fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt_mux0000_0_1 : LUT2
    generic map(
      INIT => X"2"
    )
    port map (
      I0 => fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt_addsub0000(8),
      I1 => fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt_cmp_ge0000,
      O => fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt_mux0000(0)
    );
  fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt_mux0000_1_1 : LUT2
    generic map(
      INIT => X"2"
    )
    port map (
      I0 => fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt_addsub0000(8),
      I1 => fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt_cmp_ge0000,
      O => fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt_mux0000(1)
    );
  fax4_ins_FIFO2_multi_read_ins_Mcount_write_pos_eqn_81 : LUT2
    generic map(
      INIT => X"2"
    )
    port map (
      I0 => fax4_ins_FIFO2_multi_read_ins_Result_8_1,
      I1 => fax4_ins_FIFO2_multi_read_ins_write_pos_cmp_eq0000,
      O => fax4_ins_FIFO2_multi_read_ins_Mcount_write_pos_eqn_8
    );
  fax4_ins_FIFO2_multi_read_ins_Mcount_read_pos_eqn_81 : LUT2
    generic map(
      INIT => X"2"
    )
    port map (
      I0 => fax4_ins_FIFO2_multi_read_ins_Result(8),
      I1 => fax4_ins_FIFO2_multi_read_ins_read_pos_cmp_eq0000,
      O => fax4_ins_FIFO2_multi_read_ins_Mcount_read_pos_eqn_8
    );
  fax4_ins_FIFO1_multi_read_ins_Mcount_write_pos_eqn_81 : LUT2
    generic map(
      INIT => X"2"
    )
    port map (
      I0 => fax4_ins_FIFO1_multi_read_ins_Result_8_1,
      I1 => fax4_ins_FIFO1_multi_read_ins_write_pos_cmp_eq0000,
      O => fax4_ins_FIFO1_multi_read_ins_Mcount_write_pos_eqn_8
    );
  fax4_ins_FIFO1_multi_read_ins_Mcount_read_pos_eqn_81 : LUT2
    generic map(
      INIT => X"2"
    )
    port map (
      I0 => fax4_ins_FIFO1_multi_read_ins_Result(8),
      I1 => fax4_ins_FIFO1_multi_read_ins_read_pos_cmp_eq0000,
      O => fax4_ins_FIFO1_multi_read_ins_Mcount_read_pos_eqn_8
    );
  fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt_mux0000_0_1 : LUT2
    generic map(
      INIT => X"2"
    )
    port map (
      I0 => fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt_addsub0000(9),
      I1 => fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt_cmp_ge0000,
      O => fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt_mux0000(0)
    );
  fax4_ins_FIFO2_multi_read_ins_Mcount_write_pos_eqn_91 : LUT2
    generic map(
      INIT => X"2"
    )
    port map (
      I0 => fax4_ins_FIFO2_multi_read_ins_Result_9_1,
      I1 => fax4_ins_FIFO2_multi_read_ins_write_pos_cmp_eq0000,
      O => fax4_ins_FIFO2_multi_read_ins_Mcount_write_pos_eqn_9
    );
  fax4_ins_FIFO2_multi_read_ins_Mcount_read_pos_eqn_91 : LUT2
    generic map(
      INIT => X"2"
    )
    port map (
      I0 => fax4_ins_FIFO2_multi_read_ins_Result(9),
      I1 => fax4_ins_FIFO2_multi_read_ins_read_pos_cmp_eq0000,
      O => fax4_ins_FIFO2_multi_read_ins_Mcount_read_pos_eqn_9
    );
  fax4_ins_FIFO1_multi_read_ins_Mcount_write_pos_eqn_91 : LUT2
    generic map(
      INIT => X"2"
    )
    port map (
      I0 => fax4_ins_FIFO1_multi_read_ins_Result_9_1,
      I1 => fax4_ins_FIFO1_multi_read_ins_write_pos_cmp_eq0000,
      O => fax4_ins_FIFO1_multi_read_ins_Mcount_write_pos_eqn_9
    );
  fax4_ins_FIFO1_multi_read_ins_Mcount_read_pos_eqn_91 : LUT2
    generic map(
      INIT => X"2"
    )
    port map (
      I0 => fax4_ins_FIFO1_multi_read_ins_Result(9),
      I1 => fax4_ins_FIFO1_multi_read_ins_read_pos_cmp_eq0000,
      O => fax4_ins_FIFO1_multi_read_ins_Mcount_read_pos_eqn_9
    );
  huffman_ins_v2_hor_code_10_mux0003151 : LUT3
    generic map(
      INIT => X"10"
    )
    port map (
      I0 => huffman_ins_v2_Madd_hor_code_width_addsub0000_cy(0),
      I1 => huffman_ins_v2_Madd_hor_code_width_addsub0000_lut(2),
      I2 => huffman_ins_v2_mux_code_white_width(1),
      O => huffman_ins_v2_N232
    );
  huffman_ins_v2_hor_code_width_mux0001_3_1 : LUT4
    generic map(
      INIT => X"EB41"
    )
    port map (
      I0 => huffman_ins_v2_horizontal_mode_part_2_2065,
      I1 => huffman_ins_v2_Madd_hor_code_width_addsub0000_lut(3),
      I2 => huffman_ins_v2_N170,
      I3 => huffman_ins_v2_mux_code_black_width(3),
      O => huffman_ins_v2_hor_code_width_mux0001(3)
    );
  huffman_ins_v2_hor_code_8_mux0003111 : LUT3
    generic map(
      INIT => X"08"
    )
    port map (
      I0 => huffman_ins_v2_mux_code_black_width(3),
      I1 => huffman_ins_v2_mux_code_black_width(1),
      I2 => huffman_ins_v2_mux_code_black_width(4),
      O => huffman_ins_v2_N87
    );
  huffman_ins_v2_code_white_3_mux00001 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => huffman_ins_v2_code_white_8_or0000,
      I1 => huffman_ins_v2_ter_white_code(3),
      I2 => huffman_ins_v2_code_white(3),
      O => huffman_ins_v2_code_white_3_mux0000
    );
  huffman_ins_v2_code_white_2_mux00001 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => huffman_ins_v2_code_white_8_or0000,
      I1 => huffman_ins_v2_ter_white_code(2),
      I2 => huffman_ins_v2_code_white(2),
      O => huffman_ins_v2_code_white_2_mux0000
    );
  huffman_ins_v2_code_white_1_mux00001 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => huffman_ins_v2_code_white_8_or0000,
      I1 => huffman_ins_v2_ter_white_code(1),
      I2 => huffman_ins_v2_code_white(1),
      O => huffman_ins_v2_code_white_1_mux0000
    );
  huffman_ins_v2_code_white_0_mux00001 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => huffman_ins_v2_code_white_8_or0000,
      I1 => huffman_ins_v2_ter_white_code(0),
      I2 => huffman_ins_v2_code_white(0),
      O => huffman_ins_v2_code_white_0_mux0000
    );
  huffman_ins_v2_code_white_16_mux00001 : LUT4
    generic map(
      INIT => X"F888"
    )
    port map (
      I0 => huffman_ins_v2_code_white_8_cmp_eq0004,
      I1 => huffman_ins_v2_code_table_ins_makeup_white(8),
      I2 => huffman_ins_v2_code_white_8_or0000,
      I3 => huffman_ins_v2_code_white(16),
      O => huffman_ins_v2_code_white_16_mux0000
    );
  huffman_ins_v2_hor_code_14_mux0003281 : LUT2
    generic map(
      INIT => X"7"
    )
    port map (
      I0 => huffman_ins_v2_code_white_width(2),
      I1 => huffman_ins_v2_code_white_width(3),
      O => huffman_ins_v2_N223
    );
  huffman_ins_v2_hor_code_14_mux0003271 : LUT2
    generic map(
      INIT => X"7"
    )
    port map (
      I0 => huffman_ins_v2_code_black_width(2),
      I1 => huffman_ins_v2_code_black_width(3),
      O => huffman_ins_v2_N203
    );
  huffman_ins_v2_hor_code_14_mux0003221 : LUT2
    generic map(
      INIT => X"1"
    )
    port map (
      I0 => huffman_ins_v2_a0_value_2_1510,
      I1 => huffman_ins_v2_horizontal_mode_part_2_2065,
      O => huffman_ins_v2_N103
    );
  huffman_ins_v2_hor_code_10_mux000381 : LUT2
    generic map(
      INIT => X"8"
    )
    port map (
      I0 => huffman_ins_v2_a0_value_2_1510,
      I1 => huffman_ins_v2_horizontal_mode_part_2_2065,
      O => huffman_ins_v2_N107
    );
  huffman_ins_v2_hor_code_14_mux000311 : LUT2
    generic map(
      INIT => X"9"
    )
    port map (
      I0 => huffman_ins_v2_a0_value_2_1510,
      I1 => huffman_ins_v2_horizontal_mode_part_2_2065,
      O => huffman_ins_v2_N11
    );
  huffman_ins_v2_code_white_4_mux000016 : LUT3
    generic map(
      INIT => X"10"
    )
    port map (
      I0 => huffman_ins_v2_codetab_ter_white_width(1),
      I1 => huffman_ins_v2_codetab_ter_white_width(3),
      I2 => huffman_ins_v2_codetab_ter_white_width(2),
      O => huffman_ins_v2_code_white_4_mux000016_1765
    );
  huffman_ins_v2_code_white_4_mux000039 : LUT3
    generic map(
      INIT => X"C8"
    )
    port map (
      I0 => huffman_ins_v2_code_white_8_cmp_eq0004,
      I1 => huffman_ins_v2_ter_white_code(4),
      I2 => huffman_ins_v2_N239,
      O => huffman_ins_v2_code_white_4_mux000039_1769
    );
  huffman_ins_v2_code_white_5_mux000039 : LUT3
    generic map(
      INIT => X"C8"
    )
    port map (
      I0 => huffman_ins_v2_code_white_8_cmp_eq0004,
      I1 => huffman_ins_v2_ter_white_code(5),
      I2 => huffman_ins_v2_N239,
      O => huffman_ins_v2_code_white_5_mux000039_1774
    );
  huffman_ins_v2_horizontal_mode_1_cmp_eq000111 : LUT3
    generic map(
      INIT => X"10"
    )
    port map (
      I0 => fax4_ins_mode_indicator_o(1),
      I1 => fax4_ins_mode_indicator_o(2),
      I2 => fax4_ins_mode_indicator_o(3),
      O => huffman_ins_v2_horizontal_mode_1_or0000
    );
  huffman_ins_v2_hor_code_0_mux0003111 : LUT4
    generic map(
      INIT => X"FFFE"
    )
    port map (
      I0 => huffman_ins_v2_mux_code_black_width(1),
      I1 => huffman_ins_v2_mux_code_black_width(0),
      I2 => huffman_ins_v2_mux_code_black_width(3),
      I3 => huffman_ins_v2_mux_code_black_width(2),
      O => huffman_ins_v2_N89
    );
  huffman_ins_v2_hor_code_23_mux00039 : LUT4
    generic map(
      INIT => X"F020"
    )
    port map (
      I0 => huffman_ins_v2_N244,
      I1 => huffman_ins_v2_a0_value_2_1510,
      I2 => huffman_ins_v2_code_black(23),
      I3 => huffman_ins_v2_N228,
      O => huffman_ins_v2_hor_code_23_mux00039_1971
    );
  huffman_ins_v2_hor_code_23_mux000322 : LUT4
    generic map(
      INIT => X"1000"
    )
    port map (
      I0 => huffman_ins_v2_Madd_hor_code_width_addsub0000_lut(3),
      I1 => huffman_ins_v2_hor_code_13_or0005,
      I2 => huffman_ins_v2_N102,
      I3 => huffman_ins_v2_Madd_hor_code_width_addsub0000_cy(0),
      O => huffman_ins_v2_hor_code_23_mux000322_1968
    );
  huffman_ins_v2_hor_code_24_mux000312 : LUT4
    generic map(
      INIT => X"22A2"
    )
    port map (
      I0 => huffman_ins_v2_N244,
      I1 => huffman_ins_v2_Madd_hor_code_width_addsub0000_cy(0),
      I2 => huffman_ins_v2_code_black(24),
      I3 => huffman_ins_v2_a0_value_2_1510,
      O => huffman_ins_v2_hor_code_24_mux000312_1973
    );
  huffman_ins_v2_hor_code_24_mux000348 : LUT3
    generic map(
      INIT => X"F1"
    )
    port map (
      I0 => huffman_ins_v2_Madd_hor_code_width_addsub0000_lut(3),
      I1 => huffman_ins_v2_mux_code_white_width(1),
      I2 => huffman_ins_v2_N3,
      O => huffman_ins_v2_hor_code_24_mux000348_1976
    );
  huffman_ins_v2_hor_code_24_mux000371 : LUT4
    generic map(
      INIT => X"A820"
    )
    port map (
      I0 => huffman_ins_v2_hor_code(24),
      I1 => huffman_ins_v2_horizontal_mode_part_2_2065,
      I2 => huffman_ins_v2_hor_code_24_mux000348_1976,
      I3 => huffman_ins_v2_hor_code_24_mux000335_1975,
      O => huffman_ins_v2_hor_code_24_mux000371_1977
    );
  huffman_ins_v2_hor_code_15_mux0003211 : LUT4
    generic map(
      INIT => X"32FA"
    )
    port map (
      I0 => huffman_ins_v2_hor_code_15_mux00038_1893,
      I1 => huffman_ins_v2_mux_code_black_width(3),
      I2 => huffman_ins_v2_hor_code_15_mux00035_1888,
      I3 => huffman_ins_v2_N99,
      O => huffman_ins_v2_hor_code_15_mux000321
    );
  huffman_ins_v2_hor_code_15_mux0003122 : LUT4
    generic map(
      INIT => X"2822"
    )
    port map (
      I0 => huffman_ins_v2_hor_code(15),
      I1 => huffman_ins_v2_Madd_hor_code_width_addsub0000_lut(4),
      I2 => huffman_ins_v2_N98,
      I3 => huffman_ins_v2_Madd_hor_code_width_addsub0000_cy(1),
      O => huffman_ins_v2_hor_code_15_mux0003122_1884
    );
  huffman_ins_v2_hor_code_14_mux00038 : LUT3
    generic map(
      INIT => X"1F"
    )
    port map (
      I0 => huffman_ins_v2_code_black_width(1),
      I1 => huffman_ins_v2_code_black_width(2),
      I2 => huffman_ins_v2_code_black_width(3),
      O => huffman_ins_v2_hor_code_14_mux00038_1882
    );
  huffman_ins_v2_hor_code_14_mux000327 : LUT3
    generic map(
      INIT => X"1F"
    )
    port map (
      I0 => huffman_ins_v2_code_white_width(1),
      I1 => huffman_ins_v2_code_white_width(2),
      I2 => huffman_ins_v2_code_white_width(3),
      O => huffman_ins_v2_hor_code_14_mux000327_1876
    );
  huffman_ins_v2_hor_code_14_mux0003139 : LUT4
    generic map(
      INIT => X"FFEA"
    )
    port map (
      I0 => huffman_ins_v2_hor_code_14_mux000343_1879,
      I1 => huffman_ins_v2_hor_code_14_mux000371_1880,
      I2 => huffman_ins_v2_hor_code_14_mux000379_1881,
      I3 => huffman_ins_v2_hor_code_14_mux0003126_1866,
      O => huffman_ins_v2_hor_code_14_mux0003139_1867
    );
  huffman_ins_v2_hor_code_14_mux0003186 : LUT4
    generic map(
      INIT => X"22F2"
    )
    port map (
      I0 => huffman_ins_v2_hor_code_14_mux0003155_1868,
      I1 => huffman_ins_v2_code_black_width(4),
      I2 => huffman_ins_v2_hor_code_14_mux0003173_1869,
      I3 => huffman_ins_v2_code_white_width(4),
      O => huffman_ins_v2_hor_code_14_mux0003186_1870
    );
  huffman_ins_v2_hor_code_14_mux0003227 : LUT4
    generic map(
      INIT => X"0F08"
    )
    port map (
      I0 => huffman_ins_v2_code_white_width(0),
      I1 => huffman_ins_v2_hor_code_14_mux0003203_1871,
      I2 => huffman_ins_v2_N223,
      I3 => huffman_ins_v2_hor_code_14_mux0003213_1872,
      O => huffman_ins_v2_hor_code_14_mux0003227_1873
    );
  huffman_ins_v2_hor_code_14_mux0003277 : LUT4
    generic map(
      INIT => X"0F08"
    )
    port map (
      I0 => huffman_ins_v2_code_black_width(0),
      I1 => huffman_ins_v2_hor_code_14_mux0003256_1874,
      I2 => huffman_ins_v2_N203,
      I3 => huffman_ins_v2_hor_code_14_mux0003264_1875,
      O => huffman_ins_v2_hor_code_14_mux0003277_1877
    );
  huffman_ins_v2_hor_code_14_mux0003301 : LUT4
    generic map(
      INIT => X"CCC8"
    )
    port map (
      I0 => huffman_ins_v2_hor_code_14_mux0003186_1870,
      I1 => huffman_ins_v2_hor_code(14),
      I2 => huffman_ins_v2_hor_code_14_mux0003227_1873,
      I3 => huffman_ins_v2_hor_code_14_mux0003277_1877,
      O => huffman_ins_v2_hor_code_14_mux0003301_1878
    );
  huffman_ins_v2_code_white_8_cmp_eq00041 : LUT4
    generic map(
      INIT => X"0010"
    )
    port map (
      I0 => huffman_ins_v2_codetab_ter_white_width(1),
      I1 => huffman_ins_v2_codetab_ter_white_width(0),
      I2 => huffman_ins_v2_codetab_ter_white_width(3),
      I3 => huffman_ins_v2_codetab_ter_white_width(2),
      O => huffman_ins_v2_code_white_8_cmp_eq0004
    );
  huffman_ins_v2_code_white_8_cmp_eq00011 : LUT4
    generic map(
      INIT => X"1000"
    )
    port map (
      I0 => huffman_ins_v2_codetab_ter_white_width(1),
      I1 => huffman_ins_v2_codetab_ter_white_width(3),
      I2 => huffman_ins_v2_codetab_ter_white_width(2),
      I3 => huffman_ins_v2_codetab_ter_white_width(0),
      O => huffman_ins_v2_code_white_8_cmp_eq0001
    );
  huffman_ins_v2_code_white_15_mux0000_SW0 : LUT4
    generic map(
      INIT => X"F888"
    )
    port map (
      I0 => huffman_ins_v2_code_white_8_or0000,
      I1 => huffman_ins_v2_code_white(15),
      I2 => huffman_ins_v2_code_table_ins_makeup_white(7),
      I3 => huffman_ins_v2_code_white_8_cmp_eq0004,
      O => N7
    );
  huffman_ins_v2_code_black_24_mux00001_SW0 : LUT2
    generic map(
      INIT => X"D"
    )
    port map (
      I0 => huffman_ins_v2_code_black(24),
      I1 => huffman_ins_v2_codetab_ter_black_width(1),
      O => N9
    );
  huffman_ins_v2_code_black_24_mux00001_SW1 : LUT4
    generic map(
      INIT => X"ABA8"
    )
    port map (
      I0 => huffman_ins_v2_code_black(24),
      I1 => huffman_ins_v2_codetab_ter_black_width(1),
      I2 => huffman_ins_v2_codetab_ter_black_width(0),
      I3 => huffman_ins_v2_code_table_ins_makeup_black_8_Q,
      O => N10
    );
  huffman_ins_v2_code_black_24_mux00001 : LUT4
    generic map(
      INIT => X"8901"
    )
    port map (
      I0 => huffman_ins_v2_codetab_ter_black_width(3),
      I1 => huffman_ins_v2_codetab_ter_black_width(2),
      I2 => N9,
      I3 => N10,
      O => huffman_ins_v2_code_black_24_mux0000
    );
  fax4_ins_frame_finished_o1 : LUT2
    generic map(
      INIT => X"E"
    )
    port map (
      I0 => fax4_ins_state_FSM_FFd1_1322,
      I1 => fax4_ins_state_FSM_FFd4_1331,
      O => frame_finished_wire
    );
  huffman_ins_v2_hor_code_4_mux000331 : LUT3
    generic map(
      INIT => X"1F"
    )
    port map (
      I0 => huffman_ins_v2_mux_code_black_width(1),
      I1 => huffman_ins_v2_mux_code_black_width(0),
      I2 => huffman_ins_v2_mux_code_black_width(2),
      O => huffman_ins_v2_N71
    );
  huffman_ins_v2_hor_code_19_mux000311 : LUT4
    generic map(
      INIT => X"AEFF"
    )
    port map (
      I0 => huffman_ins_v2_N246,
      I1 => huffman_ins_v2_Madd_hor_code_width_addsub0000_cy(1),
      I2 => huffman_ins_v2_N98,
      I3 => huffman_ins_v2_Madd_hor_code_width_addsub0000_lut(4),
      O => huffman_ins_v2_N3
    );
  huffman_ins_v2_hor_code_18_mux0003321 : LUT4
    generic map(
      INIT => X"AF2F"
    )
    port map (
      I0 => huffman_ins_v2_mux_code_black_width(3),
      I1 => huffman_ins_v2_N78,
      I2 => huffman_ins_v2_mux_code_black_width(4),
      I3 => huffman_ins_v2_N250,
      O => huffman_ins_v2_N186
    );
  huffman_ins_v2_hor_code_15_mux00032_SW0 : LUT3
    generic map(
      INIT => X"27"
    )
    port map (
      I0 => huffman_ins_v2_a0_value_2_1510,
      I1 => huffman_ins_v2_code_black_width(4),
      I2 => huffman_ins_v2_code_white_width(4),
      O => N12
    );
  huffman_ins_v2_hor_code_15_mux00032 : LUT3
    generic map(
      INIT => X"EA"
    )
    port map (
      I0 => N12,
      I1 => huffman_ins_v2_N251,
      I2 => huffman_ins_v2_mux_code_black_width(3),
      O => huffman_ins_v2_N65
    );
  huffman_ins_v2_hor_code_7_mux00035 : LUT4
    generic map(
      INIT => X"FFEA"
    )
    port map (
      I0 => huffman_ins_v2_N166,
      I1 => huffman_ins_v2_N100,
      I2 => huffman_ins_v2_N170,
      I3 => huffman_ins_v2_N105,
      O => huffman_ins_v2_hor_code_7_mux00035_2024
    );
  huffman_ins_v2_hor_code_7_mux000324 : LUT4
    generic map(
      INIT => X"0E04"
    )
    port map (
      I0 => huffman_ins_v2_a0_value_2_1510,
      I1 => huffman_ins_v2_code_black(7),
      I2 => huffman_ins_v2_horizontal_mode_part_2_2065,
      I3 => huffman_ins_v2_code_white(7),
      O => huffman_ins_v2_hor_code_7_mux000324_2022
    );
  huffman_ins_v2_hor_code_7_mux000356 : LUT4
    generic map(
      INIT => X"A820"
    )
    port map (
      I0 => huffman_ins_v2_horizontal_mode_part_2_2065,
      I1 => huffman_ins_v2_a0_value_2_1510,
      I2 => huffman_ins_v2_code_white(7),
      I3 => huffman_ins_v2_code_black(7),
      O => huffman_ins_v2_hor_code_7_mux000356_2025
    );
  huffman_ins_v2_hor_code_7_mux000370 : LUT3
    generic map(
      INIT => X"EA"
    )
    port map (
      I0 => huffman_ins_v2_hor_code_7_mux000368_2026,
      I1 => huffman_ins_v2_N48,
      I2 => huffman_ins_v2_hor_code_7_mux000356_2025,
      O => huffman_ins_v2_hor_code_7_mux000370_2027
    );
  huffman_ins_v2_hor_code_25_mux000342 : LUT4
    generic map(
      INIT => X"3F1F"
    )
    port map (
      I0 => huffman_ins_v2_Madd_hor_code_width_addsub0000_cy(0),
      I1 => huffman_ins_v2_Madd_hor_code_width_addsub0000_lut(3),
      I2 => huffman_ins_v2_Madd_hor_code_width_addsub0000_lut(4),
      I3 => huffman_ins_v2_hor_code_13_or0005,
      O => huffman_ins_v2_hor_code_25_mux000342_1981
    );
  huffman_ins_v2_hor_code_11_mux000338 : LUT4
    generic map(
      INIT => X"FFFE"
    )
    port map (
      I0 => huffman_ins_v2_N166,
      I1 => huffman_ins_v2_N105,
      I2 => huffman_ins_v2_N100,
      I3 => huffman_ins_v2_hor_code_11_mux000321_1833,
      O => huffman_ins_v2_hor_code_11_mux000338_1834
    );
  huffman_ins_v2_hor_code_11_mux000373 : LUT4
    generic map(
      INIT => X"0E04"
    )
    port map (
      I0 => huffman_ins_v2_a0_value_2_1510,
      I1 => huffman_ins_v2_code_black(11),
      I2 => huffman_ins_v2_horizontal_mode_part_2_2065,
      I3 => huffman_ins_v2_code_white(11),
      O => huffman_ins_v2_hor_code_11_mux000373_1835
    );
  huffman_ins_v2_hor_code_11_mux00031211 : LUT4
    generic map(
      INIT => X"2000"
    )
    port map (
      I0 => huffman_ins_v2_Madd_hor_code_width_addsub0000_lut(3),
      I1 => huffman_ins_v2_Madd_hor_code_width_addsub0000_lut(2),
      I2 => huffman_ins_v2_Madd_hor_code_width_addsub0000_cy(0),
      I3 => huffman_ins_v2_mux_code_white_width(1),
      O => huffman_ins_v2_hor_code_11_mux0003121
    );
  huffman_ins_v2_hor_code_17_mux000350 : LUT4
    generic map(
      INIT => X"1000"
    )
    port map (
      I0 => huffman_ins_v2_Madd_hor_code_width_addsub0000_lut(3),
      I1 => huffman_ins_v2_N59,
      I2 => huffman_ins_v2_N102,
      I3 => huffman_ins_v2_Madd_hor_code_width_addsub0000_cy(0),
      O => huffman_ins_v2_hor_code_17_mux000350_1909
    );
  huffman_ins_v2_hor_code_17_mux000353 : LUT4
    generic map(
      INIT => X"FFA8"
    )
    port map (
      I0 => huffman_ins_v2_code_black(17),
      I1 => huffman_ins_v2_hor_code_17_mux000316_1907,
      I2 => huffman_ins_v2_hor_code_17_mux000319_1908,
      I3 => huffman_ins_v2_hor_code_17_mux000350_1909,
      O => huffman_ins_v2_hor_code_17_mux000353_1910
    );
  huffman_ins_v2_hor_code_17_mux0003110 : LUT4
    generic map(
      INIT => X"313B"
    )
    port map (
      I0 => huffman_ins_v2_Madd_hor_code_width_addsub0000_lut(3),
      I1 => huffman_ins_v2_Madd_hor_code_width_addsub0000_lut(4),
      I2 => huffman_ins_v2_hor_code_13_or0005,
      I3 => huffman_ins_v2_Madd_hor_code_width_addsub0000_cy(0),
      O => huffman_ins_v2_hor_code_17_mux0003110_1904
    );
  huffman_ins_v2_hor_code_10_mux000359 : LUT4
    generic map(
      INIT => X"A820"
    )
    port map (
      I0 => huffman_ins_v2_horizontal_mode_part_2_2065,
      I1 => huffman_ins_v2_a0_value_2_1510,
      I2 => huffman_ins_v2_code_white(10),
      I3 => huffman_ins_v2_code_black(10),
      O => huffman_ins_v2_hor_code_10_mux000359_1824
    );
  huffman_ins_v2_hor_code_10_mux000362 : LUT4
    generic map(
      INIT => X"AA80"
    )
    port map (
      I0 => huffman_ins_v2_hor_code_10_mux000359_1824,
      I1 => huffman_ins_v2_mux_code_black_width(0),
      I2 => huffman_ins_v2_N87,
      I3 => huffman_ins_v2_N62,
      O => huffman_ins_v2_hor_code_10_mux000362_1825
    );
  huffman_ins_v2_hor_code_10_mux000369 : LUT3
    generic map(
      INIT => X"EA"
    )
    port map (
      I0 => huffman_ins_v2_hor_code_10_mux000362_1825,
      I1 => huffman_ins_v2_hor_code(10),
      I2 => huffman_ins_v2_hor_code_10_mux000329_1823,
      O => huffman_ins_v2_hor_code_10_mux000369_1826
    );
  huffman_ins_v2_hor_code_10_mux000393 : LUT4
    generic map(
      INIT => X"A820"
    )
    port map (
      I0 => huffman_ins_v2_N38,
      I1 => huffman_ins_v2_a0_value_2_1510,
      I2 => huffman_ins_v2_code_black(10),
      I3 => huffman_ins_v2_code_white(10),
      O => huffman_ins_v2_hor_code_10_mux000393_1827
    );
  huffman_ins_v2_hor_code_10_mux000399 : LUT3
    generic map(
      INIT => X"08"
    )
    port map (
      I0 => huffman_ins_v2_N232,
      I1 => huffman_ins_v2_Madd_hor_code_width_addsub0000_lut(3),
      I2 => huffman_ins_v2_Madd_hor_code_width_addsub0000_lut(4),
      O => huffman_ins_v2_hor_code_10_mux000399_1828
    );
  huffman_ins_v2_hor_code_10_mux0003112 : LUT3
    generic map(
      INIT => X"32"
    )
    port map (
      I0 => huffman_ins_v2_hor_code_10_mux000399_1828,
      I1 => huffman_ins_v2_horizontal_mode_part_2_2065,
      I2 => huffman_ins_v2_hor_code_10_mux000393_1827,
      O => huffman_ins_v2_hor_code_10_mux0003112_1822
    );
  huffman_ins_v2_hor_code_9_mux000313 : LUT4
    generic map(
      INIT => X"2AAA"
    )
    port map (
      I0 => huffman_ins_v2_N100,
      I1 => huffman_ins_v2_Madd_hor_code_width_addsub0000_lut(2),
      I2 => huffman_ins_v2_Madd_hor_code_width_addsub0000_cy(0),
      I3 => huffman_ins_v2_mux_code_white_width(1),
      O => huffman_ins_v2_hor_code_9_mux000313_2042
    );
  huffman_ins_v2_hor_code_9_mux000342 : LUT4
    generic map(
      INIT => X"CCC8"
    )
    port map (
      I0 => huffman_ins_v2_N166,
      I1 => huffman_ins_v2_hor_code(9),
      I2 => huffman_ins_v2_hor_code_9_mux000313_2042,
      I3 => huffman_ins_v2_hor_code_9_mux000320_2044,
      O => huffman_ins_v2_hor_code_9_mux000342_2045
    );
  huffman_ins_v2_hor_code_9_mux000398 : LUT4
    generic map(
      INIT => X"A820"
    )
    port map (
      I0 => huffman_ins_v2_N38,
      I1 => huffman_ins_v2_a0_value_2_1510,
      I2 => huffman_ins_v2_code_black(9),
      I3 => huffman_ins_v2_code_white(9),
      O => huffman_ins_v2_hor_code_9_mux000398_2049
    );
  huffman_ins_v2_hor_code_9_mux0003114 : LUT4
    generic map(
      INIT => X"1000"
    )
    port map (
      I0 => huffman_ins_v2_Madd_hor_code_width_addsub0000_lut(4),
      I1 => huffman_ins_v2_mux_code_white_width(1),
      I2 => huffman_ins_v2_hor_code_9_mux0003104_2040,
      I3 => huffman_ins_v2_Madd_hor_code_width_addsub0000_lut(3),
      O => huffman_ins_v2_hor_code_9_mux0003114_2041
    );
  huffman_ins_v2_hor_code_8_mux000313 : LUT4
    generic map(
      INIT => X"020A"
    )
    port map (
      I0 => huffman_ins_v2_N109,
      I1 => huffman_ins_v2_mux_code_white_width(1),
      I2 => huffman_ins_v2_Madd_hor_code_width_addsub0000_lut(3),
      I3 => huffman_ins_v2_Madd_hor_code_width_addsub0000_lut(2),
      O => huffman_ins_v2_hor_code_8_mux000313_2031
    );
  huffman_ins_v2_hor_code_8_mux000341 : LUT4
    generic map(
      INIT => X"FFFE"
    )
    port map (
      I0 => huffman_ins_v2_N166,
      I1 => huffman_ins_v2_N105,
      I2 => huffman_ins_v2_hor_code_8_mux000313_2031,
      I3 => huffman_ins_v2_hor_code_8_mux000327_2035,
      O => huffman_ins_v2_hor_code_8_mux000341_2036
    );
  huffman_ins_v2_hor_code_8_mux000390 : LUT4
    generic map(
      INIT => X"A820"
    )
    port map (
      I0 => huffman_ins_v2_horizontal_mode_part_2_2065,
      I1 => huffman_ins_v2_a0_value_2_1510,
      I2 => huffman_ins_v2_code_white(8),
      I3 => huffman_ins_v2_code_black(8),
      O => huffman_ins_v2_hor_code_8_mux000390_2037
    );
  huffman_ins_v2_hor_code_8_mux0003129 : LUT4
    generic map(
      INIT => X"0E04"
    )
    port map (
      I0 => huffman_ins_v2_a0_value_2_1510,
      I1 => huffman_ins_v2_code_black(8),
      I2 => huffman_ins_v2_horizontal_mode_part_2_2065,
      I3 => huffman_ins_v2_code_white(8),
      O => huffman_ins_v2_hor_code_8_mux0003129_2030
    );
  huffman_ins_v2_hor_code_8_mux0003149 : LUT4
    generic map(
      INIT => X"1000"
    )
    port map (
      I0 => huffman_ins_v2_Madd_hor_code_width_addsub0000_lut(2),
      I1 => huffman_ins_v2_Madd_hor_code_width_addsub0000_cy(1),
      I2 => huffman_ins_v2_N109,
      I3 => huffman_ins_v2_Madd_hor_code_width_addsub0000_lut(3),
      O => huffman_ins_v2_hor_code_8_mux0003149_2032
    );
  huffman_ins_v2_hor_code_8_mux0003151 : LUT3
    generic map(
      INIT => X"EA"
    )
    port map (
      I0 => huffman_ins_v2_hor_code_8_mux0003149_2032,
      I1 => huffman_ins_v2_N51,
      I2 => huffman_ins_v2_hor_code_8_mux0003129_2030,
      O => huffman_ins_v2_hor_code_8_mux0003151_2033
    );
  huffman_ins_v2_hor_code_18_mux000346 : LUT3
    generic map(
      INIT => X"C8"
    )
    port map (
      I0 => huffman_ins_v2_N186,
      I1 => huffman_ins_v2_horizontal_mode_part_2_2065,
      I2 => huffman_ins_v2_hor_code_18_mux000328_1921,
      O => huffman_ins_v2_hor_code_18_mux000346_1922
    );
  huffman_ins_v2_hor_code_18_mux0003127 : LUT4
    generic map(
      INIT => X"1000"
    )
    port map (
      I0 => huffman_ins_v2_Madd_hor_code_width_addsub0000_cy(0),
      I1 => huffman_ins_v2_horizontal_mode_part_2_2065,
      I2 => huffman_ins_v2_hor_code_18_and0001,
      I3 => huffman_ins_v2_mux_code_white_width(1),
      O => huffman_ins_v2_hor_code_18_mux0003127_1915
    );
  huffman_ins_v2_hor_code_18_mux0003130 : LUT4
    generic map(
      INIT => X"FFA8"
    )
    port map (
      I0 => huffman_ins_v2_hor_code(18),
      I1 => huffman_ins_v2_hor_code_18_mux000346_1922,
      I2 => huffman_ins_v2_hor_code_18_mux000381_1923,
      I3 => huffman_ins_v2_hor_code_18_mux0003127_1915,
      O => huffman_ins_v2_hor_code_18_mux0003130_1916
    );
  huffman_ins_v2_hor_code_18_mux0003181 : LUT4
    generic map(
      INIT => X"E444"
    )
    port map (
      I0 => huffman_ins_v2_hor_code_18_and0001,
      I1 => huffman_ins_v2_N245,
      I2 => huffman_ins_v2_N103,
      I3 => huffman_ins_v2_mux_code_white_width(1),
      O => huffman_ins_v2_hor_code_18_mux0003181_1918
    );
  huffman_ins_v2_hor_code_18_mux0003230 : LUT4
    generic map(
      INIT => X"AA80"
    )
    port map (
      I0 => huffman_ins_v2_code_black(18),
      I1 => huffman_ins_v2_hor_code_18_mux0003181_1918,
      I2 => huffman_ins_v2_hor_code_18_mux0003199_1919,
      I3 => huffman_ins_v2_hor_code_18_mux0003164_1917,
      O => huffman_ins_v2_hor_code_18_mux0003230_1920
    );
  huffman_ins_v2_code_white_8_cmp_eq000211 : LUT3
    generic map(
      INIT => X"08"
    )
    port map (
      I0 => huffman_ins_v2_codetab_ter_white_width(2),
      I1 => huffman_ins_v2_codetab_ter_white_width(1),
      I2 => huffman_ins_v2_codetab_ter_white_width(3),
      O => huffman_ins_v2_N239
    );
  huffman_ins_v2_code_white_8_cmp_eq00001 : LUT4
    generic map(
      INIT => X"0010"
    )
    port map (
      I0 => huffman_ins_v2_codetab_ter_white_width(0),
      I1 => huffman_ins_v2_codetab_ter_white_width(1),
      I2 => huffman_ins_v2_codetab_ter_white_width(2),
      I3 => huffman_ins_v2_codetab_ter_white_width(3),
      O => huffman_ins_v2_code_white_8_cmp_eq0000
    );
  huffman_ins_v2_code_white_8_or00001 : LUT4
    generic map(
      INIT => X"DDD9"
    )
    port map (
      I0 => huffman_ins_v2_codetab_ter_white_width(2),
      I1 => huffman_ins_v2_codetab_ter_white_width(3),
      I2 => huffman_ins_v2_codetab_ter_white_width(1),
      I3 => huffman_ins_v2_codetab_ter_white_width(0),
      O => huffman_ins_v2_code_white_8_or0000
    );
  huffman_ins_v2_code_white_14_mux00004 : LUT4
    generic map(
      INIT => X"F888"
    )
    port map (
      I0 => huffman_ins_v2_code_white_8_or0000,
      I1 => huffman_ins_v2_code_white(14),
      I2 => huffman_ins_v2_code_white_8_cmp_eq0004,
      I3 => huffman_ins_v2_code_table_ins_makeup_white(6),
      O => huffman_ins_v2_code_white_14_mux00004_1754
    );
  huffman_ins_v2_code_white_6_mux00004 : LUT4
    generic map(
      INIT => X"F888"
    )
    port map (
      I0 => huffman_ins_v2_code_white_8_cmp_eq0000,
      I1 => huffman_ins_v2_code_table_ins_makeup_white(2),
      I2 => huffman_ins_v2_code_white(6),
      I3 => huffman_ins_v2_code_white_8_or0000,
      O => huffman_ins_v2_code_white_6_mux00004_1778
    );
  huffman_ins_v2_code_white_9_mux00004 : LUT4
    generic map(
      INIT => X"F888"
    )
    port map (
      I0 => huffman_ins_v2_code_white_8_cmp_eq0001,
      I1 => huffman_ins_v2_code_table_ins_makeup_white(4),
      I2 => huffman_ins_v2_code_white_8_cmp_eq0000,
      I3 => huffman_ins_v2_code_table_ins_makeup_white(5),
      O => huffman_ins_v2_code_white_9_mux00004_1796
    );
  huffman_ins_v2_code_white_9_mux00009 : LUT4
    generic map(
      INIT => X"F888"
    )
    port map (
      I0 => huffman_ins_v2_code_white_8_or0000,
      I1 => huffman_ins_v2_code_white(9),
      I2 => huffman_ins_v2_code_white_8_cmp_eq0004,
      I3 => huffman_ins_v2_code_table_ins_makeup_white(1),
      O => huffman_ins_v2_code_white_9_mux00009_1797
    );
  huffman_ins_v2_code_white_9_mux000010 : LUT2
    generic map(
      INIT => X"E"
    )
    port map (
      I0 => huffman_ins_v2_code_white_9_mux00004_1796,
      I1 => huffman_ins_v2_code_white_9_mux00009_1797,
      O => huffman_ins_v2_code_white_9_mux000010_1794
    );
  huffman_ins_v2_code_white_8_mux00004 : LUT4
    generic map(
      INIT => X"F888"
    )
    port map (
      I0 => huffman_ins_v2_code_white_8_cmp_eq0001,
      I1 => huffman_ins_v2_code_table_ins_makeup_white(3),
      I2 => huffman_ins_v2_code_white_8_cmp_eq0000,
      I3 => huffman_ins_v2_code_table_ins_makeup_white(4),
      O => huffman_ins_v2_code_white_8_mux00004_1790
    );
  huffman_ins_v2_code_white_8_mux00009 : LUT4
    generic map(
      INIT => X"F888"
    )
    port map (
      I0 => huffman_ins_v2_code_white_8_or0000,
      I1 => huffman_ins_v2_code_white(8),
      I2 => huffman_ins_v2_code_white_8_cmp_eq0004,
      I3 => huffman_ins_v2_code_table_ins_makeup_white(0),
      O => huffman_ins_v2_code_white_8_mux00009_1791
    );
  huffman_ins_v2_code_white_8_mux000010 : LUT2
    generic map(
      INIT => X"E"
    )
    port map (
      I0 => huffman_ins_v2_code_white_8_mux00004_1790,
      I1 => huffman_ins_v2_code_white_8_mux00009_1791,
      O => huffman_ins_v2_code_white_8_mux000010_1788
    );
  huffman_ins_v2_code_white_7_mux00004 : LUT4
    generic map(
      INIT => X"F888"
    )
    port map (
      I0 => huffman_ins_v2_code_white_8_cmp_eq0001,
      I1 => huffman_ins_v2_code_table_ins_makeup_white(2),
      I2 => huffman_ins_v2_code_white_8_cmp_eq0000,
      I3 => huffman_ins_v2_code_table_ins_makeup_white(3),
      O => huffman_ins_v2_code_white_7_mux00004_1782
    );
  huffman_ins_v2_code_white_7_mux00009 : LUT4
    generic map(
      INIT => X"F888"
    )
    port map (
      I0 => huffman_ins_v2_code_white_8_or0000,
      I1 => huffman_ins_v2_code_white(7),
      I2 => huffman_ins_v2_code_white_8_cmp_eq0004,
      I3 => huffman_ins_v2_ter_white_code(7),
      O => huffman_ins_v2_code_white_7_mux00009_1783
    );
  huffman_ins_v2_code_white_7_mux000010 : LUT2
    generic map(
      INIT => X"E"
    )
    port map (
      I0 => huffman_ins_v2_code_white_7_mux00004_1782,
      I1 => huffman_ins_v2_code_white_7_mux00009_1783,
      O => huffman_ins_v2_code_white_7_mux000010_1780
    );
  huffman_ins_v2_code_white_12_mux00004 : LUT4
    generic map(
      INIT => X"F888"
    )
    port map (
      I0 => huffman_ins_v2_code_white_8_cmp_eq0001,
      I1 => huffman_ins_v2_code_table_ins_makeup_white(7),
      I2 => huffman_ins_v2_code_white_8_cmp_eq0000,
      I3 => huffman_ins_v2_code_table_ins_makeup_white(8),
      O => huffman_ins_v2_code_white_12_mux00004_1747
    );
  huffman_ins_v2_code_white_12_mux00009 : LUT4
    generic map(
      INIT => X"F888"
    )
    port map (
      I0 => huffman_ins_v2_code_white_8_or0000,
      I1 => huffman_ins_v2_code_white(12),
      I2 => huffman_ins_v2_code_white_8_cmp_eq0004,
      I3 => huffman_ins_v2_code_table_ins_makeup_white(4),
      O => huffman_ins_v2_code_white_12_mux00009_1748
    );
  huffman_ins_v2_code_white_12_mux000010 : LUT2
    generic map(
      INIT => X"E"
    )
    port map (
      I0 => huffman_ins_v2_code_white_12_mux00004_1747,
      I1 => huffman_ins_v2_code_white_12_mux00009_1748,
      O => huffman_ins_v2_code_white_12_mux000010_1745
    );
  huffman_ins_v2_code_white_11_mux00004 : LUT4
    generic map(
      INIT => X"F888"
    )
    port map (
      I0 => huffman_ins_v2_code_white_8_cmp_eq0001,
      I1 => huffman_ins_v2_code_table_ins_makeup_white(6),
      I2 => huffman_ins_v2_code_white_8_cmp_eq0000,
      I3 => huffman_ins_v2_code_table_ins_makeup_white(7),
      O => huffman_ins_v2_code_white_11_mux00004_1742
    );
  huffman_ins_v2_code_white_11_mux00009 : LUT4
    generic map(
      INIT => X"F888"
    )
    port map (
      I0 => huffman_ins_v2_code_white_8_or0000,
      I1 => huffman_ins_v2_code_white(11),
      I2 => huffman_ins_v2_code_white_8_cmp_eq0004,
      I3 => huffman_ins_v2_code_table_ins_makeup_white(3),
      O => huffman_ins_v2_code_white_11_mux00009_1743
    );
  huffman_ins_v2_code_white_11_mux000010 : LUT2
    generic map(
      INIT => X"E"
    )
    port map (
      I0 => huffman_ins_v2_code_white_11_mux00004_1742,
      I1 => huffman_ins_v2_code_white_11_mux00009_1743,
      O => huffman_ins_v2_code_white_11_mux000010_1740
    );
  huffman_ins_v2_code_white_10_mux00004 : LUT4
    generic map(
      INIT => X"F888"
    )
    port map (
      I0 => huffman_ins_v2_code_white_8_cmp_eq0001,
      I1 => huffman_ins_v2_code_table_ins_makeup_white(5),
      I2 => huffman_ins_v2_code_white_8_cmp_eq0000,
      I3 => huffman_ins_v2_code_table_ins_makeup_white(6),
      O => huffman_ins_v2_code_white_10_mux00004_1737
    );
  huffman_ins_v2_code_white_10_mux00009 : LUT4
    generic map(
      INIT => X"F888"
    )
    port map (
      I0 => huffman_ins_v2_code_white_8_or0000,
      I1 => huffman_ins_v2_code_white(10),
      I2 => huffman_ins_v2_code_white_8_cmp_eq0004,
      I3 => huffman_ins_v2_code_table_ins_makeup_white(2),
      O => huffman_ins_v2_code_white_10_mux00009_1738
    );
  huffman_ins_v2_code_white_10_mux000010 : LUT2
    generic map(
      INIT => X"E"
    )
    port map (
      I0 => huffman_ins_v2_code_white_10_mux00004_1737,
      I1 => huffman_ins_v2_code_white_10_mux00009_1738,
      O => huffman_ins_v2_code_white_10_mux000010_1735
    );
  fax4_ins_state_FSM_FFd5_In5 : LUT4
    generic map(
      INIT => X"CCC8"
    )
    port map (
      I0 => fax4_ins_state_FSM_FFd2_1327,
      I1 => fax4_ins_pass_mode,
      I2 => fax4_ins_state_FSM_FFd6_1336,
      I3 => fax4_ins_state_FSM_FFd10_1323,
      O => fax4_ins_state_FSM_FFd5_In5_1335
    );
  huffman_ins_v2_run_length_black_0_1 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => fax4_ins_a0_value_o_950,
      I1 => huffman_ins_v2_run_length_white_sub0000(0),
      I2 => huffman_ins_v2_run_length_white_sub0001(0),
      O => huffman_ins_v2_run_length_black(0)
    );
  huffman_ins_v2_hor_code_4_mux0003211 : LUT3
    generic map(
      INIT => X"C8"
    )
    port map (
      I0 => huffman_ins_v2_mux_code_black_width(0),
      I1 => huffman_ins_v2_mux_code_black_width(2),
      I2 => huffman_ins_v2_mux_code_black_width(1),
      O => huffman_ins_v2_N251
    );
  huffman_ins_v2_mux_code_white_width_4_1 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => huffman_ins_v2_a0_value_2_1510,
      I1 => huffman_ins_v2_code_black_width(4),
      I2 => huffman_ins_v2_code_white_width(4),
      O => huffman_ins_v2_Madd_hor_code_width_addsub0000_lut(4)
    );
  huffman_ins_v2_mux_code_white_width_3_1 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => huffman_ins_v2_a0_value_2_1510,
      I1 => huffman_ins_v2_code_black_width(3),
      I2 => huffman_ins_v2_code_white_width(3),
      O => huffman_ins_v2_Madd_hor_code_width_addsub0000_lut(3)
    );
  huffman_ins_v2_mux_code_white_width_0_1 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => huffman_ins_v2_a0_value_2_1510,
      I1 => huffman_ins_v2_code_black_width(0),
      I2 => huffman_ins_v2_code_white_width(0),
      O => huffman_ins_v2_Madd_hor_code_width_addsub0000_cy(0)
    );
  huffman_ins_v2_mux_code_black_width_4_1 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => huffman_ins_v2_a0_value_2_1510,
      I1 => huffman_ins_v2_code_white_width(4),
      I2 => huffman_ins_v2_code_black_width(4),
      O => huffman_ins_v2_mux_code_black_width(4)
    );
  huffman_ins_v2_mux_code_black_width_3_1 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => huffman_ins_v2_a0_value_2_1510,
      I1 => huffman_ins_v2_code_white_width(3),
      I2 => huffman_ins_v2_code_black_width(3),
      O => huffman_ins_v2_mux_code_black_width(3)
    );
  huffman_ins_v2_mux_code_black_width_0_1 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => huffman_ins_v2_a0_value_2_1510,
      I1 => huffman_ins_v2_code_white_width(0),
      I2 => huffman_ins_v2_code_black_width(0),
      O => huffman_ins_v2_mux_code_black_width(0)
    );
  huffman_ins_v2_hor_code_13_or00031 : LUT3
    generic map(
      INIT => X"B5"
    )
    port map (
      I0 => huffman_ins_v2_Madd_hor_code_width_addsub0000_lut(2),
      I1 => huffman_ins_v2_Madd_hor_code_width_addsub0000_cy(0),
      I2 => huffman_ins_v2_mux_code_white_width(1),
      O => huffman_ins_v2_hor_code_13_or0003
    );
  huffman_ins_v2_hor_code_10_mux000342 : LUT4
    generic map(
      INIT => X"8000"
    )
    port map (
      I0 => huffman_ins_v2_mux_code_black_width(4),
      I1 => huffman_ins_v2_horizontal_mode_part_2_2065,
      I2 => huffman_ins_v2_N251,
      I3 => huffman_ins_v2_mux_code_black_width(3),
      O => huffman_ins_v2_N82
    );
  huffman_ins_v2_hor_code_10_mux00031212 : LUT4
    generic map(
      INIT => X"AEAA"
    )
    port map (
      I0 => huffman_ins_v2_N82,
      I1 => huffman_ins_v2_N102,
      I2 => huffman_ins_v2_N170,
      I3 => huffman_ins_v2_Madd_hor_code_width_addsub0000_lut(3),
      O => huffman_ins_v2_N166
    );
  huffman_ins_v2_hor_code_5_mux000315 : LUT4
    generic map(
      INIT => X"FFEA"
    )
    port map (
      I0 => huffman_ins_v2_N166,
      I1 => huffman_ins_v2_N105,
      I2 => huffman_ins_v2_N78,
      I3 => huffman_ins_v2_hor_code_5_mux00037_2010,
      O => huffman_ins_v2_hor_code_5_mux000315_2007
    );
  huffman_ins_v2_hor_code_5_mux000349 : LUT4
    generic map(
      INIT => X"0E04"
    )
    port map (
      I0 => huffman_ins_v2_a0_value_2_1510,
      I1 => huffman_ins_v2_code_black(5),
      I2 => huffman_ins_v2_horizontal_mode_part_2_2065,
      I3 => huffman_ins_v2_code_white(5),
      O => huffman_ins_v2_hor_code_5_mux000349_2009
    );
  huffman_ins_v2_hor_code_5_mux000376 : LUT4
    generic map(
      INIT => X"A820"
    )
    port map (
      I0 => huffman_ins_v2_horizontal_mode_part_2_2065,
      I1 => huffman_ins_v2_a0_value_2_1510,
      I2 => huffman_ins_v2_code_white(5),
      I3 => huffman_ins_v2_code_black(5),
      O => huffman_ins_v2_hor_code_5_mux000376_2011
    );
  huffman_ins_v2_hor_code_5_mux000380 : LUT4
    generic map(
      INIT => X"AA02"
    )
    port map (
      I0 => huffman_ins_v2_hor_code_5_mux000376_2011,
      I1 => huffman_ins_v2_mux_code_black_width(4),
      I2 => huffman_ins_v2_N78,
      I3 => huffman_ins_v2_N48,
      O => huffman_ins_v2_hor_code_5_mux000380_2012
    );
  huffman_ins_v2_hor_code_3_mux000340 : LUT4
    generic map(
      INIT => X"2000"
    )
    port map (
      I0 => huffman_ins_v2_mux_code_white_width(1),
      I1 => huffman_ins_v2_Madd_hor_code_width_addsub0000_lut(2),
      I2 => huffman_ins_v2_Madd_hor_code_width_addsub0000_cy(0),
      I3 => huffman_ins_v2_N100,
      O => huffman_ins_v2_hor_code_3_mux000340_1993
    );
  huffman_ins_v2_hor_code_3_mux000342 : LUT3
    generic map(
      INIT => X"EA"
    )
    port map (
      I0 => huffman_ins_v2_hor_code_3_mux000340_1993,
      I1 => huffman_ins_v2_hor_code(3),
      I2 => huffman_ins_v2_hor_code_3_mux000318_1991,
      O => huffman_ins_v2_hor_code_3_mux000342_1994
    );
  huffman_ins_v2_hor_code_0_mux000310 : LUT4
    generic map(
      INIT => X"FF04"
    )
    port map (
      I0 => huffman_ins_v2_N99,
      I1 => huffman_ins_v2_N105,
      I2 => huffman_ins_v2_mux_code_black_width(0),
      I3 => huffman_ins_v2_N166,
      O => huffman_ins_v2_hor_code_0_mux000310_1816
    );
  huffman_ins_v2_hor_code_0_mux000324 : LUT3
    generic map(
      INIT => X"EA"
    )
    port map (
      I0 => huffman_ins_v2_hor_code_0_mux000322_1817,
      I1 => huffman_ins_v2_hor_code(0),
      I2 => huffman_ins_v2_hor_code_0_mux000310_1816,
      O => huffman_ins_v2_hor_code_0_mux000324_1818
    );
  huffman_ins_v2_hor_code_1_mux000339 : LUT4
    generic map(
      INIT => X"0E04"
    )
    port map (
      I0 => huffman_ins_v2_a0_value_2_1510,
      I1 => huffman_ins_v2_code_black(1),
      I2 => huffman_ins_v2_horizontal_mode_part_2_2065,
      I3 => huffman_ins_v2_code_white(1),
      O => huffman_ins_v2_hor_code_1_mux000339_1931
    );
  huffman_ins_v2_hor_code_1_mux000347 : LUT4
    generic map(
      INIT => X"70E0"
    )
    port map (
      I0 => huffman_ins_v2_N59,
      I1 => huffman_ins_v2_Madd_hor_code_width_addsub0000_lut(3),
      I2 => huffman_ins_v2_hor_code_1_mux000339_1931,
      I3 => huffman_ins_v2_Madd_hor_code_width_addsub0000_lut(4),
      O => huffman_ins_v2_hor_code_1_mux000347_1932
    );
  huffman_ins_v2_hor_code_1_mux000379 : LUT4
    generic map(
      INIT => X"FF04"
    )
    port map (
      I0 => huffman_ins_v2_mux_code_black_width(2),
      I1 => huffman_ins_v2_N105,
      I2 => huffman_ins_v2_mux_code_black_width(1),
      I3 => huffman_ins_v2_N166,
      O => huffman_ins_v2_hor_code_1_mux000379_1934
    );
  huffman_ins_v2_hor_code_1_mux000386 : LUT3
    generic map(
      INIT => X"EA"
    )
    port map (
      I0 => huffman_ins_v2_hor_code_1_mux000354_1933,
      I1 => huffman_ins_v2_hor_code(1),
      I2 => huffman_ins_v2_hor_code_1_mux000379_1934,
      O => huffman_ins_v2_hor_code_1_mux000386_1935
    );
  huffman_ins_v2_hor_code_1_mux0003116 : LUT4
    generic map(
      INIT => X"A820"
    )
    port map (
      I0 => huffman_ins_v2_horizontal_mode_part_2_2065,
      I1 => huffman_ins_v2_a0_value_2_1510,
      I2 => huffman_ins_v2_code_white(1),
      I3 => huffman_ins_v2_code_black(1),
      O => huffman_ins_v2_hor_code_1_mux0003116_1929
    );
  huffman_ins_v2_hor_code_1_mux0003120 : LUT4
    generic map(
      INIT => X"F020"
    )
    port map (
      I0 => huffman_ins_v2_mux_code_black_width(1),
      I1 => huffman_ins_v2_mux_code_black_width(4),
      I2 => huffman_ins_v2_hor_code_1_mux0003116_1929,
      I3 => huffman_ins_v2_N52,
      O => huffman_ins_v2_hor_code_1_mux0003120_1930
    );
  huffman_ins_v2_hor_code_4_mux000310 : LUT4
    generic map(
      INIT => X"FFEA"
    )
    port map (
      I0 => huffman_ins_v2_N166,
      I1 => huffman_ins_v2_N105,
      I2 => huffman_ins_v2_N71,
      I3 => huffman_ins_v2_hor_code_4_mux00033_1999,
      O => huffman_ins_v2_hor_code_4_mux000310_1997
    );
  huffman_ins_v2_hor_code_4_mux0003311 : LUT4
    generic map(
      INIT => X"1000"
    )
    port map (
      I0 => huffman_ins_v2_Madd_hor_code_width_addsub0000_cy(0),
      I1 => huffman_ins_v2_mux_code_white_width(1),
      I2 => huffman_ins_v2_N100,
      I3 => huffman_ins_v2_Madd_hor_code_width_addsub0000_lut(2),
      O => huffman_ins_v2_hor_code_4_mux000331_2000
    );
  huffman_ins_v2_hor_code_4_mux000333 : LUT3
    generic map(
      INIT => X"EA"
    )
    port map (
      I0 => huffman_ins_v2_hor_code_4_mux000331_2000,
      I1 => huffman_ins_v2_hor_code(4),
      I2 => huffman_ins_v2_hor_code_4_mux000310_1997,
      O => huffman_ins_v2_hor_code_4_mux000333_2001
    );
  huffman_ins_v2_hor_code_4_mux000358 : LUT4
    generic map(
      INIT => X"0E04"
    )
    port map (
      I0 => huffman_ins_v2_a0_value_2_1510,
      I1 => huffman_ins_v2_code_black(4),
      I2 => huffman_ins_v2_horizontal_mode_part_2_2065,
      I3 => huffman_ins_v2_code_white(4),
      O => huffman_ins_v2_hor_code_4_mux000358_2002
    );
  huffman_ins_v2_hor_code_4_mux000384 : LUT4
    generic map(
      INIT => X"A820"
    )
    port map (
      I0 => huffman_ins_v2_horizontal_mode_part_2_2065,
      I1 => huffman_ins_v2_a0_value_2_1510,
      I2 => huffman_ins_v2_code_white(4),
      I3 => huffman_ins_v2_code_black(4),
      O => huffman_ins_v2_hor_code_4_mux000384_2003
    );
  huffman_ins_v2_hor_code_4_mux000388 : LUT4
    generic map(
      INIT => X"F020"
    )
    port map (
      I0 => huffman_ins_v2_N251,
      I1 => huffman_ins_v2_mux_code_black_width(4),
      I2 => huffman_ins_v2_hor_code_4_mux000384_2003,
      I3 => huffman_ins_v2_N48,
      O => huffman_ins_v2_hor_code_4_mux000388_2004
    );
  huffman_ins_v2_hor_code_22_mux000317 : LUT4
    generic map(
      INIT => X"028A"
    )
    port map (
      I0 => huffman_ins_v2_N95,
      I1 => huffman_ins_v2_mux_code_black_width(3),
      I2 => huffman_ins_v2_N67,
      I3 => huffman_ins_v2_N99,
      O => huffman_ins_v2_hor_code_22_mux000317_1961
    );
  huffman_ins_v2_hor_code_22_mux000360 : LUT4
    generic map(
      INIT => X"45EF"
    )
    port map (
      I0 => huffman_ins_v2_a0_value_2_1510,
      I1 => huffman_ins_v2_code_black(22),
      I2 => huffman_ins_v2_code_black_width(0),
      I3 => huffman_ins_v2_code_white_width(0),
      O => huffman_ins_v2_hor_code_22_mux000360_1963
    );
  huffman_ins_v2_hor_code_22_mux000375 : LUT4
    generic map(
      INIT => X"1000"
    )
    port map (
      I0 => huffman_ins_v2_hor_code_13_or0005,
      I1 => huffman_ins_v2_Madd_hor_code_width_addsub0000_lut(3),
      I2 => huffman_ins_v2_hor_code_22_mux000360_1963,
      I3 => huffman_ins_v2_N102,
      O => huffman_ins_v2_hor_code_22_mux000375_1964
    );
  huffman_ins_v2_hor_code_22_mux000385 : LUT4
    generic map(
      INIT => X"FFA8"
    )
    port map (
      I0 => huffman_ins_v2_code_black(22),
      I1 => huffman_ins_v2_hor_code_22_mux000317_1961,
      I2 => huffman_ins_v2_hor_code_22_mux000320_1962,
      I3 => huffman_ins_v2_hor_code_22_mux000375_1964,
      O => huffman_ins_v2_hor_code_22_mux000385_1965
    );
  huffman_ins_v2_hor_code_22_mux0003112 : LUT4
    generic map(
      INIT => X"FD75"
    )
    port map (
      I0 => huffman_ins_v2_mux_code_black_width(4),
      I1 => huffman_ins_v2_mux_code_black_width(3),
      I2 => huffman_ins_v2_N67,
      I3 => huffman_ins_v2_N251,
      O => huffman_ins_v2_hor_code_22_mux0003112_1959
    );
  huffman_ins_v2_hor_code_2_mux000330 : LUT4
    generic map(
      INIT => X"0E04"
    )
    port map (
      I0 => huffman_ins_v2_a0_value_2_1510,
      I1 => huffman_ins_v2_code_black(2),
      I2 => huffman_ins_v2_horizontal_mode_part_2_2065,
      I3 => huffman_ins_v2_code_white(2),
      O => huffman_ins_v2_hor_code_2_mux000330_1986
    );
  huffman_ins_v2_hor_code_2_mux0003104 : LUT4
    generic map(
      INIT => X"AEAA"
    )
    port map (
      I0 => huffman_ins_v2_N52,
      I1 => huffman_ins_v2_mux_code_black_width(0),
      I2 => huffman_ins_v2_mux_code_black_width(4),
      I3 => huffman_ins_v2_mux_code_black_width(1),
      O => huffman_ins_v2_hor_code_2_mux0003104_1983
    );
  huffman_ins_v2_hor_code_2_mux0003117 : LUT4
    generic map(
      INIT => X"A820"
    )
    port map (
      I0 => huffman_ins_v2_horizontal_mode_part_2_2065,
      I1 => huffman_ins_v2_a0_value_2_1510,
      I2 => huffman_ins_v2_code_white(2),
      I3 => huffman_ins_v2_code_black(2),
      O => huffman_ins_v2_hor_code_2_mux0003117_1984
    );
  huffman_ins_v2_hor_code_20_mux000370 : LUT4
    generic map(
      INIT => X"FFE2"
    )
    port map (
      I0 => huffman_ins_v2_hor_code_20_mux000350_1946,
      I1 => huffman_ins_v2_horizontal_mode_part_2_2065,
      I2 => huffman_ins_v2_hor_code_20_mux000315_1942,
      I3 => huffman_ins_v2_hor_code_20_mux00030_1938,
      O => huffman_ins_v2_hor_code_20_mux000370_1947
    );
  huffman_ins_v2_hor_code_20_mux0003105 : LUT4
    generic map(
      INIT => X"1000"
    )
    port map (
      I0 => huffman_ins_v2_Madd_hor_code_width_addsub0000_lut(3),
      I1 => huffman_ins_v2_Madd_hor_code_width_addsub0000_cy(1),
      I2 => huffman_ins_v2_N102,
      I3 => huffman_ins_v2_Madd_hor_code_width_addsub0000_lut(2),
      O => huffman_ins_v2_hor_code_20_mux0003105_1939
    );
  huffman_ins_v2_hor_code_20_mux0003127 : LUT4
    generic map(
      INIT => X"F020"
    )
    port map (
      I0 => huffman_ins_v2_N250,
      I1 => huffman_ins_v2_mux_code_black_width(3),
      I2 => huffman_ins_v2_N95,
      I3 => huffman_ins_v2_N169,
      O => huffman_ins_v2_hor_code_20_mux0003127_1940
    );
  huffman_ins_v2_hor_code_20_mux0003145 : LUT4
    generic map(
      INIT => X"028A"
    )
    port map (
      I0 => huffman_ins_v2_N245,
      I1 => huffman_ins_v2_Madd_hor_code_width_addsub0000_lut(3),
      I2 => huffman_ins_v2_N170,
      I3 => huffman_ins_v2_N59,
      O => huffman_ins_v2_hor_code_20_mux0003145_1941
    );
  huffman_ins_v2_hor_code_20_mux0003158 : LUT3
    generic map(
      INIT => X"C8"
    )
    port map (
      I0 => huffman_ins_v2_hor_code_20_mux0003127_1940,
      I1 => huffman_ins_v2_code_black(20),
      I2 => huffman_ins_v2_hor_code_20_mux0003145_1941,
      O => huffman_ins_v2_hor_code_20_mux0003158_1943
    );
  huffman_ins_v2_hor_code_16_mux000394 : LUT2
    generic map(
      INIT => X"8"
    )
    port map (
      I0 => huffman_ins_v2_code_white_width(4),
      I1 => huffman_ins_v2_code_white(16),
      O => huffman_ins_v2_hor_code_16_mux000394_1902
    );
  huffman_ins_v2_hor_code_16_mux0003102 : LUT4
    generic map(
      INIT => X"F888"
    )
    port map (
      I0 => huffman_ins_v2_hor_code(16),
      I1 => huffman_ins_v2_hor_code_16_mux000359_1900,
      I2 => huffman_ins_v2_hor_code_16_mux000393_1901,
      I3 => huffman_ins_v2_hor_code_16_mux000394_1902,
      O => huffman_ins_v2_hor_code_16_mux0003102_1896
    );
  huffman_ins_v2_hor_code_16_mux0003136 : LUT4
    generic map(
      INIT => X"0010"
    )
    port map (
      I0 => huffman_ins_v2_Madd_hor_code_width_addsub0000_lut(3),
      I1 => huffman_ins_v2_Madd_hor_code_width_addsub0000_cy(0),
      I2 => huffman_ins_v2_N102,
      I3 => huffman_ins_v2_N59,
      O => huffman_ins_v2_hor_code_16_mux0003136_1898
    );
  huffman_ins_v2_hor_code_21_mux000334 : LUT4
    generic map(
      INIT => X"1810"
    )
    port map (
      I0 => huffman_ins_v2_code_black_width(2),
      I1 => huffman_ins_v2_code_black_width(1),
      I2 => huffman_ins_v2_Madd_hor_code_width_addsub0000_lut(3),
      I3 => huffman_ins_v2_hor_code_13_or0003,
      O => huffman_ins_v2_hor_code_21_mux000334_1953
    );
  huffman_ins_v2_hor_code_21_mux000379 : LUT4
    generic map(
      INIT => X"FFA8"
    )
    port map (
      I0 => huffman_ins_v2_code_black(21),
      I1 => huffman_ins_v2_hor_code_21_mux000310_1949,
      I2 => huffman_ins_v2_hor_code_21_mux000335_1954,
      I3 => huffman_ins_v2_hor_code_21_mux000376_1955,
      O => huffman_ins_v2_hor_code_21_mux000379_1956
    );
  huffman_ins_v2_hor_code_21_mux0003123 : LUT4
    generic map(
      INIT => X"AEAA"
    )
    port map (
      I0 => huffman_ins_v2_hor_code_13_cmp_eq0000,
      I1 => huffman_ins_v2_hor_code_13_or0003,
      I2 => huffman_ins_v2_Madd_hor_code_width_addsub0000_lut(3),
      I3 => huffman_ins_v2_hor_code_13_or0005,
      O => huffman_ins_v2_hor_code_21_mux0003123_1950
    );
  huffman_ins_v2_hor_code_21_mux0003179 : LUT2
    generic map(
      INIT => X"8"
    )
    port map (
      I0 => huffman_ins_v2_hor_code(21),
      I1 => huffman_ins_v2_hor_code_21_mux0003168_1951,
      O => huffman_ins_v2_hor_code_21_mux0003179_1952
    );
  huffman_ins_v2_hor_code_13_mux00039 : LUT4
    generic map(
      INIT => X"FAF2"
    )
    port map (
      I0 => huffman_ins_v2_N110,
      I1 => huffman_ins_v2_mux_code_black_width(3),
      I2 => huffman_ins_v2_N82,
      I3 => huffman_ins_v2_N78,
      O => huffman_ins_v2_hor_code_13_mux00039_1861
    );
  huffman_ins_v2_hor_code_13_mux000320 : LUT4
    generic map(
      INIT => X"3111"
    )
    port map (
      I0 => huffman_ins_v2_Madd_hor_code_width_addsub0000_lut(3),
      I1 => huffman_ins_v2_Madd_hor_code_width_addsub0000_lut(4),
      I2 => huffman_ins_v2_hor_code_13_or0003,
      I3 => huffman_ins_v2_hor_code_13_or0005,
      O => huffman_ins_v2_hor_code_13_mux000320_1856
    );
  huffman_ins_v2_hor_code_13_mux000350 : LUT4
    generic map(
      INIT => X"F3F2"
    )
    port map (
      I0 => huffman_ins_v2_hor_code_13_mux000325_1857,
      I1 => huffman_ins_v2_horizontal_mode_part_2_2065,
      I2 => huffman_ins_v2_hor_code_13_mux00039_1861,
      I3 => huffman_ins_v2_hor_code_13_mux000320_1856,
      O => huffman_ins_v2_hor_code_13_mux000350_1858
    );
  huffman_ins_v2_hor_code_13_mux0003161 : LUT4
    generic map(
      INIT => X"0010"
    )
    port map (
      I0 => huffman_ins_v2_Madd_hor_code_width_addsub0000_lut(4),
      I1 => huffman_ins_v2_mux_code_white_width(1),
      I2 => huffman_ins_v2_Madd_hor_code_width_addsub0000_cy(0),
      I3 => huffman_ins_v2_N98,
      O => huffman_ins_v2_hor_code_13_mux0003161_1853
    );
  huffman_ins_v2_hor_code_13_mux0003181 : LUT3
    generic map(
      INIT => X"32"
    )
    port map (
      I0 => huffman_ins_v2_hor_code_13_mux0003161_1853,
      I1 => huffman_ins_v2_horizontal_mode_part_2_2065,
      I2 => huffman_ins_v2_hor_code_13_mux0003137_1852,
      O => huffman_ins_v2_hor_code_13_mux0003181_1854
    );
  huffman_ins_v2_hor_code_12_mux000311 : LUT4
    generic map(
      INIT => X"0010"
    )
    port map (
      I0 => huffman_ins_v2_code_black_width(4),
      I1 => huffman_ins_v2_code_black_width(0),
      I2 => huffman_ins_v2_a0_value_2_1510,
      I3 => huffman_ins_v2_code_black_width(1),
      O => huffman_ins_v2_hor_code_12_mux000311_1839
    );
  huffman_ins_v2_hor_code_12_mux000324 : LUT4
    generic map(
      INIT => X"0001"
    )
    port map (
      I0 => huffman_ins_v2_code_white_width(4),
      I1 => huffman_ins_v2_a0_value_2_1510,
      I2 => huffman_ins_v2_code_white_width(0),
      I3 => huffman_ins_v2_code_white_width(1),
      O => huffman_ins_v2_hor_code_12_mux000324_1846
    );
  huffman_ins_v2_hor_code_12_mux0003104 : LUT4
    generic map(
      INIT => X"0010"
    )
    port map (
      I0 => huffman_ins_v2_code_white_width(4),
      I1 => huffman_ins_v2_code_white_width(0),
      I2 => huffman_ins_v2_a0_value_2_1510,
      I3 => huffman_ins_v2_code_white_width(1),
      O => huffman_ins_v2_hor_code_12_mux0003104_1838
    );
  huffman_ins_v2_hor_code_12_mux0003117 : LUT4
    generic map(
      INIT => X"0001"
    )
    port map (
      I0 => huffman_ins_v2_code_black_width(4),
      I1 => huffman_ins_v2_a0_value_2_1510,
      I2 => huffman_ins_v2_code_black_width(0),
      I3 => huffman_ins_v2_code_black_width(1),
      O => huffman_ins_v2_hor_code_12_mux0003117_1840
    );
  huffman_ins_v2_hor_code_12_mux0003135 : LUT4
    generic map(
      INIT => X"FFAE"
    )
    port map (
      I0 => huffman_ins_v2_hor_code_12_mux0003104_1838,
      I1 => huffman_ins_v2_Madd_hor_code_width_addsub0000_cy(1),
      I2 => huffman_ins_v2_N98,
      I3 => huffman_ins_v2_hor_code_12_mux0003117_1840,
      O => huffman_ins_v2_hor_code_12_mux0003135_1841
    );
  huffman_ins_v2_hor_code_12_mux0003163 : LUT4
    generic map(
      INIT => X"F888"
    )
    port map (
      I0 => huffman_ins_v2_horizontal_mode_part_2_2065,
      I1 => huffman_ins_v2_hor_code_12_mux000364_1849,
      I2 => huffman_ins_v2_N102,
      I3 => huffman_ins_v2_hor_code_12_mux0003135_1841,
      O => huffman_ins_v2_hor_code_12_mux0003163_1842
    );
  huffman_ins_v2_hor_code_12_mux0003216 : LUT4
    generic map(
      INIT => X"0001"
    )
    port map (
      I0 => huffman_ins_v2_Madd_hor_code_width_addsub0000_lut(4),
      I1 => huffman_ins_v2_horizontal_mode_part_2_2065,
      I2 => huffman_ins_v2_Madd_hor_code_width_addsub0000_cy(1),
      I3 => huffman_ins_v2_N98,
      O => huffman_ins_v2_hor_code_12_mux0003216_1844
    );
  huffman_ins_v2_hor_code_12_mux0003219 : LUT4
    generic map(
      INIT => X"FFA8"
    )
    port map (
      I0 => huffman_ins_v2_hor_code(12),
      I1 => huffman_ins_v2_hor_code_12_mux0003163_1842,
      I2 => huffman_ins_v2_hor_code_12_mux0003175_1843,
      I3 => huffman_ins_v2_hor_code_12_mux0003216_1844,
      O => huffman_ins_v2_hor_code_12_mux0003219_1845
    );
  huffman_ins_v2_code_black_15_mux000031 : LUT2
    generic map(
      INIT => X"8"
    )
    port map (
      I0 => huffman_ins_v2_codetab_ter_black_width(0),
      I1 => huffman_ins_v2_code_table_ins_makeup_black_8_Q,
      O => huffman_ins_v2_code_black_15_mux0000_bdd1
    );
  huffman_ins_v2_Madd_code_white_width_add0000_lut_0_1 : LUT2
    generic map(
      INIT => X"6"
    )
    port map (
      I0 => huffman_ins_v2_code_table_ins_makeup_white(9),
      I1 => huffman_ins_v2_codetab_ter_white_width(0),
      O => huffman_ins_v2_Madd_code_white_width_add0000_lut(0)
    );
  huffman_ins_v2_Madd_code_black_width_add0000_lut_0_1 : LUT2
    generic map(
      INIT => X"6"
    )
    port map (
      I0 => huffman_ins_v2_code_table_ins_makeup_black_13_Q,
      I1 => huffman_ins_v2_codetab_ter_black_width(0),
      O => huffman_ins_v2_Madd_code_black_width_add0000_lut(0)
    );
  huffman_ins_v2_code_black_11_mux000071 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => huffman_ins_v2_codetab_ter_black_width(0),
      I1 => huffman_ins_v2_code_table_ins_makeup_black_7_Q,
      I2 => huffman_ins_v2_code_table_ins_makeup_black_6_Q,
      O => huffman_ins_v2_code_black_11_mux0000_bdd5
    );
  huffman_ins_v2_code_black_11_mux000051 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => huffman_ins_v2_codetab_ter_black_width(0),
      I1 => huffman_ins_v2_code_table_ins_makeup_black_5_Q,
      I2 => huffman_ins_v2_code_table_ins_makeup_black_4_Q,
      O => huffman_ins_v2_code_black_11_mux0000_bdd3
    );
  huffman_ins_v2_code_black_11_mux000041 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => huffman_ins_v2_codetab_ter_black_width(0),
      I1 => huffman_ins_v2_code_table_ins_makeup_black_3_Q,
      I2 => huffman_ins_v2_code_table_ins_makeup_black_2_Q,
      O => huffman_ins_v2_code_black_11_mux0000_bdd2
    );
  huffman_ins_v2_code_black_11_mux000021 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => huffman_ins_v2_codetab_ter_black_width(0),
      I1 => huffman_ins_v2_code_table_ins_makeup_black_1_Q,
      I2 => huffman_ins_v2_code_table_ins_makeup_black_0_Q,
      O => huffman_ins_v2_code_black_11_mux0000_bdd0
    );
  huffman_ins_v2_code_black_10_mux000071 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => huffman_ins_v2_codetab_ter_black_width(0),
      I1 => huffman_ins_v2_code_table_ins_makeup_black_6_Q,
      I2 => huffman_ins_v2_code_table_ins_makeup_black_5_Q,
      O => huffman_ins_v2_code_black_10_mux0000_bdd5
    );
  huffman_ins_v2_code_black_10_mux000061 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => huffman_ins_v2_codetab_ter_black_width(0),
      I1 => huffman_ins_v2_code_table_ins_makeup_black_8_Q,
      I2 => huffman_ins_v2_code_table_ins_makeup_black_7_Q,
      O => huffman_ins_v2_code_black_10_mux0000_bdd4
    );
  huffman_ins_v2_code_black_10_mux000051 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => huffman_ins_v2_codetab_ter_black_width(0),
      I1 => huffman_ins_v2_code_table_ins_makeup_black_4_Q,
      I2 => huffman_ins_v2_code_table_ins_makeup_black_3_Q,
      O => huffman_ins_v2_code_black_10_mux0000_bdd3
    );
  huffman_ins_v2_code_black_10_mux000041 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => huffman_ins_v2_codetab_ter_black_width(0),
      I1 => huffman_ins_v2_code_table_ins_makeup_black_2_Q,
      I2 => huffman_ins_v2_code_table_ins_makeup_black_1_Q,
      O => huffman_ins_v2_code_black_10_mux0000_bdd2
    );
  huffman_ins_v2_code_black_1_mux00001_SW0 : LUT4
    generic map(
      INIT => X"8891"
    )
    port map (
      I0 => huffman_ins_v2_codetab_ter_black_width(2),
      I1 => huffman_ins_v2_codetab_ter_black_width(3),
      I2 => huffman_ins_v2_codetab_ter_black_width(0),
      I3 => huffman_ins_v2_codetab_ter_black_width(1),
      O => N18
    );
  huffman_ins_v2_code_black_1_mux00001 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => N18,
      I1 => huffman_ins_v2_ter_black_code(1),
      I2 => huffman_ins_v2_code_black(1),
      O => huffman_ins_v2_code_black_1_mux0000
    );
  huffman_ins_v2_code_black_0_mux00001 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => N18,
      I1 => huffman_ins_v2_ter_black_code(0),
      I2 => huffman_ins_v2_code_black(0),
      O => huffman_ins_v2_code_black_0_mux0000
    );
  huffman_ins_v2_code_black_23_mux0000112 : LUT4
    generic map(
      INIT => X"A820"
    )
    port map (
      I0 => huffman_ins_v2_codetab_ter_black_width(1),
      I1 => huffman_ins_v2_codetab_ter_black_width(2),
      I2 => huffman_ins_v2_code_black_15_mux0000_bdd1,
      I3 => huffman_ins_v2_code_black(23),
      O => huffman_ins_v2_code_black_23_mux0000112_1613
    );
  huffman_ins_v2_code_black_23_mux0000123 : LUT2
    generic map(
      INIT => X"2"
    )
    port map (
      I0 => huffman_ins_v2_codetab_ter_black_width(2),
      I1 => huffman_ins_v2_codetab_ter_black_width(1),
      O => huffman_ins_v2_code_black_22_mux0000123
    );
  huffman_ins_v2_code_black_23_mux0000128 : LUT4
    generic map(
      INIT => X"A820"
    )
    port map (
      I0 => huffman_ins_v2_code_black_22_mux0000123,
      I1 => huffman_ins_v2_codetab_ter_black_width(0),
      I2 => huffman_ins_v2_code_table_ins_makeup_black_8_Q,
      I3 => huffman_ins_v2_code_black(23),
      O => huffman_ins_v2_code_black_23_mux0000128_1614
    );
  huffman_ins_v2_code_black_23_mux0000169 : LUT4
    generic map(
      INIT => X"0010"
    )
    port map (
      I0 => huffman_ins_v2_codetab_ter_black_width(3),
      I1 => huffman_ins_v2_codetab_ter_black_width(2),
      I2 => huffman_ins_v2_code_black(23),
      I3 => huffman_ins_v2_codetab_ter_black_width(1),
      O => huffman_ins_v2_code_black_23_mux0000169_1615
    );
  huffman_ins_v2_code_black_22_mux0000112 : LUT4
    generic map(
      INIT => X"A820"
    )
    port map (
      I0 => huffman_ins_v2_codetab_ter_black_width(1),
      I1 => huffman_ins_v2_codetab_ter_black_width(2),
      I2 => huffman_ins_v2_code_table_ins_makeup_black_8_Q,
      I3 => huffman_ins_v2_code_black(22),
      O => huffman_ins_v2_code_black_22_mux0000112_1607
    );
  huffman_ins_v2_code_black_22_mux0000128 : LUT4
    generic map(
      INIT => X"A820"
    )
    port map (
      I0 => huffman_ins_v2_code_black_22_mux0000123,
      I1 => huffman_ins_v2_codetab_ter_black_width(0),
      I2 => huffman_ins_v2_code_table_ins_makeup_black_8_Q,
      I3 => huffman_ins_v2_code_black(22),
      O => huffman_ins_v2_code_black_22_mux0000128_1609
    );
  huffman_ins_v2_code_black_22_mux0000169 : LUT4
    generic map(
      INIT => X"0010"
    )
    port map (
      I0 => huffman_ins_v2_codetab_ter_black_width(3),
      I1 => huffman_ins_v2_codetab_ter_black_width(2),
      I2 => huffman_ins_v2_code_black(22),
      I3 => huffman_ins_v2_codetab_ter_black_width(1),
      O => huffman_ins_v2_code_black_22_mux0000169_1610
    );
  huffman_ins_v2_code_black_3_mux000011 : LUT4
    generic map(
      INIT => X"FF57"
    )
    port map (
      I0 => huffman_ins_v2_codetab_ter_black_width(2),
      I1 => huffman_ins_v2_codetab_ter_black_width(1),
      I2 => huffman_ins_v2_codetab_ter_black_width(0),
      I3 => huffman_ins_v2_code_black(3),
      O => huffman_ins_v2_code_black_3_mux00001
    );
  huffman_ins_v2_code_black_3_mux000012 : LUT4
    generic map(
      INIT => X"C080"
    )
    port map (
      I0 => huffman_ins_v2_codetab_ter_black_width(1),
      I1 => huffman_ins_v2_codetab_ter_black_width(2),
      I2 => huffman_ins_v2_code_black(3),
      I3 => huffman_ins_v2_codetab_ter_black_width(0),
      O => huffman_ins_v2_code_black_3_mux000011_1629
    );
  huffman_ins_v2_code_black_3_mux00001_f5 : MUXF5
    port map (
      I0 => huffman_ins_v2_code_black_3_mux000011_1629,
      I1 => huffman_ins_v2_code_black_3_mux00001,
      S => huffman_ins_v2_ter_black_code(3),
      O => huffman_ins_v2_code_black_3_mux00001_f5_1632
    );
  huffman_ins_v2_code_black_3_mux000013 : LUT4
    generic map(
      INIT => X"FFE2"
    )
    port map (
      I0 => huffman_ins_v2_code_black(3),
      I1 => huffman_ins_v2_codetab_ter_black_width(1),
      I2 => huffman_ins_v2_code_black_11_mux0000_bdd0,
      I3 => huffman_ins_v2_codetab_ter_black_width(2),
      O => huffman_ins_v2_code_black_3_mux000012_1630
    );
  huffman_ins_v2_code_black_3_mux000014 : LUT4
    generic map(
      INIT => X"0E04"
    )
    port map (
      I0 => huffman_ins_v2_codetab_ter_black_width(1),
      I1 => huffman_ins_v2_code_black(3),
      I2 => huffman_ins_v2_codetab_ter_black_width(2),
      I3 => huffman_ins_v2_code_black_11_mux0000_bdd0,
      O => huffman_ins_v2_code_black_3_mux000013_1631
    );
  huffman_ins_v2_code_black_3_mux00001_f5_0 : MUXF5
    port map (
      I0 => huffman_ins_v2_code_black_3_mux000013_1631,
      I1 => huffman_ins_v2_code_black_3_mux000012_1630,
      S => huffman_ins_v2_ter_black_code(3),
      O => huffman_ins_v2_code_black_3_mux00001_f51
    );
  huffman_ins_v2_code_black_3_mux00001_f6 : MUXF6
    port map (
      I0 => huffman_ins_v2_code_black_3_mux00001_f51,
      I1 => huffman_ins_v2_code_black_3_mux00001_f5_1632,
      S => huffman_ins_v2_codetab_ter_black_width(3),
      O => huffman_ins_v2_code_black_3_mux0000
    );
  huffman_ins_v2_code_black_2_mux000021 : LUT4
    generic map(
      INIT => X"FF57"
    )
    port map (
      I0 => huffman_ins_v2_codetab_ter_black_width(2),
      I1 => huffman_ins_v2_codetab_ter_black_width(1),
      I2 => huffman_ins_v2_codetab_ter_black_width(0),
      I3 => huffman_ins_v2_code_black(2),
      O => huffman_ins_v2_code_black_2_mux00002
    );
  huffman_ins_v2_code_black_2_mux000022 : LUT4
    generic map(
      INIT => X"C080"
    )
    port map (
      I0 => huffman_ins_v2_codetab_ter_black_width(1),
      I1 => huffman_ins_v2_codetab_ter_black_width(2),
      I2 => huffman_ins_v2_code_black(2),
      I3 => huffman_ins_v2_codetab_ter_black_width(0),
      O => huffman_ins_v2_code_black_2_mux000021_1621
    );
  huffman_ins_v2_code_black_2_mux00002_f5 : MUXF5
    port map (
      I0 => huffman_ins_v2_code_black_2_mux000021_1621,
      I1 => huffman_ins_v2_code_black_2_mux00002,
      S => huffman_ins_v2_ter_black_code(2),
      O => huffman_ins_v2_code_black_2_mux00002_f5_1624
    );
  huffman_ins_v2_code_black_2_mux000023 : LUT4
    generic map(
      INIT => X"ABA8"
    )
    port map (
      I0 => huffman_ins_v2_ter_black_code(2),
      I1 => huffman_ins_v2_codetab_ter_black_width(2),
      I2 => huffman_ins_v2_codetab_ter_black_width(0),
      I3 => huffman_ins_v2_code_table_ins_makeup_black_0_Q,
      O => huffman_ins_v2_code_black_2_mux000022_1622
    );
  huffman_ins_v2_code_black_2_mux000024 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => huffman_ins_v2_codetab_ter_black_width(2),
      I1 => huffman_ins_v2_code_black(2),
      I2 => huffman_ins_v2_ter_black_code(2),
      O => huffman_ins_v2_code_black_2_mux000023_1623
    );
  huffman_ins_v2_code_black_2_mux00002_f5_0 : MUXF5
    port map (
      I0 => huffman_ins_v2_code_black_2_mux000023_1623,
      I1 => huffman_ins_v2_code_black_2_mux000022_1622,
      S => huffman_ins_v2_codetab_ter_black_width(1),
      O => huffman_ins_v2_code_black_2_mux00002_f51
    );
  huffman_ins_v2_code_black_2_mux00002_f6 : MUXF6
    port map (
      I0 => huffman_ins_v2_code_black_2_mux00002_f51,
      I1 => huffman_ins_v2_code_black_2_mux00002_f5_1624,
      S => huffman_ins_v2_codetab_ter_black_width(3),
      O => huffman_ins_v2_code_black_2_mux0000
    );
  huffman_ins_v2_code_black_21_mux000011 : LUT4
    generic map(
      INIT => X"ABA8"
    )
    port map (
      I0 => huffman_ins_v2_code_black(21),
      I1 => huffman_ins_v2_codetab_ter_black_width(1),
      I2 => huffman_ins_v2_codetab_ter_black_width(0),
      I3 => huffman_ins_v2_code_table_ins_makeup_black_8_Q,
      O => huffman_ins_v2_code_black_21_mux00001
    );
  huffman_ins_v2_code_black_21_mux00001_f5 : MUXF5
    port map (
      I0 => huffman_ins_v2_code_black_21_mux000011_1603,
      I1 => huffman_ins_v2_code_black_21_mux00001,
      S => huffman_ins_v2_codetab_ter_black_width(2),
      O => huffman_ins_v2_code_black_21_mux00001_f5_1605
    );
  huffman_ins_v2_code_black_21_mux000013 : LUT3
    generic map(
      INIT => X"10"
    )
    port map (
      I0 => huffman_ins_v2_codetab_ter_black_width(2),
      I1 => huffman_ins_v2_codetab_ter_black_width(1),
      I2 => huffman_ins_v2_code_black(21),
      O => huffman_ins_v2_code_black_21_mux000012_1604
    );
  huffman_ins_v2_code_black_21_mux00001_f6 : MUXF6
    port map (
      I0 => huffman_ins_v2_code_black_21_mux000012_1604,
      I1 => huffman_ins_v2_code_black_21_mux00001_f5_1605,
      S => huffman_ins_v2_codetab_ter_black_width(3),
      O => huffman_ins_v2_code_black_21_mux0000
    );
  huffman_ins_v2_code_black_20_mux0000187 : LUT4
    generic map(
      INIT => X"0010"
    )
    port map (
      I0 => huffman_ins_v2_codetab_ter_black_width(3),
      I1 => huffman_ins_v2_codetab_ter_black_width(2),
      I2 => huffman_ins_v2_code_black(20),
      I3 => huffman_ins_v2_codetab_ter_black_width(1),
      O => huffman_ins_v2_code_black_20_mux0000187_1599
    );
  huffman_ins_v2_code_black_5_mux000011 : LUT4
    generic map(
      INIT => X"FF57"
    )
    port map (
      I0 => huffman_ins_v2_codetab_ter_black_width(2),
      I1 => huffman_ins_v2_codetab_ter_black_width(1),
      I2 => huffman_ins_v2_codetab_ter_black_width(0),
      I3 => huffman_ins_v2_code_black(5),
      O => huffman_ins_v2_code_black_5_mux00001
    );
  huffman_ins_v2_code_black_5_mux000012 : LUT4
    generic map(
      INIT => X"C080"
    )
    port map (
      I0 => huffman_ins_v2_codetab_ter_black_width(1),
      I1 => huffman_ins_v2_codetab_ter_black_width(2),
      I2 => huffman_ins_v2_code_black(5),
      I3 => huffman_ins_v2_codetab_ter_black_width(0),
      O => huffman_ins_v2_code_black_5_mux000011_1645
    );
  huffman_ins_v2_code_black_5_mux00001_f5 : MUXF5
    port map (
      I0 => huffman_ins_v2_code_black_5_mux000011_1645,
      I1 => huffman_ins_v2_code_black_5_mux00001,
      S => huffman_ins_v2_ter_black_code(5),
      O => huffman_ins_v2_code_black_5_mux00001_f5_1648
    );
  huffman_ins_v2_code_black_5_mux000013 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => huffman_ins_v2_codetab_ter_black_width(1),
      I1 => huffman_ins_v2_code_black_11_mux0000_bdd0,
      I2 => huffman_ins_v2_ter_black_code(5),
      O => huffman_ins_v2_code_black_5_mux000012_1646
    );
  huffman_ins_v2_code_black_5_mux000014 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => huffman_ins_v2_codetab_ter_black_width(1),
      I1 => huffman_ins_v2_code_black(5),
      I2 => huffman_ins_v2_code_black_11_mux0000_bdd2,
      O => huffman_ins_v2_code_black_5_mux000013_1647
    );
  huffman_ins_v2_code_black_5_mux00001_f5_0 : MUXF5
    port map (
      I0 => huffman_ins_v2_code_black_5_mux000013_1647,
      I1 => huffman_ins_v2_code_black_5_mux000012_1646,
      S => huffman_ins_v2_codetab_ter_black_width(2),
      O => huffman_ins_v2_code_black_5_mux00001_f51
    );
  huffman_ins_v2_code_black_5_mux00001_f6 : MUXF6
    port map (
      I0 => huffman_ins_v2_code_black_5_mux00001_f51,
      I1 => huffman_ins_v2_code_black_5_mux00001_f5_1648,
      S => huffman_ins_v2_codetab_ter_black_width(3),
      O => huffman_ins_v2_code_black_5_mux0000
    );
  huffman_ins_v2_code_black_4_mux000011 : LUT4
    generic map(
      INIT => X"ABA8"
    )
    port map (
      I0 => huffman_ins_v2_code_black(4),
      I1 => huffman_ins_v2_codetab_ter_black_width(1),
      I2 => huffman_ins_v2_codetab_ter_black_width(0),
      I3 => huffman_ins_v2_ter_black_code(4),
      O => huffman_ins_v2_code_black_4_mux00001
    );
  huffman_ins_v2_code_black_4_mux000012 : LUT4
    generic map(
      INIT => X"ABA8"
    )
    port map (
      I0 => huffman_ins_v2_ter_black_code(4),
      I1 => huffman_ins_v2_codetab_ter_black_width(1),
      I2 => huffman_ins_v2_codetab_ter_black_width(0),
      I3 => huffman_ins_v2_code_table_ins_makeup_black_0_Q,
      O => huffman_ins_v2_code_black_4_mux000011_1637
    );
  huffman_ins_v2_code_black_4_mux00001_f5 : MUXF5
    port map (
      I0 => huffman_ins_v2_code_black_4_mux000011_1637,
      I1 => huffman_ins_v2_code_black_4_mux00001,
      S => huffman_ins_v2_codetab_ter_black_width(3),
      O => huffman_ins_v2_code_black_4_mux00001_f5_1640
    );
  huffman_ins_v2_code_black_4_mux000013 : LUT4
    generic map(
      INIT => X"FFE2"
    )
    port map (
      I0 => huffman_ins_v2_code_black(4),
      I1 => huffman_ins_v2_codetab_ter_black_width(1),
      I2 => huffman_ins_v2_code_black_10_mux0000_bdd2,
      I3 => huffman_ins_v2_codetab_ter_black_width(3),
      O => huffman_ins_v2_code_black_4_mux000012_1638
    );
  huffman_ins_v2_code_black_4_mux000014 : LUT4
    generic map(
      INIT => X"0E04"
    )
    port map (
      I0 => huffman_ins_v2_codetab_ter_black_width(1),
      I1 => huffman_ins_v2_code_black(4),
      I2 => huffman_ins_v2_codetab_ter_black_width(3),
      I3 => huffman_ins_v2_code_black_10_mux0000_bdd2,
      O => huffman_ins_v2_code_black_4_mux000013_1639
    );
  huffman_ins_v2_code_black_4_mux00001_f5_0 : MUXF5
    port map (
      I0 => huffman_ins_v2_code_black_4_mux000013_1639,
      I1 => huffman_ins_v2_code_black_4_mux000012_1638,
      S => huffman_ins_v2_ter_black_code(4),
      O => huffman_ins_v2_code_black_4_mux00001_f51
    );
  huffman_ins_v2_code_black_4_mux00001_f6 : MUXF6
    port map (
      I0 => huffman_ins_v2_code_black_4_mux00001_f51,
      I1 => huffman_ins_v2_code_black_4_mux00001_f5_1640,
      S => huffman_ins_v2_codetab_ter_black_width(2),
      O => huffman_ins_v2_code_black_4_mux0000
    );
  huffman_ins_v2_code_black_19_mux000011 : LUT4
    generic map(
      INIT => X"ABA8"
    )
    port map (
      I0 => huffman_ins_v2_code_black(19),
      I1 => huffman_ins_v2_codetab_ter_black_width(1),
      I2 => huffman_ins_v2_codetab_ter_black_width(0),
      I3 => huffman_ins_v2_code_table_ins_makeup_black_7_Q,
      O => huffman_ins_v2_code_black_19_mux00001
    );
  huffman_ins_v2_code_black_19_mux00001_f5 : MUXF5
    port map (
      I0 => huffman_ins_v2_code_black_19_mux00001_f5_rt_1594,
      I1 => huffman_ins_v2_code_black_19_mux00001,
      S => huffman_ins_v2_codetab_ter_black_width(2),
      O => huffman_ins_v2_code_black_19_mux00001_f5_1593
    );
  huffman_ins_v2_code_black_19_mux000012 : LUT4
    generic map(
      INIT => X"9810"
    )
    port map (
      I0 => huffman_ins_v2_codetab_ter_black_width(2),
      I1 => huffman_ins_v2_codetab_ter_black_width(1),
      I2 => huffman_ins_v2_code_black(19),
      I3 => huffman_ins_v2_code_black_15_mux0000_bdd1,
      O => huffman_ins_v2_code_black_19_mux000011_1592
    );
  huffman_ins_v2_code_black_19_mux00001_f6 : MUXF6
    port map (
      I0 => huffman_ins_v2_code_black_19_mux000011_1592,
      I1 => huffman_ins_v2_code_black_19_mux00001_f5_1593,
      S => huffman_ins_v2_codetab_ter_black_width(3),
      O => huffman_ins_v2_code_black_19_mux0000
    );
  huffman_ins_v2_code_black_18_mux000011 : LUT4
    generic map(
      INIT => X"ABA8"
    )
    port map (
      I0 => huffman_ins_v2_code_black(18),
      I1 => huffman_ins_v2_codetab_ter_black_width(1),
      I2 => huffman_ins_v2_codetab_ter_black_width(0),
      I3 => huffman_ins_v2_code_table_ins_makeup_black_6_Q,
      O => huffman_ins_v2_code_black_18_mux00001
    );
  huffman_ins_v2_code_black_18_mux00001_f5 : MUXF5
    port map (
      I0 => huffman_ins_v2_code_black_18_mux000011_1586,
      I1 => huffman_ins_v2_code_black_18_mux00001,
      S => huffman_ins_v2_codetab_ter_black_width(2),
      O => huffman_ins_v2_code_black_18_mux00001_f5_1588
    );
  huffman_ins_v2_code_black_18_mux000013 : LUT4
    generic map(
      INIT => X"9810"
    )
    port map (
      I0 => huffman_ins_v2_codetab_ter_black_width(2),
      I1 => huffman_ins_v2_codetab_ter_black_width(1),
      I2 => huffman_ins_v2_code_black(18),
      I3 => huffman_ins_v2_code_table_ins_makeup_black_8_Q,
      O => huffman_ins_v2_code_black_18_mux000012_1587
    );
  huffman_ins_v2_code_black_18_mux00001_f6 : MUXF6
    port map (
      I0 => huffman_ins_v2_code_black_18_mux000012_1587,
      I1 => huffman_ins_v2_code_black_18_mux00001_f5_1588,
      S => huffman_ins_v2_codetab_ter_black_width(3),
      O => huffman_ins_v2_code_black_18_mux0000
    );
  huffman_ins_v2_code_black_7_mux000011 : LUT4
    generic map(
      INIT => X"FF57"
    )
    port map (
      I0 => huffman_ins_v2_codetab_ter_black_width(2),
      I1 => huffman_ins_v2_codetab_ter_black_width(1),
      I2 => huffman_ins_v2_codetab_ter_black_width(0),
      I3 => huffman_ins_v2_code_black(7),
      O => huffman_ins_v2_code_black_7_mux00001
    );
  huffman_ins_v2_code_black_7_mux000012 : LUT4
    generic map(
      INIT => X"C080"
    )
    port map (
      I0 => huffman_ins_v2_codetab_ter_black_width(1),
      I1 => huffman_ins_v2_codetab_ter_black_width(2),
      I2 => huffman_ins_v2_code_black(7),
      I3 => huffman_ins_v2_codetab_ter_black_width(0),
      O => huffman_ins_v2_code_black_7_mux000011_1658
    );
  huffman_ins_v2_code_black_7_mux00001_f5 : MUXF5
    port map (
      I0 => huffman_ins_v2_code_black_7_mux000011_1658,
      I1 => huffman_ins_v2_code_black_7_mux00001,
      S => huffman_ins_v2_ter_black_code(7),
      O => huffman_ins_v2_code_black_7_mux00001_f5_1661
    );
  huffman_ins_v2_code_black_7_mux000013 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => huffman_ins_v2_codetab_ter_black_width(1),
      I1 => huffman_ins_v2_code_black_11_mux0000_bdd2,
      I2 => huffman_ins_v2_code_black_11_mux0000_bdd0,
      O => huffman_ins_v2_code_black_7_mux000012_1659
    );
  huffman_ins_v2_code_black_7_mux000014 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => huffman_ins_v2_codetab_ter_black_width(1),
      I1 => huffman_ins_v2_code_black(7),
      I2 => huffman_ins_v2_code_black_11_mux0000_bdd3,
      O => huffman_ins_v2_code_black_7_mux000013_1660
    );
  huffman_ins_v2_code_black_7_mux00001_f5_0 : MUXF5
    port map (
      I0 => huffman_ins_v2_code_black_7_mux000013_1660,
      I1 => huffman_ins_v2_code_black_7_mux000012_1659,
      S => huffman_ins_v2_codetab_ter_black_width(2),
      O => huffman_ins_v2_code_black_7_mux00001_f51
    );
  huffman_ins_v2_code_black_7_mux00001_f6 : MUXF6
    port map (
      I0 => huffman_ins_v2_code_black_7_mux00001_f51,
      I1 => huffman_ins_v2_code_black_7_mux00001_f5_1661,
      S => huffman_ins_v2_codetab_ter_black_width(3),
      O => huffman_ins_v2_code_black_7_mux0000
    );
  huffman_ins_v2_code_black_6_mux0000282 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => huffman_ins_v2_codetab_ter_black_width(0),
      I1 => huffman_ins_v2_code_table_ins_makeup_black_0_Q,
      I2 => huffman_ins_v2_ter_black_code(6),
      O => huffman_ins_v2_code_black_6_mux0000282_1654
    );
  huffman_ins_v2_code_black_17_mux000011 : LUT4
    generic map(
      INIT => X"ABA8"
    )
    port map (
      I0 => huffman_ins_v2_code_black(17),
      I1 => huffman_ins_v2_codetab_ter_black_width(1),
      I2 => huffman_ins_v2_codetab_ter_black_width(0),
      I3 => huffman_ins_v2_code_table_ins_makeup_black_5_Q,
      O => huffman_ins_v2_code_black_17_mux00001
    );
  huffman_ins_v2_code_black_17_mux000012 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => huffman_ins_v2_codetab_ter_black_width(1),
      I1 => huffman_ins_v2_code_table_ins_makeup_black_8_Q,
      I2 => huffman_ins_v2_code_black_11_mux0000_bdd5,
      O => huffman_ins_v2_code_black_17_mux000011_1578
    );
  huffman_ins_v2_code_black_17_mux00001_f5 : MUXF5
    port map (
      I0 => huffman_ins_v2_code_black_17_mux000011_1578,
      I1 => huffman_ins_v2_code_black_17_mux00001,
      S => huffman_ins_v2_codetab_ter_black_width(2),
      O => huffman_ins_v2_code_black_17_mux00001_f5_1581
    );
  huffman_ins_v2_code_black_17_mux000013 : LUT4
    generic map(
      INIT => X"DC54"
    )
    port map (
      I0 => huffman_ins_v2_codetab_ter_black_width(1),
      I1 => huffman_ins_v2_codetab_ter_black_width(2),
      I2 => huffman_ins_v2_code_black(17),
      I3 => huffman_ins_v2_code_table_ins_makeup_black_8_Q,
      O => huffman_ins_v2_code_black_17_mux000012_1579
    );
  huffman_ins_v2_code_black_17_mux000014 : LUT4
    generic map(
      INIT => X"9810"
    )
    port map (
      I0 => huffman_ins_v2_codetab_ter_black_width(2),
      I1 => huffman_ins_v2_codetab_ter_black_width(1),
      I2 => huffman_ins_v2_code_black(17),
      I3 => huffman_ins_v2_code_table_ins_makeup_black_8_Q,
      O => huffman_ins_v2_code_black_17_mux000013_1580
    );
  huffman_ins_v2_code_black_17_mux00001_f5_0 : MUXF5
    port map (
      I0 => huffman_ins_v2_code_black_17_mux000013_1580,
      I1 => huffman_ins_v2_code_black_17_mux000012_1579,
      S => huffman_ins_v2_code_black_15_mux0000_bdd1,
      O => huffman_ins_v2_code_black_17_mux00001_f51
    );
  huffman_ins_v2_code_black_17_mux00001_f6 : MUXF6
    port map (
      I0 => huffman_ins_v2_code_black_17_mux00001_f51,
      I1 => huffman_ins_v2_code_black_17_mux00001_f5_1581,
      S => huffman_ins_v2_codetab_ter_black_width(3),
      O => huffman_ins_v2_code_black_17_mux0000
    );
  huffman_ins_v2_code_black_16_mux000011 : LUT4
    generic map(
      INIT => X"ABA8"
    )
    port map (
      I0 => huffman_ins_v2_code_black(16),
      I1 => huffman_ins_v2_codetab_ter_black_width(1),
      I2 => huffman_ins_v2_codetab_ter_black_width(0),
      I3 => huffman_ins_v2_code_table_ins_makeup_black_4_Q,
      O => huffman_ins_v2_code_black_16_mux00001
    );
  huffman_ins_v2_code_black_16_mux000012 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => huffman_ins_v2_codetab_ter_black_width(1),
      I1 => huffman_ins_v2_code_black_10_mux0000_bdd4,
      I2 => huffman_ins_v2_code_black_10_mux0000_bdd5,
      O => huffman_ins_v2_code_black_16_mux000011_1572
    );
  huffman_ins_v2_code_black_16_mux00001_f5 : MUXF5
    port map (
      I0 => huffman_ins_v2_code_black_16_mux000011_1572,
      I1 => huffman_ins_v2_code_black_16_mux00001,
      S => huffman_ins_v2_codetab_ter_black_width(2),
      O => huffman_ins_v2_code_black_16_mux00001_f5_1574
    );
  huffman_ins_v2_code_black_16_mux000013 : LUT4
    generic map(
      INIT => X"AE04"
    )
    port map (
      I0 => huffman_ins_v2_codetab_ter_black_width(2),
      I1 => huffman_ins_v2_code_black(16),
      I2 => huffman_ins_v2_codetab_ter_black_width(1),
      I3 => huffman_ins_v2_code_table_ins_makeup_black_8_Q,
      O => huffman_ins_v2_code_black_16_mux000012_1573
    );
  huffman_ins_v2_code_black_16_mux00001_f6 : MUXF6
    port map (
      I0 => huffman_ins_v2_code_black_16_mux000012_1573,
      I1 => huffman_ins_v2_code_black_16_mux00001_f5_1574,
      S => huffman_ins_v2_codetab_ter_black_width(3),
      O => huffman_ins_v2_code_black_16_mux0000
    );
  huffman_ins_v2_code_black_9_mux0000212 : LUT4
    generic map(
      INIT => X"A820"
    )
    port map (
      I0 => huffman_ins_v2_codetab_ter_black_width(1),
      I1 => huffman_ins_v2_codetab_ter_black_width(2),
      I2 => huffman_ins_v2_ter_black_code(9),
      I3 => huffman_ins_v2_code_black(9),
      O => huffman_ins_v2_code_black_9_mux0000212_1670
    );
  huffman_ins_v2_code_black_9_mux00002135 : LUT4
    generic map(
      INIT => X"FAD8"
    )
    port map (
      I0 => huffman_ins_v2_codetab_ter_black_width(3),
      I1 => huffman_ins_v2_code_black_9_mux0000212_1670,
      I2 => huffman_ins_v2_code_black_9_mux00002107_1669,
      I3 => huffman_ins_v2_code_black_9_mux0000243,
      O => huffman_ins_v2_code_black_9_mux0000
    );
  huffman_ins_v2_code_black_8_mux00001153 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => huffman_ins_v2_codetab_ter_black_width(3),
      I1 => huffman_ins_v2_code_black_8_mux00001126_1665,
      I2 => huffman_ins_v2_code_black_8_mux0000172_1666,
      O => huffman_ins_v2_code_black_8_mux0000
    );
  huffman_ins_v2_code_black_15_mux0000112 : LUT4
    generic map(
      INIT => X"A820"
    )
    port map (
      I0 => huffman_ins_v2_codetab_ter_black_width(1),
      I1 => huffman_ins_v2_codetab_ter_black_width(2),
      I2 => huffman_ins_v2_code_black_11_mux0000_bdd3,
      I3 => huffman_ins_v2_code_black(15),
      O => huffman_ins_v2_code_black_15_mux0000112_1564
    );
  huffman_ins_v2_code_black_15_mux00001135 : LUT4
    generic map(
      INIT => X"FAD8"
    )
    port map (
      I0 => huffman_ins_v2_codetab_ter_black_width(3),
      I1 => huffman_ins_v2_code_black_15_mux0000112_1564,
      I2 => huffman_ins_v2_code_black_15_mux00001107,
      I3 => huffman_ins_v2_code_black_15_mux0000143,
      O => huffman_ins_v2_code_black_15_mux0000
    );
  huffman_ins_v2_code_black_14_mux0000112 : LUT4
    generic map(
      INIT => X"A820"
    )
    port map (
      I0 => huffman_ins_v2_codetab_ter_black_width(1),
      I1 => huffman_ins_v2_codetab_ter_black_width(2),
      I2 => huffman_ins_v2_code_black_10_mux0000_bdd3,
      I3 => huffman_ins_v2_code_black(14),
      O => huffman_ins_v2_code_black_14_mux0000112_1555
    );
  huffman_ins_v2_code_black_14_mux00001135 : LUT4
    generic map(
      INIT => X"FAD8"
    )
    port map (
      I0 => huffman_ins_v2_codetab_ter_black_width(3),
      I1 => huffman_ins_v2_code_black_14_mux0000112_1555,
      I2 => huffman_ins_v2_code_black_14_mux00001107_1554,
      I3 => huffman_ins_v2_code_black_14_mux0000143,
      O => huffman_ins_v2_code_black_14_mux0000
    );
  huffman_ins_v2_code_black_13_mux0000112 : LUT4
    generic map(
      INIT => X"A820"
    )
    port map (
      I0 => huffman_ins_v2_codetab_ter_black_width(1),
      I1 => huffman_ins_v2_codetab_ter_black_width(2),
      I2 => huffman_ins_v2_code_black_11_mux0000_bdd2,
      I3 => huffman_ins_v2_code_black(13),
      O => huffman_ins_v2_code_black_13_mux0000112_1548
    );
  huffman_ins_v2_code_black_13_mux00001135 : LUT4
    generic map(
      INIT => X"FAD8"
    )
    port map (
      I0 => huffman_ins_v2_codetab_ter_black_width(3),
      I1 => huffman_ins_v2_code_black_13_mux0000112_1548,
      I2 => huffman_ins_v2_code_black_13_mux00001107_1547,
      I3 => huffman_ins_v2_code_black_13_mux0000143,
      O => huffman_ins_v2_code_black_13_mux0000
    );
  huffman_ins_v2_code_black_12_mux0000112 : LUT4
    generic map(
      INIT => X"A820"
    )
    port map (
      I0 => huffman_ins_v2_codetab_ter_black_width(1),
      I1 => huffman_ins_v2_codetab_ter_black_width(2),
      I2 => huffman_ins_v2_code_black_10_mux0000_bdd2,
      I3 => huffman_ins_v2_code_black(12),
      O => huffman_ins_v2_code_black_12_mux0000112_1541
    );
  huffman_ins_v2_code_black_12_mux00001135 : LUT4
    generic map(
      INIT => X"FAD8"
    )
    port map (
      I0 => huffman_ins_v2_codetab_ter_black_width(3),
      I1 => huffman_ins_v2_code_black_12_mux0000112_1541,
      I2 => huffman_ins_v2_code_black_12_mux00001107_1540,
      I3 => huffman_ins_v2_code_black_12_mux0000143,
      O => huffman_ins_v2_code_black_12_mux0000
    );
  huffman_ins_v2_code_black_11_mux0000112 : LUT4
    generic map(
      INIT => X"A820"
    )
    port map (
      I0 => huffman_ins_v2_codetab_ter_black_width(1),
      I1 => huffman_ins_v2_codetab_ter_black_width(2),
      I2 => huffman_ins_v2_code_black_11_mux0000_bdd0,
      I3 => huffman_ins_v2_code_black(11),
      O => huffman_ins_v2_code_black_11_mux0000112_1530
    );
  huffman_ins_v2_code_black_11_mux00001135 : LUT4
    generic map(
      INIT => X"FAD8"
    )
    port map (
      I0 => huffman_ins_v2_codetab_ter_black_width(3),
      I1 => huffman_ins_v2_code_black_11_mux0000112_1530,
      I2 => huffman_ins_v2_code_black_11_mux00001107_1529,
      I3 => huffman_ins_v2_code_black_11_mux0000143,
      O => huffman_ins_v2_code_black_11_mux0000
    );
  huffman_ins_v2_code_black_10_mux000010 : LUT2
    generic map(
      INIT => X"8"
    )
    port map (
      I0 => huffman_ins_v2_codetab_ter_black_width(2),
      I1 => huffman_ins_v2_code_black(10),
      O => huffman_ins_v2_code_black_10_mux000010_1516
    );
  huffman_ins_v2_code_black_10_mux0000115 : LUT4
    generic map(
      INIT => X"0E04"
    )
    port map (
      I0 => huffman_ins_v2_codetab_ter_black_width(0),
      I1 => huffman_ins_v2_code_table_ins_makeup_black_0_Q,
      I2 => huffman_ins_v2_codetab_ter_black_width(2),
      I3 => huffman_ins_v2_ter_black_code(10),
      O => huffman_ins_v2_code_black_10_mux0000115_1519
    );
  huffman_ins_v2_code_black_10_mux00001103 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => huffman_ins_v2_codetab_ter_black_width(2),
      I1 => huffman_ins_v2_code_black_10_mux0000_bdd4,
      I2 => huffman_ins_v2_code_black_10_mux0000_bdd3,
      O => huffman_ins_v2_code_black_10_mux00001103_1517
    );
  huffman_ins_v2_code_black_10_mux00001116 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => huffman_ins_v2_codetab_ter_black_width(2),
      I1 => huffman_ins_v2_code_black(10),
      I2 => huffman_ins_v2_code_black_10_mux0000_bdd5,
      O => huffman_ins_v2_code_black_10_mux00001116_1518
    );
  fax4_ins_state_updated_mux000824 : LUT4
    generic map(
      INIT => X"0001"
    )
    port map (
      I0 => fax4_ins_state_FSM_FFd5_1333,
      I1 => fax4_ins_state_FSM_FFd10_1323,
      I2 => fax4_ins_state_FSM_FFd11_1325,
      I3 => fax4_ins_state_FSM_FFd8_1338,
      O => fax4_ins_state_updated_mux000824_1346
    );
  fax4_ins_FIFO2_multi_read_ins_mux2_and000011 : LUT3
    generic map(
      INIT => X"01"
    )
    port map (
      I0 => fax4_ins_FIFO2_multi_read_ins_used(2),
      I1 => fax4_ins_FIFO2_multi_read_ins_used(1),
      I2 => fax4_ins_FIFO2_multi_read_ins_N4,
      O => fax4_ins_FIFO2_multi_read_ins_N7
    );
  fax4_ins_FIFO1_multi_read_ins_mux2_and000011 : LUT3
    generic map(
      INIT => X"01"
    )
    port map (
      I0 => fax4_ins_FIFO1_multi_read_ins_used(2),
      I1 => fax4_ins_FIFO1_multi_read_ins_used(1),
      I2 => fax4_ins_FIFO1_multi_read_ins_N4,
      O => fax4_ins_FIFO1_multi_read_ins_N7
    );
  fax4_ins_FIFO2_multi_read_ins_mem_rd11_SW0 : LUT4
    generic map(
      INIT => X"FFFE"
    )
    port map (
      I0 => fax4_ins_FIFO2_multi_read_ins_used(6),
      I1 => fax4_ins_FIFO2_multi_read_ins_used(4),
      I2 => fax4_ins_FIFO2_multi_read_ins_used(3),
      I3 => fax4_ins_FIFO2_multi_read_ins_used(5),
      O => N24
    );
  fax4_ins_FIFO2_multi_read_ins_mem_rd11 : LUT4
    generic map(
      INIT => X"FFFE"
    )
    port map (
      I0 => fax4_ins_FIFO2_multi_read_ins_used(9),
      I1 => fax4_ins_FIFO2_multi_read_ins_used(8),
      I2 => fax4_ins_FIFO2_multi_read_ins_used(7),
      I3 => N24,
      O => fax4_ins_FIFO2_multi_read_ins_N4
    );
  fax4_ins_FIFO1_multi_read_ins_mem_rd11_SW0 : LUT4
    generic map(
      INIT => X"FFFE"
    )
    port map (
      I0 => fax4_ins_FIFO1_multi_read_ins_used(6),
      I1 => fax4_ins_FIFO1_multi_read_ins_used(4),
      I2 => fax4_ins_FIFO1_multi_read_ins_used(3),
      I3 => fax4_ins_FIFO1_multi_read_ins_used(5),
      O => N26
    );
  fax4_ins_FIFO1_multi_read_ins_mem_rd11 : LUT4
    generic map(
      INIT => X"FFFE"
    )
    port map (
      I0 => fax4_ins_FIFO1_multi_read_ins_used(9),
      I1 => fax4_ins_FIFO1_multi_read_ins_used(8),
      I2 => fax4_ins_FIFO1_multi_read_ins_used(7),
      I3 => N26,
      O => fax4_ins_FIFO1_multi_read_ins_N4
    );
  huffman_ins_v2_mux_code_white_width_2_1 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => huffman_ins_v2_a0_value_2_1510,
      I1 => huffman_ins_v2_code_black_width(2),
      I2 => huffman_ins_v2_code_white_width(2),
      O => huffman_ins_v2_Madd_hor_code_width_addsub0000_lut(2)
    );
  huffman_ins_v2_mux_code_white_width_1_1 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => huffman_ins_v2_a0_value_2_1510,
      I1 => huffman_ins_v2_code_black_width(1),
      I2 => huffman_ins_v2_code_white_width(1),
      O => huffman_ins_v2_mux_code_white_width(1)
    );
  huffman_ins_v2_mux_code_black_width_2_1 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => huffman_ins_v2_a0_value_2_1510,
      I1 => huffman_ins_v2_code_white_width(2),
      I2 => huffman_ins_v2_code_black_width(2),
      O => huffman_ins_v2_mux_code_black_width(2)
    );
  huffman_ins_v2_mux_code_black_width_1_1 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => huffman_ins_v2_a0_value_2_1510,
      I1 => huffman_ins_v2_code_white_width(1),
      I2 => huffman_ins_v2_code_black_width(1),
      O => huffman_ins_v2_mux_code_black_width(1)
    );
  huffman_ins_v2_hor_code_6_mux000327 : LUT4
    generic map(
      INIT => X"2000"
    )
    port map (
      I0 => huffman_ins_v2_Madd_hor_code_width_addsub0000_lut(2),
      I1 => huffman_ins_v2_Madd_hor_code_width_addsub0000_cy(0),
      I2 => huffman_ins_v2_mux_code_white_width(1),
      I3 => huffman_ins_v2_N100,
      O => huffman_ins_v2_hor_code_6_mux000327_2015
    );
  huffman_ins_v2_hor_code_6_mux000329 : LUT3
    generic map(
      INIT => X"EA"
    )
    port map (
      I0 => huffman_ins_v2_hor_code_6_mux000327_2015,
      I1 => huffman_ins_v2_hor_code(6),
      I2 => huffman_ins_v2_hor_code_6_mux000310_2014,
      O => huffman_ins_v2_hor_code_6_mux000329_2016
    );
  huffman_ins_v2_hor_code_6_mux000367 : LUT4
    generic map(
      INIT => X"AA80"
    )
    port map (
      I0 => huffman_ins_v2_code_black(6),
      I1 => huffman_ins_v2_N103,
      I2 => huffman_ins_v2_N39,
      I3 => huffman_ins_v2_hor_code_6_mux000361_2018,
      O => huffman_ins_v2_hor_code_6_mux000367_2019
    );
  fax4_ins_FIFO2_multi_read_ins_mux3_valid1 : LUT3
    generic map(
      INIT => X"FE"
    )
    port map (
      I0 => fax4_ins_FIFO2_multi_read_ins_mux3,
      I1 => fax4_ins_FIFO2_multi_read_ins_N4,
      I2 => fax4_ins_FIFO2_multi_read_ins_used(2),
      O => fax4_ins_FIFO2_multi_read_ins_mux3_valid
    );
  fax4_ins_FIFO1_multi_read_ins_mux3_valid1 : LUT3
    generic map(
      INIT => X"FE"
    )
    port map (
      I0 => fax4_ins_FIFO1_multi_read_ins_mux3,
      I1 => fax4_ins_FIFO1_multi_read_ins_N4,
      I2 => fax4_ins_FIFO1_multi_read_ins_used(2),
      O => fax4_ins_FIFO1_multi_read_ins_mux3_valid
    );
  fax4_ins_FIFO2_multi_read_ins_mux3_x_9_1 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => fax4_ins_FIFO2_multi_read_ins_mux3,
      I1 => fax4_ins_FIFO2_multi_read_ins_mem_data_out(9),
      I2 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(9),
      O => fax4_ins_FIFO2_multi_read_ins_mux3_x(9)
    );
  fax4_ins_FIFO2_multi_read_ins_mux3_x_8_1 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => fax4_ins_FIFO2_multi_read_ins_mux3,
      I1 => fax4_ins_FIFO2_multi_read_ins_mem_data_out(8),
      I2 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(8),
      O => fax4_ins_FIFO2_multi_read_ins_mux3_x(8)
    );
  fax4_ins_FIFO2_multi_read_ins_mux3_x_7_1 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => fax4_ins_FIFO2_multi_read_ins_mux3,
      I1 => fax4_ins_FIFO2_multi_read_ins_mem_data_out(7),
      I2 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(7),
      O => fax4_ins_FIFO2_multi_read_ins_mux3_x(7)
    );
  fax4_ins_FIFO2_multi_read_ins_mux3_x_6_1 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => fax4_ins_FIFO2_multi_read_ins_mux3,
      I1 => fax4_ins_FIFO2_multi_read_ins_mem_data_out(6),
      I2 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(6),
      O => fax4_ins_FIFO2_multi_read_ins_mux3_x(6)
    );
  fax4_ins_FIFO2_multi_read_ins_mux3_x_5_1 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => fax4_ins_FIFO2_multi_read_ins_mux3,
      I1 => fax4_ins_FIFO2_multi_read_ins_mem_data_out(5),
      I2 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(5),
      O => fax4_ins_FIFO2_multi_read_ins_mux3_x(5)
    );
  fax4_ins_FIFO2_multi_read_ins_mux3_x_4_1 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => fax4_ins_FIFO2_multi_read_ins_mux3,
      I1 => fax4_ins_FIFO2_multi_read_ins_mem_data_out(4),
      I2 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(4),
      O => fax4_ins_FIFO2_multi_read_ins_mux3_x(4)
    );
  fax4_ins_FIFO2_multi_read_ins_mux3_x_3_1 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => fax4_ins_FIFO2_multi_read_ins_mux3,
      I1 => fax4_ins_FIFO2_multi_read_ins_mem_data_out(3),
      I2 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(3),
      O => fax4_ins_FIFO2_multi_read_ins_mux3_x(3)
    );
  fax4_ins_FIFO2_multi_read_ins_mux3_x_2_1 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => fax4_ins_FIFO2_multi_read_ins_mux3,
      I1 => fax4_ins_FIFO2_multi_read_ins_mem_data_out(2),
      I2 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(2),
      O => fax4_ins_FIFO2_multi_read_ins_mux3_x(2)
    );
  fax4_ins_FIFO2_multi_read_ins_mux3_x_1_1 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => fax4_ins_FIFO2_multi_read_ins_mux3,
      I1 => fax4_ins_FIFO2_multi_read_ins_mem_data_out(1),
      I2 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(1),
      O => fax4_ins_FIFO2_multi_read_ins_mux3_x(1)
    );
  fax4_ins_FIFO2_multi_read_ins_mux3_x_0_1 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => fax4_ins_FIFO2_multi_read_ins_mux3,
      I1 => fax4_ins_FIFO2_multi_read_ins_mem_data_out(0),
      I2 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(0),
      O => fax4_ins_FIFO2_multi_read_ins_mux3_x(0)
    );
  fax4_ins_FIFO2_multi_read_ins_mux3_to_white1 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => fax4_ins_FIFO2_multi_read_ins_mux3,
      I1 => fax4_ins_FIFO2_multi_read_ins_mem_data_out(10),
      I2 => fax4_ins_to_white_1349,
      O => fax4_ins_FIFO2_multi_read_ins_mux3_to_white
    );
  fax4_ins_FIFO1_multi_read_ins_mux3_x_9_1 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => fax4_ins_FIFO1_multi_read_ins_mux3,
      I1 => fax4_ins_FIFO1_multi_read_ins_mem_data_out(9),
      I2 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(9),
      O => fax4_ins_FIFO1_multi_read_ins_mux3_x(9)
    );
  fax4_ins_FIFO1_multi_read_ins_mux3_x_8_1 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => fax4_ins_FIFO1_multi_read_ins_mux3,
      I1 => fax4_ins_FIFO1_multi_read_ins_mem_data_out(8),
      I2 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(8),
      O => fax4_ins_FIFO1_multi_read_ins_mux3_x(8)
    );
  fax4_ins_FIFO1_multi_read_ins_mux3_x_7_1 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => fax4_ins_FIFO1_multi_read_ins_mux3,
      I1 => fax4_ins_FIFO1_multi_read_ins_mem_data_out(7),
      I2 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(7),
      O => fax4_ins_FIFO1_multi_read_ins_mux3_x(7)
    );
  fax4_ins_FIFO1_multi_read_ins_mux3_x_6_1 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => fax4_ins_FIFO1_multi_read_ins_mux3,
      I1 => fax4_ins_FIFO1_multi_read_ins_mem_data_out(6),
      I2 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(6),
      O => fax4_ins_FIFO1_multi_read_ins_mux3_x(6)
    );
  fax4_ins_FIFO1_multi_read_ins_mux3_x_5_1 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => fax4_ins_FIFO1_multi_read_ins_mux3,
      I1 => fax4_ins_FIFO1_multi_read_ins_mem_data_out(5),
      I2 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(5),
      O => fax4_ins_FIFO1_multi_read_ins_mux3_x(5)
    );
  fax4_ins_FIFO1_multi_read_ins_mux3_x_4_1 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => fax4_ins_FIFO1_multi_read_ins_mux3,
      I1 => fax4_ins_FIFO1_multi_read_ins_mem_data_out(4),
      I2 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(4),
      O => fax4_ins_FIFO1_multi_read_ins_mux3_x(4)
    );
  fax4_ins_FIFO1_multi_read_ins_mux3_x_3_1 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => fax4_ins_FIFO1_multi_read_ins_mux3,
      I1 => fax4_ins_FIFO1_multi_read_ins_mem_data_out(3),
      I2 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(3),
      O => fax4_ins_FIFO1_multi_read_ins_mux3_x(3)
    );
  fax4_ins_FIFO1_multi_read_ins_mux3_x_2_1 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => fax4_ins_FIFO1_multi_read_ins_mux3,
      I1 => fax4_ins_FIFO1_multi_read_ins_mem_data_out(2),
      I2 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(2),
      O => fax4_ins_FIFO1_multi_read_ins_mux3_x(2)
    );
  fax4_ins_FIFO1_multi_read_ins_mux3_x_1_1 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => fax4_ins_FIFO1_multi_read_ins_mux3,
      I1 => fax4_ins_FIFO1_multi_read_ins_mem_data_out(1),
      I2 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(1),
      O => fax4_ins_FIFO1_multi_read_ins_mux3_x(1)
    );
  fax4_ins_FIFO1_multi_read_ins_mux3_x_0_1 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => fax4_ins_FIFO1_multi_read_ins_mux3,
      I1 => fax4_ins_FIFO1_multi_read_ins_mem_data_out(0),
      I2 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(0),
      O => fax4_ins_FIFO1_multi_read_ins_mux3_x(0)
    );
  fax4_ins_FIFO1_multi_read_ins_mux3_to_white1 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => fax4_ins_FIFO1_multi_read_ins_mux3,
      I1 => fax4_ins_FIFO1_multi_read_ins_mem_data_out(10),
      I2 => fax4_ins_to_white_1349,
      O => fax4_ins_FIFO1_multi_read_ins_mux3_to_white
    );
  huffman_ins_v2_run_length_black_1_1 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => fax4_ins_a0_value_o_950,
      I1 => huffman_ins_v2_run_length_white_sub0000(1),
      I2 => huffman_ins_v2_run_length_white_sub0001(1),
      O => huffman_ins_v2_run_length_black(1)
    );
  huffman_ins_v2_run_length_black_2_1 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => fax4_ins_a0_value_o_950,
      I1 => huffman_ins_v2_run_length_white_sub0000(2),
      I2 => huffman_ins_v2_run_length_white_sub0001(2),
      O => huffman_ins_v2_run_length_black(2)
    );
  huffman_ins_v2_run_length_black_3_1 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => fax4_ins_a0_value_o_950,
      I1 => huffman_ins_v2_run_length_white_sub0000(3),
      I2 => huffman_ins_v2_run_length_white_sub0001(3),
      O => huffman_ins_v2_run_length_black(3)
    );
  huffman_ins_v2_run_length_black_4_1 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => fax4_ins_a0_value_o_950,
      I1 => huffman_ins_v2_run_length_white_sub0000(4),
      I2 => huffman_ins_v2_run_length_white_sub0001(4),
      O => huffman_ins_v2_run_length_black(4)
    );
  huffman_ins_v2_run_length_black_5_1 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => fax4_ins_a0_value_o_950,
      I1 => huffman_ins_v2_run_length_white_sub0000(5),
      I2 => huffman_ins_v2_run_length_white_sub0001(5),
      O => huffman_ins_v2_run_length_black(5)
    );
  fax4_ins_state_updated_mux000811 : LUT2
    generic map(
      INIT => X"7"
    )
    port map (
      I0 => fax4_ins_pix_changed_1319,
      I1 => fax4_ins_state_FSM_FFd8_1338,
      O => fax4_ins_N20
    );
  fax4_ins_FIFO2_multi_read_ins_mux2_x_9_1 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => fax4_ins_FIFO2_multi_read_ins_mux2,
      I1 => fax4_ins_FIFO2_multi_read_ins_data3_o(9),
      I2 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(9),
      O => fax4_ins_FIFO2_multi_read_ins_mux2_x(9)
    );
  fax4_ins_FIFO2_multi_read_ins_mux2_x_8_1 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => fax4_ins_FIFO2_multi_read_ins_mux2,
      I1 => fax4_ins_FIFO2_multi_read_ins_data3_o(8),
      I2 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(8),
      O => fax4_ins_FIFO2_multi_read_ins_mux2_x(8)
    );
  fax4_ins_FIFO2_multi_read_ins_mux2_x_7_1 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => fax4_ins_FIFO2_multi_read_ins_mux2,
      I1 => fax4_ins_FIFO2_multi_read_ins_data3_o(7),
      I2 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(7),
      O => fax4_ins_FIFO2_multi_read_ins_mux2_x(7)
    );
  fax4_ins_FIFO2_multi_read_ins_mux2_x_6_1 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => fax4_ins_FIFO2_multi_read_ins_mux2,
      I1 => fax4_ins_FIFO2_multi_read_ins_data3_o(6),
      I2 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(6),
      O => fax4_ins_FIFO2_multi_read_ins_mux2_x(6)
    );
  fax4_ins_FIFO2_multi_read_ins_mux2_x_5_1 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => fax4_ins_FIFO2_multi_read_ins_mux2,
      I1 => fax4_ins_FIFO2_multi_read_ins_data3_o(5),
      I2 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(5),
      O => fax4_ins_FIFO2_multi_read_ins_mux2_x(5)
    );
  fax4_ins_FIFO2_multi_read_ins_mux2_x_4_1 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => fax4_ins_FIFO2_multi_read_ins_mux2,
      I1 => fax4_ins_FIFO2_multi_read_ins_data3_o(4),
      I2 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(4),
      O => fax4_ins_FIFO2_multi_read_ins_mux2_x(4)
    );
  fax4_ins_FIFO2_multi_read_ins_mux2_x_3_1 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => fax4_ins_FIFO2_multi_read_ins_mux2,
      I1 => fax4_ins_FIFO2_multi_read_ins_data3_o(3),
      I2 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(3),
      O => fax4_ins_FIFO2_multi_read_ins_mux2_x(3)
    );
  fax4_ins_FIFO2_multi_read_ins_mux2_x_2_1 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => fax4_ins_FIFO2_multi_read_ins_mux2,
      I1 => fax4_ins_FIFO2_multi_read_ins_data3_o(2),
      I2 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(2),
      O => fax4_ins_FIFO2_multi_read_ins_mux2_x(2)
    );
  fax4_ins_FIFO2_multi_read_ins_mux2_x_1_1 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => fax4_ins_FIFO2_multi_read_ins_mux2,
      I1 => fax4_ins_FIFO2_multi_read_ins_data3_o(1),
      I2 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(1),
      O => fax4_ins_FIFO2_multi_read_ins_mux2_x(1)
    );
  fax4_ins_FIFO2_multi_read_ins_mux2_x_0_1 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => fax4_ins_FIFO2_multi_read_ins_mux2,
      I1 => fax4_ins_FIFO2_multi_read_ins_data3_o(0),
      I2 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(0),
      O => fax4_ins_FIFO2_multi_read_ins_mux2_x(0)
    );
  fax4_ins_FIFO2_multi_read_ins_mux2_to_white1 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => fax4_ins_FIFO2_multi_read_ins_mux2,
      I1 => fax4_ins_FIFO2_multi_read_ins_to_white3_o_685,
      I2 => fax4_ins_to_white_1349,
      O => fax4_ins_FIFO2_multi_read_ins_mux2_to_white
    );
  fax4_ins_FIFO2_multi_read_ins_mux1_x_9_1 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => fax4_ins_FIFO2_multi_read_ins_N11,
      I1 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(9),
      I2 => fax4_ins_FIFO2_multi_read_ins_data2_o(9),
      O => fax4_ins_FIFO2_multi_read_ins_mux1_x(9)
    );
  fax4_ins_FIFO2_multi_read_ins_mux1_x_8_1 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => fax4_ins_FIFO2_multi_read_ins_N11,
      I1 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(8),
      I2 => fax4_ins_FIFO2_multi_read_ins_data2_o(8),
      O => fax4_ins_FIFO2_multi_read_ins_mux1_x(8)
    );
  fax4_ins_FIFO2_multi_read_ins_mux1_x_7_1 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => fax4_ins_FIFO2_multi_read_ins_N11,
      I1 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(7),
      I2 => fax4_ins_FIFO2_multi_read_ins_data2_o(7),
      O => fax4_ins_FIFO2_multi_read_ins_mux1_x(7)
    );
  fax4_ins_FIFO2_multi_read_ins_mux1_x_6_1 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => fax4_ins_FIFO2_multi_read_ins_N11,
      I1 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(6),
      I2 => fax4_ins_FIFO2_multi_read_ins_data2_o(6),
      O => fax4_ins_FIFO2_multi_read_ins_mux1_x(6)
    );
  fax4_ins_FIFO2_multi_read_ins_mux1_x_5_1 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => fax4_ins_FIFO2_multi_read_ins_N11,
      I1 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(5),
      I2 => fax4_ins_FIFO2_multi_read_ins_data2_o(5),
      O => fax4_ins_FIFO2_multi_read_ins_mux1_x(5)
    );
  fax4_ins_FIFO2_multi_read_ins_mux1_x_4_1 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => fax4_ins_FIFO2_multi_read_ins_N11,
      I1 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(4),
      I2 => fax4_ins_FIFO2_multi_read_ins_data2_o(4),
      O => fax4_ins_FIFO2_multi_read_ins_mux1_x(4)
    );
  fax4_ins_FIFO2_multi_read_ins_mux1_x_3_1 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => fax4_ins_FIFO2_multi_read_ins_N11,
      I1 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(3),
      I2 => fax4_ins_FIFO2_multi_read_ins_data2_o(3),
      O => fax4_ins_FIFO2_multi_read_ins_mux1_x(3)
    );
  fax4_ins_FIFO2_multi_read_ins_mux1_x_2_1 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => fax4_ins_FIFO2_multi_read_ins_N11,
      I1 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(2),
      I2 => fax4_ins_FIFO2_multi_read_ins_data2_o(2),
      O => fax4_ins_FIFO2_multi_read_ins_mux1_x(2)
    );
  fax4_ins_FIFO2_multi_read_ins_mux1_x_1_1 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => fax4_ins_FIFO2_multi_read_ins_N11,
      I1 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(1),
      I2 => fax4_ins_FIFO2_multi_read_ins_data2_o(1),
      O => fax4_ins_FIFO2_multi_read_ins_mux1_x(1)
    );
  fax4_ins_FIFO2_multi_read_ins_mux1_x_0_1 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => fax4_ins_FIFO2_multi_read_ins_N11,
      I1 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(0),
      I2 => fax4_ins_FIFO2_multi_read_ins_data2_o(0),
      O => fax4_ins_FIFO2_multi_read_ins_mux1_x(0)
    );
  fax4_ins_FIFO2_multi_read_ins_mux1_to_white2 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => fax4_ins_FIFO2_multi_read_ins_N11,
      I1 => fax4_ins_to_white_1349,
      I2 => fax4_ins_FIFO2_multi_read_ins_to_white2_o_684,
      O => fax4_ins_FIFO2_multi_read_ins_mux1_to_white
    );
  fax4_ins_FIFO1_multi_read_ins_mux2_x_9_1 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => fax4_ins_FIFO1_multi_read_ins_mux2,
      I1 => fax4_ins_FIFO1_multi_read_ins_data3_o(9),
      I2 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(9),
      O => fax4_ins_FIFO1_multi_read_ins_mux2_x(9)
    );
  fax4_ins_FIFO1_multi_read_ins_mux2_x_8_1 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => fax4_ins_FIFO1_multi_read_ins_mux2,
      I1 => fax4_ins_FIFO1_multi_read_ins_data3_o(8),
      I2 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(8),
      O => fax4_ins_FIFO1_multi_read_ins_mux2_x(8)
    );
  fax4_ins_FIFO1_multi_read_ins_mux2_x_7_1 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => fax4_ins_FIFO1_multi_read_ins_mux2,
      I1 => fax4_ins_FIFO1_multi_read_ins_data3_o(7),
      I2 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(7),
      O => fax4_ins_FIFO1_multi_read_ins_mux2_x(7)
    );
  fax4_ins_FIFO1_multi_read_ins_mux2_x_6_1 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => fax4_ins_FIFO1_multi_read_ins_mux2,
      I1 => fax4_ins_FIFO1_multi_read_ins_data3_o(6),
      I2 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(6),
      O => fax4_ins_FIFO1_multi_read_ins_mux2_x(6)
    );
  fax4_ins_FIFO1_multi_read_ins_mux2_x_5_1 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => fax4_ins_FIFO1_multi_read_ins_mux2,
      I1 => fax4_ins_FIFO1_multi_read_ins_data3_o(5),
      I2 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(5),
      O => fax4_ins_FIFO1_multi_read_ins_mux2_x(5)
    );
  fax4_ins_FIFO1_multi_read_ins_mux2_x_4_1 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => fax4_ins_FIFO1_multi_read_ins_mux2,
      I1 => fax4_ins_FIFO1_multi_read_ins_data3_o(4),
      I2 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(4),
      O => fax4_ins_FIFO1_multi_read_ins_mux2_x(4)
    );
  fax4_ins_FIFO1_multi_read_ins_mux2_x_3_1 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => fax4_ins_FIFO1_multi_read_ins_mux2,
      I1 => fax4_ins_FIFO1_multi_read_ins_data3_o(3),
      I2 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(3),
      O => fax4_ins_FIFO1_multi_read_ins_mux2_x(3)
    );
  fax4_ins_FIFO1_multi_read_ins_mux2_x_2_1 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => fax4_ins_FIFO1_multi_read_ins_mux2,
      I1 => fax4_ins_FIFO1_multi_read_ins_data3_o(2),
      I2 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(2),
      O => fax4_ins_FIFO1_multi_read_ins_mux2_x(2)
    );
  fax4_ins_FIFO1_multi_read_ins_mux2_x_1_1 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => fax4_ins_FIFO1_multi_read_ins_mux2,
      I1 => fax4_ins_FIFO1_multi_read_ins_data3_o(1),
      I2 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(1),
      O => fax4_ins_FIFO1_multi_read_ins_mux2_x(1)
    );
  fax4_ins_FIFO1_multi_read_ins_mux2_x_0_1 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => fax4_ins_FIFO1_multi_read_ins_mux2,
      I1 => fax4_ins_FIFO1_multi_read_ins_data3_o(0),
      I2 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(0),
      O => fax4_ins_FIFO1_multi_read_ins_mux2_x(0)
    );
  fax4_ins_FIFO1_multi_read_ins_mux2_to_white1 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => fax4_ins_FIFO1_multi_read_ins_mux2,
      I1 => fax4_ins_FIFO1_multi_read_ins_to_white3_o_443,
      I2 => fax4_ins_to_white_1349,
      O => fax4_ins_FIFO1_multi_read_ins_mux2_to_white
    );
  fax4_ins_FIFO1_multi_read_ins_mux1_x_9_1 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => fax4_ins_FIFO1_multi_read_ins_N11,
      I1 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(9),
      I2 => fax4_ins_FIFO1_multi_read_ins_data2_o(9),
      O => fax4_ins_FIFO1_multi_read_ins_mux1_x(9)
    );
  fax4_ins_FIFO1_multi_read_ins_mux1_x_8_1 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => fax4_ins_FIFO1_multi_read_ins_N11,
      I1 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(8),
      I2 => fax4_ins_FIFO1_multi_read_ins_data2_o(8),
      O => fax4_ins_FIFO1_multi_read_ins_mux1_x(8)
    );
  fax4_ins_FIFO1_multi_read_ins_mux1_x_7_1 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => fax4_ins_FIFO1_multi_read_ins_N11,
      I1 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(7),
      I2 => fax4_ins_FIFO1_multi_read_ins_data2_o(7),
      O => fax4_ins_FIFO1_multi_read_ins_mux1_x(7)
    );
  fax4_ins_FIFO1_multi_read_ins_mux1_x_6_1 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => fax4_ins_FIFO1_multi_read_ins_N11,
      I1 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(6),
      I2 => fax4_ins_FIFO1_multi_read_ins_data2_o(6),
      O => fax4_ins_FIFO1_multi_read_ins_mux1_x(6)
    );
  fax4_ins_FIFO1_multi_read_ins_mux1_x_5_1 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => fax4_ins_FIFO1_multi_read_ins_N11,
      I1 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(5),
      I2 => fax4_ins_FIFO1_multi_read_ins_data2_o(5),
      O => fax4_ins_FIFO1_multi_read_ins_mux1_x(5)
    );
  fax4_ins_FIFO1_multi_read_ins_mux1_x_4_1 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => fax4_ins_FIFO1_multi_read_ins_N11,
      I1 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(4),
      I2 => fax4_ins_FIFO1_multi_read_ins_data2_o(4),
      O => fax4_ins_FIFO1_multi_read_ins_mux1_x(4)
    );
  fax4_ins_FIFO1_multi_read_ins_mux1_x_3_1 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => fax4_ins_FIFO1_multi_read_ins_N11,
      I1 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(3),
      I2 => fax4_ins_FIFO1_multi_read_ins_data2_o(3),
      O => fax4_ins_FIFO1_multi_read_ins_mux1_x(3)
    );
  fax4_ins_FIFO1_multi_read_ins_mux1_x_2_1 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => fax4_ins_FIFO1_multi_read_ins_N11,
      I1 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(2),
      I2 => fax4_ins_FIFO1_multi_read_ins_data2_o(2),
      O => fax4_ins_FIFO1_multi_read_ins_mux1_x(2)
    );
  fax4_ins_FIFO1_multi_read_ins_mux1_x_1_1 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => fax4_ins_FIFO1_multi_read_ins_N11,
      I1 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(1),
      I2 => fax4_ins_FIFO1_multi_read_ins_data2_o(1),
      O => fax4_ins_FIFO1_multi_read_ins_mux1_x(1)
    );
  fax4_ins_FIFO1_multi_read_ins_mux1_x_0_1 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => fax4_ins_FIFO1_multi_read_ins_N11,
      I1 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(0),
      I2 => fax4_ins_FIFO1_multi_read_ins_data2_o(0),
      O => fax4_ins_FIFO1_multi_read_ins_mux1_x(0)
    );
  fax4_ins_FIFO1_multi_read_ins_mux1_to_white2 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => fax4_ins_FIFO1_multi_read_ins_N11,
      I1 => fax4_ins_to_white_1349,
      I2 => fax4_ins_FIFO1_multi_read_ins_to_white2_o_442,
      O => fax4_ins_FIFO1_multi_read_ins_mux1_to_white
    );
  huffman_ins_v2_run_length_white_and000020 : LUT4
    generic map(
      INIT => X"0001"
    )
    port map (
      I0 => fax4_ins_a0_o(2),
      I1 => fax4_ins_a0_o(3),
      I2 => fax4_ins_a0_o(4),
      I3 => fax4_ins_a0_o(0),
      O => huffman_ins_v2_run_length_white_and000020_2134
    );
  huffman_ins_v2_run_length_white_and000043 : LUT4
    generic map(
      INIT => X"0001"
    )
    port map (
      I0 => fax4_ins_a0_o(6),
      I1 => fax4_ins_a0_o(7),
      I2 => fax4_ins_a0_o(8),
      I3 => fax4_ins_a0_o(1),
      O => huffman_ins_v2_run_length_white_and000043_2135
    );
  huffman_ins_v2_run_length_white_and000045 : LUT3
    generic map(
      INIT => X"80"
    )
    port map (
      I0 => huffman_ins_v2_run_length_white_and00007_2136,
      I1 => huffman_ins_v2_run_length_white_and000020_2134,
      I2 => huffman_ins_v2_run_length_white_and000043_2135,
      O => huffman_ins_v2_run_length_white_and0000
    );
  fax4_ins_FIFO2_multi_read_ins_mux2_and00001 : LUT3
    generic map(
      INIT => X"80"
    )
    port map (
      I0 => fax4_ins_FIFO2_multi_read_ins_used(0),
      I1 => fax4_ins_fifo2_wr,
      I2 => fax4_ins_FIFO2_multi_read_ins_N7,
      O => fax4_ins_FIFO2_multi_read_ins_mux2
    );
  fax4_ins_FIFO2_multi_read_ins_mux1_to_white11 : LUT3
    generic map(
      INIT => X"F7"
    )
    port map (
      I0 => fax4_ins_fifo2_wr,
      I1 => fax4_ins_FIFO2_multi_read_ins_N7,
      I2 => fax4_ins_FIFO2_multi_read_ins_used(0),
      O => fax4_ins_FIFO2_multi_read_ins_N11
    );
  fax4_ins_FIFO1_multi_read_ins_mux2_and00001 : LUT3
    generic map(
      INIT => X"80"
    )
    port map (
      I0 => fax4_ins_FIFO1_multi_read_ins_used(0),
      I1 => fax4_ins_fifo1_wr,
      I2 => fax4_ins_FIFO1_multi_read_ins_N7,
      O => fax4_ins_FIFO1_multi_read_ins_mux2
    );
  fax4_ins_FIFO1_multi_read_ins_mux1_to_white11 : LUT3
    generic map(
      INIT => X"F7"
    )
    port map (
      I0 => fax4_ins_fifo1_wr,
      I1 => fax4_ins_FIFO1_multi_read_ins_N7,
      I2 => fax4_ins_FIFO1_multi_read_ins_used(0),
      O => fax4_ins_FIFO1_multi_read_ins_N11
    );
  huffman_ins_v2_run_length_black_6_1 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => fax4_ins_a0_value_o_950,
      I1 => huffman_ins_v2_run_length_white_sub0000(6),
      I2 => huffman_ins_v2_run_length_white_sub0001(6),
      O => huffman_ins_v2_run_length_black(6)
    );
  huffman_ins_v2_code_table_ins_Mrom_makeup_black_mux000141 : LUT3
    generic map(
      INIT => X"A2"
    )
    port map (
      I0 => huffman_ins_v2_run_length_black(8),
      I1 => huffman_ins_v2_run_length_black(9),
      I2 => huffman_ins_v2_run_length_black(7),
      O => huffman_ins_v2_code_table_ins_Mrom_makeup_black_mux00014
    );
  huffman_ins_v2_code_table_ins_Mrom_makeup_black_mux0001111 : LUT4
    generic map(
      INIT => X"9998"
    )
    port map (
      I0 => huffman_ins_v2_run_length_black(9),
      I1 => huffman_ins_v2_run_length_black(7),
      I2 => huffman_ins_v2_run_length_black(6),
      I3 => huffman_ins_v2_run_length_black(8),
      O => huffman_ins_v2_code_table_ins_Mrom_makeup_black_mux00011
    );
  huffman_ins_v2_code_table_ins_Mrom_makeup_black_mux000151 : LUT4
    generic map(
      INIT => X"9C98"
    )
    port map (
      I0 => N465,
      I1 => huffman_ins_v2_run_length_black(8),
      I2 => huffman_ins_v2_run_length_black(9),
      I3 => huffman_ins_v2_run_length_black(6),
      O => huffman_ins_v2_code_table_ins_Mrom_makeup_black_mux00015
    );
  huffman_ins_v2_code_table_ins_Mrom_makeup_black_mux000131 : LUT4
    generic map(
      INIT => X"3F36"
    )
    port map (
      I0 => huffman_ins_v2_run_length_black(6),
      I1 => huffman_ins_v2_run_length_black(8),
      I2 => huffman_ins_v2_run_length_black(7),
      I3 => huffman_ins_v2_run_length_black(9),
      O => huffman_ins_v2_code_table_ins_Mrom_makeup_black_mux00013
    );
  huffman_ins_v2_code_table_ins_Mrom_makeup_black_mux000121 : LUT4
    generic map(
      INIT => X"6362"
    )
    port map (
      I0 => huffman_ins_v2_run_length_black(9),
      I1 => huffman_ins_v2_run_length_black(7),
      I2 => huffman_ins_v2_run_length_black(8),
      I3 => huffman_ins_v2_run_length_black(6),
      O => huffman_ins_v2_code_table_ins_Mrom_makeup_black_mux00012
    );
  fax4_ins_load_mux_b_SW0 : LUT3
    generic map(
      INIT => X"EA"
    )
    port map (
      I0 => fax4_ins_pass_mode,
      I1 => fax4_ins_state_FSM_FFd10_1323,
      I2 => fax4_ins_state_updated_1345,
      O => N56
    );
  fax4_ins_load_mux_b : LUT4
    generic map(
      INIT => X"FFA8"
    )
    port map (
      I0 => fax4_ins_pix_changed_1319,
      I1 => fax4_ins_vertical_mode_cmp_le0000,
      I2 => fax4_ins_state_FSM_FFd8_1338,
      I3 => N56,
      O => fax4_ins_load_mux_b_1285
    );
  fax4_ins_fifo_out2_valid1 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt(0),
      I1 => fax4_ins_FIFO2_multi_read_ins_valid2_o_699,
      I2 => fax4_ins_FIFO1_multi_read_ins_valid2_o_457,
      O => fax4_ins_fifo_out2_valid
    );
  huffman_ins_v2_run_length_black_8_1 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => fax4_ins_a0_value_o_950,
      I1 => huffman_ins_v2_run_length_white_sub0000(8),
      I2 => huffman_ins_v2_run_length_white_sub0001(8),
      O => huffman_ins_v2_run_length_black(8)
    );
  huffman_ins_v2_code_table_ins_Mrom_makeup_black_mux0001151 : LUT3
    generic map(
      INIT => X"FE"
    )
    port map (
      I0 => huffman_ins_v2_run_length_black(9),
      I1 => huffman_ins_v2_run_length_black(7),
      I2 => huffman_ins_v2_run_length_black(8),
      O => huffman_ins_v2_code_table_ins_Mrom_makeup_black_mux000115
    );
  huffman_ins_v2_run_length_black_9_1 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => fax4_ins_a0_value_o_950,
      I1 => huffman_ins_v2_run_length_white_sub0000(9),
      I2 => huffman_ins_v2_run_length_white_sub0001(9),
      O => huffman_ins_v2_run_length_black(9)
    );
  huffman_ins_v2_code_table_ins_Mrom_makeup_white_mux000113 : LUT3
    generic map(
      INIT => X"36"
    )
    port map (
      I0 => huffman_ins_v2_run_length_white(8),
      I1 => huffman_ins_v2_run_length_white(6),
      I2 => huffman_ins_v2_run_length_white(9),
      O => huffman_ins_v2_code_table_ins_Mrom_makeup_white_mux0001
    );
  huffman_ins_v2_code_table_ins_Mrom_makeup_white_mux000171 : LUT4
    generic map(
      INIT => X"AA80"
    )
    port map (
      I0 => huffman_ins_v2_run_length_white(9),
      I1 => huffman_ins_v2_run_length_white(6),
      I2 => huffman_ins_v2_run_length_white(7),
      I3 => huffman_ins_v2_run_length_white(8),
      O => huffman_ins_v2_code_table_ins_Mrom_makeup_white_mux00017
    );
  huffman_ins_v2_code_table_ins_Mrom_makeup_white_mux000151 : LUT4
    generic map(
      INIT => X"2666"
    )
    port map (
      I0 => huffman_ins_v2_run_length_white(8),
      I1 => huffman_ins_v2_run_length_white(9),
      I2 => huffman_ins_v2_run_length_white(6),
      I3 => huffman_ins_v2_run_length_white(7),
      O => huffman_ins_v2_code_table_ins_Mrom_makeup_white_mux00015
    );
  huffman_ins_v2_code_table_ins_Mrom_makeup_white_mux000131 : LUT4
    generic map(
      INIT => X"2062"
    )
    port map (
      I0 => huffman_ins_v2_run_length_white(6),
      I1 => huffman_ins_v2_run_length_white(8),
      I2 => huffman_ins_v2_run_length_white(9),
      I3 => huffman_ins_v2_run_length_white(7),
      O => huffman_ins_v2_code_table_ins_Mrom_makeup_white_mux00013
    );
  huffman_ins_v2_code_table_ins_Mrom_makeup_white_mux000121 : LUT4
    generic map(
      INIT => X"F62E"
    )
    port map (
      I0 => huffman_ins_v2_run_length_white(8),
      I1 => huffman_ins_v2_run_length_white(9),
      I2 => huffman_ins_v2_run_length_white(6),
      I3 => huffman_ins_v2_run_length_white(7),
      O => huffman_ins_v2_code_table_ins_Mrom_makeup_white_mux00012
    );
  huffman_ins_v2_code_table_ins_Mrom_makeup_white_mux0001111 : LUT4
    generic map(
      INIT => X"578E"
    )
    port map (
      I0 => huffman_ins_v2_run_length_white(6),
      I1 => huffman_ins_v2_run_length_white(8),
      I2 => huffman_ins_v2_run_length_white(9),
      I3 => huffman_ins_v2_run_length_white(7),
      O => huffman_ins_v2_code_table_ins_Mrom_makeup_white_mux00011
    );
  huffman_ins_v2_code_table_ins_Mrom_makeup_white_mux000141 : LUT4
    generic map(
      INIT => X"C78E"
    )
    port map (
      I0 => huffman_ins_v2_run_length_white(7),
      I1 => huffman_ins_v2_run_length_white(8),
      I2 => huffman_ins_v2_run_length_white(9),
      I3 => huffman_ins_v2_run_length_white(6),
      O => huffman_ins_v2_code_table_ins_Mrom_makeup_white_mux00014
    );
  huffman_ins_v2_code_table_ins_Mrom_makeup_white_mux000191 : LUT4
    generic map(
      INIT => X"F816"
    )
    port map (
      I0 => huffman_ins_v2_run_length_white(6),
      I1 => huffman_ins_v2_run_length_white(7),
      I2 => huffman_ins_v2_run_length_white(8),
      I3 => huffman_ins_v2_run_length_white(9),
      O => huffman_ins_v2_code_table_ins_Mrom_makeup_white_mux00019
    );
  fax4_ins_fifo_out1_to_white1 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt(0),
      I1 => fax4_ins_FIFO2_multi_read_ins_to_white1_o_683,
      I2 => fax4_ins_FIFO1_multi_read_ins_to_white1_o_441,
      O => fax4_ins_fifo_out1_to_white
    );
  fax4_ins_mux_a0_or00001 : LUT4
    generic map(
      INIT => X"FFD5"
    )
    port map (
      I0 => fax4_ins_state_FSM_N7,
      I1 => fax4_ins_state_updated_1345,
      I2 => fax4_ins_state_FSM_FFd10_1323,
      I3 => fax4_ins_state_FSM_FFd11_1325,
      O => fax4_ins_mux_a0_0_Q
    );
  fax4_ins_b2_mux0004_1_21 : LUT4
    generic map(
      INIT => X"0103"
    )
    port map (
      I0 => fax4_ins_fifo_out2_valid,
      I1 => fax4_ins_b2_to_white_and0000,
      I2 => fax4_ins_b2_to_white_and0001,
      I3 => N498,
      O => fax4_ins_N19
    );
  fax4_ins_fifo_out1_x_9_1 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt(0),
      I1 => fax4_ins_FIFO2_multi_read_ins_data1_o(9),
      I2 => fax4_ins_FIFO1_multi_read_ins_data1_o(9),
      O => fax4_ins_fifo_out1_x(9)
    );
  fax4_ins_fifo_out1_x_8_1 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt(0),
      I1 => fax4_ins_FIFO2_multi_read_ins_data1_o(8),
      I2 => fax4_ins_FIFO1_multi_read_ins_data1_o(8),
      O => fax4_ins_fifo_out1_x(8)
    );
  fax4_ins_fifo_out1_x_7_1 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt(0),
      I1 => fax4_ins_FIFO2_multi_read_ins_data1_o(7),
      I2 => fax4_ins_FIFO1_multi_read_ins_data1_o(7),
      O => fax4_ins_fifo_out1_x(7)
    );
  fax4_ins_fifo_out1_x_6_1 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt(0),
      I1 => fax4_ins_FIFO2_multi_read_ins_data1_o(6),
      I2 => fax4_ins_FIFO1_multi_read_ins_data1_o(6),
      O => fax4_ins_fifo_out1_x(6)
    );
  fax4_ins_b2_to_white_and00001 : LUT2
    generic map(
      INIT => X"8"
    )
    port map (
      I0 => fax4_ins_fifo_out_prev1_valid_1240,
      I1 => N492,
      O => fax4_ins_b2_to_white_and0000
    );
  fax4_ins_b2_to_white_and00011 : LUT4
    generic map(
      INIT => X"D800"
    )
    port map (
      I0 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt(0),
      I1 => fax4_ins_FIFO1_multi_read_ins_valid1_o_456,
      I2 => fax4_ins_FIFO2_multi_read_ins_valid1_o_698,
      I3 => fax4_ins_mux_b1(1),
      O => fax4_ins_b2_to_white_and0001
    );
  fax4_ins_mux_b1_1_and0000_SW0 : LUT2
    generic map(
      INIT => X"8"
    )
    port map (
      I0 => fax4_ins_fifo_out_prev1_valid_1240,
      I1 => fax4_ins_pass_mode,
      O => N73
    );
  fax4_ins_mux_b1_0_and0000_SW0 : LUT2
    generic map(
      INIT => X"8"
    )
    port map (
      I0 => fax4_ins_fifo_out_prev2_valid_1253,
      I1 => fax4_ins_pass_mode,
      O => N75
    );
  fax4_ins_fifo_out1_x_5_1 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt(0),
      I1 => fax4_ins_FIFO2_multi_read_ins_data1_o(5),
      I2 => fax4_ins_FIFO1_multi_read_ins_data1_o(5),
      O => fax4_ins_fifo_out1_x(5)
    );
  fax4_ins_fifo_out1_x_4_1 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt(0),
      I1 => fax4_ins_FIFO2_multi_read_ins_data1_o(4),
      I2 => fax4_ins_FIFO1_multi_read_ins_data1_o(4),
      O => fax4_ins_fifo_out1_x(4)
    );
  fax4_ins_fifo_out1_x_3_1 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt(0),
      I1 => fax4_ins_FIFO2_multi_read_ins_data1_o(3),
      I2 => fax4_ins_FIFO1_multi_read_ins_data1_o(3),
      O => fax4_ins_fifo_out1_x(3)
    );
  fax4_ins_mode_indicator_o_mux0001_2_232 : LUT4
    generic map(
      INIT => X"0001"
    )
    port map (
      I0 => fax4_ins_a1b1(4),
      I1 => fax4_ins_a1b1(5),
      I2 => fax4_ins_a1b1(6),
      I3 => N483,
      O => fax4_ins_mode_indicator_o_mux0001_2_232_1296
    );
  fax4_ins_fifo_out1_x_2_1 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt(0),
      I1 => fax4_ins_FIFO2_multi_read_ins_data1_o(2),
      I2 => fax4_ins_FIFO1_multi_read_ins_data1_o(2),
      O => fax4_ins_fifo_out1_x(2)
    );
  fax4_ins_fifo_out2_x_9_1 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt(0),
      I1 => fax4_ins_FIFO2_multi_read_ins_data2_o(9),
      I2 => fax4_ins_FIFO1_multi_read_ins_data2_o(9),
      O => fax4_ins_fifo_out2_x(9)
    );
  fax4_ins_fifo_out1_x_1_1 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt(0),
      I1 => fax4_ins_FIFO2_multi_read_ins_data1_o(1),
      I2 => fax4_ins_FIFO1_multi_read_ins_data1_o(1),
      O => fax4_ins_fifo_out1_x(1)
    );
  fax4_ins_fifo_out2_x_8_1 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt(0),
      I1 => fax4_ins_FIFO2_multi_read_ins_data2_o(8),
      I2 => fax4_ins_FIFO1_multi_read_ins_data2_o(8),
      O => fax4_ins_fifo_out2_x(8)
    );
  fax4_ins_fifo_out1_x_0_1 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt(0),
      I1 => fax4_ins_FIFO2_multi_read_ins_data1_o(0),
      I2 => fax4_ins_FIFO1_multi_read_ins_data1_o(0),
      O => fax4_ins_fifo_out1_x(0)
    );
  fax4_ins_b1_mux0004_9_18 : LUT4
    generic map(
      INIT => X"0E04"
    )
    port map (
      I0 => fax4_ins_mux_b1(2),
      I1 => fax4_ins_fifo_out2_x(9),
      I2 => fax4_ins_mux_b1(1),
      I3 => fax4_ins_fifo_out1_x(9),
      O => fax4_ins_b1_mux0004_9_18_1053
    );
  fax4_ins_b2_mux0004_0_10 : LUT4
    generic map(
      INIT => X"EC20"
    )
    port map (
      I0 => fax4_ins_fifo_out1_x(0),
      I1 => fax4_ins_b2_to_white_and0000,
      I2 => fax4_ins_b2_to_white_and0001,
      I3 => fax4_ins_fifo_out_prev1_x(0),
      O => fax4_ins_b2_mux0004_0_10_1065
    );
  fax4_ins_b2_to_white_mux000410 : LUT4
    generic map(
      INIT => X"EC20"
    )
    port map (
      I0 => fax4_ins_fifo_out1_to_white,
      I1 => fax4_ins_b2_to_white_and0000,
      I2 => fax4_ins_b2_to_white_and0001,
      I3 => fax4_ins_fifo_out_prev1_to_white_1239,
      O => fax4_ins_b2_to_white_mux000410_1098
    );
  fax4_ins_fifo_out2_x_7_1 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt(0),
      I1 => fax4_ins_FIFO2_multi_read_ins_data2_o(7),
      I2 => fax4_ins_FIFO1_multi_read_ins_data2_o(7),
      O => fax4_ins_fifo_out2_x(7)
    );
  fax4_ins_fifo_out2_x_6_1 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt(0),
      I1 => fax4_ins_FIFO2_multi_read_ins_data2_o(6),
      I2 => fax4_ins_FIFO1_multi_read_ins_data2_o(6),
      O => fax4_ins_fifo_out2_x(6)
    );
  fax4_ins_FIFO2_multi_read_ins_latch3_or00001 : LUT2
    generic map(
      INIT => X"E"
    )
    port map (
      I0 => fax4_ins_FIFO2_multi_read_ins_mux3,
      I1 => fax4_ins_fifo2_rd,
      O => fax4_ins_FIFO2_multi_read_ins_latch3
    );
  fax4_ins_FIFO1_multi_read_ins_latch3_or00001 : LUT2
    generic map(
      INIT => X"E"
    )
    port map (
      I0 => N495,
      I1 => fax4_ins_fifo1_rd,
      O => fax4_ins_FIFO1_multi_read_ins_latch3
    );
  fax4_ins_fifo_out2_x_5_1 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt(0),
      I1 => fax4_ins_FIFO2_multi_read_ins_data2_o(5),
      I2 => fax4_ins_FIFO1_multi_read_ins_data2_o(5),
      O => fax4_ins_fifo_out2_x(5)
    );
  fax4_ins_fifo_out2_x_4_1 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt(0),
      I1 => fax4_ins_FIFO2_multi_read_ins_data2_o(4),
      I2 => fax4_ins_FIFO1_multi_read_ins_data2_o(4),
      O => fax4_ins_fifo_out2_x(4)
    );
  fax4_ins_fifo_out2_x_3_1 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt(0),
      I1 => fax4_ins_FIFO2_multi_read_ins_data2_o(3),
      I2 => fax4_ins_FIFO1_multi_read_ins_data2_o(3),
      O => fax4_ins_fifo_out2_x(3)
    );
  fax4_ins_fifo_out2_x_2_1 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt(0),
      I1 => fax4_ins_FIFO2_multi_read_ins_data2_o(2),
      I2 => fax4_ins_FIFO1_multi_read_ins_data2_o(2),
      O => fax4_ins_fifo_out2_x(2)
    );
  fax4_ins_fifo_out2_x_1_1 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt(0),
      I1 => fax4_ins_FIFO2_multi_read_ins_data2_o(1),
      I2 => fax4_ins_FIFO1_multi_read_ins_data2_o(1),
      O => fax4_ins_fifo_out2_x(1)
    );
  fax4_ins_fifo_out2_x_0_1 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt(0),
      I1 => fax4_ins_FIFO2_multi_read_ins_data2_o(0),
      I2 => fax4_ins_FIFO1_multi_read_ins_data2_o(0),
      O => fax4_ins_fifo_out2_x(0)
    );
  fax4_ins_mux_b1_3_and0000_SW0 : LUT4
    generic map(
      INIT => X"A695"
    )
    port map (
      I0 => fax4_ins_a0_to_white_946,
      I1 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt(0),
      I2 => fax4_ins_FIFO1_multi_read_ins_to_white2_o_442,
      I3 => fax4_ins_FIFO2_multi_read_ins_to_white2_o_684,
      O => N77
    );
  fax4_ins_b1_mux0004_8_12 : LUT4
    generic map(
      INIT => X"CCA0"
    )
    port map (
      I0 => fax4_ins_fifo_out2_x(8),
      I1 => fax4_ins_fifo_out1_x(8),
      I2 => N493,
      I3 => fax4_ins_mux_b1(2),
      O => fax4_ins_b1_mux0004_8_12_1049
    );
  fax4_ins_b1_mux0004_3_12 : LUT4
    generic map(
      INIT => X"CCA0"
    )
    port map (
      I0 => fax4_ins_fifo_out2_x(3),
      I1 => fax4_ins_fifo_out1_x(3),
      I2 => fax4_ins_mux_b1(3),
      I3 => fax4_ins_mux_b1(2),
      O => fax4_ins_b1_mux0004_3_12_1037
    );
  fax4_ins_b1_mux0004_2_12 : LUT4
    generic map(
      INIT => X"CCA0"
    )
    port map (
      I0 => fax4_ins_fifo_out2_x(2),
      I1 => fax4_ins_fifo_out1_x(2),
      I2 => fax4_ins_mux_b1(3),
      I3 => fax4_ins_mux_b1(2),
      O => fax4_ins_b1_mux0004_2_12_1033
    );
  fax4_ins_b1_mux0004_1_12 : LUT4
    generic map(
      INIT => X"CCA0"
    )
    port map (
      I0 => fax4_ins_fifo_out2_x(1),
      I1 => fax4_ins_fifo_out1_x(1),
      I2 => fax4_ins_mux_b1(3),
      I3 => fax4_ins_mux_b1(2),
      O => fax4_ins_b1_mux0004_1_12_1029
    );
  fax4_ins_FIFO2_multi_read_ins_mem_rd_SW0 : LUT4
    generic map(
      INIT => X"FEFF"
    )
    port map (
      I0 => fax4_ins_FIFO2_multi_read_ins_read_as_last_operation_668,
      I1 => fax4_ins_FIFO2_multi_read_ins_used(1),
      I2 => fax4_ins_FIFO2_multi_read_ins_used(0),
      I3 => fax4_ins_FIFO2_multi_read_ins_used(2),
      O => N79
    );
  fax4_ins_FIFO2_multi_read_ins_mem_rd_SW1 : LUT4
    generic map(
      INIT => X"AAA2"
    )
    port map (
      I0 => fax4_ins_FIFO2_multi_read_ins_used(2),
      I1 => fax4_ins_FIFO2_multi_read_ins_read_as_last_operation_668,
      I2 => fax4_ins_FIFO2_multi_read_ins_used(0),
      I3 => fax4_ins_FIFO2_multi_read_ins_used(1),
      O => N80
    );
  fax4_ins_FIFO2_multi_read_ins_mem_rd : LUT4
    generic map(
      INIT => X"FC05"
    )
    port map (
      I0 => N79,
      I1 => N80,
      I2 => fax4_ins_FIFO2_multi_read_ins_N4,
      I3 => N485,
      O => fax4_ins_FIFO2_multi_read_ins_mem_rd_628
    );
  fax4_ins_FIFO1_multi_read_ins_mem_rd_SW0 : LUT4
    generic map(
      INIT => X"FEFF"
    )
    port map (
      I0 => fax4_ins_FIFO1_multi_read_ins_read_as_last_operation_426,
      I1 => fax4_ins_FIFO1_multi_read_ins_used(1),
      I2 => fax4_ins_FIFO1_multi_read_ins_used(0),
      I3 => fax4_ins_FIFO1_multi_read_ins_used(2),
      O => N82
    );
  fax4_ins_FIFO1_multi_read_ins_mem_rd_SW1 : LUT4
    generic map(
      INIT => X"AAA2"
    )
    port map (
      I0 => fax4_ins_FIFO1_multi_read_ins_used(2),
      I1 => fax4_ins_FIFO1_multi_read_ins_read_as_last_operation_426,
      I2 => fax4_ins_FIFO1_multi_read_ins_used(0),
      I3 => fax4_ins_FIFO1_multi_read_ins_used(1),
      O => N83
    );
  fax4_ins_FIFO1_multi_read_ins_mem_rd : LUT4
    generic map(
      INIT => X"FC05"
    )
    port map (
      I0 => N82,
      I1 => N83,
      I2 => fax4_ins_FIFO1_multi_read_ins_N4,
      I3 => N486,
      O => fax4_ins_FIFO1_multi_read_ins_mem_rd_387
    );
  fax4_ins_FIFO2_multi_read_ins_used_not0002_SW0 : LUT4
    generic map(
      INIT => X"FFFE"
    )
    port map (
      I0 => fax4_ins_FIFO2_multi_read_ins_used(1),
      I1 => fax4_ins_FIFO2_multi_read_ins_used(0),
      I2 => fax4_ins_FIFO2_multi_read_ins_read_as_last_operation_668,
      I3 => fax4_ins_FIFO2_multi_read_ins_N4,
      O => N85
    );
  fax4_ins_FIFO2_multi_read_ins_used_not0002 : LUT4
    generic map(
      INIT => X"FAF2"
    )
    port map (
      I0 => fax4_ins_FIFO2_multi_read_ins_N8,
      I1 => fax4_ins_FIFO2_multi_read_ins_used(2),
      I2 => fax4_ins_fifo2_wr,
      I3 => N85,
      O => fax4_ins_FIFO2_multi_read_ins_used_not0002_696
    );
  fax4_ins_FIFO1_multi_read_ins_used_not0002_SW0 : LUT4
    generic map(
      INIT => X"FFFE"
    )
    port map (
      I0 => fax4_ins_FIFO1_multi_read_ins_used(1),
      I1 => fax4_ins_FIFO1_multi_read_ins_used(0),
      I2 => fax4_ins_FIFO1_multi_read_ins_read_as_last_operation_426,
      I3 => fax4_ins_FIFO1_multi_read_ins_N4,
      O => N87
    );
  fax4_ins_FIFO1_multi_read_ins_used_not0002 : LUT4
    generic map(
      INIT => X"FAF2"
    )
    port map (
      I0 => fax4_ins_FIFO1_multi_read_ins_N8,
      I1 => fax4_ins_FIFO1_multi_read_ins_used(2),
      I2 => fax4_ins_fifo1_wr,
      I3 => N87,
      O => fax4_ins_FIFO1_multi_read_ins_used_not0002_454
    );
  fax4_ins_load_mux_a0_SW0 : LUT4
    generic map(
      INIT => X"FFD5"
    )
    port map (
      I0 => fax4_ins_state_FSM_N7,
      I1 => fax4_ins_state_updated_1345,
      I2 => fax4_ins_state_FSM_FFd10_1323,
      I3 => fax4_ins_pass_mode,
      O => N89
    );
  fax4_ins_load_mux_a0 : LUT4
    generic map(
      INIT => X"FAF8"
    )
    port map (
      I0 => fax4_ins_pix_changed_1319,
      I1 => fax4_ins_state_FSM_FFd8_1338,
      I2 => N89,
      I3 => N471,
      O => fax4_ins_load_mux_a0_1284
    );
  fax4_ins_fifo_rd22 : LUT4
    generic map(
      INIT => X"0E04"
    )
    port map (
      I0 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt(0),
      I1 => fax4_ins_FIFO2_multi_read_ins_valid1_o_698,
      I2 => fax4_ins_EOL,
      I3 => fax4_ins_FIFO1_multi_read_ins_valid1_o_456,
      O => fax4_ins_fifo_rd22_1267
    );
  fax4_ins_mode_indicator_o_mux0001_2_36 : LUT2
    generic map(
      INIT => X"8"
    )
    port map (
      I0 => N480,
      I1 => fax4_ins_a1b1(3),
      O => fax4_ins_mode_indicator_o_mux0001_2_36_1300
    );
  fax4_ins_counter_xy_v2_ins_EOL_o1 : LUT2
    generic map(
      INIT => X"7"
    )
    port map (
      I0 => fax4_ins_counter_xy_v2_ins_frame_valid_1206,
      I1 => fax4_ins_counter_xy_v2_ins_line_valid_1210,
      O => fax4_ins_EOL
    );
  fax4_ins_mode_indicator_o_mux0001_3_9 : LUT4
    generic map(
      INIT => X"2000"
    )
    port map (
      I0 => N497,
      I1 => fax4_ins_a1b1(0),
      I2 => fax4_ins_load_a1_or0001,
      I3 => fax4_ins_N15,
      O => fax4_ins_mode_indicator_o_mux0001_3_9_1302
    );
  fax4_ins_a0_mux0000_9_Q : LUT4
    generic map(
      INIT => X"FDF0"
    )
    port map (
      I0 => rsync_i,
      I1 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(0),
      I2 => N93,
      I3 => fax4_ins_mux_a0_1_Q,
      O => fax4_ins_a0_mux0000(9)
    );
  fax4_ins_a0_mux0000_5_Q : LUT4
    generic map(
      INIT => X"FDF0"
    )
    port map (
      I0 => rsync_i,
      I1 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(4),
      I2 => N95,
      I3 => fax4_ins_mux_a0_1_Q,
      O => fax4_ins_a0_mux0000(5)
    );
  fax4_ins_a0_mux0000_4_Q : LUT4
    generic map(
      INIT => X"FDF0"
    )
    port map (
      I0 => rsync_i,
      I1 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(5),
      I2 => N97,
      I3 => fax4_ins_mux_a0_1_Q,
      O => fax4_ins_a0_mux0000(4)
    );
  fax4_ins_a0_mux0000_3_Q : LUT4
    generic map(
      INIT => X"FDF0"
    )
    port map (
      I0 => rsync_i,
      I1 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(6),
      I2 => N99,
      I3 => fax4_ins_mux_a0_1_Q,
      O => fax4_ins_a0_mux0000(3)
    );
  fax4_ins_a0_mux0000_2_Q : LUT4
    generic map(
      INIT => X"FDF0"
    )
    port map (
      I0 => rsync_i,
      I1 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(7),
      I2 => N101,
      I3 => fax4_ins_mux_a0_1_Q,
      O => fax4_ins_a0_mux0000(2)
    );
  fax4_ins_a0_mux0000_0_Q : LUT4
    generic map(
      INIT => X"FDF0"
    )
    port map (
      I0 => rsync_i,
      I1 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(9),
      I2 => N103,
      I3 => fax4_ins_mux_a0_1_Q,
      O => fax4_ins_a0_mux0000(0)
    );
  fax4_ins_a0_to_white_mux00007 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => rsync_i,
      I1 => fax4_ins_pix_prev_1321,
      I2 => fax4_ins_to_white_1349,
      O => fax4_ins_a0_to_white_mux00007_949
    );
  fax4_ins_a0_mux0000_8_1 : LUT4
    generic map(
      INIT => X"ECA0"
    )
    port map (
      I0 => fax4_ins_b2(1),
      I1 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(1),
      I2 => N489,
      I3 => fax4_ins_N01,
      O => fax4_ins_a0_mux0000(8)
    );
  fax4_ins_a0_mux0000_7_1 : LUT4
    generic map(
      INIT => X"ECA0"
    )
    port map (
      I0 => fax4_ins_b2(2),
      I1 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(2),
      I2 => fax4_ins_mux_a0_3_Q,
      I3 => N490,
      O => fax4_ins_a0_mux0000(7)
    );
  fax4_ins_a0_mux0000_6_1 : LUT4
    generic map(
      INIT => X"ECA0"
    )
    port map (
      I0 => fax4_ins_b2(3),
      I1 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(3),
      I2 => fax4_ins_mux_a0_3_Q,
      I3 => fax4_ins_N01,
      O => fax4_ins_a0_mux0000(6)
    );
  fax4_ins_a0_mux0000_1_1 : LUT4
    generic map(
      INIT => X"ECA0"
    )
    port map (
      I0 => fax4_ins_b2(8),
      I1 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(8),
      I2 => fax4_ins_mux_a0_3_Q,
      I3 => fax4_ins_N01,
      O => fax4_ins_a0_mux0000(1)
    );
  fax4_ins_vertical_mode_cmp_le000020 : LUT2
    generic map(
      INIT => X"8"
    )
    port map (
      I0 => fax4_ins_a1b1(10),
      I1 => fax4_ins_vertical_mode_addsub0000(10),
      O => fax4_ins_vertical_mode_cmp_le000020_1361
    );
  fax4_ins_vertical_mode_cmp_le0000213 : LUT3
    generic map(
      INIT => X"57"
    )
    port map (
      I0 => fax4_ins_a1b1(10),
      I1 => fax4_ins_vertical_mode_addsub0000(8),
      I2 => fax4_ins_vertical_mode_addsub0000(9),
      O => fax4_ins_vertical_mode_cmp_le0000213_1363
    );
  fax4_ins_vertical_mode_cmp_le0000226 : LUT3
    generic map(
      INIT => X"57"
    )
    port map (
      I0 => fax4_ins_a1b1(10),
      I1 => fax4_ins_vertical_mode_addsub0000(6),
      I2 => fax4_ins_vertical_mode_addsub0000(7),
      O => fax4_ins_vertical_mode_cmp_le0000226_1365
    );
  huffman_ins_v2_code_table_ins_makeup_white_6 : FDS
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      D => huffman_ins_v2_code_table_ins_Mrom_makeup_white_mux000161,
      S => huffman_ins_v2_run_length_white(9),
      Q => huffman_ins_v2_code_table_ins_makeup_white(6)
    );
  huffman_ins_v2_code_table_ins_Mrom_makeup_white_mux0001611 : LUT3
    generic map(
      INIT => X"80"
    )
    port map (
      I0 => huffman_ins_v2_run_length_white(8),
      I1 => huffman_ins_v2_run_length_white(6),
      I2 => huffman_ins_v2_run_length_white(7),
      O => huffman_ins_v2_code_table_ins_Mrom_makeup_white_mux000161
    );
  huffman_ins_v2_code_table_ins_makeup_white_8 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      D => huffman_ins_v2_code_table_ins_Mrom_makeup_white_mux000181,
      R => huffman_ins_v2_run_length_white(8),
      Q => huffman_ins_v2_code_table_ins_makeup_white(8)
    );
  huffman_ins_v2_code_table_ins_Mrom_makeup_white_mux0001811 : LUT3
    generic map(
      INIT => X"01"
    )
    port map (
      I0 => huffman_ins_v2_run_length_white(9),
      I1 => huffman_ins_v2_run_length_white(6),
      I2 => huffman_ins_v2_run_length_white(7),
      O => huffman_ins_v2_code_table_ins_Mrom_makeup_white_mux000181
    );
  huffman_ins_v2_code_table_ins_makeup_white_10 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      D => huffman_ins_v2_code_table_ins_Mrom_makeup_white_mux0001101,
      R => huffman_ins_v2_run_length_white(9),
      Q => huffman_ins_v2_code_table_ins_makeup_white(10)
    );
  huffman_ins_v2_code_table_ins_Mrom_makeup_white_mux00011011 : LUT3
    generic map(
      INIT => X"18"
    )
    port map (
      I0 => huffman_ins_v2_run_length_white(6),
      I1 => huffman_ins_v2_run_length_white(7),
      I2 => huffman_ins_v2_run_length_white(8),
      O => huffman_ins_v2_code_table_ins_Mrom_makeup_white_mux0001101
    );
  huffman_ins_v2_code_table_ins_makeup_white_11 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      D => huffman_ins_v2_code_table_ins_Mrom_makeup_white_mux00011111,
      R => huffman_ins_v2_run_length_white(9),
      Q => huffman_ins_v2_code_table_ins_makeup_white(11)
    );
  huffman_ins_v2_code_table_ins_Mrom_makeup_white_mux000111111 : LUT3
    generic map(
      INIT => X"36"
    )
    port map (
      I0 => huffman_ins_v2_run_length_white(7),
      I1 => huffman_ins_v2_run_length_white(8),
      I2 => huffman_ins_v2_run_length_white(6),
      O => huffman_ins_v2_code_table_ins_Mrom_makeup_white_mux00011111
    );
  huffman_ins_v2_code_table_ins_makeup_white_12 : FDS
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      D => huffman_ins_v2_code_table_ins_Mrom_makeup_white_mux0001121,
      S => huffman_ins_v2_run_length_white(9),
      Q => huffman_ins_v2_code_table_ins_makeup_white(12)
    );
  huffman_ins_v2_code_table_ins_Mrom_makeup_white_mux00011211 : LUT3
    generic map(
      INIT => X"C8"
    )
    port map (
      I0 => huffman_ins_v2_run_length_white(6),
      I1 => huffman_ins_v2_run_length_white(8),
      I2 => huffman_ins_v2_run_length_white(7),
      O => huffman_ins_v2_code_table_ins_Mrom_makeup_white_mux0001121
    );
  huffman_ins_v2_code_table_ins_makeup_black_0 : FDS
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      D => huffman_ins_v2_code_table_ins_Mrom_makeup_black_mux000112,
      S => huffman_ins_v2_run_length_black(6),
      Q => huffman_ins_v2_code_table_ins_makeup_black_0_Q
    );
  huffman_ins_v2_code_table_ins_Mrom_makeup_black_mux0001121 : LUT3
    generic map(
      INIT => X"10"
    )
    port map (
      I0 => huffman_ins_v2_run_length_black(9),
      I1 => huffman_ins_v2_run_length_black(7),
      I2 => huffman_ins_v2_run_length_black(8),
      O => huffman_ins_v2_code_table_ins_Mrom_makeup_black_mux000112
    );
  huffman_ins_v2_code_table_ins_makeup_black_6 : FDS
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      D => huffman_ins_v2_code_table_ins_Mrom_makeup_black_mux000161,
      S => huffman_ins_v2_run_length_black(9),
      Q => huffman_ins_v2_code_table_ins_makeup_black_6_Q
    );
  huffman_ins_v2_code_table_ins_Mrom_makeup_black_mux0001611 : LUT3
    generic map(
      INIT => X"26"
    )
    port map (
      I0 => huffman_ins_v2_run_length_black(7),
      I1 => huffman_ins_v2_run_length_black(8),
      I2 => huffman_ins_v2_run_length_black(6),
      O => huffman_ins_v2_code_table_ins_Mrom_makeup_black_mux000161
    );
  huffman_ins_v2_code_table_ins_makeup_black_7 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      D => huffman_ins_v2_code_table_ins_Mrom_makeup_black_mux000171,
      R => huffman_ins_v2_run_length_black(8),
      Q => huffman_ins_v2_code_table_ins_makeup_black_7_Q
    );
  huffman_ins_v2_code_table_ins_makeup_black_8 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      D => huffman_ins_v2_code_table_ins_Mrom_makeup_black_mux0001101,
      R => huffman_ins_v2_run_length_black(6),
      Q => huffman_ins_v2_code_table_ins_makeup_black_8_Q
    );
  huffman_ins_v2_code_table_ins_makeup_black_14 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      D => huffman_ins_v2_run_length_black(6),
      R => huffman_ins_v2_code_table_ins_Mrom_makeup_black_mux000115,
      Q => huffman_ins_v2_code_table_ins_makeup_black_14_Q
    );
  huffman_ins_v2_code_table_ins_makeup_black_16 : FDS
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      D => huffman_ins_v2_run_length_black(6),
      S => huffman_ins_v2_code_table_ins_Mrom_makeup_black_mux000115,
      Q => huffman_ins_v2_code_table_ins_makeup_black_16_Q
    );
  huffman_ins_v2_pass_vert_code_width_1_0 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      D => huffman_ins_v2_Mrom_run_length_i_rom000012,
      R => fax4_ins_mode_indicator_o(3),
      Q => huffman_ins_v2_pass_vert_code_width_1_0_Q
    );
  huffman_ins_v2_Mrom_run_length_i_rom0000121 : LUT3
    generic map(
      INIT => X"67"
    )
    port map (
      I0 => fax4_ins_mode_indicator_o(0),
      I1 => fax4_ins_mode_indicator_o(2),
      I2 => fax4_ins_mode_indicator_o(1),
      O => huffman_ins_v2_Mrom_run_length_i_rom000012
    );
  huffman_ins_v2_pass_vert_code_1_1 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      D => huffman_ins_v2_Mrom_run_length_i_rom0000111,
      R => fax4_ins_mode_indicator_o(3),
      Q => huffman_ins_v2_pass_vert_code_1(1)
    );
  huffman_ins_v2_Mrom_run_length_i_rom00001111 : LUT3
    generic map(
      INIT => X"7E"
    )
    port map (
      I0 => fax4_ins_mode_indicator_o(0),
      I1 => fax4_ins_mode_indicator_o(1),
      I2 => fax4_ins_mode_indicator_o(2),
      O => huffman_ins_v2_Mrom_run_length_i_rom0000111
    );
  huffman_ins_v2_code_white_7 : FDS
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      D => huffman_ins_v2_code_white_7_mux000021_1781,
      S => huffman_ins_v2_code_white_7_mux000010_1780,
      Q => huffman_ins_v2_code_white(7)
    );
  huffman_ins_v2_code_white_6 : FDS
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      D => huffman_ins_v2_code_white_6_mux000021_1777,
      S => huffman_ins_v2_code_white_6_mux000014_1776,
      Q => huffman_ins_v2_code_white(6)
    );
  huffman_ins_v2_code_white_4 : FDS
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      D => huffman_ins_v2_code_white_4_mux000039_1769,
      S => huffman_ins_v2_code_white_4_mux000028,
      Q => huffman_ins_v2_code_white(4)
    );
  huffman_ins_v2_code_white_5 : FDS
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      D => huffman_ins_v2_code_white_5_mux000039_1774,
      S => huffman_ins_v2_code_white_5_mux000028,
      Q => huffman_ins_v2_code_white(5)
    );
  huffman_ins_v2_hor_code_9 : FDS
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      D => huffman_ins_v2_hor_code_9_mux0003147,
      S => huffman_ins_v2_hor_code_9_mux000342_2045,
      Q => huffman_ins_v2_hor_code(9)
    );
  huffman_ins_v2_hor_code_8 : FDS
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      D => huffman_ins_v2_hor_code_8_mux0003165,
      S => huffman_ins_v2_hor_code_8_mux000392_2038,
      Q => huffman_ins_v2_hor_code(8)
    );
  huffman_ins_v2_hor_code_8_mux00031651 : LUT3
    generic map(
      INIT => X"EA"
    )
    port map (
      I0 => huffman_ins_v2_hor_code_8_mux0003151_2033,
      I1 => huffman_ins_v2_hor_code(8),
      I2 => huffman_ins_v2_hor_code_8_mux000341_2036,
      O => huffman_ins_v2_hor_code_8_mux0003165
    );
  huffman_ins_v2_code_black_23 : FDS
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      D => huffman_ins_v2_code_black_23_mux0000172,
      S => huffman_ins_v2_code_black_23_mux0000169_1615,
      Q => huffman_ins_v2_code_black(23)
    );
  huffman_ins_v2_code_black_23_mux00001721 : LUT3
    generic map(
      INIT => X"C8"
    )
    port map (
      I0 => huffman_ins_v2_code_black_23_mux0000112_1613,
      I1 => huffman_ins_v2_codetab_ter_black_width(3),
      I2 => huffman_ins_v2_code_black_23_mux0000128_1614,
      O => huffman_ins_v2_code_black_23_mux0000172
    );
  huffman_ins_v2_hor_code_7 : FDS
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      D => huffman_ins_v2_hor_code_7_mux000381,
      S => huffman_ins_v2_hor_code_7_mux000325_2023,
      Q => huffman_ins_v2_hor_code(7)
    );
  huffman_ins_v2_hor_code_7_mux0003811 : LUT3
    generic map(
      INIT => X"EA"
    )
    port map (
      I0 => huffman_ins_v2_hor_code_7_mux000370_2027,
      I1 => huffman_ins_v2_hor_code(7),
      I2 => huffman_ins_v2_hor_code_7_mux00035_2024,
      O => huffman_ins_v2_hor_code_7_mux000381
    );
  huffman_ins_v2_code_black_22 : FDS
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      D => huffman_ins_v2_code_black_22_mux0000172,
      S => huffman_ins_v2_code_black_22_mux0000169_1610,
      Q => huffman_ins_v2_code_black(22)
    );
  huffman_ins_v2_code_black_22_mux00001721 : LUT3
    generic map(
      INIT => X"C8"
    )
    port map (
      I0 => huffman_ins_v2_code_black_22_mux0000112_1607,
      I1 => huffman_ins_v2_codetab_ter_black_width(3),
      I2 => huffman_ins_v2_code_black_22_mux0000128_1609,
      O => huffman_ins_v2_code_black_22_mux0000172
    );
  huffman_ins_v2_hor_code_6 : FDS
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      D => huffman_ins_v2_hor_code_6_mux000371,
      S => huffman_ins_v2_hor_code_6_mux000329_2016,
      Q => huffman_ins_v2_hor_code(6)
    );
  huffman_ins_v2_hor_code_6_mux0003711 : LUT3
    generic map(
      INIT => X"EA"
    )
    port map (
      I0 => huffman_ins_v2_hor_code_6_mux000367_2019,
      I1 => huffman_ins_v2_code_white(6),
      I2 => huffman_ins_v2_hor_code_6_mux000343_2017,
      O => huffman_ins_v2_hor_code_6_mux000371
    );
  huffman_ins_v2_hor_code_5 : FDS
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      D => huffman_ins_v2_hor_code_5_mux0003102,
      S => huffman_ins_v2_hor_code_5_mux000327_2008,
      Q => huffman_ins_v2_hor_code(5)
    );
  huffman_ins_v2_hor_code_5_mux00031021 : LUT3
    generic map(
      INIT => X"EA"
    )
    port map (
      I0 => huffman_ins_v2_hor_code_5_mux000380_2012,
      I1 => huffman_ins_v2_N39,
      I2 => huffman_ins_v2_hor_code_5_mux000349_2009,
      O => huffman_ins_v2_hor_code_5_mux0003102
    );
  huffman_ins_v2_code_black_20 : FDS
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      D => huffman_ins_v2_code_black_20_mux0000187_1599,
      S => huffman_ins_v2_code_black_20_mux0000166_1598,
      Q => huffman_ins_v2_code_black(20)
    );
  huffman_ins_v2_hor_code_4 : FDS
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      D => huffman_ins_v2_hor_code_4_mux0003110,
      S => huffman_ins_v2_hor_code_4_mux000333_2001,
      Q => huffman_ins_v2_hor_code(4)
    );
  huffman_ins_v2_hor_code_4_mux00031101 : LUT3
    generic map(
      INIT => X"EA"
    )
    port map (
      I0 => huffman_ins_v2_hor_code_4_mux000388_2004,
      I1 => huffman_ins_v2_N40,
      I2 => huffman_ins_v2_hor_code_4_mux000358_2002,
      O => huffman_ins_v2_hor_code_4_mux0003110
    );
  huffman_ins_v2_hor_code_3 : FDS
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      D => huffman_ins_v2_hor_code_3_mux000397_1995,
      S => huffman_ins_v2_hor_code_3_mux000342_1994,
      Q => huffman_ins_v2_hor_code(3)
    );
  huffman_ins_v2_hor_code_2 : FDS
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      D => huffman_ins_v2_hor_code_2_mux0003129,
      S => huffman_ins_v2_hor_code_2_mux000385_1989,
      Q => huffman_ins_v2_hor_code(2)
    );
  huffman_ins_v2_hor_code_2_mux00031291 : LUT2
    generic map(
      INIT => X"8"
    )
    port map (
      I0 => huffman_ins_v2_hor_code_2_mux0003104_1983,
      I1 => huffman_ins_v2_hor_code_2_mux0003117_1984,
      O => huffman_ins_v2_hor_code_2_mux0003129
    );
  huffman_ins_v2_hor_code_1 : FDS
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      D => huffman_ins_v2_hor_code_1_mux0003120_1930,
      S => huffman_ins_v2_hor_code_1_mux000386_1935,
      Q => huffman_ins_v2_hor_code(1)
    );
  huffman_ins_v2_hor_code_0 : FDS
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      D => huffman_ins_v2_hor_code_0_mux000352_1819,
      S => huffman_ins_v2_hor_code_0_mux000324_1818,
      Q => huffman_ins_v2_hor_code(0)
    );
  huffman_ins_v2_hor_code_25 : FDS
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      D => huffman_ins_v2_hor_code_25_mux0003112,
      S => huffman_ins_v2_hor_code_25_mux00030_1979,
      Q => huffman_ins_v2_hor_code(25)
    );
  huffman_ins_v2_hor_code_25_mux00031121 : LUT2
    generic map(
      INIT => X"8"
    )
    port map (
      I0 => huffman_ins_v2_hor_code(25),
      I1 => huffman_ins_v2_hor_code_25_mux000380_1982,
      O => huffman_ins_v2_hor_code_25_mux0003112
    );
  huffman_ins_v2_hor_code_19 : FDS
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      D => huffman_ins_v2_hor_code_19_mux0003138_1925,
      S => huffman_ins_v2_hor_code_19_mux000380_1928,
      Q => huffman_ins_v2_hor_code(19)
    );
  huffman_ins_v2_hor_code_24 : FDS
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      D => huffman_ins_v2_hor_code_24_mux000371_1977,
      S => huffman_ins_v2_hor_code_24_mux000316_1974,
      Q => huffman_ins_v2_hor_code(24)
    );
  huffman_ins_v2_hor_code_23 : FDS
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      D => huffman_ins_v2_hor_code_23_mux000373,
      S => huffman_ins_v2_hor_code_23_mux00039_1971,
      Q => huffman_ins_v2_hor_code(23)
    );
  huffman_ins_v2_hor_code_23_mux0003731 : LUT3
    generic map(
      INIT => X"EA"
    )
    port map (
      I0 => huffman_ins_v2_hor_code_23_mux000322_1968,
      I1 => huffman_ins_v2_hor_code(23),
      I2 => huffman_ins_v2_hor_code_23_mux000356_1969,
      O => huffman_ins_v2_hor_code_23_mux000373
    );
  huffman_ins_v2_hor_code_18 : FDS
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      D => huffman_ins_v2_hor_code_18_mux0003230_1920,
      S => huffman_ins_v2_hor_code_18_mux0003130_1916,
      Q => huffman_ins_v2_hor_code(18)
    );
  huffman_ins_v2_hor_code_22 : FDS
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      D => huffman_ins_v2_hor_code_22_mux0003135_1960,
      S => huffman_ins_v2_hor_code_22_mux000385_1965,
      Q => huffman_ins_v2_hor_code(22)
    );
  huffman_ins_v2_hor_code_17 : FDS
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      D => huffman_ins_v2_hor_code_17_mux0003153,
      S => huffman_ins_v2_hor_code_17_mux000353_1910,
      Q => huffman_ins_v2_hor_code(17)
    );
  huffman_ins_v2_hor_code_16 : FDS
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      D => huffman_ins_v2_hor_code_16_mux0003138_1899,
      S => huffman_ins_v2_hor_code_16_mux0003102_1896,
      Q => huffman_ins_v2_hor_code(16)
    );
  huffman_ins_v2_hor_code_21 : FDS
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      D => huffman_ins_v2_hor_code_21_mux0003179_1952,
      S => huffman_ins_v2_hor_code_21_mux000379_1956,
      Q => huffman_ins_v2_hor_code(21)
    );
  huffman_ins_v2_hor_code_20 : FDS
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      D => huffman_ins_v2_hor_code_20_mux0003171,
      S => huffman_ins_v2_hor_code_20_mux0003105_1939,
      Q => huffman_ins_v2_hor_code(20)
    );
  huffman_ins_v2_hor_code_20_mux00031711 : LUT3
    generic map(
      INIT => X"EA"
    )
    port map (
      I0 => huffman_ins_v2_hor_code_20_mux0003158_1943,
      I1 => huffman_ins_v2_hor_code(20),
      I2 => huffman_ins_v2_hor_code_20_mux000370_1947,
      O => huffman_ins_v2_hor_code_20_mux0003171
    );
  huffman_ins_v2_hor_code_15 : FDS
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      D => huffman_ins_v2_hor_code_15_mux0003157,
      S => huffman_ins_v2_hor_code_15_mux000326_1887,
      Q => huffman_ins_v2_hor_code(15)
    );
  huffman_ins_v2_hor_code_15_mux00031571 : LUT3
    generic map(
      INIT => X"32"
    )
    port map (
      I0 => huffman_ins_v2_hor_code_15_mux0003122_1884,
      I1 => huffman_ins_v2_horizontal_mode_part_2_2065,
      I2 => huffman_ins_v2_hor_code_15_mux000380_1894,
      O => huffman_ins_v2_hor_code_15_mux0003157
    );
  huffman_ins_v2_hor_code_14 : FDS
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      D => huffman_ins_v2_hor_code_14_mux0003301_1878,
      S => huffman_ins_v2_hor_code_14_mux0003139_1867,
      Q => huffman_ins_v2_hor_code(14)
    );
  huffman_ins_v2_code_white_14 : FDS
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      D => huffman_ins_v2_code_white_14_mux000014,
      S => huffman_ins_v2_code_white_14_mux00004_1754,
      Q => huffman_ins_v2_code_white(14)
    );
  huffman_ins_v2_code_white_15 : FDS
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      D => huffman_ins_v2_code_white_15_mux00001_1756,
      S => N7,
      Q => huffman_ins_v2_code_white(15)
    );
  huffman_ins_v2_code_white_13 : FDS
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      D => huffman_ins_v2_code_white_13_mux000015_1750,
      S => huffman_ins_v2_code_white_13_mux00006_1751,
      Q => huffman_ins_v2_code_white(13)
    );
  huffman_ins_v2_hor_code_12 : FDS
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      D => huffman_ins_v2_hor_code_12_mux0003249_1847,
      S => huffman_ins_v2_hor_code_12_mux0003219_1845,
      Q => huffman_ins_v2_hor_code(12)
    );
  huffman_ins_v2_hor_code_13 : FDS
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      D => huffman_ins_v2_hor_code_13_mux0003198,
      S => huffman_ins_v2_hor_code_13_mux000389_1860,
      Q => huffman_ins_v2_hor_code(13)
    );
  huffman_ins_v2_hor_code_13_mux00031981 : LUT3
    generic map(
      INIT => X"EA"
    )
    port map (
      I0 => huffman_ins_v2_hor_code_13_mux0003181_1854,
      I1 => huffman_ins_v2_hor_code(13),
      I2 => huffman_ins_v2_hor_code_13_mux000350_1858,
      O => huffman_ins_v2_hor_code_13_mux0003198
    );
  huffman_ins_v2_hor_code_11 : FDS
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      D => huffman_ins_v2_hor_code_11_mux0003141,
      S => huffman_ins_v2_hor_code_11_mux000374_1836,
      Q => huffman_ins_v2_hor_code(11)
    );
  huffman_ins_v2_hor_code_11_mux00031411 : LUT3
    generic map(
      INIT => X"EA"
    )
    port map (
      I0 => huffman_ins_v2_hor_code_11_mux0003129_1831,
      I1 => huffman_ins_v2_hor_code(11),
      I2 => huffman_ins_v2_hor_code_11_mux000338_1834,
      O => huffman_ins_v2_hor_code_11_mux0003141
    );
  huffman_ins_v2_code_white_12 : FDS
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      D => huffman_ins_v2_code_white_12_mux000021_1746,
      S => huffman_ins_v2_code_white_12_mux000010_1745,
      Q => huffman_ins_v2_code_white(12)
    );
  huffman_ins_v2_code_white_11 : FDS
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      D => huffman_ins_v2_code_white_11_mux000021_1741,
      S => huffman_ins_v2_code_white_11_mux000010_1740,
      Q => huffman_ins_v2_code_white(11)
    );
  huffman_ins_v2_code_white_10 : FDS
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      D => huffman_ins_v2_code_white_10_mux000021_1736,
      S => huffman_ins_v2_code_white_10_mux000010_1735,
      Q => huffman_ins_v2_code_white(10)
    );
  huffman_ins_v2_code_white_9 : FDS
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      D => huffman_ins_v2_code_white_9_mux000021_1795,
      S => huffman_ins_v2_code_white_9_mux000010_1794,
      Q => huffman_ins_v2_code_white(9)
    );
  huffman_ins_v2_hor_code_10 : FDS
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      D => huffman_ins_v2_hor_code_10_mux0003112_1822,
      S => huffman_ins_v2_hor_code_10_mux000369_1826,
      Q => huffman_ins_v2_hor_code(10)
    );
  huffman_ins_v2_code_white_8 : FDS
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      D => huffman_ins_v2_code_white_8_mux000021_1789,
      S => huffman_ins_v2_code_white_8_mux000010_1788,
      Q => huffman_ins_v2_code_white(8)
    );
  fax4_ins_state_FSM_FFd11 : FDS
    generic map(
      INIT => '1'
    )
    port map (
      C => pclk_i,
      D => fax4_ins_state_FSM_FFd11_In1,
      S => fax4_ins_state_FSM_FFd1_1322,
      Q => fax4_ins_state_FSM_FFd11_1325
    );
  fax4_ins_state_FSM_FFd11_In11 : LUT3
    generic map(
      INIT => X"EA"
    )
    port map (
      I0 => fax4_ins_state_FSM_FFd4_1331,
      I1 => fax4_ins_counter_xy_v2_ins_frame_valid_1206,
      I2 => fax4_ins_state_FSM_FFd11_1325,
      O => fax4_ins_state_FSM_FFd11_In1
    );
  fax4_ins_state_FSM_FFd8 : FDS
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      D => fax4_ins_state_FSM_FFd8_In25,
      S => fax4_ins_state_FSM_FFd8_In7_1340,
      Q => fax4_ins_state_FSM_FFd8_1338
    );
  fax4_ins_state_FSM_FFd9 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      D => fax4_ins_state_FSM_FFd9_In1,
      R => fax4_ins_state_FSM_N7,
      Q => fax4_ins_state_FSM_FFd9_1341
    );
  fax4_ins_state_FSM_FFd1 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      D => fax4_ins_state_FSM_FFd9_1341,
      R => fax4_ins_counter_xy_v2_ins_frame_valid_1206,
      Q => fax4_ins_state_FSM_FFd1_1322
    );
  fax4_ins_EOF_prev : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      D => N1,
      R => fax4_ins_counter_xy_v2_ins_frame_valid_1206,
      Q => fax4_ins_EOF_prev_228
    );
  fax4_ins_output_valid_o : FDS_1
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      D => fax4_ins_output_valid_o_mux000336,
      S => fax4_ins_output_valid_o_mux000315,
      Q => fax4_ins_output_valid_o_1311
    );
  fax4_ins_state_updated : FDS
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      D => fax4_ins_output_valid_o_mux000336,
      S => fax4_ins_state_updated_mux000854_1348,
      Q => fax4_ins_state_updated_1345
    );
  fax4_ins_state_FSM_FFd4 : FDRS
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      D => fax4_ins_state_FSM_FFd4_In11,
      R => fax4_ins_counter_xy_v2_ins_frame_valid_1206,
      S => fax4_ins_state_FSM_FFd3_1329,
      Q => fax4_ins_state_FSM_FFd4_1331
    );
  fax4_ins_state_FSM_FFd4_In111 : LUT2
    generic map(
      INIT => X"2"
    )
    port map (
      I0 => fax4_ins_state_FSM_N12,
      I1 => fax4_ins_EOF_prev_228,
      O => fax4_ins_state_FSM_FFd4_In11
    );
  huffman_ins_v2_Msub_run_length_white_addsub0000_cy_0_rt : LUT1
    generic map(
      INIT => X"2"
    )
    port map (
      I0 => fax4_ins_a1_o(0),
      O => huffman_ins_v2_Msub_run_length_white_addsub0000_cy_0_rt_1404
    );
  fax4_ins_counter_xy_v2_ins_counter_x_ins_Madd_cnt_addsub0000_cy_8_rt : LUT1
    generic map(
      INIT => X"2"
    )
    port map (
      I0 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(8),
      O => fax4_ins_counter_xy_v2_ins_counter_x_ins_Madd_cnt_addsub0000_cy_8_rt_1123
    );
  fax4_ins_counter_xy_v2_ins_counter_x_ins_Madd_cnt_addsub0000_cy_7_rt : LUT1
    generic map(
      INIT => X"2"
    )
    port map (
      I0 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(7),
      O => fax4_ins_counter_xy_v2_ins_counter_x_ins_Madd_cnt_addsub0000_cy_7_rt_1121
    );
  fax4_ins_counter_xy_v2_ins_counter_x_ins_Madd_cnt_addsub0000_cy_6_rt : LUT1
    generic map(
      INIT => X"2"
    )
    port map (
      I0 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(6),
      O => fax4_ins_counter_xy_v2_ins_counter_x_ins_Madd_cnt_addsub0000_cy_6_rt_1119
    );
  fax4_ins_counter_xy_v2_ins_counter_x_ins_Madd_cnt_addsub0000_cy_5_rt : LUT1
    generic map(
      INIT => X"2"
    )
    port map (
      I0 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(5),
      O => fax4_ins_counter_xy_v2_ins_counter_x_ins_Madd_cnt_addsub0000_cy_5_rt_1117
    );
  fax4_ins_counter_xy_v2_ins_counter_x_ins_Madd_cnt_addsub0000_cy_4_rt : LUT1
    generic map(
      INIT => X"2"
    )
    port map (
      I0 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(4),
      O => fax4_ins_counter_xy_v2_ins_counter_x_ins_Madd_cnt_addsub0000_cy_4_rt_1115
    );
  fax4_ins_counter_xy_v2_ins_counter_x_ins_Madd_cnt_addsub0000_cy_3_rt : LUT1
    generic map(
      INIT => X"2"
    )
    port map (
      I0 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(3),
      O => fax4_ins_counter_xy_v2_ins_counter_x_ins_Madd_cnt_addsub0000_cy_3_rt_1113
    );
  fax4_ins_counter_xy_v2_ins_counter_x_ins_Madd_cnt_addsub0000_cy_2_rt : LUT1
    generic map(
      INIT => X"2"
    )
    port map (
      I0 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(2),
      O => fax4_ins_counter_xy_v2_ins_counter_x_ins_Madd_cnt_addsub0000_cy_2_rt_1111
    );
  fax4_ins_counter_xy_v2_ins_counter_x_ins_Madd_cnt_addsub0000_cy_1_rt : LUT1
    generic map(
      INIT => X"2"
    )
    port map (
      I0 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(1),
      O => fax4_ins_counter_xy_v2_ins_counter_x_ins_Madd_cnt_addsub0000_cy_1_rt_1109
    );
  fax4_ins_counter_xy_v2_ins_counter_y_ins_Madd_cnt_addsub0000_cy_7_rt : LUT1
    generic map(
      INIT => X"2"
    )
    port map (
      I0 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt(7),
      O => fax4_ins_counter_xy_v2_ins_counter_y_ins_Madd_cnt_addsub0000_cy_7_rt_1173
    );
  fax4_ins_counter_xy_v2_ins_counter_y_ins_Madd_cnt_addsub0000_cy_6_rt : LUT1
    generic map(
      INIT => X"2"
    )
    port map (
      I0 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt(6),
      O => fax4_ins_counter_xy_v2_ins_counter_y_ins_Madd_cnt_addsub0000_cy_6_rt_1171
    );
  fax4_ins_counter_xy_v2_ins_counter_y_ins_Madd_cnt_addsub0000_cy_5_rt : LUT1
    generic map(
      INIT => X"2"
    )
    port map (
      I0 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt(5),
      O => fax4_ins_counter_xy_v2_ins_counter_y_ins_Madd_cnt_addsub0000_cy_5_rt_1169
    );
  fax4_ins_counter_xy_v2_ins_counter_y_ins_Madd_cnt_addsub0000_cy_4_rt : LUT1
    generic map(
      INIT => X"2"
    )
    port map (
      I0 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt(4),
      O => fax4_ins_counter_xy_v2_ins_counter_y_ins_Madd_cnt_addsub0000_cy_4_rt_1167
    );
  fax4_ins_counter_xy_v2_ins_counter_y_ins_Madd_cnt_addsub0000_cy_3_rt : LUT1
    generic map(
      INIT => X"2"
    )
    port map (
      I0 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt(3),
      O => fax4_ins_counter_xy_v2_ins_counter_y_ins_Madd_cnt_addsub0000_cy_3_rt_1165
    );
  fax4_ins_counter_xy_v2_ins_counter_y_ins_Madd_cnt_addsub0000_cy_2_rt : LUT1
    generic map(
      INIT => X"2"
    )
    port map (
      I0 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt(2),
      O => fax4_ins_counter_xy_v2_ins_counter_y_ins_Madd_cnt_addsub0000_cy_2_rt_1163
    );
  fax4_ins_counter_xy_v2_ins_counter_y_ins_Madd_cnt_addsub0000_cy_1_rt : LUT1
    generic map(
      INIT => X"2"
    )
    port map (
      I0 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt(1),
      O => fax4_ins_counter_xy_v2_ins_counter_y_ins_Madd_cnt_addsub0000_cy_1_rt_1161
    );
  fax4_ins_FIFO1_multi_read_ins_Mcount_read_pos_cy_1_rt : LUT1
    generic map(
      INIT => X"2"
    )
    port map (
      I0 => fax4_ins_FIFO1_multi_read_ins_read_pos(1),
      O => fax4_ins_FIFO1_multi_read_ins_Mcount_read_pos_cy_1_rt_234
    );
  fax4_ins_FIFO1_multi_read_ins_Mcount_read_pos_cy_2_rt : LUT1
    generic map(
      INIT => X"2"
    )
    port map (
      I0 => fax4_ins_FIFO1_multi_read_ins_read_pos(2),
      O => fax4_ins_FIFO1_multi_read_ins_Mcount_read_pos_cy_2_rt_236
    );
  fax4_ins_FIFO1_multi_read_ins_Mcount_read_pos_cy_3_rt : LUT1
    generic map(
      INIT => X"2"
    )
    port map (
      I0 => fax4_ins_FIFO1_multi_read_ins_read_pos(3),
      O => fax4_ins_FIFO1_multi_read_ins_Mcount_read_pos_cy_3_rt_238
    );
  fax4_ins_FIFO1_multi_read_ins_Mcount_read_pos_cy_4_rt : LUT1
    generic map(
      INIT => X"2"
    )
    port map (
      I0 => fax4_ins_FIFO1_multi_read_ins_read_pos(4),
      O => fax4_ins_FIFO1_multi_read_ins_Mcount_read_pos_cy_4_rt_240
    );
  fax4_ins_FIFO1_multi_read_ins_Mcount_read_pos_cy_5_rt : LUT1
    generic map(
      INIT => X"2"
    )
    port map (
      I0 => fax4_ins_FIFO1_multi_read_ins_read_pos(5),
      O => fax4_ins_FIFO1_multi_read_ins_Mcount_read_pos_cy_5_rt_242
    );
  fax4_ins_FIFO1_multi_read_ins_Mcount_read_pos_cy_6_rt : LUT1
    generic map(
      INIT => X"2"
    )
    port map (
      I0 => fax4_ins_FIFO1_multi_read_ins_read_pos(6),
      O => fax4_ins_FIFO1_multi_read_ins_Mcount_read_pos_cy_6_rt_244
    );
  fax4_ins_FIFO1_multi_read_ins_Mcount_read_pos_cy_7_rt : LUT1
    generic map(
      INIT => X"2"
    )
    port map (
      I0 => fax4_ins_FIFO1_multi_read_ins_read_pos(7),
      O => fax4_ins_FIFO1_multi_read_ins_Mcount_read_pos_cy_7_rt_246
    );
  fax4_ins_FIFO1_multi_read_ins_Mcount_read_pos_cy_8_rt : LUT1
    generic map(
      INIT => X"2"
    )
    port map (
      I0 => fax4_ins_FIFO1_multi_read_ins_read_pos(8),
      O => fax4_ins_FIFO1_multi_read_ins_Mcount_read_pos_cy_8_rt_248
    );
  fax4_ins_FIFO1_multi_read_ins_Mcount_write_pos_cy_1_rt : LUT1
    generic map(
      INIT => X"2"
    )
    port map (
      I0 => fax4_ins_FIFO1_multi_read_ins_write_pos(1),
      O => fax4_ins_FIFO1_multi_read_ins_Mcount_write_pos_cy_1_rt_282
    );
  fax4_ins_FIFO1_multi_read_ins_Mcount_write_pos_cy_2_rt : LUT1
    generic map(
      INIT => X"2"
    )
    port map (
      I0 => fax4_ins_FIFO1_multi_read_ins_write_pos(2),
      O => fax4_ins_FIFO1_multi_read_ins_Mcount_write_pos_cy_2_rt_284
    );
  fax4_ins_FIFO1_multi_read_ins_Mcount_write_pos_cy_3_rt : LUT1
    generic map(
      INIT => X"2"
    )
    port map (
      I0 => fax4_ins_FIFO1_multi_read_ins_write_pos(3),
      O => fax4_ins_FIFO1_multi_read_ins_Mcount_write_pos_cy_3_rt_286
    );
  fax4_ins_FIFO1_multi_read_ins_Mcount_write_pos_cy_4_rt : LUT1
    generic map(
      INIT => X"2"
    )
    port map (
      I0 => fax4_ins_FIFO1_multi_read_ins_write_pos(4),
      O => fax4_ins_FIFO1_multi_read_ins_Mcount_write_pos_cy_4_rt_288
    );
  fax4_ins_FIFO1_multi_read_ins_Mcount_write_pos_cy_5_rt : LUT1
    generic map(
      INIT => X"2"
    )
    port map (
      I0 => fax4_ins_FIFO1_multi_read_ins_write_pos(5),
      O => fax4_ins_FIFO1_multi_read_ins_Mcount_write_pos_cy_5_rt_290
    );
  fax4_ins_FIFO1_multi_read_ins_Mcount_write_pos_cy_6_rt : LUT1
    generic map(
      INIT => X"2"
    )
    port map (
      I0 => fax4_ins_FIFO1_multi_read_ins_write_pos(6),
      O => fax4_ins_FIFO1_multi_read_ins_Mcount_write_pos_cy_6_rt_292
    );
  fax4_ins_FIFO1_multi_read_ins_Mcount_write_pos_cy_7_rt : LUT1
    generic map(
      INIT => X"2"
    )
    port map (
      I0 => fax4_ins_FIFO1_multi_read_ins_write_pos(7),
      O => fax4_ins_FIFO1_multi_read_ins_Mcount_write_pos_cy_7_rt_294
    );
  fax4_ins_FIFO1_multi_read_ins_Mcount_write_pos_cy_8_rt : LUT1
    generic map(
      INIT => X"2"
    )
    port map (
      I0 => fax4_ins_FIFO1_multi_read_ins_write_pos(8),
      O => fax4_ins_FIFO1_multi_read_ins_Mcount_write_pos_cy_8_rt_296
    );
  fax4_ins_FIFO2_multi_read_ins_Mcount_read_pos_cy_1_rt : LUT1
    generic map(
      INIT => X"2"
    )
    port map (
      I0 => fax4_ins_FIFO2_multi_read_ins_read_pos(1),
      O => fax4_ins_FIFO2_multi_read_ins_Mcount_read_pos_cy_1_rt_475
    );
  fax4_ins_FIFO2_multi_read_ins_Mcount_read_pos_cy_2_rt : LUT1
    generic map(
      INIT => X"2"
    )
    port map (
      I0 => fax4_ins_FIFO2_multi_read_ins_read_pos(2),
      O => fax4_ins_FIFO2_multi_read_ins_Mcount_read_pos_cy_2_rt_477
    );
  fax4_ins_FIFO2_multi_read_ins_Mcount_read_pos_cy_3_rt : LUT1
    generic map(
      INIT => X"2"
    )
    port map (
      I0 => fax4_ins_FIFO2_multi_read_ins_read_pos(3),
      O => fax4_ins_FIFO2_multi_read_ins_Mcount_read_pos_cy_3_rt_479
    );
  fax4_ins_FIFO2_multi_read_ins_Mcount_read_pos_cy_4_rt : LUT1
    generic map(
      INIT => X"2"
    )
    port map (
      I0 => fax4_ins_FIFO2_multi_read_ins_read_pos(4),
      O => fax4_ins_FIFO2_multi_read_ins_Mcount_read_pos_cy_4_rt_481
    );
  fax4_ins_FIFO2_multi_read_ins_Mcount_read_pos_cy_5_rt : LUT1
    generic map(
      INIT => X"2"
    )
    port map (
      I0 => fax4_ins_FIFO2_multi_read_ins_read_pos(5),
      O => fax4_ins_FIFO2_multi_read_ins_Mcount_read_pos_cy_5_rt_483
    );
  fax4_ins_FIFO2_multi_read_ins_Mcount_read_pos_cy_6_rt : LUT1
    generic map(
      INIT => X"2"
    )
    port map (
      I0 => fax4_ins_FIFO2_multi_read_ins_read_pos(6),
      O => fax4_ins_FIFO2_multi_read_ins_Mcount_read_pos_cy_6_rt_485
    );
  fax4_ins_FIFO2_multi_read_ins_Mcount_read_pos_cy_7_rt : LUT1
    generic map(
      INIT => X"2"
    )
    port map (
      I0 => fax4_ins_FIFO2_multi_read_ins_read_pos(7),
      O => fax4_ins_FIFO2_multi_read_ins_Mcount_read_pos_cy_7_rt_487
    );
  fax4_ins_FIFO2_multi_read_ins_Mcount_read_pos_cy_8_rt : LUT1
    generic map(
      INIT => X"2"
    )
    port map (
      I0 => fax4_ins_FIFO2_multi_read_ins_read_pos(8),
      O => fax4_ins_FIFO2_multi_read_ins_Mcount_read_pos_cy_8_rt_489
    );
  fax4_ins_FIFO2_multi_read_ins_Mcount_write_pos_cy_1_rt : LUT1
    generic map(
      INIT => X"2"
    )
    port map (
      I0 => fax4_ins_FIFO2_multi_read_ins_write_pos(1),
      O => fax4_ins_FIFO2_multi_read_ins_Mcount_write_pos_cy_1_rt_523
    );
  fax4_ins_FIFO2_multi_read_ins_Mcount_write_pos_cy_2_rt : LUT1
    generic map(
      INIT => X"2"
    )
    port map (
      I0 => fax4_ins_FIFO2_multi_read_ins_write_pos(2),
      O => fax4_ins_FIFO2_multi_read_ins_Mcount_write_pos_cy_2_rt_525
    );
  fax4_ins_FIFO2_multi_read_ins_Mcount_write_pos_cy_3_rt : LUT1
    generic map(
      INIT => X"2"
    )
    port map (
      I0 => fax4_ins_FIFO2_multi_read_ins_write_pos(3),
      O => fax4_ins_FIFO2_multi_read_ins_Mcount_write_pos_cy_3_rt_527
    );
  fax4_ins_FIFO2_multi_read_ins_Mcount_write_pos_cy_4_rt : LUT1
    generic map(
      INIT => X"2"
    )
    port map (
      I0 => fax4_ins_FIFO2_multi_read_ins_write_pos(4),
      O => fax4_ins_FIFO2_multi_read_ins_Mcount_write_pos_cy_4_rt_529
    );
  fax4_ins_FIFO2_multi_read_ins_Mcount_write_pos_cy_5_rt : LUT1
    generic map(
      INIT => X"2"
    )
    port map (
      I0 => fax4_ins_FIFO2_multi_read_ins_write_pos(5),
      O => fax4_ins_FIFO2_multi_read_ins_Mcount_write_pos_cy_5_rt_531
    );
  fax4_ins_FIFO2_multi_read_ins_Mcount_write_pos_cy_6_rt : LUT1
    generic map(
      INIT => X"2"
    )
    port map (
      I0 => fax4_ins_FIFO2_multi_read_ins_write_pos(6),
      O => fax4_ins_FIFO2_multi_read_ins_Mcount_write_pos_cy_6_rt_533
    );
  fax4_ins_FIFO2_multi_read_ins_Mcount_write_pos_cy_7_rt : LUT1
    generic map(
      INIT => X"2"
    )
    port map (
      I0 => fax4_ins_FIFO2_multi_read_ins_write_pos(7),
      O => fax4_ins_FIFO2_multi_read_ins_Mcount_write_pos_cy_7_rt_535
    );
  fax4_ins_FIFO2_multi_read_ins_Mcount_write_pos_cy_8_rt : LUT1
    generic map(
      INIT => X"2"
    )
    port map (
      I0 => fax4_ins_FIFO2_multi_read_ins_write_pos(8),
      O => fax4_ins_FIFO2_multi_read_ins_Mcount_write_pos_cy_8_rt_537
    );
  fax4_ins_Madd_fifo_rd_addsub0000_cy_8_rt : LUT1
    generic map(
      INIT => X"2"
    )
    port map (
      I0 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(8),
      O => fax4_ins_Madd_fifo_rd_addsub0000_cy_8_rt_747
    );
  fax4_ins_Madd_fifo_rd_addsub0000_cy_7_rt : LUT1
    generic map(
      INIT => X"2"
    )
    port map (
      I0 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(7),
      O => fax4_ins_Madd_fifo_rd_addsub0000_cy_7_rt_745
    );
  fax4_ins_Madd_fifo_rd_addsub0000_cy_6_rt : LUT1
    generic map(
      INIT => X"2"
    )
    port map (
      I0 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(6),
      O => fax4_ins_Madd_fifo_rd_addsub0000_cy_6_rt_743
    );
  fax4_ins_Madd_fifo_rd_addsub0000_cy_5_rt : LUT1
    generic map(
      INIT => X"2"
    )
    port map (
      I0 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(5),
      O => fax4_ins_Madd_fifo_rd_addsub0000_cy_5_rt_741
    );
  fax4_ins_Madd_fifo_rd_addsub0000_cy_4_rt : LUT1
    generic map(
      INIT => X"2"
    )
    port map (
      I0 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(4),
      O => fax4_ins_Madd_fifo_rd_addsub0000_cy_4_rt_739
    );
  fax4_ins_Madd_fifo_rd_addsub0000_cy_3_rt : LUT1
    generic map(
      INIT => X"2"
    )
    port map (
      I0 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(3),
      O => fax4_ins_Madd_fifo_rd_addsub0000_cy_3_rt_737
    );
  fax4_ins_Madd_fifo_rd_addsub0000_cy_2_rt : LUT1
    generic map(
      INIT => X"2"
    )
    port map (
      I0 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(2),
      O => fax4_ins_Madd_fifo_rd_addsub0000_cy_2_rt_735
    );
  fax4_ins_Madd_fifo_rd_addsub0000_cy_1_rt : LUT1
    generic map(
      INIT => X"2"
    )
    port map (
      I0 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(1),
      O => fax4_ins_Madd_fifo_rd_addsub0000_cy_1_rt_733
    );
  fax4_ins_counter_xy_v2_ins_counter_x_ins_Madd_cnt_addsub0000_xor_9_rt : LUT1
    generic map(
      INIT => X"2"
    )
    port map (
      I0 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(9),
      O => fax4_ins_counter_xy_v2_ins_counter_x_ins_Madd_cnt_addsub0000_xor_9_rt_1125
    );
  fax4_ins_counter_xy_v2_ins_counter_y_ins_Madd_cnt_addsub0000_xor_8_rt : LUT1
    generic map(
      INIT => X"2"
    )
    port map (
      I0 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt(8),
      O => fax4_ins_counter_xy_v2_ins_counter_y_ins_Madd_cnt_addsub0000_xor_8_rt_1175
    );
  fax4_ins_FIFO1_multi_read_ins_Mcount_read_pos_xor_9_rt : LUT1
    generic map(
      INIT => X"2"
    )
    port map (
      I0 => fax4_ins_FIFO1_multi_read_ins_read_pos(9),
      O => fax4_ins_FIFO1_multi_read_ins_Mcount_read_pos_xor_9_rt_260
    );
  fax4_ins_FIFO1_multi_read_ins_Mcount_write_pos_xor_9_rt : LUT1
    generic map(
      INIT => X"2"
    )
    port map (
      I0 => fax4_ins_FIFO1_multi_read_ins_write_pos(9),
      O => fax4_ins_FIFO1_multi_read_ins_Mcount_write_pos_xor_9_rt_308
    );
  fax4_ins_FIFO2_multi_read_ins_Mcount_read_pos_xor_9_rt : LUT1
    generic map(
      INIT => X"2"
    )
    port map (
      I0 => fax4_ins_FIFO2_multi_read_ins_read_pos(9),
      O => fax4_ins_FIFO2_multi_read_ins_Mcount_read_pos_xor_9_rt_501
    );
  fax4_ins_FIFO2_multi_read_ins_Mcount_write_pos_xor_9_rt : LUT1
    generic map(
      INIT => X"2"
    )
    port map (
      I0 => fax4_ins_FIFO2_multi_read_ins_write_pos(9),
      O => fax4_ins_FIFO2_multi_read_ins_Mcount_write_pos_xor_9_rt_549
    );
  fax4_ins_Madd_fifo_rd_addsub0000_xor_9_rt : LUT1
    generic map(
      INIT => X"2"
    )
    port map (
      I0 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(9),
      O => fax4_ins_Madd_fifo_rd_addsub0000_xor_9_rt_749
    );
  huffman_ins_v2_code_black_19_mux00001_f5_rt : LUT1
    generic map(
      INIT => X"2"
    )
    port map (
      I0 => huffman_ins_v2_code_table_ins_makeup_black_8_Q,
      O => huffman_ins_v2_code_black_19_mux00001_f5_rt_1594
    );
  fax4_ins_vertical_mode_cmp_le00002169_SW0 : LUT4
    generic map(
      INIT => X"AAA8"
    )
    port map (
      I0 => N481,
      I1 => fax4_ins_vertical_mode_addsub0000(2),
      I2 => fax4_ins_vertical_mode_addsub0000(4),
      I3 => fax4_ins_vertical_mode_addsub0000(5),
      O => N105
    );
  fax4_ins_vertical_mode_cmp_le00002169 : LUT4
    generic map(
      INIT => X"0080"
    )
    port map (
      I0 => fax4_ins_vertical_mode_cmp_le00002114_1362,
      I1 => fax4_ins_vertical_mode_cmp_le0000245_1366,
      I2 => fax4_ins_vertical_mode_cmp_le0000281_1367,
      I3 => N105,
      O => fax4_ins_vertical_mode_cmp_le00002169_1364
    );
  fax4_ins_vertical_mode_cmp_le00002114 : LUT4
    generic map(
      INIT => X"F0F1"
    )
    port map (
      I0 => fax4_ins_a1b1(4),
      I1 => fax4_ins_a1b1(5),
      I2 => fax4_ins_a1b1(10),
      I3 => N111,
      O => fax4_ins_vertical_mode_cmp_le00002114_1362
    );
  fax4_ins_a1b1_0_1 : LUT4
    generic map(
      INIT => X"D515"
    )
    port map (
      I0 => fax4_ins_b1(0),
      I1 => fax4_ins_counter_xy_v2_ins_line_valid_1210,
      I2 => fax4_ins_counter_xy_v2_ins_frame_valid_1206,
      I3 => fax4_ins_a1b1_addsub0000(0),
      O => fax4_ins_a1b1(0)
    );
  fax4_ins_vertical_mode_cmp_le0000245 : LUT4
    generic map(
      INIT => X"27FF"
    )
    port map (
      I0 => fax4_ins_EOL,
      I1 => fax4_ins_a1b1_addsub0001(10),
      I2 => fax4_ins_a1b1_addsub0000(10),
      I3 => fax4_ins_vertical_mode_addsub0000(3),
      O => fax4_ins_vertical_mode_cmp_le0000245_1366
    );
  fax4_ins_fifo_rd36 : LUT4
    generic map(
      INIT => X"00E0"
    )
    port map (
      I0 => fax4_ins_fifo_rd0_1266,
      I1 => fax4_ins_fifo_rd3_1268,
      I2 => fax4_ins_fifo_rd22_1267,
      I3 => fax4_ins_Mcompar_fifo_rd_cmp_lt0000_cy(9),
      O => fax4_ins_fifo_rd
    );
  fax4_ins_FIFO1_multi_read_ins_Mcount_used_lut_0_Q : LUT3
    generic map(
      INIT => X"65"
    )
    port map (
      I0 => fax4_ins_FIFO1_multi_read_ins_used(0),
      I1 => fax4_ins_fifo1_wr,
      I2 => fax4_ins_FIFO1_multi_read_ins_N8,
      O => fax4_ins_FIFO1_multi_read_ins_Mcount_used_lut(0)
    );
  fax4_ins_FIFO2_multi_read_ins_Mcount_used_lut_0_Q : LUT3
    generic map(
      INIT => X"65"
    )
    port map (
      I0 => fax4_ins_FIFO2_multi_read_ins_used(0),
      I1 => fax4_ins_fifo2_wr,
      I2 => fax4_ins_FIFO2_multi_read_ins_N8,
      O => fax4_ins_FIFO2_multi_read_ins_Mcount_used_lut(0)
    );
  fax4_ins_FIFO1_multi_read_ins_Mcount_used_lut_9_Q : LUT3
    generic map(
      INIT => X"9A"
    )
    port map (
      I0 => fax4_ins_FIFO1_multi_read_ins_used(9),
      I1 => fax4_ins_fifo1_wr,
      I2 => fax4_ins_FIFO1_multi_read_ins_N8,
      O => fax4_ins_FIFO1_multi_read_ins_Mcount_used_lut(9)
    );
  fax4_ins_FIFO2_multi_read_ins_Mcount_used_lut_9_Q : LUT3
    generic map(
      INIT => X"9A"
    )
    port map (
      I0 => fax4_ins_FIFO2_multi_read_ins_used(9),
      I1 => fax4_ins_fifo2_wr,
      I2 => fax4_ins_FIFO2_multi_read_ins_N8,
      O => fax4_ins_FIFO2_multi_read_ins_Mcount_used_lut(9)
    );
  fax4_ins_vertical_mode_cmp_le0000281_SW0 : LUT4
    generic map(
      INIT => X"FFE2"
    )
    port map (
      I0 => fax4_ins_a1b1_addsub0000(7),
      I1 => fax4_ins_EOL,
      I2 => fax4_ins_a1b1_addsub0001(7),
      I3 => N478,
      O => N113
    );
  fax4_ins_Madd_vertical_mode_not0000_1_1 : LUT4
    generic map(
      INIT => X"13B3"
    )
    port map (
      I0 => fax4_ins_counter_xy_v2_ins_line_valid_1210,
      I1 => fax4_ins_a1b1_addsub0001(1),
      I2 => fax4_ins_counter_xy_v2_ins_frame_valid_1206,
      I3 => fax4_ins_a1b1_addsub0000(1),
      O => fax4_ins_Madd_vertical_mode_not0000(1)
    );
  fax4_ins_Madd_vertical_mode_not0000_2_1 : LUT4
    generic map(
      INIT => X"13B3"
    )
    port map (
      I0 => fax4_ins_counter_xy_v2_ins_line_valid_1210,
      I1 => fax4_ins_a1b1_addsub0001(2),
      I2 => fax4_ins_counter_xy_v2_ins_frame_valid_1206,
      I3 => fax4_ins_a1b1_addsub0000(2),
      O => fax4_ins_Madd_vertical_mode_not0000(2)
    );
  fax4_ins_Madd_vertical_mode_not0000_3_1 : LUT4
    generic map(
      INIT => X"13B3"
    )
    port map (
      I0 => fax4_ins_counter_xy_v2_ins_line_valid_1210,
      I1 => fax4_ins_a1b1_addsub0001(3),
      I2 => fax4_ins_counter_xy_v2_ins_frame_valid_1206,
      I3 => fax4_ins_a1b1_addsub0000(3),
      O => fax4_ins_Madd_vertical_mode_not0000(3)
    );
  fax4_ins_Madd_vertical_mode_not0000_4_1 : LUT4
    generic map(
      INIT => X"13B3"
    )
    port map (
      I0 => fax4_ins_counter_xy_v2_ins_line_valid_1210,
      I1 => fax4_ins_a1b1_addsub0001(4),
      I2 => fax4_ins_counter_xy_v2_ins_frame_valid_1206,
      I3 => fax4_ins_a1b1_addsub0000(4),
      O => fax4_ins_Madd_vertical_mode_not0000(4)
    );
  fax4_ins_Madd_vertical_mode_not0000_5_1 : LUT4
    generic map(
      INIT => X"13B3"
    )
    port map (
      I0 => fax4_ins_counter_xy_v2_ins_line_valid_1210,
      I1 => fax4_ins_a1b1_addsub0001(5),
      I2 => fax4_ins_counter_xy_v2_ins_frame_valid_1206,
      I3 => fax4_ins_a1b1_addsub0000(5),
      O => fax4_ins_Madd_vertical_mode_not0000(5)
    );
  fax4_ins_Madd_vertical_mode_not0000_6_1 : LUT4
    generic map(
      INIT => X"13B3"
    )
    port map (
      I0 => fax4_ins_counter_xy_v2_ins_line_valid_1210,
      I1 => fax4_ins_a1b1_addsub0001(6),
      I2 => fax4_ins_counter_xy_v2_ins_frame_valid_1206,
      I3 => fax4_ins_a1b1_addsub0000(6),
      O => fax4_ins_Madd_vertical_mode_not0000(6)
    );
  fax4_ins_Madd_vertical_mode_not0000_7_1 : LUT4
    generic map(
      INIT => X"13B3"
    )
    port map (
      I0 => fax4_ins_counter_xy_v2_ins_line_valid_1210,
      I1 => fax4_ins_a1b1_addsub0001(7),
      I2 => fax4_ins_counter_xy_v2_ins_frame_valid_1206,
      I3 => fax4_ins_a1b1_addsub0000(7),
      O => fax4_ins_Madd_vertical_mode_not0000(7)
    );
  fax4_ins_Madd_vertical_mode_not0000_8_1 : LUT4
    generic map(
      INIT => X"13B3"
    )
    port map (
      I0 => fax4_ins_counter_xy_v2_ins_line_valid_1210,
      I1 => fax4_ins_a1b1_addsub0001(8),
      I2 => fax4_ins_counter_xy_v2_ins_frame_valid_1206,
      I3 => fax4_ins_a1b1_addsub0000(8),
      O => fax4_ins_Madd_vertical_mode_not0000(8)
    );
  fax4_ins_Madd_vertical_mode_not0000_9_1 : LUT4
    generic map(
      INIT => X"13B3"
    )
    port map (
      I0 => fax4_ins_counter_xy_v2_ins_line_valid_1210,
      I1 => fax4_ins_a1b1_addsub0001(9),
      I2 => fax4_ins_counter_xy_v2_ins_frame_valid_1206,
      I3 => fax4_ins_a1b1_addsub0000(9),
      O => fax4_ins_Madd_vertical_mode_not0000(9)
    );
  fax4_ins_a1b1_9_1 : LUT4
    generic map(
      INIT => X"EC4C"
    )
    port map (
      I0 => fax4_ins_counter_xy_v2_ins_frame_valid_1206,
      I1 => fax4_ins_a1b1_addsub0001(9),
      I2 => fax4_ins_counter_xy_v2_ins_line_valid_1210,
      I3 => fax4_ins_a1b1_addsub0000(9),
      O => fax4_ins_a1b1(9)
    );
  fax4_ins_mode_indicator_o_or00001_SW0 : LUT2
    generic map(
      INIT => X"2"
    )
    port map (
      I0 => fax4_ins_EOL_prev_230,
      I1 => fax4_ins_EOL_prev_prev_231,
      O => N142
    );
  fax4_ins_mux_a0_and00011_SW1 : LUT4
    generic map(
      INIT => X"A2AE"
    )
    port map (
      I0 => N496,
      I1 => fax4_ins_pix_changed_1319,
      I2 => fax4_ins_state_FSM_FFd8_1338,
      I3 => rsync_i,
      O => N146
    );
  fax4_ins_mux_a0_and00011_SW2 : LUT2
    generic map(
      INIT => X"2"
    )
    port map (
      I0 => fax4_ins_pix_changed_1319,
      I1 => fax4_ins_state_FSM_FFd8_1338,
      O => N148
    );
  fax4_ins_mode_indicator_o_3 : FD_1
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      D => fax4_ins_mode_indicator_o_3_rstpot_1295,
      Q => fax4_ins_mode_indicator_o(3)
    );
  fax4_ins_mode_indicator_o_2 : FD_1
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      D => fax4_ins_mode_indicator_o_2_rstpot_1291,
      Q => fax4_ins_mode_indicator_o(2)
    );
  fax4_ins_mode_indicator_o_1 : FD_1
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      D => fax4_ins_mode_indicator_o_1_rstpot_1289,
      Q => fax4_ins_mode_indicator_o(1)
    );
  fax4_ins_mode_indicator_o_0 : FD_1
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      D => fax4_ins_mode_indicator_o_0_rstpot_1287,
      Q => fax4_ins_mode_indicator_o(0)
    );
  fax4_ins_mux_a0_and00011_SW8 : LUT4
    generic map(
      INIT => X"FB40"
    )
    port map (
      I0 => fax4_ins_state_FSM_FFd8_1338,
      I1 => fax4_ins_pix_changed_1319,
      I2 => fax4_ins_a0_to_white_mux00007_949,
      I3 => N479,
      O => N165
    );
  fax4_ins_a0_to_white_mux000047 : LUT4
    generic map(
      INIT => X"FAEE"
    )
    port map (
      I0 => fax4_ins_mux_a0_0_Q,
      I1 => N133,
      I2 => N165,
      I3 => fax4_ins_vertical_mode_cmp_le0000,
      O => fax4_ins_a0_to_white_mux0000
    );
  fax4_ins_vertical_mode1_SW1 : LUT2
    generic map(
      INIT => X"E"
    )
    port map (
      I0 => fax4_ins_pass_mode,
      I1 => fax4_ins_load_a1_or0001,
      O => N167
    );
  fax4_ins_mode_indicator_o_mux0001_2_35_SW2_SW0 : LUT4
    generic map(
      INIT => X"D555"
    )
    port map (
      I0 => fax4_ins_load_a1_or0001,
      I1 => N469,
      I2 => fax4_ins_mode_indicator_o_mux0001_2_261_1297,
      I3 => fax4_ins_mode_indicator_o_mux0001_2_3111_1298,
      O => N172
    );
  fax4_ins_mode_indicator_o_mux0001_3_41_SW2 : LUT4
    generic map(
      INIT => X"ECCC"
    )
    port map (
      I0 => fax4_ins_a1b1(0),
      I1 => N174,
      I2 => fax4_ins_mode_indicator_o_mux0001_2_341_1299,
      I3 => N470,
      O => N161
    );
  fax4_ins_mode_indicator_o_2_rstpot : LUT4
    generic map(
      INIT => X"2733"
    )
    port map (
      I0 => fax4_ins_state_FSM_FFd8_1338,
      I1 => N176,
      I2 => N177,
      I3 => fax4_ins_vertical_mode_cmp_le0000,
      O => fax4_ins_mode_indicator_o_2_rstpot_1291
    );
  fax4_ins_mode_indicator_o_3_rstpot : LUT4
    generic map(
      INIT => X"D8CC"
    )
    port map (
      I0 => fax4_ins_state_FSM_FFd8_1338,
      I1 => N179,
      I2 => N180,
      I3 => fax4_ins_vertical_mode_cmp_le0000,
      O => fax4_ins_mode_indicator_o_3_rstpot_1295
    );
  fax4_ins_FIFO1_multi_read_ins_read_as_last_operation_and0000111_SW0 : LUT3
    generic map(
      INIT => X"5D"
    )
    port map (
      I0 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt(0),
      I1 => fax4_ins_FIFO1_multi_read_ins_N7,
      I2 => fax4_ins_FIFO1_multi_read_ins_used(0),
      O => N182
    );
  fax4_ins_FIFO1_multi_read_ins_Mcount_used_lut_1_Q : LUT4
    generic map(
      INIT => X"A9AA"
    )
    port map (
      I0 => fax4_ins_FIFO1_multi_read_ins_used(1),
      I1 => N182,
      I2 => fax4_ins_fifo1_wr,
      I3 => fax4_ins_fifo_rd,
      O => fax4_ins_FIFO1_multi_read_ins_Mcount_used_lut(1)
    );
  fax4_ins_FIFO2_multi_read_ins_read_as_last_operation_and0000111_SW0 : LUT3
    generic map(
      INIT => X"31"
    )
    port map (
      I0 => fax4_ins_FIFO2_multi_read_ins_N7,
      I1 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt(0),
      I2 => fax4_ins_FIFO2_multi_read_ins_used(0),
      O => N184
    );
  fax4_ins_FIFO2_multi_read_ins_Mcount_used_lut_1_Q : LUT4
    generic map(
      INIT => X"A6AA"
    )
    port map (
      I0 => fax4_ins_FIFO2_multi_read_ins_used(1),
      I1 => N184,
      I2 => fax4_ins_fifo2_wr,
      I3 => fax4_ins_fifo_rd,
      O => fax4_ins_FIFO2_multi_read_ins_Mcount_used_lut(1)
    );
  fax4_ins_FIFO1_multi_read_ins_Mcount_used_lut_2_Q : LUT4
    generic map(
      INIT => X"A9AA"
    )
    port map (
      I0 => fax4_ins_FIFO1_multi_read_ins_used(2),
      I1 => N182,
      I2 => fax4_ins_fifo1_wr,
      I3 => fax4_ins_fifo_rd,
      O => fax4_ins_FIFO1_multi_read_ins_Mcount_used_lut(2)
    );
  fax4_ins_FIFO2_multi_read_ins_Mcount_used_lut_2_Q : LUT4
    generic map(
      INIT => X"A6AA"
    )
    port map (
      I0 => fax4_ins_FIFO2_multi_read_ins_used(2),
      I1 => N184,
      I2 => fax4_ins_fifo2_wr,
      I3 => fax4_ins_fifo_rd,
      O => fax4_ins_FIFO2_multi_read_ins_Mcount_used_lut(2)
    );
  fax4_ins_FIFO1_multi_read_ins_Mcount_used_lut_3_Q : LUT4
    generic map(
      INIT => X"A9AA"
    )
    port map (
      I0 => fax4_ins_FIFO1_multi_read_ins_used(3),
      I1 => N182,
      I2 => fax4_ins_fifo1_wr,
      I3 => fax4_ins_fifo_rd,
      O => fax4_ins_FIFO1_multi_read_ins_Mcount_used_lut(3)
    );
  fax4_ins_FIFO2_multi_read_ins_Mcount_used_lut_3_Q : LUT4
    generic map(
      INIT => X"A6AA"
    )
    port map (
      I0 => fax4_ins_FIFO2_multi_read_ins_used(3),
      I1 => N184,
      I2 => fax4_ins_fifo2_wr,
      I3 => fax4_ins_fifo_rd,
      O => fax4_ins_FIFO2_multi_read_ins_Mcount_used_lut(3)
    );
  fax4_ins_FIFO1_multi_read_ins_Mcount_used_lut_4_Q : LUT4
    generic map(
      INIT => X"A9AA"
    )
    port map (
      I0 => fax4_ins_FIFO1_multi_read_ins_used(4),
      I1 => N182,
      I2 => fax4_ins_fifo1_wr,
      I3 => fax4_ins_fifo_rd,
      O => fax4_ins_FIFO1_multi_read_ins_Mcount_used_lut(4)
    );
  fax4_ins_FIFO2_multi_read_ins_Mcount_used_lut_4_Q : LUT4
    generic map(
      INIT => X"A6AA"
    )
    port map (
      I0 => fax4_ins_FIFO2_multi_read_ins_used(4),
      I1 => N184,
      I2 => fax4_ins_fifo2_wr,
      I3 => fax4_ins_fifo_rd,
      O => fax4_ins_FIFO2_multi_read_ins_Mcount_used_lut(4)
    );
  fax4_ins_FIFO1_multi_read_ins_Mcount_used_lut_5_Q : LUT4
    generic map(
      INIT => X"A9AA"
    )
    port map (
      I0 => fax4_ins_FIFO1_multi_read_ins_used(5),
      I1 => N182,
      I2 => fax4_ins_fifo1_wr,
      I3 => fax4_ins_fifo_rd,
      O => fax4_ins_FIFO1_multi_read_ins_Mcount_used_lut(5)
    );
  fax4_ins_FIFO2_multi_read_ins_Mcount_used_lut_5_Q : LUT4
    generic map(
      INIT => X"A6AA"
    )
    port map (
      I0 => fax4_ins_FIFO2_multi_read_ins_used(5),
      I1 => N184,
      I2 => fax4_ins_fifo2_wr,
      I3 => fax4_ins_fifo_rd,
      O => fax4_ins_FIFO2_multi_read_ins_Mcount_used_lut(5)
    );
  fax4_ins_FIFO1_multi_read_ins_Mcount_used_lut_6_Q : LUT4
    generic map(
      INIT => X"A9AA"
    )
    port map (
      I0 => fax4_ins_FIFO1_multi_read_ins_used(6),
      I1 => N182,
      I2 => fax4_ins_fifo1_wr,
      I3 => fax4_ins_fifo_rd,
      O => fax4_ins_FIFO1_multi_read_ins_Mcount_used_lut(6)
    );
  fax4_ins_FIFO2_multi_read_ins_Mcount_used_lut_6_Q : LUT4
    generic map(
      INIT => X"A6AA"
    )
    port map (
      I0 => fax4_ins_FIFO2_multi_read_ins_used(6),
      I1 => N184,
      I2 => fax4_ins_fifo2_wr,
      I3 => fax4_ins_fifo_rd,
      O => fax4_ins_FIFO2_multi_read_ins_Mcount_used_lut(6)
    );
  fax4_ins_FIFO1_multi_read_ins_Mcount_used_lut_7_Q : LUT4
    generic map(
      INIT => X"A9AA"
    )
    port map (
      I0 => fax4_ins_FIFO1_multi_read_ins_used(7),
      I1 => N182,
      I2 => fax4_ins_fifo1_wr,
      I3 => fax4_ins_fifo_rd,
      O => fax4_ins_FIFO1_multi_read_ins_Mcount_used_lut(7)
    );
  fax4_ins_FIFO2_multi_read_ins_Mcount_used_lut_7_Q : LUT4
    generic map(
      INIT => X"A6AA"
    )
    port map (
      I0 => fax4_ins_FIFO2_multi_read_ins_used(7),
      I1 => N184,
      I2 => fax4_ins_fifo2_wr,
      I3 => fax4_ins_fifo_rd,
      O => fax4_ins_FIFO2_multi_read_ins_Mcount_used_lut(7)
    );
  fax4_ins_FIFO1_multi_read_ins_Mcount_used_lut_8_Q : LUT4
    generic map(
      INIT => X"A9AA"
    )
    port map (
      I0 => fax4_ins_FIFO1_multi_read_ins_used(8),
      I1 => N182,
      I2 => fax4_ins_fifo1_wr,
      I3 => fax4_ins_fifo_rd,
      O => fax4_ins_FIFO1_multi_read_ins_Mcount_used_lut(8)
    );
  fax4_ins_FIFO2_multi_read_ins_Mcount_used_lut_8_Q : LUT4
    generic map(
      INIT => X"A6AA"
    )
    port map (
      I0 => fax4_ins_FIFO2_multi_read_ins_used(8),
      I1 => N184,
      I2 => fax4_ins_fifo2_wr,
      I3 => fax4_ins_fifo_rd,
      O => fax4_ins_FIFO2_multi_read_ins_Mcount_used_lut(8)
    );
  fax4_ins_FIFO1_multi_read_ins_read_as_last_operation : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => fax4_ins_pclk_not,
      D => fax4_ins_FIFO1_multi_read_ins_read_as_last_operation_rstpot_427,
      Q => fax4_ins_FIFO1_multi_read_ins_read_as_last_operation_426
    );
  fax4_ins_FIFO2_multi_read_ins_read_as_last_operation : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => fax4_ins_pclk_not,
      D => fax4_ins_FIFO2_multi_read_ins_read_as_last_operation_rstpot_669,
      Q => fax4_ins_FIFO2_multi_read_ins_read_as_last_operation_668
    );
  fax4_ins_a1b1_5_1 : LUT4
    generic map(
      INIT => X"EC4C"
    )
    port map (
      I0 => fax4_ins_counter_xy_v2_ins_frame_valid_1206,
      I1 => fax4_ins_a1b1_addsub0001(5),
      I2 => fax4_ins_counter_xy_v2_ins_line_valid_1210,
      I3 => fax4_ins_a1b1_addsub0000(5),
      O => fax4_ins_a1b1(5)
    );
  fax4_ins_a1b1_4_1 : LUT4
    generic map(
      INIT => X"EC4C"
    )
    port map (
      I0 => fax4_ins_counter_xy_v2_ins_frame_valid_1206,
      I1 => fax4_ins_a1b1_addsub0001(4),
      I2 => fax4_ins_counter_xy_v2_ins_line_valid_1210,
      I3 => fax4_ins_a1b1_addsub0000(4),
      O => fax4_ins_a1b1(4)
    );
  fax4_ins_a1b1_3_1 : LUT4
    generic map(
      INIT => X"EC4C"
    )
    port map (
      I0 => fax4_ins_counter_xy_v2_ins_frame_valid_1206,
      I1 => fax4_ins_a1b1_addsub0001(3),
      I2 => fax4_ins_counter_xy_v2_ins_line_valid_1210,
      I3 => fax4_ins_a1b1_addsub0000(3),
      O => fax4_ins_a1b1(3)
    );
  fax4_ins_mode_indicator_o_mux0001_2_28_SW0 : LUT3
    generic map(
      INIT => X"FE"
    )
    port map (
      I0 => fax4_ins_a1b1(2),
      I1 => fax4_ins_a1b1(3),
      I2 => N482,
      O => N218
    );
  fax4_ins_mode_indicator_o_1_rstpot : LUT4
    generic map(
      INIT => X"2733"
    )
    port map (
      I0 => fax4_ins_state_FSM_FFd8_1338,
      I1 => N220,
      I2 => N221,
      I3 => fax4_ins_vertical_mode_cmp_le0000,
      O => fax4_ins_mode_indicator_o_1_rstpot_1289
    );
  fax4_ins_FIFO1_multi_read_ins_read_as_last_operation_rstpot_SW0 : LUT3
    generic map(
      INIT => X"32"
    )
    port map (
      I0 => N487,
      I1 => fax4_ins_fifo1_wr,
      I2 => fax4_ins_FIFO1_multi_read_ins_read_as_last_operation_426,
      O => N223
    );
  fax4_ins_FIFO1_multi_read_ins_read_as_last_operation_rstpot : LUT4
    generic map(
      INIT => X"BBB8"
    )
    port map (
      I0 => fax4_ins_FIFO1_multi_read_ins_read_as_last_operation_426,
      I1 => frame_finished_wire,
      I2 => N223,
      I3 => fax4_ins_FIFO1_multi_read_ins_mem_rd_387,
      O => fax4_ins_FIFO1_multi_read_ins_read_as_last_operation_rstpot_427
    );
  fax4_ins_FIFO2_multi_read_ins_read_as_last_operation_rstpot_SW0 : LUT3
    generic map(
      INIT => X"32"
    )
    port map (
      I0 => N488,
      I1 => fax4_ins_fifo2_wr,
      I2 => fax4_ins_FIFO2_multi_read_ins_read_as_last_operation_668,
      O => N225
    );
  fax4_ins_FIFO2_multi_read_ins_read_as_last_operation_rstpot : LUT4
    generic map(
      INIT => X"BBB8"
    )
    port map (
      I0 => fax4_ins_FIFO2_multi_read_ins_read_as_last_operation_668,
      I1 => frame_finished_wire,
      I2 => N225,
      I3 => fax4_ins_FIFO2_multi_read_ins_mem_rd_628,
      O => fax4_ins_FIFO2_multi_read_ins_read_as_last_operation_rstpot_669
    );
  fax4_ins_fifo_rd36_SW2 : LUT4
    generic map(
      INIT => X"AF8C"
    )
    port map (
      I0 => fax4_ins_FIFO1_multi_read_ins_used(0),
      I1 => fax4_ins_fifo_rd3_1268,
      I2 => fax4_ins_FIFO1_multi_read_ins_N7,
      I3 => N467,
      O => N231
    );
  fax4_ins_fifo_rd36_SW3 : LUT4
    generic map(
      INIT => X"222F"
    )
    port map (
      I0 => fax4_ins_FIFO2_multi_read_ins_N7,
      I1 => fax4_ins_FIFO2_multi_read_ins_used(0),
      I2 => N468,
      I3 => fax4_ins_fifo_rd0_1266,
      O => N233
    );
  fax4_ins_mode_indicator_o_mux0001_2_35_SW2_SW1 : LUT3
    generic map(
      INIT => X"80"
    )
    port map (
      I0 => fax4_ins_a1b1(0),
      I1 => fax4_ins_a1b1(1),
      I2 => N484,
      O => N235
    );
  fax4_ins_mode_indicator_o_0_rstpot : LUT4
    generic map(
      INIT => X"FE02"
    )
    port map (
      I0 => fax4_ins_mode_indicator_o(0),
      I1 => N167,
      I2 => N237,
      I3 => fax4_ins_mode_indicator_o_mux0001(3),
      O => fax4_ins_mode_indicator_o_0_rstpot_1287
    );
  fax4_ins_mode_indicator_o_not00011_SW0 : LUT4
    generic map(
      INIT => X"EC4C"
    )
    port map (
      I0 => fax4_ins_vertical_mode_cmp_le00002169_1364,
      I1 => N239,
      I2 => fax4_ins_vertical_mode_cmp_le0000213_1363,
      I3 => N240,
      O => N237
    );
  fax4_ins_vertical_mode_cmp_le00002199_SW0 : LUT4
    generic map(
      INIT => X"AA2A"
    )
    port map (
      I0 => N142,
      I1 => fax4_ins_a1b1(10),
      I2 => fax4_ins_vertical_mode_addsub0000(10),
      I3 => fax4_ins_state_FSM_FFd8_1338,
      O => N239
    );
  fax4_ins_vertical_mode_cmp_le00002199_SW2 : LUT3
    generic map(
      INIT => X"FD"
    )
    port map (
      I0 => fax4_ins_pix_changed_1319,
      I1 => fax4_ins_state_FSM_FFd8_1338,
      I2 => fax4_ins_mux_a0_0_Q,
      O => N242
    );
  fax4_ins_mux_a0_1_1 : LUT4
    generic map(
      INIT => X"4474"
    )
    port map (
      I0 => N242,
      I1 => fax4_ins_vertical_mode_cmp_le000020_1361,
      I2 => fax4_ins_vertical_mode_cmp_le00002169_1364,
      I3 => N243,
      O => fax4_ins_mux_a0_1_Q
    );
  fax4_ins_vertical_mode_cmp_le00002199_SW4 : LUT4
    generic map(
      INIT => X"F2F0"
    )
    port map (
      I0 => fax4_ins_pix_changed_1319,
      I1 => fax4_ins_state_FSM_FFd8_1338,
      I2 => N144,
      I3 => fax4_ins_vertical_mode_cmp_le000020_1361,
      O => N245
    );
  fax4_ins_vertical_mode_cmp_le00002199_SW6 : LUT4
    generic map(
      INIT => X"FCFA"
    )
    port map (
      I0 => N115,
      I1 => N146,
      I2 => fax4_ins_mux_a0_0_Q,
      I3 => fax4_ins_vertical_mode_cmp_le000020_1361,
      O => N248
    );
  fax4_ins_vertical_mode_cmp_le00002199_SW8 : LUT4
    generic map(
      INIT => X"FEFC"
    )
    port map (
      I0 => N148,
      I1 => fax4_ins_mux_a0_0_Q,
      I2 => N117,
      I3 => fax4_ins_vertical_mode_cmp_le000020_1361,
      O => N251
    );
  fax4_ins_vertical_mode_cmp_le00002199_SW10 : LUT4
    generic map(
      INIT => X"FEFC"
    )
    port map (
      I0 => N148,
      I1 => fax4_ins_mux_a0_0_Q,
      I2 => N119,
      I3 => fax4_ins_vertical_mode_cmp_le000020_1361,
      O => N254
    );
  fax4_ins_vertical_mode_cmp_le00002199_SW12 : LUT4
    generic map(
      INIT => X"FEFC"
    )
    port map (
      I0 => N148,
      I1 => fax4_ins_mux_a0_0_Q,
      I2 => N121,
      I3 => fax4_ins_vertical_mode_cmp_le000020_1361,
      O => N257
    );
  fax4_ins_vertical_mode_cmp_le00002199_SW14 : LUT4
    generic map(
      INIT => X"FEFC"
    )
    port map (
      I0 => N148,
      I1 => fax4_ins_mux_a0_0_Q,
      I2 => N123,
      I3 => fax4_ins_vertical_mode_cmp_le000020_1361,
      O => N260
    );
  fax4_ins_vertical_mode_cmp_le00002199_SW16 : LUT4
    generic map(
      INIT => X"FEFC"
    )
    port map (
      I0 => N148,
      I1 => fax4_ins_mux_a0_0_Q,
      I2 => N125,
      I3 => fax4_ins_vertical_mode_cmp_le000020_1361,
      O => N263
    );
  fax4_ins_vertical_mode_cmp_le00002199_SW18 : LUT4
    generic map(
      INIT => X"FEFC"
    )
    port map (
      I0 => N148,
      I1 => fax4_ins_mux_a0_0_Q,
      I2 => N127,
      I3 => fax4_ins_vertical_mode_cmp_le000020_1361,
      O => N266
    );
  fax4_ins_mux_b1_1_and0000 : LUT4
    generic map(
      INIT => X"0060"
    )
    port map (
      I0 => fax4_ins_fifo_out_prev1_to_white_1239,
      I1 => fax4_ins_a0_to_white_946,
      I2 => N73,
      I3 => fax4_ins_Mcompar_mux_b1_1_cmp_gt0000_cy(9),
      O => fax4_ins_mux_b1(1)
    );
  fax4_ins_b2_mux0004_9_42 : LUT4
    generic map(
      INIT => X"FFEA"
    )
    port map (
      I0 => fax4_ins_b2_mux0004_9_10_1092,
      I1 => fax4_ins_fifo_out2_x(9),
      I2 => fax4_ins_N13,
      I3 => fax4_ins_b2_mux0004_9_36_1093,
      O => fax4_ins_b2_mux0004(9)
    );
  fax4_ins_b2_mux0004_8_39 : LUT4
    generic map(
      INIT => X"FFEA"
    )
    port map (
      I0 => fax4_ins_b2_mux0004_8_10_1089,
      I1 => fax4_ins_fifo_out2_x(8),
      I2 => fax4_ins_N13,
      I3 => fax4_ins_b2_mux0004_8_33_1090,
      O => fax4_ins_b2_mux0004(8)
    );
  fax4_ins_b2_mux0004_7_42 : LUT4
    generic map(
      INIT => X"FFEA"
    )
    port map (
      I0 => fax4_ins_b2_mux0004_7_10_1086,
      I1 => fax4_ins_fifo_out2_x(7),
      I2 => fax4_ins_N13,
      I3 => fax4_ins_b2_mux0004_7_36_1087,
      O => fax4_ins_b2_mux0004(7)
    );
  fax4_ins_b2_mux0004_6_42 : LUT4
    generic map(
      INIT => X"FFEA"
    )
    port map (
      I0 => fax4_ins_b2_mux0004_6_10_1083,
      I1 => fax4_ins_fifo_out2_x(6),
      I2 => fax4_ins_N13,
      I3 => fax4_ins_b2_mux0004_6_36_1084,
      O => fax4_ins_b2_mux0004(6)
    );
  fax4_ins_b2_mux0004_5_42 : LUT4
    generic map(
      INIT => X"FFEA"
    )
    port map (
      I0 => fax4_ins_b2_mux0004_5_10_1080,
      I1 => fax4_ins_fifo_out2_x(5),
      I2 => fax4_ins_N13,
      I3 => fax4_ins_b2_mux0004_5_36_1081,
      O => fax4_ins_b2_mux0004(5)
    );
  fax4_ins_b2_mux0004_4_42 : LUT4
    generic map(
      INIT => X"FFEA"
    )
    port map (
      I0 => fax4_ins_b2_mux0004_4_10_1077,
      I1 => fax4_ins_fifo_out2_x(4),
      I2 => fax4_ins_N13,
      I3 => fax4_ins_b2_mux0004_4_36_1078,
      O => fax4_ins_b2_mux0004(4)
    );
  fax4_ins_b2_mux0004_3_39 : LUT4
    generic map(
      INIT => X"FFEA"
    )
    port map (
      I0 => fax4_ins_b2_mux0004_3_10_1074,
      I1 => fax4_ins_fifo_out2_x(3),
      I2 => fax4_ins_N13,
      I3 => fax4_ins_b2_mux0004_3_33_1075,
      O => fax4_ins_b2_mux0004(3)
    );
  fax4_ins_b2_mux0004_2_39 : LUT4
    generic map(
      INIT => X"FFEA"
    )
    port map (
      I0 => fax4_ins_b2_mux0004_2_10_1071,
      I1 => fax4_ins_fifo_out2_x(2),
      I2 => fax4_ins_N13,
      I3 => fax4_ins_b2_mux0004_2_33_1072,
      O => fax4_ins_b2_mux0004(2)
    );
  fax4_ins_b2_mux0004_1_39 : LUT4
    generic map(
      INIT => X"FFEA"
    )
    port map (
      I0 => fax4_ins_b2_mux0004_1_10_1068,
      I1 => fax4_ins_fifo_out2_x(1),
      I2 => fax4_ins_N13,
      I3 => fax4_ins_b2_mux0004_1_33_1069,
      O => fax4_ins_b2_mux0004(1)
    );
  fax4_ins_b2_mux0004_0_42 : LUT4
    generic map(
      INIT => X"FFEA"
    )
    port map (
      I0 => fax4_ins_b2_mux0004_0_10_1065,
      I1 => fax4_ins_fifo_out2_x(0),
      I2 => fax4_ins_N13,
      I3 => fax4_ins_b2_mux0004_0_36_1066,
      O => fax4_ins_b2_mux0004(0)
    );
  fax4_ins_Mcompar_mux_b1_3_cmp_gt0000_lut_0_Q : LUT4
    generic map(
      INIT => X"A695"
    )
    port map (
      I0 => fax4_ins_a0(0),
      I1 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt(0),
      I2 => fax4_ins_FIFO1_multi_read_ins_data2_o(0),
      I3 => fax4_ins_FIFO2_multi_read_ins_data2_o(0),
      O => fax4_ins_Mcompar_mux_b1_3_cmp_gt0000_lut(0)
    );
  fax4_ins_Mcompar_mux_b1_3_cmp_gt0000_lut_1_Q : LUT4
    generic map(
      INIT => X"A695"
    )
    port map (
      I0 => fax4_ins_a0(1),
      I1 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt(0),
      I2 => fax4_ins_FIFO1_multi_read_ins_data2_o(1),
      I3 => fax4_ins_FIFO2_multi_read_ins_data2_o(1),
      O => fax4_ins_Mcompar_mux_b1_3_cmp_gt0000_lut(1)
    );
  fax4_ins_Mcompar_mux_b1_2_cmp_gt0000_lut_1_Q : LUT4
    generic map(
      INIT => X"E41B"
    )
    port map (
      I0 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt(0),
      I1 => fax4_ins_FIFO2_multi_read_ins_data1_o(1),
      I2 => fax4_ins_FIFO1_multi_read_ins_data1_o(1),
      I3 => fax4_ins_a0(1),
      O => fax4_ins_Mcompar_mux_b1_2_cmp_gt0000_lut(1)
    );
  fax4_ins_Mcompar_mux_b1_3_cmp_gt0000_lut_2_Q : LUT4
    generic map(
      INIT => X"A695"
    )
    port map (
      I0 => fax4_ins_a0(2),
      I1 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt(0),
      I2 => fax4_ins_FIFO1_multi_read_ins_data2_o(2),
      I3 => fax4_ins_FIFO2_multi_read_ins_data2_o(2),
      O => fax4_ins_Mcompar_mux_b1_3_cmp_gt0000_lut(2)
    );
  fax4_ins_Mcompar_mux_b1_2_cmp_gt0000_lut_2_Q : LUT4
    generic map(
      INIT => X"E41B"
    )
    port map (
      I0 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt(0),
      I1 => fax4_ins_FIFO2_multi_read_ins_data1_o(2),
      I2 => fax4_ins_FIFO1_multi_read_ins_data1_o(2),
      I3 => fax4_ins_a0(2),
      O => fax4_ins_Mcompar_mux_b1_2_cmp_gt0000_lut(2)
    );
  fax4_ins_Mcompar_mux_b1_3_cmp_gt0000_lut_3_Q : LUT4
    generic map(
      INIT => X"A695"
    )
    port map (
      I0 => fax4_ins_a0(3),
      I1 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt(0),
      I2 => fax4_ins_FIFO1_multi_read_ins_data2_o(3),
      I3 => fax4_ins_FIFO2_multi_read_ins_data2_o(3),
      O => fax4_ins_Mcompar_mux_b1_3_cmp_gt0000_lut(3)
    );
  fax4_ins_Mcompar_mux_b1_2_cmp_gt0000_lut_3_Q : LUT4
    generic map(
      INIT => X"E41B"
    )
    port map (
      I0 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt(0),
      I1 => fax4_ins_FIFO2_multi_read_ins_data1_o(3),
      I2 => fax4_ins_FIFO1_multi_read_ins_data1_o(3),
      I3 => fax4_ins_a0(3),
      O => fax4_ins_Mcompar_mux_b1_2_cmp_gt0000_lut(3)
    );
  fax4_ins_Mcompar_mux_b1_3_cmp_gt0000_lut_4_Q : LUT4
    generic map(
      INIT => X"A695"
    )
    port map (
      I0 => fax4_ins_a0(4),
      I1 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt(0),
      I2 => fax4_ins_FIFO1_multi_read_ins_data2_o(4),
      I3 => fax4_ins_FIFO2_multi_read_ins_data2_o(4),
      O => fax4_ins_Mcompar_mux_b1_3_cmp_gt0000_lut(4)
    );
  fax4_ins_Mcompar_mux_b1_2_cmp_gt0000_lut_4_Q : LUT4
    generic map(
      INIT => X"E41B"
    )
    port map (
      I0 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt(0),
      I1 => fax4_ins_FIFO2_multi_read_ins_data1_o(4),
      I2 => fax4_ins_FIFO1_multi_read_ins_data1_o(4),
      I3 => fax4_ins_a0(4),
      O => fax4_ins_Mcompar_mux_b1_2_cmp_gt0000_lut(4)
    );
  fax4_ins_Mcompar_mux_b1_3_cmp_gt0000_lut_5_Q : LUT4
    generic map(
      INIT => X"A695"
    )
    port map (
      I0 => fax4_ins_a0(5),
      I1 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt(0),
      I2 => fax4_ins_FIFO1_multi_read_ins_data2_o(5),
      I3 => fax4_ins_FIFO2_multi_read_ins_data2_o(5),
      O => fax4_ins_Mcompar_mux_b1_3_cmp_gt0000_lut(5)
    );
  fax4_ins_Mcompar_mux_b1_2_cmp_gt0000_lut_5_Q : LUT4
    generic map(
      INIT => X"A695"
    )
    port map (
      I0 => fax4_ins_a0(5),
      I1 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt(0),
      I2 => fax4_ins_FIFO1_multi_read_ins_data1_o(5),
      I3 => fax4_ins_FIFO2_multi_read_ins_data1_o(5),
      O => fax4_ins_Mcompar_mux_b1_2_cmp_gt0000_lut(5)
    );
  fax4_ins_Mcompar_mux_b1_3_cmp_gt0000_lut_6_Q : LUT4
    generic map(
      INIT => X"A695"
    )
    port map (
      I0 => fax4_ins_a0(6),
      I1 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt(0),
      I2 => fax4_ins_FIFO1_multi_read_ins_data2_o(6),
      I3 => fax4_ins_FIFO2_multi_read_ins_data2_o(6),
      O => fax4_ins_Mcompar_mux_b1_3_cmp_gt0000_lut(6)
    );
  fax4_ins_Mcompar_mux_b1_2_cmp_gt0000_lut_6_Q : LUT4
    generic map(
      INIT => X"A695"
    )
    port map (
      I0 => fax4_ins_a0(6),
      I1 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt(0),
      I2 => fax4_ins_FIFO1_multi_read_ins_data1_o(6),
      I3 => fax4_ins_FIFO2_multi_read_ins_data1_o(6),
      O => fax4_ins_Mcompar_mux_b1_2_cmp_gt0000_lut(6)
    );
  fax4_ins_Mcompar_mux_b1_3_cmp_gt0000_lut_7_Q : LUT4
    generic map(
      INIT => X"A695"
    )
    port map (
      I0 => fax4_ins_a0(7),
      I1 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt(0),
      I2 => fax4_ins_FIFO1_multi_read_ins_data2_o(7),
      I3 => fax4_ins_FIFO2_multi_read_ins_data2_o(7),
      O => fax4_ins_Mcompar_mux_b1_3_cmp_gt0000_lut(7)
    );
  fax4_ins_Mcompar_mux_b1_2_cmp_gt0000_lut_7_Q : LUT4
    generic map(
      INIT => X"A695"
    )
    port map (
      I0 => fax4_ins_a0(7),
      I1 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt(0),
      I2 => fax4_ins_FIFO1_multi_read_ins_data1_o(7),
      I3 => fax4_ins_FIFO2_multi_read_ins_data1_o(7),
      O => fax4_ins_Mcompar_mux_b1_2_cmp_gt0000_lut(7)
    );
  fax4_ins_Mcompar_mux_b1_3_cmp_gt0000_lut_8_Q : LUT4
    generic map(
      INIT => X"A695"
    )
    port map (
      I0 => fax4_ins_a0(8),
      I1 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt(0),
      I2 => fax4_ins_FIFO1_multi_read_ins_data2_o(8),
      I3 => fax4_ins_FIFO2_multi_read_ins_data2_o(8),
      O => fax4_ins_Mcompar_mux_b1_3_cmp_gt0000_lut(8)
    );
  fax4_ins_Mcompar_mux_b1_2_cmp_gt0000_lut_8_Q : LUT4
    generic map(
      INIT => X"A695"
    )
    port map (
      I0 => fax4_ins_a0(8),
      I1 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt(0),
      I2 => fax4_ins_FIFO1_multi_read_ins_data1_o(8),
      I3 => fax4_ins_FIFO2_multi_read_ins_data1_o(8),
      O => fax4_ins_Mcompar_mux_b1_2_cmp_gt0000_lut(8)
    );
  fax4_ins_Mcompar_mux_b1_3_cmp_gt0000_lut_9_Q : LUT4
    generic map(
      INIT => X"A695"
    )
    port map (
      I0 => fax4_ins_a0(9),
      I1 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt(0),
      I2 => fax4_ins_FIFO1_multi_read_ins_data2_o(9),
      I3 => fax4_ins_FIFO2_multi_read_ins_data2_o(9),
      O => fax4_ins_Mcompar_mux_b1_3_cmp_gt0000_lut(9)
    );
  fax4_ins_Mcompar_mux_b1_2_cmp_gt0000_lut_9_Q : LUT4
    generic map(
      INIT => X"A695"
    )
    port map (
      I0 => fax4_ins_a0(9),
      I1 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt(0),
      I2 => fax4_ins_FIFO1_multi_read_ins_data1_o(9),
      I3 => fax4_ins_FIFO2_multi_read_ins_data1_o(9),
      O => fax4_ins_Mcompar_mux_b1_2_cmp_gt0000_lut(9)
    );
  fax4_ins_vertical_mode_cmp_le0000226_SW0 : LUT4
    generic map(
      INIT => X"DDD5"
    )
    port map (
      I0 => fax4_ins_pix_changed_1319,
      I1 => fax4_ins_a1b1(10),
      I2 => fax4_ins_vertical_mode_addsub0000(6),
      I3 => fax4_ins_vertical_mode_addsub0000(7),
      O => N269
    );
  fax4_ins_Madd_vertical_mode_not0000_10_1 : LUT4
    generic map(
      INIT => X"13B3"
    )
    port map (
      I0 => fax4_ins_counter_xy_v2_ins_line_valid_1210,
      I1 => fax4_ins_a1b1_addsub0001(10),
      I2 => fax4_ins_counter_xy_v2_ins_frame_valid_1206,
      I3 => fax4_ins_a1b1_addsub0000(10),
      O => fax4_ins_Madd_vertical_mode_not0000(10)
    );
  fax4_ins_vertical_mode_cmp_le00002199_SW9 : LUT4
    generic map(
      INIT => X"FEFC"
    )
    port map (
      I0 => N148,
      I1 => fax4_ins_mux_a0_0_Q,
      I2 => N472,
      I3 => N271,
      O => N252
    );
  fax4_ins_vertical_mode_cmp_le00002199_SW11 : LUT4
    generic map(
      INIT => X"FEFC"
    )
    port map (
      I0 => N148,
      I1 => fax4_ins_mux_a0_0_Q,
      I2 => N473,
      I3 => N271,
      O => N255
    );
  fax4_ins_vertical_mode_cmp_le00002199_SW13 : LUT4
    generic map(
      INIT => X"FEFC"
    )
    port map (
      I0 => N148,
      I1 => fax4_ins_mux_a0_0_Q,
      I2 => N474,
      I3 => N271,
      O => N258
    );
  fax4_ins_vertical_mode_cmp_le00002199_SW15 : LUT4
    generic map(
      INIT => X"FEFC"
    )
    port map (
      I0 => N148,
      I1 => fax4_ins_mux_a0_0_Q,
      I2 => N475,
      I3 => N271,
      O => N261
    );
  fax4_ins_vertical_mode_cmp_le00002199_SW17 : LUT4
    generic map(
      INIT => X"FEFC"
    )
    port map (
      I0 => N148,
      I1 => fax4_ins_mux_a0_0_Q,
      I2 => N476,
      I3 => N271,
      O => N264
    );
  fax4_ins_vertical_mode_cmp_le00002199_SW19 : LUT4
    generic map(
      INIT => X"FEFC"
    )
    port map (
      I0 => N148,
      I1 => fax4_ins_mux_a0_0_Q,
      I2 => N477,
      I3 => N271,
      O => N267
    );
  fax4_ins_vertical_mode_cmp_le00002199_SW5 : LUT4
    generic map(
      INIT => X"AEAA"
    )
    port map (
      I0 => N144,
      I1 => fax4_ins_pix_changed_1319,
      I2 => fax4_ins_state_FSM_FFd8_1338,
      I3 => N494,
      O => N246
    );
  fax4_ins_b2_to_white_mux000423_SW0 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt(0),
      I1 => fax4_ins_FIFO2_multi_read_ins_to_white2_o_684,
      I2 => fax4_ins_FIFO1_multi_read_ins_to_white2_o_442,
      O => N285
    );
  fax4_ins_b2_to_white_mux000458 : LUT4
    generic map(
      INIT => X"FFEA"
    )
    port map (
      I0 => fax4_ins_b2_to_white_mux000410_1098,
      I1 => N466,
      I2 => N285,
      I3 => fax4_ins_b2_to_white_mux000452_1099,
      O => fax4_ins_b2_to_white_mux0004
    );
  fax4_ins_FIFO2_multi_read_ins_used_not0003_inv2 : LUT4
    generic map(
      INIT => X"4500"
    )
    port map (
      I0 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt(0),
      I1 => fax4_ins_FIFO2_multi_read_ins_used(0),
      I2 => fax4_ins_FIFO2_multi_read_ins_N7,
      I3 => fax4_ins_fifo_rd,
      O => fax4_ins_FIFO2_multi_read_ins_used_not0003_inv
    );
  fax4_ins_vertical_mode_cmp_le00002199_SW7 : MUXF5
    port map (
      I0 => N287,
      I1 => N288,
      S => fax4_ins_vertical_mode_cmp_le000020_1361,
      O => N249
    );
  fax4_ins_vertical_mode_cmp_le00002199_SW7_F : LUT4
    generic map(
      INIT => X"FCFA"
    )
    port map (
      I0 => N115,
      I1 => N146,
      I2 => fax4_ins_mux_a0_0_Q,
      I3 => fax4_ins_vertical_mode_cmp_le0000226_1365,
      O => N287
    );
  fax4_ins_vertical_mode_cmp_le00002199_SW7_G : LUT2
    generic map(
      INIT => X"E"
    )
    port map (
      I0 => fax4_ins_mux_a0_0_Q,
      I1 => N146,
      O => N288
    );
  fax4_ins_output_valid_o_mux0003361 : LUT4
    generic map(
      INIT => X"AAA2"
    )
    port map (
      I0 => fax4_ins_load_a1_or0000,
      I1 => fax4_ins_state_FSM_N7,
      I2 => fax4_ins_pass_mode,
      I3 => fax4_ins_pix_changed_1319,
      O => fax4_ins_output_valid_o_mux000336
    );
  huffman_ins_v2_hor_code_9_mux00031471 : LUT4
    generic map(
      INIT => X"F3F2"
    )
    port map (
      I0 => huffman_ins_v2_hor_code_9_mux0003114_2041,
      I1 => huffman_ins_v2_horizontal_mode_part_2_2065,
      I2 => huffman_ins_v2_hor_code_9_mux000366,
      I3 => huffman_ins_v2_hor_code_9_mux000398_2049,
      O => huffman_ins_v2_hor_code_9_mux0003147
    );
  fax4_ins_state_FSM_FFd8_In251 : LUT4
    generic map(
      INIT => X"C040"
    )
    port map (
      I0 => fax4_ins_vertical_mode_cmp_le0000,
      I1 => fax4_ins_load_a1_or0001,
      I2 => fax4_ins_load_a1_or0000,
      I3 => fax4_ins_state_FSM_FFd8_1338,
      O => fax4_ins_state_FSM_FFd8_In25
    );
  huffman_ins_v2_hor_code_1_mux000354 : LUT4
    generic map(
      INIT => X"AEAA"
    )
    port map (
      I0 => huffman_ins_v2_hor_code_1_mux000347_1932,
      I1 => huffman_ins_v2_Madd_hor_code_width_addsub0000_cy(0),
      I2 => huffman_ins_v2_N59,
      I3 => huffman_ins_v2_N100,
      O => huffman_ins_v2_hor_code_1_mux000354_1933
    );
  huffman_ins_v2_hor_code_15_mux000326 : LUT4
    generic map(
      INIT => X"EAAA"
    )
    port map (
      I0 => huffman_ins_v2_hor_code_15_mux000321,
      I1 => huffman_ins_v2_N65,
      I2 => huffman_ins_v2_horizontal_mode_part_2_2065,
      I3 => huffman_ins_v2_hor_code(15),
      O => huffman_ins_v2_hor_code_15_mux000326_1887
    );
  huffman_ins_v2_hor_code_5_mux000327 : LUT4
    generic map(
      INIT => X"F888"
    )
    port map (
      I0 => huffman_ins_v2_hor_code_13_cmp_eq0000,
      I1 => huffman_ins_v2_N100,
      I2 => huffman_ins_v2_hor_code(5),
      I3 => huffman_ins_v2_hor_code_5_mux000315_2007,
      O => huffman_ins_v2_hor_code_5_mux000327_2008
    );
  huffman_ins_v2_hor_code_2_mux000385 : LUT4
    generic map(
      INIT => X"FFEA"
    )
    port map (
      I0 => huffman_ins_v2_hor_code_2_mux000335_1987,
      I1 => huffman_ins_v2_N100,
      I2 => huffman_ins_v2_N232,
      I3 => huffman_ins_v2_hor_code_2_mux000379_1988,
      O => huffman_ins_v2_hor_code_2_mux000385_1989
    );
  fax4_ins_state_FSM_FFd5_In14 : LUT4
    generic map(
      INIT => X"0C08"
    )
    port map (
      I0 => fax4_ins_state_FSM_FFd5_1333,
      I1 => fax4_ins_state_FSM_N7,
      I2 => fax4_ins_pix_changed_1319,
      I3 => fax4_ins_state_FSM_FFd5_In5_1335,
      O => fax4_ins_state_FSM_FFd5_In
    );
  huffman_ins_v2_hor_code_22_mux0003135 : LUT4
    generic map(
      INIT => X"A820"
    )
    port map (
      I0 => huffman_ins_v2_hor_code(22),
      I1 => huffman_ins_v2_horizontal_mode_part_2_2065,
      I2 => huffman_ins_v2_N3,
      I3 => huffman_ins_v2_hor_code_22_mux0003112_1959,
      O => huffman_ins_v2_hor_code_22_mux0003135_1960
    );
  fax4_ins_state_updated_mux000854 : LUT4
    generic map(
      INIT => X"FFA8"
    )
    port map (
      I0 => fax4_ins_state_FSM_FFd8_1338,
      I1 => fax4_ins_EOL,
      I2 => fax4_ins_pix_changed_1319,
      I3 => fax4_ins_state_updated_mux000840_1347,
      O => fax4_ins_state_updated_mux000854_1348
    );
  huffman_ins_v2_hor_code_14_mux0003126 : LUT4
    generic map(
      INIT => X"1000"
    )
    port map (
      I0 => huffman_ins_v2_code_black_width(4),
      I1 => huffman_ins_v2_N203,
      I2 => huffman_ins_v2_hor_code_14_mux0003117_1865,
      I3 => huffman_ins_v2_code_black_width(1),
      O => huffman_ins_v2_hor_code_14_mux0003126_1866
    );
  fax4_ins_FIFO2_multi_read_ins_write_pos_cmp_eq000023 : LUT4
    generic map(
      INIT => X"2000"
    )
    port map (
      I0 => fax4_ins_FIFO2_multi_read_ins_write_pos(9),
      I1 => fax4_ins_FIFO2_multi_read_ins_write_pos(8),
      I2 => fax4_ins_FIFO2_multi_read_ins_write_pos_cmp_eq00007_715,
      I3 => fax4_ins_FIFO2_multi_read_ins_write_pos_cmp_eq000015_714,
      O => fax4_ins_FIFO2_multi_read_ins_write_pos_cmp_eq0000
    );
  fax4_ins_FIFO2_multi_read_ins_read_pos_cmp_eq000023 : LUT4
    generic map(
      INIT => X"2000"
    )
    port map (
      I0 => fax4_ins_FIFO2_multi_read_ins_read_pos(9),
      I1 => fax4_ins_FIFO2_multi_read_ins_read_pos(8),
      I2 => fax4_ins_FIFO2_multi_read_ins_read_pos_cmp_eq00007_682,
      I3 => fax4_ins_FIFO2_multi_read_ins_read_pos_cmp_eq000015_681,
      O => fax4_ins_FIFO2_multi_read_ins_read_pos_cmp_eq0000
    );
  fax4_ins_FIFO1_multi_read_ins_write_pos_cmp_eq000023 : LUT4
    generic map(
      INIT => X"2000"
    )
    port map (
      I0 => fax4_ins_FIFO1_multi_read_ins_write_pos(9),
      I1 => fax4_ins_FIFO1_multi_read_ins_write_pos(8),
      I2 => fax4_ins_FIFO1_multi_read_ins_write_pos_cmp_eq00007_472,
      I3 => fax4_ins_FIFO1_multi_read_ins_write_pos_cmp_eq000015_471,
      O => fax4_ins_FIFO1_multi_read_ins_write_pos_cmp_eq0000
    );
  fax4_ins_FIFO1_multi_read_ins_read_pos_cmp_eq000023 : LUT4
    generic map(
      INIT => X"2000"
    )
    port map (
      I0 => fax4_ins_FIFO1_multi_read_ins_read_pos(9),
      I1 => fax4_ins_FIFO1_multi_read_ins_read_pos(8),
      I2 => fax4_ins_FIFO1_multi_read_ins_read_pos_cmp_eq00007_440,
      I3 => fax4_ins_FIFO1_multi_read_ins_read_pos_cmp_eq000015_439,
      O => fax4_ins_FIFO1_multi_read_ins_read_pos_cmp_eq0000
    );
  fax4_ins_mode_indicator_o_mux0001_3_41_SW1 : LUT4
    generic map(
      INIT => X"F3F1"
    )
    port map (
      I0 => fax4_ins_EOL_prev_230,
      I1 => fax4_ins_load_a1_or0001,
      I2 => fax4_ins_state_FSM_FFd8_1338,
      I3 => fax4_ins_EOL_prev_prev_231,
      O => N160
    );
  huffman_ins_v2_hor_code_16_mux0003138 : LUT4
    generic map(
      INIT => X"EAAA"
    )
    port map (
      I0 => huffman_ins_v2_hor_code_16_mux0003136_1898,
      I1 => huffman_ins_v2_hor_code_16_mux0003117_1897,
      I2 => huffman_ins_v2_code_black_width(4),
      I3 => huffman_ins_v2_code_black(16),
      O => huffman_ins_v2_hor_code_16_mux0003138_1899
    );
  huffman_ins_v2_hor_code_18_mux000381 : LUT4
    generic map(
      INIT => X"0133"
    )
    port map (
      I0 => N305,
      I1 => huffman_ins_v2_horizontal_mode_part_2_2065,
      I2 => huffman_ins_v2_N246,
      I3 => huffman_ins_v2_Madd_hor_code_width_addsub0000_lut(4),
      O => huffman_ins_v2_hor_code_18_mux000381_1923
    );
  huffman_ins_v2_code_white_13_mux00006_SW0 : LUT4
    generic map(
      INIT => X"F888"
    )
    port map (
      I0 => huffman_ins_v2_code_table_ins_makeup_white(8),
      I1 => huffman_ins_v2_code_white_8_cmp_eq0001,
      I2 => huffman_ins_v2_code_white(13),
      I3 => huffman_ins_v2_code_white_8_or0000,
      O => N315
    );
  huffman_ins_v2_code_white_13_mux00006 : LUT3
    generic map(
      INIT => X"EA"
    )
    port map (
      I0 => N315,
      I1 => huffman_ins_v2_code_table_ins_makeup_white(5),
      I2 => huffman_ins_v2_code_white_8_cmp_eq0004,
      O => huffman_ins_v2_code_white_13_mux00006_1751
    );
  fax4_ins_state_FSM_FFd6_In_SW2 : LUT4
    generic map(
      INIT => X"F7FF"
    )
    port map (
      I0 => fax4_ins_vertical_mode_cmp_le0000,
      I1 => fax4_ins_load_a1_or0000,
      I2 => fax4_ins_state_FSM_FFd8_1338,
      I3 => fax4_ins_pix_changed_1319,
      O => N317
    );
  fax4_ins_state_FSM_FFd6_In : LUT4
    generic map(
      INIT => X"22A2"
    )
    port map (
      I0 => fax4_ins_state_FSM_N7,
      I1 => N317,
      I2 => fax4_ins_state_FSM_FFd6_1336,
      I3 => fax4_ins_N53,
      O => fax4_ins_state_FSM_FFd6_In_1337
    );
  huffman_ins_v2_code_black_6_mux0000250_SW0 : LUT2
    generic map(
      INIT => X"E"
    )
    port map (
      I0 => huffman_ins_v2_codetab_ter_black_width(1),
      I1 => huffman_ins_v2_codetab_ter_black_width(0),
      O => N319
    );
  huffman_ins_v2_hor_code_width_mux0001_4_Q : LUT4
    generic map(
      INIT => X"EB41"
    )
    port map (
      I0 => huffman_ins_v2_horizontal_mode_part_2_2065,
      I1 => huffman_ins_v2_Madd_hor_code_width_addsub0000_lut(4),
      I2 => N305,
      I3 => huffman_ins_v2_mux_code_black_width(4),
      O => huffman_ins_v2_hor_code_width_mux0001(4)
    );
  fax4_ins_state_updated_mux000840_SW0 : LUT4
    generic map(
      INIT => X"2232"
    )
    port map (
      I0 => fax4_ins_state_FSM_FFd11_1325,
      I1 => fax4_ins_counter_xy_v2_ins_frame_valid_1206,
      I2 => fax4_ins_state_FSM_FFd10_1323,
      I3 => fax4_ins_EOF_prev_228,
      O => N333
    );
  fax4_ins_state_updated_mux000840 : LUT4
    generic map(
      INIT => X"FF04"
    )
    port map (
      I0 => fax4_ins_state_FSM_FFd2_1327,
      I1 => fax4_ins_state_updated_mux000824_1346,
      I2 => fax4_ins_state_FSM_FFd6_1336,
      I3 => N333,
      O => fax4_ins_state_updated_mux000840_1347
    );
  huffman_ins_v2_hor_code_19_mux000380 : LUT4
    generic map(
      INIT => X"EAAA"
    )
    port map (
      I0 => huffman_ins_v2_hor_code_19_mux00036_1927,
      I1 => huffman_ins_v2_code_black(19),
      I2 => huffman_ins_v2_code_black_width(4),
      I3 => N337,
      O => huffman_ins_v2_hor_code_19_mux000380_1928
    );
  huffman_ins_v2_hor_code_24_mux000316 : LUT4
    generic map(
      INIT => X"EAAA"
    )
    port map (
      I0 => huffman_ins_v2_hor_code_24_mux000312_1973,
      I1 => huffman_ins_v2_N228,
      I2 => huffman_ins_v2_mux_code_black_width(0),
      I3 => huffman_ins_v2_code_black(24),
      O => huffman_ins_v2_hor_code_24_mux000316_1974
    );
  huffman_ins_v2_code_black_20_mux0000166_SW0 : LUT4
    generic map(
      INIT => X"ABA8"
    )
    port map (
      I0 => huffman_ins_v2_code_black(20),
      I1 => huffman_ins_v2_codetab_ter_black_width(0),
      I2 => huffman_ins_v2_codetab_ter_black_width(1),
      I3 => huffman_ins_v2_code_table_ins_makeup_black_8_Q,
      O => N339
    );
  huffman_ins_v2_code_black_20_mux0000166 : LUT4
    generic map(
      INIT => X"A820"
    )
    port map (
      I0 => huffman_ins_v2_codetab_ter_black_width(3),
      I1 => huffman_ins_v2_codetab_ter_black_width(2),
      I2 => huffman_ins_v2_code_table_ins_makeup_black_8_Q,
      I3 => N339,
      O => huffman_ins_v2_code_black_20_mux0000166_1598
    );
  fax4_ins_FIFO2_multi_read_ins_mux1_valid1 : LUT4
    generic map(
      INIT => X"AEAA"
    )
    port map (
      I0 => fax4_ins_FIFO2_multi_read_ins_valid2_o_699,
      I1 => fax4_ins_FIFO2_multi_read_ins_N7,
      I2 => fax4_ins_FIFO2_multi_read_ins_used(0),
      I3 => fax4_ins_fifo2_wr,
      O => fax4_ins_FIFO2_multi_read_ins_mux1_valid
    );
  fax4_ins_FIFO1_multi_read_ins_mux1_valid1 : LUT4
    generic map(
      INIT => X"AEAA"
    )
    port map (
      I0 => fax4_ins_FIFO1_multi_read_ins_valid2_o_457,
      I1 => fax4_ins_FIFO1_multi_read_ins_N7,
      I2 => fax4_ins_FIFO1_multi_read_ins_used(0),
      I3 => fax4_ins_fifo1_wr,
      O => fax4_ins_FIFO1_multi_read_ins_mux1_valid
    );
  huffman_ins_v2_hor_code_6_mux000361 : LUT4
    generic map(
      INIT => X"AA02"
    )
    port map (
      I0 => huffman_ins_v2_N107,
      I1 => huffman_ins_v2_mux_code_black_width(4),
      I2 => huffman_ins_v2_N67,
      I3 => huffman_ins_v2_N48,
      O => huffman_ins_v2_hor_code_6_mux000361_2018
    );
  huffman_ins_v2_hor_code_11_mux000374 : LUT4
    generic map(
      INIT => X"8A02"
    )
    port map (
      I0 => huffman_ins_v2_hor_code_11_mux000373_1835,
      I1 => huffman_ins_v2_Madd_hor_code_width_addsub0000_lut(4),
      I2 => huffman_ins_v2_N98,
      I3 => huffman_ins_v2_N14,
      O => huffman_ins_v2_hor_code_11_mux000374_1836
    );
  huffman_ins_v2_hor_code_17_mux000316 : LUT4
    generic map(
      INIT => X"1400"
    )
    port map (
      I0 => huffman_ins_v2_a0_value_2_1510,
      I1 => huffman_ins_v2_code_black_width(3),
      I2 => huffman_ins_v2_N59,
      I3 => huffman_ins_v2_N102,
      O => huffman_ins_v2_hor_code_17_mux000316_1907
    );
  fax4_ins_FIFO2_multi_read_ins_mux2_valid1 : LUT4
    generic map(
      INIT => X"EAAA"
    )
    port map (
      I0 => fax4_ins_FIFO2_multi_read_ins_valid3_o_700,
      I1 => fax4_ins_FIFO2_multi_read_ins_used(0),
      I2 => fax4_ins_fifo2_wr,
      I3 => fax4_ins_FIFO2_multi_read_ins_N7,
      O => fax4_ins_FIFO2_multi_read_ins_mux2_valid
    );
  fax4_ins_FIFO1_multi_read_ins_mux2_valid1 : LUT4
    generic map(
      INIT => X"EAAA"
    )
    port map (
      I0 => fax4_ins_FIFO1_multi_read_ins_valid3_o_458,
      I1 => fax4_ins_FIFO1_multi_read_ins_used(0),
      I2 => fax4_ins_fifo1_wr,
      I3 => fax4_ins_FIFO1_multi_read_ins_N7,
      O => fax4_ins_FIFO1_multi_read_ins_mux2_valid
    );
  huffman_ins_v2_hor_code_5_mux00037 : LUT4
    generic map(
      INIT => X"1000"
    )
    port map (
      I0 => huffman_ins_v2_Madd_hor_code_width_addsub0000_lut(3),
      I1 => huffman_ins_v2_Madd_hor_code_width_addsub0000_lut(2),
      I2 => huffman_ins_v2_N70,
      I3 => huffman_ins_v2_N109,
      O => huffman_ins_v2_hor_code_5_mux00037_2010
    );
  fax4_ins_FIFO1_multi_read_ins_read_as_last_operation_and0000111_SW6 : LUT4
    generic map(
      INIT => X"FFFE"
    )
    port map (
      I0 => fax4_ins_FIFO1_multi_read_ins_used(2),
      I1 => fax4_ins_FIFO1_multi_read_ins_used(1),
      I2 => fax4_ins_FIFO1_multi_read_ins_N4,
      I3 => fax4_ins_FIFO1_multi_read_ins_used(0),
      O => N208
    );
  huffman_ins_v2_hor_code_0_mux000311 : LUT4
    generic map(
      INIT => X"72FA"
    )
    port map (
      I0 => huffman_ins_v2_mux_code_black_width(4),
      I1 => huffman_ins_v2_mux_code_black_width(3),
      I2 => huffman_ins_v2_N89,
      I3 => huffman_ins_v2_N99,
      O => huffman_ins_v2_N16
    );
  huffman_ins_v2_hor_code_17_mux000319 : LUT4
    generic map(
      INIT => X"2800"
    )
    port map (
      I0 => huffman_ins_v2_N107,
      I1 => huffman_ins_v2_mux_code_black_width(3),
      I2 => huffman_ins_v2_N99,
      I3 => huffman_ins_v2_code_black_width(4),
      O => huffman_ins_v2_hor_code_17_mux000319_1908
    );
  huffman_ins_v2_hor_code_21_mux000376 : LUT4
    generic map(
      INIT => X"1000"
    )
    port map (
      I0 => huffman_ins_v2_mux_code_white_width(1),
      I1 => huffman_ins_v2_Madd_hor_code_width_addsub0000_lut(3),
      I2 => huffman_ins_v2_N102,
      I3 => huffman_ins_v2_N248,
      O => huffman_ins_v2_hor_code_21_mux000376_1955
    );
  huffman_ins_v2_code_white_6_mux000021 : LUT4
    generic map(
      INIT => X"AA80"
    )
    port map (
      I0 => huffman_ins_v2_ter_white_code(6),
      I1 => huffman_ins_v2_codetab_ter_white_width(0),
      I2 => huffman_ins_v2_N239,
      I3 => huffman_ins_v2_code_white_8_cmp_eq0004,
      O => huffman_ins_v2_code_white_6_mux000021_1777
    );
  fax4_ins_fifo2_wr1 : LUT4
    generic map(
      INIT => X"8000"
    )
    port map (
      I0 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt(0),
      I1 => fax4_ins_pix_changed_1319,
      I2 => fax4_ins_counter_xy_v2_ins_frame_valid_1206,
      I3 => fax4_ins_counter_xy_v2_ins_line_valid_1210,
      O => fax4_ins_fifo2_wr
    );
  fax4_ins_state_FSM_FFd9_In11 : LUT3
    generic map(
      INIT => X"08"
    )
    port map (
      I0 => fax4_ins_load_a1_or0000,
      I1 => fax4_ins_vertical_mode_cmp_le0000,
      I2 => fax4_ins_state_FSM_FFd8_1338,
      O => fax4_ins_state_FSM_FFd9_In1
    );
  huffman_ins_v2_hor_code_12_mux000351 : LUT4
    generic map(
      INIT => X"7A2A"
    )
    port map (
      I0 => huffman_ins_v2_mux_code_black_width(4),
      I1 => huffman_ins_v2_N99,
      I2 => huffman_ins_v2_mux_code_black_width(3),
      I3 => huffman_ins_v2_N251,
      O => huffman_ins_v2_N60
    );
  huffman_ins_v2_hor_code_17_mux000371 : LUT4
    generic map(
      INIT => X"FF8D"
    )
    port map (
      I0 => huffman_ins_v2_mux_code_black_width(3),
      I1 => huffman_ins_v2_N251,
      I2 => huffman_ins_v2_N99,
      I3 => N12,
      O => huffman_ins_v2_hor_code_17_mux000371_1911
    );
  huffman_ins_v2_hor_code_7_mux000368 : LUT4
    generic map(
      INIT => X"1000"
    )
    port map (
      I0 => huffman_ins_v2_Madd_hor_code_width_addsub0000_lut(3),
      I1 => huffman_ins_v2_N70,
      I2 => huffman_ins_v2_Madd_hor_code_width_addsub0000_lut(2),
      I3 => huffman_ins_v2_N109,
      O => huffman_ins_v2_hor_code_7_mux000368_2026
    );
  huffman_ins_v2_code_white_15_mux00001 : LUT3
    generic map(
      INIT => X"80"
    )
    port map (
      I0 => huffman_ins_v2_codetab_ter_white_width(0),
      I1 => huffman_ins_v2_N239,
      I2 => huffman_ins_v2_code_table_ins_makeup_white(8),
      O => huffman_ins_v2_code_white_15_mux00001_1756
    );
  huffman_ins_v2_hor_code_25_mux00030 : LUT4
    generic map(
      INIT => X"2000"
    )
    port map (
      I0 => huffman_ins_v2_Madd_hor_code_width_addsub0000_lut(3),
      I1 => huffman_ins_v2_N59,
      I2 => huffman_ins_v2_N102,
      I3 => huffman_ins_v2_Madd_hor_code_width_addsub0000_cy(0),
      O => huffman_ins_v2_hor_code_25_mux00030_1979
    );
  fax4_ins_mode_indicator_o_3_rstpot_SW1 : LUT4
    generic map(
      INIT => X"0C08"
    )
    port map (
      I0 => fax4_ins_pass_mode,
      I1 => fax4_ins_state_FSM_N7,
      I2 => fax4_ins_pix_changed_1319,
      I3 => fax4_ins_mode_indicator_o(3),
      O => N180
    );
  fax4_ins_load_a2_or00001 : LUT4
    generic map(
      INIT => X"F444"
    )
    port map (
      I0 => fax4_ins_EOL_prev_230,
      I1 => fax4_ins_EOL,
      I2 => fax4_ins_pix_changed_1319,
      I3 => fax4_ins_state_FSM_FFd8_1338,
      O => fax4_ins_load_a2
    );
  huffman_ins_v2_Madd_code_white_width_add0000_cy_1_11 : LUT4
    generic map(
      INIT => X"EA80"
    )
    port map (
      I0 => huffman_ins_v2_code_table_ins_makeup_white(10),
      I1 => huffman_ins_v2_code_table_ins_makeup_white(9),
      I2 => huffman_ins_v2_codetab_ter_white_width(0),
      I3 => huffman_ins_v2_codetab_ter_white_width(1),
      O => huffman_ins_v2_Madd_code_white_width_add0000_cy_1_Q
    );
  huffman_ins_v2_Madd_code_black_width_add0000_cy_1_11 : LUT4
    generic map(
      INIT => X"EA80"
    )
    port map (
      I0 => huffman_ins_v2_code_table_ins_makeup_black_14_Q,
      I1 => huffman_ins_v2_code_table_ins_makeup_black_13_Q,
      I2 => huffman_ins_v2_codetab_ter_black_width(0),
      I3 => huffman_ins_v2_codetab_ter_black_width(1),
      O => huffman_ins_v2_Madd_code_black_width_add0000_cy_1_Q
    );
  huffman_ins_v2_hor_code_12_mux0003175 : LUT4
    generic map(
      INIT => X"0103"
    )
    port map (
      I0 => huffman_ins_v2_N59,
      I1 => huffman_ins_v2_Madd_hor_code_width_addsub0000_lut(4),
      I2 => huffman_ins_v2_horizontal_mode_part_2_2065,
      I3 => huffman_ins_v2_Madd_hor_code_width_addsub0000_lut(3),
      O => huffman_ins_v2_hor_code_12_mux0003175_1843
    );
  huffman_ins_v2_hor_code_20_mux000315 : LUT4
    generic map(
      INIT => X"9993"
    )
    port map (
      I0 => huffman_ins_v2_mux_code_black_width(2),
      I1 => huffman_ins_v2_mux_code_black_width(3),
      I2 => huffman_ins_v2_mux_code_black_width(0),
      I3 => huffman_ins_v2_mux_code_black_width(1),
      O => huffman_ins_v2_hor_code_20_mux000315_1942
    );
  huffman_ins_v2_hor_code_21_mux000341 : LUT3
    generic map(
      INIT => X"80"
    )
    port map (
      I0 => huffman_ins_v2_a0_value_2_1510,
      I1 => huffman_ins_v2_code_black_width(4),
      I2 => huffman_ins_v2_horizontal_mode_part_2_2065,
      O => huffman_ins_v2_N95
    );
  huffman_ins_v2_Madd_code_white_width_add0000_xor_1_11 : LUT4
    generic map(
      INIT => X"9666"
    )
    port map (
      I0 => huffman_ins_v2_code_table_ins_makeup_white(10),
      I1 => huffman_ins_v2_codetab_ter_white_width(1),
      I2 => huffman_ins_v2_code_table_ins_makeup_white(9),
      I3 => huffman_ins_v2_codetab_ter_white_width(0),
      O => huffman_ins_v2_code_white_width_add0000(1)
    );
  huffman_ins_v2_Madd_code_black_width_add0000_xor_1_11 : LUT4
    generic map(
      INIT => X"9666"
    )
    port map (
      I0 => huffman_ins_v2_code_table_ins_makeup_black_14_Q,
      I1 => huffman_ins_v2_codetab_ter_black_width(1),
      I2 => huffman_ins_v2_code_table_ins_makeup_black_13_Q,
      I3 => huffman_ins_v2_codetab_ter_black_width(0),
      O => huffman_ins_v2_code_black_width_add0000(1)
    );
  huffman_ins_v2_hor_code_18_mux0003199 : LUT4
    generic map(
      INIT => X"5562"
    )
    port map (
      I0 => huffman_ins_v2_Madd_hor_code_width_addsub0000_lut(3),
      I1 => huffman_ins_v2_mux_code_white_width(1),
      I2 => huffman_ins_v2_Madd_hor_code_width_addsub0000_cy(0),
      I3 => huffman_ins_v2_Madd_hor_code_width_addsub0000_lut(2),
      O => huffman_ins_v2_hor_code_18_mux0003199_1919
    );
  fax4_ins_FIFO1_multi_read_ins_mux3_and0000_SW1 : LUT4
    generic map(
      INIT => X"FDFF"
    )
    port map (
      I0 => fax4_ins_FIFO1_multi_read_ins_used(1),
      I1 => fax4_ins_FIFO1_multi_read_ins_used(2),
      I2 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt(0),
      I3 => fax4_ins_pix_changed_1319,
      O => N341
    );
  huffman_ins_v2_code_white_13_mux000015 : LUT4
    generic map(
      INIT => X"A820"
    )
    port map (
      I0 => huffman_ins_v2_N239,
      I1 => huffman_ins_v2_codetab_ter_white_width(0),
      I2 => huffman_ins_v2_code_table_ins_makeup_white(7),
      I3 => huffman_ins_v2_code_table_ins_makeup_white(6),
      O => huffman_ins_v2_code_white_13_mux000015_1750
    );
  huffman_ins_v2_code_white_9_mux000021 : LUT4
    generic map(
      INIT => X"A820"
    )
    port map (
      I0 => huffman_ins_v2_N239,
      I1 => huffman_ins_v2_codetab_ter_white_width(0),
      I2 => huffman_ins_v2_code_table_ins_makeup_white(3),
      I3 => huffman_ins_v2_code_table_ins_makeup_white(2),
      O => huffman_ins_v2_code_white_9_mux000021_1795
    );
  huffman_ins_v2_code_white_8_mux000021 : LUT4
    generic map(
      INIT => X"A820"
    )
    port map (
      I0 => huffman_ins_v2_N239,
      I1 => huffman_ins_v2_codetab_ter_white_width(0),
      I2 => huffman_ins_v2_code_table_ins_makeup_white(2),
      I3 => huffman_ins_v2_code_table_ins_makeup_white(1),
      O => huffman_ins_v2_code_white_8_mux000021_1789
    );
  huffman_ins_v2_code_white_7_mux000021 : LUT4
    generic map(
      INIT => X"A820"
    )
    port map (
      I0 => huffman_ins_v2_N239,
      I1 => huffman_ins_v2_codetab_ter_white_width(0),
      I2 => huffman_ins_v2_code_table_ins_makeup_white(1),
      I3 => huffman_ins_v2_code_table_ins_makeup_white(0),
      O => huffman_ins_v2_code_white_7_mux000021_1781
    );
  huffman_ins_v2_code_white_12_mux000021 : LUT4
    generic map(
      INIT => X"A820"
    )
    port map (
      I0 => huffman_ins_v2_N239,
      I1 => huffman_ins_v2_codetab_ter_white_width(0),
      I2 => huffman_ins_v2_code_table_ins_makeup_white(6),
      I3 => huffman_ins_v2_code_table_ins_makeup_white(5),
      O => huffman_ins_v2_code_white_12_mux000021_1746
    );
  huffman_ins_v2_code_white_11_mux000021 : LUT4
    generic map(
      INIT => X"A820"
    )
    port map (
      I0 => huffman_ins_v2_N239,
      I1 => huffman_ins_v2_codetab_ter_white_width(0),
      I2 => huffman_ins_v2_code_table_ins_makeup_white(5),
      I3 => huffman_ins_v2_code_table_ins_makeup_white(4),
      O => huffman_ins_v2_code_white_11_mux000021_1741
    );
  huffman_ins_v2_code_white_10_mux000021 : LUT4
    generic map(
      INIT => X"A820"
    )
    port map (
      I0 => huffman_ins_v2_N239,
      I1 => huffman_ins_v2_codetab_ter_white_width(0),
      I2 => huffman_ins_v2_code_table_ins_makeup_white(4),
      I3 => huffman_ins_v2_code_table_ins_makeup_white(3),
      O => huffman_ins_v2_code_white_10_mux000021_1736
    );
  huffman_ins_v2_hor_code_14_mux0003117 : LUT4
    generic map(
      INIT => X"9011"
    )
    port map (
      I0 => huffman_ins_v2_a0_value_2_1510,
      I1 => huffman_ins_v2_horizontal_mode_part_2_2065,
      I2 => huffman_ins_v2_code_black(14),
      I3 => huffman_ins_v2_code_black_width(0),
      O => huffman_ins_v2_hor_code_14_mux0003117_1865
    );
  huffman_ins_v2_hor_code_14_mux0003203 : LUT4
    generic map(
      INIT => X"4602"
    )
    port map (
      I0 => huffman_ins_v2_horizontal_mode_part_2_2065,
      I1 => huffman_ins_v2_a0_value_2_1510,
      I2 => huffman_ins_v2_code_white_width(1),
      I3 => huffman_ins_v2_code_white_width(4),
      O => huffman_ins_v2_hor_code_14_mux0003203_1871
    );
  huffman_ins_v2_hor_code_14_mux0003256 : LUT4
    generic map(
      INIT => X"1908"
    )
    port map (
      I0 => huffman_ins_v2_a0_value_2_1510,
      I1 => huffman_ins_v2_horizontal_mode_part_2_2065,
      I2 => huffman_ins_v2_code_black_width(1),
      I3 => huffman_ins_v2_code_black_width(4),
      O => huffman_ins_v2_hor_code_14_mux0003256_1874
    );
  huffman_ins_v2_hor_code_14_mux000371 : LUT4
    generic map(
      INIT => X"6022"
    )
    port map (
      I0 => huffman_ins_v2_a0_value_2_1510,
      I1 => huffman_ins_v2_horizontal_mode_part_2_2065,
      I2 => huffman_ins_v2_code_white(14),
      I3 => huffman_ins_v2_code_white_width(0),
      O => huffman_ins_v2_hor_code_14_mux000371_1880
    );
  huffman_ins_v2_hor_code_13_mux000386 : LUT4
    generic map(
      INIT => X"A820"
    )
    port map (
      I0 => huffman_ins_v2_horizontal_mode_part_2_2065,
      I1 => huffman_ins_v2_a0_value_2_1510,
      I2 => huffman_ins_v2_code_white(13),
      I3 => huffman_ins_v2_code_black(13),
      O => huffman_ins_v2_hor_code_13_mux000386_1859
    );
  huffman_ins_v2_hor_code_width_mux0001_0_1 : LUT4
    generic map(
      INIT => X"A3C5"
    )
    port map (
      I0 => huffman_ins_v2_code_black_width(0),
      I1 => huffman_ins_v2_code_white_width(0),
      I2 => huffman_ins_v2_horizontal_mode_part_2_2065,
      I3 => huffman_ins_v2_a0_value_2_1510,
      O => huffman_ins_v2_hor_code_width_mux0001(0)
    );
  fax4_ins_FIFO1_multi_read_ins_wr_SW1 : LUT4
    generic map(
      INIT => X"FFEA"
    )
    port map (
      I0 => fax4_ins_FIFO1_multi_read_ins_N4,
      I1 => fax4_ins_FIFO1_multi_read_ins_used(0),
      I2 => fax4_ins_FIFO1_multi_read_ins_used(1),
      I3 => fax4_ins_FIFO1_multi_read_ins_used(2),
      O => N343
    );
  fax4_ins_FIFO1_multi_read_ins_wr : LUT4
    generic map(
      INIT => X"1000"
    )
    port map (
      I0 => fax4_ins_EOL,
      I1 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt(0),
      I2 => fax4_ins_pix_changed_1319,
      I3 => N343,
      O => fax4_ins_FIFO1_multi_read_ins_wr_459
    );
  fax4_ins_a1_o_mux0000_9_1 : LUT3
    generic map(
      INIT => X"F7"
    )
    port map (
      I0 => fax4_ins_counter_xy_v2_ins_frame_valid_1206,
      I1 => fax4_ins_counter_xy_v2_ins_line_valid_1210,
      I2 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(0),
      O => fax4_ins_a1_o_mux0000(9)
    );
  fax4_ins_a1_o_mux0000_5_1 : LUT3
    generic map(
      INIT => X"F7"
    )
    port map (
      I0 => fax4_ins_counter_xy_v2_ins_frame_valid_1206,
      I1 => fax4_ins_counter_xy_v2_ins_line_valid_1210,
      I2 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(4),
      O => fax4_ins_a1_o_mux0000(5)
    );
  fax4_ins_a1_o_mux0000_4_1 : LUT3
    generic map(
      INIT => X"F7"
    )
    port map (
      I0 => fax4_ins_counter_xy_v2_ins_frame_valid_1206,
      I1 => fax4_ins_counter_xy_v2_ins_line_valid_1210,
      I2 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(5),
      O => fax4_ins_a1_o_mux0000(4)
    );
  fax4_ins_a1_o_mux0000_3_1 : LUT3
    generic map(
      INIT => X"F7"
    )
    port map (
      I0 => fax4_ins_counter_xy_v2_ins_frame_valid_1206,
      I1 => fax4_ins_counter_xy_v2_ins_line_valid_1210,
      I2 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(6),
      O => fax4_ins_a1_o_mux0000(3)
    );
  fax4_ins_a1_o_mux0000_2_1 : LUT3
    generic map(
      INIT => X"F7"
    )
    port map (
      I0 => fax4_ins_counter_xy_v2_ins_frame_valid_1206,
      I1 => fax4_ins_counter_xy_v2_ins_line_valid_1210,
      I2 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(7),
      O => fax4_ins_a1_o_mux0000(2)
    );
  fax4_ins_a1_o_mux0000_0_1 : LUT3
    generic map(
      INIT => X"F7"
    )
    port map (
      I0 => fax4_ins_counter_xy_v2_ins_frame_valid_1206,
      I1 => fax4_ins_counter_xy_v2_ins_line_valid_1210,
      I2 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(9),
      O => fax4_ins_a1_o_mux0000(0)
    );
  huffman_ins_v2_code_table_ins_Mrom_makeup_black_mux00011011 : LUT3
    generic map(
      INIT => X"01"
    )
    port map (
      I0 => huffman_ins_v2_run_length_black(9),
      I1 => huffman_ins_v2_run_length_black(7),
      I2 => huffman_ins_v2_run_length_black(8),
      O => huffman_ins_v2_code_table_ins_Mrom_makeup_black_mux0001101
    );
  fax4_ins_a0_to_white_mux000026 : LUT4
    generic map(
      INIT => X"EC4C"
    )
    port map (
      I0 => fax4_ins_counter_xy_v2_ins_frame_valid_1206,
      I1 => fax4_ins_pix_prev_1321,
      I2 => fax4_ins_counter_xy_v2_ins_line_valid_1210,
      I3 => fax4_ins_to_white_1349,
      O => fax4_ins_a0_to_white_mux000026_948
    );
  fax4_ins_state_FSM_FFd10_In41 : LUT4
    generic map(
      INIT => X"1000"
    )
    port map (
      I0 => fax4_ins_pass_mode,
      I1 => fax4_ins_pix_changed_1319,
      I2 => fax4_ins_state_FSM_N7,
      I3 => fax4_ins_state_FSM_FFd10_1323,
      O => fax4_ins_state_FSM_N12
    );
  huffman_ins_v2_hor_code_20_mux000346 : LUT4
    generic map(
      INIT => X"C080"
    )
    port map (
      I0 => huffman_ins_v2_mux_code_white_width(1),
      I1 => huffman_ins_v2_Madd_hor_code_width_addsub0000_lut(3),
      I2 => huffman_ins_v2_Madd_hor_code_width_addsub0000_lut(2),
      I3 => huffman_ins_v2_Madd_hor_code_width_addsub0000_cy(0),
      O => huffman_ins_v2_hor_code_20_mux000346_1945
    );
  huffman_ins_v2_hor_code_17_mux000361 : LUT4
    generic map(
      INIT => X"0E04"
    )
    port map (
      I0 => huffman_ins_v2_a0_value_2_1510,
      I1 => huffman_ins_v2_code_black_width(4),
      I2 => huffman_ins_v2_horizontal_mode_part_2_2065,
      I3 => huffman_ins_v2_code_white_width(4),
      O => huffman_ins_v2_N102
    );
  huffman_ins_v2_hor_code_21_mux000395 : LUT3
    generic map(
      INIT => X"08"
    )
    port map (
      I0 => huffman_ins_v2_mux_code_black_width(2),
      I1 => huffman_ins_v2_mux_code_black_width(0),
      I2 => huffman_ins_v2_mux_code_black_width(1),
      O => huffman_ins_v2_hor_code_21_mux000395_1957
    );
  huffman_ins_v2_hor_code_19_mux00036 : LUT4
    generic map(
      INIT => X"1000"
    )
    port map (
      I0 => huffman_ins_v2_N70,
      I1 => huffman_ins_v2_horizontal_mode_part_2_2065,
      I2 => huffman_ins_v2_Madd_hor_code_width_addsub0000_lut(4),
      I3 => huffman_ins_v2_N246,
      O => huffman_ins_v2_hor_code_19_mux00036_1927
    );
  huffman_ins_v2_hor_code_3_mux00033 : LUT3
    generic map(
      INIT => X"01"
    )
    port map (
      I0 => huffman_ins_v2_Madd_hor_code_width_addsub0000_lut(2),
      I1 => huffman_ins_v2_mux_code_white_width(1),
      I2 => huffman_ins_v2_Madd_hor_code_width_addsub0000_cy(0),
      O => huffman_ins_v2_hor_code_3_mux00033_1992
    );
  huffman_ins_v2_hor_code_0_mux000322 : LUT4
    generic map(
      INIT => X"0010"
    )
    port map (
      I0 => huffman_ins_v2_N59,
      I1 => huffman_ins_v2_Madd_hor_code_width_addsub0000_cy(0),
      I2 => huffman_ins_v2_N109,
      I3 => huffman_ins_v2_Madd_hor_code_width_addsub0000_lut(3),
      O => huffman_ins_v2_hor_code_0_mux000322_1817
    );
  huffman_ins_v2_code_black_21_mux000012 : LUT3
    generic map(
      INIT => X"C8"
    )
    port map (
      I0 => huffman_ins_v2_codetab_ter_black_width(1),
      I1 => huffman_ins_v2_code_table_ins_makeup_black_8_Q,
      I2 => huffman_ins_v2_codetab_ter_black_width(0),
      O => huffman_ins_v2_code_black_21_mux000011_1603
    );
  huffman_ins_v2_code_black_18_mux000012 : LUT4
    generic map(
      INIT => X"EC4C"
    )
    port map (
      I0 => huffman_ins_v2_codetab_ter_black_width(1),
      I1 => huffman_ins_v2_code_table_ins_makeup_black_8_Q,
      I2 => huffman_ins_v2_codetab_ter_black_width(0),
      I3 => huffman_ins_v2_code_table_ins_makeup_black_7_Q,
      O => huffman_ins_v2_code_black_18_mux000011_1586
    );
  huffman_ins_v2_horizontal_mode_1_cmp_eq00012 : LUT4
    generic map(
      INIT => X"1000"
    )
    port map (
      I0 => fax4_ins_mode_indicator_o(1),
      I1 => fax4_ins_mode_indicator_o(2),
      I2 => fax4_ins_mode_indicator_o(0),
      I3 => fax4_ins_mode_indicator_o(3),
      O => huffman_ins_v2_horizontal_mode_1_cmp_eq0001
    );
  fax4_ins_a1_o_mux0000_8_1 : LUT3
    generic map(
      INIT => X"80"
    )
    port map (
      I0 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(1),
      I1 => fax4_ins_counter_xy_v2_ins_frame_valid_1206,
      I2 => fax4_ins_counter_xy_v2_ins_line_valid_1210,
      O => fax4_ins_a1_o_mux0000(8)
    );
  fax4_ins_a1_o_mux0000_7_1 : LUT3
    generic map(
      INIT => X"80"
    )
    port map (
      I0 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(2),
      I1 => fax4_ins_counter_xy_v2_ins_frame_valid_1206,
      I2 => fax4_ins_counter_xy_v2_ins_line_valid_1210,
      O => fax4_ins_a1_o_mux0000(7)
    );
  fax4_ins_a1_o_mux0000_6_1 : LUT3
    generic map(
      INIT => X"80"
    )
    port map (
      I0 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(3),
      I1 => fax4_ins_counter_xy_v2_ins_frame_valid_1206,
      I2 => fax4_ins_counter_xy_v2_ins_line_valid_1210,
      O => fax4_ins_a1_o_mux0000(6)
    );
  fax4_ins_a1_o_mux0000_1_1 : LUT3
    generic map(
      INIT => X"80"
    )
    port map (
      I0 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(8),
      I1 => fax4_ins_counter_xy_v2_ins_frame_valid_1206,
      I2 => fax4_ins_counter_xy_v2_ins_line_valid_1210,
      O => fax4_ins_a1_o_mux0000(1)
    );
  huffman_ins_v2_hor_code_0_mux000321 : LUT4
    generic map(
      INIT => X"777F"
    )
    port map (
      I0 => huffman_ins_v2_Madd_hor_code_width_addsub0000_lut(4),
      I1 => huffman_ins_v2_Madd_hor_code_width_addsub0000_lut(3),
      I2 => huffman_ins_v2_Madd_hor_code_width_addsub0000_lut(2),
      I3 => huffman_ins_v2_mux_code_white_width(1),
      O => huffman_ins_v2_N45
    );
  huffman_ins_v2_hor_code_19_mux000323 : LUT4
    generic map(
      INIT => X"2028"
    )
    port map (
      I0 => huffman_ins_v2_N107,
      I1 => huffman_ins_v2_mux_code_black_width(3),
      I2 => huffman_ins_v2_mux_code_black_width(2),
      I3 => huffman_ins_v2_mux_code_black_width(1),
      O => huffman_ins_v2_hor_code_19_mux000323_1926
    );
  huffman_ins_v2_hor_code_15_mux00035 : LUT4
    generic map(
      INIT => X"8000"
    )
    port map (
      I0 => huffman_ins_v2_a0_value_2_1510,
      I1 => huffman_ins_v2_horizontal_mode_part_2_2065,
      I2 => huffman_ins_v2_code_black_width(4),
      I3 => huffman_ins_v2_code_black(15),
      O => huffman_ins_v2_hor_code_15_mux00035_1888
    );
  huffman_ins_v2_hor_code_15_mux00038 : LUT4
    generic map(
      INIT => X"2000"
    )
    port map (
      I0 => huffman_ins_v2_horizontal_mode_part_2_2065,
      I1 => huffman_ins_v2_a0_value_2_1510,
      I2 => huffman_ins_v2_code_white_width(4),
      I3 => huffman_ins_v2_code_white(15),
      O => huffman_ins_v2_hor_code_15_mux00038_1893
    );
  huffman_ins_v2_hor_code_14_mux0003213 : LUT4
    generic map(
      INIT => X"2800"
    )
    port map (
      I0 => huffman_ins_v2_code_white_width(4),
      I1 => huffman_ins_v2_a0_value_2_1510,
      I2 => huffman_ins_v2_horizontal_mode_part_2_2065,
      I3 => huffman_ins_v2_code_white_width(1),
      O => huffman_ins_v2_hor_code_14_mux0003213_1872
    );
  huffman_ins_v2_hor_code_14_mux0003264 : LUT4
    generic map(
      INIT => X"9000"
    )
    port map (
      I0 => huffman_ins_v2_a0_value_2_1510,
      I1 => huffman_ins_v2_horizontal_mode_part_2_2065,
      I2 => huffman_ins_v2_code_black_width(4),
      I3 => huffman_ins_v2_code_black_width(1),
      O => huffman_ins_v2_hor_code_14_mux0003264_1875
    );
  huffman_ins_v2_hor_code_14_mux000379 : LUT4
    generic map(
      INIT => X"2000"
    )
    port map (
      I0 => huffman_ins_v2_code_white_width(2),
      I1 => huffman_ins_v2_code_white_width(4),
      I2 => huffman_ins_v2_code_white_width(3),
      I3 => huffman_ins_v2_code_white_width(1),
      O => huffman_ins_v2_hor_code_14_mux000379_1881
    );
  fax4_ins_state_FSM_FFd8_In7 : LUT4
    generic map(
      INIT => X"2000"
    )
    port map (
      I0 => fax4_ins_counter_xy_v2_ins_frame_valid_1206,
      I1 => fax4_ins_pix_changed_1319,
      I2 => fax4_ins_counter_xy_v2_ins_line_valid_1210,
      I3 => fax4_ins_state_FSM_FFd8_1338,
      O => fax4_ins_state_FSM_FFd8_In7_1340
    );
  fax4_ins_pix_change_detector_reset_inv1 : LUT3
    generic map(
      INIT => X"01"
    )
    port map (
      I0 => fax4_ins_state_FSM_FFd11_1325,
      I1 => fax4_ins_state_FSM_FFd3_1329,
      I2 => fax4_ins_state_FSM_FFd9_1341,
      O => fax4_ins_pix_change_detector_reset_inv
    );
  fax4_ins_state_FSM_FFd3_In1 : LUT3
    generic map(
      INIT => X"2A"
    )
    port map (
      I0 => fax4_ins_state_FSM_FFd8_1338,
      I1 => fax4_ins_counter_xy_v2_ins_frame_valid_1206,
      I2 => fax4_ins_counter_xy_v2_ins_line_valid_1210,
      O => fax4_ins_state_FSM_FFd3_In
    );
  fax4_ins_mode_indicator_o_mux0001_2_261 : LUT4
    generic map(
      INIT => X"569A"
    )
    port map (
      I0 => fax4_ins_a1b1(0),
      I1 => fax4_ins_EOL,
      I2 => fax4_ins_a1b1_addsub0000(1),
      I3 => fax4_ins_a1b1_addsub0001(1),
      O => fax4_ins_mode_indicator_o_mux0001_2_261_1297
    );
  fax4_ins_fifo_rd36_SW0 : LUT4
    generic map(
      INIT => X"0001"
    )
    port map (
      I0 => fax4_ins_state_FSM_FFd8_1338,
      I1 => fax4_ins_state_FSM_FFd5_1333,
      I2 => fax4_ins_state_FSM_FFd6_1336,
      I3 => fax4_ins_fifo_rd0_1266,
      O => N227
    );
  fax4_ins_fifo_rd36_SW1 : LUT4
    generic map(
      INIT => X"FFFE"
    )
    port map (
      I0 => fax4_ins_state_FSM_FFd8_1338,
      I1 => fax4_ins_state_FSM_FFd5_1333,
      I2 => fax4_ins_state_FSM_FFd6_1336,
      I3 => fax4_ins_fifo_rd0_1266,
      O => N229
    );
  huffman_ins_v2_hor_code_9_mux000320 : LUT4
    generic map(
      INIT => X"020A"
    )
    port map (
      I0 => huffman_ins_v2_horizontal_mode_part_2_2065,
      I1 => huffman_ins_v2_mux_code_black_width(3),
      I2 => huffman_ins_v2_mux_code_black_width(4),
      I3 => huffman_ins_v2_N99,
      O => huffman_ins_v2_hor_code_9_mux000320_2044
    );
  huffman_ins_v2_code_table_ins_Mrom_makeup_black_mux0001711 : LUT4
    generic map(
      INIT => X"0E04"
    )
    port map (
      I0 => fax4_ins_a0_value_o_950,
      I1 => huffman_ins_v2_run_length_white_sub0000(7),
      I2 => huffman_ins_v2_run_length_black(9),
      I3 => huffman_ins_v2_run_length_white_sub0001(7),
      O => huffman_ins_v2_code_table_ins_Mrom_makeup_black_mux000171
    );
  huffman_ins_v2_hor_code_12_mux000339 : LUT4
    generic map(
      INIT => X"1FBF"
    )
    port map (
      I0 => huffman_ins_v2_a0_value_2_1510,
      I1 => huffman_ins_v2_code_white_width(2),
      I2 => huffman_ins_v2_mux_code_black_width(3),
      I3 => huffman_ins_v2_code_black_width(2),
      O => huffman_ins_v2_hor_code_12_mux000339_1848
    );
  huffman_ins_v2_hor_code_24_mux000351 : LUT4
    generic map(
      INIT => X"1000"
    )
    port map (
      I0 => huffman_ins_v2_mux_code_black_width(1),
      I1 => huffman_ins_v2_mux_code_black_width(2),
      I2 => huffman_ins_v2_hor_code_23_and0000,
      I3 => huffman_ins_v2_N107,
      O => huffman_ins_v2_N228
    );
  huffman_ins_v2_Madd_code_white_width_add0000_xor_2_11 : LUT3
    generic map(
      INIT => X"96"
    )
    port map (
      I0 => huffman_ins_v2_code_table_ins_makeup_white(11),
      I1 => huffman_ins_v2_codetab_ter_white_width(2),
      I2 => huffman_ins_v2_Madd_code_white_width_add0000_cy_1_Q,
      O => huffman_ins_v2_code_white_width_add0000(2)
    );
  huffman_ins_v2_Madd_code_black_width_add0000_xor_2_11 : LUT3
    generic map(
      INIT => X"96"
    )
    port map (
      I0 => huffman_ins_v2_code_table_ins_makeup_black_15_Q,
      I1 => huffman_ins_v2_codetab_ter_black_width(2),
      I2 => huffman_ins_v2_Madd_code_black_width_add0000_cy_1_Q,
      O => huffman_ins_v2_code_black_width_add0000(2)
    );
  huffman_ins_v2_hor_code_17_mux000378 : LUT4
    generic map(
      INIT => X"8000"
    )
    port map (
      I0 => huffman_ins_v2_Madd_hor_code_width_addsub0000_lut(2),
      I1 => huffman_ins_v2_Madd_hor_code_width_addsub0000_cy(0),
      I2 => huffman_ins_v2_N102,
      I3 => huffman_ins_v2_Madd_hor_code_width_addsub0000_lut(3),
      O => huffman_ins_v2_hor_code_17_mux000378_1912
    );
  huffman_ins_v2_hor_code_9_mux0003104 : LUT4
    generic map(
      INIT => X"0E04"
    )
    port map (
      I0 => huffman_ins_v2_a0_value_2_1510,
      I1 => huffman_ins_v2_code_black_width(0),
      I2 => huffman_ins_v2_Madd_hor_code_width_addsub0000_lut(2),
      I3 => huffman_ins_v2_code_white_width(0),
      O => huffman_ins_v2_hor_code_9_mux0003104_2040
    );
  huffman_ins_v2_hor_code_8_mux000327 : LUT4
    generic map(
      INIT => X"0010"
    )
    port map (
      I0 => huffman_ins_v2_mux_code_black_width(0),
      I1 => huffman_ins_v2_mux_code_black_width(1),
      I2 => huffman_ins_v2_N110,
      I3 => huffman_ins_v2_mux_code_black_width(2),
      O => huffman_ins_v2_hor_code_8_mux000327_2035
    );
  huffman_ins_v2_hor_code_13_mux000325 : LUT4
    generic map(
      INIT => X"0C08"
    )
    port map (
      I0 => huffman_ins_v2_Madd_hor_code_width_addsub0000_cy(0),
      I1 => huffman_ins_v2_Madd_hor_code_width_addsub0000_lut(4),
      I2 => huffman_ins_v2_N98,
      I3 => huffman_ins_v2_mux_code_white_width(1),
      O => huffman_ins_v2_hor_code_13_mux000325_1857
    );
  fax4_ins_counter_xy_v2_ins_counter_x_ins_overflow_o_mux00021 : LUT3
    generic map(
      INIT => X"80"
    )
    port map (
      I0 => fax4_ins_counter_xy_v2_ins_line_valid_1210,
      I1 => fax4_ins_counter_xy_v2_ins_frame_valid_1206,
      I2 => fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt_cmp_ge0000,
      O => fax4_ins_counter_xy_v2_ins_counter_x_ins_overflow_o_mux0002
    );
  huffman_ins_v2_hor_code_18_mux0003211 : LUT4
    generic map(
      INIT => X"0213"
    )
    port map (
      I0 => huffman_ins_v2_a0_value_2_1510,
      I1 => huffman_ins_v2_Madd_hor_code_width_addsub0000_lut(2),
      I2 => huffman_ins_v2_code_white_width(3),
      I3 => huffman_ins_v2_code_black_width(3),
      O => huffman_ins_v2_N246
    );
  huffman_ins_v2_hor_code_15_mux000378 : LUT4
    generic map(
      INIT => X"1000"
    )
    port map (
      I0 => huffman_ins_v2_Madd_hor_code_width_addsub0000_lut(4),
      I1 => huffman_ins_v2_N98,
      I2 => huffman_ins_v2_Madd_hor_code_width_addsub0000_cy(0),
      I3 => huffman_ins_v2_mux_code_white_width(1),
      O => huffman_ins_v2_hor_code_15_mux000378_1892
    );
  huffman_ins_v2_hor_code_15_mux000380 : LUT4
    generic map(
      INIT => X"FF4C"
    )
    port map (
      I0 => huffman_ins_v2_Madd_hor_code_width_addsub0000_lut(3),
      I1 => huffman_ins_v2_hor_code_15_mux000355,
      I2 => huffman_ins_v2_N59,
      I3 => huffman_ins_v2_hor_code_15_mux000378_1892,
      O => huffman_ins_v2_hor_code_15_mux000380_1894
    );
  huffman_ins_v2_hor_code_24_mux000335 : LUT4
    generic map(
      INIT => X"AF9F"
    )
    port map (
      I0 => huffman_ins_v2_mux_code_black_width(2),
      I1 => huffman_ins_v2_mux_code_black_width(1),
      I2 => huffman_ins_v2_hor_code_23_and0000,
      I3 => huffman_ins_v2_mux_code_black_width(0),
      O => huffman_ins_v2_hor_code_24_mux000335_1975
    );
  huffman_ins_v2_hor_code_18_mux0003164 : LUT4
    generic map(
      INIT => X"2A08"
    )
    port map (
      I0 => huffman_ins_v2_N95,
      I1 => huffman_ins_v2_mux_code_black_width(3),
      I2 => huffman_ins_v2_N99,
      I3 => N345,
      O => huffman_ins_v2_hor_code_18_mux0003164_1917
    );
  huffman_ins_v2_hor_code_14_mux0003155 : LUT4
    generic map(
      INIT => X"9908"
    )
    port map (
      I0 => huffman_ins_v2_a0_value_2_1510,
      I1 => huffman_ins_v2_horizontal_mode_part_2_2065,
      I2 => huffman_ins_v2_code_black_width(0),
      I3 => huffman_ins_v2_N203,
      O => huffman_ins_v2_hor_code_14_mux0003155_1868
    );
  huffman_ins_v2_hor_code_14_mux0003173 : LUT4
    generic map(
      INIT => X"6604"
    )
    port map (
      I0 => huffman_ins_v2_a0_value_2_1510,
      I1 => huffman_ins_v2_horizontal_mode_part_2_2065,
      I2 => huffman_ins_v2_code_white_width(0),
      I3 => huffman_ins_v2_N223,
      O => huffman_ins_v2_hor_code_14_mux0003173_1869
    );
  huffman_ins_v2_hor_code_16_mux000393 : LUT4
    generic map(
      INIT => X"6240"
    )
    port map (
      I0 => huffman_ins_v2_horizontal_mode_part_2_2065,
      I1 => huffman_ins_v2_a0_value_2_1510,
      I2 => huffman_ins_v2_N14,
      I3 => huffman_ins_v2_N34,
      O => huffman_ins_v2_hor_code_16_mux000393_1901
    );
  huffman_ins_v2_hor_code_6_mux000343 : LUT4
    generic map(
      INIT => X"6240"
    )
    port map (
      I0 => huffman_ins_v2_horizontal_mode_part_2_2065,
      I1 => huffman_ins_v2_a0_value_2_1510,
      I2 => huffman_ins_v2_N39,
      I3 => huffman_ins_v2_N55,
      O => huffman_ins_v2_hor_code_6_mux000343_2017
    );
  huffman_ins_v2_hor_code_16_mux0003117 : LUT4
    generic map(
      INIT => X"9810"
    )
    port map (
      I0 => huffman_ins_v2_a0_value_2_1510,
      I1 => huffman_ins_v2_horizontal_mode_part_2_2065,
      I2 => huffman_ins_v2_N14,
      I3 => huffman_ins_v2_N34,
      O => huffman_ins_v2_hor_code_16_mux0003117_1897
    );
  huffman_ins_v2_hor_code_10_mux000329_SW0 : LUT4
    generic map(
      INIT => X"15FF"
    )
    port map (
      I0 => huffman_ins_v2_mux_code_black_width(2),
      I1 => huffman_ins_v2_mux_code_black_width(1),
      I2 => huffman_ins_v2_mux_code_black_width(0),
      I3 => huffman_ins_v2_mux_code_black_width(3),
      O => N349
    );
  huffman_ins_v2_hor_code_10_mux000329 : LUT4
    generic map(
      INIT => X"FFEA"
    )
    port map (
      I0 => huffman_ins_v2_N166,
      I1 => huffman_ins_v2_N110,
      I2 => N349,
      I3 => huffman_ins_v2_N100,
      O => huffman_ins_v2_hor_code_10_mux000329_1823
    );
  huffman_ins_v2_hor_code_2_mux000379_SW0 : LUT4
    generic map(
      INIT => X"020A"
    )
    port map (
      I0 => huffman_ins_v2_N110,
      I1 => huffman_ins_v2_mux_code_black_width(1),
      I2 => huffman_ins_v2_mux_code_black_width(3),
      I3 => huffman_ins_v2_mux_code_black_width(0),
      O => N351
    );
  huffman_ins_v2_hor_code_2_mux000379 : LUT4
    generic map(
      INIT => X"F020"
    )
    port map (
      I0 => N351,
      I1 => huffman_ins_v2_mux_code_black_width(2),
      I2 => huffman_ins_v2_hor_code(2),
      I3 => huffman_ins_v2_N166,
      O => huffman_ins_v2_hor_code_2_mux000379_1988
    );
  fax4_ins_mux_a0_and00011_SW0 : LUT4
    generic map(
      INIT => X"F8FF"
    )
    port map (
      I0 => fax4_ins_pix_changed_1319,
      I1 => fax4_ins_state_FSM_FFd8_1338,
      I2 => fax4_ins_mux_a0_0_Q,
      I3 => N491,
      O => N144
    );
  fax4_ins_FIFO2_multi_read_ins_latch2_or00001 : LUT4
    generic map(
      INIT => X"EAAA"
    )
    port map (
      I0 => fax4_ins_fifo2_rd,
      I1 => fax4_ins_FIFO2_multi_read_ins_used(0),
      I2 => fax4_ins_fifo2_wr,
      I3 => fax4_ins_FIFO2_multi_read_ins_N7,
      O => fax4_ins_FIFO2_multi_read_ins_latch2
    );
  fax4_ins_FIFO2_multi_read_ins_latch1_or00001 : LUT4
    generic map(
      INIT => X"AEAA"
    )
    port map (
      I0 => fax4_ins_fifo2_rd,
      I1 => fax4_ins_FIFO2_multi_read_ins_N7,
      I2 => fax4_ins_FIFO2_multi_read_ins_used(0),
      I3 => fax4_ins_fifo2_wr,
      O => fax4_ins_FIFO2_multi_read_ins_latch1
    );
  fax4_ins_FIFO1_multi_read_ins_latch2_or00001 : LUT4
    generic map(
      INIT => X"EAAA"
    )
    port map (
      I0 => fax4_ins_fifo1_rd,
      I1 => fax4_ins_FIFO1_multi_read_ins_used(0),
      I2 => fax4_ins_fifo1_wr,
      I3 => fax4_ins_FIFO1_multi_read_ins_N7,
      O => fax4_ins_FIFO1_multi_read_ins_latch2
    );
  fax4_ins_FIFO1_multi_read_ins_latch1_or00001 : LUT4
    generic map(
      INIT => X"AEAA"
    )
    port map (
      I0 => fax4_ins_fifo1_rd,
      I1 => fax4_ins_FIFO1_multi_read_ins_N7,
      I2 => fax4_ins_FIFO1_multi_read_ins_used(0),
      I3 => fax4_ins_fifo1_wr,
      O => fax4_ins_FIFO1_multi_read_ins_latch1
    );
  huffman_ins_v2_code_white_6_mux000014_SW0 : LUT3
    generic map(
      INIT => X"EA"
    )
    port map (
      I0 => huffman_ins_v2_code_white_6_mux00004_1778,
      I1 => huffman_ins_v2_code_table_ins_makeup_white(1),
      I2 => huffman_ins_v2_code_white_8_cmp_eq0001,
      O => N355
    );
  huffman_ins_v2_code_white_6_mux000014 : LUT4
    generic map(
      INIT => X"AEAA"
    )
    port map (
      I0 => N355,
      I1 => huffman_ins_v2_code_table_ins_makeup_white(0),
      I2 => huffman_ins_v2_codetab_ter_white_width(0),
      I3 => huffman_ins_v2_N239,
      O => huffman_ins_v2_code_white_6_mux000014_1776
    );
  huffman_ins_v2_hor_code_13_mux0003137 : LUT4
    generic map(
      INIT => X"A820"
    )
    port map (
      I0 => N359,
      I1 => huffman_ins_v2_a0_value_2_1510,
      I2 => huffman_ins_v2_code_black(13),
      I3 => huffman_ins_v2_code_white(13),
      O => huffman_ins_v2_hor_code_13_mux0003137_1852
    );
  huffman_ins_v2_code_white_14_mux0000141 : LUT4
    generic map(
      INIT => X"A820"
    )
    port map (
      I0 => huffman_ins_v2_N239,
      I1 => huffman_ins_v2_codetab_ter_white_width(0),
      I2 => huffman_ins_v2_code_table_ins_makeup_white(8),
      I3 => huffman_ins_v2_code_table_ins_makeup_white(7),
      O => huffman_ins_v2_code_white_14_mux000014
    );
  huffman_ins_v2_hor_code_13_mux0003137_SW0 : LUT4
    generic map(
      INIT => X"42AA"
    )
    port map (
      I0 => huffman_ins_v2_Madd_hor_code_width_addsub0000_lut(4),
      I1 => huffman_ins_v2_mux_code_white_width(1),
      I2 => huffman_ins_v2_Madd_hor_code_width_addsub0000_lut(2),
      I3 => huffman_ins_v2_Madd_hor_code_width_addsub0000_lut(3),
      O => N359
    );
  huffman_ins_v2_hor_code_16_mux000332_SW0 : LUT4
    generic map(
      INIT => X"A820"
    )
    port map (
      I0 => huffman_ins_v2_Madd_hor_code_width_addsub0000_lut(2),
      I1 => huffman_ins_v2_a0_value_2_1510,
      I2 => huffman_ins_v2_code_black_width(3),
      I3 => huffman_ins_v2_code_white_width(3),
      O => N361
    );
  huffman_ins_v2_hor_code_5_mux000311 : LUT4
    generic map(
      INIT => X"6E7F"
    )
    port map (
      I0 => huffman_ins_v2_Madd_hor_code_width_addsub0000_lut(3),
      I1 => huffman_ins_v2_Madd_hor_code_width_addsub0000_lut(4),
      I2 => huffman_ins_v2_N59,
      I3 => huffman_ins_v2_hor_code_13_or0005,
      O => huffman_ins_v2_N39
    );
  fax4_ins_state_FSM_FFd6_In221 : LUT4
    generic map(
      INIT => X"FF01"
    )
    port map (
      I0 => fax4_ins_EOL,
      I1 => fax4_ins_Mcompar_pass_mode_cmp_lt0000_cy(9),
      I2 => fax4_ins_state_FSM_FFd8_1338,
      I3 => fax4_ins_pix_changed_1319,
      O => fax4_ins_N53
    );
  huffman_ins_v2_hor_code_10_mux000363 : LUT3
    generic map(
      INIT => X"01"
    )
    port map (
      I0 => huffman_ins_v2_horizontal_mode_part_2_2065,
      I1 => huffman_ins_v2_Madd_hor_code_width_addsub0000_lut(4),
      I2 => huffman_ins_v2_Madd_hor_code_width_addsub0000_lut(3),
      O => huffman_ins_v2_N100
    );
  huffman_ins_v2_hor_code_7_mux000325 : LUT4
    generic map(
      INIT => X"70A0"
    )
    port map (
      I0 => huffman_ins_v2_Madd_hor_code_width_addsub0000_lut(3),
      I1 => huffman_ins_v2_N59,
      I2 => huffman_ins_v2_hor_code_7_mux000324_2022,
      I3 => huffman_ins_v2_Madd_hor_code_width_addsub0000_lut(4),
      O => huffman_ins_v2_hor_code_7_mux000325_2023
    );
  fax4_ins_b1_mux0004_9_41_SW1 : LUT4
    generic map(
      INIT => X"AB01"
    )
    port map (
      I0 => fax4_ins_mux_b1(1),
      I1 => fax4_ins_mux_b1(2),
      I2 => fax4_ins_mux_b1(3),
      I3 => fax4_ins_fifo_out_prev1_x(9),
      O => N363
    );
  fax4_ins_b1_mux0004_9_41 : LUT4
    generic map(
      INIT => X"FE54"
    )
    port map (
      I0 => fax4_ins_mux_b1(0),
      I1 => fax4_ins_b1_mux0004_9_18_1053,
      I2 => N363,
      I3 => fax4_ins_fifo_out_prev2_x(9),
      O => fax4_ins_b1_mux0004(9)
    );
  fax4_ins_b1_mux0004_7_41_SW1 : LUT4
    generic map(
      INIT => X"AB01"
    )
    port map (
      I0 => fax4_ins_mux_b1(1),
      I1 => fax4_ins_mux_b1(2),
      I2 => fax4_ins_mux_b1(3),
      I3 => fax4_ins_fifo_out_prev1_x(7),
      O => N365
    );
  fax4_ins_b1_mux0004_7_41 : LUT4
    generic map(
      INIT => X"FE54"
    )
    port map (
      I0 => fax4_ins_mux_b1(0),
      I1 => fax4_ins_b1_mux0004_7_18_1047,
      I2 => N365,
      I3 => fax4_ins_fifo_out_prev2_x(7),
      O => fax4_ins_b1_mux0004(7)
    );
  fax4_ins_b1_mux0004_6_41_SW1 : LUT4
    generic map(
      INIT => X"AB01"
    )
    port map (
      I0 => fax4_ins_mux_b1(1),
      I1 => fax4_ins_mux_b1(2),
      I2 => fax4_ins_mux_b1(3),
      I3 => fax4_ins_fifo_out_prev1_x(6),
      O => N367
    );
  fax4_ins_b1_mux0004_6_41 : LUT4
    generic map(
      INIT => X"FE54"
    )
    port map (
      I0 => fax4_ins_mux_b1(0),
      I1 => fax4_ins_b1_mux0004_6_18_1045,
      I2 => N367,
      I3 => fax4_ins_fifo_out_prev2_x(6),
      O => fax4_ins_b1_mux0004(6)
    );
  fax4_ins_b1_mux0004_5_41_SW1 : LUT4
    generic map(
      INIT => X"AB01"
    )
    port map (
      I0 => fax4_ins_mux_b1(1),
      I1 => fax4_ins_mux_b1(2),
      I2 => fax4_ins_mux_b1(3),
      I3 => fax4_ins_fifo_out_prev1_x(5),
      O => N369
    );
  fax4_ins_b1_mux0004_5_41 : LUT4
    generic map(
      INIT => X"FE54"
    )
    port map (
      I0 => fax4_ins_mux_b1(0),
      I1 => fax4_ins_b1_mux0004_5_18_1043,
      I2 => N369,
      I3 => fax4_ins_fifo_out_prev2_x(5),
      O => fax4_ins_b1_mux0004(5)
    );
  fax4_ins_b1_mux0004_4_41_SW1 : LUT4
    generic map(
      INIT => X"AB01"
    )
    port map (
      I0 => fax4_ins_mux_b1(1),
      I1 => fax4_ins_mux_b1(2),
      I2 => fax4_ins_mux_b1(3),
      I3 => fax4_ins_fifo_out_prev1_x(4),
      O => N371
    );
  fax4_ins_b1_mux0004_4_41 : LUT4
    generic map(
      INIT => X"FE54"
    )
    port map (
      I0 => fax4_ins_mux_b1(0),
      I1 => fax4_ins_b1_mux0004_4_18_1041,
      I2 => N371,
      I3 => fax4_ins_fifo_out_prev2_x(4),
      O => fax4_ins_b1_mux0004(4)
    );
  fax4_ins_b1_mux0004_0_41_SW1 : LUT4
    generic map(
      INIT => X"AB01"
    )
    port map (
      I0 => fax4_ins_mux_b1(1),
      I1 => fax4_ins_mux_b1(2),
      I2 => fax4_ins_mux_b1(3),
      I3 => fax4_ins_fifo_out_prev1_x(0),
      O => N373
    );
  fax4_ins_b1_mux0004_0_41 : LUT4
    generic map(
      INIT => X"FE54"
    )
    port map (
      I0 => fax4_ins_mux_b1(0),
      I1 => fax4_ins_b1_mux0004_0_18_1027,
      I2 => N373,
      I3 => fax4_ins_fifo_out_prev2_x(0),
      O => fax4_ins_b1_mux0004(0)
    );
  huffman_ins_v2_hor_code_20_mux00030 : LUT4
    generic map(
      INIT => X"217B"
    )
    port map (
      I0 => huffman_ins_v2_horizontal_mode_part_2_2065,
      I1 => huffman_ins_v2_code_black_width(4),
      I2 => huffman_ins_v2_a0_value_2_1510,
      I3 => huffman_ins_v2_code_white_width(4),
      O => huffman_ins_v2_hor_code_20_mux00030_1938
    );
  huffman_ins_v2_hor_code_20_mux0003111 : LUT4
    generic map(
      INIT => X"1018"
    )
    port map (
      I0 => huffman_ins_v2_mux_code_black_width(1),
      I1 => huffman_ins_v2_mux_code_black_width(2),
      I2 => huffman_ins_v2_mux_code_black_width(3),
      I3 => huffman_ins_v2_mux_code_black_width(0),
      O => huffman_ins_v2_N169
    );
  huffman_ins_v2_hor_code_21_mux000310 : LUT4
    generic map(
      INIT => X"0280"
    )
    port map (
      I0 => huffman_ins_v2_N95,
      I1 => huffman_ins_v2_mux_code_black_width(1),
      I2 => huffman_ins_v2_mux_code_black_width(2),
      I3 => huffman_ins_v2_mux_code_black_width(3),
      O => huffman_ins_v2_hor_code_21_mux000310_1949
    );
  huffman_ins_v2_hor_code_19_mux000380_SW0_SW0 : LUT4
    generic map(
      INIT => X"2028"
    )
    port map (
      I0 => huffman_ins_v2_N103,
      I1 => huffman_ins_v2_Madd_hor_code_width_addsub0000_lut(3),
      I2 => huffman_ins_v2_Madd_hor_code_width_addsub0000_lut(2),
      I3 => huffman_ins_v2_mux_code_white_width(1),
      O => N375
    );
  huffman_ins_v2_hor_code_19_mux000380_SW0 : LUT4
    generic map(
      INIT => X"FF4C"
    )
    port map (
      I0 => huffman_ins_v2_Madd_hor_code_width_addsub0000_lut(4),
      I1 => N375,
      I2 => huffman_ins_v2_N246,
      I3 => huffman_ins_v2_hor_code_19_mux000323_1926,
      O => N337
    );
  fax4_ins_mode_indicator_o_mux0001_2_322_SW0_SW0 : LUT4
    generic map(
      INIT => X"F3F1"
    )
    port map (
      I0 => fax4_ins_EOL,
      I1 => fax4_ins_pix_changed_1319,
      I2 => fax4_ins_state_FSM_FFd8_1338,
      I3 => fax4_ins_EOL_prev_230,
      O => N174
    );
  fax4_ins_fifo1_wr1 : LUT4
    generic map(
      INIT => X"2000"
    )
    port map (
      I0 => fax4_ins_counter_xy_v2_ins_frame_valid_1206,
      I1 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt(0),
      I2 => fax4_ins_counter_xy_v2_ins_line_valid_1210,
      I3 => fax4_ins_pix_changed_1319,
      O => fax4_ins_fifo1_wr
    );
  fax4_ins_load_a1_and00001 : LUT4
    generic map(
      INIT => X"F020"
    )
    port map (
      I0 => fax4_ins_EOL,
      I1 => fax4_ins_EOL_prev_230,
      I2 => fax4_ins_load_a1_or0000,
      I3 => fax4_ins_pix_changed_1319,
      O => fax4_ins_load_a0
    );
  huffman_ins_v2_N1701 : LUT3
    generic map(
      INIT => X"1F"
    )
    port map (
      I0 => huffman_ins_v2_mux_code_white_width(1),
      I1 => huffman_ins_v2_Madd_hor_code_width_addsub0000_cy(0),
      I2 => huffman_ins_v2_Madd_hor_code_width_addsub0000_lut(2),
      O => huffman_ins_v2_N170
    );
  huffman_ins_v2_hor_code_5_mux000381 : LUT3
    generic map(
      INIT => X"08"
    )
    port map (
      I0 => huffman_ins_v2_Madd_hor_code_width_addsub0000_lut(2),
      I1 => huffman_ins_v2_Madd_hor_code_width_addsub0000_cy(0),
      I2 => huffman_ins_v2_mux_code_white_width(1),
      O => huffman_ins_v2_hor_code_13_cmp_eq0000
    );
  huffman_ins_v2_hor_code_11_mux000312 : LUT4
    generic map(
      INIT => X"4A6A"
    )
    port map (
      I0 => huffman_ins_v2_mux_code_black_width(4),
      I1 => huffman_ins_v2_mux_code_black_width(2),
      I2 => huffman_ins_v2_mux_code_black_width(3),
      I3 => huffman_ins_v2_mux_code_black_width(1),
      O => huffman_ins_v2_N62
    );
  huffman_ins_v2_hor_code_6_mux000321 : LUT3
    generic map(
      INIT => X"7F"
    )
    port map (
      I0 => huffman_ins_v2_mux_code_black_width(0),
      I1 => huffman_ins_v2_mux_code_black_width(1),
      I2 => huffman_ins_v2_mux_code_black_width(2),
      O => huffman_ins_v2_N67
    );
  huffman_ins_v2_hor_code_24_mux000361 : LUT4
    generic map(
      INIT => X"1000"
    )
    port map (
      I0 => huffman_ins_v2_Madd_hor_code_width_addsub0000_lut(2),
      I1 => huffman_ins_v2_mux_code_white_width(1),
      I2 => huffman_ins_v2_Madd_hor_code_width_addsub0000_lut(3),
      I3 => huffman_ins_v2_N102,
      O => huffman_ins_v2_N244
    );
  huffman_ins_v2_hor_code_10_mux000372 : LUT3
    generic map(
      INIT => X"10"
    )
    port map (
      I0 => huffman_ins_v2_mux_code_black_width(4),
      I1 => huffman_ins_v2_mux_code_black_width(3),
      I2 => huffman_ins_v2_horizontal_mode_part_2_2065,
      O => huffman_ins_v2_N105
    );
  huffman_ins_v2_hor_code_18_mux000381_SW0 : LUT4
    generic map(
      INIT => X"777F"
    )
    port map (
      I0 => huffman_ins_v2_Madd_hor_code_width_addsub0000_lut(2),
      I1 => huffman_ins_v2_Madd_hor_code_width_addsub0000_lut(3),
      I2 => huffman_ins_v2_Madd_hor_code_width_addsub0000_cy(0),
      I3 => huffman_ins_v2_mux_code_white_width(1),
      O => N305
    );
  huffman_ins_v2_hor_code_16_mux000311 : LUT4
    generic map(
      INIT => X"5756"
    )
    port map (
      I0 => huffman_ins_v2_mux_code_black_width(3),
      I1 => huffman_ins_v2_mux_code_black_width(1),
      I2 => huffman_ins_v2_mux_code_black_width(2),
      I3 => huffman_ins_v2_mux_code_black_width(0),
      O => huffman_ins_v2_N34
    );
  huffman_ins_v2_hor_code_20_mux000350 : LUT4
    generic map(
      INIT => X"8891"
    )
    port map (
      I0 => huffman_ins_v2_Madd_hor_code_width_addsub0000_lut(2),
      I1 => huffman_ins_v2_Madd_hor_code_width_addsub0000_lut(3),
      I2 => huffman_ins_v2_Madd_hor_code_width_addsub0000_cy(0),
      I3 => huffman_ins_v2_mux_code_white_width(1),
      O => huffman_ins_v2_hor_code_20_mux000350_1946
    );
  huffman_ins_v2_hor_code_17_mux0003811 : LUT3
    generic map(
      INIT => X"10"
    )
    port map (
      I0 => huffman_ins_v2_a0_value_2_1510,
      I1 => huffman_ins_v2_horizontal_mode_part_2_2065,
      I2 => huffman_ins_v2_code_black_width(4),
      O => huffman_ins_v2_N245
    );
  huffman_ins_v2_hor_code_18_mux0003164_SW0 : LUT4
    generic map(
      INIT => X"EAE2"
    )
    port map (
      I0 => huffman_ins_v2_mux_code_black_width(2),
      I1 => huffman_ins_v2_code_black_width(1),
      I2 => huffman_ins_v2_mux_code_black_width(0),
      I3 => huffman_ins_v2_mux_code_black_width(1),
      O => N345
    );
  huffman_ins_v2_hor_code_10_mux000312 : LUT4
    generic map(
      INIT => X"5A6A"
    )
    port map (
      I0 => huffman_ins_v2_Madd_hor_code_width_addsub0000_lut(4),
      I1 => huffman_ins_v2_mux_code_white_width(1),
      I2 => huffman_ins_v2_Madd_hor_code_width_addsub0000_lut(3),
      I3 => huffman_ins_v2_Madd_hor_code_width_addsub0000_lut(2),
      O => huffman_ins_v2_N38
    );
  huffman_ins_v2_hor_code_2_mux000335_SW0 : LUT4
    generic map(
      INIT => X"FFE2"
    )
    port map (
      I0 => huffman_ins_v2_code_black_width(1),
      I1 => huffman_ins_v2_a0_value_2_1510,
      I2 => huffman_ins_v2_code_white_width(1),
      I3 => huffman_ins_v2_Madd_hor_code_width_addsub0000_lut(2),
      O => N377
    );
  huffman_ins_v2_hor_code_2_mux000335 : LUT4
    generic map(
      INIT => X"70E0"
    )
    port map (
      I0 => huffman_ins_v2_Madd_hor_code_width_addsub0000_lut(3),
      I1 => huffman_ins_v2_Madd_hor_code_width_addsub0000_lut(4),
      I2 => huffman_ins_v2_hor_code_2_mux000330_1986,
      I3 => N377,
      O => huffman_ins_v2_hor_code_2_mux000335_1987
    );
  huffman_ins_v2_hor_code_6_mux000311 : LUT4
    generic map(
      INIT => X"6E7F"
    )
    port map (
      I0 => huffman_ins_v2_mux_code_black_width(3),
      I1 => huffman_ins_v2_mux_code_black_width(4),
      I2 => huffman_ins_v2_N99,
      I3 => huffman_ins_v2_N67,
      O => huffman_ins_v2_N55
    );
  huffman_ins_v2_hor_code_21_mux000335 : LUT4
    generic map(
      INIT => X"1000"
    )
    port map (
      I0 => huffman_ins_v2_a0_value_2_1510,
      I1 => huffman_ins_v2_horizontal_mode_part_2_2065,
      I2 => huffman_ins_v2_code_black_width(4),
      I3 => huffman_ins_v2_hor_code_21_mux000334_1953,
      O => huffman_ins_v2_hor_code_21_mux000335_1954
    );
  huffman_ins_v2_hor_code_5_mux000331 : LUT4
    generic map(
      INIT => X"1FBF"
    )
    port map (
      I0 => huffman_ins_v2_a0_value_2_1510,
      I1 => huffman_ins_v2_code_black_width(0),
      I2 => huffman_ins_v2_mux_code_white_width(1),
      I3 => huffman_ins_v2_code_white_width(0),
      O => huffman_ins_v2_N70
    );
  huffman_ins_v2_hor_code_4_mux00033 : LUT4
    generic map(
      INIT => X"0010"
    )
    port map (
      I0 => huffman_ins_v2_Madd_hor_code_width_addsub0000_lut(3),
      I1 => huffman_ins_v2_Madd_hor_code_width_addsub0000_lut(2),
      I2 => huffman_ins_v2_N109,
      I3 => huffman_ins_v2_mux_code_white_width(1),
      O => huffman_ins_v2_hor_code_4_mux00033_1999
    );
  huffman_ins_v2_hor_code_13_or00051 : LUT4
    generic map(
      INIT => X"1FBF"
    )
    port map (
      I0 => huffman_ins_v2_a0_value_2_1510,
      I1 => huffman_ins_v2_code_black_width(2),
      I2 => huffman_ins_v2_mux_code_white_width(1),
      I3 => huffman_ins_v2_code_white_width(2),
      O => huffman_ins_v2_hor_code_13_or0005
    );
  huffman_ins_v2_hor_code_20_mux0003121 : LUT4
    generic map(
      INIT => X"A820"
    )
    port map (
      I0 => huffman_ins_v2_mux_code_black_width(0),
      I1 => huffman_ins_v2_a0_value_2_1510,
      I2 => huffman_ins_v2_code_white_width(2),
      I3 => huffman_ins_v2_code_black_width(2),
      O => huffman_ins_v2_N250
    );
  huffman_ins_v2_hor_code_22_mux000320 : LUT4
    generic map(
      INIT => X"1000"
    )
    port map (
      I0 => huffman_ins_v2_N59,
      I1 => huffman_ins_v2_a0_value_2_1510,
      I2 => huffman_ins_v2_code_black_width(3),
      I3 => huffman_ins_v2_N102,
      O => huffman_ins_v2_hor_code_22_mux000320_1962
    );
  huffman_ins_v2_hor_code_23_and00001 : LUT4
    generic map(
      INIT => X"A820"
    )
    port map (
      I0 => huffman_ins_v2_mux_code_black_width(3),
      I1 => huffman_ins_v2_a0_value_2_1510,
      I2 => huffman_ins_v2_code_white_width(4),
      I3 => huffman_ins_v2_code_black_width(4),
      O => huffman_ins_v2_hor_code_23_and0000
    );
  fax4_ins_mux_b1_2_and000032_SW0 : LUT4
    generic map(
      INIT => X"8F0F"
    )
    port map (
      I0 => fax4_ins_counter_xy_v2_ins_line_valid_1210,
      I1 => fax4_ins_counter_xy_v2_ins_frame_valid_1206,
      I2 => fax4_ins_mux_b1_2_and000019_1310,
      I3 => fax4_ins_Mcompar_mux_b1_2_cmp_gt0000_cy(9),
      O => N381
    );
  fax4_ins_state_FSM_FFd10_In21 : LUT3
    generic map(
      INIT => X"EA"
    )
    port map (
      I0 => fax4_ins_EOL_prev_230,
      I1 => fax4_ins_counter_xy_v2_ins_frame_valid_1206,
      I2 => fax4_ins_counter_xy_v2_ins_line_valid_1210,
      O => fax4_ins_state_FSM_N7
    );
  fax4_ins_load_a1_or00011 : LUT4
    generic map(
      INIT => X"FF15"
    )
    port map (
      I0 => fax4_ins_EOL_prev_230,
      I1 => fax4_ins_counter_xy_v2_ins_line_valid_1210,
      I2 => fax4_ins_counter_xy_v2_ins_frame_valid_1206,
      I3 => fax4_ins_pix_changed_1319,
      O => fax4_ins_load_a1_or0001
    );
  huffman_ins_v2_hor_code_7_mux000311 : LUT4
    generic map(
      INIT => X"57AA"
    )
    port map (
      I0 => huffman_ins_v2_mux_code_black_width(3),
      I1 => huffman_ins_v2_mux_code_black_width(1),
      I2 => huffman_ins_v2_mux_code_black_width(2),
      I3 => huffman_ins_v2_mux_code_black_width(4),
      O => huffman_ins_v2_N48
    );
  huffman_ins_v2_hor_code_10_mux0003114 : LUT4
    generic map(
      INIT => X"028A"
    )
    port map (
      I0 => huffman_ins_v2_horizontal_mode_part_2_2065,
      I1 => huffman_ins_v2_a0_value_2_1510,
      I2 => huffman_ins_v2_code_white_width(4),
      I3 => huffman_ins_v2_code_black_width(4),
      O => huffman_ins_v2_N110
    );
  huffman_ins_v2_hor_code_10_mux0003103 : LUT4
    generic map(
      INIT => X"0213"
    )
    port map (
      I0 => huffman_ins_v2_a0_value_2_1510,
      I1 => huffman_ins_v2_horizontal_mode_part_2_2065,
      I2 => huffman_ins_v2_code_white_width(4),
      I3 => huffman_ins_v2_code_black_width(4),
      O => huffman_ins_v2_N109
    );
  huffman_ins_v2_hor_code_12_mux000321 : LUT3
    generic map(
      INIT => X"1F"
    )
    port map (
      I0 => huffman_ins_v2_mux_code_white_width(1),
      I1 => huffman_ins_v2_Madd_hor_code_width_addsub0000_lut(2),
      I2 => huffman_ins_v2_Madd_hor_code_width_addsub0000_lut(3),
      O => huffman_ins_v2_N14
    );
  huffman_ins_v2_hor_code_3_mux000311 : LUT4
    generic map(
      INIT => X"57FA"
    )
    port map (
      I0 => huffman_ins_v2_mux_code_black_width(4),
      I1 => huffman_ins_v2_mux_code_black_width(1),
      I2 => huffman_ins_v2_mux_code_black_width(2),
      I3 => huffman_ins_v2_mux_code_black_width(3),
      O => huffman_ins_v2_N52
    );
  huffman_ins_v2_hor_code_8_mux000321 : LUT4
    generic map(
      INIT => X"57AA"
    )
    port map (
      I0 => huffman_ins_v2_Madd_hor_code_width_addsub0000_lut(4),
      I1 => huffman_ins_v2_Madd_hor_code_width_addsub0000_lut(2),
      I2 => huffman_ins_v2_mux_code_white_width(1),
      I3 => huffman_ins_v2_Madd_hor_code_width_addsub0000_lut(3),
      O => huffman_ins_v2_N51
    );
  huffman_ins_v2_hor_code_4_mux000311 : LUT4
    generic map(
      INIT => X"57FA"
    )
    port map (
      I0 => huffman_ins_v2_Madd_hor_code_width_addsub0000_lut(4),
      I1 => huffman_ins_v2_mux_code_white_width(1),
      I2 => huffman_ins_v2_Madd_hor_code_width_addsub0000_lut(2),
      I3 => huffman_ins_v2_Madd_hor_code_width_addsub0000_lut(3),
      O => huffman_ins_v2_N40
    );
  huffman_ins_v2_hor_code_12_mux000341 : LUT4
    generic map(
      INIT => X"4A6A"
    )
    port map (
      I0 => huffman_ins_v2_Madd_hor_code_width_addsub0000_lut(4),
      I1 => huffman_ins_v2_Madd_hor_code_width_addsub0000_lut(2),
      I2 => huffman_ins_v2_Madd_hor_code_width_addsub0000_lut(3),
      I3 => huffman_ins_v2_mux_code_white_width(1),
      O => huffman_ins_v2_N44
    );
  huffman_ins_v2_Madd_hor_code_width_addsub0000_cy_1_11 : LUT4
    generic map(
      INIT => X"FFE2"
    )
    port map (
      I0 => huffman_ins_v2_code_black_width(1),
      I1 => huffman_ins_v2_a0_value_2_1510,
      I2 => huffman_ins_v2_code_white_width(1),
      I3 => huffman_ins_v2_Madd_hor_code_width_addsub0000_cy(0),
      O => huffman_ins_v2_Madd_hor_code_width_addsub0000_cy(1)
    );
  huffman_ins_v2_hor_code_13_mux0003411 : LUT4
    generic map(
      INIT => X"1FBF"
    )
    port map (
      I0 => huffman_ins_v2_a0_value_2_1510,
      I1 => huffman_ins_v2_code_black_width(2),
      I2 => huffman_ins_v2_Madd_hor_code_width_addsub0000_lut(3),
      I3 => huffman_ins_v2_code_white_width(2),
      O => huffman_ins_v2_N98
    );
  huffman_ins_v2_hor_code_5_mux000341 : LUT4
    generic map(
      INIT => X"1FBF"
    )
    port map (
      I0 => huffman_ins_v2_a0_value_2_1510,
      I1 => huffman_ins_v2_code_white_width(1),
      I2 => huffman_ins_v2_mux_code_black_width(2),
      I3 => huffman_ins_v2_code_black_width(1),
      O => huffman_ins_v2_N78
    );
  huffman_ins_v2_hor_code_8_mux000392_SW0 : LUT4
    generic map(
      INIT => X"A8A9"
    )
    port map (
      I0 => huffman_ins_v2_mux_code_black_width(4),
      I1 => huffman_ins_v2_mux_code_black_width(1),
      I2 => huffman_ins_v2_mux_code_black_width(2),
      I3 => huffman_ins_v2_mux_code_black_width(0),
      O => N383
    );
  huffman_ins_v2_hor_code_8_mux000392 : LUT4
    generic map(
      INIT => X"2A08"
    )
    port map (
      I0 => huffman_ins_v2_hor_code_8_mux000390_2037,
      I1 => huffman_ins_v2_mux_code_black_width(3),
      I2 => N383,
      I3 => huffman_ins_v2_mux_code_black_width(4),
      O => huffman_ins_v2_hor_code_8_mux000392_2038
    );
  fax4_ins_FIFO1_multi_read_ins_used_not0003_inv2 : LUT3
    generic map(
      INIT => X"80"
    )
    port map (
      I0 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt(0),
      I1 => N208,
      I2 => fax4_ins_fifo_rd,
      O => fax4_ins_FIFO1_multi_read_ins_used_not0003_inv
    );
  huffman_ins_v2_hor_code_18_and00011 : LUT4
    generic map(
      INIT => X"A820"
    )
    port map (
      I0 => huffman_ins_v2_N246,
      I1 => huffman_ins_v2_a0_value_2_1510,
      I2 => huffman_ins_v2_code_black_width(4),
      I3 => huffman_ins_v2_code_white_width(4),
      O => huffman_ins_v2_hor_code_18_and0001
    );
  huffman_ins_v2_hor_code_17_mux00037111 : LUT4
    generic map(
      INIT => X"A820"
    )
    port map (
      I0 => huffman_ins_v2_Madd_hor_code_width_addsub0000_cy(0),
      I1 => huffman_ins_v2_a0_value_2_1510,
      I2 => huffman_ins_v2_code_black_width(2),
      I3 => huffman_ins_v2_code_white_width(2),
      O => huffman_ins_v2_N248
    );
  huffman_ins_v2_hor_code_13_mux000389_SW0 : LUT3
    generic map(
      INIT => X"BD"
    )
    port map (
      I0 => huffman_ins_v2_mux_code_black_width(4),
      I1 => huffman_ins_v2_mux_code_black_width(1),
      I2 => huffman_ins_v2_mux_code_black_width(2),
      O => N385
    );
  huffman_ins_v2_hor_code_13_mux000389 : LUT4
    generic map(
      INIT => X"2A08"
    )
    port map (
      I0 => huffman_ins_v2_hor_code_13_mux000386_1859,
      I1 => huffman_ins_v2_mux_code_black_width(3),
      I2 => N385,
      I3 => huffman_ins_v2_mux_code_black_width(4),
      O => huffman_ins_v2_hor_code_13_mux000389_1860
    );
  huffman_ins_v2_hor_code_1_mux0003111 : LUT4
    generic map(
      INIT => X"FFE2"
    )
    port map (
      I0 => huffman_ins_v2_code_black_width(2),
      I1 => huffman_ins_v2_a0_value_2_1510,
      I2 => huffman_ins_v2_code_white_width(2),
      I3 => huffman_ins_v2_mux_code_white_width(1),
      O => huffman_ins_v2_N59
    );
  huffman_ins_v2_hor_code_8_mux0003311 : LUT4
    generic map(
      INIT => X"FFE2"
    )
    port map (
      I0 => huffman_ins_v2_code_white_width(1),
      I1 => huffman_ins_v2_a0_value_2_1510,
      I2 => huffman_ins_v2_code_black_width(1),
      I3 => huffman_ins_v2_mux_code_black_width(2),
      O => huffman_ins_v2_N99
    );
  fax4_ins_Madd_a1b1_addsub0001_cy_9_rt : LUT1
    generic map(
      INIT => X"2"
    )
    port map (
      I0 => fax4_ins_b1(9),
      O => fax4_ins_Madd_a1b1_addsub0001_cy_9_rt_730
    );
  fax4_ins_Madd_a1b1_addsub0001_cy_7_rt : LUT1
    generic map(
      INIT => X"2"
    )
    port map (
      I0 => fax4_ins_b1(7),
      O => fax4_ins_Madd_a1b1_addsub0001_cy_7_rt_727
    );
  fax4_ins_Madd_a1b1_addsub0001_cy_6_rt : LUT1
    generic map(
      INIT => X"2"
    )
    port map (
      I0 => fax4_ins_b1(6),
      O => fax4_ins_Madd_a1b1_addsub0001_cy_6_rt_725
    );
  fax4_ins_Madd_a1b1_addsub0001_cy_5_rt : LUT1
    generic map(
      INIT => X"2"
    )
    port map (
      I0 => fax4_ins_b1(5),
      O => fax4_ins_Madd_a1b1_addsub0001_cy_5_rt_723
    );
  fax4_ins_Madd_a1b1_addsub0001_cy_4_rt : LUT1
    generic map(
      INIT => X"2"
    )
    port map (
      I0 => fax4_ins_b1(4),
      O => fax4_ins_Madd_a1b1_addsub0001_cy_4_rt_721
    );
  fax4_ins_Madd_a1b1_addsub0001_cy_1_rt : LUT1
    generic map(
      INIT => X"2"
    )
    port map (
      I0 => fax4_ins_b1(1),
      O => fax4_ins_Madd_a1b1_addsub0001_cy_1_rt_717
    );
  huffman_ins_v2_code_black_8_mux0000172 : MUXF5
    port map (
      I0 => N387,
      I1 => N388,
      S => huffman_ins_v2_codetab_ter_black_width(2),
      O => huffman_ins_v2_code_black_8_mux0000172_1666
    );
  huffman_ins_v2_code_black_8_mux0000172_F : LUT4
    generic map(
      INIT => X"ABA8"
    )
    port map (
      I0 => huffman_ins_v2_ter_black_code(8),
      I1 => huffman_ins_v2_codetab_ter_black_width(1),
      I2 => huffman_ins_v2_codetab_ter_black_width(0),
      I3 => huffman_ins_v2_code_table_ins_makeup_black_0_Q,
      O => N387
    );
  huffman_ins_v2_code_black_8_mux0000172_G : LUT4
    generic map(
      INIT => X"ABA8"
    )
    port map (
      I0 => huffman_ins_v2_code_black(8),
      I1 => huffman_ins_v2_codetab_ter_black_width(1),
      I2 => huffman_ins_v2_codetab_ter_black_width(0),
      I3 => huffman_ins_v2_ter_black_code(8),
      O => N388
    );
  huffman_ins_v2_code_black_14_mux00001107 : MUXF5
    port map (
      I0 => N389,
      I1 => N390,
      S => huffman_ins_v2_code_black_10_mux0000_bdd4,
      O => huffman_ins_v2_code_black_14_mux00001107_1554
    );
  huffman_ins_v2_code_black_14_mux00001107_F : LUT4
    generic map(
      INIT => X"7160"
    )
    port map (
      I0 => huffman_ins_v2_codetab_ter_black_width(1),
      I1 => huffman_ins_v2_codetab_ter_black_width(2),
      I2 => huffman_ins_v2_code_table_ins_makeup_black_8_Q,
      I3 => huffman_ins_v2_code_black(14),
      O => N389
    );
  huffman_ins_v2_code_black_14_mux00001107_G : LUT4
    generic map(
      INIT => X"EDE8"
    )
    port map (
      I0 => huffman_ins_v2_codetab_ter_black_width(1),
      I1 => huffman_ins_v2_code_table_ins_makeup_black_8_Q,
      I2 => huffman_ins_v2_codetab_ter_black_width(2),
      I3 => huffman_ins_v2_code_black(14),
      O => N390
    );
  huffman_ins_v2_code_black_13_mux00001107 : MUXF5
    port map (
      I0 => N391,
      I1 => N392,
      S => huffman_ins_v2_code_black_11_mux0000_bdd5,
      O => huffman_ins_v2_code_black_13_mux00001107_1547
    );
  huffman_ins_v2_code_black_13_mux00001107_F : LUT4
    generic map(
      INIT => X"7160"
    )
    port map (
      I0 => huffman_ins_v2_codetab_ter_black_width(1),
      I1 => huffman_ins_v2_codetab_ter_black_width(2),
      I2 => huffman_ins_v2_code_table_ins_makeup_black_8_Q,
      I3 => huffman_ins_v2_code_black(13),
      O => N391
    );
  huffman_ins_v2_code_black_13_mux00001107_G : LUT4
    generic map(
      INIT => X"EDE8"
    )
    port map (
      I0 => huffman_ins_v2_codetab_ter_black_width(1),
      I1 => huffman_ins_v2_code_table_ins_makeup_black_8_Q,
      I2 => huffman_ins_v2_codetab_ter_black_width(2),
      I3 => huffman_ins_v2_code_black(13),
      O => N392
    );
  huffman_ins_v2_code_black_12_mux00001107 : MUXF5
    port map (
      I0 => N393,
      I1 => N394,
      S => huffman_ins_v2_codetab_ter_black_width(1),
      O => huffman_ins_v2_code_black_12_mux00001107_1540
    );
  huffman_ins_v2_code_black_12_mux00001107_F : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => huffman_ins_v2_codetab_ter_black_width(2),
      I1 => huffman_ins_v2_code_black(12),
      I2 => huffman_ins_v2_code_black_10_mux0000_bdd4,
      O => N393
    );
  huffman_ins_v2_code_black_12_mux00001107_G : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => huffman_ins_v2_codetab_ter_black_width(2),
      I1 => huffman_ins_v2_code_table_ins_makeup_black_8_Q,
      I2 => huffman_ins_v2_code_black_10_mux0000_bdd5,
      O => N394
    );
  huffman_ins_v2_code_black_11_mux00001107 : MUXF5
    port map (
      I0 => N395,
      I1 => N396,
      S => huffman_ins_v2_codetab_ter_black_width(1),
      O => huffman_ins_v2_code_black_11_mux00001107_1529
    );
  huffman_ins_v2_code_black_11_mux00001107_F : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => huffman_ins_v2_codetab_ter_black_width(2),
      I1 => huffman_ins_v2_code_black(11),
      I2 => huffman_ins_v2_code_black_11_mux0000_bdd5,
      O => N395
    );
  huffman_ins_v2_code_black_11_mux00001107_G : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => huffman_ins_v2_codetab_ter_black_width(2),
      I1 => huffman_ins_v2_code_table_ins_makeup_black_8_Q,
      I2 => huffman_ins_v2_code_black_11_mux0000_bdd3,
      O => N396
    );
  fax4_ins_state_FSM_FFd10_In : MUXF5
    port map (
      I0 => N397,
      I1 => N398,
      S => fax4_ins_counter_xy_v2_ins_frame_valid_1206,
      O => fax4_ins_state_FSM_FFd10_In_1324
    );
  fax4_ins_state_FSM_FFd10_In_F : LUT3
    generic map(
      INIT => X"EA"
    )
    port map (
      I0 => fax4_ins_state_FSM_FFd11_1325,
      I1 => fax4_ins_EOF_prev_228,
      I2 => fax4_ins_state_FSM_N12,
      O => N397
    );
  fax4_ins_state_FSM_FFd10_In_G : LUT3
    generic map(
      INIT => X"FE"
    )
    port map (
      I0 => fax4_ins_state_FSM_FFd3_1329,
      I1 => fax4_ins_state_FSM_FFd9_1341,
      I2 => fax4_ins_state_FSM_N12,
      O => N398
    );
  huffman_ins_v2_hor_code_12_mux000364 : MUXF5
    port map (
      I0 => N399,
      I1 => N400,
      S => huffman_ins_v2_mux_code_black_width(4),
      O => huffman_ins_v2_hor_code_12_mux000364_1849
    );
  huffman_ins_v2_hor_code_12_mux000364_F : LUT3
    generic map(
      INIT => X"FE"
    )
    port map (
      I0 => huffman_ins_v2_hor_code_12_mux000311_1839,
      I1 => huffman_ins_v2_hor_code_12_mux000339_1848,
      I2 => huffman_ins_v2_hor_code_12_mux000324_1846,
      O => N399
    );
  huffman_ins_v2_hor_code_12_mux000364_G : LUT4
    generic map(
      INIT => X"FFEA"
    )
    port map (
      I0 => huffman_ins_v2_hor_code_12_mux000311_1839,
      I1 => huffman_ins_v2_N251,
      I2 => huffman_ins_v2_mux_code_black_width(3),
      I3 => huffman_ins_v2_hor_code_12_mux000324_1846,
      O => N400
    );
  huffman_ins_v2_code_black_10_mux00001154 : MUXF5
    port map (
      I0 => N401,
      I1 => N402,
      S => huffman_ins_v2_codetab_ter_black_width(3),
      O => huffman_ins_v2_code_black_10_mux0000
    );
  huffman_ins_v2_code_black_10_mux00001154_F : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => huffman_ins_v2_codetab_ter_black_width(1),
      I1 => huffman_ins_v2_code_black_10_mux00001116_1518,
      I2 => huffman_ins_v2_code_black_10_mux00001103_1517,
      O => N401
    );
  huffman_ins_v2_code_black_10_mux00001154_G : LUT4
    generic map(
      INIT => X"FAD8"
    )
    port map (
      I0 => huffman_ins_v2_codetab_ter_black_width(1),
      I1 => huffman_ins_v2_code_black_10_mux000010_1516,
      I2 => huffman_ins_v2_code_black_10_mux0000152,
      I3 => huffman_ins_v2_code_black_10_mux0000115_1519,
      O => N402
    );
  huffman_ins_v2_code_black_6_mux00002126 : MUXF5
    port map (
      I0 => N403,
      I1 => N404,
      S => huffman_ins_v2_codetab_ter_black_width(1),
      O => huffman_ins_v2_code_black_6_mux00002126_1652
    );
  huffman_ins_v2_code_black_6_mux00002126_F : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => huffman_ins_v2_codetab_ter_black_width(2),
      I1 => huffman_ins_v2_code_black(6),
      I2 => huffman_ins_v2_code_black_10_mux0000_bdd2,
      O => N403
    );
  huffman_ins_v2_code_black_6_mux00002126_G : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => huffman_ins_v2_codetab_ter_black_width(2),
      I1 => huffman_ins_v2_code_black_10_mux0000_bdd3,
      I2 => huffman_ins_v2_code_black_6_mux0000282_1654,
      O => N404
    );
  huffman_ins_v2_code_black_9_mux00002107 : MUXF5
    port map (
      I0 => N405,
      I1 => N406,
      S => huffman_ins_v2_codetab_ter_black_width(1),
      O => huffman_ins_v2_code_black_9_mux00002107_1669
    );
  huffman_ins_v2_code_black_9_mux00002107_F : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => huffman_ins_v2_codetab_ter_black_width(2),
      I1 => huffman_ins_v2_code_black(9),
      I2 => huffman_ins_v2_code_black_11_mux0000_bdd3,
      O => N405
    );
  huffman_ins_v2_code_black_9_mux00002107_G : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => huffman_ins_v2_codetab_ter_black_width(2),
      I1 => huffman_ins_v2_code_black_11_mux0000_bdd5,
      I2 => huffman_ins_v2_code_black_11_mux0000_bdd2,
      O => N406
    );
  huffman_ins_v2_code_black_8_mux00001126 : MUXF5
    port map (
      I0 => N407,
      I1 => N408,
      S => huffman_ins_v2_codetab_ter_black_width(1),
      O => huffman_ins_v2_code_black_8_mux00001126_1665
    );
  huffman_ins_v2_code_black_8_mux00001126_F : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => huffman_ins_v2_codetab_ter_black_width(2),
      I1 => huffman_ins_v2_code_black(8),
      I2 => huffman_ins_v2_code_black_10_mux0000_bdd3,
      O => N407
    );
  huffman_ins_v2_code_black_8_mux00001126_G : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => huffman_ins_v2_codetab_ter_black_width(2),
      I1 => huffman_ins_v2_code_black_10_mux0000_bdd5,
      I2 => huffman_ins_v2_code_black_10_mux0000_bdd2,
      O => N408
    );
  huffman_ins_v2_hor_code_19_mux0003138 : MUXF5
    port map (
      I0 => N409,
      I1 => N410,
      S => huffman_ins_v2_horizontal_mode_part_2_2065,
      O => huffman_ins_v2_hor_code_19_mux0003138_1925
    );
  huffman_ins_v2_hor_code_19_mux0003138_F : LUT4
    generic map(
      INIT => X"2A08"
    )
    port map (
      I0 => huffman_ins_v2_hor_code(19),
      I1 => huffman_ins_v2_hor_code_18_and0001,
      I2 => huffman_ins_v2_Madd_hor_code_width_addsub0000_cy(1),
      I3 => huffman_ins_v2_N3,
      O => N409
    );
  huffman_ins_v2_hor_code_19_mux0003138_G : LUT4
    generic map(
      INIT => X"AA02"
    )
    port map (
      I0 => huffman_ins_v2_hor_code(19),
      I1 => huffman_ins_v2_mux_code_black_width(2),
      I2 => huffman_ins_v2_mux_code_black_width(3),
      I3 => huffman_ins_v2_N65,
      O => N410
    );
  huffman_ins_v2_hor_code_14_mux000343 : MUXF5
    port map (
      I0 => N411,
      I1 => N412,
      S => huffman_ins_v2_N11,
      O => huffman_ins_v2_hor_code_14_mux000343_1879
    );
  huffman_ins_v2_hor_code_14_mux000343_F : LUT3
    generic map(
      INIT => X"80"
    )
    port map (
      I0 => huffman_ins_v2_hor_code_14_mux000327_1876,
      I1 => huffman_ins_v2_code_white_width(4),
      I2 => huffman_ins_v2_code_white(14),
      O => N411
    );
  huffman_ins_v2_hor_code_14_mux000343_G : LUT3
    generic map(
      INIT => X"80"
    )
    port map (
      I0 => huffman_ins_v2_hor_code_14_mux00038_1882,
      I1 => huffman_ins_v2_code_black_width(4),
      I2 => huffman_ins_v2_code_black(14),
      O => N412
    );
  huffman_ins_v2_hor_code_21_mux0003168 : MUXF5
    port map (
      I0 => N413,
      I1 => N414,
      S => huffman_ins_v2_horizontal_mode_part_2_2065,
      O => huffman_ins_v2_hor_code_21_mux0003168_1951
    );
  huffman_ins_v2_hor_code_21_mux0003168_F : LUT3
    generic map(
      INIT => X"FD"
    )
    port map (
      I0 => huffman_ins_v2_Madd_hor_code_width_addsub0000_lut(4),
      I1 => huffman_ins_v2_hor_code_21_mux0003123_1950,
      I2 => huffman_ins_v2_hor_code_20_mux000346_1945,
      O => N413
    );
  huffman_ins_v2_hor_code_21_mux0003168_G : LUT4
    generic map(
      INIT => X"FFAE"
    )
    port map (
      I0 => huffman_ins_v2_N186,
      I1 => huffman_ins_v2_N78,
      I2 => huffman_ins_v2_mux_code_black_width(3),
      I3 => huffman_ins_v2_hor_code_21_mux000395_1957,
      O => N414
    );
  huffman_ins_v2_hor_code_3_mux000397 : MUXF5
    port map (
      I0 => N415,
      I1 => N416,
      S => huffman_ins_v2_horizontal_mode_part_2_2065,
      O => huffman_ins_v2_hor_code_3_mux000397_1995
    );
  huffman_ins_v2_hor_code_3_mux000397_F : LUT4
    generic map(
      INIT => X"A820"
    )
    port map (
      I0 => huffman_ins_v2_N40,
      I1 => huffman_ins_v2_a0_value_2_1510,
      I2 => huffman_ins_v2_code_black(3),
      I3 => huffman_ins_v2_code_white(3),
      O => N415
    );
  huffman_ins_v2_hor_code_3_mux000397_G : LUT4
    generic map(
      INIT => X"A820"
    )
    port map (
      I0 => huffman_ins_v2_N52,
      I1 => huffman_ins_v2_a0_value_2_1510,
      I2 => huffman_ins_v2_code_white(3),
      I3 => huffman_ins_v2_code_black(3),
      O => N416
    );
  huffman_ins_v2_hor_code_18_mux000328 : MUXF5
    port map (
      I0 => N417,
      I1 => N418,
      S => huffman_ins_v2_a0_value_2_1510,
      O => huffman_ins_v2_hor_code_18_mux000328_1921
    );
  huffman_ins_v2_hor_code_18_mux000328_F : LUT4
    generic map(
      INIT => X"0103"
    )
    port map (
      I0 => huffman_ins_v2_code_white_width(0),
      I1 => huffman_ins_v2_code_white_width(3),
      I2 => huffman_ins_v2_code_white_width(2),
      I3 => huffman_ins_v2_code_white_width(1),
      O => N417
    );
  huffman_ins_v2_hor_code_18_mux000328_G : LUT4
    generic map(
      INIT => X"0103"
    )
    port map (
      I0 => huffman_ins_v2_code_black_width(0),
      I1 => huffman_ins_v2_code_black_width(3),
      I2 => huffman_ins_v2_code_black_width(2),
      I3 => huffman_ins_v2_code_black_width(1),
      O => N418
    );
  fax4_ins_b2_mux0004_9_36 : MUXF5
    port map (
      I0 => N419,
      I1 => N420,
      S => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt(0),
      O => fax4_ins_b2_mux0004_9_36_1093
    );
  fax4_ins_b2_mux0004_9_36_F : LUT4
    generic map(
      INIT => X"AA2A"
    )
    port map (
      I0 => fax4_ins_N19,
      I1 => fax4_ins_mux_b1(3),
      I2 => fax4_ins_FIFO2_multi_read_ins_valid3_o_700,
      I3 => fax4_ins_FIFO2_multi_read_ins_data3_o(9),
      O => N419
    );
  fax4_ins_b2_mux0004_9_36_G : LUT4
    generic map(
      INIT => X"AA2A"
    )
    port map (
      I0 => fax4_ins_N19,
      I1 => fax4_ins_mux_b1(3),
      I2 => fax4_ins_FIFO1_multi_read_ins_valid3_o_458,
      I3 => fax4_ins_FIFO1_multi_read_ins_data3_o(9),
      O => N420
    );
  fax4_ins_b2_mux0004_8_33 : MUXF5
    port map (
      I0 => N421,
      I1 => N422,
      S => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt(0),
      O => fax4_ins_b2_mux0004_8_33_1090
    );
  fax4_ins_b2_mux0004_8_33_F : LUT4
    generic map(
      INIT => X"8000"
    )
    port map (
      I0 => fax4_ins_N19,
      I1 => fax4_ins_mux_b1(3),
      I2 => fax4_ins_FIFO2_multi_read_ins_valid3_o_700,
      I3 => fax4_ins_FIFO2_multi_read_ins_data3_o(8),
      O => N421
    );
  fax4_ins_b2_mux0004_8_33_G : LUT4
    generic map(
      INIT => X"8000"
    )
    port map (
      I0 => fax4_ins_N19,
      I1 => fax4_ins_mux_b1(3),
      I2 => fax4_ins_FIFO1_multi_read_ins_valid3_o_458,
      I3 => fax4_ins_FIFO1_multi_read_ins_data3_o(8),
      O => N422
    );
  fax4_ins_b2_mux0004_7_36 : MUXF5
    port map (
      I0 => N423,
      I1 => N424,
      S => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt(0),
      O => fax4_ins_b2_mux0004_7_36_1087
    );
  fax4_ins_b2_mux0004_7_36_F : LUT4
    generic map(
      INIT => X"AA2A"
    )
    port map (
      I0 => fax4_ins_N19,
      I1 => fax4_ins_mux_b1(3),
      I2 => fax4_ins_FIFO2_multi_read_ins_valid3_o_700,
      I3 => fax4_ins_FIFO2_multi_read_ins_data3_o(7),
      O => N423
    );
  fax4_ins_b2_mux0004_7_36_G : LUT4
    generic map(
      INIT => X"AA2A"
    )
    port map (
      I0 => fax4_ins_N19,
      I1 => fax4_ins_mux_b1(3),
      I2 => fax4_ins_FIFO1_multi_read_ins_valid3_o_458,
      I3 => fax4_ins_FIFO1_multi_read_ins_data3_o(7),
      O => N424
    );
  fax4_ins_b2_mux0004_6_36 : MUXF5
    port map (
      I0 => N425,
      I1 => N426,
      S => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt(0),
      O => fax4_ins_b2_mux0004_6_36_1084
    );
  fax4_ins_b2_mux0004_6_36_F : LUT4
    generic map(
      INIT => X"AA2A"
    )
    port map (
      I0 => fax4_ins_N19,
      I1 => fax4_ins_mux_b1(3),
      I2 => fax4_ins_FIFO2_multi_read_ins_valid3_o_700,
      I3 => fax4_ins_FIFO2_multi_read_ins_data3_o(6),
      O => N425
    );
  fax4_ins_b2_mux0004_6_36_G : LUT4
    generic map(
      INIT => X"AA2A"
    )
    port map (
      I0 => fax4_ins_N19,
      I1 => fax4_ins_mux_b1(3),
      I2 => fax4_ins_FIFO1_multi_read_ins_valid3_o_458,
      I3 => fax4_ins_FIFO1_multi_read_ins_data3_o(6),
      O => N426
    );
  fax4_ins_b2_mux0004_5_36 : MUXF5
    port map (
      I0 => N427,
      I1 => N428,
      S => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt(0),
      O => fax4_ins_b2_mux0004_5_36_1081
    );
  fax4_ins_b2_mux0004_5_36_F : LUT4
    generic map(
      INIT => X"AA2A"
    )
    port map (
      I0 => fax4_ins_N19,
      I1 => fax4_ins_mux_b1(3),
      I2 => fax4_ins_FIFO2_multi_read_ins_valid3_o_700,
      I3 => fax4_ins_FIFO2_multi_read_ins_data3_o(5),
      O => N427
    );
  fax4_ins_b2_mux0004_5_36_G : LUT4
    generic map(
      INIT => X"AA2A"
    )
    port map (
      I0 => fax4_ins_N19,
      I1 => fax4_ins_mux_b1(3),
      I2 => fax4_ins_FIFO1_multi_read_ins_valid3_o_458,
      I3 => fax4_ins_FIFO1_multi_read_ins_data3_o(5),
      O => N428
    );
  fax4_ins_b2_mux0004_4_36 : MUXF5
    port map (
      I0 => N429,
      I1 => N430,
      S => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt(0),
      O => fax4_ins_b2_mux0004_4_36_1078
    );
  fax4_ins_b2_mux0004_4_36_F : LUT4
    generic map(
      INIT => X"AA2A"
    )
    port map (
      I0 => fax4_ins_N19,
      I1 => fax4_ins_mux_b1(3),
      I2 => fax4_ins_FIFO2_multi_read_ins_valid3_o_700,
      I3 => fax4_ins_FIFO2_multi_read_ins_data3_o(4),
      O => N429
    );
  fax4_ins_b2_mux0004_4_36_G : LUT4
    generic map(
      INIT => X"AA2A"
    )
    port map (
      I0 => fax4_ins_N19,
      I1 => fax4_ins_mux_b1(3),
      I2 => fax4_ins_FIFO1_multi_read_ins_valid3_o_458,
      I3 => fax4_ins_FIFO1_multi_read_ins_data3_o(4),
      O => N430
    );
  fax4_ins_b2_mux0004_3_33 : MUXF5
    port map (
      I0 => N431,
      I1 => N432,
      S => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt(0),
      O => fax4_ins_b2_mux0004_3_33_1075
    );
  fax4_ins_b2_mux0004_3_33_F : LUT4
    generic map(
      INIT => X"8000"
    )
    port map (
      I0 => fax4_ins_N19,
      I1 => fax4_ins_mux_b1(3),
      I2 => fax4_ins_FIFO2_multi_read_ins_valid3_o_700,
      I3 => fax4_ins_FIFO2_multi_read_ins_data3_o(3),
      O => N431
    );
  fax4_ins_b2_mux0004_3_33_G : LUT4
    generic map(
      INIT => X"8000"
    )
    port map (
      I0 => fax4_ins_N19,
      I1 => fax4_ins_mux_b1(3),
      I2 => fax4_ins_FIFO1_multi_read_ins_valid3_o_458,
      I3 => fax4_ins_FIFO1_multi_read_ins_data3_o(3),
      O => N432
    );
  fax4_ins_b2_mux0004_2_33 : MUXF5
    port map (
      I0 => N433,
      I1 => N434,
      S => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt(0),
      O => fax4_ins_b2_mux0004_2_33_1072
    );
  fax4_ins_b2_mux0004_2_33_F : LUT4
    generic map(
      INIT => X"8000"
    )
    port map (
      I0 => fax4_ins_N19,
      I1 => fax4_ins_mux_b1(3),
      I2 => fax4_ins_FIFO2_multi_read_ins_valid3_o_700,
      I3 => fax4_ins_FIFO2_multi_read_ins_data3_o(2),
      O => N433
    );
  fax4_ins_b2_mux0004_2_33_G : LUT4
    generic map(
      INIT => X"8000"
    )
    port map (
      I0 => fax4_ins_N19,
      I1 => fax4_ins_mux_b1(3),
      I2 => fax4_ins_FIFO1_multi_read_ins_valid3_o_458,
      I3 => fax4_ins_FIFO1_multi_read_ins_data3_o(2),
      O => N434
    );
  fax4_ins_b2_mux0004_1_33 : MUXF5
    port map (
      I0 => N435,
      I1 => N436,
      S => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt(0),
      O => fax4_ins_b2_mux0004_1_33_1069
    );
  fax4_ins_b2_mux0004_1_33_F : LUT4
    generic map(
      INIT => X"8000"
    )
    port map (
      I0 => fax4_ins_N19,
      I1 => fax4_ins_mux_b1(3),
      I2 => fax4_ins_FIFO2_multi_read_ins_valid3_o_700,
      I3 => fax4_ins_FIFO2_multi_read_ins_data3_o(1),
      O => N435
    );
  fax4_ins_b2_mux0004_1_33_G : LUT4
    generic map(
      INIT => X"8000"
    )
    port map (
      I0 => fax4_ins_N19,
      I1 => fax4_ins_mux_b1(3),
      I2 => fax4_ins_FIFO1_multi_read_ins_valid3_o_458,
      I3 => fax4_ins_FIFO1_multi_read_ins_data3_o(1),
      O => N436
    );
  fax4_ins_b2_mux0004_0_36 : MUXF5
    port map (
      I0 => N437,
      I1 => N438,
      S => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt(0),
      O => fax4_ins_b2_mux0004_0_36_1066
    );
  fax4_ins_b2_mux0004_0_36_F : LUT4
    generic map(
      INIT => X"AA2A"
    )
    port map (
      I0 => fax4_ins_N19,
      I1 => fax4_ins_mux_b1(3),
      I2 => fax4_ins_FIFO2_multi_read_ins_valid3_o_700,
      I3 => fax4_ins_FIFO2_multi_read_ins_data3_o(0),
      O => N437
    );
  fax4_ins_b2_mux0004_0_36_G : LUT4
    generic map(
      INIT => X"AA2A"
    )
    port map (
      I0 => fax4_ins_N19,
      I1 => fax4_ins_mux_b1(3),
      I2 => fax4_ins_FIFO1_multi_read_ins_valid3_o_458,
      I3 => fax4_ins_FIFO1_multi_read_ins_data3_o(0),
      O => N438
    );
  fax4_ins_b2_to_white_mux000452 : MUXF5
    port map (
      I0 => N439,
      I1 => N440,
      S => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt(0),
      O => fax4_ins_b2_to_white_mux000452_1099
    );
  fax4_ins_b2_to_white_mux000452_F : LUT4
    generic map(
      INIT => X"AA2A"
    )
    port map (
      I0 => fax4_ins_N19,
      I1 => fax4_ins_mux_b1(3),
      I2 => fax4_ins_FIFO2_multi_read_ins_valid3_o_700,
      I3 => fax4_ins_FIFO2_multi_read_ins_to_white3_o_685,
      O => N439
    );
  fax4_ins_b2_to_white_mux000452_G : LUT4
    generic map(
      INIT => X"AA2A"
    )
    port map (
      I0 => fax4_ins_N19,
      I1 => fax4_ins_mux_b1(3),
      I2 => fax4_ins_FIFO1_multi_read_ins_valid3_o_458,
      I3 => fax4_ins_FIFO1_multi_read_ins_to_white3_o_443,
      O => N440
    );
  huffman_ins_v2_hor_code_12_mux0003249 : MUXF5
    port map (
      I0 => N441,
      I1 => N442,
      S => huffman_ins_v2_horizontal_mode_part_2_2065,
      O => huffman_ins_v2_hor_code_12_mux0003249_1847
    );
  huffman_ins_v2_hor_code_12_mux0003249_F : LUT4
    generic map(
      INIT => X"A820"
    )
    port map (
      I0 => huffman_ins_v2_N44,
      I1 => huffman_ins_v2_a0_value_2_1510,
      I2 => huffman_ins_v2_code_black(12),
      I3 => huffman_ins_v2_code_white(12),
      O => N441
    );
  huffman_ins_v2_hor_code_12_mux0003249_G : LUT4
    generic map(
      INIT => X"A820"
    )
    port map (
      I0 => huffman_ins_v2_N60,
      I1 => huffman_ins_v2_a0_value_2_1510,
      I2 => huffman_ins_v2_code_white(12),
      I3 => huffman_ins_v2_code_black(12),
      O => N442
    );
  huffman_ins_v2_hor_code_0_mux000352 : MUXF5
    port map (
      I0 => N443,
      I1 => N444,
      S => huffman_ins_v2_horizontal_mode_part_2_2065,
      O => huffman_ins_v2_hor_code_0_mux000352_1819
    );
  huffman_ins_v2_hor_code_0_mux000352_F : LUT4
    generic map(
      INIT => X"A820"
    )
    port map (
      I0 => huffman_ins_v2_N45,
      I1 => huffman_ins_v2_a0_value_2_1510,
      I2 => huffman_ins_v2_code_black(0),
      I3 => huffman_ins_v2_code_white(0),
      O => N443
    );
  huffman_ins_v2_hor_code_0_mux000352_G : LUT4
    generic map(
      INIT => X"A820"
    )
    port map (
      I0 => huffman_ins_v2_N16,
      I1 => huffman_ins_v2_a0_value_2_1510,
      I2 => huffman_ins_v2_code_white(0),
      I3 => huffman_ins_v2_code_black(0),
      O => N444
    );
  huffman_ins_v2_hor_code_25_mux000380 : MUXF5
    port map (
      I0 => N445,
      I1 => N446,
      S => huffman_ins_v2_horizontal_mode_part_2_2065,
      O => huffman_ins_v2_hor_code_25_mux000380_1982
    );
  huffman_ins_v2_hor_code_25_mux000380_F : LUT4
    generic map(
      INIT => X"EAAA"
    )
    port map (
      I0 => huffman_ins_v2_hor_code_25_mux000342_1981,
      I1 => huffman_ins_v2_Madd_hor_code_width_addsub0000_lut(2),
      I2 => huffman_ins_v2_Madd_hor_code_width_addsub0000_lut(3),
      I3 => huffman_ins_v2_Madd_hor_code_width_addsub0000_cy(1),
      O => N445
    );
  huffman_ins_v2_hor_code_25_mux000380_G : LUT4
    generic map(
      INIT => X"F7D7"
    )
    port map (
      I0 => huffman_ins_v2_hor_code_23_and0000,
      I1 => huffman_ins_v2_mux_code_black_width(1),
      I2 => huffman_ins_v2_mux_code_black_width(2),
      I3 => huffman_ins_v2_mux_code_black_width(0),
      O => N446
    );
  huffman_ins_v2_hor_code_23_mux000356 : MUXF5
    port map (
      I0 => N447,
      I1 => N448,
      S => huffman_ins_v2_horizontal_mode_part_2_2065,
      O => huffman_ins_v2_hor_code_23_mux000356_1969
    );
  huffman_ins_v2_hor_code_23_mux000356_F : LUT4
    generic map(
      INIT => X"FF01"
    )
    port map (
      I0 => huffman_ins_v2_mux_code_white_width(1),
      I1 => huffman_ins_v2_Madd_hor_code_width_addsub0000_cy(0),
      I2 => huffman_ins_v2_Madd_hor_code_width_addsub0000_lut(3),
      I3 => huffman_ins_v2_N3,
      O => N447
    );
  huffman_ins_v2_hor_code_23_mux000356_G : LUT3
    generic map(
      INIT => X"F7"
    )
    port map (
      I0 => huffman_ins_v2_mux_code_black_width(4),
      I1 => huffman_ins_v2_mux_code_black_width(3),
      I2 => huffman_ins_v2_N251,
      O => N448
    );
  huffman_ins_v2_hor_code_11_mux000321 : MUXF5
    port map (
      I0 => N449,
      I1 => N450,
      S => huffman_ins_v2_horizontal_mode_part_2_2065,
      O => huffman_ins_v2_hor_code_11_mux000321_1833
    );
  huffman_ins_v2_hor_code_11_mux000321_F : LUT4
    generic map(
      INIT => X"0001"
    )
    port map (
      I0 => huffman_ins_v2_Madd_hor_code_width_addsub0000_cy(0),
      I1 => huffman_ins_v2_Madd_hor_code_width_addsub0000_lut(2),
      I2 => huffman_ins_v2_Madd_hor_code_width_addsub0000_lut(4),
      I3 => huffman_ins_v2_mux_code_white_width(1),
      O => N449
    );
  huffman_ins_v2_hor_code_11_mux000321_G : LUT4
    generic map(
      INIT => X"0213"
    )
    port map (
      I0 => huffman_ins_v2_a0_value_2_1510,
      I1 => huffman_ins_v2_mux_code_black_width(4),
      I2 => huffman_ins_v2_code_black_width(2),
      I3 => huffman_ins_v2_code_white_width(2),
      O => N450
    );
  huffman_ins_v2_hor_code_11_mux0003129 : MUXF5
    port map (
      I0 => N451,
      I1 => N452,
      S => huffman_ins_v2_horizontal_mode_part_2_2065,
      O => huffman_ins_v2_hor_code_11_mux0003129_1831
    );
  huffman_ins_v2_hor_code_11_mux0003129_F : LUT4
    generic map(
      INIT => X"028A"
    )
    port map (
      I0 => huffman_ins_v2_hor_code_11_mux0003121,
      I1 => huffman_ins_v2_a0_value_2_1510,
      I2 => huffman_ins_v2_code_black_width(4),
      I3 => huffman_ins_v2_code_white_width(4),
      O => N451
    );
  huffman_ins_v2_hor_code_11_mux0003129_G : LUT4
    generic map(
      INIT => X"A820"
    )
    port map (
      I0 => huffman_ins_v2_N62,
      I1 => huffman_ins_v2_a0_value_2_1510,
      I2 => huffman_ins_v2_code_white(11),
      I3 => huffman_ins_v2_code_black(11),
      O => N452
    );
  fax4_ins_state_FSM_FFd2_In : MUXF5
    port map (
      I0 => N453,
      I1 => N454,
      S => fax4_ins_pix_changed_1319,
      O => fax4_ins_state_FSM_FFd2_In_1328
    );
  fax4_ins_state_FSM_FFd2_In_F : LUT4
    generic map(
      INIT => X"0C04"
    )
    port map (
      I0 => fax4_ins_EOL,
      I1 => fax4_ins_state_FSM_FFd2_1327,
      I2 => fax4_ins_pass_mode,
      I3 => fax4_ins_EOL_prev_230,
      O => N453
    );
  fax4_ins_state_FSM_FFd2_In_G : LUT3
    generic map(
      INIT => X"80"
    )
    port map (
      I0 => fax4_ins_state_FSM_FFd8_1338,
      I1 => fax4_ins_counter_xy_v2_ins_frame_valid_1206,
      I2 => fax4_ins_counter_xy_v2_ins_line_valid_1210,
      O => N454
    );
  huffman_ins_v2_hor_code_16_mux000359 : MUXF5
    port map (
      I0 => N455,
      I1 => N456,
      S => huffman_ins_v2_horizontal_mode_part_2_2065,
      O => huffman_ins_v2_hor_code_16_mux000359_1900
    );
  huffman_ins_v2_hor_code_16_mux000359_F : LUT4
    generic map(
      INIT => X"C877"
    )
    port map (
      I0 => huffman_ins_v2_mux_code_white_width(1),
      I1 => N361,
      I2 => huffman_ins_v2_Madd_hor_code_width_addsub0000_cy(0),
      I3 => huffman_ins_v2_Madd_hor_code_width_addsub0000_lut(4),
      O => N455
    );
  huffman_ins_v2_hor_code_16_mux000359_G : LUT4
    generic map(
      INIT => X"FFD5"
    )
    port map (
      I0 => huffman_ins_v2_N89,
      I1 => huffman_ins_v2_N251,
      I2 => huffman_ins_v2_mux_code_black_width(3),
      I3 => N12,
      O => N456
    );
  fax4_ins_mode_indicator_o_2_rstpot_SW0 : MUXF5
    port map (
      I0 => N457,
      I1 => N458,
      S => N167,
      O => N176
    );
  fax4_ins_mode_indicator_o_2_rstpot_SW0_F : LUT3
    generic map(
      INIT => X"5D"
    )
    port map (
      I0 => fax4_ins_mode_indicator_o(2),
      I1 => fax4_ins_EOL_prev_230,
      I2 => fax4_ins_EOL_prev_prev_231,
      O => N457
    );
  fax4_ins_mode_indicator_o_2_rstpot_SW0_G : LUT4
    generic map(
      INIT => X"FF72"
    )
    port map (
      I0 => fax4_ins_EOL_prev_230,
      I1 => fax4_ins_EOL_prev_prev_231,
      I2 => fax4_ins_EOL,
      I3 => fax4_ins_pix_changed_1319,
      O => N458
    );
  fax4_ins_mode_indicator_o_1_rstpot_SW0 : MUXF5
    port map (
      I0 => N459,
      I1 => N460,
      S => N167,
      O => N220
    );
  fax4_ins_mode_indicator_o_1_rstpot_SW0_F : LUT3
    generic map(
      INIT => X"5D"
    )
    port map (
      I0 => fax4_ins_mode_indicator_o(1),
      I1 => fax4_ins_EOL_prev_230,
      I2 => fax4_ins_EOL_prev_prev_231,
      O => N459
    );
  fax4_ins_mode_indicator_o_1_rstpot_SW0_G : LUT4
    generic map(
      INIT => X"FF72"
    )
    port map (
      I0 => fax4_ins_EOL_prev_230,
      I1 => fax4_ins_EOL_prev_prev_231,
      I2 => fax4_ins_EOL,
      I3 => fax4_ins_pix_changed_1319,
      O => N460
    );
  huffman_ins_v2_hor_code_3_mux000318 : MUXF5
    port map (
      I0 => N461,
      I1 => N462,
      S => huffman_ins_v2_horizontal_mode_part_2_2065,
      O => huffman_ins_v2_hor_code_3_mux000318_1991
    );
  huffman_ins_v2_hor_code_3_mux000318_F : LUT4
    generic map(
      INIT => X"FF04"
    )
    port map (
      I0 => huffman_ins_v2_Madd_hor_code_width_addsub0000_lut(4),
      I1 => huffman_ins_v2_hor_code_3_mux00033_1992,
      I2 => huffman_ins_v2_Madd_hor_code_width_addsub0000_lut(3),
      I3 => huffman_ins_v2_N166,
      O => N461
    );
  huffman_ins_v2_hor_code_3_mux000318_G : LUT4
    generic map(
      INIT => X"FF01"
    )
    port map (
      I0 => huffman_ins_v2_mux_code_black_width(3),
      I1 => huffman_ins_v2_mux_code_black_width(2),
      I2 => huffman_ins_v2_mux_code_black_width(4),
      I3 => huffman_ins_v2_N166,
      O => N462
    );
  huffman_ins_v2_hor_code_6_mux000310 : MUXF5
    port map (
      I0 => N463,
      I1 => N464,
      S => huffman_ins_v2_horizontal_mode_part_2_2065,
      O => huffman_ins_v2_hor_code_6_mux000310_2014
    );
  huffman_ins_v2_hor_code_6_mux000310_F : LUT4
    generic map(
      INIT => X"FF01"
    )
    port map (
      I0 => huffman_ins_v2_Madd_hor_code_width_addsub0000_lut(3),
      I1 => huffman_ins_v2_Madd_hor_code_width_addsub0000_lut(2),
      I2 => huffman_ins_v2_Madd_hor_code_width_addsub0000_lut(4),
      I3 => huffman_ins_v2_N166,
      O => N463
    );
  huffman_ins_v2_hor_code_6_mux000310_G : LUT4
    generic map(
      INIT => X"FF04"
    )
    port map (
      I0 => huffman_ins_v2_mux_code_black_width(4),
      I1 => huffman_ins_v2_N67,
      I2 => huffman_ins_v2_mux_code_black_width(3),
      I3 => huffman_ins_v2_N166,
      O => N464
    );
  huffman_ins_v2_Msub_run_length_white_addsub0000_lut_9_INV_0 : INV
    port map (
      I => fax4_ins_a1_o(9),
      O => huffman_ins_v2_Msub_run_length_white_addsub0000_lut(9)
    );
  huffman_ins_v2_Msub_run_length_white_addsub0000_lut_8_INV_0 : INV
    port map (
      I => fax4_ins_a1_o(8),
      O => huffman_ins_v2_Msub_run_length_white_addsub0000_lut(8)
    );
  huffman_ins_v2_Msub_run_length_white_addsub0000_lut_7_INV_0 : INV
    port map (
      I => fax4_ins_a1_o(7),
      O => huffman_ins_v2_Msub_run_length_white_addsub0000_lut(7)
    );
  huffman_ins_v2_Msub_run_length_white_addsub0000_lut_6_INV_0 : INV
    port map (
      I => fax4_ins_a1_o(6),
      O => huffman_ins_v2_Msub_run_length_white_addsub0000_lut(6)
    );
  huffman_ins_v2_Msub_run_length_white_addsub0000_lut_5_INV_0 : INV
    port map (
      I => fax4_ins_a1_o(5),
      O => huffman_ins_v2_Msub_run_length_white_addsub0000_lut(5)
    );
  huffman_ins_v2_Msub_run_length_white_addsub0000_lut_4_INV_0 : INV
    port map (
      I => fax4_ins_a1_o(4),
      O => huffman_ins_v2_Msub_run_length_white_addsub0000_lut(4)
    );
  huffman_ins_v2_Msub_run_length_white_addsub0000_lut_3_INV_0 : INV
    port map (
      I => fax4_ins_a1_o(3),
      O => huffman_ins_v2_Msub_run_length_white_addsub0000_lut(3)
    );
  huffman_ins_v2_Msub_run_length_white_addsub0000_lut_2_INV_0 : INV
    port map (
      I => fax4_ins_a1_o(2),
      O => huffman_ins_v2_Msub_run_length_white_addsub0000_lut(2)
    );
  huffman_ins_v2_Msub_run_length_white_addsub0000_lut_1_INV_0 : INV
    port map (
      I => fax4_ins_a1_o(1),
      O => huffman_ins_v2_Msub_run_length_white_addsub0000_lut(1)
    );
  fax4_ins_counter_xy_v2_ins_counter_x_ins_Madd_cnt_addsub0000_lut_0_INV_0 : INV
    port map (
      I => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(0),
      O => fax4_ins_counter_xy_v2_ins_counter_x_ins_Madd_cnt_addsub0000_lut(0)
    );
  fax4_ins_counter_xy_v2_ins_counter_y_ins_Madd_cnt_addsub0000_lut_0_INV_0 : INV
    port map (
      I => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt(0),
      O => fax4_ins_counter_xy_v2_ins_counter_y_ins_Madd_cnt_addsub0000_lut(0)
    );
  fax4_ins_FIFO1_multi_read_ins_Mcount_read_pos_lut_0_INV_0 : INV
    port map (
      I => fax4_ins_FIFO1_multi_read_ins_read_pos(0),
      O => fax4_ins_FIFO1_multi_read_ins_Mcount_read_pos_lut(0)
    );
  fax4_ins_FIFO1_multi_read_ins_Mcount_write_pos_lut_0_INV_0 : INV
    port map (
      I => fax4_ins_FIFO1_multi_read_ins_write_pos(0),
      O => fax4_ins_FIFO1_multi_read_ins_Mcount_write_pos_lut(0)
    );
  fax4_ins_FIFO2_multi_read_ins_Mcount_read_pos_lut_0_INV_0 : INV
    port map (
      I => fax4_ins_FIFO2_multi_read_ins_read_pos(0),
      O => fax4_ins_FIFO2_multi_read_ins_Mcount_read_pos_lut(0)
    );
  fax4_ins_FIFO2_multi_read_ins_Mcount_write_pos_lut_0_INV_0 : INV
    port map (
      I => fax4_ins_FIFO2_multi_read_ins_write_pos(0),
      O => fax4_ins_FIFO2_multi_read_ins_Mcount_write_pos_lut(0)
    );
  fax4_ins_Madd_fifo_rd_addsub0000_lut_0_INV_0 : INV
    port map (
      I => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(0),
      O => fax4_ins_Madd_fifo_rd_addsub0000_lut(0)
    );
  fax4_ins_pclk_not1_INV_0 : INV
    port map (
      I => pclk_i,
      O => fax4_ins_pclk_not
    );
  fax4_ins_a1b1_not0000_8_1_INV_0 : INV
    port map (
      I => fax4_ins_b1(8),
      O => fax4_ins_a1b1_not0000_8_Q
    );
  fax4_ins_a1b1_not0000_3_1_INV_0 : INV
    port map (
      I => fax4_ins_b1(3),
      O => fax4_ins_a1b1_not0000_3_Q
    );
  fax4_ins_a1b1_not0000_2_1_INV_0 : INV
    port map (
      I => fax4_ins_b1(2),
      O => fax4_ins_a1b1_not0000_2_Q
    );
  huffman_ins_v2_code_table_ins_Mrom_white_code_mux0001 : RAMB16_S18
    generic map(
      WRITE_MODE => "WRITE_FIRST",
      INIT_02 => X"080A08050804082D082C082B082A08290828081708160815081408130812081B",
      INIT => X"00000",
      INIT_00 => X"06350634060306080508050705140513040F040E040C040B0408040706070835",
      INIT_01 => X"081A08030802071807240713072B07280704070307170708070C0727062B062A",
      INIT_03 => X"083408330832084B084A085B085A08590858082508240855085408530852080B"
    )
    port map (
      CLK => pclk_i,
      EN => N1,
      SSR => NlwRenamedSig_OI_run_len_code_o(26),
      WE => NlwRenamedSig_OI_run_len_code_o(26),
      ADDR(9) => NlwRenamedSig_OI_run_len_code_o(26),
      ADDR(8) => NlwRenamedSig_OI_run_len_code_o(26),
      ADDR(7) => NlwRenamedSig_OI_run_len_code_o(26),
      ADDR(6) => NlwRenamedSig_OI_run_len_code_o(26),
      ADDR(5) => huffman_ins_v2_run_length_white(5),
      ADDR(4) => huffman_ins_v2_run_length_white(4),
      ADDR(3) => huffman_ins_v2_run_length_white(3),
      ADDR(2) => huffman_ins_v2_run_length_white(2),
      ADDR(1) => huffman_ins_v2_run_length_white(1),
      ADDR(0) => huffman_ins_v2_run_length_white(0),
      DI(15) => NlwRenamedSig_OI_run_len_code_o(26),
      DI(14) => NlwRenamedSig_OI_run_len_code_o(26),
      DI(13) => NlwRenamedSig_OI_run_len_code_o(26),
      DI(12) => NlwRenamedSig_OI_run_len_code_o(26),
      DI(11) => NlwRenamedSig_OI_run_len_code_o(26),
      DI(10) => NlwRenamedSig_OI_run_len_code_o(26),
      DI(9) => NlwRenamedSig_OI_run_len_code_o(26),
      DI(8) => NlwRenamedSig_OI_run_len_code_o(26),
      DI(7) => NlwRenamedSig_OI_run_len_code_o(26),
      DI(6) => NlwRenamedSig_OI_run_len_code_o(26),
      DI(5) => NlwRenamedSig_OI_run_len_code_o(26),
      DI(4) => NlwRenamedSig_OI_run_len_code_o(26),
      DI(3) => NlwRenamedSig_OI_run_len_code_o(26),
      DI(2) => NlwRenamedSig_OI_run_len_code_o(26),
      DI(1) => NlwRenamedSig_OI_run_len_code_o(26),
      DI(0) => NlwRenamedSig_OI_run_len_code_o(26),
      DIP(1) => NlwRenamedSig_OI_run_len_code_o(26),
      DIP(0) => NlwRenamedSig_OI_run_len_code_o(26),
      DO(15) => NLW_huffman_ins_v2_code_table_ins_Mrom_white_code_mux0001_DO_15_UNCONNECTED,
      DO(14) => NLW_huffman_ins_v2_code_table_ins_Mrom_white_code_mux0001_DO_14_UNCONNECTED,
      DO(13) => NLW_huffman_ins_v2_code_table_ins_Mrom_white_code_mux0001_DO_13_UNCONNECTED,
      DO(12) => NLW_huffman_ins_v2_code_table_ins_Mrom_white_code_mux0001_DO_12_UNCONNECTED,
      DO(11) => huffman_ins_v2_codetab_ter_white_width(3),
      DO(10) => huffman_ins_v2_codetab_ter_white_width(2),
      DO(9) => huffman_ins_v2_codetab_ter_white_width(1),
      DO(8) => huffman_ins_v2_codetab_ter_white_width(0),
      DO(7) => huffman_ins_v2_ter_white_code(7),
      DO(6) => huffman_ins_v2_ter_white_code(6),
      DO(5) => huffman_ins_v2_ter_white_code(5),
      DO(4) => huffman_ins_v2_ter_white_code(4),
      DO(3) => huffman_ins_v2_ter_white_code(3),
      DO(2) => huffman_ins_v2_ter_white_code(2),
      DO(1) => huffman_ins_v2_ter_white_code(1),
      DO(0) => huffman_ins_v2_ter_white_code(0),
      DOP(1) => NLW_huffman_ins_v2_code_table_ins_Mrom_white_code_mux0001_DOP_1_UNCONNECTED,
      DOP(0) => NLW_huffman_ins_v2_code_table_ins_Mrom_white_code_mux0001_DOP_0_UNCONNECTED
    );
  huffman_ins_v2_code_table_ins_Mrom_black_code_mux0001 : RAMB16_S18
    generic map(
      WRITE_MODE => "WRITE_FIRST",
      INIT_02 => X"C057C056C055C054C0DBC0DAC06DC06CC0D7C0D6C0D5C0D4C0D3C0D2C06BC06A",
      INIT => X"00000",
      INIT_00 => X"901880078004700770057004600460055003400240033003200220033002A037",
      INIT_01 => X"C069C068C0CDC0CCC0CBC0CAB018B017B028B037B06CB068B067A008A018A017",
      INIT_03 => X"C067C066C05AC02CC02BC059C058C028C027C038C037C024C053C052C065C064"
    )
    port map (
      CLK => pclk_i,
      EN => N1,
      SSR => NlwRenamedSig_OI_run_len_code_o(26),
      WE => NlwRenamedSig_OI_run_len_code_o(26),
      ADDR(9) => NlwRenamedSig_OI_run_len_code_o(26),
      ADDR(8) => NlwRenamedSig_OI_run_len_code_o(26),
      ADDR(7) => NlwRenamedSig_OI_run_len_code_o(26),
      ADDR(6) => NlwRenamedSig_OI_run_len_code_o(26),
      ADDR(5) => huffman_ins_v2_run_length_black(5),
      ADDR(4) => huffman_ins_v2_run_length_black(4),
      ADDR(3) => huffman_ins_v2_run_length_black(3),
      ADDR(2) => huffman_ins_v2_run_length_black(2),
      ADDR(1) => huffman_ins_v2_run_length_black(1),
      ADDR(0) => huffman_ins_v2_run_length_black(0),
      DI(15) => NlwRenamedSig_OI_run_len_code_o(26),
      DI(14) => NlwRenamedSig_OI_run_len_code_o(26),
      DI(13) => NlwRenamedSig_OI_run_len_code_o(26),
      DI(12) => NlwRenamedSig_OI_run_len_code_o(26),
      DI(11) => NlwRenamedSig_OI_run_len_code_o(26),
      DI(10) => NlwRenamedSig_OI_run_len_code_o(26),
      DI(9) => NlwRenamedSig_OI_run_len_code_o(26),
      DI(8) => NlwRenamedSig_OI_run_len_code_o(26),
      DI(7) => NlwRenamedSig_OI_run_len_code_o(26),
      DI(6) => NlwRenamedSig_OI_run_len_code_o(26),
      DI(5) => NlwRenamedSig_OI_run_len_code_o(26),
      DI(4) => NlwRenamedSig_OI_run_len_code_o(26),
      DI(3) => NlwRenamedSig_OI_run_len_code_o(26),
      DI(2) => NlwRenamedSig_OI_run_len_code_o(26),
      DI(1) => NlwRenamedSig_OI_run_len_code_o(26),
      DI(0) => NlwRenamedSig_OI_run_len_code_o(26),
      DIP(1) => NlwRenamedSig_OI_run_len_code_o(26),
      DIP(0) => NlwRenamedSig_OI_run_len_code_o(26),
      DO(15) => huffman_ins_v2_codetab_ter_black_width(3),
      DO(14) => huffman_ins_v2_codetab_ter_black_width(2),
      DO(13) => huffman_ins_v2_codetab_ter_black_width(1),
      DO(12) => huffman_ins_v2_codetab_ter_black_width(0),
      DO(11) => huffman_ins_v2_ter_black_code(11),
      DO(10) => huffman_ins_v2_ter_black_code(10),
      DO(9) => huffman_ins_v2_ter_black_code(9),
      DO(8) => huffman_ins_v2_ter_black_code(8),
      DO(7) => huffman_ins_v2_ter_black_code(7),
      DO(6) => huffman_ins_v2_ter_black_code(6),
      DO(5) => huffman_ins_v2_ter_black_code(5),
      DO(4) => huffman_ins_v2_ter_black_code(4),
      DO(3) => huffman_ins_v2_ter_black_code(3),
      DO(2) => huffman_ins_v2_ter_black_code(2),
      DO(1) => huffman_ins_v2_ter_black_code(1),
      DO(0) => huffman_ins_v2_ter_black_code(0),
      DOP(1) => NLW_huffman_ins_v2_code_table_ins_Mrom_black_code_mux0001_DOP_1_UNCONNECTED,
      DOP(0) => NLW_huffman_ins_v2_code_table_ins_Mrom_black_code_mux0001_DOP_0_UNCONNECTED
    );
  fax4_ins_FIFO1_multi_read_ins_RAM_ins_Mram_mem : RAMB16_S18_S18
    generic map(
      WRITE_MODE_A => "READ_FIRST",
      WRITE_MODE_B => "WRITE_FIRST",
      INIT_B => X"00000"
    )
    port map (
      CLKA => fax4_ins_pclk_not,
      CLKB => fax4_ins_pclk_not,
      ENA => N1,
      ENB => fax4_ins_FIFO1_multi_read_ins_mem_rd_387,
      SSRA => NlwRenamedSig_OI_run_len_code_o(26),
      SSRB => NlwRenamedSig_OI_run_len_code_o(26),
      WEA => fax4_ins_FIFO1_multi_read_ins_wr_459,
      WEB => NlwRenamedSig_OI_run_len_code_o(26),
      ADDRA(9) => fax4_ins_FIFO1_multi_read_ins_write_pos(9),
      ADDRA(8) => fax4_ins_FIFO1_multi_read_ins_write_pos(8),
      ADDRA(7) => fax4_ins_FIFO1_multi_read_ins_write_pos(7),
      ADDRA(6) => fax4_ins_FIFO1_multi_read_ins_write_pos(6),
      ADDRA(5) => fax4_ins_FIFO1_multi_read_ins_write_pos(5),
      ADDRA(4) => fax4_ins_FIFO1_multi_read_ins_write_pos(4),
      ADDRA(3) => fax4_ins_FIFO1_multi_read_ins_write_pos(3),
      ADDRA(2) => fax4_ins_FIFO1_multi_read_ins_write_pos(2),
      ADDRA(1) => fax4_ins_FIFO1_multi_read_ins_write_pos(1),
      ADDRA(0) => fax4_ins_FIFO1_multi_read_ins_write_pos(0),
      ADDRB(9) => fax4_ins_FIFO1_multi_read_ins_read_pos(9),
      ADDRB(8) => fax4_ins_FIFO1_multi_read_ins_read_pos(8),
      ADDRB(7) => fax4_ins_FIFO1_multi_read_ins_read_pos(7),
      ADDRB(6) => fax4_ins_FIFO1_multi_read_ins_read_pos(6),
      ADDRB(5) => fax4_ins_FIFO1_multi_read_ins_read_pos(5),
      ADDRB(4) => fax4_ins_FIFO1_multi_read_ins_read_pos(4),
      ADDRB(3) => fax4_ins_FIFO1_multi_read_ins_read_pos(3),
      ADDRB(2) => fax4_ins_FIFO1_multi_read_ins_read_pos(2),
      ADDRB(1) => fax4_ins_FIFO1_multi_read_ins_read_pos(1),
      ADDRB(0) => fax4_ins_FIFO1_multi_read_ins_read_pos(0),
      DIA(15) => NlwRenamedSig_OI_run_len_code_o(26),
      DIA(14) => NlwRenamedSig_OI_run_len_code_o(26),
      DIA(13) => NlwRenamedSig_OI_run_len_code_o(26),
      DIA(12) => NlwRenamedSig_OI_run_len_code_o(26),
      DIA(11) => NlwRenamedSig_OI_run_len_code_o(26),
      DIA(10) => fax4_ins_to_white_1349,
      DIA(9) => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(9),
      DIA(8) => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(8),
      DIA(7) => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(7),
      DIA(6) => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(6),
      DIA(5) => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(5),
      DIA(4) => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(4),
      DIA(3) => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(3),
      DIA(2) => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(2),
      DIA(1) => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(1),
      DIA(0) => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(0),
      DIB(15) => NLW_fax4_ins_FIFO1_multi_read_ins_RAM_ins_Mram_mem_DIB_15_UNCONNECTED,
      DIB(14) => NLW_fax4_ins_FIFO1_multi_read_ins_RAM_ins_Mram_mem_DIB_14_UNCONNECTED,
      DIB(13) => NLW_fax4_ins_FIFO1_multi_read_ins_RAM_ins_Mram_mem_DIB_13_UNCONNECTED,
      DIB(12) => NLW_fax4_ins_FIFO1_multi_read_ins_RAM_ins_Mram_mem_DIB_12_UNCONNECTED,
      DIB(11) => NLW_fax4_ins_FIFO1_multi_read_ins_RAM_ins_Mram_mem_DIB_11_UNCONNECTED,
      DIB(10) => NLW_fax4_ins_FIFO1_multi_read_ins_RAM_ins_Mram_mem_DIB_10_UNCONNECTED,
      DIB(9) => NLW_fax4_ins_FIFO1_multi_read_ins_RAM_ins_Mram_mem_DIB_9_UNCONNECTED,
      DIB(8) => NLW_fax4_ins_FIFO1_multi_read_ins_RAM_ins_Mram_mem_DIB_8_UNCONNECTED,
      DIB(7) => NLW_fax4_ins_FIFO1_multi_read_ins_RAM_ins_Mram_mem_DIB_7_UNCONNECTED,
      DIB(6) => NLW_fax4_ins_FIFO1_multi_read_ins_RAM_ins_Mram_mem_DIB_6_UNCONNECTED,
      DIB(5) => NLW_fax4_ins_FIFO1_multi_read_ins_RAM_ins_Mram_mem_DIB_5_UNCONNECTED,
      DIB(4) => NLW_fax4_ins_FIFO1_multi_read_ins_RAM_ins_Mram_mem_DIB_4_UNCONNECTED,
      DIB(3) => NLW_fax4_ins_FIFO1_multi_read_ins_RAM_ins_Mram_mem_DIB_3_UNCONNECTED,
      DIB(2) => NLW_fax4_ins_FIFO1_multi_read_ins_RAM_ins_Mram_mem_DIB_2_UNCONNECTED,
      DIB(1) => NLW_fax4_ins_FIFO1_multi_read_ins_RAM_ins_Mram_mem_DIB_1_UNCONNECTED,
      DIB(0) => NLW_fax4_ins_FIFO1_multi_read_ins_RAM_ins_Mram_mem_DIB_0_UNCONNECTED,
      DIPA(1) => NlwRenamedSig_OI_run_len_code_o(26),
      DIPA(0) => NlwRenamedSig_OI_run_len_code_o(26),
      DIPB(1) => NLW_fax4_ins_FIFO1_multi_read_ins_RAM_ins_Mram_mem_DIPB_1_UNCONNECTED,
      DIPB(0) => NLW_fax4_ins_FIFO1_multi_read_ins_RAM_ins_Mram_mem_DIPB_0_UNCONNECTED,
      DOA(15) => NLW_fax4_ins_FIFO1_multi_read_ins_RAM_ins_Mram_mem_DOA_15_UNCONNECTED,
      DOA(14) => NLW_fax4_ins_FIFO1_multi_read_ins_RAM_ins_Mram_mem_DOA_14_UNCONNECTED,
      DOA(13) => NLW_fax4_ins_FIFO1_multi_read_ins_RAM_ins_Mram_mem_DOA_13_UNCONNECTED,
      DOA(12) => NLW_fax4_ins_FIFO1_multi_read_ins_RAM_ins_Mram_mem_DOA_12_UNCONNECTED,
      DOA(11) => NLW_fax4_ins_FIFO1_multi_read_ins_RAM_ins_Mram_mem_DOA_11_UNCONNECTED,
      DOA(10) => NLW_fax4_ins_FIFO1_multi_read_ins_RAM_ins_Mram_mem_DOA_10_UNCONNECTED,
      DOA(9) => NLW_fax4_ins_FIFO1_multi_read_ins_RAM_ins_Mram_mem_DOA_9_UNCONNECTED,
      DOA(8) => NLW_fax4_ins_FIFO1_multi_read_ins_RAM_ins_Mram_mem_DOA_8_UNCONNECTED,
      DOA(7) => NLW_fax4_ins_FIFO1_multi_read_ins_RAM_ins_Mram_mem_DOA_7_UNCONNECTED,
      DOA(6) => NLW_fax4_ins_FIFO1_multi_read_ins_RAM_ins_Mram_mem_DOA_6_UNCONNECTED,
      DOA(5) => NLW_fax4_ins_FIFO1_multi_read_ins_RAM_ins_Mram_mem_DOA_5_UNCONNECTED,
      DOA(4) => NLW_fax4_ins_FIFO1_multi_read_ins_RAM_ins_Mram_mem_DOA_4_UNCONNECTED,
      DOA(3) => NLW_fax4_ins_FIFO1_multi_read_ins_RAM_ins_Mram_mem_DOA_3_UNCONNECTED,
      DOA(2) => NLW_fax4_ins_FIFO1_multi_read_ins_RAM_ins_Mram_mem_DOA_2_UNCONNECTED,
      DOA(1) => NLW_fax4_ins_FIFO1_multi_read_ins_RAM_ins_Mram_mem_DOA_1_UNCONNECTED,
      DOA(0) => NLW_fax4_ins_FIFO1_multi_read_ins_RAM_ins_Mram_mem_DOA_0_UNCONNECTED,
      DOPA(1) => NLW_fax4_ins_FIFO1_multi_read_ins_RAM_ins_Mram_mem_DOPA_1_UNCONNECTED,
      DOPA(0) => NLW_fax4_ins_FIFO1_multi_read_ins_RAM_ins_Mram_mem_DOPA_0_UNCONNECTED,
      DOB(15) => NLW_fax4_ins_FIFO1_multi_read_ins_RAM_ins_Mram_mem_DOB_15_UNCONNECTED,
      DOB(14) => NLW_fax4_ins_FIFO1_multi_read_ins_RAM_ins_Mram_mem_DOB_14_UNCONNECTED,
      DOB(13) => NLW_fax4_ins_FIFO1_multi_read_ins_RAM_ins_Mram_mem_DOB_13_UNCONNECTED,
      DOB(12) => NLW_fax4_ins_FIFO1_multi_read_ins_RAM_ins_Mram_mem_DOB_12_UNCONNECTED,
      DOB(11) => NLW_fax4_ins_FIFO1_multi_read_ins_RAM_ins_Mram_mem_DOB_11_UNCONNECTED,
      DOB(10) => fax4_ins_FIFO1_multi_read_ins_mem_data_out(10),
      DOB(9) => fax4_ins_FIFO1_multi_read_ins_mem_data_out(9),
      DOB(8) => fax4_ins_FIFO1_multi_read_ins_mem_data_out(8),
      DOB(7) => fax4_ins_FIFO1_multi_read_ins_mem_data_out(7),
      DOB(6) => fax4_ins_FIFO1_multi_read_ins_mem_data_out(6),
      DOB(5) => fax4_ins_FIFO1_multi_read_ins_mem_data_out(5),
      DOB(4) => fax4_ins_FIFO1_multi_read_ins_mem_data_out(4),
      DOB(3) => fax4_ins_FIFO1_multi_read_ins_mem_data_out(3),
      DOB(2) => fax4_ins_FIFO1_multi_read_ins_mem_data_out(2),
      DOB(1) => fax4_ins_FIFO1_multi_read_ins_mem_data_out(1),
      DOB(0) => fax4_ins_FIFO1_multi_read_ins_mem_data_out(0),
      DOPB(1) => NLW_fax4_ins_FIFO1_multi_read_ins_RAM_ins_Mram_mem_DOPB_1_UNCONNECTED,
      DOPB(0) => NLW_fax4_ins_FIFO1_multi_read_ins_RAM_ins_Mram_mem_DOPB_0_UNCONNECTED
    );
  fax4_ins_FIFO2_multi_read_ins_RAM_ins_Mram_mem : RAMB16_S18_S18
    generic map(
      WRITE_MODE_A => "READ_FIRST",
      WRITE_MODE_B => "WRITE_FIRST",
      INIT_B => X"00000"
    )
    port map (
      CLKA => fax4_ins_pclk_not,
      CLKB => fax4_ins_pclk_not,
      ENA => N1,
      ENB => fax4_ins_FIFO2_multi_read_ins_mem_rd_628,
      SSRA => NlwRenamedSig_OI_run_len_code_o(26),
      SSRB => NlwRenamedSig_OI_run_len_code_o(26),
      WEA => fax4_ins_FIFO2_multi_read_ins_wr,
      WEB => NlwRenamedSig_OI_run_len_code_o(26),
      ADDRA(9) => fax4_ins_FIFO2_multi_read_ins_write_pos(9),
      ADDRA(8) => fax4_ins_FIFO2_multi_read_ins_write_pos(8),
      ADDRA(7) => fax4_ins_FIFO2_multi_read_ins_write_pos(7),
      ADDRA(6) => fax4_ins_FIFO2_multi_read_ins_write_pos(6),
      ADDRA(5) => fax4_ins_FIFO2_multi_read_ins_write_pos(5),
      ADDRA(4) => fax4_ins_FIFO2_multi_read_ins_write_pos(4),
      ADDRA(3) => fax4_ins_FIFO2_multi_read_ins_write_pos(3),
      ADDRA(2) => fax4_ins_FIFO2_multi_read_ins_write_pos(2),
      ADDRA(1) => fax4_ins_FIFO2_multi_read_ins_write_pos(1),
      ADDRA(0) => fax4_ins_FIFO2_multi_read_ins_write_pos(0),
      ADDRB(9) => fax4_ins_FIFO2_multi_read_ins_read_pos(9),
      ADDRB(8) => fax4_ins_FIFO2_multi_read_ins_read_pos(8),
      ADDRB(7) => fax4_ins_FIFO2_multi_read_ins_read_pos(7),
      ADDRB(6) => fax4_ins_FIFO2_multi_read_ins_read_pos(6),
      ADDRB(5) => fax4_ins_FIFO2_multi_read_ins_read_pos(5),
      ADDRB(4) => fax4_ins_FIFO2_multi_read_ins_read_pos(4),
      ADDRB(3) => fax4_ins_FIFO2_multi_read_ins_read_pos(3),
      ADDRB(2) => fax4_ins_FIFO2_multi_read_ins_read_pos(2),
      ADDRB(1) => fax4_ins_FIFO2_multi_read_ins_read_pos(1),
      ADDRB(0) => fax4_ins_FIFO2_multi_read_ins_read_pos(0),
      DIA(15) => NlwRenamedSig_OI_run_len_code_o(26),
      DIA(14) => NlwRenamedSig_OI_run_len_code_o(26),
      DIA(13) => NlwRenamedSig_OI_run_len_code_o(26),
      DIA(12) => NlwRenamedSig_OI_run_len_code_o(26),
      DIA(11) => NlwRenamedSig_OI_run_len_code_o(26),
      DIA(10) => fax4_ins_to_white_1349,
      DIA(9) => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(9),
      DIA(8) => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(8),
      DIA(7) => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(7),
      DIA(6) => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(6),
      DIA(5) => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(5),
      DIA(4) => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(4),
      DIA(3) => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(3),
      DIA(2) => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(2),
      DIA(1) => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(1),
      DIA(0) => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_x_ins_cnt(0),
      DIB(15) => NLW_fax4_ins_FIFO2_multi_read_ins_RAM_ins_Mram_mem_DIB_15_UNCONNECTED,
      DIB(14) => NLW_fax4_ins_FIFO2_multi_read_ins_RAM_ins_Mram_mem_DIB_14_UNCONNECTED,
      DIB(13) => NLW_fax4_ins_FIFO2_multi_read_ins_RAM_ins_Mram_mem_DIB_13_UNCONNECTED,
      DIB(12) => NLW_fax4_ins_FIFO2_multi_read_ins_RAM_ins_Mram_mem_DIB_12_UNCONNECTED,
      DIB(11) => NLW_fax4_ins_FIFO2_multi_read_ins_RAM_ins_Mram_mem_DIB_11_UNCONNECTED,
      DIB(10) => NLW_fax4_ins_FIFO2_multi_read_ins_RAM_ins_Mram_mem_DIB_10_UNCONNECTED,
      DIB(9) => NLW_fax4_ins_FIFO2_multi_read_ins_RAM_ins_Mram_mem_DIB_9_UNCONNECTED,
      DIB(8) => NLW_fax4_ins_FIFO2_multi_read_ins_RAM_ins_Mram_mem_DIB_8_UNCONNECTED,
      DIB(7) => NLW_fax4_ins_FIFO2_multi_read_ins_RAM_ins_Mram_mem_DIB_7_UNCONNECTED,
      DIB(6) => NLW_fax4_ins_FIFO2_multi_read_ins_RAM_ins_Mram_mem_DIB_6_UNCONNECTED,
      DIB(5) => NLW_fax4_ins_FIFO2_multi_read_ins_RAM_ins_Mram_mem_DIB_5_UNCONNECTED,
      DIB(4) => NLW_fax4_ins_FIFO2_multi_read_ins_RAM_ins_Mram_mem_DIB_4_UNCONNECTED,
      DIB(3) => NLW_fax4_ins_FIFO2_multi_read_ins_RAM_ins_Mram_mem_DIB_3_UNCONNECTED,
      DIB(2) => NLW_fax4_ins_FIFO2_multi_read_ins_RAM_ins_Mram_mem_DIB_2_UNCONNECTED,
      DIB(1) => NLW_fax4_ins_FIFO2_multi_read_ins_RAM_ins_Mram_mem_DIB_1_UNCONNECTED,
      DIB(0) => NLW_fax4_ins_FIFO2_multi_read_ins_RAM_ins_Mram_mem_DIB_0_UNCONNECTED,
      DIPA(1) => NlwRenamedSig_OI_run_len_code_o(26),
      DIPA(0) => NlwRenamedSig_OI_run_len_code_o(26),
      DIPB(1) => NLW_fax4_ins_FIFO2_multi_read_ins_RAM_ins_Mram_mem_DIPB_1_UNCONNECTED,
      DIPB(0) => NLW_fax4_ins_FIFO2_multi_read_ins_RAM_ins_Mram_mem_DIPB_0_UNCONNECTED,
      DOA(15) => NLW_fax4_ins_FIFO2_multi_read_ins_RAM_ins_Mram_mem_DOA_15_UNCONNECTED,
      DOA(14) => NLW_fax4_ins_FIFO2_multi_read_ins_RAM_ins_Mram_mem_DOA_14_UNCONNECTED,
      DOA(13) => NLW_fax4_ins_FIFO2_multi_read_ins_RAM_ins_Mram_mem_DOA_13_UNCONNECTED,
      DOA(12) => NLW_fax4_ins_FIFO2_multi_read_ins_RAM_ins_Mram_mem_DOA_12_UNCONNECTED,
      DOA(11) => NLW_fax4_ins_FIFO2_multi_read_ins_RAM_ins_Mram_mem_DOA_11_UNCONNECTED,
      DOA(10) => NLW_fax4_ins_FIFO2_multi_read_ins_RAM_ins_Mram_mem_DOA_10_UNCONNECTED,
      DOA(9) => NLW_fax4_ins_FIFO2_multi_read_ins_RAM_ins_Mram_mem_DOA_9_UNCONNECTED,
      DOA(8) => NLW_fax4_ins_FIFO2_multi_read_ins_RAM_ins_Mram_mem_DOA_8_UNCONNECTED,
      DOA(7) => NLW_fax4_ins_FIFO2_multi_read_ins_RAM_ins_Mram_mem_DOA_7_UNCONNECTED,
      DOA(6) => NLW_fax4_ins_FIFO2_multi_read_ins_RAM_ins_Mram_mem_DOA_6_UNCONNECTED,
      DOA(5) => NLW_fax4_ins_FIFO2_multi_read_ins_RAM_ins_Mram_mem_DOA_5_UNCONNECTED,
      DOA(4) => NLW_fax4_ins_FIFO2_multi_read_ins_RAM_ins_Mram_mem_DOA_4_UNCONNECTED,
      DOA(3) => NLW_fax4_ins_FIFO2_multi_read_ins_RAM_ins_Mram_mem_DOA_3_UNCONNECTED,
      DOA(2) => NLW_fax4_ins_FIFO2_multi_read_ins_RAM_ins_Mram_mem_DOA_2_UNCONNECTED,
      DOA(1) => NLW_fax4_ins_FIFO2_multi_read_ins_RAM_ins_Mram_mem_DOA_1_UNCONNECTED,
      DOA(0) => NLW_fax4_ins_FIFO2_multi_read_ins_RAM_ins_Mram_mem_DOA_0_UNCONNECTED,
      DOPA(1) => NLW_fax4_ins_FIFO2_multi_read_ins_RAM_ins_Mram_mem_DOPA_1_UNCONNECTED,
      DOPA(0) => NLW_fax4_ins_FIFO2_multi_read_ins_RAM_ins_Mram_mem_DOPA_0_UNCONNECTED,
      DOB(15) => NLW_fax4_ins_FIFO2_multi_read_ins_RAM_ins_Mram_mem_DOB_15_UNCONNECTED,
      DOB(14) => NLW_fax4_ins_FIFO2_multi_read_ins_RAM_ins_Mram_mem_DOB_14_UNCONNECTED,
      DOB(13) => NLW_fax4_ins_FIFO2_multi_read_ins_RAM_ins_Mram_mem_DOB_13_UNCONNECTED,
      DOB(12) => NLW_fax4_ins_FIFO2_multi_read_ins_RAM_ins_Mram_mem_DOB_12_UNCONNECTED,
      DOB(11) => NLW_fax4_ins_FIFO2_multi_read_ins_RAM_ins_Mram_mem_DOB_11_UNCONNECTED,
      DOB(10) => fax4_ins_FIFO2_multi_read_ins_mem_data_out(10),
      DOB(9) => fax4_ins_FIFO2_multi_read_ins_mem_data_out(9),
      DOB(8) => fax4_ins_FIFO2_multi_read_ins_mem_data_out(8),
      DOB(7) => fax4_ins_FIFO2_multi_read_ins_mem_data_out(7),
      DOB(6) => fax4_ins_FIFO2_multi_read_ins_mem_data_out(6),
      DOB(5) => fax4_ins_FIFO2_multi_read_ins_mem_data_out(5),
      DOB(4) => fax4_ins_FIFO2_multi_read_ins_mem_data_out(4),
      DOB(3) => fax4_ins_FIFO2_multi_read_ins_mem_data_out(3),
      DOB(2) => fax4_ins_FIFO2_multi_read_ins_mem_data_out(2),
      DOB(1) => fax4_ins_FIFO2_multi_read_ins_mem_data_out(1),
      DOB(0) => fax4_ins_FIFO2_multi_read_ins_mem_data_out(0),
      DOPB(1) => NLW_fax4_ins_FIFO2_multi_read_ins_RAM_ins_Mram_mem_DOPB_1_UNCONNECTED,
      DOPB(0) => NLW_fax4_ins_FIFO2_multi_read_ins_RAM_ins_Mram_mem_DOPB_0_UNCONNECTED
    );
  huffman_ins_v2_code_white_4_mux0000281 : LUT4
    generic map(
      INIT => X"F888"
    )
    port map (
      I0 => huffman_ins_v2_code_white(4),
      I1 => huffman_ins_v2_code_white_8_or0000,
      I2 => huffman_ins_v2_ter_white_code(4),
      I3 => huffman_ins_v2_code_white_4_mux000016_1765,
      O => huffman_ins_v2_code_white_4_mux0000281_1767
    );
  huffman_ins_v2_code_white_4_mux0000282 : LUT4
    generic map(
      INIT => X"F888"
    )
    port map (
      I0 => huffman_ins_v2_code_white(4),
      I1 => huffman_ins_v2_code_white_8_or0000,
      I2 => huffman_ins_v2_code_table_ins_makeup_white(0),
      I3 => huffman_ins_v2_code_white_4_mux000016_1765,
      O => huffman_ins_v2_code_white_4_mux0000282_1768
    );
  huffman_ins_v2_code_white_4_mux000028_f5 : MUXF5
    port map (
      I0 => huffman_ins_v2_code_white_4_mux0000282_1768,
      I1 => huffman_ins_v2_code_white_4_mux0000281_1767,
      S => huffman_ins_v2_codetab_ter_white_width(0),
      O => huffman_ins_v2_code_white_4_mux000028
    );
  huffman_ins_v2_code_white_5_mux0000281 : LUT4
    generic map(
      INIT => X"F888"
    )
    port map (
      I0 => huffman_ins_v2_code_white(5),
      I1 => huffman_ins_v2_code_white_8_or0000,
      I2 => huffman_ins_v2_code_table_ins_makeup_white(0),
      I3 => huffman_ins_v2_code_white_4_mux000016_1765,
      O => huffman_ins_v2_code_white_5_mux0000281_1772
    );
  huffman_ins_v2_code_white_5_mux0000282 : LUT4
    generic map(
      INIT => X"F888"
    )
    port map (
      I0 => huffman_ins_v2_code_white(5),
      I1 => huffman_ins_v2_code_white_8_or0000,
      I2 => huffman_ins_v2_code_table_ins_makeup_white(1),
      I3 => huffman_ins_v2_code_white_4_mux000016_1765,
      O => huffman_ins_v2_code_white_5_mux0000282_1773
    );
  huffman_ins_v2_code_white_5_mux000028_f5 : MUXF5
    port map (
      I0 => huffman_ins_v2_code_white_5_mux0000282_1773,
      I1 => huffman_ins_v2_code_white_5_mux0000281_1772,
      S => huffman_ins_v2_codetab_ter_white_width(0),
      O => huffman_ins_v2_code_white_5_mux000028
    );
  huffman_ins_v2_hor_code_9_mux0003661 : LUT4
    generic map(
      INIT => X"C080"
    )
    port map (
      I0 => huffman_ins_v2_N62,
      I1 => huffman_ins_v2_horizontal_mode_part_2_2065,
      I2 => huffman_ins_v2_code_black(9),
      I3 => huffman_ins_v2_N87,
      O => huffman_ins_v2_hor_code_9_mux0003661_2047
    );
  huffman_ins_v2_hor_code_9_mux0003662 : LUT4
    generic map(
      INIT => X"C080"
    )
    port map (
      I0 => huffman_ins_v2_N62,
      I1 => huffman_ins_v2_horizontal_mode_part_2_2065,
      I2 => huffman_ins_v2_code_white(9),
      I3 => huffman_ins_v2_N87,
      O => huffman_ins_v2_hor_code_9_mux0003662_2048
    );
  huffman_ins_v2_hor_code_9_mux000366_f5 : MUXF5
    port map (
      I0 => huffman_ins_v2_hor_code_9_mux0003662_2048,
      I1 => huffman_ins_v2_hor_code_9_mux0003661_2047,
      S => huffman_ins_v2_a0_value_2_1510,
      O => huffman_ins_v2_hor_code_9_mux000366
    );
  huffman_ins_v2_code_black_6_mux000021551 : LUT4
    generic map(
      INIT => X"EC4C"
    )
    port map (
      I0 => huffman_ins_v2_codetab_ter_black_width(2),
      I1 => huffman_ins_v2_ter_black_code(6),
      I2 => N319,
      I3 => huffman_ins_v2_code_black(6),
      O => huffman_ins_v2_code_black_6_mux00002155
    );
  huffman_ins_v2_code_black_6_mux00002155_f5 : MUXF5
    port map (
      I0 => huffman_ins_v2_code_black_6_mux00002126_1652,
      I1 => huffman_ins_v2_code_black_6_mux00002155,
      S => huffman_ins_v2_codetab_ter_black_width(3),
      O => huffman_ins_v2_code_black_6_mux0000
    );
  huffman_ins_v2_code_black_9_mux00002431 : LUT4
    generic map(
      INIT => X"0E04"
    )
    port map (
      I0 => huffman_ins_v2_codetab_ter_black_width(0),
      I1 => huffman_ins_v2_ter_black_code(9),
      I2 => huffman_ins_v2_codetab_ter_black_width(1),
      I3 => huffman_ins_v2_code_black(9),
      O => huffman_ins_v2_code_black_9_mux00002431_1672
    );
  huffman_ins_v2_code_black_9_mux00002432 : LUT2
    generic map(
      INIT => X"2"
    )
    port map (
      I0 => huffman_ins_v2_code_black_11_mux0000_bdd0,
      I1 => huffman_ins_v2_codetab_ter_black_width(1),
      O => huffman_ins_v2_code_black_9_mux00002432_1673
    );
  huffman_ins_v2_code_black_9_mux0000243_f5 : MUXF5
    port map (
      I0 => huffman_ins_v2_code_black_9_mux00002432_1673,
      I1 => huffman_ins_v2_code_black_9_mux00002431_1672,
      S => huffman_ins_v2_codetab_ter_black_width(2),
      O => huffman_ins_v2_code_black_9_mux0000243
    );
  huffman_ins_v2_code_black_15_mux00001431 : LUT4
    generic map(
      INIT => X"0E04"
    )
    port map (
      I0 => huffman_ins_v2_codetab_ter_black_width(0),
      I1 => huffman_ins_v2_code_table_ins_makeup_black_3_Q,
      I2 => huffman_ins_v2_codetab_ter_black_width(1),
      I3 => huffman_ins_v2_code_black(15),
      O => huffman_ins_v2_code_black_15_mux00001431_1566
    );
  huffman_ins_v2_code_black_15_mux00001432 : LUT2
    generic map(
      INIT => X"2"
    )
    port map (
      I0 => huffman_ins_v2_code_black_11_mux0000_bdd5,
      I1 => huffman_ins_v2_codetab_ter_black_width(1),
      O => huffman_ins_v2_code_black_15_mux00001432_1567
    );
  huffman_ins_v2_code_black_15_mux0000143_f5 : MUXF5
    port map (
      I0 => huffman_ins_v2_code_black_15_mux00001432_1567,
      I1 => huffman_ins_v2_code_black_15_mux00001431_1566,
      S => huffman_ins_v2_codetab_ter_black_width(2),
      O => huffman_ins_v2_code_black_15_mux0000143
    );
  huffman_ins_v2_code_black_14_mux00001431 : LUT4
    generic map(
      INIT => X"0E04"
    )
    port map (
      I0 => huffman_ins_v2_codetab_ter_black_width(0),
      I1 => huffman_ins_v2_code_table_ins_makeup_black_2_Q,
      I2 => huffman_ins_v2_codetab_ter_black_width(1),
      I3 => huffman_ins_v2_code_black(14),
      O => huffman_ins_v2_code_black_14_mux00001431_1557
    );
  huffman_ins_v2_code_black_14_mux00001432 : LUT2
    generic map(
      INIT => X"2"
    )
    port map (
      I0 => huffman_ins_v2_code_black_10_mux0000_bdd5,
      I1 => huffman_ins_v2_codetab_ter_black_width(1),
      O => huffman_ins_v2_code_black_14_mux00001432_1558
    );
  huffman_ins_v2_code_black_14_mux0000143_f5 : MUXF5
    port map (
      I0 => huffman_ins_v2_code_black_14_mux00001432_1558,
      I1 => huffman_ins_v2_code_black_14_mux00001431_1557,
      S => huffman_ins_v2_codetab_ter_black_width(2),
      O => huffman_ins_v2_code_black_14_mux0000143
    );
  huffman_ins_v2_code_black_13_mux00001431 : LUT4
    generic map(
      INIT => X"0E04"
    )
    port map (
      I0 => huffman_ins_v2_codetab_ter_black_width(0),
      I1 => huffman_ins_v2_code_table_ins_makeup_black_1_Q,
      I2 => huffman_ins_v2_codetab_ter_black_width(1),
      I3 => huffman_ins_v2_code_black(13),
      O => huffman_ins_v2_code_black_13_mux00001431_1550
    );
  huffman_ins_v2_code_black_13_mux00001432 : LUT2
    generic map(
      INIT => X"2"
    )
    port map (
      I0 => huffman_ins_v2_code_black_11_mux0000_bdd3,
      I1 => huffman_ins_v2_codetab_ter_black_width(1),
      O => huffman_ins_v2_code_black_13_mux00001432_1551
    );
  huffman_ins_v2_code_black_13_mux0000143_f5 : MUXF5
    port map (
      I0 => huffman_ins_v2_code_black_13_mux00001432_1551,
      I1 => huffman_ins_v2_code_black_13_mux00001431_1550,
      S => huffman_ins_v2_codetab_ter_black_width(2),
      O => huffman_ins_v2_code_black_13_mux0000143
    );
  huffman_ins_v2_code_black_12_mux00001431 : LUT4
    generic map(
      INIT => X"0E04"
    )
    port map (
      I0 => huffman_ins_v2_codetab_ter_black_width(0),
      I1 => huffman_ins_v2_code_table_ins_makeup_black_0_Q,
      I2 => huffman_ins_v2_codetab_ter_black_width(1),
      I3 => huffman_ins_v2_code_black(12),
      O => huffman_ins_v2_code_black_12_mux00001431_1543
    );
  huffman_ins_v2_code_black_12_mux00001432 : LUT2
    generic map(
      INIT => X"2"
    )
    port map (
      I0 => huffman_ins_v2_code_black_10_mux0000_bdd3,
      I1 => huffman_ins_v2_codetab_ter_black_width(1),
      O => huffman_ins_v2_code_black_12_mux00001432_1544
    );
  huffman_ins_v2_code_black_12_mux0000143_f5 : MUXF5
    port map (
      I0 => huffman_ins_v2_code_black_12_mux00001432_1544,
      I1 => huffman_ins_v2_code_black_12_mux00001431_1543,
      S => huffman_ins_v2_codetab_ter_black_width(2),
      O => huffman_ins_v2_code_black_12_mux0000143
    );
  huffman_ins_v2_code_black_11_mux00001431 : LUT4
    generic map(
      INIT => X"0E04"
    )
    port map (
      I0 => huffman_ins_v2_codetab_ter_black_width(0),
      I1 => huffman_ins_v2_ter_black_code(11),
      I2 => huffman_ins_v2_codetab_ter_black_width(1),
      I3 => huffman_ins_v2_code_black(11),
      O => huffman_ins_v2_code_black_11_mux00001431_1532
    );
  huffman_ins_v2_code_black_11_mux00001432 : LUT2
    generic map(
      INIT => X"2"
    )
    port map (
      I0 => huffman_ins_v2_code_black_11_mux0000_bdd2,
      I1 => huffman_ins_v2_codetab_ter_black_width(1),
      O => huffman_ins_v2_code_black_11_mux00001432_1533
    );
  huffman_ins_v2_code_black_11_mux0000143_f5 : MUXF5
    port map (
      I0 => huffman_ins_v2_code_black_11_mux00001432_1533,
      I1 => huffman_ins_v2_code_black_11_mux00001431_1532,
      S => huffman_ins_v2_codetab_ter_black_width(2),
      O => huffman_ins_v2_code_black_11_mux0000143
    );
  huffman_ins_v2_code_black_10_mux00001521 : LUT4
    generic map(
      INIT => X"FA72"
    )
    port map (
      I0 => huffman_ins_v2_codetab_ter_black_width(2),
      I1 => huffman_ins_v2_codetab_ter_black_width(0),
      I2 => huffman_ins_v2_code_black_10_mux0000_bdd2,
      I3 => huffman_ins_v2_code_black(10),
      O => huffman_ins_v2_code_black_10_mux00001521_1521
    );
  huffman_ins_v2_code_black_10_mux00001522 : LUT4
    generic map(
      INIT => X"E444"
    )
    port map (
      I0 => huffman_ins_v2_codetab_ter_black_width(2),
      I1 => huffman_ins_v2_code_black_10_mux0000_bdd2,
      I2 => huffman_ins_v2_codetab_ter_black_width(0),
      I3 => huffman_ins_v2_code_black(10),
      O => huffman_ins_v2_code_black_10_mux00001522_1522
    );
  huffman_ins_v2_code_black_10_mux0000152_f5 : MUXF5
    port map (
      I0 => huffman_ins_v2_code_black_10_mux00001522_1522,
      I1 => huffman_ins_v2_code_black_10_mux00001521_1521,
      S => huffman_ins_v2_ter_black_code(10),
      O => huffman_ins_v2_code_black_10_mux0000152
    );
  fax4_ins_FIFO2_multi_read_ins_wr1 : LUT4
    generic map(
      INIT => X"FFEA"
    )
    port map (
      I0 => fax4_ins_FIFO2_multi_read_ins_used(2),
      I1 => fax4_ins_FIFO2_multi_read_ins_used(1),
      I2 => fax4_ins_FIFO2_multi_read_ins_used(0),
      I3 => fax4_ins_FIFO2_multi_read_ins_N4,
      O => fax4_ins_FIFO2_multi_read_ins_wr1_702
    );
  fax4_ins_FIFO2_multi_read_ins_wr_f5 : MUXF5
    port map (
      I0 => NlwRenamedSig_OI_run_len_code_o(26),
      I1 => fax4_ins_FIFO2_multi_read_ins_wr1_702,
      S => fax4_ins_fifo2_wr,
      O => fax4_ins_FIFO2_multi_read_ins_wr
    );
  huffman_ins_v2_run_length_white_0_1 : LUT4
    generic map(
      INIT => X"F5B1"
    )
    port map (
      I0 => huffman_ins_v2_run_length_white_and0000,
      I1 => fax4_ins_a0_value_o_950,
      I2 => huffman_ins_v2_run_length_white_addsub0000(0),
      I3 => huffman_ins_v2_run_length_white_sub0000(0),
      O => huffman_ins_v2_run_length_white_0_1_2094
    );
  huffman_ins_v2_run_length_white_0_2 : LUT4
    generic map(
      INIT => X"EC20"
    )
    port map (
      I0 => huffman_ins_v2_run_length_white_sub0000(0),
      I1 => huffman_ins_v2_run_length_white_and0000,
      I2 => fax4_ins_a0_value_o_950,
      I3 => huffman_ins_v2_run_length_white_addsub0000(0),
      O => huffman_ins_v2_run_length_white_0_2_2095
    );
  huffman_ins_v2_run_length_white_0_f5 : MUXF5
    port map (
      I0 => huffman_ins_v2_run_length_white_0_2_2095,
      I1 => huffman_ins_v2_run_length_white_0_1_2094,
      S => huffman_ins_v2_run_length_white_sub0001(0),
      O => huffman_ins_v2_run_length_white(0)
    );
  fax4_ins_FIFO2_multi_read_ins_mux3_and00001 : LUT4
    generic map(
      INIT => X"0010"
    )
    port map (
      I0 => fax4_ins_FIFO2_multi_read_ins_used(2),
      I1 => fax4_ins_FIFO2_multi_read_ins_used(0),
      I2 => fax4_ins_FIFO2_multi_read_ins_used(1),
      I3 => fax4_ins_FIFO2_multi_read_ins_N4,
      O => fax4_ins_FIFO2_multi_read_ins_mux3_and0000
    );
  fax4_ins_FIFO2_multi_read_ins_mux3_and0000_f5 : MUXF5
    port map (
      I0 => NlwRenamedSig_OI_run_len_code_o(26),
      I1 => fax4_ins_FIFO2_multi_read_ins_mux3_and0000,
      S => fax4_ins_fifo2_wr,
      O => fax4_ins_FIFO2_multi_read_ins_mux3
    );
  huffman_ins_v2_hor_code_17_mux000315311 : LUT4
    generic map(
      INIT => X"A820"
    )
    port map (
      I0 => huffman_ins_v2_hor_code(17),
      I1 => huffman_ins_v2_horizontal_mode_part_2_2065,
      I2 => huffman_ins_v2_hor_code_17_mux0003110_1904,
      I3 => huffman_ins_v2_hor_code_17_mux000371_1911,
      O => huffman_ins_v2_hor_code_17_mux00031531
    );
  huffman_ins_v2_hor_code_17_mux00031531_f5 : MUXF5
    port map (
      I0 => huffman_ins_v2_hor_code_17_mux00031531,
      I1 => huffman_ins_v2_hor_code(17),
      S => huffman_ins_v2_hor_code_17_mux000378_1912,
      O => huffman_ins_v2_hor_code_17_mux0003153
    );
  fax4_ins_b1_mux0004_8_421 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => fax4_ins_mux_b1(0),
      I1 => fax4_ins_fifo_out_prev1_x(8),
      I2 => fax4_ins_fifo_out_prev2_x(8),
      O => fax4_ins_b1_mux0004_8_42
    );
  fax4_ins_b1_mux0004_8_422 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => fax4_ins_mux_b1(0),
      I1 => fax4_ins_b1_mux0004_8_12_1049,
      I2 => fax4_ins_fifo_out_prev2_x(8),
      O => fax4_ins_b1_mux0004_8_421_1051
    );
  fax4_ins_b1_mux0004_8_42_f5 : MUXF5
    port map (
      I0 => fax4_ins_b1_mux0004_8_421_1051,
      I1 => fax4_ins_b1_mux0004_8_42,
      S => fax4_ins_mux_b1(1),
      O => fax4_ins_b1_mux0004(8)
    );
  fax4_ins_b1_mux0004_3_421 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => fax4_ins_mux_b1(0),
      I1 => fax4_ins_fifo_out_prev1_x(3),
      I2 => fax4_ins_fifo_out_prev2_x(3),
      O => fax4_ins_b1_mux0004_3_42
    );
  fax4_ins_b1_mux0004_3_422 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => fax4_ins_mux_b1(0),
      I1 => fax4_ins_b1_mux0004_3_12_1037,
      I2 => fax4_ins_fifo_out_prev2_x(3),
      O => fax4_ins_b1_mux0004_3_421_1039
    );
  fax4_ins_b1_mux0004_3_42_f5 : MUXF5
    port map (
      I0 => fax4_ins_b1_mux0004_3_421_1039,
      I1 => fax4_ins_b1_mux0004_3_42,
      S => fax4_ins_mux_b1(1),
      O => fax4_ins_b1_mux0004(3)
    );
  fax4_ins_b1_mux0004_2_421 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => fax4_ins_mux_b1(0),
      I1 => fax4_ins_fifo_out_prev1_x(2),
      I2 => fax4_ins_fifo_out_prev2_x(2),
      O => fax4_ins_b1_mux0004_2_42
    );
  fax4_ins_b1_mux0004_2_422 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => fax4_ins_mux_b1(0),
      I1 => fax4_ins_b1_mux0004_2_12_1033,
      I2 => fax4_ins_fifo_out_prev2_x(2),
      O => fax4_ins_b1_mux0004_2_421_1035
    );
  fax4_ins_b1_mux0004_2_42_f5 : MUXF5
    port map (
      I0 => fax4_ins_b1_mux0004_2_421_1035,
      I1 => fax4_ins_b1_mux0004_2_42,
      S => fax4_ins_mux_b1(1),
      O => fax4_ins_b1_mux0004(2)
    );
  fax4_ins_b1_mux0004_1_421 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => fax4_ins_mux_b1(0),
      I1 => fax4_ins_fifo_out_prev1_x(1),
      I2 => fax4_ins_fifo_out_prev2_x(1),
      O => fax4_ins_b1_mux0004_1_42
    );
  fax4_ins_b1_mux0004_1_422 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => fax4_ins_mux_b1(0),
      I1 => fax4_ins_b1_mux0004_1_12_1029,
      I2 => fax4_ins_fifo_out_prev2_x(1),
      O => fax4_ins_b1_mux0004_1_421_1031
    );
  fax4_ins_b1_mux0004_1_42_f5 : MUXF5
    port map (
      I0 => fax4_ins_b1_mux0004_1_421_1031,
      I1 => fax4_ins_b1_mux0004_1_42,
      S => fax4_ins_mux_b1(1),
      O => fax4_ins_b1_mux0004(1)
    );
  huffman_ins_v2_hor_code_15_mux0003551 : LUT4
    generic map(
      INIT => X"EC20"
    )
    port map (
      I0 => huffman_ins_v2_code_black(15),
      I1 => huffman_ins_v2_a0_value_2_1510,
      I2 => huffman_ins_v2_code_black_width(4),
      I3 => huffman_ins_v2_code_white(15),
      O => huffman_ins_v2_hor_code_15_mux0003551_1890
    );
  huffman_ins_v2_hor_code_15_mux0003552 : LUT3
    generic map(
      INIT => X"08"
    )
    port map (
      I0 => huffman_ins_v2_code_black_width(4),
      I1 => huffman_ins_v2_code_black(15),
      I2 => huffman_ins_v2_a0_value_2_1510,
      O => huffman_ins_v2_hor_code_15_mux0003552_1891
    );
  huffman_ins_v2_hor_code_15_mux000355_f5 : MUXF5
    port map (
      I0 => huffman_ins_v2_hor_code_15_mux0003552_1891,
      I1 => huffman_ins_v2_hor_code_15_mux0003551_1890,
      S => huffman_ins_v2_code_white_width(4),
      O => huffman_ins_v2_hor_code_15_mux000355
    );
  huffman_ins_v2_run_length_white_9_1 : LUT4
    generic map(
      INIT => X"F5B1"
    )
    port map (
      I0 => huffman_ins_v2_run_length_white_and0000,
      I1 => fax4_ins_a0_value_o_950,
      I2 => huffman_ins_v2_run_length_white_addsub0000(9),
      I3 => huffman_ins_v2_run_length_white_sub0000(9),
      O => huffman_ins_v2_run_length_white_9_1_2121
    );
  huffman_ins_v2_run_length_white_9_2 : LUT4
    generic map(
      INIT => X"EC20"
    )
    port map (
      I0 => huffman_ins_v2_run_length_white_sub0000(9),
      I1 => huffman_ins_v2_run_length_white_and0000,
      I2 => fax4_ins_a0_value_o_950,
      I3 => huffman_ins_v2_run_length_white_addsub0000(9),
      O => huffman_ins_v2_run_length_white_9_2_2122
    );
  huffman_ins_v2_run_length_white_9_f5 : MUXF5
    port map (
      I0 => huffman_ins_v2_run_length_white_9_2_2122,
      I1 => huffman_ins_v2_run_length_white_9_1_2121,
      S => huffman_ins_v2_run_length_white_sub0001(9),
      O => huffman_ins_v2_run_length_white(9)
    );
  huffman_ins_v2_run_length_white_8_1 : LUT4
    generic map(
      INIT => X"F5B1"
    )
    port map (
      I0 => huffman_ins_v2_run_length_white_and0000,
      I1 => fax4_ins_a0_value_o_950,
      I2 => huffman_ins_v2_run_length_white_addsub0000(8),
      I3 => huffman_ins_v2_run_length_white_sub0000(8),
      O => huffman_ins_v2_run_length_white_8_1_2118
    );
  huffman_ins_v2_run_length_white_8_2 : LUT4
    generic map(
      INIT => X"EC20"
    )
    port map (
      I0 => huffman_ins_v2_run_length_white_sub0000(8),
      I1 => huffman_ins_v2_run_length_white_and0000,
      I2 => fax4_ins_a0_value_o_950,
      I3 => huffman_ins_v2_run_length_white_addsub0000(8),
      O => huffman_ins_v2_run_length_white_8_2_2119
    );
  huffman_ins_v2_run_length_white_8_f5 : MUXF5
    port map (
      I0 => huffman_ins_v2_run_length_white_8_2_2119,
      I1 => huffman_ins_v2_run_length_white_8_1_2118,
      S => huffman_ins_v2_run_length_white_sub0001(8),
      O => huffman_ins_v2_run_length_white(8)
    );
  huffman_ins_v2_run_length_white_7_1 : LUT4
    generic map(
      INIT => X"F5B1"
    )
    port map (
      I0 => huffman_ins_v2_run_length_white_and0000,
      I1 => fax4_ins_a0_value_o_950,
      I2 => huffman_ins_v2_run_length_white_addsub0000(7),
      I3 => huffman_ins_v2_run_length_white_sub0000(7),
      O => huffman_ins_v2_run_length_white_7_1_2115
    );
  huffman_ins_v2_run_length_white_7_2 : LUT4
    generic map(
      INIT => X"EC20"
    )
    port map (
      I0 => huffman_ins_v2_run_length_white_sub0000(7),
      I1 => huffman_ins_v2_run_length_white_and0000,
      I2 => fax4_ins_a0_value_o_950,
      I3 => huffman_ins_v2_run_length_white_addsub0000(7),
      O => huffman_ins_v2_run_length_white_7_2_2116
    );
  huffman_ins_v2_run_length_white_7_f5 : MUXF5
    port map (
      I0 => huffman_ins_v2_run_length_white_7_2_2116,
      I1 => huffman_ins_v2_run_length_white_7_1_2115,
      S => huffman_ins_v2_run_length_white_sub0001(7),
      O => huffman_ins_v2_run_length_white(7)
    );
  huffman_ins_v2_run_length_white_6_1 : LUT4
    generic map(
      INIT => X"F5B1"
    )
    port map (
      I0 => huffman_ins_v2_run_length_white_and0000,
      I1 => fax4_ins_a0_value_o_950,
      I2 => huffman_ins_v2_run_length_white_addsub0000(6),
      I3 => huffman_ins_v2_run_length_white_sub0000(6),
      O => huffman_ins_v2_run_length_white_6_1_2112
    );
  huffman_ins_v2_run_length_white_6_2 : LUT4
    generic map(
      INIT => X"EC20"
    )
    port map (
      I0 => huffman_ins_v2_run_length_white_sub0000(6),
      I1 => huffman_ins_v2_run_length_white_and0000,
      I2 => fax4_ins_a0_value_o_950,
      I3 => huffman_ins_v2_run_length_white_addsub0000(6),
      O => huffman_ins_v2_run_length_white_6_2_2113
    );
  huffman_ins_v2_run_length_white_6_f5 : MUXF5
    port map (
      I0 => huffman_ins_v2_run_length_white_6_2_2113,
      I1 => huffman_ins_v2_run_length_white_6_1_2112,
      S => huffman_ins_v2_run_length_white_sub0001(6),
      O => huffman_ins_v2_run_length_white(6)
    );
  huffman_ins_v2_run_length_white_5_1 : LUT4
    generic map(
      INIT => X"F5B1"
    )
    port map (
      I0 => huffman_ins_v2_run_length_white_and0000,
      I1 => fax4_ins_a0_value_o_950,
      I2 => huffman_ins_v2_run_length_white_addsub0000(5),
      I3 => huffman_ins_v2_run_length_white_sub0000(5),
      O => huffman_ins_v2_run_length_white_5_1_2109
    );
  huffman_ins_v2_run_length_white_5_2 : LUT4
    generic map(
      INIT => X"EC20"
    )
    port map (
      I0 => huffman_ins_v2_run_length_white_sub0000(5),
      I1 => huffman_ins_v2_run_length_white_and0000,
      I2 => fax4_ins_a0_value_o_950,
      I3 => huffman_ins_v2_run_length_white_addsub0000(5),
      O => huffman_ins_v2_run_length_white_5_2_2110
    );
  huffman_ins_v2_run_length_white_5_f5 : MUXF5
    port map (
      I0 => huffman_ins_v2_run_length_white_5_2_2110,
      I1 => huffman_ins_v2_run_length_white_5_1_2109,
      S => huffman_ins_v2_run_length_white_sub0001(5),
      O => huffman_ins_v2_run_length_white(5)
    );
  huffman_ins_v2_run_length_white_4_1 : LUT4
    generic map(
      INIT => X"F5B1"
    )
    port map (
      I0 => huffman_ins_v2_run_length_white_and0000,
      I1 => fax4_ins_a0_value_o_950,
      I2 => huffman_ins_v2_run_length_white_addsub0000(4),
      I3 => huffman_ins_v2_run_length_white_sub0000(4),
      O => huffman_ins_v2_run_length_white_4_1_2106
    );
  huffman_ins_v2_run_length_white_4_2 : LUT4
    generic map(
      INIT => X"EC20"
    )
    port map (
      I0 => huffman_ins_v2_run_length_white_sub0000(4),
      I1 => huffman_ins_v2_run_length_white_and0000,
      I2 => fax4_ins_a0_value_o_950,
      I3 => huffman_ins_v2_run_length_white_addsub0000(4),
      O => huffman_ins_v2_run_length_white_4_2_2107
    );
  huffman_ins_v2_run_length_white_4_f5 : MUXF5
    port map (
      I0 => huffman_ins_v2_run_length_white_4_2_2107,
      I1 => huffman_ins_v2_run_length_white_4_1_2106,
      S => huffman_ins_v2_run_length_white_sub0001(4),
      O => huffman_ins_v2_run_length_white(4)
    );
  huffman_ins_v2_run_length_white_3_1 : LUT4
    generic map(
      INIT => X"F5B1"
    )
    port map (
      I0 => huffman_ins_v2_run_length_white_and0000,
      I1 => fax4_ins_a0_value_o_950,
      I2 => huffman_ins_v2_run_length_white_addsub0000(3),
      I3 => huffman_ins_v2_run_length_white_sub0000(3),
      O => huffman_ins_v2_run_length_white_3_1_2103
    );
  huffman_ins_v2_run_length_white_3_2 : LUT4
    generic map(
      INIT => X"EC20"
    )
    port map (
      I0 => huffman_ins_v2_run_length_white_sub0000(3),
      I1 => huffman_ins_v2_run_length_white_and0000,
      I2 => fax4_ins_a0_value_o_950,
      I3 => huffman_ins_v2_run_length_white_addsub0000(3),
      O => huffman_ins_v2_run_length_white_3_2_2104
    );
  huffman_ins_v2_run_length_white_3_f5 : MUXF5
    port map (
      I0 => huffman_ins_v2_run_length_white_3_2_2104,
      I1 => huffman_ins_v2_run_length_white_3_1_2103,
      S => huffman_ins_v2_run_length_white_sub0001(3),
      O => huffman_ins_v2_run_length_white(3)
    );
  huffman_ins_v2_run_length_white_2_1 : LUT4
    generic map(
      INIT => X"F5B1"
    )
    port map (
      I0 => huffman_ins_v2_run_length_white_and0000,
      I1 => fax4_ins_a0_value_o_950,
      I2 => huffman_ins_v2_run_length_white_addsub0000(2),
      I3 => huffman_ins_v2_run_length_white_sub0000(2),
      O => huffman_ins_v2_run_length_white_2_1_2100
    );
  huffman_ins_v2_run_length_white_2_2 : LUT4
    generic map(
      INIT => X"EC20"
    )
    port map (
      I0 => huffman_ins_v2_run_length_white_sub0000(2),
      I1 => huffman_ins_v2_run_length_white_and0000,
      I2 => fax4_ins_a0_value_o_950,
      I3 => huffman_ins_v2_run_length_white_addsub0000(2),
      O => huffman_ins_v2_run_length_white_2_2_2101
    );
  huffman_ins_v2_run_length_white_2_f5 : MUXF5
    port map (
      I0 => huffman_ins_v2_run_length_white_2_2_2101,
      I1 => huffman_ins_v2_run_length_white_2_1_2100,
      S => huffman_ins_v2_run_length_white_sub0001(2),
      O => huffman_ins_v2_run_length_white(2)
    );
  huffman_ins_v2_run_length_white_1_1 : LUT4
    generic map(
      INIT => X"F5B1"
    )
    port map (
      I0 => huffman_ins_v2_run_length_white_and0000,
      I1 => fax4_ins_a0_value_o_950,
      I2 => huffman_ins_v2_run_length_white_addsub0000(1),
      I3 => huffman_ins_v2_run_length_white_sub0000(1),
      O => huffman_ins_v2_run_length_white_1_1_2097
    );
  huffman_ins_v2_run_length_white_1_2 : LUT4
    generic map(
      INIT => X"EC20"
    )
    port map (
      I0 => huffman_ins_v2_run_length_white_sub0000(1),
      I1 => huffman_ins_v2_run_length_white_and0000,
      I2 => fax4_ins_a0_value_o_950,
      I3 => huffman_ins_v2_run_length_white_addsub0000(1),
      O => huffman_ins_v2_run_length_white_1_2_2098
    );
  huffman_ins_v2_run_length_white_1_f5 : MUXF5
    port map (
      I0 => huffman_ins_v2_run_length_white_1_2_2098,
      I1 => huffman_ins_v2_run_length_white_1_1_2097,
      S => huffman_ins_v2_run_length_white_sub0001(1),
      O => huffman_ins_v2_run_length_white(1)
    );
  huffman_ins_v2_code_black_15_mux000011071 : LUT4
    generic map(
      INIT => X"FFE2"
    )
    port map (
      I0 => huffman_ins_v2_code_black(15),
      I1 => huffman_ins_v2_codetab_ter_black_width(1),
      I2 => huffman_ins_v2_codetab_ter_black_width(0),
      I3 => huffman_ins_v2_codetab_ter_black_width(2),
      O => huffman_ins_v2_code_black_15_mux000011071_1562
    );
  huffman_ins_v2_code_black_15_mux000011072 : LUT3
    generic map(
      INIT => X"10"
    )
    port map (
      I0 => huffman_ins_v2_codetab_ter_black_width(2),
      I1 => huffman_ins_v2_codetab_ter_black_width(1),
      I2 => huffman_ins_v2_code_black(15),
      O => huffman_ins_v2_code_black_15_mux000011072_1563
    );
  huffman_ins_v2_code_black_15_mux00001107_f5 : MUXF5
    port map (
      I0 => huffman_ins_v2_code_black_15_mux000011072_1563,
      I1 => huffman_ins_v2_code_black_15_mux000011071_1562,
      S => huffman_ins_v2_code_table_ins_makeup_black_8_Q,
      O => huffman_ins_v2_code_black_15_mux00001107
    );
  huffman_ins_v2_Madd_code_white_width_add0000_xor_3_111 : LUT4
    generic map(
      INIT => X"9996"
    )
    port map (
      I0 => huffman_ins_v2_code_table_ins_makeup_white(12),
      I1 => huffman_ins_v2_codetab_ter_white_width(3),
      I2 => huffman_ins_v2_code_table_ins_makeup_white(11),
      I3 => huffman_ins_v2_codetab_ter_white_width(2),
      O => huffman_ins_v2_Madd_code_white_width_add0000_xor_3_11
    );
  huffman_ins_v2_Madd_code_white_width_add0000_xor_3_112 : LUT4
    generic map(
      INIT => X"9666"
    )
    port map (
      I0 => huffman_ins_v2_code_table_ins_makeup_white(12),
      I1 => huffman_ins_v2_codetab_ter_white_width(3),
      I2 => huffman_ins_v2_code_table_ins_makeup_white(11),
      I3 => huffman_ins_v2_codetab_ter_white_width(2),
      O => huffman_ins_v2_Madd_code_white_width_add0000_xor_3_111_1383
    );
  huffman_ins_v2_Madd_code_white_width_add0000_xor_3_11_f5 : MUXF5
    port map (
      I0 => huffman_ins_v2_Madd_code_white_width_add0000_xor_3_111_1383,
      I1 => huffman_ins_v2_Madd_code_white_width_add0000_xor_3_11,
      S => huffman_ins_v2_Madd_code_white_width_add0000_cy_1_Q,
      O => huffman_ins_v2_code_white_width_add0000(3)
    );
  huffman_ins_v2_Madd_code_black_width_add0000_xor_3_111 : LUT4
    generic map(
      INIT => X"9996"
    )
    port map (
      I0 => huffman_ins_v2_code_table_ins_makeup_black_16_Q,
      I1 => huffman_ins_v2_codetab_ter_black_width(3),
      I2 => huffman_ins_v2_code_table_ins_makeup_black_15_Q,
      I3 => huffman_ins_v2_codetab_ter_black_width(2),
      O => huffman_ins_v2_Madd_code_black_width_add0000_xor_3_11
    );
  huffman_ins_v2_Madd_code_black_width_add0000_xor_3_112 : LUT4
    generic map(
      INIT => X"9666"
    )
    port map (
      I0 => huffman_ins_v2_code_table_ins_makeup_black_16_Q,
      I1 => huffman_ins_v2_codetab_ter_black_width(3),
      I2 => huffman_ins_v2_code_table_ins_makeup_black_15_Q,
      I3 => huffman_ins_v2_codetab_ter_black_width(2),
      O => huffman_ins_v2_Madd_code_black_width_add0000_xor_3_111_1376
    );
  huffman_ins_v2_Madd_code_black_width_add0000_xor_3_11_f5 : MUXF5
    port map (
      I0 => huffman_ins_v2_Madd_code_black_width_add0000_xor_3_111_1376,
      I1 => huffman_ins_v2_Madd_code_black_width_add0000_xor_3_11,
      S => huffman_ins_v2_Madd_code_black_width_add0000_cy_1_Q,
      O => huffman_ins_v2_code_black_width_add0000(3)
    );
  huffman_ins_v2_Madd_code_white_width_add0000_cy_3_11 : LUT4
    generic map(
      INIT => X"FEA8"
    )
    port map (
      I0 => huffman_ins_v2_code_table_ins_makeup_white(12),
      I1 => huffman_ins_v2_code_table_ins_makeup_white(11),
      I2 => huffman_ins_v2_codetab_ter_white_width(2),
      I3 => huffman_ins_v2_codetab_ter_white_width(3),
      O => huffman_ins_v2_Madd_code_white_width_add0000_cy_3_1
    );
  huffman_ins_v2_Madd_code_white_width_add0000_cy_3_12 : LUT4
    generic map(
      INIT => X"EA80"
    )
    port map (
      I0 => huffman_ins_v2_code_table_ins_makeup_white(12),
      I1 => huffman_ins_v2_code_table_ins_makeup_white(11),
      I2 => huffman_ins_v2_codetab_ter_white_width(2),
      I3 => huffman_ins_v2_codetab_ter_white_width(3),
      O => huffman_ins_v2_Madd_code_white_width_add0000_cy_3_11_1380
    );
  huffman_ins_v2_Madd_code_white_width_add0000_cy_3_1_f5 : MUXF5
    port map (
      I0 => huffman_ins_v2_Madd_code_white_width_add0000_cy_3_11_1380,
      I1 => huffman_ins_v2_Madd_code_white_width_add0000_cy_3_1,
      S => huffman_ins_v2_Madd_code_white_width_add0000_cy_1_Q,
      O => huffman_ins_v2_Madd_code_white_width_add0000_cy_3_Q
    );
  huffman_ins_v2_Madd_code_black_width_add0000_cy_3_11 : LUT4
    generic map(
      INIT => X"FEA8"
    )
    port map (
      I0 => huffman_ins_v2_code_table_ins_makeup_black_16_Q,
      I1 => huffman_ins_v2_code_table_ins_makeup_black_15_Q,
      I2 => huffman_ins_v2_codetab_ter_black_width(2),
      I3 => huffman_ins_v2_codetab_ter_black_width(3),
      O => huffman_ins_v2_Madd_code_black_width_add0000_cy_3_1
    );
  huffman_ins_v2_Madd_code_black_width_add0000_cy_3_12 : LUT4
    generic map(
      INIT => X"EA80"
    )
    port map (
      I0 => huffman_ins_v2_code_table_ins_makeup_black_16_Q,
      I1 => huffman_ins_v2_code_table_ins_makeup_black_15_Q,
      I2 => huffman_ins_v2_codetab_ter_black_width(2),
      I3 => huffman_ins_v2_codetab_ter_black_width(3),
      O => huffman_ins_v2_Madd_code_black_width_add0000_cy_3_11_1373
    );
  huffman_ins_v2_Madd_code_black_width_add0000_cy_3_1_f5 : MUXF5
    port map (
      I0 => huffman_ins_v2_Madd_code_black_width_add0000_cy_3_11_1373,
      I1 => huffman_ins_v2_Madd_code_black_width_add0000_cy_3_1,
      S => huffman_ins_v2_Madd_code_black_width_add0000_cy_1_Q,
      O => huffman_ins_v2_Madd_code_black_width_add0000_cy_3_Q
    );
  fax4_ins_output_valid_o_mux0003151 : LUT4
    generic map(
      INIT => X"FF72"
    )
    port map (
      I0 => fax4_ins_EOL_prev_230,
      I1 => fax4_ins_EOL_prev_prev_231,
      I2 => fax4_ins_EOL,
      I3 => fax4_ins_pix_changed_1319,
      O => fax4_ins_output_valid_o_mux0003151_1313
    );
  fax4_ins_output_valid_o_mux000315_f5 : MUXF5
    port map (
      I0 => NlwRenamedSig_OI_run_len_code_o(26),
      I1 => fax4_ins_output_valid_o_mux0003151_1313,
      S => fax4_ins_state_FSM_FFd8_1338,
      O => fax4_ins_output_valid_o_mux000315
    );
  fax4_ins_mode_indicator_o_2_rstpot_SW11 : LUT3
    generic map(
      INIT => X"1F"
    )
    port map (
      I0 => fax4_ins_a1b1(1),
      I1 => fax4_ins_a1b1(0),
      I2 => fax4_ins_N15,
      O => fax4_ins_mode_indicator_o_2_rstpot_SW1
    );
  fax4_ins_mode_indicator_o_2_rstpot_SW12 : LUT2
    generic map(
      INIT => X"1"
    )
    port map (
      I0 => fax4_ins_mode_indicator_o(2),
      I1 => fax4_ins_pass_mode,
      O => fax4_ins_mode_indicator_o_2_rstpot_SW11_1293
    );
  fax4_ins_mode_indicator_o_2_rstpot_SW1_f5 : MUXF5
    port map (
      I0 => fax4_ins_mode_indicator_o_2_rstpot_SW11_1293,
      I1 => fax4_ins_mode_indicator_o_2_rstpot_SW1,
      S => fax4_ins_load_a1_or0001,
      O => N177
    );
  huffman_ins_v2_run_length_white_and00007 : LUT3_L
    generic map(
      INIT => X"10"
    )
    port map (
      I0 => fax4_ins_a0_o(9),
      I1 => fax4_ins_a0_o(5),
      I2 => fax4_ins_a0_value_o_950,
      LO => huffman_ins_v2_run_length_white_and00007_2136
    );
  huffman_ins_v2_run_length_black_7_1 : LUT3_D
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => fax4_ins_a0_value_o_950,
      I1 => huffman_ins_v2_run_length_white_sub0000(7),
      I2 => huffman_ins_v2_run_length_white_sub0001(7),
      LO => N465,
      O => huffman_ins_v2_run_length_black(7)
    );
  fax4_ins_b2_mux0004_1_11 : LUT4_D
    generic map(
      INIT => X"1000"
    )
    port map (
      I0 => fax4_ins_b2_to_white_and0000,
      I1 => fax4_ins_b2_to_white_and0001,
      I2 => fax4_ins_fifo_out2_valid,
      I3 => fax4_ins_mux_b1(2),
      LO => N466,
      O => fax4_ins_N13
    );
  fax4_ins_b1_mux0004_7_18 : LUT4_L
    generic map(
      INIT => X"0E04"
    )
    port map (
      I0 => fax4_ins_mux_b1(2),
      I1 => fax4_ins_fifo_out2_x(7),
      I2 => fax4_ins_mux_b1(1),
      I3 => fax4_ins_fifo_out1_x(7),
      LO => fax4_ins_b1_mux0004_7_18_1047
    );
  fax4_ins_b1_mux0004_6_18 : LUT4_L
    generic map(
      INIT => X"0E04"
    )
    port map (
      I0 => fax4_ins_mux_b1(2),
      I1 => fax4_ins_fifo_out2_x(6),
      I2 => fax4_ins_mux_b1(1),
      I3 => fax4_ins_fifo_out1_x(6),
      LO => fax4_ins_b1_mux0004_6_18_1045
    );
  fax4_ins_b1_mux0004_5_18 : LUT4_L
    generic map(
      INIT => X"0E04"
    )
    port map (
      I0 => fax4_ins_mux_b1(2),
      I1 => fax4_ins_fifo_out2_x(5),
      I2 => fax4_ins_mux_b1(1),
      I3 => fax4_ins_fifo_out1_x(5),
      LO => fax4_ins_b1_mux0004_5_18_1043
    );
  fax4_ins_b1_mux0004_4_18 : LUT4_L
    generic map(
      INIT => X"0E04"
    )
    port map (
      I0 => fax4_ins_mux_b1(2),
      I1 => fax4_ins_fifo_out2_x(4),
      I2 => fax4_ins_mux_b1(1),
      I3 => fax4_ins_fifo_out1_x(4),
      LO => fax4_ins_b1_mux0004_4_18_1041
    );
  fax4_ins_b1_mux0004_0_18 : LUT4_L
    generic map(
      INIT => X"0E04"
    )
    port map (
      I0 => fax4_ins_mux_b1(2),
      I1 => fax4_ins_fifo_out2_x(0),
      I2 => fax4_ins_mux_b1(1),
      I3 => fax4_ins_fifo_out1_x(0),
      LO => fax4_ins_b1_mux0004_0_18_1027
    );
  fax4_ins_b2_mux0004_9_10 : LUT4_L
    generic map(
      INIT => X"EC20"
    )
    port map (
      I0 => fax4_ins_fifo_out1_x(9),
      I1 => fax4_ins_b2_to_white_and0000,
      I2 => fax4_ins_b2_to_white_and0001,
      I3 => fax4_ins_fifo_out_prev1_x(9),
      LO => fax4_ins_b2_mux0004_9_10_1092
    );
  fax4_ins_b2_mux0004_8_10 : LUT4_L
    generic map(
      INIT => X"EC20"
    )
    port map (
      I0 => fax4_ins_fifo_out1_x(8),
      I1 => fax4_ins_b2_to_white_and0000,
      I2 => fax4_ins_b2_to_white_and0001,
      I3 => fax4_ins_fifo_out_prev1_x(8),
      LO => fax4_ins_b2_mux0004_8_10_1089
    );
  fax4_ins_b2_mux0004_7_10 : LUT4_L
    generic map(
      INIT => X"EC20"
    )
    port map (
      I0 => fax4_ins_fifo_out1_x(7),
      I1 => fax4_ins_b2_to_white_and0000,
      I2 => fax4_ins_b2_to_white_and0001,
      I3 => fax4_ins_fifo_out_prev1_x(7),
      LO => fax4_ins_b2_mux0004_7_10_1086
    );
  fax4_ins_b2_mux0004_6_10 : LUT4_L
    generic map(
      INIT => X"EC20"
    )
    port map (
      I0 => fax4_ins_fifo_out1_x(6),
      I1 => fax4_ins_b2_to_white_and0000,
      I2 => fax4_ins_b2_to_white_and0001,
      I3 => fax4_ins_fifo_out_prev1_x(6),
      LO => fax4_ins_b2_mux0004_6_10_1083
    );
  fax4_ins_b2_mux0004_5_10 : LUT4_L
    generic map(
      INIT => X"EC20"
    )
    port map (
      I0 => fax4_ins_fifo_out1_x(5),
      I1 => fax4_ins_b2_to_white_and0000,
      I2 => fax4_ins_b2_to_white_and0001,
      I3 => fax4_ins_fifo_out_prev1_x(5),
      LO => fax4_ins_b2_mux0004_5_10_1080
    );
  fax4_ins_b2_mux0004_4_10 : LUT4_L
    generic map(
      INIT => X"EC20"
    )
    port map (
      I0 => fax4_ins_fifo_out1_x(4),
      I1 => fax4_ins_b2_to_white_and0000,
      I2 => fax4_ins_b2_to_white_and0001,
      I3 => fax4_ins_fifo_out_prev1_x(4),
      LO => fax4_ins_b2_mux0004_4_10_1077
    );
  fax4_ins_b2_mux0004_3_10 : LUT4_L
    generic map(
      INIT => X"EC20"
    )
    port map (
      I0 => fax4_ins_fifo_out1_x(3),
      I1 => fax4_ins_b2_to_white_and0000,
      I2 => fax4_ins_b2_to_white_and0001,
      I3 => fax4_ins_fifo_out_prev1_x(3),
      LO => fax4_ins_b2_mux0004_3_10_1074
    );
  fax4_ins_b2_mux0004_2_10 : LUT4_L
    generic map(
      INIT => X"EC20"
    )
    port map (
      I0 => fax4_ins_fifo_out1_x(2),
      I1 => fax4_ins_b2_to_white_and0000,
      I2 => fax4_ins_b2_to_white_and0001,
      I3 => fax4_ins_fifo_out_prev1_x(2),
      LO => fax4_ins_b2_mux0004_2_10_1071
    );
  fax4_ins_b2_mux0004_1_10 : LUT4_L
    generic map(
      INIT => X"EC20"
    )
    port map (
      I0 => fax4_ins_fifo_out1_x(1),
      I1 => fax4_ins_b2_to_white_and0000,
      I2 => fax4_ins_b2_to_white_and0001,
      I3 => fax4_ins_fifo_out_prev1_x(1),
      LO => fax4_ins_b2_mux0004_1_10_1068
    );
  fax4_ins_fifo_rd0 : LUT2_D
    generic map(
      INIT => X"E"
    )
    port map (
      I0 => fax4_ins_state_FSM_FFd10_1323,
      I1 => fax4_ins_state_FSM_FFd2_1327,
      LO => N467,
      O => fax4_ins_fifo_rd0_1266
    );
  fax4_ins_fifo_rd3 : LUT3_D
    generic map(
      INIT => X"FE"
    )
    port map (
      I0 => fax4_ins_state_FSM_FFd8_1338,
      I1 => fax4_ins_state_FSM_FFd5_1333,
      I2 => fax4_ins_state_FSM_FFd6_1336,
      LO => N468,
      O => fax4_ins_fifo_rd3_1268
    );
  fax4_ins_mode_indicator_o_mux0001_2_341 : LUT4_D
    generic map(
      INIT => X"8000"
    )
    port map (
      I0 => fax4_ins_a1b1(7),
      I1 => fax4_ins_a1b1(6),
      I2 => fax4_ins_a1b1(5),
      I3 => fax4_ins_a1b1(4),
      LO => N469,
      O => fax4_ins_mode_indicator_o_mux0001_2_341_1299
    );
  fax4_ins_mode_indicator_o_mux0001_2_3111 : LUT4_D
    generic map(
      INIT => X"8000"
    )
    port map (
      I0 => fax4_ins_a1b1(9),
      I1 => fax4_ins_a1b1(8),
      I2 => fax4_ins_a1b1(10),
      I3 => fax4_ins_mode_indicator_o_mux0001_2_36_1300,
      LO => N470,
      O => fax4_ins_mode_indicator_o_mux0001_2_3111_1298
    );
  fax4_ins_vertical_mode_cmp_le00002199 : LUT4_D
    generic map(
      INIT => X"EAAA"
    )
    port map (
      I0 => fax4_ins_vertical_mode_cmp_le000020_1361,
      I1 => fax4_ins_vertical_mode_cmp_le0000213_1363,
      I2 => fax4_ins_vertical_mode_cmp_le0000226_1365,
      I3 => fax4_ins_vertical_mode_cmp_le00002169_1364,
      LO => N471,
      O => fax4_ins_vertical_mode_cmp_le0000
    );
  fax4_ins_vertical_mode_cmp_le0000281 : LUT4_L
    generic map(
      INIT => X"F0F1"
    )
    port map (
      I0 => fax4_ins_a1b1(8),
      I1 => fax4_ins_a1b1(9),
      I2 => fax4_ins_a1b1(10),
      I3 => N113,
      LO => fax4_ins_vertical_mode_cmp_le0000281_1367
    );
  fax4_ins_a0_mux0000_9_SW0_SW0 : LUT4_D
    generic map(
      INIT => X"1DDD"
    )
    port map (
      I0 => fax4_ins_a1_o_mux0000(9),
      I1 => fax4_ins_N20,
      I2 => fax4_ins_pass_mode,
      I3 => fax4_ins_b2(0),
      LO => N472,
      O => N117
    );
  fax4_ins_a0_mux0000_5_SW0_SW0 : LUT4_D
    generic map(
      INIT => X"1DDD"
    )
    port map (
      I0 => fax4_ins_a1_o_mux0000(5),
      I1 => fax4_ins_N20,
      I2 => fax4_ins_pass_mode,
      I3 => fax4_ins_b2(4),
      LO => N473,
      O => N119
    );
  fax4_ins_a0_mux0000_4_SW0_SW0 : LUT4_D
    generic map(
      INIT => X"1DDD"
    )
    port map (
      I0 => fax4_ins_a1_o_mux0000(4),
      I1 => fax4_ins_N20,
      I2 => fax4_ins_pass_mode,
      I3 => fax4_ins_b2(5),
      LO => N474,
      O => N121
    );
  fax4_ins_a0_mux0000_3_SW0_SW0 : LUT4_D
    generic map(
      INIT => X"1DDD"
    )
    port map (
      I0 => fax4_ins_a1_o_mux0000(3),
      I1 => fax4_ins_N20,
      I2 => fax4_ins_pass_mode,
      I3 => fax4_ins_b2(6),
      LO => N475,
      O => N123
    );
  fax4_ins_a0_mux0000_2_SW0_SW0 : LUT4_D
    generic map(
      INIT => X"1DDD"
    )
    port map (
      I0 => fax4_ins_a1_o_mux0000(2),
      I1 => fax4_ins_N20,
      I2 => fax4_ins_pass_mode,
      I3 => fax4_ins_b2(7),
      LO => N476,
      O => N125
    );
  fax4_ins_a0_mux0000_0_SW0_SW0 : LUT4_D
    generic map(
      INIT => X"1DDD"
    )
    port map (
      I0 => fax4_ins_a1_o_mux0000(0),
      I1 => fax4_ins_N20,
      I2 => fax4_ins_pass_mode,
      I3 => fax4_ins_b2(9),
      LO => N477,
      O => N127
    );
  fax4_ins_a1b1_6_1 : LUT4_D
    generic map(
      INIT => X"EC4C"
    )
    port map (
      I0 => fax4_ins_counter_xy_v2_ins_frame_valid_1206,
      I1 => fax4_ins_a1b1_addsub0001(6),
      I2 => fax4_ins_counter_xy_v2_ins_line_valid_1210,
      I3 => fax4_ins_a1b1_addsub0000(6),
      LO => N478,
      O => fax4_ins_a1b1(6)
    );
  fax4_ins_a0_to_white_mux000047_SW1 : LUT4_D
    generic map(
      INIT => X"E444"
    )
    port map (
      I0 => fax4_ins_N20,
      I1 => fax4_ins_a0_to_white_mux000026_948,
      I2 => fax4_ins_pass_mode,
      I3 => fax4_ins_b2_to_white_1094,
      LO => N479,
      O => N133
    );
  fax4_ins_vertical_mode_cmp_le00002114_SW0 : LUT4_L
    generic map(
      INIT => X"FFE2"
    )
    port map (
      I0 => fax4_ins_a1b1_addsub0000(3),
      I1 => fax4_ins_EOL,
      I2 => fax4_ins_a1b1_addsub0001(3),
      I3 => fax4_ins_a1b1(2),
      LO => N111
    );
  fax4_ins_a1b1_2_1 : LUT4_D
    generic map(
      INIT => X"EC4C"
    )
    port map (
      I0 => fax4_ins_counter_xy_v2_ins_frame_valid_1206,
      I1 => fax4_ins_a1b1_addsub0001(2),
      I2 => fax4_ins_counter_xy_v2_ins_line_valid_1210,
      I3 => fax4_ins_a1b1_addsub0000(2),
      LO => N480,
      O => fax4_ins_a1b1(2)
    );
  fax4_ins_a1b1_10_1 : LUT4_D
    generic map(
      INIT => X"EC4C"
    )
    port map (
      I0 => fax4_ins_counter_xy_v2_ins_frame_valid_1206,
      I1 => fax4_ins_a1b1_addsub0001(10),
      I2 => fax4_ins_counter_xy_v2_ins_line_valid_1210,
      I3 => fax4_ins_a1b1_addsub0000(10),
      LO => N481,
      O => fax4_ins_a1b1(10)
    );
  fax4_ins_a1b1_8_1 : LUT4_D
    generic map(
      INIT => X"EC4C"
    )
    port map (
      I0 => fax4_ins_counter_xy_v2_ins_frame_valid_1206,
      I1 => fax4_ins_a1b1_addsub0001(8),
      I2 => fax4_ins_counter_xy_v2_ins_line_valid_1210,
      I3 => fax4_ins_a1b1_addsub0000(8),
      LO => N482,
      O => fax4_ins_a1b1(8)
    );
  fax4_ins_mode_indicator_o_mux0001_3_41 : LUT4_L
    generic map(
      INIT => X"FCAA"
    )
    port map (
      I0 => N160,
      I1 => N161,
      I2 => fax4_ins_mode_indicator_o_mux0001_3_9_1302,
      I3 => fax4_ins_vertical_mode_cmp_le0000,
      LO => fax4_ins_mode_indicator_o_mux0001(3)
    );
  fax4_ins_a1b1_7_1 : LUT4_D
    generic map(
      INIT => X"EC4C"
    )
    port map (
      I0 => fax4_ins_counter_xy_v2_ins_frame_valid_1206,
      I1 => fax4_ins_a1b1_addsub0001(7),
      I2 => fax4_ins_counter_xy_v2_ins_line_valid_1210,
      I3 => fax4_ins_a1b1_addsub0000(7),
      LO => N483,
      O => fax4_ins_a1b1(7)
    );
  fax4_ins_mode_indicator_o_mux0001_2_234 : LUT4_D
    generic map(
      INIT => X"0010"
    )
    port map (
      I0 => fax4_ins_a1b1(10),
      I1 => fax4_ins_a1b1(9),
      I2 => fax4_ins_mode_indicator_o_mux0001_2_232_1296,
      I3 => N218,
      LO => N484,
      O => fax4_ins_N15
    );
  fax4_ins_fifo2_rd1 : LUT4_D
    generic map(
      INIT => X"0010"
    )
    port map (
      I0 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt(0),
      I1 => N227,
      I2 => fax4_ins_fifo_rd22_1267,
      I3 => fax4_ins_Mcompar_fifo_rd_cmp_lt0000_cy(9),
      LO => N485,
      O => fax4_ins_fifo2_rd
    );
  fax4_ins_fifo1_rd1 : LUT4_D
    generic map(
      INIT => X"0080"
    )
    port map (
      I0 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt(0),
      I1 => N229,
      I2 => fax4_ins_fifo_rd22_1267,
      I3 => fax4_ins_Mcompar_fifo_rd_cmp_lt0000_cy(9),
      LO => N486,
      O => fax4_ins_fifo1_rd
    );
  fax4_ins_FIFO1_multi_read_ins_read_as_last_operation_and0000111 : LUT4_D
    generic map(
      INIT => X"2000"
    )
    port map (
      I0 => fax4_ins_fifo_rd22_1267,
      I1 => fax4_ins_Mcompar_fifo_rd_cmp_lt0000_cy(9),
      I2 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt(0),
      I3 => N231,
      LO => N487,
      O => fax4_ins_FIFO1_multi_read_ins_N8
    );
  fax4_ins_FIFO2_multi_read_ins_read_as_last_operation_and0000111 : LUT4_D
    generic map(
      INIT => X"0010"
    )
    port map (
      I0 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt(0),
      I1 => N233,
      I2 => fax4_ins_fifo_rd22_1267,
      I3 => fax4_ins_Mcompar_fifo_rd_cmp_lt0000_cy(9),
      LO => N488,
      O => fax4_ins_FIFO2_multi_read_ins_N8
    );
  fax4_ins_mode_indicator_o_1_rstpot_SW1 : LUT4_L
    generic map(
      INIT => X"111D"
    )
    port map (
      I0 => fax4_ins_mode_indicator_o(1),
      I1 => N167,
      I2 => N172,
      I3 => N235,
      LO => N221
    );
  fax4_ins_vertical_mode_cmp_le00002199_SW1 : LUT4_L
    generic map(
      INIT => X"888C"
    )
    port map (
      I0 => fax4_ins_state_FSM_FFd8_1338,
      I1 => N142,
      I2 => fax4_ins_vertical_mode_cmp_le0000226_1365,
      I3 => fax4_ins_vertical_mode_cmp_le000020_1361,
      LO => N240
    );
  fax4_ins_mux_a0_3_1 : LUT4_D
    generic map(
      INIT => X"207F"
    )
    port map (
      I0 => fax4_ins_vertical_mode_cmp_le0000213_1363,
      I1 => N246,
      I2 => fax4_ins_vertical_mode_cmp_le00002169_1364,
      I3 => N245,
      LO => N489,
      O => fax4_ins_mux_a0_3_Q
    );
  fax4_ins_a0_mux0000_1_11 : LUT4_D
    generic map(
      INIT => X"078F"
    )
    port map (
      I0 => fax4_ins_vertical_mode_cmp_le0000213_1363,
      I1 => fax4_ins_vertical_mode_cmp_le00002169_1364,
      I2 => N248,
      I3 => N249,
      LO => N490,
      O => fax4_ins_N01
    );
  fax4_ins_a0_mux0000_9_SW0 : LUT4_L
    generic map(
      INIT => X"207F"
    )
    port map (
      I0 => fax4_ins_vertical_mode_cmp_le0000213_1363,
      I1 => N252,
      I2 => fax4_ins_vertical_mode_cmp_le00002169_1364,
      I3 => N251,
      LO => N93
    );
  fax4_ins_a0_mux0000_5_SW0 : LUT4_L
    generic map(
      INIT => X"207F"
    )
    port map (
      I0 => fax4_ins_vertical_mode_cmp_le0000213_1363,
      I1 => N255,
      I2 => fax4_ins_vertical_mode_cmp_le00002169_1364,
      I3 => N254,
      LO => N95
    );
  fax4_ins_a0_mux0000_4_SW0 : LUT4_L
    generic map(
      INIT => X"207F"
    )
    port map (
      I0 => fax4_ins_vertical_mode_cmp_le0000213_1363,
      I1 => N258,
      I2 => fax4_ins_vertical_mode_cmp_le00002169_1364,
      I3 => N257,
      LO => N97
    );
  fax4_ins_a0_mux0000_3_SW0 : LUT4_L
    generic map(
      INIT => X"207F"
    )
    port map (
      I0 => fax4_ins_vertical_mode_cmp_le0000213_1363,
      I1 => N261,
      I2 => fax4_ins_vertical_mode_cmp_le00002169_1364,
      I3 => N260,
      LO => N99
    );
  fax4_ins_a0_mux0000_2_SW0 : LUT4_L
    generic map(
      INIT => X"207F"
    )
    port map (
      I0 => fax4_ins_vertical_mode_cmp_le0000213_1363,
      I1 => N264,
      I2 => fax4_ins_vertical_mode_cmp_le00002169_1364,
      I3 => N263,
      LO => N101
    );
  fax4_ins_a0_mux0000_0_SW0 : LUT4_L
    generic map(
      INIT => X"207F"
    )
    port map (
      I0 => fax4_ins_vertical_mode_cmp_le0000213_1363,
      I1 => N267,
      I2 => fax4_ins_vertical_mode_cmp_le00002169_1364,
      I3 => N266,
      LO => N103
    );
  fax4_ins_mux_b1_0_and000021 : LUT4_D
    generic map(
      INIT => X"0001"
    )
    port map (
      I0 => fax4_ins_pix_changed_1319,
      I1 => fax4_ins_state_FSM_FFd8_1338,
      I2 => fax4_ins_Mcompar_pass_mode_cmp_lt0000_cy(9),
      I3 => fax4_ins_EOL,
      LO => N491,
      O => fax4_ins_pass_mode
    );
  fax4_ins_mux_b1_0_and0000 : LUT4_D
    generic map(
      INIT => X"0060"
    )
    port map (
      I0 => fax4_ins_fifo_out_prev2_to_white_1252,
      I1 => fax4_ins_a0_to_white_946,
      I2 => N75,
      I3 => fax4_ins_Mcompar_mux_b1_0_cmp_gt0000_cy(9),
      LO => N492,
      O => fax4_ins_mux_b1(0)
    );
  fax4_ins_mux_b1_3_and0000 : LUT4_D
    generic map(
      INIT => X"0C04"
    )
    port map (
      I0 => fax4_ins_Mcompar_mux_b1_3_cmp_gt0000_cy(9),
      I1 => fax4_ins_fifo_out2_valid,
      I2 => N77,
      I3 => fax4_ins_EOL,
      LO => N493,
      O => fax4_ins_mux_b1(3)
    );
  fax4_ins_vertical_mode_cmp_le00002199_SW3 : LUT4_L
    generic map(
      INIT => X"FEFF"
    )
    port map (
      I0 => N269,
      I1 => fax4_ins_mux_a0_0_Q,
      I2 => fax4_ins_state_FSM_FFd8_1338,
      I3 => fax4_ins_vertical_mode_cmp_le0000213_1363,
      LO => N243
    );
  fax4_ins_vertical_mode_cmp_le00002199_SW9_SW0 : LUT4_D
    generic map(
      INIT => X"FF57"
    )
    port map (
      I0 => fax4_ins_a1b1(10),
      I1 => fax4_ins_vertical_mode_addsub0000(7),
      I2 => fax4_ins_vertical_mode_addsub0000(6),
      I3 => fax4_ins_vertical_mode_addsub0000(10),
      LO => N494,
      O => N271
    );
  fax4_ins_FIFO1_multi_read_ins_mux3_and0000 : LUT4_D
    generic map(
      INIT => X"0001"
    )
    port map (
      I0 => fax4_ins_EOL,
      I1 => fax4_ins_FIFO1_multi_read_ins_N4,
      I2 => fax4_ins_FIFO1_multi_read_ins_used(0),
      I3 => N341,
      LO => N495,
      O => fax4_ins_FIFO1_multi_read_ins_mux3
    );
  fax4_ins_mode_indicator_o_3_rstpot_SW0 : LUT4_L
    generic map(
      INIT => X"FFFE"
    )
    port map (
      I0 => fax4_ins_pass_mode,
      I1 => fax4_ins_load_a1_or0001,
      I2 => N142,
      I3 => fax4_ins_mode_indicator_o(3),
      LO => N179
    );
  fax4_ins_a0_mux0000_1_11_SW0 : LUT4_D
    generic map(
      INIT => X"7FFF"
    )
    port map (
      I0 => fax4_ins_counter_xy_v2_ins_line_valid_1210,
      I1 => fax4_ins_counter_xy_v2_ins_frame_valid_1206,
      I2 => fax4_ins_pix_changed_1319,
      I3 => fax4_ins_state_FSM_FFd8_1338,
      LO => N496,
      O => N115
    );
  fax4_ins_mux_b1_2_and000019 : LUT4_L
    generic map(
      INIT => X"569A"
    )
    port map (
      I0 => fax4_ins_a0_to_white_946,
      I1 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt(0),
      I2 => fax4_ins_FIFO2_multi_read_ins_to_white1_o_683,
      I3 => fax4_ins_FIFO1_multi_read_ins_to_white1_o_441,
      LO => fax4_ins_mux_b1_2_and000019_1310
    );
  fax4_ins_a1b1_1_1 : LUT4_D
    generic map(
      INIT => X"EC4C"
    )
    port map (
      I0 => fax4_ins_counter_xy_v2_ins_frame_valid_1206,
      I1 => fax4_ins_a1b1_addsub0001(1),
      I2 => fax4_ins_counter_xy_v2_ins_line_valid_1210,
      I3 => fax4_ins_a1b1_addsub0000(1),
      LO => N497,
      O => fax4_ins_a1b1(1)
    );
  fax4_ins_mux_b1_2_and000032 : LUT4_D
    generic map(
      INIT => X"00D8"
    )
    port map (
      I0 => NlwRenamedSig_OI_fax4_ins_counter_xy_v2_ins_counter_y_ins_cnt(0),
      I1 => fax4_ins_FIFO1_multi_read_ins_valid1_o_456,
      I2 => fax4_ins_FIFO2_multi_read_ins_valid1_o_698,
      I3 => N381,
      LO => N498,
      O => fax4_ins_mux_b1(2)
    );
  huffman_ins_v2_Mshreg_pass_vert_code_width_3_0 : SRL16
    generic map(
      INIT => X"0000"
    )
    port map (
      A0 => NlwRenamedSig_OI_run_len_code_o(26),
      A1 => NlwRenamedSig_OI_run_len_code_o(26),
      A2 => NlwRenamedSig_OI_run_len_code_o(26),
      A3 => NlwRenamedSig_OI_run_len_code_o(26),
      CLK => pclk_i,
      D => huffman_ins_v2_pass_vert_code_width_1_0_Q,
      Q => huffman_ins_v2_Mshreg_pass_vert_code_width_3_0_1400
    );
  huffman_ins_v2_pass_vert_code_width_3_0 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      D => huffman_ins_v2_Mshreg_pass_vert_code_width_3_0_1400,
      Q => huffman_ins_v2_pass_vert_code_width_3_0_Q
    );
  huffman_ins_v2_Mshreg_frame_finished_o : SRL16
    generic map(
      INIT => X"0000"
    )
    port map (
      A0 => NlwRenamedSig_OI_run_len_code_o(26),
      A1 => N1,
      A2 => NlwRenamedSig_OI_run_len_code_o(26),
      A3 => NlwRenamedSig_OI_run_len_code_o(26),
      CLK => pclk_i,
      D => frame_finished_wire,
      Q => huffman_ins_v2_Mshreg_frame_finished_o_1395
    );
  huffman_ins_v2_frame_finished_o : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      D => huffman_ins_v2_Mshreg_frame_finished_o_1395,
      Q => huffman_ins_v2_frame_finished_o_1814
    );
  huffman_ins_v2_Mshreg_pass_vert_code_width_3_2 : SRL16
    generic map(
      INIT => X"0000"
    )
    port map (
      A0 => NlwRenamedSig_OI_run_len_code_o(26),
      A1 => NlwRenamedSig_OI_run_len_code_o(26),
      A2 => NlwRenamedSig_OI_run_len_code_o(26),
      A3 => NlwRenamedSig_OI_run_len_code_o(26),
      CLK => pclk_i,
      D => huffman_ins_v2_pass_vert_code_width_1_2_Q,
      Q => huffman_ins_v2_Mshreg_pass_vert_code_width_3_2_1401
    );
  huffman_ins_v2_pass_vert_code_width_3_2 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      D => huffman_ins_v2_Mshreg_pass_vert_code_width_3_2_1401,
      Q => huffman_ins_v2_pass_vert_code_width_3_2_Q
    );
  huffman_ins_v2_Mshreg_pass_vert_code_3_2 : SRL16
    generic map(
      INIT => X"0001"
    )
    port map (
      A0 => NlwRenamedSig_OI_run_len_code_o(26),
      A1 => NlwRenamedSig_OI_run_len_code_o(26),
      A2 => NlwRenamedSig_OI_run_len_code_o(26),
      A3 => NlwRenamedSig_OI_run_len_code_o(26),
      CLK => pclk_i,
      D => huffman_ins_v2_pass_vert_code_1(2),
      Q => huffman_ins_v2_Mshreg_pass_vert_code_3_2_1399
    );
  huffman_ins_v2_pass_vert_code_3_2 : FD
    generic map(
      INIT => '1'
    )
    port map (
      C => pclk_i,
      D => huffman_ins_v2_Mshreg_pass_vert_code_3_2_1399,
      Q => huffman_ins_v2_pass_vert_code_3(2)
    );
  huffman_ins_v2_Mshreg_pass_vert_code_3_1 : SRL16
    generic map(
      INIT => X"0000"
    )
    port map (
      A0 => NlwRenamedSig_OI_run_len_code_o(26),
      A1 => NlwRenamedSig_OI_run_len_code_o(26),
      A2 => NlwRenamedSig_OI_run_len_code_o(26),
      A3 => NlwRenamedSig_OI_run_len_code_o(26),
      CLK => pclk_i,
      D => huffman_ins_v2_pass_vert_code_1(1),
      Q => huffman_ins_v2_Mshreg_pass_vert_code_3_1_1398
    );
  huffman_ins_v2_pass_vert_code_3_1 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      D => huffman_ins_v2_Mshreg_pass_vert_code_3_1_1398,
      Q => huffman_ins_v2_pass_vert_code_3(1)
    );
  huffman_ins_v2_Mshreg_pass_vert_code_3_0 : SRL16
    generic map(
      INIT => X"0000"
    )
    port map (
      A0 => NlwRenamedSig_OI_run_len_code_o(26),
      A1 => NlwRenamedSig_OI_run_len_code_o(26),
      A2 => NlwRenamedSig_OI_run_len_code_o(26),
      A3 => NlwRenamedSig_OI_run_len_code_o(26),
      CLK => pclk_i,
      D => huffman_ins_v2_pass_vert_code_1(0),
      Q => huffman_ins_v2_Mshreg_pass_vert_code_3_0_1397
    );
  huffman_ins_v2_pass_vert_code_3_0 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      D => huffman_ins_v2_Mshreg_pass_vert_code_3_0_1397,
      Q => huffman_ins_v2_pass_vert_code_3(0)
    );
  huffman_ins_v2_Mshreg_run_len_code_valid_o : SRL16
    generic map(
      INIT => X"0000"
    )
    port map (
      A0 => N1,
      A1 => NlwRenamedSig_OI_run_len_code_o(26),
      A2 => NlwRenamedSig_OI_run_len_code_o(26),
      A3 => NlwRenamedSig_OI_run_len_code_o(26),
      CLK => pclk_i,
      D => fax4_ins_output_valid_o_1311,
      Q => huffman_ins_v2_Mshreg_run_len_code_valid_o_1402
    );
  huffman_ins_v2_run_len_code_valid_o : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      D => huffman_ins_v2_Mshreg_run_len_code_valid_o_1402,
      Q => huffman_ins_v2_run_len_code_valid_o_2082
    );
  huffman_ins_v2_Mshreg_horizontal_mode_3 : SRL16
    generic map(
      INIT => X"0000"
    )
    port map (
      A0 => NlwRenamedSig_OI_run_len_code_o(26),
      A1 => NlwRenamedSig_OI_run_len_code_o(26),
      A2 => NlwRenamedSig_OI_run_len_code_o(26),
      A3 => NlwRenamedSig_OI_run_len_code_o(26),
      CLK => pclk_i,
      D => huffman_ins_v2_horizontal_mode_1_2060,
      Q => huffman_ins_v2_Mshreg_horizontal_mode_3_1396
    );
  huffman_ins_v2_horizontal_mode_3 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      D => huffman_ins_v2_Mshreg_horizontal_mode_3_1396,
      Q => huffman_ins_v2_horizontal_mode_3_2063
    );
  huffman_ins_v2_Mshreg_a0_value_2 : SRL16
    generic map(
      INIT => X"0000"
    )
    port map (
      A0 => NlwRenamedSig_OI_run_len_code_o(26),
      A1 => NlwRenamedSig_OI_run_len_code_o(26),
      A2 => NlwRenamedSig_OI_run_len_code_o(26),
      A3 => NlwRenamedSig_OI_run_len_code_o(26),
      CLK => pclk_i,
      D => fax4_ins_a0_value_o_950,
      Q => huffman_ins_v2_Mshreg_a0_value_2_1394
    );
  huffman_ins_v2_a0_value_2 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => pclk_i,
      D => huffman_ins_v2_Mshreg_a0_value_2_1394,
      Q => huffman_ins_v2_a0_value_2_1510
    );

end Structure;

