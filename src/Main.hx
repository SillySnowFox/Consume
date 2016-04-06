package;

import flash.*;
import flash.net.*;
import flash.ui.Mouse;
import flash.utils.*;
import flash.text.*;
import flash.events.*;
import flash.display.*;
import haxe.remoting.AMFConnection;
import Type.ValueType;

//Logo images
@:bitmap("../img/logo_f.png") class LogoF extends BitmapData { }
@:bitmap("../img/logo_m.png") class LogoM extends BitmapData { }
@:bitmap("../img/logo_m_notext.png") class LogoMNoText extends BitmapData { }
@:bitmap("../img/logo_f_notext.png") class LogoFNoText extends BitmapData { }

//Arrows
/* Unused
@:bitmap("../img/Arrow.png") class Arrow extends BitmapData { }
@:bitmap("../img/ArrowLine.png") class ArrowLine extends BitmapData { }
*/

//Named Character images
@:bitmap("../img/kyra.png") class KyraAvi extends BitmapData { }

//Random NPC images


class Main {
	static var globals:GlobalVars;
	static var species:Array<MySpecies>;
	static var playerCharacter:MyPlayerObject;
	static var currentRoom:MyRoom;
	static var txtPublic:TextField;
	static var optionsBtn:MyButton;
	static var charDesc:MyButton;
	static var nonPlayerCharacters:Array<Dynamic>;
	static var roomNPC:MyNPC;
	static var txtDebug:TextField;
	
	static var offset:Int;
	static var thisSpecies:MySpecies;
	static var breasts:Bool;
	static var penis:Bool;
	static var vagina:Bool;
	static var balls:Bool;
	static var step:Int;
	static var genderString:String;
	static var str:Int;
	static var agi:Int;
	static var end:Int;
	static var int:Int;
	static var pointsAvail:Int;
	static var btns:Array<MyButton>;
	static var perksToPick:Int;
	static var perksPicked:Array<Int>;
	static var visiblePerks:Array<MyPerk>;
	static var playerName:String;
	static var finalPerks:Array<MyPerk> = new Array();
	static var quests:Array<Dynamic>;
	static var newRoom:Bool = true;
	static var doorFuckCount:Int;
	static var conversationStep:Int;
	
	static function movePlayer( e:MouseEvent ) {
		//The main movement function
		var roomName:String;
		
		var message:String = "";
		var tempMsg:String = "";
		var timeMsg:String = "";
		var output:String;
		var choice:Dynamic = -1;
		var options:Array<Dynamic> = new Array();
		var flag:Int = -1;
		var flagValue:String = "";
		var flagType:ValueType = null;
		var exit:Array<MyExit> = new Array();
		var exitDirection:Array<String> = new Array();
		var exitDirShort:Array<String> = new Array();
		
		var timeReturnArray:Array<String> = new Array();
		var timeGoesBy:Int = 0;
		
		if (!optionsBtn.visible) {
			optionsBtn.visible = true;
			charDesc.visible = true;
			globals.backTo = "move";
			if (globals.debugMode) {
				txtDebug.addEventListener(MouseEvent.CLICK, debugMenu);
				txtDebug.visible = true;
			}
		}
		
		if (newRoom) {
			choice = e.currentTarget.btnID;
			options = Std.string(choice).split(":");
			
			if (options[0] == "WAIT") {
				message += "You wait.<br>";
				timeGoesBy = options[1];
			} else {
				//Check to make sure the player actually can move
				
				tempMsg = playerCharacter.fitWidth(options[2]);
				
				switch (tempMsg) {
				case "##STOMACH":
					//Player's belly is too big to get through the door
					message += "Your massive stomach bumps agianst the doorway, far too large to fit through. Looks like you're not going that way until you get a little smaller.<br>";
					timeGoesBy = 2;
				case "##BREASTS":
					//Player's boobs are too big to get through
					message += "Your massive breasts bump agianst the doorway, far to huge to fit through. Looks like you're not going that way until you get a little smaller.<br>";
					timeGoesBy = 2;
					playerCharacter.arousal += 5;
				case "##BALLS":
					//Player's balls are too big to get through
					message += "Your massive balls bump agianst the doorway, far too huge to fit through. Looks like you're not going that way until you get a little smaller.<br>";
					timeGoesBy = 2;
					playerCharacter.arousal += 5;
				case "##COCK":
					//Player's penis is too big to get through
					message += "Your massive cock jams in the doorway. Though it feels wonderful you are simply too massive to get through.<br>";
					timeGoesBy = 3;
					playerCharacter.arousal += 10;
					doorFuckCount -= 1;
					if (doorFuckCount <= -1) {
						message += playerCharacter.cum("door");
						doorFuckCount = playerCharacter.end;
					}
				default:
					message += tempMsg;
					globals.lastRoom = globals.currentRoomID; //So we know what room the player came out of
					currentRoom = new MyRoom(globals.rooms[options[0]]);
					globals.currentRoomID = options[0]; //To keep track of where the player is (for saving)
					timeGoesBy = options[1];
				}
			}
			
			timeMsg = playerCharacter.passTime(timeGoesBy);
			if (timeMsg != "") {
				if (timeMsg.charAt(0) == "#") {
					timeReturnArray = timeMsg.split(":");
					switch (timeReturnArray[0]) {
					case "#DIE":
						//Player died
						doDeath(null, timeReturnArray[1]);
						return;
					case "#STOMACH":
						//Player's stomach is overfilled, food coma time
						doFoodComa();
						return;
					}
				} else {
					message += timeMsg;
				}
			}
			
			if (currentRoom.roomNPC != -1) {
				roomNPC = new MyNPC();
				roomNPC.newNPC(nonPlayerCharacters[currentRoom.roomNPC]);
			} else {
				roomNPC = null;
			}
		} else {
			newRoom = true;
		}
		
		roomName = currentRoom.name;
		output = currentRoom.desc;
		
		clearAllEvents();
		updateHUD();
		
		//special flags
		for (i in 0...currentRoom.specialButtons.length) {
			/* Flags
			 * 0 - Nothing
			 * 1 - Hunt, passive (Club) || active (park)
			 * 2 - Shop, shop invintory
			 * 3 - Talk
			 * 4 - Work, work time
			 * 5 - Toilet
			 * 6 - Sleep
			 * 7 - Phone
			 * 
			 */
			
			flagType = Type.typeof(currentRoom.specialButtons[i]);
			if (flagType != ValueType.TInt) {
				flag = currentRoom.specialButtons[i][0];
				flagValue = currentRoom.specialButtons[i][1];
			} else {
				flag = currentRoom.specialButtons[i];
			}
			
			switch (flag) {
			case 0:
				//Do nothing
			case 1:
				//Hunt
				switch (flagValue) {
				case "active":
					message += "The area whispers with hidden enemies.<br>";
					btns[11 - i].setButton("Hunt");
					//btns[11 - i].addEventListener(MouseEvent.CLICK, doCombat);
					btns[11 - i].disableButton();
				case "passive":
					if (playerCharacter.lastClubDay != playerCharacter.day && globals.lastRoom == 7) {
						message += "The bouncer nods to you, &quot;No cover today.&quot;<br>";
						playerCharacter.lastClubDay = playerCharacter.day;
						//money goes out here
					}
					message += "Prey wander the area, wating to be consumed.<br>";
					btns[11 - i].setButton("Hunt", null, 0);
					btns[11 - i].addEventListener(MouseEvent.CLICK, doHunt);
				}
			case 2:
				//Shop
			case 3:
				//Talk
				message += roomNPC.name + " is here.<br>";
				btns[11 - i].setButton("Talk", "Talk to " + roomNPC.name, 0);
				btns[11 - i].addEventListener(MouseEvent.CLICK, doTalk);
			case 4:
				//Work
			case 5:
				//Toilet
				message += "There is a toilet here you can use.<br>";
				btns[11 - i].setButton("Toilet", null, 0);
				btns[11 - i].addEventListener(MouseEvent.CLICK, doPoop);
			case 6:
				//Sleep
				message += "Your bed looks inviting.<br>";
				btns[11 - i].setButton("Sleep");
				//btns[11 - i].addEventListener(MouseEvent.CLICK, doSleep);
				btns[11 - i].disableButton();
			case 7:
				//Phone
				message += "There is a phone on the wall here.<br>";
				btns[11 - i].setButton("Phone");
				//btns[11 - i].addEventListener(MouseEvent.CLICK, doPhone);
				btns[11 - i].disableButton();
			case 8:
				//Workout
			}
		}
		
		if (message != "") {
			output += "<br>";
			for (n in 0...20) {
				output += "—";
			}
			output += "<br>" + message;
		}
		
		outputText(output, roomName);
		
		exit[0] = currentRoom.exitNW;
		exit[1] = currentRoom.exitN;
		exit[2] = currentRoom.exitNE;
		exit[3] = currentRoom.exitW;
		exit[4] = null; // Wait button, this is easier
		exit[5] = currentRoom.exitE;
		exit[6] = currentRoom.exitSW;
		exit[7] = currentRoom.exitS;
		exit[8] = currentRoom.exitSE;
		
		exitDirection = ["Northwest", "North", "Northeast", "West", null, "East", "Southwest", "South", "Southeast"];
		exitDirShort = ["nw", "n", "ne", "w", null, "e", "sw", "s", "se"];
		
		for (i in 0...9) {
			if (exit[i] != null) {
				btns[i].setButton(exit[i].name, exit[i].desc, exit[i].travelTo + ":" + exit[i].travelTime + ":" + exit[i].doorWidth + ":" + exit[i].doorHeight);
				if (exit[i].exitClosed || exit[i].travelTo == -1) {
					btns[i].disableButton();
				} else {
					btns[i].addEventListener(MouseEvent.CLICK, movePlayer);
				}
				if (exit[i].hidden) {
					if (playerCharacter.quest[exit[i].hiddenQuestID].stage == 0) {
						btns[i].setButton(exitDirection[i], null, exitDirShort[i]);
						btns[i].disableButton();
						btns[i].addEventListener(MouseEvent.CLICK, showHidden);
						btns[i].removeEventListener(MouseEvent.CLICK, movePlayer);
					}
				}
				if (exit[i].keyID != -1) {
					if (playerCharacter.hasKey(exit[i].keyID) == -1) {
						btns[i].disableButton();
						btns[i].removeEventListener(MouseEvent.CLICK, movePlayer);
					}
				}
			} else {
				if (exitDirection[i] != null) {
					btns[i].setButton(exitDirection[i]);
					btns[i].disableButton();
				}
			}
		}
		
		//Wait, btn 4
		if (currentRoom.allowWait) {
			btns[4].setButton("Wait", null, "WAIT:15");
			btns[4].addEventListener(MouseEvent.CLICK, movePlayer);
		}
		
		
		
	}
	
	
	static function doFoodComa( ?e:MouseEvent ) {
		var message:String = "";
		var totalDigested:Float = 0; //How much the player digests during the food coma
		var digested:Float = 0; //How much is digested during one tick
		var tick:Int = 0; //How many minutes the player spends digesting before their stomach streaches
		var fatGained:Int = 0;
		var poopGained:Int = 0;
		var cumGained:Float = 0;
		var milkGained:Float = 0;
		var stomachStreachTotal:Int = 0;
		
		var timeSpentInComa:Int = 0;
		var comaCount:Int = 0;
		var digestDamage:Int = 0;
		var digestedNPCs:Array<MyNPC> = new Array();
		
		txtPublic.visible = false;
		optionsBtn.visible = false;
		charDesc.visible = false;
		if (globals.debugMode)
			txtDebug.removeEventListener(MouseEvent.CLICK, debugMenu);
		
		newRoom = true;
		
		clearAllEvents();
		
		/* How long does it take for the player's stomach to streach
		 * how much mass does the player digest during that time
		 * repeat until stomachCurrent <= stomachCap
		 */
		
		while (playerCharacter.stomachCurrent > playerCharacter.stomachCap) {
			comaCount++;
			digested = playerCharacter.stomachCap;
			totalDigested += digested;
			
			tick = Math.round(digested / playerCharacter.digestDamage);
			
			timeSpentInComa += tick;
			
			playerCharacter.stomachCurrent -= digested;
			
			if (playerCharacter.stomachStreachCountdown != playerCharacter.stretchRateStomach) {
				stomachStreachTotal += playerCharacter.stretchAmountStomach;
				playerCharacter.stomachStreachCountdown = playerCharacter.stretchRateStomach;
			} else {
				if (tick <= playerCharacter.stretchRateStomach) {
					playerCharacter.stomachStreachCountdown -= tick;
					tick = 0;
				}
			}
			
			while (tick > playerCharacter.stretchRateStomach) {
				stomachStreachTotal += playerCharacter.stretchAmountStomach;
				tick -= playerCharacter.stretchRateStomach;
			}
			
			playerCharacter.stomachCap += stomachStreachTotal;
		}
		
		fatGained = playerCharacter.fatGain * timeSpentInComa;
		poopGained = Math.round(totalDigested / 3);
		if (playerCharacter.balls || (playerCharacter.penis && playerCharacter.hasPerk("inbal")))
			cumGained = playerCharacter.cumGain * timeSpentInComa;
		if (playerCharacter.breasts && playerCharacter.lac)
			milkGained = playerCharacter.milkGain * timeSpentInComa;
		
		playerCharacter.healthCurr = playerCharacter.healthMax;
		playerCharacter.fat += fatGained;
		playerCharacter.bowelsCurrent += poopGained;
		playerCharacter.cumCurrent += cumGained;
		playerCharacter.breastCurrent += milkGained;
		
		//NPCs in the belly
		for (i in 0...playerCharacter.stomachContents.length) {
			digestDamage = timeSpentInComa * playerCharacter.digestDamage;
			if (playerCharacter.stomachContents[i].healthCurr > 0) {
				var npcHealth = playerCharacter.stomachContents[i].healthCurr;
				
				playerCharacter.stomachContents[i].healthCurr -= digestDamage;
				digestDamage -= npcHealth;
			}
			if (digestDamage > 0) {
				playerCharacter.stomachContents[i].mass -= digestDamage;
			}
			if (playerCharacter.stomachContents[i].mass <= 0) {
				digestedNPCs.push(playerCharacter.stomachContents[i]);
			}
		}
		
		for (i in 0...digestedNPCs.length) {
			if (globals.allowScat)
				playerCharacter.bowelsContents.push(digestedNPCs[i]);
			playerCharacter.stomachContents.remove(digestedNPCs[i]);
		}
		
		message = "{Placeholder} You sleep for " + convertTime(timeSpentInComa) + " and digested " + totalDigested + " cubic inches of mass. You gained " + fatGained + "lbs of fat, " + poopGained + "lbs of poo, " + cumGained + "lbs of cum and " + milkGained + "lbs of milk. Your stomach streached out by " + stomachStreachTotal;
		
		
		
		outputText(message, "Food Coma");
		updateHUD();
		
		btns[11].setButton("Next", null, 0);
		btns[11].addEventListener(MouseEvent.CLICK, movePlayer);
	}
	
	static function doDeath( ?e:MouseEvent, ?how:String ) {
		
		clearAllEvents();
		
		outputText("{Placeholder} Dead", "Death");
		
		btns[11].setButton("Main Menu");
		btns[11].addEventListener(MouseEvent.CLICK, resetGame);
	}
	
	static function doHunt( e:MouseEvent ) {
		//Consume/passive hunting
		var takeAction:Int = e.currentTarget.btnID;
		var btnOptions:Object = Lib.current.getChildByName("Options Button");
		var btnDesc:Object = Lib.current.getChildByName("Desc Button");
		var txtTime:Object = Lib.current.getChildByName("Time");
		var message:String = "";
		var title:String = "";
		
		clearAllEvents();
		
		switch (takeAction) {
		case 0:
			//Just entered from movement system
			btnDesc.visible = false;
			btnOptions.visible = false;
			txtTime.visible = false;
			newRoom = false;
			
			roomNPC = new MyNPC();
			roomNPC.randomNPC(species, playerCharacter);
			
			title = "Consume - Hunting Prey";
			message += "Your eyes pass over the crowd of prey wandering the area, as you do your gaze falls on a " + roomNPC.gender("gender").toLowerCase() + " " + roomNPC.name + " watching you in return. " + roomNPC.gender("sub") + " looks very ";
			
			if (roomNPC.likeVore) {
				message += "excited";
			} else {
				message += "nervous";
			}
			
			message += " as you run your eyes over " + roomNPC.gender("obj").toLowerCase() + ".";
			
			btns[0].setButton("Consume", "Take " + roomNPC.gender("obj").toLowerCase() + " to the backroom and fill your belly.", 1);
			btns[0].addEventListener(MouseEvent.CLICK, doHunt);
			
			if (playerCharacter.arousal >= 50 && globals.allowSex) {
				btns[2].setButton("Fuck", "Take " + roomNPC.gender("obj").toLowerCase() + " to the backroom and sate yourself", 3);
				btns[2].addEventListener(MouseEvent.CLICK, doHunt);
			}
			btns[9].setButton("Look Again", "Take another look around the room", 0);
			btns[9].addEventListener(MouseEvent.CLICK, doHunt);
			btns[11].setButton("Leave", "Stop looking for prey", 0);
			btns[11].addEventListener(MouseEvent.CLICK, movePlayer);
		case 1:
			//Consume options
			txtPublic.visible = false;
			
			title = "Consume - Consumption Room";
			message += "You lead the " + roomNPC.name + " to the backroom, passing the bouncer at the back hall who makes a note on his clipboard as you walk past and handing you a key to one of the rooms. You lead your prey to the room marked on the key and unlock the door.</p><br><p>The room inside is setup like a cheap hotel room, a double bed is shoved into one corner most of the room is empty. Thin, abused carpet covers the floor, so badly discolored you can't even guess at what color it was originally. The bed has a basic set of sheets, also badly stained. The whole room has a faint, though not unpleasant, smell of cum.</p><br><p>The " + roomNPC.name + " follows you into the room, closing the door behind " + roomNPC.gender("obj").toLowerCase() + ". You run your eyes over your prey as " + roomNPC.gender("sub").toLowerCase() + " begins to disrobe.</p><br><p>";
			message += roomNPC.npcDesc();
			message += " " + roomNPC.gender("sub") + " stands near the middle of the room, waiting for you to make the first move.";
			
			newRoom = true;
			
			btns[0].setButton("Eat", "Your belly rumbles as you eye your prey.", 2);
			btns[0].addEventListener(MouseEvent.CLICK, doHunt);
			if (playerCharacter.arousal >= 50 && globals.allowSex) {
				btns[2].setButton("Fuck", "You need to sate yourself, perhaps then you'll fill your belly.", 3);
				btns[2].addEventListener(MouseEvent.CLICK, doHunt);
			}
			if (playerCharacter.hasPerk("cv") && playerCharacter.penis) {
				btns[3].setButton("CockVore", "Use your cock to consume your prey", 4);
				btns[3].disableButton();
				//btns[3].addEventListener(MouseEvent.CLICK, doHunt);
			}
			if (playerCharacter.hasPerk("bv") && playerCharacter.breasts) {
				btns[4].setButton("BreastVore", "Use your breasts to consume your prey", 5);
				btns[4].disableButton();
				//btns[4].addEventListener(MouseEvent.CLICK, doHunt);
			}
			if (playerCharacter.hasPerk("av")) {
				btns[5].setButton("AnalVore", "Use your ass to consume your prey", 6);
				btns[5].disableButton();
				//btns[5].addEventListener(MouseEvent.CLICK, doHunt);
			}
			if (playerCharacter.hasPerk("ub") && playerCharacter.vagina) {
				btns[6].setButton("Unbirth", "Slide your prey into your vagina", 7);
				btns[6].disableButton();
				//btns[6].addEventListener(MouseEvent.CLICK, doHunt);
			}
			
			btns[11].setButton("Leave", "You changed your mind, perhaps you'll seek other prey.", 10);
			btns[11].addEventListener(MouseEvent.CLICK, movePlayer);
		case 2:
			//Do the eating
			title = "Consume - Consumption Room";
			message += "This room is setup like a cheap hotel room, a double bed is shoved into one corner most of the room is empty. Thin, abused carpet covers the floor, so badly discolored you can't even guess at what color it was originally. The bed has a basic set of sheets, also badly stained. The whole room has a faint, though not unpleasant, smell of cum.</p><br><p>";
			message += "You move to " + roomNPC.gender("obj").toLowerCase() + " and, with an anticipatory rumble from your belly, open your mouth and cover the " + roomNPC.name + "'s head. You lift " + roomNPC.gender("obj").toLowerCase() + " and swallow, forcing " + roomNPC.gender("pos").toLowerCase() + " body down your throat and into your belly. Several swallows later and you're alone in the room, just you and your swollen belly. </p><p>Your stomach rumbles happily.";
			
			playerCharacter.stomachContents.push(roomNPC);
			playerCharacter.stomachCurrent += roomNPC.mass;
			playerCharacter.numEaten++;
			
			btns[11].setButton("Next", null, 10);
			btns[11].addEventListener(MouseEvent.CLICK, movePlayer);
		case 3:
			//Sex
			title = "Consume - Consumption Room";
			message += "This room is setup like a cheap hotel room, a double bed is shoved into one corner most of the room is empty. Thin, abused carpet covers the floor, so badly discolored you can't even guess at what color it was originally. The bed has a basic set of sheets, also badly stained. The whole room has a faint, though not unpleasant, smell of cum.</p><br><p>";
			roomNPC.mass += Math.round(playerCharacter.cumCurrent);
			message += "{Placeholder} Sex, " + playerCharacter.cum("NPC");
			
			btns[0].setButton("Eat", "You've emptied yourself, now fill yourself back up.", 2);
			btns[0].addEventListener(MouseEvent.CLICK, doHunt);
		case 4:
			//Cockvore
		case 5:
			//Breastvore
		case 6:
			//Analvore
		case 7:
			//Unbirth
		}
		
		outputText(message, title);
	}
	
