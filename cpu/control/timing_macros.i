//=========================================================================================
// This file contains substitute strings for macros used in the Excel timing table and
// is read and processed by genmatrix.py script to generate exec_matrix.vh include file.
//
// Format of the file:
//
// * Each key is prefixed by ':' and corresponds to a spreadsheet column name.
// * A column (key) contains a number of macros, each starting at its own line.
// * A macro may span multiple lines, in which case use the '\' character after the name to
//   continue on the next line.
// * Multiline macros end when a line does not _start_ with a space character.
// //-style comments are wrapped within /* ... */ if they don't start a line.
//=========================================================================================

//-----------------------------------------------------------------------------------------
:Function
//-----------------------------------------------------------------------------------------
//Fetch is M1
fMFetch
fMRead          fMRead=1;
fMWrite         fMWrite=1;
fIORead         fIORead=1;
fIOWrite        fIOWrite=1;

//-----------------------------------------------------------------------------------------
// Basic timing control
//-----------------------------------------------------------------------------------------
:valid
1               validPLA=1;
:nextM
1               nextM=1;
mr              nextM=1; ctl_mRead=1;
mw              nextM=1; ctl_mWrite=1;
ior             nextM=1; ctl_iorw=1;
iow             nextM=1; ctl_iorw=1;
CC              nextM=!flags_cond_true;
INT             nextM=1; ctl_mRead=in_intr & im2;   // RST38 interrupt extension
:setM1
1               setM1=1;
SS              setM1=!flags_cond_true;
CC              setM1=!flags_cond_true;
ZF              setM1=flags_zf; // Used in DJNZ
BR              setM1=nonRep | !repeat_en;
BRZ             setM1=nonRep | !repeat_en | flags_zf;
INT             setM1=!(in_intr & im2);             // RST38 interrupt extension

