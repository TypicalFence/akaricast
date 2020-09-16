module akaricastd.commands;

import djrpc.v2 : JsonRpc2Request, JsonRpc2Response;
import akaricastd.player : Player; 
import akaricastd.playlist: Playlist;
import akaricastd.commands.playback; 
import akaricastd.commands.playlist; 

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
        this.commands[EnqueueCommand.getName()] = new EnqueueCommand(player, playlist);
    }

    Command getCommand(string name) {
        return this.commands[name];
    }
    
}
