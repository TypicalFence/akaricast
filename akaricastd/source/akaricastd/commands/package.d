module akaricastd.commands;

import std.experimental.logger;
import djrpc.v2 : JsonRpc2Request, JsonRpc2Response;
import akaricastd.player : Player; 
import akaricastd.playlist: Playlist;
import akaricastd.commands.playback; 
import akaricastd.commands.playlist; 
import akaricastd.commands.info; 

interface Command {
    static string getName();
    JsonRpc2Response run(JsonRpc2Request request);
}

class CommandLocator {
    
    protected Command[string] commands;

    this(Player player, Playlist playlist) {
        this.commands[PlayCommand.getName()] = new PlayCommand(player);
        this.commands[PauseCommand.getName()] = new PauseCommand(player);
        this.commands[StopCommand.getName()] = new StopCommand(player);
        this.commands[NextCommand.getName()] = new NextCommand(player);
        this.commands[EnqueueCommand.getName()] = new EnqueueCommand(player, playlist);
        this.commands[GetPlaylistCommand.getName()] = new GetPlaylistCommand(playlist);
        this.commands[SupportInfoCommand.getName()] = new SupportInfoCommand();
    }

    Command getCommand(string name) {
        if ((name in this.commands) != null) {
            return this.commands[name];
        }
        
        return null;
    }
    
}
