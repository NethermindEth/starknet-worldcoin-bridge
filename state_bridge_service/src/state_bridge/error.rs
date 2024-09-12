use ethers::prelude::{AbiError, ContractError};
use ethers::providers::{Middleware, ProviderError};
use ethers::signers::WalletError;
use ethers::types::H256;
use thiserror::Error;

#[derive(Error, Debug)]
pub enum StateBridgeError<M>
where
    M: Middleware,
{
    #[error("L1 middleware error")]
    MiddlewareError(<M as Middleware>::Error),
    #[error("Provider error")]
    ProviderError(#[from] ProviderError),
    #[error("L1 contract error")]
    L1ContractError(ContractError<M>),
    #[error("ABI Codec error")]
    ABICodecError(#[from] AbiError),
    #[error("Eth ABI error")]
    EthABIError(#[from] ethers::abi::Error),
    #[error("Transaction error")]
    TransactionError(#[from] TransactionError<M>),
}

#[derive(Error, Debug)]
pub enum TransactionError<M>
where
    M: Middleware,
{
    #[error("Middleware error")]
    MiddlewareError(<M as Middleware>::Error),
    #[error("Provider error")]
    ProviderError(#[from] ethers::providers::ProviderError),
    #[error("Wallet error")]
    WalletError(#[from] WalletError),
    #[error("Wallet has insufficient funds")]
    InsufficientWalletFunds,
    #[error("Tx receipt not found")]
    TxReceiptNotFound(H256),
}
