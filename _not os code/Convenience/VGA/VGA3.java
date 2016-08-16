import javax.imageio.*;
import java.awt.image.*;
import java.awt.*;
import java.io.*;
public class VGA3
{
public static void main(String[] args) throws Exception
{
BufferedImage img = ImageIO.read(new File(args[0]));
int WIDTH = img.getWidth();
int HEIGHT = img.getHeight();
File output = new File(args[0].split("\\Q.\\E")[0] + ".rawimage");
output.createNewFile();
FileOutputStream out = new FileOutputStream(output);
out.write(WIDTH&0xFF);
out.write(WIDTH>>8&0xFF);
out.write(WIDTH>>16&0xFF);
out.write(WIDTH>>24&0xFF);
out.write(HEIGHT&0xFF);
out.write(HEIGHT>>8&0xFF);
out.write(HEIGHT>>16&0xFF);
out.write(HEIGHT>>24&0xFF);
BufferedImage image = new BufferedImage(WIDTH, HEIGHT, BufferedImage.TYPE_INT_ARGB);

Image scaled = img.getScaledInstance(WIDTH, HEIGHT, BufferedImage.SCALE_AREA_AVERAGING);

Graphics2D g = image.createGraphics();
g.drawImage(scaled, 0, 0, WIDTH, HEIGHT, null);
g.dispose();
ImageIO.write(image, "png", new File("_step.png"));
for (int y = 0; y < HEIGHT; y++)
{
for (int x = 0; x < WIDTH; x++)
{
Color c = new Color(image.getRGB(x, y));
int red = c.getRed();
int green = c.getGreen();
int blue = c.getBlue();
int alpha = (int)(((long)(image.getRGB(x, y))&0xFF000000l)>>24);
//System.out.println(((long)(image.getRGB(x, y))&0xFF000000l)>>24);
out.write(blue);
out.write(green);
out.write(red);
out.write(alpha);
image.setRGB(x, y, new Color(red, green, blue, alpha).getRGB());
}
}
ImageIO.write(image, "png", new File("_step2.png"));
}

}