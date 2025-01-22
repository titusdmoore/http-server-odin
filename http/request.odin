package http 

import "core:net"
import "core:io"
import "core:strings"

Request :: struct {
        method: RequestMethod,
        path: string,
        headers: map[string]string,
        body: string,
		client_socket: ^net.TCP_Socket
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
parse_request :: proc(request: []u8, socket: ^net.TCP_Socket) -> (Request, bool) {
        return Request{
			method = RequestMethod.GET,
			path = "/",
			headers = nil,
			body = "",
			client_socket = socket
		}, true
}

send_response :: proc(response: []u8, request: Request) {
        return net.send_tcp(request.client_socket^, response)
}
