FROM juliosueiras/vim-terraform-completion-base:latest
USER root
RUN git clone https://github.com/junegunn/vader.vim
ADD tests/ tests/
COPY tests.vimrc tests.vimrc
ADD . vim-terraform-completion/
ENTRYPOINT ["/bin/bash"]
