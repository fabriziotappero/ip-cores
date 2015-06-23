@echo off

pushd ..
pushd ..
set xrisc=%cd%
set icon=%xrisc%\intercon
set cpu=%xrisc%\cpu\rtl
set mem=%xrisc%\mem\rtl
set flash=%xrisc%\flash\rtl
set ddr=%xrisc%\ddr\rtl
set vga=%xrisc%\vga\rtl
set keyb=%xrisc%\keyb\rtl
set pit=%xrisc%\pit\rtl
set uart=%xrisc%\rs232\rtl
set rtl=%icon%\rtl
set tb=%icon%\bench
popd
popd

echo Compiling testbench for "cpu" ...
vlib work
vcom %cpu%\mips1.vhd %cpu%\tcpu.vhd %cpu%\icpu.vhd  %cpu%\fcpu.vhd %cpu%\gpr.vhd
vcom %cpu%\cpu.vhd %rtl%\iwb.vhd %cpu%\iwbm.vhd %cpu%\wbm.vhd 
vcom %mem%\imem.vhd %xrisc%\sw\bin\data.vhd %mem%\mem.vhd 
vcom %flash%\iflash.vhd %flash%\flash.vhd
REM vcom %ddr%\iddr.vhd %ddr%\ddr_init.vhd %ddr%\ddr.vhd
vcom %vga%\ivga.vhd %vga%\ram.vhd %vga%\rom.vhd %vga%\vga.vhd
vcom %keyb%\ikeyb.vhd %keyb%\keyb.vhd
vcom %pit%\ipit.vhd %pit%\pit.vhd
vcom %uart%\iuart.vhd %uart%\uartr.vhd %uart%\uartt.vhd
vcom %rtl%\icon.vhd %rtl%\intercon.vhd %tb%\tb_icon.vhd

vsim -do icon.do tb_icon tb
