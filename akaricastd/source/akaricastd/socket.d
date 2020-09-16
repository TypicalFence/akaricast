module akaricastd.socket;

import std.stdio;
import std.conv;
import std.algorithm;
import std.socket : InternetAddress, Socket, SocketException, SocketSet, TcpSocket;
import djrpc.v2 : JsonRpc2Request, JsonRpc2Response;
import akaricastd.player : Player;
import akaricastd.playlist : Playlist;
import akaricastd.commands : Command, CommandLocator;

abstract class BaseSocket {
    
    protected bool running = false;
    private Socket socket;
    private SocketSet set;
    
    this(Socket socket) {
        this.socket = socket;
        this.set = new SocketSet();
    }
    
    abstract char[] handleRequest(char[] requestData);

    void listen() {
        this.running = true;
        this.socket.listen(10);
        
        Socket[] connectedClients;
        char[1024] buffer;

        while(this.running) {
            this.set.reset();
            this.set.add(this.socket);

            foreach(client; connectedClients){ 
                this.set.add(client);
            }

            if(socket.Socket.select(this.set, null, null)) {
                for (size_t i = 0; i < connectedClients.length; i++) {
                    Socket client = connectedClients[i];
                    
                    if(this.set.isSet(client)) {
                        // read from it and echo it back
                        auto got = client.receive(buffer);
                        // trim
                        auto data = (buffer[0 .. got]);
                        auto response = this.handleRequest(data);
                        client.send(response);
                    }

                   // release socket resources now
                    client.close();
                    connectedClients = connectedClients.remove(i);
                    i--;
                }

                if(this.set.isSet(this.socket)) {
                    // the listener is ready to read, that means
                    // a new client wants to connect. We accept it here.
                    auto newSocket = this.socket.accept();
                    connectedClients ~= newSocket; // add to our list
                }
            }
        }
    }

    bool isRunning() {
        return this.running;
    }
}

class ControlSocket : BaseSocket {
    
    private Player player;
    private Playlist playlist;
    private CommandLocator cmdLocator;

    this(InternetAddress addr, Player player, Playlist playlist) {
        this.player = player;
        this.playlist = playlist;
        this.cmdLocator = new CommandLocator(this.player, this.playlist);
        auto socket = new TcpSocket();
        socket.bind(addr);
        super(socket);
    }
    
    override char[] handleRequest(char[] requestData) {
        try {
            JsonRpc2Request request = cast(JsonRpc2Request) JsonRpc2Request.parse(to!string(requestData));

            string method = request.getMethod();
            Command cmd = this.cmdLocator.getCommand(method);
            JsonRpc2Response response = cmd.run(request);
            return response.encode().dup();
        } catch (Exception) {
            writeln(requestData);
            return "no".dup();
        }
    }

}
