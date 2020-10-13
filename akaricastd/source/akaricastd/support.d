module akaricastd.support;

import std.file : readText;
import std.algorithm: canFind;
import std.array: split;
import akaricastd.config : Config;


final class ProtocolSupport {
    
    string[] supported = [];

    this() {
        this.supported ~= "http";
        this.supported ~= "https";
        this.handleNfsSupport();
    }

    private void handleNfsSupport() {
        version(linux) {
            string filesystems = readText("/proc/filesystems");
            auto lines = filesystems.split("\n");

            foreach (string line; lines) {
                auto atoms = line.split("\t");
                
                if (atoms[1] == "nfs") {
                    this.supported ~= "nfs";
                    break;
                }
            }
        }
    } 

    public bool isProtocolSupported(string protocol) {
        return this.supported.canFind(protocol);
    }

    public string[] getProtocols() {
        return this.supported;
    }
}

final class SiteSupport {

    string[] supported = [];
    
    this() {
        supported ~= "youtube.com";
        supported ~= "youtu.be";
    }

    public bool isSiteSupported(string site) {
        return this.supported.canFind(site);
    }

    public string[] getSites() {
        return this.supported;
    }
}

final class SupportChecker {
    ProtocolSupport protocols;
    SiteSupport sites;
    
    this() {
        this.protocols = new ProtocolSupport();
        this.sites = new SiteSupport();
    }

    public bool isProtocolSupported(string protocol) {
        return this.protocols.isProtocolSupported(protocol);
    }
    
    public bool isSiteSupported(string site) {
        return this.sites.isSiteSupported(site);
    }

    public string[] getProtocols() {
        return this.protocols.getProtocols();
    }

    public string[] getSites() {
        return this.sites.getSites();
    }
}
