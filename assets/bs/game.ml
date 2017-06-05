open Tea

type msg =
  | GameJoined of string
  | GameJoinedFailed of string
  [@@bs.deriving {accessors}]

type model = {
  game_name: string option;
  join_error: string option;
}

external currentUser : string option = "" [@@bs.val] [@@bs.return null_undefined_to_opt]
external game_name : string option = "" [@@bs.val] [@@bs.return null_undefined_to_opt]

type game_joined_error_payload = < error : string Js.null_undefined > Js.t

let init () = 
  let empty_model = {game_name = None; join_error = None} in
  match (currentUser, game_name) with
    | (Some name, Some game_name) ->
      let opts = [%bs.obj { params = { player_name = name}}] in
      let socket = Phoenix.Socket.create ~options:opts "/socket" 
      |> Phoenix.Socket.connect
      in
      let channel = Phoenix.Socket.channel ("game:" ^ game_name) socket in
      let cmds = Cmd.call (fun callbacks ->
        Phoenix.Channel.join channel 
        |> Phoenix.Channel.receive (`ok (fun _ -> print_endline "joined game"))
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
      ) in
      ({empty_model with game_name = Some game_name}, cmds)
    | _ -> 
      (empty_model, Cmd.none)

let update model = function
  | GameJoined _s -> 
    (model, Cmd.none)
  | GameJoinedFailed error -> 
    ({model with join_error = Some error}, Cmd.none)

let subscriptions _model =
  Sub.none

let view model =
    let open Html in
    match model.join_error with
      | Some error ->
        div [class' "ui error message"] [
          div [class' "header"] [text "Fatal error while joining the game"] ;
          p [] [text error]
        ]
      | None ->
        text "ok"

let main =
  App.standardProgram {
    init;
    update;
    view;
    subscriptions;
  }