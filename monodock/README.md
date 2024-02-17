### TODO ###
- [x] add Jaeger
- [x] add PostgreSQL for tx-sitter
- [x] add PostgreSQL for signup-sequencer 
- [ ] add anvil
- [ ] init anvil state with predeployed smart contracts
- [ ] add tx-sitter
- [ ] add signup-sequencer
- [ ] (eplore) add PostgreSQL to OpenTelemetry

NOTE: for rust-tracing-otlp to properly expose ports outside of the container it needs to bind to 0.0.0.0:8080 and not 127.0.0.1:8080 - it requires manual update in the submodule after checkout for now