----------------------------------------------------------------------  
----  stepping_logic                                              ---- 
----                                                              ---- 
----  This file is part of the                                    ----
----    Modular Simultaneous Exponentiation Core project          ---- 
----    http://www.opencores.org/cores/mod_sim_exp/               ---- 
----                                                              ---- 
----  Description                                                 ---- 
----    stepping logic to control the pipeline for one            ----
----    montgommery multiplication                                ----
----                                                              ----
----  Dependencies:                                               ----
----    - d_flip_flop                                             ----
----    - counter_sync                                            ----
----                                                              ----
----  Authors:                                                    ----
----      - Geoffrey Ottoy, DraMCo research group                 ----
----      - Jonas De Craene, JonasDC@opencores.org                ---- 
----                                                              ---- 
---------------------------------------------------------------------- 
----                                                              ---- 
---- Copyright (C) 2011 DraMCo research group and OPENCORES.ORG   ---- 
----                                                              ---- 
---- This source file may be used and distributed without         ---- 
---- restriction provided that this copyright statement is not    ---- 
---- removed from the file and that any derivative work contains  ---- 
---- the original copyright notice and the associated disclaimer. ---- 
----                                                              ---- 
---- This source file is free software; you can redistribute it   ---- 
---- and/or modify it under the terms of the GNU Lesser General   ---- 
---- Public License as published by the Free Software Foundation; ---- 
---- either version 2.1 of the License, or (at your option) any   ---- 
---- later version.                                               ---- 
----                                                              ---- 
---- This source is distributed in the hope that it will be       ---- 
---- useful, but WITHOUT ANY WARRANTY; without even the implied   ---- 
---- warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ---- 
---- PURPOSE.  See the GNU Lesser General Public License for more ---- 
---- details.                                                     ---- 
----                                                              ---- 
---- You should have received a copy of the GNU Lesser General    ---- 
---- Public License along with this source; if not, download it   ---- 
---- from http://www.opencores.org/lgpl.shtml                     ---- 
----                                                              ---- 
----------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library mod_sim_exp;
use mod_sim_exp.mod_sim_exp_pkg.all;


-- stepping logic for the pipeline, generates the start pulses for the
-- first stage and keeps track of when the last stages are done
entity stepping_logic is
  generic(
    n : integer := 1536;  -- max nr of steps required to complete a multiplication
    t : integer := 192    -- total nr of steps in the pipeline
  );
  port(
    core_clk          : in  std_logic;  -- clock input
    start             : in  std_logic;  -- start signal for pipeline (one multiplication)
    reset             : in  std_logic;  -- reset signal
    t_sel             : in integer range 0 to t; -- nr of stages in the pipeline piece
    n_sel             : in integer range 0 to n; -- nr of steps(bits in operands) required for a complete multiplication
    start_first_stage : out std_logic;  -- start pulse output for first stage
    stepping_done     : out std_logic   -- done signal
  );
end stepping_logic;


architecture Behavioral of stepping_logic is

  -- signals for the first stage control, pulses and counters
  signal first_stage_done     : std_logic; -- indicates the first stage is done running for this multiplication
  signal first_stage_active   : std_logic; -- indicates the first stage is active
  signal first_stage_active_d : std_logic; -- delayed version of first_stage_active
  signal start_first_stage_i  : std_logic; -- internal version of start_first_stage output

  -- signals for the last stages control and counter
  signal last_stages_done     : std_logic; -- indicates the last stages are done running for this multiplication
  signal last_stages_active   : std_logic; -- indicates the last stages are active
  signal last_stages_active_d : std_logic; -- delayed version of last_stages_active

begin

	-- map outputs
	stepping_done <= last_stages_done;
	
	-- internal signals
	--------------------
	-- first_stage_active signal gets active from a start pulse 
	--                                inactive from first_stage_done pulse
	first_stage_active <= start or (first_stage_active_d and not first_stage_done);
	
	-- done signal gets active from a first_stage_done pulse
	--                  inactive from last_stages_done pulse
	last_stages_active <= first_stage_done or (last_stages_active_d and not last_stages_done);
	
	-- map start_first_stage_i to output, but also use the initial start pulse
	start_first_stage <= start or start_first_stage_i;
	
  last_stages_active_delay : d_flip_flop
  port map(
    core_clk => core_clk,
    reset    => reset,
    din      => last_stages_active,
    dout     => last_stages_active_d
  );

  first_stage_active_delay : d_flip_flop
  port map(
    core_clk => core_clk,
    reset    => reset,
    din      => first_stage_active,
    dout     => first_stage_active_d
  );
  
  -- the counters
  ----------------
  
  -- for counting the last steps (waiting for the other stages to stop)
  -- counter for keeping track of how many stages are done
  laststeps_counter : counter_sync
  generic map(
    max_value => t
  )
  port map(
    reset_value => t_sel,
    core_clk    => core_clk,
    ce          => last_stages_active,
    reset       => reset,
    overflow    => last_stages_done
  );

  -- counter for keeping track of how many times the first stage is started
  -- counts bits in operand x till operand width then generates pulse on first_stage_done
  steps_counter : counter_sync
  generic map(
    max_value => n
  )
  port map(
    reset_value => (n_sel),
    core_clk    => core_clk,
    ce          => start_first_stage_i,
    reset       => reset,
    overflow    => first_stage_done
  );

  -- the output (overflow) of this counter starts the first stage every 2 clock cycles
  substeps_counter : counter_sync
  generic map(
    max_value => 2
  )
  port map(
    reset_value => 2,
    core_clk    => core_clk,
    ce          => first_stage_active,
    reset       => reset,
    overflow    => start_first_stage_i
  );

end Behavioral;