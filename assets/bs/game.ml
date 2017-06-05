open Tea

type msg =
  | Todo
  [@@bs.deriving {accessors}]

type model = int

let init () = (0, Cmd.none)

let update model = function
  | Todo -> 
    (model, Cmd.none)

let subscriptions _model =
  Sub.none

let view model =
    let open Html in
    text "Game view"

let main =
  App.standardProgram {
    init;
    update;
    view;
    subscriptions;
  }