import std.socket : InternetAddress;
import akaricastd.config : Config;
import akaricastd.socket : ControlSocket;
import akaricastd.player : MpvPlayer;
import akaricastd.playlist : Playlist;

void main() {
    Config config = new Config();
    Playlist playlist = new Playlist();
    MpvPlayer player = new MpvPlayer(config, playlist);
    InternetAddress address = new InternetAddress(config.port);
    ControlSocket socket = new ControlSocket(address, player, playlist);
    socket.listen();
}
