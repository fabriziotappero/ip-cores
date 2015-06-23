module data_test2 (
  input                 rst,            //reset
  input                 clk,

  output  reg           din_stb,
  input         [1:0]   din_ready,
  output  reg   [1:0]   din_activate,
  output  reg   [31:0]  din,
  input         [23:0]  din_size,

  input                 dout_ready,
  output  reg           dout_activate,
  input         [31:0]  dout,
  output  reg           dout_stb,
  input         [23:0]  dout_size,

  output  reg           count_error,
  output  reg           incorrect_data,
  output  reg   [23:0]  count_detected,
  output  reg   [31:0]  detected_value

);

//Parameters
//Registers/Wires
reg             [31:0]  write_count;
reg             [31:0]  read_count;
//Submodules
//Asynchronous Logic
//Synchronous Logic

always @ (posedge clk) begin
  if (rst) begin
    din_stb             <=  0;
    din_activate        <=  0;
    din                 <=  0;
    write_count         <=  0;

    dout_activate       <=  0;
    dout_stb            <=  0;
    read_count          <=  0;

    count_error         <=  0;
    incorrect_data      <=  0;
    detected_value      <=  0;
    count_detected      <=  0;
  end
  else begin
    din_stb             <=  0;
    dout_stb            <=  0;
    count_error         <=  0;
    incorrect_data      <=  0;

    if ((din_ready > 0) && (din_activate == 0)) begin
      write_count       <=  0;
      din               <=  0;
      if (din_ready[0]) begin
        din_activate[0] <=  1;
      end
      else begin
        din_activate[1] <=  1;
      end
    end
    else if (din_activate != 0) begin
      if (write_count < din_size) begin
        din_stb         <=  1;
        din             <=  write_count;
        write_count     <=  write_count + 1;
      end
      else begin
        din_activate    <=  0;
      end
    end

    if (dout_ready && !dout_activate) begin
      read_count        <=  0;
      dout_activate     <=  1;
      if (dout_size != 24'h0800) begin
        count_error     <=  1;
        count_detected  <=  dout_size;
      end
    end
    else if (dout_activate) begin
      if (read_count < dout_size) begin
        dout_stb        <=  1;
        read_count      <=  read_count + 1;
      end
      else begin
        dout_activate   <=  0;
      end

      //Error Detection
      if (read_count > 0) begin
        if (dout !=  read_count - 1) begin
          incorrect_data  <=  1;
          count_detected  <=  read_count[23:0];
          detected_value  <=  dout;
        end
      end
      else begin
        if (dout != 0) begin
          incorrect_data  <=  1;
          count_detected  <=  read_count[23:0];
          detected_value  <=  dout;
        end
      end
    end
  end
end

endmodule
