////////////////////////////////////////////////////////////////
//
// guiCountRegsGroup.java
//
// Copyright (C) 2010 Nathan Yawn 
//                    (nyawn@opencores.org)
//
// This class holds the GUI elements related to the hardware
// counters in the watchpoint unit.
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
import org.eclipse.swt.layout.GridData;
import org.eclipse.swt.layout.GridLayout;
import org.eclipse.swt.widgets.Button;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Group;
import org.eclipse.swt.widgets.Label;
import org.eclipse.swt.widgets.Spinner;
import org.eclipse.swt.widgets.Combo;


public class guiCountRegsGroup implements RegisterObserver {

	private Combo count1ChainCombo;
	private Group countRegGroup = null;
	private Group count1Composite;
	private Button count1EnableCheckBox;
	private Label count1EnableLabel;
	private Button count1BPCheckBox;
	private Label count1EnableBPLabel;
	private Group count2Composite;
	private Button count2EnableCheckBox;
	private Label count2EnableLabel;
	private Button count2BPCheckBox;
	private Label count2EnableBPLabel;
	private Spinner matchValueEnteredSpinner;
	private Group matchValueActualGroup;
	private Spinner matchValueActualSpinner;
	private Combo count2ChainCombo;
	private Group matchValueEnteredGroup2;
	private Spinner matchValueEnteredSpinner2;
	private Group matchValueActualGroup2;
	private Spinner match2ValueActualSpinner;
	private registerInterpreter regSet = null;
	private Image activeImage = null;
	private Image inactiveImage = null;
	private Label count1BPActiveLabel = null;
	private Label count2BPActiveLabel = null;
	private Combo ctrCountLinkCombo[]  = {null, null};
	
	public guiCountRegsGroup(Composite parent, Device display, mainControl mCtrl) {
		
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
		
		// Create the Count registers GUI elements
		countRegGroup = new Group(parent, SWT.NONE);
		countRegGroup.setLayout(new GridLayout());
		createCount1Composite();
		createCount2Composite();
		countRegGroup.setText("Counters");
		
		// Register with main control for register set updates
		mCtrl.registerForRegsetUpdates(this);
		
		// Wrap the register set with an interpreter that knows the bit meanings
		regSet = new registerInterpreter(mCtrl.getRegSet());
	}

	private void createCount1Composite() {
		GridData gridData4 = new GridData();
		gridData4.horizontalAlignment = SWT.FILL;
		gridData4.grabExcessHorizontalSpace = true;
		
		GridLayout gridLayout1 = new GridLayout();
		gridLayout1.numColumns = 7;
		count1Composite = new Group(countRegGroup, SWT.NONE);
		count1Composite.setText("Count 0");

		count1BPActiveLabel = new Label(count1Composite, SWT.NONE);
		count1BPActiveLabel.setImage(inactiveImage);
		GridData gd = new GridData();
		gd.verticalSpan = 2;
		count1BPActiveLabel.setLayoutData(gd);
		
		count1EnableCheckBox = new Button(count1Composite, SWT.CHECK);
		count1EnableLabel = new Label(count1Composite, SWT.NONE);
		count1EnableLabel.setText("Enable");

		createMatchValue1EnteredGroup();
		createMatchValue1ActualGroup();
		createCount1ChainCombo();
		createCtr1CountLinkCombo();
		
		count1BPCheckBox = new Button(count1Composite, SWT.CHECK);
		count1EnableBPLabel = new Label(count1Composite, SWT.NONE);
		count1EnableBPLabel.setText("Break on Match");
		count1Composite.setLayout(gridLayout1);
		count1Composite.setLayoutData(gridData4);
	}
	
