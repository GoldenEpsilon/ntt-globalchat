//TODO:
//ping on mention
//mute command
//voteban command that tempbans
//if it gets worse, voteipban that also tempbans (painful to make)
//gui
//screenshots

#macro version 2.6

#define init

global.ip = "ntt-globalchat.herokuapp.com";
global.port = "80";
global.queries = [];
global.foundServer = 0;
global.dead = 0;
global.meta = 0;
global.openmind = 0;
global.eagleeyes = 0;
global.gammaguts = 0;
global.winstreakadded = 0;
global.winstreak = 0;
global.loop = 0;
global.bully = 0;
global.newLevel = false;
global.minRunTime = 30;

global.mods = [
	["gatorboss", "mod", "Blaac's Hard Mode"],
	["ntte", "mod", "NTTE"],
	["defpack tools", "mod", "Defpack"],
	["miscreant", "mod", "Minimod"],
	["popo", "mod", "Popo"],
	["vagabonds_master", "mod", "Vagabonds"],
	["itemlib", "mod", "Risk of Acid Rain"],
	["NT3D", "mod", "NT3D"],
	["super hot", "mod", "SUPER HOT"],
	["nts", "mod", "Nuclear Throne Stupid"],
	["diceywastelands", "mod", "Dicey Wastelands"],
	["pvp", "mod", "PvP"]
]

chat_comp_add("gcip", "Sets your ip for the global chat.");
chat_comp_add("gcport", "Sets your port for the global chat.");
trace("Version "+string(version));
trace("Welcome to the official NTT Global Chat server! type !help for a list of commands");


#define level_start

global.bully = 0;
if(global.meta > 0){
	global.meta--;
}


#define game_start

global.dead = 0;
global.meta = 0;
global.openmind = 0;
global.eagleeyes = 0;
global.gammaguts = 0;
global.winstreakadded = 0;
global.loop = 0;


#define step

if(instance_exists(GenCont)) global.newLevel = true;
else if(global.newLevel){
	global.newLevel = false;
	level_start();
}

sendcheck();

var actualLoops = GameCont.loops - UberCont.hardmode

