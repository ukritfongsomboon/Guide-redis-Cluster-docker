#!/bin/bash

# Load environment variables from .env
if [ -f .env ]; then
    export $(cat .env | xargs)
fi

echo "Starting Redis Cluster with username/password authentication..."
docker-compose up -d

echo "Waiting for cluster to initialize..."
TIMEOUT=60
ELAPSED=0
while [ $ELAPSED -lt $TIMEOUT ]; do
    STATUS=$(docker-compose exec -T -e REDISCLI_AUTH="$REDISCLI_AUTH_PASSWORD" redis-node-1 redis-cli cluster info 2>/dev/null | grep cluster_state)
    if [[ $STATUS == *"ok"* ]]; then
        echo "✅ Cluster is ready!"
        break
    fi
    echo "⏳ Waiting... ($ELAPSED/$TIMEOUT seconds)"
    sleep 2
    ELAPSED=$((ELAPSED + 2))
done

if [ $ELAPSED -ge $TIMEOUT ]; then
    echo "⚠️  Cluster initialization timeout after $TIMEOUT seconds"
fi

echo "Redis Cluster is starting up!"
echo ""
echo "Services:"
echo "  - Redis Cluster (via Nginx): localhost:6379"
echo "  - Redis Nodes (individual): ports 7001-7006"
echo "  - Nginx Health Check: http://localhost:8080/health"
echo "  - Nginx Stats: http://localhost:8080/stats"
echo "  - Redis Insight: http://localhost:8001"
echo ""
echo "Connection Details:"
echo "  Host: localhost"
echo "  Port: 6379 (or 63790 if port conflict)"
echo "  Username: $REDISCLI_AUTH_USERNAME"
echo "  Password: ****"
echo ""
echo "Cluster details:"
docker-compose exec -T -e REDISCLI_AUTH="$REDISCLI_AUTH_PASSWORD" redis-node-1 redis-cli cluster info | head -20
