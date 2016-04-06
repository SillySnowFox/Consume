import flash.*;
import flash.utils.*;

class MyItem_Armor extends MyItem {

	public var defend:Int;
	public var specials:Array<Dynamic> = new Array();
	
	/*Special array structure;
	 * specials[x][0] = ability name
	 * specials[x][1] = ability description
	 * specials[x][2] = ability target (player/foe)
	 * specials[x][3] = ability effect (damage/healing/weight/etc)
	 * specials[x][4] = ability amount
	 */
	
	public function equip() {
		var playerCharacter:Object = Lib.current.getChildByName("PlayerCharacter");
		
		var plrInv:Array<MyItem> = playerCharacter.invObject;
		var armorUnequip:MyItem = new MyItem();
		var itemIndex:Int = -1;
		var ignore:String = "";
		var message:String = "";
		
		for (i in 0...plrInv.length) {
			if (plrInv[i].name == this.name)
				itemIndex = i;
		}
		
		if (plrInv[itemIndex].count > 1) {
			plrInv[itemIndex].count -= 1;
		} else {
			plrInv.splice(itemIndex, 1);
		}
		
		if (playerCharacter.equipArmObj != null) {
			armorUnequip = playerCharacter.equipArmObj;
			armorUnequip.count = 1;
			playerCharacter.equipArmObj = this;
			
			armorUnequip.give();
			
			message = "<p>You return your " + armorUnequip.name.toLowerCase() + " to your pack and put your " + this.name.toLowerCase() + " on.</p><br>";
		} else {
			playerCharacter.equipArmObj = this;
			
			message = "<p>You put your " + this.name.toLowerCase() + " on.</p><br>";
		}
		
		playerCharacter.invObject = plrInv;
		
		return message;
	}
	
	public function new(name:String, mass:Int, value:Int, desc:String, newDefend:Int, newSpecials:Array<Dynamic>) {
		super();
		
		this.name = name;
		this.mass = mass;
		this.value = value;
		this.desc = desc;
		this.defend = newDefend;
		this.specials = newSpecials;
	}
	
}