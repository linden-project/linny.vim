desc "release"
task :release do
  print "To release a new version run:\n$ ./release.rb [VERSION]\n"
end

desc "create doc/linny.txt"
task :gen_doc do
  sh "/Users/pim/RnD/forks/vim-tools/html2vimdoc/bin/python /Users/pim/RnD/forks/vim-tools/html2vimdoc.py --file=Linny ./linny_help_source.md > doc/linny.txt"
end

