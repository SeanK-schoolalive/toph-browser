SHELL := /usr/bin/env bash

.PHONY: help verify bootstrap versions audit api build

help:
	@printf '%s\n' \
	  'Toph Browser development targets:' \
	  '  make verify    - verify repository structure and locked revisions' \
	  '  make bootstrap - fetch locked Tor Browser and Tor sources' \
	  '  make versions  - print checked-out upstream revisions' \
	  '  make audit     - run the network-audit checklist' \
	  '  make api       - print Android API/ABI information from a connected device' \
	  '  make build     - build the locked Tor Browser Android baseline'

verify:
	bash scripts/verify-lock.sh

bootstrap:
	bash scripts/bootstrap-upstream.sh

versions:
	bash scripts/record-versions.sh

audit:
	bash scripts/audit-network.sh

api:
	bash scripts/check-android-api.sh

build:
	bash scripts/build-android.sh
