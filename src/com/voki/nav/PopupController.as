package com.voki.nav {
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import com.voki.panels.AlertPopup;
	import com.voki.panels.EditTTSPopup;
	import com.voki.panels.EmailPopup;
	import com.voki.panels.EmbedPopup;
	import com.voki.panels.InfoPopup;
	import com.voki.panels.IntroScreen;
	import com.voki.panels.PublishPopup;
	import com.voki.panels.RenamePopup;
	import com.voki.panels.SelectAudioPopup;
	import com.voki.panels.SkinPromoPopup;
	import com.voki.panels.UpgradeAlertPopup;
	import com.voki.panels.UpgradePopup;
	import com.voki.panels.UploadBackgroundPopup;
	
	/**
	* ...
	* @author Sam Myer
	*/
	public class PopupController {
		private var popupParent:DisplayObjectContainer;
		
		public var alertWin:AlertPopup;
		public var confirmWin:AlertPopup;
		public var upgradeWin:UpgradeAlertPopup;
		public var aboutWin:AlertPopup;
		public var uploadBGWin:UploadBackgroundPopup;
		public var renameWin:RenamePopup;
		public var editTTSWin:EditTTSPopup;
		public var selectAudioWin:SelectAudioPopup;
		public var skinPromoWin:SkinPromoPopup;
		public var emailWin:EmailPopup;
		public var embedWin:EmbedPopup;
		public var publishWin:PublishPopup;
		public var introWin:IntroScreen;
		public var infoWin:InfoPopup;
		
		public var saveBlocker:MovieClip;
		public var modelBlocker:MovieClip;
		public var audioBlocker:MovieClip;
		public var sceneBlocker:MovieClip;
		public var accessoryBlocker:MovieClip;
		public var genericBlocker:MovieClip;
		
		public function PopupController($popupParent:DisplayObjectContainer) {
			popupParent = $popupParent;
			alertWin = new sp_popup_alert();
			confirmWin = new sp_popup_confirm();
			uploadBGWin = new sp_popup_uploadBG();
			renameWin = new sp_popup_rename();
			editTTSWin = new sp_popup_ttsEdit();
			selectAudioWin = new sp_popup_selectAudio();
			skinPromoWin = new sp_popup_skinPromo();
			upgradeWin = new sp_popup_upgrade();
			aboutWin = new sp_popup_alertAbout();
			emailWin = new sp_popup_email();
			embedWin = new sp_popup_embed();
			publishWin = new sp_popup_publish();
			introWin = new sp_intro();
			infoWin = new sp_popup_alertInfo();
			
			saveBlocker = new sp_blocker_save();
			modelBlocker = new sp_blocker_model();
			sceneBlocker = new sp_blocker_scene();
			accessoryBlocker = new sp_blocker_accessory();
			audioBlocker = new sp_blocker_audio();
			genericBlocker = new sp_blocker();
		}
		
		public function openPopup(popup:Sprite) {
			popupParent.addChild(popup);
			popup.addEventListener(Event.CLOSE, popupClosed);
		}
		
		public function closePopup(popup:Sprite) {
			if (!popupParent.contains(popup)) return;
			popupParent.removeChild(popup);
			popup.removeEventListener(Event.CLOSE, popupClosed);
		}
		
		private function popupClosed(evt:Event) {
			closePopup(evt.target as Sprite);
		}
	}
	
}