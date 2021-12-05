reload_nginx() {  
  docker exec nginx /usr/sbin/nginx -s reload  
}

zero_downtime_deploy() {  
  service_name=web  
  image_name=hosting.nightingale.is
  old_container_id=$(docker ps | grep "$image_name" | awk '{ print $1 }')

  # bring a new container online, running new code  
  # (nginx continues routing to the old container only)  
  docker-compose up -d --no-deps --scale $service_name=2 --no-recreate $service_name

  # wait for new container to be available  
  new_container_id=$(docker ps | grep "$image_name" | grep -v $old_container_id | awk '{ print $1 }')
  new_container_ip=$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $new_container_id)
  sleep 60 # replace with container health check is the goal here

  echo 'checkpoint 1'
  # start routing requests to the new container (as well as the old)  
  reload_nginx
  
  echo "old id $old_container_id"
  echo "new id $new_container_id"
  # take the old container offline  
  docker stop $old_container_id
  docker rm $old_container_id
  docker-compose up -d --no-deps --scale $service_name=1 --no-recreate $service_name

  # stop routing requests to the old container  
  reload_nginx  
  echo 'script ran to completion'
}

zero_downtime_deploy
