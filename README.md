# MacroERC20

An ERC20 with built-in:
- `doTheMacro` - a multi call that passes the msg.sender as the first parameter
- Calling self enacts a special case that uses an overridden msgSender, without overriding the parameters

## Risks

Integrators should read the caller from calldata

The caller should be trusted only when:
- msg.sender == token
- caller is the first parameter of the function