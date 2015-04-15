// Dolphin
void	Dolphin.setBackgroundImage(String imageName)
void	Dolphin.showWindow(byte winNum)
void	Dolphin.setSize(byte winNum, int width, int height)
void	Dolphin.setPosition(byte winNum, int x, int y)
void	Dolphin.unregisterWindow(byte winNum)
void	Dolphin.setTitle(byte winNum, String title)
void	Dolphin.drawImage(byte winNum, long image, int x, int y)
void	Dolphin.drawText(byte winNum, long buffer, long bufferSize)
void	Dolphin.requestFocus(byte winNum)
long	Dolphin.getBuffer(byte winNum)
int		Dolphin.getWidth(byte winNum)
int		Dolphin.getHeight(byte winNum)
int		Dolphin.getX(byte winNum)
int		Dolphin.getY(byte winNum)
byte	Dolphin.getType(byte winNum)
byte	Dolphin.createWindow(byte type)
String	Dolphin.getTitle(byte winNum)
boolean	Dolphin.hasFocus(byte winNum)

// Debug
void	Debug.system(Sting message)
void	Debug.warn(String message)
void	Debug.inform(String message)
void	Debug.println(String message)
void	Debug.print(String message)
void	Debug.clear()
void	Debug.show()
void	Debug.hide()

// Minnow
long	Minnow.readFile(String fileName)
long	Minnow.getFileSize(long file)
byte	Minnow.getFileType(long file)
String	Minnow.getFileName(long file)
boolean	Minnow.fileExists(String fileName)

// Guppy
long	Guppy.malloc(int sectors)

// Console
void	Console.setColor(byte color)
void	Console.println(String message)
void	Console.print(String message)
void	Console.clear()
void	Console.exit()
long	Console.getWindow()
byte	Console.getColor()
String	Console.getLine()

// Image
//	NOTE: Images should ALWAYS retain their dimensions at their head!
int		Image.getWidth(long image)
int		Image.getHeight(long image)
void	Image.copyImage(long image)
void	Image.clearImage(long image, byte color)

// Misc
byte	Keyboard.getChar()
boolean	String.equals(String one, String two)
void	System.halt(String panicMessage)
void	Program.register()


/*************** PLANNED ****************/

// Catfish
void	Catfish.notify(String message)
void	Catfish.notify(String title, String message, byte urgency, int lifeTime)
void	Catfish.requestClear()
boolean	Catfish.enable()
boolean	Catfish.disable()

// Minnow (additions)
void	Minnow.nextSector()
void	Minnow.loadSector(int sector)
void	Minnow.write(String fileName, String type, long location, long size)

// Manager
void	Manager.lock()
void	Manager.debugMode()
