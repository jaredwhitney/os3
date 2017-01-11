import java.io.*;
import java.nio.file.*;
import java.util.*;
public class MapFormatter
{
	public static void main(String[] args) throws Exception
	{
		PrintStream out = System.out;
		String fileText = new String(Files.readAllBytes(Paths.get("labels.map")));
		String labelList = fileText.split("\\QReal              Virtual           Name\r\n\\E")[1].split("\r\n\r\n")[0];
		int num = 0;
		String[] lines = labelList.split("\n");
		out.println("Debug.methodTraceLookupTable :");
		for (String line : lines)
		{
			line = line.substring(16, line.length()).trim();
			String[] parts = line.split("\\Q  \\E");
			out.println("dd 0x" + parts[0]);
			out.println("dd __traceString" + num);
			lines[num] = parts[1];
			num++;
		}
		num = 0;
		out.println("Debug.methodTraceStringTable :");
		for (String line : lines)
		{
			out.println("__traceString" + num + " :");
			out.println("db \"" + line + "\", 0");
			num++;
		}
	}
}