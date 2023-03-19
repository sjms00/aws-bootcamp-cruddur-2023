# Week 4 — Postgres and RDS

I created an db instance and a database with aws cli
Info in : https://docs.aws.amazon.com/cli/latest/reference/rds/create-db-instance.html
I use this command:

## Provision RDS Instance

```sh
aws rds create-db-instance \
  --db-instance-identifier cruddur-db-instance \
  --db-instance-class db.t3.micro \
  --engine postgres \
  --engine-version  14.6 \
  --master-username crudurroot \
  --master-user-password ******** \
  --allocated-storage 20 \
  --availability-zone us-east-1a \
  --backup-retention-period 0 \
  --port 5432 \
  --no-multi-az \
  --db-name cruddur \
  --storage-type gp2 \
  --publicly-accessible \
  --storage-encrypted \
  --enable-performance-insights \
  --performance-insights-retention-period 7 \
  --no-deletion-protection
```


![create_database](_docs/assets/week4/create_database.png) 

I stopped temporaly the database created and I try to connect to the docker database postgres
To connect to psql via the psql client cli tool remember to use the host flag to specific localhost.

```
psql -Upostgres --host localhost
```
And create a database named cruddr with:

```sql
CREATE database cruddur;
```

And list the databases:

![connect_database_list](_docs/assets/week4/connect_database_list.png)



Common PSQL commands:

```sql
\x on -- expanded display when looking at data
\q -- Quit PSQL
\l -- List all databases
\c database_name -- Connect to a specific database
\dt -- List all tables in the current database
\d table_name -- Describe a specific table
\du -- List all users and their roles
\dn -- List all schemas in the current database
CREATE DATABASE database_name; -- Create a new database
DROP DATABASE database_name; -- Delete a database
CREATE TABLE table_name (column1 datatype1, column2 datatype2, ...); -- Create a new table
DROP TABLE table_name; -- Delete a table
SELECT column1, column2, ... FROM table_name WHERE condition; -- Select data from a table
INSERT INTO table_name (column1, column2, ...) VALUES (value1, value2, ...); -- Insert data into a table
UPDATE table_name SET column1 = value1, column2 = value2, ... WHERE condition; -- Update data in a table
DELETE FROM table_name WHERE condition; -- Delete data from a table
```

## Create (and dropping) our database

We can use the createdb command to create our database:

https://www.postgresql.org/docs/current/app-createdb.html

```
createdb cruddur -h localhost -U postgres
```

```sh
psql -U postgres -h localhost
```

```sql
DROP database cruddur;
```

We can create the database within the PSQL client

```sql
CREATE database cruddur;
```


We can use the next to login in database:

```sh
psql postgresql://postgres:password@localhost:5432/cruddur
```

or:

```sh
export CONNECTION_URL="postgresql://postgres:password@localhost:5432/cruddur"
psql $CONNECTION_URL
```

![connect_database_env](_docs/assets/week4/connect_database_env.png)


we create the connection URL's vars in local and prod database:

```sh
export CONNECTION_URL="postgresql://postgres:******@localhost:5432/cruddur"
gp env CONNECTION_URL="postgresql://postgres:******@localhost:5432/cruddur"

export PROD_CONNECTION_URL="postgresql://cruddurroot:******@cruddur-db-instance.czgmtaw1bmat.us-east-1.rds.amazonaws.com:5432/cruddur"
gp env PROD_CONNECTION_URL="postgresql://cruddurroot:******@cruddur-db-instance.czgmtaw1bmat.us-east-1.rds.amazonaws.com:5432/cruddur"
```


## Import Script

We'll create a new SQL file called `schema.sql`
and we'll place it in `backend-flask/db`


## Add UUID Extension

We are going to have Postgres generate out UUIDs.
We'll need to use an extension called:

```sql
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
```

## Create our tables

https://www.postgresql.org/docs/current/sql-createtable.html

add the next sql statments:

At the beginig we add the drop tables if existx:

