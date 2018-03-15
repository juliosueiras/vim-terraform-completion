FROM base/archlinux
USER root
WORKDIR /root
RUN pacman -Syy && \
    pacman -S vim neovim ruby gcc make git unzip ruby-rdoc --noconfirm 
RUN echo 'export PATH=$PATH:/root/.gem/ruby/2.5.0/bin' >> ~/.bashrc
RUN gem install neovim
RUN curl https://releases.hashicorp.com/terraform/0.11.1/terraform_0.11.1_linux_amd64.zip -o terraform_0.11.1_linux_amd64.zip && \
    unzip terraform_0.11.1_linux_amd64.zip && \
    mv terraform /usr/bin/terraform
RUN git clone https://github.com/junegunn/vader.vim
ADD tests/ tests/
COPY tests.vimrc tests.vimrc
ADD . vim-terraform-completion/
ENTRYPOINT ["/usr/sbin/bash"]
