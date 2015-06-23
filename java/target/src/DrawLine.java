import com.muvium.leros.Native;

import com.muvium.MuviumRunnable;

/*
 * Example program for Leros.
 * Line drawing benchmark for the JTRES 2011 paper submisssion.
 * 
 * Might in the meantime be broken, as this used a different IO class
 */

public class DrawLine extends MuviumRunnable {

    static int Axv ;
    static int Ayv ;
    static int Bxv ;
    static int Byv ;
    static int Z ;
    static int color ;
 
    static int  Ax = Axv;
    static int  Ay = Ayv;
    static int  Bx = Bxv;
    static int  By = Byv;
    
    static int  p ;
 
    public void run(){
        int dx = 0 ;
        int dy  = 0;
        int Xincr  = 0;
        int Yincr  = 0;
        int dPr = 0;
        int dPru = 0;
   
       while( true ){
 
             Axv = Native.rd(0);  
             Ayv = Native.rd(0);  
             Bxv = Native.rd(0);  
             Byv = Native.rd(0);  
             Z =   Native.rd(0);  
             color = Native.rd(0);  
 
              Ax = Axv;
              Ay = Ayv;
              Bx = Bxv;
              By = Byv;
  
           //dx = Math.abs(Ax - Bx);  //';  // store the change in X and Y of the line endpoints
           if( Bx > Ax ){
               dx = Bx - Ax;
           }else{
               dx = Ax - Bx;
           }
     
      
           //dY = Math.abs(AY - By);  //';  // store the change in X and Y of the line endpoints
           if( By > Ay ){
               dy = By - Ay;
           }else{
               dy = Ay - By;
           }
           
           if( dy == 0){
               //horizontalLine( Ax, Bx, AY ); //TODO Inline
 
            }else{
               if( dx == 0 ){
                  // verticalLine( AY, By, Ax );//TODO Inline
                
               }else{
              
              // 'diagonal line
               
            //'If dX = 0 Then drawHorizontal

       //'//------------------------------------------------------------------------
       //'// DETERMINE "DIRECTIONS" TO INCREMENT X AND Y (REGARDLESS OF DECISION)
       //'//------------------------------------------------------------------------
               if( Ax > Bx ){ // '// which direction in X?
                   Xincr = -1;
               }else{
                   Xincr = 1;
               }
      
               if(  Ay > By) { // '// which direction in Y?
                   Yincr = -1;
               }else{
                   Yincr = 1;
               }

  
       //'//------------------------------------------------------------------------
       //'// DETERMINE INDEPENDENT VARIABLE (ONE THAT ALWAYS INCREMENTS BY 1 (OR -1) )
       //'// AND INITIATE APPROPRIATE LINE DRAWING ROUTINE (BASED ON FIRST OCTANT
       //'// ALWAYS). THE X AND Y'S MAY BE FLIPPED IF Y IS THE INDEPENDENT VARIABLE.
       //'//------------------------------------------------------------------------
                       if (dx >= dy) { //              '// if X is the independent variable
                       
                           dPr = dy * 2;             //   '// amount to increment decision if right is chosen (always)
                           dPru = dPr - (dx * 2) ;    //  '// amount to increment decision if up is chosen
                           
                           p = dPr - dx ;              // '// decision variable start value
           
                           for(; dx >= 0; dx-- ){ //For dx = dx To 0 Step -1
             
                              // setPixel( Ax, AY, color );  
                             
                               Native.wr( Z , 0);
                               Native.wr( color, 0);
                               Native.wr( Ax, 0);
                               Native.wr( Ay, 0);
                      
                               
                               Ax = Ax + Xincr;        // '// increment independent variable
                               if( p > 0 ){
                                   Ay = Ay + Yincr;
                               }
           
                               
                               if( p > 0 ){
                                 p = p + dPru ;         //'// increment decision (for up)
                               }else{
                                   p = p + dPr;
                               }
                               
                           }
                       
                       }else{
                   
                           dPr = dx * 2 ;           //    '// amount to increment decision if right is chosen (always)
                           dPru = dPr - (dy * 2)    ;//   '// amount to increment decision if up is chosen
                           p = dPr - dy             ;//  '// decision variable start value

                           for(; dy >= 0; dy--){ //For dY = dY To 0 Step -1    '// process each point in the line one at a time (just use dY)
               
                              //  setPixel( Ax, AY, color );  
                               Native.wr( Z , 0);
                               Native.wr( color, 0);
                               Native.wr( Ax, 0);
                               Native.wr( Ay, 0);
          
                               Ay = Ay + Yincr;        //  '// increment independent variable
                               if( p > 0 ){
                                   Ax = Ax + Xincr;
                               }
                     
                               if( p > 0 ){ 
                                 p = p + dPru ;          // '// increment decision (for up)
                               }else{
                                   p = p + dPr;
                               }
                               
                           }
                       }
           
               }
            }
       
            Native.wr(0xFF, 0); //Done
        }

    } //Run()
}
