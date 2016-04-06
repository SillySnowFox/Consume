import flash.*;
import flash.utils.*;

class MyItem {
	//Ur-Item class. All other items will be based on this one.
	
	public var name:String;
	public var mass:Int;
	public var value:Int;
	public var desc:String;
	public var count:Int = 1;
	
	public function give():String {
		//Add this to the player's invintory
		
		var playerCharacter:Object = Lib.current.getChildByName("PlayerCharacter");
		
		var playerInv:Array<Dynamic> = playerCharacter.invObject;
		var itemIndex:Int = -1;
		var itemCount:Int = -1;
		
		
		for (i in 0...playerInv.length) {
			if (playerInv[i].name == this.name)
				itemIndex = i;
		}
		
		if (itemIndex == -1) {
			//player has no items with the same name as this
			playerInv.push(this);
			itemIndex = playerInv.length - 1;
		} else {
			//Player already has one of this
			playerInv[itemIndex].count += 1;
		}
		
		playerCharacter.invObject = playerInv;
		
		itemCount = playerInv[itemIndex].count;
		
		return "<p>You tuck the " + this.name.toLowerCase() + " away in your pocket.</p><br><p>You have " + itemCount + " of them.</p><br>";
	}
	
	public function toss(index:Int, returnCount:Bool = false):Dynamic {
		//index is the position in playerCharacter.inv where the item rests
		//put a conformation screen in before this function gets called
		
		var playerCharacter:Object = Lib.current.getChildByName("PlayerCharacter");
		
		var playerInv:Array<Dynamic> = playerCharacter.invObject;
		var removedItem:Array<Dynamic> = new Array();
		var itemCount:Int = -1;
		
		if (playerInv[index].count == 1) {
			//Keep the removed item for now for debugging uses
			removedItem = playerInv.splice(index, 1);
			itemCount = 0;
		} else {
			playerInv[index].count -= 1;
			removedItem = playerInv[index];
			itemCount = playerInv[index].count;
		}
		
		playerCharacter.invObject = playerInv;
		
		if (returnCount) {
			return itemCount;
		} else {
			return "<p>You drop the " + this.name.toLowerCase() + ".</p><br><p>You have " + itemCount + " remaining.</p><br>";
		}
	}
	
	public function eat(index:Int):String {
		var playerCharacter:Object = Lib.current.getChildByName("PlayerCharacter");
		
		var itemCount:Int = -1;
		
		playerCharacter.stomachCurrent += this.mass;
		
		itemCount = this.toss(index, true);
		
		return "<p>You pop the " + this.name.toLowerCase() + " into your mouth and swallow it down.</p><br><p>You have " + itemCount + " remaining.</p><br>";
	}
	
	public function new() {
		
	}
	
}