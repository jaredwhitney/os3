import java.util.*;						// NOTE:: $END tag is not yet added!~
import java.io.*;
import java.util.Map.Entry;

public class OrcaHLL
{
	static Stack<Container> level = new Stack<Container>();
	static String pName, pTitle, inp;
	static String programCode = "";
	static Map<String, Var> vars = new HashMap<String, Var>();
	static Map<String, Type> defTypes = new HashMap<String, Type>();
	static boolean preRunFinished = false;
	static int scount = 0;
	static boolean wasLastValString;
	static int line = 0;
	
	public static void main(String[] args) throws Exception
	{
		Scanner in = new Scanner(new File(args[0]));
		inp = in.nextLine();
		line++;
		int last = 0;
			defTypes.put("char", Type.Char);
			defTypes.put("int", Type.Int);
			defTypes.put("String", Type.String);
		while (inp != null)
		{
			if (!inp.trim().equals(""))	// ignore empty lines
			{
				inp = inp.split(";")[0];
				int tabs = getTabCount();
				System.out.println("LINE_" + line + ": " + inp.trim());
				String[] words = inp.trim().split(" ");
				for (int q = 0; q < words.length; q++)
					words[q] = words[q].trim();
				if (tabs < last)
					closeLast(inp);
				if (words[0].equals("func"))
					makeFunc(inp);
				else if (words[0].equals("program"))
					makeProgram(inp);
				else if (words[0].charAt(0)=='#')
					handleDirective(inp);
				else
				{
					String cvName = inp.split(" ")[0].trim();
					if (cvName.split("\\Q.\\E").length > 0)
						cvName = cvName.split("\\Q.\\E")[0];
					Var vName = lookupVar(cvName);
					String rest = inp.split("\\Q" + cvName + "\\E")[1].trim();
					char fchar = rest.charAt(0);
					if (vName != null)
					{
						System.out.println("\tDeal with " + cvName + "[" + vName.Container + "]");
						if (fchar == '=')
						{
							rest = rest.substring(1, rest.length()).trim();
							System.out.println("\tSet [" + vName.name + "] to '" + rest + "'");
							if (vName.Container.equals("String"))
							{
								programCode += tabs() + "push dword " + vName.name + "\n";
								
							}
							else 
							{
								System.err.println("uwot? '" + rest + "'");
								String nVal = handleValue(rest);
								programCode += tabs() + "mov [" + vName.name + "], " + nVal + "\n\n";
							}
						}
						else if (fchar == '.') 
						{
							if (!contains(inp, '='))
							{
								handleArguments(inp);
							
								String func = handleRef(rest, vName);
								
								System.out.println("\tCall method '" + func + "' on object [" + vName.name + "]");
								
								programCode += tabs() + "push word [System.function], Meta." + vName.Container + "." + func + "\n" + tabs() + "int 0x30\n\n";
							}
							else
							{
								String thing = rest.split(" ")[0].trim();
								thing = thing.substring(1, thing.length());
								rest = inp.split("\\Q=\\E")[1].trim();
								grabSubVar(vName, thing);
								String value = handleValue(rest);
								System.out.println("\tSet " + thing + " of [" + vName.name + "] to '" + value + "'");
								programCode += tabs() + "push dword " + value + "\n";
								if (wasLastValString)
								{
									programCode += tabs() + "mov word [System.function], Meta.String.Copy\n" + tabs() + "int 0x30\n\n";
								}
								else	// setting a ref equal to a non-String value (ik, ik... should just be a getVar() thing)
								{
									//handleValue();	// blarg!
								}
							}
						}
					}
					else
					{
						if (!contains(inp, '='))
						{
							handleArguments(inp);
							String func = inp.split("\\Q(\\E")[0].trim();
							System.out.println("\tCall static method '" + func + "'");
							programCode += tabs() + "push word [System.function], Meta." + func + "\n" + tabs() + "int 0x30\n\n";
							System.out.println("\tStatic? : " + inp.trim());
						}
						else 	// need to make sure it won't attempt to do this with Strings etx!
						{
							// handle it properly please!
						}
					}
				}
				last = tabs;
			}
			try
			{
				inp = in.nextLine();
				line++;
			}
			catch (NoSuchElementException e)
			{
				break;
			}
		}
		while (!level.isEmpty())
			closeLast(inp);
		for (Entry<String, Var> q : vars.entrySet())
		{
			programCode += q.getValue().name + " :\n\td" + lookupMc(q.getValue().Container) + " ";
			if (q.getValue() instanceof StringVar)
				programCode += "\"" + ((StringVar)q.getValue()).val.replaceAll("\\Q\\n\\E", "\", 0xA, \"") + "\", 0\n";
			else
				programCode += "0x0\n";
		}
		
		programCode += tabs() + "\n\n$" + pName + "_END :\n";
		PrintWriter out = new PrintWriter(new FileOutputStream(new File(args[0].replaceAll("\\Q.orca\\E", "") + ".asm")));
		out.println(programCode);
		out.close();
		if (level.size() > 0)
			System.err.println("Something is mismatched :/");
	}
	
