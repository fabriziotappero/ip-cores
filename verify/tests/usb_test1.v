`define usbbfm  tb.u_usb_agent.bfm_inst
task usb_test1;

reg [6:0] address;
reg [3:0] endpt;
reg [3:0] Status;
reg [31:0] ByteCount;

integer    i,j;
reg [7:0]  startbyte;
reg [15:0] mask;
integer    MaxPktSize;
reg [3:0]  PackType;


parameter  MYACK   = 4'b0000,
           MYNAK   = 4'b0001,
           MYSTALL = 4'b0010,
           MYTOUT  = 4'b0011,
           MYIVRES = 4'b0100,
           MYCRCER = 4'b0101;



     begin
  

    $display("%0d: USB Reset  -----", $time);
    tb.u_usb_agent.bfm_inst.usb_reset(48);

    address = 1;
    endpt    = 0;
    $display("%0d: Set Address = %x -----", $time,address);
    `usbbfm.SetAddress (address);
    $display("%0d: Sending Setup Command ", $time);
    `usbbfm.setup(7'h00, 4'h0, Status);
    `usbbfm.printstatus(Status, MYACK);
    $display("%0d: Sending Status Command ", $time);
    `usbbfm.status_IN(7'h00, endpt, Status);
    `usbbfm.printstatus(Status, MYACK);
    #5000;
  
    $display("%0d: Set configuration  -----", $time);
    `usbbfm.SetConfiguration(2'b01);
    `usbbfm.setup(address, 4'b0000, Status);
    `usbbfm.printstatus(Status, MYACK);
    `usbbfm.status_IN(address, 4'b0000, Status);
    `usbbfm.printstatus(Status, MYACK);
    #2000;

    $display("%0d: Configuration done !!!!!!", $time);
    tb.test_control.finish_test;
     
  end

endtask
