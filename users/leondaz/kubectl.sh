[[ $commands[kubectl] ]] && source <(kubectl completion zsh)

alias k=kubectl;
alias kc='k config';
complete -o default -F __start_kubectl k;
alias kgp='k get pods';
alias kgnp='k get networkpolicy';
alias kdp='k describe pod';
alias kdnp='k describe networkpolicy';
alias klp='k logs pod';
alias ksetn='k config set-config --current --namespace';
alias kx='k exec -it';
alias kl='k logs';
alias klf='k logs -f';
