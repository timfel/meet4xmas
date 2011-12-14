all: java_libs

java_lib_dir=lib/java
java_libs:
	cd $(java_lib_dir) && make all

java_libs_service:
	cd $(java_lib_dir) && make service_classes

run_server: java_libs_service
	ruby lib/server.rb

run: run_server

run_ruby_interactive_test_client:
	irb -r 'interactive_client'

run_client: run_ruby_interactive_test_client

run_java_test_client:
	cd $(java_lib_dir) && make run_test

clean:
	cd $(java_lib_dir) && make clean
