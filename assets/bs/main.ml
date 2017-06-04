open Tea

type msg =
  | UpdateNewGameName of string
  | CreateNewGame
  | CreateNewGameSucceeded 
  | NewGameCreated of string
  | CreateNewGameFailed
  [@@bs.deriving {accessors}]

type model = {
  new_game_name : string;
  games: string list;
  channel: Phoenix.Channel.t option;
}

external currentUser : string option = "" [@@bs.val] [@@bs.return null_undefined_to_opt]

type game_created_payload = < game_name : string Js.null_undefined [@bs.get {undefined; null}] > Js.t

let init () =
  let user_name = currentUser in
  match user_name with
    | Some name ->
      let opts = [%bs.obj { params = { player_name = name}}] in
      let socket = Phoenix.Socket.create ~options:opts "/socket" 
      |> Phoenix.Socket.connect in
      let channel = Phoenix.Socket.channel "lobby" socket in
      Phoenix.Channel.join "lobby" channel 
      |> Phoenix.Channel.receive (`ok (fun _ -> print_endline "received ok"))
      |> Phoenix.Channel.receive (`error (fun _ -> print_endline "received error"))
      |> ignore;
      let cmd = Cmd.call (fun callbacks ->
        Phoenix.Channel.on "game_created" (fun (x: game_created_payload) -> 
          let optName = x##game_name |> Js.Null_undefined.to_opt in 
          match optName with
            | Some name  -> !callbacks.enqueue (newGameCreated name)
            | None -> print_endline "Illegal value received???"
        ) channel |> ignore;

      ) in
      let model = {
        new_game_name = "";
        games = [];
        channel = Some channel
      } in
      (model, cmd)
    | None ->
      let model = {
        new_game_name = "";
        games = [];
        channel = None
      } in
      (model, Cmd.none)

let update model = function
  | UpdateNewGameName name -> 
    ({model with new_game_name = name}, Cmd.none)
  | CreateNewGameSucceeded ->
    print_endline "NEW GAME CREATED";
    (model, Cmd.none)
  | CreateNewGameFailed ->
    print_endline "NEW GAME CREATED Failed";
    (model, Cmd.none)
  | NewGameCreated name ->
    ({model with games = (name :: model.games)}, Cmd.none)
  | CreateNewGame ->
      match model.channel with
        | Some c ->
          let cmd = Cmd.call (fun callbacks -> 
            let payload = [%bs.obj {game_name = model.new_game_name}] in
            Phoenix.Channel.push "create_game" payload c
            |> Phoenix.Channel.receive (`ok (fun _ -> 
              !callbacks.enqueue createNewGameSucceeded
            ))
            |> Phoenix.Channel.receive (`error (fun _ ->
              !callbacks.enqueue createNewGameFailed
            ))
            |> ignore;
          ) in
          (model, cmd)
        | None -> 
          (model, Cmd.none)

let subscriptions _model =
  Sub.none

let viewInvald =
  let open Html in
  div [] [ text "Initializing..."]

let view model =
  match model.channel with
    | None -> viewInvald
    | Some _ ->
      let open Html in
      div
        []
        [ h1 [class' "ui header"] [ text "Welcome in the lobby"] ;
          h2 [class' "ui header"] [ text "Create a new Game"] ;
          div [id "new-game"; class' "ui form"] [
            div [class' "field"] [
              label [] [text "Game name"] ;
              input' [
                type' "text"; 
                name "game-name"; 
                placeholder "Gamen name";
                onInput updateNewGameName;
              ] []
            ] ;
            button [class' "ui button"; onClick createNewGame] [ text "Create new game"]
          ] ;
          h2 [class' "ui header"] [ text "Open games"] ;
          ul [] (List.map (fun game -> 
            li [] [ text game]
          ) model.games)
        ]

let main =
  App.standardProgram {
    init;
    update;
    view;
    subscriptions;
  }