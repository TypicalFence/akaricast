module akaricastd.player;

import core.stdc.stdlib;
import std.conv : to;
import std.string : toStringz;
import mpv;

enum PlayerError {
    OK,
    ERROR
}


interface Player {
    PlayerError play(string url);
    bool isPlaying();
    PlayerError pause();
    PlayerError stop();
}

class MpvPlayer : Player {
    
    private mpv_handle *mpv;

    this() {
        this.mpv = mpv_create();
        mpv_initialize(this.mpv);
    }
    
    
    private string getProperty(string name) {
        char *value = mpv_get_property_string(
                this.mpv, 
                toStringz(name)
        );
        return to!string(value);
    }
    
    public PlayerError play(string url) {
        const(char)** cmd = cast(const(char)**) malloc(3);
        cmd[0] = toStringz("loadfile");
        cmd[1] = toStringz(url);
        cmd[2] = null;
        int status = mpv_command(this.mpv, cmd);
        free(cmd);
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
        const(char)** cmd = cast(const(char)**) malloc(2);
        cmd[0] = toStringz("pause");
        cmd[1] = null;
        int status = mpv_command(this.mpv, cmd);
        free(cmd);
        return PlayerError.OK;
    }   
}
