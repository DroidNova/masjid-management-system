FROM ghcr.io/cirruslabs/flutter:stable AS build
WORKDIR /app
# APP_ENV picks env/<APP_ENV>.json (dev | staging | prod).
# API_BASE_URL, when set, overrides the URL in that file.
ARG APP_ENV=dev
ARG API_BASE_URL=
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get
COPY . .
RUN if [ -n "$API_BASE_URL" ]; then \
      flutter build web --release --no-wasm-dry-run \
        --dart-define-from-file=env/${APP_ENV}.json \
        --dart-define=API_BASE_URL=${API_BASE_URL}; \
    else \
      flutter build web --release --no-wasm-dry-run \
        --dart-define-from-file=env/${APP_ENV}.json; \
    fi

FROM nginx:1.27-alpine AS runtime
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/build/web /usr/share/nginx/html
EXPOSE 80
HEALTHCHECK --interval=30s --timeout=5s --retries=5 CMD wget -qO- http://localhost/health >/dev/null 2>&1 || exit 1
