FROM ruby:1.9

WORKDIR /app

# needs a JavaScript runtime
RUN apt-get update && apt-get install -y \
  nodejs \
  && rm -rf /var/lib/apt/lists/*

# more secure and less warnings running as non-root user
RUN groupadd --gid 1000 ruby \
  && useradd --uid 1000 --gid ruby --shell /bin/bash --create-home ruby \
  && chown -R ruby:ruby ${GEM_HOME} \
  && chmod -R 755 ${GEM_HOME}

USER ruby

COPY --chown=ruby:ruby Gemfile* ./

RUN bundle

COPY --chown=ruby:ruby . .

EXPOSE 3000

# need an entrypoint to run rake db:setup when db is ready
ENTRYPOINT [ "/app/docker-entrypoint.sh" ]

CMD [ "rails", "s" ]