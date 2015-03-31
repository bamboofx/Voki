/**
* ...
* @author Dave Segal
* @version 0.1
* @Date 11.27.2007
* 
*/

package com.voki.vhss.structures{

	import com.oddcast.assets.structures.AudioStruct;
	import com.oddcast.assets.structures.BackgroundStruct;
	import com.oddcast.assets.structures.HostStruct;
	import com.oddcast.assets.structures.SkinStruct;
	import com.pagodaflash.data.ObjectUtil;
	
	import flash.geom.Matrix;
	import flash.utils.ByteArray;
	
	public class SceneStruct
	{
		public var id:String;
		public var number:Number;
		public var auto_advance:Boolean;
		public var advance_delay:Number;
		public var mouse_follow:Number;
		public var playback_limit:Number;
		public var playback_interval:Number;
		
		public var host_x:Number = 0;
		public var host_y:Number = 0;
		public var host_scale:Number = 100;
		public var host_visible:Boolean = true;
		public var host_exp:String;
		public var host_exp_intensity:Number = 1;
		public var bg_visible:Boolean = true;
		public var play_mode:String = "";
		public var title:String;
		public var audio:AudioStruct;
		public var assets_to_load:Number = 0;
		public var link:LinkStruct;
		
		//public var link_url:String;
		//public var link_target:String
		
		private var _skin_conf:XML;
		private var host_data:HostStruct;
		private var bg_data:BackgroundStruct;
		private var skin_data:SkinStruct;
		private var _backgroundTransform:Object = { x:0, y:0, rotation:0, scaleX:1, scaleY:1 };
		
		
		
		public function set host(host:HostStruct):void
		{
			if (host && host.url)
				++assets_to_load;
			host_data = host;
		}
		public function get host():HostStruct
		{
			return host_data;
		}
		
		public function set bg(bg:BackgroundStruct):void
		{
			if (bg && bg.url) {
				++assets_to_load;
				bg_data = bg;
			}	
		}
		public function get bg():BackgroundStruct
		{
			return bg_data;
		}
		
		public function get backgroundTransform():Object
		{
			function clone( source:Object ):* 
			{ 
				var myBA:ByteArray = new ByteArray(); 
				myBA.writeObject( source ); 
				myBA.position = 0; 
				return( myBA.readObject() ); 
			}

			return clone(_backgroundTransform);
		}
		
		public function set backgroundTransform(transform:Object):void
		{
			// since transform might not contain all available props (maybe just x and y, not rotation, scaleX, scaleY), copy properties over so as not to overwrite untouched ones
			for (var key:String in transform) {
				_backgroundTransform[key] = transform[key];
			}
		}
		
		public function set skin(skin:SkinStruct):void
		{
			if (skin && skin.url) {
				++assets_to_load;
				skin_data = skin;
			} else {
				skin_data = null;
			}
		}
		public function get skin():SkinStruct
		{
			return skin_data;
		}
		
		public function set skin_conf($x:XML):void
		{
			_skin_conf = $x;
			title = $x.@TITLE;
		}
		public function get skin_conf():XML
		{
			return _skin_conf;
		}
	}
	
	/*
	 * <scene>
			<id>17505</id>
			<order>1</order>
			<autoadv delay="1">true</autoadv>
			<mouse>4</mouse>
			<avatar>
				<id>21735</id>
				<x>116</x>
				<y>22</y>
				<scale>57</scale>
				<visible>true</visible>
			</avatar>
			<bg>
				<id>33483</id>
				<visible>true</visible>
			</bg>
			<audio>
				<id>1</id>
				<play>load</play>
			</audio>
			<skin>
				<id>87</id>
				<SKINCONF CATID="0" ID="87" ALIGN="center" TITLE="hello" VTITLE="0" NEXT="1" PREV="" VOL="1" PLAY="1" HEIGHT="300" WIDTH="400" MUTE="1" C1="0x784848" C2="0xBE8F25" C3="0xF414AD" C4="0x2B623D" EMAIL="dave@oddcast.com">
					<FAQ>
						<Q NAME="-+dave+mic+rec+1" ID="17215" URL="user/ebd/1508/audio/1183057810168_1508">what+is+4+plus+1%3F</Q>
					</FAQ>
				</SKINCONF>
			</skin>
			<link window="_blank">http://www.npr.com</link>
		</scene>
	 */
}