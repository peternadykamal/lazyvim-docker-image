# Use Alpine as the base image
FROM alpine:latest

ENV \
    UID="1500" \
    GID="1500" \
    UNAME="peter" \
    SHELL="/bin/zsh"

RUN apk add --no-cache shadow sudo tzdata

# Copy root password file
COPY ./user_password.txt /root/user_password.txt
COPY ./docker_setup/user_setup.sh /tmp/user_setup.sh
# seting up user
# RUN env UID=$UID GID=$GID UNAME=$UNAME SHELL=$SHELL sh /tmp/user_setup.sh
RUN sh /tmp/user_setup.sh

# Install packages
COPY ./docker_setup/install_packages.sh /tmp/install_packages.sh
# RUN env UNAME=$UNAME sh /tmp/install_packages.sh 
RUN sh /tmp/install_packages.sh 

# Copy .tmux.conf
COPY ./.tmux.conf /home/$UNAME/.tmux.conf
COPY ./lua /home/$UNAME/.config/nvim/lua

RUN chown -R $UNAME:$UNAME /home/$UNAME

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