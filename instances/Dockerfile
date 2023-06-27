FROM ubuntu

# Updating packages
RUN apt-get update
RUN apt-get install curl -y
# Downloading Node 10.x
RUN curl -sL https://deb.nodesource.com/setup_16.x | bash -
# Installing Node.JS
RUN apt install nodejs -y

WORKDIR /usr/app
COPY . /usr/app/

EXPOSE 3000

CMD [ "npm", "start" ]