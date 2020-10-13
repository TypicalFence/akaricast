module akaricastd.commands.info;

import std.typecons : Nullable, nullable;
import std.json : JSONValue;
import djrpc.v2 : JsonRpc2Request, JsonRpc2Response, JsonRpc2Error;
import akaricastd.commands : Command;
import akaricastd.support : SupportChecker;

class SupportInfoCommand : Command {
   
    private SupportChecker supportChecker;
    
    this() {
        this.supportChecker = new SupportChecker();
    }

    static string getName() {
        return "supportInfo";
    }

    JsonRpc2Response run(JsonRpc2Request request) {
        JSONValue support = JSONValue();
        support["protocols"] = this.supportChecker.getProtocols();
        support["sites"] = this.supportChecker.getSites();

        Nullable!JSONValue result = nullable(support);
        Nullable!JsonRpc2Error error = Nullable!JsonRpc2Error.init;
        Nullable!JSONValue data = Nullable!JSONValue.init;

        return new JsonRpc2Response(
            request.getID(),
            error,
            result
        );
    }
}
