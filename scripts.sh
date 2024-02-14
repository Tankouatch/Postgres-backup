kubectl create secret docker-registry myregistrykey \
--docker-server=https://index.docker.io/v1/ \
--docker-username=tankouatc \
--docker-password=auafhlahfufhahhrrarr \
--docker-email=tankouatc@gmail.com

kubectl create configmap db-config \
  --from-literal=DB_USER=doadmin \
  --from-literal=DB_HOST="db-postgresql-nyc3-26515-do-user-12198957-0.c.db.ondigitalocean.com" \
  --from-literal=DB_NAME=s6-user