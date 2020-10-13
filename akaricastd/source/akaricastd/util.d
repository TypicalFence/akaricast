module akaricastd.util;

import std.typecons : Nullable, nullable;
import std.json : JSONValue;
import djrpc.v2 : JsonRpc2Request, JsonRpc2Response, JsonRpc2Error;

JsonRpc2Response getError(JsonRpc2Request req,long code, string reason) {
    Nullable!JSONValue result = nullable(JSONValue(null));
    Nullable!JsonRpc2Error error = nullable(new JsonRpc2Error(code, reason, Nullable!JSONValue.init));
    return new JsonRpc2Response(
        req.getID(),
        error,
        result
    );

}
