sh mkdir synopsys
set objects synopsys
set hdlin_ff_always_sync_set_reset true
set hdlin_infer_complex_set_reset true
set hdlin_translate_off_skip_text true
set suppress_errors VHDL-2285
set hdlin_use_carry_in true
source  compile.dc
analyze -f VHDL -library work config.vhd
analyze -f VHDL -library work ahbrom.vhd
analyze -f VHDL -library work vga_clkgen.vhd
analyze -f VHDL -library work leon3mp.vhd
elaborate leon3mp
