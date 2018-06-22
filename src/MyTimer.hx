package;

import flash.*;
import flash.display.Sprite;
import flash.events.TimerEvent;
import flash.text.TextField;
import flash.utils.Timer;

class MyTimer extends Sprite {
	public var tmrName:String;
	public var tmrQuick:Timer;
	public var tmrTime:Int;
	public var tmrKey:String;
	public var txtQuick:TextField = new TextField();
	public var txtQuickDsp:TextField = new TextField();
	public var successScene:Int;
	public var failScene:Int;
	
	private var timeCount:Int;
	
	private function onTick(e:TimerEvent) {
		timeCount -= 1;
		txtQuickDsp.htmlText = "<body><font size = '32'><p align = 'center'>" + timeCount + "</p></font></body>";
	}
	
	public function new(timeToEnd:Int, keyWait:String, success:Int, fail:Int) {
		super();
		
		txtQuick.name = "QTE";
		txtQuick.x = 10;
		txtQuick.y = 490;
		txtQuick.width = 500;
		txtQuick.height = 145;
		txtQuick.background = true;
		txtQuick.border = true;
		txtQuick.multiline = true;
		txtQuick.htmlText = "<body><font size = '26'><br><p align = 'center'>Press '" + keyWait.toUpperCase() + "'!</p></font></body>";
		
		txtQuickDsp.name = "QuickBar";
		txtQuickDsp.x = 100;
		txtQuickDsp.y = 550;
		txtQuickDsp.width = 300;
		txtQuickDsp.height = 40;
		txtQuickDsp.visible = true;
		txtQuickDsp.border = false;
		txtQuickDsp.htmlText = "<body><font size = '32'><p align = 'center'>" + timeToEnd + "</p></font></body>";
		
		successScene = success;
		failScene = fail;
		
		this.addChild(txtQuick);
		this.addChild(txtQuickDsp);
		
		timeCount = timeToEnd;
		tmrTime = timeToEnd;
		tmrKey = keyWait.toLowerCase();
		
		tmrQuick = new Timer(1000, tmrTime);
		tmrQuick.addEventListener(TimerEvent.TIMER, onTick);
		
		tmrQuick.start();
	}
}