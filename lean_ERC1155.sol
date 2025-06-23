// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.1.0) (token/ERC1155/ERC1155.sol)

pragma solidity ^0.8.20;

import {IERC1155} from "./IERC1155.sol";
import {IERC1155MetadataURI} from "./extensions/IERC1155MetadataURI.sol";
import {ERC1155Utils} from "./utils/ERC1155Utils.sol";
import {Context} from "../../utils/Context.sol";
import {IERC165, ERC165} from "../../utils/introspection/ERC165.sol";
import {Arrays} from "../../utils/Arrays.sol";
import {IERC1155Errors} from "../../interfaces/draft-IERC6093.sol";

/**
 * @dev Implementation of the basic standard multi-token.
 * See https://eips.ethereum.org/EIPS/eip-1155
 * Originally based on code by Enjin: https://github.com/enjin/erc-1155
 */
abstract contract ERC1155 is Context, ERC165, IERC1155, IERC1155MetadataURI, IERC1155Errors {
    using Arrays for uint256[];
    using Arrays for address[];

    mapping(uint256 id => mapping(address account => uint256)) private _balances;

    mapping(address account => mapping(address operator => bool)) private _operatorApprovals;

    // Used as the URI for all token types by relying on ID substitution, e.g. https://token-cdn-domain/{id}.json
    string private _uri;

    /**
     * @dev See {_setURI}.
     */
    constructor(string memory uri_) {
        _setURI(uri_);
    }
    //     constructor (构造函数)
    // 功能作用: 合约部署时执行，用于初始化 ERC-1155 合约。它设置了所有代币的统一 URI。
    // 入参:
    // uri_ (string memory): 所有代币的元数据 URI。这个 URI 通常包含 {id} 占位符，客户端会用实际的代币 ID 替换它。
    // 返回值: 无

    /// @inheritdoc IERC165
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(IERC1155).interfaceId ||
            interfaceId == type(IERC1155MetadataURI).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /* /**
    /*supportsInterface
    功能作用: 用于检查合约是否支持某个接口。这是 ERC-165 标准的一部分，允许智能合约发现其他合约支持哪些接口。
    入参:
    interfaceId (bytes4): 要查询的接口的 ID。
    返回值:
    bool: 如果合约支持该接口，则返回 true；否则返回 false。
     * @dev See {IERC1155MetadataURI-uri}.
     *
     * This implementation returns the same URI for *all* token types. It relies
     * on the token type ID substitution mechanism
     * https://eips.ethereum.org/EIPS/eip-1155#metadata[defined in the ERC].
     *
     * Clients calling this function must replace the `\{id\}` substring with the
     * actual token type ID.
     */
    function uri(uint256 /* id */) public view virtual returns (string memory) {
        return _uri;
    }
    /* 功能作用: 返回所有代币的统一资源标识符 (URI)。这个 URI 用于指向代币的元数据。它通常包含一个 {id} 占位符，
        客户端会将其替换为实际的代币 ID。
    入参:
    id (uint256): 代币 ID。在此实现中，这个参数未被使用，因为所有代币都使用相同的 URI。
    返回值:
    string memory: 所有代币的元数据 URI。 */
    /// @inheritdoc IERC1155
    function balanceOf(address account, uint256 id) public view virtual returns (uint256) {
        return _balances[id][account];
    }
    /* balanceOf
    功能作用: 查询指定地址在特定代币 ID 下的余额。
    入参:
    account (address): 要查询余额的地址。
    id (uint256): 要查询的代币 ID。
    返回值:
    uint256: 指定地址拥有的特定代币的数量。 */
    /**
     * @dev See {IERC1155-balanceOfBatch}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(
        address[] memory accounts,
        uint256[] memory ids
    ) public view virtual returns (uint256[] memory) {
        if (accounts.length != ids.length) {
            revert ERC1155InvalidArrayLength(ids.length, accounts.length);
        }

        uint256[] memory batchBalances = new uint256[](accounts.length);

        for (uint256 i = 0; i < accounts.length; ++i) {
            batchBalances[i] = balanceOf(accounts.unsafeMemoryAccess(i), ids.unsafeMemoryAccess(i));
        }

        return batchBalances;
    }
   /*  balanceOfBatch
        功能作用: 批量查询多个地址在多个代币 ID 下的余额。
        入参:
        accounts (address[] memory): 要查询余额的地址数组。
        ids (uint256[] memory): 要查询的代币 ID 数组。accounts 和 ids 数组的长度必须相同，并且 accounts[i] 对应 ids[i]。
        返回值:
        uint256[] memory: 对应于 accounts 和 ids 数组中每个组合的余额数组 */

    /// @inheritdoc IERC1155
    function setApprovalForAll(address operator, bool approved) public virtual {
        _setApprovalForAll(_msgSender(), operator, approved);
    }
    /*   setApprovalForAll
    功能作用: 允许或取消授权一个操作员地址代表调用者管理其所有代币。
    入参:
    operator (address): 被授权或取消授权的操作员地址。
    approved (bool): 如果为 true，则授权；如果为 false，则取消授权。
    返回值: 无 */

    /// @inheritdoc IERC1155
    function isApprovedForAll(address account, address operator) public view virtual returns (bool) {
        return _operatorApprovals[account][operator];
    }
    /* isApprovedForAll
    功能作用: 查询一个操作员地址是否被授权管理某个地址的所有代币。
    入参:
    account (address): 代币所有者的地址。
    operator (address): 操作员地址。
    返回值:
    bool: 如果操作员被授权，则返回 true；否则返回 false */

    /// @inheritdoc IERC1155
    function safeTransferFrom(address from, address to, uint256 id, uint256 value, bytes memory data) public virtual {
        address sender = _msgSender();
        if (from != sender && !isApprovedForAll(from, sender)) {
            revert ERC1155MissingApprovalForAll(sender, from);
        }
        _safeTransferFrom(from, to, id, value, data);
    }
    /* safeTransferFrom
    功能作用: 从一个地址安全地转移单个代币到另一个地址。此函数会检查调用者是否被授权执行此操作。如果接收方是合约，还会执行 ERC-1155 接收器钩子。
    入参:
    from (address): 代币的来源地址。
    to (address): 代币的目标地址。
    id (uint256): 要转移的代币 ID。
    value (uint256): 要转移的代币数量。
    data (bytes memory): 附加数据，在调用接收方合约时传递。
    返回值: 无 */
    /// @inheritdoc IERC1155
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory values,
        bytes memory data
    ) public virtual {
        address sender = _msgSender();
        if (from != sender && !isApprovedForAll(from, sender)) {
            revert ERC1155MissingApprovalForAll(sender, from);
        }
        _safeBatchTransferFrom(from, to, ids, values, data);
    }
    /*  safeBatchTransferFrom
    功能作用: 从一个地址安全地批量转移多个代币到另一个地址。此函数会检查调用者是否被授权执行此操作。如果接收方是合约，还会执行 ERC-1155 批量接收器钩子。
    入参:
    from (address): 代币的来源地址。
    to (address): 代币的目标地址。
    ids (uint256[] memory): 要转移的代币 ID 数组。
    values (uint256[] memory): 对应要转移的每个代币 ID 的数量数组。ids 和 values 的长度必须相同。
    data (bytes memory): 附加数据，在调用接收方合约时传递。
    返回值: 无 */
    /**
     * @dev Transfers a `value` amount of tokens of type `id` from `from` to `to`. Will mint (or burn) if `from`
     * (or `to`) is the zero address.
     *
     * Emits a {TransferSingle} event if the arrays contain one element, and {TransferBatch} otherwise.
     *
     * Requirements:
     *
     * - If `to` refers to a smart contract, it must implement either {IERC1155Receiver-onERC1155Received}
     *   or {IERC1155Receiver-onERC1155BatchReceived} and return the acceptance magic value.
     * - `ids` and `values` must have the same length.
     *
     * NOTE: The ERC-1155 acceptance check is not performed in this function. See {_updateWithAcceptanceCheck} instead.
     */
    function _update(address from, address to, uint256[] memory ids, uint256[] memory values) internal virtual {
        if (ids.length != values.length) {
            revert ERC1155InvalidArrayLength(ids.length, values.length);
        }

        address operator = _msgSender();

        for (uint256 i = 0; i < ids.length; ++i) {
            uint256 id = ids.unsafeMemoryAccess(i);
            uint256 value = values.unsafeMemoryAccess(i);

            if (from != address(0)) {
                uint256 fromBalance = _balances[id][from];
                if (fromBalance < value) {
                    revert ERC1155InsufficientBalance(from, fromBalance, value, id);
                }
                unchecked {
                    // Overflow not possible: value <= fromBalance
                    _balances[id][from] = fromBalance - value;
                }
            }

            if (to != address(0)) {
                _balances[id][to] += value;
            }
        }

        if (ids.length == 1) {
            uint256 id = ids.unsafeMemoryAccess(0);
            uint256 value = values.unsafeMemoryAccess(0);
            emit TransferSingle(operator, from, to, id, value);
        } else {
            emit TransferBatch(operator, from, to, ids, values);
        }
    }
        /* _update (内部函数)
        功能作用: 执行实际的代币转移（包括铸造和销毁）。这是一个核心内部函数，不直接进行外部调用，也不执行接收方合约的钩子。
        入参:
        from (address): 代币的来源地址。如果是零地址 address(0)，表示铸造。
        to (address): 代币的目标地址。如果是零地址 address(0)，表示销毁。
        ids (uint256[] memory): 要更新的代币 ID 数组。
        values (uint256[] memory): 对应要更新的每个代币 ID 的数量数组。
        返回值: 无 */
    /**
     * @dev Version of {_update} that performs the token acceptance check by calling
     * {IERC1155Receiver-onERC1155Received} or {IERC1155Receiver-onERC1155BatchReceived} on the receiver address if it
     * contains code (eg. is a smart contract at the moment of execution).
     *
     * IMPORTANT: Overriding this function is discouraged because it poses a reentrancy risk from the receiver. So any
     * update to the contract state after this function would break the check-effect-interaction pattern. Consider
     * overriding {_update} instead.
     */
    function _updateWithAcceptanceCheck(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory values,
        bytes memory data
    ) internal virtual {
        _update(from, to, ids, values);
        if (to != address(0)) {
            address operator = _msgSender();
            if (ids.length == 1) {
                uint256 id = ids.unsafeMemoryAccess(0);
                uint256 value = values.unsafeMemoryAccess(0);
                ERC1155Utils.checkOnERC1155Received(operator, from, to, id, value, data);
            } else {
                ERC1155Utils.checkOnERC1155BatchReceived(operator, from, to, ids, values, data);
            }
        }
    }
    /* _updateWithAcceptanceCheck (内部函数)
    功能作用: 在执行代币转移（通过调用 _update）后，如果接收方是合约，则执行 ERC-1155 接收器钩子 (onERC1155Received 或 onERC1155BatchReceived)。这个函数是进行安全检查的关键部分，确保代币只发送到支持 ERC-1155 的合约。
    入参:
    from (address): 代币的来源地址。
    to (address): 代币的目标地址。
    ids (uint256[] memory): 要更新的代币 ID 数组。
    values (uint256[] memory): 对应要更新的每个代币 ID 的数量数组。
    data (bytes memory): 附加数据，在调用接收方合约时传递。
    返回值: 无 */
    /**
     * @dev Transfers a `value` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `from` must have a balance of tokens of type `id` of at least `value` amount.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function _safeTransferFrom(address from, address to, uint256 id, uint256 value, bytes memory data) internal {
        if (to == address(0)) {
            revert ERC1155InvalidReceiver(address(0));
        }
        if (from == address(0)) {
            revert ERC1155InvalidSender(address(0));
        }
        (uint256[] memory ids, uint256[] memory values) = _asSingletonArrays(id, value);
        _updateWithAcceptanceCheck(from, to, ids, values, data);
    }
    /*  _safeTransferFrom (内部函数)
    功能作用: 这是一个内部辅助函数，用于执行单个代币的安全转移。它在调用 _updateWithAcceptanceCheck 之前对输入进行初步检查（例如，to 和 from 不能是零地址）。
    入参:
    from (address): 代币的来源地址。
    to (address): 代币的目标地址。
    id (uint256): 要转移的代币 ID。
    value (uint256): 要转移的代币数量。
    data (bytes memory): 附加数据。
    返回值: 无 */
    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {_safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     * - `ids` and `values` must have the same length.
     */
    function _safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory values,
        bytes memory data
    ) internal {
        if (to == address(0)) {
            revert ERC1155InvalidReceiver(address(0));
        }
        if (from == address(0)) {
            revert ERC1155InvalidSender(address(0));
        }
        _updateWithAcceptanceCheck(from, to, ids, values, data);
    }
    /* _safeBatchTransferFrom (内部函数)
    功能作用: 这是一个内部辅助函数，用于执行批量代币的安全转移。它在调用 _updateWithAcceptanceCheck 之前对输入进行初步检查（例如，to 和 from 不能是零地址）。
    入参:
    from (address): 代币的来源地址。
    to (address): 代币的目标地址。
    ids (uint256[] memory): 要转移的代币 ID 数组。
    values (uint256[] memory): 对应要转移的每个代币 ID 的数量数组。
    data (bytes memory): 附加数据。
    返回值: 无 */
    /**
     * @dev Sets a new URI for all token types, by relying on the token type ID
     * substitution mechanism
     * https://eips.ethereum.org/EIPS/eip-1155#metadata[defined in the ERC].
     *
     * By this mechanism, any occurrence of the `\{id\}` substring in either the
     * URI or any of the values in the JSON file at said URI will be replaced by
     * clients with the token type ID.
     *
     * For example, the `https://token-cdn-domain/\{id\}.json` URI would be
     * interpreted by clients as
     * `https://token-cdn-domain/000000000000000000000000000000000000000000000000000000000004cce0.json`
     * for token type ID 0x4cce0.
     *
     * See {uri}.
     *
     * Because these URIs cannot be meaningfully represented by the {URI} event,
     * this function emits no events.
     */
    function _setURI(string memory newuri) internal virtual {
        _uri = newuri;
    }
    /*     _setURI (内部函数)
    功能作用: 设置所有代币的新 URI。这个函数通常由合约的部署者或管理员调用。
    入参:
    newuri (string memory): 新的 URI 字符串。
    返回值: 无 */
    /**
     * @dev Creates a `value` amount of tokens of type `id`, and assigns them to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function _mint(address to, uint256 id, uint256 value, bytes memory data) internal {
        if (to == address(0)) {
            revert ERC1155InvalidReceiver(address(0));
        }
        (uint256[] memory ids, uint256[] memory values) = _asSingletonArrays(id, value);
        _updateWithAcceptanceCheck(address(0), to, ids, values, data);
    }
    /* _mint (内部函数)
    功能作用: 铸造 (创建) 少量指定 ID 的代币并分配给目标地址。它会调用 _updateWithAcceptanceCheck 来处理实际的余额更新和接收方检查。
    入参:
    to (address): 接收新铸造代币的地址。不能是零地址。
    id (uint256): 要铸造的代币 ID。
    value (uint256): 要铸造的代币数量。
    data (bytes memory): 附加数据，传递给接收方合约。
    返回值: 无 */
    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {_mint}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `ids` and `values` must have the same length.
     * - `to` cannot be the zero address.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function _mintBatch(address to, uint256[] memory ids, uint256[] memory values, bytes memory data) internal {
        if (to == address(0)) {
            revert ERC1155InvalidReceiver(address(0));
        }
        _updateWithAcceptanceCheck(address(0), to, ids, values, data);
    }
    /* _mintBatch (内部函数)
    功能作用: 批量铸造 (创建) 多个指定 ID 的代币并分配给目标地址。它会调用 _updateWithAcceptanceCheck 来处理实际的余额更新和接收方检查。
    入参:
    to (address): 接收新铸造代币的地址。不能是零地址。
    ids (uint256[] memory): 要铸造的代币 ID 数组。
    values (uint256[] memory): 对应要铸造的每个代币 ID 的数量数组。
    data (bytes memory): 附加数据，传递给接收方合约。
    返回值: 无 */
    /**
     * @dev Destroys a `value` amount of tokens of type `id` from `from`
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `from` must have at least `value` amount of tokens of type `id`.
     */
    function _burn(address from, uint256 id, uint256 value) internal {
        if (from == address(0)) {
            revert ERC1155InvalidSender(address(0));
        }
        (uint256[] memory ids, uint256[] memory values) = _asSingletonArrays(id, value);
        _updateWithAcceptanceCheck(from, address(0), ids, values, "");
    }
    /*     _burn (内部函数)
    功能作用: 销毁 (销毁) 少量指定 ID 的代币。它会调用 _updateWithAcceptanceCheck 来处理实际的余额更新。
    入参:
    from (address): 代币的来源地址。不能是零地址。
    id (uint256): 要销毁的代币 ID。
    value (uint256): 要销毁的代币数量。
    返回值: 无 */
    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {_burn}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `from` must have at least `value` amount of tokens of type `id`.
     * - `ids` and `values` must have the same length.
     */
    function _burnBatch(address from, uint256[] memory ids, uint256[] memory values) internal {
        if (from == address(0)) {
            revert ERC1155InvalidSender(address(0));
        }
        _updateWithAcceptanceCheck(from, address(0), ids, values, "");
    }
     /*    _burnBatch (内部函数)
    功能作用: 批量销毁 (销毁) 多个指定 ID 的代币。它会调用 _updateWithAcceptanceCheck 来处理实际的余额更新。
    入参:
    from (address): 代币的来源地址。不能是零地址。
    ids (uint256[] memory): 要销毁的代币 ID 数组。
    values (uint256[] memory): 对应要销毁的每个代币 ID 的数量数组。
    返回值: 无 */
    /**
     * @dev Approve `operator` to operate on all of `owner` tokens
     *
     * Emits an {ApprovalForAll} event.
     *
     * Requirements:
     *
     * - `operator` cannot be the zero address.
     */
    function _setApprovalForAll(address owner, address operator, bool approved) internal virtual {
        if (operator == address(0)) {
            revert ERC1155InvalidOperator(address(0));
        }
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }
    /*     _setApprovalForAll (内部函数)
    功能作用: 内部函数，用于设置或取消操作员对所有者的所有代币的授权。它会发出 ApprovalForAll 事件。
    入参:
    owner (address): 代币所有者的地址。
    operator (address): 被授权或取消授权的操作员地址。不能是零地址。
    approved (bool): 如果为 true，则授权；如果为 false，则取消授权。
    返回值: 无 */
    /**
     * @dev Creates an array in memory with only one value for each of the elements provided.
     */
    function _asSingletonArrays(
        uint256 element1,
        uint256 element2
    ) private pure returns (uint256[] memory array1, uint256[] memory array2) {
        assembly ("memory-safe") {
            // Load the free memory pointer
            array1 := mload(0x40)
            // Set array length to 1
            mstore(array1, 1)
            // Store the single element at the next word after the length (where content starts)
            mstore(add(array1, 0x20), element1)

            // Repeat for next array locating it right after the first array
            array2 := add(array1, 0x40)
            mstore(array2, 1)
            mstore(add(array2, 0x20), element2)

            // Update the free memory pointer by pointing after the second array
            mstore(0x40, add(array2, 0x40))
        }
    }
    /* _asSingletonArrays (私有纯函数)
    功能作用: 这是一个低级汇编函数，用于将两个单独的 uint256 值高效地打包成两个各自只包含一个元素的 uint256[] 数组。它直接操作内存，以优化 Gas 成本。
    入参:
    element1 (uint256): 第一个要放入数组的元素。
    element2 (uint256): 第二个要放入数组的元素。
    返回值:
    array1 (uint256[] memory): 包含 element1 的单元素数组。
    array2 (uint256[] memory): 包含 element2 的单元素数组 */
}