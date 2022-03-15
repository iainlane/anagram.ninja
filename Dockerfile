FROM debian:bullseye-slim AS build


RUN apt update
RUN apt install -y curl git unzip xz-utils

RUN git clone --depth=1 --verbose https://github.com/flutter/flutter.git /flutter

ENV PATH="/flutter/bin:/flutter/bin/cache/dart-sdk/bin:${PATH}"

RUN flutter doctor -v
RUN flutter channel master
RUN flutter upgrade
RUN flutter config --enable-web

RUN mkdir /build/
COPY . /build/
WORKDIR /build/
RUN flutter build web

FROM nginx:1.21.6-alpine
COPY --from=build /build/build/web /usr/share/nginx/html
