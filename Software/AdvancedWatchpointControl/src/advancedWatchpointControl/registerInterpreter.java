////////////////////////////////////////////////////////////////
//
// registerInterpreter.java
//
// Copyright (C) 2010 Nathan Yawn 
//                    (nyawn@opencores.org)
//
// This class wraps the basic register set cache.  It adds
// convenience methods so that the UI classes do not need to
// interpret the various bit meanings in the registers.
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


public class registerInterpreter {

	public enum compareSource  { DISABLED, INSTR_FETCH_ADDR, LOAD_ADDR, STORE_ADDR, LOAD_DATA, STORE_DATA,
		LOAD_STORE_ADDR, LOAD_STORE_DATA }
	public enum compareType  { MASKED, EQ, LT, LE, GT, GE, NE }
	public enum chainType { NONE, AND, OR }
	
	private targetDebugRegisterSet registers;
	
	public registerInterpreter(targetDebugRegisterSet regs) {
		registers = regs;
	}
	
	
	public boolean isWPImplemented(int whichWP) {
		long exists = registers.getDCR(whichWP) & 0x1;
		if(exists != 0) return true;
		else return false;
	}
	
	public boolean getWPBreakEnabled(int whichWP) {
		long enabled = (registers.getDMR2() >> (12+whichWP)) & 0x1;
		if(enabled != 0) return true;
		else return false;
	}

	public void setWPBreakEnabled(int whichWP, boolean enabled) {
		long maskval = 0x1 << (12+whichWP);
		if(enabled) {
			registers.setDMR2(registers.getDMR2() | maskval);
		}
		else {
			registers.setDMR2(registers.getDMR2() & (~maskval));
		}
	}
	
	public compareSource getWPCompareSource(int whichWP) {
		int src = (int)((registers.getDCR(whichWP) >> 5) & 0x7);
		compareSource ret = compareSource.DISABLED;
		switch(src) {
			case 0:
				ret = compareSource.DISABLED;
				break;
			case 1:
				ret = compareSource.INSTR_FETCH_ADDR;
				break;
			case 2:
				ret = compareSource.LOAD_ADDR;
				break;
			case  3:
				ret = compareSource.STORE_ADDR;
				break;
			case  4:
				ret = compareSource.LOAD_DATA;
				break;
			case  5:
				ret = compareSource.STORE_DATA;
				break;
			case  6:
				ret = compareSource.LOAD_STORE_ADDR;
				break;
			case  7:
				ret = compareSource.LOAD_STORE_DATA;
				break;
		}
		return ret;
	}
	
	public void setWPCompareSource(int whichWP, compareSource src) {
		long val = 0;
		switch(src) {
		case DISABLED:
			val = 0;
			break;
		case INSTR_FETCH_ADDR:
			val = 1;
			break; 
		case LOAD_ADDR:
			val = 2;
			break; 
		case STORE_ADDR:
			val = 3;
			break; 
		case LOAD_DATA:
			val = 4;
			break; 
		case STORE_DATA:
			val = 5;
			break;
		case LOAD_STORE_ADDR:
			val = 6;
			break; 
		case LOAD_STORE_DATA:
			val = 7;
			break;
		}
		val = val << 5;
		long mask = 7 << 5;
		long tmp = registers.getDCR(whichWP);
		tmp &= (~mask);
		tmp |= val;
		registers.setDCR(whichWP, tmp);
	}
	
	public compareType getWPCompareType(int whichWP) {
		int src = (int)((registers.getDCR(whichWP) >> 1) & 0x7);
		compareType ret = compareType.MASKED;
		switch(src) {
			case 0:
				ret = compareType.MASKED;
				break;
			case 1:
				ret = compareType.EQ;
				break;
			case 2:
				ret = compareType.LT;
				break;
			case  3:
				ret = compareType.LE;
				break;
			case  4:
				ret = compareType.GT;
				break;
			case  5:
				ret = compareType.GE;
				break;
			case  6:
				ret = compareType.NE;
				break;
		}
		return ret;
	}
	
	public void setWPCompareType(int whichWP, compareType type) {
		long val = 0;
		switch(type) {
		case MASKED:
			val = 0;
			break;
		case EQ:
			val = 1;
			break; 
		case LT:
			val = 2;
			break; 
		case LE:
			val = 3;
			break; 
		case GT:
			val = 4;
			break; 
		case GE:
			val = 5;
			break;
		case NE:
			val = 6;
			break; 

		}
		val = val << 1;
		long mask = 7 << 1;
		long tmp = registers.getDCR(whichWP);
		tmp &= (~mask);
		tmp |= val;
		registers.setDCR(whichWP, tmp);
	}
	
	public boolean getWPSignedCompare(int whichWP) {
		long enabled = registers.getDCR(whichWP) & 0x10;
		if(enabled != 0) return true;
		else return false;
	}

	public void setWPSignedCompare(int whichWP, boolean signed) {
		long maskval = 0x10;
		long tmp = registers.getDCR(whichWP);
		if(signed) tmp |= maskval;
		else tmp &= (~maskval);
		registers.setDCR(whichWP, tmp);
	}
	