	private void createCount2Composite() {
		GridData gridData5 = new GridData();
		gridData5.horizontalAlignment = SWT.FILL;
		gridData5.grabExcessHorizontalSpace = true;
		
		GridLayout gridLayout1 = new GridLayout();
		gridLayout1.numColumns = 7;
		count2Composite = new Group(countRegGroup, SWT.NONE);
		count2Composite.setText("Count 1");

		count2BPActiveLabel = new Label(count2Composite, SWT.NONE);
		count2BPActiveLabel.setImage(inactiveImage);
		GridData gd = new GridData();
		gd.verticalSpan = 2;
		count2BPActiveLabel.setLayoutData(gd);
		
		count2EnableCheckBox = new Button(count2Composite, SWT.CHECK);
		count2EnableLabel = new Label(count2Composite, SWT.NONE);
		count2EnableLabel.setText("Enable");

		createMatchValue2EnteredGroup();
		createMatchValue2ActualGroup();
		createCount2ChainCombo();
		createCtr2CountLinkCombo();
		
		count2BPCheckBox = new Button(count2Composite, SWT.CHECK);
		count2EnableBPLabel = new Label(count2Composite, SWT.NONE);
		count2EnableBPLabel.setText("Break on Match");
		count2Composite.setLayout(gridLayout1);
		count2Composite.setLayoutData(gridData5);
	}

	private void createMatchValue1EnteredGroup() {
		GridData gridData = new GridData();
		gridData.verticalSpan = 2;
		gridData.verticalAlignment = GridData.CENTER;
		gridData.horizontalAlignment = GridData.CENTER;
		Group matchValueEnteredGroup = new Group(count1Composite, SWT.NONE);
		matchValueEnteredGroup.setLayout(new GridLayout());
		matchValueEnteredGroup.setLayoutData(gridData);
		matchValueEnteredGroup.setText("Match Value");
		matchValueEnteredSpinner = new Spinner(matchValueEnteredGroup, SWT.BORDER);
		matchValueEnteredSpinner.setValues(0, 0, 0xFFFF, 0, 1, 100);
	}

	/**
	 * This method initializes matchValue1ActualGroup
	 *
	 */
	private void createMatchValue1ActualGroup() {
		GridData gridData2 = new GridData();
		gridData2.horizontalAlignment = GridData.CENTER;
		gridData2.verticalAlignment = GridData.CENTER;
		GridData gridData1 = new GridData();
		gridData1.verticalSpan = 2;
		matchValueActualGroup = new Group(count1Composite, SWT.NONE);
		matchValueActualGroup.setLayout(new GridLayout());
		matchValueActualGroup.setLayoutData(gridData1);
		matchValueActualGroup.setText("Current Count Value");
		matchValueActualSpinner = new Spinner(matchValueActualGroup, SWT.NONE);
		matchValueActualSpinner.setValues(0, 0, 0xFFFF, 0, 1, 100);
		matchValueActualSpinner.setLayoutData(gridData2);
	}
	
	private void createCount1ChainCombo() {
		GridData gridData = new GridData();
		gridData.verticalSpan = 2;
		count1ChainCombo = new Combo(count1Composite, SWT.DROP_DOWN|SWT.READ_ONLY);
		count1ChainCombo.setLayoutData(gridData);
		count1ChainCombo.add("No chain", 0);
		count1ChainCombo.add("AND WP3", 1);
		count1ChainCombo.add("OR WP3", 2);
		count1ChainCombo.select(0);
	}
	
	private void createMatchValue2EnteredGroup() {
		GridData gridData = new GridData();
		gridData.verticalSpan = 2;
		gridData.verticalAlignment = GridData.CENTER;
		gridData.horizontalAlignment = GridData.CENTER;
		matchValueEnteredGroup2 = new Group(count2Composite, SWT.NONE);
		matchValueEnteredGroup2.setLayout(new GridLayout());
		matchValueEnteredGroup2.setLayoutData(gridData);
		matchValueEnteredGroup2.setText("Match Value");
		matchValueEnteredSpinner2 = new Spinner(matchValueEnteredGroup2, SWT.BORDER);
		matchValueEnteredSpinner2.setValues(0, 0, 0xFFFF, 0, 1, 100);
	}
	
