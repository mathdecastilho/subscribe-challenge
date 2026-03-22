FROM ruby:4.0.2-slim

WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY .rspec ./
COPY app.rb ./
COPY lib/ ./lib/
COPY spec/ ./spec/

ENTRYPOINT ["ruby", "app.rb"]
