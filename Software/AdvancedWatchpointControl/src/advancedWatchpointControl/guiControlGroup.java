////////////////////////////////////////////////////////////////
//
// guiControlGroup.java
//
// Copyright (C) 2010 Nathan Yawn 
//                    (nyawn@opencores.org)
//
// This class holds the GUI elements for the control group,
// which includes the read and write button, along with the
// message output window.
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

import java.text.SimpleDateFormat;
import org.eclipse.swt.SWT;
import org.eclipse.swt.graphics.FontMetrics;
import org.eclipse.swt.graphics.GC;
import org.eclipse.swt.layout.GridData;
import org.eclipse.swt.layout.GridLayout;
import org.eclipse.swt.widgets.Button;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Group;
import org.eclipse.swt.widgets.Text;

public class guiControlGroup implements LogMessageObserver {

	private Group miscGroup = null;
	private Button applyButton = null;
	private Button rereadButton = null;
	private Group messagesGroup = null;
	private Text notifyMessageLabel = null;
	private mainControl mCtrl = null;

	public guiControlGroup(Composite parent, mainControl mc) {
		mCtrl = mc;
		GridLayout gridLayout2 = new GridLayout();
		gridLayout2.numColumns = 2;
		gridLayout2.horizontalSpacing = 10;
		gridLayout2.makeColumnsEqualWidth = false;
		miscGroup = new Group(parent, SWT.NONE);
		miscGroup.setText("Control");
		applyButton = new Button(miscGroup, SWT.NONE);
		applyButton.setText("Write Registers");
		applyButton.addSelectionListener(new org.eclipse.swt.events.SelectionAdapter() {
			public void widgetSelected(org.eclipse.swt.events.SelectionEvent e) {
				mCtrl.doWriteAllRegisters();
			}
		});
		createMessagesGroup();
		rereadButton = new Button(miscGroup, SWT.NONE);
		rereadButton.setText("Read Registers");
		rereadButton.addSelectionListener(new org.eclipse.swt.events.SelectionAdapter() {
					public void widgetSelected(org.eclipse.swt.events.SelectionEvent e) {
						mCtrl.doReadAllRegisters();
					}
				});
		miscGroup.setLayout(gridLayout2);
		mCtrl.registerForLogMessages(this);
	}

	
	private void createMessagesGroup() {
		GridData gridData6 = new GridData();
		gridData6.verticalSpan = 2;
		gridData6.grabExcessHorizontalSpace = true;
		gridData6.horizontalAlignment = GridData.FILL;
		gridData6.verticalAlignment = GridData.FILL;
		gridData6.grabExcessVerticalSpace = true;
		messagesGroup = new Group(miscGroup, SWT.NONE);
		messagesGroup.setLayout(new GridLayout());
		messagesGroup.setLayoutData(gridData6);
		messagesGroup.setText("Messages");
		
		notifyMessageLabel = new Text(messagesGroup, SWT.MULTI|SWT.READ_ONLY);
	    java.util.Date today = new java.util.Date();
	    SimpleDateFormat sdf = new SimpleDateFormat("HH:mm:ss.SSS  ");
		notifyMessageLabel.setText(sdf.format(today) + "Ready");
		
		int columns = 100;
		int rows = 4;
	    GC gc = new GC (notifyMessageLabel);
	    FontMetrics fm = gc.getFontMetrics ();
	    int width = columns * fm.getAverageCharWidth ();
	    int height = rows * fm.getHeight ();
	    gc.dispose ();
	    
	    gridData6 = new GridData();
	    gridData6.widthHint = width;
	    gridData6.heightHint = height;
		notifyMessageLabel.setLayoutData(gridData6);
	}

	public void notifyLogMessage() {
		String msg = mCtrl.getLogMessage();
	    java.util.Date today = new java.util.Date();
	    SimpleDateFormat sdf = new SimpleDateFormat("HH:mm:ss.SSS  ");
		notifyMessageLabel.append("\n" + sdf.format(today) + msg);
		System.out.print(sdf.format(today) + msg + "\n");
	}
	
}
