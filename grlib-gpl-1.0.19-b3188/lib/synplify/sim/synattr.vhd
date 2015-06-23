-- $Header: /syn/cvs/rcs/compilers/vhdl/vhd/synattr.vhd,v 1.90.2.14.2.1 2003/07/08 18:06:01 akapoor Exp $
-----------------------------------------------------------------------------
--                                                                         --
-- Copyright (c) 1997-2003 by Synplicity, Inc.  All rights reserved.       --
--                                                                         --
-- This source file may be used and distributed without restriction        --
-- provided that this copyright statement is not removed from the file     --
-- and that any derivative work contains this copyright notice.            --
--                                                                         --
--                                                                         --
--  Library name: synplify                                                 --
--  Package name: attributes                                               --
--                                                                         --
--  Description:  This package contains declarations for synplify          --
--                attributes                                               --
--                                                                         --
--                                                                         --
--                                                                         --
-----------------------------------------------------------------------------
--

 -- Definitions used for Scope Integration ----------------
 --{tcl set actel "act* 40* 42* 32* 54* ex* ax*"}
 --{tcl set altera "max* flex* acex*"}
 --{tcl set altera_retiming "flex* acex* apex* mercury* excalibur*"}
 --{tcl set apex "apex20k apexii excalibur*"}
 --{tcl set apexe "apex20kc apex20ke mercury* stratix* cyclone"}
 --{tcl set apex20k "apex20k*"}
 --{tcl set lattice "pLSI*"}
 --{tcl set mach "mach* isp* gal*"}
 --{tcl set quicklogic "pasic* quick* eclipse*"}
 --{tcl set lucent "orca*"}
 --{tcl set xilinx "xc* vir* spart*"}
 --{tcl set virtex "vir* spartan*"}
 --{tcl set virtex2 "virtex2*"}
 --{tcl set stratix "stratix*"}
 --{tcl set triscend "triscend*" }
 --{tcl set asic "asic*" }
 --{tcl set atmel "fpslic" }
 --{tcl set cp_only "apex20k* excalibur* mercury apexii stratix* cyclone spartan* virtex*" }
  -------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all;

package attributes is
    
 -- Compiler attributes

  -- {family *}
 attribute phys_pin_loc : string; -- pin loacatin {objtype port} {desc Placement constarint for pin or pad} {physattr 1}
 attribute phys_pin_hslots : string; -- pin loacatin {objtype module} {desc Set of slots or placable IO locations} {physattr 1}
 attribute phys_pin_vslots : string; -- pin loacatin {objtype module} {desc Set of slots or placable IO locations} {physattr 1}
 attribute phys_halo : string; -- pin loacatin {objtype module cell } {desc Halo to be used for the macros} {physattr 1}

 -- syn_enum_encoding specifies the encoding for an enumeration type
 attribute syn_enum_encoding : string;  -- "onehot", "sequential", "gray" {noscope}

 -- syn_encoding specifies the encoding for a state register
 attribute syn_encoding : string;       -- "onehot", "sequential", "gray", "safe" {objtype fsm} {desc FSM encoding (onehot, sequential, gray, safe)} {default gray}  {enum onehot sequential gray safe safe,onehot safe,sequential safe,gray default}

