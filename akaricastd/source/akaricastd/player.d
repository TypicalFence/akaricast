module akaricastd.player;

import core.stdc.stdlib;
import core.thread : Fiber, Thread, dur;
import std.stdio;
import std.conv : to;
import std.string : toStringz;
import std.typecons : Nullable;
import mpv;
import akaricastd.config : Config;
import akaricastd.playlist: Playlist, PlaylistItem;

enum PlayerError {
    OK,
    ERROR
}

interface Player {
    PlayerError playURL(string url);
    PlayerError play();
    bool isPlaying();
    PlayerError pause();
    PlayerError stop();
}

class MpvPlayer : Player {
    
    private mpv_handle *mpv;
    // event handler is a nonblocking
    // running in another thread
    private MpvEventHandler eventHandler;
    private Playlist playlist;

    this(Config config, Playlist playlist) {
        this.playlist = playlist;
        this.mpv = mpv_create();
        mpv_initialize(this.mpv);

        if (config.fullscreen) {
            mpv_set_property_string(this.mpv, "fullscreen", "yes");
        }

        this.eventHandler = new MpvEventHandler(this, this.mpv);
        eventHandler.start();
    }
    
    
    private string getProperty(string name) {
        char *value = mpv_get_property_string(
                this.mpv, 
                toStringz(name)
        );
        return to!string(value);
    }
    
    public PlayerError play() {
        if (!this.isPlaying()) {
            // play next item in the playlist
            Nullable!PlaylistItem nullItem = this.playlist.popItem();
            if (!nullItem.isNull()) {
                PlaylistItem item = nullItem.get;
                return this.playURL(item.uri);
            }           
        }

        return PlayerError.OK;
    }

    public PlayerError playURL(string url) {
        const(char)** cmd = cast(const(char)**) malloc(3);
        cmd[0] = toStringz("loadfile");
        cmd[1] = toStringz(url);
        cmd[2] = null;
        int status = mpv_command(this.mpv, cmd);
        free(cmd);

        writeln("playing " ~ url);
        return PlayerError.OK;
    }

    bool isPlaying() {
        string paused_str = this.getProperty("core-idle");
        if (paused_str == "yes") {
            return false;
        } 
        
        return true;
    }

   PlayerError stop() {
        const(char)** cmd = cast(const(char)**) malloc(2);
        cmd[0] = toStringz("stop");
        cmd[1] = null;
        int status = mpv_command(this.mpv, cmd);
        free(cmd);
        return PlayerError.OK;
    }

    PlayerError pause() {
        const(char) *prop = toStringz("pause");
        const(char) *val = toStringz("yes");
        int status = mpv_set_property_string(this.mpv, prop, val);
        return PlayerError.OK;
    }

    void tryToPlayNextFile() {
        Nullable!PlaylistItem nullItem = this.playlist.popItem();
        if (!nullItem.isNull()) {
            PlaylistItem item = nullItem.get;

            this.playURL(item.uri);
        }

    }
}

enum mpv_event_id {
    MPV_EVENT_END_FILE = 7
}

final class MpvEventHandler : Thread {
    MpvPlayer player;
    mpv_handle *mpv;

    this(MpvPlayer player, mpv_handle *mpv) {
        this.player = player;
        this.mpv = mpv;
        super(&run);
    }

    void run() {
        while(true) {
            mpv_event *event = mpv_wait_event(this.mpv, 10000); 
            if (event.event_id == mpv_event_id.MPV_EVENT_END_FILE) {
                this.player.tryToPlayNextFile();
            }
        }
    }
}
