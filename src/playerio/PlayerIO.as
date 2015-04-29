﻿package playerio {
	import flash.display.Stage
	import flash.display.Loader
	import flash.events.Event
	import flash.events.IOErrorEvent
	import flash.events.SecurityErrorEvent
	import flash.net.URLRequest;
	import flash.net.URLLoader
	import flash.net.URLLoaderDataFormat
	import flash.system.ApplicationDomain
	import flash.system.LoaderContext
	
	/**
	 * API wrapper that is used to connect to the PlayerIO webservices 
	 * 
	 */
	public final class PlayerIO{
		private static var wrapper:Loader;
		private static var queue:Array = [];
		private static var apiError:PlayerIOError
		private static var wo:Object = {};
		private static var lc:LoaderContext = new LoaderContext(false, ApplicationDomain.currentDomain);
		/**
		 * You cannot create an instance of the PlayerIO class, all use happens via static methods. 
		 * @throws Error You cannot create an instance of the PlayerIO class!
		 */		
		public function PlayerIO(){
			throw new Error("You cannot create an instance of the PlayerIO class!")
		}
		
		/**
		 * Authenticates and connects the game to the Player.IO webservices.
		 * @param stage A reference to the base stage of your project.
		 * @param gameid Unique ID that identifies which game the client will try to connect to
		 * @param connectionid Id of the connection to use when connecting to the game. Usually this is "public" unless you've set up different connections in the Player.IO admin panel.
		 * @param userid Unique identifier of the current user playing the game. This can be supplied by you, or a a third party. Example userids are Username, Facebook UserID, OpenID Url etc.
		 * @param auth User auth. Can be left blank if the connection identified by connectionid does not require authentication.
		 * @param partnerId String that identifies a possible affiliate partner.
		 * @param callback Function executed on successful connect: function(client:Client):void{...}
		 * @param errorhandler Function executed if the request failed: function(error:PlayerIOError):void{...}
		 * 
		 * @see Client Client returned on successfull connect
		 */		
		public static function connect(stage:Stage, gameid:String, connectionid:String, userid:String, auth:String, partnerId:String, callback:Function, errorhandler:Function = null):void{
			proxy("connect", arguments);
		}
		
		/**
		 * Referance to a QuickConnect instance that allows you to easly connect with 3rd party user databases.  
		 * @return instance of QuickConnect
		 * 
		 */
		public static function get quickConnect():QuickConnect{
			return new QuickConnect(proxy);
		}
		
		/**
		 * Referance to a GameFS instance that allows you to access GameFS 
		 * @param gameId the GameID of your game.
		 * @return An instance of GameFS
		 * @example Example of how to request the file game.swf from your games GameFS via PlayerIO
		 * <listing version="3.0">
		 * 	var url:String = PlayerIO.gameFS("game-id").getURL("game.swf")
		 * </listing>
		 * 
		 */
		public static function gameFS(gameId:String):GameFS{
			return new SimpleGameFS(gameId, wo)
		}
		
		/**
		 * Gives you greater control over when and where the Player.IO logo is shown. If this method is called, the logo will not appear when you connect to player.io via playerio.connect nor via QuickConnect. 
		 * @param stage A reference to the base stage of your project.
		 * @param align Where should the logo appear. Valid values are TL, CL, BL, TC, CC, BC, TR, CR, BR. The first letter stands for vertical position Top, Center or Bottom. The second letter is for horizontal position Left, Center or Right.
		 * 
		 */
		public static function showLogo(stage:Stage, align:String):void{
			proxy("showLogo", arguments)
		}
		
		//For future use.
		/*public static function clearAnonymousUser(errorHandler:Function = null):void{
			proxy("clearAnonymousUser", arguments);
		}*/
		
		private static function proxy(target:String, args:Object):void{
			if(apiError){
				throwError(apiError,args[args.callee.length-1])
			}else if(wrapper && wrapper.content){
				try{
					var api:* = wrapper.content
					var path:Array = target.split(".");
					while(path.length > 1){
						api = api[path.shift()]
					}
					api[path[0]].apply(null, args)
				}catch(e:Error){
					throwError(new PlayerIOError(e.message, e.errorID),args[args.callee.length-1])
				}
			}else{
				queue.push(function():void{ args.callee.apply(null, args) })
			}
			if(!wrapper) loadAPI()
		}
		
		private static function loadAPI():void {
			
			wrapper = new Loader();
			var loader:URLLoader = new URLLoader();
			loader.dataFormat = URLLoaderDataFormat.BINARY;
			loader.addEventListener(Event.COMPLETE, function(e:Event):void{
				wrapper.contentLoaderInfo.addEventListener(Event.COMPLETE, emptyQueue);
				wrapper.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, handleLoadError);
				wrapper.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, handleLoadError);
				lc.allowCodeImport = true;
				wrapper.loadBytes(loader.data,lc);
				wo.wrapper = wrapper
			});
			/*loader.addEventListener(Event.COMPLETE, function(e:Event):void{
				wrapper.contentLoaderInfo.addEventListener(Event.COMPLETE, emptyQueue)
				wrapper.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, handleLoadError)
				wrapper.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, handleLoadError)
				wrapper.loadBytes(loader.data, new LoaderContext(false, ApplicationDomain.currentDomain));
				wo.wrapper = wrapper
			})*/
			loader.addEventListener(IOErrorEvent.IO_ERROR, handleLoadError )
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, handleLoadError)
			//loader.load(new URLRequest("http://n.c/flashbridge/1"));
			loader.load(new URLRequest("http://api.playerio.com/flashbridge/1"));
		}
		
		private static function handleLoadError(e:Event = null):void{
			apiError = new PlayerIOError("Unable to connect to the API due to " + e.type + ". Please verify that your internet connection is working!",0)
			emptyQueue() 
		}
		
		private static function emptyQueue(e:Event = null):void{
 			while(queue.length)
				queue.shift()();
		}
		
		private static function throwError(error:PlayerIOError, target:Function):void{
			if( target != null ){
				target(error)
			}else{
				throw PlayerIOError
			}
		}
	} 
}

