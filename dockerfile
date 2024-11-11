# Use Alpine as the base image
FROM alpine:latest

ENV \
    UID="1500" \
    GID="1500" \
    UNAME="peter" \
    SHELL="/bin/zsh"

# Add dependencies for installing additional tools
RUN apk add --no-cache \
    shadow sudo zsh curl wget git bash tzdata

# Create user and set password for root
RUN groupadd -g $GID $UNAME \
    && useradd -m -u $UID -g $GID -s $SHELL $UNAME \
    && echo "$UNAME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Copy root password file
COPY ./user_password.txt /root/user_password.txt

# Set the root password from the file
RUN echo "$(cat /root/user_password.txt)" | passwd --stdin $UNAME \
    && rm /root/user_password.txt  # Remove the password file after setting

# Install development tools and dependencies
RUN apk add --no-cache \
    build-base procps cmake make gcc g++ file \
    curl curl-doc git unzip zsh ripgrep tmux fzf bat nodejs npm python3 py3-pip \
    ncdu neofetch fd zoxide ranger eza

# Install tldr
RUN npm install -g tldr

# Install Neovim
RUN apk add --no-cache neovim

# Clone Neovim configuration
RUN apk add --no-cache lazygit alpine-sdk
RUN git clone https://github.com/LazyVim/starter /home/$UNAME/.config/nvim

# Install tpm
RUN git clone https://github.com/tmux-plugins/tpm /home/$UNAME/.tmux/plugins/tpm 
# Copy .tmux.conf
COPY ./.tmux.conf /home/$UNAME/.tmux.conf
RUN dos2unix /home/$UNAME/.tmux.conf
COPY ./lua /home/$UNAME/.config/nvim/lua

RUN chown -R peter:peter /home/$UNAME

# Install Zsh with plugins
COPY ./zsh /tmp/zsh
RUN env HOME=/home/$UNAME sh /tmp/zsh/zsh-in-docker.sh -t https://github.com/denysdovhan/spaceship-prompt

# working directory
WORKDIR /home/$UNAME/projects

# Replace existing TERM setting in .zshrc if it exists
ENV TERM xterm-256color

# Modify sudoers file to replace $UNAME ALL=(ALL) NOPASSWD:ALL with $UNAME ALL=(ALL) ALL
RUN sed -i "s|$UNAME ALL=(ALL) NOPASSWD:ALL|$UNAME ALL=(ALL) ALL|" /etc/sudoers

USER $UNAME

# Start zsh by default
CMD [ "/bin/zsh" ]