//-----------------------------------------------------------------------------------------
// Register file, address (downstream) endpoint
//-----------------------------------------------------------------------------------------
:A:reg rd
// General purpose registers
A       ctl_reg_gp_sel=`GP_REG_AF; ctl_reg_gp_hilo=2'b10; ctl_sw_4d=1;  // Read 8-bit general purpose A register, enable SW4 downstream
r16     ctl_reg_gp_sel=op54; ctl_reg_gp_hilo=2'b11; ctl_sw_4d=1;        // Read 16-bit general purpose register, enable SW4 downstream
BC      ctl_reg_gp_sel=`GP_REG_BC; ctl_reg_gp_hilo=2'b11; ctl_sw_4d=1;  // Read 16-bit BC, enable SW4 downstream
DE      ctl_reg_gp_sel=`GP_REG_DE; ctl_reg_gp_hilo=2'b11; ctl_sw_4d=1;  // Read 16-bit DE, enable SW4 downstream
HL      ctl_reg_gp_sel=`GP_REG_HL; ctl_reg_gp_hilo=2'b11; ctl_sw_4d=1;  // Read 16-bit HL, enable SW4 downstream
SP      ctl_reg_use_sp=1; ctl_reg_gp_sel=`GP_REG_AF; ctl_reg_gp_hilo=2'b11; ctl_sw_4d=1;// Read 16-bit SP, enable SW4 downstream

// System registers
WZ      ctl_reg_sel_wz=1; ctl_reg_sys_hilo=2'b11; ctl_sw_4d=1;      // Select 16-bit WZ
IR      ctl_reg_sel_ir=1; ctl_reg_sys_hilo=2'b11;                   // Select 16-bit IR
I*      ctl_reg_sel_ir=1; ctl_reg_sys_hilo=2'b10; ctl_sw_4d=1;      // Select 8-bit I register
PC      ctl_reg_sel_pc=1; ctl_reg_sys_hilo=2'b11;                   // Select 16-bit PC

// Conditional assertions of WZ, HL instead of PC
WZ? \
    if (flags_cond_true) begin      // If cc is true, use WZ instead of PC (for jumps)
        ctl_reg_not_pc=1; ctl_reg_sel_wz=1; ctl_reg_sys_hilo=2'b11; ctl_sw_4d=1;
    end

:A:reg wr
// General purpose registers
r16     ctl_reg_gp_we=1; ctl_reg_gp_sel=op54; ctl_reg_gp_hilo=2'b11; ctl_sw_4u=1; // Write 16-bit general purpose register, enable SW4 upstream
BC      ctl_reg_gp_we=1; ctl_reg_gp_sel=`GP_REG_BC; ctl_reg_gp_hilo=2'b11; ctl_sw_4u=1; // Write 16-bit BC, enable SW4 upstream
DE      ctl_reg_gp_we=1; ctl_reg_gp_sel=`GP_REG_DE; ctl_reg_gp_hilo=2'b11; ctl_sw_4u=1; // Write 16-bit BC, enable SW4 upstream
HL      ctl_reg_gp_we=1; ctl_reg_gp_sel=`GP_REG_HL; ctl_reg_gp_hilo=2'b11; ctl_sw_4u=1; // Write 16-bit HL, enable SW4 upstream
SP      ctl_reg_gp_we=1; ctl_reg_gp_sel=`GP_REG_AF; ctl_reg_gp_hilo=2'b11; ctl_reg_use_sp=1; ctl_sw_4u=1; // Write 16-bit SP, enable SW4 upstream
// System registers
WZ      ctl_reg_sys_we=1; ctl_reg_sel_wz=1; ctl_reg_sys_hilo=2'b11; ctl_sw_4u=1; // Write 16-bit WZ, enable SW4 upstream
IR      ctl_reg_sys_we=1; ctl_reg_sel_ir=1; ctl_reg_sys_hilo=2'b11; // Write 16-bit IR
// PC will not be incremented if we are in HALT, INTR or NMI state
PC      ctl_reg_sys_we=1; ctl_reg_sel_pc=1; ctl_reg_sys_hilo=2'b11; pc_inc=!(in_halt | in_intr | in_nmi); // Write 16-bit PC and control incrementer
>       ctl_sw_4u=1;

//-----------------------------------------------------------------------------------------
// Controls the address latch incrementer, the address latch and the address pin mux
//-----------------------------------------------------------------------------------------
:inc/dec
+       ctl_inc_cy=pc_inc;                      // Increment
-       ctl_inc_cy=pc_inc; ctl_inc_dec=1;       // Decrement
op3     ctl_inc_cy=pc_inc; ctl_inc_dec=op3;     // Decrement if op3 is set; increment otherwise

:A:latch
W       ctl_al_we=1;                            // Write a value from the register bus to the address latch
R       ctl_bus_inc_oe=1;                       // Output enable incrementer to the register bus
P       ctl_apin_mux=1;                         // Apin sourced from incrementer
RL      ctl_bus_inc_oe=1; ctl_apin_mux2=1;      // Apin sourced from AL

//-----------------------------------------------------------------------------------------
// Register file, data (upstream) endpoint
//-----------------------------------------------------------------------------------------
:D:reg rd
//----- General purpose registers -----
A       ctl_reg_gp_sel=`GP_REG_AF; ctl_reg_gp_hilo=2'b10;
AF      ctl_reg_gp_sel=`GP_REG_AF; ctl_reg_gp_hilo=2'b11;
B       ctl_reg_gp_sel=`GP_REG_BC; ctl_reg_gp_hilo=2'b10;
H       ctl_reg_gp_sel=`GP_REG_HL; ctl_reg_gp_hilo=2'b10;
L       ctl_reg_gp_sel=`GP_REG_HL; ctl_reg_gp_hilo=2'b01;
r8 \    // r8 addressing does not allow reading F register (A and F are also indexed as swapped) (ex. in OUT (c),r)
    if (op4 & op5 & !op3) ctl_bus_zero_oe=1;                // Trying to read flags? Put 0 on the bus instead.
    else begin ctl_reg_gp_sel=op54; ctl_reg_gp_hilo={!rsel3,rsel3}; end // Read 8-bit GP register
