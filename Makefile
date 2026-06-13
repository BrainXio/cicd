.PHONY: setup validate clean

SHELL := /bin/bash

setup: ## Install git hooks
	@if [ ! -e .git/hooks/commit-msg ]; then \
			echo "Installing git hooks..."; \
			cp .githooks/commit-msg .git/hooks/commit-msg && \
			cp .githooks/pre-commit .git/hooks/pre-commit && \
			cp .githooks/pre-push .git/hooks/pre-push && \
			chmod +x .git/hooks/commit-msg .git/hooks/pre-commit .git/hooks/pre-push; \
		else \
			echo "Git hooks already installed."; \
	fi
