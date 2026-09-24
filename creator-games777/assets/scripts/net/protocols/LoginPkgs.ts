import { gOM, type ObjMgr, type PkgInstance, type PkgMeta } from '../ObjMgr';

function baseCreate(typeId: number, typeName: string, fields: Record<string, unknown>): PkgInstance {
  return { _typeId: typeId, _typeName: typeName, ...fields };
}

const ClientType: PkgMeta = {
  typeId: 1103,
  typeName: 'PKG_Client_Login_ClientType',
  Create: (o) =>
    Object.assign(
      o || baseCreate(1103, 'PKG_Client_Login_ClientType', {}),
      {
        clientType: '',
        phoneType: 0,
        createIp: '',
        version: '',
        packageName: '',
        device_id: '',
        ram: '',
        promotion_code: '',
        facebook: '',
        password: '',
      },
    ),
  Write(self, om) {
    const d = om.d;
    d.Wstr(String(self.clientType || ''));
    d.Wvi32(Number(self.phoneType || 0));
    d.Wstr(String(self.createIp || ''));
    d.Wstr(String(self.version || ''));
    d.Wstr(String(self.packageName || ''));
    d.Wstr(String(self.device_id || ''));
    d.Wstr(String(self.ram || ''));
    d.Wstr(String(self.promotion_code || ''));
    d.Wstr(String(self.facebook || ''));
    d.Wstr(String(self.password || ''));
  },
  Read(self, om) {
    const d = om.d;
    let r: number;
    let v: string | number;
    [r, v] = d.Rstr(); if (r) return r; self.clientType = v;
    [r, v] = d.Rvi32(); if (r) return r; self.phoneType = v;
    [r, v] = d.Rstr(); if (r) return r; self.createIp = v;
    [r, v] = d.Rstr(); if (r) return r; self.version = v;
    [r, v] = d.Rstr(); if (r) return r; self.packageName = v;
    [r, v] = d.Rstr(); if (r) return r; self.device_id = v;
    [r, v] = d.Rstr(); if (r) return r; self.ram = v;
    [r, v] = d.Rstr(); if (r) return r; self.promotion_code = v;
    [r, v] = d.Rstr(); if (r) return r; self.facebook = v;
    [r, v] = d.Rstr(); if (r) return r; self.password = v;
    return 0;
  },
};

const Auth: PkgMeta = {
  typeId: 1104,
  typeName: 'PKG_Client_Login_Auth',
  Create: (o) => {
    const x = ClientType.Create(o);
    x._typeId = 1104;
    x._typeName = 'PKG_Client_Login_Auth';
    x.pkgGenMd5 = '';
    return x;
  },
  Write(self, om) {
    ClientType.Write(self, om);
    om.d.Wstr(String(self.pkgGenMd5 || ''));
  },
  Read(self, om) {
    const r0 = ClientType.Read(self, om);
    if (r0) return r0;
    const [r, v] = om.d.Rstr();
    if (r) return r;
    self.pkgGenMd5 = v;
    return 0;
  },
};

export const PKG_Client_Login_AuthByUsername: PkgMeta = {
  typeId: 1106,
  typeName: 'PKG_Client_Login_AuthByUsername',
  Create: (o) => {
    const x = Auth.Create(o);
    x._typeId = 1106;
    x._typeName = 'PKG_Client_Login_AuthByUsername';
    x.username = '';
    x.account_name = '';
    x.google = '';
    x.apple = '';
    x.code = '';
    return x;
  },
  Write(self, om) {
    Auth.Write(self, om);
    const d = om.d;
    d.Wstr(String(self.username || ''));
    d.Wstr(String(self.account_name || ''));
    d.Wstr(String(self.google || ''));
    d.Wstr(String(self.apple || ''));
    d.Wstr(String(self.code || ''));
  },
  Read(self, om) {
    const r0 = Auth.Read(self, om);
    if (r0) return r0;
    const d = om.d;
    let r: number; let v: string;
    [r, v] = d.Rstr(); if (r) return r; self.username = v;
    [r, v] = d.Rstr(); if (r) return r; self.account_name = v;
    [r, v] = d.Rstr(); if (r) return r; self.google = v;
    [r, v] = d.Rstr(); if (r) return r; self.apple = v;
    [r, v] = d.Rstr(); if (r) return r; self.code = v;
    return 0;
  },
};

