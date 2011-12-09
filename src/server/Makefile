source_dir=lib/java

class_ext=class
source_ext=java

server_classes=$(source_dir)/Appointment.$(class_ext) \
	$(source_dir)/Location.$(class_ext) \
	$(source_dir)/TravelPlan.$(class_ext) \
	\
	$(source_dir)/ResponseBody.$(class_ext) \
	$(source_dir)/Servlet.$(class_ext) \
	\
	$(source_dir)/util/StringUtil.$(class_ext)
test_classes=Test.$(class_ext)

all_classes=$(server_classes) $(test_classes)

classpath=-classpath .

all: $(all_classes)


test: $(test_classes)
	java -classpath ".:hessian.jar" Test

Test.$(class_ext): Test.$(source_ext)
	javac -classpath ".:hessian.jar" $<

run: $(server_classes)
	ruby server.rb

%.$(class_ext): %.$(source_ext)
	javac $(classpath) $<


clean:
	rm -rf $(all_classes)