	static function doTalk( e:MouseEvent ) {
		var charName:String = roomNPC.name;
		var clicked:Int = e.currentTarget.btnID;
		var talkFlag:String = roomNPC.talk[clicked][1][0];
		var quest:Bool = false;
		var questAction:String = "";
		var questFlag:String = "";
		var questID:Int = -1;
		var questValue:Int = -1;
		var questSkip:Int = -1;
		var keyID:Int = -1;
		var key:MyItem_Key = new MyItem_Key();
		var moneyChangeAmount:Int = -1;
		var feeding:Bool = false;
		var feedAmount:Int = -1;
		var butt:Bool = false;
		var buttAmount:Int = -1;
		var talkCommandArray:Array<Dynamic> = new Array();
		
		var message:String = "";
		var returnMessage:String = "";
		
		clearAllEvents();
		
		switch (clicked) {
		case 0:
			//Inital screen
			optionsBtn.visible = false;
			charDesc.visible = false; /*
			if (globals.debugMode)
				txtDebug.removeEventListener(MouseEvent.CLICK, debugMenu); */
			newRoom = false;
		}
		
		talkCommandArray = talkFlag.split("|");
		
		for (i in 0...talkCommandArray.length) {
			questFlag = talkCommandArray[i].split(" ")[0];
			
			switch (questFlag) {
			case "talk":
				//Normal text
			case "quest":
				//Quest
				quest = true;
				questID = Std.parseInt(talkCommandArray[i].split(" ")[1]);
			case "value":
				questValue = Std.parseInt(talkCommandArray[i].split(" ")[1]);
			case "skip":
				questSkip = Std.parseInt(talkCommandArray[i].split(" ")[1]);
			case "action":
				questAction = talkCommandArray[i].split(" ")[1];
			case "key":
				keyID = Std.parseInt(talkCommandArray[i].split(" ")[1]);
			case "money":
				moneyChangeAmount = Std.parseInt(talkCommandArray[i].split(" ")[1]);
			case "feed":
				feeding = true;
				feedAmount = Std.parseInt(talkCommandArray[i].split(" ")[1]);
			case "bowels":
				butt = true;
				buttAmount = Std.parseInt(talkCommandArray[i].split(" ")[1]);
			}
			
			if (quest) {
				if (playerCharacter.quest[questID] == null) {
					playerCharacter.quest[questID] = new MyQuest();
					playerCharacter.quest[questID].newQuest(quests[questID]);
				}
				
				switch (questAction) {
				case "set":
					//set QuestID.stage to questValue
					playerCharacter.quest[questID].stage = questValue;
				case "giveKey":
					//give the player keyID
					key.newKey(globals.keys[keyID]);
					returnMessage += key.giveKey();
				case "skip":
					//Skip to questSkip if questID.stage is greater then questValue
					if (playerCharacter.quest[questID].stage > questValue)
						clicked = questSkip;
				case "check":
					//Check playerCharacter.money agianst money if the player has less then money go to questSkip
					if (playerCharacter.money >= moneyChangeAmount) {
						playerCharacter.money -= moneyChangeAmount;
					} else {
						clicked = questSkip;
					}
				}
			}
		}
		
		if (feeding)
			playerCharacter.stomachCurrent += feedAmount;
		if (butt)
			playerCharacter.bowelsCurrent += buttAmount;
		
		message = roomNPC.talk[clicked][0];
		
		message += returnMessage;
		
		for (i in 0...roomNPC.talk[clicked][2].length) {
			btns[i].setButton(roomNPC.talk[clicked][2][i][0], roomNPC.talk[clicked][2][i][1], roomNPC.talk[clicked][2][i][2]);
			
			switch (roomNPC.talk[clicked][2][i][2]) {
			case -1:
				//Exit option
				btns[i].addEventListener(MouseEvent.CLICK, movePlayer);
				
			default:
				btns[i].addEventListener(MouseEvent.CLICK, doTalk);
			}
		}
		
		outputText(message, charName);
	}
	
	static function doPoop( e:MouseEvent ) {
		var message:String = "";
		var title:String = "";
		var choice:Int = e.currentTarget.btnID;
		
		var poopScene:String = "";
		var rndPee:Int = Math.round(Math.random() * 5);
		
		clearAllEvents();
		
		if (optionsBtn.visible) {
			optionsBtn.visible = false;
			charDesc.visible = false;
			if (globals.debugMode)
				txtDebug.removeEventListener(MouseEvent.CLICK, debugMenu);
		}
		
		if (globals.allowScat) {
			//Scat on
			switch (choice) {
			case 0:
				//First screen
				if (currentRoom.isPublic) {
					//Public restroom
					poopScene = "You lock the restroom door behind you, turning carefully in the small space and sitting down on the toilet with a sigh as your guts gurgle.</p><br><p>Your ";
				} else {
					//Private restroom
					poopScene = "You sigh and rub your gut as you approach your humble toilet, the faithful piece of porcelain having served you through years. Still, time again for it to serve, and you turn and rest your rump on the seat and clear your mind for this familiar ritual.</p><br><p>Your ";
				}
				
				poopScene += playerCharacter.sphincter + " clenches and quivers and your bowels groan as you rest your hands on your thighs and take a breath, the shifting inside building to that familiar pressure behind your anal sphincter.</p><br><p>";
				
				if (playerCharacter.bowelsCurrent == 0)
					poopScene += "You clench, feeling your innards shift, and a bubble of gas blows from your butt. Huh, looks like a false alarm.</p><br><p>";
				if ((playerCharacter.bowelsCurrent > 0) && (playerCharacter.bowelsCurrent <= playerCharacter.bowelsCap * .5))
					poopScene += "Your load is no issue for your ass to handle, the remains of your meal sliding through your spreading pucker with little fanfare and plopping into the porcelain bowl below, quick and simple.</p><br><p>";
				if ((playerCharacter.bowelsCurrent > playerCharacter.bowelsCap * .5) && (playerCharacter.bowelsCurrent <= playerCharacter.bowelsCap))
					poopScene += "With a grunt your ass spreads open, the thick mass of your digested meal slowly emerging from your innards and crackling in the cold bathroom air, the first sizable log breaking off and splashing into the bowl as less firm shit follows behind and flows steadily with a bit of clenching, obscuring' the water in the toilet under foul waste by the time you're done.</p><br><p>";
				if ((playerCharacter.bowelsCurrent > playerCharacter.bowelsCap) && (playerCharacter.bowelsCurrent <= playerCharacter.bowelsCap * 1.5))
					poopScene += "Your ass flexes outwards, the mass of shit held behind bulging your pucker out before it spreads over the dried head, the stretch causing you to wince and grunt as you work out the widest part, the smell of digested meat heavy in the air as inch by inch your bowels ripple and push that log through. With a heavy plop and a sigh that first load of former food slips from your hole, leaving you gaping for a second and breathing in relief, before the next, mercifully softer log presses on and out, the smoother texture almost a balm on your poor anal ring, and soon you get into a leisurely pattern of clenching and relaxing, filling the toilet nearly to the rim before you're empty.</p><br><p>";
				
				if (rndPee == 0) {
					poopScene += "Your bowels empty, another natural need arises, and you take the opportunity to empty your liquid waste, a rich golden stream of piss gushing from your ";
				
					if (playerCharacter.penis) {
						poopScene += "penis";
					} else {
						poopScene += "slit";
					}
					
					poopScene += "</p><br><p>";
				}
				
				poopScene += "Your business concluded, you give yourself a quick, thorough wipe with the available toilet paper, stand, and flush your waste away to the sewer where it belongs.</p><br><p>";
				
				if (playerCharacter.bowelsContents.length != 0) {
					poopScene += "The remains of a " + playerCharacter.bowelsContents[0].name;
					
					for (i in 1...playerCharacter.bowelsContents.length) {
						poopScene += ", a " + playerCharacter.bowelsContents[i].name;
					}
					
					poopScene += " slide from you and fill the bowl.</p>";
				}
				
				playerCharacter.bowelsContents = new Array();
				playerCharacter.bowelsCurrent = 0;
				
				updateHUD();
				
				newRoom = false;
				
				message = poopScene;
				title = "Restroom";
				
				btns[0].setButton("Items", null, 1);
				btns[0].disableButton();
				//btns[0].addEventListener(MouseEvent.CLICK, doPoop);
				
				btns[11].setButton("Finish");
				btns[11].addEventListener(MouseEvent.CLICK, movePlayer);
			case 1:
				//Item screen
				
			}
		} else {
			//Scat off
			title = "Restroom";
			message = "You make use of the facilities. You feel much better after.";
			
			btns[11].setButton("Next");
			btns[11].addEventListener(MouseEvent.CLICK, movePlayer);
		}
		
		outputText(message, title);
	}
	
	static function doSleep( e:MouseEvent ) {
		
		outputText("Sleep", "Sleep");
	}
	
	static function doPhone( e:MouseEvent ) {
		
		outputText("Phone", "Phone");
	}
	
	static function doDescription( e:MouseEvent ) {
		var title:String = playerCharacter.name;
		var message:String = "";
		var btnOptions:Object = Lib.current.getChildByName("Options Button");
		var btnDesc:Object = Lib.current.getChildByName("Desc Button");
		var txtTime:Object = Lib.current.getChildByName("Time");
		var takeAction:Int = e.currentTarget.btnID;
		var activeQuests:Array<MyQuest> = new Array();
		
		btnDesc.visible = false;
		btnOptions.visible = false;
		txtTime.visible = false;
		newRoom = false;
		txtPublic.visible = false;
		if (globals.debugMode)
			txtDebug.removeEventListener(MouseEvent.CLICK, debugMenu);
		
		clearAllEvents();
		
		switch (takeAction) {
		case 0:
			//Player description
			message += playerCharacter.playerDesc();
			message += "You have eaten " + playerCharacter.numEaten + " prey.";
			
			btns[0].setButton("Inventory", "View your inventory", 1);
			//btns[0].addEventListener(MouseEvent.CLICK, doDescription);
			btns[0].disableButton();
			
			btns[1].setButton("Keys", "View your keys", 2);
			btns[1].addEventListener(MouseEvent.CLICK, doDescription);
			
			btns[2].setButton("Prey", "See what you've consumed", 3);
			btns[2].addEventListener(MouseEvent.CLICK, doDescription);
			
			btns[3].setButton("Quests", "View your active quests", 4);
			btns[3].addEventListener(MouseEvent.CLICK, doDescription);
			
			btns[11].setButton("Back", "Back to the game");
			btns[11].addEventListener(MouseEvent.CLICK, movePlayer);
			
		case 1:
			//Player invintory
			
		case 2:
			//Keys
			title = "Keys";
			
			message += "Apartment key --- The key to your apartment. Never leave home without it.<br>";
			
			if (playerCharacter.keyRing.length != 0) {
				for (i in 0...playerCharacter.keyRing.length) {
					message += playerCharacter.keyRing[i].name + " --- " + playerCharacter.keyRing[i].desc + "<br>";
				}
			}
			
			message += "</p><br><p>";
			
			btns[11].setButton("Back", null, 0);
			btns[11].addEventListener(MouseEvent.CLICK, doDescription);
		case 3:
			//Prey
			title = "Consumed Prey";
			
			if (playerCharacter.stomachContents.length != 0) {
				message += "Stomach:";
				for (i in 0...playerCharacter.stomachContents.length) {
					message += "<br>A " + playerCharacter.stomachContents[i].name + " is ";
					if (playerCharacter.stomachContents[i].healthCurr > 0) {
						message += "alive";
						if (playerCharacter.stomachContents[i].likeVore) {
							message += " and masterbating";
						}
					} else {
						message += "dead";
					}
					message += ".";
					
					if (globals.debugMode)
						message += playerCharacter.stomachContents[i].healthCurr + " health " + playerCharacter.stomachContents[i].mass + " mass.";
				}
				message += "</p><br><p>";
			} else {
				message += "Your stomach is empty.</p><br><p>";
			}
			if (playerCharacter.ballContents.length != 0) {
				message += "Balls:";
				for (i in 0...playerCharacter.ballContents.length) {
					message += "<br>A " + playerCharacter.ballContents[i].name + " is ";
					if (playerCharacter.ballContents[i].healthCurr > 0) {
						message += "alive";
						if (playerCharacter.ballContents[i].likeVore) {
							message += " and masterbating";
						}
					} else {
						message += "dead";
					}
					message += ".";
					
					if (globals.debugMode)
						message += playerCharacter.ballContents[i].healthCurr + " health " + playerCharacter.ballContents[i].mass + " mass.";
				}
				message += "</p><br><p>";
			} else {
				message += "Your balls are empty.</p><br><p>";
			}
			
			
			btns[11].setButton("Back", null, 0);
			btns[11].addEventListener(MouseEvent.CLICK, doDescription);
		case 4:
			//Quests
			title = "Quests";
			
			for (i in 0...playerCharacter.quest.length) {
				if (!playerCharacter.quest[i].hidden && playerCharacter.quest[i].stageDesc[playerCharacter.quest[i].stage] != "") {
					activeQuests.push(playerCharacter.quest[i]);
				}
			}
			
			if (activeQuests.length == 0) {
				message = "No Quests, go look for some!";
			} else {
				message += "Quests:<br>";
				for (i in 0...activeQuests.length) {
					message += activeQuests[i].dispName + ": " + activeQuests[i].stageDesc[activeQuests[i].stage] + "<br>";
				}
			}
			
			btns[11].setButton("Back", null, 0);
			btns[11].addEventListener(MouseEvent.CLICK, doDescription);
		}
		
		outputText(message, title);
	}
	
	
	static function resetGame( e:MouseEvent ) {
		var choice:Int = e.currentTarget.btnID;
		
		clearAllEvents();
		
		switch (choice) {
		case 0:
			outputText("Return to the main menu? Anything not saved will be lost.", "Reset Game");
			
			btns[0].setButton("Yes", null, 1);
			btns[0].addEventListener(MouseEvent.CLICK, resetGame);
			btns[2].setButton("No");
			btns[2].addEventListener(MouseEvent.CLICK, optionsScreen);
		case 1:
			Lib.current.removeChildren();
			globals = new GlobalVars();
			playerCharacter = new MyPlayerObject();
			initialize();
			drawPlayfield();
			welcomeScreen();
		}
	}
	
	static function debugMenu( e:MouseEvent ) {
		var message:String = "";
		var option:Int = 0;
		var questID:Int = -1;
		var stage:Int = -1;
		var btnOptions:Array<String> = new Array();
		
		txtPublic.visible = false;
		optionsBtn.visible = false;
		charDesc.visible = false;
		txtDebug.removeEventListener(MouseEvent.CLICK, debugMenu);
		newRoom = false;
		
		if (e.currentTarget.hasOwnProperty("btnID")) {
			if (Type.typeof(e.currentTarget.btnID) == ValueType.TInt) {
				option = e.currentTarget.btnID;
			} else {
				btnOptions = e.currentTarget.btnID.split("|");
				option = Std.parseInt(btnOptions[0]);
				questID = Std.parseInt(btnOptions[1]);
				if (btnOptions.length == 3)
					stage = Std.parseInt(btnOptions[2]);
			}
		}
		
		clearAllEvents();
		
		switch (option) {
		case 0:
			message = "Choose wisely</p><br><p>Lactation is ";
			if (playerCharacter.lac) {
				message += "on";
			} else {
				message += "off";
			}
			message += ".</p><br><p>";
			
			btns[0].setButton("Toggle Lactation", null, 1);
			btns[0].addEventListener(MouseEvent.CLICK, debugMenu);
			btns[1].setButton("Set Quest stage", null, 2);
			btns[1].addEventListener(MouseEvent.CLICK, debugMenu);
			
			btns[11].setButton("Back");
			btns[11].addEventListener(MouseEvent.CLICK, movePlayer);
			
		case 1:
			message = "Lactation is now ";
			
			if (playerCharacter.lac) {
				playerCharacter.lac = false;
				message += "off";
			} else {
				playerCharacter.lac = true;
				message += "on";
			}
			message += ".";
			
			btns[11].setButton("Next", null, 0);
			btns[11].addEventListener(MouseEvent.CLICK, debugMenu);
		case 2:
			message = "Quest?";
			
			for (i in 0...playerCharacter.quest.length) {
				btns[i].setButton(playerCharacter.quest[i].name, null, "3|" + i);
				btns[i].addEventListener(MouseEvent.CLICK, debugMenu);
			}
			
			btns[11].setButton("Cancel", null, 0);
			btns[11].addEventListener(MouseEvent.CLICK, debugMenu);
		case 3:
			message = "Set stage to?";
			
			for (i in 0...playerCharacter.quest[questID].stageDesc.length) {
				btns[i].setButton("#" + i, null, "4|" + questID + "|" + i);
				btns[i].addEventListener(MouseEvent.CLICK, debugMenu);
			}
			
			btns[11].setButton("Cancel", null, 0);
			btns[11].addEventListener(MouseEvent.CLICK, debugMenu);
		case 4:
			playerCharacter.quest[questID].stage = stage;
			
			message = "Quest '" + playerCharacter.quest[questID].dispName + "' set to stage '" + stage + "': " + playerCharacter.quest[questID].stageDesc[stage];
			
			btns[11].setButton("Back", null, 0);
			btns[11].addEventListener(MouseEvent.CLICK, debugMenu);
		}
		
		outputText(message, "Debug Menu");
	}
	
