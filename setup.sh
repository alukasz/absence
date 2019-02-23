#!/bin/bash

mix deps.get

cd assets
yarn install
cd ..

mix ecto.setup

mix phx.server
