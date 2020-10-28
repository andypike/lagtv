#!/bin/bash

set -ex

get_salt() {
  echo $(head /dev/urandom | LC_ALL=C tr -dc A-Za-z0-9 | head -c 32)
}

# make sure yml exists
if [ ! -f ./config/application.yml ]; then
  HUMAN_SALT=$(get_salt)
  SECRET_TOKEN=$(get_salt)
  sed \
    -e 's/localhost/app/g' \
    -e "s/is_human_salt: \"\"/is_human_salt: \"${HUMAN_SALT}\"/g" \
    -e "s/secret_token: \"\"/secret_token: \"${SECRET_TOKEN}\"/g" \
    ./config/application.example.yml > ./config/application.yml \
  && sed \
    -e 's/localhost/db/g' \
    -e 's/password:/password: password/g' \
    ./config/database.example.yml > ./config/database.yml \
  && cp \
    ./config/newrelic.example.yml ./config/newrelic.yml
fi

# wait until db is ready?
# attempt setup
rake db:setup || true

TEMP_FILE="/app/tmp/pids/server.pid"

# removes server process file on exit
trap "rm -f $TEMP_FILE" EXIT

# makes sure server process file absolutely does not exist before starting
if [[ ("$@" = "rails s") && (-f $TEMP_FILE) ]]; then
  rm -f $TEMP_FILE
fi

# call CMD
exec "$@"