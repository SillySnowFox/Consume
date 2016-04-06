import flash.utils.Object;
import flash.Lib;

class MyRoom {

	public var name:String; //Room name
	public var desc:String; //Room description, displayed under the title
	public var exitNW:MyExit; //NorthWest exit (button 0)
	public var exitN:MyExit; //North exit (button 1)
	public var exitNE:MyExit; //NorthEast exit (button 2)
	public var exitW:MyExit; //West Exit (button 3)
	public var exitE:MyExit; //East exit (button 5)
	public var exitSW:MyExit; //SouthWest exit (button 6)
	public var exitS:MyExit; //South exit (button 7)
	public var exitSE:MyExit; //SouthEast exit (button 8)
	public var allowWait:Bool; //Can the player wait in this room (button 4)
	
	public var isPublic:Bool; //Is the room public or private?
	
	public var roomNPC:Int; //List of NPCs in the room. Interaction is controlled through the three 'special' buttons below
	
	/* Special button flags, each button can have one of the following flags on it
	 * 0 - Nothing
	 * 1 - Hunt, passive/active (Allows the player to hunt for prey. passive/active = club/park probably)
	 * 2 - Shop, [shop invintory]
	 * 3 - Talk, NPC (Chat with an NPC, should be an ID from roomNPCs. Eating NPCs will be handled here now)
	 * 4 - Work, Time (Player works for time)
	 * 5 - Toilet
	 * 6 - Sleep
	 * 
	 */
	
	public var specialButtons:Array<Dynamic>;
	
	public function new(newRoom:Array<Dynamic>) {
		var globals:Object = Lib.current.getChildByName("GlobalVars");
		var exits:Array<Dynamic> = globals.exits;
		
		this.name = newRoom[0];
		if (newRoom[1] != null)
			this.exitNW = new MyExit(exits[newRoom[1]]); // newRoom[1];
		if (newRoom[2] != null)
			this.exitN = new MyExit(exits[newRoom[2]]); // newRoom[2];
		if (newRoom[3] != null)
			this.exitNE = new MyExit(exits[newRoom[3]]); // newRoom[3];
		if (newRoom[4] != null)
			this.exitW = new MyExit(exits[newRoom[4]]); // newRoom[4];
		if (newRoom[5] != null)
			this.exitE = new MyExit(exits[newRoom[5]]); // newRoom[5];
		if (newRoom[6] != null)
			this.exitSW = new MyExit(exits[newRoom[6]]); // newRoom[6];
		if (newRoom[7] != null)
			this.exitS = new MyExit(exits[newRoom[7]]); // newRoom[7];
		if (newRoom[8] != null)
			this.exitSE = new MyExit(exits[newRoom[8]]); // newRoom[8];
		this.specialButtons = newRoom[9];
		this.allowWait = newRoom[10];
		this.isPublic = newRoom[11];
		if (newRoom[12] != null) {
			this.roomNPC = newRoom[12];
		} else {
			this.roomNPC = -1;
		}
		this.desc = newRoom[13];
	}
	
}