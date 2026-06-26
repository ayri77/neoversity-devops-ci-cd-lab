#!/usr/bin/env bash

# break if error
set -e

echo "Training bash script. Lesson 3. CI/CD"

# packets update
sudo apt update

# Docker official install/check
DOCKER_PACKAGES=(
    docker-ce
    docker-ce-cli
    containerd.io
    docker-buildx-plugin
    docker-compose-plugin
)

CONFLICTING_DOCKER_PACKAGES=(
    docker.io
    docker-compose
    docker-compose-v2
    docker-doc
    podman-docker
    containerd
    runc
)

is_package_installed() {
    dpkg-query -W -f='${Status}' "$1" 2>/dev/null | grep -q "install ok installed"
}

is_official_docker_installed() {
    local pkg

    for pkg in "${DOCKER_PACKAGES[@]}"; do        
        if ! is_package_installed "$pkg"; then
            return 1
        fi
    done

    docker --version >/dev/null 2>&1 && docker compose version >/dev/null 2>&1 && docker buildx version >/dev/null 2>&1
}

remove_conflicting_docker_packages() {
    local pkg
    local installed_conflicting_packages=()

    for pkg in "${CONFLICTING_DOCKER_PACKAGES[@]}"; do
        if is_package_installed "$pkg"; then
            installed_conflicting_packages+=("$pkg")
        fi
    done

    if [ "${#installed_conflicting_packages[@]}" -gt 0 ]; then
        echo "Removing conflicting Docker packages: ${installed_conflicting_packages[*]}"
        sudo apt remove -y "${installed_conflicting_packages[@]}"
    else
        echo "No conflicting Docker packages found"
    fi
}

setup_docker_apt_repository() {
    echo "Setting up official Docker APT repository..."

    sudo apt install -y ca-certificates curl
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc

    sudo tee /etc/apt/sources.list.d/docker.sources >/dev/null <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF

    sudo apt update
}


if is_official_docker_installed; then
    echo "Official Docker packages are already installed"
else
    echo "Official Docker packages are not installed"

    remove_conflicting_docker_packages
    setup_docker_apt_repository

    echo "Installing official Docker packages..."
    sudo apt install -y "${DOCKER_PACKAGES[@]}"
fi

ensure_docker_daemon_running() {
    if docker ps >/dev/null 2>&1; then
        echo "Docker daemon is already running"
        return 0
    fi

    echo "Docker daemon is not running. Trying to start it..."

    if command -v systemctl >/dev/null 2>&1 && [ "$(ps -p 1 -o comm=)" = "systemd" ]; then
        sudo systemctl reset-failed docker || true
        sudo systemctl start containerd
        sudo systemctl start docker
    else
        echo "Error: systemd is not available. Please start Docker daemon manually."
        exit 1
    fi

    if docker ps >/dev/null 2>&1; then
        echo "Docker daemon is running"
    else
        echo "Error: Docker daemon is still not running"
        sudo systemctl status docker --no-pager || true
        exit 1
    fi
}

ensure_docker_daemon_running

# Python 3.9+ install/check
REQUIRED_PYTHON_MAJOR=3
REQUIRED_PYTHON_MINOR=9
PYTHON_BIN=""
PYTHON_VENV_PACKAGE=""

is_python_39_plus() {
    "$1" -c "import sys; exit(0 if sys.version_info >= (${REQUIRED_PYTHON_MAJOR}, ${REQUIRED_PYTHON_MINOR}) else 1)" >/dev/null 2>&1
}

find_available_python_package() {
    local pkg
    local candidate

    for pkg in python3.13 python3.12 python3.11 python3.10 python3.9; do
        candidate=$(apt-cache policy "$pkg" | awk '/Candidate:/ {print $2}')
        if [ -n "$candidate" ] && [ "$candidate" != "(none)" ]; then
            echo "$pkg"
            return 0
        fi
    done

    return 1
}

if command -v python3 >/dev/null 2>&1 && is_python_39_plus python3; then
    PYTHON_BIN="python3"
    PYTHON_VENV_PACKAGE="python3-venv"
    echo "Python 3.9+ is already installed: $(python3 --version)"
else
    echo "Python 3.9+ is not installed. Searching for available Python package..."

    PYTHON_PACKAGE=$(find_available_python_package || true)

    if [ -z "$PYTHON_PACKAGE" ]; then
        echo "No Python 3.9+ package found in current apt repositories."
        echo "Adding deadsnakes PPA..."

        sudo apt install -y software-properties-common
        sudo add-apt-repository -y ppa:deadsnakes/ppa
        sudo apt update

        PYTHON_PACKAGE=$(find_available_python_package || true)
    fi

    if [ -z "$PYTHON_PACKAGE" ]; then
        echo "Error: Could not find available Python 3.9+ package."
        exit 1
    fi

    echo "Installing $PYTHON_PACKAGE..."
    sudo apt install -y "$PYTHON_PACKAGE" "$PYTHON_PACKAGE-venv"

    PYTHON_BIN="$PYTHON_PACKAGE"
    PYTHON_VENV_PACKAGE="$PYTHON_PACKAGE-venv"

    if is_python_39_plus "$PYTHON_BIN"; then
        echo "Python 3.9+ installed: $("$PYTHON_BIN" --version)"
    else
        echo "Error: Installed Python version is still lower than 3.9"
        "$PYTHON_BIN" --version
        exit 1
    fi
fi

# Python venv package
if is_package_installed "$PYTHON_VENV_PACKAGE"; then
    echo "$PYTHON_VENV_PACKAGE is installed"
else
    echo "$PYTHON_VENV_PACKAGE is not installed"
    sudo apt install -y "$PYTHON_VENV_PACKAGE"
fi

# venv
if [ -d ".venv" ]; then
    if .venv/bin/python -c "import sys; exit(0 if sys.version_info >= (${REQUIRED_PYTHON_MAJOR}, ${REQUIRED_PYTHON_MINOR}) else 1)" >/dev/null 2>&1; then
        echo "Virtual environment already exists and uses Python 3.9+"
    else
        echo "Virtual environment exists but uses Python lower than 3.9. Recreating it..."
        rm -rf .venv
        "$PYTHON_BIN" -m venv .venv
    fi
else
    echo "Creating virtual environment"
    "$PYTHON_BIN" -m venv .venv
fi

# activate virtual env
source .venv/bin/activate

# Django install with pip inside virtual environment.
# The --user flag is not used here because Django is installed inside .venv.
if python -m django --version >/dev/null 2>&1; then
    echo "Django is already installed"
else
    echo "Django is not installed"
    python -m pip install django
fi

# check versions
echo
echo "========================================"
echo "Installed versions:"
echo "========================================"
docker --version
docker compose version
docker buildx version
"$PYTHON_BIN" --version
python -m django --version
echo "========================================"
