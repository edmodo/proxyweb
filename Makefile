basedir = /usr/local/proxyweb
secret_key=$(shell cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 16 | head -n 1)

proxyweb-build:
	docker build -t proxyweb/proxyweb:latest .

proxyweb-build-nocache:
	docker build --no-cache -t proxyweb/proxyweb:latest .

proxyweb-run-local: proxyweb-build
	docker run -h proxyweb --name proxyweb --network="host" -d proxyweb/proxyweb:latest

proxyweb-run: proxyweb-build
	docker run -h proxyweb --name proxyweb -p 5000:5000 -d proxyweb/proxyweb:latest

proxyweb-run-mappedconf:
	docker run --mount type=bind,source="`pwd`/config/config.yml",target="/app/config.yml" -h proxyweb --name proxyweb --network="host" -d proxyweb/proxyweb:latest

proxyweb-login: proxyweb-run
	docker exec -it proxyweb bash

proxyweb-pull:
	docker pull proxyweb/proxyweb:latest

proxyweb-push:
	docker push proxyweb/proxyweb:latest

proxyweb-destroy:
	docker stop proxyweb && docker rm proxyweb

install:
	useradd -s /bin/false -d $(basedir)  proxyweb
	apt update && apt install python3-pip python3-venv -y
	mkdir -p $(basedir)/
	cp -r . $(basedir)/
	chown -R proxyweb  $(basedir)/config/
	sed -i "s/12345678901234567890/${secret_key}/" ${basedir}/config/config.yml
	python3 -m venv $(basedir)/
	$(basedir)/bin/pip3 install -r $(basedir)/requirements.txt
	cp misc/proxyweb.service /etc/systemd/system/
	systemctl daemon-reload
	systemctl enable proxyweb
	systemctl start proxyweb
	systemctl status proxyweb

uninstall:
	-systemctl stop proxyweb
	-systemctl disable proxyweb
	-userdel proxyweb
	-rm /etc/systemd/system/proxyweb.service
	-rm -rf $(basedir)

proxyweb-start:
	systemctl start proxyweb

proxyweb-stop:
	systemctl stop proxyweb

orchestrator-build:
	cd docker-compose/orchestrator && docker build -t proxyweb/orchestrator:latest .

orchestrator-build-nocache:
	cd docker-compose/orchestrator && docker build --no-cache -t proxyweb/orchestrator:latest .

orchestrator-pull:
	docker pull proxyweb/orchestrator:latest

orchestrator-push:
	docker push proxyweb/orchestrator:latest

orchestrator-run:
	docker run -h orchestrator --name orchestrator -p 3000:3000 -d proxyweb/orchestrator:latest

orchestrator-destroy:
	docker stop orchestrator  && docker rm  orchestrator

goss-build:
	cd docker-compose/goss && docker build -t proxyweb/goss:latest .

goss-build-nocache:
	cd docker-compose/goss && docker build --no-cache -t proxyweb/goss:latest .

goss-pull:
	docker pull proxyweb/goss:latest

goss-push:
	docker push proxyweb/goss:latest

goss-run:
	docker run -h goss --name goss -p 8080:8080 -d proxyweb/goss:latest

goss-destroy:
	docker stop goss  && docker rm goss

compose-destroy: compose-down
	cd docker-compose/ && docker-compose rm -f

compose-up:
	cd docker-compose && make up

compose-down:
	cd docker-compose && make down

compose-dev:
	cd docker-compose/ && docker-compose up proxysql_standalone

sysbench-logs:
	cd docker-compose && make sysbench-logs

sysbench-up:
	cd docker-compose && make sysbench-up

sysbench-down:
	cd docker-compose && make sysbench-down
