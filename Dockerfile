FROM ruby:4.0.2-slim

WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY sales_taxes.rb ./

ENTRYPOINT ["ruby", "sales_taxes.rb"]
