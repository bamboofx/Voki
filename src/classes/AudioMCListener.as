//import EngineSound;

class AudioMCListener
{
	private var callbackObj:Object;
	private var loadingTimeLeft:Number;
	private var audioLength:Number;
	private var avgSpeed:Number;
	private var loadingTimeStart:Number;
	private var deltaTime:Number;
	private var deltaBytes:Number;
	private var lastTime:Number;
	private var lastByte:Number = 0;
	private var audioFPS:Number;
	private var audioTimeReady:Number;
	private var audioLoadedBroadcasted:Boolean = false;
	private var safeLoadPercent:Number = 0.2; //20 percent
	private var _engineSoundRef:Object;
	
	function AudioMCListener(cb:Object,FPS:Number)
	{
		//trace("AudioMCListener()")
		_engineSoundRef = cb;
		audioFPS = FPS>0?FPS:12;
		audioLength = 0;
		
	}
	
	public function onLoadStart(target_mc:MovieClip)
	{
		//trace("-------- onLoadStart "+target_mc)
		loadingTimeStart = lastTime = getTimer();
		
		//callbackObj.audioLoadStarted(target_mc);
	}
	
	public function onLoadInit(target_mc:MovieClip)
	{
		//trace("AudioMCListener::onLoadInit "+target_mc);
		//trace("time elapsed for loading ="+((lastTime-loadingTimeStart)/1000))
		if (!audioLoadedBroadcasted)
		{
			_engineSoundRef.loadingDone(target_mc);
			//callbackObj.audioLoaded(target_mc);
		}
		
	}
	
	public function onLoadError(target_mc:MovieClip, errorCode:String, httpStatus:Number)
	{
		//trace("AudioMCListener::onLoadError "+target_mc+" "+errorCode+" "+httpStatus);
		_engineSoundRef.soundError(target_mc,errorCode+"("+String(httpStatus)+")");//soundError(target_mc,errorCode+"("+String(httpStatus)+")");
		//callbackObj.audioLoadError(target_mc, errorCode)
	}
	
	public function onLoadProgress(target_mc:MovieClip, bloaded:Number, btotal:Number)
	{
		if (audioLoadedBroadcasted)
		{
			return;
		}
		if (audioLength==0)
		{
			loadingTimeLeft = audioLength = (target_mc._totalframes/audioFPS);
		}
		deltaTime = ((getTimer()-lastTime)/1000);
		deltaBytes = bloaded-lastByte;
		avgSpeed = (deltaBytes/deltaTime)
		loadingTimeLeft = (btotal-bloaded)/avgSpeed;
		audioTimeReady = target_mc._framesloaded>0?target_mc._framesloaded/audioFPS:0;
		//trace("AudioMCListener::onLoadProgress "+bloaded+" of "+btotal);
		//avgSpeed="+avgSpeed+", loadingTimeLeft="+loadingTimeLeft+", audioTimeReady="+audioTimeReady+" lip_string ready? "+(target_mc.lip_string.length>0));
		//if we have enough to play and we have the lipdata already sure start playing
		if (loadingTimeLeft<=(audioTimeReady-(safeLoadPercent*audioLength)) && target_mc.lip_string.length>0)
		{
			audioLoadedBroadcasted = true;
			//trace("AudioMCListener::onLoadProgress loaded enough to play loadingTimeLeft="+loadingTimeLeft+" audioTimeReady="+audioTimeReady);
			_engineSoundRef.loadingDone(target_mc);
			//callbackObj.audioLoaded(target_mc);
			//trace("************ ready to play")
		}
		/*
		trace("deltaTime:	"+deltaTime);
		trace("bytesLoaded:	"+bloaded);
		trace("bytesTotal:	"+btotal);
		
		trace("audioTimeReady:	"+audioTimeReady);
		trace("loadingTimeLeft:	"+loadingTimeLeft);
		trace("audioLength:	"+audioLength);
		trace("avgSpeed:	"+avgSpeed);
		*/
		lastTime = getTimer();
		lastByte = bloaded;
		
	}
}