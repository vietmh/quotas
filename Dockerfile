FROM node:8 

ADD docker/install-yarn.sh /usr/sbin/install-yarn.sh

ENV NPM_CONFIG_PREFIX=/home/node/.npm-global
ENV PATH=$PATH:/home/node/.npm-global/bin

WORKDIR /app
COPY quotas/ /app

RUN /usr/sbin/install-yarn.sh

CMD yarn start
EXPOSE 1337
