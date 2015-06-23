/*
   Copyright 2011 Martin Schoeberl <masca@imm.dtu.dk>,
                  Technical University of Denmark, DTU Informatics. 
   All rights reserved.

   Redistribution and use in source and binary forms, with or without
   modification, are permitted provided that the following conditions are met:

      1. Redistributions of source code must retain the above copyright notice,
         this list of conditions and the following disclaimer.

      2. Redistributions in binary form must reproduce the above copyright
         notice, this list of conditions and the following disclaimer in the
         documentation and/or other materials provided with the distribution.

   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDER ``AS IS'' AND ANY EXPRESS
   OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
   OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN
   NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY
   DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
   (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
   LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
   ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
   (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
   THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

   The views and conclusions contained in the software and documentation are
   those of the authors and should not be interpreted as representing official
   policies, either expressed or implied, of the copyright holder.
 */

package leros.sim;

import java.io.*;

/**
 * A crude simulation of Leros. Pipeline effects (branch delay slots) are
 * currently ignored.
 * 
 * @author Martin Schoeberl
 * 
 */
public class LerosSim {

	String fname;
	// no real use of dstDir
	String dstDir = "./";
	String srcDir = "./";
	boolean log;

	ILerosIO io;

	final static int IM_SIZE = 1024;
	final static int DM_SIZE = 1024;
	char im[] = new char[IM_SIZE];
	char dm[] = new char[DM_SIZE];
	int progSize = 0;

	int executedInstructions;
	
	public LerosSim(LerosIO io, String[] args) {

		this.io = io;

		String s = System.getProperty("log");
		if (s != null) {
			log = s.equals("true");
		}
		log=false;
		srcDir = System.getProperty("user.dir");
		dstDir = System.getProperty("user.dir");
		processOptions(args);
		if (!srcDir.endsWith(File.separator))
			srcDir += File.separator;
		if (!dstDir.endsWith(File.separator))
			dstDir += File.separator;

		BufferedReader instr = null;
		try {
			instr = new BufferedReader(new FileReader(srcDir + fname));
			String l;
			while ((l = instr.readLine()) != null) {
				im[progSize] = (char) Integer.parseInt(l);
				++progSize;
			}
			System.out.println("Instruction memory " + (progSize * 2)
					+ " bytes");
		} catch (IOException e) {
			e.printStackTrace();
		} finally {
			if (instr != null) {
				try {
					instr.close();
				} catch (IOException e) {
					e.printStackTrace();
				}
			}

		}
	}

	private boolean processOptions(String clist[]) {
		boolean success = true;

		for (int i = 0; i < clist.length; i++) {
			if (clist[i].equals("-s")) {
				srcDir = clist[++i];
			} else if (clist[i].equals("-d")) {
				dstDir = clist[++i];
			} else if (clist[i].equals("-qio")) {
				QuickIO qio = new QuickIO();
				qio.setVisible(true);
				io = qio;
				
			} else {
				fname = clist[i];
			}
		}

		return success;
	}

	/**
	 * Run the simulation. First instruction is not executed as in the hardware.
	 */
	public void simulate() {

		int ar, pc, accu;
		int accu_dly, accu_dly1;

		pc = 1;
		accu = 0;
		ar = 0;
		accu_dly = accu_dly1 = 0;

		for (;;) {

			// two cycles delay for branch
			// condition modeling
			// We should model the 'real' pipeline in the simulator...
			accu_dly = accu_dly1;
			accu_dly1 = accu;

			int next_pc = pc + 1;
			if (pc >= progSize) {
			    System.out.println("Excuted = " + executedInstructions );
				return;
			}
			int instr = im[pc];
			int val;
			// immediate value
			if ((instr & 0x0100) != 0) {
				// take o bit from the instruction
				val = instr & 0xff;
				// sign extension to 16 bit
				if ((val & 0x80)!=0) { val |= 0xff00; }
			} else {
				val = dm[instr & 0xff];
			}
			executedInstructions++;
			
			switch (instr & 0xfe00) {
			case 0x0000: // nop
				break;
			case 0x0800: // add
				accu += val;
				break;
			case 0x0c00: // sub
				accu -= val;
				break;
			case 0x1000: // shr
				accu >>>= 1;
				break;
			case 0x2000: // load
				accu = val;
				break;
			case 0x2200: // and
				accu &= val;
				break;
			case 0x2400: // or
				accu |= val;
				break;
			case 0x2600: // xor
				accu ^= val;
				break;
			case 0x2800: // loadh
				accu = (accu & 0xff) + (val << 8);
				break;
			case 0x3000: // store
				dm[instr & 0x00ff] = (char) accu;
				break;
			case 0x3800: // out
				io.write(instr & 0xff, accu);
				break;
			case 0x3c00: // in
				accu = io.read(instr & 0xff);
				break;
			case 0x4000: // jal
				dm[instr & 0xff] = (char) (pc+1);
				next_pc = accu_dly;
				break;
			case 0x5000: // loadaddr
				// nop, as it is only available one cycle later
				break;
			case 0x6000: // load indirect
				accu = dm[ar + (instr & 0xff)];
				break;
			case 0x7000: // store indirect
				dm[ar + (instr & 0xff)] = (char) accu;
				break;
			// case 7: // I/O (ld/st indirect)
			// break;
			// case 8: // brl
			// break;
			// case 9: // br conditional
			// break;
			default:
				// branches use the immediate bit for decode
				// TODO: we could change the encoding so it
				// does not 'consume' the immediate bit - would
				// this be simpler (and lead to less HW?)
				switch (instr & 0xff00) {
				case 0x4800: // branch
					// at the moment just 8 bits offset (sign extension)
					next_pc = pc + ((instr << 24) >> 24);
					break;
				case 0x4900: // brz
					if (accu_dly == 0) {
						// at the moment just 8 bits offset (sign extension)
						next_pc = pc + ((instr << 24) >> 24);
					}
					break;
				case 0x4a00: // brnz
					if (accu_dly != 0) {
						// at the moment just 8 bits offset (sign extension)
						next_pc = pc + ((instr << 24) >> 24);
					}
					break;
				case 0x4b00: // brp
					if ((accu_dly & 0x8000) == 0) {
						// at the moment just 8 bits offset (sign extension)
						next_pc = pc + ((instr << 24) >> 24);
					}
					break;
				case 0x4c00: // brn
					if ((accu_dly & 0x8000) != 0) {
						// at the moment just 8 bits offset (sign extension)
						next_pc = pc + ((instr << 24) >> 24);
					}
					break;

				default:
					throw new Error("Instruction " + instr + " at address " + pc
							+ " not implemented");
				}
			}
	    

			// keep it in 16 bit
			accu &= 0xffff;
			// the address register is only available for one
			// cycle later
			ar = dm[instr & 0xff];

			if (log) {
				System.out.print("PC: " + pc + " accu: " + accu + " "
						+ accu_dly + " ar: " + ar + " Mem: ");
				for (int i = 0; i < 16; ++i) {
					System.out.print(((int) dm[i]) + " ");
				}
				System.out.println();
			}
			pc = next_pc;

		}
		

	}

	/**
	 * @param args
	 */
	public static void main(String[] args) {

		if (args.length < 1) {
			System.out.println("usage: java LerosSim [-s srcDir] [-qio] filename");
			System.exit(-1);
		}
		LerosSim ls = new LerosSim(new LerosIO(), args);
		ls.simulate();
	}

}