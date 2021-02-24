up:
	docker-compose up --remove-orphans -d --scale sysbench=0
	docker-compose exec db1 /setup_topology.sh master
	docker-compose exec db2 /setup_topology.sh slave
	docker-compose exec db3 /setup_topology.sh slave
	docker-compose exec db4 /setup_topology.sh slave
	docker-compose exec orchestrator /usr/local/orchestrator/orchestrator -c discover -i db1
	@cat banner.txt

down:
	docker-compose down --volumes

sysbench-logs:
	docker-compose logs sysbench

sysbench-up:
	docker-compose up -d --scale sysbench=1 sysbench

sysbench-down:
	docker-compose up -d --scale sysbench=0 sysbench
