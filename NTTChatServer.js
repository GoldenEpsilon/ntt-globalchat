
const UsingDiscord = false;

const Discord = require('discord.js')
const http    = require('http')
const config  = require('./config.json')
const port    = process.env.PORT || 3000;

const Client       = new Discord.Client()
const logChannelId = ''

console.log("Loading up!");

if(UsingDiscord){
	//Discord startup
	Client.once('ready', () => {
		console.log('Logged in as ' + Client.user.tag + '!')
		Client.logChannel = Client.channels.cache.get(logChannelId)
	})
}

//Server startup
const Server = http.createServer((req, res) => {
	if (req.method == 'GET') serverGet(req, res)
	else if (req.method == 'POST') serverPost(req, res)
})

const lastIndexPerUser = {}
const userPings        = {}
const messages         = []
const colors           = []

const discordColor     = '16753976'
const checkDisconnects = 3000;
const disconnectTime   = 2000;

//Recieved NTT message
function serverPost(req, res) {
	res.writeHead(200, { 'Content-Type': 'text/plain' })

	//Send previous messages
	if(lastIndexPerUser[req.headers.name]){
		for (let i = lastIndexPerUser[req.headers.name]; i < messages.length; i++) {
			res.write(m.message.replace(/	/gi, " "))
			res.write('	')
			res.write(m.col)
			res.write('	')
		}
	}

	if (req.headers.message) {
		if(req.headers.message == "!help"){
			res.write("Server: Commands: !help !ping !list")
			res.write('	')
			res.write("0")
			res.write('	')
		}else if(req.headers.message == "!ping"){
			res.write("Server: Pong")
			res.write('	')
			res.write("0")
			res.write('	')
		}else if(req.headers.message == "!list"){
			res.write("Server: ");
			var first = true;
			for(const [key, value] of Object.entries(userPings)){
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

	lastIndexPerUser[req.headers.name] = messages.length

	if (req.headers.message == '!online') {
		messages.push({message : usersOnline + ' users connected.', col : "0"});
	}

	if (!userPings[req.headers.name]) {
		userPings[req.headers.name] = new Date().getTime()

		messages.push({message : req.headers.name + ` has connected. (${Object.keys(userPings).length} total)`, col : "0"});
	} else {
		userPings[req.headers.name] = new Date().getTime()
	}

	res.end('END')
}

//Check for disconnects
setInterval(() => {
	for (const [key, value] of Object.entries(userPings)) {
		if (value < (new Date().getTime() - disconnectTime)) {
			delete userPings[key]
			
			messages.push({message : key + ` has disconnected. (${Object.keys(userPings).length} total)`, col : "0"});
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
