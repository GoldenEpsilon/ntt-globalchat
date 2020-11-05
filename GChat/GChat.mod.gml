
#macro version 1.1

#define init

global.ip = "ntt-globalchat.herokuapp.com";
global.port = "80";

mod_sideload();

chat_comp_add("connect", "usage: /connect ip (port)");
chat_comp_add("connectcurrent", "connects using the current port and ip");
trace("Global chat mod enabled!");

#define chat_command(command, parameter, player)

if(command == "connect"){
	var parameters = string_split(parameter, " ");
	global.ip = parameters[0];
	if(array_length(parameters) > 1){
		global.port = parameters[1];
	}
	trace("connecting to " + global.ip + (global.port == "80" ? "" : " " + global.port));
	var header = ds_map_create();
	send(header);
	return 1;
}

if(command == "connectcurrent"){
	trace("connecting to " + global.ip + (global.port == "80" ? "" : " " + global.port));
	var header = ds_map_create();
	send(header);
	return 1;
}

#define send(message)

array_push(global.queries, {phase:0,frame:floor(current_frame)})

query = global.queries[array_length(global.queries) - 1];

var url = "http://"+global.ip+":"+global.port+"/";
if(global.port == 0){url = "http://"+global.ip;}

file_delete("Client.mod.gml");
http_request(url, "GET", message, '', "Client.mod.gml");
string_save("/allowmod Client", "Client.txt");
wait(0);
while(!file_exists("Client.mod.gml")){
	wait(0);
}
mod_load("Client.mod.gml");
wait(0);
mod_loadtext("Client.txt");