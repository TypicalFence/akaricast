module akaricastd.playlist;

import std.typecons : Nullable, nullable;
import std.range.primitives;
import std.digest.md;
import std.conv : to;
import std.json : JSONValue;
import std.experimental.logger;
import akaricastd.player : Player;

enum PlaylistItemType {
    Youtube = "youtube",
    HttpFile = "http_file",
    TemporaryFile = "temporary_file",
    DownloadedFile = "downloaded_file",
    WeJustDontKnow = "wejustdontknow"
}

struct PlaylistItem {
    string id;
    string uri;
    PlaylistItemType type;

    JSONValue toJSON() {
        JSONValue json = [ "id": this.id ];
        json["uri"] = this.uri;
        json["type"] = this.type;
        return json;
    }
}

final class Playlist {
    
    // probably convert this to a map lol
    private PlaylistItem[]  playlist;

    this() {
        this.playlist = [];
    }
    
    private string getImprovisedID(string uri) {
        // note: this is sorta bad
        auto md5 = new MD5Digest();
        // add the playlist length, incase we have duplicate uri's
        ubyte[] hash = md5.digest(uri ~ to!string(this.playlist.length));
        return toHexString(hash);
    }

    public void addItem(string uri, PlaylistItemType type) {
        string id = getImprovisedID(uri);
        this.playlist ~= PlaylistItem(id, uri, type);
        info("added " ~ uri ~ "to playlist");
    }

    public void addItem(string id, string uri, PlaylistItemType type) {
        this.playlist ~= PlaylistItem(id, uri, type);
        info("added " ~ uri ~ "to playlist");
    }
    
    public Nullable!PlaylistItem popItem() {
        if (this.playlist.length > 0) {
            PlaylistItem item = this.playlist[0];
            this.playlist.popFront();
            return nullable(item);
        }

        return Nullable!PlaylistItem.init;
    }

    public PlaylistItem[] getPlaylistItems() {
        return this.playlist;
    }
}
