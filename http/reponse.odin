#+feature dynamic-literals

package http

import "core:os"
import "core:strings"
import "core:net"
import "core:fmt"

SRC_PATH :: "./public"

Reserved_Path :: struct {
    initial_path: string,
    updated_path: string
}

RESERVED_PATHS: []Reserved_Path : {
    Reserved_Path{
        initial_path = "/",
        updated_path = "index.html"
    }
}

Path_Lookup_Error :: union #shared_nil {
    Lookup_Error,
    os.Error
}
Lookup_Error :: enum {
    None = 0,
    NotFound,
    AccessDenied
}


get_file_for_path :: proc(path: string) -> (file: os.File_Info, err: Path_Lookup_Error) {
    updated_path := path

    for reserved_path in RESERVED_PATHS {
        if strings.compare(reserved_path.initial_path, updated_path) == 0 {
            updated_path = reserved_path.updated_path
        }
    }

    file_path, cct_err := strings.concatenate({SRC_PATH, "/", updated_path})

    if !os.is_file(file_path) {
        return os.File_Info{}, Lookup_Error.NotFound
    }

    fd, foerr := os.open(file_path); if foerr != nil {
        return os.File_Info{}, foerr
    } 
    defer os.close(fd)

    fs, fserr := os.fstat(fd); if fserr != nil {
        return os.File_Info{}, fserr
    }

    return fs, nil
}

build_get_response :: proc(request: Request) -> string {
    path_file, err := get_file_for_path(request.path); if err != nil {
        // 500 or possible 404
        if err == Lookup_Error.NotFound {
            return "HTTP/1.1 404 File Not Found\r\n"
        }

        return "HTTP/1.1 500 Internal Server Error\r\n"
    }

    
    resp_str := "HTTP/1.1 200 OK\r\n\r\n"
    file_content, file_err := os.read_entire_file_or_err(path_file.fullpath); if file_err != nil {
        return "HTTP/1.1 500 Internal Server Error\r\n"
    }

    resp_str = strings.concatenate({resp_str, transmute(string)file_content})

    return resp_str 
}

send_response :: proc(
	response: []u8,
	request: Request,
) -> (
	bytes_written: int,
	err: net.Network_Error,
) {
	return net.send_tcp(request.client_socket^, response)
}