import java.io.*;
import java.util.*;
public class Jasm
{
static String pname;
static int vnum = 0, lnum = 0;
static ArrayList decs = new ArrayList();
static ArrayList<Var> vars = new ArrayList<Var>();
static String inp = "";
static boolean seq = false;
static boolean ext = false;
public static void main(String[] args) throws Exception
{
if (args.length > 0)
	for (String a : args)
		if (a.equalsIgnoreCase("-e"))
			ext = true;
if (new File("build.cfg").exists())
{
BufferedReader cin = new BufferedReader(new FileReader("build.cfg"));
String nam = cin.readLine();
while (nam!=null)
{
if (nam.contains(".jasm"))
proccess(nam);
else if (nam.contains(".asm"))
Runtime.getRuntime().exec(new String[]{"nasm.exe", "-o " + nam.split("\\Q.\\E")[0] + ".bin", "-f bin", nam}).waitFor();
decs.clear();
vars.clear();
vnum = 0;
nam = cin.readLine();
}
}
else
{
System.err.println("\tNO CONFIG FILE FOUND!\n\tRUNNING IN SIMPLE MODE");
proccess(args[args.length-1]);
}
System.out.println("retval :\ndd 0x0");
}
public static void proccess(String filename) throws Exception
{
BufferedReader in = new BufferedReader(new FileReader(filename));
inp = in.readLine();
while (inp != null)
{
	inp=inp.trim();
	System.out.println("\t\t; " + inp);
	if (inp.contains("$$"))
		inp = "IGNORE";
	if (inp.contains("=") && !inp.contains("if") && !inp.contains("while"))
	{
		if (!contains(inp, '+') && !contains(inp, '-'))
		{
		String tnp = inp+"";
		inp = inp.split("=")[1].trim();
		System.err.println("inp: " + inp+"\ntnp: "+tnp);
		System.out.println("push eax");
		if (ext)
			System.out.println("push ebx");
		System.out.println("mov eax, " + parse(inp));
		inp = tnp;
		if (ext)
		{
			System.out.println("mov ebx, " + pname + "." + inp.split("\\Q=\\E")[0].trim());
			System.out.println("call fmtEBX");
			System.out.println("mov [ebx], eax");
		}
		else
			System.out.println("mov [" + pname + "." + inp.split("\\Q=\\E")[0].trim()+"], eax");
		if (ext)
			System.out.println("pop ebx");
		System.out.println("pop eax");
		boolean mnew = true;
		for (Var v : vars)
			if (v.n.equals(inp.split("\\Q=\\E")[0].trim()))
				mnew = false;
		if (mnew)
			vars.add(new Var(inp.split("\\Q=\\E")[0].trim(), 4));
		}
		else
		{
			String op = "";
			if (contains(inp, '+'))
				op = "add ";
			if (contains(inp, '-'))
				op = "sub ";
			System.out.println("push eax");
			System.out.println("push ebx");
			String[] operands = inp.replaceAll("\\Q+\\E","").replaceAll("\\Q-\\E","").split("\\Q=\\E");
			System.out.println("mov eax, " + parse(operands[0]));
			System.out.println("mov ebx, " + parse(operands[1]));
			System.out.println(op + "eax, ebx");
			System.out.println("mov " + parse(operands[0]) + ", eax");
			System.out.println("pop ebx");
			System.out.println("pop eax");
		}
		inp = "IGNORE";
	}
	if (inp.contains("if ") || inp.contains("while "))
	{
		if (!inp.split(" ")[2].equalsIgnoreCase("seq") && !inp.split(" ")[2].equalsIgnoreCase("seq_mem"))	// seq = String equals
		{
			if (inp.contains("while "))
				System.out.println(pname + ".loop_" + lnum + ".start :");
			System.out.println("push eax");
			System.out.println("push ebx");
			System.out.println("mov eax, " + parse(inp.split(" ")[1].replaceAll("\\(","").replaceAll("\\)","")));
			System.out.println("mov ebx, " + parse(inp.split(" ")[3].replaceAll("\\(","").replaceAll("\\)","")));
			System.out.println("cmp eax, ebx");
			System.out.println("pop ebx");
			System.out.println("pop eax");
			String op = "";
			String ufop=inp.split(" ")[2].trim();
			if (contains(ufop, '='))
				op = "jne";
			if (contains(ufop, '>'))
				op = "jle";
			if (contains(ufop, '=') && contains(ufop, '>'))
				op = "jl";
			if (contains(ufop, '<'))
				op = "jge";
			if (contains(ufop, '=') && contains(ufop, '<'))
				op = "jg";
			if (contains(ufop, '=') && contains(ufop, '!'))
				op = "je";
			System.out.println(op + " " + pname + ".loop_" + lnum + ".end");
		}
		else
		{
			System.out.println("pusha");
			if (inp.split(" ")[2].equalsIgnoreCase("seq_mem"))
			System.out.println("mov eax, " + parse(inp.split(" ")[1].replaceAll("\\(","").replaceAll("\\)","")));
			else
			System.out.println("mov eax, " + parse(inp.split(" ")[1].replaceAll("\\(","").replaceAll("\\)","")).replaceAll("\\[","").replaceAll("\\]",""));
			/*System.out.println("mov ebx, eax");
			System.out.println("push eax");
			System.out.println("mov ah, 0xB");
			System.out.println("call console.println");*/
			System.out.println("mov ebx, " + parse(inp.split(" ")[3].replaceAll("\\(","").replaceAll("\\)","")).replaceAll("\\[","").replaceAll("\\]",""));
			//System.out.println("call console.println");
			//System.out.println("pop eax");
			System.out.println(pname + ".loop_" + lnum + ".start :");
			System.out.println("mov cl, [eax]");
			System.out.println("mov dl, [ebx]");
			System.out.println("cmp cl, dl");
			System.out.println("jne " + pname + ".loop_" + lnum + ".end");
			System.out.println("cmp cl, 0");
			System.out.println("je " + pname + ".loop_" + lnum + ".go");
			System.out.println("add eax, 1");
			System.out.println("add ebx, 1");
			/*System.out.println("pusha ;begin testing");
			System.out.println("mov bh, 0xB");
			System.out.println("mov bl, 'K'");
			System.out.println("call console.cprint");
			System.out.println("popa ;testing end");*/
			System.out.println("jmp " + pname + ".loop_" + lnum + ".start");
			System.out.println(pname + ".loop_" + lnum + ".go :");
			System.out.println("popa");
			seq = true;
			System.err.println("\tWROTE A SEQ LOOP!");
		}
	}
	if (inp.contains("endif"))
	{
		if (seq)
		{
			System.out.println("jmp " + pname + ".loop_" + lnum + ".EQend");
		}
		System.out.println(pname + ".loop_" + lnum + ".end :");
		if (seq)
		{
		System.out.println("popa");
		System.out.println(pname + ".loop_" + lnum + ".EQend :");
		seq = false;
		}
		lnum++;
	}
	if (inp.contains("endwhile"))
	{
		System.out.println("jmp " + pname + ".loop_" + lnum + ".start");
		System.out.println(pname + ".loop_" + lnum + ".end :");
		lnum++;
	}
	if (inp.contains("class")&&inp.indexOf("class")==0)
	{
		System.err.println("Define class " + inp.split(" ")[1]);
		pname = inp.split(" ")[1];
	}
	if (inp.contains("{"))
	{
		System.err.println("Group open");
	}
	if (inp.contains("}"))
	{
		System.err.println("Group close.");
	}
	if (inp.contains("func"))
	{
		System.err.println("Method declare");
		//System.err.println("Method declare: [" + inp.split(" ")[1] + "] " + inp.split(" ")[2].split("\\(")[0] + " {" + inp.split("\\(")[1].split("\\)")[0] + "}");
		System.out.println(pname + "." + inp.split(" ")[2].split("\\(")[0] + " :");
		System.out.println("pusha");
	}
	else if (contains(inp, '(') && !inp.contains("if") && !inp.contains("while"))
	{
		callmthd();
	}
	if (inp.contains("return ")&&inp.indexOf("return ")==0)
	{
		System.err.println("<- " + inp.split("return ")[1]);
		System.out.println("mov eax, " + parse(inp.split("return ")[1].replaceAll("\\Q;\\E","")));
		if (ext)
		{
			System.out.println("push ebx");
			System.out.println("mov ebx, retval");
			System.out.println("fmtEBX");
			System.out.println("mov [ebx], eax");
			System.out.println("pop ebx");
		}
		else
			System.out.println("mov [retval], eax");
		System.out.println("popa");
		System.out.println("ret");
	}
	inp = in.readLine();
}
System.out.println();
for (int x = 0; x < vars.size(); x++)
{
System.out.println(pname + "." + vars.get(x).n+" :");
System.out.print("db ");
for (int p = vars.get(x).s-1; p > 0; p--)
System.out.print("0, ");
System.out.println("0");
}
for (int x = 0; x < decs.size(); x++)
{
System.out.println(pname + ".var_"+x+" :");
System.out.println("db " + decs.get(x));
}
}
	public static void callmthd()
	{
		System.err.println("Method call: " + inp);
		//System.err.println(inp.split("\\(")[1].split("\\)")[0]+"->"+inp.split("\\(")[0]);
		if (!inp.split("\\(")[1].split("\\)")[0].equals("null"))
		{
		System.out.println("push ebx");
		System.out.println("mov ebx, " + parse(inp.split("\\(")[1].split("\\)")[0]));
		}
		System.out.println("call " + mlookup(inp.split("\\(")[0]));
		if (!inp.split("\\(")[1].split("\\)")[0].equals("null"))
		System.out.println("pop ebx");
	}
public static boolean contains(String s, char c)
{
for (char t : s.toCharArray())
	if (t==c)
		return true;
return false;
}
public static String parse(String s)
{
boolean string = false;
s=s.trim();
if (s.contains("STRING:"))
{
	s = s.replaceAll("STRING:", "");
	string = true;
}
if (contains(s, '(')  && contains(s, ')'))
{
	callmthd();
	return "[retval]";
}
if (Character.isDigit(s.charAt(0)))
return s;
if (s.contains("\""))
{
decs.add(s+", 0");
return pname+".var_"+vnum++;
}
else
{
for (Var v : vars)
{
System.err.println(s + ", " + v.n);
if (s.equals(v.n))
if (!string)
	return "[" + pname+"."+v.n + "]";
else
	return pname + "." + v.n;
}
}
if (s.equals("os.platform"))
return "[0x1000]";
if (s.equals("os.EMULATOR"))
return "0xF";
if (s.equals("os.return"))
return "retfunc";
if (s.equals("Dolphin.screenWidth"))
return "[Graphics.SCREEN_WIDTH]";
if (s.equals("Dolphin.screenHeight"))
return "[Graphics.SCREEN_HEIGHT]";
System.err.println("Unrecognized token: " + s);
return pname + "." + s;	// assume its a method
}

public static String mlookup(String s)
{
if (s.equals("print"))
return "console.print";
else if (s.equals("println"))
return "console.println";
else if (s.equals("print_num"))
return "console.numOut";
else if (s.equals("newl"))
return "console.newline";
else if (s.equals("cls"))
return "console.clearScreen";
else if (s.equals("catch_enter"))
return "os.setEnterSub";
else if (s.equals("getLine"))
return "console.getLine";
else if (s.equals("print_mem"))
return "console.printMem";
else if (s.equals("color"))
return "console.setColor";
else if (s.equals("setWidth"))
return "console.setWidth";
else if (s.equals("setHeight"))
return "console.setHeight";
else if (s.equals("setPos"))
return "console.setPos";
else if (s.equals("toggleDebug"))
return "debug.toggleView";
else if (s.equals("update_bg"))
return "Dolphin.redrawBG";
else if (s.equals("View.file"))
return "View.file";
else if (s.equals("String.mem"))
return "os.String.removeColor";
else if (s.equals("Minnow.tree"))
return "Minnow.ctree";
else if (s.equals("console.test"))
return "console.test";
else if (s.equals("console.memstat"))
return "console.memstat";
else if (s.equals("Manager.lock"))
return "Manager.lock";
else if (contains(s, '.'))
return s;
else
return pname + "." + s;
}
}
class Var
{
String n;
int s;
public Var(String name, int size)
{
n = name;
s = size;
}
}