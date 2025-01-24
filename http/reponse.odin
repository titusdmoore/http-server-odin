package http

import "core:os"
import "core:strings"

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

    file_path, cct_err := strings.concatenate({SRC_PATH, "/", path})

    fd, fo_err := os.open(SRC_PATH); if err != nil {
        return os.File_Info{}, fo_err
    } 

    return os.File_Info{}, nil
}