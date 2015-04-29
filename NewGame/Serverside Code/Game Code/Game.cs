using System;
using System.Collections.Generic;
using System.Text;
using System.Collections;
using PlayerIO.GameLibrary;
using System.Drawing;
using System.Web;

namespace MyGame {
	public class Player : BasePlayer {
		public int x,y;
        public String map,username;
        public bool[] keys = new bool[4];
        public DateTime positionUpdate;
	}

	[RoomType("Map")]
	public class GameCode : Game<Player> {
        private Dictionary<String,Point> Doors = new Dictionary<string,Point>();
        private Dictionary<String,ArrayList> Points = new Dictionary<string, ArrayList>();
        private DatabaseObject roomData;
		// This method is called when an instance of your the game is created
		public override void GameStarted() {
            PreloadPlayerObjects = true;
			// anything you write to the Console will show up in the 
			// output window of the development server
			Console.WriteLine("Game is started: " + RoomId);
            PlayerIO.BigDB.Load("RoomData", RoomId, delegate(DatabaseObject data) {
                roomData = data;
                Console.WriteLine("Loading links");
                Console.WriteLine(data);
                DatabaseObject links = data.GetObject("links");
                foreach (String name in links.Properties)
                {
                    Console.WriteLine("Loaded "+name);
                    DatabaseObject link = links.GetObject(name);
                    Doors.Add(name, new Point(link.GetInt("x"), link.GetInt("y")));
                }
            });
			// This is how you setup a timer
			AddTimer(delegate {
				// code here will code every 100th millisecond (ten times a second)
			}, 100);
			
			// Debug Example:
			// Sometimes, it can be very usefull to have a graphical representation
			// of the state of your game.
			// An easy way to accomplish this is to setup a timer to update the
			// debug view every 250th second (4 times a second).
			AddTimer(delegate {
				// This will cause the GenerateDebugImage() method to be called
				// so you can draw a grapical version of the game state.
				RefreshDebugView(); 
			}, 250);
		}
        public override bool AllowUserJoin(Player player) {
            if (RoomId != player.PlayerObject.GetString("map"))
                return false;
            foreach (Player p in Players) {
                if (p.username == player.PlayerObject.GetString("username"))
                {
                    player.Send("AlreadyInRoom");
                    Console.WriteLine("Refused a user");
                    return false;
                }
            }
            return true;
        }
        public void loadPoints(DatabaseObject roomData,String username)
        {
            
            DatabaseObject points = roomData.GetObject("points");
     
            if (!points.Contains(username))
                return;
            DatabaseObject user = points.GetObject(username);
            if (user.GetDateTime("day") < DateTime.Today)
            {
                Console.WriteLine("Purged old slime point data in map: " + RoomId);
                points.Remove(username);
                roomData.Save(true, true);
                return;
            }
            DatabaseArray userpoints = user.GetArray("list");
            ArrayList listPoints = new ArrayList();
            for (int i = 0; i < userpoints.Count; i++)
                listPoints.Add(userpoints.GetInt(i));
            Points.Add((String)username.Clone(), listPoints);
        }
		// This method is called when the last player leaves the room, and it's closed down.
		public override void GameClosed() {
            roomData.Save(true, true, delegate() {
                Console.WriteLine("Room saved.");
            });
			Console.WriteLine("RoomId: " + RoomId);
		}

		// This method is called whenever a player joins the game
        public void BroadcastExcept(Player player,String message,params object[] parameters) {
            foreach(Player p in Players) {
                if (p != player)
                    p.Send(message, parameters);
            };
        }
		public override void UserJoined(Player player) {
            player.x = player.PlayerObject.GetInt("x");
            player.y = player.PlayerObject.GetInt("y");
            player.username = player.PlayerObject.GetString("username");
            player.map = player.PlayerObject.GetString("map");
            Console.WriteLine("Player Joined: " + player.username + "(" + player.Id + ") at " + player.x + "," + player.y);
            PlayerIO.BigDB.Load("RoomData",RoomId,delegate(DatabaseObject data) {
                Message begin = Message.Create("Begin");
                begin.Add(player.username, player.Id, player.x, player.y);
                loadPoints(data,player.username);
                if (Points.ContainsKey(player.username))
                {
                    foreach (int pointId in Points[player.username])
                    {
                        Console.WriteLine("Point " + pointId);
                        begin.Add(pointId);
                    }
                }
                player.Send(begin);
                Message msg = Message.Create("InitPlayers");
                foreach (Player p in Players)
                {
                    if (p.Id != player.Id)
                    {
                        msg.Add(p.username);
                        msg.Add(p.Id);
                        msg.Add(p.x);
                        msg.Add(p.y);
                    }
                }
                player.Send(msg);
                BroadcastExcept(player,"UserJoined", player.username, player.Id, player.x, player.y);
                
            });
		}

