FROM alpine:3.5
USER root
WORKDIR /root
ADD example.vimrc .vimrc
RUN apk add --no-cache curl vim git terraform && \
    curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim && \
    vim +PlugInstall +qall
ENTRYPOINT ["vim"]
