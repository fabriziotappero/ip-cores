//		$display("%d Fetched pc=%h.%h insn: %h", $time, {pc[63:4],4'h0},pc[3:2], insn);
		$display("Fetched pc=%h insn: %h HWI:%d", {pc[63:2],2'h0}, insn, StatusHWI);
		casex(insn[31:25])
		`MISC:
			begin
			$display("MISC");
			case(insn[6:0])
			`BRK:	$display("BRK");
			`WAIT:	$display("WAIT");
			`IRET:	$display("IRET");
			`CLI:	$display("CLI");
			`SEI:	$display("SEI");
			`TLBR:	$display("TLBR");
			`TLBWI:	$display("TLBWI");
			`TLBWR:	$display("TLBWR");
			`ICACHE_ON:	$display("ICACHE_ON");
			`ICACHE_OFF:	$display("ICACHE_OFF");
			`DCACHE_ON:	$display("DCACHE_ON");
			`DCACHE_OFF:	$display("DCACHE_OFF");
			default:	;
			endcase
			end
		`R:	
			case(insn[5:0])
//			`SGN:	$display("SGN");
			`NEG:	$display("NEG r%d,r%d",insn[19:15],insn[24:20]);
			`COM:	$display("COM r%d,r%d",insn[19:15],insn[24:20]);
			`ABS:	$display("ABS r%d,r%d",insn[19:15],insn[24:20]);
			`SQRT:	$display("SQRT r%d,r%d",insn[19:15],insn[24:20]);
			`OMGI:	$display("OMG r%d,#%d",insn[19:15],insn[12:7]);
			`MOV:	$display("MOV r%r,r%d",insn[19:15],insn[24:20]);
			default:	;
			endcase
		`RR:
			case(insn[5:0])
			`ADD:	$display("ADD r%d,r%d,r%d",insn[14:10],insn[24:20],insn[19:15]);
			`ADDU:	$display("ADDU r%d,r%d,r%d",insn[14:10],insn[24:20],insn[19:15]);
			`SUB:	$display("SUB r%d,r%d,r%d",insn[14:10],insn[24:20],insn[19:15]);
			`SUBU:	$display("SUBU r%d,r%d,r%d",insn[14:10],insn[24:20],insn[19:15]);
			`CMP:	$display("CMP r%d,r%d,r%d",insn[14:10],insn[24:20],insn[19:15]);
			`CMPU:	$display("CMPU r%d,r%d,r%d",insn[14:10],insn[24:20],insn[19:15]);
			`AND:	$display("AND r%d,r%d,r%d",insn[14:10],insn[24:20],insn[19:15]);
			`ANDC:	$display("ANDC r%d,r%d,r%d",insn[14:10],insn[24:20],insn[19:15]);
			`OR:	$display("OR  r%d,r%d,r%d",insn[14:10],insn[24:20],insn[19:15]);
			`ORC:	$display("ORC r%d,r%d,r%d",insn[14:10],insn[24:20],insn[19:15]);
			`XOR:	$display("XOR r%d,r%d,r%d",insn[14:10],insn[24:20],insn[19:15]);
			`NAND:	$display("NAND r%d,r%d,r%d",insn[14:10],insn[24:20],insn[19:15]);
			`NOR:	$display("NOR  r%d,r%d,r%d",insn[14:10],insn[24:20],insn[19:15]);
			`XNOR:	$display("XNOR r%d,r%d,r%d",insn[14:10],insn[24:20],insn[19:15]);
			`MULU:	$display("MULU r%d,r%d,r%d",insn[14:10],insn[24:20],insn[19:15]);
			default:	;
			endcase
		`SHFTI:
			case(insn[4:0])
			`SHLI:	$display("SHLI r%d,r%d,#%d",insn[19:15],insn[24:20],insn[14:9]);
			`SHRUI:	$display("SHRUI r%d,r%d,#%d",insn[19:15],insn[24:20],insn[14:9]);
			`SHRI:	$display("SHRI r%d,r%d,#%d",insn[19:15],insn[24:20],insn[14:9]);
			`ROLI:	$display("ROLI r%d,r%d,#%d",insn[19:15],insn[24:20],insn[14:9]);
			`RORI:	$display("RORI r%d,r%d,#%d",insn[19:15],insn[24:20],insn[14:9]);
			`SHLUI:	$display("SHLUI r%d,r%d,#%d",insn[19:15],insn[24:20],insn[14:9]);
			endcase
		`BTRR:
			case(insn[4:0])
			`BEQ:	$display("BEQ r%d,r%d,%h)",insn[24:20],insn[19:15],{{54{insn[14]}},insn[14:5]});
			`BNE:	$display("BNE r%d,r%d,%h)",insn[24:20],insn[19:15],{{54{insn[14]}},insn[14:5]});
			`BLT:	$display("BLT r%d,r%d,%h)",insn[24:20],insn[19:15],{{54{insn[14]}},insn[14:5]});
			`BLE:	$display("BLE r%d,r%d,%h)",insn[24:20],insn[19:15],{{54{insn[14]}},insn[14:5]});
			`BGT:	$display("BGT r%d,r%d,%h)",insn[24:20],insn[19:15],{{54{insn[14]}},insn[14:5]});
			`BGE:	$display("BGE r%d,r%d,%h)",insn[24:20],insn[19:15],{{54{insn[14]}},insn[14:5]});
			`BLTU:	$display("BLTU r%d,r%d,%h)",insn[24:20],insn[19:15],{{54{insn[14]}},insn[14:5]});
			`BLEU:	$display("BLEU r%d,r%d,%h)",insn[24:20],insn[19:15],{{54{insn[14]}},insn[14:5]});
			`BGTU:	$display("BGTU r%d,r%d,%h)",insn[24:20],insn[19:15],{{54{insn[14]}},insn[14:5]});
			`BGEU:	$display("BGEU r%d,r%d,%h)",insn[24:20],insn[19:15],{{54{insn[14]}},insn[14:5]});
			`BRA:	$display("BRA %h)",{{54{insn[14]}},insn[14:5]});
			`LOOP:	$display("LOOP r%d,%h)",insn[19:15],{{54{insn[14]}},insn[14:5]});
			default:	;
			endcase
		`SETLO:	$display("SETLO r%d,#%h", insn[26:22],insn[21:0]);
		`SETMID:	$display("SETMID r%d,#%h", insn[26:22],insn[21:0]);
		`SETHI:	$display("SETHI r%d,#%h", insn[26:22],insn[19:0]);
		`ADDI:	$display("ADDI r%d,r%d,#%d",insn[19:15],insn[24:20],{{49{insn[14]}},insn[14:0]});
		`ADDUI:	$display("ADDUI r%d,r%d,#%d",insn[19:15],insn[24:20],{{49{insn[14]}},insn[14:0]});
		`SUBI:	$display("SUBI r%d,r%d,#%d",insn[19:15],insn[24:20],{{49{insn[14]}},insn[14:0]});
		`SUBUI:	$display("SUBUI r%d,r%d,#%d",insn[19:15],insn[24:20],{{49{insn[14]}},insn[14:0]});
		`CMPI:	$display("CMPI r%d,r%d,#%d",insn[19:15],insn[24:20],{{49{insn[14]}},insn[14:0]});
		`CMPUI:	$display("CMPUI r%d,r%d,#%d",insn[19:15],insn[24:20],{{49{insn[14]}},insn[14:0]});
		`DIVUI:	$display("DIVUI r%d,r%d,#%d",insn[19:15],insn[24:20],{49'd0,insn[14:0]});
		`DIVSI:	$display("DIVSI r%d,r%d,#%d",insn[19:15],insn[24:20],{49'd0,insn[14:0]});
		`ANDI:	$display("ANDI r%d,r%d,#%d",insn[19:15],insn[24:20],{{49{insn[14]}},insn[14:0]});
		`ORI:	$display("ORI  r%d,r%d,#%d",insn[19:15],insn[24:20],{49'd0,insn[14:0]});
		`XORI:	$display("XORI r%d,r%d,#%d",insn[19:15],insn[24:20],{49'd0,insn[14:0]});
		`JMP:	$display("JMP  %h",{insn[24:0],2'b00});
		`CALL:	$display("CALL %h",{insn[24:0],2'b00});
		`JAL:	$display("JAL %h,",insn[19:15]);
		`RET:	$display("RET R%d,R%d,#%h",insn[24:20],insn[19:15],{{49{insn[14]}},insn[14:0]});
		`BEQI:	$display("BEQI r%d,#%d,%h)",insn[24:20],insn[7:0],{{50{insn[19]}},insn[19:8]});
		`BNEI:	$display("BNEI r%d,#%d,%h)",insn[24:20],insn[7:0],{{50{insn[19]}},insn[19:8]});
		`BLTI:	$display("BLTI r%d,#%d,%h)",insn[24:20],insn[7:0],{{50{insn[19]}},insn[19:8]});
		`BLEI:	$display("BLEI r%d,#%d,%h)",insn[24:20],insn[7:0],{{50{insn[19]}},insn[19:8]});
		`BGTI:	$display("BGTI r%d,#%d,%h)",insn[24:20],insn[7:0],{{50{insn[19]}},insn[19:8]});
		`BGEI:	$display("BGEI r%d,#%d,%h)",insn[24:20],insn[7:0],{{50{insn[19]}},insn[19:8]});
		`BLTUI:	$display("BLTUI r%d,#%d,%h)",insn[24:20],insn[7:0],{{50{insn[19]}},insn[19:8]});
		`BLEUI:	$display("BLEUI r%d,#%d,%h)",insn[24:20],insn[7:0],{{50{insn[19]}},insn[19:8]});
		`BGTUI:	$display("BGTUI r%d,#%d,%h)",insn[24:20],insn[7:0],{{50{insn[19]}},insn[19:8]});
		`BGEUI:	$display("BGEUI r%d,#%d,%h)",insn[24:20],insn[7:0],{{50{insn[19]}},insn[19:8]});
		`NOPI:	$display("NOP");
		`SB:	$display("SB r%d,%d[r%d]",insn[19:15],{{49{insn[14]}},insn[14:0]},insn[24:20]);
		`SC:	$display("SC r%d,%d[r%d]",insn[19:15],{{49{insn[14]}},insn[14:0]},insn[24:20]);
		`SH:	$display("SH r%d,%d[r%d]",insn[19:15],{{49{insn[14]}},insn[14:0]},insn[24:20]);
		`SW:	$display("SW %d:r%d,%d[r%d]",AXC,insn[19:15],{{49{insn[14]}},insn[14:0]},insn[24:20]);
		`LEA:	$display("LEA r%d,%d[r%d]",insn[19:15],{{49{insn[14]}},insn[14:0]},insn[24:20]);
		`LB:	$display("LB r%d,%d[r%d]",insn[19:15],{{49{insn[14]}},insn[14:0]},insn[24:20]);
		`LBU:	$display("LBU r%d,%d[r%d]",insn[19:15],{{49{insn[14]}},insn[14:0]},insn[24:20]);
		`LC:	$display("LC r%d,%d[r%d]",insn[19:15],{{49{insn[14]}},insn[14:0]},insn[24:20]);
		`LCU:	$display("LCU r%d,%d[r%d]",insn[19:15],{{49{insn[14]}},insn[14:0]},insn[24:20]);
		`LH:	$display("LH r%d,%d[r%d]",insn[19:15],{{49{insn[14]}},insn[14:0]},insn[24:20]);
		`LHU:	$display("LHU r%d,%d[r%d]",insn[19:15],{{49{insn[14]}},insn[14:0]},insn[24:20]);
		`LW:	$display("LW %d:r%d,%d[r%d]",AXC,insn[19:15],{{49{insn[14]}},insn[14:0]},insn[24:20]);
		`INB:	$display("INB r%d,%d[r%d]",insn[19:15],{{49{insn[14]}},insn[14:0]},insn[24:20]);
		`INBU:	$display("INBU r%d,%d[r%d]",insn[19:15],{{49{insn[14]}},insn[14:0]},insn[24:20]);
		`INCH:	$display("INCH r%d,%d[r%d]",insn[19:15],{{49{insn[14]}},insn[14:0]},insn[24:20]);
		`INCU:	$display("INCU r%d,%d[r%d]",insn[19:15],{{49{insn[14]}},insn[14:0]},insn[24:20]);
		`INH:	$display("INH r%d,%d[r%d]",insn[19:15],{{49{insn[14]}},insn[14:0]},insn[24:20]);
		`INHU:	$display("INHU r%d,%d[r%d]",insn[19:15],{{49{insn[14]}},insn[14:0]},insn[24:20]);
		`INW:	$display("INW r%d,%d[r%d]",insn[19:15],{{49{insn[14]}},insn[14:0]},insn[24:20]);
		`OUTB:	$display("OUTB r%d,%d[r%d]",insn[19:15],{{49{insn[14]}},insn[14:0]},insn[24:20]);
		`OUTC:	$display("OUTC r%d,%d[r%d]",insn[19:15],{{49{insn[14]}},insn[14:0]},insn[24:20]);
		`OUTH:	$display("OUTH r%d,%d[r%d]",insn[19:15],{{49{insn[14]}},insn[14:0]},insn[24:20]);
		`OUTW:	$display("OUTW r%d,%d[r%d]",insn[19:15],{{49{insn[14]}},insn[14:0]},insn[24:20]);
		`MEMNDX:
			case(insn[5:0]+32)
			`SB:	$display("SB r%d,[r%d+r%d<<%d]",insn[14:10],insn[24:20],insn[19:15],insn[9:8]);
			`SC:	$display("SC r%d,[r%d+r%d<<%d]",insn[14:10],insn[24:20],insn[19:15],insn[9:8]);
			`SH:	$display("SH r%d,[r%d+r%d<<%d]",insn[14:10],insn[24:20],insn[19:15],insn[9:8]);
			`SW:	$display("SW r%d,[r%d+r%d<<%d]",insn[14:10],insn[24:20],insn[19:15],insn[9:8]);
			`LB:	$display("LB r%d,[r%d+r%d<<%d]",insn[14:10],insn[24:20],insn[19:15],insn[9:8]);
			`LC:	$display("LC r%d,[r%d+r%d<<%d]",insn[14:10],insn[24:20],insn[19:15],insn[9:8]);
			`LH:	$display("LH r%d,[r%d+r%d<<%d]",insn[14:10],insn[24:20],insn[19:15],insn[9:8]);
			`LBU:	$display("LBU r%d,[r%d+r%d<<%d]",insn[14:10],insn[24:20],insn[19:15],insn[9:8]);
			`LHU:	$display("LHU r%d,[r%d+r%d<<%d]",insn[14:10],insn[24:20],insn[19:15],insn[9:8]);
			`LW:	$display("LW r%d,[r%d+r%d<<%d]",insn[14:10],insn[24:20],insn[19:15],insn[9:8]);
			`LEA:	$display("LEA");
			`OUTB:	$display("OUTB r%d,[r%d+r%d<<%d]",insn[14:10],insn[24:20],insn[19:15],insn[9:8]);
			`OUTC:	$display("OUTC r%d,[r%d+r%d<<%d]",insn[14:10],insn[24:20],insn[19:15],insn[9:8]);
			`OUTH:	$display("OUTH r%d,[r%d+r%d<<%d]",insn[14:10],insn[24:20],insn[19:15],insn[9:8]);
			`OUTW:	$display("OUTW r%d,[r%d+r%d<<%d]",insn[14:10],insn[24:20],insn[19:15],insn[9:8]);
			`INB:	$display("INB r%d,[r%d+r%d<<%d]",insn[14:10],insn[24:20],insn[19:15],insn[9:8]);
			`INCH:	$display("INCH r%d,[r%d+r%d<<%d]",insn[14:10],insn[24:20],insn[19:15],insn[9:8]);
			`INH:	$display("INH r%d,[r%d+r%d<<%d]",insn[14:10],insn[24:20],insn[19:15],insn[9:8]);
			`INW:	$display("INW r%d,[r%d+r%d<<%d]",insn[14:10],insn[24:20],insn[19:15],insn[9:8]);
			`INBU:	$display("INBU r%d,[r%d+r%d<<%d]",insn[14:10],insn[24:20],insn[19:15],insn[9:8]);
			`INCU:	$display("INCU r%d,[r%d+r%d<<%d]",insn[14:10],insn[24:20],insn[19:15],insn[9:8]);
			`INHU:	$display("INHU r%d,[r%d+r%d<<%d]",insn[14:10],insn[24:20],insn[19:15],insn[9:8]);
			endcase
		default:	;
		endcase
