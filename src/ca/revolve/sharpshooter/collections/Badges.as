package ca.revolve.sharpshooter.collections
{
	import ca.revolve.sharpshooter.elements.Badge;

	public class Badges
	{
		public var badges:Vector.<Badge>;
		
		public function Badges()
		{
			badges = new Vector.<Badge>;
		}
		
		public function get length():uint
		{
			return badges.length;
		}
		
		public function getAwardedBadges():Vector.<String>
		{
			// create emptys string vector for return
			var result:Vector.<String> = new Vector.<String>();
			// get awarded badges
			var unlockedBadges:Vector.<Badge> = awardedBadges();
			// and push the ID of each one into our return vector
			for each(var badge:Badge in unlockedBadges)
			{
				result.push(badge.id);
			}
			// send it back
			return result;
		}
		
		private function awardedBadges():Vector.<Badge>
		{
			// prepare result vector
			var result:Vector.<Badge> = new Vector.<Badge>();
			var uniqueBadges:Vector.<String> = new Vector.<String>();
			var badgeUnlocked:Boolean = false;
			// get unique badge IDs
			for each(var badge:Badge in badges)
			{
				if(uniqueBadges.indexOf(String(badge.id)) < 0)
				{
					uniqueBadges.push(badge.id);
				}
			}
			// go through each unique badge ID
			for each(var badgeId:String in uniqueBadges)
			{
				// filter badges down to just current badge
				var currentBadge:Vector.<Badge> = badges.filter
				(
					function(element:int, index:int, badges:Vector.<Badge>):Boolean
					{
						return badges[index].id == badgeId;
					}
				);				// default to unlocked
				badgeUnlocked = true;
				// loop through
				for each(badge in currentBadge)
				{
					// if not activated
					if(!badge.activated)
					{
						// badge has not been unlocked
						badgeUnlocked = false;
						break;
					}
				}
				if(badgeUnlocked)
				{
					// push to result vector if still unlocked
					result.push(badge);
				}
			}
			return result;
		}
	}
}