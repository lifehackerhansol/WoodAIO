#!/bin/sh
mkdir data 2>/dev/null
mkdir data/rpg 2>/dev/null
mkdir data/r4 2>/dev/null
mkdir data/r4idsn 2>/dev/null
mkdir elf 2>/dev/null
mkdir elf/rpg 2>/dev/null
mkdir elf/r4 2>/dev/null
mkdir elf/r4idsn 2>/dev/null
$DEVKITARM/bin/arm-eabi-as -o elf/bank_nor_1.elf bank_nor_1.s
$DEVKITARM/bin/arm-eabi-objcopy -O binary elf/bank_nor_1.elf data/bank_nor_1.bin
$DEVKITARM/bin/arm-eabi-as -o elf/bank_nor_2.elf bank_nor_2.s
$DEVKITARM/bin/arm-eabi-objcopy -O binary elf/bank_nor_2.elf data/bank_nor_2.bin
$DEVKITARM/bin/arm-eabi-as -o elf/il2.elf il2.s
$DEVKITARM/bin/arm-eabi-objcopy -O binary elf/il2.elf data/il2.bin
$DEVKITARM/bin/arm-eabi-as -o elf/patch7.elf patch7.s
$DEVKITARM/bin/arm-eabi-objcopy -O binary elf/patch7.elf data/patch7.bin
$DEVKITARM/bin/arm-eabi-as -o elf/patch7wram_sr.elf patch7wram_sr.s
$DEVKITARM/bin/arm-eabi-objcopy -O binary elf/patch7wram_sr.elf data/patch7wram_sr.bin
$DEVKITARM/bin/arm-eabi-as -o elf/repatch.elf repatch.s
$DEVKITARM/bin/arm-eabi-objcopy -O binary elf/repatch.elf data/repatch.bin
$DEVKITARM/bin/arm-eabi-as -o elf/repatch_pokemon.elf repatch_pokemon.s
$DEVKITARM/bin/arm-eabi-objcopy -O binary elf/repatch_pokemon.elf data/repatch_pokemon.bin
$DEVKITARM/bin/arm-eabi-as -o elf/repatch9.elf repatch9.s
$DEVKITARM/bin/arm-eabi-objcopy -O binary elf/repatch9.elf data/repatch9.bin
$DEVKITARM/bin/arm-eabi-as -o elf/unprot_001.elf unprot_001.s
$DEVKITARM/bin/arm-eabi-objcopy -O binary elf/unprot_001.elf data/unprot_001.bin
$DEVKITARM/bin/arm-eabi-as -o elf/unprot_002.elf unprot_002.s
$DEVKITARM/bin/arm-eabi-objcopy -O binary elf/unprot_002.elf data/unprot_002.bin
$DEVKITARM/bin/arm-eabi-as -o elf/unprot_003.elf unprot_003.s
$DEVKITARM/bin/arm-eabi-objcopy -O binary elf/unprot_003.elf data/unprot_003.bin
$DEVKITARM/bin/arm-eabi-as -o elf/unprot_004.elf unprot_004.s
$DEVKITARM/bin/arm-eabi-objcopy -O binary elf/unprot_004.elf data/unprot_004.bin
$DEVKITARM/bin/arm-eabi-as -o elf/unprot_005.elf unprot_005.s
$DEVKITARM/bin/arm-eabi-objcopy -O binary elf/unprot_005.elf data/unprot_005.bin
$DEVKITARM/bin/arm-eabi-as -o elf/unprot_006.elf unprot_006.s
$DEVKITARM/bin/arm-eabi-objcopy -O binary elf/unprot_006.elf data/unprot_006.bin
$DEVKITARM/bin/arm-eabi-as -o elf/unprot_007.elf unprot_007.s
$DEVKITARM/bin/arm-eabi-objcopy -O binary elf/unprot_007.elf data/unprot_007.bin
$DEVKITARM/bin/arm-eabi-as -o elf/unprot_008.elf unprot_008.s
$DEVKITARM/bin/arm-eabi-objcopy -O binary elf/unprot_008.elf data/unprot_008.bin
$DEVKITARM/bin/arm-eabi-as -o elf/unprot_009.elf unprot_009.s
$DEVKITARM/bin/arm-eabi-objcopy -O binary elf/unprot_009.elf data/unprot_009.bin
$DEVKITARM/bin/arm-eabi-as -o elf/unprot_010.elf unprot_010.s
$DEVKITARM/bin/arm-eabi-objcopy -O binary elf/unprot_010.elf data/unprot_010.bin
$DEVKITARM/bin/arm-eabi-as -o elf/unprot_011.elf unprot_011.s
$DEVKITARM/bin/arm-eabi-objcopy -O binary elf/unprot_011.elf data/unprot_011.bin
$DEVKITARM/bin/arm-eabi-as -o elf/unprot_012.elf unprot_012.s
$DEVKITARM/bin/arm-eabi-objcopy -O binary elf/unprot_012.elf data/unprot_012.bin
$DEVKITARM/bin/arm-eabi-as -o elf/unprot_013.elf unprot_013.s
$DEVKITARM/bin/arm-eabi-objcopy -O binary elf/unprot_013.elf data/unprot_013.bin
$DEVKITARM/bin/arm-eabi-as -o elf/unprot_014.elf unprot_014.s
$DEVKITARM/bin/arm-eabi-objcopy -O binary elf/unprot_014.elf data/unprot_014.bin
$DEVKITARM/bin/arm-eabi-as -o elf/unprot_015.elf unprot_015.s
$DEVKITARM/bin/arm-eabi-objcopy -O binary elf/unprot_015.elf data/unprot_015.bin
$DEVKITARM/bin/arm-eabi-as -o elf/unprot_016.elf unprot_016.s
$DEVKITARM/bin/arm-eabi-objcopy -O binary elf/unprot_016.elf data/unprot_016.bin
$DEVKITARM/bin/arm-eabi-as -o elf/unprot_017.elf unprot_017.s
$DEVKITARM/bin/arm-eabi-objcopy -O binary elf/unprot_017.elf data/unprot_017.bin
$DEVKITARM/bin/arm-eabi-as -o elf/unprot_018.elf unprot_018.s
$DEVKITARM/bin/arm-eabi-objcopy -O binary elf/unprot_018.elf data/unprot_018.bin
$DEVKITARM/bin/arm-eabi-as -o elf/unpatch9.elf unpatch9.s
$DEVKITARM/bin/arm-eabi-objcopy -O binary elf/unpatch9.elf data/unpatch9.bin
$DEVKITARM/bin/arm-eabi-as -o elf/sw_cw_ja.elf sw_cw_ja.s
$DEVKITARM/bin/arm-eabi-objcopy -O binary elf/sw_cw_ja.elf data/sw_cw_ja.bin
$DEVKITARM/bin/arm-eabi-as -I ./include/rpg -o elf/rpg/dma4.elf dma4.s
$DEVKITARM/bin/arm-eabi-objcopy -O binary elf/rpg/dma4.elf data/rpg/dma4.bin
$DEVKITARM/bin/arm-eabi-as -I ./include/rpg -o elf/rpg/hb_reset.elf hb_reset.s
$DEVKITARM/bin/arm-eabi-objcopy -O binary elf/rpg/hb_reset.elf data/rpg/hb_reset.bin
$DEVKITARM/bin/arm-eabi-as -I ./include/rpg -o elf/rpg/resetpatch9.elf resetpatch9.s
$DEVKITARM/bin/arm-eabi-objcopy -O binary elf/rpg/resetpatch9.elf data/rpg/resetpatch9.bin
$DEVKITARM/bin/arm-eabi-as -I ./include/rpg -o elf/rpg/save_nand.elf save_nand.s
$DEVKITARM/bin/arm-eabi-objcopy -O binary elf/rpg/save_nand.elf data/rpg/save_nand.bin
$DEVKITARM/bin/arm-eabi-as -I ./include/rpg -o elf/rpg/sd_save.elf sd_save.s
$DEVKITARM/bin/arm-eabi-objcopy -O binary elf/rpg/sd_save.elf data/rpg/sd_save.bin
$DEVKITARM/bin/arm-eabi-as -I ./include/r4 -o elf/r4/dma4.elf dma4.s
$DEVKITARM/bin/arm-eabi-objcopy -O binary elf/r4/dma4.elf data/r4/dma4.bin
$DEVKITARM/bin/arm-eabi-as -I ./include/r4 -o elf/r4/hb_reset.elf hb_reset.s
$DEVKITARM/bin/arm-eabi-objcopy -O binary elf/r4/hb_reset.elf data/r4/hb_reset.bin
$DEVKITARM/bin/arm-eabi-as -I ./include/r4 -o elf/r4/resetpatch9.elf resetpatch9.s
$DEVKITARM/bin/arm-eabi-objcopy -O binary elf/r4/resetpatch9.elf data/r4/resetpatch9.bin
$DEVKITARM/bin/arm-eabi-as -I ./include/r4 -o elf/r4/save_nand.elf save_nand.s
$DEVKITARM/bin/arm-eabi-objcopy -O binary elf/r4/save_nand.elf data/r4/save_nand.bin
$DEVKITARM/bin/arm-eabi-as -I ./include/r4 -o elf/r4/sd_save.elf sd_save.s
$DEVKITARM/bin/arm-eabi-objcopy -O binary elf/r4/sd_save.elf data/r4/sd_save.bin
$DEVKITARM/bin/arm-eabi-as -I ./include/r4idsn -o elf/r4idsn/dma4.elf dma4.s
$DEVKITARM/bin/arm-eabi-objcopy -O binary elf/r4idsn/dma4.elf data/r4idsn/dma4.bin
$DEVKITARM/bin/arm-eabi-as -I ./include/r4idsn -o elf/r4idsn/hb_reset.elf hb_reset.s
$DEVKITARM/bin/arm-eabi-objcopy -O binary elf/r4idsn/hb_reset.elf data/r4idsn/hb_reset.bin
$DEVKITARM/bin/arm-eabi-as -I ./include/r4idsn -o elf/r4idsn/resetpatch9.elf resetpatch9.s
$DEVKITARM/bin/arm-eabi-objcopy -O binary elf/r4idsn/resetpatch9.elf data/r4idsn/resetpatch9.bin
$DEVKITARM/bin/arm-eabi-as -I ./include/r4idsn -o elf/r4idsn/save_nand.elf save_nand.s
$DEVKITARM/bin/arm-eabi-objcopy -O binary elf/r4idsn/save_nand.elf data/r4idsn/save_nand.bin
$DEVKITARM/bin/arm-eabi-as -I ./include/r4idsn -o elf/r4idsn/sd_save.elf sd_save.s
$DEVKITARM/bin/arm-eabi-objcopy -O binary elf/r4idsn/sd_save.elf data/r4idsn/sd_save.bin
cp -a data ../arm9/
