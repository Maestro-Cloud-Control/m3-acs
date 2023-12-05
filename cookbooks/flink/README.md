This cookbook used to install Apache Flink cookbook.

To install cookbook, chef will download binary file with specified version from Apache file storage.
You can set version of flink package in attributes file.

Chef will download flink-*.tgz, unpack it, and create symlink for flink executable to /usr/local/bin/ for all users to execute.

After that, chfe will use bash to execute 'start-cluster.sh' to deploy Flink cluster.
