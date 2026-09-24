export interface GameInfo {
    id: number;
    icon: number;
    name: string;
    type: string;
}

export interface HallResult {
    ok: boolean;
    message: string;
}

export interface MailItem {
    title: string;
    body: string;
    read: boolean;
}

export function formatMoney(value: number): string {
    const sign = value < 0 ? '-' : '';
    const digits = Math.floor(Math.abs(value)).toString();
    return sign + digits.replace(/\B(?=(\d{3})+(?!\d))/g, ',');
}

export function parseMoney(text: string): number {
    const value = Number(String(text).replace(/,/g, ''));
    return Number.isFinite(value) ? value : 0;
}

/**
 * Local hall account. Buttons change this state directly until the lobby socket is ported.
 */
export class HallState {
    nickname = '玩家9236';
    userId = '9236';
    vipLevel = 3;
    money = 128800;
    moneySafe = 50000;
    washCode = 8600;
    giftSafe = 1200;
    url = 'www.game.com';
    account = '';
    registered = false;
    giftPassword = '';
    music = true;
    sound = true;
    effect = true;
    notice = true;
    signed = false;
    reliefClaimed = false;
    giftFee = 0.02;
    giftMin = 100;
    giftRemain = 1000;
    readonly mails: MailItem[] = [
        { title: '欢迎来到大厅', body: '可以领取救济金，也可以把金币存入保险箱。', read: false },
        { title: '系统公告', body: '活动中心每天可以签到，奖励直接加到携带金币。', read: false },
    ];
    readonly activities = [
        { id: 'sign', name: '每日签到', detail: '每天可领取 500 金币。' },
        { id: 'recharge', name: '充值返利', detail: '选择金额后金币立即到账。' },
        { id: 'vip', name: 'VIP 专属', detail: '当前 VIP 可在个人信息里查看。' },
    ];
    readonly records: { target: string; amount: number; fee: number }[] = [];
    private readonly listeners: Array<() => void> = [];
    private readonly accounts: Record<string, AccountRecord> = {
        player9236: {
            password: '12345678',
            nickname: '玩家9236',
            userId: '9236',
            vipLevel: 3,
            money: 128800,
            moneySafe: 50000,
            washCode: 8600,
            giftSafe: 1200,
        },
    };

    constructor() {
        const saved = readAccounts();
        Object.assign(this.accounts, saved);
    }

    listen(fn: () => void): void {
        this.listeners.push(fn);
    }

    emit(): void {
        this.captureAccount();
        this.listeners.forEach((fn) => fn());
    }

    loginGuest(): HallResult {
        const id = String(100000 + Math.floor(Math.random() * 900000));
        this.account = '';
        this.registered = false;
        this.nickname = `游客${id.slice(-4)}`;
        this.userId = id;
        this.vipLevel = 0;
        this.money = 50000;
        this.moneySafe = 0;
        this.washCode = 0;
        this.giftSafe = 0;
        this.emit();
        return { ok: true, message: '游客登录成功' };
    }

    loginAccount(account: string, password: string): HallResult {
        const found = this.accounts[account.trim()];
        if (!found || found.password !== password) {
            return { ok: false, message: '用户名或密码错误' };
        }
        this.applyAccount(account.trim(), found);
        return { ok: true, message: '登录成功' };
    }

    registerAccount(account: string, password: string, confirm: string): HallResult {
        const name = account.trim();
        if (name.length < 4 || name.length > 12) {
            return { ok: false, message: '账户名称长度4至12位' };
        }
        if (password.length < 8 || password.length > 16) {
            return { ok: false, message: '账户密码长度8至16位' };
        }
        if (password !== confirm) {
            return { ok: false, message: '两次密码不一致' };
        }
        if (this.accounts[name]) {
            return { ok: false, message: '账号已存在' };
        }
        const id = String(200000 + Math.floor(Math.random() * 700000));
        this.accounts[name] = {
            password,
            nickname: name,
            userId: id,
            vipLevel: 1,
            money: 50000,
            moneySafe: 0,
            washCode: 0,
            giftSafe: 0,
        };
        return this.loginAccount(name, password);
    }

