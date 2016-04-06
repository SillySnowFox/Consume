import flash.Lib;
import flash.utils.Object;


class MyExit {

	public var name:String; //Exit name, displayed on the button
	public var desc:String; //Exit description, displayed in the button's tooltip
	public var hidden:Bool; //Exit is hidden until the player clicks on it
	public var timeOpen:Int; //player.hour time the exit opens
	public var timeClose:Int; //player.hour time the exit closes
	public var travelTo:Int; //Location the button links to
	public var travelTime:Int; //How long it take the player to travel to the next room
	public var doorWidth:Int; //How wide is the door, possible use when players get really massive?
	public var doorHeight:Int; //How tall is the door
	public var exitClosed:Bool; //Is the exit connect to another room?
	public var hiddenQuestID:Int;
	public var keyID:Int = -1; //Is the door locked?
	
	
	public function new(newExit:Array<Dynamic>) {
		var globals:Object = Lib.current.getChildByName("GlobalVars");
		var rooms:Array<Dynamic> = globals.rooms;
		
		this.name = newExit[0];
		this.hidden = newExit[1];
		this.timeOpen = newExit[2];
		this.timeClose = newExit[3];
		if (newExit[4] != null) {
			if (rooms[newExit[4]] == null) {
				exitClosed = true;
			} else {
				this.travelTo = newExit[4];
				exitClosed = false;
			}
		}
		this.travelTime = newExit[5];
		this.doorWidth = newExit[6];
		this.doorHeight = newExit[7];
		this.desc = newExit[8];
		this.hiddenQuestID = newExit[9];
		if (newExit[10] != null)
			this.keyID = newExit[10];
	}
	
}