v 20121203 2
C 1500 300 1 0 0 in_port_v.sym
{
T 1500 300 5 10 1 1 0 6 1
refdes=tdo_i[1:0]
}
C 1500 700 1 0 0 in_port.sym
{
T 1500 700 5 10 1 1 0 6 1
refdes=trst_n_pad_in
}
C 1500 1100 1 0 0 in_port.sym
{
T 1500 1100 5 10 1 1 0 6 1
refdes=tms_pad_in
}
C 1500 1500 1 0 0 in_port.sym
{
T 1500 1500 5 10 1 1 0 6 1
refdes=tdi_pad_in
}
C 1500 1900 1 0 0 in_port.sym
{
T 1500 1900 5 10 1 1 0 6 1
refdes=tclk_pad_in
}
C 5400 300 1 0 0 out_port_v.sym
{
T 6400 300 5 10 1 1 0 0 1
refdes=shiftcapture_dr_clk_o[1:0]
}
C 5400 700 1 0 0 out_port_v.sym
{
T 6400 700 5 10 1 1 0 0 1
refdes=select_o[1:0]
}
C 5400 1100 1 0 0 out_port.sym
{
T 6400 1100 5 10 1 1 0 0 1
refdes=user2_clk
}
C 5400 1500 1 0 0 out_port.sym
{
T 6400 1500 5 10 1 1 0 0 1
refdes=user1_clk
}
C 5400 1900 1 0 0 out_port.sym
{
T 6400 1900 5 10 1 1 0 0 1
refdes=update_dr_o
}
C 5400 2300 1 0 0 out_port.sym
{
T 6400 2300 5 10 1 1 0 0 1
refdes=update_dr_clk_o
}
C 5400 2700 1 0 0 out_port.sym
{
T 6400 2700 5 10 1 1 0 0 1
refdes=test_logic_reset_o
}
C 5400 3100 1 0 0 out_port.sym
{
T 6400 3100 5 10 1 1 0 0 1
refdes=tdo_pad_out
}
C 5400 3500 1 0 0 out_port.sym
{
T 6400 3500 5 10 1 1 0 0 1
refdes=tdo_pad_oe
}
C 5400 3900 1 0 0 out_port.sym
{
T 6400 3900 5 10 1 1 0 0 1
refdes=tdi_o
}
C 5400 4300 1 0 0 out_port.sym
{
T 6400 4300 5 10 1 1 0 0 1
refdes=tap_highz_mode
}
C 5400 4700 1 0 0 out_port.sym
{
T 6400 4700 5 10 1 1 0 0 1
refdes=shift_dr_o
}
C 5400 5100 1 0 0 out_port.sym
{
T 6400 5100 5 10 1 1 0 0 1
refdes=jtag_shift_clk
}
C 5400 5500 1 0 0 out_port.sym
{
T 6400 5500 5 10 1 1 0 0 1
refdes=jtag_clk
}
C 5400 5900 1 0 0 out_port.sym
{
T 6400 5900 5 10 1 1 0 0 1
refdes=capture_dr_o
}
C 2200 5100 1 0 0 and2-1.sym
{
T 2600 5000 5 10 1 1 0 2 1
refdes=U?
T 2600 5200 5 8 0 0 0 0 1
device=and
}
