module akaricastd.playlist;

import std.typecons : Nullable, nullable;
import std.range.primitives;
import akaricastd.player : Player;

enum PlaylistItemType {
    File = "file",
    Youtube = "youtube"
}


struct PlaylistItem {
    string uri;
    PlaylistItemType type;
}

final class Playlist {
    
    private PlaylistItem[]  playlist;

    this() {
        this.playlist = [];
    }

    public void addItem(string uri) {
        this.playlist ~= PlaylistItem(uri, PlaylistItemType.File);
    }
    
    public Nullable!PlaylistItem popItem() {
        if (this.playlist.length > 0) {
            PlaylistItem item = this.playlist[0];
            this.playlist.popFront();
            return nullable(item);
        }

        return Nullable!PlaylistItem.init;
    }
}
