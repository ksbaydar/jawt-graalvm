# Makefile
#
#
#
#

CLASSPATH=${PWD}:${PWD}/classes:

PROJECT_DIR=${PWD}
JAWT_HOME=${PWD}
APP_NAME=HelloJAWTWorld
APP_JAR=${PROJECT_DIR}/bin/${APP_NAME}.jar
APP_NATIVE_PREFIX=nj
APP_NATIVE_NAME=${APP_NATIVE_PREFIX}_${APP_NAME}
APP_NATIVE=${PROJECT_DIR}/${APP_NATIVE_NAME}

NATIVE_IMAGE_XMX_SIZE="10G"
APP_NATIVE_COMPILER_OPTIONS="-g"
APP_NATIVE_AWT_HEADLESS=false
APP_NATIVE_OPTIMIZE=0
APP_NATIVE_DEBUG=1

APP_AGENT_REFLECT_CONFIG=${JAWT_HOME}/etc/reflect-config.json
APP_AGENT_JNI_CONFIG=${JAWT_HOME}/etc/jni-config.json
APP_AGENT_RESOURCE_CONFIG=${JAWT_HOME}/etc/resource-config.json
APP_AGENT_PROXY_CONFIG=${JAWT_HOME}/etc/proxy-config.json
APP_AGENT_SERIALIZATION_CONFIG=${JAWT_HOME}/etc/serialization-config.json

LD_LIBRARY_PATH=${GRAALVM_HOME}/lib:${GRAALVM_HOME}/lib/server

NATIVE_IMAGE_EXTRA_OPTIONS=
APP_MAIN_CLASS="HelloJAWTWorld"
APPJARS="$(CLASSPATH)$(APP_JAR)"


all: demo 

src/HelloJAWTWorld.class: src/HelloJAWTWorld.java
	#javac src/HelloWorld.java
	find . -name  '*.java' > sources.txt && javac -d classes/ @sources.txt -cp ${CLASSPATH}
	rm -rf sources.txt

src/HelloJAWTWorld.h: src/HelloJAWTWorld.java 
	cd src && javac -h . HelloJAWTWorld.java

libmylib.so: src/HelloJAWTWorld.h src/libmylibsrc/libmylib.c
	gcc -m64 -fpic --shared -o lib/libmylib.so -I${JAVA_HOME}/include  -I${JAVA_HOME}/include/linux -L${JAVA_HOME}/lib -ljawt -lawt_xawt -lXtst -lXext src/libmylibsrc/libmylib.c

HelloJAWTWorld.jar: src/HelloJAWTWorld.class
	rm -rf META-INF
	mkdir META-INF
	echo -e "Main-Class: HelloJAWTWorld" >> META-INF/MANIFEST.MF	
	jar cfm bin/HelloJAWTWorld.jar ./META-INF/MANIFEST.MF -C classes/ . >/dev/null 2>&1
	chmod 777 -R  bin/HelloJAWTWorld.jar

run-config: src/HelloJAWTWorld.class libmylib.so 
	java -agentlib:native-image-agent=config-merge-dir=etc -cp ${CLASSPATH} -Djava.library.path=${LD_LIBRARY_PATH}:${JAWT_HOME}/lib  HelloJAWTWorld

run-jar: HelloJAWTWorld.jar libmylib.so
	LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${JAWT_HOME}/lib java -jar -Djava.library.path=${LD_LIBRARY_PATH}:${JAWT_HOME}/lib bin/HelloJAWTWorld.jar

native: HelloJAWTWorld.jar libmylib.so
	${GRAALVM_HOME}/bin/native-image \
		--no-server \
		--no-fallback \
		--verbose \
		"-J-Xmx1g" \
		${NATIVE_IMAGE_EXTRA_OPTIONS} \
		--native-compiler-options=${APP_NATIVE_COMPILER_OPTIONS} \
		--initialize-at-run-time=com.sun.imageio \
		--initialize-at-run-time=java.awt \
		--initialize-at-run-time=javax.imageio \
		--initialize-at-run-time=sun.awt \
		--initialize-at-run-time=sun.font \
		--initialize-at-run-time=sun.java2d \
		-J-Xmx${NATIVE_IMAGE_XMX_SIZE} \
		-Djava.awt.headless=$(APP_NATIVE_AWT_HEADLESS) \
		-H:Optimize=${APP_NATIVE_OPTIMIZE} \
		-H:+ReportExceptionStackTraces \
		-H:FallbackThreshold=0 \
		-H:+StackTrace \
		-H:+PrintAnalysisCallTree \
		-H:CLibraryPath=. \
		-H:+JNIVerboseLookupErrors \
		-H:+JNI \
		-H:GenerateDebugInfo=${APP_NATIVE_DEBUG} \
		-H:Class=${APP_MAIN_CLASS} \
		-H:Name=${APP_NATIVE} \
		-H:ReflectionConfigurationFiles=${APP_AGENT_REFLECT_CONFIG} \
		-H:JNIConfigurationFiles=${APP_AGENT_JNI_CONFIG} \
		-H:ResourceConfigurationFiles=${APP_AGENT_RESOURCE_CONFIG} \
		-H:DynamicProxyConfigurationFiles=${APP_AGENT_PROXY_CONFIG} \
		-H:SerializationConfigurationFiles=${APP_AGENT_SERIALIZATION_CONFIG} \
		-H:NativeLinkerOption=${JAWT_HOME}/lib/libmylib.so \
		-cp ${APPJARS} \
	

run-native: native libmylib.so
	LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${JAWT_HOME}/lib ./${APP_NATIVE_NAME}

clean:
	-rm -rf classes/
	-rm -rf src/*.class
	-rm -rf bin/*.jar
	-rm -rf lib/*.so
	-rm -rf graal_HelloJAWTWorld
	-rm -rf sources/
	-rm -rf reports/

