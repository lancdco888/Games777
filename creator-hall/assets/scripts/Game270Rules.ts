/** Paylines from FGame270 WinLineConfigs. Row 0 is the top row. */
export const LINES: number[][] = [
    [1, 1, 1, 1, 1],
    [0, 0, 0, 0, 0],
    [2, 2, 2, 2, 2],
    [0, 1, 2, 1, 0],
    [2, 1, 0, 1, 2],
    [0, 0, 1, 0, 0],
    [2, 2, 1, 2, 2],
    [1, 2, 2, 2, 1],
    [1, 0, 0, 0, 1],
    [0, 1, 1, 1, 0],
    [2, 1, 1, 1, 2],
    [0, 1, 0, 1, 0],
    [2, 1, 2, 1, 2],
    [1, 0, 1, 0, 1],
    [1, 2, 1, 2, 1],
    [1, 1, 0, 1, 1],
    [1, 1, 2, 1, 1],
    [0, 2, 0, 2, 0],
    [2, 0, 2, 0, 2],
    [1, 0, 2, 0, 1],
    [1, 2, 0, 2, 1],
    [0, 0, 2, 0, 0],
    [2, 2, 0, 2, 2],
    [0, 2, 2, 2, 0],
    [2, 0, 0, 0, 2],
    [0, 2, 1, 2, 0],
    [2, 0, 1, 0, 2],
    [1, 1, 1, 1, 2],
    [0, 0, 1, 2, 2],
    [2, 2, 1, 0, 0],
    [0, 1, 1, 1, 2],
    [2, 1, 1, 1, 0],
    [0, 1, 2, 1, 2],
    [2, 1, 0, 1, 0],
    [0, 0, 0, 0, 1],
    [2, 2, 2, 2, 1],
    [0, 1, 0, 1, 2],
    [2, 1, 2, 1, 0],
    [1, 0, 1, 2, 1],
    [1, 2, 1, 0, 1],
    [1, 1, 0, 0, 0],
    [1, 1, 2, 2, 2],
    [1, 0, 0, 1, 2],
    [1, 2, 2, 1, 0],
    [1, 0, 1, 2, 2],
    [1, 2, 1, 0, 0],
    [2, 1, 0, 0, 1],
    [0, 1, 2, 2, 1],
    [0, 0, 1, 2, 1],
    [2, 2, 1, 0, 1],
];

export const WILD = 1;
export const SCATTER = 2;

export const SYMBOLS = [
    { id: 1, name: '百搭', color: '#f0c14a' },
    { id: 2, name: '散布', color: '#e2557a' },
    { id: 3, name: '灯笼', color: '#ef7b2f' },
    { id: 4, name: '佛', color: '#d4a017' },
    { id: 5, name: '布', color: '#3d8bfd' },
    { id: 6, name: '酒', color: '#8d4b2a' },
    { id: 7, name: '蝎', color: '#c23b3b' },
    { id: 8, name: 'K', color: '#5b6ee1' },
    { id: 9, name: 'Q', color: '#7a5af5' },
    { id: 10, name: 'J', color: '#2f9e8f' },
    { id: 11, name: '10', color: '#4caf7d' },
    { id: 12, name: '9', color: '#607d8b' },
];

const PAY = [0, 0, 0, 2, 8, 20];

export function symbolById(id: number): { id: number; name: string; color: string } {
    return SYMBOLS[id - 1] || SYMBOLS[0];
}

export function rollGrid(random: () => number = Math.random): number[][] {
    const grid: number[][] = [];
    for (let col = 0; col < 5; col += 1) {
        const reel: number[] = [];
        for (let row = 0; row < 3; row += 1) {
            reel.push(1 + Math.floor(random() * SYMBOLS.length));
        }
        grid.push(reel);
    }
    return grid;
}

export function scoreGrid(grid: number[][], bet: number): { win: number; hits: number } {
    const perLine = bet / LINES.length;
    let win = 0;
    let hits = 0;
    for (const line of LINES) {
        const ids = line.map((row, col) => grid[col][row]);
        const count = runLength(ids);
        if (count >= 3) {
            hits += 1;
            win += Math.floor(perLine * PAY[count]);
        }
    }
    let scatters = 0;
    for (const reel of grid) {
        for (const id of reel) {
            if (id === SCATTER) {
                scatters += 1;
            }
        }
    }
    if (scatters >= 3) {
        hits += 1;
        win += bet * 2;
    }
    return { win, hits };
}

function runLength(ids: number[]): number {
    let base = 0;
    for (const id of ids) {
        if (id !== WILD) {
            base = id;
            break;
        }
    }
    if (base === 0 || base === SCATTER) {
        return 0;
    }
    let count = 0;
    for (const id of ids) {
        if (id === base || id === WILD) {
            count += 1;
        } else {
            break;
        }
    }
    return count;
}
