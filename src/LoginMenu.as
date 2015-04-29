package  
{
	import flash.sampler.NewObjectSample;
	import net.flashpunk.FP;
	import net.flashpunk.graphics.Text;
	import net.flashpunk.transition.effects.FadeIn;
	import net.flashpunk.transition.effects.FadeOut;
	import net.flashpunk.transition.Transition;
	import net.flashpunk.utils.Input;
	import net.flashpunk.utils.Key;
	import net.flashpunk.World;
	import playerio.Client;
	import playerio.DatabaseObject;
	import playerio.PlayerIO;
	import playerio.PlayerIOError;
	/**
	 * ...
	 * @author 
	 */
	public class LoginMenu extends World
	{
		private var username:TextBox = new TextBox(false, "Username", 16, 50);
		private var password:TextBox = new TextBox(false, "********", 16, 100);
		public function LoginMenu()
		{
			FP.screen.color = 0x00EEEE;
			addGraphic(new Text("David is lazy, so press B to login as Ben,\n and D to login as Dave", 0, 0, { size:"12",embed:true, color:0xFFFFFF, outline:true } ), 0, 16, 16);
			Transition.to(new LevelLoader("level0"), new FadeIn( { duration:20 } ),new FadeOut( { duration:5 } ));//SKIP LOGIN
			//add(username);
			//add(password);
		}
		public override function update():void
		{
			if (Input.pressed(Key.B) || Input.pressed(Key.D) || Input.mousePressed)
			{
					addGraphic(new Text("Clicked.", 0, 0, { size:"12",embed:true, color:0x0000FF, outline:true } ), 0, 16, 50);
				var username:String = "Ben";
				if (Input.pressed(Key.D) || Input.mousePressed)
					username = "Dave";
				PlayerIO.quickConnect.simpleConnect(FP.stage, "slime-online-vfmizlp35uacecktxbcoa",username, "password",function(client:Client) {
					client.bigDB.loadMyPlayerObject(function(o:DatabaseObject) {
						Transition.to(new LevelLoader(o.map), new FadeIn( { duration:20 } ),new FadeOut( { duration:5 } ));
					});
					trace('Connected to Player.io');
					Main.client = client; 
					//client.multiplayer.developmentServer = "localhost:8184";
				},function(e:PlayerIOError) {
					addGraphic(new Text("Can't connect, sucks man.", 0, 0, { size:"12",embed:true, color:0xFF0000, outline:true } ), 0, 16, 50);
				});
			}
		}
	}

}