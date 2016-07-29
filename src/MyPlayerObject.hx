import flash.events.MouseEvent;
import flash.Lib;
import flash.utils.Object;
import haxe.xml.Check.Attrib;

class MyPlayerObject extends MyCharacter {
	public var money:Float;
	
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
	public var cumStretchCountdown:Int = -1;
	public var milkStretchCountdown:Int = -1;
	public var stomachStretchCountdown:Int = -1;
	public var bowelsStretchCountdown:Int = -1;

	public var unlockedPhoneNumbers:Array<Bool>;
	public var deliveryDriversEaten:Int;
	
	//Level Up
	public var pointsSpent:Int;
	public var strNeededToUp:Int;
	public var agiNeededToUp:Int;
	public var endNeededToUp:Int;
	public var intNeededToUp:Int;
	
	private var starvationCheck:Bool; //True if we haven't checked yet this action, false if we have
	private var massToPooRatio:Float = 0.33;	// $design: Arbitrary amount of poo from each unit of mass
	private static var digestMessages:Array<String> = 
		[
			"", 
			"Your stomach rumbles happily as it works on its contents.</p><br><p>"
		];
	
	
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
	
	private function checkStretching():Void {
		
		if (stomachCurrent >= stomachCap) {
			stomachStretchCountdown--;
			if (stomachStretchCountdown <= 0) {
				stomachCap += stretchAmountStomach;
				stomachStretchCountdown = stretchRateStomach;
			}
		}
		if (cumCurrent > cumCap) {
			cumStretchCountdown--;
			if (cumStretchCountdown <= 0) {
				cumStretchCountdown = stretchRateCum;
				cumCap += stretchAmountCum;
			}
		}
		if (breastCurrent > breastCap) {
			milkStretchCountdown--;
			if (milkStretchCountdown <= 0) {
				milkStretchCountdown = stretchRateMilk;
				breastCap += stretchAmountMilk;
			}
		}
		if (bowelsCurrent > bowelsCap) {
			bowelsStretchCountdown--;
			if (bowelsStretchCountdown <= 0) {
				bowelsStretchCountdown = stretchRateBowels;
				bowelsCap += stretchAmountBowels;
			}
		}
	}
	
	private function digestTick():Void {
		
		// If stomach is empty
		if (stomachCurrent == 0) {
			if (fat != 0) {
				//var FatBurnRate:Int = digestDamage;	// $design: Slower fat burn/starvation?
				var FatBurnRate:Int = 1;				//  Seems like the player starves really quick at game start. Maybe a bit of starting fat would help.
				if (fat >= FatBurnRate) {
					fat -= FatBurnRate;
				} else {
					fat = 0;
				}
				emptyStomachCountdown = end;
			} else {
				//Time-To-Starve countdown. This should be in actions, not ticks, giving the player a chance to get somewhere with food, rather then just passing out between rooms
				if (starvationCheck) {
					//Check once per action if the player is starving
					starvationCheck = false;
					if(emptyStomachCountdown > 0) {
						emptyStomachCountdown--;
					} else {
						healthCurr--;
					}
				}
				
			}
			return;
		}
		
		
		// Stomach is not empty, proceed with digestion
		this.fat += this.fatGain;
		emptyStomachCountdown = end;
		
		if (stomachContents.length > 0) {
			//var DigestAmt:Int = digestDamage;										// $design: If there are multiple prey in stomach, should each 
			var DigestAmt:Int = Math.ceil(digestDamage / stomachContents.length);	// one take full digest damage, or should damage be split between all prey?

			for (CurPrey in stomachContents) {
				if(CurPrey.healthCurr > 0){
					CurPrey.healthCurr -= DigestAmt;
					if (CurPrey.healthCurr < 0) {
						CurPrey.healthCurr = 0;
					}
				} else {
					if (CurPrey.mass >= DigestAmt) {
						stomachCurrent -= DigestAmt;
						CurPrey.mass -= DigestAmt;
						bowelsCurrent += DigestAmt * massToPooRatio;
					} else {
						stomachCurrent -= CurPrey.mass;
						bowelsCurrent += CurPrey.mass * massToPooRatio;
						CurPrey.mass = 0;
					}
				}
			}
		} else{
			// Nothing specific in stomach, just decrease stomachCurrent
			if (stomachCurrent >= digestDamage) {
				bowelsCurrent += digestDamage * massToPooRatio;
				stomachCurrent -= digestDamage;
			} else {
				bowelsCurrent += stomachCurrent * massToPooRatio;
				stomachCurrent = 0;
			}
		}
		
		
		// This shouldn't happen, but just in case...
		if (stomachCurrent < 0) {
			stomachCurrent = 0;
		}
		
		
		var Globals:Object = Lib.current.getChildByName("GlobalVars");
		if (Globals.allowScat) {
			// Move fully digested prey into bowels
			var i:Int = 0;
			while (i < stomachContents.length) {
				if (stomachContents[i].mass <= 0) {
					bowelsContents.push(stomachContents[i]);
					stomachContents.remove(stomachContents[i]);
					i--;
				}
				i++;
			}
		} else {
			bowelsCurrent = 0;
		}
	}
	
