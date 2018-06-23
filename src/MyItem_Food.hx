import flash.*;
import flash.utils.*;

class MyItem_Food extends MyItem {
	//Items which are for eating
	
	public var consumeDesc:String;
	
	/*Special array structure;
	 * specials[x][0] = ability name
	 * specials[x][1] = ability amount
	 */
	
	override public function eat(playerCharacter:MyPlayerObject):String {
		//Check for other options, heal to do such to the player
		//butt to increase the size of the player's ass
		
		var healPerc:Float = 0;
		var foodEffect:String = "";
		var buttExpand:Int = 0;
		var message:String = "";
		
		for (i in 0...this.specials.length - 1) {
			foodEffect = this.specials[i].split("|")[0];
			
			switch foodEffect {
			case "heal":
				healPerc = Std.parseFloat(this.specials[i].split("|")[1]);
			case "butt":
				buttExpand = Std.parseInt(this.specials[i].split("|")[1]);
			}
		}
		
		playerCharacter.stomachCurrent += this.mass;
		
		playerCharacter.healPlayer(healPerc);
		playerCharacter.buttSize += buttExpand;
		
		if (this.count > 1) {
			this.count--;
		} else {
			this.toss(playerCharacter);
		}
		
		return this.consumeDesc;
	}
	
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
		
		this.toss(playerCharacter);
		
		return message;
	}
	
	public function copyItem():MyItem_Food {
		var newItem:MyItem_Food = new MyItem_Food();
		
		newItem.type = "food";
		newItem.name = this.name;
		newItem.mass = this.mass;
		newItem.value = this.value;
		newItem.desc = this.desc;
		newItem.specials = this.specials;
		newItem.consumeDesc = this.consumeDesc;
		
		return newItem;
	}
	
	public function newFood(food:Array<Dynamic>) {
		this.type = "food";
		this.name = food[0];
		this.mass = food[1];
		this.value = food[2];
		this.desc = food[3];
		this.specials = food[4];
		this.consumeDesc = food[5];
	}
	
	public function new() {
		super();
	}
}