package flixel.addons.ui;
import flash.geom.Rectangle;
import flixel.addons.ui.FlxUISprite;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.util.FlxColorUtil;
import flixel.util.FlxStringUtil;
import flixel.util.loaders.CachedGraphics;

/**
 * ...
 * @author 
 */
class FlxUIColorSwatch extends FlxUIButton
{
	public var multiColored(default, set):Bool;
	public var hilight(default, set):Int;
	public var midtone(default, set):Int;
	public var shadowMid(default, set):Int;
	public var shadowDark(default, set):Int;
	public var colors(get, set):SwatchData;
	
	public var callback:Void->Void;
	
	public static inline var CLICK_EVENT:String = "click_color_swatch";
	
	/**SETTERS**/
	
	public override function set_color(Color:Int):Int
	{
		midtone = Color; 				//color does double duty for midtone
		return super.set_color(color);
	}
	
	public function set_colors(Colors:SwatchData):SwatchData
	{
		_skipRefresh = true;
		hilight = Colors.hilight;
		midtone = Colors.midtone;
		shadowMid = Colors.shadowMid;
		shadowDark = Colors.shadowDark;
		_skipRefresh = false;
		refreshColor();
		return Colors;
	}
	
	public function get_colors():SwatchData
	{
		return new SwatchData(id, hilight, midtone, shadowMid, shadowDark);
	}
	
	/**
	 * If true, the swatch will draw itself dynamically based on the four colors provided
	 * @param	b
	 * @return
	 */
	public function set_multiColored(b:Bool):Bool {
		multiColored = b;
		refreshColor();
		return multiColored;
	}
	
	public function set_hilight(i:Int):Int {
		hilight = i;
		refreshColor();
		return hilight;
	}
	public function set_midtone(i:Int):Int {
		midtone = i;
		refreshColor();
		return midtone;
	}
	
	public function set_shadowMid(i:Int):Int {
		shadowMid = i;
		refreshColor();
		return shadowMid;
	}
	
	public function set_shadowDark(i:Int):Int {
		shadowDark = i;
		refreshColor();
		return shadowDark;
	}
	
	/**
	 * Creates a new color swatch that can store and display a color value
	 * @param	X
	 * @param	Y
	 * @param	?Color			Single color for the swatch
	 * @param	?Colors			Multiple colors for the swatch
	 * @param	?Asset			An asset for the swatch graphic (optional)
	 * @param	?Callback		Function to call when clicked
	 */
	
	public function new(X:Float, Y:Float, ?Color:Int = 0xFFFFFF, ?Colors:SwatchData, ?Asset:Dynamic, ?Callback:Void->Void) 
	{
		super(X, Y, onClick);
		
		callback = Callback;
		
		_skipRefresh = true;
		
		if(Asset != null){
			loadGraphic(Asset);					//load custom asset if provided
		}else {
			loadGraphic(FlxUIAssets.IMG_SWATCH);//load default monochrome swatch
		}
		
		_origKey = cachedGraphics.key;
		
		if (Color != 0xFFFFFF) {
			multiColored = false;
			color = Color;
		}
		
		if (Colors != null) {
			multiColored = true;
			colors = Colors;
		}
		
		_skipRefresh = false;
		refreshColor();
	}
	
	
	public function refreshColor():Void {
		if (_skipRefresh) 
		{ 
			return;
		}
		
		var key:String = colorKey();
		
		if (multiColored) 
		{
			if(cachedGraphics.key != key){
				if (FlxG.bitmap.checkCache(key) == false) 			//draw the swatch dynamically from supplied color values
				{
					makeGraphic(Std.int(width), Std.int(height), 0xFFFFFFFF, true, key);
					_flashRect.x = 0; _flashRect.y = 0;
					_flashRect.width = pixels.width;
					_flashRect.height = pixels.height;
					pixels.fillRect(_flashRect, 0xFF000000);		//outline
					_flashRect.x = 1; _flashRect.y = 1;
					_flashRect.width -= 2;
					_flashRect.height -= 2;
					pixels.fillRect(_flashRect, shadowDark);		//dark shadow
					_flashRect.x = 2; _flashRect.y = 1;
					_flashRect.width -= 1;
					_flashRect.height -= 1;
					pixels.fillRect(_flashRect, shadowMid);		//mid shadow
					_flashRect.x = 4; _flashRect.y = 2;
					_flashRect.width -= 3;
					_flashRect.height -= 3;
					pixels.fillRect(_flashRect, midtone);		//midtone
					_flashRect.x = pixels.width - 7; 
					_flashRect.y = 3;
					_flashRect.width = 4;
					_flashRect.height = 4;
					pixels.fillRect(_flashRect, hilight);		//hilight
					calcFrame();
				}else{
					loadGraphic(key);
				}
			}
		}
		else 
		{
			if (cachedGraphics.key != key) 							//load the right asset
			{
				loadGraphic(key);
			}
			color = midtone;										//just rely on color-tinting
		}
	}
	
	private var _origKey:String = "";
	private var _skipRefresh:Bool = false;
	
	private function onClick():Void {
		if (callback != null) {
			callback();
		}
		if (broadcastToFlxUI)
		{
			if(multiColored){
				FlxUI.event(CLICK_EVENT, this, colors);
			}else {
				FlxUI.event(CLICK_EVENT, this, color);
			}
		}
	}
	
	private function colorKey():String {
		if (multiColored) {
			return _origKey + "+" + FlxColorUtil.ARGBtoWebString(hilight) +
							  "+" + FlxColorUtil.ARGBtoWebString(midtone) +
							  "+" + FlxColorUtil.ARGBtoWebString(shadowMid) +
							  "+" + FlxColorUtil.ARGBtoWebString(shadowDark);
		}
		return _origKey;
	}
}