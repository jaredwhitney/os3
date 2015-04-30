import java.io.*;
import java.util.*;
import java.nio.file.*;
public class Orca
{
static final byte REG_MASK = 0b111;
static byte[] bytearr = new byte[512];
static boolean mode_32b = true;
static boolean mode_16b = false;
static String a1 = "", a2 = "";
public static void main(String[] args) throws Exception
{
BufferedReader in = new BufferedReader(new FileReader(args[0]));
String inp = in.readLine();
if (inp.replaceAll("\\[","").replaceAll("\\]","").equalsIgnoreCase("bits 16"))
{
mode_32b = false;
mode_16b = true;
}
else if (!inp.replaceAll("\\[","").replaceAll("\\]","").equalsIgnoreCase("bits 32"))
{
System.err.println("Mode not defined as 16 or 32 bits.");
System.exit(0);
}
inp = in.readLine();
Path p = Paths.get("output.bin");
int x = 0;
while (inp != null)
{
if (!inp.equals(""))
{
	inp=inp.trim().replaceAll("\\Q,\\E","");
	String op = inp.split(" ")[0];
	if (inp.split(" ").length >= 2)
		a1 = inp.split(" ")[1];
	if (inp.split(" ").length >= 3)
		a2 = inp.split(" ")[2];
	if (op.equalsIgnoreCase("MOV"))
	{
		if (isReg8(a1) && isReg8(a2))
		{
			bytearr[x] = (byte)0b10001000;
			bytearr[x+1] = (byte)(0b11000000 | (getReg(a2) << 3) | getReg(a1));
			x += 2;
		}
		if (isReg16(a1) && isReg16(a2))
		{
			if (mode_32b)
			{
				bytearr[x] = (byte)0b01100110;
				x++;
			}
			bytearr[x] = (byte)0b10001001;
			bytearr[x+1] = (byte)(0b11000000 | (getReg(a2) << 3) | getReg(a1));
			x += 2;
		}
		if (isReg32(a1) && isReg32(a2))
		{
			if (mode_16b)
			{
				bytearr[x] = (byte)0b01100110;
				x++;
			}
			bytearr[x] = (byte)0b10001001;
			bytearr[x+1] = (byte)(0b11000000 | (getReg(a2) << 3) | getReg(a1));
			x += 2;
		}
		if (isReg8(a1) && isImmediate(a2))
		{
			bytearr[x] = (byte)(0b10110000 | getReg(a1));
			bytearr[x+1] = (byte)getImmediate(a2, x+1, 0xFF, 0, false);
			x += 2;
		}
		if (isReg16(a1) && isImmediate(a2))
		{
			if (mode_32b)
			{
				bytearr[x] = (byte)0b01100110;
				x++;
			}
			bytearr[x] = (byte)(0b10111000 | getReg(a1));
			bytearr[x+1] = (byte)(getImmediate(a2, x+1, 0xFF, 0, false) & 0x00FF);
			bytearr[x+2] = (byte)((getImmediate(a2, x+1, 0xFF00, 8, false) & 0xFF00) >> 8);
			x += 3;
		}
		if (isReg32(a1) && isImmediate(a2))
		{
			if (mode_16b)
			{
				bytearr[x] = (byte)0b01100110;
				x++;
			}
			bytearr[x] = (byte)(0b10111000 | getReg(a1));
			bytearr[x+1] = (byte)( getImmediate(a2, x+1, 0xFF, 0, false) & 0x000000FF);
			bytearr[x+2] = (byte)((getImmediate(a2, x+2, 0xFF00, 8, false) & 0x0000FF00) >> 8);
			bytearr[x+3] = (byte)((getImmediate(a2, x+3, 0xFF0000, 16, false) & 0x00FF0000) >> 16);
			bytearr[x+4] = (byte)((getImmediate(a2, x+4, 0xFF000000, 24, false) & 0xFF000000) >> 24);
			x += 5;
		}
		if (isMemReg(a2))	// this is actually being done in an intelligent, logical way, unlike the previous things...
		{
			String a2s = a2.replaceAll("\\[","").replaceAll("\\]","");
			byte hop = (byte)0x8B;
			int mod = 0;
			if (isReg8(a1))
				hop = (byte)0x8A;
			if ((isReg16(a1) && mode_32b) || (isReg32(a1) && mode_16b))
				bytearr[x++] = (byte)0x66;
			if ((isReg16(a2s) && mode_32b) || (isReg32(a2s) && mode_16b))
				bytearr[x++] = (byte)0x67;
			if (isReg16(a2s))
				mod = 0b100;
			bytearr[x++] = hop;
			bytearr[x++] = (byte)((getReg(a1) << 3) | (getReg(a2s) | mod));
		}
		if (isMemReg(a1))
		{
			String a1s = a1.replaceAll("\\[","").replaceAll("\\]","");
			byte hop = (byte)0x89;
			if (isReg8(a2))
				hop = (byte)0x88;
			if (isReg16(a2) && mode_32b)
				bytearr[x++] = (byte)0x66;
			if (isReg32(a2) && mode_16b)
				bytearr[x++] = (byte)0x66;
			if (isReg32(a1s) && mode_16b)
				bytearr[x++] = (byte)0x67;
			bytearr[x++] = hop;
			bytearr[x++] = (byte)((getReg(a2) << 3) | getReg(a1s));
		}
	}
	if (op.equalsIgnoreCase("POPA"))
	{
		bytearr[x] = (byte)0x61;
		x++;
	}
	if (op.equalsIgnoreCase("PUSHA"))
	{
		bytearr[x] = (byte)0x60;
		x++;
	}
	if (op.equalsIgnoreCase("NOP"))
	{
		bytearr[x] = (byte)0x90;
		x++;
	}
	if (op.equalsIgnoreCase("RET"))
		bytearr[x++] = (byte)0xC3;
	if (op.equalsIgnoreCase("ADD"))
	{
		if (isReg8(a1) && isReg8(a2))
		{
			bytearr[x] = (byte)0x0;
			bytearr[x+1] = (byte)(0xC0 | (getReg(a2) << 3) | getReg(a1));
			x += 2;
		}
		if (isReg16(a1) && isReg16(a2))
		{
			if (mode_32b)
			{
				bytearr[x] = (byte)0x66;
				x++;
			}
			bytearr[x] = (byte)0x1;
			bytearr[x+1] = (byte)(0xC0 | (getReg(a2) << 3) | getReg(a1));
			x += 2;
		}
		if (isReg32(a1) && isReg32(a2))
		{
			if (mode_16b)
			{
				bytearr[x] = (byte)0x66;
				x++;
			}
			bytearr[x] = (byte)0x1;
			bytearr[x+1] = (byte)(0xC0 | (getReg(a2) << 3) | getReg(a1));
			x += 2;
		}
	}
	if (op.equalsIgnoreCase("CALL") || op.equalsIgnoreCase("JMP"))
	{
		byte hop = (byte)0xE8;
		byte mod = (byte)0xD0;
		if (op.equalsIgnoreCase("JMP"))
		{
			hop = (byte)0xE9;
			mod = (byte)0xE0;
		}
		if (isReg(a1))
		{
			if ((isReg32(a1) && mode_16b) || (isReg16(a1) && mode_32b))
				bytearr[x++] = (byte)0x66;
			bytearr[x++] = (byte)0xFF;	// an absolute jump
			bytearr[x++] = (byte)(mod | getReg(a1));
		}
		if (isImmediate(a1))
		{
			long num = getImmediate(a1, x+1, 0xFF, 0, true);
			getImmediate(a1, x+2, 0xFF00, 8, true);
			System.out.print(num + " -- ");
			if (num < x)
			{
				num = 0xFFFD - Math.abs(num - x);		// signing the number
			}
			else
				num = num - x - 3;
			System.out.println(num);
			bytearr[x++] = (byte)hop;	// a relative jump
			bytearr[x++] = (byte) (num & 0x00FF);
			bytearr[x++] = (byte)((num & 0xFF00) >> 8);
		}
	}
	if (contains(inp, ':'))
	{
		new Replacement(inp.replaceAll("\\:","").trim(), x);
	}
	}
	inp = in.readLine();
}
FixLater.fix();
new File("output.bin").createNewFile();
byte[] finalArr = new byte[x];
for (int y = 0; y < x; y++)
	finalArr[y] = bytearr[y];
Files.write(p, finalArr);
}
public static byte getReg(String s)
{
if (s.equalsIgnoreCase("al")||s.equalsIgnoreCase("ax")||s.equalsIgnoreCase("eax"))
return 0b000;
if (s.equalsIgnoreCase("cl")||s.equalsIgnoreCase("cx")||s.equalsIgnoreCase("ecx"))
return 0b001;
if (s.equalsIgnoreCase("dl")||s.equalsIgnoreCase("dx")||s.equalsIgnoreCase("edx"))
return 0b010;
if (s.equalsIgnoreCase("bl")||s.equalsIgnoreCase("bx")||s.equalsIgnoreCase("ebx"))
return 0b011;
if (s.equalsIgnoreCase("ah"))
return 0b100;
if (s.equalsIgnoreCase("ch"))
return 0b101;
if (s.equalsIgnoreCase("dh"))
return 0b110;
if (s.equalsIgnoreCase("bh"))
return 0b111;
System.exit(0);
return 0b000;
}
public static boolean isReg(String s)
{
if (s.equalsIgnoreCase("al")||s.equalsIgnoreCase("ax")||s.equalsIgnoreCase("eax")||s.equalsIgnoreCase("bl")||s.equalsIgnoreCase("bx")||s.equalsIgnoreCase("ebx")||s.equalsIgnoreCase("cl")||s.equalsIgnoreCase("cx")||s.equalsIgnoreCase("ecx")||s.equalsIgnoreCase("dl")||s.equalsIgnoreCase("dx")||s.equalsIgnoreCase("edx")||s.equalsIgnoreCase("ah")||s.equalsIgnoreCase("bh")||s.equalsIgnoreCase("ch")||s.equalsIgnoreCase("dh"))
return true;
return false;
}
public static boolean isReg8(String s)
{
if (s.equalsIgnoreCase("al")||s.equalsIgnoreCase("bl")||s.equalsIgnoreCase("cl")||s.equalsIgnoreCase("dl")||s.equalsIgnoreCase("ah")||s.equalsIgnoreCase("bh")||s.equalsIgnoreCase("ch")||s.equalsIgnoreCase("dh"))
return true;
return false;
}
public static boolean isReg16(String s)
{
if (s.equalsIgnoreCase("ax")||s.equalsIgnoreCase("bx")||s.equalsIgnoreCase("cx")||s.equalsIgnoreCase("dx"))
return true;
return false;
}
public static boolean isReg32(String s)
{
if (s.equalsIgnoreCase("eax")||s.equalsIgnoreCase("ebx")||s.equalsIgnoreCase("ecx")||s.equalsIgnoreCase("edx"))
return true;
return false;
}
public static boolean isImmediate(String s)
{
if (!contains(s,'[') && !isReg(s) && !isMemReg(s))
return true;
return false;
}
public static long getImmediate(String s, long loc, int and, int shift, boolean rel)
{
if (s.contains("0x"))
return Long.parseLong(s.replaceAll("0x",""), 16);
if (s.contains("0b"))
return Long.parseLong(s.replaceAll("0b",""), 2);
if (Character.isDigit(s.charAt(0)))
return Long.parseLong(s);
return Replacement.register(s, loc, and, shift, rel);
}
public static boolean isMemReg(String s)
{
if (contains(s,'[')&&isReg(s.replaceAll("\\[","").replaceAll("\\]","")))
return true;
System.out.println(s.replaceAll("\\[","").replaceAll("\\]",""));
return false;
}
public static boolean contains(String s, char c)
{
for (char p : s.toCharArray())
if (p==c)
return true;
return false;
}
}
class Replacement
{
static ArrayList<Replacement> labels = new ArrayList<Replacement>();
String tag;
long location;
public Replacement(String name, long loc)
{
tag = name;
location = loc;
labels.add(this);
System.out.println("\t" + name + " found at " + loc);
}
public static long getLabel(String lbl)
{
for (Replacement r : labels)
if (r.tag.equals(lbl))
return r.location;
System.out.println("Label not yet defined: " + lbl);
return -1;
}
public static long register(String label, long loc, int and, int shift, boolean rel)
{
if (getLabel(label) != -1)
return getLabel(label);
new FixLater(label, loc, and, shift, rel);
System.out.println("\tMarked for fix later.");
return 0;
}
}
class FixLater
{
static ArrayList<FixLater> elements = new ArrayList<FixLater>();
String label;
long loc;
int and, shift;
boolean relative;
public FixLater(String labe, long lo, int an, int shif, boolean rel)
{
elements.add(this);
label = labe;
loc = lo;
and = an;
shift = shif;
relative = rel;
}
public static void fix()
{
for (FixLater fl : elements)
if (fl.relative)
{
//System.out.println(fl.label + " (" + fl.loc + ") should be " + (((Replacement.getLabel(fl.label)-(2+fl.loc)) & fl.and) >> fl.shift));
Orca.bytearr[(int)fl.loc] = (byte)(((Replacement.getLabel(fl.label)-(2+fl.loc)) & fl.and) >> fl.shift);
}
else
{
//System.out.println(fl.label + " (" + fl.loc + ") should be " + (((Replacement.getLabel(fl.label)) & fl.and) >> fl.shift));
Orca.bytearr[(int)fl.loc] = (byte)(((Replacement.getLabel(fl.label)) & fl.and) >> fl.shift);
}
}
}