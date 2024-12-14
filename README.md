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

# Implementation
The project is implemented on a Linux VM with Rocky Linux distro. Docker was used to contain the PSQL instance and several bash scripts were created to automate the creation of the PSQL database. For the *host_usage.sh* who collects the usage specs, it was important to automate the data collection by using the *crontab* which is a tool that Linux has.


## Architecture
![Cluster Diagram of the Project with three Linux hosts, a Database and agents](assets/clusterDiagram.svg)

## Scripts
- psql_docker.sh: 
This script is used to automate the Docker container. If the container is stopped, it will start it. 

- host_info.sh:
This script is used to automate the fetching of data with the command `lscpu`. It is then added to the table *host_info.sh*.

- host_usage.sh
This script is used to automate the fetching of usage data with the command `vmstat`. The collected usage data is added to the table *host_usage.sh*.

- crontab
This script is used to automate the fetching of usage data. It is run every minute and if any errors are encountered, it is added to the /tmp/host_usage.log.

- queries.sql
A business problem that could be resolve with this file would be to monitor and optimize the resource utilization but also its host performance. These queries would track all the informations needed in the database and give us better metrics to understand what needs to be refactored. An ongoing data collection allows better understanding of the potential issues that could arise, but also fix before it happens.

## Database Modelling

Table *host_info* :
| Column Name | Data Type | Nullable | Constraints | Description |
| --- | --- | --- | ---| --- |
| id | SERIAL | NO | PRIMARY KEY | Unique identifier for each information |
| hostname | VARCHAR | NO | UNIQUE | Hostname for the machine |
| cpu_number | INT2 | NO | | Number of CPU cores |
| cpu_architecture | VARCHAR | NO |  | CPU architecture |
| cpu_model | VARCHAR | NO | | Model name for the CPU |
| cpu_mhz | FLOAT8 | NO | | CPU clock speed in MHz |
| l2_cache | INT4 | NO | | Size of the L2 cache in KB |
| timestamp | TIMESTAMP | YES | | Timestamp when the record was created |
| total_mem | INT4 | YES | | Total memory available on the host (in KB) |

Table *host_usage* :
| Column Name | Data Type | Nullable | Constraints | Description |
| --- | --- | --- | ---| --- |
| timestamp | TIMESTAMP | NO | | Timestamp for the recorded usage data |
| host_id | SERIAL | NO | FOREIGN KEY REFERENCES *host_info(id)* | Identifier linking to the host in *host_info* |
| memory_free | INT4 | NO |  | Amount of free memory on the host (in KB) |
| cpu_idle | INT2 | NO | | Percentage of CPU time spent idle |
| cpu_kernel | INT2 | NO | | Percentage of CPU time spent in kernel mode |
| disk_io | INT4 | NO | | Disk I/O operations performed |
| disk_available | INT4 | NO | | 	Available disk space on the host (in KB) |

# Test
The files were tested with logs. If any errors were detected, the program will exit with an error code. In any steps, bash commands were verified to ensure that no mistakes were made. For example, to make sure the table host_usage had the information inserted properly, the command ```SELECT * FROM host_usage``` was done and the results were printed on the terminal.

# Deployment
This project was deployed on GitHub to ensure good version control and practices. To also make sure that the environment is well managed, Docker was used. From there, the PSQL instance was pulled directly from their image library to get the newest version of it.  

# Improvements
Several improvements could be done, such as ensuring that all the hardwares are updated properly to collect the most recent data possible. Also, alerts could be sent to the user to warn of excessive usage of the host. It could also be more interesting having more data for the host_info and doing something with that data as well.
