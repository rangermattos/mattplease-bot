require 'discordrb'
require 'yaml'

# parse config file
settings = YAML.load_file('config.yml')
if settings['token'].nil? || settings['client_id'].nil? || settings['owner'].nil?
	puts "'token', 'client_id', and 'owner' are required!"
	exit
end

settings['prefix_char'] ||= '!' # default prefix

# This statement creates a bot with the specified token and application ID. After this line, you can add events to the
# created bot, and eventually run it.
#
# If you don't yet have a token and application ID to put in here, you will need to create a bot account here:
#   https://discordapp.com/developers/applications/me
# If you're wondering about what redirect URIs and RPC origins, you can ignore those for now. If that doesn't satisfy
# you, look here: https://github.com/meew0/discordrb/wiki/Redirect-URIs-and-RPC-origins
# After creating the bot, simply copy the token (*not* the OAuth2 secret) and the client ID and put it into the
# respective places.
bot = Discordrb::Commands::CommandBot.new token: settings['token'], client_id: settings['client_id'], prefix: settings['prefix_char']

# Here we output the invite URL to the console so the bot account can be invited to the channel. This only has to be
# done once, afterwards, you can remove this part if you want
puts "This bot's invite URL is #{bot.invite_url}."
puts 'Click on it to invite it to your server.'

#~bot.command :admin do |event|
	#~break unless event.user.id == settings['owner']
	#~bot.send_message(event.channel.id, 'https://discordapp.com/oauth2/authorize?client_id=240120547399303168&scope=bot&permissions=251132938')
#~end
#~
#~bot.command :test do |event|
	#~bot.send_message(event.channel.id, 'test')
#~end

bot.command :mattplease do |event|
	break unless event.user.id == settings['owner'] # only i can use
	channel = event.user.voice_channel
	break unless channel # only in voice chat
	#~channel.users.each do |x|
		#~return if x.id == 104428065626533888 # not if ray's in voice
	#~end
	voice_bot = bot.voice_connect(channel)
	puts "Connected to channel: #{channel.name}"
	
	voice_bot.play_file('data/mattplz.wav')
	
	voice_bot.destroy
	nil
end

#~bot.command :ignore do |event, usr|
	#~is_admin = event.author.permission?(:administrator);
	#~break unless is_admin
	#~usr_to_ignore = bot.parse_mention(usr)
	#~if bot.ignored?(usr_to_ignore)
		#~bot.send_message(event.channel.id, "User " + usr + " already ignored")
	#~else
		#~bot.send_message(event.channel.id, "Ignoring " + usr)
		#~bot.ignore_user(usr_to_ignore)
	#~end
	#~nil
#~end
#~
#~# currently not working, TODO
#~bot.command :ignoredusers do |event|
	#~return
	#~ignored_ids = bot.instance_variable_get(:@ignored_ids).to_a
	#~puts ignored_ids.to_s
	#~ignored_users = ignored_ids.map do |id| 
		#~p id
		#~Discordrb::API::User.resolve(settings['token'],id)
	#~end
	#~bot.send_message(event.channel.id, ignored_users.to_s)
#~end
#~
#~bot.command :unignore do |event, usr|
	#~is_admin = event.author.permission?(:administrator);
	#~break unless is_admin
	#~usr_to_unignore = bot.parse_mention(usr)
	#~if !bot.ignored?(usr_to_unignore)
		#~bot.send_message(event.channel.id, "User " + usr + " already unignored")
	#~else
		#~bot.send_message(event.channel.id, "Unignoring " + usr)
		#~bot.unignore_user(usr_to_unignore)
	#~end
	#~nil
#~end

bot.command(:exit, help_available: false) do |event|
  # This is a check that only allows a user with a specific ID to execute this command. Otherwise, everyone would be
  # able to shut your bot down whenever they wanted.
  break unless event.user.id == settings['owner']

  bot.send_message(event.channel.id, 'Bot is shutting down')
  bot.stop
  exit
end

# This method call has to be put at the end of your script, it is what makes the bot actually connect to Discord. If you
# leave it out (try it!) the script will simply stop and the bot will not appear online.
bot.run
