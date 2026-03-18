docker build -t mailbox-service .


docker tag mailbox-service o3webmaster/mailbox-service:swarm-mode


docker push o3webmaster/mailbox-service:swarm-mode

------
docker build -t app-service-identity .


docker tag app-service-identity o3webmaster/app-service-identity:swarm-mode


docker push o3webmaster/app-service-identity:swarm-mode

------

docker build -t customer-complaint-management .


docker tag customer-complaint-management o3webmaster/customer-complaint-management:swarm-mode


docker push o3webmaster/customer-complaint-management:swarm-mode

------

docker build -t sdk-service-client-handshake .


docker tag sdk-service-client-handshake o3webmaster/sdk-service-client-handshake:swarm-mode


docker push o3webmaster/sdk-service-client-handshake:swarm-mode

------

docker build -t sdk-service-bugs .


docker tag sdk-service-bugs o3webmaster/sdk-service-bugs:swarm-mode


docker push o3webmaster/sdk-service-bugs:swarm-mode

------

docker build -t sdk-service-survey .


docker tag sdk-service-survey o3webmaster/sdk-service-survey:swarm-mode


docker push o3webmaster/sdk-service-survey:swarm-mode

------

docker build -t sdk-service-crashes .


docker tag sdk-service-crashes o3webmaster/sdk-service-crashes:swarm-mode


docker push o3webmaster/sdk-service-crashes:swarm-mode

------

docker build -t sdk-service-submit-complaint .


docker tag sdk-service-submit-complaint o3webmaster/sdk-service-submit-complaint:swarm-mode


docker push o3webmaster/sdk-service-submit-complaint:swarm-mode

------

docker build -t sdk-secure-link .


docker tag sdk-secure-link o3webmaster/sdk-secure-link:swarm-mode


docker push o3webmaster/sdk-secure-link:swarm-mode

