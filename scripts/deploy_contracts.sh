#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILE="${1:-${ENV_FILE:-$ROOT_DIR/scripts/deploy.env}}"
OUTPUT_ENV_FILE="${OUTPUT_ENV_FILE:-$ROOT_DIR/deploy.outputs.env}"

if [[ -f "$ENV_FILE" ]]; then
  set -a
  # shellcheck disable=SC1090
  . "$ENV_FILE"
  set +a
fi

require_env() {
  local var_name="$1"
  if [[ -z "${!var_name:-}" ]]; then
    echo "Missing required env var: $var_name" >&2
    exit 1
  fi
}

source_shell_rc() {
  local rc_files=(
    "$HOME/.bashrc"
    "$HOME/.bash_profile"
    "$HOME/.zshrc"
    "$HOME/.zprofile"
  )
  local rc_file
  for rc_file in "${rc_files[@]}"; do
    if [[ -f "$rc_file" ]]; then
      # shellcheck disable=SC1090
      . "$rc_file"
    fi
  done
}

SCARB_VERSION="${SCARB_VERSION:-2.11.4}"
SNCAST_VERSION="${SNCAST_VERSION:-0.55.0}"
SNCAST_ACCOUNT_NAME="${SNCAST_ACCOUNT_NAME:-starknet_world_bridge_deployer}"
STARKNET_NETWORK="${STARKNET_NETWORK:-sepolia}"

require_env "L2_ACCOUNT_ADDRESS"
require_env "L2_PRIVATE_KEY"
require_env "L2_ACCOUNT_TYPE"
require_env "L2_RPC_URL"
require_env "L1_RPC_URL"
require_env "L1_PRIVATE_KEY"
require_env "L1_ACCOUNT_ADDRESS"
require_env "WORLDID_IDENTITY_MAANGER_ADDRESS"
require_env "L2_SEQUENCER_ADDRESS"

echo "==> Installing Scarb $SCARB_VERSION"
curl --proto '=https' --tlsv1.2 -sSf https://docs.swmansion.com/scarb/install.sh | sh -s -- -v "$SCARB_VERSION"

# Make sure newly installed tools are on PATH for this script.
source_shell_rc

scarb_version_installed="$(scarb --version | grep -Eo '[0-9]+\.[0-9]+\.[0-9]+' | head -n1)"
if [[ "$scarb_version_installed" != "$SCARB_VERSION" ]]; then
  echo "Expected Scarb $SCARB_VERSION, got $scarb_version_installed" >&2
  exit 1
fi

echo "==> Installing Starknet toolchain (starkup)"
set +e
starkup_output="$(curl --proto '=https' --tlsv1.2 -sSf https://sh.starkup.sh | sh 2>&1)"
starkup_status=$?
set -e
if [[ $starkup_status -ne 0 ]]; then
  if echo "$starkup_output" | grep -qi "already installed outside of asdf"; then
    echo "starkup: already installed outside of asdf; continuing."
  else
    echo "$starkup_output" >&2
    exit "$starkup_status"
  fi
fi

source_shell_rc

sncast_version_installed="$(sncast --version | grep -Eo '[0-9]+\.[0-9]+\.[0-9]+' | head -n1)"
if [[ "$sncast_version_installed" != "$SNCAST_VERSION" ]]; then
  echo "Expected sncast $SNCAST_VERSION, got $sncast_version_installed" >&2
  exit 1
fi

echo "==> Importing Starknet account"
sncast account import \
  --name "$SNCAST_ACCOUNT_NAME" \
  --address "$L2_ACCOUNT_ADDRESS" \
  --type "$L2_ACCOUNT_TYPE" \
  --network "$STARKNET_NETWORK" \
  --private-key "$L2_PRIVATE_KEY"

echo "==> Installing Foundry"
curl -L https://foundry.paradigm.xyz | bash
source_shell_rc
foundryup

