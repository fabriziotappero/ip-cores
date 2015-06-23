
/* Random Walk Filter with reset value of 0*/
module randomwalkfilter(MainClock, Lead, Lag, Positive, Negative);
 input  MainClock, Lead, Lag;    // System Clock and Phase Comparator signals
 output Positive, Negative;      // "positive shift" and "negative shift" outputs

/* some parametere are accessible from outside */
parameter FilterLength      = 8;
parameter FilterResetValue  = 4;
parameter FilterMaxValue    = FilterResetValue;
parameter FilterMinValue    = 256 - FilterResetValue;

/* reversive counter */ 
reg [FilterLength-1 : 0] FilterCounter;

/* calculation of output pulses synchrinized with MainClock */
always @(posedge MainClock)
 begin
  if((FilterCounter == FilterMaxValue) || (FilterCounter == FilterMinValue))
    FilterCounter <= 0;
    else
     begin
      if(Lead) FilterCounter <= FilterCounter + 1;
      if(Lag)  FilterCounter <= FilterCounter - 1;
     end
 end

/* making "Lead" and "Lag" signals when  */
/* counter reached max or min levels     */
reg Positive, Negative;
always @(posedge MainClock)
 begin
  Positive <= (FilterCounter == FilterMaxValue);
  Negative <= (FilterCounter == FilterMinValue);
 end

endmodule


