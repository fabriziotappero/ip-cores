
/* frequency divider and phase controller */

module freqdivider(MainClock, Positive, Negative, FrequencyOut);
 input MainClock;                 // main clock
 input Positive, Negative;    // signals Positive, Negative are synchronous with MainClock
 output FrequencyOut;         // output frequency

/* needed counter length */
parameter DividerLength   = 7;

/*  controlled prescaler, after this prescales the "divider by 2" installed,     */
/*  so composite divide coefficient will be equivalent of 96 (in this example) - */
/*  it's necessary for work DPLL on frequency 192kHz with oscillator             */
/*  frequency 18432kHz                                                           */
/* additional divider by 2 used for getting output signal with duty factor of 2  */

parameter DividerMaxValue = 48;

reg [DividerLength-1 : 0] DividerCounter;
reg FrequencyOut;        // registered output

/* Process of freq. division according to  signals from Random  Deviations Filter:  */
/* if "lag" then counter will incremented by 2                                                                          */
/* if "lead" then counter will not changed                                                                                */
/* if there is no phase lead or lag then counter normally incremented by 1                          */

always @(posedge MainClock)
 begin
  if(DividerCounter >= (DividerMaxValue - 1))
    DividerCounter <= 0;
    else if(Negative)       DividerCounter <= DividerCounter + 2;
          else if(Positive) DividerCounter <= DividerCounter;
                else        DividerCounter <= DividerCounter + 1;
  if(DividerCounter == 0) FrequencyOut <= ~FrequencyOut;           // additional divider by 2 - for producing 50% duty factor of the output signal
 end

endmodule
