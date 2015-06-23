////////////////////////////////////////////////////////////////
//
// guiDCRGroup.java
//
// Copyright (C) 2010 Nathan Yawn 
//                    (nyawn@opencores.org)
//
// This class holds the GUI elements related to the DCR registers
// (the main watchpoint control registers) in the watchpoint
//  unit.
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

import org.eclipse.swt.SWT;
import org.eclipse.swt.graphics.Color;
import org.eclipse.swt.graphics.Device;
import org.eclipse.swt.graphics.GC;
import org.eclipse.swt.graphics.Image;
import org.eclipse.swt.layout.GridLayout;
import org.eclipse.swt.widgets.Button;
import org.eclipse.swt.widgets.Combo;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Group;
import org.eclipse.swt.widgets.Label;
import org.eclipse.swt.widgets.Text;


public class guiDCRGroup implements RegisterObserver {

	public Group dcrRegsGroup = null;
	private Group dcrGroup[]  = {null, null, null, null, null, null, null, null};
	private Button dcrBPCheckbox[]  = {null, null, null, null, null, null, null, null};
	private Label dcrBPcbLabel[]  = {null, null, null, null, null, null, null, null};
	// The Spinner only uses a signed int as its max, so we use a Text element instead
	private Text dvrValText[]  = {null, null, null, null, null, null, null, null};
	private Button dcrSignedCheckBox[]  = {null, null, null, null, null, null, null, null};
	private Label dcrSignedCheckboxLabel[]  = {null, null, null, null, null, null, null, null};
	private Combo dcrCmpSource[]  = {null, null, null, null, null, null, null, null};
	private Combo dcrCmpType[]  = {null, null, null, null, null, null, null, null};
	private Combo dcrChainCombo[]  = {null, null, null, null, null, null, null, null};
	private Combo dcrCountLinkCombo[]  = {null, null, null, null, null, null, null, null};
	private Label dcrBPActiveLabel[]  = {null, null, null, null, null, null, null, null};
	private registerInterpreter regSet = null;
	private Image activeImage = null;
	private Image inactiveImage = null;
	
	public guiDCRGroup(Composite parent, Device display, mainControl mCtrl) {
		
		// Wrap the register set with an interpreter that knows the bit meanings
		regSet = new registerInterpreter(mCtrl.getRegSet());
		
		// Register with main control for register set updates
		mCtrl.registerForRegsetUpdates(this);
		
		// Create images for active interrupt indicators
		activeImage = new Image (display, 16, 16);
		Color color = display.getSystemColor (SWT.COLOR_RED);
		GC gc = new GC (activeImage);
		gc.setBackground (color);
		gc.fillRectangle (activeImage.getBounds ());
		gc.dispose ();

		inactiveImage = new Image (display, 16, 16);
		color = display.getSystemColor (SWT.COLOR_DARK_GRAY);
		gc = new GC (inactiveImage);
		gc.setBackground (color);
		gc.fillRectangle (inactiveImage.getBounds ());
		gc.dispose ();
		
		// Create Watchpoint GUI elements
		dcrRegsGroup = new Group(parent, SWT.NONE);
		dcrRegsGroup.setText("Watchpoints");
		
		GridLayout gridLayout = new GridLayout();
		gridLayout.numColumns = 1;
		dcrRegsGroup.setLayout(gridLayout);
			 
		for (int i = 7; i >= 0; i--) {
			createDcrGroup(i);
		}
	}
	
