/**************************************************************************************************************
*
*    L Z R W 1   E N C O D E R   C O R E
*
*  A high throughput loss less data compression core.
* 
* Copyright 2012-2013   Lukas Schrittwieser (LS)
*
*    This program is free software: you can redistribute it and/or modify
*    it under the terms of the GNU General Public License as published by
*    the Free Software Foundation, either version 2 of the License, or
*    (at your option) any later version.
*
*    This program is distributed in the hope that it will be useful,
*    but WITHOUT ANY WARRANTY; without even the implied warranty of
*    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
*    GNU General Public License for more details.
*
*    You should have received a copy of the GNU General Public License
*    along with this program; if not, write to the Free Software
*    Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
*    Or see <http://www.gnu.org/licenses/>
*
***************************************************************************************************************
*
* Change Log:
*
* Version 1.0 - 2013/04/05 - LS
*   released
*
***************************************************************************************************************
*
* This program can be used to create random test vectors with a given probability of redundency and a 
* given length.
*                                                                                                                    
***************************************************************************************************************/   

import java.io.BufferedOutputStream;
import java.io.BufferedInputStream;
import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.FileReader;
import java.io.FileOutputStream;
import java.io.FileInputStream;
import java.io.File;
import java.io.IOException;
import java.lang.Integer;
import java.util.Random;
import java.lang.Math;

class TestVectGen
{
	// define probabilities defining the generated vectors specifics
	
	// probability in percent that an object is a literal (otherwise it is repeated from the history buffer)
	final static int P_LITERAL	= 90;
	
	final static int MAX_COPY_LEN = 16;
	
	final static int HISTORY_LEN = 4096;	// buffer length in bytes 
	
	// create a binary test vector (file) to test compression programms
	public static void main (String args[])
	{
		if (args.length < 2)
		{
			System.err.println("Usage: TestVectGen out-file min-length-in-bytes");
			return;
		}
		
		int len = -1;
		int [] historyBuffer = new int[HISTORY_LEN];
		int histLength = 0;
		int histWrInd = 0;
		int ch;
		Random rand = new Random();
		
		try
		{
			BufferedOutputStream outStream = new BufferedOutputStream(new FileOutputStream(args[0]));
			len = Integer.parseInt(args[1]);
			
			for (int i=0; i<len; i++)
			{
				// decide wether we want a literal or a replica
				if (((Math.abs(rand.nextInt())%100) < P_LITERAL) || (i == 0))
				{
					ch = Math.abs(rand.nextInt());	// create a random literal
					ch &= 0x7f;
					if (ch < 32) // make it a valid asci symbol
						ch += 32;
					ch &= 0x7F;	 
					if (ch == 127)
						ch = 32;
					outStream.write(ch);
					historyBuffer[histWrInd++] = ch;
					if (histWrInd >= HISTORY_LEN)
						histWrInd -= HISTORY_LEN;
					if (histLength < HISTORY_LEN)
						histLength++;
				}
				else
				{
					// choose a random length for the copy operation
					int cLen	= (Math.abs(rand.nextInt()) % (MAX_COPY_LEN-3)) + 3; // -3 and +3 because we want values between 3 and MAX_COPY_LEN (both inclusive)
					int offset = Math.abs(rand.nextInt()) % (histLength);
					//System.out.printf("cpy:  i=%d  len=%d  off=%d\n",i,cLen,offset);
					
					for (int j=0; j<=cLen; j++)
					{
						// load the byte from the history buffer
						int ind = histWrInd-offset-1;
						while (ind < 0)
							ind += HISTORY_LEN;
						
						ch = historyBuffer[ind];
						outStream.write(ch);
						
						// save this byte in the history buffer
						historyBuffer[histWrInd++] = ch;
						if (histWrInd >= HISTORY_LEN)
							histWrInd = 0;
						if (histLength < HISTORY_LEN)
						histLength++;					
					}
					// correct the loop variable (we created more than 1 byte)
					i += cLen - 1; // compensate for the i++ of for by -1
				}
				
			}
			outStream.close();			
		}
		catch (Exception e)
		{
			System.err.println("exception: "+e);
			e.printStackTrace();
		}
		
	}
}
