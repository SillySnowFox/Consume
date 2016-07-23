
class MyCharacter {
	// All characters will start from this class. Players, random NPCs and named NPCs
	
	public var name:String;
	
	//Physical descriptors
	public var species:MySpecies;
	public var skin:String;
	public var tail:Bool;
	public var taliDesc:String;
	public var mouth:String;
	public var legs:String;
	public var arms:String;
	public var hands:String;
	public var feet:String;
	public var sphincter:String;
	
	//Mesurements
	public var tall:Float; // in inches
	public var weight:Float; // in pounds, not including stomach contents
	public var fat:Int; // fatness, in pounds
	public var chestSize:Int; // bra band size, in inches
	public var waistSize:Int; // size around waist, in inches, not including stomach
	public var hipSize:Float; // size around hips, in inches
	public var buttSize:Int; // size of butt, in inches, beyond hipSize
	
	//Sex bits
	public var breasts:Bool;
	public var vagina:Bool;
	public var penis:Bool;
	public var balls:Bool;
	public var lac:Bool;
	
	//Sex bits sizes
	public var breastSize:Int;
	public var penisL:Float;
	public var penisW:Float;
	public var ballSize:Float;
	public var errect:Float; //Errection multiplier
	
	//Containers
	public var stomachCap:Float; // capacity of stomach, in cubic inches
	public var bowelsCap:Float; // capacity of bowels, in cubic inches
	public var breastCap:Float; // milk capacity, if lactating, in gallons
	public var cumCap:Float; // ball cum capacity, in ounces
	
	//Fullness
	public var stomachCurrent:Float; // current fullness, in cubic inches
	public var breastCurrent:Float; // current milk fullness, in gallons
	public var cumCurrent:Float; // in ounces
	public var bowelsCurrent:Float = 0;
	
	//Item arrays for contents
	public var stomachContents:Array<MyNPC>; // Current contants of player's stomach
	public var bowelsContents:Array<MyNPC>; //Current contents of player's bowels
	public var breastContents:Array<MyNPC>;
	public var ballContents:Array<MyNPC>;
	
	//Digestion stuff
	public var fatGain:Int; //fat gain rate
	public var milkGain:Float; //milk gain rate
	public var cumGain:Float; //cum gain rate
	public var digestDamage:Float; //How much damage per tick (minute) the character's stomach does to consumed objects
	
	//Streatching
	public var stretchRateStomach:Int; //How many ticks (minutes) the character's stomach needs to be over capacity to stretch larger
	public var stretchRateBowels:Int; //Ticks to stretch bowels
	public var stretchRateMilk:Int; //Ticks to stretch milk
	public var stretchRateCum:Int; //Ticks to stretch cum
	
	public var stretchAmountStomach:Int; //how much the character's stomach stretches
	public var stretchAmountBowels:Int;
	public var stretchAmountMilk:Float;
	public var stretchAmountCum:Float;
	
	//Sins
	public var pride:Int;
	public var lust:Int;
	public var greed:Int;
	public var wrath:Int;
	public var gluttony:Int;
	public var sloth:Int;
	public var envy:Int;
	
	//Stats
	public var healthCurr:Int;
	public var healthMax:Int;
	public var str:Int;
	public var agi:Int;
	public var end:Int;
	public var int:Int;
	
	public var arousal:Int;
	
	private var perks:Array<MyPerk>;
	
