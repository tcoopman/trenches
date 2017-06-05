open Tea

type game = {
  name : string;
  created_at : string;
  status : string;
}

type msg =
  | UpdateNewGameName of string
  | CreateNewGame
  | CreateNewGameSucceeded 
  | NewGameCreated of game
  | GamesInitialized of game list
  | CreateNewGameFailed
  [@@bs.deriving {accessors}]

type model = {
  new_game_name : string;
  games: (game list) option;
  channel: Phoenix.Channel.t option;
}

external currentUser : string option = "" [@@bs.val] [@@bs.return null_undefined_to_opt]

type game_object = < name : string ; created_at : string ; status : string > Js.t
type game_created_payload = < game : game_object Js.null_undefined > Js.t
type lobby_joined_payload = < games : game_object array Js.null_undefined > Js.t

let game_object_to_game game_object =
  { name= game_object##name ; created_at= game_object##created_at ; status= game_object##status; }

let lobby_payload_to_game_list payload =
    let game_objects = payload##games |> Js.Null_undefined.to_opt in
    match game_objects with
      | Some objects -> 
        let games = objects
        |> Array.to_list
        |> List.map game_object_to_game in
        Some games
      | None ->
        None

let init () =
  let user_name = currentUser in
  match user_name with
    | Some name ->
      let opts = [%bs.obj { params = { player_name = name}}] in
      let socket = Phoenix.Socket.create ~options:opts "/socket" 
      |> Phoenix.Socket.connect in
      let channel = Phoenix.Socket.channel "lobby" socket in
      let joinCommands = Cmd.call (fun callbacks -> 
        Phoenix.Channel.join "lobby" channel 
        |> Phoenix.Channel.receive (`ok (fun (x: lobby_joined_payload) -> 
          match lobby_payload_to_game_list x with
            | Some games ->
              !callbacks.enqueue (gamesInitialized games)
            | None ->
              print_endline "No games received on join???"
        ))
        |> Phoenix.Channel.receive (`error (fun _ -> print_endline "received error"))
        |> ignore;
      ) in
      let eventCommands = Cmd.call (fun callbacks ->
        Phoenix.Channel.on "game_created" (fun (x: game_created_payload) -> 
          let game_object_option = x##game |> Js.Null_undefined.to_opt in 
          match game_object_option with
            | Some game_object  -> !callbacks.enqueue (newGameCreated (game_object_to_game game_object))
            | None -> print_endline "Illegal value received???"
        ) channel |> ignore;

      ) in
      let model = {
        new_game_name = "";
        games = None;
        channel = Some channel
      } in
      (model, Cmd.batch [eventCommands; joinCommands])
    | None ->
      let model = {
        new_game_name = "";
        games = None;
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
  | NewGameCreated game ->
    begin match model.games with
      | None -> 
        (model, Cmd.none)
      | Some games -> 
        ({model with games = Some (game :: games)}, Cmd.none)
    end
  | GamesInitialized games ->
    ({model with games = Some games}, Cmd.none)
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

let view_games games_option =
  let open Html in
  let view_game game =
    div [class' "ui card"] [
      div [class' "content"] [
        div [class' "right floated meta"] [ text game.created_at] ;
        text game.name
      ]
    ]
  in
  match games_option with
    | None ->
      div [class' "ui segment"] [
        div [class' "ui active inverted dimmer"] [
          div [class' "ui text loader"] [ text "Loading"]
        ]
      ]
    | Some games ->
        div [class' "ui link cards"] (List.map view_game games)

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
          view_games model.games
        ]

let main =
  App.standardProgram {
    init;
    update;
    view;
    subscriptions;
  }