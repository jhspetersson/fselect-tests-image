FROM ubuntu

RUN apt-get update -qq && apt-get install -y -qq zip > /dev/null 2>&1 && rm -rf /var/lib/apt/lists/*

COPY ./run_tests.sh /opt
COPY ./fs /opt/fs
COPY ./tests /opt/tests