	static function loadGame( e:MouseEvent ) {
		var saveDataObject:SharedObject = SharedObject.getLocal(globals.gameSaveName, "/");
		var gameLogo:Object = Lib.current.getChildByName("gameLogo");
		
		var save1Name:String = "No saved data";
		var save2Name:String = "No saved data";
		var save3Name:String = "No saved data";
		var save1Tip:String = null;
		var save2Tip:String = null;
		var save3Tip:String = null;
		var slot1Filled:Bool = false;
		var slot2Filled:Bool = false;
		var slot3Filled:Bool = false;
		
		var message:String = "";
		var clicked:Dynamic = e.currentTarget.btnID;
		
		if (gameLogo != null)
			Lib.current.removeChild(gameLogo);
		
		clearAllEvents();
		
		if (clicked == 0) {
			if (saveDataObject.data != null) {
				if (saveDataObject.data.save1 != null) {
					if (saveDataObject.data.save1[0] < globals.minBuildNumber || saveDataObject.data.player1.species == null) {
						//Old save data. Can't use it anymore
						save1Name = "Incompatable save data found in slot 1.";
						save1Tip = "Cannot load slot 1";
					} else {
						slot1Filled = true;
						if (saveDataObject.data.save1[0] == globals.buildNumber) {
							save1Name = saveDataObject.data.player1.name;
							save1Tip = "Load " + saveDataObject.data.player1.name;
						} else {
							//Out of date save data
							save1Name = saveDataObject.data.player1.name + " -- Needs updating";
							save1Tip = "Load " + saveDataObject.data.player1.name;
						}
					}
				}
				
				if (saveDataObject.data.save2 != null) {
					if (saveDataObject.data.save2[0] < globals.minBuildNumber || saveDataObject.data.player2.species == null) {
						save2Name = "Incompatable save data found in slot 2.";
						save2Tip = "Cannot load slot 2";
					} else {
						slot2Filled = true;
						if (saveDataObject.data.save2[0] == globals.buildNumber) {
							save2Name = saveDataObject.data.player2.name;
							save2Tip = "Load " + saveDataObject.data.player2.name;
						} else {
							save2Name = saveDataObject.data.player2.name + " -- Needs updating";
							save2Tip = "Load " + saveDataObject.data.player2.name;
						}
					}
				}
				
				if (saveDataObject.data.save3 != null) {
					if (saveDataObject.data.save3[0] < globals.minBuildNumber || saveDataObject.data.player3.species == null) {
						save3Name = "Incompatable save data found in slot 3.";
						save3Tip = "Cannot load slot 3";
					} else {
						slot3Filled = true;
						if (saveDataObject.data.save3[0] == globals.buildNumber) {
							save3Name = saveDataObject.data.player3.name;
							save3Tip = "Load " + saveDataObject.data.player3.name;
						} else {
							save3Name = saveDataObject.data.player3.name + " -- Needs updating";
							save3Tip = "Load " + saveDataObject.data.player3.name;
						}
					}
				}
				
			} else {
				save1Name = "No saved data";
				save2Name = "No saved data";
				save3Name = "No saved data";
				save1Tip = "Save to slot 1";
				save2Tip = "Save to slot 2";
				save3Tip = "Save to slot 3";
			}
			
			message = "Saved games:<br><br>Slot 1: " + save1Name + "<br>Slot 2: " + save2Name + "<br>Slot 3: " + save3Name;
			
			outputText(message, "Load Game");
			
			btns[0].setButton("Slot 1", save1Tip, 1);
			if (slot1Filled)
				btns[0].addEventListener(MouseEvent.CLICK, loadGame);
			btns[1].setButton("Slot 2", save2Tip, 2);
			if (slot2Filled)
				btns[1].addEventListener(MouseEvent.CLICK, loadGame);
			btns[2].setButton("Slot 3", save3Tip, 3);
			if (slot3Filled)
				btns[2].addEventListener(MouseEvent.CLICK, loadGame);
			
			btns[11].setButton("Back");
			switch (globals.backTo) {
			case "Welcome":
				btns[11].addEventListener(MouseEvent.CLICK, welcomeScreen);
			case "move":
				btns[11].addEventListener(MouseEvent.CLICK, optionsScreen);
			}
		} else {
			var loadedPlayer:Object = null;
			
			globals.debugMode = saveDataObject.data.globals[0];
			globals.textSize = saveDataObject.data.globals[1];
			globals.allowScat = saveDataObject.data.globals[2];
			globals.allowSex = saveDataObject.data.globals[3];
			globals.allowedGenders = saveDataObject.data.globals[4];
			
			switch (clicked) {
			case 1:
				globals.currentRoomID = saveDataObject.data.save1[1];
				loadedPlayer = saveDataObject.data.player1;
			case 2:
				globals.currentRoomID = saveDataObject.data.save2[1];
				loadedPlayer = saveDataObject.data.player2;
			case 3:
				globals.currentRoomID = saveDataObject.data.save3[1];
				loadedPlayer = saveDataObject.data.player3;
			}
			
			playerCharacter = loadedPlayer;
			
			globals.playerCharacter = playerCharacter;
			
			doorFuckCount = playerCharacter.end;
			
			if (playerCharacter.cumStreachCountdown == -1)
				playerCharacter.cumStreachCountdown = playerCharacter.stretchRateCum;
			if (playerCharacter.milkStreachCountdown == -1)
				playerCharacter.milkStreachCountdown = playerCharacter.stretchRateMilk;
			if (playerCharacter.bowelsStreachCountdown == -1)
				playerCharacter.bowelsStreachCountdown = playerCharacter.stretchRateBowels;
			if (playerCharacter.stomachStreachCountdown == -1)
				playerCharacter.stomachStreachCountdown = playerCharacter.stretchRateStomach;
			
			if (playerCharacter.quest.length != quests.length) {
				for (i in playerCharacter.quest.length...quests.length) {
					playerCharacter.quest[i] = new MyQuest();
					playerCharacter.quest[i].newQuest(quests[i]);
				}
			}
			
			if (playerCharacter.sphincter == null && playerCharacter.species != null)
				playerCharacter.sphincter = playerCharacter.species.sphincter;
			
			updateHUD();
			outputText("Game loaded from slot " + clicked, "Load Game");
			
			btns[11].setButton("Next", null, globals.currentRoomID + ":" + 0);
			btns[11].addEventListener(MouseEvent.CLICK, movePlayer);
		}
	}
	
	static function saveGame( e:MouseEvent ) {
		var saveDataObject:SharedObject = SharedObject.getLocal(globals.gameSaveName, "/");
		
		var save1Name:String = "";
		var save2Name:String = "";
		var save3Name:String = "";
		var save1Tip:String = "";
		var save2Tip:String = "";
		var save3Tip:String = "";
		
		var message:String = "";
		var clicked:Dynamic = e.currentTarget.btnID;
		
		clearAllEvents();
		
		if (clicked == 0) {
			if (saveDataObject.data != null) {
				if (saveDataObject.data.save1 != null) {
					if (saveDataObject.data.save1[0] < globals.minBuildNumber || saveDataObject.data.player1.species == null) {
						//Old save data. Can't use it anymore
						save1Name = "Incompatable save data found in slot 1.";
						save1Tip = "Save to slot 1";
					} else {
						if (saveDataObject.data.save1[0] == globals.buildNumber) {
							save1Name = saveDataObject.data.player1.name;
							save1Tip = "Overwrite " + saveDataObject.data.player1.name + " -- WARNING! This action cannot be undone!";
						} else {
							//Out of date save data
							save1Name = saveDataObject.data.player1.name + " -- Needs updating";
							save1Tip = "Update " + saveDataObject.data.player1.name + " -- WARNING! This action cannot be undone!";
						}
					}
				} else {
					save1Name = "No saved data";
					save1Tip = "Save to slot 1";
				}
				
				if (saveDataObject.data.save2 != null) {
					if (saveDataObject.data.save2[0] < globals.minBuildNumber || saveDataObject.data.player2.species == null) {
						save2Name = "Incompatable save data found in slot 2.";
						save2Tip = "Save to slot 2";
					} else {
						if (saveDataObject.data.save2[0] == globals.buildNumber) {
							save2Name = saveDataObject.data.player2.name;
							save2Tip = "Overwrite " + saveDataObject.data.player2.name + " -- WARNING! This action cannot be undone!";
						} else {
							save2Name = saveDataObject.data.player2.name + " -- Needs updating";
							save2Tip = "Update " + saveDataObject.data.player2.name + " -- WARNING! This action cannot be undone!";
						}
					}
				} else {
					save2Name = "No saved data";
					save2Tip = "Save to slot 2";
				}
				
				if (saveDataObject.data.save3 != null) {
					if (saveDataObject.data.save3[0] < globals.minBuildNumber || saveDataObject.data.player3.species == null) {
						save3Name = "Incompatable save data found in slot 3.";
						save3Tip = "Save to slot 3";
					} else {
						if (saveDataObject.data.save3[0] == globals.buildNumber) {
							save3Name = saveDataObject.data.player3.name;
							save3Tip = "Overwrite " + saveDataObject.data.player3.name + " -- WARNING! This action cannot be undone!";
						} else {
							save3Name = saveDataObject.data.player3.name + " -- Needs updating";
							save3Tip = "Update " + saveDataObject.data.player3.name + " -- WARNING! This action cannot be undone!";
						}
					}
				} else {
					save3Name = "No saved data";
					save3Tip = "Save to slot 3";
				}
				
			} else {
				save1Name = "No saved data";
				save2Name = "No saved data";
				save3Name = "No saved data";
				save1Tip = "Save to slot 1";
				save2Tip = "Save to slot 2";
				save3Tip = "Save to slot 3";
			}
			
			message = "Saved games:<br><br>Slot 1: " + save1Name + "<br>Slot 2: " + save2Name + "<br>Slot 3: " + save3Name;
			
			outputText(message, "Save Game");
			btns[0].setButton("Slot 1", save1Tip, 1);
			btns[0].addEventListener(MouseEvent.CLICK, saveGame);
			btns[1].setButton("Slot 2", save2Tip, 2);
			btns[1].addEventListener(MouseEvent.CLICK, saveGame);
			btns[2].setButton("Slot 3", save3Tip, 3);
			btns[2].addEventListener(MouseEvent.CLICK, saveGame);
			
			btns[11].setButton("Back");
			btns[11].addEventListener(MouseEvent.CLICK, optionsScreen);
		} else {
			var globalSaveArray:Array<Dynamic> = new Array();
			var playerSaveArray:Array<Dynamic> = new Array();
			
			globalSaveArray.push(globals.debugMode);
			globalSaveArray.push(globals.textSize);
			globalSaveArray.push(globals.allowScat);
			globalSaveArray.push(globals.allowSex);
			globalSaveArray.push(globals.allowedGenders);
			
			playerSaveArray[0] = globals.buildNumber;
			playerSaveArray[1] = globals.currentRoomID;
			
			saveDataObject.data.globals = globalSaveArray;
			
			switch (clicked) {
			case 1:
				saveDataObject.data.save1 = playerSaveArray;
				saveDataObject.data.player1 = playerCharacter;
			case 2:
				saveDataObject.data.save2 = playerSaveArray;
				saveDataObject.data.player2 = playerCharacter;
			case 3:
				saveDataObject.data.save3 = playerSaveArray;
				saveDataObject.data.player3 = playerCharacter;
			default:
				new AlertBox("ERROR: Bad save slot target " + clicked);
			}
			
			var saving:AlertBox = new AlertBox("Saving, please wait", false);
			
			saveDataObject.flush();
			
			saving.remove();
			
			outputText("Game saved to slot " + clicked, "Save Game");
			
			btns[11].setButton("Next");
			btns[11].addEventListener(MouseEvent.CLICK, optionsScreen);
		}
	}
	
