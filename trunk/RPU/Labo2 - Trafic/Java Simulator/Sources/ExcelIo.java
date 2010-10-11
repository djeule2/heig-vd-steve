import java.io.*;
/**
*@author Markus Jaton
*@version Software Release 1.0
*
* copyright EINEV 19.06.1997 all right reserved
*
* Permission to use, copy, modify and distribute this software
* and its documentation for NON-COMMERCIAL and NON-PROFIT purpose
* is hereby granted. 
*
* This class is used for generating files that can
* be imported by a spreadsheet. The format is an
* upload format (lines separated by tabs). The separator
* can be redefined if necessary.
* Main purpose of this class is to generate statistic
* files from other programs, and its primary use is
* the telecommunication lab at EINEV
*/
public class	ExcelIo {
	private PrintStream ps;
	private boolean fileOpen = false;
	private int index = 0;
	private char separator = '\t';

	private void sep() { if (index != 0) ps.print(separator); index++; }
	ExcelIo()
		{
		}
	boolean open(String name)
		{
		fileOpen = true;
		try
			{
			FileOutputStream fos = new FileOutputStream(name);
			BufferedOutputStream bos = new BufferedOutputStream(fos);
			ps = new PrintStream(bos);
			}
		catch(IOException ioe) { /* Severe Microsoft bug !!! (throws an invalid exception) */ }
		finally {
			return fileOpen;
			}
		}
	void	close() { ps.close(); }
	public void put(String s) { sep(); ps.print('"' + s + '"'); }
	public void put(int anInt) { sep(); ps.print(anInt); }
	public void put(char aChar) { sep(); ps.print(aChar); }
	public void put(boolean aBool)
		{ sep(); if (aBool) put("TRUE"); else put("FALSE"); }
	public void put(double d)  { sep(); ps.print(d); }
	public void put(float d)  { sep(); ps.print(d); }
	public void eor() { ps.println(); index = 0; }
	public void put()  { eor(); }
	}
