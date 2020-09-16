module akaricastd.commands.playlist;

import std.typecons : Nullable;
import std.json : JSONValue;
import djrpc.v2 : JsonRpc2Request, JsonRpc2Response, JsonRpc2Error;
import akaricastd.commands : Command;
import akaricastd.player : Player;
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