	static String handleRef(String s, Var vName)
	{
		String ret = s.split("\\Q.\\E")[1].split("\\Q(\\E")[0];
		programCode += tabs() + "mov ebx, [" + pName + ".$memLoc]\n" + tabs() + "add ebx, [" + vName.name + "]\n";
		return ret;
	}
	
	static String tabs()
	{
		String ret = "";
		for (int x = 1; x < level.size(); x++)
			ret += "\t";
		return ret;
	}
	
	static void handleArguments(String inp)
	{
		// write this!
		String[] things = inp.split("\\Q(\\E");
		String noSplitArgs = "";
		for (int a = 1; a < things.length; a++)
			noSplitArgs += "(" + things[a];
		String[] args = noSplitArgs.trim().split(",");
		for (int a = 0; a < args.length; a++)	// trim all arguments
			args[a] = args[a].trim();
		args[0] = args[0].substring(1, args[0].length());	// remove leading '('
		args[args.length-1] = args[args.length-1].substring(0, args[args.length-1].length()-1);	// remove trailing ')'
		for (int a = 0; a < args.length; a++)
		{
			if (!args[a].equals(""))
			{
				System.out.println("\t\tHandle arg: " + args[a]);
				String val = handleValue(args[a]);
				programCode += tabs() + "push dword " + val + "\n";
			}
		}
		programCode += "\n";
	}
	
	static void grabSubVar(Var hVar, String subName)
	{
		programCode += tabs() + "mov ebx, [" + pName + ".$memLoc]\n" + tabs() + "add ebx, [" + hVar.name + "]\n" + tabs() + "add ebx, [Meta." + hVar.Container + ".offs." + subName + "]\n\n";
	}
	
	static char lookupMc(String s)
	{
		try
		{
			return defTypes.get(s).mod;
		}
		catch (Exception e)
		{
			return 'd';
		}
	}
	
	static Var lookupVar(String name)
	{
		try
		{
			return vars.get(name);
		}
		catch (Exception e)
		{
			return null;
		}
	}
	
	static int getTabCount()
	{
		int tcount = 0;
		for (char c : inp.toCharArray())
		{
			if (c!='\t')
				break;
			tcount++;
		}
		return tcount;
	}
	
	static boolean contains(String s, char c)
	{
		char[] carr = s.toCharArray();
		for (char q : carr)
			if (q==c)
				return true;
		return false;
	}
	
	static void makeFunc(String inp)
	{
		if (!preRunFinished)
		{
			programCode += "ret\n\n";
			preRunFinished = true;
		}
		String name = inp.split(" ")[1].trim();
		String rets = inp.split("\\Q(\\E")[1].split(":")[0].trim();
		String params = inp.split(":")[1].split("\\Q)\\E")[0].trim();
		
		level.push(new Container(Container.FUNC, name, rets, params));
		System.out.println("\tMake func '" + name + "' (accepts: " + params + ") (returns: " + rets + ")");
		programCode += pName + "." + name + " :\n\n";
		String[] paramArr = params.split(",");
		for (int y = paramArr.length-1; y >= 0; y--)	// need to be popped backwards!
		{
			if (paramArr[y].equals("null"))
				break;
			String param = paramArr[y];
			
			param = param.trim();
			Var v = new Var(param.split(" ")[0], pName + ".$local." + name + "." + param.split(" ")[1]);
			vars.put(param.split(" ")[1], v);

			programCode += tabs() + "pop ebx\n" + tabs() + "mov [" + v.name + "], ebx\n";
		}
	}
	
	static void closeLast(String inp)
	{
		Container thing = level.pop();
		System.out.println("\tClosing [" + thing.Container + ", " + thing.name + "]");
		if (thing.Container==0)
		{
			// TO-DO: Handle non-void return values!
			programCode += "ret\n\n";
		}
	}
	
	static void handleDirective(String inp)
	{
		String temp = inp.split(" ")[0].trim();
		String dir = temp.substring(1, temp.length());
		System.out.println("\tPreproccess " + dir);
		if (dir.equals("pre-alloc"))
			programCode += "\t; Pre-alloc\n\tmov ebx, " + inp.split("\\Q[\\E")[1].split(",")[0].split("\\Q]\\E")[0] + "\n\tmov word [System.function], Meta.Guppy.Malloc\n\tint 0x30\n\tmov [" + pName + ".$memLoc], ecx\n\n";
		else if (dir.equals("request"))
			programCode += "\t; Permission\n\tmov eax, Meta." + inp.split("\\Q[\\E")[1].split("\\Q]\\E")[0] + "\n\tmov word [System.function], Meta.Manager.Request\n\tint 0x30\n\n";
		else if (dir.equals("global"))
		{
			//programCode += "\t; Global\n\tmov ebx, [" + pName + ".$memLoc]\n\tadd ebx, [" + pName + ".$obj_createOffs]\n\tmov [" + pName + ".$global." + inp.split("\\Q[\\E")[1].split(" ")[1].split("\\Q]\\E")[0].trim() + "], ebx\n\tmov ebx, [" + pName + ".$obj_createOffs]\n\tadd ebx, [Meta." + inp.split("\\Q[\\E")[1].split(" ")[0].trim() + ".SIZE]\n\tmov [" + pName + ".$obj_createOffs], ebx\n\n";
			String thing = inp.split("\\Q[\\E")[1].split(" ")[1].split("\\Q]\\E")[0].trim();
			vars.put(thing, new Var(inp.split("\\Q[\\E")[1].split(" ")[0].trim(), pName + ".$global." + thing));
		}
	}
	
