module test_in (
  input               clk,
  input               rst,

  input               enable,
  output  reg         finished,
  input       [23:0]  write_count,

  input       [1:0]   ready,
  output  reg [1:0]   activate,
  output  reg [31:0]  fifo_data,
  input       [23:0]  fifo_size,
  output  reg         strobe
);


//Parameters
//Registers/Wires
reg           [23:0]  count;
reg           [23:0]  total_count;
//Sub modules
//Asynchronous Logic
//Synchronous Logic

always @ (posedge clk or posedge rst) begin
  if (rst) begin
    activate            <=  0;
    fifo_data           <=  0;
    strobe              <=  0;
    count               <=  0;
    total_count         <=  0;
    finished            <=  0;
  end
  else begin
    strobe              <=  0;
    if (!enable) begin
        total_count     <=  0;
        activate        <=  0;
        finished        <=  0;
    end
    else if (total_count < write_count) begin
      if ((ready > 0) && (activate == 0)) begin
        //A FIFO is available
        count             <=  0;
        if (ready[0]) begin
          activate[0]     <=  1;
        end
        else begin
          activate[1]     <=  1;
        end
      end
      else if ((activate > 0) && (count < fifo_size))begin
        fifo_data         <=  total_count;
        total_count       <=  total_count + 1;
        count             <=  count + 1;
        strobe            <=  1;
      end
      else begin
        activate          <=  0;
      end
    end
    else begin
        finished          <=  1;
        activate          <=  0;
    end
  end
end

endmodule
