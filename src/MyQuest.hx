package;

class MyQuest {

	public var name:String; //Quest name
	public var dispName:String; //Quest name displayed in player's info
	public var stage:Int; //Quest stage
	public var keyID:Array<Int>; //ID of a key the player needs to be given/have
	public var stageDesc:Array<String> = new Array(); //Description of each quest stage, for multi-step quests
	public var questData:Int = 0; //Various quest-related data
	
	public var hidden:Bool; //If the quest should be hidden from the player or not
	
	
	public function newQuest(newQuest:Array<Dynamic>) {
		this.name = newQuest[0];
		this.dispName = newQuest[1];
		this.hidden = newQuest[2];
		this.stageDesc = newQuest[3];
		this.keyID = newQuest[4];
		
		this.stage = 0;
	}
	
	public function new() {
		
	}
}