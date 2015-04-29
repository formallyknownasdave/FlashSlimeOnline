package
{
import flash.display.Loader;
import flash.events.Event;
import flash.net.URLLoader;
import flash.net.URLRequest;
import net.flashpunk.Engine;
import net.flashpunk.Entity;
import net.flashpunk.FP;
import net.flashpunk.graphics.Image;
import net.flashpunk.graphics.Text;
import net.flashpunk.transition.effects.Fade;
import net.flashpunk.transition.effects.FadeIn;
import net.flashpunk.transition.effects.FadeOut;
import net.flashpunk.utils.Input;
import flash.ui.Multitouch;
import flash.ui.MultitouchInputMode;
import playerio.BigDB;
import playerio.Connection;
import playerio.DatabaseObject;
import playerio.PlayerIO;
import playerio.Client;
import playerio.Multiplayer;
import playerio.Message;
import playerio.RoomInfo;
[SWF(width = "400", height = "240")]
	public class Main extends Engine
	{
		public static var connection:Connection = null;
		public static var client:Client = null;
		public function Main()
		{
			super(400, 240, 60, true);
			Multitouch.inputMode = MultitouchInputMode.NONE;
		}
		override public function init():void
		{
			Assets.load_assets();
			//PlayerIO.quickConnect.simpleRegister(FP.stage,"<KEY>","Ben","password","email","","",{},"",function(client:Client) {
			FP.world = new LevelLoader("level0",new FadeOut({duration:20}),-1,-1);
			trace("Loaded first level.");
			//FP.world = new LoginMenu();
			trace("FlashPunk has started successfully!");
		}
	}
}
