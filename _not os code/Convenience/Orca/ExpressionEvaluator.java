public class ExpressionEvaluator
{
	public static void main(String[] args)
	{
		System.out.print("Expression:\t");
		long val = eval(new java.util.Scanner(System.in).nextLine());
		System.out.println("\n" + val);
	}
	public static long eval(String exp)
	{
		exp = exp.trim();
		if (isPlainNum(exp))
			return Long.parseLong(exp);
		String arg0 = "";
		for (int ind = 0; ind < exp.length(); ind++)
		{
			char c = exp.charAt(ind);
			if (c=='(')
			{
				int end = -1;
				for (end = ind; end < exp.length(); end++)
					if (exp.charAt(end)==')')
						break;
				System.out.println("Need to eval: " + exp.substring(ind+1, end));
				eval(exp.substring(ind+1, end));
			}
			else if (c=='*' || c=='/')
			{
				
			}
			else
				arg0 += c;
		}
		return -1;
	}
	public static boolean isPlainNum(String s)
	{
		for (char c : s.toCharArray())
			if (!Character.isDigit(c) && c!='x' && c!='b')
				return false;
		return true;
	}
}