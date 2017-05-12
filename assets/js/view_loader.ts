// @ts-check
import LobbyIndexView from './views/lobby';
import {View, ViewConstructor} from './Types';

// Collection of specific view modules
interface Views {
  [key: string]: ViewConstructor
}
const views: Views = {
  LobbyIndexView,
};

class NoView implements View {
    mount() {}
    unmount() {}
}


export default function loadView(viewName: string): ViewConstructor {
  return views[viewName] || NoView;
}