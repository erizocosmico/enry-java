JNAERATOR_VERSION=ac73c9e
RESOURCES_DIR=./shared
LINUX_DIR=$(RESOURCES_DIR)/linux-x86-64
LINUX_SHARED_LIB=$(LINUX_DIR)/libenry.so
DARWIN_DIR=$(RESOURCES_DIR)/darwin
DARWIN_SHARED_LIB=$(DARWIN_DIR)/libenry.dylib
HEADER_FILE=libenry.h
NATIVE_LIB_DIR=./.enry
NATIVE_LIB=$(NATIVE_LIB_DIR)/shared/enry.go
JARS_DIR=./lib
JAR=$(JARS_DIR)/enry.jar
JNAERATOR_DIR=./.jnaerator
JNAERATOR_JAR=$(JNAERATOR_DIR)/jnaerator.jar

all: $(JAR)

$(JAR): $(NATIVE_LIB) $(JNAERATOR_JAR)
	mkdir -p lib && \
	java -jar $(JNAERATOR_JAR) \
		-package tech.sourced.enry.nativelib \
		-library enry \
		$(RESOURCES_DIR)/$(HEADER_FILE) \
		-o $(JARS_DIR) \
		-mode StandaloneJar \
		-runtime JNA;

$(NATIVE_LIB):
	git clone --depth 1 https://gopkg.in/src-d/enry.v1 $(NATIVE_LIB_DIR)

$(JNAERATOR_JAR):
	git clone --depth 1 https://github.com/nativelibs4java/jnaerator.git $(JNAERATOR_DIR) && \
	cd $(JNAERATOR_DIR) && \
	git checkout $(JNAERATOR_VERSION) && \
	mvn clean install && \
	mv jnaerator/target/jnaerator-*-shaded.jar ./jnaerator.jar && \
	cd ..;

linux-shared: $(LINUX_SHARED_LIB)

darwin-shared: $(DARWIN_SHARED_LIB)

$(DARWIN_SHARED_LIB): $(NATIVE_LIB)
	mkdir -p $(DARWIN_DIR) && \
	GOOS=darwin GOARCH=amd64 go build -buildmode=c-shared -o $(DARWIN_SHARED_LIB) $(NATIVE_LIB) && \
	mv $(DARWIN_DIR)/$(HEADER_FILE) $(RESOURCES_DIR)/$(HEADER_FILE)

$(LINUX_SHARED_LIB): $(NATIVE_LIB)
	mkdir -p $(LINUX_DIR) && \
	GOOS=linux GOARCH=amd64 go build -buildmode=c-shared -o $(LINUX_SHARED_LIB) $(NATIVE_LIB) && \
	mv $(LINUX_DIR)/$(HEADER_FILE) $(RESOURCES_DIR)/$(HEADER_FILE)

test:
	sbt clean test

package:
	sbt clean assembly

clean:
	rm -rf $(JAR)
	rm -rf $(RESOURCES_DIR)/libenry.h
	rm -rf $(LINUX_DIR)
	rm -rf $(DARWIN_DIR)
	rm -rf $(WINDOWS_DIR)

