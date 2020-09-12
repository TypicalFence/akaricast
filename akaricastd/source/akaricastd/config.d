module akaricastd.config;

import dyaml = dyaml;

enum CONFIGPATH = "/etc/akaricastd.yml";

final class Config {
    bool fullscreen;
    ushort port;

    this() {
        dyaml.Node config =  dyaml.Loader.fromFile(CONFIGPATH).load();
        
        try {
            this.fullscreen = config["fullscreen"].as!bool;
        } catch (Exception) {
            this.fullscreen = false;
        }

        try {
            this.port = config["port"].as!ushort;
        } catch (Exception) {
            this.port = 1337;
        }
    }
}

