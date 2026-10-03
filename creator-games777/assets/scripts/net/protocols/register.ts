import { gOM } from '../ObjMgr';
import { registerLoginPkgs } from './LoginPkgs';
import { registerLobbyPkgs } from './LobbyPkgs';

let registered = false;

export function registerAllProtocols(): void {
  if (registered) return;
  registerLoginPkgs(gOM);
  registerLobbyPkgs(gOM);
  registered = true;
}
