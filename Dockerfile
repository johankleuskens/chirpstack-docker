FROM ubuntu:18.04

RUN apt-get update -qq
RUN apt-get install -y mosquitto 
RUN apt-get install -y mosquitto-clients 
RUN apt-get install -y redis-server redis-tools 
RUN apt-get install -y postgresql

USER postgres
RUN /etc/init.d/postgresql start && \
	psql --command "create role chirpstack_as with login password 'dbpassword';" &&\
	psql --command "create role chirpstack_ns with login password 'dbpassword';" &&\
	psql --command "create database chirpstack_as with owner chirpstack_as;" && \
	psql --command "create database chirpstack_ns with owner chirpstack_ns;" &&\
	psql --command  "\c chirpstack_as" &&\
	psql --command "create extension pg_trgm;" &&\
	psql --command "create extension hstore;"
	
USER root
RUN apt-get install -y apt-transport-https dirmngr
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 1CE2AFD36DBCCA00
RUN echo "deb https://artifacts.chirpstack.io/packages/3.x/deb stable main" | tee /etc/apt/sources.list.d/chirpstack.list
RUN apt-get install -y ca-certificates
RUN	apt-get update

RUN apt-get install chirpstack-network-server
RUN /etc/init.d/chirpstack-network-server start

RUN apt-get install chirpstack-application-server
RUN /etc/init.d/chirpstack-application-server start
	 