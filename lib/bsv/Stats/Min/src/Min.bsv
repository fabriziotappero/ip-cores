import Register::*;

interface Min#(type data_t);
  interface ReadOnly#(data_t) min;
  method Action inputSample(data_t sample);
endinterface

module mkMin (Min#(data_t))
  provisos (Bits#(data_t,data_sz),
            Ord#(data_t),
            Bounded#(data_t));

  Reg#(data_t) result <- mkReg(maxBound);

  interface min = readOnly(result._read);

  method Action inputSample(data_t sample);
    if(sample < result)
      begin
        result <= sample;
      end
  endmethod
endmodule