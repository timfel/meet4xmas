source_dir=org/meet4xmas

class_ext=class
source_ext=java

service_classes= \
	$(source_dir)/wire/Appointment.$(class_ext) \
	$(source_dir)/wire/ErrorInfo.$(class_ext) \
	$(source_dir)/wire/IServiceAPI.$(class_ext) \
	$(source_dir)/wire/Location.$(class_ext) \
	$(source_dir)/wire/Participant.$(class_ext) \
	$(source_dir)/wire/Response.$(class_ext) \
	$(source_dir)/wire/TravelPlan.$(class_ext) \
	\
	$(source_dir)/util/StringUtil.$(class_ext)

test_classes=Test.$(class_ext)

all_classes=$(service_classes) $(test_classes)


classpath=.


all: $(all_classes)


test: $(test_classes)
	java -classpath "$(classpath):hessian.jar" Test

Test.$(class_ext): Test.$(source_ext)
	javac -classpath "$(classpath):hessian.jar" $<

service_classes: $(service_classes)

%.$(class_ext): %.$(source_ext)
	javac -classpath $(classpath) $<


run_test: $(test_classes)
	java -classpath "$(classpath):hessian.jar" Test


clean:
	rm -rf $(all_classes)
