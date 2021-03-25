require 'openssl'
require 'socket'
conn=TCPSocket.new('irc.rizon.net',6697)
def sanitizeinput(string)
	special = "?<>',?[]}{=-)(*&^%$`~{}"
	string.match(/[#{special.gsub(/./){|char| "\\#{char}"}}]/).nil?
end
ssl = OpenSSL::SSL::SSLSocket.new(conn)
ssl.sync_close = true
ssl.connect
 
    ssl.puts('USER NitterBot NitterBot NitterBot NitterBot')
    ssl.puts('NICK NitterBot') 
    #ssl.puts('MSG nickserv identify password')
	chanlist=["#ex1","#ex2"]

while(1==1)
    line=ssl.gets
    puts line
    if line.include? ":p@"
        channel=line[line.index(' #')+1..line.index(' :')-1]
        searchterm=line[line.index(':p@')+3..line.length].chomp
        if sanitizeinput(searchterm)
        	if `curl -Ns https://nitter.cc/#{searchterm}/media`=~ /not found|No items found|suspended/ or not(`curl -Ns "https://nitter.cc/#{searchterm}/media" | grep -Eo "src=\\"/pic/media.+(jpg|png)" | sed -E "s/src=\\"//" | shuf -n1`=~/jpg|png/)
			    ssl.puts "PRIVMSG #{channel} :Sorry, got nothing!"
			    next			
        	end
				message= `curl -Ns https://nitter.cc/#{searchterm}/media | grep -Eo "src=\\"/pic/media.+(jpg|png|mp4)" | sed -E s/src=\\"// | shuf -n1`
		    	ssl.puts "PRIVMSG #{channel} https://nitter.cc#{message}"
		end

   elsif line.include? ":p#"
        channel=line[line.index(' #')+1..line.index(' :')-1]
        searchterm=line[line.index(':p#')+3..line.length].chomp
        if sanitizeinput(searchterm)
	        if `curl -Ns "https://nitter.cc/search?f=tweets\&q=#{searchterm}" | grep -Eo 'No items found'`.include?"No items found" or not(`curl -Ns "https://nitter.cc/search?f=tweets\&q=#{searchterm}" | grep -Eo "src=\\"/pic/media.+(jpg|png)" | sed -E "s/src=\\"//" | shuf -n1`=~/jpg|png/)
   			    ssl.puts "PRIVMSG #{channel} :Sorry, got nothing!"
			    next
	        end
				message= `curl -Ns "https://nitter.cc/search?f=tweets\&q=#{searchterm}" | grep -Eo "src=\\"/pic/media.+(jpg|png|mp4)" | sed -E "s/src=\\"//" | shuf -n1`
				puts 	 message
		        ssl.puts "PRIVMSG #{channel} https://nitter.cc#{message}"
		end		

	elsif line.include? ":t#"
	        channel=line[line.index(' #')+1..line.index(' :')-1]
	        searchterm=line[line.index(':t#')+3..line.length].chomp
	        if sanitizeinput(searchterm)
	        if `curl -Ns "https://nitter.cc/search?f=tweets\&q=#{searchterm}" | grep -Eo "No items found"`.include?"No items found"
	           		 ssl.puts "PRIVMSG #{channel} :Sorry, got nothing!"
	   			    next
   	        end
						message= `curl -Ns "https://nitter.cc/search?f=tweets\&q=#{searchterm}"| grep -E 'tweet-content media-body.+\/div>' |sed -E 's\/.*auto">|<\\/div>|<div>|<\\/a>\/\/g' |sed -E 's\/<a href=".*>\/\/g'|shuf -n1`
					puts 	 message
			        ssl.puts "PRIVMSG #{channel} :#{message}"
			end	

	elsif line.include? ":t@"
		        channel=line[line.index(' #')+1..line.index(' :')-1]
		        searchterm=line[line.index(':t@')+3..line.length].chomp
		        if sanitizeinput(searchterm)
    	        	if `curl -Ns https://nitter.cc/#{searchterm}/media`.=~ /not found|No items found|suspended/
			        	ssl.puts "PRIVMSG #{channel} :Sorry, got nothing!"
			        	next			
			        end
						message= `curl -Ns "https://nitter.cc/#{searchterm}/media" | grep -E 'tweet-content media-body.+\/div>' |sed -E 's\/.*auto">|<\\/div>|<div>|<\\/a>\/\/g' |sed -E 's\/<a href=".*>\/\/g'|shuf -n1`
						puts 	 message
				        ssl.puts "PRIVMSG #{channel} :@#{searchterm}: #{message}"      
			end	

    elsif line.include? "PING"
        ssl.puts "PONG #{line[line.index(':')+1..line.length]}"
        puts "PONG #{line[line.index(':')+1..line.length]}"
		sleep(1)

    elsif line.include? ":.bots"
    		        channel=line[line.index(' #')+1..line.index(' :')-1]
          ssl.puts "PRIVMSG #{channel} :Reporting in! [Ruby] https://github.com/Azrotronik/NitterBot, commands are t@,t#,p@,p#"

	elsif line.include? "VERSION"
	     ssl.puts "VERSION NitterBot"
	     chanlist.each do |ch|
	     	ssl.puts("join #{ch}")
	     end
    end
    
end
