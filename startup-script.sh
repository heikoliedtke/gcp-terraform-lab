#!/bin/bash
set -e # Exit immediately if a command exits with a non-zero status.

sudo apt-get update
sudo apt-get install -y apache2
sudo systemctl start apache2
sudo systemctl enable apache2
echo "<h1>Hello World from $(hostname)</h1>" | sudo tee /var/www/html/index.html