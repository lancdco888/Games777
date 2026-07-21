import { _decorator, Component, Label, Node, director } from 'cc';
import { UserData } from '../data/UserData';
import { GameData } from '../data/GameData';
import { ConstGame } from '../data/ConstGame';
import { gSound } from '../core/Sound';
import { AppStorage } from '../core/Storage';
import { Dispatcher } from '../core/Dispatcher';
import { SendEnterRoomLevel } from './GameLauncher';
import { UIManager } from './UIManager';

const { ccclass, property } = _decorator;

/**
 * Lobby shell — port of hallnew Panel_Lobby + LobbyLayer.
 * Attach to Lobby scene root. Bind labels / game-list container in editor.
 */
@ccclass('LobbyController')
export class LobbyController extends Component {
  @property(Label)
  nicknameLabel: Label | null = null;

  @property(Label)
  moneyLabel: Label | null = null;

  @property(Node)
  gameListRoot: Node | null = null;

  @property(Label)
  statusLabel: Label | null = null;

  onLoad(): void {
    Dispatcher.Add('UI_TOAST', this, (text: unknown) => {
      if (this.statusLabel) this.statusLabel.string = String(text);
    });
  }

  onDestroy(): void {
    Dispatcher.Remove(this);
  }

  start(): void {
    this.EnterLobby();
  }

  EnterLobby(): void {
    if (!AppStorage.getBool('Once', false)) {
      AppStorage.setBool('music', true);
      AppStorage.setBool('effect', true);
      AppStorage.setBool('Once', true);
    }
    gSound.playBgm('hallsound/bg_lobby.mp3');
    this.refreshUserBar();
    this.refreshGameList();
  }

  refreshUserBar(): void {
    if (this.nicknameLabel) {
      this.nicknameLabel.string = UserData.nickname || UserData.username || `ID:${UserData.id}`;
    }
    if (this.moneyLabel) {
      this.moneyLabel.string = UserData.money.toFixed(2);
    }
  }

  refreshGameList(): void {
    const ids = GameData.game_ids.length ? GameData.game_ids : Object.keys(ConstGame.Param).map(Number);
    if (this.statusLabel) {
      this.statusLabel.string = `games: ${ids.join(', ')}`;
    }
    // Full GameList item prefabs arrive with art migration from CSB.
  }

  /** Bound from game icon buttons in editor */
  async onClickGame(gameId: number): Promise<void> {
    UIManager.ShowWaiting();
    await SendEnterRoomLevel(gameId);
    UIManager.HideWaiting();
  }

  onClickGame270(): void {
    void this.onClickGame(270);
  }

  onClickGame485(): void {
    void this.onClickGame(485);
  }

  onClickFish30(): void {
    void this.onClickGame(30);
  }

  onClickBackLogin(): void {
    director.loadScene('Login');
  }
}