	private void createMatchValue2ActualGroup() {
		GridData gridData2 = new GridData();
		gridData2.horizontalAlignment = GridData.CENTER;
		gridData2.verticalSpan = 2;
		gridData2.verticalAlignment = GridData.CENTER;
		GridData gridData1 = new GridData();
		gridData1.verticalSpan = 2;
		matchValueActualGroup2 = new Group(count2Composite, SWT.NONE);
		matchValueActualGroup2.setLayout(new GridLayout());
		matchValueActualGroup2.setLayoutData(gridData2);
		matchValueActualGroup2.setText("Current Count Value");
		match2ValueActualSpinner = new Spinner(matchValueActualGroup2, SWT.NONE);
		match2ValueActualSpinner.setValues(0, 0, 0xFFFF, 0, 1, 100);
	}
	
	private void createCount2ChainCombo() {
		GridData gridData = new GridData();
		gridData.verticalSpan = 2;
		count2ChainCombo = new Combo(count2Composite, SWT.DROP_DOWN|SWT.READ_ONLY);
		count2ChainCombo.setLayoutData(gridData);
		count2ChainCombo.add("No chain", 0);
		count2ChainCombo.add("AND WP7", 1);
		count2ChainCombo.add("OR WP7", 2);
		count2ChainCombo.select(0);
	}
	
	private void createCtr1CountLinkCombo() {
		GridData gridData = new GridData();
		gridData.verticalSpan = 2;
		ctrCountLinkCombo[0] = new Combo(count1Composite, SWT.DROP_DOWN|SWT.READ_ONLY);
		ctrCountLinkCombo[0].setLayoutData(gridData);
		ctrCountLinkCombo[0].add("counter 0", 0);
		ctrCountLinkCombo[0].add("counter 1", 1);
		ctrCountLinkCombo[0].select(0);		
	}

	private void createCtr2CountLinkCombo() {
		GridData gridData = new GridData();
		gridData.verticalSpan = 2;
		ctrCountLinkCombo[1] = new Combo(count2Composite, SWT.DROP_DOWN|SWT.READ_ONLY);
		ctrCountLinkCombo[1].setLayoutData(gridData);
		ctrCountLinkCombo[1].add("counter 0", 0);
		ctrCountLinkCombo[1].add("counter 1", 1);
		ctrCountLinkCombo[1].select(0);		
	}
	
