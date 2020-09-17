"""Basic transportless json-rpc 2.0 implementation & helpers"""
import json
import uuid
from abc import ABC, abstractmethod


class JsonRpcObject(ABC):
    @abstractmethod
    def to_json(self):
        pass

    @abstractmethod
    def from_json(json_str):
        pass

    @property
    def jsonrpc(self):
        return "2.0"


class JsonRpcRequest(JsonRpcObject):
    def __init__(self, method, params=None, id=None):
        if id is None:
            self._id = uuid.uuid4().hex
        else:
            self._id = id

        self._method = method
        self._params = params

    @property
    def id(self):
        return self._id

    @property
    def method(self):
        return self._method

    @property
    def params(self):
        return self._params

    def to_json(self):
        return json.dumps({
            "id": self.id,
            "jsonrpc": self.jsonrpc,
            "method": self.method,
            "params": self.params
        })

    def from_json(json_str):
        data = json.loads(json_str)
        return JsonRpcRequest(data["method"], data["params"], data["id"])


class JsonRpcResponse(JsonRpcObject):
    def __init__(self, id, result=None, error=None):
        self._id = id
        self._result = result
        self._error = error

    @property
    def id(self):
        return self._id

    @property
    def result(self):
        return self._result

    @property
    def error(self):
        return self._error

    def to_json(self):
        data = {
            "id": self.id,
            "jsonrpc": self.jsonrpc,
        }

        # TODO this is sorta dumb
        if self.result is not None:
            data["result"] = self.result
        else:
            data["error"] = self.error

        return json.dumps(data)

    def from_json(json_str):
        data = json.loads(json_str)
        result = None
        error = None

        if "result" in data:
            result = data["result"]

        if "error" in data:
            error = data["error"]

        return JsonRpcResponse(data["id"], result, error)
