import flash.*;
import flash.utils.*;

class MyItem_Ring extends MyItem {
	//Rings, extra bonuses mostly
	
	public function equip(playerCharacter:MyPlayerObject):String {
		var ringUnequip:MyItem_Ring = new MyItem_Ring();
		var itemIndex:Int = -1;
		var message:String = "";
		var special:String = "";
		var specialValue:Int = 0;
		
		for (i in 0...playerCharacter.invObject.length) {
			if (playerCharacter.invObject[i].name == this.name)
				itemIndex = i;
		}
		
		if (playerCharacter.invObject[itemIndex].count > 1) {
			playerCharacter.invObject[itemIndex].count--;
		} else {
			playerCharacter.invObject.remove(this);
		}
		
		if (playerCharacter.equipRing != null) {
			ringUnequip = playerCharacter.equipRing;
			ringUnequip.count = 1;
			playerCharacter.equipRing = this;
			ringUnequip.give(playerCharacter);
			message += "<p>You slide the " + ringUnequip.name.toLowerCase() + " off and return it to your pack then slide the " + this.name.toLowerCase() + " on in it's place.</p>";
		} else {
			playerCharacter.equipRing = this;
			message += "<p>You slide the " + this.name.toLowerCase() + " on your finder.</p>";
		}
		
		if (this.specials.length != 0) {
			for (i in 0...this.specials.length) {
				special = this.specials[i].split("|")[0];
				specialValue = Std.parseInt(this.specials[i].split("|")[1]);
				playerCharacter.tempSkill(special, specialValue);
			}
		}
		
		if (ringUnequip != null) {
			for (i in 0...ringUnequip.specials.length) {
				special = ringUnequip.specials[i].split("|")[0];
				specialValue = Std.parseInt(ringUnequip.specials[i].split("|")[1]);
				playerCharacter.tempSkill(special, -specialValue);
			}
		}
		
		return message;
	}
	
	public function copyItem():MyItem_Ring {
		var newItem:MyItem_Ring = new MyItem_Ring();
		
		newItem.type = "ring";
		newItem.name = this.name;
		newItem.mass = this.mass;
		newItem.value = this.value;
		newItem.desc = this.desc;
		newItem.specials = new Array();
		
		return newItem;
	}
	
	public function newRing(ring:Array<Dynamic>) {
		this.type = "ring";
		this.name = ring[0];
		this.mass = ring[1];
		this.value = ring[2];
		this.desc = ring[3];
	}
	
	public function new() {
		super();
	}
}