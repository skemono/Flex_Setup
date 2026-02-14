# Dockerfile para construir Flex desde código fuente
# https://github.com/westes/flex

FROM ubuntu:22.04

# Evitar prompts interactivos durante instalación de paquetes
ENV DEBIAN_FRONTEND=noninteractive

# Instalar dependencias de compilación
# Nota: flex es necesario para bootstrap al compilar desde fuente
RUN apt-get update && apt-get install -y \
    git \
    build-essential \
    autoconf \
    automake \
    libtool \
    m4 \
    bison \
    flex \
    gettext \
    autopoint \
    texinfo \
    help2man \
    && rm -rf /var/lib/apt/lists/*

# Clonar el repositorio de flex
WORKDIR /opt
RUN git clone https://github.com/westes/flex.git

# Compilar flex desde fuente
# Nota: NO usar make paralelo (-j) - causa condiciones de carrera durante bootstrap
WORKDIR /opt/flex
RUN ./autogen.sh \
    && ./configure --prefix=/usr/local \
    && make \
    && make install

# Verificar instalación
RUN flex --version

# Configurar directorio de trabajo para archivos del usuario
WORKDIR /workspace

# Mantener contenedor ejecutándose para uso interactivo
CMD ["sleep", "infinity"]