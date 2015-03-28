/**
 * 
 * ...
 * @author Default
 * @version 0.1
 * 
 * 
 */

package com.voki.vhss.dataHandler{
	
	import com.oddcast.assets.structures.*;
	import com.oddcast.audio.CachedTTS;
	
	import com.voki.vhss.Constants;
	import com.voki.vhss.structures.*;
	
	public class VSPlayerXMLHandler implements IXMLHandler
	{
		private var player_xml:XML;
		private var error_url:String;
		
		public function VSPlayerXMLHandler($xml:XML)
		{
			player_xml = $xml;
			var _params_list:XMLList = player_xml.params;
			//trace("VHSS V5 :: PlayerXMLHandler ::: "+Constants.PAGE_DOMAIN);
			if (_params_list.hasOwnProperty("secure_domains")) Constants.verifyDomains(_params_list.secure_domains.D);
			Constants.IS_AI_ENABLED = (_params_list.hasOwnProperty("ai") && _params_list.ai == "1" && Constants.IS_ENABLED_DOMAIN);
			Constants.IS_FILTERED = (_params_list.hasOwnProperty("badwords") && _params_list.badwords == "1");
			if (_params_list.hasOwnProperty("secureplayback") && _params_list.secureplayback == "1" && !Constants.IS_ENABLED_DOMAIN && Constants.PAGE_DOMAIN.indexOf("oddcast.com") == -1)
			{
				error_url = _params_list.errorfile.toString()
				if (_params_list.hasOwnProperty("content_base_url")) error_url = _params_list.content_base_url.toString()+ error_url;
			}
			if (_params_list.hasOwnProperty("online") && _params_list.online == "1") Constants.ONLINE = true;
			Constants.INTERNAL_MODE = _params_list.hasOwnProperty("internalmode") ? _params_list.internalmode.toString() : null;
		}
		
		public function getErrorFile():String
		{
			return error_url;
		}
		
		public function getShowData():SlideShowStruct
		{
			var _params_list:XMLList = player_xml.params;
			var _assets_list:XMLList = player_xml.assets;
			var _ss:SlideShowStruct = new SlideShowStruct();
			_ss.show_xml = player_xml;
			_ss.account_id = (_params_list.hasOwnProperty("account")) ? _params_list.account : _params_list.door;
			_ss.show_id = _params_list.showid;
			_ss.edition_id = _params_list.edition;
			_ss.door_id = _params_list.door;
			_ss.id = _params_list.id;
			_ss.name = _params_list.name;
			if(_params_list.hasOwnProperty("bg_color")) _ss.bg_color = _params_list.bg_color;
			
			if (_params_list.hasOwnProperty("aiengine")) _ss.ai_engine_id = _params_list.aiengine;
			if (_params_list.hasOwnProperty("track_url")) _ss.track_url = _params_list.track_url;
			_ss.oh_dom = (_params_list.hasOwnProperty("oh_base_url")) ? _params_list.oh_base_url.toString() : Constants.RELATIVE_URL;
			_ss.content_dom = (_params_list.hasOwnProperty("content_base_url")) ? _params_list.content_base_url.toString() : Constants.RELATIVE_URL;
			if (_params_list.hasOwnProperty("tts_domain")) _ss.tts_dom = _params_list.tts_domain.toString();
			if (_assets_list.hasOwnProperty("loader")) 
			{
				_ss.loader_url = (_assets_list.loader.toString().indexOf("http") == 0) ? _assets_list.loader.toString() : _ss.content_dom + _assets_list.loader.toString();
				_ss.loaderIsCustom = _assets_list.loader.@custom.toString() == '1' ? true : false;
			}
			if (_assets_list.hasOwnProperty("watermark"))
			{
				_ss.watermark_url = (_assets_list.watermark.toString().indexOf("http") == 0) ? _assets_list.watermark.toString() : _ss.content_dom + _assets_list.watermark.toString();
			}
			_ss.scenes = getSceneData(_ss);
			if (_params_list.hasOwnProperty("volume")) _ss.volume = parseInt(_params_list.volume.toString()); 
			return _ss;
		}
		
		private function getSceneData($ss:SlideShowStruct):Array
		{			
			var _t_ar:Array = new Array();
			for each(var _sx:XML in player_xml..scene) {
				var _sc:SceneStruct = new SceneStruct();
				_sc.id = _sx.id;
				_sc.playback_limit = int(_sx.playbacklimit);
				_sc.playback_interval = int(_sx.playbackdays);
				if (_sx.hasOwnProperty("autoadv")) _sc.auto_advance = (int(_sx.autoadv) >= 0);
				if (_sc.auto_advance) _sc.advance_delay = int(_sx.autoadv);
				_sc.mouse_follow = int(_sx.mouse);
				_sc.host = getHostData(_sx, $ss, _sc);
				_sc.bg = getBGData(_sx, $ss, _sc);
				_sc.skin = getSkinData(_sx, $ss, _sc);
				_sc.audio = getAudioData(_sx, $ss, _sc);
				
				if (_sx.hasOwnProperty("link") && _sx.link.@href != null && !Constants.SUPPRESS_LINK)//_sx.link.toString().length > 0) 
				{
					_sc.link = new LinkStruct();
					_sc.link.url = _sx.link.@href;
					_sc.link.target = (_sx.link.@window != null) ? _sx.link.@window : "_blank";
					_sc.link.is_start_launch = (_sx.link.@auto == "start");
					_sc.link.is_end_launch = (_sx.link.@auto == "end");
					_sc.link.is_button_launch = (_sx.link.@button == "1");
					if (_sx.link.@delay != null) _sc.link.auto_delay = parseInt(_sx.link.@delay)*1000;
					//<link href="http://www.huffingtonpost.com" auto="start" delay="0" window="_self" button="1"/>
					
				}
				_t_ar.push(_sc);
			}
			return _t_ar;
		}	
		
		private function getHostData($sx:XML, $ss:SlideShowStruct, $scs:SceneStruct):HostStruct
		{
			if ($sx.avatar.hasSimpleContent())
			{
				return null;
			}
			else
			{
				var _assets_list:XMLList = player_xml.assets;
				var _hxl:XML = _assets_list.avatar.(@id == $sx.avatar.id)[0]; // grabs the 1st matching id on the assets list
				var _hurl:String = _hxl.toString();
				var _exl:XML = _assets_list.engine.(@id == _hxl.@engine)[0]; // grabs the 1st matching id on the assets list
				var _eng_type:String = _exl.@type.toLowerCase();
				var _hs:HostStruct;
				if ($sx.avatar.hasOwnProperty("scale"))
				{
					$scs.host_scale = int($sx.avatar.scale);
				}
				if ($sx.avatar.hasOwnProperty("visible")) $scs.host_visible = ($sx.avatar.visible.toString() == "true");
				if ($sx.avatar.hasOwnProperty("x"))
				{
					$scs.host_x = int($sx.avatar.x);
				}
				if ($sx.avatar.hasOwnProperty("y"))
				{
					$scs.host_y = int($sx.avatar.y);
				}
				if ($sx.avatar.hasOwnProperty("expression")) 
				{
					$scs.host_exp = $sx.avatar.expression.toString();
					if ($sx.avatar.expression.@amp != undefined) $scs.host_exp_intensity = $sx.avatar.expression.@amp;
				}
				if (_eng_type == "3d")
				{
					if ($ss.content_dom.length > 0 && _hurl.indexOf("http") != 0) _hurl = $ss.content_dom + _hurl;
					//trace("PLAYERXMLHANDLER -----  engine type ::: 3d ::: host url: " + _hurl);
					_hs = new HostStruct(_hurl,  $sx.avatar.id, "host_3d");
				}
				else
				{
					var t_hurl:String = _hurl.split("?")[0];
					if (t_hurl.indexOf("http") != 0) t_hurl = $ss.oh_dom + t_hurl;
					_hs = new HostStruct(t_hurl,  $sx.avatar.id, "host_2d");
				}
				_hs.cs = _hurl.split("cs=")[1];
				if (_exl.@url.indexOf("http") != 0 && $ss.oh_dom.length > 0)
				{
					if ($ss.oh_dom.charAt($ss.oh_dom.length-1) != "/" && _exl.@url.charAt(0) != "/")
					{
						_exl.@url = "/"+_exl.@url;
					}
					_hs.engine.url = $ss.oh_dom + _exl.@url;
				}
				else
				{
					_hs.engine.url = _exl.@url;
				}
				//----trace("PLAYERXMLHANDLER -----  engine url :: " + _hs.engine.url );
				_hs.engine.type = _exl.@type.toLowerCase();
				_hs.engine.id = _hxl.@engine;
				return _hs;
			}
		}
		
		private function getBGData($sx:XML, $ss:SlideShowStruct, $scs:SceneStruct):BackgroundStruct
		{
			if ($sx.bg.hasSimpleContent())
			{
				return null;
			}
			else
			{
				var _assets_list:XMLList = player_xml.assets;
				//trace("!!!!!!!!!!!!!  $sx.bg.visible: "+$sx.bg.visible+ "  $sx.bg.scale: "+$sx.bg.scale);
				if ($sx.bg.hasOwnProperty("visible")) $scs.bg_visible = ($sx.bg.visible == "true" || $sx.bg.visible == "1");
				var _xl:XML = _assets_list.bg.(@id == $sx.bg.id)[0];
				var _burl:String = (_xl.toString().indexOf("http") != 0 && $ss.content_dom.length > 0) ? $ss.content_dom + _xl : _xl;
				var _btype:String = _xl.@type;
				if ($sx.bg.hasOwnProperty("scale")) {
					$scs.backgroundTransform = { scaleX:parseFloat($sx.bg.scale) * .01, scaleY:parseFloat($sx.bg.scale) * .01 };
				}
				var _bs:BackgroundStruct = new BackgroundStruct(_burl, $sx.bg.id, _btype);
				return _bs;
			}
		}
		
		private function getAudioData($sx:XML, $ss:SlideShowStruct, $scs:SceneStruct):AudioStruct
		{
			//trace("PlayerXMLHandler -- getAudioData -- \nAUDIO_____\n"+$sx.audio+"\nID_____  "+$sx.audio.hasOwnProperty("id")+"\n"+$sx.audio.id);
			if (!$sx.audio.hasOwnProperty("id"))
			{
				if ($sx.audio.hasOwnProperty("play")) $scs.play_mode = $sx.audio.play;
				return null;
			}
			else
			{
				var _assets_list:XMLList = player_xml.assets;
				var _as:AudioStruct = new AudioStruct();
				var _id_node:String = ($sx.audio.hasOwnProperty("tempid")) ? "tempid" : "id";
				var t_id_list:XMLList = $sx.audio[_id_node];
				var t_audio_ar:Array = new Array();
				for (var n:int = 0; n < t_id_list.length(); ++n)
				{
					var t_commas_ar:Array = t_id_list[n].split(",");
					for (var i:int = 0; i < t_commas_ar.length; ++i)
					{
						t_audio_ar.push(t_commas_ar[i]);
					}
				}
				//var t_audio_ar:Array = $sx.audio[_id_node];//.toString().split(",");
				
				_as.id = t_audio_ar[int(Math.random()*t_audio_ar.length)];
				//_as.id = $sx.audio[_id_node];
				
				//_as.play_mode = $sx.audio.play;
				$scs.play_mode = $sx.audio.play;
				
				var _xl:XML = _assets_list.audio.(@[_id_node] == _as.id)[0];
				if (_xl.@type == "tts" || _xl.text.toString().length > 1)
				{
					CachedTTS.setDomain($ss.tts_dom);
					var _code:int = parseInt(_xl.voice.toString());
					var _engine:int = Math.floor(_code/100000);
					var _lang:int = Math.floor((_code%100000)/1000);
					var _voice:int = Math.floor(_code%100);
					var _fx_type:String = "";
					var _fx_level:Number;
					if (_xl.hasOwnProperty("fx_type") && _xl.hasOwnProperty("fx_level"))
					{
						_fx_type = _xl.fx_type.toString();;
						_fx_level = parseInt(_xl.fx_level.toString());
					}
					_as.url = CachedTTS.getTTSURL(unescape(unescape(_xl.text.toString())), _voice, _lang, _engine, _fx_type, _fx_level);
					//----trace("PlayerXMLHandler _+_+_ cached tts url: " + _as.url+"  CachedTTS: "+CachedTTS);
				}
				else 
				{
					_as.url = (_xl.toString().indexOf("http") != 0 && $ss.content_dom.length > 0) ? $ss.content_dom + _xl.toString() : _xl.toString();
				}
				return _as;
			}
		}
		
		private function getSkinData($sx:XML, $ss:SlideShowStruct, $scs:SceneStruct):SkinStruct
		{
			if ($sx.skin.hasSimpleContent())
			{
				return null;
			}
			else
			{
				var _assets_list:XMLList = player_xml.assets;
				var _ss:SkinStruct = new SkinStruct();
				_ss.id = $sx.skin.id;
				var _xl:XML = _assets_list.skin.(@id == $sx.skin.id)[0];
				_ss.url = (_xl.toString().indexOf("http") != 0 && $ss.content_dom.length > 0) ? $ss.content_dom + _xl.toString() : _xl.toString();
				$scs.skin_conf = XML($sx.skin.SKINCONF);
				//----trace("PlayerXMLHandler  -- getSkinData  --- skin xml: "+$sx.skin.SKINCONF)
				return _ss;
			}
		}
		
		private function getVideoData($sx:XML, $ss:SlideShowStruct, $scs:SceneStruct):VideoStruct
		{
			if ($sx.video.hasSimpleContent())
			{
				return null;
			}
			else
			{
				var _assets_list:XMLList = player_xml.assets;
				var _vxl:XML = _assets_list.video.(@id == $sx.video.id)[0]; // grabs the 1st matching id on the assets list
				var _vurl:String = _vxl.toString();
				
			}
			
			//var videoStruct:VideoStruct = new VideoStruct();
			return null;
		}
	}
	
	
}