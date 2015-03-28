package com.voki.engine
{
	public dynamic class EngineV5Export extends EngineV5
	{
		
		
		function EngineV5Export():void
		{
			trace("EXPORT ENGINE -- 04.12.10 12:07");
			super();
		}
		
		override protected function validate():Boolean
		{
			//trace("Engine v5 -- validate export");
			return true; //  remove for export and comment next line!!!!
		}
		
	}
}