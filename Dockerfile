FROM centos:centos7.7.1908

COPY files/install_config.txt /opt/install_config.txt
COPY files/install.sh /opt/install.sh

ARG VERSION=2019.2
ARG INSTALLER_NAME=Xilinx_Vivado_2019.2_1106_2127
ARG INSTALLER_PATH=/opt/${INSTALLER_NAME}/
ARG TARBALL_NAME=${INSTALLER_NAME}.tar.gz
ARG TARBALL_PATH=/opt/${TARBALL_NAME}
ARG REFERENCE_MD5SUM=e2b2762964ef5f014591b13d77d823ab
ARG CERNBOX_URL_LIST="https://cernbox.cern.ch/index.php/s/JGU1wnAVDPUeiRd;\
                      https://cernbox.cern.ch/index.php/s/Mh7E70G73ycav5z;\
                      https://cernbox.cern.ch/index.php/s/49ffV0Md7eqJS1Z;\
                      https://cernbox.cern.ch/index.php/s/NSTvnre5d9eYShW;\
                      https://cernbox.cern.ch/index.php/s/AvC6Ms6C0mB4vBj;\
                      https://cernbox.cern.ch/index.php/s/7tYojW77992HXzi;\
                      https://cernbox.cern.ch/index.php/s/UxIh38v2lIWHfmA;\
                      https://cernbox.cern.ch/index.php/s/IWl2FDXgKeyn93Q;\
                      https://cernbox.cern.ch/index.php/s/Y79Fuism5l6RPoI;\
                      https://cernbox.cern.ch/index.php/s/j7cyUAiQ9USOg8b;\
                      https://cernbox.cern.ch/index.php/s/8NNpUD6cxJea5Xh;\
                      https://cernbox.cern.ch/index.php/s/JGR6opD9QyBnmbK;\
                      https://cernbox.cern.ch/index.php/s/0uQQxVvfeNxhV8c;\
                      https://cernbox.cern.ch/index.php/s/PgQe6aT2uXvwQwM;\
                      https://cernbox.cern.ch/index.php/s/sEjgjoPZ3aUZZcq;\
                      https://cernbox.cern.ch/index.php/s/Z4HDnwy2lseFNU8;\
                      https://cernbox.cern.ch/index.php/s/RbhbW640cjTuq5l;\
                      https://cernbox.cern.ch/index.php/s/rLrov5Acv6t19JD;\
                      https://cernbox.cern.ch/index.php/s/Y4xCc78oXeFlvqe;\
                      https://cernbox.cern.ch/index.php/s/rvzU4lM3KuIs0Cc;\
                      https://cernbox.cern.ch/index.php/s/0ptGZPTScZHxgKu;\
                      https://cernbox.cern.ch/index.php/s/1cFRBuCiR6gOhTP;\
                      https://cernbox.cern.ch/index.php/s/liQD8TI6hX5OO1R;\
                      https://cernbox.cern.ch/index.php/s/WtZ6xF953syUiqH;\
                      https://cernbox.cern.ch/index.php/s/GtCo6bNc85H39JU;\
                      https://cernbox.cern.ch/index.php/s/XKkwdaoAhIDu2rJ;\
                      https://cernbox.cern.ch/index.php/s/1BIPYqyk2RtEnYT"
ARG REFERENCE_SPLIT_MD5SUM_LIST="f611d6fc1f45911e5667f759089fcf3f;\
                                 4899a3efb371c264febc5d64af828694;\
                                 c08f68bec8745fcaf7511307f72a0cac;\
                                 3058a2b5eaa88a0a2afcdcdf8cd8e64f;\
                                 6378485fb67d620fc48d5003e9af6555;\
                                 1c8f17ec42cbadb7976348ba9b51bb4e;\
                                 33e1e0c72632cc0059fc28f8af178ebb;\
                                 2406db2a80e2f45b37d9e2ca67fb74fc;\
                                 0ddd4cf0ff8729c3b6e3b905f35d232e;\
                                 f500303372ce39a1779817547493f3d9;\
                                 f56e4a1fcdaf5ee70c9018abcbf25183;\
                                 49da20695e1ec3b52415bdf45f1feef2;\
                                 2f97c177acea621eccccb51a191f3328;\
                                 991ba25a478d2c75ed585a110880ef26;\
                                 f86422d7ea022f9676ea29c9115fbc59;\
                                 a23ca055c55cb731f73d9de7855b98d2;\
                                 fef1b9899ff8b52378ef24bf4d9b805f;\
                                 c0b2e1fbe9d8adba37e0b5067e40e913;\
                                 bbec88b77d8ce8b2335a3e06dc2c39fe;\
                                 68258c436f76a8eb2d3ca8a196e6d51b;\
                                 7947bf0349e8cae56031e25e257c4e90;\
                                 7f134ef90a468bffc7aaeb9c5620af94;\
                                 ab5c78ddb69e3f7126be970f81bf793c;\
                                 6389de8d45a0387426826ffa8c2e307a;\
                                 cad71456e78576a407b0b479224fcd81;\
                                 005aaa902ceba12b82e9ac7499cfe63a;\
                                 32cc297b01b41e3e08fd900538925b51"

