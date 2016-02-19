import flash.*;
import flash.display.*;
import flash.text.*;
import flash.events.*;
import flash.ui.*;
import flash.utils.*;

/* Important!
 * This displays a box in the middle of the playfield with 'message' and a button that says 'OK'
 * The button will clear one box, And only one. I have no idea why. These are mostly only used
 * for problems, it's not a good idea to use them for long messages either as the box doesn't
 * resize 
 */

class AlertBox extends Sprite {
	public function new(message:String, button:Bool = true) {
		super();
		
		var txtMessage:TextField = new TextField();
		txtMessage.name = "Message Field";
		txtMessage.x = 150;
		txtMessage.y = 150;
		txtMessage.width = 400;
		txtMessage.height = 100;
		txtMessage.border = true;
		txtMessage.borderColor = 0x000000;
		txtMessage.background = true;
		txtMessage.backgroundColor = 0xFFFFFF;
		txtMessage.multiline = true;
		txtMessage.htmlText = "<body><font size = '22'>" + message + "</font></body>";
		txtMessage.wordWrap = true;
		
		if (button) {
			var btn:MyButton = new MyButton(450, 235);
			btn.setButton("OK");
			Lib.current.addChild(btn);
			btn.addEventListener(MouseEvent.CLICK, closeBox);
		}
		
		Lib.current.addChild(txtMessage);
	}
	
	public function remove() {
		var box:Object = Lib.current.getChildByName("Message Field");
		
		Lib.current.removeChild(box);
	}
	
	private function closeBox( e:MouseEvent ) {
		var btn:Object = e.currentTarget;
		var box:Object = Lib.current.getChildByName("Message Field");
		
		Lib.current.removeChild(btn);
		Lib.current.removeChild(box);
	}
}