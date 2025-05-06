use clap::{Parser, ValueEnum};

#[derive(Parser, Debug)]
pub struct Cli {
    #[arg(short, long, value_enum, default_value_t = Network::Sepolia)]
    pub network: Network,
    #[arg(short, long, value_enum, default_value_t = Fee::Estimate)]
    pub fee: Fee,
}

#[derive(Debug, Copy, Clone, PartialEq, Eq, ValueEnum)]
pub enum Network {
    Sepolia,
    Mainnet,
}

#[derive(Debug, Copy, Clone, PartialEq, Eq, ValueEnum)]
pub enum Fee {
    Estimate,
    Default,
    NoFee,
}
