FROM python:3.9-slim-buster

LABEL maintainer="miklos.szel@edmodo.com"

COPY ./requirements.txt /app/requirements.txt

WORKDIR /app

RUN pip3 install -r requirements.txt

COPY . /app
COPY ./config/config.yml /config/config.yml
RUN cp /app/misc/entry.sh /app/
RUN chmod 755 /app/entry.sh 

RUN apt-get update -y && \
    apt-get install  wget   ca-certificates  debsums libncurses6 libatomic1  libaio1  libnuma1 mysql-common  -y
RUN wget https://downloads.percona.com/downloads/Percona-Server-5.7/Percona-Server-5.7.32-35/binary/debian/buster/x86_64/percona-server-common-5.7_5.7.32-35-1.buster_amd64.deb -O /tmp/percona-server-common-5.7_5.7.32-35-1.buster_amd64.deb
RUN wget https://downloads.percona.com/downloads/Percona-Server-5.7/Percona-Server-5.7.32-35/binary/debian/buster/x86_64/percona-server-client-5.7_5.7.32-35-1.buster_amd64.deb -O /tmp/percona-server-client-5.7_5.7.32-35-1.buster_amd64.deb
RUN dpkg -i /tmp/percona-server-common-5.7_5.7.32-35-1.buster_amd64.deb /tmp/percona-server-client-5.7_5.7.32-35-1.buster_amd64.deb
RUN rm -rf /var/lib/apt/lists/* && rm /tmp/*.deb

ENTRYPOINT [ "./entry.sh" ]
CMD [ "app.py" ]
