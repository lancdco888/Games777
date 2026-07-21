import { _decorator, Component, Label, EditBox, director } from 'cc';
import { LoginData, LoginType } from '../data/LoginData';
import { LogicMain } from '../hall/LogicMain';
import { TR } from '../core/i18n';
import { Dispatcher } from '../core/Dispatcher';
import { Coroutines } from '../core/Coroutine';

const { ccclass, property } = _decorator;

/**
 * Login shell — port of packagelua LoginLayer (guest / password).
 */
@ccclass('LoginController')
export class LoginController extends Component {
  @property(Label)
  titleLabel: Label | null = null;

  @property(Label)
  statusLabel: Label | null = null;

  @property(EditBox)
  accountEdit: EditBox | null = null;

  @property(EditBox)
  passwordEdit: EditBox | null = null;

  onLoad(): void {
    Dispatcher.Add('UI_WAITING', this, (show: unknown, text: unknown) => {
      if (this.statusLabel) {
        this.statusLabel.string = show ? String(text || TR('登录中')) : '';
      }
    });
    Dispatcher.Add('UI_TOAST', this, (text: unknown) => {
      if (this.statusLabel) this.statusLabel.string = String(text);
    });
  }

  onDestroy(): void {
    Dispatcher.Remove(this);
  }

  start(): void {
    if (this.titleLabel) this.titleLabel.string = 'Games777';
    this.schedule((dt: number) => Coroutines.update(dt), 0);
  }

  onClickGuest(): void {
    LoginData.EnsureGuestAccount();
    if (this.statusLabel) this.statusLabel.string = TR('登录中');
    void LogicMain();
  }

  onClickPassword(): void {
    const account = this.accountEdit?.string?.trim() || LoginData.GetAccount();
    const password = this.passwordEdit?.string || '';
    if (!account) {
      if (this.statusLabel) this.statusLabel.string = 'account required';
      return;
    }
    LoginData.SetType(LoginType.PWD);
    LoginData.SetAccount(account);
    LoginData.SetPassword(password);
    if (this.statusLabel) this.statusLabel.string = TR('登录中');
    void LogicMain();
  }
}
