# Scenes (create in Cocos Creator Editor)

Create these scenes under this folder and attach scripts:

| Scene | Script |
|-------|--------|
| Boot | `boot/BootApp` |
| Login | `login/LoginController` |
| Lobby | `hall/LobbyController` |
| CasinoLoading | `hall/CasinoLoadingController` |
| CasinoStub | `fgame/CasinoStubController` |
| FishStub | `fish2/FishStubController` |

Set project launch scene to **Boot**.

Mock flow: Guest login → Lobby game list → FGame485 → CasinoLoading → CasinoStub.
