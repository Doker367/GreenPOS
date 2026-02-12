# Dockerfile para Soft Restaurant
FROM ubuntu:22.04

# Evitar prompts interactivos
ENV DEBIAN_FRONTEND=noninteractive

# Instalar dependencias
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    xz-utils \
    zip \
    libglu1-mesa \
    clang \
    cmake \
    ninja-build \
    pkg-config \
    libgtk-3-dev \
    && rm -rf /var/lib/apt/lists/*

# Descargar Flutter
RUN cd /opt && \
    curl -L https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.27.1-stable.tar.xz -o flutter.tar.xz && \
    tar xf flutter.tar.xz && \
    rm flutter.tar.xz

# Configurar PATH
ENV PATH="/opt/flutter/bin:${PATH}"

# Pre-download Flutter artifacts
RUN flutter doctor -v
RUN flutter precache

# Directorio de trabajo
WORKDIR /app

# Copiar archivos del proyecto
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

COPY . .

# Exponer puerto para web
EXPOSE 8080

# Comando por defecto
CMD ["flutter", "run", "-d", "web-server", "--web-port=8080", "--web-hostname=0.0.0.0"]
