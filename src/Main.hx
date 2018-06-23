package;

import flash.*;
import flash.net.*;
import flash.ui.Mouse;
import flash.utils.*;
import flash.text.*;
import flash.events.*;
import flash.display.*;
import flash.net.FileReference;
import haxe.remoting.AMFConnection;
import Type.ValueType;
import haxe.xml.Check.Attrib;
import flash.errors.*;

//Logo images
@:bitmap("../img/logo_f.png") class LogoF extends BitmapData { }
@:bitmap("../img/logo_m.png") class LogoM extends BitmapData { }
@:bitmap("../img/logo_m_notext.png") class LogoMNoText extends BitmapData { }
@:bitmap("../img/logo_f_notext.png") class LogoFNoText extends BitmapData { }

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
	static var btnDebugDump:MyButton;
	
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
	static var finalPerks:Array<MyPerk>;
	static var quests:Array<Dynamic>;
	static var newRoom:Bool = true;
	static var doorFuckCount:Int;
	static var conversationStep:Int;
	static var grabbedNPC:Bool; //The Player has a hold of the NPC
	static var grabbedPC:Bool; //The NPC has a hold of the Player
	
	static var fileSaveObject:FileReference = new FileReference();
	
	static var shopList:Array<Dynamic> = new Array();
	static var shopListMade:Bool = false;
	
	static var playerDied:String;
	static var playerDead:Bool = false;
	
	static var QTEstage:Int;
	static var timerQTE:MyTimer;
	
	static var talkInProgress:Bool;
	
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
		
		if (!btnDebugDump.visible)
			btnDebugDump.visible = true;
		
		if (!optionsBtn.visible) {
			optionsBtn.visible = true;
			charDesc.visible = true;
			globals.backTo = "move";
			talkInProgress = false;
			if (globals.debugMode) {
				txtDebug.addEventListener(MouseEvent.CLICK, debugMenu);
				txtDebug.visible = true;
			}
		}
		
		//If the player signed up to be prey, we need to flip them right to the consumption scene rather then letting them move about.
		if (playerCharacter.quest[1].stage == 2) {
			playerDied = "prey";
			doDeath();
			return;
		}
		
		if (playerCharacter.healthCurr <= 0) {
			//Somehow the player survived a combat with less then 0 HP
			playerCharacter.healPlayer();
		}
		
		// If the player is overfull, skip to food coma
		if (playerCharacter.stomachCurrent >= playerCharacter.stomachCap * 1.5) {
			doFoodComa();
			return;
		}
		
		
		if (newRoom) {
			choice = e.currentTarget.btnID;
			options = Std.string(choice).split(":");
			
			shopListMade = false;
			shopList = null;
			
			if (options[0] == "WAIT") {
				message += "You wait.<br>";
				timeGoesBy = options[1];
			} else {
				//Check to make sure the player actually can move
				
				tempMsg = playerCharacter.fitWidth(options[2]);
				
				switch (tempMsg) {
				case "##STOMACH":
					//Player's belly is too big to get through the door
					if (playerCharacter.hasPerk("comps")) {
						message += "Your massive stomach bumps against the doorway, at first it looks like you're too big to fit but you grunt and push and manage to shove your huge belly through.<br>";
						globals.lastRoom = globals.currentRoomID;
						currentRoom = new MyRoom(globals.rooms[options[0]]);
						globals.currentRoomID = options[0];
						timeGoesBy = options[1] + 5;
					} else {
						message += "Your massive stomach bumps against the doorway, far too large to fit through. Looks like you're not going that way until you get a little smaller.<br>";
						timeGoesBy = 2;
					}
				case "##BREASTS":
					//Player's boobs are too big to get through
					if (playerCharacter.hasPerk("comps")) {
						message += "Your massive breasts bump against the doorway, at first it looks like you're too big to fit through but you grunt and push and manage to shove your huge tits through the door.<br>";
						globals.lastRoom = globals.currentRoomID;
						currentRoom = new MyRoom(globals.rooms[options[0]]);
						globals.currentRoomID = options[0];
						timeGoesBy = options[1] + 5;
						playerCharacter.arousal += 5;
					} else {
						message += "Your massive breasts bump against the doorway, far to huge to fit through. Looks like you're not going that way until you get a little smaller.<br>";
						timeGoesBy = 2;
						playerCharacter.arousal += 5;
					}
				case "##BALLS":
					//Player's balls are too big to get through
					if (playerCharacter.hasPerk("comps")) {
						message += "Your massive balls bump agianst the doorway, at first it looks like you're too big to fit through, but you gurnt and push and manage to shove your huge balls through the door.<br>";
						globals.lastRoom = globals.currentRoomID;
						currentRoom = new MyRoom(globals.rooms[options[0]]);
						globals.currentRoomID = options[0];
						timeGoesBy = options[1] + 5;
						playerCharacter.arousal += 5;
					} else {
						message += "Your massive balls bump against the doorway, far too huge to fit through. Looks like you're not going that way until you get a little smaller.<br>";
						timeGoesBy = 2;
						playerCharacter.arousal += 5;
					}
				case "##COCK":
					//Player's penis is too big to get through
					if (playerCharacter.hasPerk("comps")) {
						message += "Your massive cock jams in the doorway, you have a momentary thought of staying right there and getting off using the doorway, but you push a little harder and manage to shove yourself through the door.<br>";
						globals.lastRoom = globals.currentRoomID;
						currentRoom = new MyRoom(globals.rooms[options[0]]);
						globals.currentRoomID = options[0];
						timeGoesBy = options[1] + 5;
						playerCharacter.arousal += 10;
					} else {
						message += "Your massive cock jams in the doorway. Though it feels wonderful you are simply too massive to get through.<br>";
						timeGoesBy = 3;
						playerCharacter.arousal += 10;
						doorFuckCount -= 1;
						if (doorFuckCount <= -1) {
							message += playerCharacter.cum("door");
							doorFuckCount = playerCharacter.endurance();

						}
					}
				default:
					message += tempMsg;
					globals.lastRoom = globals.currentRoomID; //So we know what room the player came out of
					currentRoom = new MyRoom(globals.rooms[options[0]]);
					globals.currentRoomID = options[0]; //To keep track of where the player is (for saving)
					timeGoesBy = options[1];
				}
			}
			
			timeMsg = playerCharacter.passTime_with_output(timeGoesBy);
			if (timeMsg != "") {
				if (timeMsg.charAt(0) == "#") {
					timeReturnArray = timeMsg.split(":");
					switch (timeReturnArray[0]) {
					case "#DIE":
						//Player died
						playerDied = timeReturnArray[1];
						doDeath();
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
			 * 8 - Workout
			 * 9 - Gold Room
			 * 10 - Staff Room
			 * 11 - Hospital, buying additional perks
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
					btns[11 - i].setButton("Hunt", null, 0);
					btns[11 - i].setClickFunc(doCombat);
				case "passive":
					if (playerCharacter.lastClubDay != playerCharacter.day && globals.lastRoom == 7) {
						message += "The bouncer nods to you, &quot;No cover today.&quot;<br>";
						playerCharacter.lastClubDay = playerCharacter.day;
						//money goes out here
					}
					message += "Prey wander the area, wating to be consumed.<br>";
					btns[11 - i].setButton("Hunt", null, 0);
					btns[11 - i].setClickFunc(doHunt);
				}
			case 2:
				//Shop
				switch (flagValue) {
				case "iceCream":
					//Ice Cream shop
					//Guffin's Shift 8-14 (3)
					//Bessie's Shift 14-20 (4)
					if (playerCharacter.hour >= 8 && playerCharacter.hour < 20) {
						roomNPC = new MyNPC();
						message += "The freezer case filled with ice cream is here, ";
					}
					if (playerCharacter.hour >= 8 && playerCharacter.hour < 14)
						roomNPC.newNPC(nonPlayerCharacters[3]);
					if (playerCharacter.hour >= 14 && playerCharacter.hour < 20)
						roomNPC.newNPC(nonPlayerCharacters[4]);
					
					if (roomNPC != null) {
						btns[9].setButton("Buy", "Buy some tasty Ice Cream.", "list|0", iceCreamShop);
						message += roomNPC.name + " is standing behind it.<br>";
						btns[11].setButton("Talk", "Talk to " + roomNPC.name, 0);
						btns[11].setClickFunc(doTalk);
					} else {
						btns[9].setButton("Eat", "No one is watching the cooler, help yourself to some tasty treats?", "free|0", iceCreamShop);
					}
				case "general":
					//general store
					message += roomNPC.name + " has something to sell.<br>";
					
					btns[9].setButton("Buy", "Take a look at the " + roomNPC.species.name + "'s stock", "gen|list|0");
					btns[9].setClickFunc(doShop);
				case "rat":
					//The rat's illegal shop
					message += roomNPC.name + " has something to sell.<br>";
					
					btns[9].setButton("Buy", "Take a look at the rat's offerings.", "rat:0");
					//btns[9].setClickFunc(doShop);
					btns[9].disableButton();
				}
			case 3:
				//Talk
				message += roomNPC.name + " is here.<br>";
				btns[11 - i].setButton("Talk", "Talk to " + roomNPC.name, 0);
				btns[11 - i].setClickFunc(doTalk);
			case 4:
				//Work
				message += "Plenty of work awaits you here.<br>";
				
				btns[9].setButton("Work 2", "Work for two hours", 2);
				btns[9].setClickFunc(doWork);
				btns[10].setButton("Work 4", "Work for four hours", 4);
				btns[10].setClickFunc(doWork);
				btns[11].setButton("Work 8", "Work for eight hours", 8);
				btns[11].setClickFunc(doWork);
			case 5:
				//Toilet
				message += "There is a toilet here you can use.<br>";
				btns[11 - i].setButton("Toilet", null, 0);
				btns[11 - i].setClickFunc(doPoop);
			case 6:
				//Sleep
				message += "Your bed looks inviting.<br>";
				btns[11 - i].setButton("Sleep");
				//btns[11 - i].setClickFunc(doSleep);
				btns[11 - i].disableButton();
			case 7:
				//Phone
				message += "There is a phone on the wall here.<br>";
				btns[11 - i].setButton("Phone", null, 0);
				btns[11 - i].setClickFunc(doPhone);
			case 8:
				//Workout
				message += "Workout equipment lines the walls.<br>";
				btns[11 - i].setButton("Workout", null, "choose");
				btns[11 - i].setClickFunc(doGym);
			case 9:
				//Gold room
				btns[11].setButton("Gold Machine", "Use one of the machines in this room.", "list", doGoldRoom);
				if (playerCharacter.quest[2].stage == 3) {
					//First encounter with Shay. This will always be avalible until the player speaks with him
					message += "<p>Shay is here.</p>";
					roomNPC = new MyNPC();
					roomNPC.newNPC(nonPlayerCharacters[2]);
					btns[10].setButton("Shay", "Talk to the Wolfhound", 0, doTalk);
				}
				if (playerCharacter.quest[2].stage >= 4 && playerCharacter.quest[2].stage <= 5) {
					if (Math.round(Math.random() * 9) == 0) {
						//Second encounter with Shay. Random chance of happening.
						message += "<p>Shay is here.</p>";
						roomNPC = new MyNPC();
						roomNPC.newNPC(nonPlayerCharacters[2]);
						btns[10].setButton("Shay", "Talk to the Wolfhound", 2, doTalk);
					}
				}
			case 10:
				//Staff room
				if (Math.round(Math.random() * 3) == 0) {
					message += "<p>Shay is here.</p>";
					roomNPC = new MyNPC();
					roomNPC.newNPC(nonPlayerCharacters[2]);
					btns[9].setButton("Shay", "Talk to the Wolfhound");
					btns[9].disableButton();
				}
				btns[10].setButton("Vending", "Buy something from the drink machine", "list", doVend);
				btns[11].setButton("Shay's Machine", "Give Shay's new machine a try", "list", doShayMachine);
			case 11:
				//Hospital add perk room
				message += "A small odd machine sits here. There is a place for you to insert your arm.<br>";
				btns[11 - i].setButton("Machine", "Use the machine", "list|0");
				btns[11 - i].setClickFunc(doPerk);
				
			}
		}
		
		if (playerCharacter.arousal >= 100)
			message += "You are too aroused to think, you need to deal with this somehow.<br>";
		
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
					btns[i].setClickFunc(movePlayer);
				}
				if (exit[i].hidden) {
					if (playerCharacter.quest[exit[i].hiddenQuestID].stage == 0) {
						btns[i].setButton(exitDirection[i], null, exitDirShort[i]);
						btns[i].disableButton();
						btns[i].setClickFunc(showHidden);
					}
				}
				if (exit[i].keyID != -1) {
					if (playerCharacter.hasKey(exit[i].keyID) == -1) {
						btns[i].disableButton();
						//btns[i].clearClickFunc(); Redundant
					}
				}
				if (exit[i].timeOpen != exit[i].timeClose) {
					if (playerCharacter.hour < exit[i].timeOpen || playerCharacter.hour >= exit[i].timeClose) {
						btns[i].disableButton();
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
		if (currentRoom.allowWait && currentRoom.isPublic && playerCharacter.arousal < 100) {
			btns[4].setButton("Wait", null, "WAIT:15");
			btns[4].setClickFunc(movePlayer);
		} else if (currentRoom.allowWait && !currentRoom.isPublic && playerCharacter.arousal < 60) {
			btns[4].setButton("Wait", null, "WAIT:15", movePlayer);
		} else if (!currentRoom.isPublic && playerCharacter.arousal >= 60 && playerCharacter.arousal < 100) {
			btns[4].setButton("Masturbate");
			btns[4].setClickFunc(doMasterbate);
		} else if (currentRoom.isPublic && !currentRoom.allowWait && playerCharacter.arousal < 100) {
			btns[4].setButton("Wait");
			btns[4].disableButton();
		} else if (!currentRoom.isPublic && !currentRoom.allowWait && playerCharacter.arousal < 100) {
			btns[4].setButton("Wait");
			btns[4].disableButton();
		} else if (playerCharacter.arousal >= 100) {
			for (i in 0...11) {
				btns[i].clearClickFunc();
				btns[i].disableButton();
			}
			btns[4].setButton("Masturbate");
			btns[4].setClickFunc(doMasterbate);
		} else {
			new AlertBox("Masturbate logic test failed. " + playerCharacter.arousal + ", Public: " + currentRoom.isPublic + ", Allow Wait: " + currentRoom.allowWait);
		}
		
		
	}
	
	static function doVend( e:MouseEvent ) {
		//Give the player a bottle of BouncyButt (item 4) with a small chance to get a BouncyButt+ (item 5)
		var tempItem:MyItem_Food = new MyItem_Food();
		var choice:String = e.currentTarget.btnID;
		var message:String = "<p>You stand before the vending machine, the graphics depict a horse girl with a very large butt dressed in a tiny pair of exercise shorts. You can't quite be sure, because of how she's turned, but you suspect she isn't wearing a top at all. Explains why the vending machine is tucked away back here and not out on the floor. The name on the machine is &quot;BouncyButt Sports drinks! Put some Bounce in your Butt today!&quot;</p><br>";
		
		if (optionsBtn.visible) {
			optionsBtn.visible = false;
			charDesc.visible = false;
			newRoom = false;
		}
		
		clearAllEvents();
		
		switch choice {
		case "list":
			message += "<p>A bottle costs $1</p><br><p>Buy a bottle?</p>";
			btns[0].setButton("Buy", null, "buy", doVend);
		case "buy":
			if (playerCharacter.getMoney() >= 1) {
				message += "<p>You feed your dollar into the machine and push the button. The machine rattles and thunks and a bottle drops into the slot. ";
				
				if (Math.round(Math.random() * 3) == 0) {
					message += "You pull it out and discover the machine has given you a bottle of BouncyButt+ rather then the regular stuff it was supposed to.</p>";
					tempItem = globals.food[5].copyItem();
				} else {
					message += "You pull it out and look the bottle over, BouncyButt figures the gym would have a 'health' drink stocked.</p>";
					tempItem = globals.food[4].copyItem();
				}
				
				playerCharacter.addMoney( -1);
				
				message += "<br><p>Buy another?</p>";
				
				btns[0].setButton("Buy", null, "buy", doVend);
			} else {
				message += "<p>You check your pockets for the money and find yourself coming up short.</p>";
			}
			
			tempItem.give(playerCharacter);
		}
		
		btns[11].setButton("Leave", null, null, movePlayer);
		outputText(message, "Gym - Staff Room");
	}
	
	static function doShayMachine( e:MouseEvent ) {
		var message:String = "<p>You eye the contraption that dominates this room, after a bit of work you figure out how to get yourself into it and start working out. How the thing works confuses you slightly but you manage to get it working and work yourself hard.</p><br>";
		var effects:Array<String> = new Array();
		effects = ["height", "weight", "fat", "chest", "waist", "hip", "butt", "breast", "penis length", "penis width", "balls"];
		var rndEffect:Int = Math.round(Math.random() * (effects.length - 1));
		var posOrNeg:Int = Math.round(Math.random() * 1);
		var toChange:Float = -1;
		var oldValue:Float = -1;
		
		if (optionsBtn.visible) {
			optionsBtn.visible = false;
			charDesc.visible = false;
			newRoom = false;
		}
		
		clearAllEvents();
		
		switch (posOrNeg) {
		case 0:
			posOrNeg = -1;
		case 1:
			posOrNeg = 1;
		}
		
		if (playerCharacter.lastGoldTrainDay == playerCharacter.day) {
			//Player has used a Gold Machine today
			message = "<p>You're still a little sore from the last time you used one of Shay's machines. You'll have to wait to use another.</p>";
		} else {
			playerCharacter.lastGoldTrainDay = playerCharacter.day;
			switch(effects[rndEffect]) {
			case "height":
				oldValue = playerCharacter.tall;
				toChange = Math.round(Math.random() * 11) + 1;
				toChange *= posOrNeg;
				playerCharacter.tall += toChange;
				if (playerCharacter.tall < globals.minHeight && oldValue == globals.minHeight) {
					playerCharacter.tall = globals.minHeight;
					message += "<p>You step free of the machine, nothing happened.</p>";
				} else if (playerCharacter.tall > globals.maxHeight && oldValue == globals.maxHeight) {
					playerCharacter.tall = globals.maxHeight;
					message += "<p>You step free of the machine, nothing happened.</p>";
				} else {
					if (posOrNeg == 1) {
						message += "<p>You feel strange, when you step out of the machine you find your self slightly taller.</p>";
					} else {
						message += "<p>You feel strange, when you step out of the machine you find your self slightly shorter.</p>";
					}
				}
			case "weight":
				oldValue = playerCharacter.weight;
				toChange = Math.round(Math.random() * 100) + 10;
				toChange *= posOrNeg;
				playerCharacter.weight += toChange;
				if (playerCharacter.weight < 40 && oldValue == 40) {
					playerCharacter.weight = 40;
					message += "<p>You step free of the machine, nothing happened.</p>";
				} else {
					if (posOrNeg == 1) {
						message += "<p>You feel odd, when you step free of the machine you find yourself slightly heavier.</p>";
					} else {
						message += "<p>You feel odd, when you step free of the machine you find yourself slightly lighter.</p>";
					}
				}
			case "fat":
				oldValue = playerCharacter.fat;
				toChange = Math.round(Math.random() * 1000) + 50;
				toChange *= posOrNeg;
				playerCharacter.fat += Math.round(toChange);
				if (playerCharacter.fat < 0 && oldValue == 0) {
					playerCharacter.fat = 0;
					message += "<p>You step free of the machine, nothing happened.</p>";
				} else {
					if (posOrNeg == 1) {
						message += "<p>You feel odd, when you step free of the machine you find yourself slightly heavier.</p>";
					} else {
						message += "<p>You feel odd, when you step free of the machine you find yourself slightly lighter.</p>";
					}
				}
			case "chest":
				oldValue = playerCharacter.chestSize;
				toChange = Math.round(Math.random() * 11) + 1;
				toChange *= posOrNeg;
				playerCharacter.chestSize += Math.round(toChange);
				if (playerCharacter.chestSize < 18 && oldValue == 18) {
					playerCharacter.chestSize = 18;
					message += "<p>You step free of the machine, nothing happened.</p>";
				} else {
					if (posOrNeg == 1) {
						message += "<p>Your chest feels tight, when you step free you find your torso has broadened.</p>";
					} else {
						message += "<p>Your chest feels tight, when you step free you find your torso has narrowed.</p>";
					}
				}
			case "waist":
				oldValue = playerCharacter.waistSize;
				toChange = Math.round(Math.random() * 11) + 1;
				toChange *= posOrNeg;
				playerCharacter.waistSize += Math.round(toChange);
				if (playerCharacter.waistSize < 12 && oldValue == 12) {
					playerCharacter.waistSize = 12;
					message += "<p>You step free of the machine, nothing happened.</p>";
				} else {
					if (posOrNeg == 1) {
						message += "<p>You feel something pinch around your waist, when you step out you find your waist has thickened.</p>";
					} else {
						message += "<p>You feel something pinch around your waist, when you step out you find your waist has narrowed.</p>";
					}
				}
			case "hip":
				oldValue = playerCharacter.hipSize;
				toChange = Math.round(Math.random() * 11) + 1;
				toChange *= posOrNeg;
				playerCharacter.hipSize += toChange;
				if (playerCharacter.hipSize < 12 && oldValue == 12) {
					playerCharacter.hipSize = 12;
					message += "<p>You step free of the machine, nothing happened.</p>";
				} else {
					if (posOrNeg == 1) {
						message += "<p>A sharp pain shoots through your hips, you stumble when you exit the machine not expecting the wider hips you now have.</p>";
					} else {
						message += "<p>A sharp pain shoots through your hips, you stumble when you exit the machine not expecting the narrower hips you now have.</p>";
					}
				}
			case "butt":
				oldValue = playerCharacter.buttSize;
				toChange = Math.round(Math.random() * 4) + 1;
				toChange *= posOrNeg;
				playerCharacter.buttSize += Math.round(toChange);
				if (playerCharacter.buttSize < 1 && oldValue == 1) {
					playerCharacter.buttSize = 1;
					message += "<p>You step free of the machine, nothing happened.</p>";
				} else {
					if (posOrNeg == 1) {
						message += "<p>A feeling like someone just swatted you from behind hits you just before you step out of the machine. You spin around to find no one there. When you check your rear, you find it has grown.</p>";
					} else {
						message += "<p>A feeling like someone just swatted you from behind hits you just before you step out of the machine. You spin around to find no one there. When you check your rear, you find it has shrunk.</p>";
					}
				}
			case "breast":
				oldValue = playerCharacter.breastSize;
				toChange = Math.round(Math.random() * 6) + 1;
				toChange *= posOrNeg;
				playerCharacter.breastSize += Math.round(toChange);
				if (playerCharacter.breastSize < 1 && oldValue == 1 && playerCharacter.breasts) {
					playerCharacter.breastSize = 0;
					playerCharacter.breasts = false;
					message += "<p>A very strange feeling of cold rushes through your breasts, when it passes and you manage to get yourself free of the machine, you discover your breasts are gone.</p>";
				} else if (playerCharacter.breastSize >= 1 && !playerCharacter.breasts) {
					playerCharacter.breasts = true;
					message += "<p>A very strange feeling of cold rushes through your chest, when it passes and you manage to get yourself free of the machine, you discover you have breasts!</p>";
				} else if (playerCharacter.breastSize < 1 && oldValue == 0 && !playerCharacter.breasts) {
					playerCharacter.breastSize = 0;
					message += "<p>You step free of the machine, nothing happened.</p>";
				} else if (playerCharacter.breastSize < 1 && oldValue > 1 && playerCharacter.breasts) {
					playerCharacter.breastSize = 1;
					message += "<p>A very strange feeling of cold rushes through your breasts, when it passes and you manage to get yourself free of the machine, you discover your breasts have shrunk.</p>";
				} else {
					if (posOrNeg == 1) {
						message += "<p>A very strange feeling of cold rushes through your breasts, when it passes and you manage to get yourself free of the machine, you discover your breasts have grown.</p>";
					} else {
						message += "<p>A very strange feeling of cold rushes through your breasts, when it passes and you manage to get yourself free of the machine, you discover your breasts have shrunk.</p>";
					}
				}
			case "penis length":
				oldValue = playerCharacter.penisL;
				toChange = Std.parseFloat(truncateDecimalPlaces(Math.random() * 2)) + .5;
				toChange *= posOrNeg;
				playerCharacter.penisL += toChange;
				if (playerCharacter.penisL < .1 && oldValue == .1 && playerCharacter.penis) {
					playerCharacter.penisL = 0;
					playerCharacter.penisW = 0;
					playerCharacter.penis = false;
					message += "<p>Your penis feels strange, like you have an errection only different. Once you extract yourself from the machine you discover you no longer have a penis.</p>";
				} else if (playerCharacter.penisL < .1 && oldValue != .1 && playerCharacter.penis) {
					playerCharacter.penisL = .1;
					message += "<p>Your penis feels like it's getting harder, but when you escape the machine and check it, you discover it's gotten shorter.</p>";
				} else if (playerCharacter.penisL > 0 && oldValue == 0 && !playerCharacter.penis) {
					playerCharacter.penis = true;
					if (playerCharacter.penisW < .1)
						playerCharacter.penisW = .1;
					message += "<p>Your crotch feels strange, like you're getting aroused only different. Once you extract yourself from the machine you discover you have a penis.</p>";
				} else if (playerCharacter.penisL < 0 && oldValue == 0 && !playerCharacter.penis) {
					playerCharacter.penisL = 0;
					message += "<p>You step free of the machine, nothing happened.</p>";
				} else {
					if (posOrNeg == 1) {
						message += "<p>Your penis feels like it's getting harder, but when you escape the machine and check it, you discover it's gotten longer.</p>";
					} else {
						message += "<p>Your penis feels like it's getting harder, but when you escape the machine and check it, you discover it's gotten shorter.</p>";
					}
				}
			case "penis width":
				oldValue = playerCharacter.penisW;
				toChange = Std.parseFloat(truncateDecimalPlaces(Math.random() * 1)) + .1;
				toChange *= posOrNeg;
				playerCharacter.penisW += toChange;
				if (playerCharacter.penisW < .1 && oldValue == .1 && playerCharacter.penis) {
					playerCharacter.penisW = 0;
					playerCharacter.penisL = 0;
					playerCharacter.penis = false;
					message += "<p>Your penis feels like it's getting harder, but when you escape the machine and check it, you discover it's gotten thinner.</p>";
				} else if (playerCharacter.penisW < .1 && oldValue != .1 && playerCharacter.penis) {
					playerCharacter.penisW = .1;
					message += "<p>Your penis feels like it's getting harder, but when you escape the machine and check it, you discover it's gotten thinner.</p>";
				} else if (playerCharacter.penisW > 0 && oldValue == 0 && !playerCharacter.penis) {
					playerCharacter.penis = true;
					if (playerCharacter.penisL < .1)
						playerCharacter.penisL = .1;
					message += "<p>Your crotch feels strange, like you're getting aroused only different. Once you extract yourself from the machine you discover you have a penis.</p>";
				} else if (playerCharacter.penisW < 0 && oldValue == 0 && !playerCharacter.penis) {
					playerCharacter.penisW = 0;
					message += "<p>You step free of the machine, nothing happened.</p>";
				} else {
					if (posOrNeg == 1) {
						message += "<p>Your penis feels like it's getting harder, but when you escape the machine and check it, you discover it's gotten thicker.</p>";
					} else {
						message += "<p>Your penis feels like it's getting harder, but when you escape the machine and check it, you discover it's gotten thinner.</p>";
					}
				}
			case "balls":
				oldValue = playerCharacter.ballSize;
				toChange = Std.parseFloat(truncateDecimalPlaces(Math.random() * 2)) + .2;
				toChange *= posOrNeg;
				playerCharacter.ballSize += toChange;
				if (playerCharacter.ballSize < .1 && oldValue == .1 && playerCharacter.balls) {
					playerCharacter.ballSize = 0;
					playerCharacter.balls = false;
					message += "<p>A warm feeling spreads through your balls, when it passes and you get yourself out of the machine, you discover your balls have vanished.</p>";
				} else if (playerCharacter.ballSize < .1 && oldValue != .1 && playerCharacter.balls) {
					playerCharacter.ballSize = .1;
					message += "<p>A warm feeling spreads through your balls, when it passes and you get yourself out of the machine, you discover your balls have shrunk.</p>";
				} else if (playerCharacter.ballSize > 0 && oldValue == 0 && !playerCharacter.balls) {
					playerCharacter.balls = true;
					message += "<p>A warm feeling spreads through your crotch, when it passes and you get yourself out of the machine, you discover you have balls.</p>";
				} else if (playerCharacter.ballSize < 0 && oldValue == 0 && !playerCharacter.balls) {
					playerCharacter.ballSize = 0;
					message += "<p>You step free of the machine, nothing happened.</p>";
				} else {
					if (posOrNeg == 1) {
						message += "<p>A warm feeling spreads through your balls, when it passes and you get yourself out of the machine, you discover your balls have grown.</p>";
					} else {
						message += "<p>A warm feeling spreads through your balls, when it passes and you get yourself out of the machine, you discover your balls have shrunk.</p>";
					}
				}
			}
		}
		
		outputText(message, "Gym - Staff Room");
		
		btns[11].setButton("Leave", null, null, movePlayer);
	}
	
	static function doGoldRoom( e:MouseEvent ) {
		var message:String = "";
		var clicked:Dynamic = e.currentTarget.btnID;
		var increase:Int = 0;
		var increaseCock:Float = 0;
		
		clearAllEvents();
		
		switch (clicked) {
		case "list":
			optionsBtn.visible = false;
			charDesc.visible = false;
			newRoom = false;
			
			if (playerCharacter.lastGoldTrainDay == playerCharacter.day) {
				message += "<p>You eye the machines in the room, but your body still feels sore for your last session. You'll have to come back tomorrow.</p>";
				btns[11].setButton("Next", null, null, movePlayer);
			} else {
				message += "Which machine would you like to use?";
				
				btns[0].setButton("Height", "Increase your height", "height", doGoldRoom);
				btns[1].setButton("Skinny", "Squeeze yourself skinny", "skinny", doGoldRoom);
				btns[2].setButton("Cock", "Make your cock bigger", "cock", doGoldRoom);
				if (!playerCharacter.penis)
					btns[2].disableButton();
				btns[3].setButton("Balls", "Make your balls bigger", "balls", doGoldRoom);
				if (!playerCharacter.balls)
					btns[3].disableButton();
				btns[4].setButton("Errection", "Make your cock bigger when you have an errection", "errection", doGoldRoom);
				if (!playerCharacter.penis)
					btns[4].disableButton();
				btns[5].setButton("Hips", "Make your hips slimmer", "hips", doGoldRoom);
				btns[6].setButton("Butt", "Make your butt tighter", "butt", doGoldRoom);
			}
		case "height":
			//Increase player's height by 3-5 inches
			message += "<p>You strap yourself into the machine and turn it on. The thing vibrates all over your body, a pleasant tingle going over you which quickly increases to an embarrassing level of enjoyment. All too soon the machine beeps that it's finished. You step out, after carefully untangling yourself from the contraption and see that yes, you are a few inches taller then you were when you went in.</p><br><p>Your body feels oddly sore after your last session with the machine, you're probably going to need to wait before doing another session.</p>";
			
			increase = Math.round(Math.random() * 3) + 2;
			
			playerCharacter.tall += increase;
			playerCharacter.arousal += 10;
			playerCharacter.fat -= Math.round(playerCharacter.fat / 6);
			playerCharacter.lastGoldTrainDay = playerCharacter.day;
		case "skinny":
			//Make the player very skinny
			message += "<p>You get yourself into the machine, the top closing on you when you turn it on. It's very claustrophobic and as it closes it squeezes tight on you it feels like something is oozing out of you. While it's not totally uncomfortable, it's not really what you would call pleasant either.</p><br><p>Your body feels oddly sore after your last session with the machine, you're probably going to need to wait before doing another session.</p>";
			
			if (playerCharacter.fat > 5)
				playerCharacter.fat = 5;
			if (playerCharacter.arousal >= 10)
				playerCharacter.arousal -= 10;
			playerCharacter.lastGoldTrainDay = playerCharacter.day;
		case "cock":
			//Make the player's Cock slighlty bigger, a player without a cock shouldn't be able to get to this screen.
			message += "<p>Feeling very uncomfortable, you slide your cock into the slot on the machine. A few twists of a knob and it's secure and tight. You activate the machine and it starts pumping over your shaft, you feel yourself grow hard very quickly, then the strangest sensation as you continue to swell larger. It feels like you grow to a massive size, but when the machine finally finishes and releases you you find you're only slightly larger then you started.</p><br><p>Your body feels oddly sore after your last session with the machine, you're probably going to need to wait before doing another session.</p>";
			
			increaseCock = (Math.round(Math.random() * 3) / 10) + .1;
			
			playerCharacter.penisW += increaseCock;
			playerCharacter.penisL += increaseCock + .2;
			
			if (playerCharacter.arousal < 100) {
				playerCharacter.arousal = 100;
			} else {
				playerCharacter.arousal += 30;
			}
			playerCharacter.lastGoldTrainDay = playerCharacter.day;
		case "balls":
			//Make the player's balls bigger
			message += "<p>It takes you a moment, but you manage to figure out where you're supposed to put yourself on this bizarre machine. Once you're settled in you adjust everything until the machine is just gripping your balls, then you turn it on. You feel a strange, warm sensation pour out of the machine, your balls feeling like they want to pull up towards you without actually moving. The strange sensation is rather pleasurable ";
			if (playerCharacter.penis && !playerCharacter.vagina)
				message += "and your penis quickly responds, growing painfully hard. ";
			if (playerCharacter.vagina && !playerCharacter.penis)
				message += " and your slit grows hot and very wet. ";
			if (playerCharacter.vagina && playerCharacter.penis)
				message += " and your cock quickly responds, growing painfully hard. Your slit, not to be outdone, heats and almost spills fluid. ";
			
			message += "It's all you can do to resist playing with yourself. When the machine finally finishes and you manage to extract yourself you find your balls slightly larger and heavier.</p><br><p>Your body feels oddly sore after your last session with the machine, you're probably going to need to wait before doing another session.</p>";
			
			increaseCock = (Math.round(Math.random() * 2) / 10) + .1;
			
			playerCharacter.ballSize += increaseCock;
			if (playerCharacter.arousal < 100) {
				playerCharacter.arousal = 100;
			} else {
				playerCharacter.arousal += 30;
			}
			playerCharacter.lastGoldTrainDay = playerCharacter.day;
		case "errection":
			//Make the player's cock bigger when they're aroused
			message += "<p>This machine is by far the weirdest and most embarrassing one in the room, but you manage to get yourself placed and the machine closed around you. You turn it on and your cock quickly becomes painfully hard, again it feels like your still getting hard even though you can tell you're as hard as you can get. The machine doesn't seem to care and it keeps making you bigger. When the machine finally releases you you find your erection is much bigger then you're used to. When it finally goes down, you see your the same size soft as you usually are.</p><br><p>Your body feels oddly sore after your last session with the machine, you're probably going to need to wait before doing another session.</p>";
			
			increaseCock = (Math.round(Math.random() * 4) / 10) + .1;
			
			playerCharacter.errect += increaseCock;
			if (playerCharacter.arousal < 100) {
				playerCharacter.arousal = 200;
			} else {
				playerCharacter.arousal += 70;
			}
			playerCharacter.lastGoldTrainDay = playerCharacter.day;
		case "hips":
			//Make the player's hips narrower
			message += "<p>You slide your waist into the machine and turn it on, the odd sensations going over your hips feel very strange. You can't decide if you like it or not and by the time the machine is done working you still haven't figured out if it's good or not. The machine releases you and you step out, staggering slightly as your legs have moved slightly closer together.</p><br><p>Your body feels oddly sore after your last session with the machine, you're probably going to need to wait before doing another session.</p>";
			
			increase = Math.round(Math.random() * 4) + 1;
			
			playerCharacter.hipSize -= increase;
			if (playerCharacter.hipSize < 15)
				playerCharacter.hipSize = 15;
			if (playerCharacter.arousal >= 30)
				playerCharacter.arousal -= 30;
			playerCharacter.lastGoldTrainDay = playerCharacter.day;
		case "butt":
			//Make the player's ass smaller
			message += "<p>You back yourself into the machine, the design forcing you to stick your butt out as you close yourself into it. Your turn it on and a very weird feeling, like thousands of tiny paws, swarms over your rear. The whole contraption vibrates around you until it suddenly shutters to a stop. You extract yourself from it and find your butt is noticeably smaller then it was before.</p><br><p>Your body feels oddly sore after your last session with the machine, you're probably going to need to wait before doing another session.</p>";
			
			increase = Math.round(Math.random() * 4) + 1;
			
			playerCharacter.buttSize -= increase;
			if (playerCharacter.buttSize < 1)
				playerCharacter.buttSize = 1;
			if (playerCharacter.arousal > 40)
				playerCharacter.arousal -= 40;
			playerCharacter.lastGoldTrainDay = playerCharacter.day;
		}
		
		btns[11].setButton("Leave", null, null, movePlayer);
		
		outputText(message, "Gym - Gold Room");
	}
	
	static function doPerk( e:MouseEvent ) {
		//System to allow players to buy additional perks
		//Perks cost 8 * Pride of fat and 8 * Pride of cash per perk rank
		var actionChoice:String = e.currentTarget.btnID.split("|")[0];
		var actionValue:Int = Std.parseInt(e.currentTarget.btnID.split("|")[1]);
		var title:String = "Perk Selection";
		var message:String = "The machine lights up as you slide your arm into the cuff. The screen lists a number of perks you can choose from, as well as the cost of each. Looks like it will cost an amount of body fat and money to make the changes.</p><br><p>";
		var perkCost:Int = 0;
		
		var perks:Array<MyPerk> = new Array();
		
		var dspItem:Int = 0;
		var dspFirstItem:Int = 0;
		
		newRoom = false;
		optionsBtn.visible = false;
		charDesc.visible = false;
		
		clearAllEvents();
		
		for (i in 0...globals.perks.length) {
			if (globals.perks[i].showPerk)
				perks.push(globals.perks[i]);
		}
		
		switch (actionChoice) {
		case "list":
			//List of avalible perks
			if (perks.length > 9) {
				dspFirstItem = actionValue * 9;
				dspItem = dspFirstItem + 9;
			}
			
			if (dspItem > perks.length)
				dspItem = perks.length;
			
			if (perks.length != 0) {
				for (i in dspFirstItem...dspItem) {
					message += perks[i].dispName + " -- " + perks[i].desc + "<br>";
					btns[i - dspFirstItem].setButton(perks[i].dispName, null, "perk|" + i);
					btns[i - dspFirstItem].setClickFunc(doPerk);
				}
				if (perks.length > dspItem) {
					message += "More...";
					btns[10].setButton("Next", null, "list|" + (actionValue + 1));
					btns[10].setClickFunc(doPerk);
				}
				if (dspFirstItem != 0) {
					btns[9].setButton("Prev", null, "list|" + (actionValue - 1));
					btns[9].setClickFunc(doPerk);
				}
			}
		case "perk":
			message = "Would you like to buy this perk?</p><br><p>";
			
			message += perks[actionValue].dispName + " --- " + perks[actionValue].desc + "<br>";
			
			if ((!perks[actionValue].multipleLevels && playerCharacter.hasPerk(perks[actionValue].name) == false) || perks[actionValue].multipleLevels) {
				if (playerCharacter.hasPerk(perks[actionValue].name)) {
					perkCost = Math.round((globals.perkCostMultiplier * playerCharacter.pride) * playerCharacter.perkCount(globals.perks[actionValue].name)) + 27;
					message += "Fat Cost: " + perkCost + "  Cash Cost: " + perkCost + "</p><br><p>";
					message += "Perk count: " + playerCharacter.perkCount(globals.perks[actionValue].name);
				} else {
					perkCost = Math.round((globals.perkCostMultiplier * playerCharacter.pride) / 2);
					message += "Fat Cost: " + perkCost + "  Cash Cost: " + perkCost + "</p><br><p>";
					message += "Perk Unowned";
				}
				
				if (playerCharacter.getMoney() >= perkCost && playerCharacter.fat >= perkCost) {
					//Player has enough money and fat to buy the perk
					btns[0].setButton("Buy", null, "buy|" + actionValue);
					btns[0].setClickFunc(doPerk);
				} else if (playerCharacter.getMoney() < perkCost && playerCharacter.fat >= perkCost) {
					//Player does not have enough money for the perk
					message += "</p><br><p>Not enough money!";
					btns[0].setButton("Buy", "Not enough money", "error");
					btns[0].disableButton();
				} else if (playerCharacter.getMoney() >= perkCost && playerCharacter.fat < perkCost) {
					//player does not have enough fat for the perk
					message += "</p><br><p>Not enough fat!";
					btns[0].setButton("Buy", "Not enough fat", "error");
					btns[0].disableButton();
				} else {
					//player has neither enough fat or money
					message += "</p><br><p>Not enough fat or money!";
					btns[0].setButton("Buy", "Not enough fat or money", "error");
					btns[0].disableButton();
				}
			} else {
				message += "Perk already owned.";
			}
			
			btns[2].setButton("No", null, "list|0");
			btns[2].setClickFunc(doPerk);
		case "buy":
			message = "You make your selection on the machine's display. It whirrs to life and a sharp pinch travels up your arm, you feel your body change in subtle ways. The display shows the process is complete after a moment.";
			
			playerCharacter.addPerk(perks[actionValue].name, globals);
			
			if (playerCharacter.hasPerk(perks[actionValue].name)) {
				perkCost = Math.round((globals.perkCostMultiplier * playerCharacter.pride) * playerCharacter.perkCount(globals.perks[actionValue].name)) + 27;
			} else {
				perkCost = Math.round((globals.perkCostMultiplier * playerCharacter.pride + 27) / 2);
			}
			
			playerCharacter.fat -= perkCost;
			playerCharacter.addMoney( -perkCost);
			
			updateHUD();
			
			btns[0].setButton("Next", null, "perk|" + actionValue);
			btns[0].setClickFunc(doPerk);
		}
		
		outputText(message, title);
		
		btns[11].setButton("Leave");
		btns[11].setClickFunc(movePlayer);
	}
	
	static function doCombat( e:MouseEvent ) {
		//Combat system
		var takeAction:Int = e.currentTarget.btnID;
		var btnOptions:Object = Lib.current.getChildByName("Options Button");
		var btnDesc:Object = Lib.current.getChildByName("Desc Button");
		var txtTime:Object = Lib.current.getChildByName("Time");
		var message:String = "";
		var title:String = "";
		var cash:Int = 0;
		var difficulty:Int = Math.round(playerCharacter.pointsSpent * globals.difficulty);
		var reward:Array<Dynamic> = new Array();
		var createdItems:Array<Dynamic> = new Array();
		
		var npcAttackResult:String = "";
		
		var damage:Int = 0;
		
		clearAllEvents();
		
		/* Combat actions
		 * 0 - Entered from Movement system
		 * 1 - Action choice screen
		 * 2 - Attack
		 * 3 - Grab
		 * 4 - Run
		 * 5 - Crush
		 * 6 - Eat (Only when grabbed)
		 * 7 - Release (Let a grabbed character go)
		 * 8 - Struggle (Try and escape a grab)
		 * 9 - Wait
		 * 10 - Finishing Move
		 * 11 - Consume
		 * 12 - Combat End
		 */
		
		switch (takeAction) {
		case 0:
			//Just entered from movement system
			btnDesc.visible = false;
			btnOptions.visible = false;
			txtTime.visible = false;
			newRoom = false;
			grabbedNPC = false;
			grabbedPC = false;
			
			roomNPC = new MyNPC();
			if (globals.difficulty == 0.5 )
				roomNPC.randomNPC(species, playerCharacter, -difficulty);
			if (globals.difficulty == 1.5 )
				roomNPC.randomNPC(species, playerCharacter, difficulty);
			if (globals.difficulty == 1 )
				roomNPC.randomNPC(species, playerCharacter);
			
			createdItems.push(createItem("weapon"));
			createdItems.push(createItem("armor"));
			
			roomNPC.weapon = createdItems[0];
			roomNPC.armor = createdItems[1];
			
			title = "Park - Hunting Prey";
			
			//Should probably add some element of randomness to the fight generation
			//Right now this code will make a battle pop up every time the player clicks 'hunt' in the park
			if (rollDie(roomNPC.agility() + roomNPC.skillSneak()) >= rollDie(playerCharacter.intelligence() + playerCharacter.skillSpot())) {
				//NPC gets the drop on the player
				message += "A [NPCNAME] appears. [SUBJC] suprises you and attacks!<br>";
				npcAttackResult = npcAttack();
				switch (npcAttackResult) {
				case ">KILLED<":
					//Player died. How..?
					playerDied = "Combat";
					doDeath();
					return;
				case ">ESCAPE<":
					message += "The [NPCNAME] turns tail and flees, quickly escaping you.<br>";
					btns[0].setButton("Next", null, 12);
					btns[0].setClickFunc(doCombat);
					outputText(message, title);
					return;
				default:
					message += npcAttackResult;
				}
				
				btns[0].setButton("Next", null, 1);
				btns[0].setClickFunc(doCombat);
			} else {
				//The player spots the NPC first
				message += "You come across a [NPCNAME]. [SUBJC] readies a weapon and takes an aggressive stance. It's a fight!<br>";
				
				message += playerCharacter.advanceSkill(1, "spot");
				message += playerCharacter.advanceSkill(1, "int");
				
				btns[0].setButton("Next", null, 1);
				btns[0].setClickFunc(doCombat);
				btns[2].setButton("Run", "Attempt to flee", 4);
				btns[2].setClickFunc(doCombat);
			}
			
		case 1:
			//Action choice screen
			if (grabbedPC) {
				title = "Park - Grabbed!";
			} else {
				title = "Park - Under Attack!";
			}
			
			message += "You are under attack by a [NPCNAME]. [SUBJC] appears [WOUNDED].</p><p>";
			
			if (globals.debugMode) { //debug mode on
				message += "Debug info:<br>[NPCNAME] health: " + roomNPC.healthCurr + "/" + roomNPC.health() + "<br>";
				message += "Player stats: agi: " + playerCharacter.agility() + ", str: " + playerCharacter.strength() + ", end: " + playerCharacter.endurance() + ", int: " + playerCharacter.intelligence() + "<br>";
				message += "Player skills: melee: " + playerCharacter.skillMelee() + ", run: " + playerCharacter.skillRun() + ", dodge: " + playerCharacter.skillDodge() + ", sneak: " + playerCharacter.skillSneak() + ", spot: " + playerCharacter.skillSpot() + "<br>";
				message += "NPC stats: agi: " + roomNPC.agility() + ", str: " + roomNPC.strength() + ", end: " + roomNPC.endurance() + ", int: " + roomNPC.intelligence() + "<br>";
				message += "NPC skills: melee: " + roomNPC.skillMelee() + ", run: " + roomNPC.skillRun() + ", dodge: " + roomNPC.skillDodge() + ", sneak: " + roomNPC.skillSneak() + ", spot: " + roomNPC.skillSpot() + "<br";
			}
			
			if (!grabbedNPC && !grabbedPC) { //No one is grabbing anyone
				btns[0].setButton("Attack", "Attack with your equipped weapon", 2);
				btns[0].setClickFunc(doCombat);
				btns[1].setButton("Grab", "Attempt to grab and hold your foe", 3);
				btns[1].setClickFunc(doCombat);
				btns[2].setButton("Run", "Attempt to flee", 4);
				btns[2].setClickFunc(doCombat);
			}
			if (grabbedNPC) { //The Player has a hold of the NPC
				btns[0].setButton("Crush", "Use your strength to damage your foe", 5);
				btns[0].setClickFunc(doCombat);
				btns[1].setButton("Consume", "Stuff your foe in your belly", 6);
				btns[1].setClickFunc(doCombat);
				btns[2].setButton("Release", "Let your foe go", 7);
				btns[2].setClickFunc(doCombat);
			}
			if (grabbedPC) { //The NPC has a hold of the Player
				btns[0].setButton("Struggle", "Try and escape", 8);
				btns[0].setClickFunc(doCombat);
				btns[1].setButton("Wait", "Wait and see where this is going", 9);
				btns[1].setClickFunc(doCombat);
			}
		case 2:
			//Attack
			title = "Park - Attack!";
			
			
			//Attack the NPC, first try and hit it
			if (rollDie(roomNPC.agility() + roomNPC.skillDodge()) > rollDie(playerCharacter.agility() + playerCharacter.skillMelee() + playerCharacter.equipWepObj.attack)) {
				//NPC dodges
				message += "You swing your " + playerCharacter.equipWepObj.name.toLowerCase() + " at the [NPCNAME] but [SUBJ] evades your attack.<br>";
			} else {
				//PC hits
				
				//damage
				damage = rollDie(playerCharacter.strength() + playerCharacter.equipWepObj.attack);
				if (damage <= 0)
					damage = playerCharacter.strength(); //Minimum damage
				
				playerCharacter.advanceSkill(1, "agi");
				playerCharacter.advanceSkill(1, "melee");
				playerCharacter.advanceSkill(1, "str");
				
				
				message += "You swing your " + playerCharacter.equipWepObj.name.toLowerCase() + " at the [NPCNAME] for " + damage + " damage.<br>";
				
				roomNPC.healthCurr = roomNPC.healthCurr - damage;
				
				if (roomNPC.healthCurr <= 0) {
					//NPC is dead
					message += "Your foe falls to [OBJ] knees, [OBJ] breath fading fast.<br>";
					
					btns[0].setButton("Kill", "Finish Them!", 10);
					btns[0].setClickFunc(doCombat);
					btns[1].setButton("Consume", "All that fighting worked up an appetite", 11);
					btns[1].setClickFunc(doCombat);
					btns[2].setButton("Leave", "Walk away", 12);
					btns[2].setClickFunc(doCombat);
					
					outputText(message, title);
					
					return;
				}
			}
			
			npcAttackResult = npcAttack();
			switch (npcAttackResult) {
			case ">KILLED<":
				playerDied = "Combat";
				doDeath();
				return;
			case ">ESCAPE<":
				message += "The [NPCNAME] turns tail and flees, quickly escaping you.<br>";
				btns[0].setButton("Next", null, 12);
				btns[0].setClickFunc(doCombat);
				outputText(message, title);
				return;
			default:
				message += npcAttackResult;
			}
			
			btns[0].setButton("Next", null, 1);
			btns[0].setClickFunc(doCombat);
		case 3:
			//Grab
			title = "Park - Grab";
			
			//Attempt to grab the NPC
			message += "You lunge forward, trying to get your hands around the [NPCNAME]. ";
			
			if (rollDie(roomNPC.agility() + roomNPC.skillDodge()) >= rollDie(playerCharacter.agility() + playerCharacter.skillMelee())) {
				//NPC dodges
				message += "But [SUBJ] slips out of your grasp.<br>";
				
				npcAttackResult = npcAttack();
				switch (npcAttackResult) {
				case ">KILLED<":
					//Player died. How..?
					playerDied = "Combat";
					doDeath();
					return;
				case ">ESCAPE<":
					message += "The [NPCNAME] turns tail and flees, quickly escaping you.<br>";
					btns[0].setButton("Next", null, 12);
					btns[0].setClickFunc(doCombat);
					outputText(message, title);
					return;
				default:
					message += npcAttackResult;
				}
			} else {
				//PC grabs the NPC
				message += "You successfully wrap your arms around [OBJ].<br>";
				
				playerCharacter.advanceSkill(1, "agi");
				playerCharacter.advanceSkill(1, "melee");
				
				grabbedNPC = true;
			}
			
			btns[0].setButton("Next", null, 1);
			btns[0].setClickFunc(doCombat);
		case 4:
			//Run
			title = "Park - Running";
			
			//Player attempts to escape the combat
			message += "You turn and attempt to escape, ";
			
			if (rollDie(roomNPC.agility() + roomNPC.skillRun()) >= rollDie(playerCharacter.agility() + playerCharacter.skillRun())) {
				//Player fails to escape
				message += "but the [NPCNAME] stays with you.<br>";
				
				npcAttackResult = npcAttack();
				switch (npcAttackResult) {
				case ">KILLED<":
					//Player died. How..?
					playerDied = "Combat";
					doDeath();
					return;
				case ">ESCAPE<":
					message += "The [NPCNAME] turns tail and flees, quickly escaping you.<br>";
					btns[0].setButton("Next", null, 12);
					btns[0].setClickFunc(doCombat);
					outputText(message, title);
					return;
				default:
					message += npcAttackResult;
				}
				
				btns[0].setButton("Next", null, 1);
				btns[0].setClickFunc(doCombat);
			} else {
				//Player escapes
				message += "and quickly leave the [NPCNAME] behind.<br>";
				
				btns[0].setButton("Next", null, 12);
				btns[0].setClickFunc(doCombat);
			}
		case 5:
			//Crush
			title = "Park - Grabbing";
			
			damage = rollDie(playerCharacter.strength());
			
			if (damage < playerCharacter.strength())
				damage = playerCharacter.strength(); //Minimum damage
			
			playerCharacter.advanceSkill(1, "str");
			
			message += "You squeeze the [NPCNAME] tightly for " + damage + " damage.<br>";
			
			roomNPC.healthCurr = roomNPC.healthCurr - damage;
			
			if (roomNPC.healthCurr <= 0) {
				//NPC is dead
				message += "Your foe falls to [OBJ] knees, [OBJ] breath fading fast.<br>";
				
				btns[0].setButton("Kill", "Finish Them!", 10);
				btns[0].setClickFunc(doCombat);
				btns[1].setButton("Consume", "All that fighting worked up an appetite", 11);
				btns[1].setClickFunc(doCombat);
				btns[2].setButton("Leave", "Walk away", 12);
				btns[2].setClickFunc(doCombat);
				
				outputText(message, title);
				
				return;
			}
			
			//NPC tries to escape
			if (rollDie(roomNPC.strength()) <= rollDie(playerCharacter.strength())) {
				//NPC fails to escape
				message += "Your foe struggles in your grasp, but fails to escape from you.<br>";
				
				playerCharacter.advanceSkill(1, "str");
			} else {
				//NPC escapes
				message += "Your foe struggles in your grasp and bursts free of you.<br>";
				
				grabbedNPC = false;
			}
			
			btns[0].setButton("Next", null, 1);
			btns[0].setClickFunc(doCombat);
		case 6:
			//Eat Grabbed Foe
			title = "Park - Consume Foe";
			
			if (rollDie(roomNPC.strength()) <= rollDie(playerCharacter.strength() + playerCharacter.gluttony)) {
				//NPC gets eaten
				
				message += "(Placeholder) You lift your struggling prey to your mouth and quickly slide [OBJ] down your throat.<br>";
				
				playerCharacter.gluttony++;
				playerCharacter.stomachContents.push(roomNPC);
				playerCharacter.stomachCurrent += roomNPC.mass;
				playerCharacter.numEaten++;

				playerCharacter.advanceSkill(1, "str");
				
				btns[0].setButton("Next", null, 12);
				btns[0].setClickFunc(doCombat);
			} else {
				//PC fails to swallow their foe
				
				message += "You attempt to swallow your foe, but [SUBJ] struggles out of your grasp.<br>";
				
				grabbedNPC = false;
				
				btns[0].setButton("Next", null, 1);
				btns[0].setClickFunc(doCombat);
			}
		case 7:
			//Release
			title = "Park - Release Your Foe";
			
			message += "You let your foe go, [OBJ] stands and readies [SUBJ] weapons.<br>";
			
			grabbedNPC = false;
			
			btns[0].setButton("Next", null, 1);
			btns[0].setClickFunc(doCombat);
		case 8:
			//Struggle
			title = "Park - Grabbed!";
			
			if (rollDie(playerCharacter.strength()) > rollDie(roomNPC.strength())) {
				//Player breaks free
				message += "You struggle and break free from the [NPCNAME]'s grasp.<br>";
				grabbedPC = false;
				message += playerCharacter.advanceSkill(1, "str");
			} else {
				//player failed to escape
				message += "You struggle but the [NPCNAME] holds you tight.<br>";
				
				npcAttackResult = npcAttack();
				switch (npcAttackResult) {
				case ">KILLED<":
					//Player died. How..?
					playerDied = "Combat";
					doDeath();
					return;
				case ">ESCAPE<":
					message += "The [NPCNAME] turns tail and flees, quickly escaping you.<br>";
					btns[0].setButton("Next", null, 12);
					btns[0].setClickFunc(doCombat);
					outputText(message, title);
					return;
				default:
					message += npcAttackResult;
				}
			}
			
			btns[0].setButton("Next", null, 1);
			btns[0].setClickFunc(doCombat);
		case 9:
			//Wait
			title = "Park - Wait";
			
			//Player waits, letting the NPC do what they want for a round
			message += "You wait, watching the [NPCNAME].<br>";
			
			npcAttackResult = npcAttack();
			switch (npcAttackResult) {
			case ">KILLED<":
				//Player died. How..?
				playerDied = "Combat";
				doDeath();
				return;
			case ">ESCAPE<":
				message += "The [NPCNAME] turns tail and flees, quickly escaping you.<br>";
				btns[0].setButton("Next", null, 12);
				btns[0].setClickFunc(doCombat);
				outputText(message, title);
				return;
			default:
				message += npcAttackResult;
			}
			
			btns[0].setButton("Next", null, 1);
			btns[0].setClickFunc(doCombat);
		case 10:
			//Finish Him!
			
			title = "Park - Fatality!";
			
			//Finishing moves are based on the weapon. For now, something simple.
			
			message += playerCharacter.equipWepObj.finisher;
			
			btns[0].setButton("Next", null, 12);
			btns[0].setClickFunc(doCombat);
		case 11:
			//Consume your defeated foe
			title = "Park - Consume Foe";
			
			message += "(Placeholder) Your foe struggles weakly as you lift [OBJ] to your mouth and swallow them in a few quick gulps.<br>";
			
			playerCharacter.stomachContents.push(roomNPC);
			playerCharacter.stomachCurrent += roomNPC.mass;
			playerCharacter.numEaten++;
			playerCharacter.gluttony++;
			playerCharacter.arousal += 1;
			
			btns[0].setButton("Next", null, 12);
			btns[0].setClickFunc(doCombat);
		case 12:
			//Return to the movement system and get rewards
			title = "Combat Ends";
			message += "You sigh, relaxing from the combat.<br>";
			
			//items, nothing currently
			
			if (roomNPC.weapon != null) {
				reward.push(roomNPC.weapon);
			}
			if (roomNPC.armor != null) {
				reward.push(roomNPC.armor);
			}
			if (Math.round(Math.random() * 10) == 0)
				reward.push(createItem("ring"));
			
			for (i in 0...playerCharacter.greed) {
				if (Math.round(Math.random() * playerCharacter.luck()) == 1) {
					reward.push(globals.food[Math.round(Math.random() * globals.food.length - 1)].copyItem());
				}
			}
			//cash
			if (playerCharacter.greed == 0)
				playerCharacter.greed = 1;
			
			cash = (Math.round(Math.random() * playerCharacter.intelligence()) * playerCharacter.greed) * 10;
			
			if (cash <= 0)
				cash = 10;
			
			playerCharacter.greed++;
			
			if (reward.length == 0) {
				message += "You don't find any items, but you do pick up $" + cash + " and put it in your pocket.<br>";
			} else {
				message += "You find ";
				for (i in 0...reward.length) {
					message += reward[i].name;
					if (i != reward.length - 1)
						message += ", ";
				}
				message += " on your fallen foe and $" + cash + " and put all of it away.<br>";
			}
			
			for (i in 0...reward.length) {
				reward[i].give(playerCharacter);
			}
			
			playerCharacter.addMoney(cash);
			
			btns[0].setButton("Next", null, 0);
			btns[0].setClickFunc(movePlayer);
		default:
			title = "Error";
			message = "Warning, unknown takeAction value in doCombat: " + takeAction;
		}
		
		updateHUD();
		outputText(message, title);
	}
	
	static function doGym( e:MouseEvent ) {
		var clicked:String = e.currentTarget.btnID;
		var splitArray:Array<String> = new Array();
		var action:String = "";
		var choice:String = "";
		var message:String = "";
		var rndNPCChance:Int = -1;
		var strWorkoutMessages:Array<String> = new Array();
		var agiWorkoutMessages:Array<String> = new Array();
		var endWorkoutMessages:Array<String> = new Array();
		var skillTrainSucc:Int = -1;
		var workoutMessage:String = "";
		var workoutTime:Int = 0;
		
		strWorkoutMessages = ["You decide to start at the beginning of the strength path and work your way to the end. The going is easy, with a light warm up at the beginning followed by some intense work focusing on your different muscle groups and finally ending with some easy cool downs.",
			"You decide to mix things up a little this time. You start with the warm up exercises but then switch around the focused machines, getting the same workout but keeping it from being too repetitive. The cool downs at the end are welcome.",
			"After doing your warmups you find someone else is using the first of the muscle group machines. So you move to the other end and work through them backwards, then return to do your cool downs."
			];
		
		agiWorkoutMessages = ["The agility path seems to mostly consist of a number of stretches done on a mat and a few machines. You work your way down the chart, doing one after the other in the order they're listed.",
			"The agility path seems to mostly consist of a number of stretches done on a mat and a few machines. You work your way up the chart, doing one after the other in the reverse order they're listed.",
			"The agility path seems to mostly consist of a number of stretches done on a mat and a few machines. You try and work through the stretches randomly, but you soon loose track of which one you've done and which you haven't and give up, doing them in order."
			];
		
		endWorkoutMessages = ["After doing your warmups you hit the track running round the outside of the gym. Coming back to do your cool downs after several laps.",
			"Your warmups done you hop on one of the stationary bikes and set a program, riding hard until it tells you you've finished and move off to do your cooldowns.",
			"You do your warmups quickly, then follow signs around the gym using machines from both the strength and agility paths that help you build your endurance up."
			];
		
		if (optionsBtn.visible) {
			//First time into this function, make a few adjustments
			newRoom = false;
			optionsBtn.visible = false;
			charDesc.visible = false;
			if (globals.debugMode)
				txtDebug.removeEventListener(MouseEvent.CLICK, debugMenu);
		}
		
		clearAllEvents();
		
		splitArray = clicked.split(":");
		action = splitArray[0];
		choice = splitArray[1];
		
		//Check the player is a gold memeber, they don't need to pay, or if they've already paid for the day
		if (playerCharacter.quest[2].stage >= 3 || playerCharacter.lastDayTrained == playerCharacter.day) {
			playerCharacter.lastDayTrained = playerCharacter.day; //There are other things that use this value, need to keep it accurate
		} else {
			//Player needs to pay, make sure they have the money to do so
			message = "You head towards the bank of machines, swiping your card as you do so.</p><br><p>";
			
			if (playerCharacter.getMoney() >= globals.gymFee) {
				message += "The card reader beeps and your account is lighter by $" + globals.gymFee + ".</p><br><p>";
				playerCharacter.addMoney(-globals.gymFee);
				playerCharacter.lastDayTrained = playerCharacter.day;
			} else {
				//Not enough money
				message += "The card reader buzzes and displays a message, apparently you're a little short on funds today. You need $" + globals.gymFee + ".</p><br>";
				clicked = "leave";
			}
		}
		
		/* Training paths
		 * Strength
		 * Agility
		 * Endurance
		 */
		
		switch (action) {
		case "choose":
			//Inital landing point
			message += "There are signs giving you several different options on ways to use the equipment in this room, from what you can tell there are three paths you can take, one for Strength, one for Agility and one for Endurance. Which do you wish to use first?</p><br><p>";
			
			btns[0].setButton("Strength", "Follow the signs marked for strength traning. Should take about an hour to finish.", "workout:str");
			btns[0].setClickFunc(doGym);
			btns[1].setButton("Agility", "Follow the signs marked for agility traning. Should take about an hour to finish.", "workout:agi");
			btns[1].setClickFunc(doGym);
			btns[2].setButton("Endurance", "Follow the signs marked for endurance traning. Should take about an hour and a half to finish.", "workout:end");
			btns[2].setClickFunc(doGym);
			
			btns[11].setButton("Leave", "Head to the showers and get cleaned up", "leave");
			btns[11].setClickFunc(doGym);
		case "leave":
			//Player is done with the machines
			message += "You leave the workout area and move to the showers to wash your workout sweat off you.</p><br>";
			
			//To-Do: Add an NPC encounter event here.
			var rndEnct:Int = Math.round(Math.random() * 2);
			if (rndEnct == 0 && playerCharacter.quest[2].stage == 1) {
				message += "<p>As you are leaving the showers, a tall and massively muscular human shoulder-checks you in passing. His gym shorts strain at holding back a very large buldge. He scoffs at you and pushes you out of his way, \"Move it tiny. Got places to be.\"</p><br><p>Ass.</p><br>";
			}
			
			newRoom = true;
			
			btns[11].setButton("Leave", null, 25);
			btns[11].setClickFunc(movePlayer);
		case "workout":
			//Doing the workouts
			
			if (playerCharacter.fat == 0 && !globals.debugMode) {
				outputText("You find yourself too tired to make use of any machines right now.", "Working Out");
				btns[11].setButton("Leave", "Head to the showers and get cleaned up", "leave");
				btns[11].setClickFunc(doGym);
				return;
			}
			
			btns[0].setButton("Strength", "Follow the signs marked for strength traning. Should take about an hour to finish.", "workout:str");
			btns[0].setClickFunc(doGym);
			btns[1].setButton("Agility", "Follow the signs marked for agility traning. Should take about an hour to finish.", "workout:agi");
			btns[1].setClickFunc(doGym);
			btns[2].setButton("Endurance", "Follow the signs marked for endurance traning. Should take about an hour and a half to finish.", "workout:end");
			btns[2].setClickFunc(doGym);
			
			btns[11].setButton("Leave", "Head to the showers and get cleaned up", "leave");
			btns[11].setClickFunc(doGym);
			
			switch (choice) {
			case "str":
				workoutMessage = strWorkoutMessages[Math.round(Math.random() * (strWorkoutMessages.length - 1))] + "</p><br><p>";
				skillTrainSucc = rollDie(playerCharacter.strength() + 10);
				playerCharacter.advanceSkill(skillTrainSucc, "str");
				workoutTime = 60;
				
				btns[0].setButton("Strength", "Follow the Strength path again.", "workout:str");
			case "agi":
				workoutMessage = agiWorkoutMessages[Math.round(Math.random() * (agiWorkoutMessages.length - 1))] + "</p><br><p>";
				skillTrainSucc = rollDie(playerCharacter.agility() + 10);
				playerCharacter.advanceSkill(skillTrainSucc, "agi");
				workoutTime = 60;
				
				btns[1].setButton("Agility", "Follow the Agility path again.", "workout:agi");
			case "end":
				workoutMessage = endWorkoutMessages[Math.round(Math.random() * (endWorkoutMessages.length - 1))] + "</p><br><p>";
				skillTrainSucc = rollDie(playerCharacter.endurance() + 10);
				playerCharacter.advanceSkill(skillTrainSucc, "end");
				workoutTime = 90;
				
				btns[2].setButton("Endurance", "Follow the Endurance path again.", "workout:end");
			}
			
			message += workoutMessage;
			
			if (skillTrainSucc < 0)
				message += "This message is a bug, please report the skillup roll failed.";
			if (skillTrainSucc == 0)
				message += "You do your best, but don't feel like you made any progress today.</p><br>";
			if ((skillTrainSucc > 0) && (skillTrainSucc <= 10))
				message += "You work out and build up a sweat, feeling like you made good progress.</p><br>";
			if ((skillTrainSucc > 10) && (skillTrainSucc <= 20))
				message += "You work out, feeling your muscles burn with the effort. You made great progress today.</p><br>";
			if (skillTrainSucc > 20)
				message += "You tackle the path with glee and even do an extra set on each machine. You made amazing progress today.</p><br>";
			
			//Random NPC encounter
			rndNPCChance = Math.round(Math.random() * 5);
			
			roomNPC = new MyNPC();
			roomNPC.name = "NULL";
			
			switch (rndNPCChance) {
			case 0:
				//Gold member
				if (playerCharacter.quest[2].stage < 2) {
					message += "<p>A tall, massively muscular human sits at the machine next to you.</p><br>";
					
					roomNPC.newNPC(nonPlayerCharacters[7]); //Erik, need to check on this.
				}
			//Random Named NPCs
			case 1:
				//Kyra
				
			case 2:
				// Empty Slot
			case 3:
				// Randomly generated NPC
				roomNPC.randomNPC(species, playerCharacter);
				
				message += "<p>A [NPCNAME] sits at the machine next to you.</p><br>";
			default:
				// No NPC appears
			}
			
			if (roomNPC.name != "NULL") {
				btns[9].setButton("Talk", "Talk to the " + roomNPC.species.name.toLowerCase(), 0);
				btns[9].setClickFunc(doTalk);
			}
			
			//Time pass, this might need to get tweaked for the gym
			playerCharacter.passTime(workoutTime);
			
			//Player fat burn, the more fat they have, the more should be burned off with each seasion.
			if (playerCharacter.fat >= 10)
				playerCharacter.fat -= Math.round(playerCharacter.fat * 0.09); //Aubatray number, might need some tweaking still. Also I can't spell. I am aware of this.
			//This should also keep the fat level from going into the negitives.
			if (playerCharacter.fat < 10)
				playerCharacter.fat = 0;
			
			if (globals.debugMode) {
				message += "<p>{Debug} Workout time: " + workoutTime + ", fat burn: " + Math.round(playerCharacter.fat * 0.09) + "</p>";
			}
		}
		
		
		updateHUD();
		outputText(message, "Working Out");
	}
	
	static function doFoodComa( ?e:MouseEvent ) {
		var message:String = "";
		var TimeSpentInComa:Int = 0;
		
		var StartingFat:Int = playerCharacter.fat;
		var StartingPoop:Float = playerCharacter.bowelsCurrent;
		var StartingCum:Float = playerCharacter.cumCurrent;
		var StartingMilk:Float = playerCharacter.breastCurrent;
		var StartingStomachCap:Float = playerCharacter.stomachCap;
		var StartingStomachFill:Float = playerCharacter.stomachCurrent;
		
		txtPublic.visible = false;
		optionsBtn.visible = false;
		charDesc.visible = false;
		if (globals.debugMode)
			txtDebug.removeEventListener(MouseEvent.CLICK, debugMenu);
		
		newRoom = true;
		
		clearAllEvents();
		
		/* So here's what's supposed to happen when a player goes into a food coma;
		 * They pass out for an amount of time equal to the time it takes for them to digest
		 * the food that has put them over stomachCap. So when the coma ends stomachCurrent
		 * should be equal too or slightly less then stomachCap
		 * 
		 * The tricky part here is that stomach streching still happens
		 */
		
		while (playerCharacter.stomachCurrent > playerCharacter.stomachCap) {
			// So this should be all we need to do here with the changes to the digestion system
			// The only issue is that Flash has an aubratray limit on the number of times a loop can exicute before it gets stopped.
			playerCharacter.passTime(1);
			TimeSpentInComa++;
		}
		
		message = "{Food coma message}";
		
		if (globals.debugMode) {
			message += "</p><br><p>{Placeholder} Sleep for " + convertTime(TimeSpentInComa) + 
					" and digested " + truncateDecimalPlaces(StartingStomachFill - playerCharacter.stomachCurrent) + " cubic inches of mass. " + 
					"You gained " + truncateDecimalPlaces(playerCharacter.fat - StartingFat) + "lbs of fat, " + 
					truncateDecimalPlaces(playerCharacter.bowelsCurrent - StartingPoop) + "lbs of poo, " + 
					truncateDecimalPlaces(playerCharacter.cumCurrent - StartingCum) + "lbs of cum and " + 
					truncateDecimalPlaces(playerCharacter.breastCurrent - StartingMilk) + "lbs of milk. " + 
					"Your stomach stretched out by " + truncateDecimalPlaces(playerCharacter.stomachCap - StartingStomachCap) + ".<br>";
		}
		
		// Check for prey messages
		// -- Note: This pullDisgestedPrey needs to be here even if messages aren't written- otherwise
		//		the dead prey will show up in the player's next action after this.
		var ExpiredPrey:Array<MyNPC> = playerCharacter.pullDisgestedPrey();
		for (CurPrey in ExpiredPrey) {
			//message += "The " + CurPrey.name + " you ate has stopped moving.";
		}

		outputText(message, "Food Coma");
		updateHUD();
		btns[11].setButton("Next", null, 0);
		btns[11].setClickFunc(movePlayer);
	}
	
	static function doDeath( ?e:MouseEvent ) {
		var message:String = "";
		var title:String = "You Died";
		var clicked:Int = -1;
		var smCap:Float = globals.textSize - 4;
		
		if (e != null)
			clicked = e.currentTarget.btnID;
		
		clearAllEvents();
		txtPublic.visible = false;
		
		switch (playerDied) {
		case "prey":
			//Player signed up to be prey
			roomNPC = new MyNPC();
			roomNPC.randomNPC(species, playerCharacter);
			
			for (i in 0...playerCharacter.quest.length) {
				if (playerCharacter.quest[i].name == "club")
					playerCharacter.quest[i].stage = 0;
			}
			
			title = "Consume - Prey";
			message = "You spend some time on the dance floor, eventually making your way to the bar to enjoy the free drinks. Several drinks later and you've got a nice buzz going on and a " + roomNPC.name + " approaches you and takes you into the back rooms. " + roomNPC.gender("sub") + " doesn't waste any time on pleasantries and simply shoves you down " + roomNPC.gender("pos").toLowerCase() + " throat as soon as the door locks. It takes you a few moments to process what just happened, the alcohol in your system making everything feel like a dream. In the last moments you start to panic slightly before everything goes black.</p><br><p>";
		case "bouncer":
			title = "Becoming Cum";
			
			message = "You feel movement, the bouncer is walking somewhere. Then you feel someone touching and running their hands over you. The last thing you feel, as your body dissolves into cum, is the balls around you starting to tighten as someone continues to play with them.</p><br><p>";
			
		case "Combat":
			//Player killed in combat
			message = "You fall to the ground, your foe grinning as [SUBJ] steps closer.</p><br><p>";
		case "Erik":
			message = "The large human scowles down at you, finally lifting a foot and crushing you under his mass.</p><br><p>";
			
		case "Talking to Death":
			//This space intentionally left blank
		default:
			message = "Unknown Death Type: " + playerDied;
		}
			//Time to introduce Death to the game
			
		if (playerDied != "Talking To Death")
			message += "Score: " + Math.round(globals.difficulty * ((playerCharacter.pointsSpent + playerCharacter.numEaten) - playerCharacter.timesDied)) + "</p><br><p>";
		
		//Deal with death
		
		switch (playerCharacter.quest[3].stage) {
		case 0:
			//player hasn't met Death yet
			message += "You find yourself facing a doorway filled with white light, you step through the doorway, nearly blinded by the light. As your eyes adjust to the brightness you find yourself face to face with the single most beautiful [PCSPECIESL] you've ever laid eyes on. Shi stands only five feet tall with long deep red hair. Hir breasts are at least as large as hir head and seem to be swelling before your eyes. A drip of white liquid forms on the tip of one breast, showing they are full of milk. Hir waist is tiny, small enough you could probably put your hand around it without trouble. Hir hips are round and wide, easily wider than hir shoulders, perhaps a bit more. As you look hir over, shi turns letting you see hir round pert butt, large and perfectly heart-shaped. Between hir legs is a long, thick cock. The head resting near hir knee and quite obviously soft. Behind that, two basketball sized balls rest against hir thighs.</p><br><p>";
			message += "Shi looks up as you step near, gold eyes glowing softly. Shi speaks without moving hir lips, hir 'voice' more like words simply appearing in your head without going past your ears (which you don't technically have anyway) ";
			message += "G<font size='" + smCap + "'>REETINGS [PCNAMEC]. </font>I <font size='" + smCap + "'>have good news, and bad news for you.</font></p><br><p>".toUpperCase();
			message += "Before you can speak, shi continues, ";
			message += "T<font size='" + smCap + "'>HE BAD NEWS IS THAT YOU ARE DEAD.</font> T<font size='" + smCap + "'>HE GOOD NEWS IS THAT, THOUGH YOU ARE DEAD, THERE IS THE POSSIBILITY FOR YOU TO RETURN TO THE WORLD OF THE LIVING.</font> T<font size='" + smCap + "'>O DO SO, ALL YOU HAVE TO DO IS AGREE TO A FAVOR.</font></p>";
			
			playerDied = "Talking to Death";
			
			playerCharacter.quest[3].stage = 1;
			
			outputText(message, "A Deal Is Offered");
			
			btns[0].setButton("Agree", null, 0);
			btns[0].setClickFunc(doDeath);
			btns[2].setButton("Disagree", null, 1);
			btns[2].setClickFunc(doDeath);
			return;
		case 1:
			//The player is offered the choice
			switch (clicked) {
			case 0:
				//Agreed to the deal
				message += "You pause, but the being before you smiles and waits, so you speak, &quot;Agreed.&quot; Hir smile grows and shi gestures to the side where another glowing doorway has appeared. This one you sense will take you back to the world of the living.</p><br><p>";
				message += "I'<font size='" + smCap + "'>LL BE IN TOUCH SOON.</font></p>";
				
				playerCharacter.quest[3].stage = 2;
				playerCharacter.timesDied++;
				
				playerCharacter.healPlayer();
				if (playerCharacter.fat + 100 >= 0) {
					playerCharacter.fat -= 100;
				} else {
					playerCharacter.fat = 0;
				}
				
				outputText(message, "A Bargain is Struck");
				
				newRoom = true;
				
				btns[0].setButton("Next", null, 0);
				btns[0].setClickFunc(movePlayer);
				return;
			case 1:
				//Declined the deal
				message += "You pause, but the being before you smiles and waits, so you speak, &quot;No deals.&quot; Hir smile turns sad and shi gestures to the side where another glowing doorway has appeared. This one you sense will take you back to the world of the living.</p><br><p>";
				message += "V<font size='" + smCap + "'>ERY WELL.</font> C<font size='" + smCap + "'>ONSITER THIS A GIFT FOR SPEAKING WITH ME.</font> W<font size='" + smCap + "'>E WILL NOT MEET AGAIN.</font>";
				
				playerCharacter.quest[3].stage = 3;
				
				outputText(message, "A Bargain is Declined");
				
				newRoom = true;
				playerCharacter.healPlayer();
				playerCharacter.timesDied++;
				
				if (playerCharacter.fat + 1000 >= 0) {
					playerCharacter.fat -= 1000;
				} else {
					playerCharacter.fat = 0;
				}
				
				btns[0].setButton("Next", null, 0);
				btns[0].setClickFunc(movePlayer);
				return;
			}
		case 2:
			//player agreed to the deal
			message += "You feel eyes watching you, the usual door back to the world of the living waiting before you. You sense there may be more, but Shi is waiting for some reason.";
			
			//Random chance for a sexy/vore encounter with death instead of just the door.
			
			playerCharacter.timesDied++;
			playerCharacter.healPlayer();
			if (playerCharacter.fat + 100 >= 0) {
				playerCharacter.fat -= 100;
			} else {
				playerCharacter.fat = 0;
			}
			
			outputText(message, title);
			
			newRoom = true;
			
			btns[0].setButton("Next", null, 0);
			btns[0].setClickFunc(movePlayer);
		case 3:
			//player turned the deal down
			btns[11].setButton("Main Menu");
			btns[11].setClickFunc(resetGame);
			
			playerDead = true;
			
			outputText(message, title);
		}
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
			btns[0].setClickFunc(doHunt);
			
			if (playerCharacter.arousal >= 50 && globals.allowSex) {
				btns[2].setButton("Fuck", "Take " + roomNPC.gender("obj").toLowerCase() + " to the backroom and sate yourself", 3);
				btns[2].setClickFunc(doHunt);
			}
			btns[9].setButton("Look Again", "Take another look around the room", 0);
			btns[9].setClickFunc(doHunt);
			btns[11].setButton("Leave", "Stop looking for prey", 0);
			btns[11].setClickFunc(movePlayer);
		case 1:
			//Consume options
			txtPublic.visible = false;
			
			title = "Consume - Consumption Room";
			message += "You lead the " + roomNPC.name + " to the backroom, passing the bouncer at the back hall who makes a note on his clipboard as you walk past and handing you a key to one of the rooms. You lead your prey to the room marked on the key and unlock the door.</p><br><p>The room inside is setup like a cheap hotel room, a double bed is shoved into one corner most of the room is empty. Thin, abused carpet covers the floor, so badly discolored you can't even guess at what color it was originally. The bed has a basic set of sheets, also badly stained. The whole room has a faint, though not unpleasant, smell of cum.</p><br><p>The " + roomNPC.name + " follows you into the room, closing the door behind " + roomNPC.gender("obj").toLowerCase() + ". You run your eyes over your prey as " + roomNPC.gender("sub").toLowerCase() + " begins to disrobe.</p><br><p>";
			message += roomNPC.npcDesc();
			message += " " + roomNPC.gender("sub") + " stands near the middle of the room, waiting for you to make the first move.";
			
			newRoom = true;
			
			btns[0].setButton("Eat", "Your belly rumbles as you eye your prey.", 2);
			btns[0].setClickFunc(doHunt);
			if (playerCharacter.arousal >= 50 && globals.allowSex) {
				btns[2].setButton("Fuck", "You need to sate yourself, perhaps then you'll fill your belly.", 3);
				btns[2].setClickFunc(doHunt);
			}
			if (playerCharacter.hasPerk("cv") && playerCharacter.penis) {
				btns[3].setButton("CockVore", "Use your cock to consume your prey", 4);
				btns[3].disableButton();
				//btns[3].setClickFunc(doHunt);
			}
			if (playerCharacter.hasPerk("bv") && playerCharacter.breasts) {
				btns[4].setButton("BreastVore", "Use your breasts to consume your prey", 5);
				btns[4].disableButton();
				//btns[4].setClickFunc(doHunt);
			}
			if (playerCharacter.hasPerk("av")) {
				btns[5].setButton("AnalVore", "Use your ass to consume your prey", 6);
				btns[5].disableButton();
				//btns[5].setClickFunc(doHunt);
			}
			if (playerCharacter.hasPerk("ub") && playerCharacter.vagina) {
				btns[6].setButton("Unbirth", "Slide your prey into your vagina", 7);
				btns[6].disableButton();
				//btns[6].setClickFunc(doHunt);
			}
			
			btns[11].setButton("Leave", "You changed your mind, perhaps you'll seek other prey.", 10);
			btns[11].setClickFunc(movePlayer);
		case 2:
			//Do the eating
			title = "Consume - Consumption Room";
			message += "This room is setup like a cheap hotel room, a double bed is shoved into one corner most of the room is empty. Thin, abused carpet covers the floor, so badly discolored you can't even guess at what color it was originally. The bed has a basic set of sheets, also badly stained. The whole room has a faint, though not unpleasant, smell of cum.</p><br><p>";
			message += "You move to " + roomNPC.gender("obj").toLowerCase() + " and, with an anticipatory rumble from your belly, open your mouth and cover the " + roomNPC.name + "'s head. You lift " + roomNPC.gender("obj").toLowerCase() + " and swallow, forcing " + roomNPC.gender("pos").toLowerCase() + " body down your throat and into your belly. Several swallows later and you're alone in the room, just you and your swollen belly. </p><p>Your stomach rumbles happily.";
			
			playerCharacter.stomachContents.push(roomNPC);
			playerCharacter.stomachCurrent += roomNPC.mass;
			playerCharacter.numEaten++;
			playerCharacter.gluttony++;
			playerCharacter.arousal += 1;
			
			btns[11].setButton("Next", null, 10);
			btns[11].setClickFunc(movePlayer);
		case 3:
			//Sex
			title = "Consume - Consumption Room";
			message += "This room is setup like a cheap hotel room, a double bed is shoved into one corner most of the room is empty. Thin, abused carpet covers the floor, so badly discolored you can't even guess at what color it was originally. The bed has a basic set of sheets, also badly stained. The whole room has a faint, though not unpleasant, smell of cum.</p><br><p>";
			roomNPC.mass += Math.round(playerCharacter.cumCurrent);
			message += "{Placeholder} Sex, " + playerCharacter.cum("NPC");
			
			btns[0].setButton("Eat", "You've emptied yourself, now fill yourself back up.", 2);
			btns[0].setClickFunc(doHunt);
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
		var move:Bool = false;
		var moveTo:Int = 0;
		var consume:Bool = false;
		var sex:Bool = false;
		
		var message:String = "";
		var returnMessage:String = "";
		
		clearAllEvents();
		
		if (!talkInProgress) {
			//Inital screen
			talkInProgress = true;
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
			case "eat": //Consume the roomNPC
				consume = true;
			case "move": //Move the player to a new room
				move = true;
				moveTo = Std.parseInt(talkCommandArray[i].split(" ")[1]);
			case "sex": //Fuck the roomNPC
				sex = true;
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
					returnMessage += key.giveKey(playerCharacter);
				case "skip":
					//Skip to questSkip if questID.stage is greater then questValue
					if (playerCharacter.quest[questID].stage > questValue)
						clicked = questSkip;
				case "check":
					//Check playerCharacter.money agianst money if the player has less then money go to questSkip
					if (playerCharacter.getMoney() >= moneyChangeAmount) {
						playerCharacter.addMoney(-moneyChangeAmount);
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
		if (move) {
			globals.lastRoom = globals.currentRoomID;
			currentRoom = new MyRoom(globals.rooms[moveTo]);
			globals.currentRoomID = moveTo;
		}
		if (consume) {
			playerCharacter.stomachCurrent += roomNPC.mass;
			playerCharacter.stomachContents.push(roomNPC);
			playerCharacter.numEaten++;
		}
		if (sex) {
			playerCharacter.arousal = 0;
			if (playerCharacter.balls || playerCharacter.hasPerk("inbal")) {
				returnMessage += playerCharacter.cum("NPC");
				roomNPC.mass += Math.round(playerCharacter.cumCurrent);
				playerCharacter.cumCurrent = 0;
			}
		}
		
		message = roomNPC.talk[clicked][0];
		
		message += returnMessage;
		
		for (i in 0...roomNPC.talk[clicked][2].length) {
			btns[i].setButton(roomNPC.talk[clicked][2][i][0], roomNPC.talk[clicked][2][i][1], roomNPC.talk[clicked][2][i][2]);
			
			switch (roomNPC.talk[clicked][2][i][2]) {
			case -1:
				//Exit option
				btns[i].setClickFunc(movePlayer);
			case -2:
				playerDied = "bouncer";
				btns[i].setClickFunc(doDeath);
			case -7:
				QTEstage = 0;
				btns[i].setClickFunc(doQTE);
			case -8:
				btns[i].disableButton();
			default:
				btns[i].setClickFunc(doTalk);
			}
		}
		
		outputText(message, charName);
	}
	
	static function doQTE( ?e:MouseEvent ) {
		var message:String = "";
		var title:String = "Erik the Mighty";
		
		clearAllEvents();
		Lib.current.removeEventListener(KeyboardEvent.KEY_UP, timerKeyEvent);
		if (optionsBtn.visible) {
			optionsBtn.visible = false;
			charDesc.visible = false;
			if (globals.debugMode) {
				txtDebug.removeEventListener(MouseEvent.CLICK, debugMenu);
				txtDebug.visible = false;
			}
		}
		
		switch (QTEstage) {
		case 0:
			message = "<p>You make your decision and rush forward in an attempt to grab a hold of Erik. He somehow senses you moving towards him and evades your initial rush, his own hand swiping towards your head.</p>";
			
			timerQTE = new MyTimer(10, "s", 1, 2);
			Lib.current.addChild(timerQTE);
			Lib.current.addEventListener(KeyboardEvent.KEY_UP, timerKeyEvent);
			timerQTE.tmrQuick.addEventListener(TimerEvent.TIMER_COMPLETE, timerFailEvent);
		case 1:
			message = "<p>You quickly evade his sweeping hand and catch it, pinning his arm to his side. The motion is enough to knock the two of you over with you landing on top. His other, still free arm comes towards you fast.</p>";
			
			timerQTE = new MyTimer(9, "d", 3, 4);
			Lib.current.addChild(timerQTE);
			Lib.current.addEventListener(KeyboardEvent.KEY_UP, timerKeyEvent);
			timerQTE.tmrQuick.addEventListener(TimerEvent.TIMER_COMPLETE, timerFailEvent);
		case 2:
			message = "<p>You move to dodge the hand heading towards your head, but you're not quite fast enough. The huge hand closes around your head before you can evade it and he lifts you into the air, starting to squeeze tightly. Fortuitously, his lift brings your foot level with his crotch.</p>";
			
			timerQTE = new MyTimer(15, "a", 8, 9);
			Lib.current.addChild(timerQTE);
			Lib.current.addEventListener(KeyboardEvent.KEY_UP, timerKeyEvent);
			timerQTE.tmrQuick.addEventListener(TimerEvent.TIMER_COMPLETE, timerFailEvent);
		case 3:
			message = "<p>You dodge his second sweep, catching his arm and using your weight to pin him to the ground. He struggles under you, kicking with his legs as he attempts to get free. His strength is so great you can tell he will be free in moments.</p>";
			
			timerQTE = new MyTimer(11, "e", 5, 6);
			Lib.current.addChild(timerQTE);
			Lib.current.addEventListener(KeyboardEvent.KEY_UP, timerKeyEvent);
			timerQTE.tmrQuick.addEventListener(TimerEvent.TIMER_COMPLETE, timerFailEvent);
		case 4:
			message = "<p>You duck to avoid the second swing, but in doing so you release his other arm which he uses to grab you tightly about the waist. He lifts you and stands in one motion, showing off his power muscles as he holds you before him, one hand closing around your face as he starts to squeeze tightly. Fortuitously, his lift brings your foot level with his crotch.</p>";
			
			timerQTE = new MyTimer(11, "x", 8, 9);
			Lib.current.addChild(timerQTE);
			Lib.current.addEventListener(KeyboardEvent.KEY_UP, timerKeyEvent);
			timerQTE.tmrQuick.addEventListener(TimerEvent.TIMER_COMPLETE, timerFailEvent);
		case 5:
			//Eventually add in options to allow other forms of vore for this guy. Getting crammed into a cock would be a fitting end for him.
			message = "<p>With only moments before Erik manages to escape your grasp you lunge, mouth open as wide as you can and take his head into it. You begin to swallow powerfully, his neck and shoulders vanishing just as quickly down your throat. With his arms now pinned by your mouth you are able to slow down and take your time getting the rest of the huge man down. It's quite a challenge, his bulk paired with his struggling make you nearly loose him several times, but soon the giant jackass has been reduced to nothing more then a very large bulge in your stomach.</p><br><p>You sit on the ground for a moment, processing what just happened, slightly amazed that you managed to get him down. The struggles and kicks from your stomach slowly lessen and finally stop. Soon Erik the mighty will be nothing more then another layer on your mighty body. Once you think you can manage it, you stand, staggering from the sudden addition of weight in your front, and head home to sleep off your big meal.</p>";
			
			title = "Erik the Digested";
			
			playerCharacter.stomachContents.push(roomNPC);
			playerCharacter.stomachCurrent += roomNPC.mass;
			playerCharacter.numEaten++;
			playerCharacter.gluttony++;
			playerCharacter.arousal += 1;
			
			playerCharacter.quest[2].stage = 2; //Gold Membership is now avalible
			
			newRoom = true;
			
			btns[0].setButton("Next", null, 0, movePlayer);
		case 6:
			message = "<p>You struggle, trying to get him pinned enough to force him down your throat. Unfortunately his struggles prove too much for you and he kicks you off him. By the time you regain your feet he is rushing towards you, murder in his eyes.</p>";
			
			timerQTE = new MyTimer(6, "w", 11, 12);
			Lib.current.addChild(timerQTE);
			Lib.current.addEventListener(KeyboardEvent.KEY_UP, timerKeyEvent);
			timerQTE.tmrQuick.addEventListener(TimerEvent.TIMER_COMPLETE, timerFailEvent);
		case 7:
			//Legecy option
		case 8:
			message = "<p>You swing your foot back and throw it forward with all your might. The strike landing square in his massively swollen cock. He bellows in pain and drops and you take the chance to pin his arms to his sides and hold him down. He recovers quickly and starts struggling under you, his strength such that he will be free in moments.</p>";
			
			timerQTE = new MyTimer(11, "e", 5, 6);
			Lib.current.addChild(timerQTE);
			Lib.current.addEventListener(KeyboardEvent.KEY_UP, timerKeyEvent);
			timerQTE.tmrQuick.addEventListener(TimerEvent.TIMER_COMPLETE, timerFailEvent);
		case 9:
			message = "<p>You swing your foot towards his crotch, but he moves at the last moment and you miss, only striking his thigh. He grunts in pain but tightens his grip on you as everything starts to go black. A low growl comes from him and the last thing you hear is something important in your head crack.</p>";
			
			playerDied = "Erik";
			
			btns[9].setButton("Next", null, null, doDeath);
		case 10:
			//Legecy option
		case 11:
			message = "<p>Thinking fast you rush forward, leaping to catch him in your open mouth just before he would have hit you. The speed of his rush pushes you back against the far wall, but also shoves him down your throat to his waist. You are able to swallow his struggling lower half quickly, his continuing struggles nearly causing you to loose him several times, but soon the giant jackass has been reduced to nothing more then a very large bulge in your stomach.</p><br><p>You sit on the ground for a moment, processing what just happened, slightly amazed that you managed to get him down. The struggles and kicks from your stomach slowly lessen and finally stop. Soon Erik the mighty will be nothing more then another layer on your mighty body. Once you think you can manage it, you stand, staggering from the sudden addition of weight in your front, and head home to sleep off your big meal.</p>";
			
			title = "Erik the Digested";
			
			playerCharacter.stomachContents.push(roomNPC);
			playerCharacter.stomachCurrent += roomNPC.mass;
			playerCharacter.numEaten++;
			playerCharacter.gluttony++;
			playerCharacter.arousal += 1;
			
			playerCharacter.quest[2].stage = 2; //Gold Membership is now avalible
			
			newRoom = true;
			
			btns[0].setButton("Next", null, 0, movePlayer);
		case 12:
			message = "<p>You dodge to the side, only to find your path blocked by one of the large machines in the room. Your struggles have gotten you trapped and Erik hits you like a linebacker, shoulder to your chest. You feel something break as he slams you into the far wall. The roundhouse punch that follows is almost overkill, but it does bring on the black that much faster.</p>";
			
			playerDied = "Erik";
			
			btns[9].setButton("Next", null, null, doDeath);
		default:
			new AlertBox("QuickTime Event Failure, Unknown QTE Stage; " + QTEstage + ".");
		}
		
		outputText(message, title);
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
						if (i == playerCharacter.bowelsContents.length - 1) {
							poopScene += " and a ";
						} else {
							poopScene += ", a ";
						}
						
						poopScene += playerCharacter.bowelsContents[i].name;
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
				//btns[0].setClickFunc(doPoop);
				
				btns[11].setButton("Finish");
				btns[11].setClickFunc(movePlayer);
			case 1:
				//Item screen
				
			}
		} else {
			//Scat off
			title = "Restroom";
			message = "You make use of the facilities. You feel much better after.";
			
			updateHUD();
			
			newRoom = false;
			
			btns[11].setButton("Next");
			btns[11].setClickFunc(movePlayer);
		}
		
		outputText(message, title);
	}
	
	static function doSleep( e:MouseEvent ) {
		
		outputText("Sleep", "Sleep");
	}
	
	static function doMasterbate( e:MouseEvent ) {
		//Player jerks off
		var message:String = "{Placeholder} ";
		
		//Player has only a penis
		if (playerCharacter.penis && !playerCharacter.vagina) {
			message += "You wrap your hand around your shaft and begin slowly stroking along your length. ";
			if (playerCharacter.balls) {
				message += "Your other hand cups your balls and you tease your length, toying with your head until you feel your orgasm building. With a surge you shoot cum from your cock.";
			} else {
				message += "You stroke along your length, toyin with the head of your cock until you feel your orgasm building.";
				if (playerCharacter.hasPerk("inbal")) {
					message += " With a surge you shoot cum from your cock.";
				}
			}
		}
		
		//Player has only a vagina
		if (!playerCharacter.penis && playerCharacter.vagina) {
			message += "You slide a finger inside your slit finding your clit and teasing it until you orgasm.";
		}
		
		//Player has both a vagina and penis
		if (playerCharacter.penis && playerCharacter.vagina) {
			message += "You wrap one hand around your cock and slide the other into your vagina teasing both until you shutter and cum hard.";
		}
		
		//Player has neither a vagina or a penis
		if (!playerCharacter.penis && !playerCharacter.vagina) {
			if (playerCharacter.breasts) {
				message += "You cup your breasts and massage them, teasing your nipples until you drive yourself to orgasm.";
			} else {
				message += "You slide a finder into your ass, teasing and toying with your prostate until you manage to acheive something close to an orgasm.";
			}
		}
		
		playerCharacter.arousal = 0;
		
		charDesc.visible = false;
		optionsBtn.visible = false;
		newRoom = false;
		
		clearAllEvents();
		updateHUD();
		outputText(message, "Masterbation");
		
		btns[0].setButton("Next", null, null, movePlayer);
	}
	
	static function doPhone( e:MouseEvent ) {
		var clicked:Dynamic = e.currentTarget.btnID;
		var callList:String = "";
		var phoneNames:Array<Dynamic> = [["Pizza", "Down the Street Pizza - Close enough", "Call the closest pizza place, it's in the next town over, to get one delivered."], ["Hooker", "Rebecca's Girls - Catering to all tastes and pleasures", "Call up a hooker, you know you want to."]];
		var message:String = "";
		var action:String = "";
		var value:Int = -1;
		var split:Array<String> = new Array();
		
		clearAllEvents();
		
		newRoom = false;
		
		if (Type.typeof(clicked) == ValueType.TInt) {
			switch (clicked) {
			case 0:
				for (i in 0...playerCharacter.unlockedPhoneNumbers.length) {
					if (playerCharacter.unlockedPhoneNumbers[i]) {
						callList += "<li>" + phoneNames[i][1] + "</li>";
						btns[i].setButton(phoneNames[i][0], phoneNames[i][2], "call:" + i);
						if (i == 0) {
							btns[i].setClickFunc(doPhone);
						} else {
							btns[i].disableButton();
						}
					}
				}
				
				message = "A basic phone attached to the wall. Who do you want to call?</p><br>" + callList;
			}
		} else {
			split = clicked.split(":");
			action = split[0];
			value = Std.parseInt(split[1]);
			
			switch (action) {
			case "call":
				switch (value) {
				case 0: //Pizza
					//First make sure the player hasn't been eating all of the pizza place's drivers. They do run out you know
					if (playerCharacter.deliveryDriversEaten >= 51 && playerCharacter.deliveryDriversEaten < 100) {
						// the pizza place has told the player no already
						message = "You call up the pizza place, but before you can order the girl on the other end says, in a rather annoyed voice, &quot;Look, we already told you we're not deilvering to you anymore. Stop calling.&quot; And then she hangs up.";
						
						playerCharacter.deliveryDriversEaten++; // becuase I know players will keep calling.
						
						btns[11].setButton("Hang up");
						btns[11].setClickFunc(movePlayer);
						return;
					}
					if (playerCharacter.deliveryDriversEaten == 50) {
						// The player has eaten too many of thier delivery drivers, the pizza place won't deliver anymore.
						message = "You call up the pizza place, but before you can order the girl on the other end says, &quot;The owner has told me to tell you that we won't be delivering any more to your address. Too many of our drivers haven't come back.&quot; She then hangs up.";
						
						playerCharacter.deliveryDriversEaten++; // add one more so the pizza place will remember they've told the player off already
						
						btns[11].setButton("Hang up");
						btns[11].setClickFunc(movePlayer);
						return;
					}
					if (playerCharacter.deliveryDriversEaten >= 200) {
						// Now they're trolling me
						message = "Look, they're not going to bring you anymore pizza.";
						
						btns[11].setButton("Okay");
						btns[11].setClickFunc(movePlayer);
						return;
					}
					if (playerCharacter.deliveryDriversEaten >= 100) {
						//Now the player is just trolling.
						message = "You dial the pizza place, it rings several times then clicks and the line goes dead. Seems they don't even want to talk to you now.";
						
						playerCharacter.deliveryDriversEaten++;
						
						btns[11].setButton("Hang up");
						btns[11].setClickFunc(movePlayer);
						return;
					}
					
					message = "You call up the pizza place, the person on the other end asks what you'd like;</p><br><li>Small: $5</li><li>Medium: $10</li><li>Large: $15</li><li>XLarge: $20</li><li>Fatass Special: $40</li>";
					
					btns[0].setButton("Small", null, "order|0");
					btns[0].setClickFunc(doPizza);
					btns[1].setButton("Medium", null, "order|1");
					btns[1].setClickFunc(doPizza);
					btns[2].setButton("Large", null, "order|2");
					btns[2].setClickFunc(doPizza);
					btns[3].setButton("XLarge", null, "order|3");
					btns[3].setClickFunc(doPizza);
					btns[4].setButton("Fatass", null, "order|4");
					btns[4].setClickFunc(doPizza);
					
					btns[11].setButton("Nothing");
					btns[11].setClickFunc(movePlayer);
				case 1: //Hookers
					
				default:
					new AlertBox("Bad switch action: " + action + ":" + value);
				}
			}
		}
		
		outputText(message, "Phone");
	}
	
	static function doPizza( e:MouseEvent ) {
		var clicked:String = e.currentTarget.btnID;
		var action:String = "";
		var pizzaSize:Int = -1;
		var split:Array<String> = new Array();
		var pizzaCost:Float = 0;
		var pizzaCostDeliv:Float = 0;
		var pizzaMass:Int = 0;
		var message:String = "";
		
		clearAllEvents();
		newRoom = false;
		
		split = clicked.split("|");
		action = split[0];
		pizzaSize = Std.parseInt(split[1]);
		pizzaCostDeliv = Std.parseFloat(split[2]);
		
		switch (action) {
		case "order":
			roomNPC = new MyNPC();
			roomNPC.randomNPC(species, playerCharacter, playerCharacter.pointsSpent);
			
			switch (pizzaSize) {
			case 0:
				pizzaCost = 5;
				pizzaMass = 5;
			case 1:
				pizzaCost = 10;
				pizzaMass = 10;
			case 2:
				pizzaCost = 15;
				pizzaMass = 20;
			case 3:
				pizzaCost = 20;
				pizzaMass = 40;
			case 4:
				pizzaCost = 40;
				pizzaMass = 80;
			default:
				new AlertBox("Bad pizzaSize: " + pizzaSize);
			}
			
			pizzaCost += (pizzaCost * .02); //Delivery charge
			
			pizzaCostDeliv = Std.parseFloat(truncateDecimalPlaces(pizzaCost));
			
			message = "About 30 minutes later there's a knock at your door. When you open it, you find a [NPCNAME] wearing the dark gray uniform of the pizza place. [SUBJC] checks the receipt, &quot;That'll be $" + pizzaCostDeliv + "&quot;";
			
			btns[0].setButton("No Tip", "Pay, but don't tip.", "notip|" + pizzaMass + "|" + pizzaCostDeliv);
			btns[0].setClickFunc(doPizza);
			btns[1].setButton("Tip", "Pay and include a tip.", "tip|" + pizzaMass + "|" + pizzaCostDeliv);
			btns[1].setClickFunc(doPizza);
			btns[2].setButton("Eat", "Gotta love the modern world, fresh food delivered to your door. And they even bring pizza!", "eat|" + pizzaMass + "|" + pizzaCostDeliv);
			btns[2].setClickFunc(doPizza);
			
			btns[3].setButton("Fuck", "Invite the driver in for a slice and a fuck.", "fuck|" + pizzaMass + "|" + pizzaCostDeliv);
			btns[3].disableButton();
			//btns[3].setClickFunc(doPizza);
			btns[4].setButton("Fuck and eat", "Invite the driver in and feed them the pizza. Then enjoy your pizza.", "fuckeat|" + pizzaMass + "|" + pizzaCostDeliv);
			btns[4].disableButton();
			//btns[4].setClickFunc(doPizza);
		case "notip":
			//Pay but don't tip the driver
			pizzaMass = pizzaSize; //For readability
			
			//Money check
			if (playerCharacter.getMoney() >= pizzaCostDeliv) {
				message = "You hand the [NPCNAME] $" + pizzaCostDeliv + ". [SUBJC] looks at the money and gives you an indignant look, then turns and walks off without another word, leaving you with a steaming hot pizza. You go back into your apartment and set about devouring the pizza. You make short work of it, belly full of food and burp happily.";
				playerCharacter.addMoney(-pizzaCostDeliv);
				playerCharacter.stomachCurrent += pizzaMass;
				
				updateHUD();
				
				btns[11].setButton("Next");
				btns[11].setClickFunc(movePlayer);
			}
		case "tip":
			//Pay and tip the driver
			pizzaMass = pizzaSize; //For readability
			
			pizzaCostDeliv += pizzaCostDeliv * .3;
			
			pizzaCostDeliv = Std.parseFloat(truncateDecimalPlaces(pizzaCostDeliv));
			
			if (playerCharacter.getMoney() < pizzaCostDeliv) {
				// player doesn't have enough money to pay for the pizza. Only two options left
				message = "You check your wallet to pay for the pizza, but you find you don't have enough money! Now what?";
				
				btns[0].setButton("Eat", "No money, but so hungry. Only one solution...", "eat|" + pizzaMass + "|" + pizzaCostDeliv);
				btns[0].setClickFunc(doPizza);
				btns[2].setButton("Can't Pay", "Sorry, I can't pay.", "nopay|" + pizzaMass + "|0");
				btns[2].setClickFunc(doPizza);
			} else {
				// player has money, time to buy the pizza!
				message = "You hand the [NPCNAME] $" + pizzaCostDeliv + ". [SUBJC] glances at the money and tucks it away, giving you a smile and saying &quot;Enjoy your pizza.&quot; Before turning and walking away down the hall.";
				
				playerCharacter.addMoney(-pizzaCostDeliv);
				playerCharacter.stomachCurrent += pizzaMass;
				
				updateHUD();
				
				btns[11].setButton("Next");
				btns[11].setClickFunc(movePlayer);
			}
		case "eat":
			//Eat the pizza and the driver
			pizzaMass = pizzaSize; //For readability
			
			var eatScenes:Array<String> = new Array();
			
			eatScenes.push("You smile and make as if to take the pizza from the [NPCNAME] but instead you grab [OBJ] and pull [OBJ] into your apartment, shutting the door after. [SUBJC] protests and struggles but you don't let [OBJ] go. Once inside with the door closed, you open your jaws and lunge forward, grabbing the [NPCNAME] around the waist and getting [POS] head and shoulders down your throat before [SUBJ] has a chance to cry out. You push [OBJ] further down, swallowing eagerly as your belly stretches with your new meal. It isn't long before you're down to the last swallow, the delivery driver vanishing into your gut. You rub your stomach happily, then remember the pizza. Might as well have desert too.");
			eatScenes.push("While getting your money together you hear the [NPCNAME]'s stomach rumble and an idea hits you. You ask if [SUBJ] would like to share your pizza. After some awkward fidgeting [SUBJ] nods and follows you into your apartment. The first few slices [SUBJ] eats without issues, after that it takes some cajoling to get [OBJ] to eat more. Soon only one slice remains, the stuffed [NPCNAME] refuses so you insist. Finally you give up, having the slice yourself.</p><br><p>You finish it off and eye the stuffed [NPCNAME] sitting in a stupor on your couch. Stomach stretched out over [POS] lap. Your stomach rumbles, reminding you why you ordered a pizza in the first place. Starting at the stuffed [NPCNAME]'s feet you make it to [POS] hips before [SUBJ] notices. However it isn't until you made it over [POS] stomach that [SUBJ] is finally aware of what's happening and begins to thrash and struggle. By then it's too late and even [POS] flailing arms don't stop you from swallowing the last of [OBJ]. Your stomach stretching out even fuller.");
			
			var rndMessage = Math.round(Math.random() * (eatScenes.length - 1));
			
			if (rndMessage > eatScenes.length - 1) {
				message = "Missing scene, case #" + rndMessage;
			} else {
				message = eatScenes[rndMessage];
			}
			
			playerCharacter.deliveryDriversEaten++;
			
			playerCharacter.stomachCurrent += pizzaMass + roomNPC.mass;
			playerCharacter.stomachContents.push(roomNPC);
			playerCharacter.numEaten++;
			
			btns[11].setButton("Next");
			btns[11].setClickFunc(movePlayer);
		case "fuck":
			//Screw the driver, eat the pizza
			pizzaMass = pizzaSize; //For readability
			
			message = "You smile as the [NPCNAME] hands you your pizza. You set it aside and smile, then ask if [SUBJ] would like to join you for a slice. [SUBJC] wavers for a moment then comes to a decision and steps into your apartment. You open the box and the two of you dig into the pizza. As your stomach fills your arousal grows and you notice [SUBJ] is eyeing you the same as you are [OBJ].";
			
			//Need to finish writing these eventually
			switch (playerCharacter.gender("gender")) {
			case "Female":
				// player is female
				message += "</p><br>{Scene missing}";
			case "Male":
				//player is male
				message += "</p><br>{Scene missing}";
			case "Herm":
				//player is herm
				message += "</p><br>{Scene missing}";
			case "Dickgirl":
				//player is dickgirl
				message += "</p><br>{Scene missing}";
			case "Doll":
				//player is doll
				message += "</p><br>{Scene missing}";
			case "Cuntboy":
				//player is cuntboy
				message += "</p><br>{Scene missing}";
			case "Neuter":
				//player is neuter
				message += "</p><br>{Scene missing}";
			default:
				new AlertBox("ERROR: Bad player gender string: " + playerCharacter.gender("gender"));
			}
			
			
			
			btns[11].setButton("Next");
			btns[11].setClickFunc(movePlayer);
			
		case "fuckeat":
			//screw the driver, eat the pizza and the driver
			pizzaMass = pizzaSize; //For readability
			
		default:
			new AlertBox("Bad order action: " + action);
		}
		
		outputText(message, "Pizza Delivery");
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
			message += "You are wearing " + playerCharacter.equipArmObj.name + " as armor and have " + playerCharacter.equipWepObj.name + " ready to defend yourself with.</p><br><p>";
			message += "You have eaten " + playerCharacter.numEaten + " prey.";
			
			btns[0].setButton("Inventory", "View your inventory", "page|0");
			btns[0].setClickFunc(doInventory);
			
			btns[1].setButton("Keys", "View your keys", 2);
			btns[1].setClickFunc(doDescription);
			
			btns[2].setButton("Prey", "See what you've consumed", 3);
			btns[2].setClickFunc(doDescription);
			
			btns[3].setButton("Quests", "View your active quests", 4);
			btns[3].setClickFunc(doDescription);
			
			btns[11].setButton("Back", "Back to the game");
			btns[11].setClickFunc(movePlayer);
			
		case 1:
			//Player invintory, old code. Ignore
			
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
			btns[11].setClickFunc(doDescription);
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
							message += " and masturbating";
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
			if (playerCharacter.balls || playerCharacter.hasPerk("inBal")) {
			if (playerCharacter.ballContents.length != 0) {
				message += "Balls:";
				for (i in 0...playerCharacter.ballContents.length) {
					message += "<br>A " + playerCharacter.ballContents[i].name + " is ";
					if (playerCharacter.ballContents[i].healthCurr > 0) {
						message += "alive";
						if (playerCharacter.ballContents[i].likeVore) {
							message += " and masturbating";
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
			}
			
			btns[11].setButton("Back", null, 0);
			btns[11].setClickFunc(doDescription);
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
			btns[11].setClickFunc(doDescription);
		}
		
		outputText(message, title);
	}
	
	static function doInventory( e:MouseEvent ) {
		var title:String = "Inventory";
		var message:String = "You quickly check your pockets and find:<br>";
		var choice:String = e.currentTarget.btnID;
		var dspItems:Int = 9;
		var dspFirstItem:Int = 0;
		
		var choiceType:String = choice.split("|")[0];
		var choiceValue:Int = Std.parseInt(choice.split("|")[1]);
		
		var specialSkill:String = "";
		var specialValue:String = "";
		
		clearAllEvents();
		
		switch(choiceType) {
		case "page":
			//The player is just looking at their invintory list
			
			if (playerCharacter.invObject.length > 9) {
				dspFirstItem = choiceValue * 9;
				dspItems = dspFirstItem + 9;
			}
			
			if (playerCharacter.invObject.length < dspItems)
				dspItems = playerCharacter.invObject.length;
			
			if (playerCharacter.invObject.length != 0) {
				for (i in dspFirstItem...dspItems) {
					message += playerCharacter.invObject[i].name + " --- " + playerCharacter.invObject[i].desc + "<br>";
					btns[i - dspFirstItem].setButton(playerCharacter.invObject[i].name, null, "item|" + i);
					btns[i - dspFirstItem].setClickFunc(doInventory);
				}
				if (playerCharacter.invObject.length > dspItems) {
					message += "More...<br>";
					btns[10].setButton("Next", null, "page|" + (choiceValue + 1));
					btns[10].setClickFunc(doInventory);
				}
				if (dspFirstItem != 0) {
					btns[9].setButton("Prev", null, "page|" + (choiceValue - 1));
					btns[9].setClickFunc(doInventory);
				}
			} else {
				message += "Nothing!<br>";
			}
			
			
		case "item":
			//display item details
			title += " -- Item Detail";
			
			message += "Name: " + playerCharacter.invObject[choiceValue].name + "<br>";
			message += "Type: " + playerCharacter.invObject[choiceValue].type + "<br>";
			message += "Mass: " + playerCharacter.invObject[choiceValue].mass + " ";
			message += "Value: " + playerCharacter.invObject[choiceValue].value + "<br>";
			message += playerCharacter.invObject[choiceValue].desc + "<br>";
			
			switch (playerCharacter.invObject[choiceValue].type) {
			case "weapon":
				message += "Attack: " + playerCharacter.invObject[choiceValue].attack + " ";
				if (playerCharacter.invObject[choiceValue].twoHanded) {
					message += "2H";
				} else {
					message += "1H";
				}
				
				message += "<br>Special Qualities:<br>";
				
				btns[0].setButton("Equip", "Ready the weapon", "equip|" + choiceValue);
				btns[0].setClickFunc(doInventory);
			case "armor":
				message += "Defense: " + playerCharacter.invObject[choiceValue].defend + ".<br>";
				message += "Special Qualities:<br>";
				
				btns[0].setButton("Equip", "Don the armor", "equip|" + choiceValue);
				btns[0].setClickFunc(doInventory);
			case "ring":
				message += "Special Qualities:<br>";
				
				btns[0].setButton("Equip", "Equip the ring", "equip|" + choiceValue);
				btns[0].setClickFunc(doInventory);
			case "food":
				message += "Quantity: " + playerCharacter.invObject[choiceValue].count;
			}
			
			for (i in 0...playerCharacter.invObject[choiceValue].specials.length) {
				specialSkill = playerCharacter.invObject[choiceValue].specials[i].split("|")[0];
				specialValue = playerCharacter.invObject[choiceValue].specials[i].split("|")[1];
				switch(specialSkill) {
				case "str":
					message += "Strength +" + specialValue;
				case "agi":
					message += "Agility +" + specialValue;
				case "end":
					message += "Endurance +" + specialValue;
				case "int":
					message += "Intelligence +" + specialValue;
				case "health":
					message += "Health +" + specialValue;
				case "spot":
					message += "Spot +" + specialValue;
				case "dodge":
					message += "Dodge +" + specialValue;
				case "run":
					message += "Run +" + specialValue;
				case "melee":
					message += "Melee +" + specialValue;
				case "sneak":
					message += "Sneak +" + specialValue;
				}
				if (i < playerCharacter.invObject[choiceValue].specials.length - 1)
					message += ", ";
			}
			
			btns[1].setButton("Consume", "Consume the item", "eat|" + choiceValue);
			btns[1].setClickFunc(doInventory);
			btns[2].setButton("Drop", "Discard the item", "drop|" + choiceValue);
			btns[2].setClickFunc(doInventory);
			
			btns[9].setButton("Close", "Close the item description", "page|0");
			btns[9].setClickFunc(doInventory);
		case "equip":
			message = playerCharacter.invObject[choiceValue].equip(playerCharacter);
			
			updateHUD();
			outputText(message);
			
			btns[0].setButton("Next", null, "page|0");
			btns[0].setClickFunc(doInventory);
			return;
		case "eat":
			message = playerCharacter.invObject[choiceValue].eat(playerCharacter);
			
			updateHUD();
			outputText(message);
			
			btns[0].setButton("Next", null, "page|0");
			btns[0].setClickFunc(doInventory);
			return;
		case "drop":
			message = playerCharacter.invObject[choiceValue].toss(playerCharacter);
			
			updateHUD();
			outputText(message);
			
			btns[0].setButton("Next", null, "page|0");
			btns[0].setClickFunc(doInventory);
			return;
		}
		
		btns[11].setButton("Description", null, 0);
		btns[11].setClickFunc(doDescription);
		
		outputText(message, title);
	}
	
	static function iceCreamShop( e:MouseEvent ) {
		var message:String = "";
		var title:String = "Ice Cream Shop - ";
		var action:String = e.currentTarget.btnID.split("|")[0];
		var value:String = e.currentTarget.btnID.split("|")[1];
		var page:String = "0";
		var price:Int = 0;
		var flavor:String = "";
		var eat:String = "";
		var foodMass:Int = 5;
		
		clearAllEvents();
		updateHUD();
		
		if (optionsBtn.visible) {
			optionsBtn.visible = false;
			charDesc.visible = false;
			newRoom = false;
		}
		
		switch (action) {
		case "list":
			//List the ice cream choices for the player to buy
			message += "<p>You step up to the counter, ";
			
			if (((playerCharacter.hour >= 8 && playerCharacter.hour < 14) || playerCharacter.quest[5].stage >= 6) && playerCharacter.quest[7].stage < 2) {
				//Guffin works the 8am-2pm shift, unless he's been eaten or Bessie is tied up in the back
				roomNPC = new MyNPC();
				roomNPC.newNPC(nonPlayerCharacters[3]);
				
				message += "Guffin smiles and says, &quot;O-oh, uh, what would you like? T-theres a lot to choose from.&quot;";
			} else if (((playerCharacter.hour >= 14 && playerCharacter.hour < 20) || (playerCharacter.quest[7].stage == 2)) && playerCharacter.quest[5].stage < 6) {
				//Bessie works the 2pm-8pm shift, unless Guffin has been eaten or she's tied up in the back room
				roomNPC = new MyNPC();
				roomNPC.newNPC(nonPlayerCharacters[4]);
				
				message += "Bessie scowls at you. &quot;Buy something already.&quot;";
			}
			
			message += "</p><br><p>";
			
			switch (value) {
			case "0":
				message += "&nbsp;&nbsp;&nbsp;Vanilla, $2<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Ah, the classic vanilla flavor.<br>&nbsp;&nbsp;&nbsp;Chocolate, $2<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Tastes just like… Chocolate.<br>&nbsp;&nbsp;&nbsp;Strawberry, $2<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;There are real strawberry bits inside!<br>&nbsp;&nbsp;&nbsp;Caramel, $2<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;With veins of pure caramel within, it must be hard to resist.<br>&nbsp;&nbsp;&nbsp;Blue Bubblegum, $4<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;The color pink was taken, so bubblegum will just settle on blue.<br>&nbsp;&nbsp;&nbsp;Cookies & Cream, $5<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;It even has bits of cookies mashed in!<br>";
				message += "&nbsp;&nbsp;&nbsp;Neapolitan Blast, $5<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Couldn’t decide? Have some vanilla, chocolate, AND strawberry!<br>&nbsp;&nbsp;&nbsp;Peanut Butter, $4<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;You could almost swear it’s literally a tub of peanut butter, just frozen.<br>&nbsp;&nbsp;&nbsp;Quadruple Chocolate, $5<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Its chocolate, times 4, with chocolate pieces!";
				message += "</p><br><p>More...</p>";
				
				btns[0].setButton("Vanilla", "Classic Vanilla", "buy|vanilla", iceCreamShop);
				btns[1].setButton("Chocolate", "Tasty Chocolate", "buy|chocolate", iceCreamShop);
				btns[2].setButton("Strawberry", "With Real Strawberries!", "buy|strawberry", iceCreamShop);
				btns[3].setButton("Caramel", "Classic Vanilla with pure caramel mixed in", "buy|caramel", iceCreamShop);
				btns[4].setButton("Bubblegum", "Blue bubblegum; strange, but tasty", "buy|bubblegum", iceCreamShop);
				btns[5].setButton("Cookies & Cream", "With bits of real cookie!", "buy|c&c", iceCreamShop);
				btns[6].setButton("Neapolitan", "All three classic choices", "buy|neap", iceCreamShop);
				btns[7].setButton("Peanut Butter", "Still looks like a tub of peanut butter", "buy|peanut", iceCreamShop);
				btns[8].setButton("4x Chocolate", "Chocolate, only more", "buy|4choc", iceCreamShop);
				
				btns[11].setButton("More", null, "list|1", iceCreamShop);
			case "1":
				message += "<br>&nbsp;&nbsp;&nbsp;Banana Split, $4<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;A banana, cut in half, with some ice cream and whipped cream, topped with a cherry!<br>&nbsp;&nbsp;&nbsp;Milkshake, $3<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Milk and ice cream and syrup, shaken up in a tall cup. Comes in multiple flavors!<br>&nbsp;&nbsp;&nbsp;Glutton’s Delight, $15<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;The sweetest of the sweets, a bit of every flavor put into one huge tub.";
				
				btns[0].setButton("Banana Split", "Banana and ice cream", "buy|split", iceCreamShop);
				btns[1].setButton("Milkshake", "Milk and ice cream", "shake|list", iceCreamShop);
				btns[1].disableButton();
				btns[2].setButton("Glutton", "A little of everything", "buy|glutton", iceCreamShop);
				
				btns[9].setButton("Prev", null, "list|0", iceCreamShop);
			}
			
			
			title += "Buy";
		case "free":
			//List the ice cream choices for the player to eat
			
		case "buy":
			//First screen of buy
			message += "<p>Buy ";
			
			switch (value) {
			case "vanilla":
				price = 2;
				message += "vanilla";
			case "chocolate":
				price = 2;
				message += "chocolate";
			case "strawberry":
				price = 2;
				message += "strawberry";
			case "caramel":
				price = 2;
				message += "caramel";
			case "bubblegum":
				price = 4;
				message += "blue bubblegum";
			case "c&c":
				price = 5;
				message += "cookies and cream";
			case "neap":
				price = 5;
				message += "neapolitan";
			case "peanut":
				price = 4;
				message += "peanut butter";
			case "4choc":
				price = 5;
				message += "quadruple chocolate";
			case "split":
				price = 4;
				message += "a banana split";
				page = "1";
			case "glutton":
				price = 15;
				message += "glutton's delight";
				page = "1";
			}
			
			message += "? For $" + price + "</p>";
			
			btns[0].setButton("Yes", null, "confirm|" + value, iceCreamShop);
			if (playerCharacter.getMoney() < price) 
				btns[0].disableButton();
			btns[2].setButton("No", null, "list|" + page, iceCreamShop);
		case "confirm":
			eat = "You take a seat and a spoon and prepare to eat out of your tub of ";
			
			switch (value) {
			case "vanilla":
				price = 2;
				flavor = "vanilla";
				eat += "vanilla ice cream.</p><br><p>With each spoonful, you savor the sweet, vanilla taste. It’s the closest you can get to vanilla perfection.";
			case "chocolate":
				price = 2;
				flavor = "chocolate";
				eat += "chocolate ice cream.</p><br><p>It feels thick and creamy, as you shovel it into your mouth. It’s really, great, shame they didn’t give you the recipe for it.";
			case "strawberry":
				price = 2;
				flavor = "strawberry";
				eat += "strawberry ice cream.</p><br><p>The ice cream fills your taste buds with a soft, light taste that is strawberry. As you eat, you come along small chunks, which when you bite into them, are juicy and sweet.";
			case "caramel":
				price = 2;
				flavor = "caramel";
				eat += "caramel ice cream.</p><br><p>It tends to be a rather rich, nutty flavor; ironic considering it's made by burning sugar and milk together. If you were blindfolded, you could not mistake this taste for anything else.";
			case "bubblegum":
				price = 4;
				flavor = "blue bubblegum";
				eat += "Blue Bubblegum ice cream.</p><br><p>As one of the sweetest things on the menu, the sweetness is immense. It probably has a huge amount of sugar in it, but the more the better. Your tongue is a bright blue now.";
			case "c&c":
				price = 5;
				flavor = "cookies and cream";
				eat += "cookies & cream ice cream.</p><br><p>Surprisingly smooth, even with the chunks of cookies within. The creamy texture really makes it live up to its name.";
			case "neap":
				price = 5;
				flavor = "neapolitan";
				eat += "Neapolitan blast ice cream.</p><br><p>You could almost say that it doesn’t get any better than this. Vanilla, chocolate and strawberry all in one tub. Three different tastes that all melt in your mouth at once, creating a sweet, creamy blend.";
			case "peanut":
				price = 4;
				flavor = "peanut butter";
				eat += "peanut butter ice cream.</p><br><p>You don’t remember this ice cream from when you worked here, so they must have gotten it in since you left. It’s really strong, with small lumps of the actual peanuts. If it wasn't cold, you would be able to say it were just straight up peanut butter.";
			case "4choc":
				price = 5;
				flavor = "quadruple chocolate";
				eat += "quadruple chocolate ice cream.</p><br><p>This ice cream is so thick, it feels like someone had sex in your mouth, leaving their cold chocolate love in your mouth. Plus, there's chocolate chips, which are nice too.";
			case "split":
				price = 4;
				foodMass = 7;
				flavor = "a banana split";
				page = "1";
			case "glutton":
				price = 15;
				foodMass = 40;
				flavor = "glutton's delight";
				page = "1";
				if (roomNPC != null) {
					if (roomNPC.name == "Guffin") {
						eat = "You take a seat and a spoon and prepare to eat out of your enormous tub of Glutton’s Delight ice cream.</p><br><p>This tub has a scoop from every flavor in the shop. The amount of ice cream that fills it is about as big as your head. You can see Guffin look at you with a bit of envy from the counter, wishing he could eat that much for free on one occasion and not get in trouble for it. He watches you eat, getting more envious with every spoonful.";
					} else {
						eat = "You take a seat and a spoon and prepare to eat out of your enormous tub of Glutton’s Delight ice cream.</p><br><p>This tub has a scoop from every flavor in the shop. The amount of ice cream that fills it is about as big as your head. You can see Bessie watch you empty the tub from behind the counter, a curious look on her face. You can't decide if it's envy or anger.";
					}
				}
			}
			
			if (roomNPC != null) {
				if (roomNPC.name == "Guffin") {
					message = "You pass over $" + price + " to Guffin, and he passes over your " + flavor + " ice cream.</p><br><p>" + eat + "</p><br><p>Once you’re done, you feel a little bit fuller.";
				} else {
					message = "You pass over $" + price + " to Bessie, and she passes over your " + flavor + " ice cream.</p><br><p>" + eat + "</p><br><p>Once you’re done, you feel a little bit fuller.";
				}
			}
			
			message += "</p>";
			
			playerCharacter.stomachCurrent += foodMass;
			playerCharacter.addMoney( -price);
			updateHUD();
		case "shake":
			
		}
		
		btns[10].setButton("Leave", "Step away from the counter", null, movePlayer);
		outputText(message, title);
	}
	
	static function doShop( e:MouseEvent ) {
		// rat - black market
		// gen - general store
		
		var shopAction:String = e.currentTarget.btnID.split("|")[1];
		var shopType:String = e.currentTarget.btnID.split("|")[0];
		var shopActionValue:Int = Std.parseInt(e.currentTarget.btnID.split("|")[2]);
		var canSell:Bool = false;
		var message:String = "";
		var title:String = "";
		
		var dspItems:Int = 9;
		var dspFirstItem:Int = 0;
		
		var tempItem:MyItem = new MyItem();
		
		newRoom = false;
		
		clearAllEvents();
		updateHUD();
		optionsBtn.visible = false;
		charDesc.visible = false;
		
		switch (shopType) {
		case "gen":
			//General Store
			if (shopListMade == false) {
				shopList = new Array();
				for (i in 0...globals.shopLists[0].length) {
					switch (globals.shopLists[0][i].split("|")[0]) {
					case "food":
						tempItem = new MyItem_Food();
						tempItem = globals.food[globals.shopLists[0][i].split("|")[1]].copyItem();
						
						shopList.push(new MyItem_Food());
						shopList[shopList.length - 1] = tempItem;
					}
				}
					
				for (i in 0...(Math.round(Math.random() * 5) + 1)) {
					switch (Math.round(Math.random() * 3)) {
					case 0:
						//Armor
						shopList.push(createItem("armor"));
					case 1:
						//Weapon
						shopList.push(createItem("weapon"));
					case 2:
						//Ring
						shopList.push(createItem("ring"));
					}
				}
			shopListMade = true;
			}
			canSell = true;
			title = "General Store";
			
		//Ice cream shop has been moved to it's own function as it's not adding prebuilt items to the player's invintory
		//Rather it's going to directly feed the player ice cream
		
		case "rat":
			//Black Market
			
		}
		
		switch (shopAction) {
		case "list":
			//List the items the shop has to sell
			if (shopList.length > 9) {
				dspFirstItem = shopActionValue * 9;
				dspItems = dspFirstItem + 9;
			}
			
			if (shopList.length < dspItems) 
				dspItems = shopList.length;
			
			message = "The shop has the following items for sale:</p><br><p>";
			
			if (shopList.length != 0) {
				for (i in dspFirstItem...dspItems) {
					message += shopList[i].name + ": $" + shopList[i].value + "<br>     " + shopList[i].desc + "</p><br><p>";
					btns[i - dspFirstItem].setButton(shopList[i].name, null, shopType + "|item|" + i);
					btns[i - dspFirstItem].setClickFunc(doShop);
				}
				if (shopList.length > dspItems) {
					message += "More...";
					btns[10].setButton("Next", null, shopType + "|list|" + (shopActionValue + 1));
					btns[10].setClickFunc(doShop);
				}
				if (dspFirstItem != 0) {
					btns[9].setButton("Prev", null, shopType + "|list|" + (shopActionValue - 1));
					btns[9].setClickFunc(doShop);
				} else {
					if (canSell) {
						btns[9].setButton("Sell", "Sell extra items to the shop.", shopType + "|sell|0");
						btns[9].setClickFunc(doShop);
					}
				}
			}
			
			outputText(message, title);
			
			btns[11].setButton("Leave");
			btns[11].setClickFunc(movePlayer);
		case "item":
			//Item detail view
			title += " --- Item Detail";
			
			message = "Name: " + shopList[shopActionValue].name + "<br>";
			message += "Type: " + shopList[shopActionValue].type + "<br>";
			message += "Mass: " + shopList[shopActionValue].mass + " ";
			message += "Value: " + shopList[shopActionValue].value + "<br>";
			message += shopList[shopActionValue].desc + "<br>";
			
			switch (shopList[shopActionValue].type) {
			case "weapon":
				message += "Attack: " + shopList[shopActionValue].attack + " ";
				if (shopList[shopActionValue].twoHanded) {
					message += "2H";
				} else {
					message += "1H";
				}
				
				message += "<br>Special Qualities:<br>";
			case "armor":
				message += "Defense: " + shopList[shopActionValue].defend + ".<br>";
				message += "Special Qualities:<br>";
			case "ring":
				message += "Special Qualities:<br>";
			case "food":
				
			}
			
			for (i in 0...shopList[shopActionValue].specials.length) {
				var specialSkill = shopList[shopActionValue].specials[i].split("|")[0];
				var specialValue = shopList[shopActionValue].specials[i].split("|")[1];
				switch(specialSkill) {
				case "str":
					message += "Strength +" + specialValue;
				case "agi":
					message += "Agility +" + specialValue;
				case "end":
					message += "Endurance +" + specialValue;
				case "int":
					message += "Intelligence +" + specialValue;
				case "health":
					message += "Health +" + specialValue;
				case "spot":
					message += "Spot +" + specialValue;
				case "dodge":
					message += "Dodge +" + specialValue;
				case "run":
					message += "Run +" + specialValue;
				case "melee":
					message += "Melee +" + specialValue;
				case "sneak":
					message += "Sneak +" + specialValue;
				case "heal":
					message += (Std.parseFloat(specialValue) * 100) + "% Healing";
				default:
					message += "{ERROR} Special not found:" + specialSkill + " with value: " + specialValue;
				}
				if (i < shopList[shopActionValue].specials.length - 1)
					message += ", ";
			}
			
			outputText(message, title);
			
			btns[0].setButton("Buy", null, shopType + "|buy|" + shopActionValue);
			btns[0].setClickFunc(doShop);
			btns[2].setButton("Back", null, shopType + "|list|0");
			btns[2].setClickFunc(doShop);
		case "buy":
			//Buy item check screen
			message = "Buy " + shopList[shopActionValue].name + " for $" + shopList[shopActionValue].value + "?";
			
			btns[0].setButton("Buy", null, shopType + "|confirmBuy|" + shopActionValue);
			btns[0].setClickFunc(doShop);
			
			if (playerCharacter.getMoney() < shopList[shopActionValue].value) {
				message += " Not enough money!";
				btns[0].disableButton();
			}
			
			updateHUD();
			outputText(message, title);
			
			btns[2].setButton("Back", null, shopType + "|item|" + shopActionValue);
			btns[2].setClickFunc(doShop);
		case "confirmBuy":
			//Actually buy the item
			message = "You hand over the money and the shopkeeper gives you the " + shopList[shopActionValue].name + ". ";
			
			playerCharacter.addMoney( -shopList[shopActionValue].value);
			message += shopList[shopActionValue].give(playerCharacter);
			shopList.remove(shopList[shopActionValue]);
			updateHUD();
			outputText(message, "Item Bought");
			
			btns[11].setButton("Next", null, shopType + "|list|0");
			btns[11].setClickFunc(doShop);
		case "sell":
			//Sell items back to the shop
			title = "Sell";
			message = "You check your pockets and find;<br>";
			
			if (playerCharacter.invObject.length > 9) {
				dspFirstItem = shopActionValue * 9;
				dspItems = dspFirstItem + 9;
			}
			
			if (playerCharacter.invObject.length < dspItems)
				dspItems = playerCharacter.invObject.length;
			
			if (playerCharacter.invObject.length != 0) {
				for (i in dspFirstItem...dspItems) {
					message += playerCharacter.invObject[i].name + " $" + Math.round(Std.parseInt(playerCharacter.invObject[i].value) / 2) + "<br>     " + playerCharacter.invObject[i].desc + "<br>";
					btns[i - dspFirstItem].setButton(playerCharacter.invObject[i].name, null, shopType + "|sellItem|" + i);
					btns[i - dspFirstItem].setClickFunc(doShop);
				}
				if (playerCharacter.invObject.length > dspItems) {
					message += "More...<br>";
					btns[10].setButton("Next", null, shopType + "|sell|" + (shopActionValue + 1));
					btns[10].setClickFunc(doShop);
				}
				if (dspFirstItem != 0) {
					btns[9].setButton("Prev", null, shopType + "|sell|" + (shopActionValue - 1));
					btns[9].setClickFunc(doShop);
				}
			} else {
				message += "Nothing!<br>";
			}
			
			outputText(message, title);
			btns[11].setButton("Back", null, shopType + "|list|0");
			btns[11].setClickFunc(doShop);
		case "sellItem":
			//Confirm sell off the item
			title = "Sell Item";
			message = "You offer the shopkeeper your " + playerCharacter.invObject[shopActionValue].name.toLowerCase() + ", [OBJ] offers you $" + Math.round(Std.parseInt(playerCharacter.invObject[shopActionValue].value) / 2) + "</p><br><p>Sell it?";
			
			outputText(message, title);
			updateHUD();
			
			btns[0].setButton("Yes", null, shopType + "|doSell|" + shopActionValue);
			btns[0].setClickFunc(doShop);
			
			btns[2].setButton("No", null, shopType + "|sell|0");
			btns[2].setClickFunc(doShop);
		case "doSell":
			//Actually sell off the item
			title = "Sold";
			
			message = "You agree to the sale, the shopkeeper hands you $" + Math.round(Std.parseInt(playerCharacter.invObject[shopActionValue].value) / 2) + " and puts the " + playerCharacter.invObject[shopActionValue].name.toLowerCase() + " behind the counter.";
			
			playerCharacter.addMoney(Math.round(Std.parseInt(playerCharacter.invObject[shopActionValue].value) / 2));
			playerCharacter.invObject[shopActionValue].toss(playerCharacter);
			
			updateHUD();
			outputText(message, title);
			
			btns[0].setButton("Next", null, shopType + "|sell|0");
			btns[0].setClickFunc(doShop);
		}
		
	}
	
	static function doWork( e:MouseEvent ) {
		var workTime:Int = e.currentTarget.btnID;
		var workSucc:Int = rollDie(playerCharacter.intelligence());
		var payment:Int = ((workSucc * 75) * workTime) + playerCharacter.greed;
		var message:String = "";
		
		clearAllEvents();
		
		message = playerCharacter.advanceSkill(workSucc, "int");
		
		payment = Std.parseInt(truncateDecimalPlaces(payment));
		
		if (payment < 75)
			payment = 75;
		
		playerCharacter.addMoney(payment);
		
		playerCharacter.passTime_with_output(workTime * 60);
		
		updateHUD();
		
		outputText("You spend " + workTime + " hours sorting through the piles of stuff in the storeroom. Most of it is junk of one kind or another, all of it is shiny. Without any real idea what to do with the stuff, you sort it by value, using your strange and poorly explained ability to instantly know the value of any random object you pick up. After you finish for the day you head back up stairs and let the shopkeeper know you've finished. He thanks you and hands you $" + payment + " as payment. &quot;Feel free to come back and work some more whenever you want.&quot;</p><br><p>" + message, "General Store - Work");
		
		newRoom = true;
		
		btns[0].setButton("Next", null, 19);
		btns[0].setClickFunc(movePlayer);
	}
	
	static function resetGame( e:MouseEvent ) {
		var choice:Int = e.currentTarget.btnID;
		
		clearAllEvents();
		
		switch (choice) {
		case 0:
			outputText("Return to the main menu? Anything not saved will be lost.", "Reset Game");
			
			btns[0].setButton("Yes", null, 1);
			btns[0].setClickFunc(resetGame);
			if (!playerDead) {
				btns[2].setButton("No");
				btns[2].setClickFunc(optionsScreen);
			}
		case 1:
			Lib.current.removeChildren();
			globals = new GlobalVars();
			playerCharacter = new MyPlayerObject();
			currentRoom = null;
			newRoom = true;
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
		var newItem:MyItem = new MyItem();
		
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
			var txtJump:Object = Lib.current.getChildByName("jumpTo");
			if (txtJump != null)
				Lib.current.removeChild(txtJump);
			
			message = "Choose wisely</p><br><p>Lactation is ";
			if (playerCharacter.lac) {
				message += "on";
			} else {
				message += "off";
			}
			message += ".</p><br><p>";
			
			btns[0].setButton("Toggle Lactation", null, 1);
			btns[0].setClickFunc(debugMenu);
			btns[1].setButton("Set Quest stage", null, 2);
			btns[1].setClickFunc(debugMenu);
			btns[2].setButton("Jump To", "Teleport around the map", 5);
			btns[2].setClickFunc(debugMenu);
			btns[3].setButton("Logic Test", null, 7);
			btns[3].setClickFunc(debugMenu);
			btns[4].setButton("Create Item", null, 8);
			btns[4].setClickFunc(debugMenu);
			btns[5].setButton("Perks", null, 9);
			btns[5].setClickFunc(debugMenu);
			btns[6].setButton("+Fat", null, 10);
			btns[6].setClickFunc(debugMenu);
			btns[7].setButton("+Cash", null, 11);
			btns[7].setClickFunc(debugMenu);
			btns[8].setButton("Arousal", null, 12, debugMenu);
			
			btns[11].setButton("Back");
			btns[11].setClickFunc(movePlayer);
			
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
			btns[11].setClickFunc(debugMenu);
		case 2:
			message = "Quest?";
			
			for (i in 0...playerCharacter.quest.length) {
				btns[i].setButton(playerCharacter.quest[i].name, null, "3|" + i);
				btns[i].setClickFunc(debugMenu);
			}
			
			btns[11].setButton("Cancel", null, 0);
			btns[11].setClickFunc(debugMenu);
		case 3:
			message = "Set stage to?";
			
			for (i in 0...playerCharacter.quest[questID].stageDesc.length) {
				btns[i].setButton("#" + i, null, "4|" + questID + "|" + i);
				btns[i].setClickFunc(debugMenu);
			}
			
			btns[11].setButton("Cancel", null, 0);
			btns[11].setClickFunc(debugMenu);
		case 4:
			playerCharacter.quest[questID].stage = stage;
			
			message = "Quest '" + playerCharacter.quest[questID].dispName + "' set to stage '" + stage + "': " + playerCharacter.quest[questID].stageDesc[stage];
			
			btns[11].setButton("Back", null, 0);
			btns[11].setClickFunc(debugMenu);
		case 5:
			//Teleport
			message = "Enter Room ID to teleport to:<br><br>(Tip: The Hospital Backroom has an ID of 32)";
			
			var txtFormat:TextFormat = new TextFormat("Sans", globals.textSize);
			
			
			var txtJump:TextField = new TextField();
			txtJump.x = 20;
			txtJump.y = 120;
			txtJump.visible = true;
			txtJump.border = true;
			txtJump.width = 30;
			txtJump.height = 30;
			txtJump.defaultTextFormat = txtFormat;
			txtJump.type = TextFieldType.INPUT;
			txtJump.name = "jumpTo";
			
			Lib.current.addChild(txtJump);
			
			btns[0].setButton("Jump", null, 6);
			btns[0].setClickFunc(debugMenu);
			
			btns[2].setButton("Back", null, 0);
			btns[2].setClickFunc(debugMenu);
		case 6:
			var txtJump:Object = Lib.current.getChildByName("jumpTo");
			var jumpTo:Int = Std.parseInt(txtJump.text);
			
			Lib.current.removeChild(txtJump);
			
			message = "New room set to: " + jumpTo;
			
			newRoom = true;
			
			btns[0].setButton("Next", null, jumpTo);
			btns[0].setClickFunc(movePlayer);
		case 7:
			//text parsing system logic testing
			roomNPC = new MyNPC();
			roomNPC.randomNPC(species, playerCharacter);
			
			message = "Randomly generated NPC is [NPCGENDER].</p><br>";
			message += "<p>What follows is a test of the logic parsing system.</p><br>";
			message += "<p>This sentance should appear for everyone. ";
			message += "[HasBreasts:This sentance should appear for NPCs with {POS} breasts. ]";
			message += "[HasVagina:This sentance should appear for NPCs with a vagina. ]";
			message += "[HasPenis:This sentance should appear for NPCs with a penis. ]";
			message += "[HasBalls:This sentance should appear for NPCs with balls. ]";
			
			btns[0].setButton("Test Again", null, 7);
			btns[0].setClickFunc(debugMenu);
			btns[11].setButton("Main", null, 0);
			btns[11].setClickFunc(debugMenu);
		case 8:
			//Create an item and give it to the player
			newItem = createItem("weapon");
			
			message = "Generated item:<br>";
			message += "Item type: " + newItem.name + "<br>";
			message += "Item rarity: " + newItem.rarity + "<br>";
			message += "Item specials: ";
			
			for (i in 0...newItem.specials.length) {
				message += newItem.specials[i] + " ";
			}
			
			playerCharacter.invObject.push(newItem);
			
			btns[0].setButton("Again", null, 8);
			btns[0].setClickFunc(debugMenu);
			btns[11].setButton("Main", null, 0);
			btns[11].setClickFunc(debugMenu);
		case 9:
			//list perks owned by the player
			message = "Perks Owned:<br>";
			
			for (i in 0...globals.perks.length) {
				if (playerCharacter.hasPerk(globals.perks[i].name))
					message += globals.perks[i].dispName + " x" + playerCharacter.perkCount(globals.perks[i].name) + "<br>";
			}
			
			btns[11].setButton("Back", null, 0);
			btns[11].setClickFunc(debugMenu);
		case 10:
			//Fatten up the player
			message = "You get fatter.";
			
			playerCharacter.fat += 1000;
			
			btns[11].setButton("Next", null, 0);
			btns[11].setClickFunc(debugMenu);
		case 11:
			//Gain money
			message = "You find some money.";
			
			playerCharacter.addMoney(1000);
			
			btns[11].setButton("Next", null, 0);
			btns[11].setClickFunc(debugMenu);
		case 12:
			//Make the player horny
			message = "You suddenly get inexplicably horny.";
			
			playerCharacter.arousal = 100;
			
			btns[11].setButton("Next", null, 0, debugMenu);
		}
		
		outputText(message, "Debug Menu");
	}
	
	static function loadGame( e:MouseEvent ) {
		var saveDataObject:SharedObject = SharedObject.getLocal(globals.gameSaveName, "/");
		var loadedSaveDataObject:MyFileSaveObject = new MyFileSaveObject();
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
							//Automagically update the save files where possible.
							if (saveDataObject.data.save1[0] == 12) { //Version 12 was missing unlockedPhoneNumbers
								saveDataObject.data.player1.unlockedPhoneNumbers = [true, true];
								saveDataObject.data.save1[0] = 13;
							}
							if (saveDataObject.data.save1[0] == 13) { //Version 13 had digestion rates too high
								saveDataObject.data.player1.digestDamage = saveDataObject.data.player1.digestDamage / 10;
								saveDataObject.data.save1[0] = 14;
							}
							if (saveDataObject.data.save1[0] == 14) { //Version 14 had no weapons
								saveDataObject.data.player1.equipWepObj = globals.weapons[0]; //Unarmed
								saveDataObject.data.save1[0] = 15;
							}
							if (saveDataObject.data.save1[0] == 15) {//Version 15 had no difficulty
								saveDataObject.data.globals.push(1);
								saveDataObject.data.save1[0] = 16;
							}
							if (saveDataObject.data.save1[0] == 16) {
								saveDataObject.data.player1.equipArmObj = globals.armor[0];
								saveDataObject.data.save1[0] = 17;
							}
							save1Name = saveDataObject.data.player1.name + " -- Updated";
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
							if (saveDataObject.data.save2[0] == 12) { //Version 12 was missing unlockedPhoneNumbers
								saveDataObject.data.player2.unlockedPhoneNumbers = [true, true];
								saveDataObject.data.save2[0] = 13;
							}
							if (saveDataObject.data.save2[0] == 13) { //Version 13 had digestion rates too high
								saveDataObject.data.player2.digestDamage = saveDataObject.data.player1.digestDamage / 10;
								saveDataObject.data.save2[0] = 14;
							}
							if (saveDataObject.data.save2[0] == 14) { //Version 14 had no weapons
								saveDataObject.data.player2.equipWepObj = globals.weapons[0]; //Unarmed
								saveDataObject.data.save2[0] = 15;
							}

							if (saveDataObject.data.save2[0] == 15) { //Version 15 had no difficulty
								saveDataObject.data.globals.push(1);
								saveDataObject.data.save2[0] = 16;
							}
							if (saveDataObject.data.save2[0] == 16) {
								saveDataObject.data.player2.equipArmObj = globals.armor[0];
								saveDataObject.data.save2[0] = 17;
							}
							save2Name = saveDataObject.data.player2.name + " -- Updated";
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
							if (saveDataObject.data.save3[0] == 12) { //Version 12 was missing unlockedPhoneNumbers
								saveDataObject.data.player3.unlockedPhoneNumbers = [true, true];
								saveDataObject.data.save3[0] = 13;
							}
							if (saveDataObject.data.save3[0] == 13) { //Version 13 had digestion rates too high
								saveDataObject.data.player3.digestDamage = saveDataObject.data.player1.digestDamage / 10;
								saveDataObject.data.save3[0] = 14;
							}
							if (saveDataObject.data.save3[0] == 14) { //Version 14 had no weapons
								saveDataObject.data.player3.equipWepObj = globals.weapons[0]; //Unarmed
								saveDataObject.data.save3[0] = 15;
							}
							if (saveDataObject.data.save3[0] == 15) {//Version 15 had no difficulty
								saveDataObject.data.globals.push(1);
								saveDataObject.data.save3[0] = 16;
							}
							if (saveDataObject.data.save3[0] == 16) {
								saveDataObject.data.player3.equipArmObj = globals.armor[0]; //Skin
								saveDataObject.data.save3[0] = 17;
							}
							save3Name = saveDataObject.data.player3.name + " -- Updated";
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
				btns[0].setClickFunc(loadGame);
			btns[1].setButton("Slot 2", save2Tip, 2);
			if (slot2Filled)
				btns[1].setClickFunc(loadGame);
			btns[2].setButton("Slot 3", save3Tip, 3);
			if (slot3Filled)
				btns[2].setClickFunc(loadGame);
			btns[9].setButton("File", "Load from a file", 4);
			btns[9].setClickFunc(loadGame);
			
			btns[11].setButton("Back");
			switch (globals.backTo) {
			case "Welcome":
				btns[11].setClickFunc(welcomeScreen);
			case "move":
				btns[11].setClickFunc(optionsScreen);
			}
		} else {
			var loadedPlayer:Object = null;
			
			globals.debugMode = saveDataObject.data.globals[0];
			globals.textSize = saveDataObject.data.globals[1];
			globals.allowScat = saveDataObject.data.globals[2];
			globals.allowSex = saveDataObject.data.globals[3];
			globals.allowedGenders = saveDataObject.data.globals[4];
			globals.difficulty = saveDataObject.data.globals[5];
			
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
			case 4:
				fileSaveObject.browse();
				
				fileSaveObject.addEventListener(Event.SELECT, doFileLoad);
				fileSaveObject.addEventListener(Event.COMPLETE, doDataLoad);
				fileSaveObject.addEventListener(Event.CANCEL, doLoadCancel);
				
				outputText("Please choose a file.");
				return;
			}
			
			playerCharacter = loadedPlayer;
			
			doorFuckCount = playerCharacter.endurance();
			
			if (playerCharacter.cumStretchCountdown == -1)
				playerCharacter.cumStretchCountdown = playerCharacter.stretchRateCum;
			if (playerCharacter.milkStretchCountdown == -1)
				playerCharacter.milkStretchCountdown = playerCharacter.stretchRateMilk;
			if (playerCharacter.bowelsStretchCountdown == -1)
				playerCharacter.bowelsStretchCountdown = playerCharacter.stretchRateBowels;
			if (playerCharacter.stomachStretchCountdown == -1)
				playerCharacter.stomachStretchCountdown = playerCharacter.stretchRateStomach;
			
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
			btns[11].setClickFunc(movePlayer);
		}
	}
	
	static function saveGame( e:MouseEvent ) {
		var saveDataObject:SharedObject = SharedObject.getLocal(globals.gameSaveName, "/");
		var loadedFileSaveObject:MyFileSaveObject = new MyFileSaveObject();
		
		var save1Name:String = "";
		var save2Name:String = "";
		var save3Name:String = "";
		var save1Tip:String = "";
		var save2Tip:String = "";
		var save3Tip:String = "";
		
		var message:String = "";
		var clicked:Dynamic = e.currentTarget.btnID;
		
		var saveResult:String = "";
		
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
			btns[0].setClickFunc(saveGame);
			btns[1].setButton("Slot 2", save2Tip, 2);
			btns[1].setClickFunc(saveGame);
			btns[2].setButton("Slot 3", save3Tip, 3);
			btns[2].setClickFunc(saveGame);
			btns[9].setButton("File", "Save to file", 4);
			btns[9].setClickFunc(saveGame);
			
			btns[11].setButton("Back");
			btns[11].setClickFunc(optionsScreen);
		} else {
			var globalSaveArray:Array<Dynamic> = new Array();
			var playerSaveArray:Array<Dynamic> = new Array();
			
			globalSaveArray.push(globals.debugMode);
			globalSaveArray.push(globals.textSize);
			globalSaveArray.push(globals.allowScat);
			globalSaveArray.push(globals.allowSex);
			globalSaveArray.push(globals.allowedGenders);
			globalSaveArray.push(globals.difficulty);
			
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
			case 4: //Attempting to allow saving to files. We'll see how this goes.
				var saveBytes:ByteArray = new ByteArray();
				
				loadedFileSaveObject.globals = globalSaveArray;
				loadedFileSaveObject.save = playerSaveArray;
				loadedFileSaveObject.player = playerCharacter;
				
				saveBytes.writeObject(loadedFileSaveObject);
				saveBytes.deflate();
				
				fileSaveObject.save(saveBytes, playerCharacter.name + "'s save.sol");
				
				fileSaveObject.addEventListener(Event.CANCEL, doSaveCancel);
				fileSaveObject.addEventListener(Event.COMPLETE, doSaveComplete);
				return;
			default:
				new AlertBox("ERROR: Bad save slot target " + clicked);
			}
			
			try { saveResult = saveDataObject.flush(); } catch (myError:Error) {
				//Something here is throwing an error, however FlashDevelop is fighting with me again about starting the debugger so I can't see anuything useful
				outputText("Save error: " + myError.message);
				btns[11].setButton("Back", null, 0);
				btns[11].setClickFunc(saveGame);
				return;
			}
			
			//The goal here is to display a message if the user has prevented flash from saving data locally, I think this code will work but I can't test it due to the issue with FlashDevelop's debugger
			
			if (saveResult == SharedObjectFlushStatus.FLUSHED || saveResult == SharedObjectFlushStatus.PENDING) {
				outputText("Game saved to slot " + clicked, "Save Game");
			} else {
				outputText("Failed to save game. Is flash allowed to store data locally?", "Save Game");
			}
			
			btns[11].setButton("Next");
			btns[11].setClickFunc(optionsScreen);
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
		
		// Handle integer button IDs first
		if (Type.typeof(clicked) == ValueType.TInt)
		{
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
					btns[i].setClickFunc(newGame);
				}
				if (species.length - offset > 9) {
					btns[11].setButton("More", null, -1);
					btns[11].setClickFunc(newGame);
				}
				if (offset != 0) {
					btns[9].setButton("Prev", null, -2);
					btns[9].setClickFunc(newGame);
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
				btns[0].setClickFunc(newGame);
				btns[1].setButton("Vagina", null, -4);
				btns[1].setClickFunc(newGame);
				btns[2].setButton("Penis", null, -5);
				btns[2].setClickFunc(newGame);
				if (penis) {
					btns[3].setButton("Balls", null, -6);
					btns[3].setClickFunc(newGame);
				}
				
				btns[9].setButton("Back", null, 0);
				btns[9].setClickFunc(newGame);
				
				btns[11].setButton("Next", null, 2);
				btns[11].setClickFunc(newGame);
				
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
					btns[0].setClickFunc(newGame);
					btns[3].setButton("Agility+", null, -9);
					btns[3].setClickFunc(newGame);
					btns[6].setButton("Endurance+", null, -11);
					btns[6].setClickFunc(newGame);
					btns[9].setButton("Intelligence+", null, -13);
					btns[9].setClickFunc(newGame);
				}
				
				if (str != 1) {
					btns[1].setButton("Strength-", null, -8);
					btns[1].setClickFunc(newGame);
				}
				if (agi != 1) {
					btns[4].setButton("Agility-", null, -10);
					btns[4].setClickFunc(newGame);
				}
				if (end != 1) {
					btns[7].setButton("Endurance-", null, -12);
					btns[7].setClickFunc(newGame);
				}
				if (int != 1) {
					btns[10].setButton("Intelligence-", null, -14);
					btns[10].setClickFunc(newGame);
				}
				
				
				btns[8].setButton("Back", null, 1);
				btns[8].setClickFunc(newGame);
				
				if (pointsAvail == 0) {
					btns[11].setButton("Next", null, 3);
					btns[11].setClickFunc(newGame);
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
					btns[btnNum].setClickFunc(newGame);
					btnNum += 1;
				}
				if (visiblePerks.length - offset > 9) {
					btns[11].setButton("More", null, -1);
					btns[11].setClickFunc(newGame);
				}
				if (offset != 0) {
					btns[9].setButton("Prev", null, -2);
					btns[9].setClickFunc(newGame);
				}
				
				btns[10].setButton("Back", null, 2);
				btns[10].setClickFunc(newGame);
				
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
				btns[11].setClickFunc(newGame);
				
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
				btns[0].setClickFunc(newGame);
				
				btns[2].setButton("No", null, 4);
				btns[2].setClickFunc(newGame);
			case 6:
				//Create new player object
				finalPerks = new Array();
				for (i in 0...perksPicked.length) {
					finalPerks.push(visiblePerks[perksPicked[i]]);
				}
				
				playerCharacter = new MyPlayerObject();
				playerCharacter.newPlayer(thisSpecies, breasts, vagina, penis, balls, str, agi, end, int, playerName, finalPerks);
				playerCharacter.quest = new Array();
				
				playerCharacter.pride = 2;
				
				for (i in 0...quests.length) {
					playerCharacter.quest.push(new MyQuest());
					playerCharacter.quest[playerCharacter.quest.length - 1].newQuest(quests[i]);
				}
				
				playerCharacter.emptyStomachCountdown = playerCharacter.endurance();
				doorFuckCount = playerCharacter.endurance();
				
				//equip the player with the 'unarmed' 'weapon'
				playerCharacter.equipWepObj = globals.weapons[0];
				playerCharacter.equipArmObj = globals.armor[0];
				
				updateHUD();
				
				message = "6:00 AM. <i>Damn, forgot to turn the alarm off.</i> You roll over and glare at the little black box chirping merrily away, telling you it's time to wake up and get ready for your job.</p><br><p>That you no longer have.</p><br><p>You groan and turn the alarm off, sitting up and thinking about what you're going to do. You remember you lost your job yesterday. Apparently licking coworkers and saying they taste good is frowned upon.</p><br><p>Oh well. Time to find a new way to pay the bills. Maybe that new club down the street is looking for a bartender or bouncer or something.";
				
				outputText(message, "BEEP! BEEP! BEEP! BEEP!");
				
				btns[11].setButton("Next", null, 0);
				btns[11].setClickFunc(movePlayer);
				
				//Look into variable destructors, take out all the ones used in character creation don't need them past this point.
			}
		}
			
		else	// If clicked wasn't an Int, handle it as a String
		{
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
				btns[0].setClickFunc(newGame);
				btns[2].setButton("No", null, 0);
				btns[2].setClickFunc(newGame);
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
			btns[10].setClickFunc(welcomeScreen);
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
		var message:String = "";
		
		if (gameLogo != null)
			Lib.current.removeChild(gameLogo);
		
		var clicked:Int = 0;
		
		if (e != null)
			clicked = e.currentTarget.btnID;
		
		clearAllEvents();
		
		message = "Debug Mode: " + globals.debugMode + "</p><p>Text Size: " + globals.textSize + "</p><p>Allow Scat: " + globals.allowScat + "</p><p>Allow Sex: " + globals.allowSex + "</p><p>Difficulty: ";
		
		switch(globals.difficulty) {
		case 1:
			message += "Normal";
		case 0.5:
			message += "Easy";
		case 1.5:
			message += "Hard";
		}
		if (globals.debugMode)
			message += " " + globals.difficulty;
		
		outputText(message, "Options");
		
		btnOptions.visible = false;
		btnDesc.visible = false;
		txtTime.visible = false;
		txtPublic.visible = false;
		newRoom = false;
		
		switch (clicked) {
		case 0:
			btns[0].setButton("Scat", "Allow/disallow scat. Controls if your character poops or not.", 1);
			btns[0].setClickFunc(optionsScreen);
			btns[1].setButton("Arousal", "Allow/disallow sex. Controls if your character becomes aroused.", 3);
			btns[1].setClickFunc(optionsScreen);
			btns[2].setButton("Debug", "Toggle debug mode.", 2);
			btns[2].setClickFunc(optionsScreen);
			btns[3].setButton("Font Size+");
			btns[3].setClickFunc(increaseFontSize);
			btns[4].setButton("Font Size-");
			btns[4].setClickFunc(decreaseFontSize);
			btns[5].setButton("Difficulty-", "Reduce combat difficulty", 4);
			if (globals.difficulty == 0.5) {
				btns[5].disableButton();
			} else {
				btns[5].setClickFunc(optionsScreen);
			}
			btns[8].setButton("Difficulty+", "Increase combat difficulty", 5);
			if (globals.difficulty == 1.5) {
				btns[8].disableButton();
			} else {
				btns[8].setClickFunc(optionsScreen);
			}
			
			if (globals.backTo != "Welcome") {
				btns[6].setButton("Main Menu", "Start a new game. Current game will be lost.", 0);
				btns[6].setClickFunc(resetGame);
			}
			
			btns[11].setButton("Back");
			
			switch (globals.backTo) {
				case "Welcome":
					btns[11].setClickFunc(welcomeScreen);
				case "move":
					btns[9].setButton("Save", null, 0);
					btns[9].setClickFunc(saveGame);
					
					btns[11].setClickFunc(movePlayer);
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
		case 4:
			//Decrease Combat Difficulty
			switch (globals.difficulty) {
			case 1:
				globals.difficulty = 0.5;
			case 1.5:
				globals.difficulty = 1;
			default:
				new AlertBox("Error, cannot decrease difficulty");
			}
			optionsScreen();
		case 5:
			//Increase Combat Difficulty
			switch (globals.difficulty) {
			case 0.5:
				globals.difficulty = 1;
			case 1:
				globals.difficulty = 1.5;
			default:
				new AlertBox("Error, cannot increase difficulty");
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
			btns[0].setClickFunc(movePlayer);
			
			playerCharacter.quest[currentRoom.exitNW.hiddenQuestID].stage = 1;
		case "n":
			btns[1].setButton(currentRoom.exitN.name, currentRoom.exitN.desc, currentRoom.exitN.travelTo + ":" + currentRoom.exitN.travelTime);
			btns[1].setClickFunc(movePlayer);
			
			playerCharacter.quest[currentRoom.exitN.hiddenQuestID].stage = 1;
		case "ne":
			btns[2].setButton(currentRoom.exitNE.name, currentRoom.exitNE.desc, currentRoom.exitNE.travelTo + ":" + currentRoom.exitNE.travelTime);
			btns[2].setClickFunc(movePlayer);
			
			playerCharacter.quest[currentRoom.exitNE.hiddenQuestID].stage = 1;
		case "w":
			btns[3].setButton(currentRoom.exitW.name, currentRoom.exitW.desc, currentRoom.exitW.travelTo + ":" + currentRoom.exitW.travelTime);
			btns[3].setClickFunc(movePlayer);
			
			playerCharacter.quest[currentRoom.exitW.hiddenQuestID].stage = 1;
		case "e":
			btns[5].setButton(currentRoom.exitE.name, currentRoom.exitE.desc, currentRoom.exitE.travelTo + ":" + currentRoom.exitE.travelTime);
			btns[5].setClickFunc(movePlayer);
			
			playerCharacter.quest[currentRoom.exitE.hiddenQuestID].stage = 1;
		case "sw":
			btns[6].setButton(currentRoom.exitSW.name, currentRoom.exitSW.desc, currentRoom.exitSW.travelTo + ":" + currentRoom.exitSW.travelTime);
			btns[6].setClickFunc(movePlayer);
			
			playerCharacter.quest[currentRoom.exitSW.hiddenQuestID].stage = 1;
		case "s":
			btns[7].setButton(currentRoom.exitS.name, currentRoom.exitS.desc, currentRoom.exitS.travelTo + ":" + currentRoom.exitS.travelTime);
			btns[7].setClickFunc(movePlayer);
			
			playerCharacter.quest[currentRoom.exitS.hiddenQuestID].stage = 1;
		case "se":
			btns[8].setButton(currentRoom.exitSE.name, currentRoom.exitSE.desc, currentRoom.exitSE.travelTo + ":" + currentRoom.exitSE.travelTime);
			btns[8].setClickFunc(movePlayer);
			
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
		qanda.push("<p><b>Will you add graphics/Can I make graphics for your game?</b></p><p>Yes! I am always willing to take artwork, see the forums for details. Unfortunitly I can't offer bounties right now, but maybe I will again soon.</p>");
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
		btns[8].setClickFunc(welcomeScreen);
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
		credits.push("Bug fixes and code improvements by GitHub member s-r-g-i.");
		
		oneLineBackers.push("pelle"); //Dropped to $1 Feb
		oneLineBackers.push("Writer"); //Paid Feb #10
		
		
		backerCredits.push("Foxlets"); //Dropped below $5 in October
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
		btns[8].setClickFunc(welcomeScreen);
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
		
		//Date specific messages
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
		
		txtOutput.htmlText = "<body><br><br><p><span class='byline'>Created by Kyra Sunseeker</span></p><br><br><p><span class = 'heading'>&nbsp;&nbsp;Welcome to</span></p><br><br><br><br><br><br><br><p><font size='" + textSize + "'><br><br><p align = 'center'><u><a href=\"https://twitter.com/SillySnowFox\">Follow @SillySnowFox</a></u></p><br><br><br><font size = '" + textSize + "'><p align = 'center'>" + message + "</p></font></body>";
		
		clearAllEvents();
		
		btns[0].setButton("New Game", "Start a new game", 0);
		btns[0].setClickFunc(newGame);
		btns[1].setButton("Load", "Load a saved game", 0);
		btns[1].setClickFunc(loadGame);
		btns[2].setButton("Options");
		btns[2].setClickFunc(optionsScreen);
		
		btns[6].setButton("F.A.Q.");
		btns[6].setClickFunc(displayFAQ);
		
		btns[8].setButton("Credits");
		btns[8].setClickFunc(displayCredits);
		
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
	
	static function debugDump( e:MouseEvent ) {
		//Dump data to the screen, hopefully this will help with crashes
		var message:String = "";
		
		clearAllEvents();
		
		newRoom = true;
		
		message = "Current Room ID: " + globals.currentRoomID;
		
		outputText(message);
		
		btns[0].setButton("Recover", "Attempt game recovery", 0, movePlayer);
	}
	
	/**************************\
	 *                        *
	 * Non-cickable functions *
	 *                        *
	\**************************/
	
	static function timerKeyEvent( e:KeyboardEvent ) {
		var keyPressed:String = String.fromCharCode(e.charCode).toLowerCase();
		
		if (keyPressed == timerQTE.tmrKey) {
			timerQTE.tmrQuick.stop();
			
			QTEstage = timerQTE.successScene;
			
			Lib.current.removeChild(timerQTE);
			
			doQTE();
		}
	}
	
	static function timerFailEvent( e:TimerEvent ) {
		QTEstage = timerQTE.failScene;
		timerQTE.tmrQuick.stop();
		
		Lib.current.removeChild(timerQTE);
		
		doQTE();
	}
	
	static function createItem(item:String):MyItem {
		var madeItem:MyItem = new MyItem();
		var randItem:Int = 0;
		var rarity:String = "";
		var rare:Int = Math.round((Math.random() * 100));
		
		if (rare <= 60) {
			rarity = "common";
		} else if (rare > 60 && rare <= 80) {
			rarity = "uncommon";
		} else if (rare > 80 && rare <= 90) {
			rarity = "rare";
		} else if (rare > 90 && rare <= 99) {
			rarity = "epic";
		} else if (rare == 100) {
			rarity = "legendary";
		}
		
		switch(item) {
		case "armor":
			while (randItem == 0) {
				//Don't want skin, that's not really armor
				randItem = Math.round(Math.random() * (globals.armor.length - 1));
			}
			
			madeItem = globals.armor[randItem].copyItem();
		case "weapon":
			while (randItem == 0) {
				//Don't want Fists, those aren't really a weapon
				randItem = Math.round(Math.random() * (globals.weapons.length - 1));
			}
			
			madeItem = globals.weapons[randItem].copyItem();
		case "ring":
			randItem = Math.round(Math.random() * (globals.rings.length - 1));
			
			madeItem = globals.rings[randItem].copyItem();
		default:
			new AlertBox("Unknown item type: " + item);
		}
		
		//Add special effects base on item rarity
		madeItem.rarity = rarity;
		switch(madeItem.rarity) {
		case "common":
			//Common items get one ability
			rare = 1;
		case "uncommon":
			//uncommons get two
			rare = 2;
		case "rare":
			//Rare get three
			rare = 3;
		case "epic":
			//epics get four
			rare = 4;
		case "legendary":
			//legendary get five
			rare = 5;
		}
		
		madeItem.specials = new Array();
		
		for (i in 0...rare) {
			madeItem.specials.push(generateAbility(rare));
		}
		
		return madeItem;
	}
	
	static function generateAbility(rarity:Int):String {
		var abilities:Array<String> = new Array();
		var chooseAbility:String = "";
		var improveBy:Int = 0;
		
		while (improveBy == 0) {
			improveBy = Math.round(Math.random() * (rarity * 10));
		}
		
		abilities = ["str", "agi", "end", "int", "health", "spot", "dodge", "run", "melee", "sneak"];
		
		while (chooseAbility == "" || chooseAbility == null) {
			chooseAbility = abilities[Math.round(Math.random() * abilities.length - 1)];
		}
		
		return chooseAbility + "|" + improveBy;
	}
	
	static function catchRefError( e:ReferenceError ) {
		var message:String = "";
		
		message = e.message;
		
		printError(message);
	}
	
	static function reportError( e:UncaughtErrorEvent ) {
		var message:String;
		
		if (e.error == "Error") {
			message = e.error.message;
		} else if (e.error == "ErrorEvent") {
			message = e.error.text;
		} else {
			message = e.error.toString();
		}
		
		printError(message);
	}
	
	static function printError( errorMessage:String ) {
		var message:String = "Flash has encountered an error, please report the following;</p><hr><p>";
		
		outputText(message + errorMessage);
		return;
	}
	
	static function doSaveComplete( e:Event ) {
		fileSaveObject.removeEventListener(Event.COMPLETE, doSaveComplete);
		fileSaveObject.removeEventListener(Event.CANCEL, doSaveCancel);
		
		outputText("Game saved to file.", "Save Game");
		btns[11].setButton("Next");
		btns[11].setClickFunc(optionsScreen);
	}
	
	static function doSaveCancel( e:Event ) {
		fileSaveObject.removeEventListener(Event.CANCEL, doSaveCancel);
		
		outputText("Save attempt canceled by player request.", "Save Game");
		btns[11].setButton("Next", null, 0);
		btns[11].setClickFunc(saveGame);
	}
	
	static function doLoadCancel( e:Event ) {
		fileSaveObject.removeEventListener(Event.SELECT, doFileLoad);
		fileSaveObject.removeEventListener(Event.COMPLETE, doDataLoad);
		fileSaveObject.removeEventListener(Event.CANCEL, doLoadCancel);
		fileSaveObject = null;
		
		outputText("Load attampt canceled by player request.", "Load Game");
		btns[11].setButton("Next", null, 0);
		btns[11].setClickFunc(loadGame);
	}
	
	static function doFileLoad( e:Event ) {
		fileSaveObject.load();
	}
	
	static function doDataLoad( e:Event ) {
		var saveBytes:ByteArray = new ByteArray();
		var loadedFileSaveObject:MyFileSaveObject = new MyFileSaveObject();
		
		saveBytes = fileSaveObject.data;
		
		try { saveBytes.inflate(); } catch (myError:Error) { outputText("Failed to decompress saved data."); return; }
		
		try { loadedFileSaveObject = saveBytes.readObject(); } catch (myError:Error) {
			outputText("Object Load Error: " + myError.message);
			return;
		}
		
		fileSaveObject.removeEventListener(Event.SELECT, doFileLoad);
		fileSaveObject.removeEventListener(Event.COMPLETE, doDataLoad);
		fileSaveObject.removeEventListener(Event.CANCEL, doLoadCancel);
		fileSaveObject = null;
		
		if (loadedFileSaveObject.save[0] < globals.minBuildNumber) {
			//This code should never trigger as it shouldn't be possible for the player to try and load a save with a buildNumber less the 16
			//It's here just in case, as well as to mark where any other version checking should go.
			outputText("Incompatable save data");
			btns[11].setButton("Next");
			btns[11].setClickFunc(welcomeScreen);
			return;
		}
		if (loadedFileSaveObject.save[0] == 16) {
			loadedFileSaveObject.player.equipArmObj = globals.armor[0];
			loadedFileSaveObject.save[0] = 17;
		}
		
		globals.debugMode = loadedFileSaveObject.globals[0];
		globals.textSize = loadedFileSaveObject.globals[1];
		globals.allowScat = loadedFileSaveObject.globals[2];
		globals.allowSex = loadedFileSaveObject.globals[3];
		globals.allowedGenders = loadedFileSaveObject.globals[4];
		globals.difficulty = loadedFileSaveObject.globals[5];
		
		globals.currentRoomID = loadedFileSaveObject.save[1];
		playerCharacter = loadedFileSaveObject.player;
		
		updateHUD();
		outputText("Game loaded from file.", "Load Game");
		
		btns[11].setButton("Next", null, globals.currentRoomID + ":0");
		btns[11].setClickFunc(movePlayer);
	}
	
	static function npcAttack():String {
		var message:String = "";
		var damage:Int = 0;
		var attackAction:Int = -1;
		var fatAbsorbed:Bool = false;
		
		/*NPC gets a chance to attack;
		 * 0 - 6: Strike
		 * 7 - 8: Grab
		 * 9 - Run
		 * 
		 * Action should be weighted towards strike
		 */ 
		
		if (playerCharacter.healthCurr <= 0)
			return ">KILLED<"; //Somehow the player is in combat with no health. Lets correct that.
		
		attackAction = Math.round(Math.random() * 10);
		
		if (attackAction <= 6)
			attackAction = 10;
		if (attackAction >= 7 && attackAction <= 8)
			attackAction = 11;
		if (attackAction == 9)
			attackAction = 12;
		
		//NPCs need weapons, work on that later
		
		switch (attackAction) {
		case 10:
			//Strike
			if (grabbedPC) {
				//NPC has a hold of the player, crush
				damage = rollDie(roomNPC.strength());
				
				if (damage < 1)
					damage = roomNPC.strength(); //minimum damage
				
				damage = damage - playerCharacter.equipArmObj.defend; //Player's armor eats damage
				if (playerCharacter.hasPerk("narmor1")) {
					damage -= 10;
					if (damage <= 0)
						fatAbsorbed = true;
				}
				if (playerCharacter.hasPerk("narmor2")) {
					damage -= 10;
					if (damage <= 0)
						fatAbsorbed = true;
				}
				if (playerCharacter.hasPerk("narmor3")) {
					damage -= 10;
					if (damage <= 0)
						fatAbsorbed = true;
				}
				if (damage <= 0 && !fatAbsorbed) {
					message = "The [NPCNAME] squeezes you, but your armor blocks the damage.<br>";
				} else if (damage <= 0 && fatAbsorbed) {
					message = "The [NPCNAME] squeezes you, but your thick protective layer of fat absorbs the damage.<br>";
				} else {
					playerCharacter.healthCurr = playerCharacter.healthCurr - damage;
					
					message = "The [NPCNAME] squeezes you for " + damage + " damage.<br>";
				}
				
				if (playerCharacter.healthCurr <= 0)
					return ">KILLED<";
			} else {
				//if player isn't grabbed;
				if (rollDie(roomNPC.agility() + roomNPC.skillMelee()) > rollDie(playerCharacter.agility() + playerCharacter.skillDodge())) {
					//player hit
					damage = rollDie(roomNPC.strength());
					
					if (damage < 1)
						damage = roomNPC.strength(); //minimum damage
					
					damage = damage - playerCharacter.equipArmObj.defend; //Player's armor eats damage
					if (playerCharacter.hasPerk("narmor1")) {
						damage -= 10;
						if (damage <= 0)
							fatAbsorbed = true;
					}
					if (playerCharacter.hasPerk("narmor2")) {
						damage -= 10;
						if (damage <= 0)
							fatAbsorbed = true;
					}
					if (playerCharacter.hasPerk("narmor3")) {
						damage -= 10;
						if (damage <= 0)
							fatAbsorbed = true;
					}
					if (damage <= 0 && !fatAbsorbed) {
						message = "The [NPCNAME] strikes you, but your armor blocks the damage.<br>";
					} else if (damage <= 0 && fatAbsorbed) {
						message = "The [NPCNAME] strikes you, but your thick protective layer of fat absorbs the damage.<br>";
					} else {
						playerCharacter.healthCurr = playerCharacter.healthCurr - damage;
						
						message = "The [NPCNAME] strikes you for " + damage + " damage.<br>";
					}
					
					if (playerCharacter.healthCurr <= 0)
						return ">KILLED<";
				} else {
					//player dodges
					message += "The [NPCNAME] swings at you but you skillfully evade [POS] swing.<br>";
					message += playerCharacter.advanceSkill(1, "agi");
					message += playerCharacter.advanceSkill(1, "dodge");
				}
			}
		case 11:
			//Grab attempt
			if (grabbedPC) {
				//player grabbed, reroll
				message = npcAttack();
				return message;
			} else {
				if (rollDie(roomNPC.agility() + roomNPC.skillMelee()) > rollDie(playerCharacter.agility() + playerCharacter.skillDodge())) {
					//player gets caught
					message += "The [NPCNAME] lunges forward and grabs you tightly.<br>";
					grabbedPC = true;
				} else {
					//player evades the grab
					message += "The [NPCNAME] lunges forward but you evade [POS] grasp.<br>";
					message += playerCharacter.advanceSkill(1, "agi");
					message += playerCharacter.advanceSkill(1, "dodge");
				}
			}
		case 12:
			//Run attempt
			if (grabbedPC) {
				//player grabbed, let them go
				message += "The [NPCNAME] releases you and steps back, ready for another attack.<br>";
				grabbedPC = false;
			} else {
				if (rollDie(roomNPC.agility() + roomNPC.skillRun()) > rollDie(playerCharacter.agility() + playerCharacter.skillRun())) {
					//NPC escapes
					message = ">ESCAPE<";
				} else {
					//NPC fails to escape
					message += "The [NPCNAME] turns and flees but you keep with [OBJ] until [SUBJ] stops and turns back towards you.<br>";
				}
			}
		default:
			message = "Error: bad attackAction value: " + attackAction + " in npcAttack<br>";
		}
		
		return message;
	}
	
	static function truncateDecimalPlaces(InVal:Float):String {
		//Thanks for this by the way, I couldn't figure out how to get it to work in HaXe since the ActionScript function doesn't work -- Kyra
		
		// Round to 2 decimal places
		InVal *= 100;
		InVal = Math.ffloor(InVal);
		InVal /= 100;
		return "" + InVal;
	}
	
	static function rollDie( numDie:Int ):Int {
		var rndNum:Int;
		var numSucc:Int = 0;
		var diceToRoll:Int = numDie;
		
		for (i in 0...diceToRoll) {
			rndNum = Math.round(Math.random() * 10);
			
			if ( rndNum == 10 )
				diceToRoll += 1;	// exploding tens
			
			if ( rndNum >= 7 )
				numSucc += 1;
			
			if ( rndNum == 0 )
				diceToRoll += 1;	// reroll on a 0 becuase that's not a valid result
			
			numDie -= 1;
		}
		
		return numSucc;
	}
	
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
		var parsedText:String = "";
		
		var text:TextField = new TextField();
		
		if (title != null) {
			formattedText += "<span class = 'title'>" + title + "</span><br>";
			for (n in 0...20) {
				formattedText += "—";
			}
			formattedText += "<br>";
		}
		
		//parse in-text variables
		parsedText = textParse(body);
		
		formattedText += "<font size = '" + textSize + "'><p>" + parsedText + "</p></font></body>";
		
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
		var variableText:String = "";
		var valueText:String = "";
		var variableArray:Array<String> = new Array();
		var valueArray:Array<String> = new Array();
		var parseArray:Array<String> = new Array();
		var parsedText:String = "";
		var outputText:String = "";
		
		var recordingVar:Bool = false;
		var recordingValue:Bool = false;
		
		var i:Int = 0;
		
		while (i < text.length) {
			if (text.substr(i, 1) == "]" && recordingValue) {
				valueArray.push(valueText);
				recordingValue = false;
				i++;
			}
			if (text.substr(i, 1) == "]" && !recordingValue) {
				variableArray.push(variableText);
				valueArray.push(null);
				recordingVar = false;
				i++;
			}
			if (text.substr(i, 1) == "[") {
				parseArray.push(parsedText);
				parsedText = "";
				recordingVar = true;
				variableText = "";
				i++;
			}
			if (text.substr(i, 1) == ":" && recordingVar) {
				recordingVar = false;
				variableArray.push(variableText);
				recordingValue = true;
				valueText = "";
				i++;
			}
			if (recordingVar) {
				variableText += text.substr(i, 1);
				i++;
			}
			if (recordingValue) {
				if (text.substr(i, 1) == "{" || text.substr(i, 1) == "}") {
					if (text.substr(i, 1) == "{")
						valueText += "[";
					if (text.substr(i, 1) == "}")
						valueText += "]";
				} else {
					valueText += text.substr(i, 1);
				}
				i++;
			}
			if (!recordingValue && !recordingVar) {
				parsedText += text.substr(i, 1);
				i++;
			}
		}
		
		parseArray.push(parsedText);
		
		for (n in 0...valueArray.length) {
			if (valueArray[n] != null)
				valueArray[n] = textParse(valueArray[n]);
		}
		
		var m:Int = 0;
		
		for (n in 0...parseArray.length) {
			outputText += parseArray[n];
			if (variableArray.length > m) {
				outputText += checkVar(variableArray[m], valueArray[m]);
				m++;
			}
		}
		
		return outputText;
	}
	
	static function checkVar(text:String, ?value:String):String {
		var parsedText:String = "";
		
		switch (text) {
		case "PCNAME":
			parsedText = playerCharacter.name;
		case "PCNAMEC":
			parsedText = playerCharacter.name.toUpperCase();
		case "PCSPECIESC":
			parsedText = playerCharacter.species.name;
		case "PCSPECIESL":
			parsedText = playerCharacter.species.name.toLowerCase();
		case "PCARMS":
			parsedText = playerCharacter.arms;
		case "PCLEGS":
			parsedText = playerCharacter.legs;
		case "PCSKIN":
			parsedText = playerCharacter.skin;
		case "PCMOUTH":
			parsedText = playerCharacter.mouth;
		case "PCHANDS":
			parsedText = playerCharacter.hands;
		case "PCFEETS":
			parsedText = playerCharacter.feet;
		case "NPCNAME":
			parsedText = roomNPC.name;
		case "NPCGENDER":
			parsedText = roomNPC.gender("gender");
		case "NPCGENDERL":
			parsedText = roomNPC.gender("gender").toLowerCase();
		case "SUBJC":
			parsedText = roomNPC.gender("sub");
		case "SUBJ":
			parsedText = roomNPC.gender("sub").toLowerCase();
		case "OBJC":
			parsedText = roomNPC.gender("obj");
		case "OBJ":
			parsedText = roomNPC.gender("obj").toLowerCase();
		case "POSC":
			parsedText = roomNPC.gender("pos");
		case "POS":
			parsedText = roomNPC.gender("pos").toLowerCase();
		case "WOUNDED":
			parsedText = roomNPC.wounded();
		case "HasBreasts":
			if (roomNPC.breasts)
				parsedText = value;
		case "HasVagina":
			if (roomNPC.vagina)
				parsedText = value;
		case "HasPenis":
			if (roomNPC.penis)
				parsedText = value;
		case "HasBalls":
			if (roomNPC.balls)
				parsedText = value;
		case "HasPandV":
			if (roomNPC.penis && roomNPC.vagina)
				parsedText = value;
		
		default:
			parsedText = "[" + text + "]";
		}
		
		return parsedText;
	}
	
	static function convertSpaces(textToConvert:String):String {
		var spacedLine:String = "";
		
		for (i in 0...textToConvert.length) {
			if (textToConvert.charAt(i) == "_") {
				spacedLine += " ";
			} else {
				spacedLine += textToConvert.charAt(i);
			}
		}
		
		return spacedLine;
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
		
		if (playerCharacter.fat < 0)
			playerCharacter.fat = 0;
		
		txtName.htmlText = "<body><font size = '" + globals.textSize + "'><p>" + playerCharacter.name + "</p></font></body>";
		txtHealth.htmlText = "<body><font size = '" + globals.textSize + "'><p>Health: " + playerCharacter.healthCurr + "/" + playerCharacter.health() + "</p></font></body>";
		txtStomach.htmlText = "<body><font size = '" + globals.textSize + "'><p>Fullness: " + Math.round(playerCharacter.stomachCurrent) + "/" + Math.round(playerCharacter.stomachCap) + "</p></font></body>";
		txtWeight.htmlText = "<body><font size = '" + globals.textSize + "'><p>Weight: " + truncateDecimalPlaces(playerCharacter.totalWeight()) + "lbs</p></font></body>";
		txtFat.htmlText = "<body><font size = '" + globals.textSize + "'><p>Fatness: " + playerCharacter.fat + "</p></font></body>";
		txtMoney.htmlText = "<body><font size = '" + globals.textSize + "'><p>$" + playerCharacter.getMoney() + "</p></font></body>";
		txtStr.htmlText = "<body><font size = '" + globals.textSize + "'><p>Strength: " + playerCharacter.strength() + "</p></font></body>";
		txtAgi.htmlText = "<body><font size = '" + globals.textSize + "'><p>Agility: " + playerCharacter.agility() + "</p></font></body>";
		txtEnd.htmlText = "<body><font size = '" + globals.textSize + "'><p>Endurance: " + playerCharacter.endurance() + "</p></font></body>";
		txtInt.htmlText = "<body><font size = '" + globals.textSize + "'><p>Intelligence: " + playerCharacter.intelligence() + "</p></font></body>";
		
		if (globals.allowSex)
			txtArousal.htmlText = "<body><font size = '" + globals.textSize + "'><p>Arousal: " + truncateDecimalPlaces(playerCharacter.arousal) + "%</p></font></body>";
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
		txtPublic.y = 12;
		txtPublic.width = 34;
		txtPublic.height = 26;
		txtPublic.border = false;
		txtPublic.text = "Public";
		txtPublic.visible = false;
		txtPublic.background = true;
		
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
		txtTime.y = 458;
		txtTime.width = 200;
		txtTime.height = 22;
		txtTime.htmlText = "Time";
		txtTime.selectable = false;
		txtTime.visible = false;
		txtTime.background = true;

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
		btnDebugDump = new MyButton(720, 265);
		
		btns[0].addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, reportError);
		
		charDesc.name = "Desc Button";
		optionsBtn.name = "Options Button";
		
		charDesc.setButton("Description", null, 0);
		optionsBtn.setButton("Options");
		btnDebugDump.setButton("Data Dump", null, null, debugDump);
		
		charDesc.addEventListener(MouseEvent.CLICK, doDescription);
		optionsBtn.addEventListener(MouseEvent.CLICK, optionsScreen);
		
		charDesc.visible = false;
		optionsBtn.visible = false;
		btnDebugDump.visible = false;
	}
	
	static function initialize() {
		var allSpecies:Array<Dynamic> = new Array();
		var perks:Array<Dynamic> = new Array();
		var characters:Array<Dynamic> = new Array();
		var weapons:Array<Dynamic> = new Array();
		var armor:Array<Dynamic> = new Array();
		var ring:Array<Dynamic> = new Array();
		
		quests = new Array();
		globals = new GlobalVars();
		globals.name = "GlobalVars";
		Lib.current.addChild(globals);
		
		AMFConnection.registerClassAlias("consume.playerObject", MyPlayerObject);
		AMFConnection.registerClassAlias("consume.questObject", MyQuest);
		AMFConnection.registerClassAlias("consume.perkObject", MyPerk);
		AMFConnection.registerClassAlias("consume.speciesObject", MySpecies);
		AMFConnection.registerClassAlias("consume.NPCObject", MyNPC);
		AMFConnection.registerClassAlias("consume.keyObject", MyItem_Key);
		AMFConnection.registerClassAlias("consume.weaponObject", MyItem_Weapon);
		AMFConnection.registerClassAlias("consume.fileSaveObject", MyFileSaveObject);
		AMFConnection.registerClassAlias("consume.armorObject", MyItem_Armor);
		AMFConnection.registerClassAlias("consume.ringObject", MyItem_Ring);
		
		//Species, both playable and non
		species = new Array();
		
		//																																Height			Weight			Chest			Waist			Hips			Butt																													Gain
		//allSpecies = [0 name,		1 skin,		2 tail,		3 tailDesc,		4 mouth,	5 legs,		6 arms,		7 hands,	8 feet,		9 min,	10 max,	11 min,	12 max,	13 min,	14 max, 15 min,	16 max,	17 min,	18 max, 19 min, 20 max, 21 breasts, 22 penisL,	23 penisW,	24 balls,	25 errect,	26 stomach, 27 bowels,	28 milk,	29 cum, 30 fat, 31 milk, 32 cum, 33 digestDamage,	34 stretchRateStomach,	35 stretchRateBowels,	36 stretchRateMilk, 37 stretchRateCum,	38 stretchAmountStomach,	39 stretchAmountBowels, 40 stretchAmountMilk,	41 stretchAmountCum,	42 sphincter
		allSpecies[0] = ["Human",	"skin",		false,		"none",			"mouth",	"legs",		"arms",		"hands",	"feet",		63,		72,		90,		140,	24,		30,		22,		29,		22,		26, 	1,		2,		3,			4,			1,			.5,			2,			20,			10,			3,			1,		5,		.5,		 .1,	 .1,				30,						20,						20,					15,					20,							10,						1,						.5,						"asshole"];
		allSpecies[1] = ["Fox",		"fur",		true,		"large fluffy",	"muzzle",	"legs",		"arms",		"handpaws",	"footpaws",	60,		69,		85,		100,	22,		26,		20,		25,		20,		24,		1,		3,		8,			3,			1.5,		.5,			3,			15,			15,			2.5,		2,		4,		.3,		 .4,	 .2,				15,						10,						15,					20,					15,							15,						1.5,					2,						"tailhole"];
		allSpecies[2] = ["Dragon",	"scales",	true,		"thick scally",	"maw",		"legs",		"arms",		"claws",	"feet",		78,		82,		150,	210,	30,		38,		28,		37,		30,		34,		1,		4,		10,			6,			2,			1,			3.5,		30,			20,			4,			4,		6,		1.5,	 .7,	 .5,				40,						10,						5,					5,					40,							5,						10,						2,						"tailhole"];
		allSpecies[3] = ["Wolf",	"fur",		true,		"thin fluffy",	"muzzle",	"legs",		"arms",		"handpaws",	"footpaws",	63,		72,		100,	150,	26,		32,		26,		31,		28,		28,		1,		2,		4,			5,			2.5,		1,			2,			25,			10,			5,			1,		3,		1,		 2,		 1,					30,						20,						10,					10,					30,							10,						10,						5,						"tailhole"];
		allSpecies[4] = ["Bovine",	"skin",		true,		"thin whiplike", "muzzle",	"legs",		"arms",		"handhoofs", "foothoofs", 65,	80,		160,	210,	34,		36,		30,		31,		30,		46,		1,		6,		9,			8,			3,			2.5,		4,			40,			30,			10,			6,		10,		3,		 .2,	 1,					20,						15,						15,					10,					50,							20,						20,						10,						"tailhole"];
		allSpecies[5] = ["Tiger",	"fur",		true,		"long fluffy",	"muzzle",	"legs",		"arms",		"handpaws",	"footpaws",	64,		73,		95,		100,	22,		31,		18,		31,		29,		32,		1,		5,		2,			4,			2,			1,			2,			25,			20,			3,			3,		2,		1,		 .3,	 .6,				40,						30,						30,					15,					5,							10,						5,						2,						"tailhole"];
		allSpecies[6] = ["Rat",		"fur",		true,		"thin hairless", "muzzle",	"legs",		"arms",		"handpaws",	"footpaws",	55,		59,		70,		85,		20,		25,		18,		24,		20,		25,		1,		2,		1,			2,			1,			.25,		1.5,		50,			10,			3,			2,		2,		1,		 2,		 .5,				70,						40,						30,					10,					20,							20,						10,						5,						"tailhole"];
		
		
		
		
		
		for (i in 0...allSpecies.length) {
			species.push(new MySpecies());
			species[species.length - 1].newSpecies(allSpecies[i]);
		}
		
		//Perks, even hidden ones
		globals.perks = new Array();
		
		//			Name		Display Name		Description															Effect				Buyable, if false the perk can only be granted by an event. Not bought.  Multiple levels
		perks.push(["comps",    "Compressable",		"You can cram your body through any opening, no matter how small.", "DOOR:YES",			true,		false]);
		
		perks.push(["ineat",	"Inedible",			"You cannot be eaten.",												"EATEN:NO",			true,		false]);
		perks.push(["nskinny",	"Naturally Skinny",	"Burn fat at an increased rate.",									"FAT:-10",				true,	true]);
		perks.push(["nchubby",	"Naturally Chubby", "Gain more fat from food.",											"FAT:*2",				true,   true]);
		perks.push(["narmor",	"Natural Armor",	"Gain 10 armor as long as you have at least 100 fat.",				"IF(FAT>100)|ARMOR:+10", true,  true]);
		perks.push(["bellyb",	"Belly Bash",		"Gain a bash attack with your stomach as long as it contains at least 100 mass of prey.",	"IF(STOMACH>100)|BASH:10", true, false]);
		perks.push(["httr",		"Heavy Hitter",		"Deal more damage in combat with melee attacks.",					"ATTACK:+10",			true,   true]);
		perks.push(["fstm",		"Fast Metabolism",	"Heal faster while you have prey in your stomach.",					"DIGESTHEAL:+10",		true,   true]);
		perks.push(["clctr",	"Collector",		"More likely to find items on defeated (or eaten) foes.",			"ITEMCHANCE:+10",		true,   false]);
		perks.push(["bigbly",	"Big Belly",		"Even when empty, your belly is bigger than most.",					"BELLYSIZE:+100",		true,   true]);
		perks.push(["mtn",		"The Mountian",		"When rendered immobile you cannot be attacked.", 					"IF(IMMOBLE)|ATTACK:NO", true,  false]);
		perks.push(["pit",		"Bottomless Pit",	"You are always hungry and can continue to consume prey even when immoble.", "IF(IMMOBLE)|EAT:YES", true, false]);
		perks.push(["bgbst",	"Big Breasts",		"Your breasts are larger than most.",								"BREASTSIZE:+4",		true,   true]);
		perks.push(["bgcok",	"Big Cock",			"Your penis is bigger than most.",									"PENISLENGTH:+6 PENISWIDTH:+2",	true, true]);
		perks.push(["bgbls",	"Big Balls",		"Your balls are larger than most.",									"BALLSIZE:+4",			true,   true]);
		perks.push(["hpr",		"Hyper",			"Your everything is bigger than most.",								"BELLYSIZE:+200 BREASTSIZE:+6 PENISLENGTH:+6 PENISWIDTH:+4 BALLSIZE:+8", true, true]);
		perks.push(["inbal",	"Internal Balls",	"You make cum, despite not having hanging balls.",					"CUM:YES",				true,   false]);
		perks.push(["mulbo",	"Multiboob",		"You have an additional pair of breasts.",							"BREASTS:+2",			true,   true]);
		
		perks.push(["mulcoc",	"Multicock",		"You have an additional cock.",										"PENIS:+1",				true,   true]);
		
		perks.push(["mscl",		"Big Muscles",		"Your muscles are naturally big.",									"MUSCLES:+5",			true,   true]);
		
		perks.push(["afem",		"Always Female",	"You will always be referred to in the femmine, reguardless of genitalia.", "GENDER:Female", true,  false]);
		perks.push(["amale",	"Always Male",		"You will always be referred to in the masculane, reguardless of genitalia.", "GENDER:Male", true,  false]);
		perks.push(["aherm",	"Always Herm",		"You will always be referred to in the hermaphroditic, reguardless of genitalia.", "GENDER:Herm", true, false]);
		
		
		perks.push(["taur",		"Taur",				"You have the elongated lower half of a taur. Not Implamented.",	"TAUR WEIGHT:+100 STOMACHCAP:+100 IMMOBILE:-100", true, false]);
		
		perks.push(["dbg1",		"DEBUG1 -- Huge",	"For debugging only; hugeness -- Warning may cause problems, enable at own risk", "BREASTSIZE:+24 BELLYSIZE:+65000 BALLSIZE:+24 PENISLENGTH:+50 PENISWIDTH:+45",	true, false]);
		
		
		
		//vore types
		perks.push(["cv",	"Cock Vore",	"Consume prey using your cock and turn them into cum.",		"COCKVORE",		false, false]);
		perks.push(["bv",	"Breast Vore",	"Consume prey using your breasts and turn them into milk.",	"BREASTVORE",	false, false]);
		perks.push(["av",	"Anal Vore",	"Consume prey using your butt, then digest them.",			"ANALVORE",		false, false]);
		perks.push(["ub",	"Unbirth",		"Consume prey using your vagina, then absorb them.",		"UNBIRTH",		false, false]);
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
		globals.exits[35] = ["Ice Cream",		false,	8,			20,			26,				5,			50,			86];
		globals.exits[36] = ["Street",			false,	0,			0,			6,				5,			50,			86];
		globals.exits[37] = ["Backroom",		false,	0,			0,			27,				5,			50,			86,		null,	null,	4];
		globals.exits[38] = ["Storefront",		false,	0,			0,			26,				5,			50,			86];
		globals.exits[39] = ["Freezer",			false,	0,			0,			28,				5,			50,			86,		"The shop's large walk-in freezer"];
		globals.exits[40] = ["Restroom",		false,	0,			0,			29,				5,			50,			86];
		globals.exits[41] = ["Office",			false,	0,			0,			30,				5,			50,			86];
		globals.exits[42] = ["Warehouse",		false,	0,			0,			31,				5,			55,			84,		null,	null,	5];
		globals.exits[43] = ["Storefront",		false,	0,			0,			19,				5,			55,			84];
		globals.exits[44] = ["Backroom",		false,	0,			0,			32,				10,			55,			84];
		
		
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
		globals.rooms[8]  = ["Back Alley",				null, 	null,	9,		null,	null,	null,	null,	null,	[3, [2, "rat"]], false,	false,		5,			"A dim alley running along the side of the club. It ends in a small loading dock area with a dumpster next to a locked door. There is a short drive leading to the street providing access to the dock. Halfway down the alley you find a small alcove, standing in it is a figure in a dark cloak."];
		globals.rooms[9]  = ["Consume - Dance Floor",	null,	16,		null,	13,		12,		19,		18,		null,	[[1, "passive"]], false, true,		null,		"The main room of Consume is mostly taken up by a dance floor. Along one wall is the bar, several bartenders work behind it serving drinks to thirsty patrons. Opposite the bar is a stage for live bands to preform on. It is currently empty, music being piped in from speakers hidden in the club. Across from the main entrance is a set of stairs leading to the upper balcony with a door under the steps leading to the devourment rooms."];
		globals.rooms[10] = ["Consume - Back Hall",		null,	15,		null,	null,	14, 	null,	null,	null,	[0],		true,		true,		null,		"A short hall lined with rooms on either side. Behind each door is a sparsely furnished room with little more then a lamp and a bed. At the far end of the hall is a door marked &quot;Staff Only.&quot; All the doors are locked from this side."];
		globals.rooms[11] = ["Consume - Restroom",		null,	null,	null,	null,	null,	null,	13,		null,	[5],		true,		false,		null,		"A standard single-occupancy restroom. The door locks."];
		globals.rooms[12] = ["Consume - Bar",			null,	null,	null,	null,	null,	null,	17,		null,	[0],		true,		true,		null,		"A long polished bar, running the length of the room. Like most movie bars the back wall of this one is backed by a mirror with interesting or unique liquor bottles along the shelf before it. Several individuals sit on barstools enjoying various drinks. Most seem more interested in their drink then in talking however, not that the music really allows for conversations."];
		globals.rooms[13] = ["Consume - Stage",			null,	17,		null,	null,	null,	null,	null,	null,	[0],		false,		true,		null,		"The club's stage. A drumset sits covered and ignored by the crowd. You're not really sure where the music is being piped in from. There's not much of interest here."];
		globals.rooms[14] = ["Consume - Balcony",		null,	null,	14,		20,		null,	null,	null,	null,	[0],		false,		true,		null,		"An open sided stair leads to a balcony overlooking the dance floor. A number of tables and chairs scattered in groups cover the area and some clever acoustics mute enough of the music to allow for conversation. There are a few groups up here enjoying the relative quiet. Some of them are doing more then just talking. There is a door in the back wall, marked &quot;Lounge&quot;. It's guarded by another of the club's bouncers."];
		globals.rooms[15] = ["Consume - Lounge",		null,	null,	null,	null,	19,		null,	null,	null,	[0],		true,		true,		null,		"The predator's lounge is a large dark room. Several groups of chairs and couches are arranged around the room allowing predators a place to sit and digest. A number of preds are taking advantage of this, large bellies resting on tables or other rests designed for such use. In the back of the room, under a large light that's giving most of the illumination in the room, sits a poker table. It is currently unoccupied."];
		globals.rooms[16] = ["North Main Street",		null,	23,		null,	28,		26,		null,	7,		null,	[0],		false,		true,		null,		"What is probably best referred to as the town's market district. It's rather depressing really, there is only a single general store here, located in a tiny building to the east. Across the street to the west is a modern gym, you've never gone inside it before, but perhaps now it would be worth it to take a peek inside. North of here the road heads out of town eventually leading to the highway and the rest of the country. Before it gets that far, and still within walking distance, sits the town's hospital."];
		globals.rooms[17] = ["Hospital - Waiting Room",	null,	null,	null,	44,		24,		null,	22,		null,	[0],		true,		true,		null,		"A typical hospital waiting area, the reception desk is always occupied by someone looking tired and slightly haggard. You idly wonder if the expression comes with the job, or if it's the other way around. There isn't much to see or do here other then wait, the staff isn't going to let you any deeper into the hospital unless there's something wrong with you."];
		globals.rooms[18] = ["Hospital - Pharmacy",		null,	null,	null,	25,		null,	null,	null,	null,	[0],		false,		true,		null,		"The pharmacy counter of the local hospital, the steel cage keeping random people out is closed and no one seems to be around at the moment. Looks like the pharmacist is out at the moment."];
		globals.rooms[19] = ["General Store",			null,	null,	null,	27,		null,	null,	42,		null,	[3, [2, "general"]], false,	true,	6,			"The array of junk occupying this store is truly impressive. You feel that, had you the time and desire, you could find some truly remarkable things here. Alas the haphazard piles and disorganized clutter make you fear for your safety as you navigate to the counter."];
		globals.rooms[20] = ["Gym - Reception",			null,	null,	null,	29,		27,		null,	null,	null,	[3],		false,		true,		1,			"The reception room of this gym is comfortable and modern. Several comfortable looking chairs wait to either side, with a reception desk at the end of the room. A door next to the desk is marked &quot;Members Only&quot; and seems to lead into the main workout area, visible from outside though the large floor to ceiling windows along the street facing wall. A keycard reader next to the door ensures only those with the proper access can get in the building."];
		globals.rooms[21] = ["Gym - Workout Area",		null,	null,	null,	31,		30,		33,		32,		34,		[8],		false,		true,		null,		"A large open room filled with machines of every type. Each one designed to strengthen some aspect of your body. Each machine has a sign next to it with a visual description of how to use the machine as well as several warnings about using them correctly. The machines also seem to be grouped and numbered, it looks like if you pick a group and follow the numbers in sequence you'll get a good workout in that area.</p><br><p>The back wall of the room is a large mirror, both letting you see yourself working out and giving the illusion that the room is much larger then it appears. There are three doors in the room, the first heads back out through the reception area and then outside. Across the room from that is another door secured with a card reader, it has a sign on it that reads &quot;Gold Room&quot;. Set in the mirrored wall, and nearly invisible is a third door, a small &quot;Staff&quot; sign attached to it.</p><br><p>There are several others in various states of fitness moving around, though not enough to make the place feel crowded."];
		globals.rooms[22] = ["Gym - Gold Room",			null,	null,	null,	null,	29,		null,	null,	null,	[9],		false,		true,		null,		"Calling this room the 'Gold Room' is a bit of a misnomer, the room it's self isn't actually gold. Rather it's a smallish room with mirrors on all the walls. Machines circle the outside of the room, with a break in the line for the door. The machines claim to do all kinds of strange things to your body, and studying them closely you can almost understand why the gym owner limits their use.</p><br><p>The first machine to your left is the one the ill-fated ass Erik demonstrated for you, the straps and levers inside the machine will, somehow, make you several inches taller when you use it.</p><br><p>The next machine looks a lot like a play-doh press, only person-sized. The sticker on it states that it will squeeze the fat out of your body, leaving you with as close to 0% body fat as it's possible to get.</p><br><p>Siting next to that one, looking for all the world like some kind of lewd sex machine is one which the label states will make your dick, assuming you have one, larger.</p><br><p>Unsurprisingly the next machine, which looks a lot like a steampunk bidet, claims to make the balls of anyone who uses it larger. You have to wonder why Erik didn't bother with it.</p><br><p>The next contraption is very odd looking, it seems to be a combination of the last two, but different in some way you can't really pin down just by looking. The label on this machine says that it will make your erections larger.</p><br><p>Next is a machine that you almost recognize, it looks like a thigh sculptor, only more advanced. This machine says that it will slim your hips and thighs.</p><br><p>Last, the machine directly to your right as you come in, is another nearly familiar machine. This machine appears to be an advanced squat machine, the label saying that it will give you a smaller, tighter butt."];
		globals.rooms[23] = ["Gym - Staff Room",		null,	29,		null,	null,	null,	null,	null,	null,	[10],		false,		true,		null,		"This back room of this gym is clearly not an area customers are intended to see. Two walls are covered in the lockers of the employees. The wall opposite the door has a door and a window into which is the manager's office. Shay can usually be found somewhere in the area. Along side the window sits a vending machine mostly selling health drinks.</p><br><p>The middle of the room is dominated by an impressive contraption, you can't fathom what all the parts are supposed to be used for. According to Shay, this machine is supposed to make your chest bigger. Also according to him, it doesn't work correctly."];
		globals.rooms[24] = ["Gym - Restroom",			null,	null,	29,		null,	null,	null,	null,	null,	[5],		true,		false,		null,		"A standard single-occupancy restroom. The door locks."];
		globals.rooms[25] = ["Gym - Showers",			29,		null,	null,	null,	null,	null,	null,	null,	[0],		true,		false,		null,		"A short hallway leads to several shower stalls, providing gym goers a place to change and get cleaned up. Rows of small lockers are provided for customers to store any personal belongings they don't want to carry with them into the gym proper, it is bring your own lock however."];
		globals.rooms[26] = ["Ice Cream Shop",			null,	null,	null,	36,		37,		null,	null,	null,	[[2, "iceCream"]], false, true,		null,			"Your old place of employment, the local ice cream shop. They have all the basics; cones, sundaes even a few specialty items like shakes and splits. When you worked here you got all the ice cream you wanted, now you're going to have to pay for any you want. There's a door behind the counter, but you're pretty sure you'll get in trouble if you try going back there now."];
		globals.rooms[27] = ["Ice Cream Shop - Backroom", null, 40,		null,	38,		41,		null,	39,		null,	[0],		false,		true,		null,		"The back room of the ice cream shop set up as a break room, with a table and several chairs. The old TV you remember from when you worked here is still sitting on top of the refrigerator. From here there are three doors, one is the tiny rest room, one is the large walk-in freezer that holds the extra ice cream. The third door was always locked, but now you have a key for it."];
		globals.rooms[28] = ["Ice Cream Shop - Freezer", null,	37,		null,	null,	null,	null,	null,	null,	[0],		true,		false,		null,		"The freezer, it's very cold, naturally. And it's filled with tub after tub of ice cream ready to be sold in the shop. A quick look around and you're pretty sure there's enough here the shop will never run out, even at the rates people around here eat the stuff. Or at least it'll take a long time."];
		globals.rooms[29] = ["Ice Cream Shop - Restroom", null,	null,	null,	null,	null,	null,	37,		null,	[5],		true,		true,		null,		"A standard single-occupancy restroom. The door locks."];
		globals.rooms[30] = ["Ice Cream Shop - Office",	null,	null,	null,	37,		null,	null,	null,	null,	[0],		false,		false,		null,		"While you worked here you were never allowed into this room, you were pretty sure it was just an office since Bessie was usually in here when she was at the shop at all. Now that you can get in here you see that you were mostly correct. The area right inside the door looks like your typical office, a desk sits facing the door and covered in papers and files. An old computer monitor takes up one corner of the desk. You're pretty sure there's a keyboard somewhere under the papers, but you'd have to dig to find it. A pair of filing cabinets rest against the back wall, flanking the desk to either side.</p><br><p>Where the idea of a typical office breaks down is the area to the left of the desk. A raised lip separates the two areas and probably helps keep any spills from reaching the office or escaping out the door. The floor is tiled and gently slops towards the center where a drain is placed in the floor. Slightly offset from the center is a large wooden chair. It looks vaguely like a toilet, with a hole cut in the seat, but is lacking a bowl or tank. Instead it has long, very solid arms with straps hanging off them. The legs likewise have straps placed to go around the occupant's ankles. Behind the chair on a complicated hinge system is what appears to be an automatic milking machine, it looks like it can be moved over the chair and positioned in front of who ever is sitting in the chair. The hoses run to the far corner of the room where a large tank waits to be filled, there's also a machine next to the tank labeled 'Automatic Ice Cream Maker v2.0'"];
		globals.rooms[31] = ["General Store - Warehouse", null, 43,		null,	null,	null,	null,	null,	null,	[4],		true,		false,		null,		"A massive warehouse under the main shop filled with more stuff then you could possibly sort through in several lifetimes."];
		globals.rooms[32] = ["Hospital - Backroom",		null,	null,	null,	null,	25,		null,	null,	null,	[11],		true,		false,		null,		"A small room tucked away in the back of the hospital, almost a closet. The only item of note in here is a small machine, examining it closely it seems like you can use it to gain new perks for a small fee."];
		
		
		
		
		
		currentRoom = new MyRoom(globals.rooms[0]);
		
		
		//Items
		
		//Keys				Name						keyID	desc
		globals.keys = new Array();
		globals.keys[0] = ["Gym Membership Keycard",	0,		"A credit-card sized square of plastic with the gym's logo printed on it and a black background"];
		globals.keys[1] = ["Gym Gold Membership",		1,		"A credit-card sized square of plastic with the gym's logo printed on it and a gold background"];
		globals.keys[2] = ["Gym Staff Key",				2,		"A key you got from Shay, it opens the staff room door at the gym"];
		globals.keys[3] = ["Consume Red Band",			3,		"A tight fitting band with the logo of the local club on it. You can't get it off, but you often forget you're even wearing it."];
		globals.keys[4] = ["Ice Cream Shop Backroom key", 4,	"A key you got from Bessie that will let you into the back rooms of the ice cream shop. You're pretty sure this is the same key you had when you worked there."];
		globals.keys[5] = ["General Store key",			5,		"A key you got after agreeing to help out at the general store."];
		
		//Food
		globals.food = new Array();
		var foods:Array<Dynamic> = new Array();
		
		//          Name    Mass  Value   Description                    Healing value   Consume String
		foods.push(["Cheeseburger", 5, 2, "A thick greesy cheeseburger", ["heal|.1"], "Cheeseburger eat"]);
		foods.push(["Apple", 3, 5, "A ripe healthy apple", ["heal|.3"], "Apple eat"]);
		foods.push(["Cherry Pie", 10, 5, "A large cherry pie", ["heal|.2"], "Cherry pie eat"]);
		foods.push(["Chocolate Cake", 20, 7, "A huge chocolate cake, you're not really going to eat the whole thing are you?", ["heal|.01"], "Chocolate cake eat"]);
		foods.push(["BouncyButt", 5, 1, "A popular 'health' drink. It's basically just sugar and water.", ["heal|.05"], "You crack the top open on the bottle of BouncyButt and drink it down. It tastes mostly like water with just a little flavoring, though you can't quite pin down what it's supposed to be. You do feel a little better after drinking it. Curious you shake your butt a little, disappointed as you don't seem to have any more bounce then you did before."]);
		foods.push(["BouncyButt+", 5, 250, "A bottle of a popular 'health' drink, BouncyButt, that has been modified in some way.", ["heal|.05", "butt|1"], "You crack the top open on the bottle of BouncyButt and drink it down. It tastes mostly like water with just a little flavoring, though you can't quite pin down what it's supposed to be. You do feel a little better after drinking it. Curious you shake your butt a little and find there's just a little more bounce then there was before."]);
		
		
		for (i in 0...foods.length) {
			if (foods[i] != null) {
				globals.food.push(new MyItem_Food());
				globals.food[globals.food.length - 1].newFood(foods[i]);
			}
		}
		
		//Weapons
		globals.weapons = new Array();
		//Weapons    Name           Mass Value Desc                                   Attack TwoHand Finisher Specials
		weapons.push(["Fists",        0,    0,  "Your bare hands.",                     0,    true,  "You snap the [NPCNAME]'s neck, finishing [OBJ] off.<br>",    null]);
		weapons.push(["Knife",        3,    1, "A basic knife, used for cooking.",      2,    false, null,    null]);
		weapons.push(["Short Sword",  5,    5, "A short blade, made for combat.",       4,    false, null,    null]);
		weapons.push(["Curved Sword", 6,   10, "A curved balde, popular in the east.",  6,    false, null,    null]);
		weapons.push(["Longsword",   10,   15, "A heavy knight's weapon.",             10,    true,  null,    null]);
		weapons.push(["Hammer",       5,   11, "A workman's tool.",                     3,    false, null,    null]);
		weapons.push(["Sledge",      20,   15, "A heavy hammer made for breaking rocks.", 6,  true,  null,    null]);
		
		for (i in 0...weapons.length) {
			if (weapons[i] != null) {
				globals.weapons.push(new MyItem_Weapon());
				globals.weapons[globals.weapons.length - 1].newWeapon(weapons[i]);
			}
		}
		//Armor
		
		globals.armor = new Array();
		//Armor     Name   Mass  Value  Desc               Def  Special
		armor.push(["Skin", 0,     0,   "Your naked flesh", 0,   null]);
		armor.push(["Leather Jacket", 5, 10, "A thick leather biker's jacket. Not really intended for combat.", 2, null]);
		armor.push(["Armored Coat", 7, 15, "A heavy leather coat reinforced with hard plastic panels.", 7, null]);
		armor.push(["Breastplate", 20, 20, "A solid peice of shaped metal. Heavy, but good protection.", 10, null]);
		
		for (i in 0...armor.length) {
			if (armor[i] != null) {
				globals.armor.push(new MyItem_Armor());
				globals.armor[globals.armor.length - 1].newArmor(armor[i]);
			}
		}
		
		globals.rings = new Array();
		
		ring.push(["Gold Ring", 0, 50, "A small gold ring."]);
		ring.push(["Silver Ring", 0, 25, "A small silver ring."]);
		ring.push(["Electrum Ring", 0, 30, "A small electrum ring."]);
		ring.push(["Silver Ruby Ring", 0, 50, "A small silver ring set with a professionally cut ruby."]);
		ring.push(["Gold Ruby Ring", 0, 75, "A small gold ring set with a professionally cut ruby."]);
		ring.push(["Electrum Ruby Ring", 0, 55, "A small electrum ring set with a professionally cut ruby."]);
		
		for (i in 0...ring.length) {
			if (ring[i] != null) {
				globals.rings.push(new MyItem_Ring());
				globals.rings[globals.rings.length - 1].newRing(ring[i]);
			}
		}
		//Shoplists
		
		/* Shop format
		 * Item Type|Item|Price
		 * Types:
		 *  F - Food
		 *  W - Weapon
		 *  A - Armor
		 */
		
		var genShop:Array<Dynamic> = new Array();
		genShop = ["food|0", "food|1"]; //Item IDs for the items that are to be sold in the shop
		
		
		globals.shopLists = new Array();
		globals.shopLists[0] = genShop;
		
		
		//Quests
		//			Name		dispName			hidden		stageDesc	KeyID/Stage to give
		quests[0] = ["alley",	"Alley",			true,		["", "Discovered the hidden alley"],	null];
		quests[1] = ["club",	"Club Membership",	false,		["", "Joined the club", "Joined the club as prey"],	null];
		quests[2] = ["gym",		"Gym Membership",	false,		["", "Joined the gym", "Gold membership is avalible", "Became a gold member", "Spoke with Shay", "Spoke to Shay a second time", "Agreed to help Shay with his machine", "Became fuckbuddies with Shay"],	[0, 1]];
		quests[3] = ["death",	"A Deal With Death", true,		["", "Spoke with Hir", "Agreed to Hir deal", "Turned down the deal"], null];
		quests[4] = ["cv",		"Pleasing The Wolf", false,		["", "You tried to slip past the bouncer, it wasn't a good idea."], null];
		quests[5] = ["milk",	"Milking the Cow",	false,		["", "Tweaked her nipple", "Drunk after tweaking", "Milked her", "Agreed to help with her machine", "Heard instructions on using the chair", "Bessie is in the chair", "Eaten"]];
		quests[6] = ["job",		"Part Time Job",	false,		["You need one", "Accecpted the job in the general store"], null];
		quests[7] = ["foxboi",	"Guffin's Fate",	true,		["", "You've been fucking Guffin", "You've eaten Guffin. He was as tasty as you'd hoped."], null];
		
		
		
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
		var macTalk:Array<Dynamic> = new Array();
		macTalk[0] = ["A tall, extremely buff wolf stands next to a door. He watches you suspiciously with his arms crossed over his thick, bare chest. Thick gold bands with the club's logo, a silhouette of a vixen with something halfway down her throat, her big belly forming the 'C' in Consume, wrap around the wolf's biceps. Every time he flexes the bands looks like they're about to burst off.", ["talk"], [["Hi", "Say hello to the bouncer.", 1], ["Go in?", "Ask if you can go inside.", 2], ["Dart in", "He's huge, there's no way he can move that fast, just run past him and go inside.", 17, 2, 5, 0], ["Leave", null, -1]]];
		macTalk[1] = ["His eyes narrow slightly but otherwise he doesn't move. Just when you've about given up on getting a responce he growls, &quot;Hello.&quot;", ["talk"], [["Go in?", "Ask if you can go inside.", 2]]];
		macTalk[2] = ["You ask about going inside and the wolf watches you for a moment then grunts, &quot;Pred or Prey?&quot; Your confused look prompts him to sigh and produce a pamphlet from his back pocket. He seems to carry them around just so he doesn't need to talk anymore then he needs to.</p><br><p>Looking at the pamphlet it describes the difference between the red band predators and blue band prey, the key differences are that anyone who signs up for a blue band pays no cover and nothing for drinks. But they aren't allowed to leave. (Through the doors anyway.)</p><br><p>Red band pay a $200 cover, full price on drinks and $200 for each 'morsel.'</p><br><p>After you finish reading and look up the bouncer grunts again and repeats himself, &quot;Pred or Prey?&quot;", ["quest 1|value 0|skip 5|action skip"], [["Pred", "Join as a predator", 3], ["Prey", "Join as prey", 30], ["Think", "Think about it and come back later", -1]]];
		macTalk[3] = ["You tell the bouncer you'd like to sign up as a pred. He grunts and pulls a red band with the club's logo on it out and attaches it to your arm. Interestingly it fits snugly to you with out adjusting (and won't come off no matter how you pull at it). The bouncer also takes down your payment information so you can be properly billed for everything. Once he gets it down he goes back to standing by the door, you're not really sure where he's keeping all this stuff.", ["quest 1|value 1|action set|key 3|action giveKey"], [["Next", " ", 0]]];
		
		macTalk[5] = ["You ask if you can head into the club, the bouncer nods and thumbs towards the door. &quot;You don't need to check with me. I can see your band.&quot;", ["talk"], [["Go in", "Leave the taciturn wolf alone.", -1]]];
		
		macTalk[17] = ["You make as if you walk away from the club, but turn and dart back towards the door trying to get inside before the bouncer can react. On the one hand you were right about him not being terribly quick, on the other hand you didn't count on the door being locked. A low rumbling comes from behind you, the sound like a truck coming up behind you. You turn to see the wolf's teeth glinting in the light as he snarls at you.", ["talk"], [["Flee", "Abort! Abort! Abandon thread!", 18], ["Attack", "Fight him off!", 19], ["Bribe", "Offer the wolf something to forget about this.", 20]]];
		macTalk[18] = ["You turn yourself around as fast as you can and run, the growling follows you away from the door.", ["talk"], [["Next", " ", -1]]];
		macTalk[19] = ["You ready yourself to attack and fight off the wolf. Moments later you find yourself laying on your back, very confused about what just happened. You feel something warm covering your feet and manage to get your dazed head to move. Looking down you see the wolf grinning happily, which is almost more frighting then all the nasty looks he's been giving you. You follow his arms to your hips where he's gripping you tightly. Looking between his arms you see your thighs vanishing into the wolf's huge cock.</p><br><p>Alarmed you start to struggle but your motions only seem to entice the wolf more, he grabs your arms and pin them to your sides, pushing his cock further up over your hips. You see his balls start to bulge as your legs reach them, each time you flex trying to get away you feel his cock pulse and he growls softly, pausing to let you squirm inside his shaft. He pushes again, pinning your arms inside his shaft and stands with a grunt, letting his massive cock thrust out before him with you more then halfway down it. As soon as he stands you slide down to your chest leaving only your shoulders and head exposed.</p><br><p>He moves and put himself back into place at the door, your struggles and the occasional flex of his cock slowly sliding you further into his massive balls as he goes back to guarding the door. The last thing you're aware of, as your head is pulled into the bouncer's cock and everything starts going dark, is a female voice saying, &quot;Another one Mac? I hope this wasn't a customer this time. Still, you are nice and huge now...&quot;", ["talk"], [["Next", " ", -2]]];
		macTalk[20] = ["Mind racing, you try and think how to get out of this situation. You finally decide to try offering him something to just forget about this and let you go. You make the suggestion, assuming he'll as you for a couple hundred dollars, instead he grins and rumbles, &quot;Bend over. Or open up. Either way works.&quot;", ["talk"], [["Bend over", "Let the big wolf at your ass", 21], ["Open up", "Let him shove his cock down your throat", 22], ["Attack", "Screw that, attack!", 19]]];
		macTalk[21] = ["You turn around and bend over, you hear him moving up behind you. With little more then a grunt he levels his cock at your rear and pushes inside you. You gasp as he quickly fills your butt up, then keeps pushing. You struggle as he keeps pushing, somehow managing to fit his entire cock inside you. Once inside he promptly starts pounding away, clearly not interested in your pleasure at all. You feel him tense inside you and his hands grab your hips, holding your butt against his hips. He thrusts into you three more times before you feel his knot swell against your hole. You start to protest, trying to keep him from knotting your ass, but he growls and pops you over his knot, cumming hard after.</p><br><p>A minute later he finishes, pushing into you another few times to make sure you stay full, the rumbling from the big wolf taking on more of a happy sound as he unknots and lets you off him, your butt feeling uncomfortably full now. You turn back around to see him tucking his cock back in his pants, &quot;Don't do that again.&quot;", ["quest 4|value 1|bowels 150|action set"], [["OK", "Agree and deal with your new issue", -1]]];
		macTalk[22] = ["Not wanting to let him split you with that huge cock you see him sporting, you kneel down and open your mouth. He takes the invitation and moves up, that massive shaft heading towards your mouth. You start to worry it may be too big for you to fit , but he doesn't give you a chance to protest and simply jams his cock into your mouth. He keeps forcing more and more of his cock down your throat until your nose is pressed into his crotch. Then he starts pounding into your face, big hands holding your head as he fucks your face. It doesn't take him long to get himself off, you watch as his knot swells up in front of your face, luckily he doesn't try to knot your lips. He does hold you against him as he starts to cum hard into your mouth, forcing you to swallow everything.</p><br><p>He finishes after a minute or so, pulling his cock out of your mouth and tucking himself back in his pants. You do notice he's grinning now as he growls, &quot;Don't do that again.&quot;", ["quest 4|value 1|feed 150|action set"], [["OK", "Agree and leave", -1]]];
		
		macTalk[30] = ["You tell the bouncer you'd like to sign up as prey. He grunts and pulls a blue band with the club's logo on it out and attaches it to your arm. Interestingly it fits snugly to you with out adjusting (and won't come off no matter how you pull at it) the bouncer then pushes you into the club with little fan fare.", ["quest 1|value 2|action set"], [["Next", " ", -1]]];
		
		//Receptionist
		var annTalk:Array<Dynamic> = new Array();
		annTalk[0] = ["Looking like your typical gymbunny (though not a literal rabbit in this case) the human receptionist of this gym is average of height, skinny of weight, blonde of hair and blue of eye. She is wearing a very tight low-cut tank top, showing off her modest breasts. She smiles brightly as you enter and chirps, &quot;Hello! Welcome to Shay's Gym. I'll be happy to answer any questions you might have!&quot;", ["talk"], [["Go in?", "Ask if you can go inside", 1], ["Gold", "Ask about the Gold membership", 10], ["Name?", "Ask the perky girl her name", 2], ["Eat", "Ask if you can eat her", 3], ["Leave", " ", -1]]];
		annTalk[1] = ["You inquire about joining the gym and a smile spreads over her face, &quot;We offer two levels of membership, the first is our basic package. For a modest fee you get access to all our machines for the length of your visit. I can get you signed up for that one right now if you'd like, you'll have to pay each time you visit, but the nice thing is you only pay when you visit. So you don't have to worry about going on vacation or something like that. The cost for each visit is $20.&quot;</p><br><p>She pauses for a moment before continuing, &quot;We also offer a Gold membership. That's a one time fee and gets you unlimited access for life. You also get access to the Gold Room in the back where we have a number of advanced training machines. Unfortunately at this time we don't have any Gold memberships available. Check back later, something might open up.&quot;", ["quest 2|value 0|skip 5|action skip"], [["Sign Up", "Sign up for a basic membership", 4], ["Not Now", "Maybe later", -1]]];
		annTalk[2] = ["You ask her what her name is. She gives you one of her too-bright smiles and points at the name tag clipped to one breast, it reads &quot;Ann&quot;.", ["talk"], [["Go in?", "Ask if you can go inside", 1], ["Gold", "Ask about the Gold membership", 10], ["Eat", "Ask if you can eat her.", 3], ["Leave", " ", -1]]];
		annTalk[3] = ["You grin and mention you're a little hungry. She looks puzzled for a moment then blushes, &quot;You want to eat me?&quot; She shifts nervously, her eyes darting around. &quot;You really don't. I can't imagine I taste very good, I'm all skin and bones after all!&quot; She laughs nervously and fidgets some more.", ["talk"], [["Go in?", "Ask if you can go inside", 1], ["Gold", "Ask about the Gold membership", 10], ["Name?", "Ask the perky girl her name", 2], ["Leave", " ", -1]]];
		annTalk[4] = ["You agree to sign up, the perky receptionist takes down your name and a few other random details from you and fills out a form which she has you sign. After which she hands you a card, still warm from the little printer behind her station, it has your name and Basic Membership written on it as well as a barcode. &quot;Just slide that through the door over there and you'll automatically be charged and the door will open! Enjoy!&quot;", ["quest 2|value 1|action set|key 0|action giveKey"], [["Done", " ", -1]]];
		annTalk[5] = ["You ask if you can head inside and the receptionist smiles, &quot;Just swipe your card through the reader, the door will open for you. You don't need to talk to be every time you come inside, unless you really want to anyway.&quot;", ["talk"], [["Gold", "Ask about the Gold membership", 10], ["Name?", "Ask the perky girl her name", 2], ["Eat", "Ask if you can eat her.", 3], ["Leave", " ", -1]]];
		annTalk[6] = ["You ask the receptionist about gold memberships and she smiles, &quot;You're in luck actually, we just had a gold membership open up! If you'd like to purchase it I'd be more then happy to get you set up!&quot; She bounces a little as she talks, it would seem she's rather excited about the idea. &quot;Just so you're aware, the Gold membership is a one time fee of $2000. I know that sounds super high, but you don't have to pay for daily use of the gym anymore <i>and</i> you get access to our special Gold room! So, are you interested?&quot;", ["quest 2|value 2|skip 12|action skip"], [["Buy", "Sign up for the exclusive Gold Gym membership", 8], ["Maybe Later", "Think about it and come back later", -1]]];
		annTalk[7] = ["She giggles, &quot;Don't get me wrong, I like it when you stop by and talk with me, but you don't need to check with me every time you visit. The keypad there by the door will let you in.&quot; She waves towards it.", ["talk"], [["Gold", "Ask about the Gold membership", 10], ["Name?", "Ask the perky girl her name", 9], ["Eat", "Ask if you can eat her", 10], ["Leave", " ", -1]]];
		annTalk[8] = ["You agree to buy a gold membership, eager to use some of those machines you caught a glimpse of. The receptionist smiles as you hand over the money. She pulls a tablet out of her booth and makes a few notes on it, the money vanishing somewhere behind it at the same time. When she's done she looks up smiling, &quot;All set! You should be good to go right now if you'd like! Enjoy!&quot;", ["quest 2|money 2000|skip 9|action check"], [["Next", null, 11]]];
		annTalk[9] = ["You agree to buy a gold membership, eager to use some of those machines you caught a glimpse of. When you check your wallet however you discover that you're a little short of the $2000 fee. You smile sheepishly and promise you'll come back soon. &quot;Ok, hurry though.&quot; The receptionist makes a note as she talks, &quot;These memberships don't usually stay available for long.&quot;", ["talk"], [["Go in?", "Ask if you can go inside", 1], ["Name?", "Ask the perky girl her name", 2], ["Eat", "Ask if you can eat her", 3], ["Leave", " ", -1]]];
		annTalk[10] = ["You ask the receptionist about gold memberships, she frowns a little and shakes hear head, &quot;Sorry, we don't have any avalible right now. Check back soon though, I'm sure one will open up soon!", ["quest 2|value 1|skip 6|action skip"], [["Go in?", "Ask if you can go inside", 1], ["Name?", "Ask the perky girl her name", 2], ["Eat", "Ask if you can eat her", 3], ["Leave", " ", -1]]];
		annTalk[11] = ["Smiling happily Ann finishes up. &quot;Enjoy your Gold Membership!&quot;", ["quest 2|value 3|action set|key 1|action giveKey"], [["Leave", null, -1]]];
		annTalk[12] = ["Ann giggles, &quot;Silly [PCSPECIESL], you already are a Gold Member! And don't worry, the membership is for life.&quote;", ["talk"], [["Go in?", "Ask if you can go inside", 1], ["Name?", "Ask the perky girl her name", 2], ["Eat", "Ask if you can eat her", 3], ["Leave", " ", -1]]];
		
		//Shay
		var shayTalk:Array<Dynamic> = new Array();
		shayTalk[0] = ["An extremely large Irish wolfhound smiles as you look him over. He has clearly been making use of the machines in this room, shirtless his massive muscles bulge under his copper fur. His shorts are tight over his lower half, a huge bulge in his crotch, which flexes slightly as you look.</p><br><p>His grin has grown by the time you return your gaze to his, &quot;Hello there, it's nice to meet you. I'm Shay, I own this gym.&quot;", ["quest 2|value 3|skip 2|action skip"], [["Meet", "Nice to meet you.", 1]]];
		shayTalk[1] = ["You return Shay's greeting and he grins happily, &quot;Always nice to see a new face. Be careful, some of these machines are a little questionable, you might need to take it easy with them. If you have any questions let me know, I'll be around.&quot; He then steps past you and out the door.", ["quest 2|value 4|action set"], [["Well then", "Well, that was abrupt.", -1]]];
		shayTalk[2] = ["You find Shay leaning against one of the machines, he grins as you look him over. &quot;Hello again, sorry about rushing out last time, had a few things to take care of. I've got some time now though if you want to talk.&quot;", ["talk"], [["Gold Room", "Ask about the gold room.", 3], ["Him", "Ask about him.", 8], ["Nothing", "Nothing to ask about.", -1]]];
		shayTalk[3] = ["Curious you ask Shay about the machines in this room, he grins as he looks around, a clear sense of pride as he eyes the room, &quot;You like them? Most of these I made myself. I'm still tweaking them a little, that's the reason we don't let many people in here. Wouldn't want to have the machines break, or a customer.&quot; He grins at his joke. &quot;Let me know how you like them.&quot;", ["talk"], [["Like", "Tell Shay how much you enjoy them", 4], ["Dislike", "Tell Shay that you don't like them", 9], ["Haven't", "Tell him you haven't used them yet.", 10]]];
		shayTalk[4] = ["You grin and tell Shay that you really like the machines. He looks you over and his grin widens, &quot;I can tell. How's the adjustments working out for you?&quot; He winks.", ["talk"], [["Flirty", "Give him a flirty responce", 5], ["Appreciative", "Give him an appreciative responce.", 11], ["More", "Let him know you want more", 12]]];
		shayTalk[5] = ["Your smile spreads and you tell Shay you love the way the machines make you feel as well as they way they make you look. You obviously eye his package and ask if he's made use of his own creations.</p><br><p>Shay laughs lightly, &quot;Oh yes. Had a few side-effects from early versions though. I tend to get... a little large.&quot; He looks a bit bashful as he says this.", ["talk"], [["How big?", "Just how big does he get?", 6], ["Too Bad", "That's no good", 14]]];
		shayTalk[6] = ["So he gets bigger? You slide a little closer and inquire just how big he gets. Shay shifts a little uncomfortably as you get closer to him. &quot;Oh, I um...&quot; He rubs the back of his neck, his package starting to swell quite dramatically. &quot;I don't really know to be honest. It, well I just kinda keep growing.&quot;", ["talk"], [["Fun", "That could be fun", 7], ["Awkward", "That could be awkward.", 14]]];
		shayTalk[7] = ["You slide closer still and express how much fun you think that could be, a cock that just gets bigger and bigger. You eye him as he swells larger still, his shorts getting tight around his growing erection. He shifts again, his discomfort growing almost as fast as his cock. He moves away from you and quickly moves towards the door, &quot;I uh... I need to go do something, um... somewhere else.&quot; He darts out quickly.", ["quest 2|value 5|action set"], [["Well", "I guess you embaressed him", -1]]];
		shayTalk[8] = ["You ask after the big wolfhound, he gives a little chuckle, &quot;There's not really much to tell. I like working out and building stuff. That's about it really.&quot;", ["talk"], [["Gold Room", "Ask about the gold room", 3], ["Nothing", "Nothing to ask about", -1]]];
		shayTalk[9] = ["You tell Shay you're not really sure about the machines, they cause a bit of a strange feeling after all. He nods &quot;Yeah, that's one of the side effects I haven't been able to completely get rid of. I did get some of the really bad ones gone though.&quot;", ["talk"], [["Bad?", "What kind of bad ones?", 13], ["Good", "That's good.", 15], ["Goodbye", "Say goodbye", -1]]];
		shayTalk[10] = ["You admit that you haven't actually had a chance to use the machines yet. Shay nods and gestures towards the machines, &quot;Well don't let me keep you, I'll be around if you need anything.&quot; He heads out into the main gym.", ["talk"], [["Done", "Seems like a busy guy.", -1]]];
		shayTalk[11] = ["You tell Shay that you very much enjoy how the machines affect your body, turning to show off how your use of the machines have changed you. He looks you over, only a slight twitch showing his interest to be more then simply cynical. &quot;Looking good. Planning to hit another machine?&quot;", ["talk"], [["More", "You are definitely going for more", 12], ["Talk", "You just wanted to talk", 16]]];
		shayTalk[12] = ["You smile and tell Shay that you will most definitely be going for more, he returns the smile &quot;Well don't let me get in the way of that, I'll be around if you need anything.&quot; He heads out of the room.", ["talk"], [["Done", " ", -1]]];
		shayTalk[13] = ["Shay winces slightly when you inquire about the bad side effects he's gotten rid of already, &quot;Well, a few of the early versions caused injuries. That one there,&quot; he gestures towards the fat press machine, &quot;was really tricky. Works great now though. I have a couple more machines I'm still working on.&quot; He smiles, a sense of pride radiating off him as he looks over the machines.", ["talk"], [["Goodbye", "Say goodbye", -1]]];
		shayTalk[14] = ["You make sympathetic motions about his condition. He smiles and nods, &quot;Thanks, it's not too bad really. Find the right partner and it can be rather a lot of fun.&quot; He blushes rather hotly. &quot;Sorry, um. And before you ask, no, I'm not sure exactly what caused that effect.&quot;", ["talk"], [["Strange", "Odd effects", 17], ["Goodbye", "Say goodbye", -1]]];
		shayTalk[15] = ["You nod and acknowledge that it's good he's gotten the bugs worked out. He nods and heads for the door, &quot;I'll be around if you need anything.&quot;", ["talk"], [["Goodbye", "Say goodbye", -1]]];
		shayTalk[16] = ["You say you'd just like to talk and the two of you spend a few minutes making small talk. You don't really learn anything interesting aside from the fact that Shay really likes big. Which you kind of guessed.", ["talk"], [["Goodbye", "Say goodbye", -1]]];
		shayTalk[17] = ["You mention how odd it is to have an effect like that, he nods &quot;Very, and you'd like it would have been from the one over there,&quot; he nods his head towards the machine which makes erections bigger, &quot;but it wasn't. It was one of the new ones I'm working on, supposed to make your chest broader. Doesn't do anything, uh, lower.&quot;", ["talk"], [["Ready?", "When will it be ready?", 18], ["Talk", "Just chat some", 16], ["Goodbye", " ", -1]]];
		shayTalk[18] = ["You inquire when that machine will be ready, he shrugs, &quot;I have no idea really, like I said it's supposed to make your chest wider but it seems to be doing everything except that.&quot; He pauses for a moment then continues, &quot;You know, if you like you could help me out with some testing.&quot;", ["talk"], [["Sure", "Agree to help test out the new machine.", 20], ["Later", "Maybe later", 19]]];
		shayTalk[19] = ["He nods after you say you'll think about it, &quot;I'll be around if you change your mind.&quot; He turns and heads out the door.", ["talk"], [["Done", "He left. Again.", -1]]];
		shayTalk[20] = ["You agree to help out with the testing, Shay nods and digs in his pocket for a moment, &quot;Great! I've got a key around here somewhere, it'll get you into the staff room where the new machine is set up. Give it a try when you get the chance. Ah,&quot; He pulls a key out of his pocket and hands it to you. &quot;Here you go. I'll be around if you need anything.&quot; He then heads back to the main room.", ["quest 2|value 6|action set|key 2|action giveKey"], [["Done", " ", -1]]];
		
		//Guffin
		var guffinTalk:Array<Dynamic> = new Array();
		guffinTalk[0] = ["A short white fox stands behind the counter, he smiles as you walk in then blushes when you look him over. He appears to be your typical arctic fox save for the two small horns on his head. Most of him is covered by the counter but as you step up to the counter you see him sporting a very large belly, seems someone else has been partaking of the 'free' ice cream. &quot;O-oh, uh... hello! M-my name is Guffin, m-may I take your order? W-what would you like to have? Just l-let me know what you'd like.&quot;", ["talk"], [["Okay", " ", -1]]];
		
		//Bessie
		var bessieTalk:Array<Dynamic> = new Array();
		bessieTalk[0] = ["You step up to the counter, your former boss Bessie standing behind it and glaring at you. The cowgirl who gave you so much grief while you worked for her looks like she's managed to put on a couple pounds since the last time you saw her, most of it in her extremely massive breasts each one the size of a midsize exercise ball, though the bulge of her belly under them seems a little bigger as well. Before you have a chance to say anything she narrows her eyes, &quot;No, you can't have your job back. If you want to buy something, do so then get out.&quot;", ["quest 5|value 0|skip 8|action skip|value 1|skip 9|action skip"], [["No Job", "Why would you want it back?", 2], ["Weight", "Looks like she's put on weight", 1], ["You've always...", "There is one thing you've always wanted to do...", 3], ["Leave", "Now you remember how annoying she is to talk to.", -1]]];
		bessieTalk[1] = ["You make a show of looking Bessie over and mention that she's looking bigger then when she fired you. Her eyes narrow further, &quot;Since I've had to take over your shift I haven't had time to milk myself, not that it's any of your business. Now are you going to buy something or not?&quot;", ["talk"], [["Help", "You do have a lot of spare time now, you could offer to help", 5], ["No Job", "Why would you want it back?", 2], ["You've always...", "There is one thing you've always wanted to do...", 3], ["Leave", "Now you remember how annoying she is to talk to.", -1]]];
		bessieTalk[2] = ["Why would you want your job back? You say as much and Bessie's expression darkens slightly, &quot;Then buy something and get out. Or just get out.&quot;", ["talk"], [["Weight", "Looks like she's put on weight", 1], ["You've always...", "There is one thing you've always wanted to do...", 3], ["Leave", "Now you remember how annoying she is to talk to.", -1]]];
		bessieTalk[3] = ["Ever since you met Bessie you've always wanted to just give her nipples a tug and see how much milk you could get to come out of her. It's probably going to be more now, since she seems to be rather backed up. Do you want to?", ["talk"], [["Do it", "Give her a tug!", 4], ["Don't", "No, that would be dumb", 6]]];
		bessieTalk[4] = ["You reach out quickly and grab one of Bessie's nipples in your hand. It's surprisingly large even considering how big her tits are, it feels like you have a ripe strawberry in your hand. Before she can do more then widen her eyes at your action you pull hard. The motion is enough to release the tide of backed up milk in the cowgirl's breast, the thick white liquid soaking her shirt and flowing through the cloth to the floor where it makes a mess. The breast you uncorked is visibly shrinking as you watch, Bessie's face going from surprise to outrage to a soft contentment.</p><br><p>Well, no sense in her being lopsided. You give the other tit a tug and it also releases it's milky cargo, totally coating the front of Bessie's clothes. It's rather amazing how much she has in there really, her breasts have shrunk to almost 3/4ths the size they were when you walked in and they're still going.", ["quest 5|value 1|action set"], [["Flee", "She's going to be pissed when she comes out of this, maybe you should leave", -1], ["Drink", "It's just going to waste anyway. Maybe she'll go easy on you if you help her clean up", 7]]];
		bessieTalk[5] = ["You offer to help and she outright glares at you, &quot;Didn't me firing you tell you I don't want your help? If all you're going to do is insult me you can just fuck right off.&quot;", ["talk"], [["You've always...", "There is one thing you've always wanted to do...", 3], ["Leave", "Now you remember how annoying she is to talk to.", -1]]];
		bessieTalk[6] = ["You decide not to mess with her, there's a good chance you'd get hurt. Or arrested. All the staring you've been doing at Bessie's overfilled chest hasn't gone unnoticed, she thumps one hand on the counter, sending ripples through her tits, and shouts, &quot;Buy something or get the fuck out! Stop staring at my chest!&quot;", ["talk"], [["Do it", "Screw it, she's being a bitch anyway. Give a tit a yank", 4], ["Leave", "Well if she's just going to be unplesant there's no reason to keep talking to her", -1]]];
		bessieTalk[7] = ["You move around the counter and pull Bessie's soaked shirt away from her tits and exposing her engorged nipple. You wrap your lips around it and drink, the milk flows out into your mouth and you swallow it down, your mouth refills quickly. After the first few mouthfuls it becomes clear where the shop gets the raw material for it's ice cream, and it's even better fresh.</p><br><p>As you drink, Bessie lets out a soft 'moo', her eyes closed and hands resting lightly on your shoulders. You manage to drain one breast and she eagerly moves to present you with the other, you take that one and quickly empty it.</p><br><p>You lean back, stomach stretched with warm milk. You eye Bessie, a little wary of how she's going to react. The first thing you notice is how small her breasts are now, probably a D cup. Maybe a large C. Bessie herself is sitting against the wall, a look of happy bliss on her face as she makes soft 'moo' sounds, apparently letting out all that backed up milk was quite good for her.", ["quest 5|value 2|stomach 100|action set"], [["Leave", " ", -1]]];
		bessieTalk[8] = ["You step up to the counter, your former boss Bessie standing behind it. She gives you an odd look, you notice her breasts are smaller then the last time you walked in here, but still very large. &quot;I don't know what you thought you were doing, grabbing me like that. If you do it again I'll...&quot; She pauses, clearly not sure what threat she can make. After a moment she sighs, &quot;Just don't do it again. At least not out here&quot; She blushes, something you don't think you've ever seen her do before. &quot;Wasted all that milk...&quot; She clears her throat and looks a little more abashed, &quot;Do you need something?&quot;", ["talk"], [["Help", "She seemed to enjoy it last time, maybe she'd like to have another go?", 10], ["Nothing", " ", -1]]];
		bessieTalk[9] = ["You step up to the counter, your former boss Bessie standing behind it. As you open your mouth she pulls back and slaps you across the face. It stings. A lot. When your vision stops spinning from the slap you see Bessie glaring at you, &quot;Don't you EVER. Do that. AGAIN!&quot; She rubs one of her breasts, you can't help but notice that she appears to be a large D currently. &quot;I should just kick you out, or call the cops to come and get you. Not that they'd show up for a week.&quot; She mutters that last part, then returns her glare to you, &quot;But frankly I can't afford to turn away a customer. So buy something. Or get out.&quot;", ["talk"], [["Help", "She seemed to enjoy it last time, maybe she'd like to have another go?", 10], ["Nothing", " ", -1]]];
		bessieTalk[10] = ["Since she seemed to enjoy the last time you 'helped' you offer to do it again, she actually thinks about it for a moment. &quot;Well, actually...&quot; She looks around the shop, you also look around noting that the place is completely empty. You turn back to her and see that she's still looking around. You wait, after a while you tap your foot impatiently. She looks back at you, a blush covering her face, &quot;Actually, I think I could use a hand. The machine isn't really designed to be used from the inside.&quot; She rubs the back of her neck, &quot;Part of the reason I've been so backed up. I tell you what, you meet me in the back room while the other guy is working and help me with the machine and I'll let you take some ice cream home with you. Sound fair?&quot;", ["talk"], [["Agree", " ", 11], ["Disagree", " ", 12]]];
		bessieTalk[11] = ["You agree, it'll be fun to get to tie her up for a while. She sighs and hands you a key, &quot;You know what room it's in, the one you were never allowed in before. I'll be there while the shop is open in the mornings. Maybe I can finally get someone else hired.&quot;", ["quest 5|value 4|action set|key 4|action giveKey"], [["Leave", " ", -1]]];
		bessieTalk[12] = ["You shrug and tell her you have better things to do then play with her. She shrugs, &quot;You know where to find me.&quot; Then she goes back to cleaning.", ["talk"], [["Leave", " ", -1]]];
		bessieTalk[13] = ["You step up to the counter, Bessie is behind it. She still looks annoyed with you, &quot;If you're here for ice cream, buy something. If you're here to help, you're late and you'll have to come back tomorrow.&quot;", ["talk"], [["Leave", " ", -1]]];
		
		//Rat
		var ratTalk:Array<Dynamic> = new Array();
		ratTalk[0] = ["Hidden down this dark alley you find a figure standing in a dark cloak. He's trying to be unobtrusive and gets a shifty look to him when you get close. As you get closer you can make out that he's a short rat in a long dirty coat, he looks you over and appears to come to some kind of decision. &quot;You look like the type who likes to try new things. What do you say? What to see what I've got?&quot; Apparently he's a salesman.", ["talk"], [["Why Here?", "Ask why he's selling his wares in an alley.", 1], ["Leave", "Leave the shady character alone", -1]]];
		ratTalk[1] = ["You inquire why this salesrat is selling his stuff in an alley. He gets that shifty look again then says, &quot;Some of what I have isn't strictly legal to sell. Perfectly fine to own mind you, just not to sell to others. The law's funny like that.&quot; Ah, illegal stuff. Cool.", ["talk"], [["Leave", "Leave the shady character alone", -1]]];
		
		//Shopkeeper
		var shopTalk:Array<Dynamic> = new Array();
		shopTalk[0] = ["Perhaps unsurprisingly, the owner of this shop is a very large dragon. He's not overly tall, but is extremely wide, so big in fact he must have trouble moving through some of the stacks of junk filling the shop. He smiles as you walk up to the counter, &quot;Hi there, what can I do for you?&quot;", ["talk"], [["Work", "Ask about helping out around the shop", 1], ["Leave", " ", -1]]];
		shopTalk[1] = ["You inquire if the dragon needs any part-time help. He thinks for a moment, &quot;I don't need any help with the shop, though I suppose if you wanted to sort through some of my inventory I could pay you for that. It wouldn't be regular work, just a few hours here and there.&quot; He shrugs, &quot;Honestly you could just work as much or as little as you like, sound interesting?&quot;", ["quest 6|value 0|skip 3|action skip"], [["Agree", "Accecpt the offer.", 2], ["Disagree", "Don't accecpt the offer.", 0]]];
		shopTalk[2] = ["The shopkeep smiles, &quot;Good, just let me know when you'd like to put in a few hours. There's plenty of work to do downstairs.&quot;", ["quest 6|value 1|action set|key 5|action giveKey"], [["Next", " ", 0]]];
		shopTalk[3] = ["You let the dragon know you'd like to work he nods, &quot;Just head down there and let me know when you leave.&quot;", ["talk"], [["Leave", null, -1]]];
		
		//Erik
		var erikTalk:Array<Dynamic> = new Array();
		erikTalk[0] = ["You feel the floor rumble and look up, an extremely large human has just settled himself down on the machine next to you. The poor machine seems to groan under the man's weight as he sets it as high as it will go and starts working it as easily as you'd lift a sandwich. He notices you watching him and grins, &quot;Can I help you with something?&quot;", ["talk"], [["Flirt", "Flirt with the huge man.", 1], ["Hungry", "See if the man-mountian wants to be lunch.", 2], ["Gold member?", "Ask if he's a gold gym member", 3], ["Leave", " ", -1]]];
		erikTalk[1] = ["You smile and ask if the big man is big all over or just in his arms. He grins and grabs his crotch, thrusting towards you, &quot;Oh hell yea! You have no idea what's in that room do you?&quot; He stands, pulling his gym shorts up tight so you can see him bulge, &quot;Muscles, cock. Balls. Everything gets big in there.&quot; He leers at you, &quot;You want to see?&quot;", ["talk"], [["Yes", "You tell him you would like to see just how big he really is.", 5], ["Not really", "Uh, no. Jackass.", 4]]];
		erikTalk[2] = ["You ask if the big man wants to see what you look like from the inside. He does another couple of reps then pauses, looking at you. &quot;You're one of those weirdos from that new club aren't you? Always going around eating people. Keep that shit to your little club, leave me out of it.&quot; He grunts and goes back to working out, faster then before, though he goes back to a more steady pace after a few moments.", ["talk"], [["Flirt", "Flirt with the huge man.", 1], ["Gold member?", "Ask if he's a gold gym member", 3], ["Leave", " ", -1]]];
		erikTalk[3] = ["You ask if he's a gold member of the gym. He stops working the machine for a moment and flexes, showing off his massive muscles, &quot;Sure am! Where else do you think these beauties came from? I've been a member for only six months now and I'm already huge! Just imagine how big I'll be after another six months!&quot; He kisses one bicep and goes back to the machine.", ["talk"], [["Flirt", "Flirt with the huge man.", 1], ["Hungry", "See if the man-mountian wants to be lunch.", 2], ["Leave", " ", -1]]];
		erikTalk[4] = ["You inform him that, no. You are not interested. He huffs and drops the bar he was working with, standing and giving a few unnecessary flexes before stomping off. &quot;Fine. You're not my type anyway.&quot;", ["talk"], [["Continue", " ", -1]]];
		erikTalk[5] = ["You grin and tell him that you would love to see just how big he is. And in fact you'd like to watch as he gets bigger. His grin grows, as do certain other parts, and he looks around quickly. &quot;Well, I'm not supposed to let anyone who isn't a gold member into the room, but there's no one looking...&quot; He stands, dropping the machine's bar without bothering to set it properly and grabs a gallon jug of water you hadn't noticed before and takes a huge gulp from, getting more of it down his front then actually in his mouth.</p><br><p>&quot;C'mon cupcake.&quot;He waves as he starts towards the locked gold member door, &quot;Come watch Erik the Mighty get even mightier.&quot;", ["talk"], [["Follow", "A preview of the gold room. Nice.", 6], ["Stay", "He's a jackass. Stay here and hope he doesn't come back.", -1]]];
		erikTalk[6] = ["You follow the big human, he pauses at the door to type something into the pad then pushes the door open. He actually starts pushing before the system unlocks and rather then letting go so it can unlock and starting again he just pushes harder until the poor lock squeals and releases, the door popping open. He steps through and you dart in after, the door locking shut behind you.</p><br><p>You look around getting your first look of the nearly mythical Gold Room. It's not really all that impressive, 7 machines sit in a semi circle around the outside of the room, with the door being the only section that hasn't got a machine. The outer walls have floor to ceiling mirrors just like the main room. Erik the jackass goes over to one of the machines, an almost medieval torture looking contraption. He takes another bug gulp from his water jug and tosses it in the general direction of the room's trash can. He misses, then he starts working himself into the machine.</p><br><p>&quot;You'll like this one cupcake. Makes me taller, more room for all these muscles.&quot; He winks at you and nods towards another machine, &quot;We can use that one next. It makes little me, less little.&quot; He seems to think that's funny and chuckles to himself as he keeps working himself into the straps. He's rather distracted right now, and there's no one in the room and no one is likely to enter any time soon either. You could probably get rid of him...", ["talk"], [["Wait", "You kinda want to see how this thing works. It's worth putting up with him calling you 'cupcake'", 7], ["Grab", "He's distracted and not in the machine completly yet. Now's your chance.", -7]]];
		erikTalk[7] = ["You decide to wait, watching as he finally gets all the various straps and harnesses in place and turns the machine on. It starts working over his body, tightening and pulling all over him and he makes several groans and moans, at first you think he's in pain until you notice how much his shorts appear to have shrunk, a massively over sized cock outlined clearly though the thin fabric. Amusingly he seems to have neglected his balls, you can't even see them.</p><br><p>When you look back up you see that he's watching you, a big stupid grin on his face. The machine gives a soft beep and the straps release, Erik pulls himself free mostly by simply stepping out of it. He grins and flexes for you and you can see that he's several inches taller then he was before getting in it. &quot;You like?&quot; He does a little spin, his cock straining his poor gym shorts, which break off as he flexes his muscles. His huge cock bursting free and bouncing towards you, his grin turns lecherous.</p><br><p>&quot;Well well, I see you like the look I've got here.&quot; He steps closer to you, aiming his cock towards you. &quot;So what do you say cupcake? You want to give my big hard bod a ride?&quot; He runs his hand over his cock, watching you.", ["talk"], [["Grab", "He's so eager to be inside someone...", -7], ["Leave", "Screw this, just leave.", -1]]];
		
		
		//NPCs
		nonPlayerCharacters = new Array();
		//							Name					Species		Breasts	Vagina	Penis	Balls	Height	Mass	Conversation	image
		nonPlayerCharacters[0] = ["Mac the bouncer",		species[3],	false,	false,	true,	true,	84,		500,	macTalk,		null];
		nonPlayerCharacters[1] = ["Ann the receptionist",	species[0],	true,	false,	false,	false,	63,		95,		annTalk,		null];
		nonPlayerCharacters[2] = ["Shay",					species[3], false,	false,	true,	true,	74,		600,	shayTalk,		null];
		nonPlayerCharacters[3] = ["Guffin",					species[1], false,	true,	false,	false,	65,		450,	guffinTalk,		null];
		nonPlayerCharacters[4] = ["Bessie",					species[4],	true,	false,	true,	false,	67,		690,	bessieTalk,		null];
		nonPlayerCharacters[5] = ["Shifty Rat",				species[6],	false,	false,	true,	true,	60,		80,		ratTalk,		null];
		nonPlayerCharacters[6] = ["Shopkeeper",				species[2], false,	false,	true,	true,	62,		650,	shopTalk,		null];
		nonPlayerCharacters[7] = ["Erik",					species[0], false,	false,	true,	true,	78,		700,	erikTalk,		null];
		
	}

	static function clearAllEvents() {
		for (i in 0...btns.length) {
			btns[i].setButton(" ");
			btns[i].clearClickFunc();
		}
	}
	
	static function main() {
		initialize();
		drawPlayfield();
		welcomeScreen();
	}
	
}