	static function newGame( ?e:MouseEvent ) {
		var gameLogo:Object = Lib.current.getChildByName("gameLogo");
		var clicked:Dynamic = 0;
		var message:String = "";
		
		
		if (gameLogo != null) {
			Lib.current.removeChild(gameLogo);
			offset = 0;
		}
		
		if (e != null) {
			clicked = e.currentTarget.btnID;
		} else {
			clicked = step;
		}
		
		clearAllEvents();
		
		switch (clicked) {
		case -14:
			int -= 1;
			pointsAvail += 1;
			newGame();
		case -13:
			int += 1;
			pointsAvail -= 1;
			newGame();
		case -12:
			end -= 1;
			pointsAvail += 1;
			newGame();
		case -11:
			end += 1;
			pointsAvail -= 1;
			newGame();
		case -10:
			agi -= 1;
			pointsAvail += 1;
			newGame();
		case -9:
			agi += 1;
			pointsAvail -= 1;
			newGame();
		case -8:
			str -= 1;
			pointsAvail += 1;
			newGame();
		case -7:
			str += 1;
			pointsAvail -= 1;
			newGame();
		case -6:
			if (penis) {
				if (balls) {
					balls = false;
				} else {
					balls = true;
				}
			}
			newGame();
		case -5:
			if (penis) {
				penis = false;
				balls = false;
			} else {
				penis = true;
				balls = true;
			}
			newGame();
		case -4:
			if (vagina) {
				vagina = false;
			} else {
				vagina = true;
			}
			newGame();
		case -3:
			if (breasts) {
				breasts = false;
			} else {
				breasts = true;
			}
			newGame();
		case -2:
			offset -= 9;
			newGame();
		case -1:
			offset += 9;
			newGame();
		case 0:
			//Main page
			outputText("Choose a species:", "New Game");
			
			for (i in 0...9) {
				if (i + offset == species.length)
					break;
				btns[i].setButton(species[i + offset].name, null, "Species " + (i + offset));
				btns[i].addEventListener(MouseEvent.CLICK, newGame);
			}
			if (species.length - offset > 9) {
				btns[11].setButton("More", null, -1);
				btns[11].addEventListener(MouseEvent.CLICK, newGame);
			}
			if (offset != 0) {
				btns[9].setButton("Prev", null, -2);
				btns[9].addEventListener(MouseEvent.CLICK, newGame);
			}
			
			step = 0;
			globals.backTo = "Welcome";
			pointsAvail = 10;
			str = 1;
			agi = 1;
			end = 1;
			int = 1;
			perksToPick = 2;
			perksPicked = new Array();
		case 1:
			//Gender picker
			
			message = "Playing as a ";
			
			if (breasts && vagina && !penis && !balls)
				genderString = "Female";
			if (!breasts && !vagina && penis && (balls || !balls))
				genderString = "Male";
			if ((breasts || !breasts) && vagina && penis && (balls || !balls))
				genderString = "Herm";
			if (breasts && !vagina && penis && (!balls || balls))
				genderString = "Dickgirl";
			if (breasts && !vagina && !penis && !balls)
				genderString = "Doll";
			if (!breasts && vagina && !penis && !balls)
				genderString = "Cuntboy";
			if (!breasts && !vagina && !penis && !balls)
				genderString = "Neuter";
			
			message += genderString + " " + thisSpecies.name;
				
			message += "<br><br>Breasts: ";
			if (breasts) {
				message += "Yes";
			} else {
				message += "No";
			}
			message += "<br>Vagina: ";
			if (vagina) {
				message += "Yes";
			} else {
				message += "No";
			}
			message += "<br>Penis: ";
			if (penis) {
				message += "Yes";
			} else {
				message += "No";
			}
			message += "<br>Balls: ";
			if (balls) {
				message += "Yes";
			} else {
				message += "No";
			}
			
			btns[0].setButton("Breasts", null, -3);
			btns[0].addEventListener(MouseEvent.CLICK, newGame);
			btns[1].setButton("Vagina", null, -4);
			btns[1].addEventListener(MouseEvent.CLICK, newGame);
			btns[2].setButton("Penis", null, -5);
			btns[2].addEventListener(MouseEvent.CLICK, newGame);
			if (penis) {
				btns[3].setButton("Balls", null, -6);
				btns[3].addEventListener(MouseEvent.CLICK, newGame);
			}
			
			btns[9].setButton("Back", null, 0);
			btns[9].addEventListener(MouseEvent.CLICK, newGame);
			
			btns[11].setButton("Next", null, 2);
			btns[11].addEventListener(MouseEvent.CLICK, newGame);
			
			outputText(message, "New Game");
			step = 1;
		case 2:
			//Stat assign
			message = "Playing as a " + genderString + " " + thisSpecies.name + "<br><br>";
			
			message += "Distrubite your stat points. You have " + pointsAvail + " remaining.<br>";
			message += "Strength: " + str + "<br>";
			message += "Agility: " + agi + "<br>";
			message += "Endurance: " + end + "<br>";
			message += "Intelligence: " + int + "<br>";
			
			if (pointsAvail != 0) {
				btns[0].setButton("Strength+", null, -7);
				btns[0].addEventListener(MouseEvent.CLICK, newGame);
				btns[3].setButton("Agility+", null, -9);
				btns[3].addEventListener(MouseEvent.CLICK, newGame);
				btns[6].setButton("Endurance+", null, -11);
				btns[6].addEventListener(MouseEvent.CLICK, newGame);
				btns[9].setButton("Intelligence+", null, -13);
				btns[9].addEventListener(MouseEvent.CLICK, newGame);
			}
			
			if (str != 1) {
				btns[1].setButton("Strength-", null, -8);
				btns[1].addEventListener(MouseEvent.CLICK, newGame);
			}
			if (agi != 1) {
				btns[4].setButton("Agility-", null, -10);
				btns[4].addEventListener(MouseEvent.CLICK, newGame);
			}
			if (end != 1) {
				btns[7].setButton("Endurance-", null, -12);
				btns[7].addEventListener(MouseEvent.CLICK, newGame);
			}
			if (int != 1) {
				btns[10].setButton("Intelligence-", null, -14);
				btns[10].addEventListener(MouseEvent.CLICK, newGame);
			}
			
			
			btns[8].setButton("Back", null, 1);
			btns[8].addEventListener(MouseEvent.CLICK, newGame);
			
			if (pointsAvail == 0) {
				btns[11].setButton("Next", null, 3);
				btns[11].addEventListener(MouseEvent.CLICK, newGame);
			}
			
			outputText(message, "New Game");
			step = 2;
			offset = 0;
		case 3:
			//Perk pick
			message = "Playing as a " + genderString + " " + thisSpecies.name + "<br>";
			message += "Str: " + str + ", ";
			message += "Agi: " + agi + ", ";
			message += "End: " + end + ", ";
			message += "Int: " + int + "<br><br>";
			
			message += "Choose " + perksToPick + " perks:<br>";
			
			var btnNum:Int = 0;
			visiblePerks = new Array();
			
			for (i in 0...globals.perks.length) {
				if (globals.perks[i].showPerk)
					visiblePerks.push(globals.perks[i]);
			}
			
			if (visiblePerks.length > 9) {
				message += "Page: " + (Math.ceil(offset / 9) + 1) + " of " + Math.ceil(visiblePerks.length / 9) + "<br>";
			}
			
			message += "<br>";
			
			for (i in 0...9) {
				if (i + offset == visiblePerks.length)
					break;
				if (perksPicked.indexOf(i + offset) == -1) {
					message += "<font size = '+4'>☐</font> " + visiblePerks[i + offset].dispName + "<br>";
				} else {
					message += "<font size = '+4'>☒</font> " + visiblePerks[i + offset].dispName + "<br>";
				}
				message += "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" + visiblePerks[i + offset].desc + "<br><br>";
				btns[btnNum].setButton(visiblePerks[i + offset].dispName, null, ("perk " + (i + offset)));
				btns[btnNum].addEventListener(MouseEvent.CLICK, newGame);
				btnNum += 1;
			}
			if (visiblePerks.length - offset > 9) {
				btns[11].setButton("More", null, -1);
				btns[11].addEventListener(MouseEvent.CLICK, newGame);
			}
			if (offset != 0) {
				btns[9].setButton("Prev", null, -2);
				btns[9].addEventListener(MouseEvent.CLICK, newGame);
			}
			
			btns[10].setButton("Back", null, 2);
			btns[10].addEventListener(MouseEvent.CLICK, newGame);
			
			if (perksToPick == 0) {
				btns[10].setButton("Next", null, 4);
			}
			
			step = 3;
			outputText(message, "New Game");
		case 4:
			//Name
			var txtFormat:TextFormat = new TextFormat("Sans", globals.textSize + 2);
			
			var plrName:TextField = new TextField();
			plrName.x = 60;
			plrName.y = 125;
			plrName.type = TextFieldType.INPUT;
			plrName.name = "playername";
			plrName.visible = true;
			plrName.border = true;
			plrName.height = 30;
			plrName.width = 100;
			plrName.text = "";
			plrName.defaultTextFormat = txtFormat;
			Lib.current.addChild(plrName);
			
			message = "Playing as a " + genderString + " " + thisSpecies.name + "<br>";
			message += "Str: " + str + ", ";
			message += "Agi: " + agi + ", ";
			message += "End: " + end + ", ";
			message += "Int: " + int + "<br>";
			message += "Perks: ";
			
			message += visiblePerks[perksPicked[0]].dispName + ", " + visiblePerks[perksPicked[1]].dispName + "<br><br>";
			
			message += "Name?";
			
			btns[11].setButton("Next", null, 5);
			btns[11].addEventListener(MouseEvent.CLICK, newGame);
			
			outputText(message, "New Game");
		case 5:
			//Confirm
			var plrName:Object = Lib.current.getChildByName("playername");
			
			if (plrName.text == "") {
				playerName = "Food";
			} else {
				playerName = plrName.text;
			}
			
			Lib.current.removeChild(plrName);
			
			message = "Do you want to play as a " + genderString + " " + thisSpecies.name + " named " + playerName + " with the following stats?<br>";
			message += "Str: " + str + ", ";
			message += "Agi: " + agi + ", ";
			message += "End: " + end + ", ";
			message += "Int: " + int + "<br>";
			message += "Perks: ";
			
			message += visiblePerks[perksPicked[0]].dispName + ", " + visiblePerks[perksPicked[1]].dispName + "<br><br>";
			
			outputText(message, "New Game");
			
			btns[0].setButton("Yes", null, 6);
			btns[0].addEventListener(MouseEvent.CLICK, newGame);
			
			btns[2].setButton("No", null, 4);
			btns[2].addEventListener(MouseEvent.CLICK, newGame);
		case 6:
			//Create new player object
			for (i in 0...perksPicked.length) {
				finalPerks.push(visiblePerks[perksPicked[i]]);
			}
			
			playerCharacter = new MyPlayerObject();
			playerCharacter.newPlayer(thisSpecies, breasts, vagina, penis, balls, str, agi, end, int, playerName, finalPerks);
			playerCharacter.quest = new Array();
			
			for (i in 0...quests.length) {
				playerCharacter.quest.push(new MyQuest());
				playerCharacter.quest[playerCharacter.quest.length - 1].newQuest(quests[i]);
			}
			
			playerCharacter.emptyStomachCountdown = playerCharacter.end;
			doorFuckCount = playerCharacter.end;
			
			globals.playerCharacter = playerCharacter;
			
			updateHUD();
			
			message = "6:00 AM. <i>Damn, forgot to turn the alarm off.</i> You roll over and glare at the little black box chirping merrily away, telling you it's time to wake up and get ready for your job.</p><br><p>That you no longer have.</p><br><p>You groan and turn the alarm off, sitting up and thinking about what you're going to do. You remember you lost your job yesterday. Apparently licking coworkers and saying they taste good is frowned upon.</p><br><p>Oh well. Time to find a new way to pay the bills. Maybe that new club down the street is looking for a bartender or bouncer or something.";
			
			outputText(message, "BEEP! BEEP! BEEP! BEEP!");
			
			btns[11].setButton("Next", null, 0);
			btns[11].addEventListener(MouseEvent.CLICK, movePlayer);
			
			//Look into variable destructors, take out all the ones used in character creation don't need them past this point.
			
			
		default:
			//Species info/confirmation screen
			switch (clicked.split(" ")[0]) {
			case "Species":
				thisSpecies = species[Std.parseInt(clicked.split(" ")[1])];
				
				message = "Do you want to play as a " + thisSpecies.name + "?</p><br><p>";
				
				message += "Height: " + toFeet(thisSpecies.minHeight) + " to " + toFeet(thisSpecies.maxHeight) + "<br>";
				message += "Weight: " + thisSpecies.minWeight + "lbs to " + thisSpecies.maxWeight + "lbs<br>";
				message += "Chest: " + thisSpecies.minChest + "\" to " + thisSpecies.maxChest + "\"<br>";
				message += "Waist: " + thisSpecies.minWaist + "\" to " + thisSpecies.maxWaist + "\"<br>";
				message += "Hips: " + thisSpecies.minHips + "\" to " + thisSpecies.maxHips + "\"<br>";
				message += "Butt: " + thisSpecies.minButt + "\" to " + thisSpecies.maxButt + "\"<br>";
				message += "Breast Size: " + thisSpecies.breasts + "<br>";
				message += "Penis Length: " + thisSpecies.penisL + "\"<br>";
				message += "Penis Width: " + thisSpecies.penisW + "\"<br>";
				message += "Ball Size: " + thisSpecies.balls + "\"<br><br>";
				
				message += "Stomach Capacity: " + thisSpecies.stomach + "<br>";
				message += "Bowels Capacity: " + thisSpecies.bowels + "<br>";
				message += "Cum Capacity: " + thisSpecies.cum + "<br>";
				message += "Milk Capacity: " + thisSpecies.milk;
				
				breasts = true;
				vagina = true;
				penis = true;
				balls = true;
				
				outputText(message, "New Game");
				
				btns[0].setButton("Yes", null, 1);
				btns[0].addEventListener(MouseEvent.CLICK, newGame);
				btns[2].setButton("No", null, 0);
				btns[2].addEventListener(MouseEvent.CLICK, newGame);
			case "perk":
				var perkID:Int = Std.parseInt(clicked.split(" ")[1]);
				
				if (perksPicked.indexOf(perkID) == -1) {
					if (perksToPick != 0) {
						perksPicked.push(perkID);
						perksToPick -= 1;
					}
				} else {
					perksPicked.remove(perkID);
					perksToPick += 1;
				}
				
				newGame();
			default:
				new AlertBox("Error, bad split in newGame: " + clicked.split(" ")[0]);
			}
			globals.backTo = "null";
		}
		
		switch (globals.backTo) {
		case "null":
			
		case "Welcome":
			btns[10].setButton("Back", "Back to the welcome screen");
			btns[10].addEventListener(MouseEvent.CLICK, welcomeScreen);
		}
	}
	
	static function optionsScreen(?e:MouseEvent) {
		var btnOptions:Object = Lib.current.getChildByName("Options Button");
		var gameLogo:Object = Lib.current.getChildByName("gameLogo");
		var btnDesc:Object = Lib.current.getChildByName("Desc Button");
		var txtTime:Object = Lib.current.getChildByName("Time");
		var txtBowels:Object = Lib.current.getChildByName("Bowels");
		var txtDebug:Object = Lib.current.getChildByName("Debug");
		var txtArousal:Object = Lib.current.getChildByName("Arousal");
		
		if (gameLogo != null)
			Lib.current.removeChild(gameLogo);
		
		var clicked:Int = 0;
		
		if (e != null)
			clicked = e.currentTarget.btnID;
		
		clearAllEvents();
		
		outputText("Debug Mode: " + globals.debugMode + "</p><p>Text Size: " + globals.textSize + "</p><p>Allow Scat: " + globals.allowScat + "</p><p>Allow Sex: " + globals.allowSex, "Options");
		
		btnOptions.visible = false;
		btnDesc.visible = false;
		txtTime.visible = false;
		txtPublic.visible = false;
		newRoom = false;
		
		switch (clicked) {
		case 0:
			btns[0].setButton("Scat", "Allow/disallow scat. Controls if your character poops or not.", 1);
			btns[0].addEventListener(MouseEvent.CLICK, optionsScreen);
			btns[1].setButton("Arousal", "Allow/disallow sex. Controls if your character becomes aroused.", 3);
			btns[1].addEventListener(MouseEvent.CLICK, optionsScreen);
			btns[2].setButton("Debug", "Toggle debug mode.", 2);
			btns[2].addEventListener(MouseEvent.CLICK, optionsScreen);
			btns[3].setButton("Font Size+");
			btns[3].addEventListener(MouseEvent.CLICK, increaseFontSize);
			btns[4].setButton("Font Size-");
			btns[4].addEventListener(MouseEvent.CLICK, decreaseFontSize);
			
			if (globals.backTo != "Welcome") {
				btns[6].setButton("Main Menu", "Start a new game. Current game will be lost.", 0);
				btns[6].addEventListener(MouseEvent.CLICK, resetGame);
			}
			
			btns[11].setButton("Back");
			
			switch (globals.backTo) {
				case "Welcome":
					btns[11].addEventListener(MouseEvent.CLICK, welcomeScreen);
				case "move":
					btns[9].setButton("Save", null, 0);
					btns[9].addEventListener(MouseEvent.CLICK, saveGame);
					
					btns[11].addEventListener(MouseEvent.CLICK, movePlayer);
				default:
					new AlertBox("Bad options screen backTo: " + globals.backTo);
			}
		case 1:
			//Toggle scat
			if (globals.allowScat) {
				globals.allowScat = false;
				txtBowels.visible = false;
			} else {
				globals.allowScat = true;
				txtBowels.visible = true;
			}
			optionsScreen();
		case 2:
			//Toggle debug
			if ( globals.debugMode ) {
				globals.debugMode = false;
				txtDebug.visible = false;
			} else {
				globals.debugMode = true;
				txtDebug.visible = true;
			}
			optionsScreen();
		case 3:
			//Toggle sex
			if (globals.allowSex) {
				globals.allowSex = false;
				txtArousal.visible = false;
			} else {
				globals.allowSex = true;
				txtArousal.visible = true;
			}
			optionsScreen();
		}
	}
	
	static function increaseFontSize( e:MouseEvent ) {
		var txtOutput:Object = Lib.current.getChildByName("Output Field");
		
		var outStyle:StyleSheet = new StyleSheet();
		var headStyle:StyleSheet = new StyleSheet();
		var bodyStyle:StyleSheet = new StyleSheet();
		var byStyle:StyleSheet = new StyleSheet();
		var pStyle:StyleSheet = new StyleSheet();
		var titleStyle:StyleSheet = new StyleSheet();
		
		var labelFormat:TextFormat = new TextFormat();
		var charNameFormat:TextFormat = new TextFormat();
		var versionFormat:TextFormat = new TextFormat();
		
		var textSize:Int = globals.textSize;
		
		textSize += 2;
		if (textSize >= 32)
			textSize = 30;
		
		headStyle.fontWeight = "bold";
		headStyle.fontSize = textSize + 20;
		headStyle.textAlign = "center";
		
		bodyStyle.textSize = textSize;
		pStyle.textSize = textSize +2;
		
		byStyle.fontStyle = "italic";
		byStyle.fontSize = textSize - 2;
		byStyle.textAlign = "center";
		
		titleStyle.fontWeight = "bold";
		titleStyle.fontSize = textSize + 8;
		
		outStyle.setStyle(".heading", headStyle);
		outStyle.setStyle(".byline", byStyle);
		outStyle.setStyle("p", pStyle);
		outStyle.setStyle("body", bodyStyle);
		outStyle.setStyle(".title", titleStyle);
		
		globals.textSize = textSize;
		
		optionsScreen();
	}
	
	static function decreaseFontSize( e:MouseEvent ) {
		var txtOutput:Object = Lib.current.getChildByName("Output Field");
		
		var outStyle:StyleSheet = new StyleSheet();
		var headStyle:StyleSheet = new StyleSheet();
		var bodyStyle:StyleSheet = new StyleSheet();
		var byStyle:StyleSheet = new StyleSheet();
		var pStyle:StyleSheet = new StyleSheet();
		var titleStyle:StyleSheet = new StyleSheet();
		
		var labelFormat:TextFormat = new TextFormat();
		var charNameFormat:TextFormat = new TextFormat();
		var versionFormat:TextFormat = new TextFormat();
		
		var textSize:Int = globals.textSize;
		
		textSize -= 2;
		if (textSize <= 6)
			textSize = 8;
		
		headStyle.fontWeight = "bold";
		headStyle.fontSize = textSize + 20;
		headStyle.textAlign = "center";
		
		bodyStyle.textSize = textSize;
		pStyle.textSize = textSize +2;
		
		byStyle.fontStyle = "italic";
		byStyle.fontSize = textSize - 2;
		byStyle.textAlign = "center";
		
		titleStyle.fontWeight = "bold";
		titleStyle.fontSize = textSize + 8;
		
		outStyle.setStyle(".heading", headStyle);
		outStyle.setStyle(".byline", byStyle);
		outStyle.setStyle("p", pStyle);
		outStyle.setStyle("body", bodyStyle);
		outStyle.setStyle(".title", titleStyle);
		
		globals.textSize = textSize;
		
		optionsScreen();
	}
	
	static function showHidden( e:MouseEvent ) {
		var clickedBtn:String = e.currentTarget.btnID;
		
		switch (clickedBtn) {
		case "nw":
			btns[0].setButton(currentRoom.exitNW.name, currentRoom.exitNW.desc, currentRoom.exitNW.travelTo + ":" + currentRoom.exitNW.travelTime);
			btns[0].removeEventListener(MouseEvent.CLICK, showHidden);
			btns[0].addEventListener(MouseEvent.CLICK, movePlayer);
			
			playerCharacter.quest[currentRoom.exitNW.hiddenQuestID].stage = 1;
		case "n":
			btns[1].setButton(currentRoom.exitN.name, currentRoom.exitN.desc, currentRoom.exitN.travelTo + ":" + currentRoom.exitN.travelTime);
			btns[1].removeEventListener(MouseEvent.CLICK, showHidden);
			btns[1].addEventListener(MouseEvent.CLICK, movePlayer);
			
			playerCharacter.quest[currentRoom.exitN.hiddenQuestID].stage = 1;
		case "ne":
			btns[2].setButton(currentRoom.exitNE.name, currentRoom.exitNE.desc, currentRoom.exitNE.travelTo + ":" + currentRoom.exitNE.travelTime);
			btns[2].removeEventListener(MouseEvent.CLICK, showHidden);
			btns[2].addEventListener(MouseEvent.CLICK, movePlayer);
			
			playerCharacter.quest[currentRoom.exitNE.hiddenQuestID].stage = 1;
		case "w":
			btns[3].setButton(currentRoom.exitW.name, currentRoom.exitW.desc, currentRoom.exitW.travelTo + ":" + currentRoom.exitW.travelTime);
			btns[3].removeEventListener(MouseEvent.CLICK, showHidden);
			btns[3].addEventListener(MouseEvent.CLICK, movePlayer);
			
			playerCharacter.quest[currentRoom.exitW.hiddenQuestID].stage = 1;
		case "e":
			btns[5].setButton(currentRoom.exitE.name, currentRoom.exitE.desc, currentRoom.exitE.travelTo + ":" + currentRoom.exitE.travelTime);
			btns[5].removeEventListener(MouseEvent.CLICK, showHidden);
			btns[5].addEventListener(MouseEvent.CLICK, movePlayer);
			
			playerCharacter.quest[currentRoom.exitE.hiddenQuestID].stage = 1;
		case "sw":
			btns[6].setButton(currentRoom.exitSW.name, currentRoom.exitSW.desc, currentRoom.exitSW.travelTo + ":" + currentRoom.exitSW.travelTime);
			btns[6].removeEventListener(MouseEvent.CLICK, showHidden);
			btns[6].addEventListener(MouseEvent.CLICK, movePlayer);
			
			playerCharacter.quest[currentRoom.exitSW.hiddenQuestID].stage = 1;
		case "s":
			btns[7].setButton(currentRoom.exitS.name, currentRoom.exitS.desc, currentRoom.exitS.travelTo + ":" + currentRoom.exitS.travelTime);
			btns[7].removeEventListener(MouseEvent.CLICK, showHidden);
			btns[7].addEventListener(MouseEvent.CLICK, movePlayer);
			
			playerCharacter.quest[currentRoom.exitS.hiddenQuestID].stage = 1;
		case "se":
			btns[8].setButton(currentRoom.exitSE.name, currentRoom.exitSE.desc, currentRoom.exitSE.travelTo + ":" + currentRoom.exitSE.travelTime);
			btns[8].removeEventListener(MouseEvent.CLICK, showHidden);
			btns[8].addEventListener(MouseEvent.CLICK, movePlayer);
			
			playerCharacter.quest[currentRoom.exitSE.hiddenQuestID].stage = 1;
		}
	}
	
	static function displayFAQ( e:MouseEvent ) {
		var logo:Object = Lib.current.getChildByName("gameLogo");
		
		var qanda:Array<String> = new Array();
		var message:String = "";
		
		qanda.push("<p><b>Waaaa The game sucks now! What happened?!</b></p><p>Sorry about that, while working on adding features that I've been asked about a number of times I figured out that it would be easier to rewrite the game to support those features from the ground up rather then trying to shoehorn them into my existing engine. I started working on that in version 0.29, so if you're looking for a playable version you'll have to go back to v0.28 (which you can still find on my furAffinity page). Hopefully I'll have this new engine in a working state soon. Until then, please stick around!</p>");
		qanda.push("<p><b>Will there be an option for the player to be eaten?</b></p><p>Yes. There are a few scenes in place already. There will be more as the game progresses.</p>");
		qanda.push("<p><b>Will there be [insert type of vore]?</b></p><p>Yes, it's going to take a while before any besides oral are in place, though there are currently a few types of NPC non-oral vore in place now.</p>");
		qanda.push("<p><b>Will there be [insert species]?</b></p><p>Working on adding species! There's usually a poll going on the forum to pick which species gets added in the next update. And I'm always willing to hear suggestions.</p>");
		qanda.push("<p><b>Will you add graphics/Can I make graphics for your game?</b></p><p>Yes! In fact there is a list of bounties available on the forums!</p>");
		qanda.push("<p><b>Can I write scenes?</b></p><p>Yes. Write it up and send it to me, either note or email. If I can get it in the game I'll do so and let you know (and yes you will be credited with writing it in game.) You can also write characters if you'd like, more information, including what slots are open, can be found on the forums.</p>");
		qanda.push("<p><b>Can I pay your for your wonderful fetish game?</b></p><p>By all means, yes! Yes you can! ... And I've made it even easier for you, just head over to Patreon <a target='_new' href='https://www.patreon.com/SillySnowFox'><u>here</u></a> and pledge a couple dollars!</p>");
		qanda.push("<p><b>What do you use to make Consume?</b></p><p>Consume is written in ActionScript and compiled into flash by using HaXe. I use FlashDevelop as the debugging environment. This causes a few odd issues as HaXe doesn't support some aspects of ActionScript for some reason but it also doesn't require a subscription.</p>");
		
		
		Lib.current.removeChild(logo);
		
		clearAllEvents();
		
		for (i in 0...qanda.length) {
			message += qanda[i] + "<br>";
		}
		
		outputText(message, "Frequently Asked Questions");
		
		btns[8].setButton("Back");
		btns[8].addEventListener(MouseEvent.CLICK, welcomeScreen);
	}	
	
