/*
 * FileHandler.java
 *
 * Created on March 24, 2007, 9:40 AM
 *
 * To change this template, choose Tools | Template Manager
 * and open the template in the editor.
 */

package coreedit;

import java.io.IOException;
import java.io.FileNotFoundException;
import java.io.File;
import java.io.FileReader;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;

/**
 *
 * @author alex
 */
public class FileHandler {
    
    /** Creates a new instance of FileHandler */
    public FileHandler(String filename) {
	this(new File(filename,"rws"));
    }
    
    public FileHandler(File f) {
	    currentFile = f;
    }
    
    public boolean createNew() throws IOException {
	return currentFile.createNewFile();
    }
    
    public FileInputStream getInputStream() throws FileNotFoundException {
	return new FileInputStream(currentFile);
    }
    
    public InputStreamReader getReader() throws FileNotFoundException {
	return new InputStreamReader(getInputStream());
    }
    
    public FileOutputStream getOutputStream() throws FileNotFoundException {
	return new FileOutputStream(currentFile);
    }
    
    public OutputStreamWriter getWriter() throws FileNotFoundException {
	return new OutputStreamWriter(getOutputStream());
    }
    
    private File currentFile = null;    
}
