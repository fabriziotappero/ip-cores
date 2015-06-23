// ---------------------------------- testcase0.v ----------------------------
`include "timescale.v"
`include "usbHostSlave_h.v"
`include "usbHostControl_h.v"
`include "usbHostSlaveTB_defines.v"

module testCase0();

reg ack;
reg [7:0] data;
reg [15:0] dataWord;
reg [7:0] dataRead;
reg [7:0] dataWrite;
reg [7:0] USBAddress;
reg [7:0] USBEndPoint;
reg [7:0] transType;
integer dataSize;
integer i;
integer j;
reg bm_req_dir;
reg [1:0] bm_req_type;
reg [4:0] bm_req_recp;
reg [7:0] bRequest;
reg [15:0] wValue;
reg [15:0] wIndex;
reg [15:0] wLength;

initial
begin
  $write("\n\n");
  #1000;

  testHarness.u_wb_master_model.wb_read(1, `SIM_HOST_BASE_ADDR + `HOST_SLAVE_CONTROL_BASE+`HOST_SLAVE_VERSION_REG , dataRead);
  $display("Host Version number = 0x%0x\n", dataRead);

  $write("Testing host register read/write  ");
  testHarness.u_wb_master_model.wb_write(1, `SIM_HOST_BASE_ADDR + `HCREG_BASE+`TX_LINE_CONTROL_REG , 8'h18);
  testHarness.u_wb_master_model.wb_cmp(1, `SIM_HOST_BASE_ADDR + `HCREG_BASE+`TX_LINE_CONTROL_REG , 8'h18);
  $write("--- PASSED\n");

  $write("Testing register reset  ");
  testHarness.u_wb_master_model.wb_write(1, `SIM_HOST_BASE_ADDR + `HOST_SLAVE_CONTROL_BASE+`HOST_SLAVE_CONTROL_REG , 8'h2);
  #1000;
  testHarness.u_wb_master_model.wb_cmp(1, `SIM_HOST_BASE_ADDR + `HCREG_BASE+`TX_LINE_CONTROL_REG , 8'h00);
  $write("--- PASSED\n");
  #1000;

  $write("Connect full speed  ");
  testHarness.u_wb_master_model.wb_write(1, `SIM_HOST_BASE_ADDR + `HCREG_BASE+`TX_LINE_CONTROL_REG , 8'h18);
  #40000;
  //expecting full speed connect
  testHarness.u_wb_master_model.wb_cmp(1, `SIM_HOST_BASE_ADDR + `HCREG_BASE+`RX_CONNECT_STATE_REG , 6'h02);
  $write("--- PASSED\n");


  $write("Host forcing reset  ");
  testHarness.u_wb_master_model.wb_write(1, `SIM_HOST_BASE_ADDR + `HCREG_BASE+`TX_LINE_CONTROL_REG , 8'h1c);
  #40000;
  $write("--- PASSED\n");

  $write("Connect full speed  ");
  testHarness.u_wb_master_model.wb_write(1, `SIM_HOST_BASE_ADDR + `HCREG_BASE+`TX_LINE_CONTROL_REG , 8'h18);
  #20000;
  //expecting full speed connect
  testHarness.u_wb_master_model.wb_cmp(1, `SIM_HOST_BASE_ADDR + `HCREG_BASE+`RX_CONNECT_STATE_REG , 8'h02);
  $write("--- PASSED\n");
  #5000;

  $write("Cancel interrupts  \n");
  testHarness.u_wb_master_model.wb_write(1, `SIM_HOST_BASE_ADDR + `HCREG_BASE+`INTERRUPT_STATUS_REG , 8'h04);


  // --- get status
  $write("Trans test: Device address = 0x00, GET_STATUS. ");
  USBAddress = 8'h00;
  USBEndPoint = 8'h00;
  transType = `SETUP_TRANS;
  dataSize = 8;
  //enable endpoint, and make ready
  testHarness.u_wb_master_model.wb_write(1, `SIM_HOST_BASE_ADDR + `HCREG_BASE+`TX_ADDR_REG , USBAddress);
  testHarness.u_wb_master_model.wb_write(1, `SIM_HOST_BASE_ADDR + `HCREG_BASE+`TX_ENDP_REG , USBEndPoint);
  testHarness.u_wb_master_model.wb_write(1, `SIM_HOST_BASE_ADDR + `HCREG_BASE+`TX_TRANS_TYPE_REG , transType);
  bm_req_dir = 1'b1;   // 0-Host to device; 1-device to host 
  bm_req_type = 2'b00;  // 0-standard; 1-class; 2-vendor; 3-RESERVED
  bm_req_recp = 5'b00000;   // 0-device; 1-interface; 2-endpoint; 3-other 4..31-reserved
  bRequest =  `GET_STATUS; 
  wValue = 16'h0000;
  wIndex = 16'h0000;
  wLength = 16'h0008;
  testHarness.u_wb_master_model.wb_write(1, `SIM_HOST_BASE_ADDR + `HOST_TX_FIFO_BASE + `FIFO_DATA_REG , {bm_req_dir, bm_req_type, bm_req_recp}); 
  testHarness.u_wb_master_model.wb_write(1, `SIM_HOST_BASE_ADDR + `HOST_TX_FIFO_BASE + `FIFO_DATA_REG , bRequest); 
  testHarness.u_wb_master_model.wb_write(1, `SIM_HOST_BASE_ADDR + `HOST_TX_FIFO_BASE + `FIFO_DATA_REG , wValue[7:0]); 
  testHarness.u_wb_master_model.wb_write(1, `SIM_HOST_BASE_ADDR + `HOST_TX_FIFO_BASE + `FIFO_DATA_REG , wValue[15:8]); 
  testHarness.u_wb_master_model.wb_write(1, `SIM_HOST_BASE_ADDR + `HOST_TX_FIFO_BASE + `FIFO_DATA_REG , wIndex[7:0]); 
  testHarness.u_wb_master_model.wb_write(1, `SIM_HOST_BASE_ADDR + `HOST_TX_FIFO_BASE + `FIFO_DATA_REG , wIndex[15:8]); 
  testHarness.u_wb_master_model.wb_write(1, `SIM_HOST_BASE_ADDR + `HOST_TX_FIFO_BASE + `FIFO_DATA_REG , wLength[7:0]); 
  testHarness.u_wb_master_model.wb_write(1, `SIM_HOST_BASE_ADDR + `HOST_TX_FIFO_BASE + `FIFO_DATA_REG , wLength[15:8]); 
  testHarness.u_wb_master_model.wb_write(1, `SIM_HOST_BASE_ADDR + `HCREG_BASE+`TX_CONTROL_REG , 8'h01);
  #100000
  //expecting transaction done interrupt
  testHarness.u_wb_master_model.wb_cmp(1, `SIM_HOST_BASE_ADDR + `HCREG_BASE+`INTERRUPT_STATUS_REG , 8'h01);
  testHarness.u_wb_master_model.wb_write(1, `SIM_HOST_BASE_ADDR + `HCREG_BASE+`INTERRUPT_STATUS_REG , 8'h01); //cancel interrupt
  testHarness.u_wb_master_model.wb_cmp(1, `SIM_HOST_BASE_ADDR + `HCREG_BASE+`RX_STATUS_REG , 8'h40);
  $write("--- PASSED\n");
  $write("Trans test: Device address = 0x00, 3 byte IN transaction to Endpoint 0. ");
  USBAddress = 8'h00;
  USBEndPoint = 8'h00;
  transType = `IN_TRANS;
  //enable endpoint, and make ready
  testHarness.u_wb_master_model.wb_write(1, `SIM_HOST_BASE_ADDR + `HCREG_BASE+`TX_ADDR_REG , USBAddress);
  testHarness.u_wb_master_model.wb_write(1, `SIM_HOST_BASE_ADDR + `HCREG_BASE+`TX_ENDP_REG , USBEndPoint);
  testHarness.u_wb_master_model.wb_write(1, `SIM_HOST_BASE_ADDR + `HCREG_BASE+`TX_TRANS_TYPE_REG , transType);
  testHarness.u_wb_master_model.wb_write(1, `SIM_HOST_BASE_ADDR + `HCREG_BASE+`TX_CONTROL_REG , 8'h01);
  #20000
  //expecting transaction done interrupt
  testHarness.u_wb_master_model.wb_cmp(1, `SIM_HOST_BASE_ADDR + `HCREG_BASE+`INTERRUPT_STATUS_REG , 8'h01);
  testHarness.u_wb_master_model.wb_write(1, `SIM_HOST_BASE_ADDR + `HCREG_BASE+`INTERRUPT_STATUS_REG , 8'h01); //cancel interrupt
  testHarness.u_wb_master_model.wb_cmp(1, `SIM_HOST_BASE_ADDR + `HCREG_BASE+`RX_STATUS_REG , 8'h80);
  $write("Checking receive data  ");
  testHarness.u_wb_master_model.wb_cmp(1, `SIM_HOST_BASE_ADDR + `HOST_RX_FIFO_BASE + `FIFO_DATA_COUNT_LSB , 2);
  testHarness.u_wb_master_model.wb_cmp(1, `SIM_HOST_BASE_ADDR + `HOST_RX_FIFO_BASE + `FIFO_DATA_COUNT_MSB , 0);
  testHarness.u_wb_master_model.wb_cmp(1, `SIM_HOST_BASE_ADDR + `HOST_RX_FIFO_BASE + `FIFO_DATA_REG , 1);
  testHarness.u_wb_master_model.wb_cmp(1, `SIM_HOST_BASE_ADDR + `HOST_RX_FIFO_BASE + `FIFO_DATA_REG , 0);
  $write("--- PASSED\n");









  // --- set address
  $write("Trans test: Device address = 0x00, SET_ADDRESS. ");
  USBAddress = 8'h00;
  USBEndPoint = 8'h00;
  transType = `SETUP_TRANS;
  dataSize = 8;
  //enable endpoint, and make ready
  testHarness.u_wb_master_model.wb_write(1, `SIM_HOST_BASE_ADDR + `HCREG_BASE+`TX_ADDR_REG , USBAddress);
  testHarness.u_wb_master_model.wb_write(1, `SIM_HOST_BASE_ADDR + `HCREG_BASE+`TX_ENDP_REG , USBEndPoint);
  testHarness.u_wb_master_model.wb_write(1, `SIM_HOST_BASE_ADDR + `HCREG_BASE+`TX_TRANS_TYPE_REG , transType);
  bm_req_dir = 1'b1;   // 0-Host to device; 1-device to host 
  bm_req_type = 2'b00;  // 0-standard; 1-class; 2-vendor; 3-RESERVED
  bm_req_recp = 5'b00000;   // 0-device; 1-interface; 2-endpoint; 3-other 4..31-reserved
  bRequest =  `SET_ADDRESS; 
  wValue = 16'h0012; //set device address = 0x12
  wIndex = 16'h0000;
  wLength = 16'h0000;
  testHarness.u_wb_master_model.wb_write(1, `SIM_HOST_BASE_ADDR + `HOST_TX_FIFO_BASE + `FIFO_DATA_REG , {bm_req_dir, bm_req_type, bm_req_recp}); 
  testHarness.u_wb_master_model.wb_write(1, `SIM_HOST_BASE_ADDR + `HOST_TX_FIFO_BASE + `FIFO_DATA_REG , bRequest); 
  testHarness.u_wb_master_model.wb_write(1, `SIM_HOST_BASE_ADDR + `HOST_TX_FIFO_BASE + `FIFO_DATA_REG , wValue[7:0]); 
  testHarness.u_wb_master_model.wb_write(1, `SIM_HOST_BASE_ADDR + `HOST_TX_FIFO_BASE + `FIFO_DATA_REG , wValue[15:8]); 
  testHarness.u_wb_master_model.wb_write(1, `SIM_HOST_BASE_ADDR + `HOST_TX_FIFO_BASE + `FIFO_DATA_REG , wIndex[7:0]); 
  testHarness.u_wb_master_model.wb_write(1, `SIM_HOST_BASE_ADDR + `HOST_TX_FIFO_BASE + `FIFO_DATA_REG , wIndex[15:8]); 
  testHarness.u_wb_master_model.wb_write(1, `SIM_HOST_BASE_ADDR + `HOST_TX_FIFO_BASE + `FIFO_DATA_REG , wLength[7:0]); 
  testHarness.u_wb_master_model.wb_write(1, `SIM_HOST_BASE_ADDR + `HOST_TX_FIFO_BASE + `FIFO_DATA_REG , wLength[15:8]); 
  testHarness.u_wb_master_model.wb_write(1, `SIM_HOST_BASE_ADDR + `HCREG_BASE+`TX_CONTROL_REG , 8'h01);
  #100000
  //expecting transaction done interrupt
  testHarness.u_wb_master_model.wb_cmp(1, `SIM_HOST_BASE_ADDR + `HCREG_BASE+`INTERRUPT_STATUS_REG , 8'h01);
  testHarness.u_wb_master_model.wb_write(1, `SIM_HOST_BASE_ADDR + `HCREG_BASE+`INTERRUPT_STATUS_REG , 8'h01); //cancel interrupt
  testHarness.u_wb_master_model.wb_cmp(1, `SIM_HOST_BASE_ADDR + `HCREG_BASE+`RX_STATUS_REG , 8'h40);
  $write("--- PASSED\n");
  $write("Trans test: Device address = 0x00, Sending IN so that USB address change will take effect. ");
  USBAddress = 8'h00;
  USBEndPoint = 8'h00;
  transType = `IN_TRANS;
  //enable endpoint, and make ready
  testHarness.u_wb_master_model.wb_write(1, `SIM_HOST_BASE_ADDR + `HCREG_BASE+`TX_ADDR_REG , USBAddress);
  testHarness.u_wb_master_model.wb_write(1, `SIM_HOST_BASE_ADDR + `HCREG_BASE+`TX_ENDP_REG , USBEndPoint);
  testHarness.u_wb_master_model.wb_write(1, `SIM_HOST_BASE_ADDR + `HCREG_BASE+`TX_TRANS_TYPE_REG , transType);
  testHarness.u_wb_master_model.wb_write(1, `SIM_HOST_BASE_ADDR + `HCREG_BASE+`TX_CONTROL_REG , 8'h01);
  #20000
  //expecting transaction done interrupt
  testHarness.u_wb_master_model.wb_cmp(1, `SIM_HOST_BASE_ADDR + `HCREG_BASE+`INTERRUPT_STATUS_REG , 8'h01);
  testHarness.u_wb_master_model.wb_write(1, `SIM_HOST_BASE_ADDR + `HCREG_BASE+`INTERRUPT_STATUS_REG , 8'h01); //cancel interrupt
  testHarness.u_wb_master_model.wb_cmp(1, `SIM_HOST_BASE_ADDR + `HCREG_BASE+`RX_STATUS_REG , 8'h80);
  $write("Checking receive data is zero  ");
  testHarness.u_wb_master_model.wb_cmp(1, `SIM_HOST_BASE_ADDR + `HOST_RX_FIFO_BASE + `FIFO_DATA_COUNT_LSB , 0);
  testHarness.u_wb_master_model.wb_cmp(1, `SIM_HOST_BASE_ADDR + `HOST_RX_FIFO_BASE + `FIFO_DATA_COUNT_MSB , 0);
  $write("--- PASSED\n");



  // --- get device descriptor
  $write("Trans test: Device address = 0x12, get device descriptor. ");
  USBAddress = 8'h012;
  USBEndPoint = 8'h00;
  transType = `SETUP_TRANS;
  //enable endpoint, and make ready
  testHarness.u_wb_master_model.wb_write(1, `SIM_HOST_BASE_ADDR + `HCREG_BASE+`TX_ADDR_REG , USBAddress);
  testHarness.u_wb_master_model.wb_write(1, `SIM_HOST_BASE_ADDR + `HCREG_BASE+`TX_ENDP_REG , USBEndPoint);
  testHarness.u_wb_master_model.wb_write(1, `SIM_HOST_BASE_ADDR + `HCREG_BASE+`TX_TRANS_TYPE_REG , transType);
  bm_req_dir = 1'b1;   // 0-Host to device; 1-device to host 
  bm_req_type = 2'b00;  // 0-standard; 1-class; 2-vendor; 3-RESERVED
  bm_req_recp = 5'b00000;   // 0-device; 1-interface; 2-endpoint; 3-other 4..31-reserved
  bRequest =  `GET_DESCRIPTOR; 
  wValue = {`DEV_DESC, 8'h00};
  wIndex = 16'h0000;
  wLength = 16'h0040;
  testHarness.u_wb_master_model.wb_write(1, `SIM_HOST_BASE_ADDR + `HOST_TX_FIFO_BASE + `FIFO_DATA_REG , {bm_req_dir, bm_req_type, bm_req_recp}); 
  testHarness.u_wb_master_model.wb_write(1, `SIM_HOST_BASE_ADDR + `HOST_TX_FIFO_BASE + `FIFO_DATA_REG , bRequest); 
  testHarness.u_wb_master_model.wb_write(1, `SIM_HOST_BASE_ADDR + `HOST_TX_FIFO_BASE + `FIFO_DATA_REG , wValue[7:0]); 
  testHarness.u_wb_master_model.wb_write(1, `SIM_HOST_BASE_ADDR + `HOST_TX_FIFO_BASE + `FIFO_DATA_REG , wValue[15:8]); 
  testHarness.u_wb_master_model.wb_write(1, `SIM_HOST_BASE_ADDR + `HOST_TX_FIFO_BASE + `FIFO_DATA_REG , wIndex[7:0]); 
  testHarness.u_wb_master_model.wb_write(1, `SIM_HOST_BASE_ADDR + `HOST_TX_FIFO_BASE + `FIFO_DATA_REG , wIndex[15:8]); 
  testHarness.u_wb_master_model.wb_write(1, `SIM_HOST_BASE_ADDR + `HOST_TX_FIFO_BASE + `FIFO_DATA_REG , wLength[7:0]); 
  testHarness.u_wb_master_model.wb_write(1, `SIM_HOST_BASE_ADDR + `HOST_TX_FIFO_BASE + `FIFO_DATA_REG , wLength[15:8]); 
  testHarness.u_wb_master_model.wb_write(1, `SIM_HOST_BASE_ADDR + `HCREG_BASE+`TX_CONTROL_REG , 8'h01);
  #100000
  //expecting transaction done interrupt
  testHarness.u_wb_master_model.wb_cmp(1, `SIM_HOST_BASE_ADDR + `HCREG_BASE+`INTERRUPT_STATUS_REG , 8'h01);
  testHarness.u_wb_master_model.wb_write(1, `SIM_HOST_BASE_ADDR + `HCREG_BASE+`INTERRUPT_STATUS_REG , 8'h01); //cancel interrupt
  testHarness.u_wb_master_model.wb_cmp(1, `SIM_HOST_BASE_ADDR + `HCREG_BASE+`RX_STATUS_REG , 8'h40);
  $write("--- PASSED\n");
  $write("Trans test: Device address = 0x12, 18 byte IN transaction to Endpoint 0. ");
  USBAddress = 8'h12;
  USBEndPoint = 8'h00;
  transType = `IN_TRANS;
  //enable endpoint, and make ready
  testHarness.u_wb_master_model.wb_write(1, `SIM_HOST_BASE_ADDR + `HCREG_BASE+`TX_ADDR_REG , USBAddress);
  testHarness.u_wb_master_model.wb_write(1, `SIM_HOST_BASE_ADDR + `HCREG_BASE+`TX_ENDP_REG , USBEndPoint);
  testHarness.u_wb_master_model.wb_write(1, `SIM_HOST_BASE_ADDR + `HCREG_BASE+`TX_TRANS_TYPE_REG , transType);
  testHarness.u_wb_master_model.wb_write(1, `SIM_HOST_BASE_ADDR + `HCREG_BASE+`TX_CONTROL_REG , 8'h01);
  #100000
  //expecting transaction done interrupt
  testHarness.u_wb_master_model.wb_cmp(1, `SIM_HOST_BASE_ADDR + `HCREG_BASE+`INTERRUPT_STATUS_REG , 8'h01);
  testHarness.u_wb_master_model.wb_write(1, `SIM_HOST_BASE_ADDR + `HCREG_BASE+`INTERRUPT_STATUS_REG , 8'h01); //cancel interrupt
  testHarness.u_wb_master_model.wb_cmp(1, `SIM_HOST_BASE_ADDR + `HCREG_BASE+`RX_STATUS_REG , 8'h80);
  $write("Checking receive data  ");
  testHarness.u_wb_master_model.wb_cmp(1, `SIM_HOST_BASE_ADDR + `HOST_RX_FIFO_BASE + `FIFO_DATA_COUNT_LSB , 8'h12);
  testHarness.u_wb_master_model.wb_cmp(1, `SIM_HOST_BASE_ADDR + `HOST_RX_FIFO_BASE + `FIFO_DATA_COUNT_MSB , 0);
  for (i=0; i<18; i=i+1) begin
    testHarness.u_wb_master_model.wb_read(1, `SIM_HOST_BASE_ADDR + `HOST_RX_FIFO_BASE + `FIFO_DATA_REG , dataRead);
    $display("Data[0x%0x] = 0x%0x\n", i, dataRead);
  end
  $write("--- PASSED\n");






  // --- get config descriptor
  $write("Trans test: Device address = 0x12, get config descriptor. ");
  USBAddress = 8'h012;
  USBEndPoint = 8'h00;
  transType = `SETUP_TRANS;
  //enable endpoint, and make ready
  testHarness.u_wb_master_model.wb_write(1, `SIM_HOST_BASE_ADDR + `HCREG_BASE+`TX_ADDR_REG , USBAddress);
  testHarness.u_wb_master_model.wb_write(1, `SIM_HOST_BASE_ADDR + `HCREG_BASE+`TX_ENDP_REG , USBEndPoint);
  testHarness.u_wb_master_model.wb_write(1, `SIM_HOST_BASE_ADDR + `HCREG_BASE+`TX_TRANS_TYPE_REG , transType);
  bm_req_dir = 1'b1;   // 0-Host to device; 1-device to host 
  bm_req_type = 2'b00;  // 0-standard; 1-class; 2-vendor; 3-RESERVED
  bm_req_recp = 5'b00000;   // 0-device; 1-interface; 2-endpoint; 3-other 4..31-reserved
  bRequest =  `GET_DESCRIPTOR; 
  wValue = {`CFG_DESC, 8'h00};
  wIndex = 16'h0000;
  wLength = 16'h0009;
  testHarness.u_wb_master_model.wb_write(1, `SIM_HOST_BASE_ADDR + `HOST_TX_FIFO_BASE + `FIFO_DATA_REG , {bm_req_dir, bm_req_type, bm_req_recp}); 
  testHarness.u_wb_master_model.wb_write(1, `SIM_HOST_BASE_ADDR + `HOST_TX_FIFO_BASE + `FIFO_DATA_REG , bRequest); 
  testHarness.u_wb_master_model.wb_write(1, `SIM_HOST_BASE_ADDR + `HOST_TX_FIFO_BASE + `FIFO_DATA_REG , wValue[7:0]); 
  testHarness.u_wb_master_model.wb_write(1, `SIM_HOST_BASE_ADDR + `HOST_TX_FIFO_BASE + `FIFO_DATA_REG , wValue[15:8]); 
  testHarness.u_wb_master_model.wb_write(1, `SIM_HOST_BASE_ADDR + `HOST_TX_FIFO_BASE + `FIFO_DATA_REG , wIndex[7:0]); 
  testHarness.u_wb_master_model.wb_write(1, `SIM_HOST_BASE_ADDR + `HOST_TX_FIFO_BASE + `FIFO_DATA_REG , wIndex[15:8]); 
  testHarness.u_wb_master_model.wb_write(1, `SIM_HOST_BASE_ADDR + `HOST_TX_FIFO_BASE + `FIFO_DATA_REG , wLength[7:0]); 
  testHarness.u_wb_master_model.wb_write(1, `SIM_HOST_BASE_ADDR + `HOST_TX_FIFO_BASE + `FIFO_DATA_REG , wLength[15:8]); 
  testHarness.u_wb_master_model.wb_write(1, `SIM_HOST_BASE_ADDR + `HCREG_BASE+`TX_CONTROL_REG , 8'h01);
  #100000
  //expecting transaction done interrupt
  testHarness.u_wb_master_model.wb_cmp(1, `SIM_HOST_BASE_ADDR + `HCREG_BASE+`INTERRUPT_STATUS_REG , 8'h01);
  testHarness.u_wb_master_model.wb_write(1, `SIM_HOST_BASE_ADDR + `HCREG_BASE+`INTERRUPT_STATUS_REG , 8'h01); //cancel interrupt
  testHarness.u_wb_master_model.wb_cmp(1, `SIM_HOST_BASE_ADDR + `HCREG_BASE+`RX_STATUS_REG , 8'h40);
  $write("--- PASSED\n");
  $write("Trans test: Device address = 0x12, 18 byte IN transaction to Endpoint 0. ");
  USBAddress = 8'h12;
  USBEndPoint = 8'h00;
  transType = `IN_TRANS;
  //enable endpoint, and make ready
  testHarness.u_wb_master_model.wb_write(1, `SIM_HOST_BASE_ADDR + `HCREG_BASE+`TX_ADDR_REG , USBAddress);
  testHarness.u_wb_master_model.wb_write(1, `SIM_HOST_BASE_ADDR + `HCREG_BASE+`TX_ENDP_REG , USBEndPoint);
  testHarness.u_wb_master_model.wb_write(1, `SIM_HOST_BASE_ADDR + `HCREG_BASE+`TX_TRANS_TYPE_REG , transType);
  testHarness.u_wb_master_model.wb_write(1, `SIM_HOST_BASE_ADDR + `HCREG_BASE+`TX_CONTROL_REG , 8'h01);
  #100000
  //expecting transaction done interrupt
  testHarness.u_wb_master_model.wb_cmp(1, `SIM_HOST_BASE_ADDR + `HCREG_BASE+`INTERRUPT_STATUS_REG , 8'h01);
  testHarness.u_wb_master_model.wb_write(1, `SIM_HOST_BASE_ADDR + `HCREG_BASE+`INTERRUPT_STATUS_REG , 8'h01); //cancel interrupt
  testHarness.u_wb_master_model.wb_cmp(1, `SIM_HOST_BASE_ADDR + `HCREG_BASE+`RX_STATUS_REG , 8'h80);
  $write("Checking receive data  ");
  testHarness.u_wb_master_model.wb_cmp(1, `SIM_HOST_BASE_ADDR + `HOST_RX_FIFO_BASE + `FIFO_DATA_COUNT_LSB , 8'h09);
  testHarness.u_wb_master_model.wb_cmp(1, `SIM_HOST_BASE_ADDR + `HOST_RX_FIFO_BASE + `FIFO_DATA_COUNT_MSB , 0);
  for (i=0; i<9; i=i+1) begin
    testHarness.u_wb_master_model.wb_read(1, `SIM_HOST_BASE_ADDR + `HOST_RX_FIFO_BASE + `FIFO_DATA_REG , dataRead);
    $display("Data[0x%0x] = 0x%0x\n", i, dataRead);
  end
  $write("--- PASSED\n");



  // -- get mouse data from EP1
  $write("Trans test: Device address = 0x12, 3 byte IN transaction to Endpoint 1. ");
  USBAddress = 8'h12;
  USBEndPoint = 8'h01;
  transType = `IN_TRANS;
  //enable endpoint, and make ready
  testHarness.u_wb_master_model.wb_write(1, `SIM_HOST_BASE_ADDR + `HCREG_BASE+`TX_ADDR_REG , USBAddress);
  testHarness.u_wb_master_model.wb_write(1, `SIM_HOST_BASE_ADDR + `HCREG_BASE+`TX_ENDP_REG , USBEndPoint);
  testHarness.u_wb_master_model.wb_write(1, `SIM_HOST_BASE_ADDR + `HCREG_BASE+`TX_TRANS_TYPE_REG , transType);
  testHarness.u_wb_master_model.wb_write(1, `SIM_HOST_BASE_ADDR + `HCREG_BASE+`TX_CONTROL_REG , 8'h01);
  #20000
  //expecting transaction done interrupt
  testHarness.u_wb_master_model.wb_cmp(1, `SIM_HOST_BASE_ADDR + `HCREG_BASE+`INTERRUPT_STATUS_REG , 8'h01);
  testHarness.u_wb_master_model.wb_write(1, `SIM_HOST_BASE_ADDR + `HCREG_BASE+`INTERRUPT_STATUS_REG , 8'h01); //cancel interrupt
  testHarness.u_wb_master_model.wb_cmp(1, `SIM_HOST_BASE_ADDR + `HCREG_BASE+`RX_STATUS_REG , 8'h00);
  $write("Checking receive data  ");
  testHarness.u_wb_master_model.wb_cmp(1, `SIM_HOST_BASE_ADDR + `HOST_RX_FIFO_BASE + `FIFO_DATA_REG , 0);
  testHarness.u_wb_master_model.wb_cmp(1, `SIM_HOST_BASE_ADDR + `HOST_RX_FIFO_BASE + `FIFO_DATA_REG , 1);
  testHarness.u_wb_master_model.wb_cmp(1, `SIM_HOST_BASE_ADDR + `HOST_RX_FIFO_BASE + `FIFO_DATA_REG , 1);
  $write("--- PASSED\n");

  $write("Finished all tests\n");
  $stop;	

end

endmodule

