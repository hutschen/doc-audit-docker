# Docker image for DocAudit

DocAudit is a tool for reviewing documents in the field of information security. When reviewing the documentation of an ISMS (Information Security Management System), it is often necessary to review a large amount of documents. DocAudit supports information security experts in their document work by enabling a semantic search across multiple documents. In this way, passages of text relating to information security measures can be found more quickly than is the case when documents are searched manually.

DocAudit consists of two components, the [web API](https://github.com/hutschen/doc-audit-api) and the [web client](https://github.com/hutschen/doc-audit-ng). This repository contains the Docker setup you need to easily deploy DocAudit.

If you want to make it easy, you can simply pull the Docker image from [Docker Hub](https://hub.docker.com/r/hutschen/doc-audit) instead of building it yourself. If you still want to build the doc-audit image yourself, read the following sections of this readme.

## Clone the repository

**Attention**, there are submodules included in this repository. You should clone them together with this repository. This can be done with the following command:

```sh
git clone --recurse-submodules git@github.com:hutschen/doc-audit-docker.git
```

## Build the Docker image

To build the Docker image, first make sure [Docker](https://www.docker.com/) is installed on your system. Then, change to the root directory of this repository and run the following command:

```sh
docker image build -t hutschen/doc-audit .
```

## Write a configuration file

Before you can run the DocAudit in a Docker container, you have to configure it. This is done by a configuration file. This is very simple and contains only a few entries:

- The URL to the database (connect string).
- Optional logging configuration.

```yaml
database:
  url: sqlite:///docaudit.db
uvicorn:
  log_level: error
  log_filename: docaudit.log
```

### Database connection

Only SQLite and PostgreSQL are currently supported as databases. You should use PostgreSQL if you want to use doc-audit in production. doc-audit is significantly slower with SQLite than with PostgreSQL. **SQLite is therefore not suitable in production**.

doc-audit uses SQLAlchemy as the ORM mapper. The database URLs (connect strings) must therefore be specified so that SQLAlchemy understands them:

- For **SQLite** you can find the information about the structure of the connect string in the [SQLAlchemy documentation](https://docs.sqlalchemy.org/en/14/dialects/sqlite.html#connect-strings).
- Connections to **PostgreSQL** databases are made using the [psycopg2](https://www.psycopg.org/) driver. You can also find the information about the connect string in the [SQLAlchemy documentation](https://docs.sqlalchemy.org/en/14/dialects/postgresql.html#dialect-postgresql-psycopg2-connect).

A connection to a SQLite database file might look like the following in your configuration file:

```yaml
database:
  url: sqlite:///docaudit.db
```

The database file `docaudit.db` addressed in this example is created automatically if it does not exist. It is stored in the Docker container under `/usr/src/api/docaudit.db`.

### Logging

Logging is important so that bugs can be noticed and fixed in future versions of the doc-audit. Therefore, you should set up logging and save log files outside the Docker container as well. Regarding logging, there are the following configuration options:

- **Log level** with the options `critical`, `error`, `warning`, `info`, `debug`, `trace` and the default value `error`.
- **Log Dateiname** with the default value `null`.

The logging configuration may look like the following in your configuration file:

```yaml
uvicorn:
  log_level: error
  log_filename: docaudit.log
```

If a log file name is set, the log file is stored in the Docker container at `/usr/src/api/`. Contents of the log file are not deleted. New log entries are appended to an existing file. If no log file name is set, the logs are written to Docker Logs.

## Run the Docker container

Save your configuration in a file (e.g. `config.yml`) and then execute the following commands to create the container, copy your configuration into the container and finally start the container.

```sh
docker container create --name doc-audit -p 4200:8000 hutschen/doc-audit
docker container cp config.yml doc-audit:/usr/src/api/config.yml
docker container start doc-audit
```

You should then be able to access DocAudit at http://localhost:4200.

## Contributing

The goal of DocAudit is to provide its users with the greatest possible benefit in their daily work in information security. For this reason, feedback from the field and suggestions for improvement are particularly important.

If you want to contribute something like this, feel free to create an issue with a feature request, an idea for improvement or a bug report. Issues can be created in English and German.

Please note that the purpose of this repository is to deploy the DocAudit with Docker. Issues not related to this topic are probably better placed in the issues of the [web API](https://github.com/hutschen/doc-audit-api) or the [web client](https://github.com/hutschen/doc-audit-ng).

This project is just started. Later there will be more possibilities to contribute. For now please be patient. Thanks :relaxed:

## License and dependencies

The DocAudit itself or the source code in this repository is licensed under AGPLv3. You find the license in the [license file](LICENSE). In addition, DocAudit uses a number of libraries or other software components to make it work. These libraries or software components have been released by their respective authors under their own licenses. These libraries or their source code is not part of this repository. This applies in particular to repositories embedded in this repository as submodules. Such embedded repositories are not considered part of this repository. The license terms of the respective authors apply to the embedded repositories.
