import Register::*;

interface Averager#(type data_t);
  interface ReadOnly#(data_t) average;
  method Action inputSample(data_t sample);
endinterface

module mkAverager#(Integer samplesPerAverage) (Averager#(Bit#(data_sz)));

  let counter <- mkReg(0);
  Reg#(Bit#(data_sz)) result <- mkReg(0);
  Reg#(Bit#(data_sz)) sum <- mkReg(0);

  if(exp(2,log2(samplesPerAverage)) != samplesPerAverage) 
    begin
      error("Averager must average power of two samples");
    end

  interface average = readOnly(result._read);
  method Action inputSample(Bit#(data_sz) sample);
     if(counter + 1 == fromInteger(samplesPerAverage))
       begin
         result <= (sum + sample) >> fromInteger(log2(samplesPerAverage));
         sum <= 0;
         counter <= 0;
       end
     else
       begin
         counter <= counter + 1;
         sum <= sum + sample;
       end
  endmethod
endmodule