//----------------------------------------------------------------------------
// Copyright (C) 2007 Jonathon W. Donaldson
//                    jwdonal a t opencores DOT org
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation; either version 2 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program; if not, write to the Free Software
//  Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
//
//----------------------------------------------------------------------------
//
//  $Id: Gen_LCD_Image.java,v 1.2 2007-05-29 04:15:10 jwdonal Exp $
//
//  Description: This program parses the RGB COE files in binary, decimal
//  or hex format and displays what the image should look like on the LCD
//  if the COE files given to this app are the same ones given to the Xilinx
//  CoreGen tool for each color's BRAM instance.
//  
//---------------------------------------------------------------------
import java.io.BufferedReader;
import java.io.FileReader;
import java.io.FileNotFoundException;
import java.io.IOException;

import java.awt.image.BufferedImage;
import javax.swing.JLabel;
import javax.swing.JFrame;
import javax.swing.ImageIcon;

public class Gen_LCD_Image {

  //File locations within filenames[] member variable
  private static final int RED_LOC = 0;
  private static final int GREEN_LOC = 1;
  private static final int BLUE_LOC = 2;
  private static final int HDR_LOC = 3;

  private String[] filenames;
  private BufferedReader hdrFile;
  private BufferedReader[] coeFile = new BufferedReader[NUM_COE_FILES];

  private static final int RADIX_BIN = 2;
  private static final int RADIX_DEC = 10;
  private static final int RADIX_HEX = 16;
  private static final int NUM_COE_FILES = 3;
  private static final int BRAM_WIDTH_MAX = 8;

  private BufferedImage lcd_image;
  private JFrame lcd_frame;

  private int image_width;
  private int image_height;
  private int bram_width;
  private int radix_vals[] = new int[NUM_COE_FILES];

  private String currByteRed;
  private String currByteGreen;
  private String currByteBlue;

  private int currByteIntRed;
  private int currByteIntGreen;
  private int currByteIntBlue;

  private String hdrFileStr;


  /**
   *  Constructor for a Gen_LCD_Image object.
   *
   *  @param  filenames 3 COE files (R,G,and B) and 1 Header File
   **/
  public Gen_LCD_Image( String[] filenames  ) {
    
    this.filenames = filenames;

    image_width = 0;
    image_height = 0;
    bram_width = 0;

    currByteRed = "uninitialized";
    currByteGreen = "uninitialized";
    currByteBlue = "uninitialized";

    currByteIntRed = 0;
    currByteIntGreen = 0;
    currByteIntBlue = 0;

    hdrFileStr = "uninitialized";

  }


  public void openHeaderFile() throws FileNotFoundException {

    //OPEN the header file
    hdrFile = new BufferedReader(
              new FileReader( filenames[HDR_LOC] ));

  }

  public void openCoeFiles() throws FileNotFoundException {

    //OPEN the COE files for each of the three colors
    for( int fileNum = RED_LOC; fileNum < NUM_COE_FILES; fileNum++ ) {

      //open the file
      coeFile[fileNum] = new BufferedReader(
                         new FileReader( filenames[fileNum]) );

    } //end for loop

  }


  public void checkCoeFileOrder() throws IOException {

    //OPEN the COE files for each of the three colors
    for( int fileNum = 0; fileNum < NUM_COE_FILES; fileNum++ ) {

      if( fileNum == RED_LOC ) {

        if( !coeFile[fileNum].readLine().matches(";.*RED.*") ) {
          System.err.println( "The first line of the red COE file did not contain the correct color identifier!  Please ensure that the file contains the word 'RED' somewhere in the first line!" );
          System.exit( 1 );
        }

      } else if( fileNum == GREEN_LOC ) {

        if( !coeFile[fileNum].readLine().matches(";.*GREEN.*") ) {
          System.err.println( "The first line of the green COE file did not contain the correct color identifier!  Please ensure that the file contains the word 'GREEN' somewhere in the first line!" );
          System.exit( 1 );
        }

      } else { //if BLUE_LOC

        if( !coeFile[fileNum].readLine().matches(";.*BLUE.*") ) {
          System.err.println( "The first line of the blue COE file did not contain the correct color identifier!  Please ensure that the file contains the word 'BLUE' somewhere in the first line!" );
          System.exit( 1 );
        }

      } //end if/else_if/else

    } //end for loop

  } //end checkCoeFileOrder()


