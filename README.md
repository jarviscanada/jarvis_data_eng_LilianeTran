# Introduction
This project was designed to learn more about the Linux environment that we set up with the Jarvis Remote Desktop. The technologies used were Docker, PSQL, Bash script and Git. 
To be exact, we have created a Docker container that had a PSQL instance and a new volume mapped to the container. The database created has two tables which one contains information on the hardware specifications of this VM and another one which stores the resource usage data. The bash scripts were added to automate the retrieval of these two data needed. For the resource usage database, a crontab file was created to have the bash script for the resource usage data run every minute. 

# Quick Start
Assuming the user has a Docker container with the psql instance and volume attached, the user will need to run:
```
./scripts/psql_docker.sh start ${PGPASSWORD}
psql -h ${host} -U ${user} -W ./scripts/sql/ddl.sql

```

The script *host_info.sh* allows the insertion of hardware specs data, the following command will run the script:
```
bash ./scripts/host_info.sh psql_host psql_port db_name psql_user psql_password
```

The script *host_usage.sh* allows the insertion of usage specs data, the following command will run the script:
```
bash ./scripts/host_usage.sh psql_host psql_port db_name psql_user psql_password
```

The crontab which allows automated scripts to be run must have the following:

```
crontab -e

#The following line makes the file run every minute
* * * * * bash ${path}/host_usage.sh psql_host psql_port db_name psql_user psql_password > /tmp/host_usage.log

cat /tmp/host_usage.log
```


