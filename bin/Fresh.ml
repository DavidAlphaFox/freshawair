open Lwt
open Cohttp_lwt_unix

let read_sensors () =
  let url = "http://192.168.0.100/air-data/latest" in
  Lib.Awair.read_local_sensors ~url

let json_headers =
  Cohttp.Header.init_with "content-type" "application/json; charset=utf-8"

let respond_string body =
  Server.respond_string ~headers:json_headers ~status:`OK ~body ()

let sense () =
  read_sensors () >>= fun sensor -> respond_string @@ Lib.Awair.to_json sensor

let on_sense_fail _exn =
  Server.respond_string ~headers:json_headers ~status:`Bad_gateway
    ~body:"Failed to read sensors" ()

let on_callback _conn_id _req _body = Lwt.catch sense on_sense_fail

let server ~port =
  Lwt_io.printf "server started on port %s\n" @@ string_of_int port
  >>= fun _ ->
  Server.create ~mode:(`TCP (`Port port)) (Server.make ~callback:on_callback ())

let () = ignore (Lwt_main.run @@ server ~port:8000)
