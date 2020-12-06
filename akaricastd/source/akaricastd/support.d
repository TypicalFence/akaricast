module akaricastd.support;

import std.file : readText;
import std.algorithm: canFind;
import std.array: split;
import akaricastd.config : Config;

// TODO move this to the player implementations

final class ProtocolSupport {
    
    string[] supported = [];

    this() {
        this.supported ~= "http";
        this.supported ~= "https";
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
