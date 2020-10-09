
console.log("Loading libraries...");

const UsingDiscord = false;

const http    = require('http')
if(UsingDiscord){
	const Discord = require('discord.js')
	const config  = require('./config.json')
}
const port    = process.env.PORT || 3000;

if(UsingDiscord){
	const Client       = new Discord.Client()
	const logChannelId = config.channel;
}

console.log("Loading up server!");

if(UsingDiscord){
	//Discord startup
	Client.once('ready', () => {
		console.log('Logged in as ' + Client.user.tag + '!')
		Client.logChannel = Client.channels.cache.get(logChannelId)
	})
}

//Server startup
const Server = http.createServer((req, res) => {
	if (req.method == 'POST') serverPost(req, res)
})

const users            = {}
const messages         = []
const colors           = []

const discordColor     = '16753976'
const checkDisconnects = 3000;
const disconnectTime   = 2000;

//Recieved NTT message
function serverPost(req, res) {
	res.writeHead(200, { 'Content-Type': 'text/plain' })

	//set up new users and update pings
	if(!users[req.headers.name]){
		users[req.headers.name] = {ping : new Date().getTime(), messageIndex : 0, flavor : true};
		messages.push({message : req.headers.name + ` has connected. (${Object.keys(users).length} total)`, col : "0"});
	}else{
		users[req.headers.name].ping = new Date().getTime()
	}

	//Send previous messages
	if(users[req.headers.name] && users[req.headers.name].messageIndex > 0){
		for (let i = users[req.headers.name].messageIndex; i < messages.length; i++) {
			if(users[req.headers.name].flavor){
				res.write(m.message.replace(/	/gi, " "))
				res.write('	')
				res.write(m.col)
				res.write('	')
			}
		}
	}

	if (req.headers.message) {
		if(req.headers.message == "!help"){
			res.write("Server: Commands: !help !ping !list !flavor")
			res.write('	')
			res.write("0")
			res.write('	')
		}else if(req.headers.message == "!ping"){
			res.write("Server: Pong")
			res.write('	')
			res.write("0")
			res.write('	')
		}else if(req.headers.message == "!flavor"){
			users[req.headers.name].flavor = !users[req.headers.name].flavor;
			res.write("Turned " + (users[req.headers.name].flavor ? "on" : "off") + " flavor messages")
			res.write('	')
			res.write("0")
			res.write('	')
		}else if(req.headers.message == "!list"){
			res.write("Server: ");
			var first = true;
			for(const [key, value] of Object.entries(users)){
				if(!first){
					res.write(", ");
				}
				res.write(key(/	/gi, " "));
				first = false;
			}
			res.write('	')
			res.write("0")
			res.write('	')
		}else{
			var m = {message : req.headers.message, col : "0"};

			console.log(req.headers.name + ': ' + req.headers.message);

			if(UsingDiscord){
				Client.logChannel.send(req.headers.message.replace(/@everyone/gi, "@ everyone").replace(/<@/gi, "<@ "))
			}

			if (req.headers.color) m.col = req.headers.color;
			
			messages.push(m);
		}
	}

	users[req.headers.name].messageIndex = messages.length

	if (req.headers.message == '!online') {
		messages.push({message : usersOnline + ' users connected.', col : "0"});
	}

	res.end('END')
}

//Check for disconnects
setInterval(() => {
	for (const [key, value] of Object.entries(users)) {
		if (value < (new Date().getTime() - disconnectTime)) {
			delete users[key]
			
			messages.push({message : key + ` has disconnected. (${Object.keys(users).length} total)`, col : "0"});
		}
	}
}, checkDisconnects)

Server.listen(port)
console.log('Server started on port', port)

if(UsingDiscord){
	//Recieved Discord message
	Client.on('message', message => {
		if (message.channel.id != logChannelId) return
		if (message.author.bot) return

		if (message.content) {
			messages.push('[Discord] ' + message.author.username + ': ' + message.content)
			colors.push(discordColor)
		}
	})
}

if(UsingDiscord){
	//Log in discord client
	Client.login(config.token)
}

console.log("Finished loading!");
