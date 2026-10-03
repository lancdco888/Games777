# Games777 Creator 3.x

Cocos Creator **3.8.x** 迁移工程。大厅优先，再 FGame / fish2。

详见 [`../docs/CREATOR_MIGRATION.md`](../docs/CREATOR_MIGRATION.md)。

## 快速开始

1. 用 Cocos Creator 3.8.3 打开本目录
2. 按迁移文档创建并绑定场景脚本
3. 启动场景设为 `Boot`
4. 预览：默认 `NetClient` mock 模式，游客登录可进大厅

## 脚本结构

```
assets/scripts/
  boot/          BootApp
  core/          Dispatcher / Coroutine / Device / Sound / i18n
  net/           NetClient
  data/          UserData / GameData / ConstGame / LoginData
  login/         LoginController
  hall/          LogicMain / LobbyController / GameLauncher / UIManager
  fgame/         RunCasino / APIGateway / CasinoStub
  fish2/         EnterFish / FishBridge / FishStub
```
