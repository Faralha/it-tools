#!/bin/bash
set -e

# ==========================================
# CLEANUP SCRIPT (DEV ONLY)
# ==========================================

# Load environment variables
if [ -f deploy.env ]; then source deploy.env; fi

# ==========================================
# 🔒 SAFETY LOCK
# ==========================================
# Hanya boleh jalan di ENV 'dev'
if [ "$DEPLOY_ENV" != "dev" ]; then
    echo "⛔ SAFETY LOCK ACTIVATED!"
    echo "❌ Cleanup is NOT allowed for '$DEPLOY_ENV' environment."
    exit 0
fi

# ==========================================
# Configuration Matches deploy.sh
# ==========================================

ENV_BASE_DIR="/opt/environments"
PROJECT_NAME="${CI_PROJECT_NAME}"

# ✅ DEFINISI ROOT DOMAIN DI SINI
ROOT_DOMAIN="iimlab.id"

# Config Dev Only
TUNNEL_SERVICE_NAME="dev_tunnel"
ENV_DIR="${ENV_BASE_DIR}/dev"
CLOUDFLARED_CONFIG="${ENV_DIR}/cloudflared/config.yml"

# Logic Nama Container & CNAME (Khusus Dev)
CLEAN_BRANCH=$(echo "$CI_COMMIT_BRANCH" | tr '[:upper:]' '[:lower:]')

# Logic Subdomain
SUBDOMAIN="${CLEAN_BRANCH}_${PROJECT_NAME}"
# Logic Full Hostname
FULL_HOSTNAME="${SUBDOMAIN}.${ROOT_DOMAIN}"

CONTAINER_NAME="${CLEAN_BRANCH}_${PROJECT_NAME}"

# ==========================================
# Logging
# ==========================================
log_info() { echo -e "\n🧹 [CLEANUP] $1" >&2; }
log_warn() { echo -e "\n⚠️  [WARN] $1" >&2; }
log_success() { echo -e "\n✅ [SUCCESS] $1" >&2; }

# ==========================================
# Execution
# ==========================================

log_info "Target to destroy: $CONTAINER_NAME"
log_info "Target Hostname  : $FULL_HOSTNAME"

# 1. Hapus Container App
if docker ps -a | grep -q "${CONTAINER_NAME}"; then
    log_info "Stopping & Removing Container..."
    docker stop ${CONTAINER_NAME} 2>/dev/null || true
    docker rm ${CONTAINER_NAME} 2>/dev/null || true
    log_success "Container removed successfully"
else
    log_warn "Container not found (already deleted?)."
fi

# 2. Hapus Log File & Port
log_info "Cleaning up logs and port files..."
rm -rf ${ENV_DIR}/logs/${CONTAINER_NAME}
rm -f ${ENV_DIR}/.${CONTAINER_NAME}.port
log_success "Logs and port files cleaned"

# 3. Hapus DNS CNAME Record dari Cloudflare
if [ -n "$DEV_TUNNEL_ID" ]; then
    log_info "Removing DNS CNAME record for ${FULL_HOSTNAME}..."
    docker run --rm \
        -v ${ENV_DIR}/cloudflared:/home/nonroot/.cloudflared \
        cloudflare/cloudflared:latest \
        tunnel route dns delete ${DEV_TUNNEL_ID} ${FULL_HOSTNAME} 2>&1 || log_warn "Failed to delete DNS record (might already be deleted or doesn't exist)"
    log_success "DNS CNAME record cleanup attempted"
else
    log_warn "DEV_TUNNEL_ID not found! Skipping DNS cleanup."
fi

# 4. Bersihkan Config Cloudflare (Delete Ingress)
if [ -f "$CLOUDFLARED_CONFIG" ]; then
    log_info "Removing Ingress Rule from config.yml..."
    # Hapus baris hostname FULL dan baris service di bawahnya
    sed -i "/hostname: ${FULL_HOSTNAME}/,+1d" ${CLOUDFLARED_CONFIG}
    log_success "Ingress rule removed from config"
else
    log_warn "Config file not found!"
fi

# 5. Restart Tunnel (Agar perubahan config aktif)
log_info "Reloading Tunnel..."
cd ${ENV_DIR}
docker compose restart ${TUNNEL_SERVICE_NAME}
log_success "Tunnel restarted successfully"

# 6. Hapus Docker Image (Optional - uncomment jika ingin hapus image juga)
# log_info "Removing Docker image..."
# docker rmi ${PROJECT_NAME}:${CI_COMMIT_SHORT_SHA} 2>/dev/null || log_warn "Image not found or still in use"

log_success "✅ Cleanup Complete! Dev environment destroyed."
log_info "Summary:"
log_info "  - Container: ${CONTAINER_NAME} ✓"
log_info "  - DNS Record: ${FULL_HOSTNAME} ✓"
log_info "  - Ingress Config: ✓"
log_info "  - Logs & Files: ✓"