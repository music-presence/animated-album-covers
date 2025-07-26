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

You should modify these values
depending on how much load your server can handle:

|Variable|Explanation|
|-|-|
|CONVERSION_JOB_CONCURRENCY|Controls how many simultaneous `ffmpeg` instances are allowed to run at the same time. This shouldn't exceed your CPU count. Currently Discord does not support streaming of GIFs, so GIF conversion has to be done as fast as possible, which means a single `ffmpeg` instance will use any resources it has available|
|CONVERSION_FFMPEG_THREADS|Controls how many threads a single ffmpeg instance may use. This can slightly improve conversion speed, although the impact is not very big due to GIF conversion being mostly single-threaded in nature|

You can optionally modify these values:

|Variable|Explanation|
|-|-|
|DEBUG|If you wanna reduce log clutter, you can set this to 0. The information added by enabling debug loggin will help in diagnosing any issues though, should they come up|

You can leave the rest of the values unchanged.

If you like, you can decrease `TOKEN_TTL_RESOLUTION` to reduce RAM usage over time.
But this will increase CPU usage, due to the shorter caching duration.

Now modify `redis.conf`, if needed:

- You can increase `maxmemory 512mb` if you like. Technically the server needs far less than 512 MB of memory due to load balancing and the fact that only the resuling GIF is cache, which is very small in size
- Persistence is disabled and shouldn't need to be enabled

The only values that might need changing in the future are `MAXIMUM_OUTPUT_SIZE` and `MAXIMUM_OUTPUT_FRAMERATE`, which limit how large the result GIF may be. To save on resources and since the little cover image on Discord isn't very large, these values are small.

Now you can start all services:

```
$ docker compose up -d --build
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

## Contribute your server instance to Music Presence

You can help spread the load of converting animated video covers to GIFs
by sharing the following information with me:

- The value for SERVER_BASE_URL
- The value for TOKEN_AUTH_USERNAME
- The value for TOKEN_AUTH_PASSWORD
- The value for METRICS_AUTH_USERNAME
- The original password you use to generate METRICS_AUTH_PASSWORD_BCRYPT

The last two are option, but help me keep an eye on your conversion service instance.
I'll let you know if e.g. Redis hits its memory limit
or individual conversions take too long.

Thank you for contributing your server and adding redundancy!

## Effective load balancing

Your server won't be hit with all video conversions.
Video conversion requests are spread across all available server instances
and are hashed using the video URL that is being converted.
That means the same server always converts the same subset of URLs,
evenly distributed across servers.
This ensures that when a cached conversion result is available,
it is always used, instead of converting it again on another server.

## What endpoints does the server expose?

The server exposes the following endpoints:

- `/token`: This endpoint is used to generated tokens for the /convert endpoint. It takes a number of query parameters, including the URL to the original video and returns a token and a full URL to the /convert endpoint. Requests to this URL already start the conversion of the video in the background, to speed up the response time of the /convert endpoint
- `/convert`: Requests to this endpoint will stream the conversion result in real-time, even while the conversion is in progress. Conversion is only done once and cache for the duration specified by the `CONVERSION_RESULT_TTL` environment variable
- `/metrics/video`: This endpoint exposes Prometheus metrics for the video conversion server with statistics about the number of requests made to each endpoint and how long these requests took. It's authenticated with the metrics auth environment variables
- `/metrics/cache`: This endpoint exposes Prometheus metrics for the Redis cache with statistics about the number of active cache entries. It's authenticated with the metrics auth environment variables

Feel free to roll your own Prometheus/Grafana dashboards to keep an eye on your server! These are exposed together with the video conversion service, so that it's possible for me to see that load balancing between multiple instances works correctly.

## Appendix

### Automatically provisioning a TLS certificate

TODO

---
