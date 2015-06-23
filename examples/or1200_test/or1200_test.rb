require_relative '../../lib/soc_maker'

options = {}
options[ :libpath     ] = "./core_lib/"
##
# initialize SOCMaker core
#   this sets up logging and parses all yaml files
#   found in the configure path (see also soc_maker_conf.rb)
SOCMaker::load( options )


puts "Library Content:"


puts SOCMaker::lib


SOCMaker::lib.cores do |name_version, core|
#   core.update_vcs
end

soc = SOCMaker::SOCDef.new( 'OR1200 Test SOC', 'or1200_test,v1', 'or1200_test' )
SOCMaker::lib.add_core( soc )
soc_inst = SOCMaker::CoreInst.new( 'or1200_test,v1' )
#soc_inst.name = "soc_inst"


port = SOCMaker::IfcPort.new( 'clk', 1 )
ifc  = SOCMaker::IfcDef.new( 'clk', 'clk,1', 1, { 'clk_i' => port} )
soc.interfaces[ 'clk_ifc'.to_sym ] = ifc

port = SOCMaker::IfcPort.new( 'rst', 1 )
ifc  = SOCMaker::IfcDef.new( 'rst', 'rst,1', 1, { 'rst_i' => port} )
soc.interfaces[ 'rst_ifc'.to_sym ] = ifc

soc.interfaces[ 'jtag_ifc'.to_sym ] = SOCMaker::IfcDef.new( 'jtag_tap', 'jtag_tap,1', 1, {
   'tck_i'           => SOCMaker::IfcPort.new( 'tck', 1 ),
   'tdi_i'           => SOCMaker::IfcPort.new( 'tdi', 1 ),
   'tdo_o'           => SOCMaker::IfcPort.new( 'tdo' ,1 ),
   'debug_rst_i'     => SOCMaker::IfcPort.new( 'rst', 1 ),
   'shift_dr_i'      => SOCMaker::IfcPort.new( 'shift', 1 ),
   'pause_dr_i'      => SOCMaker::IfcPort.new( 'pause', 1 ),
   'update_dr_i'     => SOCMaker::IfcPort.new( 'update', 1 ),
   'capture_dr_i'    => SOCMaker::IfcPort.new( 'capture', 1 ),
   'debug_select_i'  => SOCMaker::IfcPort.new( 'select', 1 ) } )

soc.interfaces[ 'uart_ifc'.to_sym ] = SOCMaker::IfcDef.new( 'uart', 'uart,1', 1, {
   'stx_pad_o'   => SOCMaker::IfcPort.new( 'stx_pad',   1 ),
   'srx_pad_i'   => SOCMaker::IfcPort.new( 'srx_pad',   1 ),
   'rts_pad_o'   => SOCMaker::IfcPort.new( 'rts_pad',   1 ),
   'cts_pad_i'   => SOCMaker::IfcPort.new( 'cts_pad',   1 ),
   'dtr_pad_o'   => SOCMaker::IfcPort.new( 'dtr_pad',   1 ),
   'dsr_pad_i'   => SOCMaker::IfcPort.new( 'dsr_pad',   1 ),
   'ri_pad_i'    => SOCMaker::IfcPort.new( 'ri_pad' ,   1 ),
   'dcd_pad_i'   => SOCMaker::IfcPort.new( 'dcd_pad',   1 ) } )


soc.add_core( 'or1200,rel2',           'cpu'    )
soc.add_core( 'wb_connect,1',          'wb_bus' )
soc.add_core( 'adv_debug_sys,ads_3',   'dbg'    )
soc.add_core( 'ram_wb,b3',             'ram1'   )
soc.add_core( 'ram_wb,b3',             'ram2'   )
soc.add_core( 'uart16550,rel4',        'uart'   )
soc.consistency_check


#
# Setup the CPU
#
soc.set_sparam( 'or1200,rel2', 'VCD_DUMP', false )
soc.set_sparam( 'or1200,rel2', 'VERBOSE',  false )
soc.set_sparam( 'or1200,rel2', 'ASIC'   ,  false )

soc.set_sparam( 'or1200,rel2', 'ASIC_MEM_CHOICE', 0 )
soc.set_sparam( 'or1200,rel2', 'ASIC_NO_DC', true )
soc.set_sparam( 'or1200,rel2', 'ASIC_NO_IC', true )
soc.set_sparam( 'or1200,rel2', 'ASIC_NO_DMMU', true )
soc.set_sparam( 'or1200,rel2', 'ASIC_NO_IMMU', true )
soc.set_sparam( 'or1200,rel2', 'ASIC_MUL_CHOICE', 0 )
soc.set_sparam( 'or1200,rel2', 'ASIC_IC_CHOICE', 0 )
soc.set_sparam( 'or1200,rel2', 'ASIC_DC_CHOICE', 0 )


soc.set_sparam( 'or1200,rel2', 'FPGA_MEM_CHOICE', 0 )
soc.set_sparam( 'or1200,rel2', 'FPGA_NO_DC', true )
soc.set_sparam( 'or1200,rel2', 'FPGA_NO_IC', true )
soc.set_sparam( 'or1200,rel2', 'FPGA_NO_DMMU', true )
soc.set_sparam( 'or1200,rel2', 'FPGA_NO_IMMU', true )
soc.set_sparam( 'or1200,rel2', 'FPGA_MUL_CHOICE', 1 )
soc.set_sparam( 'or1200,rel2', 'FPGA_IC_CHOICE', 0 )
soc.set_sparam( 'or1200,rel2', 'FPGA_DC_CHOICE', 0 )

#
# Setup the on-chip memory
#
soc.set_sparam( 'ram_wb,b3', 'MEM_SIZE', 10 )
soc.set_sparam( 'ram_wb,b3', 'MEM_ADR_WIDTH', 14 )


#
#
#

soc.add_connection( 'clk_ifc', 'cpu', 'clk',  'con_main_clk'      )
soc.add_connection( 'rst_ifc', 'cpu', 'rst',  'con_main_rst'      )
soc.add_connection( 'clk_ifc', 'wb_bus', 'clk',  'con_main_clk'   )
soc.add_connection( 'rst_ifc', 'wb_bus', 'rst',  'con_main_rst'   )

soc.add_connection( 'wb_bus', 'i3', 'dbg',  'wb_ifc',           'con_wb_debug'    )
soc.add_connection( 'wb_bus', 'i4', 'cpu',  'wb_data',          'con_data'        )
soc.add_connection( 'wb_bus', 'i5', 'cpu',  'wb_instruction',   'con_instruction' )
soc.add_connection( 'wb_bus', 't0', 'ram1',  'wb_ifc',           'con_ram1'         )
soc.add_connection( 'wb_bus', 't1', 'ram2',  'wb_ifc',           'con_ram2'         )
soc.add_connection( 'wb_bus', 't2', 'uart', 'wb_ifc',           'con_uart'        )

soc.add_connection( 'dbg',         'cpu0_dbg',  'cpu', 'ext_debug',           'con_debug'       )

soc.add_connection( 'clk_ifc',   'dbg',        'cpu0_dbg_clk',   'con_main_clk'     )
soc.add_connection( 'jtag_ifc',  'dbg',        'jtag',           'con_jtag_top'         )
soc.add_connection( 'uart_ifc',  'uart',       'uart_ifc',       'con_uart_top'         )

soc_inst.consistency_check
soc_inst.gen_toplevel

soc.copy_files

