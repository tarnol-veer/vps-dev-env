.PHONY: bootstrap install healthcheck update

bootstrap:
	sudo bash ./bootstrap.sh

install:
	bash ./install.sh

healthcheck:
	bash ./scripts/healthcheck.sh

update:
	sudo bash ./scripts/update-system.sh
