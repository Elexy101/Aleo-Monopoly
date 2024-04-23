class Transition {
    program;
    functionName;
    inputs;
    constructor(program, functionName, inputs) {
        this.program = program;
        this.functionName = functionName;
        this.inputs = inputs;
    }
}
 class Transaction {
    address;
    chainId;
    transitions;
    fee;
    constructor(address, chainId, transitions, fee) {
        this.address = address;
        this.chainId = chainId;
        this.transitions = transitions;
        this.fee = fee;
    }
    static createTransaction(address, chainId, program, functionName, inputs, fee) {
        const transition = new Transition(program, functionName, inputs);
        return new Transaction(address, chainId, [transition], fee);
    }
}
//# sourceMappingURL=transaction.js.map