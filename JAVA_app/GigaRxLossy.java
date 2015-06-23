/*
 * Copyright (C) 2010 Simon A. Berger
 *
 * This program is free software; you may redistribute it and/or modify its
 * under the terms of the GNU General Public License as published by the Free
 * Software Foundation; either version 2 of the License, or (at your option)
 * any later version.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
 * or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License
 * for more details.
 */


/*
 * This is the code used for the evaluation of the FPGA/PC communication using
 * UDP/IP. 
 * This program can operate in two modes, which correspond to the two evaluations
 * in the paper:
 * - one way test: receive packets for 10 seconds. Calculate actual number of
 *   sent packets from the serial numbers.
 * - two way (duplex) test: send a fixed number of packets and count received
 *   packets.
 *
 * The program mode is controlled with the DUPLEX_TEST constant.
 *
 * To compile this program use "javac GigaRxLossy.java"
 * To run the program use "java GigaRxLoss"
 */

import java.io.IOException;
import java.net.DatagramPacket;
import java.net.DatagramSocket;
import java.net.InetAddress;
import java.net.InetSocketAddress;
import java.net.SocketAddress;
import java.nio.ByteBuffer;
import java.nio.MappedByteBuffer;
import java.nio.IntBuffer;
import java.nio.DoubleBuffer;

import java.nio.channels.ClosedByInterruptException;
import java.nio.channels.DatagramChannel;


public class GigaRxLossy {
	public static boolean isValid( ByteBuffer b, int size ) {
		int ref = b.get();
		
		for( int i = 1; i < size; i++ ) {
			if( b.get() != ref ) {
				
				return false;
			}
		}

		return true;
	}
	
	public static void main(String[] args) throws IOException, InterruptedException {
		final int MTU = 1500;
		
		final SocketAddress rxaddr = new InetSocketAddress( 21844 );
		
		final DatagramChannel rxc = DatagramChannel.open();
		
		rxc.socket().bind(rxaddr);
		
		final SocketAddress txsendtoaddr = new InetSocketAddress( "192.168.1.1", 21845 );
		
				
		// set this constant to:
		// - false for the one-way test
		// - true for the duplex test
		
		boolean DUPLEX_TEST = !true;


		boolean haveTx;
		boolean trigger;
		if( DUPLEX_TEST ) {
			haveTx = true;
			trigger = false;
		
		} else {
			haveTx = false;
			trigger = true;
		}
		
		
		final DatagramChannel txc;
		
		if( haveTx || trigger )
		{
			txc = DatagramChannel.open();
			txc.socket().bind(null);
		} else {
			txc = null;
		}
		
		final Thread reader = new Thread() {
			// this is the recaiver thread
			@Override
			public void run() {
				
				java.nio.ByteBuffer rxb = ByteBuffer.allocateDirect(MTU);
				
				boolean first = true;
				int firstser = -1;
				int lastser = -1;
				int nrec = 0;
				long time = System.currentTimeMillis();

				long rxbytes = 0;
				long txn = 0;
				try {
					//rxc.connect(rxaddr);
					
					
					while( !isInterrupted() ) {
					
						rxb.rewind();
						rxc.receive(rxb);
						int rxsize = rxb.position();
						
						rxb.rewind();
						//int ser = rxb.asIntBuffer().get(0);
						IntBuffer ib = rxb.asIntBuffer();					
//						DoubleBuffer db = rxb.asDoubleBuffer();					
										
						int ser = ib.get()>>>24;

						// calculate the number of actually sent packets from the serial
						// number.
						if( !first ) {
							if( ser < lastser ) {
								txn += ser - (lastser - 256 );					
							} else {
								txn += ser - lastser;
							}
							//System.out.printf( "int %d\n", txn );
						} else {
							first = false;
						}
						lastser = ser;

						if( firstser == -1 ) {
							firstser = ser;
						}
						
						
						// for maximum speed the validity check may be disabled as the current
						// implementation is fairly inefficient. In our tests we never got any
						// packet corruption.
						boolean CHECK_VALID = true;
						if( CHECK_VALID ) {
							if( !isValid( rxb, rxsize ) ) {
								System.out.println( "invalid" );
							}
						}
//						lastser = ser;
						nrec++;
						rxbytes+=rxsize;
					
					}
				} catch( ClosedByInterruptException e ) {
					System.out.printf( "reader: interrupted. bye ...\n" );
				
				} catch (IOException e) {
				
					// TODO Auto-generated catch block
					e.printStackTrace();
					throw new RuntimeException( "bailing out." );
				}
				long dt = System.currentTimeMillis() - time;
				System.out.printf( "%d bytes in %d ms: %.2f Mb/s\n", rxbytes, dt, rxbytes / (dt * 1000.0) );
				int serrange = (lastser - firstser) + 1;
				System.out.printf( "nrec: %d of %d (%.2f%%)\n", nrec, txn, nrec / (float)txn * 100.0 );
			}
		};
		
		if( !trigger ) {	
			reader.start();
		}

		if( haveTx ) {
			Thread writer = new Thread() {
				// this is the sender thread.
				@Override
				public void run() {
					// TODO Auto-generated method stub
					//java.nio.ByteBuffer txb = MappedByteBuffer.allocate(MTU);
					java.nio.ByteBuffer txb = java.nio.ByteBuffer.allocateDirect(MTU);
					int i = 0;
					long time = System.currentTimeMillis();
	
					long txbytes = 0;
					long nj = 0;
					while( i < 1000000 ) {
						txb.rewind();
						
						txb.asIntBuffer().put(0, i);
						txb.rewind();
						try {
							txbytes += txc.send(txb, txsendtoaddr);
						
							
							
						} catch (IOException e) {
							// TODO Auto-generated catch block
							e.printStackTrace();
						}
						i++;
						
						if( i % 10000 == 0 ) {
							System.out.printf( "tx -> rx %d\n", i );
						}
						
	//					if( ack.i != -1 ) {
	//						i = ack.i;
	//						ack.i = -1;
	//					}
					}
					long dt = System.currentTimeMillis() - time;
					System.out.printf( "%d bytes in %d ms: %.2f Mb/s\n", txbytes, dt, txbytes / (dt * 1000.0) );
				}
			};
					
	
				
			writer.start();
			
			writer.join();
			reader.interrupt();
		} else {
			if( trigger ) {
				java.nio.ByteBuffer txb = java.nio.ByteBuffer.allocateDirect(MTU);
                               	txc.send(txb, txsendtoaddr);
				Thread.sleep( 1000 );
			}
			reader.start();
			Thread.sleep(10000);
			reader.interrupt();
		}
	}
}
