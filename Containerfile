FROM ubuntu:26.04

RUN apt-get update && \
    apt-get install -y --no-install-recommends janus && \
    rm -rf /var/lib/apt/lists/*

# Replace the package's default configs with ours (see ./janus/etc/janus).
RUN rm -f /etc/janus/*.jcfg
COPY janus/etc/janus/ /etc/janus/

# 8088 = HTTP/REST API (Janus sends CORS headers), 8188 = WebSocket API,
# 20000-20100/udp = RTP media
EXPOSE 8088 8188 20000-20100/udp

CMD ["janus"]
