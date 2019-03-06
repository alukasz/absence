#!/bin/bash

mix deps.get

cd apps/absence_web/assets/
yarn install
cd ..

mix ecto.setup

mix phx.server
