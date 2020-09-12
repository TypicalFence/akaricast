module akaricastd.commands;

import djrpc.v2 : JsonRpc2Request, JsonRpc2Response;

interface Command {
    string getName();
    JsonRpc2Response run(JsonRpc2Request request);
}
