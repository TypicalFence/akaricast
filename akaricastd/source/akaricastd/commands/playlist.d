module akaricastd.commands.playlist;

import std.stdio;
import std.typecons : Nullable, nullable;
import std.json : JSONValue;
import std.array : split;
import std.experimental.logger;
import djrpc.v2 : JsonRpc2Request, JsonRpc2Response, JsonRpc2Error;
import url;
import akaricastd.commands : Command;
import akaricastd.player : Player, PlayerError;
import akaricastd.playlist: Playlist, PlaylistItem, PlaylistItemType;
import akaricastd.support : SupportChecker;
import akaricastd.util : getError;

class EnqueueCommand : Command {
   
    private Player player;
    private Playlist playlist;
    private SupportChecker supportChecker;

    this(Player player, Playlist playlist) {
        this.player = player;
        this.playlist = playlist;
        this.supportChecker = new SupportChecker();
    }

    static string getName() {
        return "enqueue";
    }
    
    private PlaylistItemType getTypeFromURL(URL url) {
        if (url.host == "youtube.com") {
            return PlaylistItemType.Youtube;
        }

        if (url.scheme == "http" || url.scheme == "https") {
            return PlaylistItemType.HttpFile;
        }
        
        // idk 
        // this doesn't seem very clever when I think about it
        return PlaylistItemType.WeJustDontKnow; 
    }
    
    /**
     * Returns a Null value when valid
     */
    private Nullable!JsonRpc2Response checkUrlValidity(string url_str, JsonRpc2Request request) {
        try {
            URL url = parseURL(url_str);
            
            // filter out a urls without a path
            if (url.path.length == 0) {
                return nullable(getError(request, 1, "not a supported url"));
            }

            if (!this.supportChecker.isProtocolSupported(url.scheme)) {
                return nullable(getError(request, 2, "protocol not supported"));
            }
            
            // probably has a file ending
            // TODO maybe add supported enidngs?
            // this is suboptimal at best
            if (url.path.split(".").length == 1) {
                // when not dealing with a file only certain sites are allowed
                if (!this.supportChecker.isSiteSupported(url.host)) {
                    writeln(url.host);
                    return nullable(getError(request, 3, "site not supported"));
                }               
            }
        } catch (URLException _) {
            return nullable(getError(request, 1, "not a url"));
        }

        return Nullable!JsonRpc2Response.init;
    }

    public JsonRpc2Response run(JsonRpc2Request request) {
        JSONValue params = request.getParams();

        if (!("url" in params)) {
            return getError(request, 25, "invalid params"); 
        }

        string url_str = params["url"].str;
        bool temporary = false;

        if ("temporary" in params) {
            temporary = params["temporary"].boolean;
        }
        
        auto error = this.checkUrlValidity(url_str, request);

        if (!error.isNull) {
            warning("client tried to add an unspoorted url: " ~ url_str);
            return error.get;
        }
        
        // safe because we made sure that we have a valid url at this point
        URL url = parseURL(url_str);
        PlaylistItemType type;
        
        // ignore temporary when a special site
        if (temporary && !this.supportChecker.isSiteSupported(url.host)) {
            type = PlaylistItemType.TemporaryFile;
        } else {
            type = this.getTypeFromURL(url);
        }
        
        this.playlist.addItem(url_str, type);
        
        Nullable!JSONValue result = Nullable!JSONValue.init;
        Nullable!JsonRpc2Error rpcError = Nullable!JsonRpc2Error.init;

        result = nullable(JSONValue("ok"));

        return new JsonRpc2Response(
            request.getID(),
            rpcError,
            result
        );
    }
}

class GetPlaylistCommand : Command {
    private Playlist playlist;
    private SupportChecker supportChecker;

    this(Playlist playlist) {
        this.playlist = playlist;
    }

    static string getName() {
        return "getPlaylist";
    }

    public JsonRpc2Response run(JsonRpc2Request request) {
        Nullable!JSONValue result = Nullable!JSONValue.init;
        Nullable!JsonRpc2Error rpcError = Nullable!JsonRpc2Error.init;
        
        JSONValue[] playlistItemsJSON = [];

        foreach(PlaylistItem item; this.playlist.getPlaylistItems()) {
            playlistItemsJSON ~= item.toJSON();
        }

        result = nullable(JSONValue(playlistItemsJSON));

        return new JsonRpc2Response(
            request.getID(),
            rpcError,
            result
        );
    }
}