-- syn_allow_retiming specifies if the register can be moved for retiming purpose
-- {family $altera_retiming $virtex $virtex2 $stratix }
 attribute syn_allow_retiming : boolean;    -- {objtype register} {desc Controls retiming of registers} {default 0}

 attribute syn_state_machine : boolean; -- marks reg for SM extraction {noscope}
 --
 -- syn_preserve prevents optimization across registers it is
 -- applied to.  syn_preserve on a module/arch is applied to all
 -- registers in the module/arch.  syn_preserve on a register
 -- will preserve redundant copies.
 -- Can also be used to preserve redundant copies of instantiated
 -- combinational cells.
 attribute syn_preserve : boolean; -- {noscope}

 -- syn_keep is used on signals keep the signal through optimization
 -- so that timing constraints can be placed on the signal later.
 -- The timing constraints can be multi-cycle path and clock.
 attribute syn_keep : boolean; -- {noscope}
                
 attribute syn_sharing : string;        -- "off" or "on" {noscope}

 -- syn_evaleffort is used on modules to define the effort to be used in
 -- evaluating conditions for control structures.  This is useful for 
 -- those modules that contain while loop or if-then-else conditions 
 -- that may evaluate to a constant if more effort is applied.
 -- The higher this number, the higher the evaluation effort,
 -- and consequently the memory requirement and CPU time.  The default
 -- value is 4.
 -- This attribute is not recommended!
 attribute syn_evaleffort : integer;    -- an integer between 0 and 100 {noscope}

 -- syn_cpueffort is used on modules to define the cpu effort to be used in
 -- various optimizations (such as BDDs).  It may take a value from 1 to 10,
 -- with the default being 5.   A value of 1 to 4 would result in less CPU
 -- time and most likely less optimization, while a value of 6 to 10 would
 -- result in longer CPU time and possibly more optimization.
 --
 -- This attribute is not recommended!
 attribute syn_cpueffort : integer;    -- an integer between 1 and 10  {noscope}

 -- syn_looplimit my be attached to a loop label.   It represents the maximum
 -- number of loop iterations that are allowed.   Use this attribute when
 -- Synplify errors out after reaching the maximum loop limit.
 attribute syn_looplimit : integer;    -- the maximum loop count allowed  {noscope}

 -- the syn_pmux_slice attribute is used to enable the pmux optimization
 -- code on/off. If on at the last architecture, it is carried on the 
 -- hierarcy chain until it finds an architecture in which the attribute
 -- is expicitly set to off.
 attribute syn_pmux_slice : boolean; -- a boolean value {noscope}
 
 attribute syn_isclock : boolean; -- {noscope}

