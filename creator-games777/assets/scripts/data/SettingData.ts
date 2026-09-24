import { AppStorage } from '../core/Storage';

class SettingDataImpl {
  GetNetworkIP(): string {
    return AppStorage.getString('network_ip', '127.0.0.1');
  }

  SetNetworkIP(ip: string): void {
    AppStorage.setString('network_ip', ip);
  }

  GetNetworkPort(): number {
    const v = AppStorage.getString('network_port', '9000');
    return Number(v) || 9000;
  }

  SetNetworkPort(port: number): void {
    AppStorage.setString('network_port', String(port));
  }
}

export const SettingData = new SettingDataImpl();
