import { _decorator, Component, Label, Node } from 'cc';
import { UserData } from '../data/UserData';
import { GameData } from '../data/GameData';
import { ConstGame } from '../data/ConstGame';
import { gSound } from '../core/Sound';
import { AppStorage } from '../core/Storage';
import { Dispatcher } from '../core/Dispatcher';
import { Coroutines } from '../core/Coroutine';
import { SendEnterRoomLevel } from './GameLauncher';
import { UIManager } from './UIManager';
import {
  buildLobbyUI,
  refreshGameList,
  bindMoneyRefresh,
  clickEnterGame,
  backToLogin,
  type LobbyUIRefs,
} from './ui/LobbyUIBuilder';

const { ccclass, property } = _decorator;

/**
 * Lobby shell — port of hallnew Panel_Lobby + LobbyLayer.
 * If editor labels/nodes are unbound, builds programmatic UI (CSB stand-in).
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

  private ui: LobbyUIRefs | null = null;
  private unbindMoney: (() => void) | null = null;

  onLoad(): void {
    this.schedule((dt: number) => Coroutines.update(dt), 0);
    Dispatcher.Add('UI_TOAST', this, (text: unknown) => {
      const label = this.statusLabel || this.ui?.statusLabel;
      if (label) label.string = String(text);
    });
  }

  onDestroy(): void {
    Dispatcher.Remove(this);
    this.unbindMoney?.();
  }

  start(): void {
    if (!this.nicknameLabel || !this.moneyLabel || !this.gameListRoot) {
      this.ui = buildLobbyUI(this.node);
      this.nicknameLabel = this.ui.nicknameLabel;
      this.moneyLabel = this.ui.moneyLabel;
      this.gameListRoot = this.ui.gameListRoot;
      this.statusLabel = this.ui.statusLabel;
    }
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
    this.unbindMoney = bindMoneyRefresh(this.nicknameLabel!, this.moneyLabel!);
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
      this.statusLabel.string = `大厅游戏列表 (${ids.length}): 点击卡片进入`;
    }
    if (this.gameListRoot) {
      refreshGameList(this.gameListRoot, (gameId) => {
        void this.onClickGame(gameId);
      });
    }
  }

  async onClickGame(gameId: number): Promise<void> {
    await clickEnterGame(gameId);
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
    backToLogin();
  }

  /** Debug helper — direct enter without UI */
  onClickEnterSelected(): void {
    void SendEnterRoomLevel(GameData.game_id > 0 ? GameData.game_id : 485);
    UIManager.HideWaiting();
  }
}
