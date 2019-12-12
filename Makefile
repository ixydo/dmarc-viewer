.PHONY: build
build:
	docker build --force-rm --pull --tag dmarc-viewer:latest .

.PHONY: build-cron
build-cron:
	docker build --force-rm --pull --tag dmarc-viewer:latest --no-cache .

.PHONY: stop
stop:
	docker stop dmarc-viewer

.PHONY: stop-wait
stop-wait:
	docker stop dmarc-viewer && sleep 5 || :

.PHONY: rm
rm:
	docker rm dmarc-viewer

.PHONY: rm-wait
rm-wait:
	docker rm dmarc-viewer && sleep 5 || :

.PHONY: run
run:
	docker run \
		--log-driver syslog \
			--log-opt syslog-address=unixgram:///dev/logd \
			--log-opt syslog-facility=local0 \
			--log-opt tag=dmarc-viewer \
		--network host \
		--name dmarc-viewer \
		--env-file env/app.env \
		dmarc-viewer:latest

.PHONY: daemon
daemon:
	docker run -d \
		--restart=always \
		--log-driver syslog \
			--log-opt syslog-address=unixgram:///dev/logd \
			--log-opt syslog-facility=local0 \
			--log-opt tag=dmarc-viewer \
		--network host \
		--name dmarc-viewer \
		--env-file env/app.env \
		dmarc-viewer:latest
