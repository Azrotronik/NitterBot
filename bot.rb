# frozen_string_literal: true

require 'openssl'
require 'socket'

#######################
#######################
botname = 'NitterBot'
server = 'irc.rizon.net'
port = 6697
chanlist = ['#ex1', '#ex2']
#######################
#######################

conn = TCPSocket.new(server, port)
def sanitizeinput(string)
  special = "?<>',?[]}{=-)(*&^%$`~{}"
  string.match(/[#{special.gsub(/./) { |char| "\\#{char}" }}]/).nil?
end
ssl = OpenSSL::SSL::SSLSocket.new(conn)
ssl.sync_close = true
ssl.connect

ssl.puts("USER #{botname} #{botname} #{botname} #{botname}")
ssl.puts("NICK #{botname}")
# ssl.puts('MSG nickserv identify password')

loop do
  line = ssl.gets
  puts line
  if line.include? 'PRIVMSG NitterBot'
  # do nothing, ignore PMs
  elsif line.include? ':p@'
    channel = line[line.index(' #') + 1..line.index(' :') - 1]
    searchterm = line[line.index(':p@') + 3..line.length].chomp
    if sanitizeinput(searchterm)
      if `curl -Ns https://nitter.cc/#{searchterm}/media` =~ (/not found|No items found|suspended/) || !((`curl -Ns "https://nitter.cc/#{searchterm}/media" | grep -Eo "src=\\"/pic/media.+(jpg|png)" | sed -E "s/src=\\"//" | shuf -n1` =~ /jpg|png/))
        ssl.puts "PRIVMSG #{channel} :Sorry, got nothing!"
        next
      end
      message = `curl -Ns https://nitter.cc/#{searchterm}/media | grep -Eo "src=\\"/pic/media.+(jpg|png|mp4)" | sed -E s/src=\\"// | shuf -n1`
      ssl.puts "PRIVMSG #{channel} https://nitter.cc#{message}"
    end

  elsif line.include? ':t@'
    channel = line[line.index(' #') + 1..line.index(' :') - 1]
    searchterm = line[line.index(':t@') + 3..line.length].chomp
    if sanitizeinput(searchterm)
      if `curl -Ns https://nitter.cc/#{searchterm}/media`.=~(/not found|No items found|suspended/)
        ssl.puts "PRIVMSG #{channel} :Sorry, got nothing!"
        next
      end
      message = `curl -Ns "https://nitter.cc/#{searchterm}" | grep -E 'tweet-content media-body.+\/div>' |sed -E 's\/.*auto">|<\\/div>|<div>|<\\/a>\/\/g' |sed -E 's\/<a href=".*>\/\/g'|shuf -n1`
      puts message
      ssl.puts "PRIVMSG #{channel} :@#{searchterm}: #{message}"
    end
  elsif line.include? ':p~'
    channel = line[line.index(' #') + 1..line.index(' :') - 1]
    searchterm = line[line.index(':p~') + 3..line.length].chomp
    if sanitizeinput(searchterm)
      if `curl -Ns "https://nitter.cc/search?f=tweets\&q=#{searchterm}" | grep -Eo 'No items found'`.include?('No items found') || !((`curl -Ns "https://nitter.cc/search?f=tweets\&q=#{searchterm}" | grep -Eo "src=\\"/pic/media.+(jpg|png)" | sed -E "s/src=\\"//" | shuf -n1` =~ /jpg|png/))
        ssl.puts "PRIVMSG #{channel} :Sorry, got nothing!"
        next
      end
      message = `curl -Ns "https://nitter.cc/search?f=tweets\&q=#{searchterm}" | grep -Eo "src=\\"/pic/media.+(jpg|png|mp4)" | sed -E "s/src=\\"//" | shuf -n1`
      puts message
      ssl.puts "PRIVMSG #{channel} https://nitter.cc#{message}"
    end

  elsif line.include? ':t~'
    channel = line[line.index(' #') + 1..line.index(' :') - 1]
    searchterm = line[line.index(':t~') + 3..line.length].chomp
    if sanitizeinput(searchterm)
      if `curl -Ns "https://nitter.cc/search?f=tweets\&q=#{searchterm}" | grep -Eo "No items found"`.include? 'No items found'
        ssl.puts "PRIVMSG #{channel} :Sorry, got nothing!"
        next
      end
      message = `curl -Ns "https://nitter.cc/search?f=tweets\&q=#{searchterm}"| grep -E 'tweet-content media-body.+\/div>' |sed -E 's\/.*auto">|<\\/div>|<div>|<\\/a>\/\/g' |sed -E 's\/<a href=".*>\/\/g'|shuf -n1`
      puts message
      ssl.puts "PRIVMSG #{channel} :#{message}"
    end
  elsif line.include? ':p#'
    channel = line[line.index(' #') + 1..line.index(' :') - 1]
    searchterm = line[line.index(':p#') + 3..line.length].chomp
    if sanitizeinput(searchterm)
      if `curl -Ns "https://nitter.cc/search?f=tweets\&q=%23#{searchterm}" | grep -Eo 'No items found'`.include?('No items found') || !((`curl -Ns "https://nitter.cc/search?f=tweets\&q%23=#{searchterm}" | grep -Eo "src=\\"/pic/media.+(jpg|png)" | sed -E "s/src=\\"//" | shuf -n1` =~ /jpg|png/))
        ssl.puts "PRIVMSG #{channel} :Sorry, got nothing!"
        next
      end
      message = `curl -Ns "https://nitter.cc/search?f=tweets\&q=%23#{searchterm}" | grep -Eo "src=\\"/pic/media.+(jpg|png|mp4)" | sed -E "s/src=\\"//" | shuf -n1`
      puts message
      ssl.puts "PRIVMSG #{channel} https://nitter.cc#{message}"
    end

  elsif line.include? ':t#'
    channel = line[line.index(' #') + 1..line.index(' :') - 1]
    searchterm = line[line.index(':t#') + 3..line.length].chomp
    if sanitizeinput(searchterm)
      if `curl -Ns "https://nitter.cc/search?f=tweets\&q=%23#{searchterm}" | grep -Eo "No items found"`.include? 'No items found'
        ssl.puts "PRIVMSG #{channel} :Sorry, got nothing!"
        next
      end
      message = `curl -Ns "https://nitter.cc/search?f=tweets\&q=%23#{searchterm}"| grep -E 'tweet-content media-body.+\/div>' |sed -E 's\/.*auto">|<\\/div>|<div>|<\\/a>\/\/g' |sed -E 's\/<a href=".*>\/\/g'|shuf -n1`
      puts message
      ssl.puts "PRIVMSG #{channel} :#{message}"
    end

  elsif line.include? 'PING'
    ssl.puts "PONG #{line[line.index(':') + 1..line.length]}"
    puts "PONG #{line[line.index(':') + 1..line.length]}"
    sleep(1)
  elsif line.include? ':.bots'
    channel = line[line.index(' #') + 1..line.index(' :') - 1]
    ssl.puts "PRIVMSG #{channel} :Reporting in! [Ruby] https://github.com/Azrotronik/NitterBot, commands are t@,t#,t~,p@,p#,p~"

  elsif line.include? 'VERSION'
    ssl.puts 'VERSION NitterBot'
    chanlist.each do |ch|
      ssl.puts("join #{ch}")
    end
  end
end
