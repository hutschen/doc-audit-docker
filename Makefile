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

build:
	docker image build -t hutschen/doc-audit:latest .

cmd:
	docker container rm -f doc-audit
	docker container run -it --name doc-audit \
		-p 4200:8000 \
		-v $(shell pwd)/config.yml:/usr/src/api/config.yml \
		--entrypoint '/bin/bash' hutschen/doc-audit

run:
	docker container rm -f doc-audit
	docker container create --name doc-audit \
		-p 4200:8000 \
		-v $(shell pwd)/gbert-large-paraphrase-cosine:/usr/src/gbert-large-paraphrase-cosine \
		-v $(shell pwd)/config.yml:/usr/src/api/config.yml hutschen/doc-audit
	docker container start doc-audit

push:
	docker image push hutschen/doc-audit

tag:
	docker image tag hutschen/doc-audit hutschen/doc-audit:$(tag)
	docker image push hutschen/doc-audit:$(tag)

submodules-update:
	git submodule update --init --recursive