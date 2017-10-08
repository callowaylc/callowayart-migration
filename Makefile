SECRETS ?= s3://callowayart/secrets/migration
ARTIFACT_WORDPRESS ?= s3://callowayart/artifacts/migration/wordpress.tgz
ARTIFACT_SQL ?= s3://callowayart/artifacts/migration/wordpress.sql.tgz
ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))

-include .secrets

.PHONY: build
all:
	@ mkdir -p ./build
	@ aws s3 cp $(SECRETS) ./.secrets
	@ aws s3 cp $(ARTIFACT_WORDPRESS) ./build
	@ aws s3 cp $(ARTIFACT_SQL) ./build
	@ tar -xvzf ./build/wordpress.tgz -C ./build
	@ tar -xvzf ./build/wordpress.sql.tgz -C ./build

.PHONY: build
build:
	@ mysqldump \
	  -C \
    -u $(DB_USER) \
    -h $(DB_HOST) \
    -p$(DB_PASS) \
    	--add-drop-table \
    	--quote-names \
    		wordpress_callowayart \
      2>/dev/null > ./build/callowayart.sql

.PHONY: release
release:

# IMPORTANT - ensures arguments are not interpreted as make targets
%:
	@:
