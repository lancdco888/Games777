const_game = {}

--游戏状态:大厅中、大厅到游戏loading过程、游戏中
const_game.Lobby_State = 1
const_game.Lobby_To_Game_State = 2
const_game.Game_State = 3

--老虎机彩金刷新时间
const_game.Caijin_UpdateTime = 16

--游戏相关参数：以ID为索引，ID与服务器匹配
--icon:大厅中显示的图标
--name:游戏名称，多语言：1：中文，2：英文
--Game_type:游戏类型：昌盛，海王，老虎机区别

const_game.Icon = 'Icon'
const_game.Game_Name = 'Game_Name'
const_game.Game_type = 'Game_type'
const_game.Reconnect_Msg = 'Reconnect_Msg'

---------------------------------------------------------------------------------
-- 老虎机标记

const_game.Cocos_Support = "Cocos_Support"  -- 该游戏支持老的 cocos 版本
const_game.FGUI_Support = "FGUI_Support"    -- 该游戏支持 fgui
const_game.FGUI_Release = "FGUI_Release"    -- 该游戏 fgui 版本已经测试通过

---------------------------------------------------------------------------------

--老虎机屏幕类型
const_game.ScreenType = 'ScreenType'

-- 未知
const_game.Unknown_Screen_Type = Device.Unknown_Screen_Type
--横屏
const_game.H_Screen_Type = Device.H_Screen_Type
--竖屏
const_game.V_Screen_Type = Device.V_Screen_Type

