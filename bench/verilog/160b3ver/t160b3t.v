/*
 INTEL DEVELOPER'S SOFTWARE LICENSE AGREEMENT

BY USING THIS SOFTWARE, YOU ARE AGREEING TO BE BOUND BY THE TERMS OF 
THIS AGREEMENT.  DO NOT USE THE SOFTWARE UNTIL YOU HAVE CAREFULLY READ 
AND AGREED TO THE FOLLOWING TERMS AND CONDITIONS.  IF YOU DO NOT AGREE 
TO THE TERMS OF THIS AGREEMENT, PROMPTLY RETURN THE SOFTWARE PACKAGE AND 
ANY ACCOMPANYING ITEMS.

IF YOU USE THIS SOFTWARE, YOU WILL BE BOUND BY THE TERMS OF THIS 
AGREEMENT

LICENSE: Intel Corporation ("Intel") grants you the non-exclusive right 
to use the enclosed software program ("Software").  You will not use, 
copy, modify, rent, sell or transfer the Software or any portion 
thereof, except as provided in this Agreement.

System OEM Developers may:
1.      Copy the Software for support, backup or archival purposes;
2.      Install, use, or distribute Intel owned Software in object code
        only;
3.      Modify and/or use Software source code that Intel directly makes
        available to you as an OEM Developer;
4.      Install, use, modify, distribute, and/or make or have made
        derivatives ("Derivatives") of Intel owned Software under the
        terms and conditions in this Agreement, ONLY if you are a System
        OEM Developer and NOT an end-user.

RESTRICTIONS:

YOU WILL NOT:
1.      Copy the Software, in whole or in part, except as provided for
        in this Agreement;
2.      Decompile or reverse engineer any Software provided in object
        code format;
3.      Distribute any Software or Derivative code to any end-users,
        unless approved by Intel in a prior writing.

TRANSFER: You may transfer the Software to another OEM Developer if the 
receiving party agrees to the terms of this Agreement at the sole risk 
of any receiving party.

OWNERSHIP AND COPYRIGHT OF SOFTWARE: Title to the Software and all 
copies thereof remain with Intel or its vendors.  The Software is 
copyrighted and is protected by United States and international 
copyright laws.  You will not remove the copyright notice from the 
Software.  You agree to prevent any unauthorized copying of the 
Software.

DERIVATIVE WORK: OEM Developers that make or have made Derivatives will 
not be required to provide Intel with a copy of the source or object 
code.  OEM Developers shall be authorized to use, market, sell, and/or 
distribute Derivatives to other OEM Developers at their own risk and 
expense. Title to Derivatives and all copies thereof shall be in the 
particular OEM Developer creating the Derivative.  Such OEMs shall 
remove the Intel copyright notice from all Derivatives if such notice is 
contained in the Software source code.

DUAL MEDIA SOFTWARE: If the Software package contains multiple media, 
you may only use the medium appropriate for your system.
 
WARRANTY: Intel warrants that it has the right to license you to use, 
modify, or distribute the Software as provided in this Agreement. The 
Software is provided "AS IS".  Intel makes no representations to 
upgrade, maintain, or support the Software at any time. Intel warrants 
that the media on which the Software is furnished will be free from 
defects in material and workmanship for a period of one (1) year from 
the date of purchase.  Upon return of such defective media, Intel's 
entire liability and your exclusive remedy shall be the replacement of 
the Software.

THE ABOVE WARRANTIES ARE THE ONLY WARRANTIES OF ANY KIND, EITHER EXPRESS 
OR IMPLIED, INCLUDING WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY 
PARTICULAR PURPOSE.

LIMITATION OF LIABILITY: NEITHER INTEL NOR ITS VENDORS OR AGENTS SHALL 
BE LIABLE FOR ANY LOSS OF PROFITS, LOSS OF USE, LOSS OF DATA, 
INTERRUPTION OF BUSINESS, NOR FOR INDIRECT, SPECIAL, INCIDENTAL OR 
CONSEQUENTIAL DAMAGES OF ANY KIND WHETHER UNDER THIS AGREEMENT OR 
OTHERWISE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGES.

TERMINATION OF THIS LICENSE: Intel reserves the right to conduct or have 
conducted audits to verify your compliance with this Agreement.  Intel 
may terminate this Agreement at any time if you are in breach of any of 
its terms and conditions.  Upon termination, you will immediately 
destroy, and certify in writing the destruction of, the Software or 
return all copies of the Software and documentation to Intel.

U.S. GOVERNMENT RESTRICTED RIGHTS: The Software and documentation were 
developed at private expense and are provided with "RESTRICTED RIGHTS".  
Use, duplication or disclosure by the Government is subject to 
restrictions as set forth in FAR52.227-14 and DFAR252.227-7013 et seq. 
or its successor.

EXPORT LAWS: You agree that the distribution and export/re-export of the 
Software is in compliance with the laws, regulations, orders or other 
restrictions of the U.S. Export Administration Regulations.

APPLICABLE LAW: This Agreement is governed by the laws of the State of 
California and the United States, including patent and copyright laws.  
Any claim arising out of this Agreement will be brought in Santa Clara 
County, California.

*/

