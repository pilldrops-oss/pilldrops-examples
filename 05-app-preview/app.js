// Runs INSIDE the sandbox. The one rule for preview URLs: bind the injected
// $PORT. Hardcoding a port is the #1 reason a preview returns 502.
const http = require('http');

const port = process.env.PORT || 3000;

http.createServer((req, res) => {
  res.writeHead(200, { 'Content-Type': 'text/html; charset=utf-8' });
  res.end(`<!doctype html>
<title>Hello from a PillDrops sandbox</title>
<style>body{font-family:ui-monospace,monospace;background:#131210;color:#f4f1e8;
display:grid;place-items:center;height:100vh;margin:0;text-align:center}
b{color:#35c98a}</style>
<h1>It's <b>alive</b>.</h1>
<p>Served from a disposable microVM on port ${port}.</p>
<p>${new Date().toISOString()}</p>`);
}).listen(port, '0.0.0.0', () => console.log(`listening on ${port}`));
