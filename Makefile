.PHONY: bootstrap install plan apply doctor healthcheck update

bootstrap:
	sudo bash ./bootstrap.sh

install:
	bash ./install.sh

plan:
	bash ./bin/ade plan

apply:
	sudo bash ./bin/ade apply

doctor:
	bash ./bin/ade doctor

healthcheck:
	bash ./scripts/healthcheck.sh

update:
	sudo bash ./scripts/update-system.sh