  public void getImageWidth() throws IOException {

    //Fetch the Image Width from the header file stream
    do {

      hdrFileStr = hdrFile.readLine();

    } while( !hdrFileStr.matches( ".*Image Width" ) );

    image_width = Integer.parseInt(hdrFileStr.substring(0, hdrFileStr.indexOf( "h" )), 16 );

    System.out.println( "\nImage Width = " + image_width );

  } //end getImageWidth


  public void getImageHeight() throws IOException {

    //Fetch the Image Height from the header file stream
    do {

      hdrFileStr = hdrFile.readLine();

    } while( !hdrFileStr.matches( ".*Image Height" ) );

    image_height = Integer.parseInt(hdrFileStr.substring(0, hdrFileStr.indexOf( "h" )), 16 );

    System.out.println( "\nImage Height = " + image_height );

  } //end getImageHeight


  public void getBramWidth() throws IOException {

    //Fetch BRAM data width from header file
    do {

      hdrFileStr = hdrFile.readLine();

    } while( !hdrFileStr.matches( "Width = .*" ) );

    bram_width = Integer.parseInt(hdrFileStr.substring(hdrFileStr.lastIndexOf(" ")+1, hdrFileStr.length()), 10 );

    System.out.println( "\nBRAM Width = " + bram_width );

  } //getBramWidth

  
  public void getRadixValues() throws IOException {

    String temp = "unintialized";

    for( int fileNum = 0; fileNum < NUM_COE_FILES; fileNum++ ) {

      //Scan for the memory initialization radix value for each file
      do {
        // a whole lotta nothin until I say stop
      } while( !coeFile[fileNum].readLine().matches( "MEMORY_INITIALIZATION_RADIX.*" ) );

      //Capture the RADIX value for each color
      if( fileNum == RED_LOC ) {

        temp = coeFile[RED_LOC].readLine();
        radix_vals[RED_LOC] = Integer.parseInt( temp.substring(0, temp.length()-1).trim() ); //remove the semi-colon and get rid of any white space
        System.out.println( "\nRed radix = " + radix_vals[RED_LOC] );

      } else if( fileNum == GREEN_LOC ) {

        temp = coeFile[GREEN_LOC].readLine();
        radix_vals[GREEN_LOC] = Integer.parseInt( temp.substring(0, temp.length()-1).trim() );
        System.out.println( "\nGreen radix = " + radix_vals[GREEN_LOC] );

      } else { // BLUE_LOC

        temp = coeFile[BLUE_LOC].readLine();
        radix_vals[BLUE_LOC] = Integer.parseInt( temp.substring(0, temp.length()-1).trim() );
        System.out.println( "\nBlue radix = " + radix_vals[BLUE_LOC] );

      } //end if/else_if/else

    } //end for loop for each COE file

  }


  public void checkRadixValues() {
  
    for( int num = RED_LOC; num < NUM_COE_FILES; num++ ) {

      if( radix_vals[num] != RADIX_BIN &&
          radix_vals[num] != RADIX_DEC &&
          radix_vals[num] != RADIX_HEX ) {

        System.err.println( "RADIX value `" + radix_vals[num] + "' is not of valid type!  RADIX must be 2, 10, or 16" );
        System.exit( 1 );

      }

    } // end for loop

    // make sure all radix values are the same
    if( !(radix_vals[RED_LOC] == radix_vals[GREEN_LOC] &&
          radix_vals[RED_LOC] == radix_vals[BLUE_LOC])   ) {

      System.err.println( "WARNING! RADIX values in each color file do NOT match!" );
      System.err.println( "I received red_radix = " + radix_vals[RED_LOC] +
                                   ", green_radix = " + radix_vals[GREEN_LOC] +
                                   ", blue_radix = " + radix_vals[BLUE_LOC] );
    }

  }


