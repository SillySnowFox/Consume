import flash.events.MouseEvent;
import flash.Lib;
import flash.utils.Object;
import haxe.xml.Check.Attrib;

class MyPlayerObject extends MyCharacter {
	public var money:Int;
	
	public var numEaten:Int;
	
	public var quest:Array<MyQuest>;
	
	public var invObject:Array<MyItem>;
	public var keyRing:Array<MyItem_Key>;
	
	public var equipWepObj:MyItem_Weapon;
	public var equipArmObj:MyItem_Armor;
	
	public var lastDayTrained:Int;
	public var lastClubDay:Int;
	public var lastGoldTrainDay:Int;
	
	public var hour:Int;
	public var minute:Int;
	public var day:Int;
	
	public var emptyStomachCountdown:Int;
	public var cumStreachCountdown:Int = -1;
	public var milkStreachCountdown:Int = -1;
	public var stomachStreachCountdown:Int = -1;
	public var bowelsStreachCountdown:Int = -1;
	
	public var unlockedPhoneNumbers:Array<Bool>;
	
	//Level Up
	public var pointsSpent:Int;
	public var strNeededToUp:Int;
	public var agiNeededToUp:Int;
	public var endNeededToUp:Int;
	public var intNeededToUp:Int;
	
	public function playerDesc():String {
		var message:String = "";
		var globals:Object = Lib.current.getChildByName("GlobalVars");
		
		message += "You stand " + toFeet(this.tall) + " tall.";
		
		//head/face
		
		message += " " + "You have ";
		
		if (this.breasts) {
			//NPC has breasts
			if (this.hasPerk("mulbo1")) {
				message += "four ";
			} else {
				message += "two ";
			}
			
			message += this.breastSizeDesc() + " breasts resting on your " + this.chestSizeDesc() + " ";
		} else {
			//NPC does not have breasts
			
			message += "a flat " + this.chestSizeDesc() + " ";
		}
		
		message += "chest with " + this.strDesc() + ".";
		
		message += " Two " + this.arms + " ending in " + this.hands + " rest at your sides. ";
		
		message += "You have a " + this.stomachSizeDesc() + " stomach. ";
		
		if (this.penis) {
			message += "You have ";
			//NPC has at least one dick
			if (this.hasPerk("mulcoc1")) {
				message += "two ";
			} else {
				message += "one ";
			}
			
			message += toFeet(this.penisLength()) + " long, " + toFeet(this.penisDiam()) + " wide ";
			
			if (this.arousal >= 50) {
				message += "hard ";
			} else {
				message += "soft ";
			}
			
			message += "cock";
			
			if (this.hasPerk("mulcoc1"))
				message += "s";
			
			message += ".";
		}
		if (this.balls) {
			//NPC has balls
			message += " Two " + this.ballSizeDesc() + " balls hang below your cock";
			if (this.hasPerk("mulcoc1"))
				message += "s";
				
			message += ".";
		}
		if (this.vagina) {
			//NPC has a vagina
			message += " A soft ";
			
			if (this.arousal >= 50 && this.arousal < 100)
				message += "wet ";
			if (this.arousal > 100)
				message += "dripping ";
			
			message += "slit waits between your " + this.legs + ".";
		}
		if (!this.penis && !this.vagina) {
			//No cock, no vagina
			message += " Your crotch is smooth and unbroken by any genitalia.";
		}
		if (this.tail) {
			//NPC has a tail
			message += " A " + this.taliDesc + " tail sways behind you.";
		}
		
		message += " Two " + this.legs + " support you each ending in " + this.feet + ".</p><br><p>";
		
		if (globals.debugMode) {
			message += "Stomach Size: " + this.stomachSize();
			
			message += "</p><br><p>";
		}
		
		return message;
	}
	
	public function hasKey(keyID:Int):Int {
		var keyIndex:Int = -1;
		
		for (i in 0...this.keyRing.length) {
			if (this.keyRing[i].keyID == keyID)
				keyIndex = i;
		}
		
		return keyIndex;
	}
	
