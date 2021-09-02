FROM centos:centos7.7.1908

ARG VERSION=2019.2.1

RUN yum -y install gcc gcc-c++ make java-1.8.0-openjdk libXrender-devel libXtst-devel xorg-x11-server-Xorg xorg-x11-xauth xorg-x11-apps wget \
    && yum clean all


# Install additional dependencies
RUN yum -y install git ncurses-devel xterm which centos-release-scl devtoolset-9 gdb sudo python3-pip python3-devel patch
RUN pip3 install -U pip wheel 
RUN pip3 install numpy pyarrow vhdeps vhdmmio

COPY files/install_config.txt /opt/install_config.txt
COPY files/install.sh /opt/install.sh
COPY files/Xilinx_Vivado_Vitis_Update_2019.2.1_1205_0436.tar.gz /opt/

RUN df -ih \
    && ls -alh /opt \
    && df -ih \
    && echo "Installing Vivado ${VERSION} ..." \
    && chmod +x /opt/install.sh \
    && /opt/install.sh \
    && df -ih \
    && ls -alh /opt \
    && echo -e "Installation complete!!!" \
    && echo "Cleaning /tmp ..." \
    && rm -rf /tmp/.X* \
RUN echo "Setting up the 'opencapi' user ..." \
    && useradd -ms /bin/bash opencapi \
    && chown -R opencapi /home/opencapi \
    && echo "source /opt/Xilinx/Vivado/${VERSION}/settings64.sh" >> /home/opencapi/.bashrc

ENV DISPLAY :0
ENV GEOMETRY 1920x1200
ENV VERSION=${VERSION}

#ENTRYPOINT /opt/Xilinx/Vivado/${VERSION}/bin/vivado

