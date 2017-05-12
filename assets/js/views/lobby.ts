import {View} from '../Types';

export default class LobbyView implements View {
    constructor() {}
    mount() {
        console.log("LobbyView mounted");
    }
    unmount() {
        console.log("LobbyView unmounted");
    }
}