echo "==> Deploying L1 StarkStateBridge"
pushd "$ROOT_DIR/state_bridge_l1" >/dev/null
forge_output="$(
  forge create \
    --broadcast \
    --rpc-url "$L1_RPC_URL" \
    --private-key "$L1_PRIVATE_KEY" \
    src/StarkStateBridge.sol:StarkStateBridge \
    --constructor-args "$WORLDID_IDENTITY_MAANGER_ADDRESS" 1 "$L2_SEQUENCER_ADDRESS"
)"
popd >/dev/null

L1_DEPLOYED_CONTRACT_ADDRESS="$(
  echo "$forge_output" \
    | sed -nE 's/.*Deployed to: (0x[0-9a-fA-F]{40}).*/\1/p' \
    | head -n1
)"
if [[ -z "$L1_DEPLOYED_CONTRACT_ADDRESS" ]]; then
  echo "Failed to parse L1 deployment address from forge output." >&2
  echo "$forge_output" >&2
  exit 1
fi
echo "L1 contract address: $L1_DEPLOYED_CONTRACT_ADDRESS"

echo "==> Building L2 contracts"
pushd "$ROOT_DIR/state_bridge_l2/world_id_state_bridge" >/dev/null
scarb build

echo "==> Declaring StarkWorldID"
declare_fee_args=()
if [[ -n "${L2_DECLARE_MAX_FEE:-}" ]]; then
  declare_fee_args+=(--max-fee "$L2_DECLARE_MAX_FEE")
fi
if [[ -n "${L2_DECLARE_L1_GAS:-}" ]]; then
  declare_fee_args+=(--l1-gas "$L2_DECLARE_L1_GAS")
fi
if [[ -n "${L2_DECLARE_L1_GAS_PRICE:-}" ]]; then
  declare_fee_args+=(--l1-gas-price "$L2_DECLARE_L1_GAS_PRICE")
fi
if [[ -n "${L2_DECLARE_L2_GAS:-}" ]]; then
  declare_fee_args+=(--l2-gas "$L2_DECLARE_L2_GAS")
fi
if [[ -n "${L2_DECLARE_L2_GAS_PRICE:-}" ]]; then
  declare_fee_args+=(--l2-gas-price "$L2_DECLARE_L2_GAS_PRICE")
fi
if [[ -n "${L2_DECLARE_L1_DATA_GAS:-}" ]]; then
  declare_fee_args+=(--l1-data-gas "$L2_DECLARE_L1_DATA_GAS")
fi
if [[ -n "${L2_DECLARE_L1_DATA_GAS_PRICE:-}" ]]; then
  declare_fee_args+=(--l1-data-gas-price "$L2_DECLARE_L1_DATA_GAS_PRICE")
fi
set +e
declare_output="$(
  sncast --account "$SNCAST_ACCOUNT_NAME" declare \
    --contract-name StarkWorldID \
    --url "$L2_RPC_URL" \
    --package world_id_state_bridge \
    "${declare_fee_args[@]}" 2>&1
)"
declare_status=$?
set -e
echo "$declare_output"

CLASS_HASH="$(
  echo "$declare_output" \
    | sed -nE 's/.*[Cc]lass hash:[[:space:]]*(0x[0-9a-fA-F]{64}).*/\1/p' \
    | head -n1
)"
if [[ -z "$CLASS_HASH" ]]; then
  CLASS_HASH="$(echo "$declare_output" | grep -Eio '0x[0-9a-fA-F]{64}' | head -n1)"
fi
if [[ -z "$CLASS_HASH" ]]; then
  echo "Failed to parse class hash from sncast declare output." >&2
  echo "$declare_output" >&2
  exit 1
fi
if [[ $declare_status -ne 0 ]]; then
  if echo "$declare_output" | grep -qi "already declared"; then
    echo "Class already declared; continuing with $CLASS_HASH."
  else
    echo "$declare_output" >&2
    exit "$declare_status"
  fi
