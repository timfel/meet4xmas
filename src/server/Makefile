all: java_libs


java_lib_dir=lib/java
java_libs:
	cd $(java_lib_dir) && make all

java_libs_service:
	cd $(java_lib_dir) && make service_classes


run_server: java_libs_service
	jruby --debug --1.9 lib/server.rb

run: run_server


run_java_test_client:
	cd $(java_lib_dir) && make run_test


external_spec: java_libs_service
	jruby --1.9 -S rake spec

spec: external_spec


external_coverage: java_libs_service
	jruby --1.9 -S rake coverage

coverage: external_coverage


clean:
	cd $(java_lib_dir) && make clean


irb:
	jruby --1.9 --debug -S irb -r./interactive_client.rb
