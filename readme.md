### How to use

1. run the shell script ```bash drone-gitlab.sh``` to build a image with gitlab token refresh fix.
2. update the ```drone.patch``` or the ```go-scm.patch``` if you have additional changes.
3. A prebuilt image is already at [gluxhappy/drone-server-gitlab](https://hub.docker.com/repository/docker/gluxhappy/drone-server-gitlab)


### Attention

Please use [DRONE_GIT_USERNAME](https://docs.drone.io/server/reference/drone-git-username/) and [DRONE_GIT_PASSWORD](https://docs.drone.io/server/reference/drone-git-password/) to avoid a token refresh issue casued by [Force Token Refresh](https://github.com/harness/drone/blob/v2.12.1/service/netrc/netrc.go#L74).  

The ```DRONE_GIT_USERNAME``` should be a user's name and ```DRONE_GIT_PASSWORD``` should be an [Personal Access Token](https://gitlab.com/-/profile/personal_access_tokens) with long expiration time. The access token should has been grant at least read access to all repositories you want to build via the Drone.