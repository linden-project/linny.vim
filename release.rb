#!/usr/bin/env ruby

name = File.basename(Dir.getwd)

if new_version = ARGV[0]

  files = ["VERSION.txt"]
  files.each do |filename|
    puts "Updating version numbers in #{filename}"
    `echo #{new_version} > #{filename}`
  end

  message = "Bumped version number to v#{new_version}." unless message = ARGV[1]
  puts "git commit -am \"#{message}\""
  `git commit -am "#{message}"`
  `git push`
  puts "git tag -a v#{new_version} -m \"#{name} v#{new_version}\""
  `git tag -a v#{new_version} -m "#{name} v#{new_version}"`
  puts "git push origin v#{new_version}".colorize(:yellow)
  `git push origin v#{new_version}`
else
  puts "Error: Version number required\n"
  puts "release.sh 0.1.1"
  puts "or"
  puts "release.sh 0.1.1 \"Commit message\"\n"
end

