package;
import flash.Lib;
import flash.utils.Object;

class PlayerCharacter {

	public function new() {
		
	}
	
	public function addPerk(perk:Int) {
		var globals:Object = Lib.current.getChildByName("GlobalVars");
		var newPerk:MyPerk = new MyPerk(globals.perks[perk]);
		
		if (!hasPerk(globals.perks[perk].name)) {
			perks.push(newPerk);
		}
	}
	
	public function hasPerk(perk:String):Bool {
		var ifPerk:Bool = false;
		
		for (i in 0...perks.length) {
			if (perks[i].name == perk)
				ifPerk = true;
		}
		
		return ifPerk;
	}
	
	public function changeStat(stat:String, value:Int = 1) {
		switch stat {
		case "str":
			str += value;
		case "agi":
			agi += value;
		case "end":
			end += value;
		case "int":
			int += value;
		default:
			new AlertBox("Error, bad stat: " + stat + " in PlayerCharacter changeStat");
		}
	}
	
	public var playerName:String = "Consume";
	public var species:String = "";
	
	public var hour:Int = 0;
	public var minute:Int = 0; // minutes since midnight
	public var day:Int = 0;
	public var tall:Float = 0; // in inches
	public var weight:Float = 0; // in pounds, not including stomach contents
	public var fat:Float = 0; // fatness, in pounds
	public var chestSize:Float = 0; // bra band size, in inches
	public var waistSize:Float = 0; // size around waist, in inches, not including stomach
	public var hipSize:Float = 0; // size around hips, in inches
	public var buttSize:Float = 0; // size of butt, in inches, beyond hipSize
	
	public var stretch:Float = 0; // how much the player stretches when overfull
	public var stomachCap:Float = 0; // capacity of stomach, in cubic inches
	public var stomachCurrent:Float = 0; // current fullness, in cubic inches
	public var stomachContents:Array<Dynamic> = new Array(); // Current contants of player's stomach
	public var stomachStretchRate:Float = 0; // # of minutes until the player's stomach stretches
	public var stomachStretchTimer:Float = 0; // # of minutes remaining until the player's stomach stretches
	public var bowelsCap:Float = 0; // capacity of bowels, in cubic inches
	public var bowelsCurrent:Float = 0; 	// current bowel fullness, in cubic inches.
											// Ignored if allowScat is false
	public var bowelsContents:Array<Dynamic> = new Array(); //Current contents of player's bowels
	public var bowelsStretchRate:Float = 0; // # of minutes until the player's gut stretches
	public var bowelsStretchTimer: Float = 0; // # of minutes left until the player's gut stretches
	public var healthCurr:Float = 0;
	public var healthMax:Float = 0;
	public var str:Int = 0;
	public var agi:Int = 0;
	public var end:Int = 0;
	public var int:Int = 0;
	public var upgradeRemain:Int = 0;
	public var upgradeSpent:Int = 0;
	public var strNeededToUp:Int = 0;
	public var agiNeededToUp:Int = 0;
	public var endNeededToUp:Int = 0;
	public var intNeededToUp:Int = 0;
	public var arousal:Int = 0;
	public var money:Int = 0;
	public var numEaten:Int = 0;

	// Sex stuff
	//Gender will be determinded dynamically now.
	public var breasts:Bool = false;
	public var vagina:Bool = false;
	public var penis:Bool = false;
	public var balls:Bool = false;
	
	public var breastSize:Float = 0; // cup size, in inches beyond chestSize
	public var breastStretchRate:Float = 0;
	public var breastStretchTimer:Float = 0;
	public var lac:Bool = false; // lactation
	public var breastCap:Float = 0; // milk capacity, if lactating, in gallons
	public var breastCurrent:Float = 0; // current milk fullness, in gallons
	public var penisLength:Float = 0; // cock length, in inches
	public var penisWidth:Float = 0; // cock width (thickness), in inches
	public var penisErrectMulti:Float = 0; // errection multiplier
	public var ballSize:Float = 0; // testicle diamitar, in inches (of one)
	public var cumCap:Float = 0; // ball cum capacity, in ounces
	public var cumCurrent:Float = 0; // in ounces
	public var cumStretchRate:Float = 0;
	public var cumStretchTimer:Float = 0;

	// Digestion stuff
	public var digRate:Float = 0; // cubic inches digested per hour, decreases stomachCurrent
	public var digEff:Float = 0; 	// % of digested material converted
									// remander is added to bowelCurrent
	public var cumEff:Float = 0; 	// % of converted material turned into cum, should fill in 8 hours
									// only applies if the character has balls
	public var lacEff:Float = 0; 	// % of converted material turned into milk
									// only applies if the character has breasts and is lactating
	public var energyUse:Float = 0;	// Recharge rate for energy
	public var fatEff:Float = 0;	// % of converted material turned into fat
									// fatEff + cumEff (and/or) lacEff + energyUse should equal 100
	
	public var quest:Array<Dynamic> = [0, 0, 0, 0, 0];
	// Outdated, use invObject
	public var invObject:Array<Dynamic> = new Array();
	public var equipWepObj:MyItem_Weapon;
	public var equipArmObj:MyItem_Armor;
	
	public var lastDayTrained:Int = -1;
	public var lastClubDay:Int = -1;
	
	//Sins
	public var pride:Int = 0;
	public var lust:Int = 0;
	public var greed:Int = 0;
	public var wrath:Int = 0;
	public var gluttony:Int = 0;
	public var sloth:Int = 0;
	public var envy:Int = 0;
	
	public var lastGoldTrainDay = 0;

	public var perks:Array<Dynamic> = new Array();
}