if(instance_exists(TopCont) && TopCont.dead == 1){
	if(global.dead == 0 && GameCont.win == 0){
		global.dead = 1;
		if(actualLoops > 0 || global.winstreak > 0 || GameCont.timer / 30 > global.minRunTime){
			var deathname = is_array(GameCont.deathcause) ? GameCont.deathcause[1] : (is_string(GameCont.deathcause) ? GameCont.deathcause : (real(GameCont.deathcause) > 105 ? sprite_get_name(GameCont.deathcause) : death_cause(GameCont.deathcause)[1]));
			var deathcause = string_lower(string_split(deathname, ")")[0]);
			var dcfc = string_char_at(deathcause, 1);
			var message = player_get_alias(0) + (player_is_active(1) ? "'s group" : "") + " just got killed by " + ((dcfc=="a"||dcfc=="e"||dcfc=="i"||dcfc=="o"||dcfc=="u") ? "an ": "a ") + deathcause + (actualLoops > 0 ? " in loop " + string(actualLoops) : "") + (UberCont.hardmode ? " in hardmode" : "");
			var modlist = [];
			with(global.mods){
				if(mod_exists(self[1], self[0])){
					array_push(modlist, self[2]);
				}
			}
			for(var i = 0; i < array_length(modlist); i++){
				if(i == 0){
					message += " with ";
				}else{
					message += "/";
				}
				message += modlist[i];
			}
			message += (array_length(modlist) > 0 ? " enabled" : "") + "." + (global.winstreak > 0 ? " They had a " + string(global.winstreak) + " long winstreak." : "");
			sendMessage(message);
		}
		global.winstreak = 0;
	}
}
if(GameCont.win == 1 && !global.winstreakadded){
	global.winstreakadded = 1;
	global.winstreak++;
	if(global.winstreak > 2){
		var message = player_get_alias(0) + (player_is_active(1) ? "'s group" : "") + " has a " + string(global.winstreak) + " winstreak!";
		sendMessage(message);
	}
}
if(actualLoops > global.loop){
	global.loop = actualLoops;
	if(actualLoops == 1){
		var message = player_get_alias(0) + (player_is_active(1) ? "'s group" : "") + " is getting into loop 1!";
		sendMessage(message);
	}else if(actualLoops == 2){
		var message = player_get_alias(0) + (player_is_active(1) ? "'s group" : "") + " is going on to loop 2!";
		sendMessage(message);
	}else if(actualLoops == 3){
		var message = player_get_alias(0) + (player_is_active(1) ? "'s group" : "") + " better watch out for those freaks...";
		sendMessage(message);
	}else if(actualLoops > 3){
		var message = player_get_alias(0) + (player_is_active(1) ? "'s group" : "") + " reached loop " + string(actualLoops) + "!";
		sendMessage(message);
	}
}
if(global.openmind == 0 && skill_get(mut_open_mind)){
	global.openmind = 1;
	if(irandom(1)){
		var message = player_get_alias(0) + (player_is_active(1) ? "'s group" : "") + " opened their mind" + (player_is_active(1) ? "s" : "") + " 0_o";
		sendMessage(message);
	}
}
if(global.eagleeyes == 0 && skill_get(mut_eagle_eyes)){
	global.eagleeyes = 1;
	if(irandom(1)){
		var message = player_get_alias(0) + (player_is_active(1) ? "'s group" : "") + " can see good.";
		sendMessage(message);
	}
}
if(global.gammaguts == 0 && skill_get(mut_gamma_guts)){
	global.gammaguts = 1;
	if(irandom(1)){
		var message = player_get_alias(0) + (player_is_active(1) ? "'s group are" : " is") + " looking to fight the technomancer with gamma guts.";
		sendMessage(message);
	}
}
if(global.gammaguts == 1 && skill_get(mut_gamma_guts) && instance_exists(TechnoMancer)){
	global.gammaguts = 2;
	var message = player_get_alias(0) + (player_is_active(1) ? "'s group are" : " is") + " fighting the technomancer with gamma guts.";
	sendMessage(message);
}
with(Player) {
	if((wep == wep_super_plasma_cannon && bwep == wep_ultra_shovel) || (bwep == wep_super_plasma_cannon && wep == wep_ultra_shovel)){
		if(global.meta == 0){
			var message = player_get_alias(index) + " has meta!";
			sendMessage(message, index);
		}
		global.meta = 2;
	}
}
with(YungCuz){
	if(sprite_index == sprCuzCry && global.bully == 0){
		global.bully = 1;
		var message = player_get_alias(0) + (player_is_active(1) ? "'s group" : "") + (player_is_active(1) ? " are bullies!" : " is a bully!");
		sendMessage(message);
	}
}

if(global.foundServer < 0){
	global.foundServer++;
}


#define draw_pause

sendcheck();

#define chat_message(message, player)

var header = ds_map_create();
ds_map_set(header, "message", (string_char_at(message, 1) == "!") ? message : player_get_alias(player) + ": " + message);
ds_map_set(header, "color", string(player_get_color(player)));
send(header);


#define chat_command(command, parameter, player)

if(command == "gcip"){
	global.ip = parameter;
	trace("Your ip to connect to is set to " + global.ip);
	global.foundServer = -60;
	return 1;
}

if(command == "gcport"){
	global.port = parameter;
	trace("Your port to connect to is set to " + global.port);
	global.foundServer = -60;
	return 1;
}


#define string_in_array(str, arr)

for(var i = 0; i < array_length(arr); i++){
	if(str == arr[i]){
		return 1;
	}
}
return 0;

//argument0:message, argument1:player
#define sendMessage
var header = ds_map_create();
ds_map_set(header, "message", argument[0]);
ds_map_set(header, "color", string(player_get_color(argument_count > 1 ? argument[1] : 0)));
trace_color(argument[0], player_get_color(argument_count > 1 ? argument[1] : 0));
send(header);


#define sendcheck

if(array_length(global.queries) == 0){
	var header = ds_map_create();
	send(header);
}

for(var i = 0; i < array_length(global.queries); i++){
	switch(global.queries[i].phase){
		case 1:
			send1(global.queries[i]);
			break;
		case 2:
			send2(global.queries[i]);
			break;
		case 3:
			send3(global.queries[i]);
			break;
		case 4:
			send4(global.queries[i]);
			break;
		default:
			for(var i2 = i; i2 < array_length(global.queries) - 1; i2++){
				global.queries[i2] = global.queries[i2 + 1];
			}
			global.queries = array_slice(global.queries, 0, array_length(global.queries) - 1);
			i--;
			break;
	}
}
	

