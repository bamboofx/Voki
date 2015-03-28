package com.voki.panels {
	import com.oddcast.event.SelectorEvent;
	import com.oddcast.ui.OCheckBox;
	import com.oddcast.ui.Selector;
	import com.oddcast.utils.XMLLoader;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import com.voki.data.SessionVars;
	import com.voki.data.SkinPromoData;
	
	/**
	* ...
	* @author Sam Myer
	*/
	public class SkinPromoPopup extends MovieClip {
		public var skinTypeSelector:Selector;
		public var cb_dontShow:OCheckBox;
		public var closeBtn:SimpleButton;
		public var featuresWin:MovieClip;
		
		private var isInited:Boolean = false;
		public var firstOpen:Boolean = true;
		
		public function SkinPromoPopup() {
			closeBtn.addEventListener(MouseEvent.CLICK, onClose);
			skinTypeSelector.addEventListener(SelectorEvent.SELECTED, skinTypeSelected);
			skinTypeSelector.addItemEventListener("info", showSkinInfo);
			featuresWin.closeBtn.addEventListener(MouseEvent.CLICK, onFeaturesClose);
		}
		
		public function init() {
			featuresWin.visible = false;
			firstOpen = false;
			
			if (!isInited) XMLLoader.loadXML(SessionVars.localBaseURL+"xml/skinpromo.xml",populateSkinPromo)
		}
		
		private function closeWin() {
			SessionVars.noSkinPromo = cb_dontShow.selected;
			dispatchEvent(new Event(Event.CLOSE));			
		}
		
		private function populateSkinPromo(_xml:XML) {
			var promoArr:Array = parsePromos(_xml);
			
			skinTypeSelector.clear();
			var promo:SkinPromoData;
			for (var i:int = 0; i < promoArr.length; i++) {
				promo = promoArr[i];
				skinTypeSelector.add(i, promo.typeName, promo);
			}
			isInited = true;
		}
		
		private function parsePromos(_xml:XML) {
			var playerXml:XML;
			var playerArr:Array=new Array();
			var featureArr:Array;
			var promoData:SkinPromoData;
			var i,j;
			for (i = 0; i < _xml.PLAYER.length(); i++) {
				playerXml = _xml.PLAYER[i];
				
				promoData = new SkinPromoData();
				promoData.typeName=playerXml.@TYPE;
				promoData.title=playerXml.@TITLE;
				promoData.level=parseInt(playerXml.@LEVEL.toString());
				promoData.availability=playerXml.AVAIL.toString();
				promoData.description = playerXml.DESC.toString();
				
				promoData.features = new Array();
				for (j=0;j<playerXml.FEATURE.length();j++) {
					promoData.features.push(playerXml.FEATURE[j].toString());
				}
				
				playerArr.push(promoData);
			}
			return(playerArr);
		}
		
		private function skinTypeSelected(evt:SelectorEvent) {
			trace("SkinPromoPopup::skinTypeSelected : " + evt.text);
			skinTypeSelector.deselect();
			dispatchEvent(new TextEvent("select", false,false,evt.text));
			closeWin();
		}
		
		private function showSkinInfo(evt:SelectorEvent) {
			var promoData:SkinPromoData = evt.obj as SkinPromoData;
			featuresWin.visible = true;
			featuresWin.thumb.gotoAndStop(promoData.typeName.toLowerCase());
			featuresWin.tf_title.text = promoData.title;
			featuresWin.tf_desc.text = promoData.description;
			featuresWin.tf_availability.text = promoData.availability;
			if (promoData.features.length > 0) featuresWin.tf_feature1.text = promoData.features[0];
			if (promoData.features.length > 1) featuresWin.tf_feature2.text = promoData.features[1];
		}
		
		private function onFeaturesClose(evt:MouseEvent) {
			featuresWin.visible = false;
		}
		
		private function onClose(evt:MouseEvent) {
			closeWin();
		}		
	}
	
}