r8'     ctl_reg_gp_sel=op21; ctl_reg_gp_hilo={!rsel0,rsel0};// Read 8-bit GP register selected by op[2:0]
rh      ctl_reg_gp_sel=op54; ctl_reg_gp_hilo=2'b10;         // Read 8-bit GP register high byte
rl      ctl_reg_gp_sel=op54; ctl_reg_gp_hilo=2'b01;         // Read 8-bit GP register low byte
//----- System registers -----
WZ      ctl_reg_sel_wz=1; ctl_reg_sys_hilo=2'b11; ctl_sw_4u=1;
Z       ctl_reg_sel_wz=1; ctl_reg_sys_hilo=2'b01; ctl_sw_4u=1; // Selecting strictly Z
I/R     ctl_reg_sel_ir=1; ctl_reg_sys_hilo={!op3,op3}; ctl_sw_4u=1; // Read either I or R based on op3 (0 or 1)
PCh     ctl_reg_sel_pc=1; ctl_reg_sys_hilo=2'b10; ctl_sw_4u=1;
PCl     ctl_reg_sel_pc=1; ctl_reg_sys_hilo=2'b01; ctl_sw_4u=1;

:D:reg wr
?       // Which register to be written is decided elsewhere
//----- General purpose registers -----
A       ctl_reg_gp_we=1; ctl_reg_gp_sel=`GP_REG_AF; ctl_reg_gp_hilo=2'b10;
F       ctl_reg_gp_we=1; ctl_reg_gp_sel=`GP_REG_AF; ctl_reg_gp_hilo=2'b01;
B       ctl_reg_gp_we=1; ctl_reg_gp_sel=`GP_REG_BC; ctl_reg_gp_hilo=2'b10;
r8      ctl_reg_gp_we=1; ctl_reg_gp_sel=op54; ctl_reg_gp_hilo={!rsel3,rsel3}; // Write 8-bit GP register
r8'     ctl_reg_gp_we=1; ctl_reg_gp_sel=op21; ctl_reg_gp_hilo={!rsel0,rsel0}; // Write 8-bit GP register selected by op[2:0]
rh      ctl_reg_gp_we=1; ctl_reg_gp_sel=op54; ctl_reg_gp_hilo=2'b10; // Write 8-bit GP register high byte
rl      ctl_reg_gp_we=1; ctl_reg_gp_sel=op54; ctl_reg_gp_hilo=2'b01; // Write 8-bit GP register low byte
//----- System registers -----
I/R     ctl_reg_sys_we=1; ctl_reg_sel_ir=1; ctl_reg_sys_hilo={!op3,op3}; ctl_sw_4d=1; // Write either I or R based on op3 (0 or 1)
WZ      ctl_reg_sys_we=1; ctl_reg_sel_wz=1; ctl_reg_sys_hilo=2'b11;
W       ctl_reg_sys_we_hi=1; ctl_reg_sel_wz=1; ctl_reg_sys_hilo[1]=1; // Selecting only W
W?      ctl_reg_sys_we_hi=flags_cond_true; ctl_reg_sel_wz=flags_cond_true; ctl_reg_sys_hilo[1]=1; // Conditionally selecting only W
Z       ctl_reg_sys_we_lo=1; ctl_reg_sel_wz=1; ctl_reg_sys_hilo[0]=1; // Selecting only Z

//-----------------------------------------------------------------------------------------
// Controls the register file gate connecting it with the ALU and data bus
//-----------------------------------------------------------------------------------------
:Reg gate
<       ctl_reg_in_hi=1; ctl_reg_in_lo=1;       // From the ALU side into the register file
<l      ctl_reg_in_lo=1;                        // From the ALU side into the register file low byte only
<h      ctl_reg_in_hi=1;                        // From the ALU side into the register file high byte only
>       ctl_reg_out_hi=1; ctl_reg_out_lo=1;     // From the register file into the ALU
>l      ctl_reg_out_lo=1;                       // From the register file into the ALU low byte only
>h      ctl_reg_out_hi=1;                       // From the register file into the ALU high byte only

//-----------------------------------------------------------------------------------------
// Switches on the data bus for each direction (upstream, downstream)
//-----------------------------------------------------------------------------------------
:SW2
d       ctl_sw_2d=1;
u       ctl_sw_2u=1;

:SW1
<       ctl_sw_1d=1;
>       ctl_sw_1u=1;

//-----------------------------------------------------------------------------------------
// Data bus latches and pads control
//-----------------------------------------------------------------------------------------
:DB pads
R       ctl_bus_db_oe=1;                        // Read DB pads to internal data bus
W       ctl_bus_db_we=1;                        // Write DB pads with internal data bus value
00      ctl_bus_zero_oe=1;                      // Force 0x00 on the data bus
FF      ctl_bus_ff_oe=1;                        // Force 0xFF on the data bus

//-----------------------------------------------------------------------------------------
// ALU
//-----------------------------------------------------------------------------------------
:ALU
// Controls the master ALU output enable and the ALU input, only one can be active at a time
// >bs if set, will override >s0 which is used by bit instructions to override default M1/T3 load
<       ctl_alu_oe=1;                           // Enable ALU onto the data bus
>s0     ctl_alu_shift_oe=!ctl_alu_bs_oe;        // Shifter unit without shift-enable
>s1     ctl_alu_shift_oe=1; ctl_shift_en=1;     // Shifter unit AND shift enable!
>bs     ctl_alu_bs_oe=1;                        // Bit-selector unit

:ALU bus
// Controls the writer to the internal ALU bus
op1     ctl_alu_op1_oe=1;                       // OP1 latch
op2     ctl_alu_op2_oe=1;                       // OP2 latch
res     ctl_alu_res_oe=1;                       // Result latch

:op2 latch
// Controls a MUX to select the input to the OP2 latch
bus     ctl_alu_op2_sel_bus=1;                  // Internal bus
lq      ctl_alu_op2_sel_lq=1;                   // Cross-bus wire (see schematic)
0       ctl_alu_op2_sel_zero=1;                 // Zero

:op1 latch
// Controls a MUX to select the input to the OP1 latch
bus     ctl_alu_op1_sel_bus=1;                  // Internal bus
low     ctl_alu_op1_sel_low=1;                  // Write low nibble with a high nibble
0       ctl_alu_op1_sel_zero=1;                 // Zero

:operation
// Sets the ALU core operation
//--------------------------------------------------------------------------------------------------------------------------
CP \
    ctl_alu_core_R=0; ctl_alu_core_V=0; ctl_alu_core_S=0;                                             ctl_alu_sel_op2_neg=1;
    if (ctl_alu_op_low) begin
                                                              ctl_flags_cf_set=1;
    end else begin
        ctl_alu_core_hf=1;
    end
//--------------------------------------------------------------------------------------------------------------------------
SUB \

    ctl_alu_core_R=0; ctl_alu_core_V=0; ctl_alu_core_S=0;                                             ctl_alu_sel_op2_neg=1;
    if (ctl_alu_op_low) begin
                                                              ctl_flags_cf_set=1;
    end else begin
        ctl_alu_core_hf=1;
    end
//--------------------------------------------------------------------------------------------------------------------------
SBC \
    ctl_alu_core_R=0; ctl_alu_core_V=0; ctl_alu_core_S=0;                                             ctl_alu_sel_op2_neg=1;
    if (ctl_alu_op_low) begin
                                                                                  ctl_flags_cf_cpl=1;
    end else begin
        ctl_alu_core_hf=1;
    end
//--------------------------------------------------------------------------------------------------------------------------
SBCh \
    ctl_alu_core_R=0; ctl_alu_core_V=0; ctl_alu_core_S=0;                                             ctl_alu_sel_op2_neg=1;
    if (!ctl_alu_op_low) begin
        ctl_alu_core_hf=1;
    end
//--------------------------------------------------------------------------------------------------------------------------
ADC \
    ctl_alu_core_R=0; ctl_alu_core_V=0; ctl_alu_core_S=0;
    if (!ctl_alu_op_low) begin
        ctl_alu_core_hf=1;
    end
//--------------------------------------------------------------------------------------------------------------------------
ADD \
    ctl_alu_core_R=0; ctl_alu_core_V=0; ctl_alu_core_S=0;
    if (ctl_alu_op_low) begin
                                                              ctl_flags_cf_set=1; ctl_flags_cf_cpl=1;
    end else begin
        ctl_alu_core_hf=1;
    end
//--------------------------------------------------------------------------------------------------------------------------
AND     ctl_alu_core_R=0; ctl_alu_core_V=0; ctl_alu_core_S=1; ctl_flags_cf_set=1;
OR      ctl_alu_core_R=1; ctl_alu_core_V=1; ctl_alu_core_S=1; ctl_flags_cf_set=1; ctl_flags_cf_cpl=1;
XOR     ctl_alu_core_R=1; ctl_alu_core_V=0; ctl_alu_core_S=0; ctl_flags_cf_set=1; ctl_flags_cf_cpl=1;

NAND    ctl_alu_core_R=0; ctl_alu_core_V=0; ctl_alu_core_S=1; ctl_flags_cf_set=1;                     ctl_alu_sel_op2_neg=1;
NOR     ctl_alu_core_R=1; ctl_alu_core_V=1; ctl_alu_core_S=1; ctl_flags_cf_set=1; ctl_flags_cf_cpl=1; ctl_alu_sel_op2_neg=1;
//--------------------------------------------------------------------------------------------------------------------------

PLA     ctl_state_alu=1;                        // Assert the ALU PLA modifier to determine operation

:nibble
// ALU computational phase: low nibble or high nibble
L       ctl_alu_op_low=1;                       // Activate ALU operation on low nibble
H       ctl_alu_sel_op2_high=1;                 // Activate ALU operation on high nibble

//-----------------------------------------------------------------------------------------
// FLAGT
//-----------------------------------------------------------------------------------------
:FLAGT
<       ctl_flags_oe=1;                         // Enable FLAGT onto the data bus
>       ctl_flags_bus=1;                        // Load FLAGT from the data bus
alu     ctl_flags_alu=1;                        // Load FLAGT from the ALU

// Write enables for various flag bits and segments
:SZ
*       ctl_flags_sz_we=1;
:XY
*       ctl_flags_xy_we=1;
?
:HF
*       ctl_flags_hf_we=1;
W2      ctl_flags_hf2_we=1;                     // Write HF2 flag (DAA only)
:PF
*       ctl_flags_pf_we=1;
P       ctl_flags_pf_we=1; ctl_pf_sel=`PFSEL_P;
V       ctl_flags_pf_we=1; ctl_pf_sel=`PFSEL_V;
iff2    ctl_flags_pf_we=1; ctl_pf_sel=`PFSEL_IFF2;
REP     ctl_flags_pf_we=1; ctl_pf_sel=`PFSEL_REP;
?
:NF
*       ctl_flags_nf_we=1;                      // Previous NF, to be used when loading FLAGT
0       ctl_flags_nf_we=1; ctl_flags_nf_clr=1;
1       ctl_flags_nf_we=1; ctl_flags_nf_set=1;
S       ctl_flags_nf_we=1;                      // Sign bit, to be used with FLAGT source set to "alu"
?
:CF
*       ctl_flags_cf_we=1;
0       ctl_flags_cf_set=1; ctl_flags_cf_cpl=1; // Clear CF going into the ALU core
1       ctl_flags_cf_set=1;                     // Set CF going into the ALU core
^       ctl_flags_cf_we=1;  ctl_flags_cf_cpl=1; // CCF
:CF2
R       ctl_flags_use_cf2=1;
W       ctl_flags_cf2_we=1; ctl_flags_cf2_sel=0;
W.sh    ctl_flags_cf2_we=1; ctl_flags_cf2_sel=1;
W.daa   ctl_flags_cf2_we=1; ctl_flags_cf2_sel=2;
W.0     ctl_flags_cf2_we=1; ctl_flags_cf2_sel=3;

//-----------------------------------------------------------------------------------------
// Special sequence macros for some instructions make it simpler for all other entries
//-----------------------------------------------------------------------------------------
:Special
USE_SP          ctl_reg_use_sp=1;                           // For 16-bit loads: use SP instead of AF

// A few more specific states and instructions:
Ex_DE_HL        ctl_reg_ex_de_hl=1;                         // EX DE,HL
Ex_AF_AF'       ctl_reg_ex_af=1;                            // EX AF,AF'
EXX             ctl_reg_exx=1;                              // EXX
HALT            ctl_state_halt_set=1;                       // Enter HALT state
DI_EI           ctl_iffx_bit=op3; ctl_iffx_we=1;            // DI/EI
IM              ctl_im_we=1;                                // IM n ('n' is read by opcode[4:3])

WZ=IX+d         ixy_d=1;                                    // Compute WZ=IX+d
IX_IY           ctl_state_ixiy_we=1; ctl_state_iy_set=op5; setIXIY=1;   // IX/IY prefix
CLR_IX_IY       ctl_state_ixiy_we=1; ctl_state_ixiy_clr=!setIXIY;       // Clear IX/IY flag

CB              ctl_state_tbl_cb_set=1; setCBED=1;          // CB-table prefix
ED              ctl_state_tbl_ed_set=1; setCBED=1;          // ED-table prefix
CLR_CB_ED       ctl_state_tbl_clr=!setCBED;                 // Clear CB/ED prefix

// If the NF is set, complement HF and CF on the way out to the bus
// This is used to correctly set those flags after subtraction operations
?NF_HF_CF       ctl_flags_hf_cpl=flags_nf; ctl_flags_cf_cpl=flags_nf;
?NF_HF          ctl_flags_hf_cpl=flags_nf;
?~CF_HF         ctl_flags_hf_cpl=!flags_cf;  // Used for CCF
?SF_NEG         ctl_alu_sel_op2_neg=flags_sf;
NEG_OP2         ctl_alu_sel_op2_neg=1;
?NF_SUB         ctl_alu_sel_op2_neg=flags_nf; ctl_flags_cf_cpl=!flags_nf;

// M1 opcode read cycle and the refresh register increment cycle
// Write opcode into the instruction register through internal db0 bus:
OpcodeToIR      ctl_ir_we=1;
// At the common instruction load M1/T3, override opcode byte when servicing interrupts:
// 1. We are in HALT mode: push NOP (0x00) instead
// 2. We are in INTR mode (IM1 or IM2): push RST38 (0xFF) instead
// 3. We are in NMI mode: push RST38 (0xFF) instead
OverrideIR      ctl_bus_zero_oe=in_halt; ctl_bus_ff_oe=(in_intr & (im1 | im2)) | in_nmi;

// RST instruction uses opcode[5:3] to specify a vector and this control passes those 3 bits through
MASK_543        ctl_sw_mask543_en=!((in_intr & im2) | in_nmi);
// Based on the in_nmi state, several things are set:
// 1. Disable SW1 so the opcode will not get onto db1 bus
// 2. Generate 0x66 on the db1 bus which will be used as the target vector address
// 3. Clear IFF1 (done by the nmi logic on posedge of in_nmi)
RST_NMI         ctl_sw_1d=!in_nmi; ctl_66_oe=in_nmi;
// Based on the in_intr state, several things are set:
// 1. IM1 mode, force 0xFF on the db0 bus
// 2. Clear IFF1 and IFF2 (done by the intr logic on posedge of in_intr)
RST_INT         ctl_bus_ff_oe=in_intr & im1;
RETN            ctl_iff1_iff2=1;                // RETN copies IFF2 into IFF1
NO_INTS         ctl_no_ints=1;                  // Disable interrupt generation for this opcode (DI/EI/CB/ED/DD/FD)

EvalCond        ctl_eval_cond=1;                // Evaluate flags condition based on the opcode[5:3]
CondShort       ctl_cond_short=1;               // M1/T3 only: force a short flags condition (SS)
Limit6          ctl_inc_limit6=1;               // Limit the incrementer to 6 bits
DAA             ctl_daa_oe=1;                   // Write DAA correction factor to the bus
ZERO_16BIT      ctl_alu_zero_16bit=1;           // 16-bit arithmetic operation uses ZF calculated over 2 bytes
NonRep          nonRep=1;                       // Non-repeating block instruction
WriteBC=1       ctl_repeat_we=1;                // Update repeating flag latch with BC=1 status
NOT_PC!         ctl_reg_not_pc=1;               // For M1/T1 load from a register other than PC