```sql
DROP TABLE IF EXISTS public.users;
DROP TABLE IF EXISTS public.activities;
```

```sql
CREATE TABLE public.users (
  uuid UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  display_name text NOT NULL,
  handle text NOT NULL,
  email text NOT NULL,
  cognito_user_id text NOT NULL,
  created_at TIMESTAMP default current_timestamp NOT NULL
);
```

```sql
CREATE TABLE public.activities (
  uuid UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_uuid UUID NOT NULL,
  message text NOT NULL,
  replies_count integer DEFAULT 0,
  reposts_count integer DEFAULT 0,
  likes_count integer DEFAULT 0,
  reply_to_activity_uuid integer,
  expires_at TIMESTAMP,
  created_at TIMESTAMP default current_timestamp NOT NULL
);
```

And in the backend-flask root directory we execute:

```sh
psql -Upostgres cruddur < db/schema.sql -h localhost
```

## Automatically updating a timestamp column in PostgreSQL using Triggers

https://aviyadav231.medium.com/automatically-updating-a-timestamp-column-in-postgresql-using-triggers-98766e3b47a0

```sql
DROP FUNCTION IF EXISTS func_updated_at();
CREATE FUNCTION func_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ language 'plpgsql';
```

```sql
CREATE TRIGGER trig_users_updated_at 
BEFORE UPDATE ON users 
FOR EACH ROW EXECUTE PROCEDURE func_updated_at();
CREATE TRIGGER trig_activities_updated_at 
BEFORE UPDATE ON activities 
FOR EACH ROW EXECUTE PROCEDURE func_updated_at();
```

```sql
DROP TRIGGER IF EXISTS trig_users_updated_at ON users;
DROP TRIGGER IF EXISTS trig_activities_updated_at ON activities;
```

## Shell Script to Connect to DB

For things we commonly need to do we can create a new directory called `bin`

We'll create an new folder called `bin` to hold all our bash scripts.

```sh
mkdir /workspace/aws-bootcamp-cruddur-2023/backend-flask/bin
```

```sh
export CONNECTION_URL="postgresql://postgres:pssword@127.0.0.1:5433/cruddur"
gp env CONNECTION_URL="postgresql://postgres:pssword@127.0.0.1:5433/cruddur"
```

We'll create a new bash script `bin/db-connect`

```sh
#! /usr/bin/bash

psql $CONNECTION_URL
```

We'll make it executable:

```sh
chmod u+x bin/db-connect
```

To execute the script:
```sh
./bin/db-connect
```

## Shell script to drop the database

`bin/db-drop`

```sh
#! /usr/bin/bash

CYAN='\033[1;36m'
NO_COLOR='\033[0m'
LABEL="db-drop"
printf "${CYAN}== ${LABEL}${NO_COLOR}\n"

NO_DB_CONNECTION_URL=$(sed 's/\/cruddur//g' <<<"$CONNECTION_URL")
psql $NO_DB_CONNECTION_URL -c "drop database cruddur;"
```
![drop_create_db_script](_docs/assets/week4/drop_create_db_script.png) 

https://askubuntu.com/questions/595269/use-sed-on-a-string-variable-rather-than-a-file

## See what connections we are using


We'll create a new bash script `bin/db-sessions`

```sh
#! /usr/bin/bash
CYAN='\033[1;36m'
NO_COLOR='\033[0m'
LABEL="db-sessions"
printf "${CYAN}== ${LABEL}${NO_COLOR}\n"

if [ "$1" = "prod" ]; then
  echo "Running in production mode"
  URL=$PROD_CONNECTION_URL
else
  URL=$CONNECTION_URL
fi

NO_DB_URL=$(sed 's/\/cruddur//g' <<<"$URL")
psql $NO_DB_URL -c "select pid as process_id, \
       usename as user,  \
       datname as db, \
       client_addr, \
       application_name as app,\
       state \
from pg_stat_activity;"
```

We can see the sessions opened in the database:

![sessions_script](_docs/assets/week4/sessions_script.png) 

