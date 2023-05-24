#!/bin/bash

unalias cp
yum install -y tree git
echo "== STEP 00 Finish =="

mkdir -p /app/softwares
cd /app/softwares
git clone https://gitee.com/tishenme/smallbird-bigdata.git
tree smallbird-bigdata
echo "== STEP 00 Finish =="

yum install -y libicu
rpm -ivh /app/softwares/smallbird-bigdata/component_airflow/airflow_install_v2/linux/postgresql13-libs-13.5-1PGDG.rhel7.x86_64.rpm
rpm -ivh /app/softwares/smallbird-bigdata/component_airflow/airflow_install_v2/linux/postgresql13-13.5-1PGDG.rhel7.x86_64.rpm
rpm -ivh /app/softwares/smallbird-bigdata/component_airflow/airflow_install_v2/linux/postgresql13-server-13.5-1PGDG.rhel7.x86_64.rpm
rpm -ivh /app/softwares/smallbird-bigdata/component_airflow/airflow_install_v2/linux/postgresql13-contrib-13.5-1PGDG.rhel7.x86_64.rpm
systemctl enable postgresql-13
/usr/pgsql-13/bin/postgresql-13-setup initdb
systemctl start postgresql-13
# mkdir -p /app/servers/postgresql/data
# chown -R postgres.postgres /app/servers/postgresql/data
su - postgres <<!
psql -d postgres -c "ALTER USER postgres WITH PASSWORD 'abc123';"
# /usr/pgsql-13/bin/pg_ctl -D /app/servers/postgresql/data initdb
!
# echo "data_directory = '/app/servers/postgresql/data'" >> /var/lib/pgsql/13/data/postgresql.conf
echo "listen_addresses = '*'" >> /var/lib/pgsql/13/data/postgresql.conf
echo "host    all             all             0.0.0.0/0               trust" >> /var/lib/pgsql/13/data/pg_hba.conf
sed -i 's/local   all             all                                     peer/local   all             all                                     trust/' /var/lib/pgsql/13/data/pg_hba.conf
systemctl restart postgresql-13
# show data_directory
psql -d postgres -U postgres << EOF
show data_directory;
\q
EOF
# create role
psql -d postgres -U postgres << EOF
\du+
create role airflow createdb password 'abc123' login;
alter role airflow set search_path = airflow;
\du+
\q
EOF
# create database
PGPASSWORD=abc123 psql -d postgres -U airflow << EOF
\l+
create database airflowdb;
\c airflowdb
create schema airflow;
\dn+
\l+
\q
EOF
echo "== STEP 00 Finish =="

tar zxvf /app/softwares/smallbird-bigdata/component_airflow/airflow_install_v2/linux/sqlite-autoconf-3370200.tar.gz -C /app/softwares
cd /app/softwares/sqlite-autoconf-3370200
./configure --prefix=/usr/local
make && make install
mv /usr/bin/sqlite3 /usr/bin/sqlite3_old
ln -s /usr/local/bin/sqlite3 /usr/bin/sqlite3
echo "/usr/local/lib" > /etc/ld.so.conf.d/sqlite3.conf
ldconfig
sqlite3 -version
echo "== STEP 00 Finish =="

pip3 install --upgrade pip
pip3 install --upgrade setuptools
echo "== STEP 01 Finish =="

AIRFLOW_VERSION=2.2.2
# CONSTRAINT_URL="https://raw.githubusercontent.com/apache/airflow/constraints-2.2.2/constraints-3.7.txt"
# CONSTRAINT_URL="https://raw.githubusercontent.com/apache/airflow/constraints-2.2.2/constraints-3.9.txt"
CONSTRAINT_URL="/app/softwares/smallbird-bigdata/component_airflow/airflow_install_v2/python/requirement_airflow_2.2.2_3.9.txt"
pip3 install "apache-airflow[google,google_auth,github_enterprise,ldap,leveldb,mysql,postgres,ssh]==${AIRFLOW_VERSION}" --constraint "${CONSTRAINT_URL}"
echo "== STEP 02 Finish =="

cp -f /app/softwares/smallbird-bigdata/component_airflow/airflow_install_v2/systemd/*.service /usr/lib/systemd/system
cp -f /app/softwares/smallbird-bigdata/component_airflow/airflow_install_v2/systemd/airflow.conf /usr/lib/tmpfiles.d
cp -f /app/softwares/smallbird-bigdata/component_airflow/airflow_install_v2/systemd/airflow /etc/sysconfig
mkdir -p /run/airflow
mkdir -p /app/servers/airflow
mkdir -p /app/servers/airflow/dags
echo "== STEP 03 Finish =="

echo "export AIRFLOW_HOME=/app/servers/airflow" >> /etc/profile
source /etc/profile
echo "== STEP 04 Finish =="

systemctl enable airflow-webserver.service
systemctl enable airflow-scheduler.service
airflow --version
ll /app/servers/airflow
echo "== STEP 05 Finish =="

sed -i 's/load_examples = True/load_examples = False/' /app/servers/airflow/airflow.cfg
sed -i 's/default_ui_timezone = UTC/default_ui_timezone = Asia\/Shanghai/' /app/servers/airflow/airflow.cfg
sed -i 's/default_timezone = utc/default_timezone = Asia\/Shanghai/' /app/servers/airflow/airflow.cfg
sed -i 's/web_server_port = 8080/web_server_port = 80/' /app/servers/airflow/airflow.cfg
sed -i 's/auth_backend = airflow.api.auth.backend.deny_all/auth_backend = airflow.api.auth.backend.default/' /app/servers/airflow/airflow.cfg
sed -i 's/executor = SequentialExecutor/executor = LocalExecutor/' /app/servers/airflow/airflow.cfg
sed -i "s/sql_alchemy_conn = sqlite:\/\/\/\/app\/servers\/airflow\/airflow.db/sql_alchemy_conn = postgresql+psycopg2:\/\/airflow:abc123@192.168.52.100:5432\/airflowdb/" /app/servers/airflow/airflow.cfg
echo "== STEP 07 Finish =="

airflow db init
# airflow db reset
echo "== STEP 08 Finish =="

systemctl stop airflow-webserver.service
systemctl stop airflow-scheduler.service
systemctl start airflow-webserver.service
systemctl start airflow-scheduler.service
sleep 10
echo "== STEP 09 Finish =="

airflow users delete -u admin
airflow users create -r Admin -u admin -e airflow@apache.com -f Airflow -l Apache -p admin
airflow list_users
echo "== STEP 10 Finish =="

ps -ef | grep airflow
echo "== STEP 11 Finish =="

tree /app/servers/airflow
echo "== STEP 12 Finish =="

# http://192.168.52.100:80

# tail -f /app/servers/airflow/logs/dag_processor_manager/dag_processor_manager.log

# systemctl status airflow-webserver.service
# systemctl status airflow-scheduler.service

# systemctl stop airflow-webserver.service
# systemctl stop airflow-scheduler.service
# systemctl disable airflow-webserver.service
# systemctl disable airflow-scheduler.service

# rm -rf /app/servers/airflow
# rm -rf /run/airflow

