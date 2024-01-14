ARG ubuntu_version=20.04
FROM ubuntu:${ubuntu_version}
ARG ubuntu_version=20.04


ARG user_name=lw

ENV DEBIAN_FRONTEND noninteractive
ENV TIME_ZONE Asia/Shanghai
ENV LANG C.UTF-8

# update source
RUN apt update && \
    apt install -y --no-install-recommends --reinstall ca-certificates && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY --chown=root:root ./files/sources.list.${ubuntu_version}  /etc/apt/sources.list

# timezone
RUN apt clean && apt update && apt upgrade -y && \
    apt-get install -y tzdata && \
    ln -snf /usr/share/zoneinfo/$TIME_ZONE /etc/localtime && \
    echo $TIME_ZONE > /etc/timezone && \
    dpkg-reconfigure -f noninteractive tzdata && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# install apps
RUN apt clean && apt update && apt install -y --no-install-recommends \
                python3-pip python3-dev python-is-python3 \
                fish sudo \
                rsync lrzsz tmux tio xxd \
                git tig neovim \
                sshpass openssh-server nfs-kernel-server \
                build-essential qemu-user-static ninja-build \
                zip unzip pigz tar \
                libtool libssl-dev libusb-1.0-0-dev usbutils libncurses5-dev ncurses-dev \
                autoconf automake bison device-tree-compiler \
                tftp-hpa tftpd-hpa \
                htop tree wget curl \
                silversearcher-ag \
                gnutls-bin pkg-config gettext mtools bc ctags cpio flex \
                apt-transport-https \
                iputils-ping net-tools iproute2 \
                kmod gnupg2 gpgv && \
                apt-get autoremove -y && \
                apt-get clean && \
                rm -rf /var/lib/apt/lists/*

# User
RUN useradd -d "/home/${user_name}" -m \
            -G "sudo,video,audio,adm,dialout" \
            -s "/bin/fish" \
            --no-log-init \
            -p ${user_name} \
            ${user_name}
            
RUN echo "${user_name} ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

WORKDIR /home/${user_name}
USER ${user_name}

# git
RUN git config --global user.name ${user_name} \
    && git config --global user.email "liwang54321@gmail.com" \
    && git config --global core.editor vim \
    && git config --global http.sslVerify false \
    && git config --global http.postBuffer 1048576000 

# cmake
RUN sudo apt update && \
    sudo apt-get install -y --no-install-recommends dialog && \
    curl https://apt.kitware.com/kitware-archive.sh | sudo bash && \
    sudo apt update && \
    sudo apt install -y --no-install-recommends cmake \
    cmake --version && \
    sudo apt-get autoremove -y && \
    sudo apt-get clean 

# space vim
RUN curl -sLf https://spacevim.org/install.sh | bash

# for fish
SHELL ["/bin/fish", "-c"]
RUN curl https://gitee.com/mirrors/oh-my-fish/raw/master/bin/install | fish

# python
RUN pip3 config set global.index-url https://mirrors.aliyun.com/pypi/simple/ \
    && sudo pip3 config set global.index-url https://mirrors.aliyun.com/pypi/simple/ \
    && sudo pip3 install --upgrade conan \
    && conan profile detect --force

# rit connext
# COPY SDK
SHELL ["/bin/bash", "-c"]
ARG RTI_VERSION=rti_connext_dds-7.2.0
ENV RTI_NC_LICENSE_ACCEPTED=yes NDDSHOME=/home/${user_name}/rti
ENV PATH="/home/${user_name}/${RTI_VERSION}/bin:${PATH}"
COPY --chown=${user_name}:${user_name} files/* /tmp/
RUN chmod +x /tmp/${RTI_VERSION}-lm-x64Linux4gcc7.3.0.run && \
    yes yes | /tmp/${RTI_VERSION}-lm-x64Linux4gcc7.3.0.run \
    --prefix /home/${user_name}/rti \
    --mode text \
    --unattendedmodeui none \
    --disable_copy_examples yes \
    --installer-language en && \
    mv /home/${user_name}/yes/* /home/${user_name} && \
    rm -rf /home/${user_name}/yes

ENV RTI_LICENSE_FILE=/home/${user_name}/${RTI_VERSION}/rti_license.dat
RUN yes y | /home/${user_name}/${RTI_VERSION}/bin/rtipkginstall /tmp/${RTI_VERSION}-lm-target-armv8Linux4gcc7.3.0.rtipkg && \
    cp /tmp/rti_license.dat /home/${user_name}/${RTI_VERSION}

# clean 
RUN sudo rm /tmp/* -rf && \
    sudo apt autoremove -y && \
    sudo apt clean

WORKDIR ${sdk_path}
# ENTRYPOINT ["/bin/fish"]
CMD /bin/fish