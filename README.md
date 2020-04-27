# SimpleLib
## Create your personal Python library in a second (on your personal PyPi)

# How to use:

## First setup

Just run

```bash
bash create_lib.sh <LIB_NAME> <CUSTOM_PYPI_URL> <CUSTOM_PYPI_USERNAME> <CUSTOM_PYPI_PASSWORD>
```

It will create directory with your library, ready to be deployed and used.
On every commit your code will be built and pushed to custom PyPi repo.

Now you can run

```bash
pip install -i http://<URL> --trusted-host <URL> --upgrade <LIB_NAME>
```

on any machine and enjoy your library anywhere.


## Consequent setups

If you want to continue editing your library on another machine, just
push the repo to remote location (e.g. GitHub). Then on other machine:

```bash
git clone <REPO_URL>
./githooks/setup.sh
```

and you are ready to build new versions of your micro-lib.


## Example

```bash
bash create_lib.sh mylib http://###############.eu-central-1.compute.amazonaws.com:8080 user password
```

Voila!

