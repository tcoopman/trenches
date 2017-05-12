import {View} from '../Types';
import {Socket} from "phoenix";

const socket = new Socket("/socket", {})

export default class LobbyView implements View {
    constructor() {}
    mount() {
        socket.connect({"player_name": (window as any).currentUser});
        const lobbyChannel = socket.channel("lobby", {player_id: "thomas"});
        lobbyChannel.join()
            .receive("ok", () => console.log("joined"));
        console.log("LobbyView mounted");
    }
    unmount() {
        console.log("LobbyView unmounted");
    }
}