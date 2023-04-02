build:
	docker compose build --progress=plain


deploy: build
	docker compose up
