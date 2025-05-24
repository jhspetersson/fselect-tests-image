FROM ubuntu

COPY ./run_tests.sh /opt
COPY ./fs /opt/fs
COPY ./tests /opt/tests