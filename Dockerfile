
FROM jboss/wildfly:latest

# Variables de entorno postgres
ENV DB_HOST postgres
ENV DB_PORT 5432
ENV DB_NAME terawhars
ENV DB_USER terawhars
ENV DB_PASS terawhars

ENV DS_NAME TeraWHARSDS
ENV JNDI_NAME java:jboss/datasources/TeraWHARSDS

USER root
ADD https://jdbc.postgresql.org/download/postgresql-42.2.4.jar /tmp/postgresql-42.2.4.jar

WORKDIR /tmp
COPY input_files/wildfly-command.sh ./
COPY input_files/module-install.cli ./
# search and replace
RUN sed -i -e 's/\r$//' ./wildfly-command.sh
RUN chmod +x ./wildfly-command.sh
RUN ./wildfly-command.sh \
    &&  rm -rf $JBOSS_HOME/standalone/configuration/standalone_xml_history/

# implementacion del archivo .WAR
ADD javaee6-webapp.war $JBOSS_HOME/standalone/deployments

# Crear usuario y password Wildfly admin user
RUN $JBOSS_HOME/bin/add-user.sh administrador super_admin_sayan --silent

# Set the default command to run on boot
# Config para que se puedan conectar cual esquier interfaz de red
CMD ["/opt/jboss/wildfly/bin/standalone.sh", "-b", "0.0.0.0", "-bmanagement", "0.0.0.0"]