`timescale   1ns/1ns


module test28F160B3T();

reg     [`AddrSize-1:0]  address;

reg     [31:0]  vcc,
                vpp;

reg             ceb,
                oeb,
                web,
                wpb,
                rpb;

reg    [`MaxOutputs-1:0]  dq_reg;
wire   [`MaxOutputs-1:0]  dq = dq_reg;

IntelAdvBoot IFlash (dq, address, ceb, oeb, web, rpb, wpb, vpp, vcc);

initial
  begin
//        $dumpfile("f160b3t.dmp");
//        $dumpoff;
//        $dumpvars(???,dq,address,ceb,oeb,web,rpb,wpb);
        dq_reg = `MaxOutputs'hz;
        powerup;
        ReadID;
        //Verify READS with loose timing (OE Toggling)
        #200
        SetReadMode;
        #200
    $display("READ DATA, Loose Timing, toggle OE");        
        #200
        ReadData(`AddrSize'h0);
        #200
        ReadData(`AddrSize'h08000);
        #200
        ReadData(`AddrSize'h10000);
        #200
        ReadData(`AddrSize'hFB000);
        #200
        ReadData(`AddrSize'hFC000);
        #200
        ReadData(`AddrSize'hFD000);
        #200
        ReadData(`AddrSize'hFE000);
        #200
        ReadData(`AddrSize'hFF000);
    $display("READ DATA, Loose Timing, toggle Addr");
        //Verify Reads (OE LOW)
        #200
        address = `AddrSize'h07FFF;
        #200
        address = `AddrSize'h0A000;
        #200
        address = `AddrSize'h17FFF;
        #200
        address = `AddrSize'hFBFFF;
        #200
        address = `AddrSize'hFCFFF;
        #200
        address = `AddrSize'hFDF00;
        #200
        address = `AddrSize'hFEF00;
        #200
        address = `AddrSize'hFFFFF;
        #200
        oeb = `VIH;
    $display("PROGRAM DATA, Loose Timing, Boot Locked");
        #200
        ProgramData(`AddrSize'h00000,   `MaxOutputs'h0000);
        #200
        ProgramData(`AddrSize'h08000,   `MaxOutputs'h0001);
        #200
        ProgramData(`AddrSize'h10000,   `MaxOutputs'h0002);
        #200
        ProgramData(`AddrSize'hFB000,   `MaxOutputs'h0034);
        #200
        ProgramData(`AddrSize'hFC000,   `MaxOutputs'h0035);
        #200
        ProgramData(`AddrSize'hFD000,   `MaxOutputs'h0036);
        #200
        ProgramData(`AddrSize'hFE000,   `MaxOutputs'h0037);  //LockBlock
        #200
        ProgramData(`AddrSize'hFF000,   `MaxOutputs'h0038);  //LockBlock
        #200
        ProgramData(`AddrSize'h07FFF,   `MaxOutputs'h1001);
        #200
        ProgramData(`AddrSize'h0A000,   `MaxOutputs'h1000);
        #200
        ProgramData(`AddrSize'h17FFF,   `MaxOutputs'h2000);
        #200
        ProgramData(`AddrSize'hFBFFF,   `MaxOutputs'h3400);
        #200
        ProgramData2(`AddrSize'hFCFFF,   `MaxOutputs'h3500);
        #200
        ProgramData2(`AddrSize'hFDF00,   `MaxOutputs'h3600);
        #200
        ProgramData2(`AddrSize'hFEF00,   `MaxOutputs'h3700);  //LockBlock
        #200
        ProgramData2(`AddrSize'hFFFFF,   `MaxOutputs'h3800);  //LockBlock
    $display("READ DATA, Loose Timing, toggle OE");
        #200
        SetReadMode;
        #200
        ReadData(`AddrSize'h0);
        #200
        ReadData(`AddrSize'h08000);
        #200
        ReadData(`AddrSize'h10000);
        #200
        ReadData(`AddrSize'hFB000);
        #200
        ReadData(`AddrSize'hFC000);
        #200
        ReadData(`AddrSize'hFD000);
        #200
        ReadData(`AddrSize'hFE000);
        #200
        ReadData(`AddrSize'hFF000);
    $display("READ DATA, Loose Timing, toggle Addr");
        //Verify Reads (OE LOW)
        #200
        address = `AddrSize'h07FFF;
        #200
        address = `AddrSize'h0A000;
        #200
        address = `AddrSize'h17FFF;
        #200
        address = `AddrSize'hFBFFF;
        #200
        address = `AddrSize'hFCFFF;
        #200
        address = `AddrSize'hFDF00;
        #200
        address = `AddrSize'hFEF00;
        #200
        address = `AddrSize'hFFFFF;
        #200
        oeb = `VIH;
    $display("Unlock BOOT (WP#)");
        #200
        wpb = `VIH;      //UNLOCK
    $display("PROGRAM DATA, Boot Unlocked");
        #200
        ProgramData(`AddrSize'hFE000,   `MaxOutputs'h0037);
        #200
        ProgramData(`AddrSize'hFF000,   `MaxOutputs'h0038);
        #200
        ProgramData(`AddrSize'hFEF00,   `MaxOutputs'h3700);
        #200
        ProgramData(`AddrSize'hFFFFF,   `MaxOutputs'h3800);
    $display("READ DATA, Loose Timing,  Toggle OE");
        #200
        SetReadMode;
        #200
        ReadData(`AddrSize'hFE000);
        #200
        address = `AddrSize'hFF000;
        #200
        address = `AddrSize'hFEF00;
        #200
        address = `AddrSize'hFFFFF;
        #200
        oeb = `VIH;
    $display("WRITE SUSPEND TEST");
      begin:  WriteSuspend
        #200
        StartProgram(`AddrSize'hFA000, `MaxOutputs'h3300);
        #200
        oeb = `VIH;
        #200
        oeb = `VIL;
        #200
        oeb = `VIH;
        #(((`AC_ProgramTime_Word_27_12/2)*`TimerPeriod_)-1000)
        Suspend;
        #200
        SetReadMode;
        #200
        ReadData(`AddrSize'hF9FFF);
        #200
        ReadData(`AddrSize'hFFFFF);
        #200
        ReadData(`AddrSize'hFA000);
        #200
        oeb = `VIH;
        #200
        StartProgram(`AddrSize'hA0000, `MaxOutputs'hAAAA);
        #300
        Resume;
        #200
        oeb = `VIL;
        #(((`AC_ProgramTime_Word_27_12/2)*`TimerPeriod_)-1000)
        begin: Poll
          forever
            begin
              oeb = `VIH;
              #500
              oeb = `VIL;
              #500
              if (dq[7] == `VIH)
                disable Poll;
            end
        end
        #300
        SetReadMode;
        #200
        ReadData(`AddrSize'hFA001);
        #200
        ReadData(`AddrSize'hFA000);
        #200
        ReadData(`AddrSize'hA0000);
        #200
        oeb = `VIH;
      end  //WriteSuspend
    $display("ERASE Block");
        #200
        EraseBlock(`AddrSize'hFBF00);
    $display("READ DATA, Loose Timing");
        #300
        SetReadMode;
        #200
        ReadData(`AddrSize'hFB000);
        #200
        address = `AddrSize'hFCFFF;
        #200
        address = `AddrSize'hFBFFF;
        #200
        oeb = `VIH;
    $display("ERASE Locked Block");
        #200
        wpb = `VIL;
        #500
        EraseBlock(`AddrSize'hFE500);
        #200
        wpb = `VIH;
    $display("READ DATA, Loose Timing");
        #300
        SetReadMode;
        #200
        ReadData(`AddrSize'hFE000);
        #200
        address = `AddrSize'hFEF00;
        #200
        oeb = `VIH;
        //Bad Erase Confirm
    $display("BAD Erase confirm test");
      begin: BadErase
        #200
        address = `AddrSize'h04000;
        #200
        dq_reg = `EraseBlockCmd;
        #200
        web = `VIL;
        #200
        web = `VIH;
        #200
        dq_reg = `ReadArrayCmd;
        #200
        web = `VIL;
        #200
        web = `VIH;
        #200
        dq_reg = `MaxOutputs'hz;
        #200
        oeb = `VIL;
        #1000
        begin:  Poll
          forever
            begin
              oeb = `VIH;
              #1000
              oeb = `VIL;
              #1000
              if (dq[7] == `VIH)
                disable Poll;
            end //forever
        end //Poll
      end // BadErase
        #500
        ReadCSRMode;
        #500
        ClearCSRMode;
        #500
        ReadCSRMode;
        #500
        SetReadMode;
        #200
        ReadData(`AddrSize'h00000);
        #200
        oeb = `VIH;
    $display("Erase Suspend test");
      begin: EraseSuspendTest
        #200
        StartErase(`AddrSize'h04000);
        #1000
        oeb = `VIH;
        #200
        oeb = `VIL;
        #200
        oeb = `VIH;
        #(((`AC_EraseTime_Main_27_12/2)*`TimerPeriod_)-1000)
        Suspend;
        #200
        ReadCSRMode;
        #200
        SetReadMode;
        #200
        ReadData(`AddrSize'h00000);
        #200
        ReadData(`AddrSize'h08000);
        #200
        ReadData(`AddrSize'hFDF00);
        #200
        oeb = `VIH;
        #200
        ProgramData(`AddrSize'h50000,  `MaxOutputs'h0055);
        #1000
        Resume;
        #200
        oeb = `VIL;
        #(((`AC_EraseTime_Main_27_12/2)*`TimerPeriod_)-1000)
        begin: Poll
          forever
            begin
              oeb = `VIH;
              #500
              oeb = `VIL;
              #500
              if (dq[7] == `VIH)
                disable Poll;
            end
        end
        #300
        SetReadMode;
        #200
        ReadData(`AddrSize'h00000);
        #200
        address = `AddrSize'h50000;
        #200
        address = `AddrSize'h07FFF;
        #200
        oeb = `VIH;
      end // EraseSuspendTest
        #500
    $display("Embedded Suspend Mode");
      begin:  EraseSuspend_
        #100
        StartErase(`AddrSize'h0F000);
        #1000
        oeb = `VIH;
        #200
        oeb = `VIL;
        #200
        oeb = `VIH;
        #(((`AC_EraseTime_Main_27_12/2)*`TimerPeriod_)-1000)
        Suspend;
        #200
        SetReadMode;
        #200
        ReadData(`AddrSize'h10000);
        #200
        oeb = `VIH;
        begin:  WriteSuspend_
          $display("EMBEDDED WRITE SUSPEND TEST");
          #200
          StartProgram(`AddrSize'hFF000, `MaxOutputs'h3800);
          #200
          oeb = `VIH;
          #200
          oeb = `VIL;
          #200
          oeb = `VIH;
          #((`AC_ProgramTime_Word_27_12/2)*`TimerPeriod_)
          Suspend;
          #200
          SetReadMode;
          #200
          ReadData(`AddrSize'hFE000);
          #200
          ReadData(`AddrSize'hFFFFF);
          #200
          oeb = `VIH;
          #500
          Resume;  //Write Operation
          #200
          oeb = `VIL;
//          #500
          #(((`AC_ProgramTime_Word_27_12/2)*`TimerPeriod_)-2000)
          begin: Poll
            forever
              begin
                oeb = `VIH;
                #500
                oeb = `VIL;
                #500
                if (dq[7] == `VIH)
                  disable Poll;
              end
          end
          #300
          SetReadMode;
          #200
          ReadData(`AddrSize'hFF000);
          #200
          oeb = `VIH;
        end  //WriteSuspend_
        #300
        Resume;  //Erase Operation
        #200
        oeb = `VIL;
        #(((`AC_EraseTime_Main_27_12/2)*`TimerPeriod_)-1000)
        begin: Poll
          forever
            begin
              oeb = `VIH;
              #1000
              oeb = `VIL;
              #1000
              if (dq[7] == `VIH)
                disable Poll;
            end
        end
        #200
        ClearCSRMode;
        #300
        SetReadMode;
        #200
        ReadData(`AddrSize'hFD000);
        #200
        address = `AddrSize'h08000;
        #200
        address = `AddrSize'hFCFFF;
        #200
        address = `AddrSize'h0A000;
        #200
        oeb = `VIH;
      end  //EraseSuspend_
    $display("LOW Vpp OPERATION TEST");
        #200
        vpp =1300;
        #100
        ProgramData(`AddrSize'h33333, `MaxOutputs'h3333);
        #200
        EraseBlock(`AddrSize'h17000);
        #200
        vpp = 12000;
        #200
        SetReadMode;
        #200
        ReadData(`AddrSize'h33333);
        #200
        address = `AddrSize'h10000;
        #200
        address = `AddrSize'h17FFF;
        #200
        oeb = `VIH;
        #1000
        powerdown;
        #1000
        $finish;
    end

always @(dq or address or ceb or rpb or oeb or web or wpb or vcc or vpp)
    begin
    $display(
        "%d Addr = %h, Data = %h, CEb=%b, RPb=%b, OEb=%b, WEb=%d, WPb=%b, vcc=%d, vpp = %d",
        $time, address, dq, ceb, rpb, oeb, web, wpb, vcc, vpp);
  end

task powerup;
  begin
    $display("  POWERUP TASK");
    rpb = `VIL;         //reset
    #200
    address = 0;
    #200
    web = `VIH;         //write enable high
    #200
    oeb = `VIH;         //output ts
    #200
    ceb = `VIH;         //disabled
    #200
    vcc = 3300;         //power up vcc
    #5000
    vpp = 12000;        //ramp up vpp
    #5000
    rpb = `VIH;         //out of reset
    #500
    wpb = `VIL;         //blocks locked
    #200
    oeb = `VIL;         //enable outputs
    #200
    ceb = `VIL;         //enable chip
  end
endtask


task powerdown;
  begin
    $display("  POWERDOWN TASK");
    address = 0;
    #200
    rpb = `VIL;     //reset
    #200
    oeb = `VIH;     //output ts
    #200
    web = `VIH;     //we high
    #200
    ceb = `VIH;     //disabled
    #200
    vpp = 0;        //power down vpp
    #5000
    vcc = 0;        //ramp down vcc
  end
endtask


task ReadData;
  input [`AddrSize-1:0] addr;
  begin
    $display("  READDATA TASK");
    oeb = `VIH;
    #200
    address = addr;
    #200
    oeb = `VIL;
  end
endtask

task SetReadMode;
  begin
    $display("  SETREADMODE TASK");
    oeb = `VIH;
    #200
    dq_reg = `ReadArrayCmd;
    #200
    web = `VIL;
    #200
    web = `VIH;
    #200
    dq_reg = `MaxOutputs'hz;
  end
endtask

task ReadID;
  begin
    $display("  READID TASK");
    oeb = `VIH;
    #200
    address = `AddrSize'h0;
    #200
    dq_reg = `ReadIDCmd;
    #200
    web = `VIL;
    #200
    web = `VIH;
    #200
    dq_reg = `MaxOutputs'hz;
    #200
    oeb = `VIL;
    #200
    address = `AddrSize'h1;
  end
endtask


task ReadCSRMode;
  begin
    $display("  READCSR MODE TASK");
    oeb = `VIH;
    #200
    dq_reg = `ReadCSRCmd;
    #200
    web = `VIL;
    #200
    web = `VIH;
    #200
    dq_reg = `MaxOutputs'hz;
    #200
    oeb = `VIL;
  end
endtask

task ClearCSRMode;
  begin
    $display("  CLEARCSRMODE TASK");
    oeb = `VIH;
    #200
    dq_reg = `ClearCSRCmd;
    #200
    web = `VIL;
    #200
    web = `VIH;
    #200
    dq_reg = `MaxOutputs'hz;
  end
endtask


task StartProgram;
  input [`AddrSize-1:0] addr;
  input [`MaxOutputs-1:0] data;
  begin
    $display("  STARTPROGRAM TASK");
    #200
    address = addr;
    #200
    dq_reg = `Program2Cmd;
    #200
    web = `VIL;
    #200
    web = `VIH;
    #200
    dq_reg = data;
    #200
    web = `VIL;
    #200
    web = `VIH;
    #200
    dq_reg = `MaxOutputs'hz;
  end
endtask


task ProgramData;
  input [`AddrSize-1:0] addr;
  input [`MaxOutputs-1:0] data;
  begin
    $display("  PROGRAMDATA TASK");
    StartProgram(addr, data);
    #200
    oeb = `VIL;
    #((`AC_ProgramTime_Word_27_12*`TimerPeriod_)-500)
    begin:  Poll
      forever
        begin
          oeb = `VIH;
          #200
          oeb = `VIL;
          #200
          if (dq[7] == `VIH)
            disable Poll;
        end //forever
    end //Poll
    #300
    ClearCSRMode;
    end
endtask


task StartProgram2;
  input [`AddrSize-1:0] addr;
  input [`MaxOutputs-1:0] data;
  begin
    $display("  STARTPROGRAM2 TASK");
    #200
    address = addr;
    #200
    dq_reg = `Program2Cmd;
    #200
    web = `VIL;
    #10
    ceb = `VIL;
    #200
    ceb = `VIH;
    #10
    web = `VIH;
    #200
    dq_reg = data;
    #200
    web = `VIL;
    #10
    ceb = `VIL;
    #200
    ceb = `VIH;
    #10
    web = `VIH;
    #200
    ceb = `VIL;
    dq_reg = `MaxOutputs'hz;
  end
endtask


task ProgramData2;
  input [`AddrSize-1:0] addr;
  input [`MaxOutputs-1:0] data;
  begin
    $display("  PROGRAMDATA2 TASK");
    ceb = `VIH;
    StartProgram2(addr, data);
    #200
    oeb = `VIL;
    #((`AC_ProgramTime_Word_27_12*`TimerPeriod_)-500)
    begin:  Poll
      forever
        begin
          oeb = `VIH;
          #200
          oeb = `VIL;
          #200
          if (dq[7] == `VIH)
            disable Poll;
        end //forever
    end //Poll
    #300
    ClearCSRMode;
  end
endtask


task StartErase;
  input [`AddrSize-1:0] BlockAddr;
  begin
    $display("  STARTERASE TASK");
    #200
    address = BlockAddr;
    #200
    dq_reg = `EraseBlockCmd;
    #200
    web = `VIL;
    #200
    web = `VIH;
    #200
    dq_reg = `ConfirmCmd;
    #200
    web = `VIL;
    #200
    web = `VIH;
    #200
    dq_reg = `MaxOutputs'hz;
  end
endtask


task EraseBlock;
  input [`AddrSize-1:0] BlockAddr;
  time EraseTime;
  begin
    $display("  ERASEBLOCK TASK");
    StartErase(BlockAddr);
    #200
    oeb = `VIL;
    if (BlockAddr < `AddrSize'h08000)
      EraseTime = ((`AC_EraseTime_Param_27_12*`TimerPeriod_)-5000);
    else
      EraseTime = ((`AC_EraseTime_Main_27_12*`TimerPeriod_)-5000);
    #EraseTime
    begin:  Poll
      forever
        begin
          oeb = `VIH;
          #1000
          oeb = `VIL;
          #1000
          if (dq[7] == `VIH)
            disable Poll;
        end //forever
    end //Poll
    #300
    ClearCSRMode;
  end
endtask

task Suspend;
  begin
    $display("  SUSPEND TASK");
    #200
    dq_reg = `SuspendCmd;
    #200
    web = `VIL;
    #200
    web = `VIH;
    #200
    dq_reg = `MaxOutputs'hz;
    #200
    oeb = `VIL;
    #3000
    begin:  Poll
      forever
        begin
          oeb = `VIH;
          #500
          oeb = `VIL;
          #500
          if (dq[7] == `VIH)
            disable Poll;
       end //forever
    end //Poll
    #300
    ClearCSRMode;
  end
endtask

task Resume;
  begin
    $display("  RESUME TASK");
    #200
    dq_reg = `ResumeCmd;
    #200
    web = `VIL;
    #200
    web = `VIH;
    #200
    dq_reg = `MaxOutputs'hz;
/*    #200
    oeb = `VIL;
    #(((`AC_EraseTime_Main_27_12/2)*`TimerPeriod_)-1000)
    begin:  Poll
      forever
        begin
          oeb = `VIH;
          #1000
          oeb = `VIL;
          #1000
          if (dq[7] == `VIH)
            disable Poll;
        end //forever
    end //Poll
    #300
    ClearCSRMode;
*/
  end
endtask

endmodule
    
