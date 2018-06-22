import flash.*;
import flash.utils.*;

class MyItem_Armor extends MyItem {

	public var defend:Int;
	
	/*Special array structure;
	 * specials[x][0] = ability name
	 * specials[x][1] = ability description
	 * specials[x][2] = ability target (player/foe)
	 * specials[x][3] = ability effect (damage/healing/weight/etc)
	 * specials[x][4] = ability amount
	 */
	
	public function equip(playerCharacter:MyPlayerObject) {
		var armorUnequip:MyItem_Armor = new MyItem_Armor();
		var itemIndex:Int = -1;
		var message:String = "";
		var special:String = "";
		var specialValue:Int = 0;
		
		for (i in 0...playerCharacter.invObject.length) {
			if (playerCharacter.invObject[i].name == this.name)
				itemIndex = i;
		}
		
		if (playerCharacter.invObject[itemIndex].count > 1) {
			playerCharacter.invObject[itemIndex].count -= 1;
		} else {
			playerCharacter.invObject.remove(this);
		}
		
		if (playerCharacter.equipArmObj != null) {
			armorUnequip = playerCharacter.equipArmObj;
			armorUnequip.count = 1;
			playerCharacter.equipArmObj = this;
			
			if (armorUnequip.name != "Skin") {
				armorUnequip.give(playerCharacter);
				
				message = "<p>You return your " + armorUnequip.name.toLowerCase() + " to your pack and put your " + this.name.toLowerCase() + " on.</p><br>";
			} else {
				message = "<p>You put your " + this.name.toLowerCase() + " on.</p><br>";
			}
		} else {
			playerCharacter.equipArmObj = this;
			
			message = "<p>You put your " + this.name.toLowerCase() + " on.</p><br>";
		}
		
		if (this.specials.length != 0) {
			for (i in 0...this.specials.length) {
				special = this.specials[i].split("|")[0];
				specialValue = Std.parseInt(this.specials[i].split("|")[1]);
				playerCharacter.tempSkill(special, specialValue);
			}
		}
		
		if (armorUnequip.name != "Skin") {
			for (i in 0...armorUnequip.specials.length) {
				special = armorUnequip.specials[i].split("|")[0];
				specialValue = Std.parseInt(armorUnequip.specials[i].split("|")[1]);
				playerCharacter.tempSkill(special, -specialValue);
			}
		}
		
		return message;
	}
	
	public function copyItem():MyItem_Armor {
		var newItem:MyItem_Armor = new MyItem_Armor();
		
		newItem.type = "armor";
		newItem.name = this.name;
		newItem.mass = this.mass;
		newItem.value = this.value;
		newItem.desc = this.desc;
		newItem.defend = this.defend;
		newItem.specials = new Array();
		
		return newItem;
	}
	
	public function newArmor(armor:Array<Dynamic>) {
		this.type = "armor";
		this.name = armor[0];
		this.mass = armor[1];
		this.value = armor[2];
		this.desc = armor[3];
		this.defend = armor[4];
		this.specials = armor[5];
	}
	
	public function new() {
		super();
	}
}