.PHONY: build
build:
	nix-build

shards.nix: shard.lock
	crystal2nix

shard.lock: shard.yml
	shards install || shards update