> We could have idle connections left open by our Database Explorer extension, try disconnecting and checking again the sessions 

## Shell script to create the database

`bin/db-create`

```sh
#! /usr/bin/bash

CYAN='\033[1;36m'
NO_COLOR='\033[0m'
LABEL="db-create"
printf "${CYAN}== ${LABEL}${NO_COLOR}\n"

NO_DB_CONNECTION_URL=$(sed 's/\/cruddur//g' <<<"$CONNECTION_URL")
psql $NO_DB_CONNECTION_URL -c "create database cruddur;"
```

![drop_create_db_script](_docs/assets/week4/drop_create_db_script.png) 

## Shell script to load the schema

`bin/db-schema-load`

```sh
#! /usr/bin/bash

CYAN='\033[1;36m'
NO_COLOR='\033[0m'
LABEL="db-schema-load"
printf "${CYAN}== ${LABEL}${NO_COLOR}\n"

schema_path="$(realpath .)/db/schema.sql"
echo $schema_path

if [ "$1" = "prod" ]; then
  echo "Running in production mode"
  URL=$PROD_CONNECTION_URL
else
  URL=$CONNECTION_URL
fi

psql $URL cruddur < $schema_path
```
And executed in backend-flask directory:

![drop_create_db_script](_docs/assets/week4/drop_create_db_script.png) 

## Shell script to load the seed data

Create the script backend-flask/bin/db-seed
```
#! /usr/bin/bash

CYAN='\033[1;36m'
NO_COLOR='\033[0m'
LABEL="db-seed"
printf "${CYAN}== ${LABEL}${NO_COLOR}\n"

seed_path="$(realpath .)/db/seed.sql"
echo $seed_path

if [ "$1" = "prod" ]; then
  echo "Running in production mode"
  URL=$PROD_CONNECTION_URL
else
  URL=$CONNECTION_URL
fi

psql $URL cruddur < $seed_path
```

Create the file for the seed in backend-flask/db/seed.sql

```sql
-- this file was manually created
INSERT INTO public.users (display_name, handle, email, cognito_user_id)
VALUES
  ('Jordi Morreres', 'jordimorreres' , 'jxxx@gmail.com', 'MOCK'),
  ('Andrew Bayko2', 'bayko2' , 'qxxxx@gmail.com', 'MOCK');

INSERT INTO public.activities (user_uuid, message, expires_at)
VALUES
  (
    (SELECT uuid from public.users WHERE users.handle = 'jordimorreres' LIMIT 1),
    'This was imported as seed Jordi data!',
    current_timestamp + interval '10 day'
  )
```

we try to execute backend-flask/bin/db-seed 

![seed_script](_docs/assets/week4/seed_script.png)

## Easily setup (reset) everything for our database

to recreate,load the cruddur database will create the script backend-flask/bin/db-setup to do all this:

```sh
#! /usr/bin/bash
-e # stop if it fails at any point

CYAN='\033[1;36m'
NO_COLOR='\033[0m'
LABEL="db-setup"
printf "${CYAN}==== ${LABEL}${NO_COLOR}\n"

bin_path="$(realpath .)/bin"

source "$bin_path/db-drop"
source "$bin_path/db-create"
source "$bin_path/db-schema-load"
source "$bin_path/db-seed"
```

![setup_script](_docs/assets/week4/setup_script.png)


## Make prints nicer

We we can make prints for our shell scripts coloured so we can see what we're doing:

https://stackoverflow.com/questions/5947742/how-to-change-the-output-color-of-echo-in-linux


```sh
CYAN='\033[1;36m'
NO_COLOR='\033[0m'
LABEL="db-schema-load"
printf "${CYAN}== ${LABEL}${NO_COLOR}\n"
```

## Install Postgres Client

We need to set the env var for our backend-flask application:

```yml
  backend-flask:
    environment:
      CONNECTION_URL: "${CONNECTION_URL}"
```

https://www.psycopg.org/psycopg3/

