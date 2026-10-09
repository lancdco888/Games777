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

### Phase 1 — 大厅壳（已完成）

- Creator 工程骨架 + 场景脚本：`BootApp` / `LoginController` / `LobbyController`
- 核心基础设施：Dispatcher、Coroutine、Device、Sound、Storage、i18n
- 数据：`UserData` / `GameData` / `sGameManager` / `LoginData` / `ConstGame`（种子表）
- 网络 mock + FGame/fish2 stub

### Phase 2 — 大厅真协议 + Lobby UI + FGame485 进房（进行中 / 本迭代）

已落地：

1. **二进制协议框架**：`XxData` + `ObjMgr`（对齐 Lua ObjMgr 引用索引）
2. **关键包**：AuthByUsername(1106)、Auth_Success_Lobby(1001)、Lobby_Enter(2002)、Enter_Success(1202)、EnterGame(2003)、EnterGameSlots_Success(1215)、MoneyChanged(1236)、Ping/Pong、Slots_Enter / Enter_Success
3. **NetClient**：mock 返回真实包结构；WebSocket 二进制帧（serviceId/serial/len/payload）可接真服
4. **LogicMain**：Auth → `EnterLobbyPanel`(token) → 游戏列表 / casinoLevelTabs → 大厅场景
5. **Lobby UI**：无 Prefab 时程序化搭建 user_info + game_list（CSB 占位）
6. **FGame 进房链**：`CasinoEnterFlow` = EnterGame → Slots_Enter → loadBundle → `RunCasino`（485 等 FGUI 游戏）
7. **场景脚本**：`CasinoLoadingController` + `CasinoStubController`（展示 enterData）

仍待：

- Creator 编辑器内建齐场景并挂载脚本
- FairyGUI-Creator + `Game485` 包真渲染
- 从 `pkgs/*.lua` 代码生成完整 Shared 嵌套类型（selfAccount 等）
- 热更新 Asset Bundle 与原生 TCP（非仅 WebSocket）

### Phase 3 — fish2

1. 原生插件暴露 `Fish2Env` / `NewCatchFishEnv` 给 Creator
2. 移植 `fish2/script/` 或保留 native + 脚本桥
3. 大厅 `EnterFish` 接真环境

## 在 Creator 中打开

1. 安装 Cocos Creator **3.8.3**（或同主版本 3.8.x）
2. 打开目录 `creator-games777/`
3. 新建场景并保存到 `assets/scenes/`：
   - `Boot` → 根节点挂 `BootApp`
   - `Login` → 挂 `LoginController`（按钮绑 `onClickGuest` / `onClickPassword`）
   - `Lobby` → 挂 `LobbyController`（可绑 `onClickGame485` / `onClickFish30`）
   - `CasinoLoading` → 挂 `CasinoLoadingController`
   - `CasinoStub` → 挂 `CasinoStubController`（`onClickBack` / `onClickSpin`）
   - `FishStub` → 挂 `FishStubController`
4. 项目设置 → 启动场景设为 `Boot`
5. 预览：游客登录（mock）→ 大厅列表 → 点 485 → Loading → CasinoStub（含 enterData）

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
