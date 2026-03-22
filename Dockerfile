FROM ruby:4.0.2-slim

WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY app.rb ./

ENTRYPOINT ["ruby", "app.rb"]
