module akaricastd.commands;

import djrpc.v2 : JsonRpc2Request, JsonRpc2Response;
import akaricastd.player : Player; 
import akaricastd.commands.playback; 

interface Command {
    string getName();
    JsonRpc2Response run(JsonRpc2Request request);
}

class CommandLocator {
    
    protected Command[string] commands;

    this(Player player) {
        PlayCommand playCMD = new PlayCommand(player);
        PauseCommand pauseCMD = new PauseCommand(player);
        StopCommand stopCMD = new StopCommand(player);
        this.commands[playCMD.getName()] = playCMD;
        this.commands[pauseCMD.getName()] = pauseCMD;
        this.commands[stopCMD.getName()] = stopCMD;
    }

    Command getCommand(string name) {
        return this.commands[name];
    }
    
}
