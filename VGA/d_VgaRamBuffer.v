//==================================================================
// File:    d_VgaRamBuffer.v
// Version: 0.01
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// Copyright Stephen Pickett
//   April 28, 2005
//------------------------------------------------------------------
// Revisions:
// Ver 0.01     Apr 28, 2005    Initial Release
//
//==================================================================
module VGADataBuffer(
    CLK_50MHZ, MASTER_RST,
    VGA_RAM_DATA, VGA_RAM_ADDR, VGA_RAM_OE, VGA_RAM_WE, VGA_RAM_CS,
    VGA_RAM_ACCESS_OK,
    ADC_RAM_DATA, ADC_RAM_ADDR, ADC_RAM_CLK,
    TIME_BASE
    );
//==================================================================//
// VARIABLE DEFINITIONS                                             //
//==================================================================//
//----------------------//
// INPUTS / OUTPUTS     //
//----------------------//
input CLK_50MHZ;                // System wide clock
input MASTER_RST;               // System wide reset

output[15:0] VGA_RAM_DATA;
output[17:0] VGA_RAM_ADDR;
output       VGA_RAM_OE, VGA_RAM_WE, VGA_RAM_CS;
input        VGA_RAM_ACCESS_OK;

input[8:0]   ADC_RAM_DATA;
output[10:0] ADC_RAM_ADDR;
output       ADC_RAM_CLK;

input[5:0] TIME_BASE;

//----------------------//
// WIRES / NODES        //
//----------------------//
wire CLK_50MHZ;                // System wide clock
wire MASTER_RST;               // System wide reset
wire[15:0] VGA_RAM_DATA;
reg[17:0] VGA_RAM_ADDR;
reg VGA_RAM_OE, VGA_RAM_WE, VGA_RAM_CS;
wire  VGA_RAM_ACCESS_OK;
wire[8:0] ADC_RAM_DATA;
reg[10:0] ADC_RAM_ADDR;
wire ADC_RAM_CLK;
wire[5:0] TIME_BASE;


//----------------------//
// REGISTERS            //
//----------------------//
reg[4:0]  vcnt;
reg[9:0]  hcnt;
reg[15:0] data_to_ram;
reg[8:0]  adc_data_scale;
reg[10:0] TRIG_ADDR_buffered;


