import java.awt.*;
import java.awt.event.*;

public class HelloJAWTWorld extends Canvas {

    static {
        try {
            System.loadLibrary("mylib");
        } catch (Throwable t) {
            System.out.println("Test failed!!");
            t.printStackTrace();
            System.exit(1);
        }
    }

    public native void paint(Graphics g);

    public static void main(String[] args) {
        try {
            //Robot robot = new Robot();
            System.out.println("Test started!");
            Frame f = new Frame();
            f.setBounds(0, 0, 100, 100);
            f.add(new HelloJAWTWorld());
            f.addWindowListener(new WindowAdapter() {
                public void windowClosing(WindowEvent ev) {
                    System.exit(0);
                }
            });
            System.out.println("set visible");
            f.setVisible(true);
            Color col1 = new Color(100, 100, 120);
        } catch (Throwable t) {
            System.out.println("Test failed!");
            t.printStackTrace();
            System.exit(1);
        }
    }
}