	private function advanceOneTick():Void {
		digestTick();
		
		// If we're still fed, run body processes
		if (emptyStomachCountdown == end) {
			if (balls || hasPerk("inbal"))
				cumCurrent += cumGain;
			if (lac && breasts)
				breastCurrent += milkGain;
			if (healthCurr++ >= healthMax)
				healthCurr = healthMax;
		}
		
		// See if anything stretched
		checkStretching();
		
	}
	
	public function passTime(minutes:Int):Void {
		updateTime(minutes);
		starvationCheck = true;
		for (i in 0...minutes) {
			advanceOneTick();
		}
	}
	
	public function passTime_with_output(minutes:Int):String {
		
		var OldStomachCap:Float = stomachCap;
		var OldCumCap:Float = cumCap;
		var OldBreastCap:Float = breastCap;
		
		passTime(minutes);
		
		
		// Put together filled/stretch message
		var Message:String = "";
		
		
		// -- Stomach
		if (stomachCap > OldStomachCap) {
			Message += "Your stomach groans softly as the pressure of your recent meals lessens slightly.<br>";
		}
		
		// -- Cum
		if (cumCurrent > OldCumCap){
			if(this.balls) {
				Message += "Your balls feel heavy and full.<br>";
				if (cumCap > OldCumCap) {
					Message += "You breathe a sigh of relief as the tightness in your balls relaxes.<br>";
				}
			}
			else {
				Message += "You feel slightly bloated from all your cum filling you.<br>";
				if (cumCap > OldCumCap) {
					Message += "You breathe a sigh of relief as the pressure of your cum lightens.<br>";
				}
			}
		}
		
		// -- Breasts
		if(breastCurrent > OldBreastCap) {
			Message += "Your breasts feel tight and uncomfortably full.<br>";
			if(breastCap > OldBreastCap){
				Message += "You sigh softly as the tightness in your breasts relaxes slightly.<br>";
			}
		}
		

		// Get digest message
		var DigestMessage:String = "";
		if (stomachCurrent == 0 && emptyStomachCountdown < end/2) {
			DigestMessage = "Your stomach growls hungrily.</p><br><p>";
		} else {
			var rndMsg:Int = Math.round(Math.random() * digestMessages.length - 1);
			if (rndMsg > 0) 
				DigestMessage = digestMessages[rndMsg];
		}
		
		
		// Check for expired prey
		var RecentDeadPrey:Array<MyNPC> = pullDisgestedPrey();
		for (CurPrey in RecentDeadPrey) {
			DigestMessage += "You feel the " + CurPrey.name + "'s motions slow and finally stop.<br> ";
		}
		for(CurPrey in stomachContents) {
			if (CurPrey.healthCurr > 0) {
				if (CurPrey.likeVore) {
					DigestMessage += "Muffled moans come from your belly as your prey uses their last moments to masturbate.<br>";
				} else {
					DigestMessage += "You feel the " + CurPrey.name + " struggling against your stomach.<br> ";
				}
			}
		}
		
		if (DigestMessage.charAt( -1) == " ") {
			DigestMessage += "</p><br><p>";
		}
		
		
		// Starving checks
		if(emptyStomachCountdown == 0){
			DigestMessage = "Your stomach cramps painfully and you feel yourself grow weaker.</p><br><p>";
			if (healthCurr < 0)
				return this.die("starve");
		}
		if (this.healthCurr == 0) {
			DigestMessage = "Your head spins and the world starts to go black. You need food. Now.</p><br><p>";
		}
		
		if (DigestMessage == null) {
			new AlertBox("digestMessage: null");
			Message = "error";
		}
		
		if (DigestMessage != "")
			Message += DigestMessage;
		
		return Message;
	}
	
	public function pullDisgestedPrey():Array<MyNPC> {
		
		// Return all prey who just died this tick (health == 0), then set
		// 	their health to -1 so they don't get pulled again.
		var RetArray:Array<MyNPC> = new Array();
		
		for (CurPrey in stomachContents) {
			if (CurPrey.healthCurr == 0) {
				RetArray.push(CurPrey);
				CurPrey.healthCurr = -1;
			}
		}
		
		for (CurPrey in bowelsContents) {
			if (CurPrey.healthCurr == 0) {
				RetArray.push(CurPrey);
				CurPrey.healthCurr = -1;
			}
		}
		
		return RetArray;
	}
	
	public function updateTime(minutes:Int):Void {
		this.minute += minutes;
		while (this.minute >= 60) {
			this.minute -= 60;
			this.hour += 1;
		}
		while (this.hour >= 24) {
			this.hour -= 24;
			this.day += 1;
		}
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