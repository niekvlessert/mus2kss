#This creates player.tmp files which will be used by the sjasm ASM files. The value of C will make the chip select in the player engine.
bincut2 -o player_fmpac.tmp -s 7 -p C:1 FST2.BIN
bincut2 -o player_music_module.tmp -s 7 -p C:0 FST2.BIN
