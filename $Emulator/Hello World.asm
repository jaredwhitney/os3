[bits 32]
dd endt-start
db "TEXT"
db "HELOWRLD"
start :
db "Hello world, I am a text file :)", 0xA0
db "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Proin ac auctor enim. Nunc eu nibh ac urna maximus consectetur "
db "sed vitae sem. Vestibulum fringilla finibus molestie. Cum sociis natoque penatibus et magnis dis parturient montes, "
db "nascetur ridiculus mus. Donec ac convallis ligula. Donec ac rhoncus odio. Integer ultricies efficitur nisl. Suspendisse "
db "vitae tristique quam.", 0xA0, "Vestibulum pulvinar ac sem ac vestibulum. Pellentesque ultrices "
db "et nulla sed interdum. Donec pulvinar diam nunc, eu dignissim tortor venenatis vel. Nulla accumsan lacus sit amet molestie "
db "vehicula. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Nunc vulputate "
db "eget mi quis posuere. Duis vehicula nibh vel magna sodales sodales. Curabitur maximus accumsan nisl, quis massa nunc.", 0x0
endt :