    logout(): void {
        this.captureAccount();
        this.account = '';
        this.registered = false;
    }

    spend(amount: number): HallResult {
        if (amount <= 0 || amount > this.money) {
            return { ok: false, message: '金币不足' };
        }
        this.money -= amount;
        this.emit();
        return { ok: true, message: '' };
    }

    award(amount: number): void {
        if (amount <= 0) {
            return;
        }
        this.money += amount;
        this.emit();
    }

    applySample(sample: {
        nickname: string;
        vipLevel: number;
        money: string;
        moneySafe: string;
        washCode: string;
        url: string;
    }): void {
        this.nickname = sample.nickname;
        const digits = sample.nickname.replace(/\D/g, '');
        this.userId = digits || this.userId;
        this.vipLevel = sample.vipLevel;
        this.money = parseMoney(sample.money);
        this.moneySafe = parseMoney(sample.moneySafe);
        this.washCode = parseMoney(sample.washCode);
        this.url = sample.url;
        this.emit();
    }

    deposit(kind: 'coin' | 'wash', amount: number): HallResult {
        return this.transfer(kind, amount, true);
    }

    withdraw(kind: 'coin' | 'wash', amount: number): HallResult {
        return this.transfer(kind, amount, false);
    }

    recharge(amount: number): HallResult {
        if (amount <= 0) {
            return { ok: false, message: '请选择充值金额' };
        }
        this.money += amount;
        this.emit();
        return { ok: true, message: `充值成功，到账 ${formatMoney(amount)}` };
    }

    claimRelief(): HallResult {
        if (this.reliefClaimed) {
            return { ok: false, message: '今天已经领过救济金' };
        }
        if (this.money >= 1000) {
            return { ok: false, message: '金币充足，暂不可领取' };
        }
        this.money += 2000;
        this.reliefClaimed = true;
        this.emit();
        return { ok: true, message: '领取救济金 2,000' };
    }

    signIn(): HallResult {
        if (this.signed) {
            return { ok: false, message: '今天已经签到' };
        }
        this.signed = true;
        this.money += 500;
        this.emit();
        return { ok: true, message: '签到成功，获得 500 金币' };
    }

    bindAccount(account: string, password: string): HallResult {
        if (!account.trim()) {
            return { ok: false, message: '账号不能为空' };
        }
        if (password.length < 6) {
            return { ok: false, message: '密码至少 6 位' };
        }
        this.account = account.trim();
        this.emit();
        return { ok: true, message: '账号绑定成功' };
    }

    register(account: string): HallResult {
        if (!account.trim()) {
            return { ok: false, message: '请输入会员账号' };
        }
        this.registered = true;
        if (!this.account) {
            this.account = account.trim();
        }
        this.emit();
        return { ok: true, message: '注册成功' };
    }

    setGiftPassword(password: string): HallResult {
        if (!/^\d{6}$/.test(password)) {
            return { ok: false, message: '请设置 6 位数字密码' };
        }
        this.giftPassword = password;
        this.emit();
        return { ok: true, message: '赠送密码已设置' };
    }

    give(target: string, amount: number, password: string): HallResult {
        if (!/^\d+$/.test(target)) {
            return { ok: false, message: '请输入正确的ID' };
        }
        if (target === this.userId) {
            return { ok: false, message: '不能赠送给自己' };
        }
        if (!this.giftPassword) {
            return { ok: false, message: '请先设置赠送密码' };
        }
        if (password !== this.giftPassword) {
            return { ok: false, message: '密码输入错误请重新输入' };
        }
        if (!Number.isInteger(amount) || amount <= 0) {
            return { ok: false, message: '请输入整数金额' };
        }
        if (amount < this.giftMin) {
            return { ok: false, message: `最少赠送 ${formatMoney(this.giftMin)} 金币` };
        }
        const fee = Math.ceil(amount * this.giftFee);
        const cost = amount + fee;
        if (this.money + this.moneySafe - cost < this.giftRemain) {
            return { ok: false, message: `赠送后至少保留 ${formatMoney(this.giftRemain)} 金币` };
        }
        let left = cost;
        const fromPocket = Math.min(this.money, left);
        this.money -= fromPocket;
        left -= fromPocket;
        this.moneySafe -= left;
        this.records.unshift({ target, amount, fee });
        this.emit();
        return { ok: true, message: `成功赠送 ${formatMoney(amount)} 金币给 ${target}，手续费 ${formatMoney(fee)}` };
    }

