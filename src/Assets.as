package 
{
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.net.URLLoader;
	import flash.sampler.NewObjectSample;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;
	import net.flashpunk.transition.Transition;
	import net.flashpunk.utils.Draw;
	import mx.utils.StringUtil;
	
	/**
	 * ...
	 * @author 
	 */
	public class Assets 
	{
		/*
		 * compc -source-path . src -include-classes Assets -output test.swc
		 * */
		import neoart.flod.core.CorePlayer;
        import neoart.flod.FileLoader;
        import flash.utils.ByteArray;

		[Embed(source = "../assets/image/base.png")]
		public static const SPR_SLIME:Class;
		
		[Embed(source = "../assets/image/kirby.png")]
		public static const SPR_KIRBY:Class;
		
		[Embed(source = "../assets/image/slime_point.png")]
		public static const SPR_SLIME_POINT:Class;
		
		[Embed(source = "../assets/image/slime_point_glow.png")]
		public static const SPR_SLIME_POINT_GLOW:Class;
		
		public static const PART_CIRCLE:BitmapData = new BitmapData(20, 20,true);
		
		[Embed(source = "../assets/level/level0.oel", mimeType = "application/octet-stream")]
		public static const LVL_LEVEL0:Class;
		[Embed(source = "../assets/level/level1.oel", mimeType = "application/octet-stream")]
		public static const LVL_LEVEL1:Class;
		[Embed(source = "../assets/level/level2.oel", mimeType = "application/octet-stream")]
		public static const LVL_LEVEL2:Class;
		[Embed(source = "../assets/level/level3.oel", mimeType = "application/octet-stream")]
		public static const LVL_LEVEL3:Class;
		
		[Embed(source = "../assets/level/slope_top_right.png")]
		public static const MSK_SLOPE_TOP_RIGHT:Class;
		[Embed(source = "../assets/level/slope_top_left.png")]
		public static const MSK_SLOPE_TOP_LEFT:Class;
		[Embed(source = "../assets/level/slope_bottom_right.png")]
		public static const MSK_SLOPE_BOTTOM_RIGHT:Class;
		[Embed(source = "../assets/level/slope_bottom_left.png")]
		public static const MSK_SLOPE_BOTTOM_LEFT:Class;
		
		[Embed(source = "../assets/sound/slime_point.mp3")]
		public static const SND_SLIME_POINT:Class;
		[Embed(source = "../assets/sound/jump.mp3")]
		public static const SND_JUMP:Class;
		
		public static var player:CorePlayer = null,
						  stream:ByteArray,
						  flodisplaying:Boolean;
		public static var levelList:Dictionary = new Dictionary();
		public static var musicList:Dictionary = new Dictionary();
		public static var tileList:Dictionary = new Dictionary();
		public static var playingSong:String = "";
		public function Assets() 
		{
			Draw.setTarget(PART_CIRCLE);
			Draw.circle(10, 10, 2, 0xFF0000);
			
		}
		public static function add(id:String, url:String):void
		{
			var loader:URLLoader = new URLLoader(new URLRequest(url));
			loader.addEventListener(Event.COMPLETE, function(e:Event) {
				levelList[id] = e.target.data;
				trace("Loaded: " + id);
				});
		}
		public static function playSong(song:String):void
		{
			for (var key:* in musicList) {
				trace(key);
				if (key != song)
					trace(key + "!=" + song);
				else
					trace(key + "==" + song);
			}
			if (musicList[song] != null)
			{
				var loader:FileLoader = new FileLoader();
				stream = musicList[song];
				if (player != null)
					player.stop();
				player = loader.load(stream);
				player.play();
			}
			else
			{
				trace("Couldn't find song " + song);
				trace(musicList);
				playingSong = song;
			}
		}
		public static function load_assets():void
		{
			var loader:URLLoader = new URLLoader(new URLRequest("assets/resources.xml"));
			loader.addEventListener(Event.COMPLETE, function(e:Event) {
				trace("Found assets xml");
				var xml:XML = new XML(e.target.data);
				for each (var block:XML in xml.music)
				{
					(function() {
						var id:String = StringUtil.trim(block.@id);
						var musicLoader:URLLoader = new URLLoader(new URLRequest("assets/music/" + block));
						musicLoader.addEventListener(Event.COMPLETE, function(e:Event) {
							musicList[id] = e.target.data as ByteArray;
							trace("Loaded song " + id);
						});
					}).apply();
				}
				for each (var block:XML in xml.tileset)
				{
					(function() {
						var id:String = StringUtil.trim(block.@id);
						var tileLoader:URLLoader = new URLLoader(new URLRequest("assets/image/" + block));
						tileLoader.addEventListener(Event.COMPLETE, function(e:Event) {
							tileList[id] = e.target.data as ByteArray;
							trace("Loaded tile " + id);
						});
					}).apply();
				}
			});
		}
		public static function load_level(id:String,success:Function,failure:Function):void
		{		
			if (levelList[id] != null)
				success(levelList[id]);
			var loader:URLLoader = new URLLoader(new URLRequest("assets/level/"+id+".oel"));
			loader.addEventListener(Event.COMPLETE, function(e:Event) {
				levelList[id] = e.target.data;
				success(e.target.data);
				trace("Loaded: " + id);
				});
			loader.addEventListener(IOErrorEvent.IO_ERROR, function(e:Event) {
				failure();
				});
		}
		public static function load(id:String):*
		{
			return levelList[StringUtil.trim(id)];
		}
		public static function get_tileset(id:String):*
		{
			return tileList[StringUtil.trim(id)];
		}
		public static function loaded(id:String):Boolean
		{
			return levelList[id] != null;
		}
		public static function stopSong():void
		{
			//player.stop();
		}
		
	}

}