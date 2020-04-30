#!/bin/bash

echo "Checking environment..."
((git status > /dev/null 2>&1) && echo "Do NOT run from git repository" && exit 1) || echo "git ok"
((which python3 > /dev/null) && echo "Python3 ok") || (echo "Cannot find Python3 executable" && exit 1)
PYTHON3_PATH=$(which python3)
echo Done.

echo -n "Gathering arguments... "
PACKAGE=$1
PYPI_URL=$2
PYPI_USERNAME=$3
PYPI_PASSWORD=$4
echo Done.

echo -n "Retrieving git username / email... "
AUTHOR=$(git config user.name)
AUTHOR_EMAIL=$(git config user.email)
echo Done.

echo -n "Creating directory structure... "
mkdir ${PACKAGE}
cd ${PACKAGE}
mkdir ${PACKAGE}
echo Done.

echo -n "Setting up Python environment... "
VENV_PATH=./.venv
(${PYTHON3_PATH} -m venv ${VENV_PATH} > errors.log 2>&1) || (rm -rf ${VENV_PATH} && python3 -m virtualenv ${VENV_PATH} > errors.log 2>&1)
PYTHON=${VENV_PATH}/bin/python
${PYTHON} -m pip install twine > /dev/null 2> errors.log
echo Done.

echo -n "Initializing git repository... "
git init

mkdir githooks

echo "PACKAGE=${PACKAGE}
ROOT_DIR=\$(git rev-parse --show-toplevel)
PYTHON=\${ROOT_DIR}/.venv/bin/python
URL=\"${PYPI_URL}\"
USERNAME=\"${PYPI_USERNAME}\"
PASSWORD=\"${PYPI_PASSWORD}\"

\${PYTHON} \${ROOT_DIR}/bump_version.py
git add \${ROOT_DIR}/version.txt
\${PYTHON} \${ROOT_DIR}/setup.py sdist
\${PYTHON} -m twine upload --verbose -u \${USERNAME} -p \${PASSWORD} --repository-url \${URL} \${ROOT_DIR}/dist/\${PACKAGE}-\$(cat version.txt).tar.gz" > \
    githooks/pre-commit

echo "#!/bin/bash
git config --local core.hooksPath githooks" > githooks/setup.sh
chmod +x githooks/pre-commit
chmod +x githooks/setup.sh

./githooks/setup.sh
echo Done.

echo -n "Building package boilerplate... "
echo "from setuptools import setup, find_packages
with open('version.txt') as f:
    version = f.read().strip()
setup(name=\"${PACKAGE}\",
      version=version,
      author=\"${AUTHOR}\",
      author_email=\"${AUTHOR_EMAIL}\",
      description=\"${PACKAGE}\",
      packages=find_packages())" > setup.py

echo "with open('version.txt') as f:
    version = f.read().strip()
v1, v2 = version.split('.')
with open('version.txt', 'w') as f:
    f.write(f'{int(v1) + 1}.{v2}')" > bump_version.py

echo "0.0" > version.txt
echo "include version.txt" > MANIFEST.in
echo ${PACKAGE} > README.md
curl https://raw.githubusercontent.com/github/gitignore/master/Python.gitignore > .gitignore 2> errors.log
echo Done.

echo -n "Making first commit and creating PyPi package... "
git add .
git commit -m "Initialize directories structure" > errors.log 2>&1
echo Done.

echo Success!

