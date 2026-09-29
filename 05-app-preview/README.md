# 05 — Full-stack app preview

An agent writes an app; the app needs to be *seen*. Run it in a sandbox and
share a real URL — no tunnels, no DNS, no deploy pipeline.

```bash
bash run.sh
```

Output ends with a live link like
`https://3000-sb-xxxx.<your sandbox domain>/` serving `app.js`.

## The two rules (both cost people time)

1. **Declare the port at create time** (`--port 3000`) — the public URL maps to
   that port: `https://<port>-<id>.<your sandbox domain>`. Port **8000** is already
   used by the sandbox's built-in terminal, so give your app its own port.
2. **Previews are private by default.** Without `--public` the URL returns a
   "Private sandbox" page (403) unless the request carries the access token.
   `--public` makes it tokenless and shareable.

## Doing this from the SDK

The SDK creates the sandbox and starts the server the same way:

```python
sb = Sandbox.create(template="node-20", ports=[3000], timeout=900)
sb.upload("./app.js", "app.js")
sb.run("nohup env PORT=3000 node app.js > app.log 2>&1 &")
print(sb.url)
```

Note: `pilldrops` **1.0.0** (PyPI) has no `public=` argument, so SDK-created
previews stay private — reach them with the token, or create with `--public`
from the CLI / `"public": true` on `POST /v1/sandboxes`.

Full guide: `/guides/app-preview` on your PillDrops server
