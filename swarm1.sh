#!/bin/bash

#####监控service，失败的进行重新部署该脚本要结合我的博客文章https://linuxwt.com/gou-jian-ji-yu-dockerde-wei-fu-wu###
service_delete () {
    docker service rm $service
    sleep 5
}

service_deploy () {
    cd /root/docker/$name
    docker stack deploy -c docker-compose.yml $node
    sleep 60
}

service_array=(150_gitlab 150_jenkins  151_grafana 151_jaeger 151_kibana 150_openldap 151_mysql 151_nacos 151_postgres 151_prometheus 151_redis 152_elasticsearch 152_logstash 152_nexus manager_agent manager_portainer)

for service  in ${service_array[@]}
do
    name=$(echo $service | awk -F '_' '{print $2}')
    node=$(echo $service | awk -F '_' '{print $1}')
    s_state=$(docker service ls | tr -s " " | cut -d " " -f2,4 | grep $service | awk '{print $2}' | awk  -F  '/' '{print $1}')
    s_exist=$(docker service ls | tr -s " " | cut -d " " -f2,4 | grep $service | wc -l)

    if [ ${s_exist} -eq 0 ];then
        service_deploy 
        p_state=$(docker service ls | tr -s " " | cut -d " " -f2,4 | grep $service | awk '{print $2}' | awk -F  '/' '{print $1}')
        p_exist=$(docker service ls | tr -s " " | cut -d " " -f2,4 | grep $service | wc -l)
        [[  ${p_exist} -eq 1 && ${p_state} -eq 0 ]] && { echo "$service deploy failed";exit -1; }
    else
        [[  ${s_exist} -eq 1 && ${s_state} -eq 0 ]] && service_delete && service_deploy
        q_state=$(docker service ls | tr -s " " | cut -d " " -f2,4 | grep $service | awk '{print $2}' | awk -F  '/' '{print $1}')
        q_exist=$(docker service ls | tr -s " " | cut -d " " -f2,4 | grep $service | wc -l)
        [[  ${q_exist} -eq 1 && ${q_state} -eq 0 ]] && { echo "$service deploy failed";exit -1; }
    fi
done

prob=$( docker service ls | awk '{print $4}' | grep 0 | wc -l)
[ "$prob" -eq 0 ] && bash $(dirname $0)/$0 || exit 0
