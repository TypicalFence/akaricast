module akaricastd.commands.playback;

import std.typecons : Nullable;
import std.json : JSONValue;
import djrpc.v2 : JsonRpc2Request, JsonRpc2Response, JsonRpc2Error;
import akaricastd.commands : Command;
import akaricastd.player : Player;

class PlayCommand : Command {
   
    private Player player;

    this(Player player) {
        this.player = player;
    }

    static string getName() {
        return "play";
    }

    JsonRpc2Response run(JsonRpc2Request request) {
        this.player.play();
        
        JSONValue resultObj = [ "result": "yay" ];
        Nullable!JSONValue result = Nullable!JSONValue(resultObj);
        Nullable!JsonRpc2Error error = Nullable!JsonRpc2Error.init;

        return new JsonRpc2Response(
            request.getID(),
            error,
            result
        );
    }
}

class PauseCommand : Command {
   
    private Player player;

    this(Player player) {
        this.player = player;
    }

    static string getName() {
        return "pause";
    }

    JsonRpc2Response run(JsonRpc2Request request) {
        this.player.pause();
        
        JSONValue resultObj = [ "result": "yay" ];
        Nullable!JSONValue result = Nullable!JSONValue(resultObj);
        Nullable!JsonRpc2Error error = Nullable!JsonRpc2Error.init;

        return new JsonRpc2Response(
            request.getID(),
            error,
            result
        );
    }
}

class StopCommand : Command {
   
    private Player player;

    this(Player player) {
        this.player = player;
    }

    static string getName() {
        return "stop";
    }

    JsonRpc2Response run(JsonRpc2Request request) {
        this.player.stop();
        
        JSONValue resultObj = [ "result": "yay" ];
        Nullable!JSONValue result = Nullable!JSONValue(resultObj);
        Nullable!JsonRpc2Error error = Nullable!JsonRpc2Error.init;

        return new JsonRpc2Response(
            request.getID(),
            error,
            result
        );
    }
}
