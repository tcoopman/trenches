module Channel : sig
    type t
    type joined_t
    val join : t -> joined_t
    val on : string -> ('a Js.t -> unit) -> t -> t
    external receive : ([`ok of 'a Js.t -> unit| `error of 'b -> unit][@bs.string]) -> joined_t = "" [@@bs.send.pipe: joined_t]
    val push : string -> 'a Js.t -> t -> joined_t 
end = struct
    type t
    type joined_t

    external join : t -> joined_t = "join" [@@bs.send]

    external receive : ([`ok of 'a Js.t -> unit | `error of 'b -> unit][@bs.string]) -> joined_t = "" [@@bs.send.pipe: joined_t]

    external on : string -> ('a Js.t -> unit) -> t = "" [@@bs.send.pipe: t]
    external push : t -> string -> 'a Js.t -> joined_t = "" [@@bs.send]
    let push msg payload channel =
        push channel msg payload
end

module Socket : sig
    type t
    val create : ?options: 'a Js.t -> string -> t
    val connect : t -> t
    val channel : string -> t -> Channel.t
end = struct
    type t

    external create : string -> ?options:'a Js.t -> unit -> t = "Socket" [@@bs.new] [@@bs.module "phoenix"]
    let create ?options string =
        begin match options with
            | None -> 
                create string ()
            | Some opt ->
                create string ~options:opt ()
        end;


    external connect : t -> unit = "" [@@bs.send]
    let connect socket =
        connect socket;
        socket

    external channel : t -> string -> Channel.t = "" [@@bs.send]
    let channel name socket = channel socket name
end
