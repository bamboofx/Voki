/**
* ...
* @author Sam
* @version 0.1
* 
* Movieclip which contains webcam output
* 
* METHODS:
* 
* init(w,h,useDefault) - create webcam window. 
*	w - width of video and webcam
*	h - height of video and webcam
*	useDefault - (boolean) use the user's default camera (true) or use the approved camera list (false/default)
* setWebcamMode($w, $h, $favorArea, $setVideo) - set the area of the web camera
* setVideo($w, $h) - set the video display size
* capture() - capture still image from webcam
* clear() - clear still image
* activate(b) - activate/disactivate webcam.
* getJPG() - returns captured still image as jpeg-encoded ByteArray
* destroy() - destroys object and frees memory, listeners
* 
* PROPERTIES:
* activated - camera is allowed by user
* cameraAvailable - returns true if there is a camera on your machine.  returns true even if the camera isn't on the
* list of approved cameras
* cameraNames - returns a list of cameras set up on your machine
* 
* EVENTS:
* Event.ACTIVATE - camera dispatches this event when you move around in front of the camera
* Event.DEACTIVATE - camera dispatches this event when you stop moving around in front of the camera
*/

package com.oddcast.utils {

	import flash.display.*;
	import flash.events.*;
	import flash.geom.Matrix;
	import flash.media.*;
	import flash.system.*;
	import flash.utils.ByteArray;
	
	//import mx.controls.TextArea;

	public class Webcamera extends MovieClip {
		
		private const defaultMacCamera:String = "USB Video Class Video";
		private const MacOSSignature:String = "Mac";
		
		public var webcam:Camera;   // needs to be public for Augmented Reality
		public var vid:Video;		// needs to be public for Augmented Reality
		protected var vidHolder:Sprite;
		
		
		private var allowedCameras:Array;
		private var isAvailable:Boolean=false;
		//public var area:MovieClip;
		private var _cameraNames:Array;
		private var _useDefault:Boolean = false;
		private const DEFAULT_FPS:Number = 15.0;
		
		public function Webcamera() 
		{
			//trace("((WEBCAMERA == construtor ------)) ");
			allowedCameras = new Array("webcam", 
										"Integrated Camera", 
										"Creative Webcam Vista Plus", 
										"Logitech QuickCam Fusion", 
										"Logitech QuickCam Pro 5000", 
										"Logitech QuickCam Pro 4000", 
										"Logitech QuickCam Express", 
										"Logitech QuickCam Easy", 
										"Logitech QickCam Pro 9000");
		}
		
		public function init($width:Number, $height:Number, $useDefault:Boolean = false, $fps:Number=DEFAULT_FPS, $favorArea:Boolean = true):Boolean 
		{
			_useDefault = $useDefault;
			isAvailable = false;
			//isAllowed = false;
			_cameraNames = [];
			webcam = Camera.getCamera();
			if (webcam == null) 
			{
				//if (_useDefault)
				//{
				//	throw new Error("WebcamCapture Error -- There is no web camera to use.");
				//}
				return false;
			}
			else isAvailable = true;
			if (!_useDefault)
			{
				_cameraNames = [webcam.name];
				if (!isAllowed(webcam.name))
				{
					var hasAllowedCam:Boolean = false;
					_cameraNames = Camera.names;
					for (var i:Number = 0; i < _cameraNames.length; ++i)
					{
						if (isAllowed(String(_cameraNames[i]).toLocaleLowerCase()))
						{
							hasAllowedCam = true;
							webcam = Camera.getCamera(i.toString());
							break;
						}
					}
					if (!hasAllowedCam)
					{
						//webcam.removeEventListener(StatusEvent.STATUS, onStatus);
						//removeChild(vid);
						return false;
					}
					/*else 
					{
						Security.showSettings(SecurityPanel.CAMERA);
					}
					*/
				}
			}
			else
			{
				var t_choose_mac_camera:Boolean = false;
				var t_index:int;
				if (Capabilities.os.search(MacOSSignature) != -1)
				{
					var t_cameras:Array = Camera.names;
					for (t_index = 0; t_index < t_cameras.length; t_index++)
					{
						//trace("Webcamera camera:" + t_index + " " + t_cameras[t_index] + " ,"+defaultMacCamera);
						if (t_cameras[t_index] == defaultMacCamera)
						{
							t_choose_mac_camera = true;
							//trace("Webcamera t_choose_mac_camera:" + t_index.toString() + " " + t_cameras[t_index] + " ,"+defaultMacCamera);
							break;
						}
					}	
				}else {
					//trace("Webcamera Not Mac:" + MacOSSignature);
				}
				if (!t_choose_mac_camera)
				{
					webcam = Camera.getCamera();
				}
				else
				{
					webcam = Camera.getCamera(t_index.toString());
				}
			}
			
			webcam.addEventListener(StatusEvent.STATUS, onStatus, false, 0, true);
			webcam.addEventListener(ActivityEvent.ACTIVITY, onActivity, false, 0, true);
			webcam.setMode($width, $height, $fps);
			webcam.setLoopback(false);   //some cameras hold a memory of this!
			
			vidHolder = new Sprite();
			addChild(vidHolder);
			vid = new Video(webcam.width, webcam.height);
			//vid = new Video();
			vidHolder.addChild(vid);
			//trace("WebcamCapture::init webcam requested size="+$width+","+$height+"  actual size="+webcam.width+","+webcam.height+"   vid size = "+[vid.width,vid.height]+"   vid source = "+[vid.videoWidth,vid.videoHeight]);
			
			vid.attachCamera(webcam);
			/* 
			if (area!=null) {
				area.visible=false;
				vidHolder.width=area.width;
				vidHolder.height=area.height;
				vidHolder.x=area.x;
				vidHolder.y=area.y;
			}
			*/
			
			return true;
		}
		
		public function setWebcamMode($w:int, $h:int, $favorArea:Boolean = true, $setVideo:Boolean = true, $fps:Number=DEFAULT_FPS):void
		{
			//trace("WCC - setMode - w: "+$w+" h: "+$h+" favorArea: "+$favorArea+" resize video: "+$setVideo);
			webcam.setMode($w, $h, $fps, $favorArea);
			if ($setVideo)
			{
				vid.width = $w;
				vid.height = $h;
			}
		}
		
		public function setVideo($w:int, $h:int):void
		{
			vid.width = $w;
			vid.height = $h;
		}
		
		
		
		public function setCamera($cn:String):void
		{
			//trace("SET CAMERA "+$cn);
			Camera.getCamera($cn);
		}
		
		
		
		public function activate(b:Boolean):void 
		{
			if (vid)
				vid.attachCamera(b?webcam:null);
		}

		
		
		public function get activated():Boolean {
			return(!webcam.muted);
		}
		
		public function destroy():void {
			
			if (webcam != null) {
				webcam.removeEventListener(StatusEvent.STATUS, onStatus);
				webcam.removeEventListener(ActivityEvent.ACTIVITY,onActivity);
			}
			if (vid != null) vid.attachCamera(null);
			webcam = null;
			vid = null;
			
			allowedCameras = null;
			//area = null;
		}
		
		private function isAllowed(cam:String):Boolean
		{
			if (cam.toLowerCase().indexOf("usb") != -1) return true;
			for (var i:Number = 0; i < allowedCameras.length; ++i)
			{
				//trace("WEBCAMCAPTURE - IS ALLOWED --- " + String(allowedCameras[i]).toLocaleLowerCase()+ "  pass: " + (String(allowedCameras[i]).toLocaleLowerCase() == cam.toLowerCase()));
				if (String(allowedCameras[i]).toLocaleLowerCase() == cam.toLowerCase())
				{
					return true;
				}
			}
			return false;
		}
		
		//camera callbacks
		
		public function onStatus(evt:StatusEvent):void
		{
			//trace('Webcamera checking status on deny: evt = ', evt, webcam.muted);
			var t_allowed:Boolean = (!_useDefault) ? isAllowed(webcam.name) : true;
			//trace("Webcamera ==  on Status -- code="+evt.code+"  level="+evt.level+"  !isAllowed("+webcam.name+") : "+t_allowed+" webcam: "+webcam+ "activated:"+activated);
			if (evt.code == "Camera.Unmuted" && !t_allowed)
			{
				//trace("Webcamera == pass");
				Security.showSettings(SecurityPanel.CAMERA);
			}
			if (activated) {
				dispatchEvent(new Event(Event.ACTIVATE));
			}
			else dispatchEvent(new Event(Event.DEACTIVATE));
		}
		
		protected function onActivity(evt:ActivityEvent):void
		{
			//trace( 'mihai checking activity event: evt = ',evt);
			//trace("WEBCAMCAPTURE::onActivity  activating=" + evt.activating);
		}
		
		public function get cameraAvailable():Boolean 
		{
			return(isAvailable);
		}
		
		public function get cameraName():String
		{
			return webcam.name;
		}
		
		public function get cameraNames():Array 
		{
			return(_cameraNames);
		}
	}
	
}