FROM base/archlinux
USER root
WORKDIR /root
ADD example.vimrc .vimrc
RUN pacman -Syy && \
    pacman -S vim ruby git unzip --noconfirm && \
    curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim && \
    vim +PlugInstall +qall && \
    curl https://releases.hashicorp.com/terraform/0.9.4/terraform_0.9.4_linux_amd64.zip -o terraform_0.9.4_linux_amd64.zip && \
    unzip terraform_0.9.4_linux_amd64.zip && \
    mv terraform /usr/bin/terraform
ENTRYPOINT ["vim"]
