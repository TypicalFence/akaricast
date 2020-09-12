import std.socket : InternetAddress;
import akaricastd.config : Config;
import akaricastd.socket : ControlSocket;
import akaricastd.player : MpvPlayer;

void main() {
    Config config = new Config();
    InternetAddress address = new InternetAddress(config.port);
    MpvPlayer player = new MpvPlayer(config);
    ControlSocket socket = new ControlSocket(address, player);
    socket.listen();
}
