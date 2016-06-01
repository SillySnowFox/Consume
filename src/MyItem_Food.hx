import flash.*;
import flash.utils.*;

class MyItem_Food extends MyItem {
	//Items which are for eating
		
	public var specials:Array<Dynamic> = new Array();
	
	/*Special array structure;
	 * specials[x][0] = ability name
	 * specials[x][1] = ability amount
	 */
	
	public function use():String {
		var playerCharacter:Object = Lib.current.getChildByName("PlayerCharacter");
		
		var abilityArray:Array<Dynamic> = this.specials;
		var plrInv:Array<MyItem> = playerCharacter.invObject;
		var message:String = "";
		var itemIndex:Int = -1;
		
		for (i in 0...abilityArray.length) {
			switch abilityArray[i][0] {
			case "heal":
				playerCharacter.healthCurr += abilityArray[i][1];
				
				if (playerCharacter.healthCurr > playerCharacter.healthMax) {
					playerCharacter.healthCurr = playerCharacter.healthMax;
				} else {
					playerCharacter.healthCurr = Math.round(playerCharacter.healthCurr);
				}
				
				message = "<p>You drink down the potion and feel much better after.</p><br>";
			case "digrate":
				//playerCharacter.
			}
		}
		
		for (i in 0...plrInv.length) {
			if (plrInv[i].name == this.name)
				itemIndex = i;
		}
		
		this.toss(itemIndex);
		
		return message;
	}
	
	public function new_food(name:String, mass:Int, value:Int, desc:String, ?newSpecials:Array<Dynamic>) {
		this.name = name;
		this.mass = mass;
		this.value = value;
		this.desc = desc;
		this.specials = newSpecials;
	}
	
	public function new() {
		super();
	}
}