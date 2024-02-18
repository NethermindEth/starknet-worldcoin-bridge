### TODO ###
- [x] add Jaeger
- [x] add PostgreSQL for tx-sitter
- [x] add PostgreSQL for signup-sequencer 
- [x] add anvil
- [x] init anvil state with predeployed smart contracts (--load-state --dump-state)
- [x] add keys volume from the contract-deployer
- [x] add tx-sitter
- [x] add waiting logic for the tx-sitter
- [ ] add signup-sequencer
- [ ] (explore) add PostgreSQL to OpenTelemetry
- [ ] add Optimism Nethermind? / anvil?
- [ ] add Starknet Juno?
- [ ] add Ethereum Nethermind?
- [ ] world-id-state-bridge
- [ ] world-tree
- [ ] add and test Optimism bridge
- [ ] add and test Starknet bridge
- [ ] world ID docs?
- [ ] developer-portal?
- [ ] deploy worldcoin token?
- [ ] add OpenTelemetry code (+ Jaeger) to telemetry-batteries

NOTE: for apps to properly expose ports outside of the container it needs to bind to 0.0.0.0:8080 and not 127.0.0.1:8080