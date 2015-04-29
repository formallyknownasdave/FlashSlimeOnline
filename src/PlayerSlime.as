package  
{
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.SetIntervalTimer;
	import net.flashpunk.transition.Transition;
	import net.flashpunk.transition.effects.CircleIn;
	import net.flashpunk.transition.effects.CircleOut;
	import net.flashpunk.transition.effects.FadeIn;
	import net.flashpunk.transition.effects.FadeOut;
	import flash.utils.Timer;
	import net.flashpunk.Entity;
	import net.flashpunk.FP;
	import net.flashpunk.utils.Input;
	import net.flashpunk.utils.Key;
	/**
	 * ...
	 * @author 
	 */
	public class PlayerSlime extends BaseSlime
	{
		private var time:Timer = new Timer(3000,0);
		public function PlayerSlime(username:String,id:int,x:int,y:int) 
		{
			super(username, id, x, y);
			time.addEventListener(TimerEvent.TIMER, updatePosition);
			time.start();
		}
		public function updatePosition(e:Event)
		{
			if (Main.connection != null && Main.connection.connected)
			{
				Main.connection.send("UpdatePosition", x, y);
				trace("Updatin: " + time.currentCount);
			}
		}
		public override function update():void
		{
			keyLeft = Input.check(Key.LEFT) || (Input.mouseDown && Input.mouseX < FP.stage.stageWidth/2 && Input.mouseY > FP.stage.stageHeight / 2);
			keyRight = Input.check(Key.RIGHT) || (Input.mouseDown && Input.mouseX > FP.stage.stageWidth/2 && Input.mouseY > FP.stage.stageHeight / 2);
			keyDown = Input.check(Key.DOWN);
			keyUp = Input.pressed(Key.UP) || (Input.mouseDown && Input.mouseY < FP.stage.stageHeight / 2);
			var door:Door = collide("door", x, y) as Door;
			if (door && (Input.pressed(Key.ENTER) || !door.prompt))
			{
				trace("Switching rooms via door to " + door.target);
				Transition.to(new LevelLoader(door.target,door.transitionOut,door.targetX,door.targetY),door.transitionIn,new FadeOut());
				this.active = false;
				
			}
			if (Main.connection != null && Main.connection.connected) {
				if (Input.pressed(Key.LEFT) || (Input.mousePressed && Input.mouseX < FP.stage.stageWidth/2 && Input.mouseY > FP.stage.stageHeight / 2))
					Main.connection.send("UpdateKey", 0, true);
				else if (Input.released(Key.LEFT) || (Input.mouseReleased && Input.mouseX < FP.stage.stageWidth/2 && Input.mouseY > FP.stage.stageHeight / 2))
					Main.connection.send("UpdateKey", 0, false);
				if (Input.pressed(Key.RIGHT) || (Input.mousePressed && Input.mouseX > FP.stage.stageWidth/2 && Input.mouseY > FP.stage.stageHeight / 2))
					Main.connection.send("UpdateKey", 1, true);
				else if (Input.released(Key.RIGHT) || (Input.mouseReleased && Input.mouseX > FP.stage.stageWidth/2 && Input.mouseY > FP.stage.stageHeight / 2))
					Main.connection.send("UpdateKey", 1, false);
				if (Input.pressed(Key.UP) && Input.mouseY < FP.stage.stageHeight / 2)
					Main.connection.send("UpdateKey", 2, true);
				if (Input.pressed(Key.DOWN))
					Main.connection.send("UpdateKey", 3, true);
				else if (Input.released(Key.DOWN))
					Main.connection.send("UpdateKey", 3, false);
				if (door && Input.pressed(Key.ENTER))
					Main.connection.send("Door", (door as Door).target);
			}
			super.update();
		}
		public override function removed():void 
		{
			trace("DELETING SLIME");
			time.removeEventListener(TimerEvent.TIMER, updatePosition);
			time.stop();
			super.removed();
		}
	}

}