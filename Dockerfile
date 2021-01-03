FROM golang:1.15.6 AS builder


ENV \
    CGO_ENABLED=0 \
    GOPROXY=https://goproxy.cn,direct

WORKDIR /app
COPY . .

RUN go build -o bilibili




FROM ggdream/ffmpeg

WORKDIR /data
COPY --from=builder /app/bilibili /usr/bin/

ENTRYPOINT ["bilibili", "-a"]
CMD ["--help"]