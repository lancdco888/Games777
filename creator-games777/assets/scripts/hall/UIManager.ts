import { TR } from '../core/i18n';
import { Dispatcher } from '../core/Dispatcher';

/**
 * UI facade — port of hallnew/UIManager.lua (toast / waiting / msgbox).
 * Wired to real Prefabs in Lobby/Login scenes next.
 */
export const UIManager = {
  ShowWaiting(text?: string): void {
    Dispatcher.Dispatch('UI_WAITING', true, text || TR('登录中'));
  },

  HideWaiting(): void {
    Dispatcher.Dispatch('UI_WAITING', false);
  },

  ShowToast(text: string): void {
    Dispatcher.Dispatch('UI_TOAST', text);
    // eslint-disable-next-line no-console
    console.log('[Toast]', text);
  },

  ShowMsgBox(content: string, onOk?: () => void, onCancel?: () => void): void {
    Dispatcher.Dispatch('UI_MSGBOX', { content, onOk, onCancel });
    // Fallback for headless / early boot
    if (onOk) onOk();
  },
};
