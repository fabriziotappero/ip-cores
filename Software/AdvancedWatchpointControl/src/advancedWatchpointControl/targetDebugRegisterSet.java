////////////////////////////////////////////////////////////////
//
// targetDebugRegisterSet.java
//
// Copyright (C) 2010 Nathan Yawn 
//                    (nyawn@opencores.org)
//
// This class holds a direct, cached copy of the debug registers 
// on the OR1000 target CPU.  It relies on other classes to
// interpret the meanings of the values.
//
////////////////////////////////////////////////////////////////
//
// This source file may be used and distributed without
// restriction provided that this copyright statement is not
// removed from the file and that any derivative work contains
// the original copyright notice and the associated disclaimer.
// 
// This source file is free software; you can redistribute it
// and/or modify it under the terms of the GNU General
// Public License as published by the Free Software Foundation;
// either version 3.0 of the License, or (at your option) any
// later version.
//
// This source is distributed in the hope that it will be
// useful, but WITHOUT ANY WARRANTY; without even the implied 
// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
// PURPOSE.  See the GNU Lesser General Public License for more
// details.
// 
// You should have received a copy of the GNU General
// Public License along with this source; if not, download it 
// from http://www.gnu.org/licenses/gpl.html
//
////////////////////////////////////////////////////////////////
package advancedWatchpointControl;

public class targetDebugRegisterSet {

	public enum regType { DCR0, DVR0, DCR1, DVR1, DCR2, DVR2, DCR3, DVR3, 
		DCR4, DVR4, DCR5, DVR5, DCR6, DVR6, DCR7, DVR7, DMR1, DMR2, DWCR0, DWCR1 }
	
	// These reflect the values of the registers on the target
	// They must be 'long's, because they're unsigned ints.
	private long dcr[] = { 1, 1, 0, 0, 1, 1, 1, 1 };
	private long dvr[] = { 0, 0, 0, 0, 0, 0, 0, 0 };
	private long dmr1 = 0;
	private long dmr2 = 0;
	private long dwcr0 = 0;
	private long dwcr1 = 0;
	
	
	public void setDCR(int which, long val) {
		dcr[which] = val;
	}
	
	public long getDCR(int which) {
		return dcr[which];
	}
	
	public void setDVR(int which, long val) {
		dvr[which] = val;
	}
	
	public long getDVR(int which) {
		return dvr[which];
	}
	
	public void setDMR1(long val) {
		dmr1 = val;
	}
	
	public long getDMR1() {
		return dmr1;
	}
	
	public void setDMR2(long val) {
		dmr2 = val;
	}
	
	public long getDMR2() {
		return dmr2;
	}
	
	public void setDWCR0(long val) {
		dwcr0 = val;
	}
	
	public long getDWCR0() {
		return dwcr0;
	}
	
	public void setDWCR1(long val) {
		dwcr1 = val;
	}
	
	public long getDWCR1() {
		return dwcr1;
	}

	public static int getRegisterAddress(regType reg) {
		int retval = 0;
		int dgroup = 6 << 11;  // DEBUG group is 6, 11 bits is the group offset
		
		switch(reg) {
		case DCR0:
			retval = dgroup | 8;
			break;
		case DVR0:
			retval = dgroup | 0;
			break;
		case DCR1:
			retval = dgroup | 9;
			break;
		case DVR1:
			retval = dgroup | 1;
			break;
		case DCR2:
			retval = dgroup | 10;
			break;
		case DVR2:
			retval = dgroup | 2;
			break;
		case DCR3:
			retval = dgroup | 11;
			break;
		case DVR3:
			retval = dgroup | 3;
			break;
		case DCR4:
			retval = dgroup | 12;
			break;
		case DVR4:
			retval = dgroup | 4;
			break;
		case DCR5:
			retval = dgroup | 13;
			break;
		case DVR5:
			retval = dgroup | 5;
			break;
		case DCR6:
			retval = dgroup | 14;
			break;
		case DVR6:
			retval = dgroup | 6;
			break;
		case DCR7:
			retval = dgroup | 15;
			break;
		case DVR7:
			retval = dgroup | 7;
			break;
		case DMR1:
			retval = dgroup | 16;
			break;
		case DMR2:
			retval = dgroup | 17;
			break;
		case DWCR0:
			retval = dgroup | 18;
			break; 
		case DWCR1:
			retval = dgroup | 19;
			break;
		default:
			break;  // Register address 0 is the version register...read-only and harmless.
		}
	
		return retval;
	}
	
}
