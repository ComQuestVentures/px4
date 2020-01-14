FROM bitnami/minideb:buster

ARG root_dir=/px4

RUN apt update && install_packages \
	cmake \
	make

COPY Makefile ${root_dir}/Makefile
COPY build/ ${root_dir}/build/
COPY ROMFS/ ${root_dir}/ROMFS/

ENV PX4_SIM_MODEL=iris

WORKDIR ${root_dir}
CMD [ "./build/px4_sitl_default/bin/px4", "ROMFS/px4fmu_common", "-s", "etc/init.d-posix/rcS" ]