	public chainType getWPChainType(int whichWP) {
		int src = (int)((registers.getDMR1() >> (2*whichWP)) & 0x3);
		chainType ret = chainType.NONE;
		switch(src) {
			case 0:
				ret = chainType.NONE;
				break;
			case 1:
				ret = chainType.AND;
				break;
			case 2:
				ret = chainType.OR;
				break;
		}
		return ret;
	}
	
	public void setWPChainType(int whichWP, chainType type) {
		long val = 0;
		switch(type) {
		case NONE:
			val = 0;
			break;
		case AND:
			val = 1;
			break; 
		case OR:
			val = 2;
			break; 
		}
		val = val << (2*whichWP);
		long mask = 3 << (2*whichWP);
		long tmp = registers.getDMR1() & (~mask);
		tmp |= val;
		registers.setDMR1(tmp);
	}
	
	public int getWPCounterAssign(int whichWP) {
		int val = (int)((registers.getDMR2() >> (2 + whichWP)) & 0x1);
		return val;
	}
	
	// Note that for this method, indexes 8 and 9 are valid
	// (they indicate counter 0 and counter 1, respectively).
	public void setWPCounterAssign(int whichWP, int counter) {
		long val = (counter & 0x1) << (2+whichWP);
		long mask = 0x1 << (2+whichWP);
		long tmp = registers.getDMR2();
		tmp &= (~mask);
		tmp |= val;
		registers.setDMR2(tmp);
	}
	
	public boolean didWPCauseBreak(int whichWP) {
		int val = (int)((registers.getDMR2() >> (22+whichWP)) & 0x1);
		if(val == 0) return false;
		else return true;
	}

	public boolean getCounterEnabled(int whichCounter) {
		int enabled = (int)((registers.getDMR2() >> (whichCounter&0x1)) & 0x1);
		if(enabled != 0) return true;
		else return false;
	}


	public void setCounterEnabled(int whichCounter, boolean enabled) {
		long maskval = 0x1 << (whichCounter & 0x1);
		long tmp = registers.getDMR2();
		if(enabled) tmp |= maskval;
		else tmp &= (~maskval);
		registers.setDMR2(tmp);
	}
	

	public boolean getCounterBreakEnabled(int whichCounter) {
		int enabled = (int)((registers.getDMR2() >> (20+whichCounter)) & 0x1);
		if(enabled != 0) return true;
		else return false;
	}


	public void setCounterBreakEnabled(int whichCounter, boolean enabled) {
		long maskval = 0x1 << (20+whichCounter);
		long tmp = registers.getDMR2();
		if(enabled) tmp |= maskval;
		else tmp &= (~maskval);
		registers.setDMR2(tmp);
	}
	
	public boolean didCounterCauseBreak(int whichCounter) {
		int val = (int)((registers.getDMR2() >> (30+whichCounter)) & 0x1);
		if(val == 0) return false;
		else return true;
	}
	
	public int getCounterWatchValue(int whichCounter) {
		int val = 0;
		if(whichCounter == 0) val = (int)((registers.getDWCR0() >> 16) & 0xFFFF);
		else val = (int)((registers.getDWCR1() >> 16) & 0xFFFF);
		return val;
	}
	
	public void setCounterWatchValue(int whichCounter, int value) {
		long val = (value & 0xFFFF) << 16;
		long mask = 0x0000FFFF;
		long tmp;
		if(whichCounter == 0) {
			tmp = registers.getDWCR0();
			tmp &= mask;
			tmp |= val;
			registers.setDWCR0(tmp);
		} else {
			tmp = registers.getDWCR1();
			tmp &= mask;
			tmp |= val;
			registers.setDWCR1(tmp);
		}
	}
	
	public int getCounterCountValue(int whichCounter) {
		int val = 0;
		if(whichCounter == 0) val = (int)(registers.getDWCR0() & 0xFFFF);
		else val = (int)(registers.getDWCR1() & 0xFFFF);
		return val;
	}
	
	public void setCounterCountValue(int whichCounter, int value) {
		long val = value & 0xFFFF;
		long mask = 0xFFFF0000;
		long tmp;
		if(whichCounter == 0) {
			tmp = registers.getDWCR0();
			tmp &= mask;
			tmp |= val;
			registers.setDWCR0(tmp);
		} else {
			tmp = registers.getDWCR1();
			tmp &= mask;
			tmp |= val;
			registers.setDWCR1(tmp);
		}
	}
	
	
	public chainType getCounterChainType(int whichCounter) {
		int src = (int)((registers.getDMR1() >> (16+(2*whichCounter))) & 0x3);
		chainType ret = chainType.NONE;
		switch(src) {
			case 0:
				ret = chainType.NONE;
				break;
			case 1:
				ret = chainType.AND;
				break;
			case 2:
				ret = chainType.OR;
				break;
		}
		return ret;
	}
	
	public void setCounterChainType(int whichCounter, chainType type) {
		long val = 0;
		switch(type) {
		case NONE:
			val = 0;
			break;
		case AND:
			val = 1;
			break; 
		case OR:
			val = 2;
			break; 
		}
		val = val << (16+(2*whichCounter));
		long mask = 3 << (16+(2*whichCounter));
		long tmp = registers.getDMR1();
		tmp &= (~mask);
		tmp |= val;
		registers.setDMR1(tmp);
	}
	
	public void setDVR(int which, long val) {
		registers.setDVR(which, val);
	}
	
	public long getDVR(int which) {
		return registers.getDVR(which);
	}
	
}
