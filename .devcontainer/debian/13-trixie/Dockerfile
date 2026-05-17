# SPDX-FileCopyrightText: 2026 Jens A. Koch
# SPDX-License-Identifier: MIT
# This file is part of https://github.com/jakoch/jekyll-devbox

FROM debian:trixie

# +-----------------------------+
# | GLOBAL ARGS                 |
# +-----------------------------+

ARG DEBIAN_VERSION=13
ARG DEBIAN_VERSION_NAME=trixie

# +-----------------------------+
# | METADATA                    |
# +-----------------------------+
# Standardized Docker Image Labels
# https://github.com/opencontainers/image-spec/blob/main/annotations.md

LABEL \
    maintainer="Jens A. Koch <jakoch@web.de>" \
    org.opencontainers.image.created="$(date --utc --iso-8601=seconds)" \
    org.opencontainers.image.authors='Jens A. Koch <jakoch@web.de>' \
    org.opencontainers.image.url='https://ghcr.io/jakoch/jekyll-devbox' \
    org.opencontainers.image.source='https://github.com/jakoch/jekyll-devbox'\
    org.opencontainers.image.title='ghcr.io/jakoch/jekyll-devbox'\
    org.opencontainers.image.description="Jekyll DevBox (Debian ${DEBIAN_VERSION}-${DEBIAN_VERSION_NAME}, jekyll, ruby, node, zsh)" \
    org.opencontainers.image.licenses=MIT

# Tell Debian to be quiet during build
# Set frontend to noninteractive to avoid prompts during build.
# Set DEBCONF_NOWARNINGS to avoid warnings about debconf.
ENV DEBIAN_FRONTEND=noninteractive \
    DEBCONF_NOWARNINGS="yes"

# +-----------------------------+
# | Install Dependencies        |
# +-----------------------------+

RUN echo "Download Stage" && \
    apt-get update && apt-get install --no-install-recommends --assume-yes \
		build-essential \
		ruby \
		ruby-dev \
		nodejs npm \
		git \
		ca-certificates \
		locales \
		zsh \
		curl wget nano jq && \
	echo "Cleanup Stage" && \
	apt-get autoremove -y && \
    apt-get clean autoclean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# +-----------------------------+
# | ZSH                         |
# +-----------------------------+
# Setup zsh, ohmyzsh, powerline fonts.
# Setup zsh plugins: autosuggestions, autocompletions, history search.

ENV TERM=xterm-256color \
    ZSH_THEME=agnoster

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN echo "ZSH" && \
    apt-get update && apt-get install --no-install-recommends --assume-yes \
    # Install fonts-powerline
    fontconfig fonts-powerline && \
    # Install Oh My Zsh
    curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh | sh && \
    # Add Zsh plugins
    git clone --depth=1 --no-tags https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions && \
    git clone --depth=1 --no-tags https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:=~/.oh-my-zsh/custom}/plugins/zsh-completions && \
    git clone --depth=1 --no-tags https://github.com/zsh-users/zsh-history-substring-search ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-history-substring-search && \
    # Update .zshrc
    sed -i "s/plugins=(git)/plugins=(git zsh-completions zsh-autosuggestions zsh-history-substring-search)/" /root/.zshrc && \
    sed -i "s/ZSH_THEME=\"agnoster\"/ZSH_THEME=\"robbyrussell\"/" /root/.zshrc  && \
	# Cleanup
	apt-get autoremove -y && \
    apt-get clean autoclean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Set the default shell to zsh after it is installed
ENV SHELL=/bin/zsh

# +-----------------------------+
# | Set Locale + Timezone       |
# +-----------------------------+

ENV TZ=UTC

RUN echo "Locale & Timezone" && \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    echo $TZ > /etc/timezone && \
    dpkg-reconfigure -f noninteractive tzdata && \
    sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    echo 'LANG="en_US.UTF-8"' > /etc/default/locale && \
    dpkg-reconfigure -f noninteractive locales && \
    update-locale LANG=en_US.UTF-8 && \
    echo "export PATH=$PATH" > /etc/environment && \
    localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8

ENV LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8

# +-----------------------------+
# | Install Jekyll + Bundler    |
# +-----------------------------+

RUN --mount=type=cache,target=/var/lib/gems \
    gem install jekyll bundler && \
    gem cleanup

# +-----------------------------+
# | Finalize                    |
# +-----------------------------+

# Switch back to dialog for any ad-hoc use of apt-get
ENV DEBIAN_FRONTEND=dialog

WORKDIR /workspace

# Expose default Jekyll port
EXPOSE 4000

# Healthcheck: verifies Jekyll is serving pages
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:4000/ || exit 1

CMD ["bash"]
