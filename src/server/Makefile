all: java_libs

java_lib_dir=lib/java
java_libs:
	cd $(java_lib_dir) && make all

java_libs_service:
	cd $(java_lib_dir) && make service_classes

java_libs_test:
	cd $(java_lib_dir) && make test_classes

run: $(java_libs_service)
	ruby server.rb

run_test: $(java_libs_test)
	cd $(java_lib_dir) && make run_test

clean:
	cd $(java_lib_dir) && make clean