	public function die(how:String):String {
		return "#DIE:" + how;
	}
	
	public function sleep( e:MouseEvent ):String {
		
		return "Sleep";
	}
	
	public function poop( e:MouseEvent ):String {
		
		return "Player Poop";
	}
	
	public function cum(into:String):String {
		var currentCum:Float = this.cumCurrent;
		var ballsContents:Array<Dynamic> = this.ballContents;
		var message:String = "";
		
		this.arousal = 0;
		this.cumCurrent = 0;
		this.ballContents = new Array();
		
		switch (into) {
		case "door":
			//Player just fucked a door until they came
			message = "The feel of the doorway surrounding your massive cock is simply too much for you to bear and with a grunt you feel yourself release, filling the room beyond with thick ropes of your cum.<br>";
			
		default:
			message = "You cum and release yourself.<br>";
		}
		
		
		
		return message;
	}
	
	public function fitWidth(doorSize:Int):String {
		var stomachWidth:Int = 0;
		var breastWidth:Int = 0;
		var hipWidth:Int = 0;
		var ballWidth:Int = 0;
		var cockWidth:Int = 0;
		var message:String = "";
		
		//Frst find where the player is widest; hips, breasts, stomach or balls
		
		//Hip width, hipSize is the circumference so we have to do math. (D=C/pi)
		//This is the easy one
		hipWidth = Math.round((this.hipSize + this.buttSize) / Math.PI);
		
		stomachWidth = this.stomachSize();
		if (stomachWidth < this.waistSize)
			stomachWidth = Math.round(this.waistSize / Math.PI);
		
		if (this.breasts || this.lac) {
			breastWidth = this.breastDiam() * 2;
			if (breastWidth < this.chestSize)
				breastWidth = Math.round(this.chestSize / Math.PI);
		}
		
		if (this.balls) {
			//ballWidth. cumCurrent just like everything above, half then double again
			ballWidth = ballDiam() * 2;
			if (ballWidth < this.ballSize)
				ballWidth = Math.round(this.ballSize);
		}
		
		if (this.penis) {
			cockWidth = penisDiam();
			if (this.arousal >= 50 && this.arousal < 100)
				message += "Your arousal causes your cock to stand at attention.<br>";
			if (this.arousal >= 100)
				message += "Your cock is painfully hard.<br>";
		}
		
		if (doorSize != 0) {
			if (stomachWidth == doorSize)
				message += "The sides of your massive stomach brush the sides of the doorway as you pass through.<br>";
			if (stomachWidth > doorSize && stomachWidth <= doorSize + 6)
				message += "Your massive stomach wedges in the doorway, but after a moment you are able to push yourself through.<br>";
			if (stomachWidth > doorSize + 6)
				return "##STOMACH";
			if (breastWidth == doorSize) {
				message += "The sides of your huge breasts brush the sides of the doorway as you pass through.<br>";
				this.arousal += 1;
			}
			if (breastWidth > doorSize && breastWidth <= doorSize + 6) {
				message += "Your massive breasts stick in the doorway, but after a moment you are able to push yourself through.<br>";
				this.arousal += 2;
			}
			if (breastWidth > doorSize + 6)
				return "##BREASTS";
			if (ballWidth == doorSize) {
				message += "The sides of your massive balls brush the sides of the doorway as you pass through.<br>";
				this.arousal += 1;
			}
			if (ballWidth > doorSize && ballWidth <= doorSize + 6) {
				message += "Your massive balls stick in the doorway, but after a moment you are able to pull yourself through.<br>";
				this.arousal += 3;
			}
			if (ballWidth > doorSize + 6)
				return "##BALLS";
			if (cockWidth == doorSize) {
				message += "Your huge cock brushes the sides of the doorway as you pass through.<br>";
				this.arousal += 3;
			}
			if (cockWidth > doorSize && cockWidth <= doorSize + 6) {
				message += "Your massive cock nearly sticks in the doorway, but you manage to force yourself through.<br>";
				this.arousal += 5;
			}
			if (cockWidth > doorSize + 6)
				return "##COCK";
		}
		
		return message;
	}
	