	public function gender(pronoun:String):String {
		var genderString:String = "";
		var returnString:String = "";
		var perkEffectList:Array<String> = new Array();
		var perkAction:Array<String> = new Array();
		var perkTarget:String = "";
		var perkValue:String = "";
		
		if (this.breasts && this.vagina && !this.penis && !this.balls)
			genderString = "Female";
		if (!this.breasts && !this.vagina && this.penis && (this.balls || !this.balls))
			genderString = "Male";
		if ((this.breasts || !this.breasts) && this.vagina && this.penis && (this.balls || !this.balls))
			genderString = "Herm";
		if (this.breasts && !this.vagina && this.penis && (!this.balls || this.balls))
			genderString = "Dickgirl";
		if (this.breasts && !this.vagina && !this.penis && !this.balls)
			genderString = "Doll";
		if (!this.breasts && this.vagina && !this.penis && !this.balls)
			genderString = "Cuntboy";
		if (!this.breasts && !this.vagina && !this.penis && !this.balls)
			genderString = "Neuter";
		
		for (i in 0...this.perks.length) {
			perkEffectList = this.perks[i].effect.split(" ");
			for (x in 0...perkEffectList.length) {
				perkAction = perkEffectList[x].split(":");
				perkTarget = perkAction[0];
				if (perkAction.length > 1) {
					perkValue = Std.string(perkAction[1]);
				}
				
				if (perkTarget == "GENDER")
					genderString = perkValue;
			}
		}
		
		switch (pronoun) {
		case "gender":
			returnString = genderString;
		case "sub":
			//Subjective pronoun
			switch (genderString) {
			case "Female":
				returnString = "She";
			case "Male":
				returnString = "He";
			case "Herm":
				returnString = "Shi";
			case "Dickgirl":
				returnString = "She";
			case "Doll":
				returnString = "She";
			case "Cuntboy":
				returnString = "He";
			case "Neuter":
				returnString = "He";
			}
		case "obj":
			//Objective pronoun
			switch (genderString) {
			case "Female":
				returnString = "Her";
			case "Male":
				returnString = "Him";
			case "Herm":
				returnString = "Hir";
			case "Dickgirl":
				returnString = "Her";
			case "Doll":
				returnString = "Her";
			case "Cuntboy":
				returnString = "Him";
			case "Neuter":
				returnString = "Him";
			}
		case "pos":
			//Possessive pronoun
			switch (genderString) {
			case "Female":
				returnString = "Her";
			case "Male":
				returnString = "His";
			case "Herm":
				returnString = "Hir";
			case "Dickgirl":
				returnString = "Her";
			case "Doll":
				returnString = "Her";
			case "Cuntboy":
				returnString = "His";
			case "Neuter":
				returnString = "His";
			}
		}
		
		return returnString;
	}
	
	public function stomachSizeDesc():String {
		var message:String = "";
		var size:Int = this.stomachSize();
		
		message = size + "in";
		
		if (size <= 3)
			message = "flat";
		if (size > 3 && size <= 6)
			message = "small";
		if (size > 6 && size <= 8)
			message = "round";
		if (size > 8 && size <= 10)
			message = "bulging";
		if (size > 10 && size <= 20)
			message = "big";
		if (size > 20 && size <= 30)
			message = "huge";
		if (size > 30 && size <= 40)
			message = "massive";
		if (size > 40 && size <= 50)
			message = "doorway-filling";
		if (size > 50 && size <= 60)
			message = "person-sized";
		if (size > 60 && size <= 80)
			message = "immoblizing";
		if (size > 80)
			message = "impossible";
		
		
		return message;
	}
	
	public function breastSizeDesc():String {
		var message:String = "";
		var size:Int = this.breastDiam();
		
		if (size <= 3)
			message = "tiny";
		if (size > 3 && size <= 6)
			message = "small";
		if (size > 6 && size <= 8)
			message = "average";
		if (size > 8 && size <= 10)
			message = "big";
		if (size > 10 && size <= 14)
			message = "large";
		if (size > 14 && size <= 20)
			message = "huge";
		if (size > 20 && size <= 30)
			message = "massive";
		if (size > 30 && size <= 50)
			message = "door-filling";
		if (size > 50 && size <= 90)
			message = "person-sized";
		if (size > 90 && size <= 200)
			message = "room-filling";
		if (size > 200)
			message = "off the charts";
		
		return message;
	}
	
	public function chestSizeDesc():String {
		var message:String = "";
		var size:Int = this.chestSize;
		
		//Change this into a description, like the breast size later
		
		message = size + " inch";
		
		
		return message;
	}
	
	public function strDesc():String {
		var message:String = "";
		var size:Int = this.str;
		var perkEffectList:Array<String> = new Array();
		var perkAction:Array<String> = new Array();
		var perkTarget:String = "";
		var perkValue:Int = 0;
		
		for (i in 0...this.perks.length) {
			perkEffectList = this.perks[i].effect.split(" ");
			for (x in 0...perkEffectList.length) {
				perkAction = perkEffectList[x].split(":");
				perkTarget = perkAction[0];
				if (perkAction.length > 1) {
					perkValue = Std.parseInt(perkAction[1]);
				}
				
				if (perkTarget == "MUSCLES")
					size += perkValue;
			}
		}
		
		if (size <= 3)
			message = "non-existent";
		if (size > 3 && size <= 5)
			message = "small";
		if (size > 5 && size <= 7)
			message = "average";
		if (size > 7 && size <= 11)
			message = "big";
		if (size > 11 && size <= 20)
			message = "huge";
		if (size > 20 && size <= 30)
			message = "massive";
		if (size > 30 && size <= 50)
			message = "bulging";
		if (size > 50)
			message = "off the chart";
		
		message += " muscles";
		
		return message;
	}
	
