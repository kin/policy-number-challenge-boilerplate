# syntax=docker/dockerfile:1
FROM ruby:3.2-slim

WORKDIR /app

# Gems install to /usr/local/bundle (outside /app), so bind-mounting the
# project directory at runtime never shadows installed gems.
COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .

ENTRYPOINT ["bundle", "exec"]
CMD ["bin/policy_ocr"]
