use crate::config::constants::defaults::DEFAULT_GAS;
use crate::error::error::TransactionError;

use std::sync::Arc;

use ethers::providers::{JsonRpcClient, Middleware, PendingTransaction};
use ethers::signers::{LocalWallet, WalletError};
use ethers::types::transaction::eip2718::TypedTransaction;
use ethers::types::{
    BlockId, BlockNumber, Bytes, Eip1559TransactionRequest, TransactionReceipt, H160, U256,
};
use once_cell::sync::Lazy;
use tracing::instrument;

pub static DEFAULT_GAS_LIMIT: Lazy<U256> = Lazy::new(|| U256::from(DEFAULT_GAS));

//Signs and sends transaction, bumps gas if necessary
#[instrument(skip(wallet_key, block_confirmations, middleware))]
pub async fn sign_and_send_transaction<M: Middleware>(
    tx: TypedTransaction,
    wallet_key: &LocalWallet,
    block_confirmations: usize,
    middleware: Arc<M>,
) -> Result<TransactionReceipt, TransactionError<M>> {
    tracing::info!("Signing tx");
    let signed_tx = raw_signed_transaction(tx.clone(), wallet_key)?;
    tracing::info!("Sending tx");
    match middleware.send_raw_transaction(signed_tx.clone()).await {
        Ok(pending_tx) => {
            let tx_hash = pending_tx.tx_hash();
            tracing::info!(?tx_hash, "Pending tx");

            return wait_for_tx_receipt(pending_tx, block_confirmations).await;
        }
        Err(err) => {
            let error_string = err.to_string();
            if error_string.contains("insufficient funds") {
                tracing::error!("Insufficient funds");
                return Err(TransactionError::InsufficientWalletFunds);
            } else {
                return Err(TransactionError::MiddlewareError(err));
            }
        }
    }
}

#[instrument(skip(middleware))]
pub async fn fill_and_simulate_eip1559_transaction<M: Middleware>(
    calldata: Bytes,
    to: H160,
    from: H160,
    chain_id: u64,
    middleware: Arc<M>,
    value: U256,
) -> Result<TypedTransaction, TransactionError<M>> {
    let (max_fee_per_gas, max_priority_fee_per_gas) = middleware
        .estimate_eip1559_fees(None)
        .await
        .map_err(TransactionError::MiddlewareError)?;

    tracing::info!(
        ?max_fee_per_gas,
        ?max_priority_fee_per_gas,
        "Estimated gas fees"
    );

    let nonce = middleware
        .get_transaction_count(from, Some(BlockId::Number(BlockNumber::Latest)))
        .await
        .map_err(TransactionError::MiddlewareError)?;

    let mut tx: TypedTransaction = Eip1559TransactionRequest::new()
        .data(calldata.clone())
        .to(to)
        .from(from)
        .chain_id(chain_id)
        .max_priority_fee_per_gas(max_priority_fee_per_gas)
        .max_fee_per_gas(max_fee_per_gas)
        .value(value)
        .nonce(nonce)
        .into();

    middleware
        .fill_transaction(&mut tx, None)
        .await
        .map_err(TransactionError::MiddlewareError)?;

    let gas_limit = tx.gas().unwrap() * 150 / 100;
    tx.set_gas(gas_limit);
    let tx_gas = tx.gas().expect("Could not get tx gas");
    tracing::info!(?tx_gas, "Gas limit set");

    middleware
        .call(&tx, None)
        .await
        .map_err(TransactionError::MiddlewareError)?;

    tracing::info!("Successfully simulated tx");

    Ok(tx)
}

#[instrument]
pub async fn wait_for_tx_receipt<'a, M: Middleware, P: JsonRpcClient>(
    pending_tx: PendingTransaction<'a, P>,
    block_confirmations: usize,
) -> Result<TransactionReceipt, TransactionError<M>> {
    let pending_tx = pending_tx.confirmations(block_confirmations);
    let tx_hash = pending_tx.tx_hash();

    tracing::info!(
        ?tx_hash,
        ?block_confirmations,
        "Waiting for block confirmations"
    );

    if let Some(tx_receipt) = pending_tx.await.map_err(TransactionError::ProviderError)? {
        tracing::info!(?tx_receipt, "Tx receipt received");

        return Ok(tx_receipt);
    } else {
        return Err(TransactionError::TxReceiptNotFound(tx_hash));
    }
}

pub fn raw_signed_transaction(
    tx: TypedTransaction,
    wallet_key: &LocalWallet,
) -> Result<Bytes, WalletError> {
    Ok(tx.rlp_signed(&wallet_key.sign_transaction_sync(&tx)?))
}

pub fn check_gas_limit(set_gas: U256) -> bool {
    set_gas <= *DEFAULT_GAS_LIMIT
}
