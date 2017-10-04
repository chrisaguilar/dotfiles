#!/usr/bin/env node

const { get } = require('https');

const api_key = 'cb254703b9d67fbf04cae66e496e1aaa';
const [lat, lon] = ['33.60', '-84.37'];
const URL = `https://api.darksky.net/forecast/${api_key}/${lat},${lon}`;

function main() {
    get(URL, res => {
        let data = '';
        res.on('data', chunk => (data += chunk));
        res.on('end', () => {
            const weather = JSON.parse(data).currently;
            const t = parseInt(weather.temperature, 10);
            const c = weather.summary;
            console.log(`${t}°F`);
        });
    }).on('error', e => setTimeout(main, 1000));
}

main();
