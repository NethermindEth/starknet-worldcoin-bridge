
// TODO
//#[starknet::component]
//mod CrossDomainOwnable {
//    use state_bridge::stark_world_id::cross_domain_ownable::interface_cross_domain_ownable;
//    use openzeppelin::access::ownable::OwnableComponent;

//    component!(path: OwnableComponent , storage: ownable_storage, event: OwnableEvent);

//    #[storage]
//    struct Storage{
//        #[substorage(v0)]
//        ownable_storage: OwnableComponent::Storage,
//    }

//    #[event]
//    #[derive(Drop, starknet::Event)]
//    enum Event {
//        OwnableEvent: OwnableComponent::Event
//    }
//}