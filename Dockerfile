# eric-oss-pf-policy-dist
FROM armdocker.rnd.ericsson.se/proj-orchestration-so/eric-oss-pf-base-image:2.21.0
ARG POLICY_LOGS=/var/log/onap/policy/distribution

ENV POLICY_LOGS=$POLICY_LOGS
ENV POLICY_HOME=/opt/app/policy/distribution

RUN zypper in -l -y shadow wget zip

RUN mkdir -p $POLICY_HOME $POLICY_LOGS $POLICY_HOME/bin && \
    groupadd policy && \
    useradd -m policy -g policy && \
    chown -R policy:policy $POLICY_HOME $POLICY_LOGS

RUN wget --no-check-certificate https://arm.epk.ericsson.se/artifactory/proj-policy-framework-generic-local/com/ericsson/policy-distribution/policy-distribution-tarball-2.2.2-SNAPSHOT-tarball.tar.gz \
     && tar -zxvf policy-distribution-tarball-2.2.2-SNAPSHOT-tarball.tar.gz --directory $POLICY_HOME \
     && rm policy-distribution-tarball-2.2.2-SNAPSHOT-tarball.tar.gz

WORKDIR $POLICY_HOME
COPY policy-dist.sh  bin/.
RUN chown -R policy:policy * && chmod 755 bin/*.sh

# Added to fix SM-111272 & SM-114368
RUN zip -d $POLICY_HOME/lib/log4j-1.2.17.jar org/apache/log4j/net/JMSAppender.class && \
    zip -d $POLICY_HOME/lib/log4j-1.2.17.jar org/apache/log4j/net/SocketServer.class && \
    zip -d $POLICY_HOME/lib/log4j-1.2.17.jar org/apache/log4j/net/JMSSink.class && \
    zip -d $POLICY_HOME/lib/log4j-1.2.17.jar org/apache/log4j/jdbc/JDBCAppender.class && \
    zip -d $POLICY_HOME/lib/log4j-1.2.17.jar org/apache/log4j/chainsaw/*
	
USER policy
WORKDIR $POLICY_HOME/bin
ENTRYPOINT [ "bash", "./policy-dist.sh" ]

