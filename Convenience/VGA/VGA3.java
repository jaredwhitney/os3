import javax.imageio.*;
import java.awt.image.*;
import java.awt.*;
import java.io.*;
public class VGA3
{
public static void main(String[] args) throws Exception
{
BufferedImage img = ImageIO.read(new File(args[0]));
int WIDTH = 67;
int HEIGHT = 67;
File output = new File(args[0].split("\\Q.\\E")[0] + ".vesa.dsp");
output.createNewFile();
FileOutputStream out = new FileOutputStream(output);
BufferedImage image = new BufferedImage(WIDTH, HEIGHT, BufferedImage.TYPE_INT_RGB);

Image scaled = img.getScaledInstance(WIDTH, HEIGHT, BufferedImage.SCALE_AREA_AVERAGING);

Graphics2D g = image.createGraphics();
g.drawImage(scaled, 0, 0, WIDTH, HEIGHT, null);
g.dispose();
ImageIO.write(image, "bmp", new File("_step.bmp"));
for (int y = 0; y < HEIGHT; y++)
{
for (int x = 0; x < WIDTH; x++)
{
Color c = new Color(image.getRGB(x, y));
int red = c.getRed();
int green = c.getGreen();
int blue = c.getBlue();
out.write(blue);
out.write(green);
out.write(red);
out.write(0x0);
image.setRGB(x, y, new Color(red, green, blue).getRGB());
}
}
ImageIO.write(image, "bmp", new File("_step2.bmp"));
}

}