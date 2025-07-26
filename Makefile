.PHONY: all

all:

# reload the Caddyfile of the running service without downtime
# depending on your server, you likely have to execute this with sudo
reload:
	docker compose exec -w /etc/caddy http caddy reload

# run this to create a bcrypt hash for a password, for use with Caddy
credentials:
	@caddy hash-password
