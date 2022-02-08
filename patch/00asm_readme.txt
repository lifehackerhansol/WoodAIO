*** How to build *.bin ***

0. If you are using *nix(including OSX), execute buildcmd2sh.rb to generate build.sh.
1. Copy *.s and *.s to woodrpg/akloader/patches/include/r4/.
2. Execute build.bat or build.sh.
3. Copy woodrpg/akloader/patches/data/r4/{save_nand.bin,sd_save.bin} to woodrpg/akloader/arm9/data/r4/.

Now setting final offset is done automatically.

dstt/* has two issues.
1. Code runs only on SCDSONEi.
2. Saver doesn't work.
Therefore binary isn't included in the package.
