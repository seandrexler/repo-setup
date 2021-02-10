#!/bin/bash

# exit when any command fails
set -e

# print the instructions for using the script
display_usage() {
  echo -e "\nUsage: []
    ";
  exit 1;
}

$(command -v git &> /dev/null) && GIT_USERNAME=$(git config user.email) || GIT_USERNAME=someone@somewhere.com

# create generic .editorconfig
cat <<EOF > .editorconfig
# editorconfig.org
root = true

[*]
indent_style = space
indent_size = 2
tab_width = 2
end_of_line = lf
charset = utf-8
trim_trailing_whitespace = true
insert_final_newline = true

[*.md]
trim_trailing_whitespace = true
indent_style = space
EOF

# create empty README.md
cat <<EOF > README.md
# ${PWD##*/}
EOF

# create docker file(s)
## create docker directory
mkdir docker

#creare empty dockerfile
cat <<EOF > docker/dockerfile.default
# start from base
FROM ubuntu:18.04 as application

LABEL maintainer="${GIT_USERNAME}"

# install system-wide deps for python and node
RUN apt-get -yqq update
RUN apt-get -yqq install python3-pip python3-dev curl gnupg
RUN curl -sL https://deb.nodesource.com/setup_10.x | bash
RUN apt-get install -yq nodejs

# copy our application code
ADD flask-app /opt/flask-app
WORKDIR /opt/flask-app

# fetch app specific deps
RUN npm install
RUN npm run build
RUN pip3 install -r requirements.txt

# expose port
EXPOSE 5000

# start app
CMD [ "python3", "./app.py" ]
EOF

# create generic .dockerignore
cat <<EOF > .dockerignore
# Ignore folders
.cache
.git
.vscode

# Ignore files
.editorconfig
.gitignore
.gitlab-ci.yml
*.md
*.sh

# Ignore unnecessary files inside allowed directories
# This should go after the allowed directories
**/*~
**/*.log
**/.DS_Store
**/Thumbs.db
EOF

# create .gitignore
cat <<EOF > .gitignore
# Compiled source #
###################
*.com
*.class
*.dll
*.exe
*.o
*.so

# Packages #
############
# it's better to unpack these files and commit the raw source
# git has its own built in compression methods
*.7z
*.dmg
*.gz
*.iso
*.jar
*.rar
*.tar
*.tar.gz
*.zip

# Logs and databases #
######################
*.db
*.log
*.sqlite

# Editor directories and files #
######################
.classpath
.c9/
.history/*
.idea
.project
.settings/
*.launch
*.ntvs*
*.njsproj
*.sln
*.sublime-workspace
*.suo
*.sw?
.vscode/*
!.vscode/settings.json
.vscode/*
!.vscode/settings.json
!.vscode/tasks.json
!.vscode/launch.json
!.vscode/extensions.json

# OS generated files #
######################
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
ehthumbs.db
Thumbs.db
EOF

