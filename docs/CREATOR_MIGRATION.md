# Games777 → Cocos Creator 3.x 迁移说明

目标引擎：**Cocos Creator 3.8.x**  
策略：**大厅优先**，再 FGame（老虎机），最后 fish2（捕鱼）。

## 目录

| 路径 | 说明 |
|------|------|
| `creator-games777/` | Creator 3.x 工程（TypeScript） |
| `FGameCommon/.../Special/Creator/` | 既有 Lua `RUNTIME_IN_CREATOR` 适配层（补齐原先缺失的 Import） |
| 原 `hall/` `packagelua/` `FGame*` `fish2/` | 仍保留，作为对照与协议/配置来源 |

## 启动链路对照

```
旧: bootstrap → packagelua(Login) → hall/main → LogicMain → Lobby / Casino / Fish
新: Boot 场景(BootApp) → Login 场景 → LogicMain → Lobby / CasinoStub / FishStub
```

## 阶段计划

### Phase 1 — 大厅壳（本 PR）

- Creator 工程骨架 + 场景脚本：`BootApp` / `LoginController` / `LobbyController`
- 核心基础设施：Dispatcher、Coroutine、Device、Sound、Storage、i18n
- 数据：`UserData` / `GameData` / `sGameManager` / `LoginData` / `ConstGame`（种子表）
- 网络：`NetClient`（默认 mock，可连真服后关 mock）
- 会话：`LogicMain`（对齐 `hall/src/logic.lua`）
- 入口路由：`GameLauncher` → FGame / fish2
- FGame：`RunCasino` + `APIGateway` + FairyGUI stub + `CasinoStub` 场景脚本
- fish2：`EnterFish` + `FishBridge` + `FishStub` 场景脚本
- 补齐 `FGameCommon/Special/Creator/*` Lua 适配

### Phase 2 — 大厅完善 + 首个 FGame

1. 用 Creator 编辑器建场景：`Boot` / `Login` / `Lobby` / `CasinoStub` / `FishStub`，挂上对应脚本
2. 从 `hall/src/common/const_game.lua` 生成完整 `ConstGame.Param`
3. 大厅 UI：CSB `LobbyLayer` → Creator Prefab（用户条、游戏列表、底部功能）
4. 真 TCP/WebSocket + 从 `pkgs/*.lua` 生成协议编解码
5. 热更新：Asset Bundle 对齐 `DownloadingHall` / `FGame{id}` 模块名
6. 接入 FairyGUI-Creator，打通 **FGame485**（或 270）端到端：`RunCasino` → 主题 → 结算回大厅

### Phase 3 — fish2

1. 原生插件暴露 `Fish2Env` / `NewCatchFishEnv` 给 Creator
2. 移植 `fish2/script/` 逻辑或保留 native + Lua 脚本桥
3. 大厅 `EnterFish` 接真环境，去掉 stub

## 在 Creator 中打开

1. 安装 Cocos Creator **3.8.3**（或同主版本 3.8.x）
2. 打开目录 `creator-games777/`
3. 新建场景并保存到 `assets/scenes/`：
   - `Boot` → 根节点挂 `BootApp`
   - `Login` → 挂 `LoginController`（按钮绑 `onClickGuest` / `onClickPassword`）
   - `Lobby` → 挂 `LobbyController`（可绑 `onClickGame485` / `onClickFish30`）
   - `CasinoStub` → 挂 `CasinoStubController`
   - `FishStub` → 挂 `FishStubController`
4. 项目设置 → 启动场景设为 `Boot`
5. 预览：游客登录（mock）→ 大厅 → 点游戏进 stub

## 模块映射（Phase 1）

| 旧 Lua | 新 TS |
|--------|-------|
| `packagelua/.../Dispatcher` | `core/Dispatcher.ts` |
| `g_net` / `Network` | `net/NetClient.ts` |
| `UserData` / `GameData` | `data/UserData.ts` / `GameData.ts` |
| `logic.lua` LogicMain | `hall/LogicMain.ts` |
| `Panel_Lobby` | `hall/LobbyController.ts` + `GameLauncher.ts` |
| `FGameCommon/Entry` RunCasino | `fgame/RunCasino.ts` |
| `Special/CocosFish2/APIGateway` | `fgame/APIGateway.ts` + Lua `Special/Creator/` |
| `enterfishlayer/EnterGame` | `fish2/EnterFish.ts` |

## 风险

- **FairyGUI**：老虎机强依赖，需单独接入 Creator 运行时
- **协议**：`pkgs` 为 Lua 生成物，需代码生成到 TS
- **fish2**：C++ Env 不在本仓库，需原生工程配合
- **热更新 / SDK**：Adjust、Facebook、GooglePay 等需 Creator 原生插件重绑
