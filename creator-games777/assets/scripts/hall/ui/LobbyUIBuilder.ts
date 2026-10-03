/**
 * Programmatic Lobby UI — Creator stand-in for csb/LobbyLayer/LobbyLayer.csb
 * until art Prefabs are imported. Mirrors user_info + game_list + function_buttons.
 */
import {
  Button,
  Color,
  Label,
  Node,
  UITransform,
  Vec3,
  director,
} from 'cc';
import { UserData } from '../../data/UserData';
import { GameData } from '../../data/GameData';
import { ConstGame } from '../../data/ConstGame';
import { SendEnterRoomLevel } from '../GameLauncher';
import { UIManager } from '../UIManager';
import { Dispatcher } from '../../core/Dispatcher';

export type LobbyUIRefs = {
  root: Node;
  nicknameLabel: Label;
  moneyLabel: Label;
  statusLabel: Label;
  gameListRoot: Node;
};

function ensureUITransform(node: Node, w: number, h: number): UITransform {
  let t = node.getComponent(UITransform);
  if (!t) t = node.addComponent(UITransform);
  t.setContentSize(w, h);
  return t;
}

function makeLabel(parent: Node, name: string, text: string, fontSize: number, color: Color): Label {
  const n = new Node(name);
  parent.addChild(n);
  ensureUITransform(n, 400, 40);
  const label = n.addComponent(Label);
  label.string = text;
  label.fontSize = fontSize;
  label.color = color;
  return label;
}

export function buildLobbyUI(host: Node): LobbyUIRefs {
  const root = new Node('LobbyRoot');
  host.addChild(root);
  ensureUITransform(root, 1280, 720);

  const panel = new Node('panel');
  root.addChild(panel);
  ensureUITransform(panel, 1280, 720);

  const userInfo = new Node('user_info');
  panel.addChild(userInfo);
  ensureUITransform(userInfo, 600, 80);
  if (userInfo.setPosition) userInfo.setPosition(new Vec3(-280, 300, 0));

  const nicknameLabel = makeLabel(
    userInfo,
    'lua_nickname',
    UserData.nickname || UserData.username || '-',
    28,
    Color.WHITE,
  );
  if (nicknameLabel.node.setPosition) nicknameLabel.node.setPosition(new Vec3(0, 20, 0));

  const moneyLabel = makeLabel(
    userInfo,
    'lua_coin_num',
    UserData.money.toFixed(2),
    26,
    new Color(255, 220, 120, 255),
  );
  if (moneyLabel.node.setPosition) moneyLabel.node.setPosition(new Vec3(0, -20, 0));

  const statusLabel = makeLabel(panel, 'status', '', 20, new Color(180, 220, 255, 255));
  if (statusLabel.node.setPosition) statusLabel.node.setPosition(new Vec3(0, 250, 0));

  const gameListRoot = new Node('game_list');
  panel.addChild(gameListRoot);
  ensureUITransform(gameListRoot, 1200, 480);
  if (gameListRoot.setPosition) gameListRoot.setPosition(new Vec3(0, -20, 0));

  const func = new Node('function_buttons');
  panel.addChild(func);
  ensureUITransform(func, 800, 80);
  if (func.setPosition) func.setPosition(new Vec3(0, -300, 0));
  makeLabel(func, 'btn_hint', 'Settings / Service / Mail (TODO Prefabs)', 18, new Color(160, 160, 160, 255));

  return { root, nicknameLabel, moneyLabel, statusLabel, gameListRoot };
}

export function refreshGameList(
  gameListRoot: Node,
  onEnter: (gameId: number) => void,
): void {
  const ids = GameData.game_ids.length
    ? GameData.game_ids
    : Object.keys(ConstGame.Param).map(Number);

  const cols = 4;
  const cellW = 260;
  const cellH = 140;
  ids.forEach((gameId, index) => {
    const resId = GameData.GetGameID(gameId);
    const cfg = ConstGame.Param[resId];
    const name = cfg?.Game_Name || `Game ${gameId}`;
    const icon = cfg?.Icon ?? resId;
    const col = index % cols;
    const row = Math.floor(index / cols);
    const item = new Node(`GameItem_${gameId}`);
    gameListRoot.addChild(item);
    ensureUITransform(item, cellW - 20, cellH - 20);
    if (item.setPosition) {
      item.setPosition(new Vec3((col - (cols - 1) / 2) * cellW, 160 - row * cellH, 0));
    }

    makeLabel(item, 'title', `${name}\n#${gameId} icon:${icon}`, 18, Color.WHITE);

    const btn = item.addComponent(Button);
    // Creator editor wires click events; for code-built nodes store callback.
    (btn as Button & { __click?: () => void }).__click = () => onEnter(gameId);
    (item as Node & { __gameId?: number }).__gameId = gameId;
  });
}

export function bindMoneyRefresh(nicknameLabel: Label, moneyLabel: Label): () => void {
  const handler = () => {
    nicknameLabel.string = UserData.nickname || UserData.username || `ID:${UserData.id}`;
    moneyLabel.string = UserData.money.toFixed(2);
  };
  Dispatcher.Add('MONEY_CHANGED', 'lobby-ui', handler);
  return () => Dispatcher.Remove('lobby-ui');
}

export async function clickEnterGame(gameId: number): Promise<void> {
  UIManager.ShowWaiting();
  await SendEnterRoomLevel(gameId);
  UIManager.HideWaiting();
}

export function backToLogin(): void {
  director.loadScene('Login');
}
