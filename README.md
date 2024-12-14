# Introduction
This project was designed to learn more about the Linux environment that we set up with the Jarvis Remote Desktop. The technologies used were Docker, PSQL, Bash script and Git. 

Specifically, we have created a Docker container with a PSQL instance and a new volume mapped to the container. The database created has two tables: one containing information on the hardware specifications of this VM and another one storing the resource usage data. The bash scripts were added to automate the retrieval of these two types of data. For the resource usage table, a crontab file was created to run the resource usage data script every minute. 

# Quick Start
Assuming the user has a Docker container with the PSQL instance and volume attached, the user will need to run:
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
The project is implemented on a Linux VM with the Rocky Linux distro. Docker was used to contain the PSQL instance and several Bash scripts were created to automate the creation and management of the PSQL database. For the *host_usage.sh*, which collects the usage specs, automation was achieved using crontab, a native Linux tool.

## Architecture
![Cluster Diagram of the Project with three Linux hosts, a Database and agents](assets/clusterDiagram.svg)

## Scripts
- psql_docker.sh: 
This script is used to automate the Docker container management. If the container is stopped, it will start it. 

- host_info.sh:
This script fetches hardware specification data using the command `lscpu` and inserts it into the table *host_info.sh*.

- host_usage.sh:
This script fetches usage data using the command `vmstat`. The collected data is then inserted into the table *host_usage.sh*.

- crontab: 
This file is used to automate the execution of the *host_usage.sh* script every minute. Any errors encountered are logged to `/tmp/host_usage.log`.

- queries.sql:
This file contains SQL queries that address the business problem of monitoring and optimizing resource utilization and host performance. These queries track critical information in the database, providing insights into potential issues and enabling proactive fixes.

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
The files were tested with logs. If any errors were detected, the program exited with an error code. Throughout all steps, Bash commands were verified to ensure correctness. For instance, to confirm that the table *host_usage* was correctly populated, the following command was executed, and results were inspected:

```SELECT * FROM host_usage```

# Deployment
This project was deployed on GitHub to ensure good version control and best practices. Docker was used to maintain an isolated environment, with the PSQL instance pulled directly from the Docker image library to ensure the latest version.

# Improvements
Several improvements could be made:
- Ensuring that all hardware components are updated regularly to collect the most accurate data.
- Adding alerting mechanisms to notify users of excessive resource usage or potential performance issues.
- Expanding the *host_info* table to include more detailed hardware specifications and leveraging that data for advanced analytics.
