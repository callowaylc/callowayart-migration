export PORT ?= 80
export PROJECT ?= callowayart
export REPOSITORY ?= callowaylc/$(PROJECT)
export DOMAIN ?= migrated.callowayart.com

SECRETS ?= s3://callowayart/secrets/migration
ARTIFACT_WORDPRESS ?= s3://callowayart/artifacts/migration/wordpress.tgz
ARTIFACT_SQL ?= s3://callowayart/artifacts/migration/wordpress.sql.tgz
ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))

-include .secrets

.PHONY: build
all:
	@ rm -rf ./build && mkdir -p ./build
	@ aws s3 cp $(SECRETS) ./.secrets
	@ aws s3 cp $(ARTIFACT_WORDPRESS) ./build
	@ aws s3 cp $(ARTIFACT_SQL) ./build
	@ tar -xvzf ./build/wordpress.tgz -C ./build
	@ tar -xvzf ./build/wordpress.sql.tgz -C ./build
	@ cp -rf ./src/var/www/html/* ./build/wordpress/

.PHONY: login
login:
	docker login -u$(DOCKER_USERNAME) -p$(DOCKER_PASSWORD)

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

	@ docker-compose build bootstrap
	@ docker-compose run bootstrap
	@ docker-compose build callowayart

.PHONY: release
release:
	@ docker-compose up -d --remove-orphans callowayart

.PHONY: tag
tag:
	@ docker tag $(REPOSITORY):latest $(REPOSITORY):`git rev-parse --short HEAD`

.PHONY: publish
publish:
	@ docker push $(REPOSITORY)

.PHONY: clean
clean:
	@ docker-compose down -v --remove-orphans

.PHONY: deploy
deploy:
	@ rsync \
			-avz \
			-e ssh \
			--delete \
			--progress \
			--exclude ".git" \
			--exclude "*.tgz" \
			--exclude "*.gz" \
				. sandbox:~/work/callowaylc/$(PROJECT)

# IMPORTANT - ensures arguments are not interpreted as make targets
%:
	@:
