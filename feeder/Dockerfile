# Used to gather information about CPU, memory and disk
#  reporting it back to statsd

# This image must have a volume mapping from docker socket (host) to
#  /var/run/docker.sock (container) so that docker-api gem can read
# containers data.

# This image must have a link named monitor so that monitor can communicate
# with that

FROM ruby:2.5
MAINTAINER Cristiano A "https://www.linkedin.com/in/criscasm"

# throw errors if Gemfile has been modified since Gemfile.lock
RUN bundle config --global frozen 1

WORKDIR /usr/src/app

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY ./src/ ./src/

CMD ruby ./src/system-monitor.rb
