# MacroERC20

An ERC20 with built-in:
- `doTheMacro` - a multi call that passes the msg.sender as the first parameter

TODO
- Multicall to self with forwarding, to combine transfer, approves, etc...

TODO
- Mix both of those

## Risks

Integrators should read the caller from calldata

The caller should be trusted only when:
- msg.sender == token
- caller is the first parameter of the function