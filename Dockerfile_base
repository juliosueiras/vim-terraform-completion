FROM alpine:3.8 AS vim_ruby

RUN apk add --no-cache \
      build-base \
      ctags \
      git \
      libx11-dev \
      libxpm-dev \
      libxt-dev \
      make \
      ncurses-dev \
      ruby \
      ruby-dev

RUN git clone https://github.com/vim/vim \
  && cd vim \
  && ./configure \
  --disable-gui \
  --disable-netbeans \
  --enable-multibyte \
  --enable-rubyinterp \
  --with-ruby-command=/usr/bin/ruby \
  --with-features=big \
  && make install

FROM alpine:3.8

COPY --from=vim_ruby /usr/local/bin/ /usr/local/bin
COPY --from=vim_ruby /usr/local/share/vim/ /usr/local/share/vim/

RUN apk add bash neovim ruby gcc make git unzip ruby-rdoc ruby-dev terraform cmake build-base diffutils libice libsm libx11 libxt ncurses
RUN gem install neovim
