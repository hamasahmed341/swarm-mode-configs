






2️⃣ Initialize Docker Swarm (single node)
docker swarm init

1️⃣ Create overlay network (one time):
sudo docker network create \
  --driver overlay \
  --attachable \
  backend_net

1️⃣ Create overlay network (one time):
sudo docker network create \
  --driver overlay \
  --attachable \
  frontend_net



✅ This server becomes:

Manager

Worker

Cluster of 1 node

Check:

sudo docker node ls


//6️⃣ Deploy everything in Swarm

sudo docker stack deploy -c docker-compose.yml prod


sudo docker stack deploy --with-registry-auth -c docker-compose.yml prod

//If this stack partially deployed before, clean it:

sudo docker stack rm prod

docker service update --force prod_mongodb
docker service update --force prod_clickhouse
docker service update --force prod_redis_cache
docker service update --force prod_identity-management
docker service update --force prod_mariadb
docker service update --force prod_frontend
docker service update --force prod_customer-complaint-management
docker service update --force prod_sdk-service-client-handshake
docker service update --force prod_sdk-service-bugs
docker service update --force prod_sdk-service-survey
sudo docker service update --force prod_sdk-service-crashes


//sleep 10

//2️⃣ Check the REAL application error (MOST IMPORTANT)
//Run:

sudo docker service logs prod_identity-management


to force update the service inside running stack to get the network

sudo docker service update --network-add backend_net prod_stripe-webhook


//7️⃣ Check services:

sudo docker service ls


Check replicas:

sudo docker service ps prod_identity-management --no-trunc
sudo docker service ps prod_mariadb --no-trunc
sudo docker service ps prod_mongodb --no-trunc
sudo docker service ps prod_clickhouse --no-trunc
sudo docker service ps prod_redis_cache --no-trunc


8️⃣ Scaling later (one command)

Scale any service:

docker service scale prod_api=4

Zero downtime. Swarm handles it.



<!-- mysql mariadb -->

sudo mysqldump -u root -p fiv2_crashes_collections > fiv2_crashes_collections_11_feb_2026.sql
sudo mysqldump -u root -p fiv2_general > fiv2_general_11_feb_2026.sql
sudo mysqldump -u root -p fiv2_access_control > fiv2_access_control_11_feb_2026.sql
sudo mysqldump -u root -p fiv2_complaints_collections > fiv2_complaints_collections_19_feb_2026.sql

mariadb -u root -p fiv2_crashes_collections < fiv2_crashes_collections_11_feb_2026.sql
mariadb -u root -p fiv2_general < fiv2_general_2026-03-11_14-32-09.sql
mariadb -u root -p fiv2_access_control < fiv2_access_control_11_feb_2026.sql
mariadb -u root -p fiv2_complaints_collections < fiv2_complaints_collections.sql


<!-- move to docker container -->
<!-- sudo docker cp fiv2_complaints_collections_19_feb_2026.sql 4b2dd908bc05:/tmp/fiv2_complaints_collections.sql -->


<!-- Mongo commands -->


mongorestore \
  --username admin \  
  --password dev \
  --authenticationDatabase admin \
 /tmp/mongo_backup

mongosh -u admin -p dev 

db.packagelimits.find().limit(10).pretty()




<!-- clickhouse-client  -->


clickhouse-client --user admin --password="I11TestRoots"

sudo docker cp /home/fusion-staging/create_clickhouse_database_and_tables.sh 6d10104a47fa:/tmp/click-house-schema.sh

/tmp/click-house-schema.sh

SELECT * FROM fiv2_crashes_collections LIMIT 10;

run script to backup from dev

restore the script

CREATE DATABASE IF NOT EXISTS entF8989F91664E4040A705BC4710A61C50




🚀 Faster Method (Select All + Cut)

In nano:

Press Ctrl + Shift + 6 (or Ctrl + ^) → Start selecting

Press Alt + / → Jump to end of file

Press Ctrl + K → Cut everything

Done ✅