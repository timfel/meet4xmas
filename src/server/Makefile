source_dir=lib/java

class_ext=class
source_ext=java
classes=$(source_dir)/Appointment.$(class_ext) \
				$(source_dir)/Location.$(class_ext) \
				$(source_dir)/TravelPlan.$(class_ext) \
				\
				$(source_dir)/ResponseBody.$(class_ext) \
				\
				$(source_dir)/Servlet.$(class_ext)

classpath=-classpath .

all: $(classes)

%.$(class_ext): %.$(source_ext)
	javac $(classpath) $<

run: all
	ruby server.rb

clean:
	rm -rf $(classes)
