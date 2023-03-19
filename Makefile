.PHONY: update-tags docker-build

docker-build:
	docker build . \
		--build-arg VCS_REF=`git rev-parse HEAD` \
		--build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"`

update-tags:
	git checkout master
	git tag -s -f -a -m "latest series" latest
	git checkout -
	git push origin refs/tags/latest -f