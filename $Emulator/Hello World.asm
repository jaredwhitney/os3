[bits 32]
dd endt-start
db "TEXT"
db "HELOWRLD"
start :
dd "Hello world, I am a text file :)", 0xA0
dd "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Proin ac auctor enim. Nunc eu nibh ac urna maximus consectetur "
dd "sed vitae sem. Vestibulum fringilla finibus molestie. Cum sociis natoque penatibus et magnis dis parturient montes, "
dd "nascetur ridiculus mus. Donec ac convallis ligula. Donec ac rhoncus odio. Integer ultricies efficitur nisl. Suspendisse "
dd "vitae tristique quam.", 0xA0, "Vestibulum pulvinar ac sem ac vestibulum. Pellentesque ultrices "
dd "et nulla sed interdum. Donec pulvinar diam nunc, eu dignissim tortor venenatis vel. Nulla accumsan lacus sit amet molestie "
dd "vehicula. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Nunc vulputate "
dd "eget mi quis posuere. Duis vehicula nibh vel magna sodales sodales. Curabitur maximus accumsan nisl, quis massa nunc."
endt :