	public void notifyRegisterUpdate(updateDirection dir) throws NumberFormatException {
		
		if(dir == RegisterObserver.updateDirection.REGS_TO_GUI) {
			// Set GUI elements based on values in regSet
			// Counter 0  -- go left-to-right
			// 'caused break' indicator
			if(regSet.didCounterCauseBreak(0)) {
				count1BPActiveLabel.setImage(activeImage);
			} else {
				count1BPActiveLabel.setImage(inactiveImage);
			}

			// 'enabled' checkbox
			if(regSet.getCounterEnabled(0)) {
				count1EnableCheckBox.setSelection(true);
			} else {
				count1EnableCheckBox.setSelection(false);
			}

			// 'break on match' checkbox
			if(regSet.getCounterBreakEnabled(0)) {
				count1BPCheckBox.setSelection(true);
			} else {
				count1BPCheckBox.setSelection(false);
			}

			// Match value
			matchValueEnteredSpinner.setSelection(regSet.getCounterWatchValue(0));

			// Count value
			matchValueActualSpinner.setSelection(regSet.getCounterCountValue(0));

			// Chain type
			switch(regSet.getCounterChainType(0)) {
			case NONE:
				count1ChainCombo.select(0);
				break;
			case AND:
				count1ChainCombo.select(1);
				break; 
			case OR:
				count1ChainCombo.select(2);
				break; 
			}

			// counter assignment
			if(regSet.getWPCounterAssign(8) == 0) {
				ctrCountLinkCombo[0].select(0);
			} else {
				ctrCountLinkCombo[0].select(1);
			}

			// Counter 1
			// 'caused break' indicator
			if(regSet.didCounterCauseBreak(1)) {
				count2BPActiveLabel.setImage(activeImage);
			} else {
				count2BPActiveLabel.setImage(inactiveImage);
			}

			// 'enabled' checkbox
			if(regSet.getCounterEnabled(1)) {
				count2EnableCheckBox.setSelection(true);
			} else {
				count2EnableCheckBox.setSelection(false);
			}

			// 'break on match' checkbox
			if(regSet.getCounterBreakEnabled(1)) {
				count2BPCheckBox.setSelection(true);
			} else {
				count2BPCheckBox.setSelection(false);
			}

			// Match value
			matchValueEnteredSpinner2.setSelection(regSet.getCounterWatchValue(1));

			// Count value
			match2ValueActualSpinner.setSelection(regSet.getCounterCountValue(1));

			// Chain type
			switch(regSet.getCounterChainType(1)) {
			case NONE:
				count2ChainCombo.select(0);
				break;
			case AND:
				count2ChainCombo.select(1);
				break; 
			case OR:
				count2ChainCombo.select(2);
				break; 
			}

			// counter assignment
			if(regSet.getWPCounterAssign(9) == 0) {
				ctrCountLinkCombo[1].select(0);
			} else {
				ctrCountLinkCombo[1].select(1);
			}
		}
		else { // direction = GUI_TO_REGS
			// Set values in regSet based on GUI elements
			// Counter 0  -- go left-to-right
			// 'enabled' checkbox
			regSet.setCounterEnabled(0, count1EnableCheckBox.getSelection());

			// 'break on match' checkbox
			regSet.setCounterBreakEnabled(0, count1BPCheckBox.getSelection());

			// Match value
			regSet.setCounterWatchValue(0, matchValueEnteredSpinner.getSelection());

			// Count value
			regSet.setCounterCountValue(0, matchValueActualSpinner.getSelection());

			// Chain type
			switch(count1ChainCombo.getSelectionIndex()) {
			case 0:
				regSet.setCounterChainType(0, registerInterpreter.chainType.NONE);
				break;
			case 1:
				regSet.setCounterChainType(0, registerInterpreter.chainType.AND);
				break;
			case 2:
				regSet.setCounterChainType(0, registerInterpreter.chainType.OR);
				break;
			}

			// Counter assignment
			if(ctrCountLinkCombo[0].getSelectionIndex() == 0) {
				regSet.setWPCounterAssign(8, 0);
			} else {
				regSet.setWPCounterAssign(8, 1);	
			}

			// Counter 1
			// 'enabled' checkbox
			regSet.setCounterEnabled(1, count2EnableCheckBox.getSelection());

			// 'break on match' checkbox
			regSet.setCounterBreakEnabled(1, count2BPCheckBox.getSelection());

			// Match value
			regSet.setCounterWatchValue(1, matchValueEnteredSpinner2.getSelection());

			// Count value
			regSet.setCounterCountValue(1, match2ValueActualSpinner.getSelection());

			// Chain type
			switch(count2ChainCombo.getSelectionIndex()) {
			case 0:
				regSet.setCounterChainType(1, registerInterpreter.chainType.NONE);
				break;
			case 1:
				regSet.setCounterChainType(1, registerInterpreter.chainType.AND);
				break;
			case 2:
				regSet.setCounterChainType(1, registerInterpreter.chainType.OR);
				break;
			}

			// Counter assignment
			if(ctrCountLinkCombo[1].getSelectionIndex() == 0) {
				regSet.setWPCounterAssign(9, 0);
			} else {
				regSet.setWPCounterAssign(9, 1);	
			}
		}  // else dir == GUI_TO_REGS
	}  // notifyRegisterUpdate()
	
}
