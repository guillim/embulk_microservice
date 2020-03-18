# Embulk as a Micro-service

This project aims to facilitate deploying embulk as a micro-service through SSH tunneling

### What is does

1. Connect to your database 1
2. Do a job like converting from Db1 to Db2 (as specified in the configuration.yml file)  
3. Connect to your database 2 and write the Embulk output

Every connection is done using SSH tunneling.


Example, with Mongo (database 1) and Postgres (database 2) :  
![example](https://ibin.co/5FnkVGGw3Jej.png)

### Can it be on hosted on PAAS ?

Yes, you can host it on heroku for instance, or on your own server.

### How can I install it ?

Pre requisite : you need Docker installed on your machine

Then, you have to :
- put your ssh key (the private part) in the .ssh folder as _keyexample_ or _default_env_SSHKEY_ according to your environment_variables you will define next step => this key will allow this machine to connect to the remote database so you need also to make sure the remote machines will allow the connection with a public key
- customize the environment variables in the environment_variables.txt file according to the different IP of your servers etc...
- modify configuration_example.yml according to your needs (see [embulk website](https://www.embulk.org/docs/) for more details)
- run `docker build --tag embulk_container . && docker run --env-file=environment_variables.txt -it embulk_container bash` to launch the process
