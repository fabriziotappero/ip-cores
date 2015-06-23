| Script file for testing the UART in echo mode (Txd and must be RxD tied)
| 2 writes followed by 2 read
 
| Initial settings
delete_waveforms
restart 
stepsize 50nS
 
| Watched Signals and Vectors
| 
| Define your signal and vector watch list here
watch WB_CLK_I
watch WB_RST_I
watch WB_WE_I
watch WB_STB_I
watch WB_ACK_O
vector WB_ADR WB_ADR_I[1:0]
vector WB_DI WB_DAT_I[7:0]
vector WB_DO WB_DAT_O[7:0]
watch TxD_PAD_O	| RS232 Tx Line
watch IntTx_O	| Byte present in buffer
watch IntRx_O	| Emit Buffer is empty
watch BR_Clk_I
watch EnabTx EnabRx

| Stimulators Assignment
| 1/Write Byte
| 2/Write another byte
clock WB_CLK_I	1 0
wfm WB_RST_I	@1nS=L 100nS=H 100nS=L
wfm WB_STB_I	@1nS=L +
        		@100.001uS=H 100nS=L +
				@250.001uS=H 100nS=L		
wfm WB_WE_I		@1nS=L +
	  			@100.001uS=H +
				@250.001uS=H
wfm WB_ADR		@1nS=L +
				@100.001uS=0\H 100nS=Z +
				@250.001uS=0\H 100nS=Z
wfm WB_DI		@1nS=\0H +
				@100.001uS=81\H 101nS=Z +
				@250.001uS=55\H 101nS=Z
wfm BR_Clk_I @610nS=L (500nS=H 500nS=L)*1500

| Perform Simulation
sim 1500uS

