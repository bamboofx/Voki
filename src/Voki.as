package
{
	import com.oddcast.vhost.accessories.AccessoryData;
	import com.oddcast.workshop.Accessory_XML_Parser;
	import com.voki.Controller;
	import com.voki.data.SPHostStruct;
	import com.voki.engine.EngineV5;
	import com.voki.player.PlayerController;
	
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;	
	import flash.text.TextField;
	import flash.text.TextFieldType;
	
	//[SWF(frameRate=12)]
	public class Voki extends Sprite
	{
		
		private var _controller:PlayerController;
		private var _engine:EngineV5;
		private var _holder:MovieClip;
		public function Voki()
		{
			super();
			//Security.allowDomain("*");
			
			// support autoOrients
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			_holder = new MovieClip();
			stage.addChild(_holder);
			
			_controller = new PlayerController(_holder);
			_controller.init('assets/vhss_v5_config.xml');
			
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
			
			var request:URLRequest = new URLRequest('assets/accessory_thumnail_57191.jpg');
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, function(e:Event):void{
				stage.addChildAt(_holder, 0);
			});
			loader.load(request);
			addChild(loader);
			loader.x = stage.stageWidth-50;
			loader.addEventListener(MouseEvent.CLICK, _onAccChangeClick);
				
			
			request= new URLRequest('assets/104_15332.jpg');
			
			var modelLoader:Loader = new Loader();
			modelLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, function(e:Event):void{
				stage.addChildAt(_holder, 0);
			});
			modelLoader.load(request);
			addChild(modelLoader);
			modelLoader.x = stage.stageWidth-125;			
			modelLoader.addEventListener(MouseEvent.CLICK, _onModelChangeClick);
		}
		
		private var colors:Array;
		private var assets:Array;
		private var colorButtons:Array;
		private var assetButtons:Array;
		private var _currentColor:uint;
		private var _currentAsset:String;
		
		private function _onModelChangeClick(e:MouseEvent):void
		{//?cs=64a8a6:363a3a7:104a587:e3a4a6:0:101:101:101:101:101:1::
			var maleXML:XML = new XML('<MODEL ID="104" NAME="Carson" THUMB="puppets/thumbs/104_15332.jpg" LEVEL="0" OH="/oh/104/1509/1257/1260/1265/860/1522/302/0/0/0/ohv2.swf?cs=64a8a6:363a3a7:104a587:e3a4a6:0:101:101:101:101:101:1::" ENGINEID="1" IS3D="0" GENDERID="2" />');
			var host:SPHostStruct = new SPHostStruct('assets/ohv2-male.swf',104,'104_15332.jpg','Carson');
			//host.engine = _controller.engineAPI;
			host.cs='64a8a6:363a3a7:104a587:e3a4a6:0:101:101:101:101:101:1::';
			_controller.loadModel(host);
		}
		private function _onAccChangeClick(e:MouseEvent):void
		{
			//			<ITEM ID="57191" NAME="onLive_oc_kayla_biz_suit_blue_shirt" CATID="5" CATEGORY="" COMPAT="0" COMPATID="0" THUMB="/88/e4/accessory_thumnail_57191.jpg">
			//				<FRAGMENT TYPE="Front" FILENAME="/24/70/f9_fragment_ac57191_fr4.swf"/>
			//			</ITEM>
			//			http://content.oddcast.com/ccs2/mam/24/70/f9_fragment_ac57191_fr4.swf
			
			
			var parser:Accessory_XML_Parser = new Accessory_XML_Parser();
			var costumes:XML = new XML('<ACCESSORIES COUNT="28" BASEURL="http://content.oddcast.com/ccs2/mam" TYPE="Costume"><ITEM ID="57191" NAME="onLive_oc_kayla_biz_suit_blue_shirt" CATID="5" CATEGORY="" COMPAT="0" COMPATID="0" THUMB="/88/e4/accessory_thumnail_57191.jpg"><FRAGMENT TYPE="Front" FILENAME="assets/frag-new.swf"/></ITEM><ITEM ID="57192" NAME="onLive_oc_kayla_biz_suit_brown_shirt" CATID="5" CATEGORY="" COMPAT="0" COMPATID="0" THUMB="/58/2b/accessory_thumnail_57192.jpg"><FRAGMENT TYPE="Front" FILENAME="/e8/95/f9_fragment_ac57192_fr4.swf"/></ITEM><ITEM ID="57193" NAME="onLive_oc_kayla_biz_suit_green_shirt" CATID="5" CATEGORY="" COMPAT="0" COMPATID="0" THUMB="/4a/40/accessory_thumnail_57193.jpg"><FRAGMENT TYPE="Front" FILENAME="assets/f9_fragment_ac57193_fr4.swf"/></ITEM><ITEM ID="32532" NAME="oc_gena_costume_1" CATID="5" CATEGORY="" COMPAT="0" COMPATID="0" THUMB="/ae/5a/accessory_thumnail_32532.jpg"><FRAGMENT TYPE="Front" FILENAME="/b8/07/f9_fragment_ac32532_fr4.swf"/></ITEM><ITEM ID="32533" NAME="oc_gena_costume_2" CATID="5" CATEGORY="" COMPAT="0" COMPATID="0" THUMB="/cf/61/accessory_thumnail_32533.jpg"><FRAGMENT TYPE="Front" FILENAME="/e8/97/f9_fragment_ac32533_fr4.swf"/></ITEM><ITEM ID="7666" NAME="SPK_female_costumes8" CATID="5" CATEGORY="" COMPAT="0" COMPATID="0" THUMB="/6e/c9/accessory_thumnail_7666.jpg"><FRAGMENT TYPE="Front" FILENAME="/97/e9/f9_fragment_ac7666_fr4.swf"/></ITEM><ITEM ID="13190" NAME="blk_suit_blue_shirt" CATID="5" CATEGORY="" COMPAT="0" COMPATID="0" THUMB="/8b/a3/accessory_thumnail_13190.jpg"><FRAGMENT TYPE="Front" FILENAME="/d2/9e/f9_fragment_ac13190_fr4.swf"/></ITEM><ITEM ID="13194" NAME="blk_suit_dk_brown_suit" CATID="5" CATEGORY="" COMPAT="0" COMPATID="0" THUMB="/24/da/accessory_thumnail_13194.jpg"><FRAGMENT TYPE="Front" FILENAME="/52/12/f9_fragment_ac13194_fr4.swf"/></ITEM><ITEM ID="13191" NAME="blk_suit_pink_shirt" CATID="5" CATEGORY="" COMPAT="0" COMPATID="0" THUMB="/86/39/accessory_thumnail_13191.jpg"><FRAGMENT TYPE="Front" FILENAME="/d8/d7/f9_fragment_ac13191_fr4.swf"/></ITEM><ITEM ID="13192" NAME="blk_suit_purple_shirt" CATID="5" CATEGORY="" COMPAT="0" COMPATID="0" THUMB="/6e/bb/accessory_thumnail_13192.jpg"><FRAGMENT TYPE="Front" FILENAME="/35/c0/f9_fragment_ac13192_fr4.swf"/></ITEM><ITEM ID="13195" NAME="blk_suit_white_shirt" CATID="5" CATEGORY="" COMPAT="0" COMPATID="0" THUMB="/d8/33/accessory_thumnail_13195.jpg"><FRAGMENT TYPE="Front" FILENAME="/22/7c/f9_fragment_ac13195_fr4.swf"/></ITEM><ITEM ID="13193" NAME="blk_suit_wine_shirt" CATID="5" CATEGORY="" COMPAT="0" COMPATID="0" THUMB="/0e/2e/accessory_thumnail_13193.jpg"><FRAGMENT TYPE="Front" FILENAME="/08/2a/f9_fragment_ac13193_fr4.swf"/></ITEM><ITEM ID="6308" NAME="em_Condoleeza_Rice_costume" CATID="5" CATEGORY="" COMPAT="0" COMPATID="0" THUMB="/ba/c2/accessory_thumnail_6308.jpg"><FRAGMENT TYPE="Front" FILENAME="/b4/66/f9_fragment_ac6308_fr4.swf"/></ITEM><ITEM ID="25060" NAME="female_biz_suit_navy_blue_pinstripe" CATID="5" CATEGORY="" COMPAT="0" COMPATID="0" THUMB="/18/39/accessory_thumnail_25060.jpg"><FRAGMENT TYPE="Front" FILENAME="/c0/40/f9_fragment_ac25060_fr4.swf"/></ITEM><ITEM ID="4377" NAME="grandma_green_red_suit" CATID="5" CATEGORY="" COMPAT="0" COMPATID="0" THUMB="/c0/3f/accessory_thumnail_4377.jpg"><FRAGMENT TYPE="Front" FILENAME="/8d/cf/f9_fragment_ac4377_fr4.swf"/></ITEM><ITEM ID="448" NAME="grey_suit_020" CATID="5" CATEGORY="" COMPAT="1" COMPATID="13" THUMB="/0a/48/accessory_thumnail_448.jpg"><FRAGMENT TYPE="Front" FILENAME="/ea/a9/f9_fragment_ac448_fr4.swf"/></ITEM><ITEM ID="12661" NAME="navy_blue_suit" CATID="5" CATEGORY="" COMPAT="0" COMPATID="0" THUMB="/84/db/accessory_thumnail_12661.jpg"><FRAGMENT TYPE="Front" FILENAME="/cb/5b/f9_fragment_ac12661_fr4.swf"/></ITEM><ITEM ID="6307" NAME="oc_Hilary_Clinton_costumes" CATID="5" CATEGORY="" COMPAT="0" COMPATID="0" THUMB="/98/47/accessory_thumnail_6307.jpg"><FRAGMENT TYPE="Front" FILENAME="/05/83/f9_fragment_ac6307_fr4.swf"/></ITEM><ITEM ID="1281" NAME="olive_suit" CATID="5" CATEGORY="" COMPAT="0" COMPATID="0" THUMB="/ac/c6/accessory_thumnail_1281.jpg"><FRAGMENT TYPE="Front" FILENAME="/02/cc/f9_fragment_ac1281_fr4.swf"/></ITEM><ITEM ID="422" NAME="onLive_jacket_064" CATID="5" CATEGORY="" COMPAT="0" COMPATID="0" THUMB="/f4/d6/accessory_thumnail_422.jpg"><FRAGMENT TYPE="Front" FILENAME="/09/32/f9_fragment_ac422_fr4.swf"/></ITEM><ITEM ID="844" NAME="red_suit_118" CATID="5" CATEGORY="" COMPAT="1" COMPATID="13" THUMB="/b6/9a/accessory_thumnail_844.jpg"><FRAGMENT TYPE="Front" FILENAME="/5c/d5/f9_fragment_ac844_fr4.swf"/></ITEM><ITEM ID="6367" NAME="stephie_costume_1" CATID="5" CATEGORY="" COMPAT="0" COMPATID="0" THUMB="/dd/ad/accessory_thumnail_6367.jpg"><FRAGMENT TYPE="Front" FILENAME="/0a/e1/f9_fragment_ac6367_fr4.swf"/></ITEM><ITEM ID="6368" NAME="stephie_costume_2" CATID="5" CATEGORY="" COMPAT="0" COMPATID="0" THUMB="/02/48/accessory_thumnail_6368.jpg"><FRAGMENT TYPE="Front" FILENAME="/e0/a9/f9_fragment_ac6368_fr4.swf"/></ITEM><ITEM ID="6373" NAME="stephie_costume_7" CATID="5" CATEGORY="" COMPAT="0" COMPATID="0" THUMB="/50/2a/accessory_thumnail_6373.jpg"><FRAGMENT TYPE="Front" FILENAME="/8c/a5/f9_fragment_ac6373_fr4.swf"/></ITEM><ITEM ID="6374" NAME="stephie_costume_8" CATID="5" CATEGORY="" COMPAT="0" COMPATID="0" THUMB="/ce/79/accessory_thumnail_6374.jpg"><FRAGMENT TYPE="Front" FILENAME="/c4/05/f9_fragment_ac6374_fr4.swf"/></ITEM><ITEM ID="447" NAME="suit_014" CATID="5" CATEGORY="" COMPAT="0" COMPATID="0" THUMB="/61/03/accessory_thumnail_447.jpg"><FRAGMENT TYPE="Front" FILENAME="/25/a3/f9_fragment_ac447_fr4.swf"/></ITEM><ITEM ID="452" NAME="suit_044" CATID="5" CATEGORY="" COMPAT="0" COMPATID="0" THUMB="/23/86/accessory_thumnail_452.jpg"><FRAGMENT TYPE="Front" FILENAME="/a9/06/f9_fragment_ac452_fr4.swf"/></ITEM><ITEM ID="454" NAME="suit_117" CATID="5" CATEGORY="" COMPAT="0" COMPATID="0" THUMB="/4d/f2/accessory_thumnail_454.jpg"><FRAGMENT TYPE="Front" FILENAME="/a6/91/f9_fragment_ac454_fr4.swf"/></ITEM></ACCESSORIES>');
			var hair:XML = new XML('<ACCESSORIES COUNT="5" BASEURL="http://content.oddcast.com/ccs2/mam" TYPE="Hair"><ITEM ID="858" NAME="default_no_hair" CATID="5" CATEGORY="Default" COMPAT="0" COMPATID="0" THUMB="/1a/08/accessory_thumnail_858.jpg"><FRAGMENT TYPE="Left" FILENAME="/0d/7c/f9_fragment_ac858_fr1.swf"/><FRAGMENT TYPE="Right" FILENAME="/0c/ff/f9_fragment_ac858_fr2.swf"/></ITEM><ITEM ID="57794" NAME="onLive_oc_annabelle_hair" CATID="5" CATEGORY="Default" COMPAT="1" COMPATID="9" THUMB="/9c/7b/accessory_thumnail_57794.jpg"><FRAGMENT TYPE="Left" FILENAME="/e5/39/f9_fragment_ac57794_fr1.swf"/><FRAGMENT TYPE="Right" FILENAME="/04/75/f9_fragment_ac57794_fr2.swf"/><FRAGMENT TYPE="Back" FILENAME="/c0/69/f9_fragment_ac57794_fr3.swf"/></ITEM><ITEM ID="57790" NAME="onLive_oc_annabelle_hair1" CATID="5" CATEGORY="Default" COMPAT="1" COMPATID="9" THUMB="/5a/76/accessory_thumnail_57790.jpg"><FRAGMENT TYPE="Left" FILENAME="/06/87/f9_fragment_ac57790_fr1.swf"/><FRAGMENT TYPE="Right" FILENAME="/36/1d/f9_fragment_ac57790_fr2.swf"/><FRAGMENT TYPE="Back" FILENAME="/cb/85/f9_fragment_ac57790_fr3.swf"/></ITEM><ITEM ID="57791" NAME="onLive_oc_annabelle_hair2" CATID="5" CATEGORY="Default" COMPAT="1" COMPATID="9" THUMB="/e3/8c/accessory_thumnail_57791.jpg"><FRAGMENT TYPE="Left" FILENAME="/b9/db/f9_fragment_ac57791_fr1.swf"/><FRAGMENT TYPE="Right" FILENAME="/c2/fd/f9_fragment_ac57791_fr2.swf"/><FRAGMENT TYPE="Back" FILENAME="/28/ac/f9_fragment_ac57791_fr3.swf"/></ITEM><ITEM ID="57792" NAME="onLive_oc_annabelle_hair3" CATID="5" CATEGORY="Default" COMPAT="1" COMPATID="9" THUMB="/f0/55/accessory_thumnail_57792.jpg"><FRAGMENT TYPE="Left" FILENAME="/32/60/f9_fragment_ac57792_fr1.swf"/><FRAGMENT TYPE="Right" FILENAME="/4a/5a/f9_fragment_ac57792_fr2.swf"/><FRAGMENT TYPE="Back" FILENAME="/b8/c9/f9_fragment_ac57792_fr3.swf"/></ITEM><ITEM ID="57793" NAME="onLive_oc_annabelle_hair4" CATID="5" CATEGORY="Default" COMPAT="1" COMPATID="9" THUMB="/86/6d/accessory_thumnail_57793.jpg"><FRAGMENT TYPE="Left" FILENAME="/c6/5d/f9_fragment_ac57793_fr1.swf"/><FRAGMENT TYPE="Right" FILENAME="/0d/e5/f9_fragment_ac57793_fr2.swf"/><FRAGMENT TYPE="Back" FILENAME="/1f/c9/f9_fragment_ac57793_fr3.swf"/></ITEM></ACCESSORIES>');
			var glasses:XML = new XML('<ACCESSORIES COUNT="13" BASEURL="http://content.oddcast.com/ccs2/mam" TYPE="Glasses"><ITEM ID="302" NAME="default_no_glasses" CATID="5" CATEGORY="" COMPAT="0" COMPATID="0" THUMB="/e6/cd/accessory_thumnail_302.jpg"><FRAGMENT TYPE="Mirror" FILENAME="/37/72/f9_fragment_ac302_fr6.swf"/></ITEM><ITEM ID="60498" NAME="oc_sarah_palin_glass" CATID="5" CATEGORY="" COMPAT="0" COMPATID="0" THUMB="/59/ec/accessory_thumnail_60498.jpg"><FRAGMENT TYPE="Mirror" FILENAME="/13/fd/f9_fragment_ac60498_fr6.swf"/></ITEM><ITEM ID="26656" NAME="d29_dk_brown_glasses" CATID="5" CATEGORY="" COMPAT="1" COMPATID="0" THUMB="/45/10/accessory_thumnail_26656.jpg"><FRAGMENT TYPE="Mirror" FILENAME="/7f/ff/f9_fragment_ac26656_fr6.swf"/></ITEM><ITEM ID="26657" NAME="d30_two_brown_glasses" CATID="5" CATEGORY="" COMPAT="1" COMPATID="0" THUMB="/05/74/accessory_thumnail_26657.jpg"><FRAGMENT TYPE="Mirror" FILENAME="/62/2d/f9_fragment_ac26657_fr6.swf"/></ITEM><ITEM ID="26849" NAME="d34_john_lennon_glasses" CATID="5" CATEGORY="" COMPAT="1" COMPATID="0" THUMB="/41/5c/accessory_thumnail_26849.jpg"><FRAGMENT TYPE="Mirror" FILENAME="/ae/ea/f9_fragment_ac26849_fr6.swf"/></ITEM><ITEM ID="26854" NAME="d39_gold_polygon" CATID="5" CATEGORY="" COMPAT="1" COMPATID="0" THUMB="/a0/cd/accessory_thumnail_26854.jpg"><FRAGMENT TYPE="Mirror" FILENAME="/46/9a/f9_fragment_ac26854_fr6.swf"/></ITEM><ITEM ID="26855" NAME="d42_black_wired_rimless" CATID="5" CATEGORY="" COMPAT="1" COMPATID="0" THUMB="/01/33/accessory_thumnail_26855.jpg"><FRAGMENT TYPE="Mirror" FILENAME="/a9/fd/f9_fragment_ac26855_fr6.swf"/></ITEM><ITEM ID="26848" NAME="d47_gold_rectangle_glasses" CATID="5" CATEGORY="" COMPAT="1" COMPATID="0" THUMB="/ad/e2/accessory_thumnail_26848.jpg"><FRAGMENT TYPE="Mirror" FILENAME="/c7/f6/f9_fragment_ac26848_fr6.swf"/></ITEM><ITEM ID="879" NAME="d07_metal_oval_glasses" CATID="5" CATEGORY="" COMPAT="1" COMPATID="0" THUMB="/66/cf/accessory_thumnail_879.jpg"><FRAGMENT TYPE="Mirror" FILENAME="/cb/ee/f9_fragment_ac879_fr6.swf"/></ITEM><ITEM ID="880" NAME="d08_blk_hex_eye" CATID="5" CATEGORY="" COMPAT="1" COMPATID="0" THUMB="/33/1d/accessory_thumnail_880.jpg"><FRAGMENT TYPE="Mirror" FILENAME="/1f/2f/f9_fragment_ac880_fr6.swf"/></ITEM><ITEM ID="863" NAME="d09_blue_plastic_eye" CATID="5" CATEGORY="" COMPAT="1" COMPATID="0" THUMB="/64/8b/accessory_thumnail_863.jpg"><FRAGMENT TYPE="Mirror" FILENAME="/e1/3a/f9_fragment_ac863_fr6.swf"/></ITEM><ITEM ID="864" NAME="d10_blk_plastic_eye" CATID="5" CATEGORY="" COMPAT="1" COMPATID="0" THUMB="/b2/be/accessory_thumnail_864.jpg"><FRAGMENT TYPE="Mirror" FILENAME="/7b/df/f9_fragment_ac864_fr6.swf"/></ITEM><ITEM ID="304" NAME="d3 Plastic Frames" CATID="5" CATEGORY="" COMPAT="1" COMPATID="0" THUMB="/15/3a/accessory_thumnail_304.jpg"><FRAGMENT TYPE="Mirror" FILENAME="/c6/8c/f9_fragment_ac304_fr6.swf"/></ITEM><ITEM ID="4379" NAME="grandma_glasses" CATID="5" CATEGORY="" COMPAT="1" COMPATID="0" THUMB="/1c/23/accessory_thumnail_4379.jpg"><FRAGMENT TYPE="Mirror" FILENAME="/2f/fe/f9_fragment_ac4379_fr6.swf"/></ITEM></ACCESSORIES>');
			var accs:Array = parser.parse_xml(costumes);
			//			var id		:Number = 57191;
			//			var type	:Number = parseInt("Front");
			//			var thumb	:String = "http://content.oddcast.com/ccs2/mam/88/e4/accessory_thumnail_57191.jpg";
			//			var n		:String = "onLive_oc_kayla_biz_suit_blue_shirt";
			//			var compatibility:Number = 0;
			//			var type_name:String = "Costume";
			//			
			//			var accData:AccessoryData  = new AccessoryData(id, name, type, thumb, compatibility );
			//			accData.type_name = type_name;
			
			var accData:AccessoryData = accs[0];
			
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