-- turn on or off priority mux code
 attribute syn_primux : boolean; -- {noscope}

 -- General mapping attributes

 -- inst/module/arch
  --{family *}
 attribute syn_resources : string; -- spec resources used by module {noscope} {objtype cell} {desc Specifies resources used by module/architecture}

 attribute syn_area : string; -- spec resources used by module {noscope}

 attribute syn_noprune : boolean; -- keep object even if outputs unused {noscope} {objtype cell} {desc Retain instance when outputs are unused}

 attribute syn_probe : string; -- {objtype signal} {app ~synplify_asic} {desc Send a signal to output port for testing} {enum 0 1}

 attribute syn_direct_enable : boolean; -- {objtype signal} {app ~synplify_asic} {desc Prefered clock enable} {default 1} {enum 1}

 -- registers
 attribute syn_useenables : boolean; -- set to false to disable enable use {objtype register} {app ~synplify_asic} {desc Generate with clock enable pin}

 -- registers
 attribute syn_reference_clock : string; -- set to the name of the reference clock {objtype register} {desc Override the default clock with the given clock }

 -- I/O registers
  -- {family $lucent $apex $apexe $xilinx $quicklogic}
 attribute syn_useioff : boolean; -- set to false to disable use of I/O FF {objtype global port register} {desc Embed flip-flps in the IO ring}

  -- {family $xilinx $apex $apexe}
 attribute syn_forward_io_constraints : boolean; -- set to true to forward annotate IO constraints {objtype global} {desc Forward annotate IO constraints}

 -- used to specify implementations for dff in actel for now

 -- {family $actel}
 attribute syn_implement : string;      -- "dff", "dffr", "dffs", "dffrs" {noscope}
  attribute syn_radhardlevel : string;   -- "none", "cc", "tmr", "tmr_cc" {objtype register } {desc Radiation-hardened implementation style} {enum none cc tmr tmr_cc}


 -- {family asic}
 attribute syn_ideal_net : string; -- {objtype signal} {desc Do not buffer this net during optimization} {enum 1}

 -- {family asic}
 attribute syn_ideal_network : string; -- {objtype signal} {desc Do not buffer this network during optimization} {enum 1}

 -- {family asic}
 attribute syn_no_reopt : string; -- {objtype module} {desc Do not resize during reoptimization} {enum 1}

 -- {family asic}
 attribute syn_wire_load : string; -- {objtype module} {desc Set the wire load model to use for this module} {enum -read-wireloads-}

 -- {family *}
 -- black box attributes
 attribute syn_black_box : boolean;         -- disables automatic black box warning {noscope}

 -- OLD black box attributes
 attribute black_box : boolean;         -- disables automatic black box warning {noscope}
 attribute black_box_pad_pin : string;  -- names of I/O pad connections {noscope}
 attribute black_box_tri_pins : string; -- names of tristate ports {noscope}

 -- Black box timing attributes
 -- tpd : timing propagation delay
 -- tsu : timing setup delay
 -- tco : timing clock to output delay
 attribute syn_tpd1 : string; -- {noscope}
 attribute syn_tpd2 : string; -- {noscope}
 attribute syn_tpd3 : string; -- {noscope}
 attribute syn_tpd4 : string; -- {noscope}
 attribute syn_tpd5 : string; -- {noscope}
 attribute syn_tpd6 : string; -- {noscope}
 attribute syn_tpd7 : string; -- {noscope}
 attribute syn_tpd8 : string; -- {noscope}
 attribute syn_tpd9 : string; -- {noscope}
 attribute syn_tpd10 : string; -- {noscope}
 attribute syn_tsu1 : string; -- {noscope}
 attribute syn_tsu2 : string; -- {noscope}
 attribute syn_tsu3 : string; -- {noscope}
 attribute syn_tsu4 : string; -- {noscope}
 attribute syn_tsu5 : string; -- {noscope}
 attribute syn_tsu6 : string; -- {noscope}
 attribute syn_tsu7 : string; -- {noscope}
 attribute syn_tsu8 : string; -- {noscope}
 attribute syn_tsu9 : string; -- {noscope}
 attribute syn_tsu10 : string; -- {noscope}
 attribute syn_tco1 : string; -- {noscope}
 attribute syn_tco2 : string; -- {noscope}
 attribute syn_tco3 : string; -- {noscope}
 attribute syn_tco4 : string; -- {noscope}
 attribute syn_tco5 : string; -- {noscope}
 attribute syn_tco6 : string; -- {noscope}
 attribute syn_tco7 : string; -- {noscope}
 attribute syn_tco8 : string; -- {noscope}
 attribute syn_tco9 : string; -- {noscope}
 attribute syn_tco10 : string; -- {noscope}
 
 
 -- Mapping attributes

 -- {family $actel $xilinx $lucent $quicklogic $altera $apex $apexe}
 attribute syn_maxfan : integer;     -- {objtype input_port register_output cell} {desc Overrides the default fanout}

  -- {family $actel $xilinx $lucent $quicklogic $lattice $mach $virtex $virtex2 $triscend $asic $atmel $cp_only}
 attribute syn_noclockbuf : boolean; -- {objtype global cell input_port module} {app ~synplify_asic} {desc Use normal input buffer}

  -- {family $virtex stratix* }
 attribute syn_srlstyle : string;    -- {objtype cell global module} {desc Determines how seq. shift comp. are implemented} {default select_srl} {enum virtex (select_srl registers noextractff_srl) stratix(select_srl registers noextractff_srl altshift_tap)}

 -- set syn_ramstyle to a value of "registers" to force the ram
 -- to be implemented with registers.