/** Nested objects simplified for Creator Phase 2 — full Shared graphs later. */
export const PKG_Login_Client_Auth_Success_Lobby: PkgMeta = {
  typeId: 1001,
  typeName: 'PKG_Login_Client_Auth_Success_Lobby',
  Create: () =>
    baseCreate(1001, 'PKG_Login_Client_Auth_Success_Lobby', {
      lobbyToken: '',
      username: '',
      accountId: 0,
      phone: '',
      facebook: '',
      gameId: 0,
      self: null,
      vips: [],
      serviceId: 0,
      money_exchange_coin: 1000,
      gift_cfg: [],
      is_open_realname_mode: 0,
      google: '',
      apple: '',
      activity_give_type: 0,
      botton_configs: [],
      slots_bet_lottery_mode: 0,
      washcode_mode: 0,
    }),
  Write(self, om) {
    const d = om.d;
    d.Wstr(String(self.lobbyToken || ''));
    d.Wstr(String(self.username || ''));
    d.Wvi32(Number(self.accountId || 0));
    d.Wstr(String(self.phone || ''));
    d.Wstr(String(self.facebook || ''));
    d.Wvi32(Number(self.gameId || 0));
    om.Write((self.self as PkgInstance) || null);
    const vips = (self.vips as unknown[]) || [];
    d.Wvu32(vips.length);
    for (const v of vips) om.Write(v as PkgInstance);
    d.Wvi32(Number(self.serviceId || 0));
    d.Wvi32(Number(self.money_exchange_coin || 0));
    const gifts = (self.gift_cfg as unknown[]) || [];
    d.Wvu32(gifts.length);
    for (const g of gifts) om.Write(g as PkgInstance);
    d.Wvi32(Number(self.is_open_realname_mode || 0));
    d.Wstr(String(self.google || ''));
    d.Wstr(String(self.apple || ''));
    d.Wvi32(Number(self.activity_give_type || 0));
    const buttons = (self.botton_configs as unknown[]) || [];
    d.Wvu32(buttons.length);
    for (const b of buttons) om.Write(b as PkgInstance);
    d.Wvi32(Number(self.slots_bet_lottery_mode || 0));
    d.Wvi32(Number(self.washcode_mode || 0));
  },
  Read(self, om) {
    const d = om.d;
    let r: number; let v: string | number; let o: PkgInstance | null;
    [r, v] = d.Rstr(); if (r) return r; self.lobbyToken = v;
    [r, v] = d.Rstr(); if (r) return r; self.username = v;
    [r, v] = d.Rvi32(); if (r) return r; self.accountId = v;
    [r, v] = d.Rstr(); if (r) return r; self.phone = v;
    [r, v] = d.Rstr(); if (r) return r; self.facebook = v;
    [r, v] = d.Rvi32(); if (r) return r; self.gameId = v;
    [r, o] = om.Read(); if (r) return r; self.self = o;
    let len = 0;
    [r, len] = d.Rvu32(); if (r) return r;
    const vips: PkgInstance[] = [];
    for (let i = 0; i < len; i++) {
      [r, o] = om.Read(); if (r) return r; if (o) vips.push(o);
    }
    self.vips = vips;
    [r, v] = d.Rvi32(); if (r) return r; self.serviceId = v;
    [r, v] = d.Rvi32(); if (r) return r; self.money_exchange_coin = v;
    [r, len] = d.Rvu32(); if (r) return r;
    const gifts: PkgInstance[] = [];
    for (let i = 0; i < len; i++) {
      [r, o] = om.Read(); if (r) return r; if (o) gifts.push(o);
    }
    self.gift_cfg = gifts;
    [r, v] = d.Rvi32(); if (r) return r; self.is_open_realname_mode = v;
    [r, v] = d.Rstr(); if (r) return r; self.google = v;
    [r, v] = d.Rstr(); if (r) return r; self.apple = v;
    [r, v] = d.Rvi32(); if (r) return r; self.activity_give_type = v;
    [r, len] = d.Rvu32(); if (r) return r;
    const buttons: PkgInstance[] = [];
    for (let i = 0; i < len; i++) {
      [r, o] = om.Read(); if (r) return r; if (o) buttons.push(o);
    }
    self.botton_configs = buttons;
    [r, v] = d.Rvi32(); if (r) return r; self.slots_bet_lottery_mode = v;
    [r, v] = d.Rvi32(); if (r) return r; self.washcode_mode = v;
    return 0;
  },
};

export function registerLoginPkgs(om: ObjMgr = gOM): void {
  om.Register(ClientType);
  om.Register(Auth);
  om.Register(PKG_Client_Login_AuthByUsername);
  om.Register(PKG_Login_Client_Auth_Success_Lobby);
}
