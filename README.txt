
------------------------------ Remark ----------------------------------------
This code is a generic code written in RobustVerilog. In order to convert it to Verilog a RobustVerilog parser is required. 
It is possible to download a free RobustVerilog parser from www.provartec.com/edatools.

We will be very happy to receive any kind of feedback regarding our tools and cores. 
We will also be willing to support any company intending to integrate our cores into their project.
For any questions / remarks / suggestions / bugs please contact info@provartec.com.
------------------------------------------------------------------------------

RobustVerilog generic APB register file

This register file generator uses an Excel worksheet and produces:
1. Verilog register file
2. C header file
3. HTML documentation

The Excel worksheet named Database holds the registers and their fields.

Register and field types:
RW - Read and Write
RO - Read only
WO - Write only

The Excel worksheet automatically generates the RobustVerilog definition files in the RobustVerilog_regs and RobustVerilog_fields worksheets

Creating the output files:
1. Make changes as required in the Excel Database worksheet
2. Save worksheet RobustVerilog_regs as text to def_regs.txt (space delimiters)
3. Save worksheet RobustVerilog_fields as text to def_fields.txt (space delimiters)
4. Run the run.sh script in the run dicertory
5. Output files will be in run/out directory


In order to create the design use the run.sh script in the run directory (notice that the run scripts calls the robust binary (RobustVerilog parser)).




