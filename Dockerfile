FROM rust:slim-buster AS builder

RUN sed -i '/buster-updates/d' /etc/apt/sources.list && \
    sed -i 's|http://deb.debian.org|http://archive.debian.org|g' /etc/apt/sources.list && \
    sed -i 's|http://security.debian.org|http://archive.debian.org|g' /etc/apt/sources.list && \
    echo 'Acquire::Check-Valid-Until "false";' > /etc/apt/apt.conf.d/99no-check-valid-until && \
    apt-get update && apt-get install --no-install-recommends -y perl make && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /opt/omnisette-server/

COPY Cargo.* ./

COPY src ./src

ENV CARGO_REGISTRIES_CRATES_IO_PROTOCOL=sparse

RUN cargo build --release


FROM debian:stable-slim AS runtime

RUN apt-get update && apt-get install --no-install-recommends -y unzip curl ca-certificates && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /opt/omnisette-server/

COPY docker-entrypoint.sh ./

COPY --from=builder /opt/omnisette-server/target/release/omnisette-server ./

ENTRYPOINT [ "./docker-entrypoint.sh" ]
