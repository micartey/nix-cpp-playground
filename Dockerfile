FROM debian:sid-slim AS build

RUN apt-get update && apt-get install -y --no-install-recommends \
    g++-14 \
    gcc-14 \
    make \
    cmake \
    meson \
    ninja-build \
    pkg-config \
    python3 \
    python3-pip \
    python3-venv \
    perl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-14 100 \
    && update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-14 100 \
    && update-alternatives --install /usr/bin/cc cc /usr/bin/gcc-14 100

RUN python3 -m venv /opt/conan && /opt/conan/bin/pip install conan
ENV PATH="/opt/conan/bin:${PATH}"

WORKDIR /src
COPY profiles/ profiles/
COPY conanfile.py meson.build ./

RUN conan install . --build=missing -pr:h profiles/docker -pr:b profiles/docker

COPY . .

RUN conan build . -pr:h profiles/docker -pr:b profiles/docker

FROM debian:sid-slim AS runtime

RUN apt-get update && apt-get install -y --no-install-recommends \
    libstdc++6 \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

COPY --from=build /src/build/main /usr/local/bin/main

EXPOSE 9080

CMD ["main"]
