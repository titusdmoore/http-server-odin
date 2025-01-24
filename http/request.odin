package http

import "core:io"
import "core:net"
import "core:strings"
import "core:fmt"

Request :: struct {
	version:       string,
	method:        RequestMethod,
	path:          string,
	headers:       map[string]string,
	body:          string,
	client_socket: ^net.TCP_Socket,
}

RequestMethod :: enum {
	GET,
	POST,
	PUT,
	DELETE,
}
get_request_method :: proc(str_method: string) -> RequestMethod {
        switch {
                case strings.compare("POST", str_method) == 0:
                        return RequestMethod.POST

                case strings.compare("PUT", str_method) == 0:
                        return RequestMethod.PUT

                case strings.compare("DELETE", str_method) == 0:
                        return RequestMethod.DELETE

                case: 
                        return RequestMethod.GET
        }
}

// Remove ok to err
parse_header :: proc(str_header: string) -> (method: RequestMethod, route: string, version: string, ok: bool) {
        segments, err := strings.split(str_header, " "); if err != nil {
                fmt.println("Unable to parse header segments")
                return RequestMethod.GET, "", "", false
        }

        return get_request_method(segments[0]), segments[1], segments[2], true
}

parse_request_and_echo :: proc(
	request: []u8,
	client_socket: ^net.TCP_Socket,
) -> (
	int,
	net.Network_Error,
) {
	return send_response(request, Request{client_socket = client_socket})
}

// Convert bool to error
parse_request :: proc(request: []u8, socket: ^net.TCP_Socket) -> (Request, bool) {
        request_parts, split_err := strings.split(transmute(string)request, "\r\n"); if split_err != nil {
                fmt.println("Unable to allocate needed memory to parse request")
                return Request{}, false
        }

        fmt.println("Count of request parts", len(request_parts))
        ptr := 0
        method, path, version, ok := parse_header(request_parts[ptr]); if !ok {
                fmt.println("Unable to parse header")
                return Request{}, false
        }
        ptr += 1


	return Request {
			method = method,
			path = path,
			headers = nil,
			body = "",
			client_socket = socket,
		},
		true
}