	static function displayCredits( e:MouseEvent ) {
		var logo:Object = Lib.current.getChildByName("gameLogo");
		
		var credits:Array<String> = new Array();
		var backerCredits:Array<String> = new Array();
		var oneLineBackers:Array<String> = new Array();
		var message:String = "";
		
		clearAllEvents();
		Lib.current.removeChild(logo);
		
		credits.push("Consume logo design by forum member Alcathair.");
		credits.push("Guffin character created by forum member Foxlets.");
		credits.push("Ice cream shop content contributed by forum member Foxlets.");
		credits.push("Scat and gym anal sex scenes contributed by forum member Victor Styche.");
		credits.push("Gym female oral sex scenes contributed by forum member BeardyKomodo.");
		
		//oneLineBackers.push("pelle"); //Dropped to $1 Feb
		oneLineBackers.push("Writer"); //Paid Feb #10
		
		
		//backerCredits.push("Foxlets"); //Dropped below $5 in October
		backerCredits.push("Bradley Taylor"); //Paid Feb $5
		backerCredits.push("OutsideOctaves"); //Paid Feb $5
		backerCredits.push("Michael Brookins"); //Paid Feb $5
		backerCredits.push("Erik Camp"); //Paid Feb $5
		backerCredits.push("Pell Torr"); //Paid Feb $5
		
		
		for (i in 0...credits.length) {
			message += "<p>" + credits[i] + "</p>";
		}
		
		message += "<br><p><b>Thanks to my Patreon backers!</b></p><br>";
		
		for (i in 0...oneLineBackers.length) {
			message += "<p>" + oneLineBackers[i] + "</p>";
		}
		
		message += "<br><p>" + backerCredits[0];
		
		for (i in 1...backerCredits.length) {
			message += ", " + backerCredits[i];
		}
		
		outputText("Game code and story by Kyra Sunseeker.</b></p><br>" + message, "Credits");
		
		btns[8].setButton("Back");
		btns[8].addEventListener(MouseEvent.CLICK, welcomeScreen);
	}

	static function welcomeScreen(?event:MouseEvent) {
		var txtOutput:Object  = Lib.current.getChildByName("Output Field");
		var welcomeMessage:Array<String> = globals.welcomeMessage;
		var date:Date = Date.now();
		var textSize:Int = globals.textSize;
		
		var message:String = "";
		var rndNumer:Int = Math.round(Math.random() * (welcomeMessage.length - 1));
		var month:Int = date.getMonth();
		var day:Int = date.getDate();
		
		var logo:Bitmap = new Bitmap();
		var logoData:BitmapData = new BitmapData(469, 259);
		
		var gameLogoM:LogoM = new LogoM(469, 259);
		var gameLogoF:LogoF = new LogoF(469, 259);
		
		// for testing startup messages, set to the index of the message to test and uncomment
		//rndNumer = 26;
		message = welcomeMessage[rndNumer];
		
		if (month == 7 && day == 8) // my birthday!
			message = "Happy birthday Kyra!";
		
		if (month == 9 && day == 31) //Halloween
			message = "Happy Halloween!";
		
		if (month == 11 && day == 25) //Christmas
			message = "Merry Christmas!";
		
		if (month == 0 && day == 1) //New Years
			message = "Happy New Year!";
		
		if (Math.round(Math.random()) == 0) {
			logoData = gameLogoM;
		} else {
			logoData = gameLogoF;
		}
		
		logo.bitmapData = logoData;
		logo.name = "gameLogo";
		logo.x = 10;
		logo.y = 11;
		logo.visible = true;
		Lib.current.addChild(logo);
		
		txtOutput.htmlText = "<body><br><br><p><span class='byline'>Created by Kyra Sunseeker</span></p><br><br><p><span class = 'heading'>&nbsp;&nbsp;Welcome to</span></p><br><br><br><br><br><br><br><p><font size='" + textSize + "'><br><br><p align = 'center'><u><a target='_blank' href='http://dancingfoxstudios.com/'>Dancing Fox Studios</a></u></p><br><br><br><font size = '" + textSize + "'><p align = 'center'>" + message + "</p></font></body>";
		
		clearAllEvents();
		
		btns[0].setButton("New Game", "Start a new game", 0);
		btns[0].addEventListener(MouseEvent.CLICK, newGame);
		btns[1].setButton("Load", "Load a saved game", 0);
		btns[1].addEventListener(MouseEvent.CLICK, loadGame);
		btns[2].setButton("Options");
		btns[2].addEventListener(MouseEvent.CLICK, optionsScreen);
		
		btns[6].setButton("F.A.Q.");
		btns[6].addEventListener(MouseEvent.CLICK, displayFAQ);
		
		btns[8].setButton("Credits");
		btns[8].addEventListener(MouseEvent.CLICK, displayCredits);
		
		globals.backTo = "Welcome";
	}
	
	static function scrollTop( e:MouseEvent ) {
		var txtOutput:Object = Lib.current.getChildByName("Output Field");
		
		txtOutput.scrollV = 1;
	}
	
	static function scrollUp( e:MouseEvent ) {
		var txtOutput:Object = Lib.current.getChildByName("Output Field");
		
		txtOutput.scrollV -= 3;
	}
	
	static function scrollDn( e:MouseEvent ) {
		var txtOutput:Object = Lib.current.getChildByName("Output Field");
		
		txtOutput.scrollV += 3;
	}
	
	static function scrollBm( e:MouseEvent ) {
		var txtOutput:Object = Lib.current.getChildByName("Output Field");
		
		txtOutput.scrollV = txtOutput.maxScrollV;
	}
	
	/**************************\
	 *                        *
	 * Non-cickable functions *
	 *                        *
	\**************************/
	
	static function convertTime(minutes:Int):String {
		var hours:Int = 0;
		var days:Int = 0;
		var years:Int = 0;
		
		var message:String = "";
		
		while (minutes >= 60) {
			minutes -= 60;
			hours++;
		}
		while (hours >= 24) {
			hours -= 24;
			days++;
		}
		while (days >= 365) {
			days -= 365;
			years++;
		}
		
		if (minutes != 0)
			message = minutes + " minutes";
		if (hours != 0)
			message = hours + " hours and " + minutes + " minutes";
		if (days != 0)
			message = days + " days, " + hours + " hours and " + minutes + " minutes";
		if (years != 0)
			message = years + " years, " + days + " days, " + hours + " hours and " + minutes + " minutes";
		
		return message;
	}
	
	static function toFeet(inches:Float):String {
		var feet:Int = 0;
		
		while (inches > 11) {
			feet += 1;
			inches -= 12;
		}
		
		return (feet + "'" + inches + "\"");
	}
	
	static function outputText(body:String, title:String = null) {
		var txtOutput:Object = Lib.current.getChildByName("Output Field");
		var textSize:Int = globals.textSize;
		var toTop:Object = Lib.current.getChildByName("U2T");
		var upThree:Object = Lib.current.getChildByName("U3L");
		var dnThree:Object = Lib.current.getChildByName("D3L");
		var toBtm:Object = Lib.current.getChildByName("D2B");
		
		var formattedText:String = "<body>";
		
		var text:TextField = new TextField();
		
		if (title != null) {
			formattedText += "<span class = 'title'>" + title + "</span><br>";
			for (n in 0...20) {
				formattedText += "—";
			}
			formattedText += "<br>";
		}
		
		//this is where the text will get run through the parse system, for now skip it
		
		formattedText += "<font size = '" + textSize + "'><p>" + body + "</p></font></body>";
		
		txtOutput.htmlText = formattedText;
		
		if (txtOutput.numLines > txtOutput.bottomScrollV) {
			toTop.textColor = 0x000000;
			toTop.text = "Tp";
			toTop.addEventListener(MouseEvent.CLICK, scrollTop);
			
			upThree.textColor = 0x000000;
			upThree.text = "Up";
			upThree.addEventListener(MouseEvent.CLICK, scrollUp);
			
			dnThree.textColor = 0x000000;
			dnThree.text = "Dn";
			dnThree.addEventListener(MouseEvent.CLICK, scrollDn);
			
			toBtm.textColor = 0x000000;
			toBtm.text = "Bm";
			toBtm.addEventListener(MouseEvent.CLICK, scrollBm);
		} else {
			toTop.textColor = 0xD8D8D8;
			toTop.text = "Tp";
			toTop.removeEventListener(MouseEvent.CLICK, scrollTop);
			
			upThree.textColor = 0xD8D8D8;
			upThree.text = "Up";
			upThree.removeEventListener(MouseEvent.CLICK, scrollUp);
			
			dnThree.textColor = 0xD8D8D8;
			dnThree.text = "Dn";
			dnThree.removeEventListener(MouseEvent.CLICK, scrollDn);
			
			toBtm.textColor = 0xD8D8D8;
			toBtm.text = "Bm";
			toBtm.removeEventListener(MouseEvent.CLICK, scrollBm);
		}
	}
	
	static function textParse(text:String):String {
		var arrayToParse:Array<String> = new Array();
		var subArray:Array<String> = new Array();
		var extraToHold:String = "";
		var stringToTest:String = "";
		var parsedText:String = "";
		
		arrayToParse = text.split(" ");
		
		for (i in 0...arrayToParse.length) {
			subArray = arrayToParse[i].split("]");
			
			if (subArray.length > 1) {
				extraToHold = subArray[1] + " ";
			} else {
				extraToHold = " ";
			}
			if (subArray[0].substr(0, 1) == "[") {
				stringToTest = subArray[0].substr(0);
				
				switch (stringToTest) {
				case "PCNAME":
					parsedText += playerCharacter.name;
				case "PCSPECIESC":
					parsedText += playerCharacter.species.name;
				case "PCSPECIESL":
					parsedText += playerCharacter.species.name.toLowerCase();
				case "PCARMS":
					parsedText += playerCharacter.arms;
				case "PCLEGS":
					parsedText += playerCharacter.legs;
				case "PCSKIN":
					parsedText += playerCharacter.skin;
				case "PCMOUTH":
					parsedText += playerCharacter.mouth;
				case "PCHANDS":
					parsedText += playerCharacter.hands;
				case "PCFEETS":
					parsedText += playerCharacter.feet;
					
					
					
					
				}
				
				parsedText += extraToHold;
			}
		}
		
		
		return "AAAAAAAAAAAAAAAAAAAAH";
	}
	
	static function updateHUD() {
		var txtName:Object = Lib.current.getChildByName("Character Name");
		var txtHealth:Object = Lib.current.getChildByName("Health");
		var txtStomach:Object = Lib.current.getChildByName("Stomach");
		var txtWeight:Object = Lib.current.getChildByName("Weight");
		var txtFat:Object = Lib.current.getChildByName("Fat");
		var txtMoney:Object = Lib.current.getChildByName("Money");
		var txtArousal:Object = Lib.current.getChildByName("Arousal");
		var txtBowels:Object = Lib.current.getChildByName("Bowels");
		var txtStr:Object = Lib.current.getChildByName("Strength");
		var txtAgi:Object = Lib.current.getChildByName("Agility");
		var txtEnd:Object = Lib.current.getChildByName("Endurance");
		var txtInt:Object = Lib.current.getChildByName("Intelligence");
		var txtTime:Object = Lib.current.getChildByName("Time");
		
		txtName.htmlText = "<body><font size = '" + globals.textSize + "'><p>" + playerCharacter.name + "</p></font></body>";
		txtHealth.htmlText = "<body><font size = '" + globals.textSize + "'><p>Health: " + playerCharacter.healthCurr + "/" + playerCharacter.healthMax + "</p></font></body>";
		txtStomach.htmlText = "<body><font size = '" + globals.textSize + "'><p>Fullness: " + Math.round(playerCharacter.stomachCurrent) + "/" + Math.round(playerCharacter.stomachCap) + "</p></font></body>";
		txtWeight.htmlText = "<body><font size = '" + globals.textSize + "'><p>Weight: " + Math.round(playerCharacter.weight) + "lbs</p></font></body>";
		txtFat.htmlText = "<body><font size = '" + globals.textSize + "'><p>Fatness: " + playerCharacter.fat + "</p></font></body>";
		txtMoney.htmlText = "<body><font size = '" + globals.textSize + "'><p>$" + playerCharacter.money + ".00</p></font></body>";
		txtStr.htmlText = "<body><font size = '" + globals.textSize + "'><p>Strength: " + playerCharacter.str + "</p></font></body>";
		txtAgi.htmlText = "<body><font size = '" + globals.textSize + "'><p>Agility: " + playerCharacter.agi + "</p></font></body>";
		txtEnd.htmlText = "<body><font size = '" + globals.textSize + "'><p>Endurance: " + playerCharacter.end + "</p></font></body>";
		txtInt.htmlText = "<body><font size = '" + globals.textSize + "'><p>Intelligence: " + playerCharacter.int + "</p></font></body>";
		
		if (globals.allowSex)
			txtArousal.htmlText = "<body><font size = '" + globals.textSize + "'><p>Arousal: " + playerCharacter.arousal + "%</p></font></body>";
		if (globals.allowScat)
			txtBowels.htmlText = "<body><font size = '" + globals.textSize + "'><p>Bowels: " + Math.round(playerCharacter.bowelsCurrent) + "/" + Math.round(playerCharacter.bowelsCap) + "</p></font></body>";
		var displayMin:String = ":" + playerCharacter.minute;
		if (playerCharacter.minute < 10) {
			displayMin = ":0" + playerCharacter.minute;
		}
		txtTime.visible = true;
		txtTime.htmlText = "<body><font size = '" + globals.textSize + "'><p>Day " + playerCharacter.day + " " + playerCharacter.hour + displayMin;
		
		if (currentRoom.isPublic) {
			txtPublic.visible = true;
		} else {
			txtPublic.visible = false;
		}
	}
	
	static function onMouseEnter(e:MouseEvent) {
		Mouse.cursor = "button";
	}
	
	static function onMouseOut(e:MouseEvent) {
		Mouse.cursor = "auto";
	}
	
