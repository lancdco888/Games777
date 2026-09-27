import assert from 'node:assert/strict';
import { payHits } from '../assets/scripts/Game270Rules.ts';
import {
    CELL_SPIN,
    FREE_STOP_DELAY,
    LINE_BLINK,
    LINE_CYCLE,
    NATIVE,
    NEED_BLINK,
    STOP_INTERVAL,
    lanternReels,
    lineSegments,
    presentPlan,
    quickStop,
    requestStop,
    restingReel,
    spinReel,
    stepReel,
    visibleIcons,
    winTune,
} from '../assets/scripts/Game270Motion.ts';

const dt = 1 / 60;

function columnReel(icons: number[]) {
    return restingReel({
        symbolNum: 3,
        symbolHeight: NATIVE.symbolHeight,
        scrollSpeed: NATIVE.scrollSpeed,
        minSymbols: NATIVE.minSymbols,
        bounceDuration: NATIVE.bounceDuration,
        bounceDistance: NATIVE.bounceDistance,
        icons,
    }, () => 8);
}

function run(reels: ReturnType<typeof columnReel>[], seconds: number, random: () => number = () => 8) {
    const bounceAt: number[][] = reels.map(() => []);
    const stopAt: number[][] = reels.map(() => []);
    let time = 0;
    while (time < seconds) {
        time += dt;
        reels.forEach((reel, index) => {
            const event = stepReel(reel, dt, random);
            if (event === 'bounce') {
                bounceAt[index].push(Number(time.toFixed(4)));
            }
            if (event === 'stop') {
                stopAt[index].push(Number(time.toFixed(4)));
            }
        });
    }
    return { bounceAt, stopAt, time };
}

const reels = [0, 1, 2, 3, 4].map(() => columnReel([6, 12, 9]));
reels.forEach((reel) => spinReel(reel));
reels.forEach((reel, index) => requestStop(reel, [4, 5, 6], STOP_INTERVAL.normal * index));
const normal = run(reels, 4);
reels.forEach((reel, index) => {
    assert.deepEqual(visibleIcons(reel), [4, 5, 6], `column ${index} landed on the result`);
    assert.equal(reel.phase, 'none');
    assert.equal(reel.offset, 0);
});
const bounce = normal.bounceAt.map((times) => times[0]);
const stopped = normal.stopAt.map((times) => times[0]);
for (let index = 0; index < 5; index += 1) {
    assert.ok(bounce[index] > 0.6, `column ${index} spins at least the 15-symbol minimum`);
    assert.ok(Math.abs((stopped[index] - bounce[index]) - NATIVE.bounceDuration) < dt + 0.001, 'bounce lasts 0.4s');
    if (index > 0) {
        const gap = bounce[index] - bounce[index - 1];
        assert.ok(gap > 0.42 && gap < 0.52, `stop stagger ${gap} follows 0.45s`);
    }
}

const quick = columnReel([1, 1, 1]);
spinReel(quick);
requestStop(quick, [7, 7, 7], 1.5);
for (let i = 0; i < 12; i += 1) {
    stepReel(quick, dt, () => 8);
}
quickStop(quick);
let quickStopAt = 0;
for (let i = 0; i < 120 && quick.phase !== 'none'; i += 1) {
    const event = stepReel(quick, dt, () => 8);
    quickStopAt += dt;
    if (event === 'stop') {
        break;
    }
}
assert.deepEqual(visibleIcons(quick), [7, 7, 7]);
assert.ok(quickStopAt < 0.4, `quick stop skips the rest of the wait (${quickStopAt})`);

const cell = restingReel({
    symbolNum: 1,
    symbolHeight: NATIVE.symbolHeight,
    scrollSpeed: NATIVE.scrollSpeed,
    minSymbols: CELL_SPIN.minSymbols,
    bounceDuration: CELL_SPIN.bounceDuration,
    bounceDistance: CELL_SPIN.bounceDistance,
    icons: [3],
}, () => 8);
spinReel(cell);
requestStop(cell, [4], 0);
const cellRun = run([cell], 2);
assert.equal(visibleIcons(cell)[0], 4);
assert.ok(cellRun.bounceAt[0][0] < bounce[0] - 0.3, 'a top-up cell stops after 5 symbols, not 15');
assert.ok(Math.abs((cellRun.stopAt[0][0] - cellRun.bounceAt[0][0]) - CELL_SPIN.bounceDuration) < dt + 0.001);

