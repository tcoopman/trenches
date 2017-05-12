// @ts-check
import LobbyIndexView from './views/lobby';

// Collection of specific view modules
const views = {
  LobbyIndexView,
};

class NoView {
    mount() {}
    unmount() {}
}


export default function loadView(viewName) {
  return views[viewName] || NoView;
}