open Tea

type game = {
  countdown_clock: int;
}

type msg =
  | GameJoined 
  | GameJoinedFailed of string
  | Tick of game
  [@@bs.deriving {accessors}]

type model = {
  game_name: string option;
  join_error: string option;
  joined : bool;
  game : game option;
}

external currentUser : string option = "" [@@bs.val] [@@bs.return null_undefined_to_opt]
external game_name : string option = "" [@@bs.val] [@@bs.return null_undefined_to_opt]

type game_joined_error_payload = < error : string Js.null_undefined > Js.t
type game_payload = < countdown_clock : int > Js.t
type tick_payload = < game : game_payload Js.null_undefined > Js.t

let game_payload_to_game payload =
  { countdown_clock = payload##countdown_clock }

let init () = 
  let empty_model = {game_name = None; join_error = None; joined = false; game = None} in
  match (currentUser, game_name) with
    | (Some name, Some game_name) ->
      let opts = [%bs.obj { params = { player_name = name}}] in
      let socket = Phoenix.Socket.create ~options:opts "/socket" 
      |> Phoenix.Socket.connect
      in
      let channel = Phoenix.Socket.channel ("game:" ^ game_name) socket in
      let cmds = Cmd.call (fun callbacks ->
        Phoenix.Channel.join channel 
        |> Phoenix.Channel.receive (`ok (fun _ -> !callbacks.enqueue GameJoined))
        |> Phoenix.Channel.receive (`error (fun (p: string Js.null_undefined) -> 
          let error_option = p |> Js.Null_undefined.to_opt in
          match error_option with
            | Some error ->
              !callbacks.enqueue (gameJoinedFailed error)
            | None ->
              [%bs.debugger];
              !callbacks.enqueue (gameJoinedFailed "Unknown error")
        ))
        |> ignore;
        Phoenix.Channel.on "tick" (fun (p: tick_payload) ->
          let game_option = p##game |> Js.Null_undefined.to_opt in
          match game_option with
            | Some game -> !callbacks.enqueue (tick (game_payload_to_game game))
            | None -> [%bs.debugger];
        ) channel 
        |> ignore;
      ) in
      ({empty_model with game_name = Some game_name}, cmds)
    | _ -> 
      (empty_model, Cmd.none)

let update model = function
  | GameJoined -> 
    ({model with joined = true}, Cmd.none)
  | GameJoinedFailed error -> 
    ({model with join_error = Some error}, Cmd.none)
  | Tick game ->
    ({model with game = Some game}, Cmd.none)

let subscriptions _model =
  Sub.none

let view_game game =
  let open Html in
  match game with
    | Some game ->
      text (string_of_int game.countdown_clock)
    | None ->
      text "No game???"

let view model =
    let open Html in
    match model.join_error with
      | Some error ->
        div [class' "ui error message"] [
          div [class' "header"] [text "Fatal error while joining the game"] ;
          p [] [text error]
        ]
      | None -> view_game model.game

let main =
  App.standardProgram {
    init;
    update;
    view;
    subscriptions;
  }