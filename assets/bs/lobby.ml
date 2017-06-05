open Tea

type game_status = WaitingForPlayers | CountdownToStart | Unknown
type game = {
  name : string;
  created_at : Js.Date.t;
  created_by : string;
  status : game_status;
  nb_players: int;
}

type msg =
  | UpdateNewGameName of string
  | CreateNewGame
  | CreateNewGameSucceeded 
  | NewGameCreated of game
  | GamesInitialized of game list
  | CreateNewGameFailed of string
  | RemoveErrorFromCreateNewGame
  | JoinGame of string
  [@@bs.deriving {accessors}]

type model = {
  new_game_name : string;
  create_error: string option;
  games: (game list) option;
  channel: Phoenix.Channel.t option;
}

external currentUser : string option = "" [@@bs.val] [@@bs.return null_undefined_to_opt]

type game_object = < name : string ; created_at : string ; status : string ; created_by : string ; nb_players : int> Js.t
type game_created_payload = < game : game_object Js.null_undefined > Js.t
type lobby_joined_payload = < games : game_object array Js.null_undefined > Js.t
type game_created_error_payload = < error : string Js.null_undefined > Js.t

let game_object_to_game game_object =
  let to_status status =
    match status with
      | "waiting_for_players" -> WaitingForPlayers
      | "countdown_to_start" -> CountdownToStart
      | _ -> Unknown
  in
  let to_date date_string =
    Js.Date.fromString date_string
  in
  { name= game_object##name ; 
    created_at= (to_date game_object##created_at) ; 
    created_by = game_object##created_by ;
    status= (to_status game_object##status); 
    nb_players = game_object##nb_players;
  }

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
  let empty_model = {
    new_game_name = "";
    games = None;
    channel = None;
    create_error = None;
  }
  in
  match user_name with
    | Some name ->
      let opts = [%bs.obj { params = { player_name = name}}] in
      let socket = Phoenix.Socket.create ~options:opts "/socket" 
      |> Phoenix.Socket.connect in
      let channel = Phoenix.Socket.channel "lobby" socket in
      let joinCommands = Cmd.call (fun callbacks -> 
        Phoenix.Channel.join channel 
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
      let model = {empty_model with channel = Some channel } in
      (model, Cmd.batch [eventCommands; joinCommands])
    | None ->
      (empty_model, Cmd.none)

external window : Dom.window = "" [@@bs.val]
external setLocation : Dom.window -> string -> unit = "location" [@@bs.set]

let update model = function
  | UpdateNewGameName name -> 
    ({model with new_game_name = name}, Cmd.none)
  | CreateNewGameSucceeded ->
    print_endline "NEW GAME CREATED";
    (model, Cmd.none)
  | CreateNewGameFailed error ->
    ({model with create_error = Some error}, Cmd.none)
  | RemoveErrorFromCreateNewGame ->
    ({model with create_error = None}, Cmd.none)
  | NewGameCreated game ->
    begin match model.games with
      | None -> 
        (model, Cmd.none)
      | Some games -> 
        ({model with games = Some (game :: games)}, Cmd.none)
    end
  | GamesInitialized games ->
    ({model with games = Some games}, Cmd.none)
  | JoinGame name ->
    setLocation window ("/game/" ^ name);
    (model, Cmd.none)
  | CreateNewGame ->
      match model.channel with
        | Some c ->
          let cmd = Cmd.call (fun callbacks -> 
            let payload = [%bs.obj {game_name = model.new_game_name}] in
            Phoenix.Channel.push "create_game" payload c
            |> Phoenix.Channel.receive (`ok (fun _ -> 
              !callbacks.enqueue createNewGameSucceeded
            ))
            |> Phoenix.Channel.receive (`error (fun (p: game_created_error_payload) ->
              let error_opt = p##error |> Js.Null_undefined.to_opt in
              match error_opt with
                | Some error  -> !callbacks.enqueue (createNewGameFailed error)
                | None -> !callbacks.enqueue (createNewGameFailed "Unknown error")
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
  let view_status nb_players status =
    match status with
      | WaitingForPlayers ->
        div [class' "content"] [
          i [class' "flag icon green"] [] ; 
          text "Waiting for players";
          div [class' "discripton"] [ text ((string_of_int nb_players) ^ " player already joined!")]
        ]
      | CountdownToStart ->
        div [class' "content"] [
          i [class' "hourglass start icon red"] []; 
          text "Starting..."
        ]
      | Unknown ->
        div [class' "content"] [
          i [class' "help icon red"] [] ; text "Unknown"
        ]
  in
  let view_actions name status = 
    match status with
      | WaitingForPlayers ->
        div [class' "extra content"] [
          button [class' "ui basic green button"; onClick (joinGame name)] [ text "Join game"] ;
          button [class' "ui basic orange button"] [ text "Specate"] ;
        ]
      | CountdownToStart ->
        div [class' "extra content"] [
          button [class' "ui basic orange button"] [ text "Specate"] ;
        ]
      | Unknown -> noNode
  in
  let format_date date =
    Js.Date.toDateString date
  in
  let view_game game =
    div [class' "card raised"] [
      div [class' "content"] [
        div [class' "header"] [ text game.name ];
        div [class' "meta float right"] [ text ("Created at: " ^ (format_date game.created_at))] ;
        div [class' "meta float right"] [ text ("Created by: " ^ (game.created_by))] ;
      ] ;
      view_status game.nb_players game.status ;
      view_actions game.name game.status
    ]
  in
  match games_option with
    | None ->
      div [class' "ui segment"] [
        div [class' "ui active inverted dimmer"] [
          div [class' "ui text loader"] [ text "Loading"]
        ] ;
      ]
    | Some games ->
        div [class' "ui cards"] (List.map view_game games)


let view_create_form model =
  let open Html in
  let view_creation_error = function
    | Some error ->
        div [class' "ui visible error message"] [
          i [class' "close icon"; onClick removeErrorFromCreateNewGame] [];
          div [class' "header"] [text "There was an error creating the game"] ;
          p [] [text error]
        ];
    | None -> noNode
  in
  let input_class = function
    | Some _ -> "field error"
    | None -> "field"
  in
  div [id "new-game"; class' "ui form"] [
    div [class' (input_class model.create_error)] [
      label [] [text "Game name"] ;
      input' [
        type' "text"; 
        name "game-name"; 
        placeholder "Gamen name";
        onInput updateNewGameName;
      ] [];
    ];
    view_creation_error model.create_error;
    button [class' "ui button"; onClick createNewGame] [ text "Create new game"]
  ]

let view model =
  match model.channel with
    | None -> viewInvald
    | Some _ ->
      let open Html in
      div
        []
        [ h1 [class' "ui header"] [ text "Welcome in the lobby"] ;
          h2 [class' "ui header"] [ text "Create a new Game"] ;
          view_create_form model;
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