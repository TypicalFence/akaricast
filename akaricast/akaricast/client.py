import socket
from akaricast.json_rpc import JsonRpcRequest, JsonRpcResponse


class AkaricastClient():
    def __init__(self, host, port=1337):
        self._host = host
        self._port = port
        self._socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        self._socket.connect((self._host, self._port))

    def _make_request(self, request):
        self._socket.sendall(request.to_json().encode("utf-8"))
        data = self._socket.recv(1024)
        data_str = data.decode("utf-8")
        return JsonRpcResponse.from_json(data_str)

    def enque(self, url, id=None):
        request = JsonRpcRequest("enqueue", params={"url": url}, id=id)
        return self._make_request(request)

    def get_playlist(self, id=None):
        request = JsonRpcRequest("getPlaylist", id=id)
        return self._make_request(request)

    def play(self, id=None):
        request = JsonRpcRequest("play", id=id)
        return self._make_request(request)

    def pause(self, id=None):
        request = JsonRpcRequest("pause", id=id)
        return self._make_request(request)

    def stop(self, id=None):
        request = JsonRpcRequest("stop", id=id)
        return self._make_request(request)

    def next(self, id=None):
        request = JsonRpcRequest("next", id=id)
        return self._make_request(request)
