# Copyright (C) 2023 Helmar Hutschenreuter
# 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
# 
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# Angular build
FROM node:18.14.1-alpine3.17 AS ng_build
WORKDIR /usr/src/ng

# Install npm dependencies
COPY ./doc-audit-ng/package.json ./doc-audit-ng/package-lock.json ./
RUN npm clean-install

# Build Angular app
COPY ./doc-audit-ng ./
RUN npm run ng build --optimization

# Python build
FROM python:3.10-slim AS api_build
ENV DEBIAN_FRONTEND=noninteractive

# Update and install build-essential package, then clean up to save space
RUN apt-get update \
    && apt-get install -y --no-install-recommends build-essential \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Copy Pipfile and Pipfile.lock
COPY ./doc-audit-api/Pipfile ./doc-audit-api/Pipfile.lock ./

# Install Python dependencies in a virtual environment
RUN pip3 install --no-cache-dir pipenv \
    && python3 -m venv /venv \
    && . /venv/bin/activate \
    && pipenv install --ignore-pipfile --deploy \
    && pip3 uninstall -y pipenv

# Final stage
FROM python:3.10-slim
WORKDIR /usr/src/api

# Copy model files
COPY ./gbert-large-paraphrase-cosine ../gbert-large-paraphrase-cosine

# Copy virtual environment
COPY --from=api_build /venv /venv
ENV PATH="/venv/bin:$PATH"

# Copy API sources and Angular app build artifacts
COPY ./doc-audit-api ./
COPY --from=ng_build /usr/src/ng/dist/docaudit ./htdocs

# Download NLTK punkt model
RUN python -c "import nltk; nltk.download('punkt')"

ENTRYPOINT [ "python", "-u", "serve.py"]