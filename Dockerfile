FROM alpine:3.2

RUN apk update && apk --update add ruby ruby-irb ruby-json ruby-rake \
    ruby-bigdecimal ruby-io-console libstdc++ tzdata sqlite-dev nodejs

ADD Gemfile /app/
ADD Gemfile.lock /app/

RUN apk --update add --virtual build-dependencies build-base ruby-dev openssl-dev \
    postgresql-dev libc-dev linux-headers && \
    gem install bundler

COPY Gemfile* /tmp/
WORKDIR /tmp
RUN bundle install --without development production \
  && mkdir -p /app \
  && cd /app \
  && apk del build-dependencies

ADD . /app
RUN chown -R nobody:nogroup /app
USER nobody
WORKDIR /app

RUN chmod +x run-tests.sh
CMD ["bundle", "exec", "unicorn", "-p", "8080", "-c", "./config/unicorn.rb"]
