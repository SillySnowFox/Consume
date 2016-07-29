package;

class MySpecies {
	public var name:String; // Name of the species
	public var skin:String; // skin descriptor (skin, fur, feathers, scales, etc)
	public var tail:Bool; // Species has a tail?
	public var taliDesc:String; // tail descriptor
	public var mouth:String; // mouth descriptor (mouth, muzzle, beak, etc)
	public var legs:String; // leg descriptor
	public var arms:String; // arm descriptor
	public var hands:String; // hand descriptor
	public var feet:String; // foot descriptor
	public var sphincter:String; // asshole descriptor
	
	public var minHeight:Int; //Shortest possible (female)
	public var maxHeight:Int; //Tallest possible (male)
	
	public var minWeight:Int; //Lightest possible (female)
	public var maxWeight:Int; //Heaviest possible (male)
	
	public var minChest:Int; //smallest chest mesurement (female)
	public var maxChest:Int; //larget chest mesurement (males)
	
	public var minWaist:Int; //narrowest waist possible (female)
	public var maxWaist:Int; //thickest waist possible (male)
	
	public var minHips:Int; //slimmist hips possible (male)
	public var maxHips:Int; //widest hips possible (female)
	
	public var minButt:Int; //smallest butt possible (male)
	public var maxButt:Int; //largest butt possible (female)
	
	public var breasts:Int; //starting breast size
	public var penisL:Float; //starting penis length
	public var penisW:Float; //starting penis width
	public var balls:Float; //starting ball size
	public var errect:Float; //starting errection multiplier
	
	public var stomach:Int; //starting stomach capacity
	public var bowels:Int; //starting bowels capacity
	public var milk:Float; //starting milk/breast capacity
	public var cum:Float; //starting cum/balls capacity
	
	public var fatGain:Int; //starting fat gain rate
	public var milkGain:Float; //starting milk gain rate
	public var cumGain:Float; //starting cum gain rate
	public var digestDamage:Float; //How much damage per tick (minute) the player's stomach does to consumed objects
	
	public var stretchRateStomach:Int; //How many ticks (minutes) the player's stomach needs to be over capacity to stretch larger
	public var stretchRateBowels:Int; //Ticks to stretch bowels
	public var stretchRateMilk:Int; //Ticks to stretch milk
	public var stretchRateCum:Int; //Ticks to stretch cum
	
	public var stretchAmountStomach:Int; //how much the player's stomach stretches
	public var stretchAmountBowels:Int;
	public var stretchAmountMilk:Float;
	public var stretchAmountCum:Float;
	
	public function new() {
		
	}
	
	public function newSpecies(data:Array<Dynamic>) {
		name = data[0];
		skin = data[1];
		tail = data[2];
		taliDesc = data[3];
		mouth = data[4];
		legs = data[5];
		arms = data[6];
		hands = data[7];
		feet = data[8];
		sphincter = data[42];
		
		minHeight = data[9];
		maxHeight = data[10];
		
		minWeight = data[11];
		maxWeight = data[12];
		
		minChest = data[13];
		maxChest = data[14];
		
		minWaist = data[15];
		maxWaist = data[16];
		
		minHips = data[17];
		maxHips = data[18];
		
		minButt = data[19];
		maxButt = data[20];
		
		breasts = data[21];
		penisL = data[22];
		penisW = data[23];
		balls = data[24];
		errect = data[25];
		
		stomach = data[26];
		bowels = data[27];
		milk = data[28];
		cum = data[29];
	
		fatGain = data[30];
		milkGain = data[31];
		cumGain = data[32];
		digestDamage = data[33];
	
		stretchRateStomach = data[34];
		stretchRateBowels = data[35];
		stretchRateMilk = data[36];
		stretchRateCum = data[37];
	
		stretchAmountStomach = data[38];
		stretchAmountBowels = data[39];
		stretchAmountMilk = data[40];
		stretchAmountCum = data[41];
	}
	
}