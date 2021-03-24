require 'openssl'
require 'socket'
conn=TCPSocket.new('irc.rizon.net',6697)
def sanitizeinput(string)
	special = "?<>',?[]}{=-)(*&^%$#`~{}"
	string.match(/[#{special.gsub(/./){|char| "\\#{char}"}}]/).nil?
end
ssl = OpenSSL::SSL::SSLSocket.new(conn)
ssl.sync_close = true
ssl.connect
 
    ssl.puts('USER NitterBot NitterBot NitterBot NitterBot')
    ssl.puts('NICK NitterBot') 
    #ssl.puts('MSG nickserv identify password')
	chanlist=["#ex1,#ex2"]

while(1==1)
    line=ssl.gets
    puts line
    if line.include? ":p@"
        channel=line[line.index(' #')+1..line.index(' :')-1]
        userid=line[line.index(':p@')+3..line.length].chomp
        if sanitizeinput(userid)
				message= `curl -Ns https://nitter.eu/#{userid}/media | grep -Eo "src=\\"/pic/media.+(jpg|png)" | sed -E s/src=\\"// | shuf -n1`
		        ssl.puts "PRIVMSG #{channel} https://nitter.eu#{message}"
		end

   elsif line.include? ":p#"
        channel=line[line.index(' #')+1..line.index(' :')-1]
        searchterm=line[line.index(':p#')+3..line.length].chomp
        if sanitizeinput(searchterm)
				message= `curl -Ns "https://nitter.eu/search?f=tweets\&q=%23#{searchterm}" | grep -Eo "src=\\"/pic/media.+(jpg|png)" | sed -E "s/src=\\"//" | shuf -n1`
				puts 	 message
		        ssl.puts "PRIVMSG #{channel} https://nitter.eu#{message}"
		end		

	elsif line.include? ":t#"
	        channel=line[line.index(' #')+1..line.index(' :')-1]
	        searchterm=line[line.index(':t#')+3..line.length].chomp
	        if sanitizeinput(searchterm)
						message= `curl -Ns "https://nitter.eu/search?f=tweets\&q=%23#{searchterm}"| grep -E 'tweet-content media-body.+\/div>' |sed -E 's\/.*auto">|<\\/div>|<div>|<\\/a>\/\/g' |sed -E 's\/<a href=".*>\/\/g'|shuf -n1`
					puts 	 message
			        ssl.puts "PRIVMSG #{channel} :@#{searchterm}: #{message}"
			end	

	elsif line.include? ":t@"
		        channel=line[line.index(' #')+1..line.index(' :')-1]
		        searchterm=line[line.index(':t@')+3..line.length].chomp
		        if sanitizeinput(searchterm)
						message= `curl -Ns "https://nitter.cc/#{searchterm}" | grep -E 'tweet-content media-body.+\/div>' |sed -E 's\/.*auto">|<\\/div>|<div>|<\\/a>\/\/g' |sed -E 's\/<a href=".*>\/\/g'|shuf -n1`
						puts 	 message
				        ssl.puts "PRIVMSG #{channel} :@#{searchterm}: #{message}"
			end	

    elsif line.include? "PING"
        ssl.puts "PONG #{line[line.index(':')+1..line.length]}"
        puts "PONG #{line[line.index(':')+1..line.length]}"
		sleep(2)

    elsif line.include? ":.bots"
          ssl.puts "PRIVMSG #{channel} :Reporting in! [Ruby] 1.0, commands are t@,t#,p@,p#"

	elsif line.include? "VERSION"
	     ssl.puts "VERSION NitterBot"
	     chanlist.each do |ch|
	     	ssl.puts("join #{ch}")
	     end
    end
    
end
