FROM alpine:3.6

CMD [ "/usr/bin/svnserve", "--daemon", "--foreground", "--root", "/var/opt/svn" ]
EXPOSE 3690
HEALTHCHECK CMD netstat -ln | grep 3690 || exit 1
VOLUME [ "/var/opt/svn" ]
WORKDIR /var/opt/svn

RUN apk add --no-cache subversion curl && \
    rm -fr /var/cache/apk/*
	
	
#How to use this image
#Start a Subversion Server instance
#To start a container, with data stored in /home/svn on the host, use the
#following:
#
#docker run --name some-svn-server \
#           --detach \
#           --volume /home/svn:/var/opt/svn \
#           --publish 3690:3690 \
#           garethflowers/svn-server
#Creating a new Repository
#Use svnadmin within your container to create and manage repositories.
#
#For example, to create a repository called new-repo in container
#some-svn-server, use the following:
#
#docker exec -it some-svn-server svnadmin create new-repo