-- {family $altera $apex $apexe $xilinx $lucent $quicklogic stratix* }
 attribute syn_ramstyle : string;    -- {objtype cell global module} {desc Map inferred RAM to registers} {default registers} {desc Special implementation of inferred RAM} {enum Virtex virtex-E spartan2 spartan2e virtex2 virtex2-pro(registers block_ram no_rw_check select_ram) xilinx_default (registers select_ram) stratix (registers block_ram no_rw_check) altera_default (registers block_ram) default (registers) all_enums (registers block_ram no_rw_check select_ram)}

-- {family $virtex2 $altera $apex $apexe $apex20k $lattice $lucent $mach excalibur*}
 attribute syn_multstyle : string;    -- {objtype cell global module} {default block_mult} {desc Special implementation of multipliers} {enum Virtex virtex-E spartan2 spartan2e virtex2 virtex2-pro(logic block_mult) stratix(logic lpm_mult block_mult) altera_default (logic lpm_mult)  all_enums (logic block_mult lpm_mult)}

-- {family $virtex $virtex2}
 attribute syn_tops_region_size : integer; -- {objtype global} {desc max. size of valid TOPS region in LUTs} {app amplify}

-- set syn_romstyle to a value of "logic" to force the rom
-- to be implemented with logic, select_rom/block_rom
-- {family $altera $apex $apexe $xilinx}
attribute syn_romstyle : string;    -- {objtype cell global module} {desc Controls mapping of inferred ROM} {default logic} {desc Special implementation of inferred ROM} {enum xilinx_default (logic select_rom) altera_default(logic block_rom lpm_rom) default(logic) all_enums (logic select_rom block_rom) }

-- set syn_pipeline to a value 1 to pipeline the module front of it
-- {family $altera $apex $apexe $xilinx}
 attribute syn_pipeline : boolean;    -- {objtype register} {desc Controls pipelining of registers} {default 1} {desc Special implementation of pipelined module}

 -- controls EDIF format.  Set true on top level to disable array ports
  -- {family *}
 attribute syn_noarrayports : boolean; -- {objtype global} {app ~synplify_asic} {desc Disable array ports}

 -- controls EDIF port name length. Currently used in Altera
 -- {family $altera}
 attribute syn_edif_name_length : string;  -- {enum Restricted Unrestricted} {default Restricted} {objtype global} {desc Use Restricted for MAXII; Unrestricted for quartus}

  -- {family *}

 -- controls reconstruction of hierarchy.  Set false on top level
 -- to disable hierarchy reconstruction.
 attribute syn_netlist_hierarchy : boolean; -- {objtype global} {app ~synplify_asic} {desc Enable hierarchy reconstruction}

 --
 -- syn_hier on an instance/module/architecture can be used
 -- to control treatment of the level of hierarchy.
 -- "macro" - preserve instantiated netlist
 -- "hard" - preserves the interface of the design unit with no exceptions.
 -- "remove"- removes level of hierarchy
 -- "soft"  - managed by Synplify (default)
 -- "firm"  - preserve during opt, but allow mapping across boundary
 --
  -- {family *}
 attribute syn_hier: string; -- {objtype module} {desc Control hierarchy flattening} {enum proASIC (soft remove flatten firm) xilinx_default(hard soft remove flatten firm) actel_default altera_default all_enums(hard soft macro remove flatten firm) lucent_default (soft macro remove flatten firm) quicklogic_default(soft macro remove flatten firm) default(soft remove flatten firm)}
 -- syn_flatten on a module/architecture will flatten out the
 -- module all the way down to primitives.
 attribute syn_flatten : boolean; -- {noscope}

 -- {family $cp_only }
 attribute syn_allowed_resources : string; -- {objtype module} {desc Control resource usage in a compile point}
 
 -- Architecture specific attributes
 -- Actel
  -- {family $actel}

 --
 -- syn_preserve_sr_priority is used if you want to preserve
 -- reset over set priority for DFFRS.  Actel FF models produce
 -- an X for set and reset active.  This attribute costs gates and delay.
 attribute syn_preserve_sr_priority : boolean; -- {noscope}
 attribute alspin : string ; --{objtype port} {desc Pin locations for Actel I/Os}
 attribute alspreserve : boolean ; --{objtype signal} {desc Not collapse a net in Actel}
 attribute alsfc : string ; --{noscope}
 attribute alsdc : string ; --{noscope}
 attribute alsloc : string ; --{noscope}
 attribute alscrt : string ; --{noscope}

 -- Altera
 -- {family $altera $apex $apexe}
 
 attribute altera_implement_style : string; -- placement {noscope}
 attribute altera_clique : string; -- placement {noscope}
 attribute altera_chip_pin_lc : string; -- placement {objtype port} {desc I/O pin location}
 -- inst/module/arch:  put comb logic into rom
 attribute altera_implement_in_eab : boolean; -- {objtype cell} {desc Implment in Altera EABs, apply to module/component instance name only} {default 1}
 attribute altera_lcell: string; -- arch attribute with values of "lut" and "car" {noscope}
 								 -- for lcell config
 attribute altera_auto_use_eab : boolean; -- {objtype global} {desc Use EABs automatically} {default 1}
 attribute altera_auto_use_esb : boolean; -- {objtype global} {desc Use ESBs automatically} {default 1}

 -- Apex  
 -- {family $apex $apexe}

 attribute altera_implement_in_esb : boolean; -- {objtype cell} {desc Implment in Altera ESBs, apply to module/component instance name only} {default 1}

 -- Apex  
 -- {family $apex $apexe}

 attribute altera_logiclock_location : string; -- {objtype module} {desc Give the location of LogicLock region } {default floating} 


