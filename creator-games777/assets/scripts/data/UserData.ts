/**
 * Port of hall/src/common/UserData.lua
 */
export class UserDataStore {
  id = 0;
  username = '';
  nickname = '';
  avatar_id = 0;
  phone = '';
  is_first_login = false;

  money = 0;
  money_safe = 0;
  money_gift = 0;
  money_gift_safe = 0;
  total_recharge = 0;

  is_gift_money_password = 0;
  is_system_gift_money = 0;
  is_popularize = 0;
  is_promotion = 0;
  is_signingave = 0;
  has_gift_money_purview = 0;
  is_shows_signingave_button = 0;
  account_name = '';

  buttonList: Record<string, unknown> = {};
  activity_give_type = 0;
  is_experience = 0;
  email = '';
  is_open_email_bind = 0;
  bind_account_money_gift = 0;

  total_refund = 0;
  has_refund_purview = 0;
  refund_min_money = 0;
  refund_min_remain_money = 0;
  refund_margin = 0;
  bankcardcount = 0;
  virtual_coin_status = 0;
  virtual_coin_status_switch_money = 0;

  CanUseVirtualRecharge(): boolean {
    return this.virtual_coin_status === 1;
  }

  applyAuthSuccess(payload: Partial<UserDataStore>): void {
    Object.assign(this, payload);
  }
}

export const UserData = new UserDataStore();