	static function drawPlayfield() {
		var flashSC = flash.Lib.current;
		var outStyle:StyleSheet = new StyleSheet();
		var headStyle:StyleSheet = new StyleSheet();
		var bodyStyle:StyleSheet = new StyleSheet();
		var byStyle:StyleSheet = new StyleSheet();
		var pStyle:StyleSheet = new StyleSheet();
		var titleStyle:StyleSheet = new StyleSheet();
		
		var labelFormat:TextFormat = new TextFormat();
		var charNameFormat:TextFormat = new TextFormat();
		var versionFormat:TextFormat = new TextFormat();
		var textSize:Int = globals.textSize;
		
		headStyle.fontWeight = "bold";
		headStyle.fontSize = textSize + 20;
		headStyle.textAlign = "center";
		
		bodyStyle.textSize = textSize;
		pStyle.textSize = textSize +2;
		
		byStyle.fontStyle = "italic";
		byStyle.fontSize = textSize - 2;
		byStyle.textAlign = "center";
		
		titleStyle.fontWeight = "bold";
		titleStyle.fontSize = textSize + 8;
		
		outStyle.setStyle(".heading", headStyle);
		outStyle.setStyle(".byline", byStyle);
		outStyle.setStyle("p", pStyle);
		outStyle.setStyle("body", bodyStyle);
		outStyle.setStyle(".title", titleStyle);
		
		labelFormat.size = textSize;
		charNameFormat.size = textSize + 4;
		versionFormat.align = RIGHT;
		versionFormat.italic = true;
		versionFormat.size = 10;

		txtPublic = new TextField();
		txtPublic.name = "Public";
		txtPublic.x = 676;
		txtPublic.y = 11;
		txtPublic.width = 34;
		txtPublic.height = 26;
		txtPublic.border = false;
		txtPublic.text = "Public";
		txtPublic.visible = false;
		
		var txtOutput:TextField = new TextField();
		txtOutput.name = "Output Field";
		txtOutput.x = 10;
		txtOutput.y = 10;
		txtOutput.width = 700;
		txtOutput.height = 470;
		txtOutput.border = true;
		txtOutput.borderColor = 0x000000;
		txtOutput.multiline = true;
		txtOutput.htmlText = "";
		txtOutput.wordWrap = true;
		txtOutput.styleSheet = outStyle;
		
		var toTop:TextField = new TextField();
		toTop.name = "U2T";
		toTop.x = 710;
		toTop.y = 400;
		toTop.width = 20;
		toTop.height = 20;
		toTop.border = true;
		toTop.textColor = 0x808080;
		toTop.text = "Tp";
		toTop.visible = true;
		toTop.addEventListener(MouseEvent.ROLL_OVER, onMouseEnter);
		toTop.addEventListener(MouseEvent.ROLL_OUT, onMouseOut);
		
		var upThreeLines:TextField = new TextField();
		upThreeLines.name = "U3L";
		upThreeLines.x = 710;
		upThreeLines.y = 420;
		upThreeLines.width = 20;
		upThreeLines.height = 20;
		upThreeLines.border = true;
		upThreeLines.textColor = 0x808080;
		upThreeLines.text = "Up";
		upThreeLines.visible = true;
		upThreeLines.addEventListener(MouseEvent.ROLL_OVER, onMouseEnter);
		upThreeLines.addEventListener(MouseEvent.ROLL_OUT, onMouseOut);
		
		var downThreeLines:TextField = new TextField();
		downThreeLines.name = "D3L";
		downThreeLines.x = 710;
		downThreeLines.y = 440;
		downThreeLines.width = 20;
		downThreeLines.height = 20;
		downThreeLines.border = true;
		downThreeLines.textColor = 0x808080;
		downThreeLines.text = "Dn";
		downThreeLines.visible = true;
		downThreeLines.addEventListener(MouseEvent.ROLL_OVER, onMouseEnter);
		downThreeLines.addEventListener(MouseEvent.ROLL_OUT, onMouseOut);
		
		var toBottom:TextField = new TextField();
		toBottom.name = "D2B";
		toBottom.x = 710;
		toBottom.y = 460;
		toBottom.width = 20;
		toBottom.height = 20;
		toBottom.border = true;
		toBottom.textColor = 0x808080;
		toBottom.text = "Bm";
		toBottom.visible = true;
		toBottom.addEventListener(MouseEvent.ROLL_OVER, onMouseEnter);
		toBottom.addEventListener(MouseEvent.ROLL_OUT, onMouseOut);
		
		var txtName:TextField = new TextField();
		txtName.name = "Character Name";
		txtName.x = 720;
		txtName.y = 10;
		txtName.width = 200;
		txtName.height = 26;
		txtName.htmlText = " ";
		txtName.selectable = false;

		var txtHealth:TextField = new TextField();
		txtHealth.name = "Health";
		txtHealth.x = 720;
		txtHealth.y = 40;
		txtHealth.width = 200;
		txtHealth.height = 26;
		txtHealth.htmlText = "Health: 0/0";
		txtHealth.selectable = false;

		var txtStr:TextField = new TextField();
		txtStr.name = "Strength";
		txtStr.x = 720;
		txtStr.y = 480;
		txtStr.width = 120;
		txtStr.height = 20;
		txtStr.htmlText = "Strength: ";
		txtStr.selectable = false;

		var txtAgi:TextField = new TextField();
		txtAgi.name = "Agility";
		txtAgi.x = 720;
		txtAgi.y = 510;
		txtAgi.width = 120;
		txtAgi.height = 20;
		txtAgi.htmlText = "Agility: ";
		txtAgi.selectable = false;

		var txtEnd:TextField = new TextField();
		txtEnd.name = "Endurance";
		txtEnd.x = 720;
		txtEnd.y = 540;
		txtEnd.width = 120;
		txtEnd.height = 20;
		txtEnd.htmlText = "Endurance: ";
		txtEnd.selectable = false;

		var txtInt:TextField = new TextField();
		txtInt.name = "Intelligence";
		txtInt.x = 720;
		txtInt.y = 570;
		txtInt.width = 120;
		txtInt.height = 20;
		txtInt.htmlText = "Intelligence: ";
		txtInt.selectable = false;

		var txtStomach:TextField = new TextField();
		txtStomach.name = "Stomach";
		txtStomach.x = 300;
		txtStomach.y = 490;
		txtStomach.width = 220;
		txtStomach.height = 22;
		txtStomach.htmlText = "Fullness: 0/0";
		txtStomach.selectable = false;

		var txtBowels:TextField = new TextField();
		txtBowels.name = "Bowels";
		txtBowels.x = 300;
		txtBowels.y = 525;
		txtBowels.width = 220;
		txtBowels.height = 22;
		txtBowels.htmlText = "Bowels: 0/0";
		txtBowels.selectable = false;

		var txtWeight:TextField = new TextField();
		txtWeight.name = "Weight";
		txtWeight.x = 530;
		txtWeight.y = 490;
		txtWeight.width = 150;
		txtWeight.height = 22;
		txtWeight.htmlText = "Weight: 0lbs";
		txtWeight.selectable = false;

		var txtFat:TextField = new TextField();
		txtFat.name = "Fat";
		txtFat.x = 530;
		txtFat.y = 525;
		txtFat.width = 150;
		txtFat.height = 22;
		txtFat.htmlText = "Fat: ";
		txtFat.selectable = false;

		var txtBuildVersion:TextField = new TextField();
		txtBuildVersion.name = "Version";
		txtBuildVersion.x = 800;
		txtBuildVersion.y = 620;
		txtBuildVersion.width = 30;
		txtBuildVersion.height = 20;
		txtBuildVersion.htmlText = globals.buildVersion;
		txtBuildVersion.selectable = false;

		var txtDebugTag:TextField = new TextField();
		txtDebugTag.name = "Debug";
		txtDebugTag.x = 720;
		txtDebugTag.y = 620;
		txtDebugTag.width = 70;
		txtDebugTag.height = 20;
		txtDebugTag.htmlText = "Debug Mode";
		txtDebugTag.selectable = false;
		txtDebugTag.visible = false;
		txtDebug = txtDebugTag;

		var txtArousal:TextField = new TextField();
		txtArousal.name = "Arousal";
		txtArousal.x = 300;
		txtArousal.y = 560;
		txtArousal.width = 220;
		txtArousal.height = 22;
		txtArousal.htmlText = "Arousal: 0%";
		txtArousal.selectable = false;

		var txtMoney:TextField = new TextField();
		txtMoney.name = "Money";
		txtMoney.x = 300;
		txtMoney.y = 585;
		txtMoney.width = 220;
		txtMoney.height = 22;
		txtMoney.htmlText = "Money: ";
		txtMoney.selectable = false;
		
		var txtTime:TextField = new TextField();
		txtTime.name = "Time";
		txtTime.x = 590;
		txtTime.y = 460;
		txtTime.width = 200;
		txtTime.height = 22;
		txtTime.htmlText = "Time";
		txtTime.selectable = false;
		txtTime.visible = false;
		
		var txtBugReport:TextField = new TextField();
		txtBugReport.name = "Bugs";
		txtBugReport.x = 0;
		txtBugReport.y = 620;
		txtBugReport.width = 800;
		txtBugReport.height = 40;
		txtBugReport.htmlText = "<body><font size = '12'><p align = 'center'><u><a target='_blank' href='http://www.dancingfoxstudios.com/phpBB3/viewforum.php?f=4'>Bug Report</a></u></p></font></body>";
		txtBugReport.selectable = true;

		txtName.setTextFormat(charNameFormat);
		txtHealth.setTextFormat(labelFormat);
		txtStomach.setTextFormat(labelFormat);
		txtBowels.setTextFormat(labelFormat);
		txtBuildVersion.setTextFormat(versionFormat);

		flashSC.addChild(txtOutput);
		flashSC.addChild(txtName);
		flashSC.addChild(txtHealth);
		flashSC.addChild(txtStomach);
		flashSC.addChild(txtWeight);
		flashSC.addChild(txtFat);
		flashSC.addChild(txtMoney);
		flashSC.addChild(txtArousal);
		flashSC.addChild(txtBuildVersion);
		flashSC.addChild(txtBugReport);
		flashSC.addChild(txtDebugTag);
		flashSC.addChild(txtBowels);
		flashSC.addChild(txtTime);
		flashSC.addChild(txtPublic);
		flashSC.addChild(downThreeLines);
		flashSC.addChild(toBottom);
		flashSC.addChild(toTop);
		flashSC.addChild(upThreeLines);

		flashSC.addChild(txtStr);
		flashSC.addChild(txtAgi);
		flashSC.addChild(txtEnd);
		flashSC.addChild(txtInt);
		
		btns = new Array();
		btns[0] = new MyButton(10, 490);
		btns[1] = new MyButton(105, 490);
		btns[2] = new MyButton(200, 490);
		btns[3] = new MyButton(10, 525);
		btns[4] = new MyButton(105, 525);
		btns[5] = new MyButton(200, 525);
		btns[6] = new MyButton(10, 560);
		btns[7] = new MyButton(105, 560);
		btns[8] = new MyButton(200, 560);
		btns[9] = new MyButton(10, 595);
		btns[10] = new MyButton(105, 595);
		btns[11] = new MyButton(200, 595);
		
		charDesc = new MyButton(720, 300);
		optionsBtn = new MyButton(720, 335);
		
		charDesc.name = "Desc Button";
		optionsBtn.name = "Options Button";
		
		charDesc.setButton("Description", null, 0);
		optionsBtn.setButton("Options");
		
		charDesc.addEventListener(MouseEvent.CLICK, doDescription);
		optionsBtn.addEventListener(MouseEvent.CLICK, optionsScreen);
		
		charDesc.visible = false;
		optionsBtn.visible = false;
	}
	
