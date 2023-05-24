#!/bin/bash

yum install -y tree git
unalias cp
mkdir -p /app/softwares
cd /app/softwares
git clone https://gitee.com/tishenme/smallbird-bigdata.git
tree smallbird-bigdata
echo "== STEP 00 Finish =="


pip3 install --upgrade pip
pip3 install --upgrade setuptools
pip3 install --no-cache-dir -U crcmod
pip3 install --use-feature=2020-resolver pytest-runner 
pip3 install --use-feature=2020-resolver email_validator
echo "== STEP 01 Finish =="


# pip3 install --use-feature=2020-resolver apache-airflow[all]==1.10.15
pip3 install --use-feature=2020-resolver apache-airflow[crypto,gcp,github_enterprise,google_auth,ldap,mysql,postgres,ssh]==1.10.15
pip3 install --use-feature=2020-resolver werkzeug==0.16.0
pip3 install --use-feature=2020-resolver pyldap
pip3 uninstall -y SQLAlchemy
pip3 install --use-feature=2020-resolver SQLAlchemy==1.3.24
echo "== STEP 02 Finish =="


cp -f /app/softwares/smallbird-bigdata/component_airlfow/airflow_install/systemd/*.service /usr/lib/systemd/system
cp -f /app/softwares/smallbird-bigdata/component_airlfow/airflow_install/systemd/airflow.conf /usr/lib/tmpfiles.d
cp -f /app/softwares/smallbird-bigdata/component_airlfow/airflow_install/systemd/airflow /etc/sysconfig
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
sed -i 's/rbac = False/rbac = True/' /app/servers/airflow/airflow.cfg
sed -i 's/executor = SequentialExecutor/executor = LocalExecutor/' /app/servers/airflow/airflow.cfg
sed -i 's/sql_alchemy_conn = sqlite:\/\/\/\/app\/servers\/airflow\/airflow.db/sql_alchemy_conn = postgresql+psycopg2:\/\/airflow:abc123@192.168.52.201:5432\/airflowdb/' /app/servers/airflow/airflow.cfg
echo "== STEP 07 Finish =="


airflow db init
# airflow db reset
cp -f /app/softwares/smallbird-bigdata/component_airlfow/airflow_app/webserver_config_1.10.15_b.py /app/servers/airflow/webserver_config.py
cat /app/servers/airflow/webserver_config.py
echo "== STEP 08 Finish =="


systemctl stop airflow-webserver.service
systemctl stop airflow-scheduler.service
systemctl start airflow-webserver.service
systemctl start airflow-scheduler.service
sleep 10
echo "== STEP 09 Finish =="


airflow users delete -u admin
airflow users create -r Admin -u admin -e airflow@apache.com -f Airflow -l Apache -p abc123
airflow list_users
echo "== STEP 10 Finish =="


ps -ef | grep airflow
echo "== STEP 11 Finish =="


tree /app/servers/airflow
echo "== STEP 12 Finish =="


# http://192.168.52.202:80

# tail -f /app/servers/airflow/logs/dag_processor_manager/dag_processor_manager.log

# systemctl stop airflow-webserver.service
# systemctl stop airflow-scheduler.service
# systemctl disable airflow-webserver.service
# systemctl disable airflow-scheduler.service
# rm -rf /app/servers/airflow
# rm -rf /run/airflow

