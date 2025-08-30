
# ==================================================================================== #
# HELPERS
# ==================================================================================== #

## help: print this help message
.PHONY: help
help:
	@echo 'Usage:'
	@sed -n 's/^##//p' ${MAKEFILE_LIST} | column -t -s ':' |  sed -e 's/^/ /'

.PHONY: confirm
confirm:
	@echo -n 'Are you sure? [y/N] ' && read ans && [ $${ans:-N} = y ]

## run/api: run the cmd/api application
.PHONY: run/api
run/api: assets/build
	go run ./cmd/api

## dev: run the application in development mode with file watching
.PHONY: dev
dev: assets/build
	@echo 'Starting development server...'
	@trap 'kill %1; kill %2' INT; \
	make css/watch & \
	air &  \
	wait

## assets/build: build all static assets
.PHONY: assets/build
assets/build: css/build
	@echo 'Static assets built successfully'

# ==================================================================================== #
# CSS/TAILWIND & STATIC ASSETS
# ==================================================================================== #
## css/install: install Tailwind CSS
.PHONY: assets/install
assets/install:
	@echo 'Installing Tailwind CSS...'
	npm install -D tailwindcss
	npx tailwindcss init
	@echo 'Downloading htmx...'
	@mkdir -p ./internal/static/js
	curl -o ./internal/static/js/htmx.min.js https://unpkg.com/htmx.org@1.9.12/dist/htmx.min.js


## css/build: build CSS from Tailwind
.PHONY: css/build
css/build:
	@echo 'Building CSS...'
	@mkdir -p ./internal/static/css
	npx tailwindcss -i ./assets/css/input.css -o ./internal/static/css/styles.css --minify

## css/watch: watch and rebuild CSS on changes
.PHONY: css/watch
css/watch:
	@echo 'Watching CSS files...'
	npx tailwindcss -i ./assets/css/input.css -o ./internal/static/css/styles.css --watch

## htmx/update: download latest htmx
.PHONY: htmx/update
htmx/update:
	@echo 'Updating htmx...'
	@mkdir -p internal/static/js
	curl -o internal/static/js/htmx.min.js https://unpkg.com/htmx.org@1.9.12/dist/htmx.min.js



# ==================================================================================== #
# QUALITY CONTROL
# ==================================================================================== #

## tidy: format all .go files and tidy module dependencies
.PHONY: tidy
tidy:
	@echo 'Formatting .go files...'
	go fmt ./...
	@echo 'Tidying module dependencies...'
	go mod tidy

## audit: run quality control checks
.PHONY: audit
audit:
	@echo 'Checking module dependencies'
	go mod tidy -diff
	go mod verify
	@echo 'Vetting code...'
	go vet ./...
	staticcheck ./...
	@echo 'Running tests...'
	go test -race -vet=off ./...

# ==================================================================================== #
# BUILD
# ==================================================================================== #

## build/api: build the cmd/api application
.PHONY: build/api
build/api: templ/generate assets/build
	@echo 'Building cmd/api...'
	go build -ldflags='-s' -o=./bin/api ./cmd/api

.PHONY: templ/generate
templ/generate:
	@echo 'Generating templ templates...'
	templ generate

# ==================================================================================== #
# CLEAN
# ==================================================================================== #
## clean: remove build artifacts and generated files
.PHONY: clean
clean:
	@echo 'Cleaning build artifacts...'
	rm -rf ./bin
	rm -rf ./internal/static/css
	rm -rf ./internal/static/js
	rm -rf ./node_modules

## clean/css: remove generated CSS files
.PHONY: clean/css
clean/css:
	@echo 'Cleaning CSS files...'
	rm -rf ./internal/static/css

## clean/js: remove downloaded JS files
.PHONY: clean/js
clean/js:
	@echo 'Cleaning JS files...'
	rm -rf ./internal/static/js