	private void createDcrGroup(int groupnum) {
		GridLayout gridLayout = new GridLayout();
		gridLayout.numColumns = 10;
		dcrGroup[groupnum] = new Group(dcrRegsGroup, SWT.NONE);
		dcrGroup[groupnum].setLayout(gridLayout);
		String dcrLabel = "Watchpoint " + groupnum + ": ";
		dcrGroup[groupnum].setText(dcrLabel);
		
		dcrBPActiveLabel[groupnum] = new Label(dcrGroup[groupnum], SWT.NONE);
		dcrBPActiveLabel[groupnum].setImage(inactiveImage);
		dcrBPCheckbox[groupnum] = new Button(dcrGroup[groupnum], SWT.CHECK);
		dcrBPcbLabel[groupnum] = new Label(dcrGroup[groupnum], SWT.NONE);
		dcrBPcbLabel[groupnum].setText("Break on");
		createDcrCmpSource(groupnum);
		createDcrCmpType(groupnum);
		dvrValText[groupnum] = new Text(dcrGroup[groupnum], SWT.BORDER);
		dvrValText[groupnum].setTextLimit(10);
		dcrSignedCheckBox[groupnum] = new Button(dcrGroup[groupnum], SWT.CHECK);
		dcrSignedCheckboxLabel[groupnum] = new Label(dcrGroup[groupnum], SWT.NONE);
		dcrSignedCheckboxLabel[groupnum].setText("Signed");	
		createDcrChainCombo(groupnum); 
		createDcrCountLinkCombo(groupnum);
	}

	/**
	 * This method initializes dcrCmpSource	
	 *
	 */
	private void createDcrCmpSource(int groupnum) {
		dcrCmpSource[groupnum] = new Combo(dcrGroup[groupnum], SWT.DROP_DOWN|SWT.READ_ONLY);
		dcrCmpSource[groupnum].add("Disabled", 0);
		dcrCmpSource[groupnum].add("Instruction Fetch Addr", 1);
		dcrCmpSource[groupnum].add("Load Addr", 2);
		dcrCmpSource[groupnum].add("Store Addr", 3);
		dcrCmpSource[groupnum].add("Load Data Value", 4);
		dcrCmpSource[groupnum].add("Store Data Value", 5);
		dcrCmpSource[groupnum].add("Load or Store Addr", 6);
		dcrCmpSource[groupnum].add("Load or Store Data", 7);
		dcrCmpSource[groupnum].select(0);
	}

	/**
	 * This method initializes drcCmpType	
	 *
	 */
	private void createDcrCmpType(int groupnum) {
		dcrCmpType[groupnum] = new Combo(dcrGroup[groupnum], SWT.DROP_DOWN|SWT.READ_ONLY);
		dcrCmpType[groupnum].add("(disabled)", 0);
		dcrCmpType[groupnum].add("==", 1);
		dcrCmpType[groupnum].add("<", 2);
		dcrCmpType[groupnum].add("<=", 3);
		dcrCmpType[groupnum].add(">", 4);
		dcrCmpType[groupnum].add(">=", 5);
		dcrCmpType[groupnum].add("!=", 6);
		dcrCmpType[groupnum].select(0);
	}

	private void createDcrChainCombo(int groupnum) {
		dcrChainCombo[groupnum] = new Combo(dcrGroup[groupnum], SWT.DROP_DOWN|SWT.READ_ONLY);
		dcrChainCombo[groupnum].add("No chain", 0);
		String andStr;
		if(groupnum == 0) {
			andStr = "AND EXT";
		} else {
			andStr = "AND WP" + (groupnum-1);
		}
		dcrChainCombo[groupnum].add(andStr, 1);
		String orStr;
		if(groupnum == 0) {
			orStr = "OR EXT";
		} else {
			orStr = "OR WP" + (groupnum-1);
		}
		dcrChainCombo[groupnum].add(orStr, 2);
		dcrChainCombo[groupnum].select(0);
	}
	
