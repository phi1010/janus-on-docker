# janus-on-docker

Janus WebRTC server (Ubuntu 26.04 `janus` package) with the VideoRoom plugin, built
with buildah and published to GHCR by the workflow in `.github/workflows`.

    podman pull ghcr.io/OWNER/janus-on-docker:latest
    podman run --rm --network host ghcr.io/OWNER/janus-on-docker:latest
    # or: podman compose up -d

Ports: 8088 (HTTP REST), 8188 (WebSocket), 20000-20100/udp (RTP).

## VideoRoom

No rooms are provisioned. Any client may `create` a room with any string
name and then `join` it (`string_ids = true`). `require_pvtid` and
`notify_joining` are per-room options with no server-side default, so
the client sets them when creating the room:

    {"request": "create", "room": "any-name", "require_pvtid": true, "notify_joining": true}

If the room already exists the create fails with error 427; just join it.
Janus' HTTP transport sends `Access-Control-Allow-Origin: *`, so a page
hosted on another URL can use the REST API (WebSockets have no CORS).

Local build:

    buildah build -t janus-on-docker .
