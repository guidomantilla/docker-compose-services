#!/bin/bash
echo \
&& docker image ls --format  "table {{.Repository}} \t {{.Tag}} \t {{.Size}} \t {{.CreatedSince}}" \
&& echo \
&& docker container ls -a --format  "table {{.Image}} \t {{.RunningFor}} \t {{.Names}} \t {{.Status}} \t {{.Networks}} \t {{.Ports}}" \
&& echo && docker network ls && echo && docker volume ls && echo