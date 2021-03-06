#!/bin/bash

set -x
git clean -fxd
git clean -fXd   

# Ensure README gets packaged
mv README.md cpp

if [ "$TRAVIS_OS_NAME" == "linux" ]; then
    # manylinux build
    echo "Building manylinux wheels with auditwheel and docker"
    for PLAT in manylinux1_x86_64 manylinux2010_x86_64 manylinux1_i686; do
        DOCKER_IMAGE=quay.io/pypa/$PLAT
        if [ "$PLAT" == "manylinux1_i686" ]; then
            PRE_CMD=linux32
        else
            PRE_CMD=""
        fi
        docker pull $DOCKER_IMAGE
        docker run --rm -v `pwd`:/io -e PLAT=$PLAT -e PYTHON=$PYTHON $DOCKER_IMAGE $PRE_CMD /io/travis/build-wheels.sh
    done
else
    # os x build
    cd cpp
    $PIP install --user numpy twine setuptools wheel
    $PY setup.py sdist bdist_wheel
    cd ..
fi