	static function initialize() {
		var allSpecies:Array<Dynamic> = new Array();
		var perks:Array<Dynamic> = new Array();
		var characters:Array<Dynamic> = new Array();
		
		quests = new Array();
		globals = new GlobalVars();
		globals.name = "GlobalVars";
		Lib.current.addChild(globals);
		
		AMFConnection.registerClassAlias("consume.playerObject", MyPlayerObject);
		AMFConnection.registerClassAlias("consume.questObject", MyQuest);
		AMFConnection.registerClassAlias("consume.itemObject", MyItem);
		AMFConnection.registerClassAlias("consume.perkObject", MyPerk);
		AMFConnection.registerClassAlias("consume.speciesObject", MySpecies);
		AMFConnection.registerClassAlias("consume.NPCObject", MyNPC);
		AMFConnection.registerClassAlias("consume.keyObject", MyItem_Key);
		
		//Species, both playable and non
		species = new Array();
		
		//																																Height			Weight			Chest			Waist			Hips			Butt																													Gain
		//allSpecies = [0 name,		1 skin,		2 tail,		3 tailDesc,		4 mouth,	5 legs,		6 arms,		7 hands,	8 feet,		9 min,	10 max,	11 min,	12 max,	13 min,	14 max, 15 min,	16 max,	17 min,	18 max, 19 min, 20 max, 21 breasts, 22 penisL,	23 penisW,	24 balls,	25 errect,	26 stomach, 27 bowels,	28 milk,	29 cum, 30 fat, 31 milk, 32 cum, 33 digestDamage,	34 stretchRateStomach,	35 stretchRateBowels,	36 stretchRateMilk, 37 stretchRateCum,	38 stretchAmountStomach,	39 stretchAmountBowels, 40 stretchAmountMilk,	41 stretchAmountCum,	42 sphincter
		allSpecies[0] = ["Human",	"skin",		false,		"none",			"mouth",	"legs",		"arms",		"hands",	"feet",		63,		72,		90,		140,	24,		30,		22,		29,		22,		26, 	1,		2,		3,			4,			1,			.5,			2,			20,			10,			3,			1,		5,		.5,		 .1,	 1,					30,						20,						20,					15,					20,							10,						1,						.5,						"asshole"];
		allSpecies[1] = ["Fox",		"fur",		true,		"large fluffy",	"muzzle",	"legs",		"arms",		"handpaws",	"footpaws",	60,		69,		85,		100,	22,		26,		20,		25,		20,		24,		1,		3,		8,			3,			1.5,		.5,			3,			15,			15,			2.5,		2,		4,		.3,		 .4,	 2,					15,						10,						15,					20,					15,							15,						1.5,					2,						"tailhole"];
		allSpecies[2] = ["Dragon",	"scales",	true,		"thick scally",	"maw",		"legs",		"arms",		"claws",	"feet",		78,		82,		150,	210,	30,		38,		28,		37,		30,		34,		1,		4,		10,			6,			2,			1,			3.5,		30,			20,			4,			4,		6,		1.5,	 .7,	 5,					40,						10,						5,					5,					40,							5,						10,						2,						"tailhole"];
		allSpecies[3] = ["Wolf",	"fur",		true,		"thin fluffy",	"muzzle",	"legs",		"arms",		"handpaws",	"footpaws",	63,		72,		100,	150,	26,		32,		26,		31,		28,		28,		1,		2,		4,			5,			2.5,		1,			2,			25,			10,			5,			1,		3,		1,		 2,		 10,				30,						20,						10,					10,					30,							10,						10,						5,						"tailhole"];
		allSpecies[4] = ["Bovine",	"skin",		true,		"thin whiplike", "muzzle",	"legs",		"arms",		"handhoofs", "foothoofs", 65,	80,		160,	210,	34,		36,		30,		31,		30,		46,		1,		6,		9,			8,			3,			2.5,		4,			40,			30,			10,			6,		10,		3,		 .2,	 10,				20,						15,						15,					10,					50,							20,						20,						10,						"tailhole"];
		allSpecies[5] = ["Tiger",	"fur",		true,		"long fluffy",	"muzzle",	"legs",		"arms",		"handpaws",	"footpaws",	64,		73,		95,		100,	22,		31,		18,		31,		29,		32,		1,		5,		2,			4,			2,			1,			2,			25,			20,			3,			3,		2,		1,		 .3,	 6,					40,						30,						30,					15,					5,							10,						5,						2,						"tailhole"];
		allSpecies[6] = ["Rat",		"fur",		true,		"thin hairless", "muzzle",	"legs",		"arms",		"handpaws",	"footpaws",	55,		59,		70,		85,		20,		25,		18,		24,		20,		25,		1,		2,		1,			2,			1,			.25,		1.5,		50,			10,			3,			2,		2,		1,		 2,		 5,					70,						40,						30,					10,					20,							20,						10,						5,						"tailhole"];
		
		
		
		
		
		for (i in 0...allSpecies.length) {
			species.push(new MySpecies());
			species[species.length - 1].newSpecies(allSpecies[i]);
		}
		
		//Perks, even hidden ones
		globals.perks = new Array();
		
		//			Name		Display Name		Description															Effect				Buyable, if false the perk can only be granted by an event. Not bought.
		
		perks.push(["ineat",	"Inedible",			"You cannot be eaten.",												"EATEN:NO",			true]);
		perks.push(["nskinny",	"Naturally Skinny",	"Burn fat at an increased rate.",									"FAT:-10",				true]);
		perks.push(["nchubby",	"Naturally Chubby", "Gain more fat from food.",											"FAT:*2",				true]);
		perks.push(["narmor1",	"Natural Armor 1",	"Gain 10 armor as long as you have at least 100 fat.",				"IF(FAT>100)|ARMOR:+10", true]);
		perks.push(["narmor2",	"Natural Armor 2",	"Gain an additional 10 armor as long as you are over 200 fat.", 	"IF(FAT>200)|ARMOR:+10", false]);
		perks.push(["narmor3",  "Natural Armor 3",  "Gain an additional 10 armor as long as you are over 300 fat.", 	"IF(FAT>300)|ARMOR:+10", false]);
		perks.push(["bellyb",	"Belly Bash",		"Gain a bash attack with your stomach as long as it contains at least 100 mass of prey.",	"IF(STOMACH>100)|BASH:10", true]);
		perks.push(["httr",		"Heavy Hitter",		"Deal more damage in combat with melee attacks.",					"ATTACK:+10",			true]);
		perks.push(["fstm",		"Fast Metabolism",	"Heal faster while you have prey in your stomach.",					"DIGESTHEAL:+10",		true]);
		perks.push(["clctr",	"Collector",		"More likely to find items on defeated (or eaten) foes.",			"ITEMCHANCE:+10",		true]);
		perks.push(["bigbly1",	"Big Belly 1",		"Even when empty, your belly is bigger than most.",					"BELLYSIZE:+100",		true]);
		perks.push(["bigbly2",	"Big Belly 2",		"Your empty belly is even bigger.",									"BELLYSIZE:+100",		false]);
		perks.push(["bigbly3",	"Big Belly 3",		"Your belly is always massive, full or empty.",						"BELLYSIZE:+100",		false]);
		perks.push(["mtn",		"The Mountian",		"When rendered immobile you cannot be attacked.", 					"IF(IMMOBLE)|ATTACK:NO", true]);
		perks.push(["pit",		"Bottomless Pit",	"You are always hungry and can continue to consume prey even when immoble.", "IF(IMMOBLE)|EAT:YES", true]);
		perks.push(["bgbst1",	"Big Breasts 1",	"Your breasts are larger than most.",								"BREASTSIZE:+4",		true]);
		perks.push(["bgbst2",	"Big Breasts 2",	"Your breasts are much larger than most.",							"BREASTSIZE:+4",		false]);
		perks.push(["bgbst3",	"Big Breasts 3",	"Your breasts are massive.",										"BREASTSIZE:+4",		false]);
		perks.push(["bgcok1",	"Big Cock 1",		"Your penis is bigger than most.",									"PENISLENGTH:+4 PENISWIDTH:+4",	true]);
		perks.push(["bgcok2",	"Big Cock 2",		"Your penis is much larger than most.",								"PENISLENGTH:+10 PENISWIDTH:+6",	false]);
		perks.push(["bgcok3",	"Big Cock 3",		"Your penis is massive.",											"PENISLENGTH:+15 PENISWIDTH:+10",	false]);
		perks.push(["bgbls1",	"Big Balls 1",		"Your balls are larger than most.",									"BALLSIZE:+4",			true]);
		perks.push(["bgbls2",	"Big Balls 2",		"Your balls are much larger than most.",							"BALLSIZE:+6",			false]);
		perks.push(["bgbls3",	"Big Balls 3",		"Your balls are massive.",											"BALLSIZE:+10",			false]);
		perks.push(["hpr1",		"Hyper 1",			"Your everything is bigger than most.",								"BELLYSIZE:+200 BREASTSIZE:+6 PENISLENGTH:+6 PENISWIDTH:+4 BALLSIZE:+8", true]);
		perks.push(["hpr2",		"Hyper 2",			"Every part of you is simply massive.",								"BELLYSIZE:+400 BREASTSIZE:+12 PENISLENGTH:+12 PENISWIDTH:+6 BALLSIZE:+18", false]);
		perks.push(["hpr3",		"Hyper 3",			"You are bigger than most buildings.",								"BELLYSIZE:+600 BREASTSIZE:+18 PENISLENGTH:+20 PENISWIDTH:+10 BALLSIZE:+24", false]);
		perks.push(["inbal",	"Internal Balls",	"You make cum, despite not having hanging balls.",					"CUM:YES",				true]);
		perks.push(["mulbo1",	"Multiboob 1",		"You have an additional pair of breasts.",							"BREASTS:+2",			true]);
		
		perks.push(["mulcoc1",	"Multicock 1",		"You have an additional cock.",										"PENIS:+1",				true]);
		
		perks.push(["mscl1",	"Big Muscles 1",	"Your muscles are naturally big.",									"MUSCLES:+5",			true]);
		
		perks.push(["afem",		"Always Female",	"You will always be referred to in the femmine, reguardless of genitalia.", "GENDER:Female", true]);
		perks.push(["amale",	"Always Male",		"You will always be referred to in the masculane, reguardless of genitalia.", "GENDER:Male", true]);
		perks.push(["aherm",	"Always Herm",		"You will always be referred to in the hermaphroditic, reguardless of genitalia.", "GENDER:Herm", true]);
		
		
		perks.push(["taur",		"Taur",				"You have the elongated lower half of a taur.",						"TAUR WEIGHT:+100 STOMACHCAP:+100 IMMOBILE:-100", true]);
		
		perks.push(["dbg1",		"DEBUG1 -- Huge",	"For debugging only; hugeness",										"BREASTSIZE:+24 BELLYSIZE:+65000 BALLSIZE:+24 PENISLENGTH:+50 PENISWIDTH:+45",	true]);
		
		
		
		//vore types
		perks.push(["cv",	"Cock Vore",	"Consume prey using your cock and turn them into cum.",		"COCKVORE",		false]);
		perks.push(["bv",	"Breast Vore",	"Consume prey using your breasts and turn them into milk.",	"BREASTVORE",	false]);
		perks.push(["av",	"Anal Vore",	"Consume prey using your butt, then digest them.",			"ANALVORE",		false]);
		perks.push(["ub",	"Unbirth",		"Consume prey using your vagina, then absorb them.",		"UNBIRTH",		false]);
		//other types?
		
		for (i in 0...perks.length) {
			if (perks[i] != null) {
				globals.perks.push(new MyPerk());
				globals.perks[globals.perks.length - 1].newPerk(perks[i]);
			}
		}
		
		
		
		//Exits
		globals.exits = new Array();
		//					name				hidden	timeOpen	timeClose	travelTo	travelTime	doorWidth	doorHeight	desc	hiddenQuestID	keyID
		globals.exits[0]  = ["Living Room",		false,	0,			0,			2,				1,			48,			84,		"You call it your living room, but it's really the only other room in the aparatment"];
		globals.exits[1]  = ["Bathroom",		false,	0,			0,			1,				1,			48,			84];
		globals.exits[2]  = ["Bedroom",			false,	0,			0,			0,				1,			48,			84];
		globals.exits[3]  = ["Outside",			false,	0,			0,			4,				5,			48,			84,		"Outside, where money and food comes from."];
		globals.exits[4]  = ["Balcony",			false,	0,			0,			3,				1,			48,			84,		"Your small balcony overlooking the parking lot"];
		globals.exits[5]  = ["Apartment",		false,	0,			0,			2,				5,			48,			84,		"Your apartment."];
		globals.exits[6]  = ["Park",			false,	0,			0,			5,				5,			0,			0,		"The city park"];
		globals.exits[7]  = ["Main Street",		false,	0,			0,			4,				5,			0,			0,		"The main street of town just outside your apartment"];
		globals.exits[8]  = ["S Main St",		false,	0,			0,			6,				5,			0,			0,		"The main street of town, featuring the new club and the location of your old place of employment"];
		globals.exits[9]  = ["Club Consume",	false,	0,			0,			7,				5,			0,			0,		"The town's newest (and only) club"];
		globals.exits[10] = ["Inside",			false,	0,			0,			9,				5,			96,			84,		null,	null,			3];
		globals.exits[11] = ["Alley",			true,	0,			0,			8,				5,			48,			0,		"A short dim alley running along the side of the club", 0];
		globals.exits[12] = ["The Street",		false,	0,			0,			7,				5,			96,			84];
		globals.exits[13] = ["Back Hall",		false,	0,			0,			10,				2,			50,			90,		"The back hall of the club, the restroom and consumption rooms can be found here"];
		globals.exits[14] = ["Dance floor",		false,	0,			0,			9,				2,			50,			90,		"The club's main area domanated by the dance floor"];
		globals.exits[15] = ["Restroom",		false,	0,			0,			11,				2,			50,			90,];
		globals.exits[16] = ["Bar",				false,	0,			0,			12,				1,			0,			0,];
		globals.exits[17] = ["Dance floor",		false,	0,			0,			9,				1,			0,			0,		"The club's main area domanated by the dance floor"];
		globals.exits[18] = ["Stage",			false,	0,			0,			13,				1,			0,			0,		"An empty stage just off the dance floor"];
		globals.exits[19] = ["Balcony",			false,	0,			0,			14,				5,			50,			90,		"An open balcony overlooking the main area of the club"];
		globals.exits[20] = ["Lounge",			false,	0,			0,			15,				2,			96,			90,		"The predator-only lounge area"];
		globals.exits[21] = ["N Main St",		false,	0,			0,			16,				5,			0,			0,		"To the market district"];
		globals.exits[22] = ["Street",			false,	0,			0,			16,				5,			96,			90];
		globals.exits[23] = ["Hospital",		false,	0,			0,			17,				5,			96,			90,		"The local hospital"];
		globals.exits[24] = ["Pharmacy",		false,	0,			0,			18,				1,			0,			0,		"The hospital pharmacy counter"];
		globals.exits[25] = ["Waiting Room",	false,	0,			0,			17,				1,			0,			0,		"The large, mostly empty, waiting area of the hospital"];
		globals.exits[26] = ["Store",			false,	0,			0,			19,				5,			48,			84,		"The town's lone store, selling everything and mostly filled with junk"];
		globals.exits[27] = ["Outside",			false,	0,			0,			16,				5,			48,			84];
		globals.exits[28] = ["Gym",				false,	0,			0,			20,				5,			96,			90];
		globals.exits[29] = ["Workout",			false,	0,			0,			21,				5,			48,			84,		"The workout area of the gym", null, 0];
		globals.exits[30] = ["Reception",		false,	0,			0,			20,				5,			48,			84];
		globals.exits[31] = ["Gold Room",		false,	0,			0,			22,				5,			48,			84,		null,	null,	1];
		globals.exits[32] = ["Staff Room",		false,	0,			0,			23,				5,			48,			84,		"The staff area of the gym", null, 2];
		globals.exits[33] = ["Restroom",		false,	0,			0,			24,				5,			48,			84];
		globals.exits[34] = ["Showers",			false,	0,			0,			25,				5,			48,			84];
		globals.exits[35] = ["Ice Cream",		false,	0,			0,			26,				5,			50,			86];
		globals.exits[36] = ["Street",			false,	0,			0,			6,				5,			50,			86];
		globals.exits[37] = ["Backroom",		false,	0,			0,			27,				5,			50,			86];
		globals.exits[38] = ["Storefront",		false,	0,			0,			26,				5,			50,			86];
		globals.exits[39] = ["Freezer",			false,	0,			0,			28,				5,			50,			86,		"The shop's large walk-in freezer"];
		globals.exits[40] = ["Restroom",		false,	0,			0,			29,				5,			50,			86];
		globals.exits[41] = ["Office",			false,	0,			0,			30,				5,			50,			86];
		
		
		
		
		// Rooms
		globals.rooms = new Array();
		//					name						exitNW	exitN	exitNE	exitW	exitE	exitSW	exitS	exitSE	specials	allowWait	isPublic	roomNPC		desc
		globals.rooms[0]  = ["Apartment - Bedroom",		null,	0,		null,	null,	1,		null,	null,	null,	[6],		true,		false,		null,		"The bedroom of your tiny 2-room apartment. It's really only it's own room becuase of the divider seperating it from the rest of the apartment, there isn't even a door.</p><br><p>Contains all the normal bedroom stuff; bed, dirty clothes, clean clothes. A dresser that gets used less then it should. There's a rather nice sized closet that's currently stuffed so full of junk you don't feel safe opening the door."];
		globals.rooms[1]  = ["Apartment - Bathroom",	null,	null,	null,	2,		null,	null,	null,	null,	[5],		false,		false,		null,		"Your bathroom. Standard stuff for a person living alone. The important bits are the shower and the toilet."];
		globals.rooms[2]  = ["Apartment - Living Room",	null,	3,		null,	4,		null,	null,	2,		null,	[7],		true,		false,		null,		"Your living room. Or really just the rest of your apartment. You have a cheap couch you got from a friend when you moved in. A nice TV you probably shouldn't have bought and a card table and folding chair. To the side is your kitchen, depressingly empty as usual."];
		globals.rooms[3]  = ["Apartment - Balcony",		null,	null,	null,	null,	0,		null,	null,	null,	[0],		true,		true,		null,		"A tiny balcony overlooking the parking lot. There's really no reason to be out here, you can't even leave from here, there's no way down. And the view sucks."];
		globals.rooms[4]  = ["Main Street",				null,	21,		null,	5,		6,		null,	8,		null,	[0],		false,		true,		null,		"The street outside your apartment. Three identical buildings sit side-by-side here, they all share a single parking lot accessed by an alley. The lot is really too small for the number of apartments in the buildings but that's never bothered you since you don't have a car. Up the road a short distance from here is what's best described as the 'market district' of this small town. Across from your building is the local park, the woods always look like it would be easy to get lost in them, even during the day. Down the road away from town is the new construction that's been going up, including the new club that just opened."];
		globals.rooms[5]  = ["City Park",				null,	null,	null,	7,		null,	null,	null,	null,	[[1, "active"]], true,	true,		null,		"The city park. Though you know it's only a single block, something about the woods makes it easy to get lost. There are usually a number of less then friendly individuals in the woods as well."];
		globals.rooms[6]  = ["South Main Street",		null,	7,		null,	9,		35,		null,	null,	null,	[0],		false,		true,		null,		"Most of this area is still under construction. One building is finished, though most of it is still unoccupied their is a lighted door leading to the basement."];
		globals.rooms[7]  = ["Consume Entryway",		null,	null,	null,	10,		8,		11,		null,	null,	[3],		false,		true,		0,			"A short flight of concrete steps leading to a steel door. The landing is mostly taken up by the very large bouncer who eyes you as you come down the stairs. A single lamp lights the landing with a second light focusing on the small sign affixed to the door.</p><p>The sign reads, &quot;Welcome to Consume.&quot;"];
		globals.rooms[8]  = ["Back Alley",				null, 	null,	9,		null,	null,	null,	null,	null,	[0],		false,		false,		null,		"A dim alley running along the side of the club. It ends in a small loading dock area with a dumpster next to a locked door. There is a short drive leading to the street providing access to the dock. Halfway down the alley you find a small alcove, standing in it is a figure in a dark cloak."];
		globals.rooms[9]  = ["Consume - Dance Floor",	null,	16,		null,	13,		12,		19,		18,		null,	[[1, "passive"]], false, true,		null,		"The main room of Consume is mostly taken up by a dance floor. Along one wall is the bar, several bartenders work behind it serving drinks to thirsty patrons. Opposite the bar is a stage for live bands to preform on. It is currently empty, music being piped in from speakers hidden in the club. Across from the main entrance is a set of stairs leading to the upper balcony with a door under the steps leading to the devourment rooms."];
		globals.rooms[10] = ["Consume - Back Hall",		null,	15,		null,	null,	14, 	null,	null,	null,	[0],		true,		true,		null,		"A short hall lined with rooms on either side. Behind each door is a sparsely furnished room with little more then a lamp and a bed. At the far end of the hall is a door marked &quot;Staff Only.&quot; All the doors are locked from this side."];
		globals.rooms[11] = ["Consume - Restroom",		null,	null,	null,	null,	null,	null,	13,		null,	[5],		true,		false,		null,		"A standard single-occupancy restroom. The door locks."];
		globals.rooms[12] = ["Consume - Bar",			null,	null,	null,	null,	null,	null,	17,		null,	[0],		true,		true,		null,		"A long polished bar, running the length of the room. Like most movie bars the back wall of this one is backed by a mirror with interesting or unique liquor bottles along the shelf before it. Several individuals sit on barstools enjoying various drinks. Most seem more interested in their drink then in talking however, not that the music really allows for conversations."];
		globals.rooms[13] = ["Consume - Stage",			null,	17,		null,	null,	null,	null,	null,	null,	[0],		false,		true,		null,		"The club's stage. A drumset sits covered and ignored by the crowd. You're not really sure where the music is being piped in from. There's not much of interest here."];
		globals.rooms[14] = ["Consume - Balcony",		null,	null,	14,		20,		null,	null,	null,	null,	[0],		false,		true,		null,		"An open sided stair leads to a balcony overlooking the dance floor. A number of tables and chairs scattered in groups cover the area and some clever acoustics mute enough of the music to allow for conversation. There are a few groups up here enjoying the relative quiet. Some of them are doing more then just talking. There is a door in the back wall, marked &quot;Lounge&quot;. It's guarded by another of the club's bouncers."];
		globals.rooms[15] = ["Consume - Lounge",		null,	null,	null,	null,	19,		null,	null,	null,	[0],		true,		true,		null,		"The predator's lounge is a large dark room. Several groups of chairs and couches are arranged around the room allowing predators a place to sit and digest. A number of preds are taking advantage of this, large bellies resting on tables or other rests designed for such use. In the back of the room, under a large light that's giving most of the illumination in the room, sits a poker table. It is currently unoccupied."];
		globals.rooms[16] = ["North Main Street",		null,	23,		null,	28,		26,		null,	7,		null,	[0],		false,		true,		null,		"What is probably best referred to as the town's market district. It's rather depressing really, there is only a single general store here, located in a tiny building to the east. Across the street to the west is a modern gym, you've never gone inside it before, but perhaps now it would be worth it to take a peek inside. North of here the road heads out of town eventually leading to the highway and the rest of the country. Before it gets that far, and still within walking distance, sits the town's hospital."];
		globals.rooms[17] = ["Hospital - Waiting Room",	null,	null,	null,	null,	24,		null,	22,		null,	[0],		true,		true,		null,		"A typical hospital waiting area, the reception desk is always occupied by someone looking tired and slightly haggard. You idly wonder if the expression comes with the job, or if it's the other way around. There isn't much to see or do here other then wait, the staff isn't going to let you any deeper into the hospital unless there's something wrong with you."];
		globals.rooms[18] = ["Hospital - Pharmacy",		null,	null,	null,	25,		null,	null,	null,	null,	[0],		false,		true,		null,		"The pharmacy counter of the local hospital, the steel cage keeping random people out is closed and no one seems to be around at the moment. Looks like the pharmacist is out at the moment."];
		globals.rooms[19] = ["General Store",			null,	null,	null,	27,		null,	null,	null,	null,	[0],		false,		true,		null,		"The array of junk occupying this store is truly impressive. You feel that, had you the time and desire, you could find some truly remarkable things here. Alas the haphazard piles and disorganized clutter make you fear for your safety as you navigate to the counter."];
		globals.rooms[20] = ["Gym - Reception",			null,	null,	null,	29,		27,		null,	null,	null,	[3],		false,		true,		1,			"The reception room of this gym is comfortable and modern. Several comfortable looking chairs wait to either side, with a reception desk at the end of the room. A door next to the desk is marked &quot;Members Only&quot; and seems to lead into the main workout area, visible from outside though the large floor to ceiling windows along the street facing wall. A keycard reader next to the door ensures only those with the proper access can get in the building."];
		globals.rooms[21] = ["Gym - Workout Area",		null,	null,	null,	31,		30,		33,		32,		34,		[0],		false,		true,		null,		"A large open room filled with machines of every type. Each one designed to strengthen some aspect of your body. Each machine has a sign next to it with a visual description of how to use the machine as well as several warnings about using them correctly. The machines also seem to be grouped and numbered, it looks like if you pick a group and follow the numbers in sequence you'll get a good workout in that area.</p><br><p>The back wall of the room is a large mirror, both letting you see yourself working out and giving the illusion that the room is much larger then it appears. There are three doors in the room, the first heads back out through the reception area and then outside. Across the room from that is another door secured with a card reader, it has a sign on it that reads &quot;Gold Room&quot;. Set in the mirrored wall, and nearly invisible is a third door, a small &quot;Staff&quot; sign attached to it.</p><br><p>There are several others in various states of fitness moving around, though not enough to make the place feel crowded."];
		globals.rooms[22] = ["Gym - Gold Room",			null,	null,	null,	null,	29,		null,	null,	null,	[0],		false,		true,		null,		"Calling this room the 'Gold Room' is a bit of a misnomer, the room it's self isn't actually gold. Rather it's a smallish room with mirrors on all the walls. Machines circle the outside of the room, with a break in the line for the door. The machines claim to do all kinds of strange things to your body, and studying them closely you can almost understand why the gym owner limits their use.</p><br><p>The first machine to your left is the one the ill-fated ass Erik demonstrated for you, the straps and levers inside the machine will, somehow, make you several inches taller when you use it.</p><br><p>The next machine looks a lot like a play-doh press, only person-sized. The sticker on it states that it will squeeze the fat out of your body, leaving you with as close to 0% body fat as it's possible to get.</p><br><p>Siting next to that one, looking for all the world like some kind of lewd sex machine is one which the label states will make your dick, assuming you have one, larger.</p><br><p>Unsurprisingly the next machine, which looks a lot like a steampunk bidet, claims to make the balls of anyone who uses it larger. You have to wonder why Erik didn't bother with it.</p><br><p>The next contraption is very odd looking, it seems to be a combination of the last two, but different in some way you can't really pin down just by looking. The label on this machine says that it will make your erections larger.</p><br><p>Next is a machine that you almost recognize, it looks like a thigh sculptor, only more advanced. This machine says that it will slim your hips and thighs.</p><br><p>Last, the machine directly to your right as you come in, is another nearly familiar machine. This machine appears to be an advanced squat machine, the label saying that it will give you a smaller, tighter butt."];
		globals.rooms[23] = ["Gym - Staff Room",		null,	29,		null,	null,	null,	null,	null,	null,	[0],		false,		true,		null,		"This back room of this gym is clearly not an area customers are intended to see. Two walls are covered in the lockers of the employees. The wall opposite the door has a door and a window into which is the manager's office. Shay can usually be found somewhere in the area. Along side the window sits a vending machine mostly selling health drinks.</p><br><p>The middle of the room is dominated by an impressive contraption, you can't fathom what all the parts are supposed to be used for. According to Shay, this machine is supposed to make your chest bigger. Also according to him, it doesn't work correctly."];
		globals.rooms[24] = ["Gym - Restroom",			null,	null,	29,		null,	null,	null,	null,	null,	[5],		true,		false,		null,		"A standard single-occupancy restroom. The door locks."];
		globals.rooms[25] = ["Gym - Showers",			29,		null,	null,	null,	null,	null,	null,	null,	[0],		true,		false,		null,		"A short hallway leads to several shower stalls, providing gym goers a place to change and get cleaned up. Rows of small lockers are provided for customers to store any personal belongings they don't want to carry with them into the gym proper, it is bring your own lock however."];
		globals.rooms[26] = ["Ice Cream Shop",			null,	null,	null,	36,		37,		null,	null,	null,	[0],		false,		true,		null,		"Your old place of employment, the local ice cream shop. They have all the basics; cones, sundaes even a few specialty items like shakes and splits. When you worked here you got all the ice cream you wanted, now you're going to have to pay for any you want. There's a door behind the counter, but you're pretty sure you'll get in trouble if you try going back there now."];
		globals.rooms[27] = ["Ice Cream Shop - Backroom", null, 40,		null,	38,		41,		null,	39,		null,	[0],		false,		true,		null,		"The back room of the ice cream shop set up as a break room, with a table and several chairs. The old TV you remember from when you worked here is still sitting on top of the refrigerator. From here there are three doors, one is the tiny rest room, one is the large walk-in freezer that holds the extra ice cream. The third door was always locked, but now you have a key for it."];
		globals.rooms[28] = ["Ice Cream Shop - Freezer", null,	37,		null,	null,	null,	null,	null,	null,	[0],		true,		false,		null,		"The freezer, it's very cold, naturally. And it's filled with tub after tub of ice cream ready to be sold in the shop. A quick look around and you're pretty sure there's enough here the shop will never run out, even at the rates people around here eat the stuff. Or at least it'll take a long time."];
		globals.rooms[29] = ["Ice Cream Shop - Restroom", null,	null,	null,	null,	null,	null,	37,		null,	[5],		true,		true,		null,		"A standard single-occupancy restroom. The door locks."];
		globals.rooms[30] = ["Ice Cream Shop - Office",	null,	null,	null,	37,		null,	null,	null,	null,	[0],		false,		false,		null,		"While you worked here you were never allowed into this room, you were pretty sure it was just an office since Bessie was usually in here when she was at the shop at all. Now that you can get in here you see that you were mostly correct. The area right inside the door looks like your typical office, a desk sits facing the door and covered in papers and files. An old computer monitor takes up one corner of the desk. You're pretty sure there's a keyboard somewhere under the papers, but you'd have to dig to find it. A pair of filing cabinets rest against the back wall, flanking the desk to either side.</p><br><p>Where the idea of a typical office breaks down is the area to the left of the desk. A raised lip separates the two areas and probably helps keep any spills from reaching the office or escaping out the door. The floor is tiled and gently slops towards the center where a drain is placed in the floor. Slightly offset from the center is a large wooden chair. It looks vaguely like a toilet, with a hole cut in the seat, but is lacking a bowl or tank. Instead it has long, very solid arms with straps hanging off them. The legs likewise have straps placed to go around the occupant's ankles. Behind the chair on a complicated hinge system is what appears to be an automatic milking machine, it looks like it can be moved over the chair and positioned in front of who ever is sitting in the chair. The hoses run to the far corner of the room where a large tank waits to be filled, there's also a machine next to the tank labeled 'Automatic Ice Cream Maker v2.0'"];
		
		
		
		
		
		currentRoom = new MyRoom(globals.rooms[0]);
		
		
		//Items
		globals.keys = new Array();
		
		//Keys				Name						keyID	desc
		globals.keys[0] = ["Gym Membership Keycard",	0,		"A credit-card sized square of plastic with the gym's logo printed on it and a black background"];
		globals.keys[1] = ["Gym Gold Membership",		1,		"A credit-card sized square of plastic with the gym's logo printed on it and a gold background"];
		globals.keys[2] = ["Gym Staff Key",				2,		"A key you got from Shay, it opens the staff room door at the gym"];
		globals.keys[3] = ["Consume Red Band",			3,		"A tight fitting band with the logo of the local club on it. You can't get it off, but you often forget you're even wearing it."];
		
		
		
		//Quests
		//			Name		dispName			hidden		stageDesc	KeyID/Stage to give
		quests[0] = ["alley",	"Alley",			true,		["", "Discovered the hidden alley"],	null];
		quests[1] = ["club",	"Club Membership",	false,		["", "Joined the club"],	null];
		quests[2] = ["gym",		"Gym Membership",	false,		["", "Joined the gym", "Gold membership is avalible", "Became a gold member", "Spoke with Shay", "Agreed to help Shay with his machine", "Became fuckbuddies with Shay"],	[0, 1]];
		quests[3] = ["death",	"A Deal With Death", true,		["", "Spoke with Hir", "Agreed to Hir deal", "Turned down the deal"], null];
		quests[4] = ["cv",		"Pleasing The Wolf",	false,	["", "You tried to slip past the bouncer, it wasn't a good idea."], null];
		
		
		/* Conversation flags;
		 * 0 - Normal
		 * 1 - Quest
		 * 
		 * Quest actions;
		 * set - Set QuestID to Value
		 * skip - Skip to Step if QuestID is greater then Value
		 * 
		 * Talk Format;
		 * 0 - Dialog
		 * 1 - 0 Flag, 1 QuestID, 2 QuestFlag, 3 Step, 4 Value
		 */
		
		//Conversation -- There has to be a better way to so these, but I can't think of how to do it.
		//Bouncer
		var talk0:Array<Dynamic> = new Array();
		talk0[0] = ["A tall, extremely buff wolf stands next to a door. He watches you suspiciously with his arms crossed over his thick, bare chest. Thick gold bands with the club's logo, a silhouette of a vixen with something halfway down her throat, her big belly forming the 'C' in Consume, wrap around the wolf's biceps. Every time he flexes the bands looks like they're about to burst off.", ["talk"], [["Hi", "Say hello to the bouncer.", 1], ["Go in?", "Ask if you can go inside.", 2], ["Dart in", "He's huge, there's no way he can move that fast, just run past him and go inside.", 17, 2, 5, 0], ["Leave", null, -1]]];
		talk0[1] = ["His eyes narrow slightly but otherwise he doesn't move. Just when you've about given up on getting a responce he growls, &quot;Hello.&quot;", ["talk"], [["Go in?", "Ask if you can go inside.", 2]]];
		talk0[2] = ["You ask about going inside and the wolf watches you for a moment then grunts, &quot;Pred or Prey?&quot; Your confused look prompts him to sigh and produce a pamphlet from his back pocket. He seems to carry them around just so he doesn't need to talk anymore then he needs to.</p><br><p>Looking at the pamphlet it describes the difference between the red band predators and blue band prey, the key differences are that anyone who signs up for a blue band pays no cover and nothing for drinks. But they aren't allowed to leave. (Through the doors anyway.)</p><br><p>Red band pay a $200 cover, full price on drinks and $200 for each 'morsel.'</p><br><p>After you finish reading and look up the bouncer grunts again and repeats himself, &quot;Pred or Prey?&quot;", ["quest 1|value 0|skip 5|action skip"], [["Pred", "Join as a predator", 3], ["Prey", "Join as prey", -6], ["Think", "Think about it and come back later", -1]]];
		talk0[3] = ["You tell the bouncer you'd like to sign up as a pred. He grunts and pulls a red band with the club's logo on it out and attaches it to your arm. Interestingly it fits snugly to you with out adjusting (and won't come off no matter how you pull at it). The bouncer also takes down your payment information so you can be properly billed for everything. Once he gets it down he goes back to standing by the door, you're not really sure where he's keeping all this stuff.", ["quest 1|value 1|action set|key 3|action giveKey"], [["Next", " ", 0]]];
		
		talk0[5] = ["You ask if you can head into the club, the bouncer nods and thumbs towards the door. &quot;You don't need to check with me. I can see your band.&quot;", ["talk"], [["Go in", "Leave the taciturn wolf alone.", -1]]];
		
		talk0[17] = ["You make as if you walk away from the club, but turn and dart back towards the door trying to get inside before the bouncer can react. On the one hand you were right about him not being terribly quick, on the other hand you didn't count on the door being locked. A low rumbling comes from behind you, the sound like a truck coming up behind you. You turn to see the wolf's teeth glinting in the light as he snarls at you.", ["talk"], [["Flee", "Abort! Abort! Abandon thread!", 18], ["Attack", "Fight him off!", 19], ["Bribe", "Offer the wolf something to forget about this.", 20]]];
		talk0[18] = ["You turn yourself around as fast as you can and run, the growling follows you away from the door.", ["talk"], [["Next", " ", -1]]];
		talk0[19] = ["You ready yourself to attack and fight off the wolf. Moments later you find yourself laying on your back, very confused about what just happened. You feel something warm covering your feet and manage to get your dazed head to move. Looking down you see the wolf grinning happily, which is almost more frighting then all the nasty looks he's been giving you. You follow his arms to your hips where he's gripping you tightly. Looking between his arms you see your thighs vanishing into the wolf's huge cock.</p><br><p>Alarmed you start to struggle but your motions only seem to entice the wolf more, he grabs your arms and pin them to your sides, pushing his cock further up over your hips. You see his balls start to bulge as your legs reach them, each time you flex trying to get away you feel his cock pulse and he growls softly, pausing to let you squirm inside his shaft. He pushes again, pinning your arms inside his shaft and stands with a grunt, letting his massive cock thrust out before him with you more then halfway down it. As soon as he stands you slide down to your chest leaving only your shoulders and head exposed.</p><br><p>He moves and put himself back into place at the door, your struggles and the occasional flex of his cock slowly sliding you further into his massive balls as he goes back to guarding the door. The last thing you're aware of, as your head is pulled into the bouncer's cock and everything starts going dark, is a female voice saying, &quot;Another one Mac? I hope this wasn't a customer this time. Still, you are nice and huge now...&quot;", ["talk"], [["Next", " ", -2]]];
		talk0[20] = ["Mind racing, you try and think how to get out of this situation. You finally decide to try offering him something to just forget about this and let you go. You make the suggestion, assuming he'll as you for a couple hundred dollars, instead he grins and rumbles, &quot;Bend over. Or open up. Either way works.&quot;", ["talk"], [["Bend over", "Let the big wolf at your ass", 21], ["Open up", "Let him shove his cock down your throat", 22], ["Attack", "Screw that, attack!", 19]]];
		talk0[21] = ["You turn around and bend over, you hear him moving up behind you. With little more then a grunt he levels his cock at your rear and pushes inside you. You gasp as he quickly fills your butt up, then keeps pushing. You struggle as he keeps pushing, somehow managing to fit his entire cock inside you. Once inside he promptly starts pounding away, clearly not interested in your pleasure at all. You feel him tense inside you and his hands grab your hips, holding your butt against his hips. He thrusts into you three more times before you feel his knot swell against your hole. You start to protest, trying to keep him from knotting your ass, but he growls and pops you over his knot, cumming hard after.</p><br><p>A minute later he finishes, pushing into you another few times to make sure you stay full, the rumbling from the big wolf taking on more of a happy sound as he unknots and lets you off him, your butt feeling uncomfortably full now. You turn back around to see him tucking his cock back in his pants, &quot;Don't do that again.&quot;", ["quest 4|value 1|bowels 150|action set"], [["OK", "Agree and deal with your new issue", -1]]];
		talk0[22] = ["Not wanting to let him split you with that huge cock you see him sporting, you kneel down and open your mouth. He takes the invitation and moves up, that massive shaft heading towards your mouth. You start to worry it may be too big for you to fit , but he doesn't give you a chance to protest and simply jams his cock into your mouth. He keeps forcing more and more of his cock down your throat until your nose is pressed into his crotch. Then he starts pounding into your face, big hands holding your head as he fucks your face. It doesn't take him long to get himself off, you watch as his knot swells up in front of your face, luckily he doesn't try to knot your lips. He does hold you against him as he starts to cum hard into your mouth, forcing you to swallow everything.</p><br><p>He finishes after a minute or so, pulling his cock out of your mouth and tucking himself back in his pants. You do notice he's grinning now as he growls, &quot;Don't do that again.&quot;", ["quest 4|value 1|feed 150|action set"], [["OK", "Agree and leave", -1]]];
		
		//Receptionist
		var talk1:Array<Dynamic> = new Array();
		talk1[0] = ["Looking like your typical gymbunny (though not a literal rabbit in this case) the human receptionist of this gym is average of height, skinny of weight, blonde of hair and blue of eye. She is wearing a very tight low-cut tank top, showing off her modest breasts. She smiles brightly as you enter and chirps, &quot;Hello! Welcome to Shay's Gym. I'll be happy to answer any questions you might have!&quot;", ["talk"], [["Go in?", "Ask if you can go inside", 1], ["Gold", "Ask about the Gold membership", 10], ["Name?", "Ask the perky girl her name", 2], ["Eat", "Ask if you can eat her", 3], ["Leave", " ", -1]]];
		talk1[1] = ["You inquire about joining the gym and a smile spreads over her face, &quot;We offer two levels of membership, the first is our basic package. For a modest fee you get access to all our machines for the length of your visit. I can get you signed up for that one right now if you'd like, you'll have to pay each time you visit, but the nice thing is you only pay when you visit. So you don't have to worry about going on vacation or something like that. The cost for each visit is $20.&quot;</p><br><p>She pauses for a moment before continuing, &quot;We also offer a Gold membership. That's a one time fee and gets you unlimited access for life. You also get access to the Gold Room in the back where we have a number of advanced training machines. Unfortunately at this time we don't have any Gold memberships available. Check back later, something might open up.&quot;", ["quest 2|value 0|skip 5|action skip"], [["Sign Up", "Sign up for a basic membership", 4], ["Not Now", "Maybe later", -1]]];
		talk1[2] = ["You ask her what her name is. She gives you one of her too-bright smiles and points at the name tag clipped to one breast, it reads &quot;Ann&quot;.", ["talk"], [["Go in?", "Ask if you can go inside", 1], ["Gold", "Ask about the Gold membership", 10], ["Eat", "Ask if you can eat her.", 3], ["Leave", " ", -1]]];
		talk1[3] = ["You grin and mention you're a little hungry. She looks puzzled for a moment then blushes, &quot;You want to eat me?&quot; She shifts nervously, her eyes darting around. &quot;You really don't. I can't imagine I taste very good, I'm all skin and bones after all!&quot; She laughs nervously and fidgets some more.", ["talk"], [["Go in?", "Ask if you can go inside", 1], ["Gold", "Ask about the Gold membership", 10], ["Name?", "Ask the perky girl her name", 2], ["Leave", " ", -1]]];
		talk1[4] = ["You agree to sign up, the perky receptionist takes down your name and a few other random details from you and fills out a form which she has you sign. After which she hands you a card, still warm from the little printer behind her station, it has your name and Basic Membership written on it as well as a barcode. &quot;Just slide that through the door over there and you'll automatically be charged and the door will open! Enjoy!&quot;", ["quest 2|value 1|action set|key 0|action giveKey"], [["Done", " ", -1]]];
		talk1[5] = ["You ask if you can head inside and the receptionist smiles, &quot;Just swipe your card through the reader, the door will open for you. You don't need to talk to be every time you come inside, unless you really want to anyway.&quot;", ["talk"], [["Gold", "Ask about the Gold membership", 10], ["Name?", "Ask the perky girl her name", 2], ["Eat", "Ask if you can eat her.", 3], ["Leave", " ", -1]]];
		talk1[6] = ["You ask the receptionist about gold memberships and she smiles, &quot;You're in luck actually, we just had a gold membership open up! If you'd like to purchase it I'd be more then happy to get you set up!&quot; She bounces a little as she talks, it would seem she's rather excited about the idea. &quot;Just so you're aware, the Gold membership is a one time fee of $2000. I know that sounds super high, but you don't have to pay for daily use of the gym anymore <i>and</i> you get access to our special Gold room! So, are you interested?&quot;", ["talk"], [["Buy", "Sign up for the exclusive Gold Gym membership", 8], ["Maybe Later", "Think about it and come back later", -1]]];
		talk1[7] = ["She giggles, &quot;Don't get me wrong, I like it when you stop by and talk with me, but you don't need to check with me every time you visit. The keypad there by the door will let you in.&quot; She waves towards it.", ["talk"], [["Gold", "Ask about the Gold membership", 10], ["Name?", "Ask the perky girl her name", 9], ["Eat", "Ask if you can eat her", 10], ["Leave", " ", -1]]];
		talk1[8] = ["You agree to buy a gold membership, eager to use some of those machines you caught a glimpse of. The receptionist smiles as you hand over the money. She pulls a tablet out of her booth and makes a few notes on it, the money vanishing somewhere behind it at the same time. When she's done she looks up smiling, &quot;All set! You should be good to go right now if you'd like! Enjoy!&quot;", ["quest 2|money 2000|skip 9|action check"], [["Next", null, -1]]];
		talk1[9] = ["You agree to buy a gold membership, eager to use some of those machines you caught a glimpse of. When you check your wallet however you discover that you're a little short of the $2000 fee. You smile sheepishly and promise you'll come back soon. &quot;Ok, hurry though.&quot; The receptionist makes a note as she talks, &quot;These memberships don't usually stay available for long.&quot;", ["talk"], [["Go in?", "Ask if you can go inside", 1], ["Name?", "Ask the perky girl her name", 2], ["Eat", "Ask if you can eat her", 3], ["Leave", " ", -1]]];
		talk1[10] = ["You ask the receptionist about gold memberships, she frowns a little and shakes hear head, &quot;Sorry, we don't have any avalible right now. Check back soon though, I'm sure one will open up soon!", ["quest 2|value 1|skip 6|action skip"], [["Go in?", "Ask if you can go inside", 1], ["Name?", "Ask the perky girl her name", 2], ["Eat", "Ask if you can eat her", 3], ["Leave", " ", -1]]];
		
		
		//NPCs
		nonPlayerCharacters = new Array();
		//							Name					Species		Breasts	Vagina	Penis	Balls	Height	Mass	Conversation	image
		nonPlayerCharacters[0] = ["Mac the bouncer",		species[3],	false,	false,	true,	true,	84,		500,	talk0,			null];
		nonPlayerCharacters[1] = ["Ann the receptionist",	species[0],	true,	false,	false,	false,	63,		95,		talk1,			null];
		
		
	}

