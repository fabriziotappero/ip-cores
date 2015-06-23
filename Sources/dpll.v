
/* Top module */
module dpll(SignalIn, SignalOut, MainClock,
            Positive, Negative, Lead, Lag
            );
input  SignalIn;                // input signal
input  MainClock;               // reference signal
output SignalOut;               // output
output Positive, Negative;      // internal DPLL signals
output Lead, Lag;               // internal DPLL signals

// phase comparator 
phasecomparator inst_ph_cmp(.MainClock(MainClock), .InputSignal(SignalIn),
                            .OutputSignal(SignalOut), .Lead(Lead), .Lag(Lag)
                            );
/*
// "Zero-Reset Random Walk Filter"
randomwalkfilter inst_zrwf(.MainClock(MainClock), .Lead(Lead), .Lag(Lag),
                           .Positive(Positive), .Negative(Negative)
                           );
*/

// "Variable-Reset Random Walk Filter"
variableresetrandomwalkfilter inst_zrwf(.MainClock(MainClock), .Lead(Lead), .Lag(Lag),
                           .Positive(Positive), .Negative(Negative)
                           );

// controlled frequency divider
freqdivider inst_freqdiv(.MainClock(MainClock), .FrequencyOut(SignalOut),
                           .Positive(Positive), .Negative(Negative)
                           );

endmodule