-- Apex  
 -- {family $apex $apexe}

 attribute altera_logiclock_size : string; -- {objtype module} {desc Give the size of LogicLock region} {default auto} 


 -- {family apex20kc apex20ke excalibur* mercury* cyclone stratix* acex* flex10k* }
 attribute altera_io_opendrain : boolean; -- set to true to get opendrain port in APEX {objtype port} {desc Use opendrain capability on port or bit-port.}

 -- {family $altera_retiming}
 attribute altera_io_powerup : string; -- set to high to get IO FF to powerup high in APEX {objtype port} {desc Powerup high or low on port or bit-port in APEX20KE.}

 -- Lattice
 -- {family $lattice $quicklogic}
 
 attribute lock: string; -- pin placement {objtype port} {desc Pin locations for Lattice I/Os}
 
 -- Lucent
 -- {family $lucent}
 
 attribute din : string; -- orca2 FF placement attribute, use value "" {objtype input_port} {desc Input register goes next to I/O pad}
 attribute dout : string; -- orca2 FF placement attribute, use value "" {objtype output_port} {desc Output register goes next to I/O pad}
 attribute orca_padtype : string; -- value selects synth pad type {objtype port} {desc Pad type for I/O}
 attribute orca_props : string; -- attributes to pass for instance {objtype cell port} {desc Forward annotate attributes to ORCA back-end}

 -- Both Lucent and Mach
 -- {family $lucent $mach}
 attribute loc : string;  -- placment attribute {objtype port} {desc Pin location}


 -- Quicklogic
  -- {family $quicklogic}
 
 -- I/O attributes
 attribute ql_padtype : string; -- {objtype port} {desc Override default pad types (use BIDIR, INPUT, CLOCK)} {enum BIDIR INPUT CLOCK}
 attribute ql_placement : string; -- {objtype port cell} {desc Placement location}
 
 
 -- Xilinx
 -- {family $xilinx}

 -- Instance Placement attributes
 attribute xc_loc : string; -- placement (pads) {objtype port} {desc Port placement}
 attribute xc_rloc : string; -- see RPMs in xilinx doc {objtype cell} {desc Relative placement specification, use with xc_uset}
 attribute xc_uset : string; -- see RPMs in xilinx doc {objtype cell} {desc Assign group name for placement, use with xc_rloc}
 -- I/O attributes
 attribute xc_fast : boolean; -- {objtype output_port} {desc Fast transition time}
 attribute xc_ioff : boolean; -- {noscope}
 attribute xc_nodelay : boolean; -- {objtype input_port} {desc Remove input delay}
 attribute xc_slow : boolean; -- {objtype output_port} {desc Slow transition time}
 attribute xc_ttl : boolean; -- {noscope}
 attribute xc_cmos : boolean; -- {noscope}
 attribute xc_pullup : boolean;   -- add a pullup to I/O {objtype port} {desc Add a pullup}
 attribute xc_pulldown : boolean; -- add a pulldown to I/O {objtype port} {desc Add a pulldown}
 attribute xc_clockbuftype : string; -- {objtype input_port} {default BUFGDLL} {desc Use the Xilinx BUFGDLL clock buffer}
 attribute xc_padtype : string; -- {objtype port} {desc Applies an I/O standard to an I/O buffer}
 
 -- Top level architecture attributes
 -- number of global buffers, used only for XC4000, XC4000E
 attribute syn_global_buffers : integer; -- {objtype global} {desc Number of global buffers}
 attribute xc_use_timespec_for_io : boolean; -- {objtype global} {desc Enable use of from-to timepsec instead of offset for I/O constraint} {default 0}

 -- Xilinx Modular Design Flow --
 attribute xc_pseudo_pin_loc : string; -- {objtype signal} {default CLB_RrrCcc:CLB_RrrCcc} {desc Pseudo pin location on place and route block }
 attribute xc_modular_design : boolean; -- {objtype global } {default 1} {desc Enable modular design flow }
 attribute xc_modular_region : string; -- {objtype cell } {default rr#cc#rr#cc} {desc Specifies the number of CLB's for a modular region}

 -- Xilinx Incremental Design Flow --
  attribute xc_area_group : string; -- {objtype cell } {default rr#cc#rr#cc} {desc Specifies the region where instance should be placed}

 -- Black box attributes
 -- {family $xilinx}
 attribute xc_alias : string; -- cell name change in XNF writer {noscope}
 attribute xc_props : string; -- extra XNF attributes to pass for instance {objtype cell} {desc Extra XNF attributes to pass for instance}
 attribute xc_map : string;   -- used to map entity to fmap/hmap/lut {objtype module} {desc Map entity to fmap/hmap/lut} {enum fmap hmap lut}
 attribute xc_isgsr : boolean; -- used to mark port of core with built in GSR {noscope}

 attribute syn_tristatetomux : integer ; -- {objtype module global} {desc Threshold for converting tristates to mux}
 attribute syn_edif_bit_format  : string ; -- {objtype global} {desc Format bus names} {enum %u<%i> %u[%i] %u(%i) %u_%i %u%i %d<%i> %d[%i] %d(%i) %d_%i %d%i %n<%i> %n[%i] %n(%i) %n_%i %n%i}

 attribute syn_edif_scalar_format : string; -- {objtype global} {desc Format scaler names} {enum %u %n %d}

 attribute xc_fast_auto : boolean; -- {objtype global} {desc Enable automatic fast output buffer use}

 -- Triscend
 -- {family $triscend}

 attribute tr_map : string;   -- used to map entity to LUT {objtype module} {desc Map entity to LUT}

 attribute syn_props : string; -- extra attributes to pass to EDIF for instance {objtype cell} {desc Extra attributes to pass to EDIF for instance}

-- syn_replicate controls replication of registers
-- {family $virtex $virtex2 $altera $apex $apexe $apex20k}
 attribute syn_replicate : boolean; -- {objtype global register} {desc Controls replication of registers} {default 0}

 -- {family $xilinx}
attribute syn_verification_options : string; -- {objtype module} {default black_box} {desc Allows a module to be defined as a black_box for verification }


end attributes;
