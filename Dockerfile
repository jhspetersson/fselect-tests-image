FROM ubuntu

COPY ./fs /opt/fs
COPY ./tests /opt/tests
COPY ./run_tests.sh /opt