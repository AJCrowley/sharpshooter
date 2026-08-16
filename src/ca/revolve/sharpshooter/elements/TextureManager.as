package ca.revolve.sharpshooter.elements
{
	import flash.display.Bitmap;
	import flash.utils.Dictionary;
	
	import starling.display.MovieClip;
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;

	public class TextureManager
	{
		private var texture:Texture;
		private var atlas:TextureAtlas;
		private var movieClip:MovieClip;
		private var textureCache:Dictionary = new Dictionary();
		
		public function TextureManager(spriteSheet:Bitmap, xml:XML)
		{
			// create texture from passed sprite sheet
			texture = Texture.fromBitmap(spriteSheet);
			// generate atlas with XML
			atlas = new TextureAtlas(texture, xml);
		}
		
		public function getMovieClip(textureName:String, frameRate:uint):MovieClip
		{
			// create movieclip from requested texture
			movieClip = new MovieClip(getTexture(textureName), frameRate);
			return movieClip;
		}
		
		public function dispose():void
		{
			// get rid of movie clip
			movieClip.dispose();
			// dispose of current texture
			texture.dispose();
			texture = null;
			// loop through texture cache
			for each(var textures:Vector.<Texture> in textureCache)
			{
				// and dispose of each texture
				for each(texture in textures)
				{
					texture.dispose();
					texture = null;
				}
			}
			textureCache = null;
			// dispose of the atlas
			atlas.dispose();
			atlas = null;
		}
		
		private function getTexture(textureName:String):Vector.<Texture>
		{
			// try to get texture from cache
			var result:Vector.<Texture> = textureCache[textureName];
			// if it wasn't in the cache
			if(!result)
			{
				// then request it from atlas
				result = atlas.getTextures(textureName);
				// and add it to the cache
				textureCache[textureName] = result;
			}
			return result;
		}
	}
}