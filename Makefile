SCRIPTS_DIR ?= ./scripts

.PHONY: deploy
deploy:
	@echo "---> Deploying"
	$(SCRIPTS_DIR)/deploy.sh
