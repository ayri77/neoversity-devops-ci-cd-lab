#!/usr/bin/env bash

# break if error
set -e

echo "Training bash script. Lesson 3. CI/CD"

# packets update
sudo apt update

# Docker install
if command -v docker >/dev/null 2>&1; then
    echo "Docker is installed"
else
    echo "Docker is not installed"
    # install
    sudo apt install -y docker
fi

# Docker Compose install
if docker compose version >/dev/null 2>&1; then
    echo "Docker Compose is installed"
else
    echo "Docker Compose is not installed"
    # install
    sudo apt install -y docker
fi

# Python 3.9 install
if command -v python3 >/dev/null 2>&1; then
    echo "Python is installed"
    if python3 -c "import sys; exit(0 if sys.version_info >= (3, 9) else 1);"; then
        echo "Python 3.9+ installed"
    else
        echo "Python version is lower than 3.9"
        sudo apt install -y python3
    fi
else
    echo "Python is not installed"
    sudo apt install -y python3
fi

# pip
if command -v pip3 >/dev/null 2>&1; then
    echo "pip is installed"
else
    echo "pip is not installed"
    sudo apt install -y python3-pip
fi

# venv
if [ -d ".venv" ]; then
    echo "Virtual environment already exists"
else
    echo "Creating virtual environment"
    python3 -m venv .venv
fi

# activate virtual env
source .venv/bin/activate

# Django install with pip.
if python -m django --version >/dev/null 2>&1; then
    echo "Django is already installed"
else
    echo "Django is not installed"
    pip install django
fi

# check versions
echo "Installed versions:"
docker --version
docker compose version
python3 --version
python -m django --version