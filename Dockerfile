# Copyright (c) 2014-present Sonatype, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

FROM registry.access.redhat.com/ubi7/ubi

LABEL vendor=Sonatype \
  maintainer="Sonatype <cloud-ops@sonatype.com>" \
  com.sonatype.license="Apache License, Version 2.0" \
  com.sonatype.name="Nexus Repository Manager OSS base image"

ARG NEXUS_VERSION=2.14.18-01
ARG NEXUS_DOWNLOAD_URL=https://download.sonatype.com/nexus/oss/nexus-${NEXUS_VERSION}-bundle.tar.gz

ENV SONATYPE_WORK=/sonatype-work
ENV NEXUS_HOME=/opt/sonatype/nexus

RUN yum install -v -y --disableplugin=subscription-manager hostname java-1.8.0-openjdk-headless \
  && yum-config-manager --add-repo http://mirror.centos.org/centos/7/os/x86_64/ \
  && rpm --import http://mirror.centos.org/centos/7/os/x86_64/RPM-GPG-KEY-CentOS-7 \
  && yum install -v -y createrepo \
  && yum --disableplugin=subscription-manager clean all

RUN mkdir -p ${NEXUS_HOME} && \
  curl --fail --silent --location --retry 3 ${NEXUS_DOWNLOAD_URL} | \
  tar xz -C /tmp nexus-${NEXUS_VERSION} && \
  mv /tmp/nexus-${NEXUS_VERSION}/* ${NEXUS_HOME}/ && \
  rm -rf /tmp/nexus-${NEXUS_VERSION}

RUN useradd -r -u 200 -m -c "nexus role account" -d ${SONATYPE_WORK} -s /bin/false nexus

VOLUME ${SONATYPE_WORK}

EXPOSE 8081
WORKDIR ${NEXUS_HOME}
USER nexus

ENV CONTEXT_PATH /nexus
ENV MAX_HEAP 768m
ENV MIN_HEAP 256m
ENV JAVA_OPTS -server -Djava.net.preferIPv4Stack=true
ENV LAUNCHER_CONF ./conf/jetty.xml ./conf/jetty-requestlog.xml

CMD java \
  -Dnexus-work=${SONATYPE_WORK} -Dnexus-webapp-context-path=${CONTEXT_PATH} \
  -Xms${MIN_HEAP} -Xmx${MAX_HEAP} \
  -cp 'conf/:lib/*' \
  ${JAVA_OPTS} \
  org.sonatype.nexus.bootstrap.Launcher ${LAUNCHER_CONF}

#ADD dependencies
USER root
RUN echo "Begin add dependencies"
COPY repository/ /sonatype-work/storage/snapshots/
RUN ls -lrt /sonatype-work/storage/snapshots/
RUN chown -R nexus:nexus /sonatype-work
RUN chmod 755 /sonatype-work
RUN echo "End add dependencies"