const_game.Param = {
    [101] = {
        [const_game.Icon] = 101,
        [const_game.Game_type] = 'haiwang',
		[const_game.Game_Name] = TR("大王乌贼"),
        ["anims"] = {
            10101,      -- 外框
            11101       -- 角色
        }
	},
    [102] = {
        [const_game.Icon] = 102,
        [const_game.Game_type] = 'haiwang',
		[const_game.Game_Name] = TR("八爪章鱼"),
        ["anims"] = {
            10102,      -- 外框
            11102       -- 角色
        }
	},
    [103] = {
        [const_game.Icon] = 103,
        [const_game.Game_type] = 'haiwang',
		[const_game.Game_Name] = TR("狂暴火龙"),
        ["anims"] = {
            10103,      -- 外框
            11103       -- 角色
        }
	},
    [104] = {
        [const_game.Icon] = 104,
        [const_game.Game_type] = 'haiwang',
		[const_game.Game_Name] = TR("霸王蟹"),
        ["anims"] = {
            10104,
            11104
        }
	},
    [105] = {
        [const_game.Icon] = 105,
        [const_game.Game_type] = 'haiwang',
        [const_game.Game_Name] = TR("龙虾将军"),
        ["anims"] = {
            10105,
            11105
        }
    },
    [106] = {
        [const_game.Icon] = 106,
        [const_game.Game_type] = 'haiwang',
        [const_game.Game_Name] = TR("史前巨鳄"),
        ["anims"] = {
            10106,
            11106,
        }
    },
    [107] = {
        [const_game.Icon] = 107,
        [const_game.Game_type] = 'haiwang',
        [const_game.Game_Name] = TR("暗夜巨兽"),
        ["anims"] = {
            10107,
            11107
        }
    },
    [108] = {
        [const_game.Icon] = 108,
        [const_game.Game_type] = 'haiwang',
        [const_game.Game_Name] = TR("海王荣耀"),
        ["anims"] = {
            10108,
            11108,
        },
    },
    [109] = {
        [const_game.Icon] = 109,
        [const_game.Game_type] = 'changsheng',
        [const_game.Game_Name] =  TR("铁甲飞龙"),
        ["anims"] = {
            10109,
        },
    },
    [110] = {
        [const_game.Icon] = 110,
        [const_game.Game_type] = 'changsheng',
        [const_game.Game_Name] = TR("追风逐月"),
        ["anims"] = {
            10110
        },
    },
    [111] = {
        [const_game.Icon] = 111,
        [const_game.Game_type] = 'changsheng',
        [const_game.Game_Name] = TR("哪吒闹海"),
        ["anims"] = {
            10111
        },
    },
    [112] = {
        [const_game.Icon] = 112,
        [const_game.Game_type] = 'changsheng',
        [const_game.Game_Name] = TR("神龙宝藏"),
        ["anims"] = {
            10112
        },
    },
    [113] = {
        [const_game.Icon] = 113,
        [const_game.Game_type] = 'changsheng',
        [const_game.Game_Name] = TR("同类炸弹"),
        ["anims"] = {
            10113
        },
    },
    [114] = {
        [const_game.Icon] = 114,
        [const_game.Game_type] = 'changsheng',
        [const_game.Game_Name] = TR("响震四方"),
        ["anims"] = {
            10114
        },
    },
    [115] = {
        [const_game.Icon] = 115,
        [const_game.Game_type] = 'changsheng',
        [const_game.Game_Name] = TR("羊鳄大战"),
        ["anims"] = {
            10115
        },
    },
    [116] = {
        [const_game.Icon] = 116,
        [const_game.Game_type] = 'changsheng',
        [const_game.Game_Name] = TR("海盗船"),
        ["anims"] = {
            10116
        },
    },
    [117] = {
        [const_game.Icon] = 117,
        [const_game.Game_type] = 'changsheng',
        [const_game.Game_Name] =  TR("三色鳄鱼"),
        ["anims"] = {
            10117
        },
    },
    [118] = {
        [const_game.Icon] = 118,
        [const_game.Game_type] = 'changsheng',
        [const_game.Game_Name] = TR("李逵劈鱼"),
        ["anims"] = {
            10118
        },
    },
    [119] = {
        [const_game.Icon] = 119,
        [const_game.Game_type] = 'changsheng',
        [const_game.Game_Name] = TR("摇钱树"),
        ["anims"] = {
            10119
        },
    },
    [120] = {
        [const_game.Icon] = 120,
        [const_game.Game_type] = 'changsheng',
        [const_game.Game_Name] = TR("金蟾捕鱼"),
        ["anims"] = {
            10120
        },
    },
    [121] = {
        [const_game.Icon] = 121,
        [const_game.Game_type] = 'changsheng',
        [const_game.Game_Name] = TR("黄金美人鱼"),
        ["anims"] = {
            10121
        },
    },
    [122] = {
        [const_game.Icon] = 122,
        [const_game.Game_type] = 'changsheng',
        [const_game.Game_Name] = TR("龙鲨争霸"),
        ["anims"] = {
            10122
        },
    },
    [123] = {
        [const_game.Icon] = 123,
        [const_game.Game_type] = 'haiwang',
        [const_game.Game_Name] = TR("火凤凰"),
        ["anims"] = {
            10123
        },
    },
    [124] = {
        [const_game.Icon] = 124,
        [const_game.Game_type] = 'haiwang',
        [const_game.Game_Name] =  TR("神龙转轮"),
        ["anims"] = {
            10124
        },
    },
    [205] = {
        [const_game.Icon] = 205,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] = TR("财神道"),
		[const_game.ScreenType] = const_game.H_Screen_Type,
        ["caijin_type"] = 5,
        ["anims"] = {
            10201
        },
        [const_game.Cocos_Support] = true,
    },
    [206] = {
        [const_game.Icon] = 206,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] = TR("糖果王国"),
		[const_game.ScreenType] = const_game.H_Screen_Type,
        ["caijin_type"] = 5,
        ["anims"] = {
            10202
        },
        [const_game.Cocos_Support] = true,
    },
    [207] = {
        [const_game.Icon] = 207,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] = TR("好运年年"),
		[const_game.ScreenType] = const_game.H_Screen_Type,
        ["caijin_type"] = 4,
        ["anims"] = {
            10203
        },
        [const_game.Cocos_Support] = true,
    },
    [208] = {
        [const_game.Icon] = 208,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] = TR("幸运钻石"),
		[const_game.ScreenType] = const_game.H_Screen_Type,
        ["caijin_type"] = 1,
        ["anims"] = {
            10204
        },
        [const_game.Cocos_Support] = true,
    },
    [209] = {
        [const_game.Icon] = 209,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] = TR("阿拉丁宝藏"),
		[const_game.ScreenType] = const_game.H_Screen_Type,
        ["caijin_type"] = 2,
        ["anims"] = {
            10202
        },
        [const_game.Cocos_Support] = true,
    },
    [210] = {
        [const_game.Icon] = 210,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] = TR("皇朝88"),
		[const_game.ScreenType] = const_game.H_Screen_Type,
        ["caijin_type"] = 3,
        ["anims"] = {
            10205
        },
        [const_game.Cocos_Support] = true,
    },
    [211] = {
        [const_game.Icon] = 211,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] = TR("神偷侠兔"),
		[const_game.ScreenType] = const_game.H_Screen_Type,
        ["caijin_type"] = 5,
        ["anims"] = {
            10204
        },
        [const_game.Cocos_Support] = true,
    },
    [212] = {
        [const_game.Icon] = 212,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] = TR("冰雪女神"),
		[const_game.ScreenType] = const_game.H_Screen_Type,
        ["caijin_type"] = 4,
        ["anims"] = {
            10206
        },
        [const_game.Cocos_Support] = true,
    },
    [213] = {
        [const_game.Icon] = 213,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] = TR("金虎聚财"),
		[const_game.ScreenType] = const_game.H_Screen_Type,
        ["caijin_type"] = 2,
        ["anims"] = {
            10207
        },
        [const_game.Cocos_Support] = true,
    },
    [214] = {
        [const_game.Icon] = 214,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] = TR("巨龙争霸"),
		[const_game.ScreenType] = const_game.H_Screen_Type,
        ["caijin_type"] = 1,
        ["anims"] = {
            10201
        },
        [const_game.Cocos_Support] = true,
    },
    [215] = {
        [const_game.Icon] = 215,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] =  TR("彩凤呈祥"),
		[const_game.ScreenType] = const_game.H_Screen_Type,
        ["caijin_type"] = 5,
        ["anims"] = {
            10208
        },
        [const_game.Cocos_Support] = true,
    },
    [216] = {
        [const_game.Icon] = 216,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] = TR("黄金88"),
		[const_game.ScreenType] = const_game.V_Screen_Type,
        ["caijin_type"] = 5,
        ["anims"] = {
            10202
        },
        [const_game.Cocos_Support] = true
    },
    [217] = {
        [const_game.Icon] = 217,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] = TR("福星发财"),
		[const_game.ScreenType] = const_game.H_Screen_Type,
        ["caijin_type"] = 4,
        ["anims"] = {
            10205
        },
        [const_game.Cocos_Support] = true,
    },
    [218] = {
        [const_game.Icon] = 218,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] = TR("发财树"),
		[const_game.ScreenType] = const_game.V_Screen_Type,
        ["caijin_type"] = 2,
        ["anims"] = {
            10209
        },
        [const_game.Cocos_Support] = true,
    },
    [219] = {
        [const_game.Icon] = 219,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] = TR("法老宝藏"),
		[const_game.ScreenType] = const_game.V_Screen_Type,
        ["caijin_type"] = 1,
        ["anims"] = {
            10206
        },
        [const_game.Cocos_Support] = true,
    },
    [220] = {
        [const_game.Icon] = 220,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] = TR("熊猫宝藏"),
		[const_game.ScreenType] = const_game.H_Screen_Type,
        ["caijin_type"] = 5,
        ["anims"] = {
            10203
        },
        [const_game.Cocos_Support] = true,
    },
    [221] = {
        [const_game.Icon] = 221,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] = TR("狂野蛮牛"),
		[const_game.ScreenType] = const_game.H_Screen_Type,
        ["caijin_type"] = 4,
        ["anims"] = {
            10203
        },
        [const_game.Cocos_Support] = true,
    },
    [222] = {
        [const_game.Icon] = 222,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] = TR("幸运美金"),
		[const_game.ScreenType] = const_game.H_Screen_Type,
        ["caijin_type"] = 2,
        ["anims"] = {
            10205
        },
        [const_game.Cocos_Support] = true,
    },
    [223] = {
        [const_game.Icon] = 223,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] = TR("霹雳火"),
		[const_game.ScreenType] = const_game.H_Screen_Type,
        ["caijin_type"] = 5,
        ["anims"] = {
            10203
        },
        [const_game.Cocos_Support] = true,
    },
    [224] = {
        [const_game.Icon] = 224,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] = TR("齐天大圣"),
		[const_game.ScreenType] = const_game.H_Screen_Type,
        ["caijin_type"] = 3,
        ["anims"] = {
            10203
        },
        [const_game.Cocos_Support] = true,
    },
    [225] = {
        [const_game.Icon] = 225,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] = TR("龙海公主"),
		[const_game.ScreenType] = const_game.H_Screen_Type,
        ["caijin_type"] = 4,
        ["anims"] = {
            10203
        },
    },
    [226] = {
        [const_game.Icon] = 226,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] = TR("精灵宝藏"),
		[const_game.ScreenType] = const_game.H_Screen_Type,
        ["caijin_type"] = 2,
        ["anims"] = {
            10203
        },
        [const_game.Cocos_Support] = true,
    },
    [229] = {
        [const_game.Icon] = 229,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] = TR("维加斯之夜"),
		[const_game.ScreenType] = const_game.H_Screen_Type,
        ["caijin_type"] = 4,
        ["anims"] = {
            10204
        },
        [const_game.Cocos_Support] = true,
    },
    [230] = {
        [const_game.Icon] = 230,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] = TR("招财猫"),
		[const_game.ScreenType] = const_game.V_Screen_Type,
        ["caijin_type"] = 5,
        ["anims"] = {
            10205
        },
        [const_game.Cocos_Support] = true,
    },
    [231] = {
        [const_game.Icon] = 231,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] = TR("富贵树"),
		[const_game.ScreenType] = const_game.V_Screen_Type,
        ["caijin_type"] = 1,
        ["anims"] = {
            10204
        },
        [const_game.Cocos_Support] = true,
    },
    [232] = {
        [const_game.Icon] = 232,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] = TR("金猪报喜"),
		[const_game.ScreenType] = const_game.V_Screen_Type,
        ["caijin_type"] = 3,
        ["anims"] = {
            10203
        },
        [const_game.Cocos_Support] = true,
    },
    [233] = {
        [const_game.Icon] = 233,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] = TR("大福盛典"),
		[const_game.ScreenType] = const_game.H_Screen_Type,
        ["caijin_type"] = 4,
        ["anims"] = {
            10203
        },
    },
    [234] = {
        [const_game.Icon] = 234,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] =TR("777"),
		[const_game.ScreenType] = const_game.H_Screen_Type,
        ["caijin_type"] = 2,
        ["anims"] = {
            10206
        },
        [const_game.Cocos_Support] = true,
    },
    [251] = {
        [const_game.Icon] = 251,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] =TR("88FORTUNES_5"),
        [const_game.ScreenType] = const_game.H_Screen_Type,
        ["caijin_type"] = 3,
        ["anims"] = {
            10203
        },
        [const_game.Cocos_Support] = true,
    },
    [252] = {
        [const_game.Icon] = 252,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] =TR("DOUBLE BLESSINGS"),
		[const_game.ScreenType] = const_game.V_Screen_Type,
        ["caijin_type"] = 3,
        ["anims"] = {
            10203
        },
        [const_game.Cocos_Support] = true,
    },
    [255] = {
        [const_game.Icon] = 255,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] =TR("DIAMOND ETERNITY"),
		[const_game.ScreenType] = const_game.H_Screen_Type,
        ["caijin_type"] = 3,
        ["anims"] = {
            10204
        },
        [const_game.Cocos_Support] = true,
    },
    [256] = {
        [const_game.Icon] = 256,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] =TR("88FORTUNES_3"),
		[const_game.ScreenType] = const_game.H_Screen_Type,
        ["caijin_type"] = 3,
        ["anims"] = {
            10205
        },
        [const_game.Cocos_Support] = true,
    },
    [257] = {
        [const_game.Icon] = 257,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] =TR("DUANWU"),
		[const_game.ScreenType] = const_game.H_Screen_Type,
        ["caijin_type"] = 3,
        ["anims"] = {
            10205
        },
        [const_game.Cocos_Support] = true,
    },
    [258] = {
        [const_game.Icon] = 258,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] =TR("DANCING DRUMS"),
		[const_game.ScreenType] = const_game.V_Screen_Type,
        ["caijin_type"] = 3,
        ["anims"] = {
            10206
        },
        [const_game.Cocos_Support] = true,
    },
    [259] = {
        [const_game.Icon] = 259,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] =TR("RISING FORTUNES"),
		[const_game.ScreenType] = const_game.H_Screen_Type,
        ["caijin_type"] = 1,
        ["anims"] = {
            10205
        },
        [const_game.Cocos_Support] = true,
    },
    [260] = {
        [const_game.Icon] = 260,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] =TR("5TREASURES"),
		[const_game.ScreenType] = const_game.H_Screen_Type,
        ["caijin_type"] = 3,
        ["anims"] = {
            10205
        },
        [const_game.Cocos_Support] = true,
    },
    [270] = {
        [const_game.Icon] = 270,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] =TR("财富之眼"),
		[const_game.ScreenType] = const_game.H_Screen_Type,
        [const_game.Reconnect_Msg] = 'PKG_Slots_Client_EyesOfWealthEnterResumed',
        ["caijin_type"] = 1,
        ["anims"] = {
            10202
        },
        [const_game.Cocos_Support] = true,
        [const_game.FGUI_Support] = true,
        [const_game.FGUI_Release] = true,
    },
    [271] = {
        [const_game.Icon] = 271,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] =TR("东海龙王"),
		[const_game.ScreenType] = const_game.H_Screen_Type,
        ["caijin_type"] = 4,
        ["anims"] = {
            10202
        },
        [const_game.Cocos_Support] = true,
    },
    [272] = {
        [const_game.Icon] = 272,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] =TR("女娲"),
		[const_game.ScreenType] = const_game.H_Screen_Type,
        [const_game.Reconnect_Msg] = 'PKG_Slots_Client_NvwaEnterResumed',
        ["caijin_type"] = 4,
        ["anims"] = {
            10202
        },
        [const_game.Cocos_Support] = true,
        [const_game.FGUI_Support] = true,
        [const_game.FGUI_Release] = true,
    },
    [273] = {
        [const_game.Icon] = 273,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] =TR("锦鲤报喜"),
		[const_game.ScreenType] = const_game.H_Screen_Type,
        [const_game.Reconnect_Msg] = 'PKG_Slots_Client_KoiAnnunciationEnterResumed',
        ["caijin_type"] = 4,
        ["anims"] = {
            10206
        },
        [const_game.Cocos_Support] = true,
        -- 关闭，不使用FGUI版本
        -- [const_game.FGUI_Support] = true,
        -- [const_game.FGUI_Release] = true,
    },
    [274] = {
        [const_game.Icon] = 274,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] =TR("财神到"),
		[const_game.ScreenType] = const_game.H_Screen_Type,
        [const_game.Reconnect_Msg] = 'PKG_Slots_Client_fafafa_WealthGoldEnterResumed',
        ["caijin_type"] = 3,
        ["anims"] = {
            10203
        },
        [const_game.Cocos_Support] = true,
        -- 关闭，不使用FGUI版本
        -- [const_game.FGUI_Support] = true,
        -- [const_game.FGUI_Release] = true,
    },
    [275] = {
        [const_game.Icon] = 275,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] =TR("五龙争霸"),
		[const_game.ScreenType] = const_game.H_Screen_Type,
        [const_game.Reconnect_Msg] = 'PKG_Slots_Client_fafafa_WealthGoldEnterResumed',
        ["caijin_type"] = 3,
        ["anims"] = {
            10207
        },
        [const_game.Cocos_Support] = true,
        -- 关闭，不使用FGUI版本
        -- [const_game.FGUI_Support] = true,
        -- [const_game.FGUI_Release] = true,
    },
    [276] = {
        [const_game.Icon] = 276,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] =TR("财神赐宝"),
		[const_game.ScreenType] = const_game.H_Screen_Type,
        ["caijin_type"] = 3,
        ["anims"] = {
            10208
        },
        [const_game.Cocos_Support] = true,
    },
    [277] = {
        [const_game.Icon] = 277,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] =TR("龙之宝藏"),
		[const_game.ScreenType] = const_game.H_Screen_Type,
        [const_game.Reconnect_Msg] = 'PKG_Slots_Client_DragonGiftEnterResumed',
        ["caijin_type"] = 1,
        ["anims"] = {
            10204
        },
        [const_game.Cocos_Support] = true,
        [const_game.FGUI_Support] = true,
        [const_game.FGUI_Release] = true,
    },
    [278] = {
        [const_game.Icon] = 278,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] =TR("运财锦鲤"),
		[const_game.ScreenType] = const_game.H_Screen_Type,
        ["caijin_type"] = 4,
        ["anims"] = {
            10205
        },
        [const_game.Cocos_Support] = true,
    },
    [279] = {
        [const_game.Icon] = 279,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] =TR("天马"),
		[const_game.ScreenType] = const_game.H_Screen_Type,
        ["caijin_type"] = 4,
        ["anims"] = {
            10202
        },
        [const_game.Cocos_Support] = true,
    },
    [280] = {
        [const_game.Icon] = 280,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] =TR("龙族王子"),
		[const_game.ScreenType] = const_game.H_Screen_Type,
        ["caijin_type"] = 4,
        ["anims"] = {
            10203
        },
        [const_game.Cocos_Support] = true,
    },
    [281] = {
        [const_game.Icon] = 281,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] =TR("运财龙神"),
		[const_game.ScreenType] = const_game.H_Screen_Type,
        ["caijin_type"] = 4,
        ["anims"] = {
            10204
        },
        [const_game.Cocos_Support] = true,
    },
    [282] = {
        [const_game.Icon] = 282,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] =TR("女侠"),
		[const_game.ScreenType] = const_game.H_Screen_Type,
        [const_game.Reconnect_Msg] = 'PKG_Slots_Client_NvXiaEnterResumed',
        ["caijin_type"] = 1,
        ["anims"] = {
            10205
        },
        [const_game.Cocos_Support] = true,
        [const_game.FGUI_Support] = true,
        [const_game.FGUI_Release] = true,
    },
    [283] = {
        [const_game.Icon] = 283,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] =TR("招财狮"),
		[const_game.ScreenType] = const_game.H_Screen_Type,
        ["caijin_type"] = 3,
        ["anims"] = {
            10206
        },
        [const_game.Cocos_Support] = true,
    },
    [288] = {
        [const_game.Icon] = 288,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] =TR("龙腾虎啸"),
		[const_game.ScreenType] = const_game.H_Screen_Type,
        ["caijin_type"] = 1,
        ["anims"] = {
            10202
        },
        [const_game.Cocos_Support] = true,
    },
    [289] = {
        [const_game.Icon] = 289,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] =TR("哪吒闹海"),
		[const_game.ScreenType] = const_game.H_Screen_Type,
        ["caijin_type"] = 3,
        ["anims"] = {
            10202
        },
        [const_game.Cocos_Support] = true,
    },
    [291] = {
        [const_game.Icon] = 291,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] =TR("中秋佳节"),
		[const_game.ScreenType] = const_game.H_Screen_Type,
        ["caijin_type"] = 3,
        ["anims"] = {
            10203
        },
        [const_game.Cocos_Support] = true,
    },
    [292] = {
        [const_game.Icon] = 292,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] =TR("美女猫咪"),
		[const_game.ScreenType] = const_game.H_Screen_Type,
        ["caijin_type"] = 3,
        ["anims"] = {
            10204
        },
        [const_game.Cocos_Support] = true,
    },
    [293] = {
        [const_game.Icon] = 293,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] =TR("财神在线"),
		[const_game.ScreenType] = const_game.H_Screen_Type,
        ["caijin_type"] = 3,
        ["anims"] = {
            10206
        },
        [const_game.Cocos_Support] = true,
    },
    [294] = {
        [const_game.Icon] = 294,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] =TR("五皇争霸"),
		[const_game.ScreenType] = const_game.H_Screen_Type,
        ["caijin_type"] = 3,
        ["anims"] = {
            10202
        },
        [const_game.Cocos_Support] = true,
    },
    [295] = {
        [const_game.Icon] = 295,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] =TR("幸运女皇"),
		[const_game.ScreenType] = const_game.H_Screen_Type,
        ["caijin_type"] = 3,
        ["anims"] = {
            10204
        },
        [const_game.Cocos_Support] = true,
    },
    [296] = {
        [const_game.Icon] = 296,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] =TR("虎威公主"),
		[const_game.ScreenType] = const_game.H_Screen_Type,
        ["caijin_type"] = 3,
        ["anims"] = {
            10206
        },
        [const_game.Cocos_Support] = true,
    },
    [297] = {
        [const_game.Icon] = 297,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] =TR("熊猫滚滚"),
		[const_game.ScreenType] = const_game.H_Screen_Type,
        ["caijin_type"] = 3,
        ["anims"] = {
            10205
        },
        [const_game.Cocos_Support] = true,
    },
    [298] = {
        [const_game.Icon] = 298,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] =TR("大圣爷"),
		[const_game.ScreenType] = const_game.H_Screen_Type,
        ["caijin_type"] = 3,
        ["anims"] = {
            10203
        },
        [const_game.Cocos_Support] = true,
    },
    [299] = {
        [const_game.Icon] = 299,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] =TR("鸿福"),
		[const_game.ScreenType] = const_game.H_Screen_Type,
        ["caijin_type"] = 3,
        ["anims"] = {
            10206
        },
        [const_game.Cocos_Support] = true,
    },
    [301] = {
        [const_game.Icon] = 301,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] =TR("熊猫宝贝"),
		[const_game.ScreenType] = const_game.H_Screen_Type,
        ["caijin_type"] = 3,
        ["anims"] = {
            10202
        },
        [const_game.Cocos_Support] = true,
    },
    [302] = {
        [const_game.Icon] = 302,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] =TR("双喜熊猫"),
		[const_game.ScreenType] = const_game.H_Screen_Type,
        ["caijin_type"] = 3,
        ["anims"] = {
            10202
        },
        [const_game.Cocos_Support] = true,
    },
    [303] = {
        [const_game.Icon] = 303,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] =TR("虎虎献瑞"),
		[const_game.ScreenType] = const_game.H_Screen_Type,
        ["caijin_type"] = 3,
        ["anims"] = {
            10206
        },
        [const_game.Cocos_Support] = true,
    },
    [304] = {
        [const_game.Icon] = 304,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] =TR("金福满堂"),
		[const_game.ScreenType] = const_game.H_Screen_Type,
        ["caijin_type"] = 3,
        ["anims"] = {
            10206
        },
        [const_game.Cocos_Support] = true,
    },
    [305] = {
        [const_game.Icon] = 305,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] =TR("赤红女皇"),
		[const_game.ScreenType] = const_game.H_Screen_Type,
        ["caijin_type"] = 3,
        ["anims"] = {
            10202
        },
        [const_game.Cocos_Support] = true,
    },
    [306] = {
        [const_game.Icon] = 306,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] =TR("天龙地虎"),
		[const_game.ScreenType] = const_game.H_Screen_Type,
        ["caijin_type"] = 3,
        ["anims"] = {
            10306
        },
        [const_game.Cocos_Support] = true,
    },
    [307] = {
        [const_game.Icon] = 307,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] =TR("巨龙宝藏"),
		[const_game.ScreenType] = const_game.H_Screen_Type,
        ["caijin_type"] = 3,
        ["anims"] = {
            10307
        },
        [const_game.Cocos_Support] = true,
    },
    [309] = {
        [const_game.Icon] = 309,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] =TR("富贵之花"),
		[const_game.ScreenType] = const_game.H_Screen_Type,
        ["caijin_type"] = 3,
        ["anims"] = {
            10206
        },
        [const_game.Cocos_Support] = true,
    },
    [310] = {
        [const_game.Icon] = 310,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] =TR("财富之树"),
		[const_game.ScreenType] = const_game.V_Screen_Type,
        ["caijin_type"] = 3,
        ["anims"] = {
            10202
        },
        [const_game.Cocos_Support] = true,
    },

    [311] = {
        [const_game.Icon] = 311,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] =TR("终极火链"),
		[const_game.ScreenType] = const_game.V_Screen_Type,
        ["caijin_type"] = 3,
        ["anims"] = {
            10204
        },
        [const_game.Cocos_Support] = true,
    },

    [313] = {
        [const_game.Icon] = 313,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] =TR("女猎手"),
		[const_game.ScreenType] = const_game.H_Screen_Type,
        ["caijin_type"] = 3,
        ["anims"] = {
            10203
        },
        [const_game.Cocos_Support] = true,
    },
    [315] = {
        [const_game.Icon] = 315,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] =TR("财富之树Ⅱ"),
		[const_game.ScreenType] = const_game.V_Screen_Type,
        ["caijin_type"] = 3,
        ["anims"] = {
            10202
        },
        [const_game.Cocos_Support] = true,
        [const_game.FGUI_Support] = true,
        [const_game.FGUI_Release] = false
    },
    [317] = {
        [const_game.Icon] = 317,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] =TR("金吉报喜-龙"),
		[const_game.ScreenType] = const_game.H_Screen_Type,
        ["caijin_type"] = 1,
        ["anims"] = {
            10205
        },
        [const_game.Cocos_Support] = true,
	},
    [318] = {
        [const_game.Icon] = 318,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] =TR("金吉报喜-猪"),
		[const_game.ScreenType] = const_game.H_Screen_Type,
        ["caijin_type"] = 1,
        ["anims"] = {
            10205
        },
        [const_game.Cocos_Support] = true,
	},
    [319] = {
        [const_game.Icon] = 319,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] =TR("DANCING DRUMSⅡ"),
		[const_game.ScreenType] = const_game.V_Screen_Type,
        ["caijin_type"] = 3,
        ["anims"] = {
            10206
        },
        [const_game.Cocos_Support] = true,
    },
    [320] = {
        [const_game.Icon] = 320,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] =TR("弥勒佛"),
		[const_game.ScreenType] = const_game.H_Screen_Type,
        ["caijin_type"] = 2,
        ["anims"] = {
            10306
        },
        [const_game.Cocos_Support] = true,
    },
    [321] = {
        [const_game.Icon] = 321,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] =TR("中秋"),
		[const_game.ScreenType] = const_game.H_Screen_Type,
        ["caijin_type"] = 2,
        ["anims"] = {
            10306
        },
        [const_game.Cocos_Support] = true,
    },
    [322] = {
        [const_game.Icon] = 322,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] =TR("黄金纪元"),
		[const_game.ScreenType] = const_game.H_Screen_Type,
        ["caijin_type"] = 2,
        ["anims"] = {
            10306
        },
        [const_game.Cocos_Support] = true,
    },
    [323] = {
        [const_game.Icon] = 323,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] =TR("春节"),
		[const_game.ScreenType] = const_game.H_Screen_Type,
        ["caijin_type"] = 2,
        ["anims"] = {
            10306
        },
        [const_game.Cocos_Support] = true,
    },
    [331] = {
        [const_game.Icon] = 331,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] =TR("新黄金88"),
		[const_game.ScreenType] = const_game.V_Screen_Type,
        ["caijin_type"] = 5,
        ["anims"] = {
            10202
        },
        [const_game.Cocos_Support] = true,
    },
    [332] = {
        [const_game.Icon] = 332,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] =TR("新狂野蛮牛"),
		[const_game.ScreenType] = const_game.H_Screen_Type,
        ["caijin_type"] = 4,
        ["anims"] = {
            10203
        },
        [const_game.Cocos_Support] = true,
    },
    [333] = {
        [const_game.Icon] = 333,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] =TR("新招财猫"),
		[const_game.ScreenType] = const_game.V_Screen_Type,
        ["caijin_type"] = 5,
        ["anims"] = {
            10205
        },
        [const_game.Cocos_Support] = true,
    },
    [335] = {
        [const_game.Icon] = 335,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] = TR("天赐金路"),
		[const_game.ScreenType] = const_game.V_Screen_Type,
        [const_game.Reconnect_Msg] = 'PKG_Slots_Client_GoldenRoadEnterResumed',
        ["caijin_type"] = 5,
        ["anims"] = {
            10205
        },
        [const_game.FGUI_Support] = true,
        [const_game.FGUI_Release] = true
    },
    [336] = {
        [const_game.Icon] = 336,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] =TR("和平&长寿"),
		[const_game.ScreenType] = const_game.H_Screen_Type,
        [const_game.Reconnect_Msg] = 'PKG_Slots_Client_DragonGiftEnterResumed',
        ["caijin_type"] = 1,
        ["anims"] = {
            10204
        },
        [const_game.Cocos_Support] = false,
        [const_game.FGUI_Support] = true,
        [const_game.FGUI_Release] = true,
    },
    [338] = {
        [const_game.Icon] = 338,
        [const_game.Game_type] = "casino",
        [const_game.Game_Name] = TR("黄金万两-神奇的老鼠"),
        [const_game.ScreenType] = const_game.V_Screen_Type,
        [const_game.Reconnect_Msg] = "PKG_Slots_Client_CoinComboMouseEnterResumed",
        ["caijin_type"] = 5,
        ["anims"] = {
            10205
        },
        [const_game.FGUI_Support] = true,
        [const_game.FGUI_Release] = true
    },
    [353] = {
        [const_game.Icon] = 353,
        [const_game.Game_type] = "casino",
        [const_game.Game_Name] = TR("野牛-豪华版"),
        [const_game.ScreenType] = const_game.H_Screen_Type,
        [const_game.Reconnect_Msg] = "PKG_Slots_Client_BuffaloEnterResumed",
        ["caijin_type"] = 5,
        ["anims"] = {
            10205
        },
        [const_game.FGUI_Support] = true,
        [const_game.FGUI_Release] = true
    },
    [340] = {
        [const_game.Icon] = 340,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] = TR("福袋连连-熊猫"),
        [const_game.ScreenType] = const_game.V_Screen_Type,
        [const_game.Reconnect_Msg] = 'PKG_Slots_Client_PandaEnterResumed',
        ["caijin_type"] = 5,
        ["anims"] = {
            10205
        },
        [const_game.Cocos_Support] = false,
        [const_game.FGUI_Support] = true,
        [const_game.FGUI_Release] = true
    },
    [341] = {
        [const_game.Icon] = 341,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] = TR("魔法熊猫"),
		[const_game.ScreenType] = const_game.H_Screen_Type,
        [const_game.Reconnect_Msg] = 'PKG_Slots_Client_EyesOfWealthEnterResumed',
        ["caijin_type"] = 5,
        ["anims"] = {
            10205
        },
        [const_game.Cocos_Support] = false,
        [const_game.FGUI_Support] = true,
        [const_game.FGUI_Release] = true
    },
    [345] = {
        [const_game.Icon] = 345,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] = TR("丝绸之路"),
		[const_game.ScreenType] = const_game.H_Screen_Type,
        [const_game.Reconnect_Msg] = 'PKG_Slots_Client_EyesOfWealthEnterResumed',
        ["caijin_type"] = 5,
        ["anims"] = {
            10205
        },
        [const_game.Cocos_Support] = false,
        [const_game.FGUI_Support] = true,
        [const_game.FGUI_Release] = true
    },
    [347] = {
        [const_game.Icon] = 347,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] = TR("快乐灯笼"),
		[const_game.ScreenType] = const_game.H_Screen_Type,
        [const_game.Reconnect_Msg] = 'PKG_Slots_Client_HappyLanternEnterResumed',
        ["caijin_type"] = 5,
        ["anims"] = {
            10205
        },
        [const_game.Cocos_Support] = false,
        [const_game.FGUI_Support] = true,
        [const_game.FGUI_Release] = true
    },
    [348] = {
        [const_game.Icon] = 348,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] =TR("中秋"),
		[const_game.ScreenType] = const_game.H_Screen_Type,
        [const_game.Reconnect_Msg] = 'PKG_Slots_Client_EyesOfWealthEnterResumed',
        ["caijin_type"] = 2,
        ["anims"] = {
            10205
        },
        [const_game.FGUI_Support] = true,
        [const_game.FGUI_Release] = true
    },
    [349] = {
        [const_game.Icon] = 349,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] =TR("黄金纪元"),
		[const_game.ScreenType] = const_game.H_Screen_Type,
        [const_game.Reconnect_Msg] = 'PKG_Slots_Client_EyesOfWealthEnterResumed',
        ["caijin_type"] = 2,
        ["anims"] = {
            10205
        },
        [const_game.FGUI_Support] = true,
        [const_game.FGUI_Release] = true
    },
    [350] = {
        [const_game.Icon] = 350,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] = TR("皇室神猴"),
        [const_game.ScreenType] = const_game.V_Screen_Type,
        [const_game.Reconnect_Msg] = 'PKG_Slots_Client_RoyalMonkeyEnterResumed',
        ["caijin_type"] = 5,
        ["anims"] = {
            10205
        },
        [const_game.Cocos_Support] = false,
        [const_game.FGUI_Support] = true,
        [const_game.FGUI_Release] = true
    },
    [355] = {
        [const_game.Icon] = 355,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] = TR("福袋连连-龙"),
        [const_game.ScreenType] = const_game.V_Screen_Type,
        [const_game.Reconnect_Msg] = 'PKG_Slots_Client_PandaEnterResumed',
        ["caijin_type"] = 5,
        ["anims"] = {
            10205
        },
        [const_game.Cocos_Support] = false,
        [const_game.FGUI_Support] = true,
        [const_game.FGUI_Release] = true
    },
    [360] = {
        [const_game.Icon] = 360,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] =TR("发财牛"),
		[const_game.ScreenType] = const_game.V_Screen_Type,
        [const_game.Reconnect_Msg] = 'PKG_Slots_Client_LuckyBullEnterResumed',
        ["caijin_type"] = 2,
        ["anims"] = {
            10205
        },
        [const_game.FGUI_Support] = true,
        [const_game.FGUI_Release] = true
    },
    [366] = {
        [const_game.Icon] = 366,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] =TR("幸运小猪"),
		[const_game.ScreenType] = const_game.V_Screen_Type,
        [const_game.Reconnect_Msg] = 'PKG_Slots_Client_LuckyPigEnterResumed',
        ["caijin_type"] = 1,
        ["anims"] = {
            10204
        },
        [const_game.FGUI_Support] = true,
        [const_game.FGUI_Release] = true
    },
    [367] = {
        [const_game.Icon] = 367,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] =TR("仙人"),
		[const_game.ScreenType] = const_game.H_Screen_Type,
        [const_game.Reconnect_Msg] = 'PKG_Slots_Client_TheGreatImmortalsEnterResumed',
        ["caijin_type"] = 1,
        ["anims"] = {
            10204
        },
        [const_game.FGUI_Support] = true,
        [const_game.FGUI_Release] = true
    },
    [368] = {
        [const_game.Icon] = 368,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] =TR("埃及宝藏"),
		[const_game.ScreenType] = const_game.H_Screen_Type,
        [const_game.Reconnect_Msg] = 'PKG_Slots_Client_TheGreatImmortalsEnterResumed',
        ["caijin_type"] = 1,
        ["anims"] = {
            10204
        },
        [const_game.FGUI_Support] = true,
        [const_game.FGUI_Release] = true
    },
    [369] = {
        [const_game.Icon] = 369,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] =TR("财富"),
		[const_game.ScreenType] = const_game.V_Screen_Type,
        [const_game.Reconnect_Msg] = 'PKG_Slots_Client_MoneyIconsEnterResumed',
        ["caijin_type"] = 1,
        ["anims"] = {
            10204
        },
        [const_game.FGUI_Support] = true,
        [const_game.FGUI_Release] = true
    },

    [370] = {
        [const_game.Icon] = 370,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] =TR("深海"),
		[const_game.ScreenType] = const_game.H_Screen_Type,
        [const_game.Reconnect_Msg] = 'PKG_Slots_Client_DeepSeaEnterResumed',
        ["caijin_type"] = 1,
        ["anims"] = {
            10204
        },
        [const_game.FGUI_Support] = true,
        [const_game.FGUI_Release] = true
    },

    [371] = {
        [const_game.Icon] = 371,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] =TR("甜蜜的鸣叫"),
		[const_game.ScreenType] = const_game.H_Screen_Type,
        [const_game.Reconnect_Msg] = 'PKG_Slots_Client_DeepSeaEnterResumed',
        ["caijin_type"] = 1,
        ["anims"] = {
            10204
        },
        [const_game.FGUI_Support] = true,
        [const_game.FGUI_Release] = true
    },

    [374] = {
        [const_game.Icon] = 374,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] = TR("庞贝古城2"),
        [const_game.ScreenType] = const_game.H_Screen_Type,
        [const_game.Reconnect_Msg] = 'PKG_Slots_Client_PompeEnterResumed',
        ["caijin_type"] = 1,
        ["anims"] = {
            10204
        },
        [const_game.FGUI_Support] = true,
        [const_game.FGUI_Release] = true
    },

    [375] = {
        [const_game.Icon] = 375,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] = TR("尤里卡列车"),
        [const_game.ScreenType] = const_game.V_Screen_Type,
        [const_game.Reconnect_Msg] = 'PKG_Slots_Client_EurekaTrainEnterResumed',
        ["caijin_type"] = 1,
        ["anims"] = {
            10204
        },
        [const_game.FGUI_Support] = true,
        [const_game.FGUI_Release] = true
    },

    [377] = {
        [const_game.Icon] = 377,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] =TR("金龙宝藏"),
		[const_game.ScreenType] = const_game.H_Screen_Type,
        [const_game.Reconnect_Msg] = 'PKG_Slots_Client_DragonGiftEnterResumed',
        ["caijin_type"] = 1,
        ["anims"] = {
            10204
        },
        [const_game.FGUI_Support] = true,
        [const_game.FGUI_Release] = true
    },

    [378] = {
        [const_game.Icon] = 378,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] =TR("花好月圆"),
		[const_game.ScreenType] = const_game.H_Screen_Type,
        [const_game.Reconnect_Msg] = 'PKG_Slots_Client_EyesOfWealthEnterResumed',
        ["caijin_type"] = 2,
        ["anims"] = {
            10205
        },
        [const_game.FGUI_Support] = true,
        [const_game.FGUI_Release] = true
    },

    [379] = {
        [const_game.Icon] = 379,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] =TR("金色王朝"),
		[const_game.ScreenType] = const_game.H_Screen_Type,
        [const_game.Reconnect_Msg] = 'PKG_Slots_Client_EyesOfWealthEnterResumed',
        ["caijin_type"] = 2,
        ["anims"] = {
            10205
        },
        [const_game.FGUI_Support] = true,
        [const_game.FGUI_Release] = true
    },

    [380] = {
        [const_game.Icon] = 380,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] =TR("Tiger's Eye"),
		[const_game.ScreenType] = const_game.H_Screen_Type,
        [const_game.Reconnect_Msg] = 'PKG_Slots_Client_EyesOfWealthEnterResumed',
        ["caijin_type"] = 1,
        ["anims"] = {
            10202
        },
        [const_game.FGUI_Support] = true,
        [const_game.FGUI_Release] = true
    },

    [381] = {
        [const_game.Icon] = 381,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] = TR("百变熊猫"),
		[const_game.ScreenType] = const_game.H_Screen_Type,
        [const_game.Reconnect_Msg] = 'PKG_Slots_Client_EyesOfWealthEnterResumed',
        ["caijin_type"] = 5,
        ["anims"] = {
            10205
        },
        [const_game.Cocos_Support] = false,
        [const_game.FGUI_Support] = true,
        [const_game.FGUI_Release] = true
    },

    [382] = {
        [const_game.Icon] = 382,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] =TR("剑来"),
		[const_game.ScreenType] = const_game.H_Screen_Type,
        [const_game.Reconnect_Msg] = 'PKG_Slots_Client_NvXiaEnterResumed',
        ["caijin_type"] = 1,
        ["anims"] = {
            10205
        },
        [const_game.FGUI_Support] = true,
        [const_game.FGUI_Release] = true
    },

    [383] = {
        [const_game.Icon] = 383,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] =TR("美人鱼"),
		[const_game.ScreenType] = const_game.H_Screen_Type,
        [const_game.Reconnect_Msg] = 'PKG_Slots_Client_EyesOfWealthEnterResumed',
        ["caijin_type"] = 1,
        ["anims"] = {
            10202
        },
        [const_game.FGUI_Support] = true,
        [const_game.FGUI_Release] = true
    },

    [384] = {
        [const_game.Icon] = 384,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] = TR("舞狮"),
		[const_game.ScreenType] = const_game.H_Screen_Type,
        [const_game.Reconnect_Msg] = 'PKG_Slots_Client_HappyLanternEnterResumed',
        ["caijin_type"] = 5,
        ["anims"] = {
            10205
        },
        [const_game.Cocos_Support] = false,
        [const_game.FGUI_Support] = true,
        [const_game.FGUI_Release] = true
    },

    [385] = {
        [const_game.Icon] = 385,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] = TR("少林寺"),
		[const_game.ScreenType] = const_game.H_Screen_Type,
        [const_game.Reconnect_Msg] = 'PKG_Slots_Client_EyesOfWealthEnterResumed',
        ["caijin_type"] = 5,
        ["anims"] = {
            10205
        },
        [const_game.Cocos_Support] = false,
        [const_game.FGUI_Support] = true,
        [const_game.FGUI_Release] = true
    },

    [386] = {
        [const_game.Icon] = 386,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] =TR("情人节"),
		[const_game.ScreenType] = const_game.H_Screen_Type,
        [const_game.Reconnect_Msg] = 'PKG_Slots_Client_DragonGiftEnterResumed',
        ["caijin_type"] = 1,
        ["anims"] = {
            10204
        },
        [const_game.FGUI_Support] = true,
        [const_game.FGUI_Release] = true
    },

    [387] = {
        [const_game.Icon] = 387,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] = TR("黄金佛"),
		[const_game.ScreenType] = const_game.H_Screen_Type,
        [const_game.Reconnect_Msg] = 'PKG_Slots_Client_EyesOfWealthEnterResumed',
        ["caijin_type"] = 5,
        ["anims"] = {
            10205
        },
        [const_game.Cocos_Support] = false,
        [const_game.FGUI_Support] = true,
        [const_game.FGUI_Release] = true
    },

    [388] = {
        [const_game.Icon] = 388,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] =TR("江湖儿女"),
		[const_game.ScreenType] = const_game.H_Screen_Type,
        [const_game.Reconnect_Msg] = 'PKG_Slots_Client_NvXiaEnterResumed',
        ["caijin_type"] = 1,
        ["anims"] = {
            10205
        },
        [const_game.FGUI_Support] = true,
        [const_game.FGUI_Release] = true
    },

    [389] = {
        [const_game.Icon] = 389,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] = TR("大闹龙宫"),
		[const_game.ScreenType] = const_game.H_Screen_Type,
        [const_game.Reconnect_Msg] = 'PKG_Slots_Client_EyesOfWealthEnterResumed',
        ["caijin_type"] = 5,
        ["anims"] = {
            10205
        },
        [const_game.Cocos_Support] = false,
        [const_game.FGUI_Support] = true,
        [const_game.FGUI_Release] = true
    },

    [390] = {
        [const_game.Icon] = 390,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] =TR("中国春节"),
		[const_game.ScreenType] = const_game.H_Screen_Type,
        [const_game.Reconnect_Msg] = 'PKG_Slots_Client_EyesOfWealthEnterResumed',
        ["caijin_type"] = 1,
        ["anims"] = {
            10202
        },
        [const_game.FGUI_Support] = true,
        [const_game.FGUI_Release] = true
    },

    [391] = {
        [const_game.Icon] = 391,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] =TR("老寿星"),
		[const_game.ScreenType] = const_game.H_Screen_Type,
        [const_game.Reconnect_Msg] = 'PKG_Slots_Client_DragonGiftEnterResumed',
        ["caijin_type"] = 1,
        ["anims"] = {
            10204
        },
        [const_game.FGUI_Support] = true,
        [const_game.FGUI_Release] = true
    },

    [392] = {
        [const_game.Icon] = 392,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] =TR("龙腾"),
		[const_game.ScreenType] = const_game.H_Screen_Type,
        [const_game.Reconnect_Msg] = 'PKG_Slots_Client_NvXiaEnterResumed',
        ["caijin_type"] = 1,
        ["anims"] = {
            10205
        },
        [const_game.FGUI_Support] = true,
        [const_game.FGUI_Release] = true
    },

    [393] = {
        [const_game.Icon] = 393,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] =TR("帝王之力"),
		[const_game.ScreenType] = const_game.H_Screen_Type,
        [const_game.Reconnect_Msg] = 'PKG_Slots_Client_EyesOfWealthEnterResumed',
        ["caijin_type"] = 2,
        ["anims"] = {
            10205
        },
        [const_game.FGUI_Support] = true,
        [const_game.FGUI_Release] = true
    },

    [394] = {
        [const_game.Icon] = 394,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] =TR("孔雀公主"),
		[const_game.ScreenType] = const_game.H_Screen_Type,
        [const_game.Reconnect_Msg] = 'PKG_Slots_Client_EyesOfWealthEnterResumed',
        ["caijin_type"] = 1,
        ["anims"] = {
            10202
        },
        [const_game.FGUI_Support] = true,
        [const_game.FGUI_Release] = true
    },

    [395] = {
        [const_game.Icon] = 395,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] =TR("埃及女王"),
		[const_game.ScreenType] = const_game.H_Screen_Type,
        [const_game.Reconnect_Msg] = 'PKG_Slots_Client_DragonGiftEnterResumed',
        ["caijin_type"] = 1,
        ["anims"] = {
            10204
        },
        [const_game.FGUI_Support] = true,
        [const_game.FGUI_Release] = true
    },

    [396] = {
        [const_game.Icon] = 396,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] =TR("成吉思汗"),
		[const_game.ScreenType] = const_game.H_Screen_Type,
        [const_game.Reconnect_Msg] = 'PKG_Slots_Client_DragonGiftEnterResumed',
        ["caijin_type"] = 1,
        ["anims"] = {
            10204
        },
        [const_game.FGUI_Support] = true,
        [const_game.FGUI_Release] = true
    },

    [397] = {
        [const_game.Icon] = 397,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] =TR("热辣墨西哥"),
		[const_game.ScreenType] = const_game.H_Screen_Type,
        [const_game.Reconnect_Msg] = 'PKG_Slots_Client_EyesOfWealthEnterResumed',
        ["caijin_type"] = 2,
        ["anims"] = {
            10205
        },
        [const_game.FGUI_Support] = true,
        [const_game.FGUI_Release] = true
    },

    [398] = {
        [const_game.Icon] = 398,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] = TR("黄金锦鲤"),
		[const_game.ScreenType] = const_game.H_Screen_Type,
        [const_game.Reconnect_Msg] = 'PKG_Slots_Client_HappyLanternEnterResumed',
        ["caijin_type"] = 5,
        ["anims"] = {
            10205
        },
        [const_game.Cocos_Support] = false,
        [const_game.FGUI_Support] = true,
        [const_game.FGUI_Release] = true
    },

    [399] = {
        [const_game.Icon] = 399,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] = TR("红运锦鲤"),
		[const_game.ScreenType] = const_game.H_Screen_Type,
        [const_game.Reconnect_Msg] = 'PKG_Slots_Client_EyesOfWealthEnterResumed',
        ["caijin_type"] = 5,
        ["anims"] = {
            10205
        },
        [const_game.Cocos_Support] = false,
        [const_game.FGUI_Support] = true,
        [const_game.FGUI_Release] = true
    },

    [400] = {
        [const_game.Icon] = 400,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] =TR("尼罗河之女"),
		[const_game.ScreenType] = const_game.H_Screen_Type,
        [const_game.Reconnect_Msg] = 'PKG_Slots_Client_EyesOfWealthEnterResumed',
        ["caijin_type"] = 1,
        ["anims"] = {
            10202
        },
        [const_game.FGUI_Support] = true,
        [const_game.FGUI_Release] = true
    },

    [401] = {
        [const_game.Icon] = 401,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] =TR("龙之宝藏"),
		[const_game.ScreenType] = const_game.H_Screen_Type,
        [const_game.Reconnect_Msg] = 'PKG_Slots_Client_DragonGiftEnterResumed',
        ["caijin_type"] = 1,
        ["anims"] = {
            10204
        },
        [const_game.FGUI_Support] = true,
        [const_game.FGUI_Release] = true
    },

    [402] = {
        [const_game.Icon] = 402,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] =TR("黄金圣甲虫"),
		[const_game.ScreenType] = const_game.H_Screen_Type,
        [const_game.Reconnect_Msg] = 'PKG_Slots_Client_NvXiaEnterResumed',
        ["caijin_type"] = 1,
        ["anims"] = {
            10205
        },
        [const_game.FGUI_Support] = true,
        [const_game.FGUI_Release] = true
    },

    [403] = {
        [const_game.Icon] = 403,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] =TR("西部牛仔"),
		[const_game.ScreenType] = const_game.H_Screen_Type,
        [const_game.Reconnect_Msg] = 'PKG_Slots_Client_EyesOfWealthEnterResumed',
        ["caijin_type"] = 2,
        ["anims"] = {
            10205
        },
        [const_game.FGUI_Support] = true,
        [const_game.FGUI_Release] = true
    },

    [404] = {
        [const_game.Icon] = 404,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] = TR("黄金矿工"),
		[const_game.ScreenType] = const_game.H_Screen_Type,
        [const_game.Reconnect_Msg] = 'PKG_Slots_Client_HappyLanternEnterResumed',
        ["caijin_type"] = 5,
        ["anims"] = {
            10205
        },
        [const_game.Cocos_Support] = false,
        [const_game.FGUI_Support] = true,
        [const_game.FGUI_Release] = true
    },

    [405] = {
        [const_game.Icon] = 405,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] = TR("马踏飞燕"),
		[const_game.ScreenType] = const_game.H_Screen_Type,
        [const_game.Reconnect_Msg] = 'PKG_Slots_Client_EyesOfWealthEnterResumed',
        ["caijin_type"] = 5,
        ["anims"] = {
            10205
        },
        [const_game.Cocos_Support] = false,
        [const_game.FGUI_Support] = true,
        [const_game.FGUI_Release] = true
    },

    [406] = {
        [const_game.Icon] = 406,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] = TR("月球漫步"),
		[const_game.ScreenType] = const_game.H_Screen_Type,
        [const_game.Reconnect_Msg] = 'PKG_Slots_Client_EyesOfWealthEnterResumed',
        ["caijin_type"] = 5,
        ["anims"] = {
            10205
        },
        [const_game.Cocos_Support] = false,
        [const_game.FGUI_Support] = true,
        [const_game.FGUI_Release] = true
    },

    [407] = {
        [const_game.Icon] = 407,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] =TR("虎啸"),
		[const_game.ScreenType] = const_game.H_Screen_Type,
        [const_game.Reconnect_Msg] = 'PKG_Slots_Client_NvXiaEnterResumed',
        ["caijin_type"] = 1,
        ["anims"] = {
            10205
        },
        [const_game.FGUI_Support] = true,
        [const_game.FGUI_Release] = true
    },

    [408] = {
        [const_game.Icon] = 408,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] =TR("TIKI之火"),
		[const_game.ScreenType] = const_game.H_Screen_Type,
        [const_game.Reconnect_Msg] = 'PKG_Slots_Client_DragonGiftEnterResumed',
        ["caijin_type"] = 1,
        ["anims"] = {
            10204
        },
        [const_game.FGUI_Support] = true,
        [const_game.FGUI_Release] = true
    },

    [409] = {
        [const_game.Icon] = 409,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] =TR("桑巴舞"),
		[const_game.ScreenType] = const_game.H_Screen_Type,
        [const_game.Reconnect_Msg] = 'PKG_Slots_Client_EyesOfWealthEnterResumed',
        ["caijin_type"] = 1,
        ["anims"] = {
            10202
        },
        [const_game.FGUI_Support] = true,
        [const_game.FGUI_Release] = true
    },

    [410] = {
        [const_game.Icon] = 410,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] =TR("面具舞会"),
		[const_game.ScreenType] = const_game.H_Screen_Type,
        [const_game.Reconnect_Msg] = 'PKG_Slots_Client_EyesOfWealthEnterResumed',
        ["caijin_type"] = 1,
        ["anims"] = {
            10202
        },
        [const_game.FGUI_Support] = true,
        [const_game.FGUI_Release] = true
    },

    [411] = {
        [const_game.Icon] = 411,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] = TR("赛马"),
		[const_game.ScreenType] = const_game.H_Screen_Type,
        [const_game.Reconnect_Msg] = 'PKG_Slots_Client_EyesOfWealthEnterResumed',
        ["caijin_type"] = 5,
        ["anims"] = {
            10205
        },
        [const_game.Cocos_Support] = false,
        [const_game.FGUI_Support] = true,
        [const_game.FGUI_Release] = true
    },

    [412] = {
        [const_game.Icon] = 412,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] =TR("白头鹰"),
		[const_game.ScreenType] = const_game.H_Screen_Type,
        [const_game.Reconnect_Msg] = 'PKG_Slots_Client_NvXiaEnterResumed',
        ["caijin_type"] = 1,
        ["anims"] = {
            10205
        },
        [const_game.FGUI_Support] = true,
        [const_game.FGUI_Release] = true
    },

    [413] = {
        [const_game.Icon] = 413,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] =TR("考拉"),
		[const_game.ScreenType] = const_game.H_Screen_Type,
        [const_game.Reconnect_Msg] = 'PKG_Slots_Client_DragonGiftEnterResumed',
        ["caijin_type"] = 1,
        ["anims"] = {
            10204
        },
        [const_game.FGUI_Support] = true,
        [const_game.FGUI_Release] = true
    },

    [414] = {
        [const_game.Icon] = 414,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] = TR("TOTEM RICHES"),
		[const_game.ScreenType] = const_game.H_Screen_Type,
        [const_game.Reconnect_Msg] = 'PKG_Slots_Client_EyesOfWealthEnterResumed',
        ["caijin_type"] = 5,
        ["anims"] = {
            10205
        },
        [const_game.Cocos_Support] = false,
        [const_game.FGUI_Support] = true,
        [const_game.FGUI_Release] = true
    },

    [415] = {
        [const_game.Icon] = 415,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] =TR("印度虎"),
		[const_game.ScreenType] = const_game.H_Screen_Type,
        [const_game.Reconnect_Msg] = 'PKG_Slots_Client_EyesOfWealthEnterResumed',
        ["caijin_type"] = 2,
        ["anims"] = {
            10205
        },
        [const_game.FGUI_Support] = true,
        [const_game.FGUI_Release] = true
    },

    [416] = {
        [const_game.Icon] = 416,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] = TR("沙漠绿洲"),
		[const_game.ScreenType] = const_game.H_Screen_Type,
        [const_game.Reconnect_Msg] = 'PKG_Slots_Client_HappyLanternEnterResumed',
        ["caijin_type"] = 5,
        ["anims"] = {
            10205
        },
        [const_game.Cocos_Support] = false,
        [const_game.FGUI_Support] = true,
        [const_game.FGUI_Release] = true
    },

    [417] = {
        [const_game.Icon] = 417,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] =TR("财神到Ⅱ"),
		[const_game.ScreenType] = const_game.H_Screen_Type,
        [const_game.Reconnect_Msg] = 'PKG_Slots_Client_fafafa_WealthGoldEnterResumed',
        ["caijin_type"] = 3,
        ["anims"] = {
            10203
        },
        [const_game.Cocos_Support] = false,
        [const_game.FGUI_Support] = true,
        [const_game.FGUI_Release] = true,
    },

    [418] = {
        [const_game.Icon] = 418,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] =TR("五龙争霸"),
		[const_game.ScreenType] = const_game.H_Screen_Type,
        [const_game.Reconnect_Msg] = 'PKG_Slots_Client_fafafa_WealthGoldEnterResumed',
        ["caijin_type"] = 3,
        ["anims"] = {
            10204
        },
        [const_game.Cocos_Support] = false,
        [const_game.FGUI_Support] = true,
        [const_game.FGUI_Release] = true,
    },
    [419] = {
        [const_game.Icon] = 419,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] =TR("五头狮子"),
		[const_game.ScreenType] = const_game.H_Screen_Type,
        [const_game.Reconnect_Msg] = 'PKG_Slots_Client_fafafa_WealthGoldEnterResumed',
        ["caijin_type"] = 3,
        ["anims"] = {
            10205
        },
        [const_game.Cocos_Support] = false,
        [const_game.FGUI_Support] = true,
        [const_game.FGUI_Release] = true,
    },
    [423] = {
        [const_game.Icon] = 423,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] =TR("娲皇"),
		[const_game.ScreenType] = const_game.H_Screen_Type,
        [const_game.Reconnect_Msg] = 'PKG_Slots_Client_NvwaEnterResumed',
        ["caijin_type"] = 4,
        ["anims"] = {
            10202
        },
        [const_game.Cocos_Support] = false,
        [const_game.FGUI_Support] = true,
        [const_game.FGUI_Release] = true,
    },
	[424] = {
        [const_game.Icon] = 424,
        [const_game.Game_type] = "casino",
        [const_game.Game_Name] = TR("胜利88"),
        [const_game.ScreenType] = const_game.H_Screen_Type,
        [const_game.Reconnect_Msg] = "PKG_Slots_Client_LuckyDiceEnterResumed",
        ["caijin_type"] = 5,
        ["anims"] = {
            10205
        },
        [const_game.FGUI_Support] = true,
        [const_game.FGUI_Release] = true
    },
    [425] = {
        [const_game.Icon] = 425,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] =TR("森林泰山"),
		[const_game.ScreenType] = const_game.H_Screen_Type,
        [const_game.Reconnect_Msg] = 'PKG_Slots_Client_NvwaEnterResumed',
        ["caijin_type"] = 4,
        ["anims"] = {
            10202
        },
        [const_game.Cocos_Support] = false,
        [const_game.FGUI_Support] = true,
        [const_game.FGUI_Release] = true,
    },
    [426] = {
        [const_game.Icon] = 426,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] =TR("森林狼"),
		[const_game.ScreenType] = const_game.H_Screen_Type,
        [const_game.Reconnect_Msg] = 'PKG_Slots_Client_DragonGiftEnterResumed',
        ["caijin_type"] = 1,
        ["anims"] = {
            10204
        },
        [const_game.FGUI_Support] = true,
        [const_game.FGUI_Release] = true
    },

    [427] = {
        [const_game.Icon] = 427,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] =TR("野牛"),
		[const_game.ScreenType] = const_game.H_Screen_Type,
        [const_game.Reconnect_Msg] = 'PKG_Slots_Client_DragonGiftEnterResumed',
        ["caijin_type"] = 1,
        ["anims"] = {
            10204
        },
        [const_game.FGUI_Support] = true,
        [const_game.FGUI_Release] = true
    },

    [428] = {
        [const_game.Icon] = 428,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] = TR("埃及甲虫"),
		[const_game.ScreenType] = const_game.H_Screen_Type,
        [const_game.Reconnect_Msg] = 'PKG_Slots_Client_EyesOfWealthEnterResumed',
        ["caijin_type"] = 5,
        ["anims"] = {
            10205
        },
        [const_game.Cocos_Support] = false,
        [const_game.FGUI_Support] = true,
        [const_game.FGUI_Release] = true
    },

    [429] = {
        [const_game.Icon] = 429,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] = TR("大袋鼠"),
		[const_game.ScreenType] = const_game.H_Screen_Type,
        [const_game.Reconnect_Msg] = 'PKG_Slots_Client_HappyLanternEnterResumed',
        ["caijin_type"] = 5,
        ["anims"] = {
            10205
        },
        [const_game.Cocos_Support] = false,
        [const_game.FGUI_Support] = true,
        [const_game.FGUI_Release] = true
    },

    [430] = {
        [const_game.Icon] = 430,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] = TR("丛林之王泰山"),
		[const_game.ScreenType] = const_game.H_Screen_Type,
        [const_game.Reconnect_Msg] = 'PKG_Slots_Client_HappyLanternEnterResumed',
        ["caijin_type"] = 5,
        ["anims"] = {
            10205
        },
        [const_game.Cocos_Support] = false,
        [const_game.FGUI_Support] = true,
        [const_game.FGUI_Release] = true
    },

    [431] = {
        [const_game.Icon] = 431,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] =TR("女海盗"),
		[const_game.ScreenType] = const_game.H_Screen_Type,
        [const_game.Reconnect_Msg] = 'PKG_Slots_Client_NvXiaEnterResumed',
        ["caijin_type"] = 1,
        ["anims"] = {
            10205
        },
        [const_game.Cocos_Support] = false,
        [const_game.FGUI_Support] = true,
        [const_game.FGUI_Release] = true,
    },

    [432] = {
        [const_game.Icon] = 432,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] =TR("狂野之心泰山"),
		[const_game.ScreenType] = const_game.H_Screen_Type,
        [const_game.Reconnect_Msg] = 'PKG_Slots_Client_NvXiaEnterResumed',
        ["caijin_type"] = 1,
        ["anims"] = {
            10205
        },
        [const_game.Cocos_Support] = false,
        [const_game.FGUI_Support] = true,
        [const_game.FGUI_Release] = true,
    },

    [433] = {
        [const_game.Icon] = 433,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] = TR("庞贝古城"),
        [const_game.ScreenType] = const_game.H_Screen_Type,
        [const_game.Reconnect_Msg] = 'PKG_Slots_Client_PompeEnterResumed',
        ["caijin_type"] = 1,
        ["anims"] = {
            10204
        },
        [const_game.FGUI_Support] = true,
        [const_game.FGUI_Release] = true
    },
    [435] = {
        [const_game.Icon] = 435,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] =TR("斗牛"),
		[const_game.ScreenType] = const_game.H_Screen_Type,
        [const_game.Reconnect_Msg] = 'PKG_Slots_Client_EyesOfWealthEnterResumed',
        ["caijin_type"] = 1,
        ["anims"] = {
            10202
        },
        [const_game.Cocos_Support] = true,
        [const_game.FGUI_Support] = true,
        [const_game.FGUI_Release] = true,
    },
    [437] = {
        [const_game.Icon] = 437,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] =TR("埃及法老"),
		[const_game.ScreenType] = const_game.H_Screen_Type,
        [const_game.Reconnect_Msg] = 'PKG_Slots_Client_TheKingEnterResumed',
        ["caijin_type"] = 1,
        ["anims"] = {
            10202
        },
        [const_game.FGUI_Support] = true,
        [const_game.FGUI_Release] = true
    },

    [438] = {
        [const_game.Icon] = 438,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] =TR("拉斯维加斯公主"),
		[const_game.ScreenType] = const_game.H_Screen_Type,
        [const_game.Reconnect_Msg] = 'PKG_Slots_Client_NvXiaEnterResumed',
        ["caijin_type"] = 1,
        ["anims"] = {
            10205
        },
        [const_game.Cocos_Support] = false,
        [const_game.FGUI_Support] = true,
        [const_game.FGUI_Release] = true,
    },

    [439] = {
        [const_game.Icon] = 439,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] =TR("拉斯维加斯帅哥"),
		[const_game.ScreenType] = const_game.H_Screen_Type,
        [const_game.Reconnect_Msg] = 'PKG_Slots_Client_NvXiaEnterResumed',
        ["caijin_type"] = 1,
        ["anims"] = {
            10205
        },
        [const_game.Cocos_Support] = false,
        [const_game.FGUI_Support] = true,
        [const_game.FGUI_Release] = true,
    },

    [440] = {
        [const_game.Icon] = 440,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] = TR("铿锵玫瑰"),
		[const_game.ScreenType] = const_game.H_Screen_Type,
        [const_game.Reconnect_Msg] = 'PKG_Slots_Client_HappyLanternEnterResumed',
        ["caijin_type"] = 5,
        ["anims"] = {
            10205
        },
        [const_game.Cocos_Support] = false,
        [const_game.FGUI_Support] = true,
        [const_game.FGUI_Release] = true
    },
    [441] = {
        [const_game.Icon] = 441,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] = TR("西部警长"),
		[const_game.ScreenType] = const_game.H_Screen_Type,
        [const_game.Reconnect_Msg] = 'PKG_Slots_Client_WesternCashEnterResumed',
        ["caijin_type"] = 5,
        ["anims"] = {
            10205
        },
        [const_game.Cocos_Support] = false,
        [const_game.FGUI_Support] = true,
        [const_game.FGUI_Release] = true
    },

    [444] = {
        [const_game.Icon] = 444,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] = TR("海盗秘宝"),
		[const_game.ScreenType] = const_game.H_Screen_Type,
        [const_game.Reconnect_Msg] = 'PKG_Slots_Client_EyesOfWealthEnterResumed',
        ["caijin_type"] = 5,
        ["anims"] = {
            10205
        },
        [const_game.Cocos_Support] = false,
        [const_game.FGUI_Support] = true,
        [const_game.FGUI_Release] = true
    },

    [445] = {
        [const_game.Icon] = 445,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] = TR("埃及莲花"),
		[const_game.ScreenType] = const_game.H_Screen_Type,
        [const_game.Reconnect_Msg] = 'PKG_Slots_Client_HappyLanternEnterResumed',
        ["caijin_type"] = 5,
        ["anims"] = {
            10205
        },
        [const_game.Cocos_Support] = false,
        [const_game.FGUI_Support] = true,
        [const_game.FGUI_Release] = true
    },

    [446] = {
        [const_game.Icon] = 446,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] = TR("狮子王"),
		[const_game.ScreenType] = const_game.H_Screen_Type,
        [const_game.Reconnect_Msg] = 'PKG_Slots_Client_EyesOfWealthEnterResumed',
        ["caijin_type"] = 5,
        ["anims"] = {
            10205
        },
        [const_game.Cocos_Support] = false,
        [const_game.FGUI_Support] = true,
        [const_game.FGUI_Release] = true
    },

    [447] = {
        [const_game.Icon] = 447,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] = TR("金刚"),
		[const_game.ScreenType] = const_game.H_Screen_Type,
        [const_game.Reconnect_Msg] = 'PKG_Slots_Client_EyesOfWealthEnterResumed',
        ["caijin_type"] = 5,
        ["anims"] = {
            10205
        },
        [const_game.Cocos_Support] = false,
        [const_game.FGUI_Support] = true,
        [const_game.FGUI_Release] = true
    },

    [452] = {
        [const_game.Icon] = 452,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] =TR("万圣礼物"),
		[const_game.ScreenType] = const_game.H_Screen_Type,
        [const_game.Reconnect_Msg] = 'PKG_Slots_Client_DragonGiftEnterResumed',
        ["caijin_type"] = 1,
        ["anims"] = {
            10204
        },
        [const_game.Cocos_Support] = false,
        [const_game.FGUI_Support] = true,
        [const_game.FGUI_Release] = true,
    },
    [454] = {
        [const_game.Icon] = 454,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] =TR("埃及奇观"),
		[const_game.ScreenType] = const_game.H_Screen_Type,
        [const_game.Reconnect_Msg] = 'PKG_Slots_Client_EyesOfWealthEnterResumed',
        ["caijin_type"] = 1,
        ["anims"] = {
            10202
        },
        [const_game.Cocos_Support] = false,
        [const_game.FGUI_Support] = true,
        [const_game.FGUI_Release] = true,
    },

    [457] = {
        [const_game.Icon] = 457,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] =TR("赏金猎人"),
		[const_game.ScreenType] = const_game.H_Screen_Type,
        [const_game.Reconnect_Msg] = 'PKG_Slots_Client_ImmortalMonkeyEnterResumed',
        ["caijin_type"] = 1,
        ["anims"] = {
            10204
        },
        [const_game.FGUI_Support] = true,
        [const_game.FGUI_Release] = true
    },

    [459] = {
        [const_game.Icon] = 459,
        [const_game.Game_type] = "casino",
        [const_game.Game_Name] = TR("发财虎"),
        [const_game.ScreenType] = const_game.V_Screen_Type,
        [const_game.Reconnect_Msg] = 'PKG_Slots_Client_FortuneTigerEnterResumed',
        ["caijin_type"] = 2,
        ["anims"] = {
            10205
        },
        [const_game.FGUI_Support] = true,
        [const_game.FGUI_Release] = true
    },

    [460] = {
        [const_game.Icon] = 460,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] =TR("发财牛"),
		[const_game.ScreenType] = const_game.V_Screen_Type,
        [const_game.Reconnect_Msg] = 'PKG_Slots_Client_LuckyBullEnterResumed',
        ["caijin_type"] = 2,
        ["anims"] = {
            10205
        },
        [const_game.FGUI_Support] = true,
        [const_game.FGUI_Release] = true
    },

    [461] = {
        [const_game.Icon] = 461,
        [const_game.Game_type] = "casino",
        [const_game.Game_Name] = TR("发财兔"),
        [const_game.ScreenType] = const_game.V_Screen_Type,
        [const_game.Reconnect_Msg] = 'PKG_Slots_Client_FortuneRabbitEnterResumed',
        ["caijin_type"] = 2,
        ["anims"] = {
            10205
        },
        [const_game.FGUI_Support] = true,
        [const_game.FGUI_Release] = true
    },
    [462] = {
        [const_game.Icon] = 462,
        [const_game.Game_type] = "casino",
        [const_game.Game_Name] = TR("发财鼠"),
        [const_game.ScreenType] = const_game.V_Screen_Type,
        [const_game.Reconnect_Msg] = 'PKG_Slots_Client_LuckyBullEnterResumed',
        ["caijin_type"] = 2,
        ["anims"] = {
            10205
        },
        [const_game.FGUI_Support] = true,
        [const_game.FGUI_Release] = true
    },
    [463] = {
        [const_game.Icon] = 463,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] =TR("龙虎运"),
		[const_game.ScreenType] = const_game.V_Screen_Type,
        [const_game.Reconnect_Msg] = 'PKG_Slots_Client_DragonTigerLuckEnterResumed',
        ["caijin_type"] = 2,
        ["anims"] = {
            10206
        },
        [const_game.FGUI_Support] = true,
        [const_game.FGUI_Release] = true
    },
    [464] = {
        [const_game.Icon] = 464,
        [const_game.Game_type] = "casino",
        [const_game.Game_Name] = TR("金象神"),
        [const_game.ScreenType] = const_game.V_Screen_Type,
        [const_game.Reconnect_Msg] = 'PKG_Slots_Client_GoldenElephantEnterResumed',
        ["caijin_type"] = 2,
        ["anims"] = {
            10205
        },
        [const_game.FGUI_Support] = true,
        [const_game.FGUI_Release] = true
    },
    [465] = {
        [const_game.Icon] = 465,
        [const_game.Game_type] = "casino",
        [const_game.Game_Name] = TR("五龙争霸Ⅱ"),
        [const_game.ScreenType] = const_game.H_Screen_Type,
        [const_game.Reconnect_Msg] = 'PKG_Slots_Client_fafafa_WealthGoldEnterResumed',
        ["caijin_type"] = 2,
        ["anims"] = {
            10205
        },
        [const_game.FGUI_Support] = true,
        [const_game.FGUI_Release] = true
    },
    [466] = {
        [const_game.Icon] = 466,
        [const_game.Game_type] = "casino",
        [const_game.Game_Name] = TR("熊猫宝藏Ⅱ"),
        [const_game.ScreenType] = const_game.H_Screen_Type,
        [const_game.Reconnect_Msg] = 'PKG_Slots_Client_PandaTreasureEnterResumed',
        ["caijin_type"] = 2,
        ["anims"] = {
            10205
        },
        [const_game.FGUI_Support] = true,
        [const_game.FGUI_Release] = true
    },
    [468] = {
        [const_game.Icon] = 468,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] =TR("幸运小猪 2"),
		[const_game.ScreenType] = const_game.V_Screen_Type,
        [const_game.Reconnect_Msg] = 'PKG_Slots_Client_LuckyPigEnterResumed',
        ["caijin_type"] = 1,
        ["anims"] = {
            10204
        },
        [const_game.FGUI_Support] = true,
        [const_game.FGUI_Release] = true
    },
    [469] = {
        [const_game.Icon] = 469,
        [const_game.Game_type] = "casino",
        [const_game.Game_Name] = TR("猴王纳福"),
        [const_game.ScreenType] = const_game.V_Screen_Type,
        [const_game.Reconnect_Msg] = 'PKG_Slots_Client_MightyMonkey_EnterResumed',
        ["caijin_type"] = 2,
        ["anims"] = {
            10205
        },
        [const_game.FGUI_Support] = true,
        [const_game.FGUI_Release] = true
    },
    [475] = {
        [const_game.Icon] = 475,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] = TR("海盗财宝"),
        [const_game.ScreenType] = const_game.H_Screen_Type,
        [const_game.Reconnect_Msg] = 'PKG_Slots_Client_EyesOfWealthEnterResumed',
        ["caijin_type"] = 1,
        [const_game.FGUI_Support] = true,
        [const_game.FGUI_Release] = true
    },
    [476] = {
        [const_game.Icon] = 476,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] =TR("烈焰凤凰"),
		[const_game.ScreenType] = const_game.H_Screen_Type,
        [const_game.Reconnect_Msg] = 'PKG_Slots_Client_DragonGiftEnterResumed',
        ["caijin_type"] = 1,
        ["anims"] = {
            10204
        },
        [const_game.FGUI_Support] = true,
        [const_game.FGUI_Release] = true
    },
    [477] = {
        [const_game.Icon] = 477,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] =TR("波塞冬传奇"),
		[const_game.ScreenType] = const_game.H_Screen_Type,
        [const_game.Reconnect_Msg] = 'PKG_Slots_Client_DragonGiftEnterResumed',
        ["caijin_type"] = 1,
        ["anims"] = {
            10204
        },
        [const_game.FGUI_Support] = true,
        [const_game.FGUI_Release] = true
    },
    [479] = {
        [const_game.Icon] = 479,
        [const_game.Game_type] = "casino",
        [const_game.Game_Name] = TR("熊猫宝藏Ⅱ"),
        [const_game.ScreenType] = const_game.H_Screen_Type,
        [const_game.Reconnect_Msg] = 'PKG_Slots_Client_PandaTreasureEnterResumed',
        ["caijin_type"] = 2,
        ["anims"] = {
            10205
        },
        [const_game.FGUI_Support] = true,
        [const_game.FGUI_Release] = true
    },
    [470] = {
        [const_game.Icon] = 470,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] = TR("终极火链-2"),
        [const_game.ScreenType] = const_game.V_Screen_Type,
        [const_game.Reconnect_Msg] = 'PKG_Slots_Client_FireLinkEnterResumed',
        ["caijin_type"] = 1,
        ["anims"] = {
            10204
        },
        [const_game.FGUI_Support] = true,
        [const_game.FGUI_Release] = true
    },
    [481] = {
        [const_game.Icon] = 481,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] = TR("481-Gates of Olympus 1000"),
        [const_game.ScreenType] = const_game.H_Screen_Type,
        [const_game.Reconnect_Msg] = 'PKG_Slots_Client_GatesOfOlympusEnterResumed',
        ["caijin_type"] = 2,
        [const_game.FGUI_Support] = true,
        [const_game.FGUI_Release] = true
    },
    [482] = {
        [const_game.Icon] = 482,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] = TR("482-Gates of Olympus"),
        [const_game.ScreenType] = const_game.H_Screen_Type,
        [const_game.Reconnect_Msg] = 'PKG_Slots_Client_GatesOfOlympusEnterResumed',
        ["caijin_type"] = 2,
        [const_game.FGUI_Support] = true,
        [const_game.FGUI_Release] = true
    },
    [483] = {
        [const_game.Icon] = 483,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] = TR("麻将胡了"),
        [const_game.ScreenType] = const_game.V_Screen_Type,
        [const_game.Reconnect_Msg] = 'PKG_Slots_Client_MahjongWaysEnterResumed',
        ["caijin_type"] = 1,
        ["anims"] = {
            10204
        },
        [const_game.FGUI_Support] = true,
        [const_game.FGUI_Release] = true
    },
    [484] = {
        [const_game.Icon] = 484,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] = TR("麻将胡了2"),
        [const_game.ScreenType] = const_game.V_Screen_Type,
        [const_game.Reconnect_Msg] = 'PKG_Slots_Client_MahjongWaysEnterResumed',
        ["caijin_type"] = 1,
        ["anims"] = {
            10204
        },
        [const_game.FGUI_Support] = true,
        [const_game.FGUI_Release] = true
    },
    [485] = {
        [const_game.Icon] = 311,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] = TR("终极火链"),
        [const_game.ScreenType] = const_game.V_Screen_Type,
        [const_game.Reconnect_Msg] = 'PKG_Slots_Client_FireLinkEnterResumed',
        ["caijin_type"] = 1,
        ["anims"] = {
            10204
        },
        [const_game.FGUI_Support] = true,
        [const_game.FGUI_Release] = true
    },
    [499] = {
        [const_game.Icon] = 499,
        [const_game.Game_type] = 'casino',
        [const_game.Game_Name] = TR("燃烧吧辣椒"),
        [const_game.ScreenType] = const_game.H_Screen_Type,
        [const_game.Reconnect_Msg] = 'PKG_Slots_Client_PandaTreasureEnterResumed',
        ["caijin_type"] = 2,
        ["anims"] = {
            10205
        },
        [const_game.FGUI_Support] = true,
        [const_game.FGUI_Release] = true
    },