    enterGame(name: string, level: string, minMoney: number): HallResult {
        if (this.money < minMoney) {
            return { ok: false, message: `金币不足，至少需要 ${formatMoney(minMoney)}` };
        }
        return { ok: true, message: level ? `已进入 ${name} · ${level}` : `已进入 ${name}` };
    }

    toggle(key: 'music' | 'sound' | 'effect' | 'notice'): HallResult {
        this[key] = !this[key];
        this.emit();
        const labels = { music: '音乐', sound: '音效', effect: '特效', notice: '跑马灯' };
        return { ok: true, message: `${labels[key]}已${this[key] ? '打开' : '关闭'}` };
    }

    private transfer(kind: 'coin' | 'wash', amount: number, intoSafe: boolean): HallResult {
        if (!Number.isInteger(amount) || amount <= 0) {
            return { ok: false, message: '请输入整数金额' };
        }
        const pocket = kind === 'coin' ? this.money : this.washCode;
        const safe = kind === 'coin' ? this.moneySafe : this.giftSafe;
        if (intoSafe && amount > pocket) {
            return { ok: false, message: '携带金额不足' };
        }
        if (!intoSafe && amount > safe) {
            return { ok: false, message: '保险箱金额不足' };
        }
        if (kind === 'coin') {
            this.money += intoSafe ? -amount : amount;
            this.moneySafe += intoSafe ? amount : -amount;
        } else {
            this.washCode += intoSafe ? -amount : amount;
            this.giftSafe += intoSafe ? amount : -amount;
        }
        this.emit();
        return { ok: true, message: intoSafe ? '存入成功' : '取出成功' };
    }

    private applyAccount(account: string, found: AccountRecord): void {
        this.account = account;
        this.registered = true;
        this.nickname = found.nickname;
        this.userId = found.userId;
        this.vipLevel = found.vipLevel;
        this.money = found.money;
        this.moneySafe = found.moneySafe;
        this.washCode = found.washCode;
        this.giftSafe = found.giftSafe;
        this.emit();
    }

    private captureAccount(): void {
        if (!this.account || !this.accounts[this.account]) {
            return;
        }
        const found = this.accounts[this.account];
        found.nickname = this.nickname;
        found.vipLevel = this.vipLevel;
        found.money = this.money;
        found.moneySafe = this.moneySafe;
        found.washCode = this.washCode;
        found.giftSafe = this.giftSafe;
        writeAccounts(this.accounts);
    }
}

interface AccountRecord {
    password: string;
    nickname: string;
    userId: string;
    vipLevel: number;
    money: number;
    moneySafe: number;
    washCode: number;
    giftSafe: number;
}

function accountStorage(): { getItem(key: string): string | null; setItem(key: string, value: string): void } | undefined {
    return (globalThis as { localStorage?: { getItem(key: string): string | null; setItem(key: string, value: string): void } }).localStorage;
}

function readAccounts(): Record<string, AccountRecord> {
    try {
        const raw = accountStorage()?.getItem('creator-hall-accounts');
        if (!raw) {
            return {};
        }
        const parsed = JSON.parse(raw) as Record<string, AccountRecord>;
        return parsed && typeof parsed === 'object' ? parsed : {};
    } catch {
        return {};
    }
}

function writeAccounts(accounts: Record<string, AccountRecord>): void {
    try {
        accountStorage()?.setItem('creator-hall-accounts', JSON.stringify(accounts));
    } catch {
        // Preview without browser storage still keeps the account for this run.
    }
}