  public void getImageData() throws IOException {

    //Create a BufferedImage object that is the same size as the actual image.
    //This will be used to display the expected image for the LCD
    lcd_image = new BufferedImage(image_width, image_height, BufferedImage.TYPE_INT_ARGB);

    for( int fileNum = RED_LOC; fileNum < NUM_COE_FILES; fileNum++ ) {

      //Immediately scan each of the COE file parses down to the line just above
      //the first byte of image data.
      do {
        //a whole lotta nothing - just keep skipping lines until I say stop!
      } while( !coeFile[fileNum].readLine().matches("MEMORY_INITIALIZATION_VECTOR.*") );

    }

    //Fetch the data for each of the 3 colors from the files
    //and set the pixel colors inside the BufferedImage
    for( int rowNum = 0; rowNum < image_height; rowNum++ ) {

      for( int pixNum = 0; pixNum < image_width; pixNum++ ) {

        //RED data control
        currByteRed = coeFile[RED_LOC].readLine(); //get next data byte as string
        currByteRed = currByteRed.substring( 0, currByteRed.length()-1 ); //remove the last character (, or ;)
        currByteIntRed = Integer.parseInt( currByteRed, radix_vals[RED_LOC] ) << BRAM_WIDTH_MAX - bram_width; //Convert the hex string to an integer value (shift as necessary to get the greatest number of most significant bits that the LCD is capable of displaying)

        //GREEN data control
        currByteGreen = coeFile[GREEN_LOC].readLine();
        currByteGreen = currByteGreen.substring( 0, currByteGreen.length()-1 );
        currByteIntGreen = Integer.parseInt( currByteGreen, radix_vals[GREEN_LOC] ) << BRAM_WIDTH_MAX - bram_width;

        //BLUE data control
        currByteBlue = coeFile[BLUE_LOC].readLine();
        currByteBlue = currByteBlue.substring( 0, currByteBlue.length()-1 );
        currByteIntBlue = Integer.parseInt( currByteBlue, radix_vals[BLUE_LOC] ) << BRAM_WIDTH_MAX - bram_width;

        lcd_image.setRGB(pixNum, rowNum,
              ( (255 << 24)              |
                (currByteIntRed   << 16) |
                (currByteIntGreen << 8 ) |
                (currByteIntBlue       ) )
        );

      } // end column (pixel) loop

    } // end row (line) loop

  } //end getImageData


  public void showImage() {

    //This creates the JFrame to hold the BufferedImage
    lcd_frame = new JFrame ("LCD Display");

    //Insert the image (lcd_image) into the fram
    lcd_frame.getContentPane().add( new JLabel( new ImageIcon( lcd_image ) ) );

    //Make the frame the same size as the subcomponents (i.e. the lcd_image)
    lcd_frame.pack();

    lcd_frame.setResizable(false);
    lcd_frame.setVisible(true); //I think we'd like to see the image, yes? :-)
    lcd_frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);


  } // end showImage

  public void closeFiles() throws IOException {

    //CLOSE all COE file streams
    for( int fileNum = 0; fileNum < NUM_COE_FILES; fileNum++ ) {
      coeFile[fileNum].close();
    }

    //CLOSE header file stream
    hdrFile.close();

  }


  //--MAIN METHOD--//
  public static void main( String[] args ) {


    if( args.length != 4 ) {
      System.err.println( "Usage: java Gen_LCD_Image <r_coe_file_name> <g_coe_file_name> <b_coe_file_name> <hdr_file_name>" );
      System.exit(1);
    }

    //Create new Gen_LCD_Image object
    Gen_LCD_Image myLCDImage = new Gen_LCD_Image( args );

    //NOTE! There are no built-in sanity checks on
    //which order these functions are called in.  Make
    //sure you call the functions to open the files
    //before calling functions that use those files.
    //There are other functions that rely on others
    //to run first as well.  Just run them in the
    //order below and you'll be fine.

    //Open the provided files
    try {
      myLCDImage.openHeaderFile();
      myLCDImage.openCoeFiles();

    } catch( FileNotFoundException FNFE ) {
      System.err.println( FNFE.getMessage() );

    }

    //Get preliminary information
    try {
      myLCDImage.checkCoeFileOrder();
      myLCDImage.getImageWidth();
      myLCDImage.getImageHeight();
      myLCDImage.getBramWidth();
      myLCDImage.getRadixValues();

    } catch( IOException IOE ) {
      System.err.println( IOE.getMessage() );
    }

    //Ensure the radix values are valid
    myLCDImage.checkRadixValues();

    //Read the image data out of the COE files
    try {
      myLCDImage.getImageData();

    } catch( IOException IOE ) {
      System.err.println( IOE.getMessage() );
    }

    //Display the image to the screen
    myLCDImage.showImage();

    //CLose all file streams
    try {
      myLCDImage.closeFiles();

    } catch( IOException IOE ) {
      System.err.println( IOE.getMessage() );
    }

  } //end of main method

} // end of Gen_LCD_Image class
