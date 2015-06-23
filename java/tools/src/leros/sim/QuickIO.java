package leros.sim;
/*
 * @(#)QuickieIO.java
 */
 
import java.awt.BorderLayout;
import java.awt.Color;
import java.awt.Container;
import java.awt.Graphics;
import java.awt.Image;
import java.awt.Rectangle;
import java.awt.event.MouseListener;
import java.io.FileInputStream;
 
import javax.imageio.ImageIO;
import javax.swing.JFrame;
import javax.swing.JPanel;
import javax.swing.WindowConstants;
 
/**
 * Quick IO TestBoard for working with basic IO examples
 * 
 * <p>
 * <b>NOTES:</b><br>
 * <ul>
 * <li>Version 04/08/2011 ( Created ) </li>
 * </ul>
 * 
 * @author James
 * @see
 */
public class QuickIO extends JFrame implements ILerosIO {
    
    Image ledON;
    Image ledOFF;
    Image buttonON;
    Image buttonOFF;
    Image logo;
    Image icon;
    
  
    Rectangle[] buttons;
    boolean[] pressed;
    boolean[] LEDS;
    
    public QuickIO() {
        super("QuickIO Muvium leros Emulator");
 
        final Container c =  getContentPane();
 
        setLayout(new BorderLayout());
        pressed = new boolean[8];
        LEDS = new boolean[8];
        
        add( "Center",        new DrawPanel()  );
        setBackground(Color.white);
 
        super.setResizable(false);
        setSize(380, 320);
         
        setDefaultCloseOperation(WindowConstants.EXIT_ON_CLOSE);

        createImages();
 
    }
    
    //Address 0 to 8 set the LEDS
    public void write(int addr, int data){
    	if( addr >= 0 && addr < 8 ){
    		LEDS[7-addr] = (data!=0);
    		repaint();
    	}
    }
    
    //Address 0 to 8 read the buttons
    public int read(int addr) {
    	if( addr >= 0 && addr < 8 ){
    		if(  pressed[7-addr] ){
    			return 1;
    		}else{
    			return 0;
    		}
    	}
    	return 0;
    }
 
    private class DrawPanel extends JPanel implements MouseListener{
        public DrawPanel(){
            setDoubleBuffered(true);
            setBackground(Color.white);
            
            addMouseListener(this);
        }
        
     // Method descriptor #12 (Ljava/awt/event/MouseEvent;)V
        public void mouseClicked(java.awt.event.MouseEvent arg0){
            
        }
        
        // Method descriptor #12 (Ljava/awt/event/MouseEvent;)V
        public void mousePressed(java.awt.event.MouseEvent arg0){
            for( int i = 0; i < 8; i++ ){
                if( buttons[i].contains( arg0.getX(), arg0.getY())  ){
                    pressed[i]=true;
                    
                }
            }
            repaint() ;
        }
        
        // Method descriptor #12 (Ljava/awt/event/MouseEvent;)V
        public void mouseReleased(java.awt.event.MouseEvent arg0){
            for( int i = 0; i < 8; i++ ){
                if( buttons[i].contains( arg0.getX(), arg0.getY())  ){
                    pressed[i]=false;
                }
            }
            repaint() ;
        }
 
        // Method descriptor #12 (Ljava/awt/event/MouseEvent;)V
        public void mouseEntered(java.awt.event.MouseEvent arg0){
            
        }
        
        // Method descriptor #12 (Ljava/awt/event/MouseEvent;)V
        public void mouseExited(java.awt.event.MouseEvent arg0){
            
        }
  
        public void paint( Graphics g){
            if( ledON == null ){
                g.setColor(Color.red);
                g.drawLine(0,0,100,100);
                return;
            }
             int width = getWidth();
             int height = getHeight();
             g.setColor(Color.white);
             g.fillRect(0, 0, width, height);
             g.setColor(Color.black);
             g.drawImage(logo, (width-logo.getWidth(null))/2 ,(height-logo.getHeight(null))/2,  null );
       
            
            int w= ledON.getWidth(null)/2;
            int h= ledON.getHeight( null)/2;
  
            int left  = 20;
            buttons = new Rectangle[ 8 ];
            for( int i = 0; i < 8; i++ ){
                int top   = 20;
                //Draw LEDS
                if( LEDS[i]  ){
                    g.drawImage(ledOFF, left ,top,w,h, null );
                }else{
                    g.drawImage(ledON, left ,top,w,h, null );
                }
                g.drawString("D"+ String.valueOf(7-i) , left + 10 , top + h );
                
     
                  top   = 200;
                //Draw Buttons
                if(pressed[i]){
                    g.drawImage(buttonON, left ,top,35,35, null );
                }else{
                    g.drawImage(buttonOFF, left ,top,35,35, null );
                }
                g.drawString("B"+ String.valueOf(7-i) , left + 10 , top + 50);
                buttons[i] = new Rectangle( left,top,35,35);
          
                left+=( w + 5 );
            }
           
        }
    }
    
    
    private void createImages(){
 
          buttonON      = getImage("ButtonON.png");
          buttonOFF     = getImage("ButtonOFF.png");
          ledON         = getImage("LedON.png");
          ledOFF        = getImage("LedOFF.png");
          logo          = getImage("MuviumLOGO.png");
          icon          = getImage("MuviumICON16.png");
  
          setIconImage(icon);
         
      
    }
    
    public Image getImage( String fileName )
    {
         try
         {
 
            return ImageIO.read( ClassLoader.getSystemResourceAsStream("images/" + fileName  ) );
         }
         catch(Exception e)
         {
             System.out.println("NO IMAGES!" + fileName);
         }
         
         try
         {
 
            return ImageIO.read( new FileInputStream( "C:/eclipse/workspace-leros/Leros-API/images/" + fileName  ));
         }
         catch(Exception e)
         {
             System.out.println("NO IMAGES!" + fileName);
         }
 
         return null;
    }
  
 
    public static void main( String[] args ){
         new QuickIO().setVisible(true);
    }
}
