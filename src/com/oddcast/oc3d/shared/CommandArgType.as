package com.oddcast.oc3d.shared
{
	public class CommandArgType extends Enum
	{
		public function CommandArgType(id:uint) { super(id); }
		
		public static const NumberArg:CommandArgType = new CommandArgType(1);
		public static const StringArg:CommandArgType = new CommandArgType(2);
		public static const FunctionArg:CommandArgType = new CommandArgType(3);
		public static const ColorArg:CommandArgType = new CommandArgType(4);
		
		public static function forEachEnum(fn:Function):void
		{
			fn(NumberArg);
			fn(StringArg);
			fn(FunctionArg);
			fn(ColorArg);
		}
		
		public static function fromId(id:uint):CommandArgType 
		{
			if (id == 1)
				return NumberArg;
			else if (id == 2)
				return StringArg;
			else if (id == 3)
				return FunctionArg;
			else if (id == 4)
				return ColorArg;
			else
				throw new Error("unknown command arg type");
		}
		
		public function toReferringType():Class
		{
			if (id == 1)
				return Number;
			else if (id == 2)
				return String;
			else if (id == 3)
				return Function;
			else if (id == 4)
				return Color;
			else
				throw new Error("unknown command arg type");
		}
		
		public function toString():String
		{
			if (id == 1)
				return "Number";
			else if (id == 2)
				return "String";
			else if (id == 3)
				return "Function<>:void";
			else if (id == 4)
				return "Color";
			else
				throw new Error("unknown command arg type");
		}
		
		public static function fromName(name:String):CommandArgType
		{
			if (name == "Number")
				return NumberArg;
			else if (name == "String")
				return StringArg;
			else if (name == "Function<>:void")
				return FunctionArg;
			else if (name == "Color")
				return ColorArg;
			else
				throw new Error("unknown command arg type");
		}
	}
}