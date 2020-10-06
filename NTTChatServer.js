console.log("starting...");
const http = require('http');
var messages = [];
var colors = [];
var users = {};
const port = process.env.PORT || 3000;
const server = http.createServer((req, res) => {
//START OF SERVER ACCESS CODE ///////////////////////////////////////////////////////////////////////
    if (req.method === 'POST') {
		res.writeHead(200, {"Content-Type": "text/plain"});
		for(var i = users[req.headers.name]; i < messages.length; i++){
			res.write(messages[i]);
			res.write("	");
			res.write(colors[i]);
			res.write("	");
		}
		if(req.headers.message){
			console.log(req.headers.name + ": " + req.headers.message);
			messages.push(req.headers.name + ": " + req.headers.message);
			if(req.headers.color){
				colors.push(req.headers.color);
			}else{
				colors.push("0");
			}
		}
		if(req.headers.x){
			//res.write((parseInt(req.headers.x)).toString());
		}
		if(req.headers.y){
			//res.write((parseInt(req.headers.y)).toString());
		}
		users[req.headers.name] = messages.length;
		res.end("END");
    }
//END OF SERVER ACCESS CODE /////////////////////////////////////////////////////////////////////////
});server.listen(port);
console.log("Server started on port " + port);