	static void makeVarHRefLocal(String reg)
	{
		programCode += tabs() + "sub " + reg + ", [" + pName + ".$memLoc]\n";
	}
	
	static void createVar(String inp)
	{
		inp = inp.replaceAll("new", "").trim();
		String type = inp.split("\\Q(\\E")[0].trim();
		handleArguments(inp);
		programCode += tabs() + "mov ebx [" + pName + ".$memLoc]\n" + tabs() + "add ebx [" + pName + ".$obj_createOffs]\n\n";
		programCode += tabs() + "push word [System.function], Meta." + type + ".Create\n" + tabs() + "int 0x30\n\n";
	}
	
	static String handleValue(String val)
	{
		wasLastValString = false;
		String[] words = val.trim().split(" ");
		if (words.length > 0 && words[0].trim().equals("new"))
		{
			System.out.println("Handle object creation of '" + val + "'");	// blarg!
			createVar(val);
			makeVarHRefLocal("ecx");
			return "ecx";
		}
		else if (contains(val, '\"')  && !contains(val, '('))
		{
			StringVar s = new StringVar(pName + ".$final.String_" + scount, val.replaceAll("\\Q\"\\E", ""));
			System.out.println("\tCreate new String!");
			vars.put("$UNUSED_NAME_" + scount, s);
			scount++;
			wasLastValString = true;
			return s.name;
		}
		else if (contains(val, '('))
		{
			if (contains(val, '.'))	// function with a ref call
			{
				Var v = lookupVar(val.split("\\Q.\\E")[0]);
				if (v == null)
					ThrowError("Reference to member of a non-existant object (" + val.split("\\Q.\\E")[0] + ")");	// this shouold not throw an error, might be a static call
				handleArguments(val);
				String func = handleRef(val, v);
				programCode += tabs() + "push word [System.function], Meta." + v.Container + "." + func + "\n" + tabs() + "int 0x30\n";
				System.out.println("\tK, got " + func);
				return "ecx";
			}
			// and what about functions that don't contain reference calls? :/
		}
		else if (contains(val, '<'))
		{
			return pName + "." + val.substring(1, val.length()-1);
		}
		try
		{
			return "[" + vars.get(val).name + "]";
		}
		catch (Exception e)
		{
			if (Character.isDigit(val.charAt(0)))
				return val;	// better be a literal :/
			Var v = lookupVar(val.split("\\Q.\\E")[0]);
			if (v!=null)
			{
				String q = val.split(val.split("\\Q.\\E")[0])[1].trim();
				grabSubVar(v, q.substring(1, q.length()));
				return "ebx";
			}
			return "[Meta." + val + "]";	// welp, hope its actually in Meta...
		}
	}
	
	static boolean isRef(String s)
	{
		return contains(s, '[');
	}
	
	static void makeProgram(String inp)
	{
		pName = inp.split(" ")[1];
		pTitle = inp.split("\"")[1].split("\"")[0];
		System.out.println("\tMake program '" + pName + "' (" + pTitle + ")");
		level.push(new Container(Container.PROGRAM, pName, pTitle));
		programCode += "[bits 32]\ndd $" + pName + "_END - $" + pName + "_START\ndb \"OrcaHLLex\", 0\ndb \"" + pTitle + "\", 0\n$" + pName + "_START :\n\ndd " + pName + "._init\t; pointer to the _init function\n\n" + pName + ".$PRE_RUN :\n\n";
		
		vars.put("$OBJ_CREATEOFFS", new Var("int", pName + ".$obj_createOffs"));
		vars.put("$MEMLOC", new Var("int", pName + ".$memLoc"));
		
	}
	static void ThrowError(String s)
	{
		System.err.println("\n[Line " + line + "] ERROR: " + s);
		System.exit(0);
	}
}

class Container
{
	int Container;
	String name;
	Object[] attribs;
	static final int FUNC = 0, PROGRAM = 1, IF = 2, WHILE = 3, FOR = 4;
	public Container(int Container, String name, Object... attribs)
	{
		this.Container = Container;
		this.name = name;
		this.attribs = attribs;
	}
}

class Var
{
	String Container, name;
	public Var(String Container, String name)
	{
		this.Container = Container;
		this.name = name;
	}
}

class StringVar extends Var
{
	String val;
	public StringVar(String name, String val)
	{
		super("String", name);
		this.val = val;
	}
}

class Type
{
	int size;
	char mod;
	static final Type Char = new Type(1, 'b');
	static final Type Int = new Type(4, 'd');
	static final Type String = new Type(-1, 'b');
	
	public Type(int size, char mod)
	{
		this.size = size;
		this.mod = mod;
	}
}