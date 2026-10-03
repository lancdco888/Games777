import type { GosClient } from './GosClient';
import { formatMoney, HallState } from './HallState';
import {
    encodeActivity,
    encodeBindAccount,
    encodeChangeSafe,
    encodeFaq,
    encodeGift,
    encodeGiftPassword,
    encodeNickname,
    encodeNotice,
    encodePassword,
    encodePhoneBind,
    encodePhoneCode,
    encodePlayer,
    encodeRecharge,
    encodeRelief,
    encodeSignIn,
    encodeWashInfo,
    encodeWashTake,
    encodeWebsite,
    explain,
} from './ServerPlay';
import type { PlayPacket, WirePacket } from './ServerPlay';

export async function serverSafe(client: GosClient, state: HallState, kind: 'coin' | 'wash', amount: number, deposit: boolean): Promise<string> {
    if (!Number.isFinite(amount) || amount <= 0) {
        throw new Error('请输入金额');
    }
    const money = deposit ? Math.ceil(amount) : -Math.floor(amount);
    const packet = await client.request(0, encodeChangeSafe(client.accountId, money, kind === 'wash'));
    const safe = must(packet, 'safe');
    state.applyBalances({
        money: safe.money,
        moneySafe: safe.moneySafe,
        giftSafe: safe.moneyGiftSafe,
    });
    return `操作成功，携带 ${formatMoney(safe.money)}，保险箱 ${formatMoney(kind === 'wash' ? safe.moneyGiftSafe : safe.moneySafe)}`;
}

export async function serverRelief(client: GosClient, state: HallState): Promise<string> {
    const packet = await client.request(0, encodeRelief());
    const relief = must(packet, 'relief');
    await refreshPlayer(client, state).catch(() => undefined);
    return `领取救济金 ${formatMoney(relief.money)}`;
}

export async function serverRecharge(client: GosClient, amount: number): Promise<string> {
    const packet = await client.request(0, encodeRecharge(amount));
    const recharge = must(packet, 'recharge');
    if (recharge.payUrl) {
        return `订单 ${recharge.orderNum} ${recharge.payUrl}`;
    }
    return recharge.orderNum ? `充值订单已创建 ${recharge.orderNum}` : '充值请求已提交';
}

export async function serverGift(client: GosClient, state: HallState, targetId: number, money: number, password: string): Promise<string> {
    if (!Number.isInteger(targetId) || targetId <= 0) {
        throw new Error('请填写对方 ID');
    }
    if (!Number.isFinite(money) || money <= 0) {
        throw new Error('请填写赠送金额');
    }
    const packet = await client.request(0, encodeGift(targetId, money, password));
    const gift = must(packet, 'giftResult');
    state.applyBalances({ money: gift.money, moneySafe: gift.moneySafe });
    return `赠送成功，携带 ${formatMoney(gift.money)}，保险箱 ${formatMoney(gift.moneySafe)}`;
}

export async function serverGiftPassword(client: GosClient, password: string): Promise<string> {
    if (!/^\d{6}$/.test(password)) {
        throw new Error('赠送密码是 6 位数字');
    }
    must(await client.request(0, encodeGiftPassword(password)), 'ok');
    return '赠送密码已设置';
}

export async function serverBindAccount(client: GosClient, state: HallState, account: string, password: string): Promise<string> {
    must(await client.request(0, encodeBindAccount(account, password)), 'ok');
    state.applyBalances({ account });
    return '账号已绑定';
}

export async function serverPhoneCode(client: GosClient, phone: string): Promise<string> {
    if (!phone.trim()) {
        throw new Error('请填写手机号');
    }
    must(await client.request(0, encodePhoneCode(phone.trim())), 'ok');
    return '验证码已发送';
}

export async function serverPhoneBind(client: GosClient, code: string): Promise<string> {
    const packet = await client.request(0, encodePhoneBind(code.trim()));
    const phone = must(packet, 'phone');
    if (!phone.success) {
        throw new Error(phone.phone ? `绑定失败 ${phone.phone}` : '手机绑定失败');
    }
    return `手机已绑定 ${phone.phone}`;
}

