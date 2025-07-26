# animated-album-covers

This repository contains Docker Compose service definitions
to deploy a video conversion service to convert animated album covers to GIF.
You can deploy this on your own by following the instructions in this document.

## Setup

This setup assumes you are ready to expose an HTTP server via HTTPS,
meaning you bring your own TLS certificate.
If you need automatic provisioning of a certificate,
read the appendix.

In addition to that, you need to have Docker installed and ready for use.

To begin, clone the repository:

```
$ git clone https://github.com/music-presence/animated-album-covers
$ cd animated-album-covers
```

Copy and modify the example `.env` file:

```
$ cp .env.example .env
```

You must modify the following values:

|Variable|Explanation|
|-|-|
|SERVER_BASE_URL|A URL with scheme, hostname and optionally a path that points to the HTTP  server that is exposed by the `http` service in the `docker-compose.yaml` file. An example would be `https://api.example.com`. This value is the base URL that is used by the video conversion service and requests to it must resolve to your server|
|TOKEN_AUTH_USERNAME|Choose an arbitrary user name|
|TOKEN_AUTH_PASSWORD|Choose a secure password, e.g. by generating it using OpenSSL: `$ openssl rand -hex 16`|
|METRICS_AUTH_USERNAME|Choose an arbitrary user name|
|METRICS_AUTH_PASSWORD_BCRYPT|Choose a secure password. This must contain a bcrypt hash. You can generate it for your password with `$ make credentials` and pasting the password twice. Make sure to keep note of the password|

You can optionally modify these values:

|Variable|Explanation|
|-|-|
|CONVERSION_JOB_CONCURRENCY|Controls how many simultaneous `ffmpeg` instances are allowed to run at the same time. This shouldn't exceed your CPU count. Currently Discord does not support streaming of GIFs, so GIF conversion has to be done as fast as possible, which means a single `ffmpeg` instance will use any resources it has available|
|DEBUG|If you wanna reduce log clutter, you can set this to 0. The information added by enabling debug loggin will help in diagnosing any issues though, should they come up|

You can leave the rest of the values unchanged.

The only values that might need changing in the future are `MAXIMUM_OUTPUT_SIZE` and `MAXIMUM_OUTPUT_FRAMERATE`, which limit how large the result GIF may be. To save on resources and since the little cover image on Discord isn't very large, these values are small.

Now you can start all services:

```
$ docker compose up -d
```

Check the logs to see that everything's working:

```
$ docker compose logs --follow
```

You should see a line like this after the initial startup logs:

```
video-1  | [2025-07-26 15:03:22.110] INFO: Server listening at http://127.0.0.1:80
```

Now make sure that the server is accessible to the public
under the base URL you specified in `SERVER_BASE_URL`.

Done!

## Appendix

### Automatically provisioning a TLS certificate

TODO

---
