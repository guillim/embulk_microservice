# Embulk as a Micro-service

This project aims to facilitate deploying embulk as a micro-service through SSH tunneling

### What is does

1. Connect to your database 1
2. Do a job like converting from Db1 to Db2 (as mentioned in the configuration.yml file)  
3. Connect to your database 2 and write the Embulk output

Every connection is done using SSH tunneling.


Example, with Mongo (database 1) and Postgres (database 2) :  
![example](https://ibin.co/5FnkVGGw3Jej.png)

### Can it be on hosted on PAAS ?

Yes, you can host it on heroku for instance.

### How can I install it ?

Pre requisite : you need Docker installed on your machine

Then, you have to :
- put your ssh key (private) in the .ssh folder => this key will allow this machine to connect to the remote database
- customize the environment variables in the environment_variables.txt file
- copy configuration_example.yml to configuration.yml and modify it according to your needs
- run `docker build --tag embulk_container .`
- run `docker run --env-file=environment_variables.txt -it embulk_container bash`
