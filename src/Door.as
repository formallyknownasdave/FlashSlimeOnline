
package
{
	import net.flashpunk.Entity;
	import net.flashpunk.FP;
	import net.flashpunk.graphics.Text;
	import net.flashpunk.transition.effects.Blur;
	import net.flashpunk.transition.effects.Circle;
	import net.flashpunk.transition.effects.CircleIn;
	import net.flashpunk.transition.effects.CircleOut;
	import net.flashpunk.transition.effects.Effect;
	import net.flashpunk.transition.effects.FadeIn;
	import net.flashpunk.transition.effects.FadeOut;
	import net.flashpunk.transition.effects.Flip;
	import net.flashpunk.transition.effects.Pixelate;
	import net.flashpunk.transition.effects.Star;
	import net.flashpunk.transition.effects.StarIn;
	import net.flashpunk.transition.effects.StarOut;
	import net.flashpunk.transition.effects.StripeFade;
	import net.flashpunk.utils.Input;
	import net.flashpunk.utils.Key;
	import net.flashpunk.transition.Transition;
	import mx.utils.StringUtil;
	/**
	 * ...
	 * @author 
	 */
	public class Door extends Entity
	{
		public var message:String,
			target:String,
			transitionIn: Effect = new FadeIn( { duration:5 } ),
			transitionOut:Effect = new FadeOut( { duration:20 } ),
			targetX:int,
			targetY:int,
			prompt:Boolean;
		public function Door(data:XML)
		{
			type = "door";
			super(data.@x, data.@y);
			this.message = StringUtil.trim(data.@message);
			this.prompt = message != "";
			this.target = StringUtil.trim(data.@target);
			this.targetX = data.@targetX;
			this.targetY = data.@targetY;
			this.transitionIn = get_transition(data.@tin,true);
			this.transitionOut = get_transition(data.@tout,false);
			setHitbox(data.@width, data.@height);
		}
		private function get_transition(transition:String, goIn:Boolean):Effect
		{
			var duration:int = goIn ? 5 : 20;
			switch(StringUtil.trim(transition))
			{
				case "blur":
					return new Blur(goIn, { duration:duration } );
				case "flip":
					return new Flip(goIn, { duration:duration } );
				case "pixelate":
					return new Pixelate(goIn, { duration:duration } );
				case "star":
					return goIn ? new StarIn({ duration:duration } ) : new StarOut({ duration:duration });
				case "stripefade":
					return new StripeFade(goIn, { duration:duration } );
			}
			return goIn ? transitionIn : transitionOut;
		}
	}

}