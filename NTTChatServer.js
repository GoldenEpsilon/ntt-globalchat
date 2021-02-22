
console.log("Loading libraries...");

const UsingDiscord = true;

const http    = require('http');
const fs = require('fs');
var clientMod = "";
fs.readFile('Client.mod.gml', 'utf8' , (err, data) => {
	if (err) {
		console.error(err);
		return;
	}
	clientMod = data;
})
var Discord;
if(UsingDiscord){
    Discord = require('discord.js')
}

const port    = process.env.PORT || 3000;
var Client;
var logChannelId;
if(UsingDiscord){
	Client       = new Discord.Client({ disableMentions: 'everyone' })
	logChannelId = "765740608471957526";
	logGuildId = "765740530205720588";
}

console.log("Loading up server!");

if(UsingDiscord){
	//Discord startup
	Client.once('ready', () => {
		console.log('Logged in as ' + Client.user.tag + '!');
		Client.logChannel = Client.channels.cache.get(logChannelId);
		Client.logGuild = Client.guilds.cache.get(logGuildId);
		Client.logGuild.members.fetch();
	})
}

//Server startup
const Server = http.createServer((req, res) => {
	if (req.method == 'POST') serverPost(req, res)
	if (req.method == 'GET') serverGet(req, res)
})

const users            = {}
const messages         = []
const colors           = []

const discordColor     = '14322034'
const checkDisconnects = 10000;
const disconnectTime   = 60000;

//Someone's asking to join!
function serverGet(req, res) {
	res.writeHead(200, { 'Content-Type': 'text/plain' });
	res.write(clientMod);
	res.end('');
}

//Recieved NTT message
function serverPost(req, res) {
	res.writeHead(200, { 'Content-Type': 'text/plain' })

	//set up new users and update pings
	if(!users[req.headers.name]){
		users[req.headers.name] = {ping : new Date().getTime(), messageIndex : 0, flavor : true};
		messages.push({message : req.headers.name + ` has connected. (${Object.keys(users).length} total)`, col : "0"});

		if(UsingDiscord){
			Client.logChannel.send(("`" + req.headers.name + "`" + ` has connected. (${Object.keys(users).length} total)`).replace(/@everyone/gi, "@ everyone").replace(/<@/gi, "<@ "))
		}
	}else{
		users[req.headers.name].ping = new Date().getTime()
	}

	//Send previous messages
	if(users[req.headers.name] && users[req.headers.name].messageIndex > 0){
		for (let i = users[req.headers.name].messageIndex; i < messages.length; i++) {
			if(messages[i]){
				res.write(messages[i].message.replace(/	/gi, " "))
				res.write('	')
				res.write(messages[i].col)
				res.write('	')
			}
		}
	}

	if (req.headers.message) {
		if(req.headers.message == "!help"){
			res.write("Server: Commands: !help, !ping (username), !list")
			res.write('	')
			res.write("0")
			res.write('	')
		}else if(req.headers.message.split(" ")[0] == "!ping"){

			if(UsingDiscord){
				let user = Client.logGuild.members.cache.find(user => user.nickname == req.headers.message.split("!ping ")[1]);
				if(user == undefined){
					user = Client.logGuild.members.cache.find(user => user.username == req.headers.message.split("!ping ")[1]);
				}
				if(user != undefined){
					Client.logChannel.send("<@" + user.id + ">");
					res.write("@" + req.headers.message.split("!ping ")[1])
				}else{
					res.write("User was not found")
				}
			}else{
				res.write("Bot is not connected to discord")
			}
			res.write('	')
			res.write("0")
			res.write('	')
		}else if(req.headers.message == "!list"){
			res.write("Server: ");
			let first = true;
			for(const [key, value] of Object.entries(users)){
				if(!first){
					res.write(", ");
				}
				res.write(key.replace(/	/gi, " "));
				first = false;
			}
			res.write('	')
			res.write("0")
			res.write('	')
		}else{
			var m = {message : req.headers.message, col : "0"};

			console.log(req.headers.name + ': ' + req.headers.message);

			if(UsingDiscord){
				Client.logChannel.send(req.headers.message.replace(req.headers.name, "`"+req.headers.name+"`").replace(/@everyone/gi, "@ everyone").replace(/<@/gi, "<@ "))
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
		if (value.ping + disconnectTime < new Date().getTime()) {
			delete users[key]
			
			messages.push({message : key + ` has disconnected. (${Object.keys(users).length} total)`, col : "0"});
			
			if(UsingDiscord){
				Client.logChannel.send(("`" + key + "`" + ` has disconnected. (${Object.keys(users).length} total)`).replace(/@everyone/gi, "@ everyone").replace(/<@/gi, "<@ "))
			}
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
			if(message.content == "!help"){
				Client.logChannel.send("``Server``: Commands: !help !ping !list")
			}else if(message.content == "!ping"){
				Client.logChannel.send("``Server``: Pong")
			}else if(message.content == "!list"){
				let s = "``Server``: ";
				let first = true;
				for(const [key, value] of Object.entries(users)){
					if(!first){
						s += ", ";
					}
					s += key.replace(/	/gi, " ");
					first = false;
				}
				Client.logChannel.send(s)
			}else{
				messages.push({message : '[Discord] ' + message.author.username + ': ' + message.content + ((message.attachments.length > 0) ? " <attachment>" : ""), col : discordColor})
				colors.push(discordColor)
			}
		}
	})
}

if(UsingDiscord){
	//Log in discord client
	Client.login("NzY0NTY0NzkxNzkxNzE0MzM0.X4IGcw.es3GwUB7BRkQMWwlN7JGDMQ4qek")
}

console.log("Finished loading!");
