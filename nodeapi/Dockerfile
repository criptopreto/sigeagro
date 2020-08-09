FROM node:14.7.0

ENV TZ America/Caracas

RUN mkdir -p /backend

WORKDIR /backend

COPY . .

RUN npm install --quiet
RUN npm install nodemon -g --quiet

EXPOSE 3501