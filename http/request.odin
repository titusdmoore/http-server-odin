package http 

import "core:net"

parse_request :: proc(request: []u8, client_socket: net.TCP_Socket) -> (int, net.Network_Error) {
        return net.send_tcp(client_socket, request)
}
