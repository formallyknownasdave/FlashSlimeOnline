package  
{
	
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import mx.utils.StringUtil;
	import net.flashpunk.Entity;
	import net.flashpunk.FP;
	import net.flashpunk.graphics.Image;
	import net.flashpunk.transition.effects.FadeIn;
	import net.flashpunk.transition.effects.FadeOut;
	import net.flashpunk.transition.Transition;
	import net.flashpunk.utils.Input;
	import playerio.Connection;
	import playerio.DatabaseObject;
	import playerio.PlayerIO;
	import playerio.QuickConnect;
	
	import net.flashpunk.graphics.Text;
	import net.flashpunk.graphics.Tilemap;
	import net.flashpunk.Mask;
	import net.flashpunk.masks.Grid;
	import flash.events.Event;
	import net.flashpunk.utils.Key;
	import net.flashpunk.World;
	import playerio.Message;
	import XML;
	/**
	 * ...
	 * @author 
	 */
	public class Level extends World
	{
		private var xml:XML;
		private var slimes:Object = {};
		public var gravity:Number = 0.25;
		public var message:Text;
		public var mainSlime:BaseSlime;
		public var points:Array = new Array();
		private static var fps:Text = new Text("", 10, 10, { size:"10", font:"arial bold", color:0x0000FF, outline:true } );
		public function Level(data:String) 
		{
			super();
			xml = new XML(data);
			addGraphic(fps);
			fps.scrollX = 0;
			fps.scrollY = 0;
			message = new Text("", 0,0, { size:"14", color:0x00CC00, alpha:0,outline:true,embed:true } );
			message.relative = false;
			message.scrollX = message.scrollY = 0;
			message.x = FP.halfWidth;
			message.y = FP.halfHeight;
			addGraphic(message, -99, 0, 0);
			if (Main.connection != null) {
				Main.connection.addMessageHandler("InitPlayers", function(m:Message) { 
					trace("Message: InitPlayers");
					for (var i:int = 0; i < m.length / 4; i++)
					{
						if ( m.getInt(i * 4 + 1) == mainSlime.id)
							continue;
						var s:OtherSlime = new OtherSlime(m.getString(i * 4), m.getInt(i * 4 + 1), m.getInt(i * 4 + 2), m.getInt(i * 4 + 3));
						add(s);
						slimes[s.id] = s;
						trace("Initial Player: ", s.username,"(",s.id,")");
					}
				} );
				Main.connection.addMessageHandler("UpdatePosition", function(m:Message) {
					if (m.getInt(0) == mainSlime.id) return;
					trace("Updating position of ", slimes[m.getInt(0)].username);
					slimes[m.getInt(0)].x = m.getInt(1);
					slimes[m.getInt(0)].y = m.getInt(2);
				} );
				Main.connection.addMessageHandler("UpdateKey", function(m:Message) {
					if (m.getInt(0) == mainSlime.id) return;
					(slimes[m.getInt(0)] as OtherSlime).updateKey(m.getInt(1),m.getBoolean(2));
				} );
				Main.connection.addMessageHandler("UserJoined", function(m:Message) {
					if (m.getInt(1) == mainSlime.id) return;
					var s:OtherSlime = new OtherSlime(m.getString(0), m.getInt(1), m.getInt(2), m.getInt(3));
					add(s);
					slimes[s.id] = s;
					trace("Player has joined: ", s.username);
				} );
				Main.connection.addMessageHandler("UserLeft", function(m:Message) {
					trace("Player has left: ", slimes[m.getInt(0)].username);
					remove(slimes[m.getInt(0)]);
					delete slimes[m.getInt(0)];
				} );
				Main.connection.addMessageHandler("ChangeRoom", function(m:Message) {
					trace("Switching to room: ", m.getString(0));
					trace(m.getString(0));
					
					Transition.to(new LevelLoader(m.getString(0),new FadeOut( { duration:5 } ),-1,-1), new FadeIn( { duration:20 } ),new FadeOut( {} ));
				} );
			}
		}
		public function addSlime(slime:BaseSlime)
		{
			add(slime);
			slimes[slime.id] = slime;
			if (slime is PlayerSlime)
				mainSlime = slime;
		}
		public function removePoint(id:int)
		{
			trace("Adding ", id, " to array");
			points.push(id);
		}
		public function showMessage(message:String,color:uint = 0x00CC00):void
		{
			this.message.text = message;
			this.message.alpha = 1;
			this.message.color = color;
			this.message.update();
			this.message.originX = this.message.textWidth / 2;
			this.message.originY = this.message.textHeight / 2;
		}
		public function hideMessage():void
		{
			this.message.alpha = 0;
		}
		public function set_player(x:int, y:int):void
		{
			if (mainSlime == null)
				addSlime(new PlayerSlime("Dave", 1, x, y));
			else
			{
				mainSlime.x = x;
				mainSlime.y = y;
			}
		}
		public override function begin():void
		{
			for each (var layer:XML in xml.child("*"))
			{
				var map:Tilemap;
				if (!layer.hasOwnProperty("@tileset"))
					continue;
				map = Assets.get_tileset(layer.@tileset);
				map.loadFromString(layer);
				addGraphic(map,1);
			}
			Assets.playSong(StringUtil.trim(xml.@music))
			
			FP.screen.color = 0x568BCE;
			add(new PointCounter());
			add(new SolidBlock(xml));
			add(new JTSolidBlock(xml));
			add(new SemiSolidBlock(xml));
			
			var block:XML;
			trace("Loading points");
			for each (block in xml.obj_layer0.slime_point)
			{
				if (points.indexOf(int(block.@id)) == -1) {
					trace("Point ", block.@id,",",block.@x,",",block.@y);
					add(new SlimePoint(int(block.@id), block.@x, block.@y));
				}else
					trace("Already got ", block.@id);
			}
			for each (block in xml.obj_layer0.moving_block)
				add(new MovingBlock(block.@x, block.@y, block.@width, block.@height, block.@hspeed, block.@vspeed));
			for each (block in xml.obj_layer0.push_block)
				add(new PushBlock(block.@x, block.@y, block.@width, block.@height));
			for each (block in xml.obj_layer0.door)
				add(new Door(block));
			if (mainSlime == null)
			{
				for each (block in xml.obj_layer0.Slime)
					addSlime(new PlayerSlime("Dave", 1, block.@x, block.@y));
			}
		}
		public override function update():void
		{
			super.update();
			fps.text = "FPS: " + FP.frameRate;
			if (mainSlime != null) {
				var door:Entity = mainSlime.collide("door", mainSlime.x, mainSlime.y);
				if (door)
					showMessage((door as Door).message);
				else
					hideMessage();
				while (mainSlime.x - FP.camera.x < 150 && FP.camera.x > 0)
					FP.camera.x --;
				while (mainSlime.y - FP.camera.y < 70 && FP.camera.y > 0)
					FP.camera.y --;
				while (mainSlime.x - FP.camera.x > 250 && FP.camera.x < xml.@width - 400)
					FP.camera.x ++;
				while (mainSlime.y - FP.camera.y > 170 && FP.camera.y < xml.@height - 240)
					FP.camera.y ++;
			}
		}
		public override function end():void
		{
			for each(var s:BaseSlime in slimes)
				s.removed();
			if (Main.connection != null) {
				trace("ENDING CONNECTION");
				Main.connection.disconnect();
			}
			Assets.stopSong();
		}
	}
}