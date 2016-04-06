import flash.Lib;
import flash.utils.Object;

class MyItem_Key extends MyItem {

	public var keyID:Int;
	
	private var globals:Object = Lib.current.getChildByName("GlobalVars");
	
	public function newKey(keyArray:Array<Dynamic>) {
		this.name = keyArray[0];
		this.keyID = keyArray[1];
		this.desc = keyArray[2];
		this.value = 0;
		this.mass = 1;
		this.count = 1;
	}
	
	public function giveKey():String {
		//Add this key to the player's invintory
		
		var playerCharacter:MyPlayerObject = globals.playerCharacter;
		
		var playerKeys:Array<MyItem_Key> = playerCharacter.keyRing;
		
		
		if (playerCharacter.hasKey(this.keyID) != -1) {
			return "##FAIL";
		}
		
		playerKeys.push(this);
		
		playerCharacter.keyRing = playerKeys;
		
		return "<p>You add the " + this.name.toLowerCase() + " to your keyring and return it to your pocket.</p><br>";
	}
	
	public function new() {
		super();
	}
	
}