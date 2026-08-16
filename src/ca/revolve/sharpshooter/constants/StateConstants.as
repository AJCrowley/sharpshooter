package ca.revolve.sharpshooter.constants
{
	public class StateConstants
	{
		// default state ID for our base class
		public static const BASE:String = "stateBase";
		
		// default actor states
		public static const IDLE:String = "stateIdle";
		public static const ACTION:String = "stateAction";
		public static const REST:String = "stateRest";
		
		// default player states
		public static const WAIT:String = "playerStateWaiting";
		public static const AIM:String = "playerStateAim";
		public static const SHOOT:String = "playerStateShoot";
		
		// default puck states
		public static const STILL:String = "puckStill";
		public static const MOVING:String = "puckMoving";
	}
}