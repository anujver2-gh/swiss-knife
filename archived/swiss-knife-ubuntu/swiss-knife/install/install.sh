#!/bin/zsh

$HOME/.asdf/bin/asdf plugin-add java && \
$HOME/.asdf/bin/asdf plugin-add mysql  && \
$HOME/.asdf/bin/asdf plugin-add python  && \
$HOME/.asdf/bin/asdf plugin-add jq  && \
$HOME/.asdf/bin/asdf plugin-add jqp  && \
$HOME/.asdf/bin/asdf plugin-add awscli  && \
$HOME/.asdf/bin/asdf plugin-add leiningen  && \
$HOME/.asdf/bin/asdf plugin-add gradle  && \
$HOME/.asdf/bin/asdf plugin-add ripgrep

$HOME/.asdf/bin/asdf install awscli latest  && \
$HOME/.asdf/bin/asdf install gradle 4.7  && \
$HOME/.asdf/bin/asdf install java adoptopenjdk-11.0.22+7  && \
$HOME/.asdf/bin/asdf install jq latest  && \
$HOME/.asdf/bin/asdf install jqp latest  && \
$HOME/.asdf/bin/asdf install mysql 8.0.20 && \
$HOME/.asdf/bin/asdf install ripgrep 14.1.0 && \
$HOME/.asdf/bin/asdf install python 3.6.0