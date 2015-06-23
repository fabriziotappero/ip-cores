module hd_data_writer(
    input               clk,
    input               rst,
    input               enable,

    output  reg [31:0]  data,
    input               strobe
);

//Registers and Wires
reg             [31:0]  test_data;

//Submodules

//Asynchronous Logic


//Synchronous Logic
always @ (posedge clk) begin
    if (rst) begin
        test_data       <=  0;
        data            <=  0;
    end
    else begin
        if (enable) begin
            data            <=  test_data;
            if (strobe) begin
                test_data   <=  test_data + 1;
            end
        end
        else begin
            test_data   <=  0;
        end
    end
end

endmodule
