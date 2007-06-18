/*
 * MainJFrameTest.java
 * JUnit based test
 *
 * Created on March 21, 2007, 1:03 AM
 */

package coreedit;

import junit.framework.*;

/**
 *
 * @author alex
 */
public class MainJFrameTest extends TestCase {
    
    public MainJFrameTest(String testName) {
        super(testName);
    }

    protected void setUp() throws Exception {
    }

    protected void tearDown() throws Exception {
    }

    /**
     * Test of main method, of class coreedit.MainJFrame.
     */
    public void testMain() {
        System.out.println("main");
        
        String[] args = null;
        
        MainJFrame.main(args);
        
        // TODO review the generated test code and remove the default call to fail.
        fail("The test case is a prototype.");
    }
    
}
