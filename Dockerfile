# Tested on fedora:23
FROM fedora:23

#Before installing gcc 4.8.5, install the build pre-requisites
RUN dnf groupinstall -y "Development tools"                                         \
    && dnf install -y                                                               \ 
        tar                                                                         \
        bzip2                                                                       \
        glibc-devel                                                                 \
        glibc                                                                       \
        glibc-devel.i686                                                            \
        glibc.i686                                                                  \
        gcc-c++                                                                     \
        m4                                                                          \
        zlib                                                                        \
        zlib-devel                                                                  \
        libuuid                                                                     \
        libuuid-devel                                                               \
    && dnf clean all

#Download, build and install gcc pre-requisites
RUN curl -o- https://gmplib.org/download/gmp/gmp-5.1.3.tar.bz2 -P /tmp              \
        | tar -jxf - -C /tmp                                                        \
    && cd /tmp/gmp-5.1.3/                                                           \
    && ./configure                                                                  \
    && make                                                                         \
    && make install

RUN curl -o- https://www.mpfr.org/mpfr-3.1.2/mpfr-3.1.2.tar.bz2                     \
        | tar -jxf - -C /tmp                                                        \
    && cd /tmp/mpfr-3.1.2                                                           \
    && ./configure                                                                  \ 
        --with-gmp=/tmp/gcc485/gmp-5.1.3                                            \
    && make                                                                         \
    && make install                                    

RUN curl -o- https://ftp.gnu.org/gnu/mpc/mpc-1.0.1.tar.gz                           \
        | tar -zxf - -C /tmp                                                        \
    && cd /tmp/mpc-1.0.1/                                                           \
    && ./configure                                                                  \
        --with-gmp=/tmp/gcc485/gmp-5.1.3                                            \
        --with-mpfr=/tmp/gcc485/mpfr-3.1.2                                          \
    && make                                                                         \
    && make install

#Build gcc 4.8.5
RUN curl -o- https://ftp.gnu.org/gnu/gcc/gcc-4.8.5/gcc-4.8.5.tar.bz2                \
        | tar -jxf - -C /tmp                                                        \
    && cd /tmp/gcc-4.8.5                                                            \
    && ./configure                                                                  \
        --prefix=/opt/gcc485                                                        \
        --with-gmp=/tmp/gcc485/gmp-5.1.3                                            \
        --with-mpfr=/tmp/gcc485/mpfr-3.1.2                                          \
        --with-mpc=/tmp/gcc485/mpc-1.0.1                                            \
    && make                                                                         \
    && su root                                                                      \
    && make install

#Mapping gcc on the system
RUN cd /usr/bin                                                                     \
    && ln -s /opt/gcc485/bin/gcc gcc485                                             \
    && ln -s /opt/gcc485/bin/g++ g++485

RUN echo '' >> /root/.bashrc                                                        \
    && echo '#GCC 4.8.5 para uso do CMAKE' >> /root/.bashrc                         \
    && echo 'export CC=/opt/gcc485/bin/gcc' >> /root/.bashrc                        \
    && echo 'export CXX=/opt/gcc485/bin/g++' >> /root/.bashrc                       \
    && echo '' >> /root/.bashrc 

#Cleanup
RUN rm -rf /tmp/gcc-4.8.5/                                                          \
    && rm -rf /tmp/gmp-5.1.3/                                                       \
    && rm -rf /tmp/mpc-1.0.1/                                                       \
    && rm -rf /tmp/mpfr-3.1.2/                                                      

# Cleanup de instalacoes
# RUN dnf groupremove -y "Development tools"                                          \
#     && dnf remove -y                                                                \
#         tar                                                                         \
#         bzip2                                                                       \
#         glibc-devel                                                                 \
#         glibc                                                                       \
#         glibc-devel.i686                                                            \
#         glibc.i686                                                                  \
#         gcc-c++                                                                     \
#         m4                                                                          \
#         zlib                                                                        \
#         zlib-devel                                                                  \
#         libuuid                                                                     \
#         libuuid-devel                                                               \
#     && dnf clean all




# Install NVM and NODE v10
ENV NVM_DIR         /opt/nvm
ENV NODE_VERSION    10.15.3
ENV NODE_PATH       $NVM_DIR/v$NODE_VERSION/lib/node_modules
ENV PATH            $NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH

RUN mkdir $NVM_DIR

RUN curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.34.0/install.sh    \
        | bash                                                                      \
    && . $NVM_DIR/nvm.sh                                                            \
    && nvm install $NODE_VERSION                                                    \
    && nvm alias default $NODE_VERSION                                              \
    && nvm use default

RUN npm install -g cmake-cli --unsafe-perm --scripts-prepend-node-path
