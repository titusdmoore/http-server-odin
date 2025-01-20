package http 

import "core:net"

Request :: struct {
        method: RequestMethod,
        path: string,
        headers: map[string]string,
        body: string
}

RequestMethod :: enum {
        GET,
        POST,
        PUT,
        DELETE,
}

parse_request_and_echo :: proc(request: []u8, client_socket: net.TCP_Socket) -> (int, net.Network_Error) {
        return net.send_tcp(client_socket, request)
}

// Convert bool to error
parse_request :: proc(request: []u8) -> (Request, bool) {
        return Request{}, true
}
