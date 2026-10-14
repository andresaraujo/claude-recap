// Renders scene.html frame by frame (virtual clock, so timing is exact) and merges it with recap.wav
// → out/demo.mp4 + out/poster.png. Usage: node make.mjs (expects recap.wav + recap.txt from make.sh)
import { execFileSync } from 'node:child_process';
import { mkdirSync, readFileSync, rmSync } from 'node:fs';
import { resolve } from 'node:path';
import { pathToFileURL } from 'node:url';
import { chromium } from 'playwright';

const AUDIO_AT = 3; // seconds into the video where the recap starts
const FPS = 30;
const sh = (cmd, args) => execFileSync(cmd, args, { stdio: ['ignore', 'pipe', 'inherit'] }).toString().trim();
const audioLen = Number(sh('ffprobe', ['-v', 'error', '-show_entries', 'format=duration', '-of', 'csv=p=0', 'recap.wav']));
const total = AUDIO_AT + audioLen + 1.5; // ends on the last words, no end card

const url = new URL(pathToFileURL(resolve('scene.html')));
url.search = new URLSearchParams({ audioAt: AUDIO_AT, audioLen, script: readFileSync('recap.txt', 'utf8').trim() }).toString();

const browser = await chromium.launch({ channel: 'chrome' }); // system Chrome; no Playwright browser download
const page = await browser.newPage({ viewport: { width: 1280, height: 720 } });
await page.goto(url.href);
await page.evaluate(() => document.fonts.ready);
rmSync('out/frames', { recursive: true, force: true });
mkdirSync('out/frames', { recursive: true });
const frames = Math.ceil(total * FPS);
for (let i = 0; i < frames; i++) {
	await page.evaluate((t) => window.seek(t), i / FPS);
	await page.screenshot({ path: `out/frames/${String(i).padStart(5, '0')}.jpg`, type: 'jpeg', quality: 92 });
}
await browser.close();

// Frames + audio (delayed to AUDIO_AT) → H.264 + AAC, yuv420p: plays on X, LinkedIn, GitHub.
sh('ffmpeg', ['-y', '-v', 'error', '-framerate', String(FPS), '-i', 'out/frames/%05d.jpg', '-i', 'recap.wav',
	'-filter_complex', `[1:a]adelay=${AUDIO_AT * 1000}:all=1,apad[a]`, '-map', '0:v', '-map', '[a]', '-t', String(total),
	'-c:v', 'libx264', '-pix_fmt', 'yuv420p', '-crf', '20', '-c:a', 'aac', '-b:a', '128k', '-movflags', '+faststart', 'out/demo.mp4']);
// Poster for the README: a frame mid-recap (status line playing, subtitle on).
sh('ffmpeg', ['-y', '-v', 'error', '-ss', String(AUDIO_AT + 4), '-i', 'out/demo.mp4', '-frames:v', '1', 'out/poster.png']);
rmSync('out/frames', { recursive: true, force: true });
console.log(`out/demo.mp4 (${total.toFixed(1)}s, ${frames} frames) + out/poster.png`);