fi
echo "Class hash: $CLASS_HASH"

echo "==> Deploying StarkWorldID"
deploy_fee_args=()
if [[ -n "${L2_DEPLOY_MAX_FEE:-}" ]]; then
  deploy_fee_args+=(--max-fee "$L2_DEPLOY_MAX_FEE")
fi
if [[ -n "${L2_DEPLOY_L1_GAS:-}" ]]; then
  deploy_fee_args+=(--l1-gas "$L2_DEPLOY_L1_GAS")
fi
if [[ -n "${L2_DEPLOY_L1_GAS_PRICE:-}" ]]; then
  deploy_fee_args+=(--l1-gas-price "$L2_DEPLOY_L1_GAS_PRICE")
fi
if [[ -n "${L2_DEPLOY_L2_GAS:-}" ]]; then
  deploy_fee_args+=(--l2-gas "$L2_DEPLOY_L2_GAS")
fi
if [[ -n "${L2_DEPLOY_L2_GAS_PRICE:-}" ]]; then
  deploy_fee_args+=(--l2-gas-price "$L2_DEPLOY_L2_GAS_PRICE")
fi
if [[ -n "${L2_DEPLOY_L1_DATA_GAS:-}" ]]; then
  deploy_fee_args+=(--l1-data-gas "$L2_DEPLOY_L1_DATA_GAS")
fi
if [[ -n "${L2_DEPLOY_L1_DATA_GAS_PRICE:-}" ]]; then
  deploy_fee_args+=(--l1-data-gas-price "$L2_DEPLOY_L1_DATA_GAS_PRICE")
fi
deploy_output="$(
  sncast --account "$SNCAST_ACCOUNT_NAME" deploy \
    --class-hash "$CLASS_HASH" \
    --url "$L2_RPC_URL" \
    "${deploy_fee_args[@]}" \
    -c $L1_DEPLOYED_CONTRACT_ADDRESS 30
)"
popd >/dev/null

L2_CONTRACT_ADDRESS="$(
  echo "$deploy_output" \
    | sed -nE 's/.*Contract address: (0x[0-9a-fA-F]{64}).*/\1/p' \
    | head -n1
)"
if [[ -z "$L2_CONTRACT_ADDRESS" ]]; then
  L2_CONTRACT_ADDRESS="$(echo "$deploy_output" | grep -Eo '0x[0-9a-fA-F]{64}' | head -n1)"
fi
if [[ -z "$L2_CONTRACT_ADDRESS" ]]; then
  echo "Failed to parse L2 deployment address from sncast deploy output." >&2
  echo "$deploy_output" >&2
  exit 1
fi
echo "L2 contract address: $L2_CONTRACT_ADDRESS"

echo "==> Linking L1 to L2"
pushd "$ROOT_DIR/state_bridge_l1" >/dev/null
cast send \
  "$L1_DEPLOYED_CONTRACT_ADDRESS" \
  --from "$L1_ACCOUNT_ADDRESS" \
  --private-key "$L1_PRIVATE_KEY" \
  --rpc-url "$L1_RPC_URL" \
  "setStarkWorldIDAddress(uint256)" \
  "$L2_CONTRACT_ADDRESS"

cat > "$OUTPUT_ENV_FILE" <<EOF
L1_STARK_STATE_BRIDGE_ADDRESS=$L1_DEPLOYED_CONTRACT_ADDRESS
L2_STARK_WORLD_ID_ADDRESS=$L2_CONTRACT_ADDRESS
STARK_WORLD_ID_CLASS_HASH=$CLASS_HASH
EOF

echo "==> Wrote outputs to $OUTPUT_ENV_FILE"
echo "L1 StarkStateBridge address: $L1_DEPLOYED_CONTRACT_ADDRESS"
echo "L2 StarkWorldID address: $L2_CONTRACT_ADDRESS"

