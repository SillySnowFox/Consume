import flash.*;
import flash.utils.*;

class MyItem_Weapon extends MyItem {
	
	public var attack:Int;
	public var twoHanded:Bool;
	public var specials:Array<Dynamic> = new Array();
	
	/*Special array structure;
	 * specials[x][0] = ability name
	 * specials[x][1] = ability description
	 * specials[x][2] = ability target (player/foe)
	 * specials[x][3] = ability effect (damage/healing/weight/etc)
	 * specials[x][4] = ability amount
	 */ 
	
	public function equip():String {
		var playerCharacter:Object = Lib.current.getChildByName("PlayerCharacter");
		
		var plrInv:Array<MyItem> = playerCharacter.invObject;
		var wepToEquip:Array<MyItem> = new Array();
		var wepUnequip:MyItem = new MyItem();
		var itemIndex:Int = -1;
		var ignore:String = "";
		var message:String = "";
		
		for (i in 0...plrInv.length) {
			if (plrInv[i].name == this.name)
				itemIndex = i;
		}
		
		if (plrInv[itemIndex].count > 1) {
			plrInv[itemIndex].count - 1;
		} else {
			wepToEquip = plrInv.splice(itemIndex, 1);
		}
		
		if (playerCharacter.equipWepObj != null) {
			wepUnequip = playerCharacter.equipWepObj;
			wepUnequip.count = 1; // Just to be sure
			playerCharacter.equipWepObj = wepToEquip;
			
			ignore = wepUnequip.give();
			
			message = "<p>You return your " + wepUnequip.name.toLowerCase() + " to your pack and ready your " + this.name.toLowerCase() + " in your hand";
			
			if (this.twoHanded)
				message += "s";
			
			message += ".</p><br>";
		} else {
			playerCharacter.equipWepObj = wepToEquip;
			
			message = "<p>You  ready your " + this.name.toLowerCase() + " in your hand";
			
			if (this.twoHanded)
				message += "s";
			
			message += ".</p><br>";
		}
		
		playerCharacter.invObject = plrInv;
		
		return message;
	}
	 
	public function new(name:String, mass:Int, value:Int, desc:String, newAttack:Int, newTwoHanded:Bool, newSpecials:Array<Dynamic>) {
		super();
		
		this.name = name;
		this.mass = mass;
		this.value = value;
		this.desc = desc;
		this.attack = newAttack;
		this.twoHanded = newTwoHanded;
		this.specials = newSpecials;
	}
	
}