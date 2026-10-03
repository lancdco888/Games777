/** Fish spawned in 大王乌贼. Sizes are the original frame scaled into the 1280x720 table. */
export interface FishKind {
    typeId: number;
    name: string;
    group: 'general' | 'golden' | 'special';
    art: string;
    frames: number;
    coinMin: number;
    coinMax: number;
    coinStep: number;
    coinList: number[];
    width: number;
    height: number;
    speed: number;
    boss: boolean;
    upright: boolean;
}

export const FISH_KINDS: FishKind[] = [
    { typeId: 0, name: '迦魶鱼', group: 'general', art: 'fish101/fish/jianayu', frames: 4, coinMin: 2, coinMax: 2, coinStep: 1, coinList: [], width: 70, height: 70, speed: 146, boss: false, upright: false },
    { typeId: 1, name: '小丑鱼', group: 'general', art: 'fish101/fish/xiaochouyu', frames: 4, coinMin: 3, coinMax: 3, coinStep: 1, coinList: [], width: 62, height: 60, speed: 144, boss: false, upright: false },
    { typeId: 2, name: '碟鱼', group: 'general', art: 'fish101/fish/dieyu', frames: 4, coinMin: 4, coinMax: 4, coinStep: 1, coinList: [], width: 95, height: 60, speed: 142, boss: false, upright: false },
    { typeId: 3, name: '河豚', group: 'general', art: 'fish101/fish/xiaohetun', frames: 4, coinMin: 5, coinMax: 5, coinStep: 1, coinList: [], width: 92, height: 86, speed: 140, boss: false, upright: false },
    { typeId: 4, name: '狮子鱼', group: 'general', art: 'fish101/fish/shiziyu', frames: 4, coinMin: 6, coinMax: 6, coinStep: 1, coinList: [], width: 120, height: 126, speed: 138, boss: false, upright: false },
    { typeId: 5, name: '比目鱼', group: 'general', art: 'fish101/fish/bimuyu', frames: 4, coinMin: 7, coinMax: 7, coinStep: 1, coinList: [], width: 150, height: 140, speed: 136, boss: false, upright: false },
    { typeId: 6, name: '龙虾', group: 'general', art: 'fish101/fish/longxia', frames: 4, coinMin: 8, coinMax: 8, coinStep: 1, coinList: [], width: 150, height: 150, speed: 134, boss: false, upright: false },
    { typeId: 7, name: '旗鱼', group: 'general', art: 'fish101/fish/qiyu', frames: 4, coinMin: 9, coinMax: 9, coinStep: 1, coinList: [], width: 220, height: 95, speed: 132, boss: false, upright: false },
    { typeId: 8, name: '小水母', group: 'general', art: 'fish101/fish/xiaoshuimu', frames: 4, coinMin: 10, coinMax: 10, coinStep: 1, coinList: [], width: 170, height: 130, speed: 130, boss: false, upright: false },
    { typeId: 9, name: '章鱼', group: 'general', art: 'fish101/fish/zhangyu', frames: 4, coinMin: 10, coinMax: 10, coinStep: 1, coinList: [], width: 142, height: 140, speed: 130, boss: false, upright: false },
    { typeId: 10, name: '灯笼鱼', group: 'general', art: 'fish101/fish/lantern', frames: 4, coinMin: 12, coinMax: 12, coinStep: 1, coinList: [], width: 184, height: 116, speed: 126, boss: false, upright: false },
    { typeId: 11, name: '乌龟', group: 'general', art: 'fish101/fish/seaturtle', frames: 4, coinMin: 15, coinMax: 15, coinStep: 1, coinList: [], width: 208, height: 232, speed: 120, boss: false, upright: false },
    { typeId: 12, name: '锯齿鲨', group: 'general', art: 'fish101/fish/juchiyu', frames: 4, coinMin: 18, coinMax: 18, coinStep: 1, coinList: [], width: 219, height: 84, speed: 114, boss: false, upright: false },
    { typeId: 13, name: '蝠鲼', group: 'general', art: 'fish101/fish/fuyu', frames: 4, coinMin: 20, coinMax: 20, coinStep: 1, coinList: [], width: 220, height: 228, speed: 110, boss: false, upright: false },
    { typeId: 14, name: '巨大小丑鱼', group: 'general', art: 'fish101/fish/judaxiaochouyu', frames: 4, coinMin: 10, coinMax: 25, coinStep: 5, coinList: [], width: 219, height: 219, speed: 130, boss: false, upright: false },
    { typeId: 15, name: '巨大鲽鱼', group: 'general', art: 'fish101/fish/judadieyu', frames: 4, coinMin: 15, coinMax: 30, coinStep: 5, coinList: [], width: 220, height: 219, speed: 120, boss: false, upright: false },
    { typeId: 16, name: '鲨鱼', group: 'general', art: 'fish101/fish/shark', frames: 4, coinMin: 25, coinMax: 40, coinStep: 5, coinList: [], width: 220, height: 141, speed: 100, boss: false, upright: false },
    { typeId: 17, name: '鲸鱼', group: 'general', art: 'fish101/fish/whale', frames: 4, coinMin: 30, coinMax: 60, coinStep: 10, coinList: [], width: 220, height: 188, speed: 90, boss: false, upright: false },
    { typeId: 18, name: '巨大河豚', group: 'general', art: 'fish101/fish/judahetun', frames: 4, coinMin: 10, coinMax: 25, coinStep: 5, coinList: [], width: 220, height: 220, speed: 130, boss: false, upright: false },
    { typeId: 100, name: '旋风迦魶鱼', group: 'general', art: 'fish101/fish/jianayu_xuanfeng', frames: 4, coinMin: 50, coinMax: 50, coinStep: 1, coinList: [], width: 200, height: 256, speed: 80, boss: false, upright: false },
    { typeId: 101, name: '旋风小丑鱼', group: 'general', art: 'fish101/fish/xiaochouyu_xuanfeng', frames: 4, coinMin: 50, coinMax: 50, coinStep: 1, coinList: [], width: 192, height: 140, speed: 80, boss: false, upright: false },
    { typeId: 102, name: '旋风碟鱼', group: 'general', art: 'fish101/fish/dieyu_xuanfeng', frames: 4, coinMin: 50, coinMax: 50, coinStep: 1, coinList: [], width: 220, height: 117, speed: 80, boss: false, upright: false },
    { typeId: 104, name: '旋风狮子鱼', group: 'general', art: 'fish101/fish/shiziyu_xuanfeng', frames: 4, coinMin: 50, coinMax: 50, coinStep: 1, coinList: [], width: 220, height: 287, speed: 80, boss: false, upright: false },
    { typeId: 200, name: '闪电鲨', group: 'special', art: 'fish101/fish/shandiansha', frames: 2, coinMin: 100, coinMax: 100, coinStep: 1, coinList: [], width: 220, height: 147, speed: 80, boss: false, upright: false },
    { typeId: 203, name: '连环炸弹蟹', group: 'special', art: 'fish101/fish/zhadanxie', frames: 2, coinMin: 200, coinMax: 900, coinStep: 10, coinList: [], width: 220, height: 231, speed: 80, boss: false, upright: false },
    { typeId: 205, name: '神龙转盘', group: 'special', art: 'fish101/fish/shenlongzhuanpan', frames: 2, coinMin: 100, coinMax: 10000, coinStep: 1, coinList: [100, 150, 200, 250, 300, 350, 400, 450, 500, 1000, 10000], width: 158, height: 172, speed: 80, boss: false, upright: true },
    { typeId: 302, name: '霸王鲸', group: 'golden', art: 'fish101/fish/bawangjin', frames: 2, coinMin: 200, coinMax: 500, coinStep: 10, coinList: [], width: 220, height: 132, speed: 80, boss: false, upright: false },
    { typeId: 305, name: '大王乌贼', group: 'golden', art: 'fish101/fish/dawangwuzei', frames: 2, coinMin: 250, coinMax: 550, coinStep: 10, coinList: [], width: 300, height: 200, speed: 55, boss: true, upright: false },
    { typeId: 306, name: '电光水母', group: 'golden', art: 'fish101/fish/dianguangshuimu', frames: 2, coinMin: 200, coinMax: 400, coinStep: 10, coinList: [], width: 300, height: 185, speed: 55, boss: true, upright: false },
    { typeId: 323, name: '黄金鲨鱼', group: 'golden', art: 'fish101/fish/huangjinshayu', frames: 2, coinMin: 140, coinMax: 140, coinStep: 1, coinList: [], width: 220, height: 129, speed: 80, boss: false, upright: false },
    { typeId: 324, name: '黄金鲸', group: 'golden', art: 'fish101/fish/huangjinsharenjing', frames: 2, coinMin: 160, coinMax: 160, coinStep: 1, coinList: [], width: 220, height: 164, speed: 80, boss: false, upright: false },
    { typeId: 325, name: '聚餐元宵', group: 'golden', art: 'fish101/fish/lanternfestival', frames: 2, coinMin: 100, coinMax: 300, coinStep: 10, coinList: [], width: 220, height: 228, speed: 80, boss: false, upright: false },
];
