require 'discordrb'
require 'yaml'

# parse config file
settings = YAML.load_file('config.yml')
if settings['token'].nil? || settings['client_id'].nil? || settings['owner'].nil?
	puts "\'token\', \'client_id\', and \'owner\' are required!"
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

# limit spam commands to 3 per 60 seconds, 10 second delay between
bot.bucket :spam, limit: 3, time_span: 60, delay: 10

define_method :play_sound do |event, file_name| # define_method used instead of def to avoid scope inaccessibility for settings
	# only usable by owner or allowed users
	# TODO: change to role? allow for per-command role?
	puts "user id = #{event.user.id}"
	next "You\'re not allowed to use that command" unless event.user.id == settings['owner'] or settings ['allowed_users'].include? event.user.id

	# for debug
	puts "user confirmed"
	channel = event.user.voice_channel

	# return if not in voice chat
	next "You\'re not in a voice channel" unless channel
	# create voice bot
	voice_bot = bot.voice_connect(channel)
	# debug message
	puts "Connected to channel: #{channel.name}"

	# play file
	# assumed that files are in data/ directory
	voice_bot.play_file("data/#{file_name}")

	# destroy voice bot
	voice_bot.destroy
	# return nil
	nil
end

bot.command(:mattplease, bucket: :spam) do |event|
	puts "!mattplease command received"
	play_sound(event, "mattplz.wav")
	nil
end

bot.command(:deep, bucket: :spam) do |event|
	puts "!deep command received"
	play_sound(event, "mattplz_deep.mp3")
	nil
end

bot.command(:squirrel, bucket: :spam) do |event|
	puts "!squirrel command received"
	play_sound(event, "mattplz_squirrel.mp3")
	nil
end

bot.command(:caaake, bucket: :spam) do |event|
	puts "!caaake command received"
	play_sound(event, "caaake.mp3")
	nil
end

bot.command(:ianxcake, bucket: :spam) do |event|
	puts "!ianxcake command received"
	play_sound(event, "i_love_cake.wav")
	nil
end

bot.command(:tagg, bucket: :spam) do |event|
	put "!tagg command received"
	play_sound(event, "tagg16_amped.wav")
	nil
end

bot.command(:exit, help_available:false) do |event|
	break unless event.user.id == settings['owner']

	bot.send_message(event.channel.id, 'Bot is shutting down')
	bot.stop
	exit
end

bot.command(:reconfigure, help_available: false) do |event|
	break unless event.user.id == settings['owner']

	bot.send_message(event.channel.id, 'Reconfiguring')
	puts "#{settings = YAML.load_file('config.yml')}"
end

# This method call has to be put at the end of your script, it is what makes the bot actually connect to Discord. If you
# leave it out (try it!) the script will simply stop and the bot will not appear online.
bot.run
