#!/bin/bash
# Script to start all microservices directly in development mode

# Set environment variables
export JWT_SECRET_KEY="shared_jwt_secret_for_development"
export DEBUG="True"

# Create a function to start a service
start_service() {
  local service_name=$1
  local port=$2
  local db_port=$3
  
  echo "Starting $service_name on port $port..."
  
  # Set database URL for the service
  export DATABASE_URL="postgresql://postgres:postgres@localhost:$db_port/${service_name/_/-}_db"
  
  # For reservation and room services, also set Kafka URL
  if [ "$service_name" == "room_service" ] || [ "$service_name" == "reservation_service" ]; then
    export KAFKA_BROKER_URL="localhost:9092"
  fi
  
  # Start the service in the background
  cd /home/ademmami/devops/meeting-room-res-system-api/$service_name
  python app.py &
  
  # Store the process ID
  echo $! > /tmp/${service_name}.pid
  
  echo "$service_name started with PID $(cat /tmp/${service_name}.pid)"
}

# Function to stop all services
stop_services() {
  echo "Stopping all services..."
  for service in "user_service" "room_service" "reservation_service"; do
    if [ -f "/tmp/${service}.pid" ]; then
      pid=$(cat /tmp/${service}.pid)
      echo "Stopping $service (PID: $pid)"
      kill -15 $pid 2>/dev/null || true
      rm /tmp/${service}.pid
    fi
  done
  echo "All services stopped"
}

# Set up trap to handle script interruption
trap stop_services EXIT INT TERM

# Start each service
start_service "user_service" 5000 5432
start_service "room_service" 5001 5432
start_service "reservation_service" 5002 5432

echo "All services started. Press Ctrl+C to stop all services."

# Keep the script running
wait