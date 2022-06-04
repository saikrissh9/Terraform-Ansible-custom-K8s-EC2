#!/bin/bash
sudo service jenkins stop
sudo rm -f /var/lib/jenkins.tar
sudo tar -cvzf /var/lib/jenkins /var/lib/jenkins.tar
aws s3 cp /var/lib/jenkins.tar s3://saivalaxy1/jenkins.tar