import flash.*;
import flash.utils.*;

class MyItem_Weapon extends MyItem {
	
	public var attack:Int;
	public var twoHanded:Bool;
	public var finisher:String;
	
	/*Special array structure;
	 * specials[x][0] = ability name
	 * specials[x][1] = ability description
	 * specials[x][2] = ability target (player/foe)
	 * specials[x][3] = ability effect (damage/healing/weight/etc)
	 * specials[x][4] = ability amount
	 */ 
	
	public function equip(playerCharacter:MyPlayerObject):String {
		var wepUnequip:MyItem_Weapon = new MyItem_Weapon();
		var itemIndex:Int = -1;
		var message:String = "";
		var special:String = "";
		var specialValue:Int = 0;
		
		for (i in 0...playerCharacter.invObject.length) {
			if (playerCharacter.invObject[i].name == this.name)
				itemIndex = i;
		}
		
		if (playerCharacter.invObject[itemIndex].count > 1) {
			playerCharacter.invObject[itemIndex].count - 1;
		} else {
			playerCharacter.invObject.remove(this);
		}
		
		if (playerCharacter.equipWepObj != null) {
			wepUnequip = playerCharacter.equipWepObj;
			wepUnequip.count = 1; // Just to be sure
			playerCharacter.equipWepObj = this;
			
			if (wepUnequip.name != "Fists") {//The fists don't need to be stored in the player's invintory
				wepUnequip.give(playerCharacter);
				message = "<p>You return your " + wepUnequip.name.toLowerCase() + " to your pack and ready your " + this.name.toLowerCase() + " in your hand";
			} else {
				message = "<p>You ready your " + this.name.toLowerCase() + " in your hand";
			}
			
			if (this.twoHanded)
				message += "s";
			
			message += ".</p><br>";
		} else {
			//This should never get called, since the 'fists' count as a weapon
			playerCharacter.equipWepObj = this;
			
			message = "<p>You ready your " + this.name.toLowerCase() + " in your hand";
			
			if (this.twoHanded)
				message += "s";
			
			message += ".</p><br>";
		}
		if (this.specials.length != 0) {
			for (i in 0...this.specials.length) {
				special = this.specials[i].split("|")[0];
				specialValue = Std.parseInt(this.specials[i].split("|")[1]);
				playerCharacter.tempSkill(special, specialValue);
			}
		}
		
		if (wepUnequip.name != "Fists") {
			for (i in 0...wepUnequip.specials.length) {
				special = wepUnequip.specials[i].split("|")[0];
				specialValue = Std.parseInt(wepUnequip.specials[i].split("|")[1]);
				playerCharacter.tempSkill(special, -specialValue);
			}
		}
		
		return message;
	}
	
	public function copyItem():MyItem_Weapon {
		var newItem:MyItem_Weapon = new MyItem_Weapon();
		
		newItem.type = "weapon";
		newItem.name = this.name;
		newItem.mass = this.mass;
		newItem.value = this.value;
		newItem.desc = this.desc;
		newItem.attack = this.attack;
		newItem.twoHanded = this.twoHanded;
		newItem.finisher = this.finisher;
		newItem.specials = new Array();
		
		return newItem;
	}
	
	public function newWeapon(weapon:Array<Dynamic>) {
		this.type = "weapon";
		this.name = weapon[0];
		this.mass = weapon[1];
		this.value = weapon[2];
		this.desc = weapon[3];
		this.attack = weapon[4];
		this.twoHanded = weapon[5];
		this.specials = weapon[7];
		this.finisher = weapon[6];
	}
	
	public function new(){
		super();
	}
}