	static function clearAllEvents() {
		for (i in 0...btns.length) {
			btns[i].setButton(" ");
			
			btns[i].removeEventListener(MouseEvent.CLICK, welcomeScreen);
			btns[i].removeEventListener(MouseEvent.CLICK, displayCredits);
			btns[i].removeEventListener(MouseEvent.CLICK, displayFAQ);
			btns[i].removeEventListener(MouseEvent.CLICK, optionsScreen);
			btns[i].removeEventListener(MouseEvent.CLICK, increaseFontSize);
			btns[i].removeEventListener(MouseEvent.CLICK, decreaseFontSize);
			btns[i].removeEventListener(MouseEvent.CLICK, newGame);
			btns[i].removeEventListener(MouseEvent.CLICK, movePlayer);
			btns[i].removeEventListener(MouseEvent.CLICK, saveGame);
			btns[i].removeEventListener(MouseEvent.CLICK, loadGame);
			btns[i].removeEventListener(MouseEvent.CLICK, showHidden);
			btns[i].removeEventListener(MouseEvent.CLICK, debugMenu);
			
			btns[i].removeEventListener(MouseEvent.CLICK, doTalk);
			btns[i].removeEventListener(MouseEvent.CLICK, doSleep);
			btns[i].removeEventListener(MouseEvent.CLICK, doPoop);
			btns[i].removeEventListener(MouseEvent.CLICK, doPhone);
			btns[i].removeEventListener(MouseEvent.CLICK, doHunt);
			btns[i].removeEventListener(MouseEvent.CLICK, doDescription);
			btns[i].removeEventListener(MouseEvent.CLICK, doFoodComa);
			
			
			
		}
			
			/*
			btns[i].removeEventListener(MouseEvent.CLICK, statChange);
			
			btns[i].removeEventListener(MouseEvent.CLICK, buyDrink);
			btns[i].removeEventListener(MouseEvent.CLICK, doShop);
			btns[i].removeEventListener(MouseEvent.CLICK, doSell);
			btns[i].removeEventListener(MouseEvent.CLICK, doGym);
			btns[i].removeEventListener(MouseEvent.CLICK, giveItem);
			btns[i].removeEventListener(MouseEvent.CLICK, combatHeal);
			btns[i].removeEventListener(MouseEvent.CLICK, doCombat);
			btns[i].removeEventListener(MouseEvent.CLICK, meetDeath);
			btns[i].removeEventListener(MouseEvent.CLICK, resetGame);
			btns[i].removeEventListener(MouseEvent.CLICK, playerStats);
			btns[i].removeEventListener(MouseEvent.CLICK, statUpgrade);

			btns[i].removeEventListener(MouseEvent.CLICK, doMasterbate);

			btns[i].removeEventListener(MouseEvent.CLICK, doWork);
			btns[i].removeEventListener(MouseEvent.CLICK, eatNPC);
			btns[i].removeEventListener(MouseEvent.CLICK, freeMoney);
			
			btns[i].removeEventListener(MouseEvent.CLICK, playerInv);
			btns[i].removeEventListener(MouseEvent.CLICK, itemFunction);
			
			btns[i].removeEventListener(MouseEvent.CLICK, orderPizza);
			btns[i].removeEventListener(MouseEvent.CLICK, jumpTo);
			btns[i].removeEventListener(MouseEvent.CLICK, gymTalk);
			btns[i].removeEventListener(MouseEvent.CLICK, buyIceCream);
			btns[i].removeEventListener(MouseEvent.CLICK, resetQuests);
			btns[i].removeEventListener(MouseEvent.CLICK, quickTime);
			btns[i].removeEventListener(MouseEvent.CLICK, goldGymRoom);
			
			btns[i].removeEventListener(MouseEvent.CLICK, useVend);
			btns[i].removeEventListener(MouseEvent.CLICK, resetGymTrain);
			btns[i].removeEventListener(MouseEvent.CLICK, useMachine);
			btns[i].removeEventListener(MouseEvent.CLICK, orderHooker);
			btns[i].removeEventListener(MouseEvent.CLICK, enableLac);
			btns[i].removeEventListener(MouseEvent.CLICK, shopOffice);
			*/
		
	}
	
	static function main() {
		initialize();
		drawPlayfield();
		welcomeScreen();
	}
	
}