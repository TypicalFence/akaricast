import std.socket : InternetAddress;
import akaricastd.socket : ControlSocket;
import akaricastd.player : MpvPlayer;

void main() {
    InternetAddress address = new InternetAddress(1337);
    MpvPlayer player = new MpvPlayer();
    ControlSocket socket = new ControlSocket(address, player);
    socket.listen();
}
