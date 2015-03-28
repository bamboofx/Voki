package com.voki.panels {
	
	import com.oddcast.ui.BaseButton;
	import com.oddcast.ui.OCheckBox;
	import com.oddcast.utils.Cloner;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;	
	import flash.geom.Matrix;
	import com.voki.data.SceneStruct;
	import com.voki.data.SkinConfiguration;
	import com.voki.data.SPCharStruct;
	import com.voki.data.SPSkinStruct;
	import com.voki.player.PlayerController;
	import com.oddcast.event.AlertEvent;
	/**
	* ...
	* @author Sam Myer
	*/
	public class CopySettingsPopup extends MovieClip {
		public var _mcBtnClose:BaseButton;
		public var btnPrevious:BaseButton;
		public var btnSubsequent:BaseButton;
		public var btnAll:BaseButton;
		public var _mcBlocker:MovieClip;
		public var cbPosition:OCheckBox;
		
		private var player:PlayerController;
		
		
		public function CopySettingsPopup() {
			this.visible = false;
			this.addEventListener(MouseEvent.CLICK, onClick);
			cbPosition.selected = false;
			//_mcBtnClose.addEventListener(MouseEvent.CLICK, onClose, false, 0, true);			
		}
		
		private function onClick(evt:MouseEvent):void
		{
			trace("CopySettingsPopup::onClick "+evt.target.name);
			switch (evt.target.name)
			{
				
				case "_mcBtnClose":
					onClose();
					break;
				case "btnAll":
					copySettings();
					break;
				case "btnPrevious":
					copySettings(-1);
					break;
				case "btnSubsequent":
					copySettings(1);
					break;
					
			}
		}
		
		public function copySettings(dir:int = 0, notify:Boolean = true):void
		{
			if (player != null && player.scene != null)
			{
				player.compileScene();
				var skinConfig:SkinConfiguration = player.scene.skinConfig;
				var skin:SPSkinStruct = player.scene.skin;				
				var pos:int = player.curSceneIndex - 1;
				var hostPos:Matrix = SPCharStruct(player.scene.char).hostPos;
				var copyPosition:Boolean = cbPosition.selected;
				for (var i:int = 0; i < player.getShow().sceneArr.length; ++i )
				{
					if ((dir==1 && i > pos) || (dir==-1 && i<pos) || dir==0)
					{
						if (i==pos) continue;
						var tmpSkinObj:SPSkinStruct;
						var tmpConfig:SkinConfiguration;
						var curConfig:SkinConfiguration = SceneStruct(player.getShow().sceneArr[i]).skinConfig;
						if (skin != null)
						{
							tmpSkinObj = new SPSkinStruct(skin.url, skin.id);								
							tmpSkinObj.level = skin.level;
							tmpSkinObj.width = skin.width;
							tmpSkinObj.height = skin.height; 
							tmpSkinObj.type = skin.type;
							tmpSkinObj.selectedColorArr = skinConfig.colorArr.slice();//skin.selectedColorArr.slice();
							tmpSkinObj.defaultColorArr = SceneStruct(player.getShow().sceneArr[i]).skin.defaultColorArr.slice();
							
							tmpConfig = new SkinConfiguration(skin.type);
							tmpConfig.setFromSkin(skin);
							tmpConfig.colorArr = skinConfig.colorArr.slice()
							if (!notify)
							{
								if (SceneStruct(player.getShow().sceneArr[i]).skinConfig != null && SceneStruct(player.getShow().sceneArr[i]).skinConfig.title.length>0)
								{
									tmpConfig.title = SceneStruct(player.getShow().sceneArr[i]).skinConfig.title;
								}
								else
								{
									tmpConfig.title = SceneStruct(player.getShow().sceneArr[i]).title != null? SceneStruct(player.getShow().sceneArr[i]).title:"";
								}
							}
							else
							{
								tmpConfig.title = skinConfig.title;
								tmpConfig.showMute = skinConfig.showMute;
								tmpConfig.showNext = skinConfig.showNext;
								tmpConfig.showPlay = skinConfig.showPlay;
								tmpConfig.showPrev = skinConfig.showPrev;
								tmpConfig.showTitle = skinConfig.showTitle;
								tmpConfig.showVolume = skinConfig.showVolume;
								tmpConfig.align = skinConfig.align;
							}
							tmpConfig.ai = curConfig.ai;
							tmpConfig.faq = curConfig.faq;
							tmpConfig.lead = curConfig.lead;
							tmpConfig.email = curConfig.email;
							
							
							//tmpConfig.setFromXML(skinConfig.getXML());
						}
						else
						{
							tmpConfig = null;// new SkinConfiguration("NONE");
							
							//tmpConfig.setFromXML(skinConfig.getXML(), player.getShow().contentUrl);
							//tmpSkinObj.defaultColorArr = tmpConfig.colorArr.slice();
						}
						
						
						SceneStruct(player.getShow().sceneArr[i]).skin = tmpSkinObj;
						SceneStruct(player.getShow().sceneArr[i]).skinConfig = tmpConfig;
						//copy skin config only if type of player changed						
						if (copyPosition)
						{
							SceneStruct(player.getShow().sceneArr[i]).char.hostPos = hostPos
						}
					}
				}
				
				
				if (notify)
				{
					player.updateSkinSettings();
					dispatchEvent(new AlertEvent(AlertEvent.ALERT, "sp512", "The scene settings have been copied to selected scenes"));
				}
				onClose();
			}
		}
		
		public function openPanel():void
		{
			this.visible = true;
		}
		
		public function setPlayer(p:PlayerController)
		{
			player = p;
		}
		
		
		protected function onClose() {
			this.visible = false;
			dispatchEvent(new Event(Event.CLOSE));
		}
				
		
	}
	
}