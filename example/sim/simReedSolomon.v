//===================================================================
// Module Name : simReedSolomon
// File Name   : simReedSolomon.v
// Function    : Rs bench Module
// 
// Revision History:
// Date          By           Version    Change Description
//===================================================================
// 2009/02/03  Gael Sapience     1.0       Original
//
//===================================================================
// (C) COPYRIGHT 2009 SYSTEM LSI CO., Ltd.
//


module simReedSolomon;


   //------------------------------------------------------------------------
   // global registers
   //------------------------------------------------------------------------
   reg          CLK;       // RSenc && RSdec system clock signal
   reg          RESET;     // RSenc && RSdec system reset


   //------------------------------------------------------------------------
   // RS decoder registers & wires
   //------------------------------------------------------------------------
   reg          rsdecEnable;        // RSdec system enable
   reg          rsdecSync;          // RSdec sync signal
   reg          rsdecErasureIn;     // RSdec erasure Input signal  
   reg  [7:0]   rsdecDataIn;        // Rsdec Data Input signal


   wire         rsdecOutStartPls;   // RSdec first decoded symbol trigger
   wire         rsdecOutDone;       // RSdec last decoder symbol trigger
   wire [7:0]   rsdecOutData;       // RSdec output data signal
   wire [7:0]   rsdecErrorNum;      // RSdec Error amount statistics
   wire [7:0]   rsdecErasureNum;    // RSdec Erasure amount statistics
   wire         rsdecFail;          // RSdec Pass/Fail output flag
   wire         rsdecOutEnable;     // RSdec output enable
   wire [7:0]   rsdecDelayedData;   // RSdec delayed data


   //------------------------------------------------------------------------
   // RS encoder registers & wires
   //------------------------------------------------------------------------
   reg          rsencEnable;     // RSenc data enable input
   reg          rsencStartPls;   // RSenc Start Pulse input
   reg  [7:0]   rsencDataIn;     // RSenc data in
   wire [7:0]   rsencDataOut;    // RSenc data out


   //------------------------------------------------------------------------
   //RS  Decoder Top module Instantiation
   //------------------------------------------------------------------------
   RsDecodeTop RsDecodeTop(
      // Inputs
      .CLK          (CLK),               // system clock
      .RESET        (RESET),             // system reset
      .enable       (rsdecEnable),       // RSdec enable in
      .startPls     (rsdecSync),         // RSdec sync signal
      .erasureIn    (rsdecErasureIn),    // RSdec erasure in
      .dataIn       (rsdecDataIn),       // RSdec data in
      // Outputs
      .outEnable    (rsdecOutEnable),    // RSdec enable out
      .outStartPls  (rsdecOutStartPls),  // RSdec start pulse out
      .outDone      (rsdecOutDone),      // RSdec done out
      .errorNum     (rsdecErrorNum),     // RSdec error number
      .erasureNum   (rsdecErasureNum),   // RSdec Erasure number
      .fail         (rsdecFail),         // RSdec Pass/Fail flag
      .delayedData  (rsdecDelayedData),  // RSdec delayed data
      .outData      (rsdecOutData)       // Rsdec data out
   );


   //------------------------------------------------------------------------
   // RS Encoder Top module Instantiation
   //------------------------------------------------------------------------
   RsEncodeTop RsEncodeTop(
      // Inputs
      .CLK      (CLK),           // system clock
      .RESET    (RESET),         // system reset
      .enable   (rsencEnable),   // RSenc enable signal
      .startPls (rsencStartPls), // RSenc sync signal
      // Outputs
      .dataIn   (rsencDataIn),   // RSenc data in
      .dataOut  (rsencDataOut)   // RSenc data out
   );


   //------------------------------------------------------------------------
   // clock CLK generation
   //------------------------------------------------------------------------
   parameter period = 10;
   always # (period) CLK =~CLK;


   //------------------------------------------------------------------------
   // log file
   //------------------------------------------------------------------------
   reg           simStart;
   integer  handleA;
   initial begin
      handleA = $fopen("result.out", "w");
   end


   //------------------------------------------------------------------------
   //- RSdec Input && Output Data files
   //------------------------------------------------------------------------
   reg  [23:0]   rsdecInputBank  [2902:0];
   reg  [87:0]   rsdecOutputBank [2549:0];

   initial $readmemh("./RsDecIn.hex", rsdecInputBank);
   initial $readmemh("./RsDecOut.hex", rsdecOutputBank);


   //------------------------------------------------------------------------
   //- RSenc Input && Output Data files
   //------------------------------------------------------------------------
   reg  [15:0]   rsencInputBank  [764:0];
   reg  [7:0]   rsencOutputBank  [764:0];
   initial $readmemh("./RsEncIn.hex", rsencInputBank);
   initial $readmemh("./RsEncOut.hex", rsencOutputBank);


   //--------------------------------------------------------------------------
   //- simStartFF1, simStartFF2, simStartFF3
   //--------------------------------------------------------------------------
   reg simStartFF1;
   reg simStartFF2;
   reg simStartFF3;
   always @(posedge CLK or negedge RESET) begin
      if (~RESET) begin
         simStartFF1 <= 1'b0;
         simStartFF2 <= 1'b0;
         simStartFF3 <= 1'b0;
      end
      else begin
         simStartFF1 <= simStart;
         simStartFF2 <= simStartFF1;
         simStartFF3 <= simStartFF2;
      end
   end


   //------------------------------------------------------------------------
   //+ IBankIndex
   //------------------------------------------------------------------------
   reg [31:0]  IBankIndex;
   always @(posedge CLK or negedge RESET) begin
      if (~RESET) begin
         IBankIndex <= 32'd0;
      end
      else if (simStart == 1'b1) begin
         IBankIndex <= IBankIndex + 32'd1;
      end
   end


//--------------------------------------------------------------------------
//- RS Decoder Test Bench
//--------------------------------------------------------------------------
   //--------------------------------------------------------------------------
   //- rsdecInput
   //--------------------------------------------------------------------------
   wire  [23:0] rsdecInput;
   assign rsdecInput = (IBankIndex < 32'd2903) ? rsdecInputBank [IBankIndex] : 24'd0;


   //------------------------------------------------------------------------
   //+ rsdecSync
   //------------------------------------------------------------------------
   always @(posedge CLK or negedge RESET) begin
      if (~RESET) begin
         rsdecSync <= 1'b0;
      end
      else if (simStart == 1'b1) begin
         rsdecSync <= rsdecInput[20];
      end
   end


   //------------------------------------------------------------------------
   //+ rsdecEnable
   //------------------------------------------------------------------------
   always @(posedge CLK or negedge RESET) begin
      if (~RESET) begin
         rsdecEnable <= 1'b0;
      end
      else if (simStart == 1'b1) begin
         rsdecEnable <= rsdecInput[16];
      end
   end


   //------------------------------------------------------------------------
   //+ rsdecErasureIn
   //------------------------------------------------------------------------
   always @(posedge CLK or negedge RESET) begin
      if (~RESET) begin
         rsdecErasureIn <= 1'b0;
      end
      else begin
         rsdecErasureIn <= rsdecInput[12];
      end
   end


   //------------------------------------------------------------------------
   //+ rsdecDataIn
   //------------------------------------------------------------------------
   always @(posedge CLK or negedge RESET) begin
      if (~RESET) begin
         rsdecDataIn <= 8'd0;
      end
      else begin
         rsdecDataIn <= rsdecInput[7:0];
      end
   end


   //------------------------------------------------------------------------
   //+ rsdecOBankIndex
   //------------------------------------------------------------------------
   reg [31:0]  rsdecOBankIndex;
   always @(posedge CLK or negedge RESET) begin
      if (~RESET) begin
         rsdecOBankIndex <= 32'd0;
      end
      else if (rsdecOutEnable == 1'b1) begin
         rsdecOBankIndex <= rsdecOBankIndex + 32'd1;
      end
   end


   //--------------------------------------------------------------------------
   //- rsdecOutput
   //--------------------------------------------------------------------------
   wire  [87:0] rsdecOutput;
   assign rsdecOutput = (rsdecOBankIndex < 32'd2550) ? rsdecOutputBank [rsdecOBankIndex] : 48'd0;


   //--------------------------------------------------------------------------
   //+ rsdecExpNumError
   //--------------------------------------------------------------------------
   reg [7:0]   rsdecExpNumError;
   always @(posedge CLK or negedge RESET) begin
      if (~RESET) begin
         rsdecExpNumError <= 8'd0;
      end
      else if (rsdecOutEnable == 1'b1) begin
         rsdecExpNumError <= rsdecOutput[47:36];
      end
      else begin
         rsdecExpNumError <= 8'd0;
      end
   end


   //--------------------------------------------------------------------------
   //+ rsdecTheoricalNumError
   //--------------------------------------------------------------------------
   reg [7:0]   rsdecTheoricalNumError;
   always @(posedge CLK or negedge RESET) begin
      if (~RESET) begin
         rsdecTheoricalNumError <= 8'd0;
      end
      else if (rsdecOutEnable == 1'b1) begin
         rsdecTheoricalNumError <= rsdecOutput[75:64];
      end
      else begin
         rsdecTheoricalNumError <= 8'd0;
      end
   end


   //--------------------------------------------------------------------------
   //+ rsdecExpNumErasure
   //--------------------------------------------------------------------------
   reg [7:0]   rsdecExpNumErasure;
   always @(posedge CLK or negedge RESET) begin
      if (~RESET) begin
         rsdecExpNumErasure <= 8'd0;
      end
      else if (rsdecOutEnable == 1'b1) begin
         rsdecExpNumErasure <= rsdecOutput[31:24];
      end
      else begin
         rsdecExpNumErasure <= 8'd0;
      end
   end


   //--------------------------------------------------------------------------
   //+ rsdecTheoricalNumErasure
   //--------------------------------------------------------------------------
   reg [7:0]   rsdecTheoricalNumErasure;
   always @(posedge CLK or negedge RESET) begin
      if (~RESET) begin
         rsdecTheoricalNumErasure <= 8'd0;
      end
      else if (rsdecOutEnable == 1'b1) begin
         rsdecTheoricalNumErasure <= rsdecOutput[59:52];
      end
      else begin
         rsdecTheoricalNumErasure <= 8'd0;
      end
   end


   //--------------------------------------------------------------------------
   //+ rsdecTheoricalSyndromeLength
   //--------------------------------------------------------------------------
   reg [12:0]   rsdecTheoricalSyndromeLength;
   always @(posedge CLK or negedge RESET) begin
      if (~RESET) begin
         rsdecTheoricalSyndromeLength <= 13'd0;
      end
      else if (rsdecOutEnable == 1'b1) begin
         rsdecTheoricalSyndromeLength <= {1'b0, rsdecOutput[87:76]};
      end
      else begin
         rsdecTheoricalSyndromeLength <= 13'd0;
      end
   end


   //--------------------------------------------------------------------------
   //+ rsdecExpFailFlag
   //--------------------------------------------------------------------------
   reg       rsdecExpFailFlag;
   always @(posedge CLK or negedge RESET) begin
      if (~RESET) begin
         rsdecExpFailFlag <= 1'b0;
      end
      else if (rsdecOutEnable == 1'b1) begin
         rsdecExpFailFlag <= rsdecOutput[48];
      end
   end
   //--------------------------------------------------------------------------
   //+ rsdecExpData
   //--------------------------------------------------------------------------
   reg [7:0]   rsdecExpData;
   always @(posedge CLK or negedge RESET) begin
      if (~RESET) begin
         rsdecExpData <= 8'd0;
      end
      else if (rsdecOutEnable == 1'b1) begin
         rsdecExpData <= rsdecOutput[7:0];
      end
      else begin
         rsdecExpData <= 8'd0;
      end
   end


   //--------------------------------------------------------------------------
   //+ rsdecExpDelayedData
   //--------------------------------------------------------------------------
   reg [7:0]   rsdecExpDelayedData;
   always @(posedge CLK or negedge RESET) begin
      if (~RESET) begin
         rsdecExpDelayedData <= 8'd0;
      end
      else if (rsdecOutEnable == 1'b1) begin
         rsdecExpDelayedData <= rsdecOutput[19:12];
      end
      else begin
         rsdecExpDelayedData <= 8'd0;
      end
   end


   //--------------------------------------------------------------------------
   //+ rsdecOutDataFF, rsdecOutEnableFF
   //--------------------------------------------------------------------------
   reg [7:0] rsdecOutDataFF;
   reg       rsdecOutEnableFF;
   reg [7:0]   rsdecErrorNumFF;
   reg [7:0]   rsdecErasureNumFF;
   reg         rsdecFailFF;
   reg [7:0] rsdecDelayedDataFF;
   always @(posedge CLK or negedge RESET) begin
      if (~RESET) begin
         rsdecOutDataFF <= 8'd0;
         rsdecOutEnableFF <= 1'b0;
         rsdecDelayedDataFF <= 8'd0;
         rsdecErrorNumFF <= 8'd0;
         rsdecErasureNumFF <= 8'd0;
         rsdecFailFF <= 1'b0;
      end
      else begin
         rsdecOutDataFF <= rsdecOutData;
         rsdecOutEnableFF <= rsdecOutEnable;
         rsdecDelayedDataFF <= rsdecDelayedData;
         rsdecErrorNumFF <= rsdecErrorNum;
         rsdecErasureNumFF <= rsdecErasureNum;
         rsdecFailFF <= rsdecFail;
      end
   end


   //--------------------------------------------------------------------------
   //+ rsDecDelayedDataFlag, rsDecNGDelayedDataFlag
   //--------------------------------------------------------------------------
   reg   rsDecDelayedDataFlag;
   reg   rsDecNGDelayedDataFlag;
   always @(posedge CLK or negedge RESET) begin
      if (~RESET) begin
         rsDecDelayedDataFlag <= 1'b0;
         rsDecNGDelayedDataFlag   <= 1'b0;
      end
      else if (rsdecOutEnableFF == 1'b1) begin
         if (rsdecDelayedDataFF == rsdecExpDelayedData) begin
            rsDecDelayedDataFlag <= 1'b0;
         end
         else begin
            rsDecDelayedDataFlag <= 1'b1;
            rsDecNGDelayedDataFlag   <= 1'b1;
            $fdisplay(handleA,"Reed Solomon Decoder: Delayed Data Pin NG!!!!");
         end
      end
      else begin
         rsDecDelayedDataFlag <= 1'b0;
      end
   end






   //--------------------------------------------------------------------------
   //+ rsDecDataFlag, rsDecNGDataFlag
   //--------------------------------------------------------------------------
   reg   rsDecDataFlag;
   reg   rsDecNGDataFlag;
   always @(posedge CLK or negedge RESET) begin
      if (~RESET) begin
         rsDecDataFlag <= 1'b0;
         rsDecNGDataFlag   <= 1'b0;
      end
      else if (rsdecOutEnableFF == 1'b1) begin
         if (rsdecOutDataFF == rsdecExpData) begin
            rsDecDataFlag <= 1'b0;
         end
         else begin
            rsDecDataFlag <= 1'b1;
            rsDecNGDataFlag   <= 1'b1;
            $fdisplay(handleA,"Reed Solomon Decoder Data Out: NG!!!!");
         end
      end
      else begin
         rsDecDataFlag <= 1'b0;
      end
   end



   //--------------------------------------------------------------------------
   //+ rsDecErasureFlag, rsDecNGErasureFlag
   //--------------------------------------------------------------------------
   reg   rsDecErasureFlag;
   reg   rsDecNGErasureFlag;
   always @(posedge CLK or negedge RESET) begin
      if (~RESET) begin
         rsDecErasureFlag <= 1'b0;
         rsDecNGErasureFlag   <= 1'b0;
      end
      else if (rsdecOutEnableFF == 1'b1) begin
         if (rsdecErasureNumFF == rsdecExpNumErasure) begin
            rsDecErasureFlag <= 1'b0;
         end
         else begin
            rsDecErasureFlag <= 1'b1;
            rsDecNGErasureFlag   <= 1'b1;
            $fdisplay(handleA,"Reed Solomon Decoder Erasure Pin: NG!!!!");
         end
      end
      else begin
         rsDecErasureFlag <= 1'b0;
      end
   end



   //--------------------------------------------------------------------------
   //+ rsDecErrorFlag, rsDecNGErrorFlag
   //--------------------------------------------------------------------------
   reg   rsDecErrorFlag;
   reg   rsDecNGErrorFlag;
   always @(posedge CLK or negedge RESET) begin
      if (~RESET) begin
         rsDecErrorFlag <= 1'b0;
         rsDecNGErrorFlag   <= 1'b0;
      end
      else if (rsdecOutEnableFF == 1'b1) begin
         if (rsdecErrorNumFF == rsdecExpNumError) begin
            rsDecErrorFlag <= 1'b0;
         end
         else begin
            rsDecErrorFlag <= 1'b1;
            rsDecNGErrorFlag   <= 1'b1;
            $fdisplay(handleA,"Reed Solomon Decoder Error Pin : NG!!!!");
         end
      end
      else begin
         rsDecErrorFlag <= 1'b0;
      end
   end



   //--------------------------------------------------------------------------
   //+ rsDecFailPinFlag, rsDecNGFailPinFlag
   //--------------------------------------------------------------------------
   reg   rsDecFailPinFlag;
   reg   rsDecNGFailPinFlag;
   always @(posedge CLK or negedge RESET) begin
      if (~RESET) begin
         rsDecFailPinFlag <= 1'b0;
         rsDecNGFailPinFlag   <= 1'b0;
      end
      else if (rsdecOutEnableFF == 1'b1) begin
         if (rsdecFailFF == rsdecExpFailFlag) begin
            rsDecFailPinFlag <= 1'b0;
         end
         else begin
            rsDecFailPinFlag <= 1'b1;
            rsDecNGFailPinFlag   <= 1'b1;
            $fdisplay(handleA,"Reed Solomon Decoder Pass Fail Pin : NG!!!!");
         end
      end
      else begin
         rsDecFailPinFlag <= 1'b0;
      end
   end



   //--------------------------------------------------------------------------
   //+ rsDecCorrectionAmount
   //--------------------------------------------------------------------------
   wire [12:0]  rsDecCorrectionAmount;
   assign rsDecCorrectionAmount = rsdecTheoricalNumErasure + rsdecTheoricalNumError*2;


   //--------------------------------------------------------------------------
   //+ passFailPinThFlag
   //--------------------------------------------------------------------------
   reg   passFailPinThFlag;
   always @(posedge CLK or negedge RESET) begin
      if (~RESET) begin
         passFailPinThFlag <= 1'b0;
      end
      else if (rsdecOutEnableFF == 1'b1) begin
         if (rsDecCorrectionAmount <=  rsdecTheoricalSyndromeLength) begin
            if (rsdecFailFF==1'b1) begin
               passFailPinThFlag <= 1'b1;
               $fdisplay(handleA,"Reed Solomon Decoder Pass Fail Pin : Th NG!!!!");
            end
         end
      end
   end
   //--------------------------------------------------------------------------
   //+ ErasurePinThFlag
   //--------------------------------------------------------------------------
   reg   ErasurePinThFlag;
   always @(posedge CLK or negedge RESET) begin
      if (~RESET) begin
         ErasurePinThFlag <= 1'b0;
      end
      else if (rsdecOutEnableFF == 1'b1) begin
         if (rsDecCorrectionAmount <=  rsdecTheoricalSyndromeLength) begin
            if (rsdecErasureNumFF != rsdecTheoricalNumErasure) begin
               ErasurePinThFlag <= 1'b1;
               $fdisplay(handleA,"Reed Solomon Decoder Erasure Pin : Th NG!!!!");
            end
         end
      end
   end
   //--------------------------------------------------------------------------
   //+ ErrorPinThFlag
   //--------------------------------------------------------------------------
   reg   ErrorPinThFlag;
   always @(posedge CLK or negedge RESET) begin
      if (~RESET) begin
         ErrorPinThFlag <= 1'b0;
      end
      else if (rsdecOutEnableFF == 1'b1) begin
         if (rsDecCorrectionAmount <=  rsdecTheoricalSyndromeLength) begin
            if (rsdecErrorNumFF != rsdecTheoricalNumError) begin
               ErrorPinThFlag <= 1'b1;
               $fdisplay(handleA,"Reed Solomon Decoder Error Pin : Th NG!!!!");
            end
         end
      end
   end
//--------------------------------------------------------------------------
//- RS Encoder Test Bench
//--------------------------------------------------------------------------
   //--------------------------------------------------------------------------
   //- rsencInput
   //--------------------------------------------------------------------------
   wire  [15:0] rsencInput;
   assign rsencInput = (IBankIndex < 32'd765) ? rsencInputBank [IBankIndex] : 16'd0;


   //------------------------------------------------------------------------
   //+ rsencStartPls
   //------------------------------------------------------------------------
   always @(posedge CLK or negedge RESET) begin
      if (~RESET) begin
         rsencStartPls <= 1'b0;
      end
      else if (simStart == 1'b1) begin
         rsencStartPls <= rsencInput[12];
      end
   end


   //------------------------------------------------------------------------
   //+ rsencEnable
   //------------------------------------------------------------------------
   always @(posedge CLK or negedge RESET) begin
      if (~RESET) begin
         rsencEnable <= 1'b0;
      end
      else begin
         rsencEnable <= rsencInput[8];
      end
   end


   //------------------------------------------------------------------------
   //+ rsencDataIn
   //------------------------------------------------------------------------
   always @(posedge CLK or negedge RESET) begin
      if (~RESET) begin
         rsencDataIn <= 8'd0;
      end
      else begin
         rsencDataIn <= rsencInput[7:0];
      end
   end


   //------------------------------------------------------------------------
   //+ rsencOBankIndex
   //------------------------------------------------------------------------
   reg [31:0]  rsencOBankIndex;
   always @(posedge CLK or negedge RESET) begin
      if (~RESET) begin
         rsencOBankIndex <= 32'd0;
      end
      else if (simStartFF2 == 1'b1) begin
         rsencOBankIndex <= rsencOBankIndex + 32'd1;
      end
   end


   //--------------------------------------------------------------------------
   //- rsencOutput
   //--------------------------------------------------------------------------
   wire  [7:0] rsencOutput;
   assign rsencOutput = (rsencOBankIndex < 32'd765) ? rsencOutputBank [rsencOBankIndex] : 8'd0;


   //--------------------------------------------------------------------------
   //+ rsencExpData
   //--------------------------------------------------------------------------
   reg [7:0]   rsencExpData;
   always @(posedge CLK or negedge RESET) begin
      if (~RESET) begin
         rsencExpData <= 8'd0;
      end
      else if (simStartFF2 == 1'b1) begin
         rsencExpData <= rsencOutput[7:0];
      end
      else begin
         rsencExpData <= 8'd0;
      end
   end


   //--------------------------------------------------------------------------
   //+ rsEncPassFailFlag, rsEncFailFlag
   //--------------------------------------------------------------------------
   reg   rsEncPassFailFlag;
   reg   rsEncFailFlag;
   always @(posedge CLK or negedge RESET) begin
      if (~RESET) begin
         rsEncPassFailFlag <= 1'b0;
         rsEncFailFlag   <= 1'b0;
      end
      else if ((simStartFF3 == 1'b1) && (rsencOBankIndex < 32'd766)) begin
         if (rsencDataOut == rsencExpData) begin
            rsEncPassFailFlag <= 1'b0;
         end
         else begin
            rsEncPassFailFlag <= 1'b1;
            rsEncFailFlag   <= 1'b1;
            $fdisplay(handleA,"Reed Solomon Encoder: NG!!!!");
         end
      end
      else begin
         rsEncPassFailFlag <= 1'b0;
      end
   end
   //------------------------------------------------------------------------
   // + simOver
   //------------------------------------------------------------------------
   reg simOver;
   always @(posedge CLK or negedge RESET) begin
      if (~RESET) begin
         simOver <= 1'b0;
      end
      else if ((rsencOBankIndex > 32'd766) && (rsdecOBankIndex > 32'd2549)) begin
         simOver <= 1'b1;
         $fclose(handleA);
         $finish;
      end
   end
   //------------------------------------------------------------------------
   //-  TIMING
   //------------------------------------------------------------------------
   initial begin
      simStart = 1'b0;
      CLK = 0;
      RESET = 1;
      #(period*2)	RESET = 0;
      #(period*2)	RESET = 1;
      #(period*20) simStart = 1'b1;
      #(period*99999999);
      #(period*99999999);
      #(period*99999999);
      #(period*99999999);
      #(period*99999999);
      #(period*99999999);
      #(period*99999999);
      #(period*99999999);
      #(period*99999999);
      #(period*99999999);
      #(period*99999999);
      #(period*99999999);
      #(period*99999999);
      #(period*99999999);
      #(period*99999999);
      #(period*99999999);
      #(period*99999999);
      #(period*99999999);
      #(period*99999999);
      #(period*99999999);
      #(period*99999999);
      #(period*99999999);
      #(period*99999999);
      #(period*99999999);
      #(period*99999999);
      #(period*99999999);
      #(period*99999999);
      #(period*99999999);
      #(period*99999999);
      #(period*99999999);
      #(period*99999999);
      #(period*99999999);
      #(period*99999999);
      #(period*99999999);
      #(period*99999999);
      #(period*99999999);
      #(period*99999999);
      #(period*99999999);
      #(period*99999999);
      #(period*99999999);
   end
endmodule
