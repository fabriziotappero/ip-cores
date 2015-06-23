/**
 * 10 GE MAC Core loopback test scenario file.
 * @file: testcase.sv (loopback)
 * @author: Pratik Mahajan
 * @par Contact: pratik@e-pigeonpost.com
 * @par Company: UCSC (SV 1896 Systemverilog for advanced verification course)
 * 
 * @version: $LastChangedRevision$
 * @par Last Changed Date:
 * $LastChangedDate$
 * @par Last Changed By
 * $LastChangedBy$
 */

`include "../../verification/include.sv"
`include "../../verification/packet.sv"
`include "../../verification/driver.sv"
`include "../../verification/monitor.sv"
`include "../../verification/scoreboard.sv"
`include "../../verification/env.sv"

/**
 * Testcase representing loopback scenario.
 * The testcase sets proper environment variable for design to work in loopback mode
 * To connect DUT in loopback mode:
 * 	XGMII interface Tx is connected to XGMII Rx port.
 * 	Data transmitted through simple Tx port collected through simple Rx port
 * 	and the data is compared for equality
 */

program testcase (	macCoreInterface	driverTestInterface,
			macCoreInterface	monitorTestInterface
			);

   env envLoopBack;
   int noOfPackets;
   int lengthOfFrame;
   
   initial begin

      envLoopBack = new (driverTestInterface, monitorTestInterface);

      noOfPackets = $urandom_range (5, 8);
      lengthOfFrame = $urandom_range (58, 68);
      
      #20 envLoopBack.reset ();
      #30 envLoopBack.init ();
      envLoopBack.run (noOfPackets, lengthOfFrame);
      envLoopBack.validate (noOfPackets, lengthOfFrame);
      
      #1000000 $finish;

   end

   final begin
      $display ("\n\n");
      $display ("\t//////////////////////////////////////////////////////////\n");
      $display ("\t///////////// Test Finished, Results: ////////////////////\n");
      $display ("\t//////////////////////////////////////////////////////////\n");
      
      if (envLoopBack.macCoreScoreboard.error == 1) $display ("\t\t End Of Test ERROR: \n\t\t Error occured while checking packets\n");
      else $display ("\t\t End Of Test PASS: \n\t\t All packets were matched properly\n");
   end
   
endprogram // testcase
   
