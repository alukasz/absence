FROM elixir:1.8

RUN apt-get update \
 && apt-get install -y build-essential \
 && apt-get install -y inotify-tools

RUN mix local.hex --force \
 && mix local.rebar --force \
 && mix archive.install --force https://github.com/phoenixframework/archives/raw/master/phx_new.ez

RUN curl -sL https://deb.nodesource.com/setup_10.x | bash - \
 && apt-get install -y nodejs \
 && curl https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
 && echo "deb http://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
 && apt-get -y update && apt-get -y install yarn

WORKDIR /app
EXPOSE 4000