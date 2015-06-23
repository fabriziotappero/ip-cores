module test_out (
  input               clk,
  input               rst,

  input               enable,
  output  reg         busy,
  output  reg         error,

  input               ready,
  output  reg         activate,
  input       [23:0]  size,
  input       [31:0]  data,
  output  reg         strobe,
  output  reg [23:0]  total_count
  
);

reg           [31:0]  test_value;
reg           [23:0]  count;

always @ (posedge clk) begin
  if (rst) begin
    activate          <=  0;
    count             <=  0;
    test_value        <=  32'h0;
    error             <=  0;
    busy              <=  0;
    total_count       <=  0;
    strobe            <=  0;
  end
  else begin
    busy              <=  0;
    strobe            <=  0;
    //The user is not asking to check anything
    if (!enable) begin
      //activate        <=  0;
      //count           <=  0;
      test_value      <=  32'h0;
      error           <=  0;
      total_count     <=  0;
    end

    //Looking for total count
    //busy            <=  1;
    if (ready && !activate) begin
      count         <=  0;
      activate      <=  1;
    end
    else if (activate) begin
      busy            <= 1;
      if (count < size) begin
        strobe      <=  1;
        total_count <=  total_count + 1;
        count       <=  count + 1;
        if ((data != test_value) && enable) begin
          error     <=  1;
        end
      end
      else begin
        activate  <=  0;
      end
    end
    if (strobe) begin
      test_value  <= test_value + 1;
    end
  end
end

endmodule
