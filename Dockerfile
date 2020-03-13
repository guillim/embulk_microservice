FROM java:8

# help here : https://unix.stackexchange.com/questions/508724/failed-to-fetch-jessie-backports-repository

RUN echo "deb [check-valid-until=no] http://cdn-fastly.deb.debian.org/debian jessie main" > /etc/apt/sources.list.d/jessie.list
RUN echo "deb [check-valid-until=no] http://archive.debian.org/debian jessie-backports main" > /etc/apt/sources.list.d/jessie-backports.list
RUN sed -i '/deb http:\/\/deb.debian.org\/debian jessie-updates main/d' /etc/apt/sources.list
RUN apt-get -o Acquire::Check-Valid-Until=false update

RUN apt-get install openssh-client

SHELL ["/bin/bash", "-c"]

RUN curl --create-dirs -o ~/.embulk/bin/embulk -L "https://dl.embulk.org/embulk-latest.jar"
RUN chmod +x ~/.embulk/bin/embulk
RUN echo 'export PATH="$HOME/.embulk/bin:$PATH"' >> ~/.bashrc
RUN source ~/.bashrc

RUN ~/.embulk/bin/embulk gem install embulk-output-postgresql
RUN ~/.embulk/bin/embulk gem install embulk-input-mongodb

RUN mkdir work
COPY * /work/
COPY .ssh/* /work/.ssh/

WORKDIR /work

RUN chmod -R 600 /work/.ssh/*
RUN chmod +x script.sh

ARG SSHKEY=default_SSHKEY
ARG TUNNEL_HOST=default_TUNNEL_HOST
ARG LOCAL_PORT=default_LOCAL_PORT
ARG REMOTE_HOST=default_REMOTE_HOST
ARG REMOTE_PORT=default_REMOTE_PORT

# could be removed i think
EXPOSE 1-65535

# starting in the background ssh tunnels (for the two databases)
ENTRYPOINT ssh \
-4 \
-q \
-o StrictHostKeyChecking=no \
-i  /work/.ssh/$SSHKEY \
-L *:$LOCAL_PORT:$REMOTE_HOST:$REMOTE_PORT \
-fN \
$TUNNEL_HOST \
&& ssh \
-4 \
-q \
-o StrictHostKeyChecking=no \
-i  /work/.ssh/$SSHKEY2 \
-L *:$LOCAL_PORT2:$REMOTE_HOST2:$REMOTE_PORT2 \
-fN \
$TUNNEL_HOST2 \
&& bash
