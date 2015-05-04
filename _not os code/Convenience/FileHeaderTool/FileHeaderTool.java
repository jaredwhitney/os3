import java.io.*;
public class FileHeaderTool
{
	public static void main(String[] args) throws Exception
	{
		File orig = new File(args[0]);
		String oNm = orig.getAbsolutePath();
		String fileType = oNm.split("\\Q.\\E")[oNm.split("\\Q.\\E").length-1];
		String fileName = oNm.split("\\Q.\\E")[0].split("\\Q\\\\E|\\Q/\\E")[oNm.split("\\Q\\\\E|\\Q/\\E").length-1];
		String newFileName = oNm.split("\\Q.\\E")[0] + ".header";
		System.out.println(fileName + " (" + fileType + ") -> " + newFileName);
		File outFile = new File(newFileName);
		outFile.createNewFile();
		FileOutputStream out = new FileOutputStream(outFile);
		if (orig.length() > Integer.MAX_VALUE)
			throw new RuntimeException("FILE TOO LARGE! D:");
		int q = (int)orig.length();
		out.write((byte)((q&0xFF000000)>>24));
		out.write((byte)((q&0x00FF0000)>>16));
		out.write((byte)((q&0x0000FF00)>>8));
		out.write((byte)(q&0x000000FF));
		for (char c : fileType.toCharArray())
		{
			out.write((byte)c);
		}
		out.write(0x0);
		for (char c : fileName.toCharArray())
		{
			out.write((byte)c);
		}
		out.write(0x0);
		out.close();
		Runtime.getRuntime().exec(new String[]{"cmd", "start", "/c", "cat", outFile.getAbsolutePath(), orig.getAbsolutePath(), ">", oNm.split("\\Q.\\E")[0] + ".file"});
	}
}