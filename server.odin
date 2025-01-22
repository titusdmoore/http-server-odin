package main

import "core:fmt"
import "core:net"
import "core:os"
import "core:strings"
import "http"

ADDR :: "0.0.0.0:1521"

main :: proc() {
    socket, serr := http.initialize_server(ADDR); if serr != nil {
        fmt.println("Unable to initialize")
        return
    }
    defer net.close(socket)

    fmt.println("Listening for connections on", ADDR)
    
    for {
        http.accept_connection(socket)
    }
}