export async function serverNickname(client: GosClient, state: HallState, nickname: string): Promise<string> {
    const name = nickname.trim();
    if (!name) {
        throw new Error('请填写昵称');
    }
    const packet = await client.request(0, encodeNickname(name));
    const renamed = must(packet, 'nickname');
    state.applyBalances({ nickname: renamed.nickname || name });
    return `昵称已改为 ${renamed.nickname || name}`;
}

export async function serverPassword(client: GosClient, oldPassword: string, nextPassword: string): Promise<string> {
    if (nextPassword.length < 8 || nextPassword.length > 16) {
        throw new Error('账户密码长度8至16位');
    }
    must(await client.request(0, encodePassword(oldPassword, nextPassword)), 'ok');
    return '密码已修改';
}

export async function serverSignIn(client: GosClient, state: HallState): Promise<string> {
    const packet = await client.request(0, encodeSignIn());
    const sign = must(packet, 'signin');
    state.applyBalances({ money: sign.currMoney });
    return `签到成功，获得 ${formatMoney(sign.giveMoney)}，当前 ${formatMoney(sign.currMoney)}`;
}

export async function serverActivity(client: GosClient): Promise<PlayPacket & { kind: 'activity' }> {
    return must(await client.request(0, encodeActivity()), 'activity');
}

export async function serverWash(client: GosClient, state: HallState, activityId: number, take: boolean): Promise<string> {
    if (!take) {
        const info = must(await client.request(0, encodeWashInfo(activityId)), 'wash');
        return info.canGive ? `洗码活动 ${info.activityId} 可以领取` : `洗码活动 ${info.activityId} 暂不可领`;
    }
    const reward = must(await client.request(0, encodeWashTake(activityId)), 'washReward');
    await refreshPlayer(client, state).catch(() => undefined);
    return `领取洗码 ${formatMoney(reward.rewardValue)}`;
}

export async function serverWebsite(client: GosClient, state: HallState): Promise<string> {
    const site = must(await client.request(0, encodeWebsite()), 'website');
    if (site.website) {
        state.url = site.website;
    }
    return site.website || '服务器没有下发官网地址';
}

export async function serverPlayer(client: GosClient, state: HallState): Promise<string> {
    await refreshPlayer(client, state);
    return `${state.nickname}  ID ${state.userId}  VIP ${state.vipLevel}`;
}

export async function serverService(client: GosClient): Promise<Array<{ title: string; body: string }>> {
    const notices = await client.request(0, encodeNotice());
    if (notices.kind === 'notices' && notices.items.length) {
        return notices.items.map((item) => ({ title: item.title || '公告', body: item.content }));
    }
    const faq = await client.request(0, encodeFaq());
    if (faq.kind === 'faq') {
        return faq.items.map((item) => ({ title: item.question || '问题', body: item.answer }));
    }
    const refused = explain(notices) || explain(faq);
    if (refused) {
        throw new Error(refused);
    }
    return [];
}

async function refreshPlayer(client: GosClient, state: HallState): Promise<void> {
    const packet = await client.request(0, encodePlayer());
    const player = must(packet, 'player');
    if (!player.self) {
        return;
    }
    const self = player.self;
    state.userId = String(self.id || state.userId);
    state.applyBalances({
        money: self.money,
        moneySafe: self.moneySafe,
        washCode: self.amountOfWashcode,
        giftSafe: self.moneyGiftSafe,
        vipLevel: self.vipLevel,
        nickname: self.nickname || state.nickname,
        account: self.accountName,
    });
}

function must<Kind extends PlayPacket['kind']>(packet: WirePacket, kind: Kind): Extract<PlayPacket, { kind: Kind }> {
    const refused = explain(packet);
    if (refused) {
        throw new Error(refused);
    }
    if (packet.kind !== kind) {
        throw new Error(packet.kind === 'unknown' ? `服务器返回了未识别的包 ${packet.typeId}` : `服务器返回了未识别的包 ${packet.kind}`);
    }
    return packet as Extract<PlayPacket, { kind: Kind }>;
}
