#!/bin/bash

# Start the test environment
docker-compose -f docker-compose.test.yml up -d --build

# Wait for the database to be ready
echo "Waiting for database to be ready..."
until docker-compose -f docker-compose.test.yml exec db_test mysqladmin ping -h localhost --silent; do
    echo "Waiting for database connection..."
    sleep 2
done

# Copy .env.testing to .env within the container
docker-compose -f docker-compose.test.yml exec app cp .env.testing .env

# Generate application key
docker-compose -f docker-compose.test.yml exec app php artisan key:generate --env=testing

# Run migrations
docker-compose -f docker-compose.test.yml exec app php artisan migrate --env=testing

# Run tests with coverage
docker-compose -f docker-compose.test.yml exec app php artisan test --coverage-html tests/coverage

# Tear down the test environment
docker-compose -f docker-compose.test.yml down