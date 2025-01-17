package main

import "core:fmt"
import "core:net"

ADDR :: "0.0.0.0:1521"
READ_BUF_SIZE :: 1024

parse_request :: proc(request: []u8, client_socket: net.TCP_Socket) -> (int, net.Network_Error) {
        return net.send_tcp(client_socket, request)
}

main :: proc() {
    endpoint, ok := net.parse_endpoint(ADDR); if !ok {
        fmt.println("Unable to create endpoint", ADDR)
        return
    }

    socket, err := net.listen_tcp(endpoint); if err != nil {
        fmt.println("Unable to listen on tcp endpoint");
        return
    } 
    defer net.close(socket)

    fmt.println("Connected to ADDR: ", ADDR)
    fmt.println("Ready for requests")

    for {
        client, _, cerr := net.accept_tcp(socket); if cerr != nil {
            fmt.println("Unable to accept connections on ADDR: ", ADDR)
            return
        }
        defer net.close(client)

        buf, berr := make_slice([]u8, READ_BUF_SIZE); if berr != nil {
            fmt.println("Unable to allocate read buffer")
            return
        }
        full_message: [dynamic]u8

        read_loop: for {
            read_len, read_err := net.recv_tcp(client, buf); if err != nil {
                fmt.println("Unable to read from stream")
                break;
            }
            append(&full_message, ..buf[:])

            // If we have read less than full buf, message is over. We can end reading.
            if read_len < READ_BUF_SIZE {
                break
            }
        }

    }
}