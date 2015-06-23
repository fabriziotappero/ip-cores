| Script file for testing the minimal an maximal Baudrate excursion around the
| nominal Baudrate of 125kHz (in term of %)
 
| Initial settings
delete_waveforms
restart 
stepsize 50nS
 
| Watched Signals and Vectors
watch WB_CLK_I | Wishbone clock
watch WB_RST_I

vector RxData RxData7 RxData6 RxData5 RxData4 RxData3 RxData2 RxData1 RxData0
watch RxD_PAD_I	| RS232 Rx Line
watch IntRx_O	| Emit Buffer is empty
watch BR_Clk_I
watch EnabRx

| Stimulators Assignment
clock WB_CLK_I	1 0	| BR_CLK_I=10MHz
wfm WB_RST_I	@1nS=L 100nS=H 100nS=L
assign WB_STB_I 0
assign WB_WE_I 0

wfm BR_Clk_I  @0nS=L (0.946uS=H 1uS=L)*8000 | BR_Clk_I=500kHz
| BRDIVISOR=1. Baudrate=500000/1/4=125kHz (Bit period=8uS)
| Below is a generation of 50 same frames, coding 40h. 
wfm RxD_PAD_I    @0nS=H +
           102.7uS=H (8uS=L 8uS=L 8uS=L 8uS=L 8uS=L 8uS=L 8uS=L 8uS=H 8uS=L 8uS=H)*150 8uS=H

| Perform Simulation
sim 10mS

| Results:
| max BR_Clk_I: 2.118uS
| min BR_Clk_I: 1.946uS

