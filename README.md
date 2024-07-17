# MacroERC20

An ERC20 with built-in:
- Multicall with Forwarding, forwards the caller as the first parameter of each function

## Risks

Integrators should read the caller from calldata

The caller should be trusted only when:
- msg.sender == token
- caller is the first parameter of the function