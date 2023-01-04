for i in $(docker images | grep gitlab | awk '{print $(NF-6)":"$(NF-5)}');do docker save -o $(echo $i | awk -F '/' '{print $3}' | awk -F ':' '{print $1}').tar $i;done
