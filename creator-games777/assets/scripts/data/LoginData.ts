import { AppStorage } from '../core/Storage';

export const LoginType = {
  GUEST: 0,
  FACEBOOK: 1,
  PWD: 2,
} as const;

export type LoginTypeValue = (typeof LoginType)[keyof typeof LoginType];

class LoginDataImpl {
  TYPE = LoginType;

  private type: LoginTypeValue = LoginType.GUEST;
  private account = '';
  private password = '';

  GetType(): LoginTypeValue {
    return this.type;
  }

  SetType(t: LoginTypeValue): void {
    this.type = t;
  }

  GetAccount(): string {
    return this.account || AppStorage.getString('Account', '');
  }

  SetAccount(account: string): void {
    this.account = account;
    AppStorage.setString('Account', account);
  }

  GetPassword(): string {
    return this.password;
  }

  SetPassword(password: string): void {
    this.password = password;
  }

  EnsureGuestAccount(): string {
    let account = this.GetAccount();
    if (!account) {
      account = `guest_${Date.now()}`;
      this.SetAccount(account);
    }
    this.SetType(LoginType.GUEST);
    return account;
  }
}

export const LoginData = new LoginDataImpl();