	public function fitHeight(doorSize:Int):String {
		
		return "";
	}
	
	public function passTime(minutes:Int):String {
		var globals:Object = Lib.current.getChildByName("GlobalVars");
		var message:String = "";
		var allowScat:Bool = globals.allowScat;
		var allowSex:Bool = globals.allowSex;
		var time:Int = minutes;
		var emptyStomach:Bool = false;
		var isDig:Bool = true;
		var digestMessage:String = "";
		var rndMsg:Int = -1;
		
		var digestMessages:Array<String> = new Array();
		var digestedNPCs:Array<MyNPC> = new Array();
		
		digestMessages = ["", "Your stomach rumbles happily as it works on it's contents.</p><br><p>"];
		
		if (!allowScat) {
			this.bowelsCurrent = 0;
			this.bowelsContents = null;
		}
		if (!allowSex) {
			this.arousal = 0;
		}
		if (!this.lac) {
			this.breastCurrent = 0;
			this.breastContents = new Array();
		}
		if (!this.balls && !this.hasPerk("inbal")) {
			this.cumCurrent = 0;
			this.ballContents = new Array();
		}
		
		if (this.stomachCurrent == 0) {
			isDig = false;
			if (this.fat != 0) {
				if (this.fat >= this.digestDamage) {
					this.fat -= this.digestDamage;
				} else {
					this.fat = 0;
				}
				emptyStomach = false;
				this.emptyStomachCountdown = this.end;
			}
			if (this.emptyStomachCountdown != 0) {
				this.emptyStomachCountdown -= 1;
				emptyStomach = false;
				digestMessage = "Your stomach growls hungrily.</p><br><p>";
			} else {
				emptyStomach = true;
			}
		} else {
			emptyStomach = false;
			if (this.stomachContents.length == 0) {
				this.stomachCurrent -= time * this.digestDamage;
			}
			
			this.fat += time * this.fatGain;
			if (this.penis && (this.balls || this.hasPerk("inbal"))) {
				this.cumCurrent += time * this.cumGain;
				if ((this.cumCurrent > this.cumCap) && this.balls) {
					message += "Your balls feel heavy and full.<br>";
					this.cumStreachCountdown -= time;
					if (this.cumStreachCountdown <= 0) {
						this.cumStreachCountdown = this.stretchRateCum;
						this.cumCap += this.stretchAmountCum;
						message += "You breathe a sigh of relief as the tightness in your balls relaxes.<br>";
					}
				}
				if ((this.cumCurrent > this.cumCap) && !this.balls && this.hasPerk("inbal")) {
					message += "You feel slightly bloated from all your cum filling you.<br>";
					this.cumStreachCountdown -= time;
					if (this.cumStreachCountdown <= 0) {
						this.cumStreachCountdown = this.stretchRateCum;
						this.cumCap += this.stretchAmountCum;
						message += "You breathe a sigh of relief as the pressure of your cum lightens.<br>";
					}
				}
			}
			if (this.lac && this.breasts) {
				this.breastCurrent += time * this.milkGain;
				if (this.breastCurrent > this.breastCap) {
					message += "Your breasts feel tight and uncomfortably full.<br>";
					this.milkStreachCountdown -= time;
					if (this.milkStreachCountdown <= 0) {
						this.milkStreachCountdown = this.stretchRateMilk;
						this.breastCap += this.stretchAmountMilk;
						message += "You sigh softly as the tightness in your breasts relaxes slightly.<br>";
					}
				}
			}
			
			rndMsg = Math.round(Math.random() * digestMessages.length - 1);
			
			if (rndMsg > 0) 
				digestMessage = digestMessages[rndMsg];
			
			while (time > 0) {
				time -= 1;
				var j:Int = 0;
				while (j < stomachContents.length) {
					if (this.stomachContents[j].healthCurr > 0) {
						this.stomachContents[j].healthCurr -= this.digestDamage;
					} else {
						this.stomachCurrent -= this.digestDamage;
						this.stomachContents[j].mass -= this.digestDamage;
						
						if (this.stomachContents[j].mass <= 0) {
							digestedNPCs.push(this.stomachContents[j]);
							if (globals.allowScat)
								this.bowelsContents.push(this.stomachContents[j]);
							stomachContents.remove(stomachContents[j]);
							j--;
						}
					}
					
					j++;
				}
			}
			
			for (i in 0...this.stomachContents.length) {
				if (this.stomachContents[i].healthCurr == 0) {
					digestMessage += "You feel your prey's motions slow and finally stop.<br> ";
					this.stomachContents[i].healthCurr = -1;
				}
				if (this.stomachContents[i].healthCurr > 0) {
					if (this.stomachContents[i].likeVore) {
						digestMessage += "Muffled moans come from your belly as your prey uses their last moments to masturbate.<br>";
					} else {
						digestMessage += "You feel your prey struggling against your stomach.<br> ";
					}
				}
			}
			if (digestMessage.charAt( -1) == " ") {
				digestMessage += "</p><br><p>";
			}
		}
		
		if (this.stomachCurrent < 0)
			this.stomachCurrent = 0;
		
		if (this.stomachCurrent >= this.stomachCap && this.stomachCurrent < this.stomachCap * 1.5) {
			message += "Your stomach groans softly as the pressure of your recent meals lessens slightly.<br>";
			this.stomachCap += this.stretchAmountStomach;
			this.stomachStreachCountdown = this.stretchRateStomach;
		}
		if (this.stomachCurrent >= this.stomachCap * 1.5) {
			return "#STOMACH";
		}
		if (!emptyStomach && isDig) {
			this.emptyStomachCountdown = this.end;
			if (this.healthCurr < this.healthMax) {
				this.healthCurr += this.end;
				if (this.healthCurr > this.healthMax) {
					this.healthCurr = this.healthMax;
				}
			}
		} 
		if (emptyStomach && !isDig) {
			digestMessage = "Your stomach cramps painfully and you feel yourself grow weaker.</p><br><p>";
			this.healthCurr -= 1;
			if (this.healthCurr == -1)
				return this.die("starve");
		}
		
		this.minute += minutes;
		while (this.minute >= 60) {
			this.minute -= 60;
			this.hour += 1;
		}
		while (this.hour >= 24) {
			this.hour -= 24;
			this.day += 1;
		}
		
		if (this.healthCurr == 0) {
			digestMessage = "Your head spins and the world starts to go black. You need food. Now.</p><br><p>";
		}
		
		if (digestMessage == null) {
			new AlertBox("digestMessage: null");
			message = "error";
		}
		
		if (digestMessage != "")
			message += digestMessage;
		
		return message;
	}
	
	public function newPlayer(species:MySpecies, breasts:Bool, vagina:Bool, penis:Bool, balls:Bool, str:Int, agi:Int, end:Int, int:Int, name:String, perks:Array<MyPerk>) {
		newCharacter(species, breasts, vagina, penis, balls, str, agi, end, int, name, perks);
		
		//Setup player arrays
		stomachContents = new Array();
		bowelsContents = new Array();
		breastContents = new Array();
		ballContents = new Array();
		quest = new Array();
		invObject = new Array();
		keyRing = new Array();
		unlockedPhoneNumbers = new Array();
		
		//Set initial values
		arousal = 0;
		money = 100;
		numEaten = 0;
		lastDayTrained = -1;
		lastClubDay = -1;
		lastGoldTrainDay = -1;
		hour = 6;
		minute = 0;
		day = 1;
		
		pointsSpent = 14;
		strNeededToUp = str * 5;
		agiNeededToUp = agi * 5;
		endNeededToUp = end * 5;
		intNeededToUp = int * 5;
		
		this.name = name;
		
		/* Player phonebook
		 * 0 - Pizza
		 * 1 - Hookers
		 * 
		 */
		
		unlockedPhoneNumbers = [true, true];
	}
	
	
	public function new() {
		super();
	}
}