#! /bin/bash

if [ -z ${PX4_DOCKER_REPO+x} ]; then
	echo "guessing PX4_DOCKER_REPO based on input";
	if [[ $@ =~ .*px4_fmu.* ]]; then
		# nuttx-px4fmu-v{1,2,3,4,5}
		PX4_DOCKER_REPO="px4io/px4-dev-nuttx:latest"
	elif [[ $@ =~ .*navio2.* ]] || [[ $@ =~ .*raspberry.* ]] || [[ $@ =~ .*bebop.* ]]; then
		# posix_rpi_cross, posix_bebop_default
		PX4_DOCKER_REPO="px4io/px4-dev-raspi:2019-03-08"
	elif [[ $@ =~ .*eagle.* ]] || [[ $@ =~ .*excelsior.* ]]; then
		# eagle, excelsior
		PX4_DOCKER_REPO="lorenzmeier/px4-dev-snapdragon:2018-09-12"
	elif [[ $@ =~ .*ocpoc.* ]]; then
		# aerotennaocpoc_ubuntu
		PX4_DOCKER_REPO="px4io/px4-dev-armhf:2019-03-08"
	elif [[ $@ =~ .*clang.* ]] || [[ $@ =~ .*scan-build.* ]]; then
		# clang tools
		PX4_DOCKER_REPO="px4io/px4-dev-clang:2019-03-08"
	elif [[ $@ =~ .*tests* ]]; then
		# run all tests with simulation
		PX4_DOCKER_REPO="px4io/px4-dev-simulation:2019-03-08"
	fi
else
	echo "PX4_DOCKER_REPO is set to '$PX4_DOCKER_REPO'";
fi

# otherwise default to nuttx
if [ -z ${PX4_DOCKER_REPO+x} ]; then
	PX4_DOCKER_REPO="px4io/px4-dev-nuttx:latest"
fi

# docker hygiene

#Delete all stopped containers (including data-only containers)
#docker rm $(docker ps -a -q)

#Delete all 'untagged/dangling' (<none>) images
#docker rmi $(docker images -q -f dangling=true)

echo "PX4_DOCKER_REPO: $PX4_DOCKER_REPO";

PWD=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
SRC_DIR=$PWD/../

CCACHE_DIR=${HOME}/.ccache
mkdir -p "${CCACHE_DIR}"

docker run -it --rm -w "${SRC_DIR}" \
	--env=AWS_ACCESS_KEY_ID \
	--env=AWS_SECRET_ACCESS_KEY \
	--env=BRANCH_NAME \
	--env=CCACHE_DIR="${CCACHE_DIR}" \
	--env=CI \
	--env=CODECOV_TOKEN \
	--env=COVERALLS_REPO_TOKEN \
	--env=LOCAL_USER_ID="$(id -u)" \
	--env=PX4_ASAN \
	--env=PX4_MSAN \
	--env=PX4_TSAN \
	--env=PX4_UBSAN \
	--env=TRAVIS_BRANCH \
	--env=TRAVIS_BUILD_ID \
	--network host \
	--volume=${CCACHE_DIR}:${CCACHE_DIR}:rw \
	--volume=${SRC_DIR}:${SRC_DIR}:rw \
	${PX4_DOCKER_REPO} /bin/bash -c "$1 $2 $3"
