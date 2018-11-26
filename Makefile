export PORT ?= 80
export PROJECT ?= callowayart
export REPOSITORY ?= callowaylc/$(PROJECT)
export DOMAIN ?= migrated.callowayart.com
export MIGRATION_LIMIT ?= 50

SECRETS ?= s3://callowayart/secrets/migration
ARTIFACT_WORDPRESS ?= s3://callowayart/artifacts/migration/wordpress.tgz
ARTIFACT_SQL ?= s3://callowayart/artifacts/migration/wordpress.sql.tgz
ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))

-include .secrets

.PHONY: all build login release tag publish clean deploy
all:
	@ rm -rf ./build && mkdir -p ./build
	@ aws s3 cp $(SECRETS) ./.secrets
	@ aws s3 cp $(ARTIFACT_WORDPRESS) ./build
	@ aws s3 cp $(ARTIFACT_SQL) ./build
	@ tar -xvzf ./build/wordpress.tgz -C ./build
	@ tar -xvzf ./build/wordpress.sql.tgz -C ./build

login:
	docker login -u$(DOCKER_USERNAME) -p$(DOCKER_PASSWORD)

build:
	cp -rf ./src/var/www/html/* ./build/wordpress/
	mysqldump \
	  -C \
    -u $(DB_USER) \
    -h $(DB_HOST) \
    -p$(DB_PASS) \
    	--add-drop-table \
    	--quote-names \
    	--column-statistics=0 \
    		wordpress_callowayart \
      		> ./build/callowayart.sql

	docker-compose build bootstrap
	docker-compose build callowayart

release:
	- docker rm -f bootstrap
	docker-compose up -d --remove-orphans --force-recreate callowayart
	- docker-compose run -d --rm --name bootstrap bootstrap

	docker-compose exec callowayart bash -c "chmod -R ugo+rwx /var/www/html/wp-content"

bootstrap:
	- docker rm -f bootstrap
	docker-compose build bootstrap
	docker-compose run -d --rm --name bootstrap bootstrap

tag:
	@ docker tag $(REPOSITORY):latest $(REPOSITORY):`git rev-parse --short HEAD`

publish:
	@ docker push $(REPOSITORY)

clean:
	@ docker-compose down -v --remove-orphans

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
