use clap::{Parser, ValueEnum};

#[derive(Parser, Debug)]
pub struct Cli {
    #[arg(long, value_enum, default_value_t = Network::Sepolia)]
    pub network: Network,
}

#[derive(Debug, Copy, Clone, PartialEq, Eq, ValueEnum)]
pub enum Network {
    Sepolia,
    Mainnet,
}
