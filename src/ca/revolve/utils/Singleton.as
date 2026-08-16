/*
	Singleton base class
	kris.mccann@revolve.ca
	extend to enforce singleton style behaviour in a class
	extend Singleton in your class, then instantiate with:
	yourClass:YourClass = Singleton.getInstance(YourClass) as YourClass;
*/

package ca.revolve.utils
{
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	public class Singleton
	{
		private static var instances:Dictionary = new Dictionary();
		
		public function Singleton()
		{
			var className:String = getQualifiedClassName(this);
			var classObj:Class = getDefinitionByName(className) as Class;
			if(classObj == Singleton)
			{
				throw("Singleton is a base class that cannot be instantiated");
			}
			var instance:Object = instances[classObj];
			if(instance != null)
			{				
				throw("Classes extending Singleton can only be instantiated once by the getInstance method");				
			}
			else
			{				
				instances[classObj] = this;				
			}
		}
		
		public static function getInstance(classObj:Class):Object			
		{			
			var instance:Object = instances[classObj];			
			if(instance == null)
			{
				instance = Object(new classObj());
				var singleton:Singleton = instance as Singleton;				
				if(singleton == null)
				{					
					throw("getInstance can only be called for Classes extending Singleton");					
				}				
			}			
			return instance;			
		}
	}
}