We'll add the following to our `requirments.txt`

```
psycopg[binary]
psycopg[pool]
```

```
pip install -r requirements.txt
```

## DB Object and Connection Pool


`lib/db.py`

```py
from psycopg_pool import ConnectionPool
import os

def query_wrap_object(template):
  sql = f"""
  (SELECT COALESCE(row_to_json(object_row),'{{}}'::json) FROM (
  {template}
  ) object_row);
  """
  return sql

def query_wrap_array(template):
  sql = f"""
  (SELECT COALESCE(array_to_json(array_agg(row_to_json(array_row))),'[]'::json) FROM (
  {template}
  ) array_row);
  """
  return sql

connection_url = os.getenv("CONNECTION_URL")
pool = ConnectionPool(connection_url)
'''

In our home activities we'll replace our mock endpoint with real api call:

```py
from lib.db import pool, query_wrap_object, query_wrap_array

      sql = query_wrap_array("""
      SELECT
        activities.uuid,
        users.display_name,
        users.handle,
        activities.message,
        activities.replies_count,
        activities.reposts_count,
        activities.likes_count,
        activities.reply_to_activity_uuid,
        activities.expires_at,
        activities.created_at
      FROM public.activities
      LEFT JOIN public.users ON users.uuid = activities.user_uuid
      ORDER BY activities.created_at DESC
      """)
      print(sql)
      with pool.connection() as conn:
        with conn.cursor() as cur:
          cur.execute(sql)
          # this will return a tuple
          # the first field being the data
          json = cur.fetchone()
      return json[0]
```

And test the app

![backend_db](_docs/assets/week4/backend_db.png)

## Connect to RDS via Gitpod

In order to connect to the RDS instance we need to provide our Gitpod IP and whitelist for inbound traffic on port 5432.

```sh
GITPOD_IP=$(curl ifconfig.me)
```

We'll create an inbound rule for Postgres (5432) and provide the GITPOD ID.

We'll get the security group rule id so we can easily modify it in the future from the terminal here in Gitpod.

```sh
export DB_SG_ID="sg-8a2c86ba"
gp env DB_SG_ID="sg-8a2c86ba"
export DB_SG_RULE_ID="sgr-067133a5a49d3ed1b"
gp env DB_SG_RULE_ID="sgr-067133a5a49d3ed1b"
```

Whenever we need to update our security groups we can do this for access.
```sh    
aws ec2 modify-security-group-rules \
    --group-id $DB_SG_ID \
    --security-group-rules "SecurityGroupRuleId=$DB_SG_RULE_ID,SecurityGroupRule={Description=Gitpod,IpProtocol=tcp,FromPort=5432,ToPort=5432,CidrIpv4=$GITPOD_IP/32}"

```

https://docs.aws.amazon.com/cli/latest/reference/ec2/modify-security-group-rules.html#examples

## Test remote access

We'll update your URL for production use case

```sh
export PROD_CONNECTION_URL="postgresql://cruddurroot:******@cruddur-db-instance.czgmtaw1bmat.us-east-1.rds.amazonaws.com:5432/cruddur"
gp env PROD_CONNECTION_URL="postgresql://cruddurroot:******@cruddur-db-instance.czgmtaw1bmat.us-east-1.rds.amazonaws.com:5432/cruddur"
```

We'll test that it works in Gitpod:

``` sh
psql $PROD_CONNECTION_URL
```

![prod_connection](_docs/assets/week4/prod_connection.png)


## Update Bash scripts for production

```sh
if [ "$1" = "prod" ]; then
  echo "Running in production mode"
else
  echo "Running in development mode"
fi
```

We'll update:
- db-connect
- db-schema-load

## Update Gitpod IP on new env var

We'll add a command step for postgres in gitpod.yml:

```sh
   command: |
      export GITPOD_IP=$(curl ifconfig.me)
      source "$THEIA_WORKSPACE_ROOT/backend-flask/bin/rds-update-sg-rule"
