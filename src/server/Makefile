all: java_libs

java_lib_dir=lib/java
java_libs:
	cd $(java_lib_dir) && make all

java_libs_service:
	cd $(java_lib_dir) && make service_classes

run_server: java_libs_service
	ruby lib/server.rb

run_test:
	cd $(java_lib_dir) && make run_test

run: run_server

clean:
	cd $(java_lib_dir) && make clean
