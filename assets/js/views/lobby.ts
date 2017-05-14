import {View} from '../Types';
import {Socket, Channel} from "phoenix";

const socket = new Socket("/socket", {});

export default class LobbyView implements View {
    lobbyChannel: Channel;
    constructor() {}
    mount() {
        socket.connect({"player_name": (window as any).currentUser});
        this.lobbyChannel = socket.channel("lobby", {});
        this.lobbyChannel
            .join()
            .receive("ok", this.bindOnSubmit.bind(this));

        this.lobbyChannel.on("game_opened", this.updateGamesList);
    }
    unmount() {
        console.log("LobbyView unmounted");
    }

    bindOnSubmit() {
        const form = document.getElementById("new-game");
        if (form) {
            form.onsubmit = (event: Event) => {
                event.preventDefault();
                this.lobbyChannel
                    .push("open_game", {game_name: "new game2"})
                    .receive("ok", () => console.log("Opened a game"))
                    .receive("error", () => console.error("failed to open a game"));
            }
        }
    }

    updateGamesList(games: any) {
        console.log(games);
    }
}