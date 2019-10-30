task :default => [:test]

desc "bump"
task :bump, [:new_version] do |task, args|
  if args[:new_version]
    version_bump(args[:new_version])
  else
    puts "Error: Version number required\n"
    puts
    puts "Usage: to bump a new version run: rake bump[0.0.0]"
  end
end

desc "release"
task :release, [:new_version] do |task, args|
  if args[:new_version]
    git_release(args[:new_version])
  else
    puts "Error: Version number required\n"
    puts
    puts "Usage: to release a new version run: rake release[0.0.0]"
  end
end

desc "create doc/linny.txt"
task :gen_doc do
  sh "/Users/pim/RnD/forks/vim-tools/html2vimdoc/bin/python /Users/pim/RnD/forks/vim-tools/html2vimdoc.py --file=Linny ./linny_help_source.md > doc/linny.txt"
end

desc "test"
task :test do
  sh "test/run"
end

def version_bump(new_version)
  if new_version

    current_version = `grep return autoload/linny_version.vim | cut -d"'" -f2`.gsub("\n","")

    files = [
      "autoload/linny_version.vim",
      "test/feature/mapping.vader"
    ]

    files.each do |filename|
      puts "Updating version numbers in #{filename}"
      `sed -i.bak -e "s/#{current_version}/#{new_version}/" #{filename}`
    end
  end
end

def git_release(new_version)

  name = File.basename(Dir.getwd)
  message = "Bumped version number to v#{new_version}." # unless message = ARGV[1]
  puts "git commit -am \"#{message}\""
  `git commit -am "#{message}"`
  `git push`
  puts "git tag -a v#{new_version} -m \"#{name} v#{new_version}\""
  `git tag -a v#{new_version} -m "#{name} v#{new_version}"`
  puts "git push origin v#{new_version}"
  `git push origin v#{new_version}`
end

