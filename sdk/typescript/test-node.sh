#!/bin/bash

# Node.js SDK Test Script
# Builds the project, starts the test server, runs tests, and cleans up

set -e  # Exit on any error

echo "Building Node.js SDK..."
deno run -A build.ts

echo "Starting Node.js test server..."
node npm/esm/node/node.js &
SERVER_PID=$!

# Function to cleanup server on exit
cleanup() {
    if [ ! -z "$SERVER_PID" ]; then
        echo "Stopping test server..."
        kill $SERVER_PID 2>/dev/null || true
        wait $SERVER_PID 2>/dev/null || true
    fi
}

# Setup cleanup trap
trap cleanup EXIT

echo "Waiting for server to start..."
sleep 5

# Wait for server to be ready
max_attempts=15
attempt=1
while [ $attempt -le $max_attempts ]; do
    if curl -s http://127.0.0.1:3000/ > /dev/null 2>&1; then
        echo "Server ready! Running tests..."
        break
    fi
    
    if [ $attempt -eq $max_attempts ]; then
        echo "Error: Server failed to start after $max_attempts attempts"
        exit 1
    fi
    
    echo "Server not ready, waiting... (attempt $attempt/$max_attempts)"
    sleep 2
    attempt=$((attempt + 1))
done

# Store current directory
ORIGINAL_DIR=$(pwd)

# Run the test suite
cd ../test
./test-all.sh http://127.0.0.1:3000
TEST_RESULT=$?

# Return to original directory
cd "$ORIGINAL_DIR"

if [ $TEST_RESULT -eq 0 ]; then
    echo "All tests passed!"
else
    echo "Some tests failed (exit code: $TEST_RESULT)"
fi

exit $TEST_RESULT 