#define send(message)

array_push(global.queries, {phase:0,frame:floor(current_frame)})

query = global.queries[array_length(global.queries) - 1];

ds_map_set(message, "name", player_get_alias(0));

var url = "http://"+global.ip+":"+global.port+"/";
if(global.port == 0){url = "http://"+global.ip;}

file_delete("update"+string(query.frame)+".txt");
http_request(url, "POST", message, '', "update"+string(query.frame)+".txt");
query.phase = 1;
	
#define send1(query)

if(!file_exists("update"+string(query.frame)+".txt") && current_frame - query.frame < room_speed*2){
	return;
}else{
	file_load("update"+string(query.frame)+".txt");
	query.phase = 2;
}

#define send2(query)

if(!file_loaded("update"+string(query.frame)+".txt")){
	return;
}else{
	query.phase = 3;
}

#define send3(query)

if(!file_loaded("update"+string(query.frame)+".txt")){
	file_load("update"+string(query.frame)+".txt");
	query.phase = 2;
	return;
}

s = string_load("update"+string(query.frame)+".txt");

file_delete("update"+string(query.frame)+".txt");
file_unload("update"+string(query.frame)+".txt");

if(s == null){
	s = "";
}else if(global.foundServer == 0){
	global.foundServer = 1;
	trace("Server found!");
}

messages = string_split(s, "	");
for(var i = 0; i < array_length(messages) - 1; i+=2){
	trace_color(messages[i], real(messages[i+1]));
	sound_play(sndHitMetal);
}
query.phase = 4;

#define send4(query)
if(current_frame - query.frame < room_speed){return;}
query.phase = 5;



