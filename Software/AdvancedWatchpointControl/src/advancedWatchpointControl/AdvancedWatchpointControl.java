////////////////////////////////////////////////////////////////
//
// AdvancedWatchpointControl.java
//
// Copyright (C) 2010 Nathan Yawn 
//                    (nyawn@opencores.org)
//
// This is the main class in the AdvancedWatchpointControl
// program.  It creates all the worker classes, then passes
// control off to the SWT to listen for events.
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

import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Display;
import org.eclipse.swt.widgets.Shell;
import org.eclipse.swt.custom.ScrolledComposite;
import org.eclipse.swt.SWT;
import org.eclipse.swt.layout.FillLayout;
import org.eclipse.swt.layout.RowLayout;



public class AdvancedWatchpointControl {

	private static Display mainDisplay = null;
	private static Shell mainShell = null;
	private static guiServerGroup gServerGroup = null;
	private static guiDCRGroup gDCRGroup = null;
	private static guiCountRegsGroup gCountGroup = null;
	private static guiControlGroup gControlGroup = null;
	private static mainControl mCtrl = null;
	private static ScrolledComposite mainSC = null;
	private static Composite mainComposite = null;
	
	/**
	 * This method initializes mainShell	
	 *
	 */
	private static void createMainShell(Display disp, mainControl mc) {		
		RowLayout mainLayout = new RowLayout();		
		mainLayout.center = true;
		mainLayout.fill = true;
		mainLayout.spacing = 5;
		mainLayout.wrap = false;
		mainLayout.pack = true;
		mainLayout.type = SWT.VERTICAL;
		
		mainShell = new Shell();
		mainShell.setText("Advanced Watchpoint Control");
		mainShell.setLayout(new FillLayout());
		
		mainSC = new ScrolledComposite(mainShell, SWT.H_SCROLL|SWT.V_SCROLL);
		mainComposite = new Composite(mainSC, SWT.NONE);
		mainComposite.setLayout(mainLayout);
		
		gServerGroup = new guiServerGroup(mainComposite, mc);
		gDCRGroup = new guiDCRGroup(mainComposite, mainDisplay, mc);
		gCountGroup = new guiCountRegsGroup(mainComposite, mainDisplay, mc);
		gControlGroup = new guiControlGroup(mainComposite, mc);
		
		mainSC.setContent(mainComposite);
		// Set the minimum size
	    mainSC.setMinSize(770, 950);
	    // Expand both horizontally and vertically
	    mainSC.setExpandHorizontal(true);
	    mainSC.setExpandVertical(true);
	}
	

	/**
	 * @param args
	 */
	public static void main(String[] args) {
		
		// Create the main control.
		// This also creates the network and RSP subsystems
		mCtrl = new mainControl();
		
		// Create the GUI.  Must be done after main control creation.
		mainDisplay = new Display();
		createMainShell(mainDisplay, mCtrl);
		
		// All ready, show the UI
		mainShell.pack();
		mainShell.open();
		while (!mainShell.isDisposed()) {
		if (!mainDisplay.readAndDispatch()) mainDisplay.sleep();
		}
		mainDisplay.dispose();
	}

}
