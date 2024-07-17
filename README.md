# MacroERC20

An ERC20 with built-in:
- `doTheMacro` - a multi call that passes the msg.sender as the first parameter
- Calling self enacts a special case that uses an overridden msgSender, without overriding the parameters

## Risks

Integrators should read the caller from calldata

The caller should be trusted only when:
- msg.sender == token
- caller is the first parameter of the function

## Example use cases

- Approve and Deposit directly into a vault

See `test_approve_and_deposit` for a very simple example

## Future

I had reviewed the Forwarded + Multicall exploit, hence my immediate reaction was to code the logic not to append data at the end of the bytes, we may be able to add data there by fully determining if there are safe ways the bytes payload