const freeMid = restingReel({
    symbolNum: 1,
    symbolHeight: NATIVE.reelHeight,
    scrollSpeed: NATIVE.scrollSpeed,
    minSymbols: 10,
    bounceDuration: NATIVE.bounceDuration,
    bounceDistance: NATIVE.bounceDistance,
    icons: [1],
}, () => 8);
spinReel(freeMid);
requestStop(freeMid, [5], FREE_STOP_DELAY[1]);
const freeRun = run([freeMid], 3);
assert.equal(visibleIcons(freeMid)[0], 5);
assert.ok(freeRun.bounceAt[0][0] > FREE_STOP_DELAY[1], 'the giant free reel waits 0.8s');
assert.ok(freeRun.bounceAt[0][0] < FREE_STOP_DELAY[1] + 0.7);

const flat = lineSegments([1, 1, 1, 1, 1]);
assert.deepEqual(flat.map((segment) => segment.kind), [0, 0, 0, 0, 0, 0]);
assert.ok(flat.every((segment) => segment.row === 2));
assert.deepEqual(lineSegments([0, 1, 2, 1, 0]).map((segment) => segment.kind), [0, 1, 1, -1, -1, 0]);

assert.equal(winTune(0, 100), null);
assert.equal(winTune(50, 100)?.clip, 'wintune03');
assert.equal(winTune(60, 100)?.clip, 'wintune04');
assert.equal(winTune(800, 100)?.clip, 'wintune12');
assert.equal(winTune(800, 100)?.fire, true);
assert.equal(winTune(800, 100)?.time, 1.5);
assert.equal(winTune(100000, 100)?.clip, 'wintune16');

const scatterPlan = presentPlan({ win: 0, bet: 100, scatters: 3, lines: [], chained: true });
assert.equal(scatterPlan.bell, true);
assert.equal(scatterPlan.animAt, 2);
assert.equal(scatterPlan.linesAt, 6);
assert.equal(scatterPlan.chainAt, scatterPlan.doneAt + 0.7);

const wildPlan = presentPlan({
    win: 800,
    bet: 100,
    scatters: 0,
    lines: [{ lineIndex: 1, cells: [{ icon: 1 }, { icon: 4 }, { icon: 4 }] }],
    chained: false,
});
assert.equal(wildPlan.linesAt, 2);
assert.equal(wildPlan.tune?.clip, 'wintune12');
assert.equal(wildPlan.chainAt, wildPlan.doneAt);

const columns = [
    [3, 8, 8],
    [8, 8, 8],
    [8, 8, 8],
    [8, 8, 8],
    [3, 8, 8],
];
const flags = lanternReels(columns);
assert.equal(flags[0], true);
assert.equal(flags[4], false);

const top = [4, 4, 4, 4, 4];
const filler = [2, 2, 2, 2, 2];
const hits = payHits([top, top, top, top, top].map((column, index) => {
    void index;
    return [4, 2, 2];
}));
assert.ok(hits.some((line) => line.lineIndex === 2 && line.cells.length === 5 && line.cells.every((cell) => cell.icon === 4)));
assert.equal(NEED_BLINK.has(8) && !NEED_BLINK.has(4), true);
assert.equal(LINE_BLINK, 0.5);
assert.equal(LINE_CYCLE, 2);
void filler;

const report = {
    bounce,
    stopped,
    stagger: bounce.slice(1).map((time, index) => Number((time - bounce[index]).toFixed(4))),
    quickStopAt: Number(quickStopAt.toFixed(4)),
    cellBounce: cellRun.bounceAt[0][0],
    cellStop: cellRun.stopAt[0][0],
    freeMidBounce: freeRun.bounceAt[0][0],
    scatterChain: scatterPlan.chainAt,
    wildLinesAt: wildPlan.linesAt,
};
console.log(JSON.stringify(report));
console.log('reel motion matches BaseReel');
