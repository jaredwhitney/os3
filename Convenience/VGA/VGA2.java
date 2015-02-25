import javax.imageio.*;
import java.awt.image.*;
import java.awt.*;
import java.io.*;
public class VGA2
{
static boolean gray = false;
public static void main(String[] args) throws Exception
{
gray = args.length > 1 && args[1].equalsIgnoreCase("-g");
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
if (!gray)
{
int red = c.getRed()/85;
int green = c.getGreen()/85;
int blue = c.getBlue()/85;
out.write((blue << 4) | (green << 2) | red);
//System.out.println(c + " -> " + (((int)(c.getRed()/51))*25+((int)(c.getGreen()/51))*5+(int)(c.getBlue()/51)));
image.setRGB(x, y, new Color(red*85, green*85, blue*85).getRGB());
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