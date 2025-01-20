package main

import "core:fmt"
import "core:net"
import "core:os"
import "core:strings"
import "http"

ADDR :: "0.0.0.0:1521"
READ_BUF_SIZE :: 1024

find_file_path :: proc() {

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
		len: int;

        read_loop: for {
            read_len, read_err := net.recv_tcp(client, buf); if err != nil {
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

		tmp_st := "HTTP/1.1 200 OK\r\n\r\n"
		file_content, file_err := os.read_entire_file_from_filename_or_err("./public/index.html"); if file_err != nil {
			tmp_st = "HTTP/1.1 500 Internal Server Error\r\n"
			http.parse_request(transmute([]u8)tmp_st, client)
			continue
		}

		tmp_st = strings.concatenate({tmp_st, transmute(string)file_content})
		http.parse_request(transmute([]u8)tmp_st, client)
		// parse_request(full_message[:len], client)
    }
}
