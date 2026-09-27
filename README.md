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

## Kubernetes / Argo CD

`deploy/k8s` holds a kustomize base (namespace, hostNetwork Deployment,
Service). `deploy/argocd/application.yaml` is an Argo CD Application that
syncs it from this repo:

    kubectl apply -f deploy/argocd/application.yaml

The GHCR package must be public, or add an `imagePullSecrets` entry to the
Deployment.

The Ingress (nginx ingress class) serves `janus.qube.local.phi1010.com` with a
Let's Encrypt certificate from cert-manager (`ClusterIssuer/letsencrypt`, set
your email in `deploy/k8s/clusterissuer.yaml` or drop it if one exists):

    REST:      https://janus.qube.local.phi1010.com/janus
    WebSocket: wss://janus.qube.local.phi1010.com/ws

TLS ends at the ingress; Janus itself stays plain HTTP/WS on the node.
