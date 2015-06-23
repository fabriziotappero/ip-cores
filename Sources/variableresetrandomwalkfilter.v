
/* random-walk filter with variable reset */

module variableresetrandomwalkfilter(MainClock, Lead, Lag, Positive, Negative);
 input  MainClock, Lead, Lag; // System Clock and Phase Comparator signals
 output Positive, Negative;   // "positive shift" and "negative shift" outputs

parameter N_FilterLength      = 8;
parameter N_FilterResetValue  = 8;
parameter N_FilterMaxValue    = N_FilterResetValue;

/* 256=2_PWR_8(counter length). Use this value because unsigned arithmetic */
parameter N_FilterMinValue    = 256 - N_FilterResetValue;

/* the counter length of reset scheme must be short */
parameter ResetterCounterLength   = 4;
parameter ResetterCounterMaxValue = 3;

/* 16=2_PWR_4 */
parameter ResetterCounterMinValue = 16 - 3;

/* counter "N - RandomWalkFilter" */ 
reg [N_FilterLength-1 : 0] N_FilterCounter;

/* connections of "M - RandomWalkFilter" */
wire Up, Down;
randomwalkfilter inst_M_Filter(.MainClock(MainClock), .Lead(Lead), .Lag(Lag),
                                             .Positive(Up), .Negative(Down));
defparam inst_M_Filter.FilterResetValue = 32;  // length "M-RWF" = 32

/* Reset Scheme. This counter changes on "M-RWF" counter */
reg [ResetterCounterLength-1 : 0] ResetterCounter;
always @(posedge MainClock)
 begin
  if(Up)
   begin
    if((ResetterCounter < ResetterCounterMaxValue) || (ResetterCounter >= ResetterCounterMinValue))
     ResetterCounter <= ResetterCounter + 1;
   end
  else if(Down)
   begin
    if((ResetterCounter <= ResetterCounterMaxValue) || (ResetterCounter > ResetterCounterMinValue))
     ResetterCounter <= ResetterCounter - 1;
   end
  if((ResetterCounter > ResetterCounterMaxValue) && (ResetterCounter < ResetterCounterMinValue))
     ResetterCounter <= 0;
 end

/* Look-Up Table between ResetterCounter value and reset state of "N-RWF" */
reg [N_FilterLength-1 : 0] ResetterValue;
always @(1)
 begin
  case(ResetterCounter)
   16 - 3:  ResetterValue = 256 - 7;
   16 - 2:  ResetterValue = 256 - 6;
   16 - 1:  ResetterValue = 256 - 4;
   0:       ResetterValue = 0;
   1:       ResetterValue = 4;
   2:       ResetterValue = 6;
   3:       ResetterValue = 7;
   default: ResetterValue = 0;
  endcase
 end

/* "N-RWF" Filter has different reset states */
/* in accordance ResetterCounter value       */
always @(posedge MainClock)
 begin
  if((N_FilterCounter == N_FilterMaxValue) || (N_FilterCounter == N_FilterMinValue))
    N_FilterCounter <= ResetterValue;
    else
     begin
      if(Lead) N_FilterCounter <= N_FilterCounter + 1;
      if(Lag)  N_FilterCounter <= N_FilterCounter - 1;
     end
 end

/* making "Lead" and "Lag" signals when  */
/* counter reached max or min levels     */
reg Positive, Negative;
always @(posedge MainClock)
 begin
  Positive <= (N_FilterCounter == N_FilterMaxValue);
  Negative <= (N_FilterCounter == N_FilterMinValue);
 end

endmodule
