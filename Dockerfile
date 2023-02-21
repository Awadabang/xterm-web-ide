# Copyright (c) 2023 Gitpod GmbH. All rights reserved.
# Licensed under the GNU Affero General Public License (AGPL).
# See License-AGPL.txt in the project root for license information.

FROM node:16 as ide_installer
RUN apt update && apt install python3
COPY . /ide-prepare/
WORKDIR /ide-prepare/
RUN yarn --frozen-lockfile --network-timeout 180000 && \
    yarn package:client && \
    yarn package:server
RUN cp -r /ide-prepare/out /ide/
RUN chmod -R ugo+x /ide

FROM scratch
# copy static web resources in first layer to serve from blobserve
COPY --chown=33333:33333 --from=ide_installer /ide /ide/
COPY --chown=33333:33333 --from=ide_installer /ide-prepare/out-server/ /ide/
COPY --chown=33333:33333 --from=ide_installer /ide-prepare/node_modules/node/bin/node /ide/bin/
COPY --chown=33333:33333 startup.sh supervisor-ide-config.json /ide/
