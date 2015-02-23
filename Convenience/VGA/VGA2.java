import javax.imageio.*;
import java.awt.image.*;
import java.awt.*;
import java.io.*;
public class VGA2
{
public static void main(String[] args) throws Exception
{
BufferedImage img = ImageIO.read(new File(args[0]));
File output = new File(args[0].split("\\Q.\\E")[0] + ".dsp");
output.createNewFile();
FileOutputStream out = new FileOutputStream(output);
BufferedImage image = new BufferedImage(320, 200, BufferedImage.TYPE_INT_RGB);

Image scaled = img.getScaledInstance(320, 200, BufferedImage.SCALE_AREA_AVERAGING);

Graphics2D g = image.createGraphics();
g.drawImage(scaled, 0, 0, 320, 200, null);
g.dispose();
ImageIO.write(image, "bmp", new File("_step.bmp"));
for (int y = 0; y < 200; y++)
{
for (int x = 0; x < 320; x++)
{
Color c = new Color(image.getRGB(x, y));
if (!args[1].equalsIgnoreCase("-g"))
{
if (c.getRed() > 216)
	c = new Color(216, c.getGreen(), c.getBlue());
if (c.getGreen() > 216)
	c = new Color(c.getRed(), 216, c.getBlue());
if (c.getBlue() > 216)
	c = new Color(c.getRed(), c.getGreen(), 216);
out.write(c.getRed()/42*36+c.getGreen()/42*6+c.getBlue()/42);
//System.out.println(c + " -> " + (((int)(c.getRed()/51))*25+((int)(c.getGreen()/51))*5+(int)(c.getBlue()/51)));
image.setRGB(x, y, new Color(((int)(c.getRed()/42))*42, ((int)(c.getGreen()/42))*42, ((int)(c.getBlue()/42))*42).getRGB());
}
else
{
int a = (int)((c.getRed()+c.getBlue()+c.getGreen())/3.0/4.0);
out.write(a);
image.setRGB(x, y, new Color(a*4, a*4, a*4).getRGB());
}
}
}
ImageIO.write(image, "bmp", new File("_step2.bmp"));
}

}