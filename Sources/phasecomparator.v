
/* phase comparator */
module phasecomparator(InputSignal, OutputSignal, MainClock, Lead, Lag);

input InputSignal, OutputSignal;    // PLL input(reference) and output(dejittered clock) signals
input MainClock;                    // System Clock
output Lead, Lag;                   // Lead and Lag signals

reg [1:0] InputSignalEdgeDet;       // detector of the rising edge
always @(posedge MainClock)
 begin
  InputSignalEdgeDet <= { InputSignalEdgeDet[0], InputSignal };
 end


/* this signal checked at rising edge of MainClock.       */
/* It's simple detector of the Input signal rising edge - */
/* When it detected then we check the level of the output.*/
/* There is possible to place additional 2 registers for  */
/* output signal for eliminatig  the cmp. constant phase error */
wire InputSignalEdge = (InputSignalEdgeDet == 2'b01);

/* "Lead" signal will be generate in case of output==1 during input rising edge*/
reg Lead, Lag;                   // outputs "Lead", "Lag" are registered
always @(posedge MainClock)
 begin                         
  Lag  <= ((InputSignalEdge == 1'b1)  && (OutputSignal == 1'b0));
  Lead <= ((InputSignalEdge == 1'b1)  && (OutputSignal == 1'b1));
 end

endmodule
