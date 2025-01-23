package http

import "core:net"
import "core:strings"
import "core:os"
import "core:fmt"

READ_BUF_SIZE :: 1024

Server_Initialize_Error :: union #shared_nil {
    ParseEndpointError,
    net.Network_Error
}

ParseEndpointError :: enum {
    None = 0,
    EndpointError
} 

initialize_server :: proc(address: string) -> (socket: net.TCP_Socket, err: Server_Initialize_Error) {
    endpoint, ok := net.parse_endpoint(address); if !ok {
        return net.TCP_Socket{}, ParseEndpointError.None
    }

    return net.listen_tcp(endpoint)
}

accept_connection :: proc(server_socket: net.TCP_Socket) {
    client, _, cerr := net.accept_tcp(server_socket); if cerr != nil {
        fmt.println("Unable to accept connections.")
        return
    }
    defer net.close(client) 

    buf, berr := make_slice([]u8, READ_BUF_SIZE); if berr != nil {
        fmt.println("Unable to allocate read buffer")
        return
    }
    full_message: [dynamic]u8
    len: int;

    for {
        read_len, read_err := net.recv_tcp(client, buf); if read_err != nil {
        fmt.println("Unable to read from stream")
            break;
        }
        append(&full_message, ..buf[:])
        len += read_len

        // If we have read less than full buf, message is over. We can end reading.
        if read_len < READ_BUF_SIZE {
            break
        }
    }

    request, is_ok := parse_request(full_message[:], &client); if !is_ok {
        fmt.println("Unable to parse request")
    }

    tmp_st := "HTTP/1.1 200 OK\r\n\r\n"
    file_content, file_err := os.read_entire_file_or_err("./public/index.html"); if file_err != nil {
        tmp_st = "HTTP/1.1 500 Internal Server Error\r\n"
        parse_request_and_echo(transmute([]u8)tmp_st, &client)
        return
    }

    tmp_st = strings.concatenate({tmp_st, transmute(string)file_content})
    parse_request_and_echo(transmute([]u8)tmp_st, &client)
}