		// This method is called when a player leaves the game
		public override void UserLeft(Player player) {
            Broadcast("UserLeft", player.Id);
            player.PlayerObject.Set("x", player.x);
            player.PlayerObject.Set("y", player.y);
            player.PlayerObject.Set("map", player.map);
            player.PlayerObject.Save(true, true,delegate() {
                Console.WriteLine("Saved user.");
            });
            Console.WriteLine("User " + player.username + " is leaving while at: " + player.x + "," + player.y + " in " + player.map);
		}

		// This method is called when a player sends a message into the server code
		public override void GotMessage(Player player, Message message) {
			switch(message.Type) {
				// This is how you would set a players name when they send in their name in a 
				// "MyNameIs" message
				case "UpdatePosition":
                    if (DateTime.Now - player.positionUpdate > new TimeSpan(0, 0, 1))
                    {
                        if (player.map == RoomId)
                        {
                            player.x = message.GetInt(0);
                            player.y = message.GetInt(1);
                            BroadcastExcept(player, "UpdatePosition", player.Id, player.x, player.y);
                            Console.WriteLine("Updating position for " + player.username + " to " + player.x + "," + player.y);
                            player.positionUpdate = DateTime.Now;
                        }
                    }
                    else {
                        Console.WriteLine(player.Id + " is sending positions too fast!");
                    }
					break;
                case "UpdateKey":
                    if (message.GetInt(0) > 3)
                        break;
                    player.keys[message.GetInt(0)] = message.GetBoolean(1);
                    BroadcastExcept(player,"UpdateKey", player.Id, message.GetInt(0), message.GetBoolean(1));
                    break;
                case "Door":
                    Console.WriteLine("Door used by " + player.username + " to " + message.GetString(0));
                    player.x = Doors[message.GetString(0)].X;
                    player.y = Doors[message.GetString(0)].Y;
                    player.map = message.GetString(0);
                    player.Send("ChangeRoom",message.GetString(0));
                    break;
                case "Point":
                    Console.WriteLine("Collected point " + message.GetInteger(0) + " for " + player.username);
                    if (!roomData.GetObject("points").Contains(player.username))
                    {
                        DatabaseObject d = new DatabaseObject();
                        d.Set("day", DateTime.Today);
                        d.Set("list", new DatabaseArray());
                        roomData.GetObject("points").Set(player.username, d);
                    }
                    if (!roomData.GetObject("points").GetObject(player.username).GetArray("list").Contains(message.GetInt(0)))
                        roomData.GetObject("points").GetObject(player.username).GetArray("list").Add(message.GetInt(0));
                    break;
			}
		}

		Point debugPoint;

		// This method get's called whenever you trigger it by calling the RefreshDebugView() method.
		public override System.Drawing.Image GenerateDebugImage() {
			// we'll just draw 400 by 400 pixels image with the current time, but you can
			// use this to visualize just about anything.
			var image = new Bitmap(400,400);
			using(var g = Graphics.FromImage(image)) {
				// fill the background
				g.FillRectangle(Brushes.Blue, 0, 0, image.Width, image.Height);

				// draw the current time
				g.DrawString(DateTime.Now.ToString(), new Font("Verdana",20F),Brushes.Orange, 10,10);

				// draw a dot based on the DebugPoint variable
				g.FillRectangle(Brushes.Red, debugPoint.X,debugPoint.Y,5,5);
			}
			return image;
		}

		// During development, it's very usefull to be able to cause certain events
		// to occur in your serverside code. If you create a public method with no
		// arguments and add a [DebugAction] attribute like we've down below, a button
		// will be added to the development server. 
		// Whenever you click the button, your code will run.
		[DebugAction("Purge Points", DebugAction.Icon.Delete)]
		public void Purge() {
            PlayerIO.BigDB.Load("RoomData", RoomId, delegate(DatabaseObject roomData)
            {
                roomData.GetObject("points").Clear();
                roomData.Save(true,true);
            });
		}

		// If you use the [DebugAction] attribute on a method with
		// two int arguments, the action will be triggered via the
		// debug view when you click the debug view on a running game.
		[DebugAction("Set Debug Point", DebugAction.Icon.Green)]
		public void SetDebugPoint(int x, int y) {
			debugPoint = new Point(x,y);
		}
	}
}