//==================================================================//
// FUNCTIONAL DEFINITIONS                                           //
//==================================================================//
always @ (posedge CLK_50MHZ or posedge MASTER_RST) begin
    if(MASTER_RST == 1'b1) begin
        vcnt <= 5'd0;
    end else if(VGA_RAM_ACCESS_OK && hcnt != 10'd640) begin
        if(vcnt == 5'd24)
            vcnt <= 5'b0;
        else
            vcnt <= vcnt + 1'b1;
    end else begin
        vcnt <= 5'd0;
    end
end

always @ (posedge CLK_50MHZ or posedge MASTER_RST) begin
    if(MASTER_RST == 1'b1) begin
        hcnt <= 10'd0;
    end else if(VGA_RAM_ACCESS_OK) begin
        if(hcnt == 10'd640)
            hcnt <= hcnt;
        else if(vcnt == 5'd24)
            hcnt <= hcnt + 1'b1;
        else
            hcnt <= hcnt;
    end else begin
        hcnt <= 10'b0;
    end
end


always @ (posedge CLK_50MHZ or posedge MASTER_RST) begin
    if(MASTER_RST == 1'b1) begin
        ADC_RAM_ADDR <= 11'b0;
    end else if(VGA_RAM_ACCESS_OK) begin
        if((hcnt == 10'd640) || !(vcnt == 5'd24))
            ADC_RAM_ADDR <= ADC_RAM_ADDR;
        else
            ADC_RAM_ADDR <= ADC_RAM_ADDR + 1'b1;
    end else begin
        ADC_RAM_ADDR <= 11'd1727;
    end
end

reg[7:0] TESTING_CNT;
always @ (posedge CLK_50MHZ or posedge MASTER_RST) begin
    if(MASTER_RST == 1'b1) begin
        TESTING_CNT <= 8'd0;
    end else if(VGA_RAM_ACCESS_OK) begin
        if(vcnt == 5'd24)
            TESTING_CNT <= TESTING_CNT+1;
        else
            TESTING_CNT <= TESTING_CNT;
    end else begin
        TESTING_CNT <= 8'b0;
    end
end


always @ (ADC_RAM_DATA) begin
//      adc_data_scale = TESTING_CNT + (TESTING_CNT>>1) + (TESTING_CNT>>4) + (TESTING_CNT>>6);
//      adc_data_scale = ADC_RAM_DATA + (ADC_RAM_DATA>>1) + (ADC_RAM_DATA>>4) + (ADC_RAM_DATA>>6);
      adc_data_scale = ADC_RAM_DATA;
end




always @ (posedge CLK_50MHZ or posedge MASTER_RST) begin
    if(MASTER_RST == 1'b1) begin
        VGA_RAM_ADDR <= 18'b0;
    end else if(VGA_RAM_ACCESS_OK) begin
        if(hcnt == 10'd640)
            VGA_RAM_ADDR <= VGA_RAM_ADDR;
        else
            VGA_RAM_ADDR <= VGA_RAM_ADDR + 1'b1;
    end else begin
        VGA_RAM_ADDR <= 18'b0;
    end
end
/*
always @ (vcnt or VGA_RAM_ACCESS_OK or adc_data_scale) begin
    if(VGA_RAM_ACCESS_OK) begin
        if(vcnt == adc_data_scale[8:4]) begin
            data_to_ram = (adc_data_scale[3:0] == 4'd0)  & 16'h0001 |
                          (adc_data_scale[3:0] == 4'd1)  & 16'h0002 |
                          (adc_data_scale[3:0] == 4'd2)  & 16'h0004 |
                          (adc_data_scale[3:0] == 4'd3)  & 16'h0008 |
                          (adc_data_scale[3:0] == 4'd4)  & 16'h0010 |
                          (adc_data_scale[3:0] == 4'd5)  & 16'h0020 |
                          (adc_data_scale[3:0] == 4'd6)  & 16'h0040 |
                          (adc_data_scale[3:0] == 4'd7)  & 16'h0080 |
                          (adc_data_scale[3:0] == 4'd8)  & 16'h0100 |
                          (adc_data_scale[3:0] == 4'd9)  & 16'h0200 |
                          (adc_data_scale[3:0] == 4'd10) & 16'h0400 |
                          (adc_data_scale[3:0] == 4'd11) & 16'h0800 |
                          (adc_data_scale[3:0] == 4'd12) & 16'h1000 |
                          (adc_data_scale[3:0] == 4'd13) & 16'h2000 |
                          (adc_data_scale[3:0] == 4'd14) & 16'h4000 |
                          (adc_data_scale[3:0] == 4'd15) & 16'h8000;
        end else begin
            data_to_ram = 16'b0;
        end
    end else begin
        data_to_ram = 16'bZ;
    end
end
*/

always @ (vcnt or VGA_RAM_ACCESS_OK or adc_data_scale) begin
    if(VGA_RAM_ACCESS_OK) begin
        if(vcnt == adc_data_scale[8:4]) begin
            if(adc_data_scale[3:0] == 4'd0)
                data_to_ram = 16'h0001;
            else if(adc_data_scale[3:0] == 4'd1)
                data_to_ram = 16'h0002;
            else if(adc_data_scale[3:0] == 4'd2)
                data_to_ram = 16'h0004;
            else if(adc_data_scale[3:0] == 4'd3)
                data_to_ram = 16'h0008;
            else if(adc_data_scale[3:0] == 4'd4)
                data_to_ram = 16'h0010;
            else if(adc_data_scale[3:0] == 4'd5)
                data_to_ram = 16'h0020;
            else if(adc_data_scale[3:0] == 4'd6)
                data_to_ram = 16'h0040;
            else if(adc_data_scale[3:0] == 4'd7)
                data_to_ram = 16'h0080;
            else if(adc_data_scale[3:0] == 4'd8)
                data_to_ram = 16'h0100;
            else if(adc_data_scale[3:0] == 4'd9)
                data_to_ram = 16'h0200;
            else if(adc_data_scale[3:0] == 4'd10)
                data_to_ram = 16'h0400;
            else if(adc_data_scale[3:0] == 4'd11)
                data_to_ram = 16'h0800;
            else if(adc_data_scale[3:0] == 4'd12)
                data_to_ram = 16'h1000;
            else if(adc_data_scale[3:0] == 4'd13)
                data_to_ram = 16'h2000;
            else if(adc_data_scale[3:0] == 4'd14)
                data_to_ram = 16'h4000;
            else if(adc_data_scale[3:0] == 4'd15)
                data_to_ram = 16'h8000;
            else
                data_to_ram = 16'hFFFF;
        end else //end bigIF
            data_to_ram = 16'b0;
    end else begin
        data_to_ram = 16'bZ;
    end
end

/*
always @ (vcnt or VGA_RAM_ACCESS_OK or ADC_RAM_DATA) begin
    if(VGA_RAM_ACCESS_OK) begin
        if((vcnt[3:0] == ADC_RAM_DATA[7:4]) && vcnt[4] != 1'b1) begin
            if(ADC_RAM_DATA[3:0] == 4'd0)
                data_to_ram = 16'h0001;
            else if(ADC_RAM_DATA[3:0] == 4'd1)
                data_to_ram = 16'h0002;
            else if(ADC_RAM_DATA[3:0] == 4'd2)
                data_to_ram = 16'h0004;
            else if(ADC_RAM_DATA[3:0] == 4'd3)
                data_to_ram = 16'h0008;
            else if(ADC_RAM_DATA[3:0] == 4'd4)
                data_to_ram = 16'h0010;
            else if(ADC_RAM_DATA[3:0] == 4'd5)
                data_to_ram = 16'h0020;
            else if(ADC_RAM_DATA[3:0] == 4'd6)
                data_to_ram = 16'h0040;
            else if(ADC_RAM_DATA[3:0] == 4'd7)
                data_to_ram = 16'h0080;
            else if(ADC_RAM_DATA[3:0] == 4'd8)
                data_to_ram = 16'h0100;
            else if(ADC_RAM_DATA[3:0] == 4'd9)
                data_to_ram = 16'h0200;
            else if(ADC_RAM_DATA[3:0] == 4'd10)
                data_to_ram = 16'h0400;
            else if(ADC_RAM_DATA[3:0] == 4'd11)
                data_to_ram = 16'h0800;
            else if(ADC_RAM_DATA[3:0] == 4'd12)
                data_to_ram = 16'h1000;
            else if(ADC_RAM_DATA[3:0] == 4'd13)
                data_to_ram = 16'h2000;
            else if(ADC_RAM_DATA[3:0] == 4'd14)
                data_to_ram = 16'h4000;
            else if(ADC_RAM_DATA[3:0] == 4'd15)
                data_to_ram = 16'h8000;
            else
                data_to_ram = 16'hFFFF;
        end else //end bigIF
            data_to_ram = 16'b0;
    end else begin
        data_to_ram = 16'bZ;
    end
end
*/
/*
always @ (vcnt) begin
    if(vcnt == 5'd00 && hcnt <= 10'd319)
        data_to_ram = 16'h000F;
    else
        data_to_ram = 16'b0;
end
*/

assign ADC_RAM_CLK = CLK_50MHZ;

assign VGA_RAM_DATA = data_to_ram;

always begin
    VGA_RAM_OE = 1'b1;
    VGA_RAM_WE = 1'b0;
    VGA_RAM_CS = 1'b0;
end












endmodule
