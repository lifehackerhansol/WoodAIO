export LC_ALL=en_US.UTF-8
rm -f waio125g.7z
7z a -r0 -mx=9 -xr0!*/.svn/* -xr0!*/.svn waio125g.7z \
build patch rpglink reset \
build.sh archive.sh buildasm.sh \
getlatestloader.sh get129loader.sh updatelib.sh \
buildcmd2sh.rb GPLv3.txt readme.txt woodrpg.7z
