package
{
	import com.oddcast.vhost.accessories.AccessoryData;
	import com.oddcast.workshop.Accessory_XML_Parser;
	import com.voki.Controller;
	
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	
	public class Voki extends Sprite
	{
		
		private var _controller:Controller;
		
		
		public function Voki()
		{
			super();
			
			// support autoOrients
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			var holder:MovieClip = new MovieClip();
			stage.addChild(holder);
			
			_controller = new Controller(holder);
			_controller.init('assets/vhss_v5_config.xml');
			
			
//			_engine = new EngineV5();
//			addChild(_engine);
			
			colorButtons = []; 
			assetButtons = [];
			
			colors = [0xFFDCB1, 0xE5C298, 0xE4B98E, 0xD99164, 0x440000];
			
			for each(var color:uint in colors){
				_makeColorButton(color);
			}
			
			assets = ['mouth', 'skin', 'eyes', 'hair'];
			
			for(var i:Number = 0; i < assets.length; i++){
				_makeAssetButton(assets[i]);
			}
			
			_currentAsset = "mouth";
			_currentColor = 0xFFDCB1;
			
			(assetButtons[0] as Sprite).alpha = 1;
			(colorButtons[0] as Sprite).alpha = 1;
			
			var request:URLRequest = new URLRequest('http://content.oddcast.com/ccs2/mam/88/e4/accessory_thumnail_57191.jpg');
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, function(e:Event):void{});
			loader.load(request);
			addChild(loader);
			loader.x = stage.stageWidth-50;
			loader.addEventListener(MouseEvent.CLICK, _onAccChangeClick);
			
			
		}
		
		private var colors:Array;
		private var assets:Array;
		private var colorButtons:Array;
		private var assetButtons:Array;
		private var _currentColor:uint;
		private var _currentAsset:String;
		
		private function _onAccChangeClick(e:MouseEvent):void
		{
//			<ITEM ID="57191" NAME="onLive_oc_kayla_biz_suit_blue_shirt" CATID="5" CATEGORY="" COMPAT="0" COMPATID="0" THUMB="/88/e4/accessory_thumnail_57191.jpg">
//				<FRAGMENT TYPE="Front" FILENAME="/24/70/f9_fragment_ac57191_fr4.swf"/>
//			</ITEM>
//			http://content.oddcast.com/ccs2/mam/24/70/f9_fragment_ac57191_fr4.swf
			
			
			var parser:Accessory_XML_Parser = new Accessory_XML_Parser();
			var accs:Array = parser.parse_xml(new XML('<ACCESSORIES COUNT="28" BASEURL="http://content.oddcast.com/ccs2/mam" TYPE="Costume"><ITEM ID="57191" NAME="onLive_oc_kayla_biz_suit_blue_shirt" CATID="5" CATEGORY="" COMPAT="0" COMPATID="0" THUMB="/88/e4/accessory_thumnail_57191.jpg"><FRAGMENT TYPE="Front" FILENAME="/24/70/f9_fragment_ac57191_fr4.swf"/></ITEM><ITEM ID="57192" NAME="onLive_oc_kayla_biz_suit_brown_shirt" CATID="5" CATEGORY="" COMPAT="0" COMPATID="0" THUMB="/58/2b/accessory_thumnail_57192.jpg"><FRAGMENT TYPE="Front" FILENAME="/e8/95/f9_fragment_ac57192_fr4.swf"/></ITEM><ITEM ID="57193" NAME="onLive_oc_kayla_biz_suit_green_shirt" CATID="5" CATEGORY="" COMPAT="0" COMPATID="0" THUMB="/4a/40/accessory_thumnail_57193.jpg"><FRAGMENT TYPE="Front" FILENAME="assets/f9_fragment_ac57193_fr4.swf"/></ITEM><ITEM ID="32532" NAME="oc_gena_costume_1" CATID="5" CATEGORY="" COMPAT="0" COMPATID="0" THUMB="/ae/5a/accessory_thumnail_32532.jpg"><FRAGMENT TYPE="Front" FILENAME="/b8/07/f9_fragment_ac32532_fr4.swf"/></ITEM><ITEM ID="32533" NAME="oc_gena_costume_2" CATID="5" CATEGORY="" COMPAT="0" COMPATID="0" THUMB="/cf/61/accessory_thumnail_32533.jpg"><FRAGMENT TYPE="Front" FILENAME="/e8/97/f9_fragment_ac32533_fr4.swf"/></ITEM><ITEM ID="7666" NAME="SPK_female_costumes8" CATID="5" CATEGORY="" COMPAT="0" COMPATID="0" THUMB="/6e/c9/accessory_thumnail_7666.jpg"><FRAGMENT TYPE="Front" FILENAME="/97/e9/f9_fragment_ac7666_fr4.swf"/></ITEM><ITEM ID="13190" NAME="blk_suit_blue_shirt" CATID="5" CATEGORY="" COMPAT="0" COMPATID="0" THUMB="/8b/a3/accessory_thumnail_13190.jpg"><FRAGMENT TYPE="Front" FILENAME="/d2/9e/f9_fragment_ac13190_fr4.swf"/></ITEM><ITEM ID="13194" NAME="blk_suit_dk_brown_suit" CATID="5" CATEGORY="" COMPAT="0" COMPATID="0" THUMB="/24/da/accessory_thumnail_13194.jpg"><FRAGMENT TYPE="Front" FILENAME="/52/12/f9_fragment_ac13194_fr4.swf"/></ITEM><ITEM ID="13191" NAME="blk_suit_pink_shirt" CATID="5" CATEGORY="" COMPAT="0" COMPATID="0" THUMB="/86/39/accessory_thumnail_13191.jpg"><FRAGMENT TYPE="Front" FILENAME="/d8/d7/f9_fragment_ac13191_fr4.swf"/></ITEM><ITEM ID="13192" NAME="blk_suit_purple_shirt" CATID="5" CATEGORY="" COMPAT="0" COMPATID="0" THUMB="/6e/bb/accessory_thumnail_13192.jpg"><FRAGMENT TYPE="Front" FILENAME="/35/c0/f9_fragment_ac13192_fr4.swf"/></ITEM><ITEM ID="13195" NAME="blk_suit_white_shirt" CATID="5" CATEGORY="" COMPAT="0" COMPATID="0" THUMB="/d8/33/accessory_thumnail_13195.jpg"><FRAGMENT TYPE="Front" FILENAME="/22/7c/f9_fragment_ac13195_fr4.swf"/></ITEM><ITEM ID="13193" NAME="blk_suit_wine_shirt" CATID="5" CATEGORY="" COMPAT="0" COMPATID="0" THUMB="/0e/2e/accessory_thumnail_13193.jpg"><FRAGMENT TYPE="Front" FILENAME="/08/2a/f9_fragment_ac13193_fr4.swf"/></ITEM><ITEM ID="6308" NAME="em_Condoleeza_Rice_costume" CATID="5" CATEGORY="" COMPAT="0" COMPATID="0" THUMB="/ba/c2/accessory_thumnail_6308.jpg"><FRAGMENT TYPE="Front" FILENAME="/b4/66/f9_fragment_ac6308_fr4.swf"/></ITEM><ITEM ID="25060" NAME="female_biz_suit_navy_blue_pinstripe" CATID="5" CATEGORY="" COMPAT="0" COMPATID="0" THUMB="/18/39/accessory_thumnail_25060.jpg"><FRAGMENT TYPE="Front" FILENAME="/c0/40/f9_fragment_ac25060_fr4.swf"/></ITEM><ITEM ID="4377" NAME="grandma_green_red_suit" CATID="5" CATEGORY="" COMPAT="0" COMPATID="0" THUMB="/c0/3f/accessory_thumnail_4377.jpg"><FRAGMENT TYPE="Front" FILENAME="/8d/cf/f9_fragment_ac4377_fr4.swf"/></ITEM><ITEM ID="448" NAME="grey_suit_020" CATID="5" CATEGORY="" COMPAT="1" COMPATID="13" THUMB="/0a/48/accessory_thumnail_448.jpg"><FRAGMENT TYPE="Front" FILENAME="/ea/a9/f9_fragment_ac448_fr4.swf"/></ITEM><ITEM ID="12661" NAME="navy_blue_suit" CATID="5" CATEGORY="" COMPAT="0" COMPATID="0" THUMB="/84/db/accessory_thumnail_12661.jpg"><FRAGMENT TYPE="Front" FILENAME="/cb/5b/f9_fragment_ac12661_fr4.swf"/></ITEM><ITEM ID="6307" NAME="oc_Hilary_Clinton_costumes" CATID="5" CATEGORY="" COMPAT="0" COMPATID="0" THUMB="/98/47/accessory_thumnail_6307.jpg"><FRAGMENT TYPE="Front" FILENAME="/05/83/f9_fragment_ac6307_fr4.swf"/></ITEM><ITEM ID="1281" NAME="olive_suit" CATID="5" CATEGORY="" COMPAT="0" COMPATID="0" THUMB="/ac/c6/accessory_thumnail_1281.jpg"><FRAGMENT TYPE="Front" FILENAME="/02/cc/f9_fragment_ac1281_fr4.swf"/></ITEM><ITEM ID="422" NAME="onLive_jacket_064" CATID="5" CATEGORY="" COMPAT="0" COMPATID="0" THUMB="/f4/d6/accessory_thumnail_422.jpg"><FRAGMENT TYPE="Front" FILENAME="/09/32/f9_fragment_ac422_fr4.swf"/></ITEM><ITEM ID="844" NAME="red_suit_118" CATID="5" CATEGORY="" COMPAT="1" COMPATID="13" THUMB="/b6/9a/accessory_thumnail_844.jpg"><FRAGMENT TYPE="Front" FILENAME="/5c/d5/f9_fragment_ac844_fr4.swf"/></ITEM><ITEM ID="6367" NAME="stephie_costume_1" CATID="5" CATEGORY="" COMPAT="0" COMPATID="0" THUMB="/dd/ad/accessory_thumnail_6367.jpg"><FRAGMENT TYPE="Front" FILENAME="/0a/e1/f9_fragment_ac6367_fr4.swf"/></ITEM><ITEM ID="6368" NAME="stephie_costume_2" CATID="5" CATEGORY="" COMPAT="0" COMPATID="0" THUMB="/02/48/accessory_thumnail_6368.jpg"><FRAGMENT TYPE="Front" FILENAME="/e0/a9/f9_fragment_ac6368_fr4.swf"/></ITEM><ITEM ID="6373" NAME="stephie_costume_7" CATID="5" CATEGORY="" COMPAT="0" COMPATID="0" THUMB="/50/2a/accessory_thumnail_6373.jpg"><FRAGMENT TYPE="Front" FILENAME="/8c/a5/f9_fragment_ac6373_fr4.swf"/></ITEM><ITEM ID="6374" NAME="stephie_costume_8" CATID="5" CATEGORY="" COMPAT="0" COMPATID="0" THUMB="/ce/79/accessory_thumnail_6374.jpg"><FRAGMENT TYPE="Front" FILENAME="/c4/05/f9_fragment_ac6374_fr4.swf"/></ITEM><ITEM ID="447" NAME="suit_014" CATID="5" CATEGORY="" COMPAT="0" COMPATID="0" THUMB="/61/03/accessory_thumnail_447.jpg"><FRAGMENT TYPE="Front" FILENAME="/25/a3/f9_fragment_ac447_fr4.swf"/></ITEM><ITEM ID="452" NAME="suit_044" CATID="5" CATEGORY="" COMPAT="0" COMPATID="0" THUMB="/23/86/accessory_thumnail_452.jpg"><FRAGMENT TYPE="Front" FILENAME="/a9/06/f9_fragment_ac452_fr4.swf"/></ITEM><ITEM ID="454" NAME="suit_117" CATID="5" CATEGORY="" COMPAT="0" COMPATID="0" THUMB="/4d/f2/accessory_thumnail_454.jpg"><FRAGMENT TYPE="Front" FILENAME="/a6/91/f9_fragment_ac454_fr4.swf"/></ITEM></ACCESSORIES>'));
//			var id		:Number = 57191;
//			var type	:Number = parseInt("Front");
//			var thumb	:String = "http://content.oddcast.com/ccs2/mam/88/e4/accessory_thumnail_57191.jpg";
//			var n		:String = "onLive_oc_kayla_biz_suit_blue_shirt";
//			var compatibility:Number = 0;
//			var type_name:String = "Costume";
//			
//			var accData:AccessoryData  = new AccessoryData(id, name, type, thumb, compatibility );
//			accData.type_name = type_name;
			
			var accData:AccessoryData = accs[2];
			
			//var accData:AccessoryData = new AccessoryData(0, 'onLive_oc_kayla_biz_suit_blue_shirt', 5, 'http://content.oddcast.com/ccs2/mam/88/e4/accessory_thumnail_57191.jpg', 0);
			_controller.loadAccessory(accData);
		}
		private function _makeColorButton(hex:uint):void
		{
			var btn:Sprite = new Sprite();
			
			btn.graphics.beginFill(hex, 1);
			btn.graphics.drawRect(0, 0, 50, 50);
			btn.graphics.endFill();
					
			btn.x = 10;
			btn.y = colorButtons.length*60;
			btn.alpha = .25;
			btn.buttonMode = true;
			btn.addEventListener(MouseEvent.CLICK, _onColorChange);
			addChild(btn);
			colorButtons.push(btn);
		}
		
		private function _makeAssetButton(asset:String):void
		{
			
			var btn:Sprite = new Sprite();
			
			var tf:TextField = new TextField();
			tf.text = asset;
			tf.width = tf.textWidth + 5;
			tf.height = tf.textHeight + 5;
			tf.mouseEnabled = false;
			btn.addChild(tf);
			
			btn.y = assetButtons.length*50;
			btn.x = 75;
			btn.alpha = .25;
			btn.buttonMode = true;
			btn.addEventListener(MouseEvent.CLICK, _onAssetChange);
			addChild(btn);
			assetButtons.push(btn);
		}
		
		
		private function _onColorChange(e:MouseEvent):void
		{
			for(var i:Number = 0; i<colorButtons.length; i++){
				(colorButtons[i] as Sprite).alpha = .25;
			}
			var s:Number = colorButtons.indexOf(e.currentTarget);
			
			(e.currentTarget as Sprite).alpha = 1;
			
			_currentColor = colors[s];
			_update();
			
		}
		
		private function _onAssetChange(e:MouseEvent):void
		{
			for(var i:Number = 0; i<assetButtons.length; i++){
				(assetButtons[i] as Sprite).alpha = .25;
			}
			var s:Number = assetButtons.indexOf(e.currentTarget);
			
			(e.currentTarget as Sprite).alpha = 1;
			
			_currentAsset = assets[s];
			
			_update();
			
		}
		
		private function _update():void
		{
			_controller.engineAPI.setColor(_currentAsset, _currentColor);
		}
	}
}