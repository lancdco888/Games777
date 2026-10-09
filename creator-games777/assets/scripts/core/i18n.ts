/**
 * Minimal i18n — replaces TR() / Translator bootstrap.
 */
const tables: Record<string, Record<string, string>> = {
  zh: {
    '网络连接失败，请重试': '网络连接失败，请重试',
    '版本更新失败': '版本更新失败',
    '登录中': '登录中...',
    '进入大厅': '进入大厅',
    '游客登录': '游客登录',
    '账号登录': '账号登录',
  },
  en: {
    '网络连接失败，请重试': 'Network error, please retry',
    '版本更新失败': 'Update failed',
    '登录中': 'Signing in...',
    '进入大厅': 'Enter Lobby',
    '游客登录': 'Guest',
    '账号登录': 'Account',
  },
};

let currentLang = 'zh';

export function SetLang(lang: string): void {
  currentLang = tables[lang] ? lang : 'zh';
}

export function GetLang(): string {
  return currentLang;
}

export function TR(key: string): string {
  const table = tables[currentLang] || tables.zh;
  return table[key] ?? key;
}