--     ---------------------------------------------------- 海王新加游戏 -------------------------------------------
    [140] = {
        [const_game.Icon] = 140,
        [const_game.Game_type] = 'haiwang',
        [const_game.Game_Name] = TR("紫晶人鱼"),
        ["anims"] = {
            11140,
            10140
        },
    },
    [141] = {
        [const_game.Icon] = 141,
        [const_game.Game_type] = 'haiwang',
        [const_game.Game_Name] = TR("冥焰赤龙"),
        ["anims"] = {
            11141,
            10141
        }
    },
    [142] = {
        [const_game.Icon] = 142,
        [const_game.Game_type] = 'haiwang',
        [const_game.Game_Name] = TR("蛮荒凶兽"),
        ["anims"] = {
            11142,
            10142
        }
    },
    [143] = {
        [const_game.Icon] = 143,
        [const_game.Game_type] = 'haiwang',
        [const_game.Game_Name] = TR("金色龙虾将军"),
        ["anims"] = {
            11143,
            10143
        }
    },
    [144] = {
        [const_game.Icon] = 144,
        [const_game.Game_type] = 'haiwang',
        [const_game.Game_Name] = TR("招财宝蟾"),
        ["anims"] = {
            11144,
            10144
        }
    },
    [145] = {
        [const_game.Icon] = 145,
        [const_game.Game_type] = 'haiwang',
        [const_game.Game_Name] = TR("深海秘籍"),
        ["anims"] = {
            11145,
            10145
        }
    },
    [146] = {
        [const_game.Icon] = 146,
        [const_game.Game_type] = 'haiwang',
        [const_game.Game_Name] = TR("远古秘境"),
        ["anims"] = {
            11146,
            10146
        }
    }
}

const_game.PreLoadRes = {}
