ml /c /Fl %1.asm

link %1.obj+m88io.obj,,,,,

exe2bin %1

bin2hex %1.BIN
