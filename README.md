# dopechain-demo
Literally just a deployment config

## How to deploy this stuff
Firstly, do `git submodule init`.
`docker compose up`. Should work. Remember about putting the proper config files inside services, i.e.:
1. `./dope-bloccy/config.toml` 
2. `./dope-node/config.toml`
