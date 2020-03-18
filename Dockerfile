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
RUN ~/.embulk/bin/embulk gem install embulk-filter-expand_json
RUN ~/.embulk/bin/embulk gem install embulk-filter-add_time

ARG CONFIGURATION_FILE=configuration_example.yml
ENV CONFIGURATION_FILE=${CONFIGURATION_FILE}
RUN mkdir work
COPY $CONFIGURATION_FILE /work/$CONFIGURATION_FILE
COPY .ssh/* /work/.ssh/

WORKDIR /work

RUN chmod -R 600 /work/.ssh/*


# here are some default values (overwritten by environment_variables.txt)
ENV SSHKEY=key
ENV TUNNEL_HOST=127.0.0.1
ENV LOCAL_PORT=4001
ENV REMOTE_HOST=86.0.0.12
ENV REMOTE_PORT=27017
ENV SSHKEY2=key
ENV TUNNEL_HOST2=127.0.0.1
ENV LOCAL_PORT2=4002
ENV REMOTE_HOST2=93.0.0.11
ENV REMOTE_PORT2=5432

# could be removed i think
EXPOSE 1-65535

# starting in the background ssh tunnels (for the two databases) - note that after ENTRYPOINT the ARG disappear, and only the ENV remains
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
&& ~/.embulk/bin/embulk run $CONFIGURATION_FILE -c diff.yml \
&& bash
