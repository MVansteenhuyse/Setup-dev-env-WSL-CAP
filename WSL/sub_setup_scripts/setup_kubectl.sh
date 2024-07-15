#!/bin/bash
# FLAGS: -kubectl
# PARAMS: 

set -euo pipefail

# Ensure script isn't run as root
if [ "$EUID" -eq 0 ]; then
    echo "This script should not be run as root or with sudo."
    exit 1
fi

# Function to check if a command exists
check_command() {
    if ! command -v "$1" &> /dev/null; then
        echo "$1 could not be found, installing..."
        sudo apt-get install -y "$1"
    fi
}

# Function to install kubectl
install_kubectl() {
    if command -v kubectl &> /dev/null; then
        echo "kubectl is already installed."
    else
        echo "Installing the latest version of kubectl..."
        RELEASE_VERSION=$(curl -L -s https://dl.k8s.io/release/stable.txt)
        curl -LO "https://dl.k8s.io/release/${RELEASE_VERSION}/bin/linux/amd64/kubectl"
        curl -LO "https://dl.k8s.io/release/${RELEASE_VERSION}/bin/linux/amd64/kubectl.sha256"

        # Validate the kubectl binary against the checksum file
        echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check
        if [ $? -ne 0 ]; then
            echo "Checksum verification failed. Exiting."
            rm kubectl kubectl.sha256
            exit 1
        else
            echo "Checksum verified successfully."
        fi

        sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
        rm kubectl kubectl.sha256

        # Verify installation
        if ! kubectl version --client; then
            echo "kubectl installation failed"
            exit 1
        fi
    fi
}

# Function to create a temporary kubeconfig file if it doesn't exist
create_temp_kubeconfig() {
    mkdir -p ~/.kube
    if [ -f ~/.kube/config ]; then
        echo "kubeconfig already exists at ~/.kube/config. Skipping creation of temporary kubeconfig."
    else
        cat <<EOF > ~/.kube/config
apiVersion: v1
clusters:
- cluster:
    server: <your-cluster-api-server>
    certificate-authority-data: <base64-encoded-ca-cert>
  name: my-cluster
contexts:
- context:
    cluster: my-cluster
    user: my-user
  name: my-context
current-context: my-context
kind: Config
preferences: {}
users:
- name: my-user
  user:
    client-certificate-data: <base64-encoded-client-cert>
    client-key-data: <base64-encoded-client-key>
EOF
        echo "Temporary kubeconfig created at ~/.kube/config. Please update it with your cluster details."
    fi
}

# Function to install krew
install_krew() {
    if ! kubectl krew &> /dev/null; then
        echo "Installing krew..."
        (
          set -x; cd "$(mktemp -d)" &&
          OS="$(uname | tr '[:upper:]' '[:lower:]')" &&
          ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/arm.*$/arm/')" &&
          KREW="krew-${OS}_${ARCH}" &&
          curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz" &&
          tar zxvf "${KREW}.tar.gz" &&
          ./"${KREW}" install krew
        )

        # Add krew to PATH
        export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
        if ! grep -q 'export PATH="\${KREW_ROOT:-\$HOME/.krew}/bin:\$PATH"' ~/.bashrc; then
            echo 'export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"' >> ~/.bashrc
            echo "Added krew to PATH in ~/.bashrc."
        fi
    else
        echo "krew is already installed."
    fi
}

# Function to install oidc-login plugin
install_oidc_login_plugin() {
    if kubectl krew list | grep -q 'oidc-login'; then
        echo "oidc-login plugin is already installed."
    else
        echo "Installing oidc-login plugin..."
        kubectl krew install oidc-login
    fi
}

# Main script execution
main() {
    check_command curl
    install_kubectl
    create_temp_kubeconfig
    install_krew
    install_oidc_login_plugin
    echo "kubectl setup complete! Please update the kubeconfig at ~/.kube/config with your cluster details."
}

main "$@"