.PHONY: setup validate clean

SHELL := /bin/bash

# Hook files
HOOK_FILES := commit-msg pre-commit pre-push
HOOK_DIR := .githooks
GIT_HOOK_DIR := .git/hooks
SHA_FILE := .githooks/.sha256

setup: ## Install git hooks (updates if SHA changed)
	@echo "Checking git hooks..."
	@mkdir -p "$(GIT_HOOK_DIR)"
	@CURRENT_SHA=$$(cat "$(SHA_FILE)" 2>/dev/null || echo "none"); \
	NEW_SHA=$$(find "$(HOOK_DIR)" -name "*.sh" -o -name "commit-msg" -o -name "pre-commit" -o -name "pre-push" | sort | xargs sha256sum | sha256sum | cut -d' ' -f1); \
	if [ "$$CURRENT_SHA" != "$$NEW_SHA" ]; then \
		echo "Updating git hooks (SHA changed)..."; \
		for hook in $(HOOK_FILES); do \
			if [ -f "$(HOOK_DIR)/$$hook" ]; then \
				cp "$(HOOK_DIR)/$$hook" "$(GIT_HOOK_DIR)/$$hook"; \
				chmod +x "$(GIT_HOOK_DIR)/$$hook"; \
				echo "  Installed: $$hook"; \
			fi \
		done; \
		echo "$$NEW_SHA" > "$(SHA_FILE)"; \
		echo "Git hooks updated successfully."; \
	else \
		echo "Git hooks are up to date."; \
	fi

validate: ## Validate hook files
	@echo "Validating hook files..."
	@for hook in $(HOOK_FILES); do \
		if [ -f "$(HOOK_DIR)/$$hook" ]; then \
			echo "  ✓ $$hook"; \
		else \
			echo "  ✗ $$hook (missing)"; \
			exit 1; \
		fi \
	done
	@echo "All hook files validated."

clean: ## Remove installed git hooks
	@echo "Removing git hooks..."
	@for hook in $(HOOK_FILES); do \
		if [ -f "$(GIT_HOOK_DIR)/$$hook" ]; then \
			rm "$(GIT_HOOK_DIR)/$$hook"; \
			echo "  Removed: $$hook"; \
		fi \
	done
	@rm -f "$(SHA_FILE)"
	@echo "Git hooks removed."