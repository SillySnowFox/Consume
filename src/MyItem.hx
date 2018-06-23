import flash.*;
import flash.utils.*;
import haxe.macro.Type.ClassField;

class MyItem {
	//Ur-Item class. All other items will be based on this one.
	
	public var name:String;
	public var mass:Int;
	public var value:Int;
	public var desc:String;
	public var count:Int = 1;
	public var specials:Array<String> = new Array();
	public var rarity:String;
	public var type:String;
	
	public function give(playerCharacter:MyPlayerObject):String {
		//Add this to the player's invintory
		var playerInv:Array<Dynamic> = playerCharacter.invObject;
		var itemIndex:Int = -1;
		var itemCount:Int = -1;
		
		if (this.type != "armor" && this.type != "weapon" && this.type != "ring") {
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
		} else {
			playerInv.push(this);
			itemIndex = playerInv.length - 1;
		}
		
		playerCharacter.invObject = playerInv;
		
		itemCount = playerInv[itemIndex].count;
		
		return "<p>You tuck the " + this.name.toLowerCase() + " away in your pocket.</p><br><p>You have " + itemCount + " of them.</p><br>";
	}
	
	public function toss(playerCharacter:MyPlayerObject):String {
		playerCharacter.invObject.remove(this);
		
		return "<p>You drop the " + this.name.toLowerCase() + ".</p><br>";
	}
	
	public function eat(playerCharacter:MyPlayerObject):String {
		playerCharacter.stomachCurrent += this.mass;
		
		if (this.count > 1) {
			this.count -= 1;
		} else {
			this.toss(playerCharacter);
		}
		
		return "<p>You pop the " + this.name.toLowerCase() + " into your mouth and swallow it down.</p><br>";
	}
	
	public function new() {
		
	}
	
}