	public function ballSizeDesc():String {
		var message:String = "";
		var size:Int = this.ballDiam();
		
		if (size <= 3)
			message = "tiny";
		if (size > 3 && size <= 6)
			message = "small";
		if (size > 6 && size <= 8)
			message = "average";
		if (size > 8 && size <= 10)
			message = "big";
		if (size > 10 && size <= 14)
			message = "large";
		if (size > 14 && size <= 20)
			message = "huge";
		if (size > 20 && size <= 30)
			message = "massive";
		if (size > 30 && size <= 50)
			message = "door-filling";
		if (size > 50 && size <= 90)
			message = "person-sized";
		if (size > 90 && size <= 200)
			message = "room-filling";
		if (size > 200)
			message = "off the charts";
		
		return message;
	}
	
	public function toFeet(inches:Float):String {
		var feet:Int = 0;
		
		while (inches > 11) {
			feet += 1;
			inches -= 12;
		}
		
		return (feet + "'" + inches + "\"");
	}
	
	public function breastDiam():Int {
		var breastWidth:Int = 0;
		var modBreastSize:Int = this.breastSize;
		var bigBreastVal:Int = 0;
		var breastMass:Float = 0;
		var perkEffectList:Array<String> = new Array();
		var perkAction:Array<String> = new Array();
		var perkTarget:String = "";
		var perkValue:Int = 0;
		
		for (i in 0...this.perks.length) {
			perkEffectList = this.perks[i].effect.split(" ");
			for (x in 0...perkEffectList.length) {
				perkAction = perkEffectList[x].split(":");
				perkTarget = perkAction[0];
				if (perkAction.length > 1) {
					perkValue = Std.parseInt(perkAction[1]);
				}
				
				if (perkTarget == "BREASTSIZE")
					modBreastSize += perkValue;
			}
		}
		
		breastMass = this.breastCurrent + this.breastSize;
		
		//breastWidth. breastCurrent same as stomach except the value is for both breasts. So we need to get the size of one boob.
		breastWidth = Math.round(2 * Math.pow((3 * (breastMass / 2)) / (4 * Math.PI), 1 / 3));
		
		if (breastWidth < modBreastSize)
			return modBreastSize;
		
		return breastWidth;
	}
	
	public function stomachSize():Int {
		var stomachWidth:Int = 0;
		var bigBellyVal:Int = 0;
		var stomachMass:Float = 0;
		var perkEffectList:Array<String> = new Array();
		var perkAction:Array<String> = new Array();
		var perkTarget:String = "";
		var perkValue:Int = 0;
		
		for (i in 0...this.perks.length) {
			perkEffectList = this.perks[i].effect.split(" ");
			for (x in 0...perkEffectList.length) {
				perkAction = perkEffectList[x].split(":");
				perkTarget = perkAction[0];
				if (perkAction.length > 1) {
					perkValue = Std.parseInt(perkAction[1]);
				}
				
				if (perkTarget == "BELLYSIZE")
					bigBellyVal += perkValue;
			}
		}
		
		if (this.stomachCurrent > bigBellyVal) {
			stomachMass = this.stomachCurrent;
		} else {
			stomachMass = bigBellyVal;
		}
		
		//stomachWidth. stomachCurrent is the player's current stomach mass in cubic inches. so have to translate that into a diamater
		//formula D=2(((3V)/(4pi))^(1/3))
		stomachWidth = Math.round(2 * Math.pow((3 * stomachMass) / (4 * Math.PI), (1 / 3)));
		
		
		
		return stomachWidth;
	}
	
