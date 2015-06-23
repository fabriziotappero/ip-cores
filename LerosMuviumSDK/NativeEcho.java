import leros.Native; 

import com.muvium.MuviumRunnable;

 

public class NativeEcho extends MuviumRunnable {

 
 

    public void run(){
    
    	Native.write( 'H' );
    	Native.write( 'I' );

    	//Echo
         while( true ){
        	 Native.write( 'H' );
        	 Native.write( 'i' );
        	 int val = Native.read();
        	 Native.write( val );
    
         }
 
    } //Run()
}



 