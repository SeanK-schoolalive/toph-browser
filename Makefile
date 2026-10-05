SHELL := /usr/bin/env bash

.PHONY: help verify bootstrap versions audit api

help:
	@printf '%s\n' \
	  'Toph Browser development targets:' \
	  '  make verify    - verify repository structure and locked revisions' \
	  '  make bootstrap - fetch locked Tor Browser and Tor sources' \
	  '  make versions  - print checked-out upstream revisions' \
	  '  make audit     - run the network-audit checklist' \
	  '  make api       - print Android API/ABI information from a connected device'

verify:
	./scripts/verify-lock.sh

bootstrap:
	./scripts/bootstrap-upstream.sh

versions:
	./scripts/record-versions.sh

audit:
	./scripts/audit-network.sh

api:
	./scripts/check-android-api.sh