	public function ballDiam():Int {
		var ballWidth:Int = 0;
		var bigBallVal:Float = this.ballSize;
		var ballMass:Float = 0;
		var perkEffectList:Array<String> = new Array();
		var perkAction:Array<String> = new Array();
		var perkTarget:String = "";
		var perkValue:Int = 0;
		
		for (i in 0...this.perks.length) {
			perkEffectList = this.perks[i].effect.split(" ");
			for (x in 0...perkEffectList.length) {
				perkAction = perkEffectList[x].split(":");
				perkTarget = perkAction[0];
				if (perkAction.length > 1) {
					perkValue = Std.parseInt(perkAction[1]);
				}
				
				if (perkTarget == "BALLSIZE")
					bigBallVal += perkValue;
			}
		}
		
		ballMass = this.ballSize + this.cumCurrent;
		
		ballWidth = Math.round(2 * Math.pow((3 * (ballMass / 2)) / (4 * Math.PI), 1 / 3));
		
		if (ballWidth < bigBallVal)
			return Math.round(bigBallVal);
		
		return ballWidth;
	}
	
	public function penisLength():Int {
		var cockLength:Int = 0;
		var bigCockVal:Float = this.penisL;
		var cockMass:Float = 0;
		var perkEffectList:Array<String> = new Array();
		var perkAction:Array<String> = new Array();
		var perkTarget:String = "";
		var perkValue:Int = 0;
		
		for (i in 0...this.perks.length) {
			perkEffectList = this.perks[i].effect.split(" ");
			for (x in 0...perkEffectList.length) {
				perkAction = perkEffectList[x].split(":");
				perkTarget = perkAction[0];
				if (perkAction.length > 1) {
					perkValue = Std.parseInt(perkAction[1]);
				}
				
				if (perkTarget == "PENISLENGTH")
					bigCockVal += perkValue;
			}
		}
		
		if (this.arousal < 50)
			cockMass = bigCockVal;
		if (this.arousal >= 50 && this.arousal < 100)
			cockMass = bigCockVal * this.errect;
		if (this.arousal >= 100)
			cockMass = bigCockVal * (this.errect * 1.5);
		
		cockLength = Math.round(cockMass);
		
		return cockLength;
	}
	
	public function penisDiam():Int {
		var cockWidth:Int = 0;
		var bigCockVal:Float = this.penisW;
		var cockMass:Float = 0;
		var perkEffectList:Array<String> = new Array();
		var perkAction:Array<String> = new Array();
		var perkTarget:String = "";
		var perkValue:Int = 0;
		
		for (i in 0...this.perks.length) {
			perkEffectList = this.perks[i].effect.split(" ");
			for (x in 0...perkEffectList.length) {
				perkAction = perkEffectList[x].split(":");
				perkTarget = perkAction[0];
				if (perkAction.length > 1) {
					perkValue = Std.parseInt(perkAction[1]);
				}
				
				if (perkTarget == "PENISWIDTH")
					bigCockVal += perkValue;
			}
		}
		
		if (this.arousal < 50)
			cockMass = bigCockVal;
		if (this.arousal >= 50 && this.arousal < 100)
			cockMass = bigCockVal * this.errect;
		if (this.arousal >= 100)
			cockMass = bigCockVal * (this.errect * 1.5);
		
		cockWidth = Math.round(cockMass);
		
		return cockWidth;
	}
	
	public function addPerk(addThis:MyPerk):Bool {
		var lastChar:String = "";
		var perkRank:Int = -1;
		
		// Function to add a perk to a character. Returns true if the perk is successuflly added. False if something goes wrong (such as the character already having that perk or missing a lower ranked perk of the same type)
		
		//First thing to do is make sure the character doesn't already have the perk we are trying to add
		if (this.hasPerk(addThis.name))
			return false;
		
		lastChar = addThis.name.charAt(addThis.name.length - 1);
		
		//Next we check if they have the lower-ranked versions (assuming it has multiple ranks)
		if (!Math.isNaN(Std.parseFloat(lastChar))) {
			perkRank = Std.parseInt(lastChar);
			
			if (perkRank != 1) {
				//New perk is not a rank 1 perk. So we have to check if the character already has the lower level perk.
				//Just going to check for the next lowest, rather then the whole chain for simplicity's sake
				
				if (!this.hasPerk(addThis.name.substr(0, addThis.name.length - 1) + (perkRank - 1)))
					return false;
			}
		}
		
		//Everything is good, all prereqs are met. Add the perk to the character.
		this.perks.push(addThis);
		
		return true;
	}
	
