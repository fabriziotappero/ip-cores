// Generic priority selector module
module psel (req, gnt);
  //synopsys template
  parameter WIDTH=8;
  input wire  [WIDTH-1:0] req;
  output wire [WIDTH-1:0] gnt;

  //priority selector
  genvar i;
  generate
    for(i = WIDTH-1; i>0; i=i-1)
    begin: sel
        assign gnt[i] = req[i] & ~(|req[i-1:0]);
    end

    assign gnt[0] = req[0];
  endgenerate

endmodule
