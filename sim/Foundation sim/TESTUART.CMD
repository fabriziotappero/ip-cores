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
vector WB_ADR ADR_I[1:0]
vector WB_DI DAT_I[7:0]
vector WB_DO DAT_O[7:0]
watch RxD	TEcho| RS232 Rx Line
watch TxD	| RS232 Tx Line
watch IntTx | Byte present in buffer
watch IntRx	| Emit Buffer is empty
watch BRClk
watch EnabTx EnabRx

| Stimulators Assignment
| 1/Write Byte
| 2/Write another byte
| 3/Read Byte
| 4/Read Byte
clock WB_CLK_I	1 0
wfm WB_RST_I	@1nS=L 100nS=H 100nS=L
wfm WB_STB_I	@1nS=L +
        		@100.001uS=H 100nS=L +
				@200.001uS=H 100nS=L +
				@250.001uS=H 100nS=L +			
				@355.501uS=H 100nS=L
wfm WB_WE_I		@1nS=L +
	  			@100.001uS=H +
	            @200.001uS=L +
				@250.001uS=H +
	            @355.501uS=L
wfm WB_ADR		@1nS=L +
				@100.001uS=0\H 100nS=Z +
				@200.001uS=0\H 100nS=Z +
				@250.001uS=0\H 100nS=Z +
	            @355.501uS=0\H 100nS=Z
wfm WB_DI		@1nS=\0H +
				@100.001uS=81\H 101nS=Z +
				@250.001uS=55\H 101nS=Z
wfm BRClk @0nS=L (500nS=H 500nS=L)*500

| Perform Simulation
sim 400uS

