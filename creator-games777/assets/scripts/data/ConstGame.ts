/**
 * const_game — seeded from hall/src/common/const_game.lua for FGame + fish demo.
 */
export type GameParam = {
  Game_type: 'casino' | 'haiwang' | 'changsheng' | string;
  Icon?: number;
  Game_Name?: string;
  ScreenType?: number;
  Reconnect_Msg?: string;
  Cocos_Support?: boolean;
  FGUI_Support?: boolean;
  FGUI_Release?: boolean;
  caijin_type?: number;
};

export const ConstGame = {
  Game_type: 'Game_type' as const,
  Icon: 'Icon' as const,
  Game_Name: 'Game_Name' as const,
  Cocos_Support: 'Cocos_Support' as const,
  FGUI_Support: 'FGUI_Support' as const,
  FGUI_Release: 'FGUI_Release' as const,

  Lobby_State: 'Lobby_State',
  Game_State: 'Game_State',

  H_Screen_Type: 1,
  V_Screen_Type: 2,

  Param: {
    30: {
      Game_type: 'haiwang',
      Icon: 101,
      Game_Name: '海王捕鱼',
      Cocos_Support: true,
      ScreenType: 1,
    },
    221: {
      Game_type: 'casino',
      Icon: 221,
      Game_Name: '狂野蛮牛',
      Cocos_Support: true,
      ScreenType: 1,
    },
    270: {
      Game_type: 'casino',
      Icon: 270,
      Game_Name: '财富之眼',
      ScreenType: 1,
      Reconnect_Msg: 'PKG_Slots_Client_EyesOfWealthEnterResumed',
      Cocos_Support: true,
      FGUI_Support: true,
      FGUI_Release: true,
      caijin_type: 1,
    },
    336: {
      Game_type: 'casino',
      Icon: 336,
      Game_Name: '和平&长寿',
      ScreenType: 1,
      Reconnect_Msg: 'PKG_Slots_Client_DragonGiftEnterResumed',
      FGUI_Support: true,
      FGUI_Release: true,
    },
    341: {
      Game_type: 'casino',
      Icon: 341,
      Game_Name: '魔法熊猫',
      ScreenType: 1,
      FGUI_Support: true,
      FGUI_Release: true,
    },
    353: {
      Game_type: 'casino',
      Icon: 353,
      Game_Name: '野牛-豪华版',
      ScreenType: 1,
      FGUI_Support: true,
      FGUI_Release: true,
    },
    375: {
      Game_type: 'casino',
      Icon: 375,
      Game_Name: '尤里卡列车',
      ScreenType: 2,
      FGUI_Support: true,
      FGUI_Release: true,
    },
    388: {
      Game_type: 'casino',
      Icon: 388,
      Game_Name: '江湖儿女',
      ScreenType: 1,
      FGUI_Support: true,
      FGUI_Release: true,
    },
    465: {
      Game_type: 'casino',
      Icon: 465,
      Game_Name: '五龙争霸Ⅱ',
      ScreenType: 1,
      FGUI_Support: true,
      FGUI_Release: true,
    },
    475: {
      Game_type: 'casino',
      Icon: 475,
      Game_Name: '海盗财宝',
      ScreenType: 1,
      FGUI_Support: true,
      FGUI_Release: true,
    },
    479: {
      Game_type: 'casino',
      Icon: 479,
      Game_Name: '熊猫宝藏Ⅱ',
      ScreenType: 1,
      FGUI_Support: true,
      FGUI_Release: true,
    },
    481: {
      Game_type: 'casino',
      Icon: 481,
      Game_Name: 'Gates of Olympus 1000',
      ScreenType: 1,
      FGUI_Support: true,
      FGUI_Release: true,
    },
    482: {
      Game_type: 'casino',
      Icon: 482,
      Game_Name: 'Gates of Olympus',
      ScreenType: 1,
      FGUI_Support: true,
      FGUI_Release: true,
    },
    483: {
      Game_type: 'casino',
      Icon: 483,
      Game_Name: '麻将胡了',
      ScreenType: 2,
      FGUI_Support: true,
      FGUI_Release: true,
    },
    485: {
      Game_type: 'casino',
      Icon: 311,
      Game_Name: '终极火链',
      ScreenType: 2,
      Reconnect_Msg: 'PKG_Slots_Client_FireLinkEnterResumed',
      FGUI_Support: true,
      FGUI_Release: true,
      caijin_type: 1,
    },
  } as Record<number, GameParam>,
};
