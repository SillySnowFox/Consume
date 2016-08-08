import flash.*;
import flash.display.*;
import flash.text.*;
import flash.events.*;
import flash.ui.*;
import flash.utils.*;

class MyButton extends Sprite {
	public var btnName:String;
	public var toolTip:String;
	public var hasToolTip:Bool = false;
	public var btnX:Int;
	public var btnY:Int;
	public var btnID:Dynamic;
	public var open:Bool = false;

	private var inRect:Sprite = new Sprite();
	private var btnLabel:TextField = new TextField();
	private var curClickFunc:Function = null;	
	
	public function new(x:Int, y:Int, ?size:String) {
		super();
		flash.Lib.current.addChild(this);
		
		btnX = x;
		btnY = y;

		var outRect:Sprite = new Sprite();
		outRect.graphics.beginFill( 0x000000 , 1 );
		outRect.graphics.drawRoundRect( 0 , 0 , 90 , 30 , 5 , 5 );
		outRect.x = x;
		outRect.y = y;

		inRect.graphics.beginFill( 0xffffff , 1 );
		inRect.graphics.drawRoundRect ( 1 , 1 , 88 , 28 , 5 , 5 );
		inRect.x = x;
		inRect.y = y;

		btnLabel.x = x;
		btnLabel.y = y + 3;

		addChild( outRect );
		addChild( inRect );
		addChild( btnLabel );
		
		outRect.addEventListener(MouseEvent.ROLL_OVER, onMouseEnter);
		outRect.addEventListener(MouseEvent.ROLL_OUT, onMouseOut);
		outRect.addEventListener(MouseEvent.CLICK, removeToolTip);
		inRect.addEventListener(MouseEvent.ROLL_OVER, onMouseEnter);
		inRect.addEventListener(MouseEvent.ROLL_OUT, onMouseOut);
		inRect.addEventListener(MouseEvent.CLICK, removeToolTip);
		btnLabel.addEventListener(MouseEvent.ROLL_OVER, onMouseEnter);
		btnLabel.addEventListener(MouseEvent.ROLL_OUT, onMouseOut);
		btnLabel.addEventListener(MouseEvent.CLICK, removeToolTip);
		
		this.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		this.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
	}

	private function changeName(newName:String) {
		var labelFormat:TextFormat = new TextFormat();
		var globals:Object = Lib.current.getChildByName("GlobalVars");
		var color:String = "#000000";
		labelFormat.align = CENTER;
		labelFormat.size = globals.textSize + 2;
		
		if (newName == "Hunt") {
			newName = "<b>" + newName + "</b>";
		}
		
		if (!this.open) 
			color = "#D8D8D8";
		
		btnLabel.htmlText = "<body><font color = '" + color + "'>" + newName + "</font></body>";
		btnLabel.setTextFormat(labelFormat);
		btnLabel.width = 86;
		btnLabel.height = 26;
		btnLabel.selectable = false;
		
		while (btnLabel.textWidth > 84) {
			labelFormat.size -= 2;
			btnLabel.setTextFormat(labelFormat);
		}
		
		while (btnLabel.textHeight > 26) {
			labelFormat.size -= 2;
			btnLabel.setTextFormat(labelFormat);
		}

		this.btnName = newName;
		if (newName == " " || newName == "" || newName == null) {
			this.hasToolTip = false;
			this.open = false;
			this.toolTip = null;
		}
	}
	
	public function disableButton() {
		this.open = false;
		changeName(this.btnName);
	}
	
	public function setButton(setName:String, ?setTip:String, setID:Dynamic = null) {
		if (setTip != null && setTip != " ") {
			this.hasToolTip = true;
			this.toolTip = setTip;
		} else {
			this.hasToolTip = false;
		}
		
		if (setName.length > 1) {
			this.open = true;
		}
		
		changeName(setName);
		this.btnID = setID;
	}
	
	public function setClickFunc(newFunc:Function):Void {
		if (curClickFunc != null) {
			removeEventListener(MouseEvent.CLICK, curClickFunc);
		}
		
		if (newFunc != null) {
			addEventListener(MouseEvent.CLICK, newFunc);
		}
		
		curClickFunc = newFunc;
	}
	
	public function clearClickFunc():Void {
		setClickFunc(null);
	}
	
	
	private function removeToolTip ( ?e:MouseEvent ) {
		var toolTip:Object = this.getChildByName("Tool Tip");
		if (hasToolTip && toolTip != null) {
			this.removeChild(toolTip);
		}
	}
	
	private function addToolTip ( ?e:MouseEvent ) {
		var myTip:ToolTip = new ToolTip();
			
		myTip.changeTip(this.toolTip);
		if ((btnX - 10) <= 0) {
			myTip.x = 0;
		} else {
			myTip.x = btnX - 30;
		}
		
		myTip.y = btnY - (6 + myTip.txtHeight);
		myTip.name = "Tool Tip";
		this.addChild(myTip);
	}
	
	private function onMouseEnter( e:MouseEvent ) {
		flash.ui.Mouse.cursor = "button";
		if (this.hasToolTip)
			addToolTip();
	}

	private function onMouseOut( e:MouseEvent ) {
		flash.ui.Mouse.cursor = "auto";
		if (this.hasToolTip) 
			this.removeToolTip();
	}
	
	private function onMouseDown( e:MouseEvent ) {
		if (this.open) {
			this.inRect.visible = false;
			
			this.btnLabel.textColor = 0xFFFFFF;
		}
	}
	
	private function onMouseUp( e:MouseEvent ) {
		if (this.open) {
			this.inRect.visible = true;
			
			this.btnLabel.textColor = 0x000000;
		}
	}
}

class ToolTip extends Sprite {
	public var txtHeight:Float;
	
	public function new() {
		super();
		
		var txtTip:TextField = new TextField();
		txtTip.x = 0;
		txtTip.y = 0;
		txtTip.wordWrap = true;
		txtTip.autoSize = RIGHT;
		txtTip.border = true;
		txtTip.background = true;
		txtTip.width = 160;
		this.addChild(txtTip);
	}
	
	public function changeTip(tipText:String) {
		var txtTip:Object = this.getChildAt(0);
		var myWidth:Float = 0;
		
		txtTip.htmlText = tipText;
		txtHeight = txtTip.textHeight;
		if (txtTip.textWidth < 159 )
			txtTip.width = txtTip.textWidth + 5;
	}
	
}