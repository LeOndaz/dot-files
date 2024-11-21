function spin_postgres() {
    local container_name="postgres_container_$(date +%s)"
    local db_user="user"
    local db_password="password"
    local db_name="database"
    local db_port=5432

    docker run -d --name "$container_name" \
        -e POSTGRES_USER="$db_user" \
        -e POSTGRES_PASSWORD="$db_password" \
        -e POSTGRES_DB="$db_name" \
        -p "$db_port:5432" \
        postgres:latest

    if [ $? -ne 0 ]; then
        echo "Error: Failed to start PostgreSQL container" >&2
        return 1
    fi

    echo "Waiting for PostgreSQL container to be ready..."
    local timeout=15
    local waited=0
    until docker exec "$container_name" pg_isready -U "$db_user" -d "$db_name"; do
        sleep 1
        waited=$((waited + 1))
        if [ $waited -ge $timeout ]; then
            echo "Error: Timeout after ${timeout}s waiting for PostgreSQL container to be ready" >&2
            return 1
        fi
    done

    local db_url = "postgresql://$db_user:$db_password@localhost:$db_port/$db_name"
    local json_config=$(
        bat <<EOF
{
  "container_name": "$container_name",
  "db_user": "$db_user",
  "db_password": "$db_password",
  "db_name": "$db_name",
  "db_host": "localhost",
  "db_port": "$db_port",
  "db_url": "$db_url"
}
EOF
    )
    echo "$db_url" | pbcopy;
    echo "$json_config";
}