#define death_cause(_cause)
	/*
		Returns the death cause associated with a given index as an array containing [Sprite, Name]
	*/
	
	_cause = floor(_cause);
	
	 // Normal:
	var _loc = `CauseOfDeath:${_cause}`;
	switch(_cause){
		case   0 : return [sprBanditIdle,           loc(_loc, "bandit"                                              )];
		case   1 : return [sprMaggotIdle,           loc(_loc, "maggot"                                              )];
		case   2 : return [sprRadMaggot,            loc(_loc, "rad maggot"                                          )];
		case   3 : return [sprBigMaggotIdle,        loc(_loc, "big maggot"                                          )];
		case   4 : return [sprScorpionIdle,         loc(_loc, "scorpion"                                            )];
		case   5 : return [sprGoldScorpionIdle,     loc(_loc, "golden scorpion"                                     )];
		case   6 : return [sprBanditBossIdle,       loc(_loc, "big bandit"                                          )];
		case   7 : return [sprRatIdle,              loc(_loc, "rat"                                                 )];
		case   8 : return [sprRatkingIdle,          loc(_loc, "big rat"                                             )];
		case   9 : return [sprFastRatIdle,          loc(_loc, "green rat"                                           )];
		case  10 : return [sprGatorIdle,            loc(_loc, "gator"                                               )];
		case  11 : return [sprExploderIdle,         loc(_loc, "frog"                                                )];
		case  12 : return [sprSuperFrogIdle,        loc(_loc, "super frog"                                          )];
		case  13 : return [sprFrogQueenIdle,        loc(_loc, "mom"                                                 )];
		case  14 : return [sprMeleeIdle,            loc(_loc, "assassin"                                            )];
		case  15 : return [sprRavenIdle,            loc(_loc, "raven"                                               )];
		case  16 : return [sprSalamanderIdle,       loc(_loc, "salamander"                                          )];
		case  17 : return [sprSniperIdle,           loc(_loc, "sniper"                                              )];
		case  18 : return [sprScrapBossIdle,        loc(_loc, "big dog"                                             )];
		case  19 : return [sprSpiderIdle,           loc(_loc, "spider"                                              )];
		case  20 : return [sprBanditIdle,           loc(_loc, "new cave thing"                                      )];
		case  21 : return [sprLaserCrystalIdle,     loc(_loc, "laser crystal"                                       )];
		case  22 : return [sprHyperCrystalIdle,     loc(_loc, "hyper crystal"                                       )];
		case  23 : return [sprSnowBanditIdle,       loc(_loc, "snow bandit"                                         )];
		case  24 : return [sprSnowBotIdle,          loc(_loc, "snowbot"                                             )];
		case  25 : return [sprWolfIdle,             loc(_loc, "wolf"                                                )];
		case  26 : return [sprSnowTankIdle,         loc(_loc, "snowtank"                                            )];
		case  27 : return [sprLilHunter,            loc(_loc, "lil hunter"                                          )];
		case  28 : return [sprFreak1Idle,           loc(_loc, "freak"                                               )];
		case  29 : return [sprExploFreakIdle,       loc(_loc, "explo freak"                                         )];
		case  30 : return [sprRhinoFreakIdle,       loc(_loc, "rhino freak"                                         )];
		case  31 : return [sprNecromancerIdle,      loc(_loc, "necromancer"                                         )];
		case  32 : return [sprTurretIdle,           loc(_loc, "turret"                                              )];
		case  33 : return [sprTechnoMancer,         loc(_loc, "technomancer"                                        )];
		case  34 : return [sprGuardianIdle,         loc(_loc, "guardian"                                            )];
		case  35 : return [sprExploGuardianIdle,    loc(_loc, "explo guardian"                                      )];
		case  36 : return [sprDogGuardianWalk,      loc(_loc, "dog guardian"                                        )];
		case  37 : return [sprNothingOn,            loc(_loc, "throne"                                              )];
		case  38 : return [sprNothing2Idle,         loc(_loc, "throne II"                                           )];
		case  39 : return [sprBoneFish1Idle,        loc(_loc, "bonefish"                                            )];
		case  40 : return [sprCrabIdle,             loc(_loc, "crab"                                                )];
		case  41 : return [sprTurtleIdle,           loc(_loc, "turtle"                                              )];
		case  42 : return [sprMolefishIdle,         loc(_loc, "molefish"                                            )];
		case  43 : return [sprMolesargeIdle,        loc(_loc, "molesarge"                                           )];
		case  44 : return [sprFireBallerIdle,       loc(_loc, "fireballer"                                          )];
		case  45 : return [sprSuperFireBallerIdle,  loc(_loc, "super fireballer"                                    )];
		case  46 : return [sprJockIdle,             loc(_loc, "jock"                                                )];
		case  47 : return [sprInvSpiderIdle,        loc(_loc, /*"@p@qc@qu@qr@qs@qe@qd @qs@qp@qi@qd@qe@qr"*/"cursed spider"             )];
		case  48 : return [sprInvLaserCrystalIdle,  loc(_loc, /*"@p@qc@qu@qr@qs@qe@qd @qc@qr@qy@qs@qt@qa@ql"*/"cursed crystal"          )];
		case  49 : return [sprMimicTell,            loc(_loc, "mimic"                                               )];
		case  50 : return [sprSuperMimicTell,       loc(_loc, "health mimic"                                        )];
		case  51 : return [sprGruntIdle,            loc(_loc, "grunt"                                               )];
		case  52 : return [sprInspectorIdle,        loc(_loc, "inspector"                                           )];
		case  53 : return [sprShielderIdle,         loc(_loc, "shielder"                                            )];
		case  54 : return [sprOldGuardianIdle,      loc(_loc, "crown guardian"                                      )];
		case  55 : return [sprExplosion,            loc(_loc, "explosion"                                           )];
		case  56 : return [sprSmallExplosion,       loc(_loc, "small explosion"                                     )];
		case  57 : return [sprTrapGameover,         loc(_loc, "fire trap"                                           )];
		case  58 : return [sprShielderShieldAppear, loc(_loc, "shield"                                              )];
		case  59 : return [sprToxicGas,             loc(_loc, "toxic"                                               )];
		case  60 : return [sprEnemyHorrorIdle,      loc(_loc, "horror"                                              )];
		case  61 : return [sprBarrel,               loc(_loc, "barrel"                                              )];
		case  62 : return [sprToxicBarrel,          loc(_loc, "toxic barrel"                                        )];
		case  63 : return [sprGoldBarrel,           loc(_loc, "golden barrel"                                       )];
		case  64 : return [sprCarIdle,              loc(_loc, "car"                                                 )];
		case  65 : return [sprVenusCar,             loc(_loc, "venus car"                                           )];
		case  66 : return [sprVenusCarFixed,        loc(_loc, "venus car fixed"                                     )];
		case  67 : return [sprVenuzCar2,            loc(_loc, "venus car 2"                                         )];
		case  68 : return [sprFrozenCar,            loc(_loc, "icy car"                                             )];
		case  69 : return [sprFrozenCarThrown,      loc(_loc, "thrown car"                                          )];
		case  70 : return [sprWaterMine,            loc(_loc, "mine"                                                )];
		case  71 : return [sprCrown1Idle,           loc(_loc, "crown of death"                                      )];
		case  72 : return [sprPopoExplo,            loc(_loc, "rogue strike"                                        )];
		case  73 : return [sprBloodNader,           loc(_loc, "blood launcher"                                      )];
		case  74 : return [sprBloodCannon,          loc(_loc, "blood cannon"                                        )];
		case  75 : return [sprBloodHammer,          loc(_loc, "blood hammer"                                        )];
		case  76 : return [sprDisc,                 loc(_loc, "disc"                                                )];
		case  77 : return [sprCurse,                loc(_loc, /*"@p@qc@qu@qr@qs@qe"*/"curse"                                   )];
		case  78 : return [sprScrapBossMissileIdle, loc(_loc, "big dog missile"                                     )];
		case  79 : return [sprSpookyBanditIdle,     loc(_loc, "halloween bandit"                                    )];
		case  80 : return [sprLilHunterHurt,        loc(_loc, "lil hunter fly"                                      )];
		case  81 : return [sprNothingDeathLoop,     loc(_loc, "throne death"                                        )];
		case  82 : return [sprJungleBanditIdle,     loc(_loc, "jungle bandit"                                       )];
		case  83 : return [sprJungleAssassinIdle,   loc(_loc, "jungle assassin"                                     )];
		case  84 : return [sprJungleFlyIdle,        loc(_loc, "jungle fly"                                          )];
		case  85 : return [sprCrown1Idle,           loc(_loc, "crown of hatred"                                     )];
		case  86 : return [sprIceFlowerIdle,        loc(_loc, "ice flower"                                          )];
		case  87 : return [sprCursedAmmo,           loc(_loc, /*"@p@qc@qu@qr@qs@qe@qd @qa@qm@qm@qo @qp@qi@qc@qk@qu@qp"*/"cursed ammo pickup")];
		case  88 : return [sprLightningDeath,       loc(_loc, "electrocution"                                       )];
		case  89 : return [sprEliteGruntIdle,       loc(_loc, "elite grunt"                                         )];
		case  90 : return [sprKillsIcon,            loc(_loc, "blood gamble"                                        )];
		case  91 : return [sprEliteShielderIdle,    loc(_loc, "elite shielder"                                      )];
		case  92 : return [sprEliteInspectorIdle,   loc(_loc, "elite inspector"                                     )];
		case  93 : return [sprLastIdle,             loc(_loc, "captain"                                             )];
		case  94 : return [sprVanDrive,             loc(_loc, "van"                                                 )];
		case  95 : return [sprBuffGatorIdle,        loc(_loc, "buff gator"                                          )];
		case  96 : return [sprBigGenerator,         loc(_loc, "generator"                                           )];
		case  97 : return [sprLightningCrystalIdle, loc(_loc, "lightning crystal"                                   )];
		case  98 : return [sprGoldTankIdle,         loc(_loc, "golden snowtank"                                     )];
		case  99 : return [sprGreenExplosion,       loc(_loc, "green explosion"                                     )];
		case 100 : return [sprSmallGenerator,       loc(_loc, "small generator"                                     )];
		case 101 : return [sprGoldDisc,             loc(_loc, "golden disc"                                         )];
		case 102 : return [sprBigDogExplode,        loc(_loc, "big dog explosion"                                   )];
		case 103 : return [sprPopoFreakIdle,        loc(_loc, "popo freak"                                          )];
		case 104 : return [sprNothing2Death,        loc(_loc, "throne II death"                                     )];
		case 105 : return [sprOasisBossIdle,        loc(_loc, "big fish"                                            )];
	}
	
	 // Sprite:
	if(sprite_exists(_cause)){
		return [_cause, sprite_get_name(_cause)];
	}
	
	 // None:
	return [mskNone, ""];