import { XxData } from './XxData';

export type PkgInstance = Record<string, unknown> & { _typeId?: number; _typeName?: string };

export type PkgMeta = {
  typeId: number;
  typeName: string;
  Create: (o?: PkgInstance) => PkgInstance;
  Write: (self: PkgInstance, om: ObjMgr) => void;
  Read: (self: PkgInstance, om: ObjMgr) => number;
};

/**
 * ObjMgr — port of packagelua ObjMgr (reference-indexed object graph codec).
 */
export class ObjMgr {
  d: XxData = new XxData();
  m: { len: number; [key: string]: unknown } = { len: 0 };
  private byTypeId = new Map<number, PkgMeta>();
  private byName = new Map<string, PkgMeta>();

  Register(meta: PkgMeta): void {
    this.byTypeId.set(meta.typeId, meta);
    this.byName.set(meta.typeName, meta);
  }

  GetMeta(typeIdOrName: number | string): PkgMeta | undefined {
    return typeof typeIdOrName === 'number'
      ? this.byTypeId.get(typeIdOrName)
      : this.byName.get(typeIdOrName);
  }

  Create(typeName: string, init?: Partial<PkgInstance>): PkgInstance | null {
    const meta = this.byName.get(typeName);
    if (!meta) return null;
    const o = meta.Create();
    if (init) Object.assign(o, init);
    o._typeId = meta.typeId;
    o._typeName = meta.typeName;
    return o;
  }

  WriteTo(d: XxData, o: PkgInstance): void {
    this.d = d;
    this.m = { len: 1, [this.objKey(o)]: 1 };
    const meta = this.metaOf(o);
    d.Wvu16(meta.typeId);
    meta.Write(o, this);
  }

  ReadFrom(d: XxData): [number, PkgInstance | null] {
    this.d = d;
    this.m = { len: 0 };
    return this.ReadFirst();
  }

  Write(o: PkgInstance | null | undefined): void {
    const d = this.d;
    if (o == null) {
      d.Wu8(0);
      return;
    }
    const key = this.objKey(o);
    let n = this.m[key] as number | undefined;
    if (n === undefined) {
      n = (this.m.len as number) + 1;
      this.m.len = n;
      this.m[key] = n;
      d.Wvu32(n);
      const meta = this.metaOf(o);
      d.Wvu16(meta.typeId);
      meta.Write(o, this);
    } else {
      d.Wvu32(n);
    }
  }

  Read(): [number, PkgInstance | null] {
    const d = this.d;
    const [r0, n] = d.Rvu32();
    if (r0 !== 0) return [r0, null];
    if (n === 0) return [0, null];

    const len = Object.keys(this.m).filter((k) => k !== 'len').length;
    if (n === len + 1) {
      const [r1, typeId] = d.Rvu16();
      if (r1 !== 0) return [r1, null];
      if (typeId === 0) return [87, null];
      const meta = this.byTypeId.get(typeId);
      if (!meta) return [91, null];
      const v = meta.Create();
      v._typeId = meta.typeId;
      v._typeName = meta.typeName;
      this.m[String(n)] = v;
      const r2 = meta.Read(v, this);
      if (r2 !== 0) return [r2, null];
      return [0, v];
    }
    const existing = this.m[String(n)] as PkgInstance | undefined;
    if (!existing) return [92, null];
    return [0, existing];
  }

  private ReadFirst(): [number, PkgInstance | null] {
    const d = this.d;
    const [r0, typeId] = d.Rvu16();
    if (r0 !== 0) return [r0, null];
    if (typeId === 0) return [56, null];
    const meta = this.byTypeId.get(typeId);
    if (!meta) return [60, null];
    const v = meta.Create();
    v._typeId = meta.typeId;
    v._typeName = meta.typeName;
    this.m['1'] = v;
    const r1 = meta.Read(v, this);
    if (r1 !== 0) return [r1, null];
    return [0, v];
  }

  private metaOf(o: PkgInstance): PkgMeta {
    const id = o._typeId;
    const name = o._typeName;
    const meta = (id && this.byTypeId.get(id)) || (name && this.byName.get(name));
    if (!meta) throw new Error(`unregistered pkg ${name}/${id}`);
    return meta;
  }

  private objKey(o: PkgInstance): string {
    return `obj_${o._typeName || o._typeId}_${JSON.stringify(Object.keys(o).sort())}`;
  }
}

export const gOM = new ObjMgr();

export function writeRoot(pkg: PkgInstance): Uint8Array {
  const bb = new XxData();
  gOM.WriteTo(bb, pkg);
  return bb.ToUint8Array();
}

export function readRoot(data: Uint8Array): PkgInstance | null {
  const bb = new XxData();
  bb.FromUint8Array(data);
  const [r, o] = gOM.ReadFrom(bb);
  return r === 0 ? o : null;
}
