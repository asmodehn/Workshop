/*
 * FileHandlerTest.java
 * JUnit based test
 *
 * Created on April 4, 2007, 7:48 PM
 */

package coreedit;

import junit.framework.*;
import java.io.IOException;
import java.io.FileNotFoundException;
import java.io.File;
import java.io.FileWriter;
import java.io.FileReader;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;

/**
 *
 * @author alex
 */
public class FileHandlerTest extends TestCase
{
    
    File testfile;
	    
    public FileHandlerTest(String testName)
    {
	super(testName);
    }

	protected void setUp() throws Exception
	{
	    //TODO : create here set of tests files
	    try
	    {
		testfile = File.createTempFile("FileHandler","test");
	    }
	    catch (IOException ex)
	    {
		StringBuilder errorStr = new StringBuilder();
		errorStr.append("IO Exception raised in setUp : ");
		errorStr.append("TmpDir = ");
		errorStr.append( System.getProperty("java.io.tmpdir"));
		errorStr.append(" ");
		errorStr.append(ex.getMessage());
		
		fail(errorStr.toString());
	    }
		    
	    FileWriter fw = new FileWriter(testfile);
	    fw.write("test");
	    fw.close();
	}

	protected void tearDown() throws Exception
	{
	    //TODO : delete here the set of test files
	    testfile.delete();
	}

	/**
	 * Test of getInputStream method, of class coreedit.FileHandler.
	 */
	public void testGetInputStream()
	{
		System.out.println("getInputStream");
		
		try
		{
		    FileHandler instance = new FileHandler(testfile);
		    
		    byte[] expResult = {'t','e','s','t'};
		    FileInputStream resultstream = instance.getInputStream();
		    assertEquals(4,resultstream.available());
		    
		    byte[] btable = new byte[expResult.length];
		    assertEquals(4,resultstream.read(btable));
		    
		    for (int i=0; i<expResult.length; i++)
		    {
			assertEquals(expResult[i],btable[i]);
		    }
		}
		catch (FileNotFoundException ex)
		{
		    fail("FileNotFound Exception raised.");
		}
		catch (IOException ex)
		{
		    fail("IO Exception raised.");
		}		
	}

	/**
	 * Test of getReader method, of class coreedit.FileHandler.
	 */
	public void testGetReader()
	{
		System.out.println("getReader");
		try
		{
		    FileHandler instance = new FileHandler(testfile);
		
		    char[] expResult = {'t','e','s','t'};
		    InputStreamReader result = instance.getReader();
		    assertEquals(true,result.ready());
		    
		    char[] ctable = new char[expResult.length];
		    assertEquals(4,result.read(ctable) );
			
		    for (int i=0; i<expResult.length; i++)
		    {
			assertEquals(expResult[i],ctable[i]);
		    }
		}
		catch (FileNotFoundException ex)
		{
		    fail("FileNotFound Exception raised.");
		}
		catch (IOException ex)
		{
		    fail("IO Exception raised.");
		}	
	}

	/**
	 * Test of getOutputStream method, of class coreedit.FileHandler.
	 */
	public void testGetOutputStream()
	{
		System.out.println("getOutputStream");
		
		try
		{
		    FileHandler instance = new FileHandler(testfile);
		    FileOutputStream result = instance.getOutputStream();
		    
		    byte[] outtxt = {'i','n','g'};
		    result.write(outtxt);
		    result.close();
		    
		    byte[] expResult = {'t','e','s','t','i','n','g'};
		    FileInputStream resultstream = instance.getInputStream();
		    assertEquals(7,resultstream.available());
		    
		    byte[] btable = new byte[expResult.length];
		    assertEquals(7,resultstream.read(btable));
		    
		    for (int i=0; i<expResult.length; i++)
		    {
			assertEquals(expResult[i],btable[i]);
		    }
		}
		catch (FileNotFoundException ex)
		{
		    fail("FileNotFound Exception raised.");
		}
		catch (IOException ex)
		{
		    fail("IO Exception raised.");
		}		
		
	}

	/**
	 * Test of getWriter method, of class coreedit.FileHandler.
	 */
	public void testGetWriter()
	{
		System.out.println("getWriter");
		
		try
		{
		    FileHandler instance = new FileHandler(testfile);
		    OutputStreamWriter resultwriter = instance.getWriter();
		    
		    char[] outtxt = {'i','n','g'};
		    resultwriter.write(outtxt);
		    resultwriter.close();
		    
		    char[] expResult = {'t','e','s','t','i','n','g'};
		    InputStreamReader result = instance.getReader();
		    assertEquals(true,result.ready());
		    
		    char[] ctable = new char[expResult.length];
		    assertEquals(7,result.read(ctable) );
			
		    for (int i=0; i<expResult.length; i++)
		    {
			assertEquals(expResult[i],ctable[i]);
		    }
		}
		catch (FileNotFoundException ex)
		{
		    fail("FileNotFound Exception raised.");
		}
		catch (IOException ex)
		{
		    fail("IO Exception raised.");
		}	
	}
    
}
