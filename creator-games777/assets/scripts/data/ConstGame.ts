/**
 * Minimal const_game — full table lives in hall/src/common/const_game.lua (2760 lines).
 * Import/generate the complete Param table in a follow-up pass from Lua.
 */
export type GameParam = {
  Game_type: 'casino' | 'haiwang' | 'changsheng' | string;
  Cocos_Support?: boolean;
  FGUI_Support?: boolean;
  FGUI_Release?: boolean;
  name?: string;
};

export const ConstGame = {
  Game_type: 'Game_type' as const,
  Cocos_Support: 'Cocos_Support' as const,
  FGUI_Support: 'FGUI_Support' as const,
  FGUI_Release: 'FGUI_Release' as const,

  Lobby_State: 'Lobby_State',
  Game_State: 'Game_State',

  H_Screen_Type: 1,
  V_Screen_Type: 2,

  /** Seed entries — expand from Lua const_game.Param */
  Param: {
    30: { Game_type: 'haiwang', name: 'fish_demo', Cocos_Support: true },
    221: { Game_type: 'casino', name: 'slot_221', Cocos_Support: true },
    270: { Game_type: 'casino', name: 'FGame270', FGUI_Support: true, FGUI_Release: true },
    336: { Game_type: 'casino', name: 'FGame336', FGUI_Support: true, FGUI_Release: true },
    341: { Game_type: 'casino', name: 'FGame341', FGUI_Support: true, FGUI_Release: true },
    353: { Game_type: 'casino', name: 'FGame353', FGUI_Support: true, FGUI_Release: true },
    375: { Game_type: 'casino', name: 'FGame375', FGUI_Support: true, FGUI_Release: true },
    388: { Game_type: 'casino', name: 'FGame388', FGUI_Support: true, FGUI_Release: true },
    465: { Game_type: 'casino', name: 'FGame465', FGUI_Support: true, FGUI_Release: true },
    475: { Game_type: 'casino', name: 'FGame475', FGUI_Support: true, FGUI_Release: true },
    479: { Game_type: 'casino', name: 'FGame479', FGUI_Support: true, FGUI_Release: true },
    481: { Game_type: 'casino', name: 'FGame481', FGUI_Support: true, FGUI_Release: true },
    482: { Game_type: 'casino', name: 'FGame482', FGUI_Support: true, FGUI_Release: true },
    483: { Game_type: 'casino', name: 'FGame483', FGUI_Support: true, FGUI_Release: true },
    485: { Game_type: 'casino', name: 'FGame485', FGUI_Support: true, FGUI_Release: true },
  } as Record<number, GameParam>,
};
