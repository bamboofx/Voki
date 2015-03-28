import EngineV3;
class MouseController extends com.oddcast.event.BroadcastingMovieClip
{
	private var _nMouseInt:Number;
	private var _engine:EngineV3;
	private var _bMouseMode:Boolean;
	private var counter:Number;
	private var last_x:Number = 0, last_y:Number = 0;	
	private var breathCount:Number = 0;
	
	
	
	public function stopMouseFollow():Void
	{
		clearInterval(_nMouseInt);
	}
	
	public function startMouseFollow(rate:Number):Void
	{
		//trace("MouseController::startMouseFollow ");
		clearInterval(_nMouseInt);
		_nMouseInt = setInterval(this,"doMouseFollow",rate);
	}
	
	public function doMouseFollow():Void
	{
		if (getVersion().indexOf("MAC") != -1)
		// This is a fix for bug on the MAC. Clicking anywhere on the desktop was returning very large or very small values
		//to the flash player and causing the host to look all around and jerk it's head and eyes. If click are received
		// that are >< 10000 the mouse follow mode is deactivated.
		{
			var pt:Object = {x:_xmouse, y:_ymouse};
			this.localToGlobal(pt);
			if (Math.abs(pt.x)>10000 || Math.abs(pt.y)>10000)
			{
				_bMouseMode = _engine.g_mouseMode;
				_engine.g_mouseMode = false;
				return;
			}
			else
			{
				_engine.g_mouseMode = _bMouseMode;
			}
		}
		
		if (_engine.is_Gazing==1)
		{
			counter = 0;
			_engine.getLookCount();			
		}
		else if (Math.abs(last_x - _engine.model._xmouse)>5 || Math.abs(last_y - _engine.model._ymouse)>5)
		{
			counter = 0;
			if (_engine.initiated>3)
			{
				//trace("MouseController:: _engine.MouseMode="+_engine.MouseMode);
				if (_engine.MouseMode)
				{
					_engine.setMouseFollow(true);
				}
			}
			_engine.speed = 8;
			_engine.mouseMoved();
			update();						
		}
		else if ((counter++ > 40) && _engine.MouseMode)
		{
			counter = 0;
			_engine.recenter();
			update();
		}
		//trace("_engine.breath="+_engine.breath);
		if (breathCount++ > 2)
		{
			breathCount = 0;
			_engine.breathe();
		}
		_engine.initiated++;
	}
	
	public function update():Void
	{
		last_x = _engine.model._xmouse;
		last_y = _engine.model._ymouse;
	}
	
	public function onLoad():Void
	{
		_engine = EngineV3(_parent);
	}
	
	public function onUnload():Void
	{
		clearInterval(_nMouseInt);
	}
}