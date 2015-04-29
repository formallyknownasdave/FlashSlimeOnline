package  
{
	import flash.sampler.NewObjectSample;
	import net.flashpunk.FP;
	import net.flashpunk.graphics.Text;
	import net.flashpunk.transition.effects.Effect;
	import net.flashpunk.transition.effects.Fade;
	import net.flashpunk.transition.effects.FadeIn;
	import net.flashpunk.transition.effects.FadeOut;
	import net.flashpunk.transition.Transition;
	import net.flashpunk.World;
	import playerio.Connection;
	import playerio.Message;
	import playerio.PlayerIOError;
	/**
	 * ...
	 * @author 
	 */
	public class LevelLoader extends World
	{
		private var text:Text = new Text("Loading map...", 0, 0, { size:"14", embed:true, color:0x87f60f, outline:true } );
		private var room:String;
		private var loaded:Boolean = false;
		public function LevelLoader(room:String,transition:Effect,targetX:int,targetY:int) 
		{
			this.room = room;
			Assets.load_level(room,
				function(data:*):void
				{
					var level:Level = new Level(data);
					if (targetX > 0 && targetY > 0)
						level.set_player(targetX, targetY);
					trace("L1");
					Transition.to(level, new FadeIn(), transition);
					trace("L2");
				},
				function():void
				{
					text.text = "IO Error: Failed to load room.";
					text.color = 0xEE0000;
					text.centerOrigin();
				});
		}
		public override function update():void
		{
		}
		public override function begin():void
		{
			if (Main.client != null) {
				Main.client.multiplayer.createJoinRoom(room, "Map", true, { }, { }, function(c:Connection) {
					Main.connection = c;
					trace("NEW ROOM CONNECTION");
					Main.connection.addMessageHandler("Begin", function(m:Message) {
						var level:Level = new Level(Assets.load(room));
						level.addSlime(new PlayerSlime(m.getString(0), m.getInt(1), m.getInt(2), m.getInt(3)));
						for (var i:int = 4; i < m.length; i++ )
							level.removePoint(m.getInt(i));
						Transition.to(level, new FadeIn( { duration:5 } ), new FadeOut( { duration:20 } ));
					});
					Main.connection.addMessageHandler("AlreadyInRoom", function(m:Message) {
						text.text = "USER ALREADY IN DER";
						text.color = 0xEE0000;
						text.centerOrigin();
						trace("USER ALREADY IN DER");
						});
				},function(e:PlayerIOError) {
					text.text = e.message;
					text.color = 0xEE0000;
					text.centerOrigin();
					trace("ERROR ROOM CONNECTION");
				});
			}
			FP.screen.color = 0x000000;
			text.centerOrigin();
			addGraphic(text, 0, FP.halfWidth, FP.halfHeight);
		}
		
	}

}