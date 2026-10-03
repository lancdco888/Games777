import { gOM, type ObjMgr, type PkgInstance, type PkgMeta } from '../ObjMgr';

function base(typeId: number, typeName: string, fields: Record<string, unknown> = {}): PkgInstance {
  return { _typeId: typeId, _typeName: typeName, ...fields };
}

const Move: PkgMeta = {
  typeId: 2001,
  typeName: 'PKG_Client_Lobby_Move',
  Create: () => base(2001, 'PKG_Client_Lobby_Move'),
  Write() {},
  Read() { return 0; },
};

const MoveResult: PkgMeta = {
  typeId: 1201,
  typeName: 'PKG_Lobby_Client_Move_Result',
  Create: () => base(1201, 'PKG_Lobby_Client_Move_Result'),
  Write() {},
  Read() { return 0; },
};

export const PKG_Client_Lobby_Enter: PkgMeta = {
  typeId: 2002,
  typeName: 'PKG_Client_Lobby_Enter',
  Create: () => {
    const o = Move.Create();
    o._typeId = 2002;
    o._typeName = 'PKG_Client_Lobby_Enter';
    o.token = '';
    return o;
  },
  Write(self, om) {
    Move.Write(self, om);
    om.d.Wstr(String(self.token || ''));
  },
  Read(self, om) {
    const r0 = Move.Read(self, om);
    if (r0) return r0;
    const [r, v] = om.d.Rstr();
    if (r) return r;
    self.token = v;
    return 0;
  },
};

export const PKG_Client_Lobby_EnterGame: PkgMeta = {
  typeId: 2003,
  typeName: 'PKG_Client_Lobby_EnterGame',
  Create: () => {
    const o = Move.Create();
    o._typeId = 2003;
    o._typeName = 'PKG_Client_Lobby_EnterGame';
    o.gameId = 0;
    return o;
  },
  Write(self, om) {
    Move.Write(self, om);
    om.d.Wvi32(Number(self.gameId || 0));
  },
  Read(self, om) {
    const r0 = Move.Read(self, om);
    if (r0) return r0;
    const [r, v] = om.d.Rvi32();
    if (r) return r;
    self.gameId = v;
    return 0;
  },
};

export const PKG_Lobby_Client_EnterGameSlots_Success: PkgMeta = {
  typeId: 1215,
  typeName: 'PKG_Lobby_Client_EnterGameSlots_Success',
  Create: () => {
    const o = MoveResult.Create();
    o._typeId = 1215;
    o._typeName = 'PKG_Lobby_Client_EnterGameSlots_Success';
    o.GameId = 0;
    o.serviceId = 0;
    return o;
  },
  Write(self, om) {
    MoveResult.Write(self, om);
    om.d.Wvi32(Number(self.GameId || 0));
    om.d.Wvi32(Number(self.serviceId || 0));
  },
  Read(self, om) {
    const r0 = MoveResult.Read(self, om);
    if (r0) return r0;
    let r: number; let v: number;
    [r, v] = om.d.Rvi32(); if (r) return r; self.GameId = v;
    [r, v] = om.d.Rvi32(); if (r) return r; self.serviceId = v;
    return 0;
  },
};

export const PKG_Lobby_Client_MoneyChanged: PkgMeta = {
  typeId: 1236,
  typeName: 'PKG_Lobby_Client_MoneyChanged',
  Create: () =>
    base(1236, 'PKG_Lobby_Client_MoneyChanged', {
      money: 0,
      money_safe: 0,
      money_gift: 0,
      money_gift_safe: 0,
    }),
  Write(self, om) {
    om.d.Wd(Number(self.money || 0));
    om.d.Wd(Number(self.money_safe || 0));
    om.d.Wd(Number(self.money_gift || 0));
    om.d.Wd(Number(self.money_gift_safe || 0));
  },
  Read(self, om) {
    let r: number; let v: number;
    [r, v] = om.d.Rd(); if (r) return r; self.money = v;
    [r, v] = om.d.Rd(); if (r) return r; self.money_safe = v;
    [r, v] = om.d.Rd(); if (r) return r; self.money_gift = v;
    [r, v] = om.d.Rd(); if (r) return r; self.money_gift_safe = v;
    return 0;
  },
};

export const PKG_Client_Lobby_Ping: PkgMeta = {
  typeId: 2062,
  typeName: 'PKG_Client_Lobby_Ping',
  Create: () => base(2062, 'PKG_Client_Lobby_Ping', { ticks: 0 }),
  Write(self, om) { om.d.Wvi32(Number(self.ticks || 0)); },
  Read(self, om) {
    const [r, v] = om.d.Rvi32();
    if (r) return r;
    self.ticks = v;
    return 0;
  },
};

export const PKG_Lobby_Client_Pong: PkgMeta = {
  typeId: 1283,
  typeName: 'PKG_Lobby_Client_Pong',
  Create: () => base(1283, 'PKG_Lobby_Client_Pong', { ticks: 0 }),
  Write(self, om) { om.d.Wvi32(Number(self.ticks || 0)); },
  Read(self, om) {
    const [r, v] = om.d.Rvi32();
    if (r) return r;
    self.ticks = v;
    return 0;
  },
};

/**
 * Enter_Success — nested lists simplified; gameIds encoded as Int32 list.
 * Full Shared graphs (selfAccount / GameEntryConditions) filled in mock / later codegen.
 */
