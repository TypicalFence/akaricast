import core.stdc.stdlib : exit;
import std.socket : InternetAddress, SocketOSException;
import std.experimental.logger;
import akaricastd.config : Config;
import akaricastd.socket : ControlSocket;
import akaricastd.player : MpvPlayer;
import akaricastd.playlist : Playlist;

void main() {
    Config config = new Config();
    Playlist playlist = new Playlist();
    MpvPlayer player = new MpvPlayer(config, playlist);
    InternetAddress address = new InternetAddress(config.port);
    ControlSocket socket;

    try {
        socket = new ControlSocket(address, player, playlist);
    } catch(SocketOSException) {
        // exit when we can't bind the socket to the address
        fatal("could not bind socket to address");
        exit(1);
    }

    socket.listen();
}
