FROM alpine
ENV LANG=C.UTF-8 \
 JAVA_VERSION=8 \
 JAVA_UPDATE=171 \
 JAVA_BUILD=11 \
 JAVA_PATH=512cd62ec5174c3487ac17c61aaa89e8 \
 JAVA_HOME=”/usr/lib/jvm/default-jvm”
# Here we install GNU libc (aka glibc) and set C.UTF-8 locale as default.
RUN ALPINE_GLIBC_BASE_URL=”https://github.com/sgerrand/alpine-pkg-glibc/releases/download" && \
 ALPINE_GLIBC_PACKAGE_VERSION=”2.27-r0" && \
 ALPINE_GLIBC_BASE_PACKAGE_FILENAME=”glibc-$ALPINE_GLIBC_PACKAGE_VERSION.apk” && \
 ALPINE_GLIBC_BIN_PACKAGE_FILENAME=”glibc-bin-$ALPINE_GLIBC_PACKAGE_VERSION.apk” && \
 ALPINE_GLIBC_I18N_PACKAGE_FILENAME=”glibc-i18n-$ALPINE_GLIBC_PACKAGE_VERSION.apk” && \
 apk add — no-cache — virtual=.build-dependencies wget ca-certificates && \
 wget \
 “https://raw.githubusercontent.com/sgerrand/alpine-pkg-glibc/master/sgerrand.rsa.pub" \
 -O “/etc/apk/keys/sgerrand.rsa.pub” && \
 wget \
 “$ALPINE_GLIBC_BASE_URL/$ALPINE_GLIBC_PACKAGE_VERSION/$ALPINE_GLIBC_BASE_PACKAGE_FILENAME” \
 “$ALPINE_GLIBC_BASE_URL/$ALPINE_GLIBC_PACKAGE_VERSION/$ALPINE_GLIBC_BIN_PACKAGE_FILENAME” \
 “$ALPINE_GLIBC_BASE_URL/$ALPINE_GLIBC_PACKAGE_VERSION/$ALPINE_GLIBC_I18N_PACKAGE_FILENAME” && \
 apk add — no-cache \
 “$ALPINE_GLIBC_BASE_PACKAGE_FILENAME” \
 “$ALPINE_GLIBC_BIN_PACKAGE_FILENAME” \
 “$ALPINE_GLIBC_I18N_PACKAGE_FILENAME” && \
 \
 rm “/etc/apk/keys/sgerrand.rsa.pub” && \
 /usr/glibc-compat/bin/localedef — force — inputfile POSIX — charmap UTF-8 “$LANG” || true && \
 echo “export LANG=$LANG” > /etc/profile.d/locale.sh && \
 \
 apk del glibc-i18n && \
 \
 rm “/root/.wget-hsts” && \
 apk del .build-dependencies && \
 rm \
 “$ALPINE_GLIBC_BASE_PACKAGE_FILENAME” \
 “$ALPINE_GLIBC_BIN_PACKAGE_FILENAME” \
 “$ALPINE_GLIBC_I18N_PACKAGE_FILENAME”
RUN apk add — no-cache — virtual=build-dependencies wget ca-certificates unzip && \
 cd “/tmp” && \
 wget — header “Cookie: oraclelicense=accept-securebackup-cookie;” \
 “http://download.oracle.com/otn-pub/java/jdk/${JAVA_VERSION}u${JAVA_UPDATE}-b${JAVA_BUILD}/${JAVA_PATH}/jdk-${JAVA_VERSION}u${JAVA_UPDATE}-linux-x64.tar.gz" && \
 tar -xzf “jdk-${JAVA_VERSION}u${JAVA_UPDATE}-linux-x64.tar.gz” && \
 mkdir -p “/usr/lib/jvm” && \
 mv “/tmp/jdk1.${JAVA_VERSION}.0_${JAVA_UPDATE}” “/usr/lib/jvm/java-${JAVA_VERSION}-oracle” && \
 ln -s “java-${JAVA_VERSION}-oracle” “$JAVA_HOME” && \
 ln -s “$JAVA_HOME/bin/”* “/usr/bin/” && \
 rm -rf “$JAVA_HOME/”*src.zip && \
 wget — header “Cookie: oraclelicense=accept-securebackup-cookie;” \
 “http://download.oracle.com/otn-pub/java/jce/${JAVA_VERSION}/jce_policy-${JAVA_VERSION}.zip" && \
 unzip -jo -d “${JAVA_HOME}/jre/lib/security” “jce_policy-${JAVA_VERSION}.zip” && \
 rm “${JAVA_HOME}/jre/lib/security/README.txt” && \
 apk del build-dependencies && \
 rm “/tmp/”*
 
RUN mkdir /root/packer
WORKDIR /root/packer
RUN wget https://releases.hashicorp.com/packer/1.2.4/packer_1.2.4_linux_amd64.zip
RUN wget https://releases.hashicorp.com/terraform/0.11.7/terraform_0.11.7_linux_amd64.zip
RUN apk update
RUN unzip packer_1.2.4_linux_amd64.zip
RUN unzip terraform_0.11.7_linux_amd64.zip
RUN mv packer /usr/local/bin/packer
RUN mv terraform /usr/local/bin/terraform
RUN rm packer_1.2.4_linux_amd64.zip
RUN rm terraform_0.11.7_linux_amd64.zip
RUN apk update && apk upgrade && \
 apk add — no-cache bash git openssh
