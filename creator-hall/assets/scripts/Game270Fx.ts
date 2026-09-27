/** Frame sheets written by creator-hall/tools/export_reel_fx.py. */

export interface MovieSheet {
    file: string;
    count: number;
    columns: number;
    interval: number;
    width: number;
    height: number;
}

export const MOVIES: Record<string, MovieSheet> = {
    wild: { file: 'game270/fx/wild', count: 40, columns: 8, interval: 0.066, width: 256, height: 208 },
    scatter: { file: 'game270/fx/scatter', count: 30, columns: 8, interval: 0.083, width: 256, height: 208 },
    pic1: { file: 'game270/fx/pic1', count: 20, columns: 8, interval: 0.041, width: 256, height: 208 },
    pic2: { file: 'game270/fx/pic2', count: 60, columns: 8, interval: 0.083, width: 256, height: 208 },
    pic3: { file: 'game270/fx/pic3', count: 40, columns: 8, interval: 0.083, width: 256, height: 208 },
    pic4: { file: 'game270/fx/pic4', count: 50, columns: 8, interval: 0.083, width: 256, height: 208 },
    coin: { file: 'game270/fx/coin', count: 9, columns: 8, interval: 0.083, width: 69, height: 67 },
};