```

And test the connection to aws postgres with the script in backend directory:

``` sh
./bin/db-connect prod
```
![prod_connection2](_docs/assets/week4/prod_connection2.png)

## Load schema in prod

In backend directory , we execute:

``` sh
./bin/db-schema-load prod
```

![prod_connection2](_docs/assets/week4/prod_connection2.png)

## Setup Cognito post confirmation lambda

### Create the handler function

- Create lambda in same vpc as rds instance Python 3.8
- Add a layer for psycopg2 with one of the below methods for development or production 

ENV variables needed for the lambda environment.

First add the variable CONNECTION_URL in docker_compose.yml

```
environment:
      CONNECTION_URL: "${PROD_CONNECTION_URL}"'
```
and then add this var in ENV variables in lambda function

The function, add a copy in aws/lambdas/cruddur-post-confirrmation.py

```
import json
import psycopg2
import os

def lambda_handler(event, context):
    user = event['request']['userAttributes']
    print('userAttributes')
    print(user)

    user_display_name  = user['name']
    user_email         = user['email']
    user_handle        = user['preferred_username']
    user_cognito_id    = user['sub']
    try:
      print('entered-try')
      sql = f"""
         INSERT INTO public.users (
          display_name, 
          email,
          handle, 
          cognito_user_id
          ) 
        VALUES(
          '(user_display_name)',
          '(user_email)',
          '(user_hadle)',
          '(user_cognito_id)'
        )
      """
      print('SQL Statement ----')
      print(sql)
      conn = psycopg2.connect(os.getenv('CONNECTION_URL'))
      cur = conn.cursor()
      cur.execute(sql)
      conn.commit() 

    except (Exception, psycopg2.DatabaseError) as error:
      print(error)
    finally:
      if conn is not None:
          cur.close()
          conn.close()
          print('Database connection closed.')
    return event
```

### Development
https://github.com/AbhimanyuHK/aws-psycopg2

`
This is a custom compiled psycopg2 C library for Python. Due to AWS Lambda missing the required PostgreSQL libraries in the AMI image, we needed to compile psycopg2 with the PostgreSQL libpq.so library statically linked libpq library instead of the default dynamic link.
`

`EASIEST METHOD`

Some precompiled versions of this layer are available publicly on AWS freely to add to your function by ARN reference.

https://github.com/jetbridge/psycopg2-lambda-layer

- Just go to Layers + in the function console and add a reference for my region

`arn:aws:lambda:us-east-1:898466741470:layer:psycopg2-py38:2`

![lambda_layer](_docs/assets/week4/lambda_layer.png)


Alternatively you can create your own development layer by downloading the psycopg2-binary source files from https://pypi.org/project/psycopg2-binary/#files

- Download the package for the lambda runtime environment: [psycopg2_binary-2.9.5-cp311-cp311-manylinux_2_17_x86_64.manylinux2014_x86_64.whl](https://files.pythonhosted.org/packages/36/af/a9f06e2469e943364b2383b45b3209b40350c105281948df62153394b4a9/psycopg2_binary-2.9.5-cp311-cp311-manylinux_2_17_x86_64.manylinux2014_x86_64.whl)

- Extract to a folder, then zip up that folder and upload as a new lambda layer to your AWS account

### Production

Follow the instructions on https://github.com/AbhimanyuHK/aws-psycopg2 to compile your own layer from postgres source libraries for the desired version.


## Add the function to Cognito 

Under the user pool properties add the function as a `Post Confirmation` lambda trigger.

Test the singup:

The logs Ok
![singup_lambda](_docs/assets/week4/singup_lambda.png)

And an user inserted in DB:

![singup_lambda_user_db](_docs/assets/week4/singup_lambda_user_db.png)


### Create Activities

I made the updates to create activities in:

create_activities.py
home_activities.py
app.py  (hardcode user_handle)
and new templates  **.sql

It's works, but I hardcoded the user_handle with my user

![create_activities](_docs/assets/week4/create_activities.png)
