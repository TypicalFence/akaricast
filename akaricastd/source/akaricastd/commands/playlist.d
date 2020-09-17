module akaricastd.commands.playlist;

import std.typecons : Nullable, nullable;
import std.json : JSONValue;
import djrpc.v2 : JsonRpc2Request, JsonRpc2Response, JsonRpc2Error;
import akaricastd.commands : Command;
import akaricastd.player : Player, PlayerError;
import akaricastd.playlist: Playlist;

class EnqueueCommand : Command {
   
    private Player player;
    private Playlist playlist;

    this(Player player, Playlist playlist) {
        this.player = player;
        this.playlist = playlist;
    }

    static string getName() {
        return "enqueue";
    }

    JsonRpc2Response run(JsonRpc2Request request) {
        JSONValue params = request.getParams();
        string url = params["url"].str;
        
        this.playlist.addItem(url);
        
        Nullable!JSONValue result = Nullable!JSONValue.init;
        Nullable!JsonRpc2Error error = Nullable!JsonRpc2Error.init;

        result = nullable(JSONValue("ok"));

        return new JsonRpc2Response(
            request.getID(),
            error,
            result
        );
    }
}