	private void createDcrCountLinkCombo(int groupnum) {
		dcrCountLinkCombo[groupnum] = new Combo(dcrGroup[groupnum], SWT.DROP_DOWN|SWT.READ_ONLY);
		dcrCountLinkCombo[groupnum].add("counter 0", 0);
		dcrCountLinkCombo[groupnum].add("counter 1", 1);
		dcrCountLinkCombo[groupnum].select(0);		
	}
	
	
	public void notifyRegisterUpdate(updateDirection dir) throws NumberFormatException {
		
		if(dir == RegisterObserver.updateDirection.REGS_TO_GUI) {
			// We do this in descending order so that absent DCR/DVR pairs can
			// correctly disable the chain on the previous 
			for(int i = 7; i >= 0; i--) {
				// Go left-to-right, updating UI elements

				// If this DCR/DVR isn't implemented, disable all controls for this WP
				if(!regSet.isWPImplemented(i)) {  // disable everything
					dcrBPActiveLabel[i].setImage(inactiveImage);
					dcrBPcbLabel[i].setText("Not Implemented");
					// TODO *** Resize so the entire "Not Implemented" text is visible
					dcrBPCheckbox[i].setVisible(false);
					dcrCmpSource[i].setVisible(false);
					dcrCmpType[i].setVisible(false);
					dvrValText[i].setVisible(false);
					dcrSignedCheckBox[i].setVisible(false);
					dcrChainCombo[i].setVisible(false);
					if(i < 7) { 			// Disable the next chain type too
						dcrChainCombo[i+1].setVisible(false);
					}
					dcrCountLinkCombo[i].setVisible(false);
					dcrSignedCheckboxLabel[i].setVisible(false);
					continue;
				} else {  // enable everything
					dcrBPcbLabel[i].setText("Break on");
					dcrBPCheckbox[i].setVisible(true);
					dcrCmpSource[i].setVisible(true);
					dcrCmpType[i].setVisible(true);
					dvrValText[i].setVisible(true);
					dcrSignedCheckBox[i].setVisible(true);
					dcrChainCombo[i].setVisible(true);
					dcrCountLinkCombo[i].setVisible(true);
					dcrSignedCheckboxLabel[i].setVisible(true);				
				}


				// 'caused break' indicator
				if(regSet.didWPCauseBreak(i)) {
					dcrBPActiveLabel[i].setImage(activeImage);
				} else {
					dcrBPActiveLabel[i].setImage(inactiveImage);
				}

				// 'break enabled' indicator
				if(regSet.getWPBreakEnabled(i)) {
					dcrBPCheckbox[i].setSelection(true);
				} else {
					dcrBPCheckbox[i].setSelection(false);
				}

				// compare source
				switch(regSet.getWPCompareSource(i)) {
				case DISABLED:
					dcrCmpSource[i].select(0);
					break;
				case INSTR_FETCH_ADDR:
					dcrCmpSource[i].select(1);
					break; 
				case LOAD_ADDR:
					dcrCmpSource[i].select(2);
					break; 
				case STORE_ADDR:
					dcrCmpSource[i].select(3);
					break; 
				case LOAD_DATA:
					dcrCmpSource[i].select(4);
					break; 
				case STORE_DATA:
					dcrCmpSource[i].select(5);
					break;
				case LOAD_STORE_ADDR:
					dcrCmpSource[i].select(6);
					break; 
				case LOAD_STORE_DATA:
					dcrCmpSource[i].select(7);
					break;
				}

				// compare type
				switch(regSet.getWPCompareType(i)) {
				case MASKED:
					dcrCmpType[i].select(0);
					break;
				case EQ:
					dcrCmpType[i].select(1);
					break; 
				case LT:
					dcrCmpType[i].select(2);
					break; 
				case LE:
					dcrCmpType[i].select(3);
					break; 
				case GT:
					dcrCmpType[i].select(4);
					break; 
				case GE:
					dcrCmpType[i].select(5);
					break;
				case NE:
					dcrCmpType[i].select(6);
					break; 
				}

				// compare value
				dvrValText[i].setText("0x" + Long.toHexString(regSet.getDVR(i)));

				// signed indicator
				if(regSet.getWPSignedCompare(i)) {
					dcrSignedCheckBox[i].setSelection(true);
				} else {
					dcrSignedCheckBox[i].setSelection(false);
				}

				// chain type
				switch(regSet.getWPChainType(i)) {
				case NONE:
					dcrChainCombo[i].select(0);
					break;
				case AND:
					dcrChainCombo[i].select(1);
					break; 
				case OR:
					dcrChainCombo[i].select(2);
					break; 
				}

				// counter assignment
				if(regSet.getWPCounterAssign(i) == 0) {
					dcrCountLinkCombo[i].select(0);
				} else {
					dcrCountLinkCombo[i].select(1);
				}
			}  // for each DCR
		}
		else {  // dir == GUI_TO_REGS
	
			for(int i = 0; i < 8; i++) {

				// Don't bother to set values for un-implemented DVR/DCR pairs.
				if(!regSet.isWPImplemented(i)) {
					continue;
				}

				// Go left-to-right, putting value into the regSet
				// Break enabled
				regSet.setWPBreakEnabled(i, dcrBPCheckbox[i].getSelection());

				// Compare Source
				switch(dcrCmpSource[i].getSelectionIndex()) {
				case 0:
					regSet.setWPCompareSource(i, registerInterpreter.compareSource.DISABLED);
					break;
				case 1:
					regSet.setWPCompareSource(i, registerInterpreter.compareSource.INSTR_FETCH_ADDR);
					break;
				case 2:
					regSet.setWPCompareSource(i, registerInterpreter.compareSource.LOAD_ADDR);
					break;
				case  3:
					regSet.setWPCompareSource(i, registerInterpreter.compareSource.STORE_ADDR);
					break;
				case  4:
					regSet.setWPCompareSource(i, registerInterpreter.compareSource.LOAD_DATA);
					break;
				case  5:
					regSet.setWPCompareSource(i, registerInterpreter.compareSource.STORE_DATA);
					break;
				case  6:
					regSet.setWPCompareSource(i, registerInterpreter.compareSource.LOAD_STORE_ADDR);
					break;
				case  7:
					regSet.setWPCompareSource(i, registerInterpreter.compareSource.LOAD_STORE_DATA);
					break;
				}

				// Compare Type
				switch(dcrCmpType[i].getSelectionIndex()) {
				case 0:
					regSet.setWPCompareType(i, registerInterpreter.compareType.MASKED);
					break;
				case 1:
					regSet.setWPCompareType(i, registerInterpreter.compareType.EQ);
					break;
				case 2:
					regSet.setWPCompareType(i, registerInterpreter.compareType.LT);
					break;
				case  3:
					regSet.setWPCompareType(i, registerInterpreter.compareType.LE);
					break;
				case  4:
					regSet.setWPCompareType(i, registerInterpreter.compareType.GT);
					break;
				case  5:
					regSet.setWPCompareType(i, registerInterpreter.compareType.GE);
					break;
				case  6:
					regSet.setWPCompareType(i, registerInterpreter.compareType.NE);
					break;
				}

				// Compare Value
				//try {
					long cval;
					String str = dvrValText[i].getText();
					if(str.startsWith("0x") || str.startsWith("0X")) {
						cval = Long.parseLong(str.substring(2), 16);  // substr(2) skips the "0x"
					}
					else {
						cval = Long.parseLong(str); 
					}

					regSet.setDVR(i, cval);

				//} catch(NumberFormatException e) {
				//	return false;
				//}


				// Signed indicator
				regSet.setWPSignedCompare(i, dcrSignedCheckBox[i].getSelection());

				// Chain type
				switch(dcrChainCombo[i].getSelectionIndex()) {
				case 0:
					regSet.setWPChainType(i, registerInterpreter.chainType.NONE);
					break;
				case 1:
					regSet.setWPChainType(i, registerInterpreter.chainType.AND);
					break;
				case 2:
					regSet.setWPChainType(i, registerInterpreter.chainType.OR);
					break;
				}

				// Counter assignment
				if(dcrCountLinkCombo[i].getSelectionIndex() == 0) {
					regSet.setWPCounterAssign(i, 0);
				} else {
					regSet.setWPCounterAssign(i, 1);	
				}
			}
		}  // else dir == GUI_TO_REGS
	}  // notifyRegisterUpdate()
	
}