RUN yum -y install gcc gcc-c++ make java-1.8.0-openjdk libXrender-devel libXtst-devel xorg-x11-server-Xorg xorg-x11-xauth xorg-x11-apps wget \
    && yum clean all \
    && df -ih \
    && mkdir -p /opt \
    && ls -alh / \
    && echo "Downloading the split tarball ..." \
    && IFS='; ' read -r -a CERNBOX_URL_ARRAY <<< "${CERNBOX_URL_LIST}" \
    && IFS='; ' read -r -a REFERENCE_SPLIT_MD5SUM_ARRAY <<< "${REFERENCE_SPLIT_MD5SUM_LIST}" \
    && for i in "${!CERNBOX_URL_ARRAY[@]}"; do \
           INDEX=$(printf "%02d" ${i}); \
           CERNBOX_URL="${CERNBOX_URL_ARRAY[$i]}"; \
           CERNBOX_URL_DOWNLOAD=$(wget -q -O - ${CERNBOX_URL} | grep downloadURL | grep -Eo "(http|https)://[a-zA-Z0-9./?=_-]*"); \
           echo -e "\tDownloading file ${INDEX} ..."; \
           echo -e "\t\tThe CERNBox download url is: ${CERNBOX_URL_DOWNLOAD}"; \
           echo -e "\t\tThe output filename is: ${TARBALL_PATH}.part${INDEX}"; \
           wget --progress=dot:giga -c -O ${TARBALL_PATH}.part${INDEX} ${CERNBOX_URL_DOWNLOAD}; \
           echo -e "\tChecking the md5sum ..."; \
           checksum=$(echo $(md5sum ${TARBALL_PATH}.part${INDEX}) | awk '{print $1;}'); \
           reference_checksum="${REFERENCE_SPLIT_MD5SUM_ARRAY[$i]}"; \
           [[ "${checksum}" == "${reference_checksum}" ]] && { echo -e "\t\tChecksums match!"; } || { echo -e "\t\tWARNING::The checksum of part $i (${checksum}) doesn't match its reference checksum (${reference_checksum})!"; break; }; \
           df -h; \
       done \
    && ls -alh /opt \
    && echo "Combining the split tarball ..." \
    && cat ${TARBALL_PATH}.part* > ${TARBALL_PATH} \
    && ls -alh /opt \
    && df -ih \
    && echo "Removing the individual components of the split tarball ..." \
    && rm ${TARBALL_PATH}.part* \
    && ls -alh /opt \
    && echo "Checking the md5sum of the combined tarball ..." \
    && checksum=$(echo $(md5sum ${TARBALL_PATH}) | awk '{print $1;}') \
    && [[ "${checksum}" == "${REFERENCE_MD5SUM}" ]] && echo 'Checksums match!' || echo "WARNING::The checksums of the original tarball and the merged tarball don't match!" \
    && echo "Unpacking the tarball ..." \
    && tar --directory /opt/ -xzf ${TARBALL_PATH} \
    && ls -alh /opt \
    && df -ih \
    && echo "Removing the tarball ..." \
    && rm ${TARBALL_PATH} \
    && ls -alh /opt \
    && df -ih \
    && echo "Installing Vivado ${VERSION} ..." \
    && chmod +x ${INSTALLER_PATH}/xsetup \
    && chmod +x /opt/install.sh \
    && /opt/install.sh \
    && df -ih \
    && ls -alh /opt \
    && echo -e "Installation complete!!!\nRemoving the installer ..." \
    && rm -rf ${INSTALLER_PATH} \
    && df -ih \
    && ls -alh /opt \
    && echo "Cleaning /tmp ..." \
    && rm -rf /tmp/.X* \
    && echo "Setting up the 'vitis' user ..." \
    && useradd -ms /bin/bash vivado \
    && chown -R vivado /home/vivado \
    && echo "source /opt/Xilinx/Vivado/${VERSION}/settings64.sh" >> /home/vivado/.bashrc

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
RUN chpasswd vivado:vivado
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Install additional dependencies
RUN yum -y install git ncurses-devel xterm which centos-release-scl devtoolset-9 gdb sudo python3-pip python3-devel patch
RUN pip3 install -U pip wheel 
RUN pip3 install numpy pyarrow vhdeps vhdmmio

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
    && source /opt/Xilinx/Vivado/2019.2/settings64.sh \
    && make -s customaction.defconfig \
    && make model

CMD /work/scripts/ocxl_run_sim.sh



