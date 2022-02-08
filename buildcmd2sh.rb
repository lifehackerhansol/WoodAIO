#!/usr/bin/ruby --
cwd=Dir.pwd
Dir.chdir(File.dirname(__FILE__))
open("woodrpg/akloader/patches/build.cmd","r"){|r|
	open("woodrpg/akloader/patches/build.sh","wb"){|w| #because we like LF.
		w.puts "#!/bin/sh"
		while l=r.gets
			if l.length<4 || l[0,4]=="@rem" || l["ak2i"] then next #ak2i: fixme.
			elsif l[0,3]=="@md"
				p=l.split(" ")[1].gsub(/\\/,"/")
				w.puts "mkdir "+p+" 2>/dev/null"
			else
				l.chomp!
				w.puts l[1,l.length-1]
			end
		end
		w.puts "cp -a data ../arm9/" #copy to arm9 source folder
	}
	File.chmod(0755,"woodrpg/akloader/patches/build.sh")
}
Dir.chdir(cwd)
