interface Max#(type data_t);
  interface ReadOnly#(data_t) max;
  method Action inputSample(data_t sample);
endinterface

module mkMax (Max#(data_t))
  provisos (Bits#(data_t,data_sz),
            Ord#(data_t),
            Bounded#(data_t));

  Reg#(data_t) result <- mkReg(minBound);

  interface ReadOnly max;
    method _read = result._read;
  endinterface

  method Action inputSample(data_t sample);
    if(sample > result)
      begin
        result <= sample;
      end
  endmethod
endmodule