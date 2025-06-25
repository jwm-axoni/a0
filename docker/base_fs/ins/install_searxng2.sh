#!/bin/bash
set -e

echo "====================SEARXNG2 START===================="

# Configure git for better large repo handling
git config --global http.postBuffer 524288000
git config --global http.lowSpeedLimit 0
git config --global http.lowSpeedTime 999999

# clone SearXNG repo with retry logic and shallow clone
for i in {1..3}; do
    echo "Attempting to clone SearxNG (attempt $i/3)..."
    if git clone --depth 1 "https://github.com/searxng/searxng" \
                   "/usr/local/searxng/searxng-src"; then
        echo "Clone successful!"
        break
    else
        echo "Clone failed on attempt $i"
        if [ $i -eq 3 ]; then
            echo "All clone attempts failed, exiting..."
            exit 1
        fi
        sleep 5
    fi
done

echo "====================SEARXNG2 VENV===================="

# create virtualenv:
python3.12 -m venv "/usr/local/searxng/searx-pyenv"

# make it default
echo ". /usr/local/searxng/searx-pyenv/bin/activate" \
                   >>  "/usr/local/searxng/.profile"

# activate venv
source "/usr/local/searxng/searx-pyenv/bin/activate"

echo "====================SEARXNG2 INST===================="

# update pip's boilerplate
pip install --no-cache-dir -U pip setuptools wheel pyyaml

# jump to SearXNG's working tree and install SearXNG into virtualenv
cd "/usr/local/searxng/searxng-src"
pip install --no-cache-dir --use-pep517 --no-build-isolation -e .

# cleanup cache
pip cache purge

echo "====================SEARXNG2 END===================="