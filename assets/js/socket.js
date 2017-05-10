// NOTE: The contents of this file will only be executed if
// you uncomment its entry in "assets/js/app.js".

// To use Phoenix channels, the first step is to import Socket
// and connect at the socket path in "lib/web/endpoint.ex":
import {Socket} from "phoenix"

let socket = new Socket("/socket", {params: {token: window.userToken}})

// When you connect, you'll often need to authenticate the client.
// For example, imagine you have an authentication plug, `MyAuth`,
// which authenticates the session and assigns a `:current_user`.
// If the current user exists you can assign the user's token in
// the connection for use in the layout.
//
// In your "lib/web/router.ex":
//
//     pipeline :browser do
//       ...
//       plug MyAuth
//       plug :put_user_token
//     end
//
//     defp put_user_token(conn, _) do
//       if current_user = conn.assigns[:current_user] do
//         token = Phoenix.Token.sign(conn, "user socket", current_user.id)
//         assign(conn, :user_token, token)
//       else
//         conn
//       end
//     end
//
// Now you need to pass this token to JavaScript. You can do so
// inside a script tag in "lib/web/templates/layout/app.html.eex":
//
//     <script>window.userToken = "<%= assigns[:user_token] %>";</script>
//
// You will need to verify the user token in the "connect/2" function
// in "lib/web/channels/user_socket.ex":
//
//     def connect(%{"token" => token}, socket) do
//       # max_age: 1209600 is equivalent to two weeks in seconds
//       case Phoenix.Token.verify(socket, "user socket", token, max_age: 1209600) do
//         {:ok, user_id} ->
//           {:ok, assign(socket, :user, user_id)}
//         {:error, reason} ->
//           :error
//       end
//     end
//
// Finally, pass the token on connect as below. Or remove it
// from connect if you don't care about authentication.

const playerId = 1;
const canvas = document.getElementById('canvas');
const context = canvas.getContext('2d');
canvas.width = window.innerWidth;
canvas.height = window.innerHeight;

document.addEventListener('keyup', addSoldier);

function addSoldier(evt) {
  console.log(evt.which);
  if(evt.which == 83) {
    game1Channel.push("new_unit", {'id': playerId, 'type': 'soldier'});
  }
  if(evt.which == 84) {
    game1Channel.push("new_unit", {'id': playerId, 'type': 'tank'});
  }
}

function join(resp) {
  console.log("Joined successfully", resp);
  context.beginPath();
  context.font = "24px Helvetica";
  context.fillStyle = 'black';
  context.fillText('Joined Succesfully', 200, 200);
  playerJoined(playerId)
}

function playerJoined(resp) {
  console.log("Player joined", resp);
  drawScenery();
  context.beginPath();
  context.font = "24px Helvetica";
  context.fillStyle = 'white';
  context.fillText('You are player #' + playerId, 200, 200);
}

function drawScenery() {
  context.beginPath();
  context.fillStyle = 'black';
  context.fillRect(0,0,canvas.width,400);
}

// setInterval(tick, 500);

function drawState(resp) {
  console.log(resp);
  for (let i = 0; i < resp.players.length; i++) {
    let player = resp.players[i];
    for (let j = 0; j < player.units.length; j++) {
      let unit = player.units[j];
      drawUnit(unit, i%2===0);
    }
  }
}

function positionOf(unit, goingEast) {
  if(goingEast) {
    return (unit.position/100) * canvas.width;
  } else {
    return ((100 - unit.position)/100) * canvas.width;
  }
}

function drawUnit(unit, direction) {
  context.beginPath();
  if(unit.type == 'soldier') {
    context.fillStyle = 'white';
    context.fillRect(positionOf(unit, direction),200,10,10);
  }
  if(unit.type == 'tank') {
    context.fillStyle = 'green';
    context.fillRect(positionOf(unit, direction),200,20,15);
  }
}


function tick(resp) {
  console.log('tick');
  drawScenery();
  drawState(resp);
}

socket.connect()

// Now that you are connected, you can join channels with a topic:

const lobbyChannel = socket.channel("lobby", {player_id: playerId})
lobbyChannel.join()
  .receive("ok", lobbyJoined)
  .receive("error", resp => console.log("unable to join lobby", resp))

function lobbyJoined() {
  const gameName = "game 1";
  lobbyChannel
    .push("open_game", {game_name: gameName})
    .receive("ok", () => joinGame(gameName));
}

function joinGame(gameName) {
  let game1Channel = socket.channel(`game:${gameName}`, {player_id: playerId})
  game1Channel.join()
    .receive("ok", join)
    .receive("error", resp => { console.log("Unable to join", resp) });

  game1Channel.on("tick", tick);

}

export default socket
