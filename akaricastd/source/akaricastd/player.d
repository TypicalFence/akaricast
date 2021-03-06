module akaricastd.player;

import core.stdc.stdlib;
import core.thread : Fiber, Thread, dur;
import std.conv : to;
import std.string : toStringz;
import std.typecons : Nullable;
import std.experimental.logger;
import mpv.client;
import akaricastd.config : Config;
import akaricastd.playlist: Playlist, PlaylistItem;

enum PlayerError {
    OK,
    UNSUPPORTED_MEDIA,
    WRONG_STATE,
    ERROR
}

interface Player {
    PlayerError playURL(string url);
    PlayerError play();
    bool isPlaying();
    bool isPaused();
    PlayerError pause();
    PlayerError resume();
    PlayerError stop();
    PlayerError next();
}

// ------------------------------------------------------------------
// MPV
// ------------------------------------------------------------------

PlayerError mpv_errorToPlayerError(int error) {
    switch (error) {
        case mpv_error.MPV_ERROR_SUCCESS:
            return PlayerError.OK;

        case mpv_error.MPV_ERROR_UNKNOWN_FORMAT:
            return PlayerError.UNSUPPORTED_MEDIA;

        default:
            return PlayerError.ERROR;
    }
}

final class MpvPlayer : Player {
    
    private mpv_handle *mpv;
    // event handler is a nonblocking
    // running in another thread
    private MpvEventHandler eventHandler;
    private Playlist playlist;
    private bool stopWasRecentlyCalled;

    this(Config config, Playlist playlist) {
        this.stopWasRecentlyCalled = false;
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
        if (!this.isPlaying() && !this.isPaused()) {
            // play next item in the playlist
            Nullable!PlaylistItem nullItem = this.playlist.popItem();
            if (!nullItem.isNull()) {
                PlaylistItem item = nullItem.get;
                return this.playURL(item.uri);
            }           
        }

        if (this.isPaused()) {
            return this.resume();
        }

        return PlayerError.WRONG_STATE;
    }

    public PlayerError playURL(string url) {
        const(char)** cmd = cast(const(char)**) malloc(3);
        cmd[0] = toStringz("loadfile");
        cmd[1] = toStringz(url);
        cmd[2] = null;
        int status = mpv_command(this.mpv, cmd);
        free(cmd);

        info("playing " ~ url);
        return mpv_errorToPlayerError(status);
    }

    public bool isPlaying() {
        string idle_str = this.getProperty("core-idle");
        return !(idle_str == "yes");
    }
    
    public bool isPaused() {
        string paused_str = this.getProperty("pause");
        return paused_str == "yes";
    }

   public PlayerError stop() {
        const(char)** cmd = cast(const(char)**) malloc(2);
        cmd[0] = toStringz("playlist-remove");
        cmd[1] = toStringz("0");
        int status = mpv_command(this.mpv, cmd);
        free(cmd);
        
        if (status == mpv_error.MPV_ERROR_SUCCESS) {
            this.stopWasRecentlyCalled = true;
        }

        return mpv_errorToPlayerError(status);
    }

    public PlayerError pause() {
        const(char) *prop = toStringz("pause");
        const(char) *val = toStringz("yes");
        int status = mpv_set_property_string(this.mpv, prop, val);
        return mpv_errorToPlayerError(status);
    }
    
    public PlayerError resume() {
        if (this.isPaused()) {
            const(char) *prop = toStringz("pause");
            const(char) *val = toStringz("no");
            int status = mpv_set_property_string(this.mpv, prop, val);
            return mpv_errorToPlayerError(status);
        }

        return PlayerError.WRONG_STATE;
    }
    
    public PlayerError next() {
        Nullable!PlaylistItem nullItem = this.playlist.popItem();
        if (!nullItem.isNull()) {
            PlaylistItem item = nullItem.get;

            return this.playURL(item.uri);
        }

        return PlayerError.WRONG_STATE;
    }

    public void tryToPlayNextFile() {
        if (!this.stopWasRecentlyCalled) {
            this.next(); 
        }
        
        this.stopWasRecentlyCalled = false;
    }
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