export const PKG_Lobby_Client_Enter_Success: PkgMeta = {
  typeId: 1202,
  typeName: 'PKG_Lobby_Client_Enter_Success',
  Create: () => {
    const o = MoveResult.Create();
    o._typeId = 1202;
    o._typeName = 'PKG_Lobby_Client_Enter_Success';
    Object.assign(o, {
      gameIds: [] as number[],
      self: null,
      vips: [],
      website: '',
      gameEntryConditionsList: [] as unknown[],
      is_open_promotion: 0,
      money_exchange_coin: 1000,
      contact_service: '',
      upload_image_path: '',
      botton_configs: [],
      versioninfo: '',
      is_open_realname_mode: 0,
      gameTypeSort: '123',
    });
    return o;
  },
  Write(self, om) {
    MoveResult.Write(self, om);
    const d = om.d;
    const ids = (self.gameIds as number[]) || [];
    d.Wvu32(ids.length);
    for (const id of ids) d.Wvi32(id);
    om.Write((self.self as PkgInstance) || null);
    const vips = (self.vips as unknown[]) || [];
    d.Wvu32(vips.length);
    for (const v of vips) om.Write(v as PkgInstance);
    d.Wstr(String(self.website || ''));
    const levels = (self.gameEntryConditionsList as unknown[]) || [];
    d.Wvu32(levels.length);
    for (const lv of levels) om.Write(lv as PkgInstance);
    d.Wvi32(Number(self.is_open_promotion || 0));
    d.Wvi32(Number(self.money_exchange_coin || 0));
    d.Wstr(String(self.contact_service || ''));
    d.Wstr(String(self.upload_image_path || ''));
    const buttons = (self.botton_configs as unknown[]) || [];
    d.Wvu32(buttons.length);
    for (const b of buttons) om.Write(b as PkgInstance);
    d.Wstr(String(self.versioninfo || ''));
    d.Wvi32(Number(self.is_open_realname_mode || 0));
    d.Wstr(String(self.gameTypeSort || ''));
  },
  Read(self, om) {
    const r0 = MoveResult.Read(self, om);
    if (r0) return r0;
    const d = om.d;
    let r: number; let v: number | string; let o: PkgInstance | null; let len = 0;
    [r, len] = d.Rvu32(); if (r) return r;
    const ids: number[] = [];
    for (let i = 0; i < len; i++) {
      [r, v] = d.Rvi32(); if (r) return r; ids.push(v as number);
    }
    self.gameIds = ids;
    [r, o] = om.Read(); if (r) return r; self.self = o;
    [r, len] = d.Rvu32(); if (r) return r;
    const vips: PkgInstance[] = [];
    for (let i = 0; i < len; i++) {
      [r, o] = om.Read(); if (r) return r; if (o) vips.push(o);
    }
    self.vips = vips;
    [r, v] = d.Rstr(); if (r) return r; self.website = v;
    [r, len] = d.Rvu32(); if (r) return r;
    const levels: PkgInstance[] = [];
    for (let i = 0; i < len; i++) {
      [r, o] = om.Read(); if (r) return r; if (o) levels.push(o);
    }
    self.gameEntryConditionsList = levels;
    [r, v] = d.Rvi32(); if (r) return r; self.is_open_promotion = v;
    [r, v] = d.Rvi32(); if (r) return r; self.money_exchange_coin = v;
    [r, v] = d.Rstr(); if (r) return r; self.contact_service = v;
    [r, v] = d.Rstr(); if (r) return r; self.upload_image_path = v;
    [r, len] = d.Rvu32(); if (r) return r;
    const buttons: PkgInstance[] = [];
    for (let i = 0; i < len; i++) {
      [r, o] = om.Read(); if (r) return r; if (o) buttons.push(o);
    }
    self.botton_configs = buttons;
    [r, v] = d.Rstr(); if (r) return r; self.versioninfo = v;
    [r, v] = d.Rvi32(); if (r) return r; self.is_open_realname_mode = v;
    [r, v] = d.Rstr(); if (r) return r; self.gameTypeSort = v;
    return 0;
  },
};

/** Slots enter (service) — minimal stub matching CanisoGameEnter */
export const PKG_Client_Slots_Enter: PkgMeta = {
  typeId: 3001,
  typeName: 'PKG_Client_Slots_Enter',
  Create: () => base(3001, 'PKG_Client_Slots_Enter', { gameId: 0 }),
  Write(self, om) { om.d.Wvi32(Number(self.gameId || 0)); },
  Read(self, om) {
    const [r, v] = om.d.Rvi32();
    if (r) return r;
    self.gameId = v;
    return 0;
  },
};

export const PKG_Slots_Client_Enter_Success: PkgMeta = {
  typeId: 3101,
  typeName: 'PKG_Slots_Client_Enter_Success',
  Create: () =>
    base(3101, 'PKG_Slots_Client_Enter_Success', {
      gameId: 0,
      money: 0,
      bet: 0,
    }),
  Write(self, om) {
    om.d.Wvi32(Number(self.gameId || 0));
    om.d.Wd(Number(self.money || 0));
    om.d.Wd(Number(self.bet || 0));
  },
  Read(self, om) {
    let r: number; let v: number;
    [r, v] = om.d.Rvi32(); if (r) return r; self.gameId = v;
    [r, v] = om.d.Rd(); if (r) return r; self.money = v;
    [r, v] = om.d.Rd(); if (r) return r; self.bet = v;
    return 0;
  },
};

export function registerLobbyPkgs(om: ObjMgr = gOM): void {
  om.Register(Move);
  om.Register(MoveResult);
  om.Register(PKG_Client_Lobby_Enter);
  om.Register(PKG_Client_Lobby_EnterGame);
  om.Register(PKG_Lobby_Client_EnterGameSlots_Success);
  om.Register(PKG_Lobby_Client_MoneyChanged);
  om.Register(PKG_Client_Lobby_Ping);
  om.Register(PKG_Lobby_Client_Pong);
  om.Register(PKG_Lobby_Client_Enter_Success);
  om.Register(PKG_Client_Slots_Enter);
  om.Register(PKG_Slots_Client_Enter_Success);
}
