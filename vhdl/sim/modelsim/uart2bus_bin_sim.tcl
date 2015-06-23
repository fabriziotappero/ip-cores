set prj_home "../.."
set tb_home "$prj_home/bench"
set src_home "$prj_home/rtl"
set sim_home "$prj_home/sim/modelsim"
set wave_file "wave_uart2bus_bin.do"
set time "2500 us"

transcript file ""
transcript file $sim_home/transcript.log

if {[file exists $sim_home/work]} {
  file delete -force $sim_home/work
}
vlib $sim_home/work
vmap work $sim_home/work

vcom -work work $src_home/uart2BusTop_pkg.vhd
vcom -work work $src_home/uartTx.vhd
vcom -work work $src_home/uartRx.vhd
vcom -work work $src_home/baudGen.vhd
vcom -work work $src_home/uartTop.vhd
vcom -work work $src_home/uartParser.vhd
vcom -work work $src_home/uart2BusTop.vhd

vcom -work work $tb_home/helpers/helpers_pkg.vhd
vcom -work work $tb_home/helpers/regFileModel.vhd
vcom -work work $tb_home/uart2BusTop_bin_tb.vhd

onbreak {resume}

vsim -voptargs=+acc work.uart2BusTop_bin_tb(behavior)

do $sim_home/$wave_file

run $time

transcript file ""