RUN mkdir /work && chmod -R 777 /work && chown -R opencapi /work
RUN chpasswd opencapi:opencapi
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Install a recent CMake
RUN mkdir /work/cmake && cd /work/cmake \
    && wget https://github.com/Kitware/CMake/releases/download/v3.20.5/cmake-3.20.5-linux-x86_64.tar.gz \
    && tar -xzf cmake-3.20.5-linux-x86_64.tar.gz \
    && cp -r cmake-3.20.5-linux-x86_64/* /usr/local/

# Install Apache Arrow binary release #unfortunately we need to build Arrow from source using devtoolset-9 to fix errors on centos 7
#RUN yum install -y epel-release || sudo yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-$(cut -d: -f5 /etc/system-release-cpe | cut -d. -f1).noarch.rpm \
#    && yum install -y https://apache.jfrog.io/artifactory/arrow/centos/$(cut -d: -f5 /etc/system-release-cpe | cut -d. -f1)/apache-arrow-release-latest.rpm \
#    && yum install -y --enablerepo=epel arrow-devel

#install this dependency again (no idea why this is needed)
RUN yum -y install centos-release-scl devtoolset-9

# Install Apache Arrow from source
RUN mkdir -p /work/arrow && cd /work/arrow && \
git clone https://github.com/apache/arrow.git && \
cd arrow && \
git checkout apache-arrow-5.0.0 && \
cd /work/arrow && mkdir build && cd build && \
scl enable devtoolset-9 'bash -c "CFLAGS=-D_GLIBCXX_USE_CXX11_ABI=0 CXXFLAGS=-D_GLIBCXX_USE_CXX11_ABI=0 LDFLAGS=-D_GLIBCXX_USE_CXX11_ABI=0  cmake -DARROW_PYTHON=ON -DARROW_DATASET=ON -DARROW_PARQUET=ON -DARROW_WITH_SNAPPY=ON ../arrow/cpp"' && \
scl enable devtoolset-9 'bash -c "make -j4 && make install"'
RUN echo "/usr/local/lib64" >> /etc/ld.so.conf
RUN ldconfig

# Perform debug build of Apache Arrow
#RUN cd /work/arrow && mkdir build_dbg && cd build_dbg && \
#scl enable devtoolset-9 'bash -c "CFLAGS=-D_GLIBCXX_USE_CXX11_ABI=0 CXXFLAGS=-D_GLIBCXX_USE_CXX11_ABI=0 LDFLAGS=-D_GLIBCXX_USE_CXX11_ABI=0 cmake -DARROW_PYTHON=ON -DARROW_DATASET=ON -DARROW_PARQUET=ON -DARROW_WITH_SNAPPY=ON -DCMAKE_BUILD_TYPE=Debug ../arrow/cpp"' && \
#scl enable devtoolset-9 'bash -c "make -j4"'

# Install Fletcher and fletchgen from binary release (RPM)
#RUN cd /work/ \
#    && wget https://github.com/abs-tudelft/fletcher/releases/download/0.0.19/fletcher-0.0.19-1.el7.x86_64.rpm \
#    && rpm -i fletcher-0.0.19-1.el7.x86_64.rpm \
#    && rm fletcher-0.0.19-1.el7.x86_64.rpm

# Install Fletcher and fletchgen from binary release (wheels)
#RUN cd /work \
#    && wget https://github.com/abs-tudelft/fletcher/releases/download/0.0.19/pyfletchgen-0.0.19-cp36-cp36m-manylinux2014_x86_64.whl \
#    && pip install pyfletchgen-0.0.19-cp36-cp36m-manylinux2014_x86_64.whl --prefix /usr/local

#unfortunately we need to use a modified vhdmmio to fix errors on centos 7. We need centos 7 (and not 8) because it is officially supported by Vivado 2019.2.
# Install vhdmmio from source
RUN mkdir /work/vhdmmio && cd /work/vhdmmio \
    && git clone https://github.com/joosthooz/vhdmmio \
    && cd vhdmmio && git checkout force_utf8 \
    && pip install -e ./


USER opencapi
WORKDIR /work
RUN mkdir -p /work/OpenCAPI/

# Install Fletcher and fletchgen from source
RUN cd /work && git clone https://github.com/abs-tudelft/fletcher \
    && cd fletcher \
    && mkdir /work/fletcher/build \
    && cd /work/fletcher/build \
    && scl enable devtoolset-9 'bash -c "cmake -DFLETCHER_BUILD_FLETCHGEN=On .."' \
    && scl enable devtoolset-9 'bash -c "make -j4"'
USER root
RUN scl enable devtoolset-9 'bash -c "make -C /work/fletcher/build install"'
USER opencapi

# Install oc-accel and ocse
RUN mkdir -p /work/OpenCAPI/ && cd /work/OpenCAPI \
    && git clone https://github.com/OpenCAPI/oc-accel \
    && pushd oc-accel && git submodule init && git submodule update && popd \
    && git clone https://github.com/OpenCAPI/ocse \
    && source /opt/Xilinx/Vivado/${VERSION}/settings64.sh \
    && cd ocse && make

# Install fletcher for the oc-accel platform
RUN cd /work/OpenCAPI \
    && git clone https://github.com/abs-tudelft/fletcher-oc-accel \
    && pushd fletcher-oc-accel && git checkout merge_ocxl_updates && git submodule init && git submodule update && popd \
    && pushd fletcher-oc-accel/fletcher && git submodule init && git submodule update && popd

COPY files/snap_env.sh /work/OpenCAPI/oc-accel/
COPY files/*sim.sh /work/scripts/
COPY files/customaction.defconfig /work/OpenCAPI/oc-accel/defconfig/
USER root
RUN chmod -R +x /work/scripts
USER opencapi

# We're now using defconfig files to configure oc-accel, otherwise you can use an answerfile and pipe it into the menuconfig like this:
# COPY files/snap_interactive_config_values.txt /work/scripts/
# ... && cat /work/scripts/snap_interactive_config_values.txt | make config \
#    && cp .snap_config defconfig/9V3.customaction.defconfig \

# Prepare oc-accel configuration
RUN cd /work/OpenCAPI/oc-accel \
    && source /opt/Xilinx/Vivado/${VERSION}/settings64.sh \
    && make -s customaction.defconfig \
    && make model

CMD /work/scripts/ocxl_run_sim.sh



