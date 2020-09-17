module akaricastd.commands.playback;

import std.typecons : Nullable, nullable;
import std.json : JSONValue;
import djrpc.v2 : JsonRpc2Request, JsonRpc2Response, JsonRpc2Error;
import akaricastd.commands : Command;
import akaricastd.player : Player, PlayerError;

class PlayCommand : Command {
   
    private Player player;

    this(Player player) {
        this.player = player;
    }

    static string getName() {
        return "play";
    }

    JsonRpc2Response run(JsonRpc2Request request) {
        PlayerError playError = this.player.play();
        
        Nullable!JSONValue result = Nullable!JSONValue.init;
        Nullable!JsonRpc2Error error = Nullable!JsonRpc2Error.init;
        Nullable!JSONValue data = Nullable!JSONValue.init;

        if (playError == PlayerError.OK) {
            result = nullable(JSONValue("ok"));
        } else {
            error = nullable(new JsonRpc2Error(1, "error", data));
        }

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
        PlayerError playError = this.player.pause();
        
        Nullable!JSONValue result = Nullable!JSONValue.init;
        Nullable!JsonRpc2Error error = Nullable!JsonRpc2Error.init;
        Nullable!JSONValue data = Nullable!JSONValue.init;

        if (playError == PlayerError.OK) {
            result = nullable(JSONValue("ok"));
        } else {
            error = nullable(new JsonRpc2Error(1, "error", data));
        }

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
        PlayerError playError = this.player.stop();
        
        Nullable!JSONValue result = Nullable!JSONValue.init;
        Nullable!JsonRpc2Error error = Nullable!JsonRpc2Error.init;
        Nullable!JSONValue data = Nullable!JSONValue.init;

        if (playError == PlayerError.OK) {
            result = nullable(JSONValue("ok"));
        } else {
            error = nullable(new JsonRpc2Error(1, "error", data));
        }

        return new JsonRpc2Response(
            request.getID(),
            error,
            result
        );
    }
}
