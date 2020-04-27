PACKAGE=$1
PYPI_URL=$2
PYPI_USERNAME=$3
PYPI_PASSWORD=$4

AUTHOR=$(git config user.name)
AUTHOR_EMAIL=$(git config user.email)

mkdir ${PACKAGE}
cd ${PACKAGE}
mkdir ${PACKAGE}
python3 -m venv ./.venv
PYTHON=./.venv/bin/python

${PYTHON} -m pip install twine
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
curl https://raw.githubusercontent.com/github/gitignore/master/Python.gitignore > .gitignore

git add .
git commit -m "Initialize directories structure"

