# Simple4D Makefile
# Build and deploy macOS menu bar app

APP_NAME = Simple4D
PROJECT_DIR = macos-menubar/Simple4D
PROJECT_FILE = $(PROJECT_DIR)/Simple4D.xcodeproj
SCHEME = Simple4D
CONFIGURATION = Release
DESKTOP_PATH = ~/Desktop

.PHONY: all build clean install deploy help debug

# Default target
all: help

# Helper function to get build path
define get_app_path
	cd $(PROJECT_DIR) && xcodebuild -project Simple4D.xcodeproj -scheme $(SCHEME) -configuration $(CONFIGURATION) -showBuildSettings | grep "BUILT_PRODUCTS_DIR" | head -1 | sed 's/.*= //'
endef

# Build the app
build:
	@echo "Building $(APP_NAME)..."
	cd $(PROJECT_DIR) && xcodebuild -project Simple4D.xcodeproj -scheme $(SCHEME) -configuration $(CONFIGURATION) build

# Clean build artifacts
clean:
	@echo "Cleaning build artifacts..."
	cd $(PROJECT_DIR) && xcodebuild -project Simple4D.xcodeproj -scheme $(SCHEME) clean
	@if [ -d "$(PROJECT_DIR)/build/" ]; then rm -rf $(PROJECT_DIR)/build/; fi
	@echo "Clean completed"

# Install app to desktop
install: build
	@echo "Installing $(APP_NAME) to desktop..."
	@BUILT_PRODUCTS_DIR=$$($(call get_app_path)); \
	if [ -z "$$BUILT_PRODUCTS_DIR" ]; then \
		echo "Error: Could not determine build products directory"; \
		exit 1; \
	fi; \
	APP_PATH="$$BUILT_PRODUCTS_DIR/$(APP_NAME).app"; \
	echo "Looking for app at: $$APP_PATH"; \
	if [ -f "$$APP_PATH/Contents/MacOS/$(APP_NAME)" ]; then \
		cp -R "$$APP_PATH" $(DESKTOP_PATH)/ && echo "Successfully installed $(APP_NAME).app to desktop"; \
	else \
		echo "Error: Built app not found at $$APP_PATH"; \
		echo "Contents of $$BUILT_PRODUCTS_DIR:"; \
		ls -la "$$BUILT_PRODUCTS_DIR" 2>/dev/null || echo "Directory does not exist"; \
		exit 1; \
	fi

# Build and install in one step
deploy: install
	@echo "$(APP_NAME) built and deployed to desktop successfully!"

# Debug - show resolved paths
debug:
	@echo "Debug information for $(APP_NAME):"
	@echo "PROJECT_DIR: $(PROJECT_DIR)"
	@echo "SCHEME: $(SCHEME)"
	@echo "CONFIGURATION: $(CONFIGURATION)"
	@BUILT_PRODUCTS_DIR=$$($(call get_app_path)); \
	echo "BUILT_PRODUCTS_DIR: $$BUILT_PRODUCTS_DIR"; \
	if [ -n "$$BUILT_PRODUCTS_DIR" ]; then \
		APP_PATH="$$BUILT_PRODUCTS_DIR/$(APP_NAME).app"; \
		echo "APP_PATH: $$APP_PATH"; \
		if [ -d "$$APP_PATH" ]; then \
			echo "App exists: YES"; \
			echo "App contents:"; \
			ls -la "$$APP_PATH/Contents/" 2>/dev/null || echo "No Contents directory"; \
		else \
			echo "App exists: NO"; \
		fi; \
	fi

# Show help
help:
	@echo "Simple4D Build Commands:"
	@echo "  make build    - Build the app"
	@echo "  make install  - Build and copy app to desktop"
	@echo "  make deploy   - Build and install (alias for install)"
	@echo "  make clean    - Clean build artifacts"
	@echo "  make debug    - Show resolved paths for troubleshooting"
	@echo "  make help     - Show this help message"
