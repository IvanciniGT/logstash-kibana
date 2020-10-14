docker run \
            --rm \
            -it \
            -v ~/environment/curso/logstash/data:/data \
            -v ~/environment/curso/logstash/pipelines/$1:/usr/share/logstash/pipeline/logstash.conf \
            docker.elastic.co/logstash/logstash:7.9.2
