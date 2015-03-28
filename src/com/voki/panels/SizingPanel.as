package com.voki.panels {
	import com.oddcast.event.ScrollEvent;
	import com.oddcast.ui.Selector;
	import com.oddcast.vhost.ranges.RangeData;
	import flash.display.MovieClip;
	import com.voki.panels.IPanel;
	import com.voki.player.PlayerController;
	
	/**
	* ...
	* @author Sam Myer
	*/
	public class SizingPanel extends MovieClip implements IPanel {
		public var sliderSelector:Selector;
		
		public var player:PlayerController;
		private var sliderNames:Object;
		
		public function SizingPanel() {
			sliderNames = { mouth:"Mouth", nose:"Nose", body:"Shoulders", height:"Head height", width:"Head width", age:"Age" };
			sliderSelector.addItemEventListener(ScrollEvent.SCROLL, sliderChanged);
			
		}
		
		public function openPanel() {
			populateSliders();
		}
		
		public function closePanel() {
		}
		
		private function getSliderName(grpName:String):String {
			if (sliderNames[grpName]==undefined) return(grpName);
			else return(sliderNames[grpName]);
		}
		
		public function populateSliders() {
			sliderSelector.clear();
			var sizeGroups:Array = player.getRanges();
			var groupName:String;
			var range:RangeData;
			for (var i = 0; i < sizeGroups.length; i++ ) {
				range = sizeGroups[i];
				if (range.name == "backhair") continue;  //ignore backhair
				if (range.type == "alpha") continue;  //alpha groups are in the color panel
				sliderSelector.add(i,getSliderName(range.name),range);
			}
			
		}
		
		public function sliderChanged(evt:ScrollEvent) {
			var range:RangeData = evt.currentTarget.data as RangeData;
			player.setScale(range.name,evt.percent,range.type);
			
		}
	}
	
}