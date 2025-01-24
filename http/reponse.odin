package http

import "core:os"
import "core:strings"
import "core:net"

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


get_file_for_path :: proc(path: string) -> (file: os.File_Info, err: os.Error) {
    updated_path := path

    for reserved_path in RESERVED_PATHS {
        if strings.compare(reserved_path.initial_path, updated_path) == 0 {
            updated_path = reserved_path.updated_path
        }
    }

    file_path, cct_err := strings.concatenate({SRC_PATH, "/", path})

    fd, foerr := os.open(SRC_PATH); if foerr != nil {
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
        return ""
    }


    return ""
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