	public function hasPerk(perkName:String):Bool {
		// Function to test if the character has a perk named 'perkName'. perkName should match the 'name' field of a MyPerk object, not the dispName field.
		var testResult:Bool = false;
		
		for (i in 0...this.perks.length) {
			if (this.perks[i].name == perkName)
				testResult = true;
		}
		
		return testResult;
	}
	
	public function removePerk(perkName:String):Bool {
		// Function to remove a perk named 'perkName' from a character. Returns true if the perk was removed. False if it was not. Will also return false if the character didn't have the perk to start.
		//Should probably add a check to make sure we're not removing a prereq perk, but this function should never be called anyway.
		var perkID:Int = -1;
		
		for (i in 0...this.perks.length) {
			if (this.perks[i].name == perkName)
				perkID = i;
		}
		
		if (perkID == -1)
			return false;
		
		this.perks.remove(this.perks[perkID]);
		return true;
	}
	
	public function newCharacter(species:MySpecies, breasts:Bool, vagina:Bool, penis:Bool, balls:Bool, str:Int, agi:Int, end:Int, int:Int, name:String = "NPC", ?perks:Array<MyPerk>) {
		var rndHeight:Int = 0;
		var rndWeight:Int = 0;
		var heightRange:Int = 0;
		var weightRange:Int = 0;
		
		this.species = species;
		
		this.name = species.name;
		this.arms = species.arms;
		this.skin = species.skin;
		this.legs = species.legs;
		this.tail = species.tail;
		this.taliDesc = species.taliDesc;
		this.mouth = species.mouth;
		this.hands = species.hands;
		this.feet = species.feet;
		this.sphincter = species.sphincter;
		
		this.breasts = breasts;
		this.vagina = vagina;
		this.penis = penis;
		this.balls = balls;
		this.lac = false;
		
		this.breastSize = species.breasts;
		this.penisL = species.penisL;
		this.penisW = species.penisW;
		this.ballSize = species.balls;
		this.errect = species.errect;
		
		this.stomachCap = species.stomach;
		this.bowelsCap = species.bowels;
		this.breastCap = species.milk;
		this.cumCap = species.cum;
		
		this.fatGain = species.fatGain;
		this.milkGain = species.milkGain;
		this.cumGain = species.cumGain;
		this.digestDamage = species.digestDamage;
		
		this.stretchRateStomach = species.stretchRateStomach;
		this.stretchRateBowels = species.stretchRateBowels;
		this.stretchRateMilk = species.stretchRateMilk;
		this.stretchRateCum = species.stretchRateCum;
		
		this.stretchAmountStomach = species.stretchAmountStomach;
		this.stretchAmountBowels = species.stretchAmountBowels;
		this.stretchAmountMilk = species.stretchAmountMilk;
		this.stretchAmountCum = species.stretchAmountCum;
		
		//Determin the player's maleness, which affects how much they start with here
		
		heightRange = species.maxHeight - species.minHeight;
		weightRange = species.maxWeight - species.minWeight;
		
		rndHeight = species.minHeight + Math.round(Math.random() * heightRange);
		rndWeight = species.minWeight + Math.round(Math.random() * weightRange);
		
		this.tall = rndHeight;
		this.weight = rndWeight;
		
		
		if (breasts) {
			this.chestSize = species.minChest;
			this.waistSize = species.minWaist;
		} else {
			this.chestSize = species.maxChest;
			this.waistSize = species.maxWaist;
		}
		if (penis) {
			this.hipSize = species.minHips;
			this.buttSize = species.minButt;
		} else {
			this.hipSize = species.maxHips;
			this.buttSize = species.maxHips;
		}
		
		this.fat = 0;
		this.stomachCurrent = 10;
		this.breastCurrent = 0;
		this.cumCurrent = 0;
		this.bowelsCurrent = 0;
		
		this.str = str;
		this.agi = agi;
		this.end = end;
		this.int = int;
		
		this.healthMax = 5 + (this.end * 2);
		this.healthCurr = this.healthMax;
		
		this.name = name;
		
		if (perks != null) {
			this.perks = new Array();
			for (i in 0...perks.length) {
				if (!this.addPerk(perks[i]))
					new AlertBox("ERROR: Perk '" + perks[i].dispName + "' not added.");
			}
		}
	}
	
	public function new() {
		
	}
}