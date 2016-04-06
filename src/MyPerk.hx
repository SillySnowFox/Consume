import flash.*;
import flash.utils.*;

class MyPerk {
	
	public var name:String; //Perk name, this is the name the code uses
	public var dispName:String; //Display name, this is the name the game displays to the player
	public var desc:String; //Perk discription
	public var effect:String; //Perk effect
	public var showPerk:Bool; //If the perk is displayed on the player info screen
	
	public function newPerk(perk:Array<Dynamic>) {
		name = perk[0];
		dispName = perk[1];
		desc = perk[2];
		effect = perk[3];
		showPerk = perk[4];
	}
	
	public function new() {
		
	}
}