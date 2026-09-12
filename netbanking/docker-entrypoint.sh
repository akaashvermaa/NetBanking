#!/bin/sh
set -eu

cat > /usr/local/tomcat/webapps/netbanking/WEB-INF/classes/db.properties <<EOF
db.url=${DB_URL:-jdbc:postgresql://db:5432/NetBanking}
db.username=${DB_USERNAME:-netbanking_app}
db.password=${DB_PASSWORD:-netbanking_password}
EOF

exec catalina.sh run