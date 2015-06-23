////////////////////////////////////////////////////////////////
//
// guiServerGroup.java
//
// Copyright (C) 2010 Nathan Yawn 
//                    (nyawn@opencores.org)
//
// This class contains the GUI elements related to the server
// connection.  This includes the server address and port
// number, the connect button, and the network status message
// display.
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
import org.eclipse.swt.graphics.FontMetrics;
import org.eclipse.swt.graphics.GC;
import org.eclipse.swt.layout.GridData;
import org.eclipse.swt.layout.GridLayout;
import org.eclipse.swt.widgets.Button;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Group;
import org.eclipse.swt.widgets.Label;
import org.eclipse.swt.widgets.Text;


public class guiServerGroup implements NetworkStatusObserver {
		
	private Group serverGroup = null;
	private GridLayout serverGroupLayout = null;
	private Button serverConnectButton = null;
	private Group serverHostnameGroup = null;
	private Text serverHostnameText = null;
	private Group tcpPortGroup = null;
	private Text tcpPortText = null;
	private Group networkStatusGroup = null;
	private Label connectionStatusLabel = null;
	private mainControl mCtrl = null;
	
	public guiServerGroup(Composite parent, mainControl mc) {
			mCtrl = mc;
			serverGroup = new Group(parent, SWT.NONE);
			serverGroupLayout = new GridLayout();
			
			serverGroupLayout.numColumns = 4;
			
			serverGroup.setLayout(serverGroupLayout);
			serverGroup.setText("Server Connection");
			
			createServerHostnameGroup();
			createTcpPortGroup();
			serverConnectButton = new Button(serverGroup, SWT.NONE);
			serverConnectButton.setText("Connect");
			serverConnectButton.addSelectionListener(new org.eclipse.swt.events.SelectionAdapter() {
				public void widgetSelected(org.eclipse.swt.events.SelectionEvent e) {
					int port = Integer.parseInt(tcpPortText.getText());
					if(mCtrl != null) {
						mCtrl.doNetworkConnect(serverHostnameText.getText(), port);
					}
				}
			});
			createNetworkStatusGroup();

			mCtrl.registerForNetworkStatusUpdates(this);
	}
	
	private void createServerHostnameGroup() {
		serverHostnameGroup = new Group(serverGroup, SWT.NONE);
		serverHostnameGroup.setLayout(new GridLayout());
		serverHostnameGroup.setText("Server Hostname");
		serverHostnameText = new Text(serverHostnameGroup, SWT.BORDER);
		serverHostnameText.setText("localhost");
		
		// Make the Text box a bit bigger than default
		int columns = 20;
	    GC gc = new GC (serverHostnameText);
	    FontMetrics fm = gc.getFontMetrics ();
	    int width = columns * fm.getAverageCharWidth ();
	    int height = fm.getHeight ();
	    gc.dispose ();
	    // This doesn't seem to work, need to use gd.widthHint/heightHint below
		
		GridData gd = new GridData();
		gd.grabExcessHorizontalSpace = true;
		gd.verticalAlignment = GridData.CENTER;
		gd.horizontalAlignment = GridData.FILL;
		gd.widthHint = width;
		gd.heightHint = height;
		serverHostnameText.setLayoutData(gd);
	}
	
	private void createTcpPortGroup() {
		tcpPortGroup = new Group(serverGroup, SWT.NONE);
		tcpPortGroup.setLayout(new GridLayout());
		tcpPortGroup.setText("Server Port");
		tcpPortText = new Text(tcpPortGroup, SWT.BORDER);
		tcpPortText.setText("9928");
		GridData gd = new GridData();
		gd.horizontalAlignment = GridData.FILL;
		gd.grabExcessHorizontalSpace = true;
		gd.verticalAlignment = GridData.CENTER;
		tcpPortText.setLayoutData(gd);
	}
	
	private void createNetworkStatusGroup() {
		networkStatusGroup = new Group(serverGroup, SWT.NONE);
		networkStatusGroup.setText("Connection Status");
		GridLayout gl = new GridLayout();
		gl.makeColumnsEqualWidth = false;
		networkStatusGroup.setLayout(gl);
		
		GridData gd = new GridData();
		gd.horizontalAlignment = GridData.FILL;
		gd.grabExcessHorizontalSpace = true;
		networkStatusGroup.setLayoutData(gd);
		
		connectionStatusLabel = new Label(networkStatusGroup, SWT.NONE);
		connectionStatusLabel.setText("Not Connected");  // cheating - doesn't through mainControl
		gd = new GridData();
		gd.grabExcessHorizontalSpace = true;
		gd.verticalAlignment = GridData.CENTER;
		gd.horizontalAlignment = GridData.FILL;
		connectionStatusLabel.setLayoutData(gd);
	}
	
	public void notifyNetworkStatus() {
		// *** Limit length?
		connectionStatusLabel.setText(mCtrl.getNetworkStatus());		
	}
}