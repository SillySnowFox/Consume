import flash.display.Bitmap;
import flash.Lib;
import flash.utils.Object;

class MyNPC extends MyCharacter {

	public var mass:Int;
	public var talk:Array<Dynamic>;
	public var weapon:MyItem_Weapon;
	public var armor:MyItem_Armor;
	public var likeVore:Bool;
	
	public var image:Bitmap;
	
	public function newNPC(newChar:Array<Dynamic>) {
		this.name = newChar[0];
		this.species = newChar[1];
		this.breasts = newChar[2];
		this.vagina = newChar[3];
		this.penis = newChar[4];
		this.balls = newChar[5];
		this.tall = newChar[6];
		this.mass = newChar[7];
		this.talk = newChar[8];
		this.image = newChar[9];
	}
	
	public function npcDesc():String {
		var message:String = "";
		var globals:Object = Lib.current.getChildByName("GlobalVars");
		
		if (this.likeVore)
			this.arousal = 100;
		
		message += this.gender("sub") + " stands " + toFeet(this.tall) + " tall.";
		
		//head/face
		
		message += " " + this.gender("sub") + " has ";
		
		if (this.breasts) {
			//NPC has breasts
			if (this.hasPerk("mulbo1")) {
				message += "four ";
			} else {
				message += "two ";
			}
			
			message += this.breastSizeDesc() + " breasts resting on " + this.gender("pos").toLowerCase() + " " + this.chestSizeDesc() + " ";
		} else {
			//NPC does not have breasts
			
			message += "a flat " + this.chestSizeDesc() + " ";
		}
		
		message += "chest with " + this.strDesc() + ".";
		
		message += " Two " + this.arms + " ending in " + this.hands + " rest at " + this.gender("pos").toLowerCase() + " sides. ";
		
		message += this.gender("sub") + " has a " + this.stomachSizeDesc() + " stomach. ";
		
		if (this.penis) {
			//NPC has at least one dick
			message += this.gender("sub") + " has ";
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
			message += " Two " + this.ballSizeDesc() + " balls hang below " + this.gender("pos").toLowerCase() + " cock";
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
			
			message += "slit waits between " + this.gender("pos").toLowerCase() + "'s " + this.legs + ".";
		}
		if (!this.penis && !this.vagina) {
			//No cock, no vagina
			message += " " + this.gender("pos") + " crotch is smooth and unbroken by any genitalia.";
		}
		if (this.tail) {
			//NPC has a tail
			message += " A " + this.taliDesc + " tail sways behind " + this.gender("pos").toLowerCase() + ".";
		}
		
		message += " Two " + this.legs + " support " + this.gender("pos").toLowerCase() + " each ending in " + this.feet + ".";
		
		return message;
	}
	
