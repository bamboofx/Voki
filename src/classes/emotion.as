import emotions.emotionMap;

class emotion{

	private static var listeners:Array = new Array();
	private static var index:Number = 0;
	private static var map:Array = emotionMap.getMap();
	private static var interval:Number;


	public static function destroy(){
		//trace("emotion destroy");
		for (var n:Number = 0; n < listeners.length; ++n){
			listeners[n].gotoAndStop("position1");
			listeners[n].setEmotion(0)
		}
		//trace("---CLEAR INTERVAL---  destroy function");
		clearInterval(interval);
		delete interval;
		//trace("interval = "+interval);
	}

	public static function getEmotion(emo:String):Object{
		return map[emo];

	}

	public static function registerListener(m:MovieClip){
		listeners.push(m);
		//trace(" new emo listener "+m+"   len = "+listeners.length);
		//trace("listeners = "+listeners);
		//if (interval == undefined){
			//interval = setInterval(this, "emote", 2000, new Array("normal", "happy", "sad", "angry", "thinking", "surprised"));
		//}
		//trace(interval);
	}

	public static function removeListener(m:MovieClip):Boolean{
		for (var i = 0; i<listeners.length; ++i){
			if (m== listeners[i]){
				listeners.splice(i,1);
				return true;
			}
		}
		return false;
	}

	public static function startSequence(ar:Array, tm:Number){
		index = 0;
		if (!(tm>0)){
			tm = 0;
		}else{
			//trace("emotion -- adjust  index = "+ar[index].eTime+"  tm = "+tm+"  length = "+ar.length);
			while(ar[index].eTime < tm && index<ar.length){
				++index;
			}
			--index;
		}
		//trace("emotion -- start interval  index = "+index);
		if (interval == undefined) interval = setInterval(emotion.playEmotionSequence, 10, ar, getTimer(), tm);

	}

	public static function freeze(){
		clearInterval(interval);
		delete interval;
	}

	public static function resume(){

	}

	public static function emote(eType){
		//trace("emote function  eType = "+eType);
		var o:Object = map[eType];
		for (var i in o.def){
			for (var n:Number = 0; n < listeners.length; ++n){
				if (String(listeners[n]._name).indexOf(i) != -1){
					listeners[n].gotoAndStop("position"+o.def[i]);
					//trace("				emote   i= "+i+"  listener= "+listeners[n]+"   goto  "+"position"+o.def[i]);
					listeners[n].setEmotion(eType);
				}
			}
		}
	}

	public static function playEmotionSequence(ar:Array, st:Number, offset:Number){
		//trace("--- EMOTE index = "+index+"  ar = "+ar);
		var t:Number = ((getTimer() - st)/1000)+offset;
		//trace("--- EMOTE index = "+index+"  time = "+t);
		if (t > ar[index].eTime){
			emote(ar[index].eType);
			if (++index > ar.length){
				//trace("---CLEAR INTERVAL---  no emotions left");
				clearInterval(interval);
				delete interval;
			}
		}
	}

}