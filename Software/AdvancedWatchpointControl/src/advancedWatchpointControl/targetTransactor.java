////////////////////////////////////////////////////////////////
//
// targetTransactor.java
//
// Copyright (C) 2010 Nathan Yawn 
//                    (nyawn@opencores.org)
//
// This class handles the top-level target transactions.
// Its methods are specific transactions (read register,
// is target running, etc.).  It constructs an appropriate
// transaction object, then gives it to the RSP algorithm
// for processing.
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

import java.io.IOException;

public class targetTransactor {

	rspCoder rsp = null;
	
	public targetTransactor(rspCoder r) {
		rsp = r;
	}
	
	// Succeeds or throws an IOException.
	public void writeRegister(targetDebugRegisterSet.regType reg, long val) throws IOException {
		WriteRegisterTransaction xact = new WriteRegisterTransaction(reg, val);
		rsp.Transact(xact);
	}
	
	// Returns a valid value or throws an IOException.
	public long readRegister(targetDebugRegisterSet.regType reg) throws IOException {
		long ret;
		ReadRegisterTransaction xact = new ReadRegisterTransaction(reg);
		rsp.Transact(xact);
		ret = xact.getDataValueRead();
		return ret;
	}
	
	// Returns a valid boolean indicator or throws an IOException.
	public boolean isTargetRunning() throws IOException {
		boolean ret;
		TargetRunningTransaction xact = new TargetRunningTransaction();
		rsp.Transact(xact);
		ret = xact.getIsTargetRunning();
		return ret;
	}
	
}