	public function randomNPC(species:Array<MySpecies>, playerObject:MyPlayerObject, addPoints:Int = 0) {
		var playerPoints:Int = playerObject.pointsSpent;
		var avilPoints:Int = playerPoints + addPoints;
		var hasBreasts:Bool = false;
		var hasVagina:Bool = false;
		var hasPenis:Bool = false;
		var hasBalls:Bool = false;
		var npcGenderString:String = "ERROR";
		var npcSpeciesIndex:Int = -1;
		var newNPCArray:Array<Dynamic> = new Array();
		var i:Int = 0;
		var strTmp:Int = 0;
		var agiTmp:Int = 0;
		var endTmp:Int = 0;
		var intTmp:Int = 0;
		var npcMods:Array<Dynamic> = [["starving", -50], ["skinny", -10], [" ", 0], ["chubby", 20], ["heavy", 50], ["fat", 100], ["huge", 200], ["fit", 15], ["muscular", 20]];
		var npcName:String = "";
		var globals:Object = Lib.current.getChildByName("GlobalVars");
		
		//First pick gender
		if (Math.round(Math.random()) == 0)
			hasBreasts = true;
		if (Math.round(Math.random()) == 0)
			hasVagina = true;
		if (Math.round(Math.random()) == 0)
			hasPenis = true;
		if (Math.round(Math.random()) == 0 && hasPenis)
			hasBalls = true;
		
		//Gender error check;
		if (hasBreasts && hasVagina && !hasPenis && !hasBalls)
			npcGenderString = "female";
		if (!hasBreasts && !hasVagina && hasPenis && (hasBalls || !hasBalls))
			npcGenderString = "male";
		if ((hasBreasts || !hasBreasts) && hasVagina && hasPenis && (hasBalls || !hasBalls))
			npcGenderString = "herm";
		if (hasBreasts && !hasVagina && !hasPenis && !hasBalls)
			npcGenderString = "doll";
		if (!hasBreasts && !hasVagina && !hasPenis && !hasBalls)
			npcGenderString = "neuter";
		if (hasBreasts && !hasVagina && hasPenis && (hasBalls || !hasBalls))
			npcGenderString = "dgirl";
		if (!hasBreasts && hasVagina && !hasPenis && !hasBalls)
			npcGenderString = "cboy";
		
		if (npcGenderString == "ERROR") {
			new AlertBox("Bad gender in MyNPC.randomNPC");
		}
		
		newNPCArray[1] = hasBreasts;
		newNPCArray[2] = hasVagina;
		newNPCArray[3] = hasPenis;
		newNPCArray[4] = hasBalls;
		
		//next pick species
		npcSpeciesIndex = Math.round(Math.random() * (species.length - 1));
		
		if (npcSpeciesIndex >= species.length) {
			new AlertBox("Bad species in MyNPC.randomNPC (" + npcSpeciesIndex + ")");
		}
		
		newNPCArray[0] = species[npcSpeciesIndex];
		
		//Image selector goes here, if i ever get images anyway
		
		
		
		
		//NPC stats, addPoints increases/decreases the NPC's strength
		while (avilPoints != 0) {
			i = Math.floor(Math.random() * 4);
			
			switch (i) {
			case 0:
				strTmp += 1;
				avilPoints -= 1;
			case 1:
				agiTmp += 1;
				avilPoints -= 1;
			case 2:
				endTmp += 1;
				avilPoints -= 1;
			case 3:
				intTmp += 1;
				avilPoints -= 1;
			}
		}
		
		newNPCArray[5] = strTmp;
		newNPCArray[6] = agiTmp;
		newNPCArray[7] = endTmp;
		newNPCArray[8] = intTmp;
		
		//NPC Mod
		i = Math.round(Math.random() * (npcMods.length - 1));
		
		if (npcMods[i][0] != " ") {
			npcName = npcMods[i][0] + " " + species[npcSpeciesIndex].name.toLowerCase();
		} else {
			npcName = species[npcSpeciesIndex].name.toLowerCase();
		}
		
		this.newCharacter(newNPCArray[0], newNPCArray[1], newNPCArray[2], newNPCArray[3], newNPCArray[4], newNPCArray[5], newNPCArray[6], newNPCArray[7], newNPCArray[8], npcName);
		
		this.perks = new Array();
		
		switch (npcMods[i][0]) {
		case "starving":
			
		case "skinny":
			
		case "chubby":
			this.addPerk(globals.perks[10]);
		case "heavy":
			this.addPerk(globals.perks[10]);
			this.addPerk(globals.perks[11]);
		case "fat":
			this.addPerk(globals.perks[10]);
			this.addPerk(globals.perks[11]);
			this.addPerk(globals.perks[12]);
		case "huge":
			
		case "fit":
			
		case "muscular":
			this.addPerk(globals.perks[30]);
			
		}
		
		if (this.penis) {
			if (Math.round(Math.random()) == 0)
				this.addPerk(globals.perks[29]); //MultiCock
			
			switch (Math.round(Math.random() * 3)) {
			case 0:
				//Nothing
			case 1:
				this.addPerk(globals.perks[18]); //Big Cock
			case 2:
				this.addPerk(globals.perks[18]);
				this.addPerk(globals.perks[19]);
			case 3:
				this.addPerk(globals.perks[18]);
				this.addPerk(globals.perks[19]);
				this.addPerk(globals.perks[20]);
			}
		}
		if (this.balls) {
			switch (Math.round(Math.random() * 3)) {
			case 0:
				//Nothing
			case 1:
				this.addPerk(globals.perks[21]); //Big Balls
			case 2:
				this.addPerk(globals.perks[21]);
				this.addPerk(globals.perks[22]);
			case 3:
				this.addPerk(globals.perks[21]);
				this.addPerk(globals.perks[22]);
				this.addPerk(globals.perks[23]);
			}
		}
		if (this.breasts) {
			if (Math.round(Math.random()) == 0)
				this.addPerk(globals.perks[28]); //MultiBoob
			
			switch (Math.round(Math.random() * 3)) {
			case 0:
				//nothing
			case 1:
				this.addPerk(globals.perks[15]); //Big Breasts
			case 2:
				this.addPerk(globals.perks[15]);
				this.addPerk(globals.perks[16]);
			case 3:
				this.addPerk(globals.perks[15]);
				this.addPerk(globals.perks[16]);
				this.addPerk(globals.perks[17]);
			}
		}
		
		
		this.mass = Math.round(this.weight + npcMods[i][1]);
		
		if (Math.round(Math.random()) == 0) {
			this.likeVore = true;
		} else {
			this.likeVore = false;
		}
	}
	
	public function new() {
		super();
	}
}