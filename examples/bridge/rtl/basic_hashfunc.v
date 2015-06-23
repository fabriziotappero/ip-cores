/*
 *  Simple parameterized hash function
 * 
 * Takes an input item and folds it back upon itself using xor
 * as a reduction function.  Works only for hash tables with
 * a natural power of 2.
 */
module basic_hashfunc
  #(parameter input_sz=48,
    parameter table_sz=1024,
    parameter fsz=$clog2(table_sz))
  (
   input [input_sz-1:0]  hf_in,
   output reg [fsz-1:0]  hf_out);

  // const function not supported by Icarus Verilog
  //localparam folds = num_folds(input_sz, fsz);
  localparam folds = 5;

  wire [folds*fsz-1:0]   tmp_array;
  
  assign tmp_array = hf_in;
  
  integer                f, b;

  always @*
    begin
      for (b=0; b<fsz; b=b+1)
        begin
          hf_out[b] = 0;
          for (f=0; f<folds; f=f+1)
            hf_out[b] = hf_out[b]^tmp_array[f*fsz+b];
        end
    end

  function integer num_folds;
    input [31:0] in_sz;
    input [31:0] func_sz;
    integer      tmp_in_sz;
    begin
      num_folds = 0;
      tmp_in_sz = in_sz;
      while (tmp_in_sz > 0)
        begin
          tmp_in_sz = tmp_in_sz - func_sz;
          num_folds = num_folds + 1;
        end
    end
  endfunction
      
/* -----\/----- EXCLUDED -----\/-----
  function integer clogb2;
    input [31:0] depth;
    integer      i;
    begin
      i = depth;
      for (clogb2=0; i>0; clogb2=clogb2+1)
        i = i >> 1;
    end
  endfunction // for
 -----/\----- EXCLUDED -----/\----- */
  
endmodule // hashfunc
