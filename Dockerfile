FROM eclipse-temurin:11.0.15_10-jdk-focal

# explicitly set user/group IDs
RUN groupadd -r wildfly --gid=1023 && useradd -r -g wildfly --uid=1023 -d /opt/wildfly wildfly

# grab gosu for easy step-down from root
ENV GOSU_VERSION 1.14
RUN arch="$(dpkg --print-architecture)" \
    && set -x \
    && apt-get update \
    && apt-get install -y gnupg netcat-openbsd unzip \
    && rm -rf /var/lib/apt/lists/* \
    && curl -o /usr/local/bin/gosu -fSL "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$arch" \
    && curl -o /usr/local/bin/gosu.asc -fSL "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$arch.asc" \
    && export GNUPGHOME="$(mktemp -d)" \
    && gpg --batch --keyserver hkps://keys.openpgp.org --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
    && gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
    && gpgconf --kill all \
    && rm -rf "$GNUPGHOME" /usr/local/bin/gosu.asc \
    && chmod +x /usr/local/bin/gosu \
    && gosu --version \
    && gosu nobody true

ENV WILDFLY_VERSION=26.1.0.Final \
    KEYCLOAK_VERSION=18.0.0 \
    LOGSTASH_GELF_VERSION=1.15.0 \
    JBOSS_HOME=/opt/wildfly

RUN cd $HOME \
    && curl -L https://github.com/wildfly/wildfly/releases/download/$WILDFLY_VERSION/wildfly-$WILDFLY_VERSION.tar.gz | tar xz  \
    && mv wildfly-$WILDFLY_VERSION $JBOSS_HOME \
    && curl https://repo1.maven.org/maven2/org/jboss/resteasy/resteasy-jsapi/4.7.5.Final/resteasy-jsapi-4.7.5.Final.jar \
            -o $JBOSS_HOME/modules/system/layers/base/org/jboss/resteasy/resteasy-jsapi/main/resteasy-jsapi-4.7.5.Final.jar \
    && sed -i 's/4\.7\.4/4.7.5/' $JBOSS_HOME/modules/system/layers/base/org/jboss/resteasy/resteasy-jsapi/main/module.xml \
    && rm $JBOSS_HOME/modules/system/layers/base/org/jboss/resteasy/resteasy-jsapi/main/resteasy-jsapi-4.7.4.Final.jar \
    && curl https://repo1.maven.org/maven2/org/jboss/resteasy/resteasy-jaxb-provider/4.7.5.Final/resteasy-jaxb-provider-4.7.5.Final.jar \
            -o $JBOSS_HOME/modules/system/layers/base/org/jboss/resteasy/resteasy-jaxb-provider/main/resteasy-jaxb-provider-4.7.5.Final.jar \
    && sed -i 's/4\.7\.4/4.7.5/' $JBOSS_HOME/modules/system/layers/base/org/jboss/resteasy/resteasy-jaxb-provider/main/module.xml \
    && rm $JBOSS_HOME/modules/system/layers/base/org/jboss/resteasy/resteasy-jaxb-provider/main/resteasy-jaxb-provider-4.7.4.Final.jar \
    && curl https://repo1.maven.org/maven2/org/jboss/resteasy/resteasy-client-api/4.7.5.Final/resteasy-client-api-4.7.5.Final.jar \
            -o $JBOSS_HOME/modules/system/layers/base/org/jboss/resteasy/resteasy-client-api/main/resteasy-client-api-4.7.5.Final.jar \
    && sed -i 's/4\.7\.4/4.7.5/' $JBOSS_HOME/modules/system/layers/base/org/jboss/resteasy/resteasy-client-api/main/module.xml \
    && rm $JBOSS_HOME/modules/system/layers/base/org/jboss/resteasy/resteasy-client-api/main/resteasy-client-api-4.7.4.Final.jar \
    && curl https://repo1.maven.org/maven2/org/jboss/resteasy/resteasy-crypto/4.7.5.Final/resteasy-crypto-4.7.5.Final.jar \
            -o $JBOSS_HOME/modules/system/layers/base/org/jboss/resteasy/resteasy-crypto/main/resteasy-crypto-4.7.5.Final.jar \
    && sed -i 's/4\.7\.4/4.7.5/' $JBOSS_HOME/modules/system/layers/base/org/jboss/resteasy/resteasy-crypto/main/module.xml \
    && rm $JBOSS_HOME/modules/system/layers/base/org/jboss/resteasy/resteasy-crypto/main/resteasy-crypto-4.7.4.Final.jar \
    && curl https://repo1.maven.org/maven2/org/jboss/resteasy/resteasy-cdi/4.7.5.Final/resteasy-cdi-4.7.5.Final.jar \
            -o $JBOSS_HOME/modules/system/layers/base/org/jboss/resteasy/resteasy-cdi/main/resteasy-cdi-4.7.5.Final.jar \
    && sed -i 's/4\.7\.4/4.7.5/' $JBOSS_HOME/modules/system/layers/base/org/jboss/resteasy/resteasy-cdi/main/module.xml \
    && rm $JBOSS_HOME/modules/system/layers/base/org/jboss/resteasy/resteasy-cdi/main/resteasy-cdi-4.7.4.Final.jar \
    && curl https://repo1.maven.org/maven2/org/jboss/resteasy/resteasy-jackson2-provider/4.7.5.Final/resteasy-jackson2-provider-4.7.5.Final.jar \
            -o $JBOSS_HOME/modules/system/layers/base/org/jboss/resteasy/resteasy-jackson2-provider/main/resteasy-jackson2-provider-4.7.5.Final.jar \
    && sed -i 's/4\.7\.4/4.7.5/' $JBOSS_HOME/modules/system/layers/base/org/jboss/resteasy/resteasy-jackson2-provider/main/module.xml \
    && rm $JBOSS_HOME/modules/system/layers/base/org/jboss/resteasy/resteasy-jackson2-provider/main/resteasy-jackson2-provider-4.7.4.Final.jar \
    && curl https://repo1.maven.org/maven2/org/jboss/resteasy/resteasy-validator-provider/4.7.5.Final/resteasy-validator-provider-4.7.5.Final.jar \
            -o $JBOSS_HOME/modules/system/layers/base/org/jboss/resteasy/resteasy-validator-provider/main/resteasy-validator-provider-4.7.5.Final.jar \
    && sed -i 's/4\.7\.4/4.7.5/' $JBOSS_HOME/modules/system/layers/base/org/jboss/resteasy/resteasy-validator-provider/main/module.xml \
    && rm $JBOSS_HOME/modules/system/layers/base/org/jboss/resteasy/resteasy-validator-provider/main/resteasy-validator-provider-4.7.4.Final.jar \
    && curl https://repo1.maven.org/maven2/org/jboss/resteasy/resteasy-core-spi/4.7.5.Final/resteasy-core-spi-4.7.5.Final.jar \
            -o $JBOSS_HOME/modules/system/layers/base/org/jboss/resteasy/resteasy-core-spi/main/resteasy-core-spi-4.7.5.Final.jar \
    && sed -i 's/4\.7\.4/4.7.5/' $JBOSS_HOME/modules/system/layers/base/org/jboss/resteasy/resteasy-core-spi/main/module.xml \
    && rm $JBOSS_HOME/modules/system/layers/base/org/jboss/resteasy/resteasy-core-spi/main/resteasy-core-spi-4.7.4.Final.jar \
    && curl https://repo1.maven.org/maven2/org/jboss/resteasy/resteasy-spring/4.7.5.Final/resteasy-spring-4.7.5.Final.jar \
            -o $JBOSS_HOME/modules/system/layers/base/org/jboss/resteasy/resteasy-spring/main/bundled/resteasy-spring-jar/resteasy-spring-4.7.5.Final.jar \
    && rm $JBOSS_HOME/modules/system/layers/base/org/jboss/resteasy/resteasy-spring/main/bundled/resteasy-spring-jar/resteasy-spring-4.7.4.Final.jar \
    && curl https://repo1.maven.org/maven2/org/jboss/resteasy/jose-jwt/4.7.5.Final/jose-jwt-4.7.5.Final.jar \
            -o $JBOSS_HOME/modules/system/layers/base/org/jboss/resteasy/jose-jwt/main/jose-jwt-4.7.5.Final.jar \
    && sed -i 's/4\.7\.4/4.7.5/' $JBOSS_HOME/modules/system/layers/base/org/jboss/resteasy/jose-jwt/main/module.xml \
    && rm $JBOSS_HOME/modules/system/layers/base/org/jboss/resteasy/jose-jwt/main/jose-jwt-4.7.4.Final.jar \
    && curl https://repo1.maven.org/maven2/org/jboss/resteasy/resteasy-json-binding-provider/4.7.5.Final/resteasy-json-binding-provider-4.7.5.Final.jar \
            -o $JBOSS_HOME/modules/system/layers/base/org/jboss/resteasy/resteasy-json-binding-provider/main/resteasy-json-binding-provider-4.7.5.Final.jar \
    && sed -i 's/4\.7\.4/4.7.5/' $JBOSS_HOME/modules/system/layers/base/org/jboss/resteasy/resteasy-json-binding-provider/main/module.xml \
    && rm $JBOSS_HOME/modules/system/layers/base/org/jboss/resteasy/resteasy-json-binding-provider/main/resteasy-json-binding-provider-4.7.4.Final.jar \
    && curl https://repo1.maven.org/maven2/org/jboss/resteasy/resteasy-json-p-provider/4.7.5.Final/resteasy-json-p-provider-4.7.5.Final.jar \
            -o $JBOSS_HOME/modules/system/layers/base/org/jboss/resteasy/resteasy-json-p-provider/main/resteasy-json-p-provider-4.7.5.Final.jar \
    && sed -i 's/4\.7\.4/4.7.5/' $JBOSS_HOME/modules/system/layers/base/org/jboss/resteasy/resteasy-json-p-provider/main/module.xml \
    && rm $JBOSS_HOME/modules/system/layers/base/org/jboss/resteasy/resteasy-json-p-provider/main/resteasy-json-p-provider-4.7.4.Final.jar \
    && curl https://repo1.maven.org/maven2/org/jboss/resteasy/resteasy-core/4.7.5.Final/resteasy-core-4.7.5.Final.jar \
            -o $JBOSS_HOME/modules/system/layers/base/org/jboss/resteasy/resteasy-core/main/resteasy-core-4.7.5.Final.jar \
    && sed -i 's/4\.7\.4/4.7.5/' $JBOSS_HOME/modules/system/layers/base/org/jboss/resteasy/resteasy-core/main/module.xml \
    && rm $JBOSS_HOME/modules/system/layers/base/org/jboss/resteasy/resteasy-core/main/resteasy-core-4.7.4.Final.jar \
    && curl https://repo1.maven.org/maven2/org/jboss/resteasy/resteasy-atom-provider/4.7.5.Final/resteasy-atom-provider-4.7.5.Final.jar \
            -o $JBOSS_HOME/modules/system/layers/base/org/jboss/resteasy/resteasy-atom-provider/main/resteasy-atom-provider-4.7.5.Final.jar \
    && sed -i 's/4\.7\.4/4.7.5/' $JBOSS_HOME/modules/system/layers/base/org/jboss/resteasy/resteasy-atom-provider/main/module.xml \
    && rm $JBOSS_HOME/modules/system/layers/base/org/jboss/resteasy/resteasy-atom-provider/main/resteasy-atom-provider-4.7.4.Final.jar \
    && curl https://repo1.maven.org/maven2/org/jboss/resteasy/resteasy-multipart-provider/4.7.5.Final/resteasy-multipart-provider-4.7.5.Final.jar \
            -o $JBOSS_HOME/modules/system/layers/base/org/jboss/resteasy/resteasy-multipart-provider/main/resteasy-multipart-provider-4.7.5.Final.jar \
    && sed -i 's/4\.7\.4/4.7.5/' $JBOSS_HOME/modules/system/layers/base/org/jboss/resteasy/resteasy-multipart-provider/main/module.xml \
    && rm $JBOSS_HOME/modules/system/layers/base/org/jboss/resteasy/resteasy-multipart-provider/main/resteasy-multipart-provider-4.7.4.Final.jar \
    && curl https://repo1.maven.org/maven2/org/jboss/resteasy/resteasy-client-microprofile-base/4.7.5.Final/resteasy-client-microprofile-base-4.7.5.Final.jar \
            -o $JBOSS_HOME/modules/system/layers/base/org/jboss/resteasy/resteasy-client-microprofile/main/resteasy-client-microprofile-base-4.7.5.Final.jar \
    && curl https://repo1.maven.org/maven2/org/jboss/resteasy/resteasy-client-microprofile/4.7.5.Final/resteasy-client-microprofile-4.7.5.Final.jar \
            -o $JBOSS_HOME/modules/system/layers/base/org/jboss/resteasy/resteasy-client-microprofile/main/resteasy-client-microprofile-4.7.5.Final.jar \
    && sed -i 's/4\.7\.4/4.7.5/' $JBOSS_HOME/modules/system/layers/base/org/jboss/resteasy/resteasy-client-microprofile/main/module.xml \
    && rm $JBOSS_HOME/modules/system/layers/base/org/jboss/resteasy/resteasy-client-microprofile/main/resteasy-client-microprofile-4.7.4.Final.jar \
    && rm $JBOSS_HOME/modules/system/layers/base/org/jboss/resteasy/resteasy-client-microprofile/main/resteasy-client-microprofile-base-4.7.4.Final.jar \
    && curl https://repo1.maven.org/maven2/org/jboss/resteasy/resteasy-rxjava2/4.7.5.Final/resteasy-rxjava2-4.7.5.Final.jar \
            -o $JBOSS_HOME/modules/system/layers/base/org/jboss/resteasy/resteasy-rxjava2/main/resteasy-rxjava2-4.7.5.Final.jar \
    && sed -i 's/4\.7\.4/4.7.5/' $JBOSS_HOME/modules/system/layers/base/org/jboss/resteasy/resteasy-rxjava2/main/module.xml \
    && rm $JBOSS_HOME/modules/system/layers/base/org/jboss/resteasy/resteasy-rxjava2/main/resteasy-rxjava2-4.7.4.Final.jar \
    && curl https://repo1.maven.org/maven2/org/jboss/resteasy/resteasy-client/4.7.5.Final/resteasy-client-4.7.5.Final.jar \
            -o $JBOSS_HOME/modules/system/layers/base/org/jboss/resteasy/resteasy-client/main/resteasy-client-4.7.5.Final.jar \
    && sed -i 's/4\.7\.4/4.7.5/' $JBOSS_HOME/modules/system/layers/base/org/jboss/resteasy/resteasy-client/main/module.xml \
    && rm $JBOSS_HOME/modules/system/layers/base/org/jboss/resteasy/resteasy-client/main/resteasy-client-4.7.4.Final.jar \
    && curl -L https://github.com/keycloak/keycloak/releases/download/$KEYCLOAK_VERSION/keycloak-oidc-wildfly-adapter-$KEYCLOAK_VERSION.tar.gz | tar xz -C $JBOSS_HOME \
    && curl https://repo1.maven.org/maven2/biz/paluch/logging/logstash-gelf/${LOGSTASH_GELF_VERSION}/logstash-gelf-${LOGSTASH_GELF_VERSION}-logging-module.zip -O \
    && unzip logstash-gelf-${LOGSTASH_GELF_VERSION}-logging-module.zip \
    && mv logstash-gelf-${LOGSTASH_GELF_VERSION}/biz $JBOSS_HOME/modules/biz \
    && rmdir logstash-gelf-${LOGSTASH_GELF_VERSION} \
    && rm logstash-gelf-${LOGSTASH_GELF_VERSION}-logging-module.zip \
    && chown -R wildfly:wildfly $JBOSS_HOME \
    && mkdir /docker-entrypoint.d  && mv $JBOSS_HOME/standalone/* /docker-entrypoint.d

ENV WILDFLY_STANDALONE configuration deployments

# Ensure signals are forwarded to the JVM process correctly for graceful shutdown
ENV LAUNCH_JBOSS_IN_BACKGROUND true

ENV PATH $JBOSS_HOME/bin:$PATH

VOLUME /opt/wildfly/standalone

COPY docker-entrypoint.sh /

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["standalone.sh", "-b", "0.0.0.0", "-bmanagement", "0.0.0.0"]
