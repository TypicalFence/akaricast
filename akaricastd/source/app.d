import std.socket : InternetAddress;
import akaricastd.socket : ControlSocket;

void main() {
    InternetAddress address = new InternetAddress(1337);
    ControlSocket socket = new ControlSocket(address);
    socket.listen();
}
