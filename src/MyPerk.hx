import flash.*;
import flash.utils.*;

class MyPerk {
	
	public var name:String; //Perk name, this is the name the code uses
	public var dispName:String; //Display name, this is the name the game displays to the player
	public var desc:String; //Perk discription
	public var effect:String; //Perk effect
	public var showPerk:Bool; //If the perk is displayed on the player info screen
	public var count:Int;
	public var multipleLevels:Bool; //if the perk has multiple levels that can be bought
	
	public function newPerk(perk:Array<Dynamic>) {
		name = perk[0];
		dispName = perk[1];
		desc = perk[2];
		effect = perk[3];
		showPerk = perk[4];
		multipleLevels = perk[5];
	}
	
	public function new() {
		
	}
}